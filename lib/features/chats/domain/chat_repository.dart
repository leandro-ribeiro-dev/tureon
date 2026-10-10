import '../../../core/protocol/recipient.dart';
import '../../../generated/proto/tureon.pb.dart' as pb;
import 'chat_message.dart';
import 'message_translation.dart';

String secretChatLocalId({
  required String recipientId,
  required String firstDeviceId,
  required String secondDeviceId,
}) {
  final deviceIds = [firstDeviceId, secondDeviceId]..sort();
  return 'secret/$recipientId/${deviceIds[0]}/${deviceIds[1]}';
}

abstract interface class ChatRepository {
  bool get isStreamReady;

  Stream<bool> get streamReadinessChanges;

  Future<void> startSync();

  Future<void> stopSync();

  Future<Recipient> openOrCreateChat({
    required String recipientId,
    required Recipient recipient,
  });

  Stream<List<ChatMessage>> watchMessages({
    required String chatId,
    int limit = 100,
  });

  Stream<ChatMessage> streamMessages({required String chatId});

  Future<ChatMessage> sendMessage({
    required String chatId,
    required String senderRecipientId,
    required String body,
    String? replyToMessageId,
  });

  Future<ChatMessage> sendAttachment({
    required String chatId,
    required String senderRecipientId,
    required ChatMessageType type,
    required String sourcePath,
    required String fileName,
    required String mimeType,
    required String caption,
    String? replyToMessageId,
    bool isSecret = false,
    String? recipientServerDeviceId,
    int? durationMillis,
  });

  Future<ChatMessage> sendLocation({
    required String chatId,
    required String senderRecipientId,
    required double latitude,
    required double longitude,
    String? placeName,
    String caption = '',
    String? replyToMessageId,
    bool isSecret = false,
    String? recipientServerDeviceId,
  });

  Future<String> resolveAttachmentLocalPath(ChatAttachment attachment);

  Future<ChatMessage> sendSecretMessage({
    required String chatId,
    required String senderRecipientId,
    required String recipientServerDeviceId,
    required String body,
    String? replyToMessageId,
  });

  Future<ChatMessage> sendBotMessage({
    required Recipient recipient,
    required String senderRecipientId,
    required String body,
  });

  Future<void> retryMessage(String messageId);

  Future<void> markConversationRead({
    required String chatId,
    required String peerRecipientId,
  });

  List<ChatMessage> loadLocalHistory({required String chatId});

  Map<String, MessageTranslation> loadMessageTranslations(
    List<String> messageIds, {
    required String targetLanguage,
  });

  Future<bool> saveMessageTranslation(MessageTranslation translation);

  List<ChatMessage> loadEarlierMessages({
    required String chatId,
    required ChatMessage before,
    int limit = 50,
  });

  Future<ChatMessage> editMessage({
    required String messageId,
    required String chatId,
    required String targetRecipientId,
    required bool isSecret,
    String? targetDeviceId,
    required String body,
  });

  Future<void> deleteMessage({
    required String messageId,
    required String chatId,
    required String targetRecipientId,
    required bool isSecret,
    String? targetDeviceId,
  });

  Future<pb.InteractBotResponse> interactWithBot({
    required String username,
    required String text,
  });
}
