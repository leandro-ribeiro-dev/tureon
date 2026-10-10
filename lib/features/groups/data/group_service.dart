import 'package:grpc/grpc.dart' as grpc;

import '../../../core/network/grpc_client.dart';
import '../../../core/protocol/recipient.dart';
import '../../../core/protocol/recipient_type.dart';
import '../../../core/protocol/verification_badge.dart';
import '../../../core/storage/local_store.dart';
import '../../../generated/proto/tureon.pb.dart' as pb;
import '../domain/group_failure.dart';

/// Service dedicated strictly to Group operations adhering to SRP and Clean Architecture.
class GroupService {
  GroupService({required this.store, required this.client});

  final LocalStore store;
  final GrpcClient? Function() client;

  Future<Recipient> createGroup({
    required String name,
    String description = '',
    String avatarUrl = '',
    String visibility = 'public',
  }) async {
    final grpcClient = _requireAuthenticatedClient();
    try {
      final response = await grpcClient.groups.createGroup(
        pb.CreateGroupRequest(
          name: name.trim(),
          description: description.trim(),
          avatarUrl: avatarUrl.trim(),
          visibility: visibility.trim().isEmpty ? 'public' : visibility.trim(),
        ),
      );
      if (!response.hasGroup()) {
        throw const GroupCreateFailure('O servidor não retornou o grupo criado.');
      }
      final group = response.group;
      final recipient = Recipient(
        id: group.id,
        type: RecipientType.group,
        name: group.name.isEmpty ? name.trim() : group.name,
        handle: group.name.isEmpty ? '' : '@${group.name}',
        avatarUrl: group.avatarUrl.isEmpty ? null : group.avatarUrl,
        lastMessage: 'Grupo criado',
        unreadCount: 0,
        isOnline: false,
        isUsernameVisible: false,
        isPresenceVisible: false,
        composerRole: group.memberRole.isEmpty ? 'owner' : group.memberRole,
        canSendMessages: true,
        membersCanSendMessages: group.membersCanSendMessages,
        verificationBadge: VerificationBadge.none,
      );
      await store.saveRecipient(recipient);
      return recipient;
    } catch (e) {
      if (e is GroupFailure) rethrow;
      throw GroupCreateFailure('Erro ao criar grupo: $e');
    }
  }

  Future<void> addMember({
    required String groupId,
    required String userId,
  }) async {
    try {
      await _requireAuthenticatedClient().groups.addMember(
        pb.Empty(),
        options: grpc.CallOptions(
          metadata: {
            'group-channel-id': groupId,
            'user-id': userId,
            'role': 'member',
          },
        ),
      );
    } catch (e) {
      throw GroupMemberFailure('Erro ao adicionar participante: $e');
    }
  }

  Future<List<pb.GroupChannelMember>> listMembers({
    required String groupId,
  }) async {
    final response = await _requireAuthenticatedClient().groups.listMembers(
      pb.Empty(),
      options: grpc.CallOptions(metadata: {'group-channel-id': groupId}),
    );
    return response.members;
  }

  GrpcClient _requireAuthenticatedClient() {
    final grpcClient = client();
    if (grpcClient == null || !grpcClient.hasAccessToken) {
      throw const GroupPermissionFailure('Uma conexão autenticada é necessária.');
    }
    return grpcClient;
  }
}
