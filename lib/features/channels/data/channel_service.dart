import 'package:grpc/grpc.dart' as grpc;

import '../../../core/network/grpc_client.dart';
import '../../../core/protocol/recipient.dart';
import '../../../core/protocol/recipient_type.dart';
import '../../../core/protocol/verification_badge.dart';
import '../../../core/storage/local_store.dart';
import '../../../generated/proto/tureon.pb.dart' as pb;
import '../domain/channel_failure.dart';

/// Service dedicated strictly to Channel operations adhering to SRP and Clean Architecture.
class ChannelService {
  ChannelService({required this.store, required this.client});

  final LocalStore store;
  final GrpcClient? Function() client;

  Future<Recipient> createChannel({
    required String name,
    String description = '',
    String avatarUrl = '',
    String visibility = 'public',
  }) async {
    final grpcClient = _requireAuthenticatedClient();
    try {
      final response = await grpcClient.channels.createChannel(
        pb.CreateChannelRequest(
          name: name.trim(),
          description: description.trim(),
          avatarUrl: avatarUrl.trim(),
          visibility: visibility.trim().isEmpty ? 'public' : visibility.trim(),
        ),
      );
      if (!response.hasChannel()) {
        throw const ChannelCreateFailure(
          'O servidor não retornou o canal criado.',
        );
      }
      final channel = response.channel;
      final recipient = Recipient(
        id: channel.id,
        type: RecipientType.channel,
        name: channel.name.isEmpty ? name.trim() : channel.name,
        handle: channel.name.isEmpty ? '' : '@${channel.name}',
        avatarUrl: channel.avatarUrl.isEmpty ? null : channel.avatarUrl,
        lastMessage: 'Canal criado',
        unreadCount: 0,
        isOnline: false,
        isUsernameVisible: false,
        isPresenceVisible: false,
        composerRole: channel.memberRole.isEmpty ? 'owner' : channel.memberRole,
        canSendMessages:
            channel.memberRole.isEmpty ||
            channel.memberRole == 'owner' ||
            channel.memberRole == 'admin' ||
            channel.membersCanSendMessages,
        membersCanSendMessages: channel.membersCanSendMessages,
        memberCount: channel.memberCount.toInt(),
        isOfficial: channel.isOfficial,
        visibility: channel.visibility,
        isMember: true,
        verificationBadge: VerificationBadge.none,
      );
      await store.saveRecipient(recipient);
      return recipient;
    } catch (e) {
      if (e is ChannelFailure) rethrow;
      throw ChannelCreateFailure('Erro ao criar canal: $e');
    }
  }

  Future<void> addSubscriber({
    required String channelId,
    required String userId,
  }) async {
    try {
      await _requireAuthenticatedClient().groups.addMember(
        pb.Empty(),
        options: grpc.CallOptions(
          metadata: {
            'group-channel-id': channelId,
            'user-id': userId,
            'role': 'subscriber',
          },
        ),
      );
    } catch (e) {
      throw ChannelSubscribeFailure('Erro ao inscrever no canal: $e');
    }
  }

  Future<List<pb.GroupChannelMember>> listSubscribers({
    required String channelId,
  }) async {
    final response = await _requireAuthenticatedClient().groups.listMembers(
      pb.Empty(),
      options: grpc.CallOptions(metadata: {'group-channel-id': channelId}),
    );
    return response.members;
  }

  GrpcClient _requireAuthenticatedClient() {
    final grpcClient = client();
    if (grpcClient == null || !grpcClient.hasAccessToken) {
      throw const ChannelPermissionFailure(
        'Uma conexão autenticada é necessária.',
      );
    }
    return grpcClient;
  }
}
