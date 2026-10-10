import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:typed_data';
import 'package:tureon/core/crypto/secret_chat_crypto_port.dart';
import 'package:tureon/core/storage/chat_store.dart';
import 'package:tureon/core/storage/message_records.dart';
import 'chat_media_transfer_service.dart';

/// Deduplicates secret encryption preparation and recovers preparing outbox entries.
class ChatSecretOutboxPreparer {
  ChatSecretOutboxPreparer({
    required this.store,
    required this.secretCrypto,
    required this.isCurrentSession,
    required this.outboxBatchSize,
    this.mediaTransfer,
  });
  final ChatStore store;
  final SecretChatCryptoPort? Function() secretCrypto;
  final bool Function(UserSession) isCurrentSession;
  final int outboxBatchSize;
  final ChatMediaTransferService? mediaTransfer;
  final Map<String, Future<void>> _secretPreparationTasks = {};

  Future<void> recover(UserSession session) async {
    final crypto = secretCrypto();
    if (crypto == null || !isCurrentSession(session)) return;
    final attemptedMessageIds = <String>{};
    while (isCurrentSession(session)) {
      final batch = store.loadPreparingSecretOutbox(
        session.userId,
        session.deviceId,
        limit: outboxBatchSize,
      );
      final unattempted = batch
          .where((record) => attemptedMessageIds.add(record.messageId))
          .toList(growable: false);
      if (unattempted.isEmpty) return;
      for (final outbox in unattempted) {
        try {
          await prepare(outbox, crypto, session);
        } catch (error, stackTrace) {
          store.markOutboxPreparationFailed(outbox);
          developer.log(
            'Secret message encryption will be retried',
            name: 'tureon.messaging',
            error: error,
            stackTrace: stackTrace,
          );
        }
      }
    }
  }

  Future<void> prepare(
    OutboxRecord outbox,
    SecretChatCryptoPort crypto,
    UserSession session,
  ) {
    final activeTask = _secretPreparationTasks[outbox.messageId];
    if (activeTask != null) return activeTask;

    late final Future<void> task;
    task =
        () async {
          if (!isCurrentSession(session) ||
              outbox.accountId != session.userId ||
              outbox.senderDeviceId != session.deviceId ||
              outbox.targetDeviceId == null) {
            throw StateError(
              'The active session changed during secret encryption.',
            );
          }
          final fallbackPayload = outbox.payload.isNotEmpty
              ? outbox.payload
              : Uint8List.fromList(
                  utf8.encode(
                    store.loadChatMessage(outbox.messageId)?.body ??
                        (throw StateError(
                          'The local secret message is missing before encryption.',
                        )),
                  ),
                );
          final plaintext = mediaTransfer == null || outbox.payload.isEmpty
              ? fallbackPayload
              : await mediaTransfer!.prepareOutboxPayload(outbox);
          final ciphertext = await crypto.encrypt(
            secretChatId: outbox.chatId,
            recipientServerDeviceId: outbox.targetDeviceId!,
            plaintext: Uint8List.fromList(plaintext),
          );
          if (!isCurrentSession(session)) {
            throw StateError(
              'The active session changed during secret encryption.',
            );
          }
          store.markOutboxEncrypted(outbox, ciphertext);
        }().whenComplete(() {
          if (identical(_secretPreparationTasks[outbox.messageId], task)) {
            _secretPreparationTasks.remove(outbox.messageId);
          }
        });
    _secretPreparationTasks[outbox.messageId] = task;
    return task;
  }
}
