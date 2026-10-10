import 'dart:developer' as developer;

import 'package:tureon/core/storage/chat_store.dart';
import 'package:tureon/core/storage/message_records.dart';
import 'package:tureon/generated/proto/tureon.pb.dart' as pb;

import 'messaging_rpc.dart';

/// Drains a bounded slice of durable receipts/mutations between message batches.
/// Only one command per message is selected, preserving that message's order.
class ChatPendingCommandProcessor {
  ChatPendingCommandProcessor({
    required this.rpc,
    required this.store,
    required this.batchSize,
    required this.maxConcurrentCommands,
    required this.isCurrentWorker,
    required this.retryDelay,
    required this.scheduleRetry,
  });

  final MessagingRpc rpc;
  final ChatStore store;
  final int batchSize;
  final int maxConcurrentCommands;
  final bool Function(UserSession, int) isCurrentWorker;
  final Duration Function(int) retryDelay;
  final void Function(Duration) scheduleRetry;

  Future<bool> drainBatch(UserSession session, int generation) async {
    if (!isCurrentWorker(session, generation)) return false;
    final queued = store.loadPendingChatCommands(
      session.userId,
      limit: batchSize,
    );
    final now = DateTime.now().toUtc();
    final selectedMessages = <String>{};
    final due = <PendingChatCommand>[];
    for (final command in queued) {
      if (!selectedMessages.add(command.relatedMessageId)) continue;
      if (store.hasPendingOutboxForMessage(
        session.userId,
        command.relatedMessageId,
      )) {
        continue;
      }
      if (command.nextAttemptAt.isAfter(now)) {
        scheduleRetry(command.nextAttemptAt.difference(now));
        continue;
      }
      due.add(command);
      if (due.length == maxConcurrentCommands) break;
    }
    final results = await Future.wait([
      for (final command in due) _send(command, session, generation),
    ]);
    return results.any((removed) => removed);
  }

  Future<bool> _send(
    PendingChatCommand command,
    UserSession session,
    int generation,
  ) async {
    if (!isCurrentWorker(session, generation)) return false;
    try {
      switch (command.type) {
        case PendingChatCommandType.messageMutation:
          await rpc.sendMessageMutation(
            pb.SendMessageMutationRequest.fromBuffer(command.payload),
          );
        case PendingChatCommandType.readReceipt:
          await rpc.sendReadReceipt(
            pb.SendReadReceiptRequest.fromBuffer(command.payload),
          );
      }
      if (!isCurrentWorker(session, generation)) return false;
      store.removePendingChatCommand(session.userId, command.commandId);
      return true;
    } catch (error, stackTrace) {
      if (!isCurrentWorker(session, generation)) return false;
      final delay = retryDelay(command.attempts + 1);
      store.retryPendingChatCommand(
        command,
        nextAttemptAt: DateTime.now().toUtc().add(delay),
      );
      scheduleRetry(delay);
      developer.log(
        'Queued chat command will be retried',
        name: 'tureon.messaging',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }
}
