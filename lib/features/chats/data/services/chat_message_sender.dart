import '../../domain/chat_message_limits.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:tureon/core/crypto/secret_chat_crypto_port.dart';
import 'package:tureon/core/protocol/recipient.dart';
import 'package:tureon/core/protocol/recipient_type.dart';
import 'package:tureon/core/storage/chat_store.dart';
import 'package:tureon/core/storage/message_records.dart';
import 'package:tureon/core/background/outbox_background_scheduler.dart';
import '../../domain/chat_message.dart' as domain;
import '../../domain/chat_repository.dart';
import '../mappers/chat_message_mapper.dart';
import 'chat_secret_outbox_preparer.dart';

/// Creates text and bot commands in the persistent outbox.
class ChatMessageSender {
  final ChatStore store;
  final SecretChatCryptoPort? Function() secretCrypto;
  final String Function() newMessageId;
  final void Function() scheduleOutbox;
  final ChatSecretOutboxPreparer secretPreparer;
  static const _outboxRetention = ChatMessageLimits.outboxRetention;
  ChatMessageSender({
    required this.store,
    required this.secretCrypto,
    required this.newMessageId,
    required this.scheduleOutbox,
    required this.secretPreparer,
    required this.updatePreview,
  });
  final Future<void> Function(String, String) updatePreview;

  Future<domain.ChatMessage> sendSecretMessage({
    required String chatId,
    required String senderRecipientId,
    required String recipientServerDeviceId,
    required String body,
    String? replyToMessageId,
  }) async {
    if (body.trim().isEmpty) {
      throw ArgumentError.value(body, 'body', 'must not be empty');
    }
    if (recipientServerDeviceId.isEmpty) {
      throw ArgumentError.value(
        recipientServerDeviceId,
        'recipientServerDeviceId',
        'must not be empty',
      );
    }
    final session = store.loadSession();
    if (session == null) {
      throw StateError('A signed-in device is required to send messages.');
    }
    final crypto = secretCrypto();
    if (crypto == null) {
      throw StateError('Secret-chat encryption is not initialized.');
    }
    final timestamp = DateTime.now().toUtc();
    final messageId = newMessageId();
    final message = domain.ChatMessage(
      messageId: messageId,
      chatId: secretChatLocalId(
        recipientId: chatId,
        firstDeviceId: session.deviceId,
        secondDeviceId: recipientServerDeviceId,
      ),
      senderRecipientId: senderRecipientId,
      body: body,
      createdAt: timestamp,
      type: replyToMessageId == null
          ? domain.ChatMessageType.text
          : domain.ChatMessageType.reply,
      replyToMessageId: replyToMessageId,
      status: domain.ChatDeliveryStatus.pending,
    );
    final outbox = OutboxRecord(
      accountId: session.userId,
      localChatId: message.chatId,
      messageId: messageId,
      chatId: chatId,
      senderRecipientId: senderRecipientId,
      senderDeviceId: session.deviceId,
      targetRecipientId: chatId,
      targetDeviceId: recipientServerDeviceId,
      isSecret: true,
      messageType: ChatMessageMapper.messageTypeWireValue(message.type),
      payload: replyToMessageId == null
          ? Uint8List(0)
          : ChatMessageMapper.replyPayload(body, replyToMessageId),
      status: OutboxStatus.preparing,
      attempts: 0,
      createdAt: timestamp,
      nextAttemptAt: timestamp,
      expiresAt: timestamp.add(_outboxRetention),
    );
    store.saveOutgoingMessage(message, outbox);
    try {
      await secretPreparer.prepare(outbox, crypto, session);
    } catch (_) {
      store.markOutboxPreparationFailed(outbox);
      rethrow;
    }
    scheduleOutbox();
    unawaited(OutboxBackgroundScheduler.enqueue());
    return message;
  }

  Future<domain.ChatMessage> sendMessage({
    required String chatId,
    required String senderRecipientId,
    required String body,
    String? replyToMessageId,
  }) async {
    if (body.trim().isEmpty) {
      throw ArgumentError.value(body, 'body', 'must not be empty');
    }
    final session = store.loadSession();
    if (session == null) {
      throw StateError('A signed-in device is required to send messages.');
    }
    final timestamp = DateTime.now().toUtc();
    final messageId = newMessageId();
    final messageType = replyToMessageId == null
        ? domain.ChatMessageType.text
        : domain.ChatMessageType.reply;
    final message = domain.ChatMessage(
      messageId: messageId,
      chatId: chatId,
      senderRecipientId: senderRecipientId,
      body: body,
      createdAt: timestamp,
      type: messageType,
      replyToMessageId: replyToMessageId,
      status: domain.ChatDeliveryStatus.pending,
    );
    final outbox = OutboxRecord(
      accountId: session.userId,
      localChatId: chatId,
      messageId: messageId,
      chatId: chatId,
      senderRecipientId: senderRecipientId,
      senderDeviceId: session.deviceId,
      targetRecipientId: chatId,
      targetDeviceId: null,
      isSecret: false,
      messageType: ChatMessageMapper.messageTypeWireValue(messageType),
      payload: replyToMessageId == null
          ? Uint8List.fromList(utf8.encode(body))
          : ChatMessageMapper.replyPayload(body, replyToMessageId),
      status: OutboxStatus.pending,
      attempts: 0,
      createdAt: timestamp,
      nextAttemptAt: timestamp,
      expiresAt: timestamp.add(_outboxRetention),
    );
    store.saveOutgoingMessage(message, outbox);
    await updatePreview(chatId, body);
    scheduleOutbox();
    unawaited(OutboxBackgroundScheduler.enqueue());
    return message;
  }

  Future<domain.ChatMessage> sendBotMessage({
    required Recipient recipient,
    required String senderRecipientId,
    required String body,
  }) async {
    if (recipient.type != RecipientType.bot ||
        recipient.handle.trim().isEmpty) {
      throw ArgumentError('A bot recipient with a username is required.');
    }
    if (body.trim().isEmpty) {
      throw ArgumentError.value(body, 'body', 'must not be empty');
    }
    final session = store.loadSession();
    if (session == null) {
      throw StateError('A signed-in device is required to talk to bots.');
    }
    await store.saveRecipient(recipient);
    final timestamp = DateTime.now().toUtc();
    final messageId = newMessageId();
    final message = domain.ChatMessage(
      messageId: messageId,
      chatId: recipient.id,
      senderRecipientId: senderRecipientId,
      body: body,
      createdAt: timestamp,
      status: domain.ChatDeliveryStatus.pending,
    );
    final outbox = OutboxRecord(
      accountId: session.userId,
      localChatId: recipient.id,
      messageId: messageId,
      chatId: recipient.id,
      senderRecipientId: senderRecipientId,
      senderDeviceId: session.deviceId,
      targetRecipientId: recipient.id,
      targetDeviceId: null,
      isSecret: false,
      messageType: domain.ChatMessageType.text.index,
      payload: Uint8List.fromList(utf8.encode(body)),
      status: OutboxStatus.pending,
      attempts: 0,
      createdAt: timestamp,
      nextAttemptAt: timestamp,
      expiresAt: timestamp.add(_outboxRetention),
    );
    store.saveOutgoingMessage(message, outbox);
    await updatePreview(recipient.id, body);
    scheduleOutbox();
    unawaited(OutboxBackgroundScheduler.enqueue());
    return message;
  }
}
