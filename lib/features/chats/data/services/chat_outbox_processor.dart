import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:grpc/grpc.dart';

import 'package:tureon/generated/proto/tureon.pb.dart' as pb;
import 'package:tureon/core/storage/chat_store.dart';
import 'package:tureon/core/storage/message_records.dart';
import 'package:tureon/core/protocol/recipient_type.dart';
import 'package:tureon/features/chats/domain/chat_message.dart' as domain;
import 'messaging_rpc.dart';
import 'chat_pending_command_processor.dart';
import 'package:tureon/features/chats/data/mappers/chat_message_mapper.dart';

class ChatOutboxProcessor {
  ChatOutboxProcessor({
    required this.rpc,
    required this.store,
    required this.retryBaseDelay,
    required this.retryMaxDelay,
    required this.maxConcurrentSends,
    required this.outboxBatchSize,
    required this.isSyncStopped,
    required this.isChatBeingWatched,
    this.prepareMessagePayload,
    Random? random,
  }) : _random = random ?? Random() {
    _pendingCommands = ChatPendingCommandProcessor(
      rpc: rpc,
      store: store,
      batchSize: outboxBatchSize,
      maxConcurrentCommands: maxConcurrentSends,
      isCurrentWorker: _isCurrentWorker,
      retryDelay: _retryDelay,
      scheduleRetry: _scheduleOutboxRetry,
    );
  }

  final MessagingRpc rpc;
  final ChatStore store;
  final Duration retryBaseDelay;
  final Duration retryMaxDelay;
  final int maxConcurrentSends;
  final int outboxBatchSize;
  final bool Function() isSyncStopped;
  final bool Function(String chatId) isChatBeingWatched;
  final Future<List<int>> Function(OutboxRecord outbox)? prepareMessagePayload;
  final Random _random;
  late final ChatPendingCommandProcessor _pendingCommands;

  Timer? _outboxRetryTimer;
  DateTime? _outboxRetryAt;
  Timer? _outboxExpiryTimer;
  Future<void>? _outboxWorker;
  int _outboxGeneration = 0;
  bool _outboxRerunRequested = false;

  int get generation => _outboxGeneration;

  void incrementGeneration() {
    _outboxGeneration++;
  }

  void stop() {
    _outboxGeneration++;
    _outboxRetryTimer?.cancel();
    _outboxRetryTimer = null;
    _outboxRetryAt = null;
    _outboxExpiryTimer?.cancel();
    _outboxExpiryTimer = null;
    _outboxWorker = null;
    _outboxRerunRequested = false;
  }

  void scheduleOutboxWorker() {
    if (isSyncStopped()) return;
    _expireDueMessagesAndScheduleCheck();
    if (!rpc.isReady) return;
    _outboxRetryTimer?.cancel();
    _outboxRetryAt = null;
    if (_outboxWorker != null) {
      _outboxRetryTimer = null;
      _outboxRerunRequested = true;
      return;
    }
    _outboxRetryTimer = Timer(Duration.zero, () {
      _outboxRetryTimer = null;
      _startOutboxWorker();
    });
  }

  void scheduleExpirationChecks() {
    if (!isSyncStopped()) _expireDueMessagesAndScheduleCheck();
  }

  void _expireDueMessagesAndScheduleCheck() {
    final session = store.loadSession();
    if (session == null) return;
    final heads = store.loadOutboxHeads(
      session.userId,
      session.deviceId,
      limit: outboxBatchSize,
    );
    final now = DateTime.now().toUtc();
    final active = <OutboxRecord>[];
    for (final record in heads) {
      if (record.status == OutboxStatus.failed) continue;
      if (!record.expiresAt.isAfter(now)) {
        store.expireOutbox(record);
      } else {
        active.add(record);
      }
    }
    _outboxExpiryTimer?.cancel();
    if (active.isEmpty) {
      _outboxExpiryTimer = null;
      return;
    }
    final nextExpiry = active
        .map((record) => record.expiresAt)
        .reduce((left, right) => left.isBefore(right) ? left : right);
    final delay = nextExpiry.difference(now);
    _outboxExpiryTimer = Timer(delay.isNegative ? Duration.zero : delay, () {
      _outboxExpiryTimer = null;
      scheduleOutboxWorker();
    });
  }

  void _startOutboxWorker() {
    if (isSyncStopped() || !rpc.isReady || _outboxWorker != null) return;
    final session = store.loadSession();
    if (session == null) return;
    final gen = _outboxGeneration;
    final worker = _drainOutbox(session, gen);
    _outboxWorker = worker;
    unawaited(
      worker
          .then<void>(
            (_) {},
            onError: (Object error, StackTrace stackTrace) {
              developer.log(
                'Message outbox worker failed',
                error: error,
                stackTrace: stackTrace,
              );
              if (_isCurrentWorker(session, gen)) {
                _scheduleOutboxRetry(const Duration(seconds: 1));
              }
            },
          )
          .whenComplete(() {
            if (!identical(_outboxWorker, worker)) return;
            _outboxWorker = null;
            if (_outboxRerunRequested && _isCurrentWorker(session, gen)) {
              _outboxRerunRequested = false;
              scheduleOutboxWorker();
            }
          }),
    );
  }

  Future<void> _drainOutbox(UserSession session, int gen) async {
    while (_isCurrentWorker(session, gen) && rpc.isReady) {
      final commandsAdvanced = await _pendingCommands.drainBatch(session, gen);
      if (!_isCurrentWorker(session, gen)) return;
      final conversationHeads = store.loadOutboxHeads(
        session.userId,
        session.deviceId,
        limit: outboxBatchSize,
      );
      final now = DateTime.now().toUtc();
      final expired = conversationHeads
          .where(
            (record) =>
                record.status != OutboxStatus.failed &&
                !record.expiresAt.isAfter(now),
          )
          .toList(growable: false);
      for (final record in expired) {
        store.expireOutbox(record);
      }
      if (expired.isNotEmpty) continue;
      final due =
          conversationHeads
              .where(
                (record) =>
                    record.status == OutboxStatus.pending &&
                    !record.nextAttemptAt.isAfter(now),
              )
              .toList()
            ..sort((left, right) {
              final created = left.createdAt.compareTo(right.createdAt);
              return created != 0
                  ? created
                  : left.messageId.compareTo(right.messageId);
            });
      if (due.isEmpty) {
        if (commandsAdvanced) continue;
        final nextAttempt = conversationHeads
            .where((record) => record.status == OutboxStatus.pending)
            .map((record) => record.nextAttemptAt)
            .fold<DateTime?>(null, (earliest, attemptAt) {
              if (earliest == null || attemptAt.isBefore(earliest)) {
                return attemptAt;
              }
              return earliest;
            });
        if (nextAttempt != null) {
          final delay = nextAttempt.difference(now);
          _scheduleOutboxRetry(delay.isNegative ? Duration.zero : delay);
        }
        return;
      }
      await _sendOutboxBatch(
        due.take(maxConcurrentSends).toList(growable: false),
        session,
        gen,
      );
    }
  }

  Future<void> _sendOutboxBatch(
    List<OutboxRecord> outboxBatch,
    UserSession session,
    int gen,
  ) async {
    for (final outbox in outboxBatch) {
      store.markOutboxSending(outbox);
    }
    List<pb.ChatStreamBatchResult> results;
    try {
      final commands = <pb.ChatStreamBatchCommand>[];
      for (final outbox in outboxBatch) {
        final recipient = store.loadRecipient(outbox.targetRecipientId);
        if (recipient?.type == RecipientType.bot) {
          final username = recipient!.handle.replaceFirst('@', '').trim();
          if (username.isEmpty) {
            throw StateError(
              'The queued bot message has no bot username to deliver to.',
            );
          }
          commands.add(
            pb.ChatStreamBatchCommand(
              commandId: outbox.messageId,
              interactBot: pb.InteractBotRequest(
                botUsername: username,
                text: utf8.decode(outbox.payload),
                clientMessageId: outbox.messageId,
              ),
            ),
          );
        } else {
          final payload = prepareMessagePayload == null
              ? outbox.payload
              : await prepareMessagePayload!(outbox);
          if (!outbox.isSecret && !listEquals(payload, outbox.payload)) {
            store.markOutboxPayloadPrepared(outbox, payload);
          }
          commands.add(
            pb.ChatStreamBatchCommand(
              commandId: outbox.messageId,
              sendMessage: ChatMessageMapper.outboxToSendMessageRequest(
                outbox,
                payload: payload,
              ),
            ),
          );
        }
      }
      results = await rpc.sendBatch(commands);
    } catch (error, stackTrace) {
      if (!_isCurrentWorker(session, gen)) return;
      for (final outbox in outboxBatch) {
        _retryOutbox(outbox, session, gen, error, stackTrace);
      }
      return;
    }

    final resultsById = <String, pb.ChatStreamBatchResult>{};
    for (final result in results) {
      if (result.commandId.isEmpty ||
          resultsById.containsKey(result.commandId)) {
        for (final outbox in outboxBatch) {
          _retryOutbox(
            outbox,
            session,
            gen,
            StateError('The server returned invalid batch command ids.'),
          );
        }
        return;
      }
      resultsById[result.commandId] = result;
    }
    for (final outbox in outboxBatch) {
      if (!_isCurrentWorker(session, gen)) return;
      final result = resultsById[outbox.messageId];
      if (result == null) {
        _retryOutbox(
          outbox,
          session,
          gen,
          StateError('The server omitted a chat batch result.'),
        );
        continue;
      }
      if (result.statusCode != 0) {
        _retryOutbox(
          outbox,
          session,
          gen,
          GrpcError.custom(result.statusCode, result.message),
        );
        continue;
      }
      try {
        if (result.hasBotInteraction()) {
          await _saveBotReply(outbox, result.botInteraction);
        } else if (!result.hasSendMessage() ||
            result.sendMessage.messageId != outbox.messageId ||
            (result.sendMessage.status !=
                    pb.SendMessageStatus.SEND_MESSAGE_STATUS_UNSPECIFIED &&
                result.sendMessage.status !=
                    pb.SendMessageStatus.SEND_MESSAGE_STATUS_ACCEPTED &&
                result.sendMessage.status !=
                    pb.SendMessageStatus.SEND_MESSAGE_STATUS_DUPLICATE)) {
          throw StateError('The server returned an invalid chat batch result.');
        }
        if (!_isCurrentWorker(session, gen)) return;
        final sentAtMicros = result.hasSendMessage()
            ? result.sendMessage.serverTimestampMicros.toInt()
            : 0;
        store.markOutboxSent(
          outbox,
          serverTimestamp: sentAtMicros > 0
              ? DateTime.fromMicrosecondsSinceEpoch(sentAtMicros, isUtc: true)
              : null,
        );
      } catch (error, stackTrace) {
        _retryOutbox(outbox, session, gen, error, stackTrace);
      }
    }
  }

  Future<void> _saveBotReply(
    OutboxRecord outbox,
    pb.InteractBotResponse response,
  ) async {
    final recipient = store.loadRecipient(outbox.targetRecipientId);
    if (recipient == null || recipient.type != RecipientType.bot) {
      throw StateError('The bot conversation is missing local recipient data.');
    }
    final replyBody = response.responseText;
    final replyTime = DateTime.now().toUtc();
    final isViewed = isChatBeingWatched(outbox.localChatId);
    await store.saveIncomingMessages([
      IncomingMessageWrite(
        message: domain.ChatMessage(
          messageId: '${outbox.messageId}-reply',
          chatId: outbox.localChatId,
          senderRecipientId: recipient.id,
          body: replyBody,
          createdAt: replyTime,
          status: isViewed
              ? domain.ChatDeliveryStatus.read
              : domain.ChatDeliveryStatus.sent,
        ),
        recipient: recipient.copyWith(lastMessage: replyBody),
        incrementUnread: !isViewed,
      ),
    ]);
  }

  void _retryOutbox(
    OutboxRecord outbox,
    UserSession session,
    int gen,
    Object error, [
    StackTrace? stackTrace,
  ]) {
    if (!_isCurrentWorker(session, gen)) return;
    final permanent = _isPermanentSendFailure(error);
    final expired = !outbox.expiresAt.isAfter(DateTime.now().toUtc());
    final failed = permanent || expired;
    final disconnected = !rpc.isReady;
    final serverDelay = _groupSlowModeRetryDelay(error);
    store.retryOutboxLater(
      outbox,
      nextAttemptAt: failed || disconnected
          ? DateTime.now().toUtc()
          : DateTime.now().toUtc().add(
              serverDelay ?? _retryDelay(outbox.attempts + 1),
            ),
      failed: failed,
      countAttempt: !disconnected,
    );
    developer.log(
      failed
          ? 'Message send moved to FAILED'
          : disconnected
          ? 'Message send remains pending until the stream reconnects'
          : 'Message send will be retried',
      error: error,
      stackTrace: stackTrace,
    );
  }

  Duration _retryDelay(int attempts) {
    final exponent = (attempts - 1).clamp(0, 20).toInt();
    final multiplier = 1 << exponent;
    final exponentialMs = retryBaseDelay.inMilliseconds * multiplier;
    final jitteredMs = min(
      (exponentialMs * (0.8 + _random.nextDouble() * 0.4)).round(),
      retryMaxDelay.inMilliseconds,
    );
    return Duration(milliseconds: jitteredMs);
  }

  bool _isPermanentSendFailure(Object error) =>
      error is GrpcError &&
      {
        StatusCode.invalidArgument,
        StatusCode.permissionDenied,
        StatusCode.failedPrecondition,
      }.contains(error.code);

  Duration? _groupSlowModeRetryDelay(Object error) {
    if (error is! GrpcError || error.code != StatusCode.resourceExhausted) {
      return null;
    }
    final match = RegExp(
      r'slow_mode_retry_after_seconds=(\d+)',
    ).firstMatch(error.message ?? '');
    final seconds = int.tryParse(match?.group(1) ?? '');
    if (seconds == null || seconds < 1 || seconds > 3600) return null;
    return Duration(seconds: seconds);
  }

  bool _isCurrentWorker(UserSession session, int gen) {
    final activeSession = store.loadSession();
    return gen == _outboxGeneration &&
        rpc.isReady &&
        activeSession?.userId == session.userId &&
        activeSession?.deviceId == session.deviceId;
  }

  void _scheduleOutboxRetry(Duration delay) {
    final nextAttempt = DateTime.now().toUtc().add(delay);
    if (_outboxRetryAt != null &&
        !_outboxRetryAt!.isAfter(nextAttempt) &&
        _outboxRetryTimer?.isActive == true) {
      return;
    }
    _outboxRetryTimer?.cancel();
    _outboxRetryAt = nextAttempt;
    _outboxRetryTimer = Timer(delay, () {
      _outboxRetryTimer = null;
      _outboxRetryAt = null;
      scheduleOutboxWorker();
    });
  }
}
