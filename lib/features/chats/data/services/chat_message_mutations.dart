import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:tureon/core/crypto/secret_chat_crypto_port.dart';
import 'package:tureon/core/storage/chat_store.dart';
import 'package:tureon/core/storage/message_records.dart';
import 'package:tureon/generated/proto/tureon.pb.dart' as pb;
import '../../domain/chat_message.dart' as domain;

/// Serializes edit and delete commands per message, including secret payloads.
class ChatMessageMutations {
  ChatMessageMutations({
    required this.store,
    required this.secretCrypto,
    required this.newMessageId,
    required this.scheduleOutbox,
    required this.updatePreview,
  });
  final ChatStore store;
  final SecretChatCryptoPort? Function() secretCrypto;
  final String Function() newMessageId;
  final void Function() scheduleOutbox;
  final Future<void> Function(String, String) updatePreview;
  final Map<String, Future<void>> _mutationPreparationQueues = {};

  Future<domain.ChatMessage> editMessage({
    required String messageId,
    required String chatId,
    required String targetRecipientId,
    required bool isSecret,
    String? targetDeviceId,
    required String body,
  }) async {
    if (body.trim().isEmpty) {
      throw ArgumentError.value(body, 'body', 'must not be empty');
    }
    final session = store.loadSession();
    if (session == null) {
      throw StateError('A signed-in device is required to edit messages.');
    }
    final localMessage = store.loadChatMessage(messageId);
    if (localMessage == null) {
      throw StateError('Local message is missing and cannot be edited.');
    }
    final editedAt = DateTime.now().toUtc();
    final edited = domain.ChatMessage(
      messageId: localMessage.messageId,
      chatId: localMessage.chatId,
      senderRecipientId: localMessage.senderRecipientId,
      body: body,
      createdAt: localMessage.createdAt,
      type: localMessage.type,
      replyToMessageId: localMessage.replyToMessageId,
      editedAt: editedAt,
      status: localMessage.status,
    );
    return _serializeMutationPreparation(messageId, () async {
      final payload = await _buildMessageMutationPayload(
        body: body,
        isSecret: isSecret,
        targetRecipientId: targetRecipientId,
        targetDeviceId: targetDeviceId,
      );
      final mutationId = newMessageId();
      final mutation = pb.SendMessageMutationRequest(
        mutationId: mutationId,
        messageId: messageId,
        chatId: chatId,
        senderRecipientId: session.userId,
        senderDeviceId: session.deviceId,
        targetRecipientId: targetRecipientId,
        targetDeviceId: targetDeviceId ?? '',
        chatKind: isSecret
            ? pb.ChatKind.CHAT_KIND_SECRET
            : pb.ChatKind.CHAT_KIND_NORMAL,
        mutationType: pb.MessageMutationType.MESSAGE_MUTATION_TYPE_EDIT,
        payload: payload,
      );
      final now = DateTime.now().toUtc();
      store.enqueueMessageMutation(
        command: PendingChatCommand(
          accountId: session.userId,
          commandId: mutationId,
          relatedMessageId: messageId,
          type: PendingChatCommandType.messageMutation,
          payload: Uint8List.fromList(mutation.writeToBuffer()),
          attempts: 0,
          nextAttemptAt: now,
          createdAt: now,
        ),
        editedMessage: edited,
      );
      await updatePreview(edited.chatId, targetRecipientId);
      scheduleOutbox();
      return edited;
    });
  }

  Future<void> deleteMessage({
    required String messageId,
    required String chatId,
    required String targetRecipientId,
    required bool isSecret,
    String? targetDeviceId,
  }) async {
    final session = store.loadSession();
    if (session == null) {
      throw StateError('A signed-in device is required to delete messages.');
    }
    final localMessage = store.loadChatMessage(messageId);
    await _serializeMutationPreparation(messageId, () async {
      final payload = await _buildMessageMutationPayload(
        body: '',
        isSecret: isSecret,
        targetRecipientId: targetRecipientId,
        targetDeviceId: targetDeviceId,
      );
      final mutationId = newMessageId();
      final mutation = pb.SendMessageMutationRequest(
        mutationId: mutationId,
        messageId: messageId,
        chatId: chatId,
        senderRecipientId: session.userId,
        senderDeviceId: session.deviceId,
        targetRecipientId: targetRecipientId,
        targetDeviceId: targetDeviceId ?? '',
        chatKind: isSecret
            ? pb.ChatKind.CHAT_KIND_SECRET
            : pb.ChatKind.CHAT_KIND_NORMAL,
        mutationType: pb.MessageMutationType.MESSAGE_MUTATION_TYPE_DELETE,
        payload: payload,
      );
      final now = DateTime.now().toUtc();
      store.enqueueMessageMutation(
        command: PendingChatCommand(
          accountId: session.userId,
          commandId: mutationId,
          relatedMessageId: messageId,
          type: PendingChatCommandType.messageMutation,
          payload: Uint8List.fromList(mutation.writeToBuffer()),
          attempts: 0,
          nextAttemptAt: now,
          createdAt: now,
        ),
        deletedMessageId: messageId,
      );
      if (localMessage != null) {
        await updatePreview(localMessage.chatId, targetRecipientId);
      }
      scheduleOutbox();
    });
  }

  Future<Uint8List> _buildMessageMutationPayload({
    required String body,
    required bool isSecret,
    required String targetRecipientId,
    required String? targetDeviceId,
  }) async {
    final plaintext = Uint8List.fromList(utf8.encode(body));
    if (!isSecret) return plaintext;
    final crypto = secretCrypto();
    if (crypto == null) {
      throw StateError('Secret-chat encryption is not initialized.');
    }
    if (targetDeviceId == null || targetDeviceId.isEmpty) {
      throw ArgumentError.value(
        targetDeviceId,
        'targetDeviceId',
        'A recipient device is required for secret chat mutations.',
      );
    }
    return crypto.encrypt(
      secretChatId: targetRecipientId,
      recipientServerDeviceId: targetDeviceId,
      plaintext: plaintext,
    );
  }

  Future<T> _serializeMutationPreparation<T>(
    String messageId,
    Future<T> Function() prepare,
  ) {
    final previous =
        _mutationPreparationQueues[messageId] ?? Future<void>.value();
    final result = Completer<T>();
    final completion = Completer<void>();
    final queueTail = completion.future;
    _mutationPreparationQueues[messageId] = queueTail;
    unawaited(
      previous.then<void>((_) {}, onError: (Object _, StackTrace _) {}).then((
        _,
      ) async {
        try {
          result.complete(await prepare());
        } catch (error, stackTrace) {
          result.completeError(error, stackTrace);
        } finally {
          completion.complete();
          if (_mutationPreparationQueues[messageId] == queueTail) {
            _mutationPreparationQueues.remove(messageId);
          }
        }
      }),
    );
    return result.future;
  }
}
