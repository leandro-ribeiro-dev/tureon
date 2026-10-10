import '../../domain/chat_message_limits.dart';
import 'dart:async';
import 'dart:io';
import 'package:tureon/core/crypto/secret_chat_crypto_port.dart';
import 'package:tureon/core/storage/chat_store.dart';
import 'package:tureon/core/storage/message_records.dart';
import 'package:tureon/core/background/outbox_background_scheduler.dart';
import '../../domain/chat_message.dart' as domain;
import '../../domain/chat_repository.dart';
import '../mappers/chat_message_mapper.dart';
import 'chat_media_transfer_service.dart';
import 'messaging_rpc.dart';
import 'chat_secret_outbox_preparer.dart';

/// Stages attachment and location commands for durable delivery.
class ChatAttachmentSender {
  final ChatStore store;
  final SecretChatCryptoPort? Function() secretCrypto;
  final String Function() newMessageId;
  final void Function() scheduleOutbox;
  final ChatSecretOutboxPreparer secretPreparer;
  static const _outboxRetention = ChatMessageLimits.outboxRetention;
  ChatAttachmentSender({
    required this.store,
    required this.secretCrypto,
    required this.newMessageId,
    required this.scheduleOutbox,
    required this.secretPreparer,
    required this.rpc,
    this.mediaTransfer,
  });
  final MessagingRpc rpc;
  final ChatMediaTransferService? mediaTransfer;

  Future<domain.ChatMessage> sendAttachment({
    required String chatId,
    required String senderRecipientId,
    required domain.ChatMessageType type,
    required String sourcePath,
    required String fileName,
    required String mimeType,
    required String caption,
    String? replyToMessageId,
    bool isSecret = false,
    String? recipientServerDeviceId,
    int? durationMillis,
  }) async {
    if (!{
      domain.ChatMessageType.image,
      domain.ChatMessageType.video,
      domain.ChatMessageType.audio,
      domain.ChatMessageType.voiceNote,
      domain.ChatMessageType.file,
      domain.ChatMessageType.gif,
      domain.ChatMessageType.sticker,
    }.contains(type)) {
      throw ArgumentError.value(type, 'type', 'Unsupported attachment type.');
    }
    final transfer = mediaTransfer;
    if (transfer == null) {
      throw StateError('O serviço de mídia não está configurado.');
    }
    final source = File(sourcePath);
    if (!await source.exists()) {
      throw StateError('O arquivo selecionado não está mais disponível.');
    }
    final session = store.loadSession();
    if (session == null) {
      throw StateError('A signed-in device is required to send messages.');
    }
    final size = await source.length();
    final messageId = newMessageId();
    final mediaId = newMessageId();
    final timestamp = DateTime.now().toUtc();
    final domain.ChatAttachment attachment;
    if (isSecret) {
      final targetDevice = recipientServerDeviceId;
      final crypto = secretCrypto();
      if (targetDevice == null || targetDevice.isEmpty || crypto == null) {
        throw StateError('O dispositivo do chat secreto não está pronto.');
      }
      attachment = await transfer.encryptSecretAttachment(
        sourcePath: sourcePath,
        mediaId: mediaId,
        fileName: fileName,
        mimeType: mimeType,
        durationMillis: durationMillis ?? 0,
      );
    } else {
      attachment = domain.ChatAttachment(
        mediaId: mediaId,
        fileName: fileName,
        mimeType: mimeType,
        sizeBytes: size,
        localPath: sourcePath,
        durationMillis: durationMillis,
      );
    }
    final localChatId = isSecret
        ? secretChatLocalId(
            recipientId: chatId,
            firstDeviceId: session.deviceId,
            secondDeviceId: recipientServerDeviceId!,
          )
        : chatId;
    final message = domain.ChatMessage(
      messageId: messageId,
      chatId: localChatId,
      senderRecipientId: senderRecipientId,
      body: caption,
      createdAt: timestamp,
      type: type,
      replyToMessageId: replyToMessageId,
      attachment: attachment,
      status: domain.ChatDeliveryStatus.pending,
    );
    final payload = ChatMessageMapper.attachmentDraftPayload(
      caption: caption,
      attachment: attachment,
      replyToMessageId: replyToMessageId,
    );
    final outbox = OutboxRecord(
      accountId: session.userId,
      localChatId: localChatId,
      messageId: messageId,
      chatId: chatId,
      senderRecipientId: senderRecipientId,
      senderDeviceId: session.deviceId,
      targetRecipientId: chatId,
      targetDeviceId: isSecret ? recipientServerDeviceId : null,
      isSecret: isSecret,
      messageType: ChatMessageMapper.messageTypeWireValue(type),
      payload: payload,
      status: isSecret ? OutboxStatus.preparing : OutboxStatus.pending,
      attempts: 0,
      createdAt: timestamp,
      nextAttemptAt: timestamp,
      expiresAt: timestamp.add(_outboxRetention),
    );
    store.saveOutgoingMessage(message, outbox);
    if (isSecret && rpc.isReady) {
      final crypto = secretCrypto();
      if (crypto != null) {
        try {
          await secretPreparer.prepare(outbox, crypto, session);
        } catch (error) {
          store.markOutboxPreparationFailed(outbox);
          rethrow;
        }
      }
    }
    scheduleOutbox();
    unawaited(OutboxBackgroundScheduler.enqueue());
    return message;
  }

  Future<domain.ChatMessage> sendLocation({
    required String chatId,
    required String senderRecipientId,
    required double latitude,
    required double longitude,
    String? placeName,
    String caption = '',
    String? replyToMessageId,
    bool isSecret = false,
    String? recipientServerDeviceId,
  }) async {
    if (!latitude.isFinite ||
        !longitude.isFinite ||
        latitude < -90 ||
        latitude > 90 ||
        longitude < -180 ||
        longitude > 180) {
      throw ArgumentError('As coordenadas da localização são inválidas.');
    }
    final session = store.loadSession();
    if (session == null) {
      throw StateError('A signed-in device is required to send messages.');
    }
    final timestamp = DateTime.now().toUtc();
    final messageId = newMessageId();
    final localChatId = isSecret
        ? secretChatLocalId(
            recipientId: chatId,
            firstDeviceId: session.deviceId,
            secondDeviceId:
                recipientServerDeviceId ??
                (throw StateError('Selecione o dispositivo do chat secreto.')),
          )
        : chatId;
    final attachment = domain.ChatAttachment(
      fileName: placeName?.trim().isNotEmpty == true
          ? placeName!.trim()
          : 'Localização',
      mimeType: domain.ChatAttachment.locationMimeType,
      latitude: latitude,
      longitude: longitude,
      placeName: placeName,
    );
    final message = domain.ChatMessage(
      messageId: messageId,
      chatId: localChatId,
      senderRecipientId: senderRecipientId,
      body: caption,
      createdAt: timestamp,
      type: domain.ChatMessageType.location,
      replyToMessageId: replyToMessageId,
      attachment: attachment,
      status: domain.ChatDeliveryStatus.pending,
    );
    final outbox = OutboxRecord(
      accountId: session.userId,
      localChatId: localChatId,
      messageId: messageId,
      chatId: chatId,
      senderRecipientId: senderRecipientId,
      senderDeviceId: session.deviceId,
      targetRecipientId: chatId,
      targetDeviceId: isSecret ? recipientServerDeviceId : null,
      isSecret: isSecret,
      messageType: ChatMessageMapper.messageTypeWireValue(message.type),
      payload: ChatMessageMapper.attachmentPayload(
        caption: caption,
        attachment: attachment,
        replyToMessageId: replyToMessageId,
      ),
      status: isSecret ? OutboxStatus.preparing : OutboxStatus.pending,
      attempts: 0,
      createdAt: timestamp,
      nextAttemptAt: timestamp,
      expiresAt: timestamp.add(_outboxRetention),
    );
    store.saveOutgoingMessage(message, outbox);
    if (isSecret && rpc.isReady) {
      final crypto = secretCrypto();
      if (crypto == null) {
        throw StateError('A criptografia do chat secreto não está pronta.');
      }
      try {
        await secretPreparer.prepare(outbox, crypto, session);
      } catch (error) {
        store.markOutboxPreparationFailed(outbox);
        rethrow;
      }
    }
    scheduleOutbox();
    unawaited(OutboxBackgroundScheduler.enqueue());
    return message;
  }

  Future<String> resolveAttachmentLocalPath(
    domain.ChatAttachment attachment,
  ) async {
    final transfer = mediaTransfer;
    if (transfer == null) {
      throw StateError('O serviço de mídia não está configurado.');
    }
    return transfer.resolveLocalPath(attachment);
  }
}
