import 'dart:typed_data';

import 'package:tureon/core/storage/chat_store.dart';
import 'package:tureon/core/storage/message_records.dart';
import 'package:tureon/generated/proto/tureon.pb.dart' as pb;

/// Persists viewed-message receipts without waiting on the shared gRPC stream.
class ChatReadReceiptQueue {
  ChatReadReceiptQueue({
    required this.store,
    required this.isCurrentSession,
    required this.scheduleOutbox,
  });

  final ChatStore store;
  final bool Function(UserSession) isCurrentSession;
  final void Function() scheduleOutbox;

  void enqueue(List<pb.MessageDelivery> deliveries, UserSession session) {
    if (!isCurrentSession(session) || deliveries.isEmpty) return;
    final byChat = <String, List<pb.MessageDelivery>>{};
    for (final delivery in deliveries) {
      if (delivery.senderRecipientId == session.userId) continue;
      final local = store.loadChatMessage(delivery.messageId);
      if (local == null) continue;
      byChat.putIfAbsent(local.chatId, () => []).add(delivery);
    }
    final now = DateTime.now().toUtc();
    for (final entry in byChat.entries) {
      store.enqueueReadReceipts(
        commands: [
          for (final delivery in entry.value)
            PendingChatCommand(
              accountId: session.userId,
              commandId: 'read:${delivery.messageId}',
              relatedMessageId: delivery.messageId,
              type: PendingChatCommandType.readReceipt,
              payload: Uint8List.fromList(
                pb.SendReadReceiptRequest(
                  senderRecipientId: delivery.senderRecipientId,
                  messageId: delivery.messageId,
                ).writeToBuffer(),
              ),
              attempts: 0,
              nextAttemptAt: now,
              createdAt: now,
            ),
        ],
        readMessageIds: [
          for (final delivery in entry.value) delivery.messageId,
        ],
        peerRecipientId: entry.key,
      );
    }
    if (byChat.isNotEmpty) scheduleOutbox();
  }
}
