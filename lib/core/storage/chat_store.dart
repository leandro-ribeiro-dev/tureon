import '../../features/chats/domain/chat_message.dart';
import '../../features/chats/domain/message_translation.dart';
import '../protocol/protocol_models.dart';
import 'message_records.dart';

class IncomingMessageWrite {
  const IncomingMessageWrite({
    required this.message,
    required this.recipient,
    this.incrementUnread = true,
  });

  final ChatMessage message;
  final Recipient recipient;
  final bool incrementUnread;
}

abstract interface class ChatStore {
  UserSession? loadSession();

  Future<void> saveRecipient(Recipient recipient);

  void saveChatMessage(ChatMessage message);

  void saveOutgoingMessage(ChatMessage message, OutboxRecord outbox);

  void enqueueMessageMutation({
    required PendingChatCommand command,
    ChatMessage? editedMessage,
    String? deletedMessageId,
  });

  void enqueueReadReceipts({
    required List<PendingChatCommand> commands,
    required List<String> readMessageIds,
    required String peerRecipientId,
  });

  List<PendingChatCommand> loadPendingChatCommands(
    String accountId, {
    required int limit,
  });

  bool hasPendingOutboxForMessage(String accountId, String messageId);

  void removePendingChatCommand(String accountId, String commandId);

  void retryPendingChatCommand(
    PendingChatCommand command, {
    required DateTime nextAttemptAt,
  });

  List<OutboxRecord> loadOutboxQueue(String accountId, String deviceId);

  List<OutboxRecord> loadOutboxHeads(
    String accountId,
    String deviceId, {
    required int limit,
  });

  List<OutboxRecord> loadPreparingSecretOutbox(
    String accountId,
    String deviceId, {
    required int limit,
  });

  void markOutboxEncrypted(OutboxRecord outbox, List<int> ciphertext);

  void markOutboxPayloadPrepared(OutboxRecord outbox, List<int> payload);

  void markOutboxPreparationFailed(OutboxRecord outbox);

  void reassignNormalOutbox(String accountId, String deviceId);

  void markOutboxSending(OutboxRecord outbox);

  void retryOutboxLater(
    OutboxRecord outbox, {
    required DateTime nextAttemptAt,
    required bool failed,
    bool countAttempt = true,
  });

  void expireOutbox(OutboxRecord outbox);

  void markOutboxSent(OutboxRecord outbox, {DateTime? serverTimestamp});

  void resetSendingOutbox(String accountId);

  bool retryFailedOutbox(String accountId, String deviceId, String messageId);

  bool saveIncomingMessage(
    ChatMessage message,
    Recipient recipient, {
    bool incrementUnread = true,
  });

  Future<List<bool>> saveIncomingMessages(List<IncomingMessageWrite> messages);

  Recipient? loadRecipient(String recipientId);

  void deleteRecipient(String recipientId);

  Stream<List<ChatMessage>> watchChatMessages(String chatId, {int limit = 100});

  List<ChatMessage> loadChatMessages(String chatId);

  List<ChatMessage> loadEarlierChatMessages({
    required String chatId,
    required ChatMessage before,
    required int limit,
  });

  ChatMessage? loadChatMessage(String messageId);

  Map<String, MessageTranslation> loadMessageTranslations(
    List<String> messageIds, {
    required String targetLanguage,
  });

  bool saveMessageTranslation(MessageTranslation translation);

  void saveMessageReceiptStatus(String messageId, ChatDeliveryStatus status);

  bool hasAppliedMessageMutation(String mutationId);

  void applyChatMessageEdit(ChatMessage message, String mutationId);

  void applyChatMessageDeletion(String messageId, String mutationId);

  bool isChatMessageDeleted(String messageId);

  bool hasCompletedSecretDelivery(String deliveryId);

  bool saveIncomingSecretMessage({
    required SecretDeliveryRecord delivery,
    required ChatMessage message,
    required Recipient recipient,
  });

  void deleteChatMessage(String messageId);

  void saveSecretDelivery(SecretDeliveryRecord delivery);

  void deleteSecretDelivery(String deliveryId);

  List<SecretDeliveryRecord> loadSecretDeliveries(String chatId);
}
