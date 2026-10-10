import 'dart:async';
import 'dart:developer' as developer;

import 'package:tureon/generated/proto/tureon.pb.dart' as pb;
import 'package:tureon/core/protocol/recipient.dart';
import 'package:tureon/core/storage/chat_store.dart';
import 'package:tureon/core/storage/message_records.dart';
import 'package:tureon/features/chats/domain/chat_message.dart' as domain;
import 'chat_ack_queue.dart';

class QueuedIncomingMessage {
  const QueuedIncomingMessage({
    required this.delivery,
    required this.message,
    required this.recipient,
    required this.session,
    required this.persisted,
  });

  final pb.MessageDelivery delivery;
  final domain.ChatMessage message;
  final Recipient recipient;
  final UserSession session;
  final Completer<void> persisted;
}

class ChatInboundStreamHandler {
  ChatInboundStreamHandler({
    required this.store,
    required this.ackQueue,
    required this.incomingBatchWindow,
    required this.maxIncomingBatchSize,
    required this.isCurrentSession,
    required this.isChatBeingWatched,
    required this.queueReadReceipts,
  });

  final ChatStore store;
  final ChatAckQueue ackQueue;
  final Duration incomingBatchWindow;
  final int maxIncomingBatchSize;
  final bool Function(UserSession session) isCurrentSession;
  final bool Function(String chatId) isChatBeingWatched;
  final void Function(List<pb.MessageDelivery>, UserSession) queueReadReceipts;

  final List<QueuedIncomingMessage> _incomingMessageBatch = [];
  Timer? _incomingBatchTimer;
  Future<void> _incomingWriteQueue = Future<void>.value();

  void stop() {
    _incomingBatchTimer?.cancel();
    _incomingBatchTimer = null;
    for (final queued in _incomingMessageBatch) {
      if (!queued.persisted.isCompleted) {
        queued.persisted.completeError(
          StateError('Incoming message persistence was stopped.'),
        );
      }
    }
    _incomingMessageBatch.clear();
  }

  Future<void> queueIncomingMessage({
    required pb.MessageDelivery delivery,
    required domain.ChatMessage message,
    required Recipient recipient,
    required UserSession session,
  }) {
    final persisted = Completer<void>();
    _incomingMessageBatch.add(
      QueuedIncomingMessage(
        delivery: delivery,
        message: message,
        recipient: recipient,
        session: session,
        persisted: persisted,
      ),
    );
    if (_incomingMessageBatch.length >= maxIncomingBatchSize) {
      _incomingBatchTimer?.cancel();
      _incomingBatchTimer = null;
      unawaited(flushIncomingMessages());
      return persisted.future;
    }
    _incomingBatchTimer ??= Timer(incomingBatchWindow, () {
      _incomingBatchTimer = null;
      unawaited(flushIncomingMessages());
    });
    return persisted.future;
  }

  Future<void> flushIncomingMessages() async {
    if (_incomingMessageBatch.isEmpty) return;
    final batch = List<QueuedIncomingMessage>.of(_incomingMessageBatch);
    _incomingMessageBatch.clear();
    final session = batch.first.session;
    final operation = _incomingWriteQueue.then((_) async {
      try {
        if (!isCurrentSession(session)) {
          throw StateError('The account changed before messages were saved.');
        }
        final viewedIncomingMessageIds = <String>{};
        final writes = batch
            .map((queued) {
              final isIncoming =
                  queued.delivery.senderRecipientId != session.userId;
              final isViewed =
                  isIncoming && isChatBeingWatched(queued.message.chatId);
              if (isViewed) {
                viewedIncomingMessageIds.add(queued.message.messageId);
              }
              return IncomingMessageWrite(
                message: queued.message,
                recipient: queued.recipient,
                incrementUnread: isIncoming && !isViewed,
              );
            })
            .toList(growable: false);
        await store.saveIncomingMessages(writes);
        if (!isCurrentSession(session)) {
          throw StateError('The account changed while messages were saved.');
        }
        queueReadReceipts([
          for (final queued in batch)
            if (viewedIncomingMessageIds.contains(queued.message.messageId))
              queued.delivery,
        ], session);
        for (final queued in batch) {
          ackQueue.acknowledgePersisted(queued.delivery);
          if (!queued.persisted.isCompleted) queued.persisted.complete();
        }
      } catch (error, stackTrace) {
        for (final queued in batch) {
          if (!queued.persisted.isCompleted) {
            queued.persisted.completeError(error, stackTrace);
          }
        }
        developer.log(
          'Failed to persist incoming message batch',
          error: error,
          stackTrace: stackTrace,
        );
      }
    });
    _incomingWriteQueue = operation;
    await operation;
  }
}
