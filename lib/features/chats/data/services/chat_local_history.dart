import 'dart:async';
import 'dart:typed_data';
import 'package:tureon/core/storage/chat_store.dart';
import 'package:tureon/core/storage/message_records.dart';
import 'package:tureon/generated/proto/tureon.pb.dart' as pb;
import '../../domain/chat_message.dart' as domain;

/// Reactive local history and unread state; streams never become history storage.
class ChatLocalHistory {
  ChatLocalHistory({required this.store, required this.scheduleOutbox});
  final ChatStore store;
  final void Function() scheduleOutbox;
  final Map<String, int> _activeChatWatchers = {};
  Stream<List<domain.ChatMessage>> watchMessages({
    required String chatId,
    int limit = 100,
  }) {
    final source = store.watchChatMessages(chatId, limit: limit);
    return Stream<List<domain.ChatMessage>>.multi((controller) {
      _registerChatWatcher(chatId);
      final subscription = source.listen(
        controller.add,
        onError: (Object error, StackTrace stackTrace) =>
            controller.addError(error, stackTrace),
        onDone: controller.close,
      );
      controller.onCancel = () async {
        _unregisterChatWatcher(chatId);
        await subscription.cancel();
      };
    });
  }

  Stream<domain.ChatMessage> streamMessages({required String chatId}) {
    late final StreamController<domain.ChatMessage> controller;
    StreamSubscription<List<domain.ChatMessage>>? subscription;
    final seen = <String>{};

    void startListening() {
      _registerChatWatcher(chatId);
      subscription = store.watchChatMessages(chatId).listen((messages) {
        for (final message in messages) {
          if (seen.add(message.messageId)) {
            controller.add(message);
          }
        }
      });
    }

    void stopListening() {
      _unregisterChatWatcher(chatId);
      subscription?.cancel();
    }

    controller = StreamController<domain.ChatMessage>.broadcast(
      onListen: startListening,
      onCancel: stopListening,
    );
    return controller.stream;
  }

  Future<void> markConversationRead({
    required String chatId,
    required String peerRecipientId,
  }) {
    final session = store.loadSession();
    if (session == null) {
      throw StateError('A signed-in device is required to mark messages read.');
    }
    final unreadMessages = store
        .loadChatMessages(chatId)
        .where(
          (message) =>
              message.senderRecipientId != session.userId &&
              message.status != domain.ChatDeliveryStatus.read,
        )
        .toList();
    final now = DateTime.now().toUtc();
    final queuedCommands = unreadMessages
        .map((message) {
          final request = pb.SendReadReceiptRequest(
            senderRecipientId: message.senderRecipientId,
            messageId: message.messageId,
          );
          return PendingChatCommand(
            accountId: session.userId,
            commandId: 'read:${message.messageId}',
            relatedMessageId: message.messageId,
            type: PendingChatCommandType.readReceipt,
            payload: Uint8List.fromList(request.writeToBuffer()),
            attempts: 0,
            nextAttemptAt: now,
            createdAt: now,
          );
        })
        .toList(growable: false);
    store.enqueueReadReceipts(
      commands: queuedCommands,
      readMessageIds: unreadMessages
          .map((message) => message.messageId)
          .toList(),
      peerRecipientId: peerRecipientId,
    );
    if (queuedCommands.isNotEmpty) scheduleOutbox();
    return Future<void>.value();
  }

  bool isBeingWatched(String chatId) => (_activeChatWatchers[chatId] ?? 0) > 0;

  void _registerChatWatcher(String chatId) {
    _activeChatWatchers.update(chatId, (count) => count + 1, ifAbsent: () => 1);
  }

  void _unregisterChatWatcher(String chatId) {
    final updated = (_activeChatWatchers[chatId] ?? 1) - 1;
    if (updated <= 0) {
      _activeChatWatchers.remove(chatId);
    } else {
      _activeChatWatchers[chatId] = updated;
    }
  }

  Future<void> updatePreview(String recipientId, String body) async {
    final recipient = store.loadRecipient(recipientId);
    if (recipient == null) return;
    final updated = recipient.copyWith(lastMessage: body);
    await store.saveRecipient(updated);
  }

  Future<void> updatePreviewFromHistory(
    String chatId,
    String recipientId,
  ) async {
    final messages = store.loadChatMessages(chatId);
    await updatePreview(
      recipientId,
      messages.isEmpty ? '' : messages.last.body,
    );
  }
}
