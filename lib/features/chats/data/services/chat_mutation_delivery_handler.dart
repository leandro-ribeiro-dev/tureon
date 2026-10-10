import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:typed_data';

import 'package:tureon/core/crypto/secret_chat_crypto_port.dart';
import 'package:tureon/core/storage/chat_store.dart';
import 'package:tureon/core/storage/message_records.dart';
import 'package:tureon/features/chats/domain/chat_message.dart' as domain;
import 'package:tureon/features/chats/domain/chat_repository.dart'
    show secretChatLocalId;
import 'package:tureon/generated/proto/tureon.pb.dart' as pb;

import 'chat_ack_queue.dart';

typedef CurrentChatSession = bool Function(UserSession session);
typedef ChatPreviewUpdater =
    Future<void> Function(String chatId, String recipientId);

/// Applies incoming edits/deletions only after their source message is local.
/// Per-message queues preserve mutation order without serializing unrelated chats.
class ChatMutationDeliveryHandler {
  ChatMutationDeliveryHandler({
    required this.store,
    required this.ackQueue,
    required this.currentSession,
    required this.secretCrypto,
    required this.updatePreview,
  });

  static const _maxDeferredMutations = 256;

  final ChatStore store;
  final ChatAckQueue ackQueue;
  final CurrentChatSession currentSession;
  final SecretChatCryptoPort? Function() secretCrypto;
  final ChatPreviewUpdater updatePreview;

  final Map<String, Future<void>> _messageQueues = {};
  final Map<String, List<pb.MessageDelivery>> _deferred = {};
  int _deferredCount = 0;

  Future<void> enqueue(pb.MessageDelivery delivery, UserSession session) {
    final messageId = delivery.messageId;
    final previous = _messageQueues[messageId] ?? Future<void>.value();
    final completion = Completer<void>();
    late final Future<void> queued;
    queued = previous.then((_) async {
      try {
        await _apply(delivery, session);
        completion.complete();
      } catch (error, stackTrace) {
        completion.completeError(error, stackTrace);
      }
    });
    _messageQueues[messageId] = queued;
    unawaited(
      queued.whenComplete(() {
        if (identical(_messageQueues[messageId], queued)) {
          _messageQueues.remove(messageId);
        }
      }),
    );
    return completion.future;
  }

  Future<void> replayDeferred(String messageId, UserSession session) async {
    final deferred = _deferred.remove(messageId);
    if (deferred == null) return;
    _deferredCount -= deferred.length;
    for (final mutation in deferred) {
      if (!currentSession(session)) return;
      await enqueue(mutation, session);
    }
  }

  void clearDeferred() {
    _deferred.clear();
    _deferredCount = 0;
  }

  Future<void> _apply(pb.MessageDelivery delivery, UserSession session) async {
    if (!currentSession(session)) return;
    final eventId = delivery.eventId.isNotEmpty
        ? delivery.eventId
        : delivery.deliveryId;
    if (eventId.isEmpty || delivery.messageId.isEmpty) {
      throw StateError('Message mutation is missing its event or message id.');
    }
    final isDeleted = switch (delivery.eventType) {
      pb.MessageDeliveryEventType.MESSAGE_DELIVERY_EVENT_TYPE_DELETED => true,
      pb.MessageDeliveryEventType.MESSAGE_DELIVERY_EVENT_TYPE_EDITED => false,
      _ => throw StateError('Message mutation has an unsupported event type.'),
    };
    final localChatId = delivery.chatKind == pb.ChatKind.CHAT_KIND_SECRET
        ? secretChatLocalId(
            recipientId: delivery.senderRecipientId,
            firstDeviceId: delivery.senderDeviceId,
            secondDeviceId: delivery.targetDeviceId,
          )
        : delivery.chatId;
    if (store.hasAppliedMessageMutation(eventId)) {
      await _updatePreviewForDelivery(localChatId, delivery);
      if (currentSession(session)) ackQueue.acknowledgePersisted(delivery);
      return;
    }
    final existing = store.loadChatMessage(delivery.messageId);
    if (existing == null && !store.isChatMessageDeleted(delivery.messageId)) {
      if (currentSession(session)) _defer(delivery);
      return;
    }

    final editedAt = DateTime.fromMillisecondsSinceEpoch(
      delivery.createdAt.toInt() * 1000,
      isUtc: true,
    );
    Uint8List plaintext;
    if (delivery.chatKind == pb.ChatKind.CHAT_KIND_SECRET) {
      final crypto = secretCrypto();
      if (crypto == null) {
        throw StateError(
          'Secret-chat encryption must be initialized before mutation delivery.',
        );
      }
      plaintext = Uint8List.fromList(
        await crypto.decrypt(
          secretChatId: delivery.senderRecipientId,
          ciphertext: Uint8List.fromList(delivery.payload),
        ),
      );
    } else if (delivery.chatKind == pb.ChatKind.CHAT_KIND_NORMAL) {
      plaintext = Uint8List.fromList(delivery.payload);
    } else {
      throw StateError('Message mutation has an unsupported chat kind.');
    }
    if (!currentSession(session)) return;

    if (store.isChatMessageDeleted(delivery.messageId)) {
      store.applyChatMessageDeletion(delivery.messageId, eventId);
      await _updatePreviewForDelivery(localChatId, delivery);
      if (currentSession(session)) ackQueue.acknowledgePersisted(delivery);
      return;
    }
    if (existing == null) {
      throw StateError('Message mutation has no local source message.');
    }
    if (isDeleted) {
      store.applyChatMessageDeletion(delivery.messageId, eventId);
      await _updatePreviewForDelivery(existing.chatId, delivery);
    } else {
      final edited = domain.ChatMessage(
        messageId: existing.messageId,
        chatId: existing.chatId,
        senderRecipientId: existing.senderRecipientId,
        body: utf8.decode(plaintext),
        createdAt: existing.createdAt,
        type: existing.type,
        replyToMessageId: existing.replyToMessageId,
        editedAt: editedAt,
        status: existing.status,
      );
      store.applyChatMessageEdit(edited, eventId);
      await _updatePreviewForDelivery(edited.chatId, delivery);
    }
    if (!currentSession(session)) return;
    ackQueue.acknowledgePersisted(delivery);
  }

  Future<void> _updatePreviewForDelivery(
    String localChatId,
    pb.MessageDelivery delivery,
  ) async {
    if (delivery.chatKind == pb.ChatKind.CHAT_KIND_SECRET) return;
    await updatePreview(localChatId, delivery.chatId);
  }

  void _defer(pb.MessageDelivery delivery) {
    final eventId = delivery.eventId.isNotEmpty
        ? delivery.eventId
        : delivery.deliveryId;
    final queued = _deferred[delivery.messageId];
    if (queued?.any(
          (event) =>
              (event.eventId.isNotEmpty ? event.eventId : event.deliveryId) ==
              eventId,
        ) ??
        false) {
      return;
    }
    if (_deferredCount >= _maxDeferredMutations) {
      developer.log(
        'Deferred mutation limit reached; delivery remains unacknowledged',
        name: 'tureon.messaging',
      );
      return;
    }
    _deferred.putIfAbsent(delivery.messageId, () => []).add(delivery);
    _deferredCount++;
  }
}
