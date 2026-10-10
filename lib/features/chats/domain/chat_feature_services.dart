import '../../../core/protocol/protocol_models.dart';
import 'chat_repository.dart';

typedef ChatIdentity = ({String userId, String deviceId});

enum ChatSendRestriction { none, underReview, blocked }

abstract interface class ChatFeatureServices {
  ChatRepository? get chatRepository;

  bool get isChatStreamReady;

  Stream<bool> get chatStreamReadinessChanges;

  ChatIdentity? get chatIdentity;

  ChatSendRestriction get chatSendRestriction;

  String? loadSetting(String key);

  Future<void> sendTypingIndicator({
    required String targetRecipientId,
    required bool isTyping,
  });

  Future<void> sendBotMessage({
    required Recipient recipient,
    required String body,
  });

  Future<List<Recipient>> searchUsersByUsername(String query);

  Future<List<Recipient>> searchPublicGroupChannels(String query);

  Future<Recipient> joinPublicGroupChannel(Recipient recipient);

  Future<void> addMemberToGroupChannel({
    required String groupChannelId,
    required String userId,
    required bool isChannel,
  });

  Future<int> loadOnlineGroupMemberCount({required String groupId});
}
