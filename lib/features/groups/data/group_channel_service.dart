import 'dart:async';

import 'package:grpc/grpc.dart' as grpc;
import 'package:fixnum/fixnum.dart' as fixnum;

import '../../../core/network/grpc_client.dart';
import '../../../core/protocol/recipient.dart';
import '../../../core/protocol/recipient_type.dart';
import '../../../core/protocol/verification_badge.dart';
import '../../../core/storage/cached_room_members_page.dart';
import '../../../core/storage/local_store.dart';
import 'package:tureon/generated/google/protobuf/field_mask.pb.dart' as proto;
import '../../../generated/proto/tureon.pb.dart' as pb;

class GroupChannelService {
  GroupChannelService({required this.store, required this.client});

  final LocalStore store;
  final GrpcClient? Function() client;
  final Map<String, Future<Recipient?>> _roomRecipientLookups = {};
  final Map<String, Future<pb.ListGroupChannelMembersPageResponse>>
  _memberPageLookups = {};
  final Map<String, DateTime> _memberPageAttemptsWithoutCache = {};

  static const Duration _memberPageFreshFor = Duration(minutes: 5);
  static const Duration _memberPageRetryBackoff = Duration(seconds: 30);
  static const Duration _memberPageRequestTimeout = Duration(seconds: 5);

  Future<List<Recipient>> searchPublicGroupsAndChannels(String query) async {
    final normalized = query.trim();
    if (normalized.runes.length < 2 || normalized.runes.length > 64) {
      return const [];
    }
    final grpcClient = _requireAuthenticatedClient();
    final responses = await Future.wait([
      grpcClient.groups.searchPublicGroups(
        pb.SearchPublicGroupsRequest(query: normalized),
      ),
      grpcClient.channels.searchPublicChannels(
        pb.SearchPublicChannelsRequest(query: normalized),
      ),
    ]);
    final groups = (responses[0] as pb.SearchPublicGroupsResponse).groups;
    final channels = (responses[1] as pb.SearchPublicChannelsResponse).channels;
    return [
      ...groups.map(_recipientFromGroupChannel),
      ...channels.map(_recipientFromGroupChannel),
    ];
  }

  Future<Recipient?> resolveRoomRecipient(
    String recipientId, {
    required RecipientType type,
    bool forceRefresh = false,
  }) {
    if (type != RecipientType.group && type != RecipientType.channel) {
      return Future<Recipient?>.value();
    }
    final cached = store.loadRecipient(recipientId);
    if (!forceRefresh &&
        cached != null &&
        cached.type == type &&
        !_isIncompleteRoomRecipient(cached)) {
      return Future<Recipient?>.value(cached);
    }
    final session = store.loadSession();
    final key =
        '${session?.userId}:${session?.deviceId}:${type.index}:$recipientId';
    final pending = _roomRecipientLookups[key];
    if (pending != null) return pending;
    late final Future<Recipient?> lookup;
    lookup = _loadRoomRecipient(recipientId, type).whenComplete(() {
      if (identical(_roomRecipientLookups[key], lookup)) {
        _roomRecipientLookups.remove(key);
      }
    });
    _roomRecipientLookups[key] = lookup;
    return lookup;
  }

  bool _isIncompleteRoomRecipient(Recipient recipient) {
    final genericName = recipient.type == RecipientType.group
        ? 'Grupo'
        : 'Canal';
    return recipient.name.trim().isEmpty ||
        (recipient.name.trim() == genericName &&
            recipient.memberCount == 0 &&
            !recipient.isMember &&
            recipient.handle.isEmpty);
  }

  Future<Recipient?> _loadRoomRecipient(
    String recipientId,
    RecipientType type,
  ) async {
    final grpcClient = _requireAuthenticatedClient();
    pb.GroupChannel? room;
    if (type == RecipientType.group) {
      final response = await grpcClient.groups.getGroupChannel(
        pb.GetGroupChannelRequest(groupChannelId: recipientId),
        options: grpc.CallOptions(timeout: const Duration(seconds: 5)),
      );
      if (response.hasGroupChannel()) room = response.groupChannel;
    } else {
      final response = await grpcClient.channels.getGroupChannel(
        pb.GetGroupChannelRequest(groupChannelId: recipientId),
        options: grpc.CallOptions(timeout: const Duration(seconds: 5)),
      );
      if (response.hasGroupChannel()) room = response.groupChannel;
    }
    if (room == null) return null;
    // The caller applies metadata only if its session and room snapshot are
    // still current. Saving here would race durable membership events.
    return _recipientFromGroupChannel(room);
  }

  Future<Recipient> joinPublicGroupChannel(Recipient recipient) async {
    if (recipient.type != RecipientType.group &&
        recipient.type != RecipientType.channel) {
      throw ArgumentError.value(recipient.type, 'recipient.type');
    }
    final grpcClient = _requireAuthenticatedClient();
    final pb.GroupChannel joined;
    if (recipient.type == RecipientType.group) {
      final response = await grpcClient.groups.joinPublicGroup(
        pb.JoinPublicGroupRequest(groupId: recipient.id),
      );
      if (!response.hasGroup()) {
        throw StateError('The server did not confirm group membership.');
      }
      joined = response.group;
    } else {
      final response = await grpcClient.channels.joinPublicChannel(
        pb.JoinPublicChannelRequest(channelId: recipient.id),
      );
      if (!response.hasChannel()) {
        throw StateError('The server did not confirm channel membership.');
      }
      joined = response.channel;
    }
    final result = _recipientFromGroupChannel(joined);
    await store.saveRecipient(result);
    return result;
  }

  Recipient _recipientFromGroupChannel(pb.GroupChannel item) {
    final isGroup = item.type == 'group';
    final type = isGroup ? RecipientType.group : RecipientType.channel;
    final isMember = item.memberRole.isNotEmpty;
    final canSend = isGroup
        ? item.memberRole == 'owner' ||
              item.memberRole == 'admin' ||
              (isMember && item.membersCanSendMessages)
        : item.memberRole == 'owner' ||
              item.memberRole == 'admin' ||
              (isMember && item.membersCanSendMessages);
    final cleanName = item.name.trim();
    return Recipient(
      id: item.id,
      type: type,
      name: cleanName,
      handle: isMember
          ? (item.username.isEmpty ? '' : '@${item.username}')
          : isGroup
          ? (item.username.isEmpty ? 'Grupo público' : '@${item.username}')
          : (item.username.isEmpty ? 'Canal público' : '@${item.username}'),
      avatarUrl: item.avatarUrl.isEmpty ? null : item.avatarUrl,
      createdAt: item.createdAt.toInt() == 0
          ? null
          : DateTime.fromMillisecondsSinceEpoch(
              item.createdAt.toInt() * 1000,
              isUtc: true,
            ),
      description: item.description,
      isUsernameVisible: item.username.isNotEmpty,
      isPresenceVisible: false,
      composerRole: isMember ? item.memberRole : 'member',
      canSendMessages: canSend,
      membersCanSendMessages: item.membersCanSendMessages,
      membersCanSendMedia: item.membersCanSendMedia,
      membersCanSendStickersGifs: item.membersCanSendStickersGifs,
      membersCanEmbedLinks: item.membersCanEmbedLinks,
      membersCanAddMembers: item.membersCanAddMembers,
      membersCanChangeInfo: item.membersCanChangeInfo,
      membersCanReact: item.membersCanReact,
      membersCanForward: item.membersCanForward,
      slowModeSeconds: item.slowModeSeconds,
      memberCount: item.memberCount.toInt(),
      isOfficial: item.isOfficial,
      visibility: item.visibility,
      isMember: isMember,
      verificationBadge: item.isOfficial
          ? VerificationBadge.verified
          : VerificationBadge.none,
    );
  }

  Future<Recipient> createGroup({
    required String name,
    String description = '',
    String avatarUrl = '',
    String visibility = 'public',
  }) async {
    final grpcClient = _requireAuthenticatedClient();
    final response = await grpcClient.groups.createGroup(
      pb.CreateGroupRequest(
        name: name.trim(),
        description: description.trim(),
        avatarUrl: avatarUrl.trim(),
        visibility: visibility.trim().isEmpty ? 'public' : visibility.trim(),
      ),
    );
    if (!response.hasGroup()) {
      throw StateError('The server did not return the created group.');
    }
    final group = response.group;
    final recipient = Recipient(
      id: group.id,
      type: RecipientType.group,
      name: group.name.isEmpty ? name.trim() : group.name,
      handle: group.username.isEmpty ? '' : '@${group.username}',
      description: group.description,
      avatarUrl: group.avatarUrl.isEmpty ? null : group.avatarUrl,
      lastMessage: 'Grupo criado',
      unreadCount: 0,
      isOnline: false,
      isUsernameVisible: group.username.isNotEmpty,
      isPresenceVisible: false,
      composerRole: group.memberRole.isEmpty ? 'owner' : group.memberRole,
      canSendMessages:
          group.memberRole.isEmpty ||
          group.memberRole == 'owner' ||
          group.memberRole == 'admin' ||
          group.membersCanSendMessages,
      membersCanSendMessages: group.membersCanSendMessages,
      membersCanSendMedia: group.membersCanSendMedia,
      membersCanSendStickersGifs: group.membersCanSendStickersGifs,
      membersCanEmbedLinks: group.membersCanEmbedLinks,
      membersCanAddMembers: group.membersCanAddMembers,
      membersCanChangeInfo: group.membersCanChangeInfo,
      memberCount: group.memberCount.toInt(),
      isOfficial: group.isOfficial,
      visibility: group.visibility,
      isMember: true,
      verificationBadge: VerificationBadge.none,
    );
    await store.saveRecipient(recipient);
    return recipient;
  }

  Future<Recipient> createChannel({
    required String name,
    String description = '',
    String avatarUrl = '',
    String visibility = 'public',
  }) async {
    final grpcClient = _requireAuthenticatedClient();
    final response = await grpcClient.channels.createChannel(
      pb.CreateChannelRequest(
        name: name.trim(),
        description: description.trim(),
        avatarUrl: avatarUrl.trim(),
        visibility: visibility.trim().isEmpty ? 'public' : visibility.trim(),
      ),
    );
    if (!response.hasChannel()) {
      throw StateError('The server did not return the created channel.');
    }
    final channel = response.channel;
    final recipient = Recipient(
      id: channel.id,
      type: RecipientType.channel,
      name: channel.name.isEmpty ? name.trim() : channel.name,
      handle: channel.username.isEmpty ? '' : '@${channel.username}',
      description: channel.description,
      avatarUrl: channel.avatarUrl.isEmpty ? null : channel.avatarUrl,
      lastMessage: 'Canal criado',
      unreadCount: 0,
      isOnline: false,
      isUsernameVisible: channel.username.isNotEmpty,
      isPresenceVisible: false,
      composerRole: channel.memberRole.isEmpty ? 'owner' : channel.memberRole,
      canSendMessages:
          channel.memberRole.isEmpty ||
          channel.memberRole == 'owner' ||
          channel.memberRole == 'admin' ||
          channel.membersCanSendMessages,
      membersCanSendMessages: channel.membersCanSendMessages,
      membersCanSendMedia: channel.membersCanSendMedia,
      membersCanSendStickersGifs: channel.membersCanSendStickersGifs,
      membersCanEmbedLinks: channel.membersCanEmbedLinks,
      membersCanAddMembers: channel.membersCanAddMembers,
      membersCanChangeInfo: channel.membersCanChangeInfo,
      membersCanReact: channel.membersCanReact,
      membersCanForward: channel.membersCanForward,
      memberCount: channel.memberCount.toInt(),
      isOfficial: channel.isOfficial,
      visibility: channel.visibility,
      isMember: true,
      verificationBadge: VerificationBadge.none,
    );
    await store.saveRecipient(recipient);
    return recipient;
  }

  Future<pb.GroupChannel> loadProfile({
    required String groupChannelId,
    required bool isChannel,
  }) async {
    final grpcClient = _requireAuthenticatedClient();
    final response = isChannel
        ? await grpcClient.channels.getGroupChannel(
            pb.GetGroupChannelRequest(groupChannelId: groupChannelId),
          )
        : await grpcClient.groups.getGroupChannel(
            pb.GetGroupChannelRequest(groupChannelId: groupChannelId),
          );
    if (!response.hasGroupChannel()) {
      throw StateError(
        'The group or channel is not available to this account.',
      );
    }
    return response.groupChannel;
  }

  Future<pb.GroupChannel> updateProfile({
    required String groupChannelId,
    required bool isChannel,
    required String name,
    required String username,
    required String description,
    required String avatarUrl,
    required String visibility,
  }) async {
    final grpcClient = _requireAuthenticatedClient();
    final request = pb.UpdateGroupChannelRequest(
      groupChannelId: groupChannelId,
      name: name.trim(),
      username: username.trim().replaceFirst(RegExp(r'^@'), ''),
      description: description.trim(),
      avatarUrl: avatarUrl.trim(),
      visibility: visibility,
      updateMask: proto.FieldMask(
        paths: ['name', 'username', 'description', 'avatar_url', 'visibility'],
      ),
    );
    final response = isChannel
        ? await grpcClient.channels.updateChannel(request)
        : await grpcClient.groups.updateGroup(request);
    if (!response.hasGroupChannel()) {
      throw StateError('The server did not return the updated profile.');
    }
    final updated = response.groupChannel;
    final cached = store.loadRecipient(groupChannelId);
    if (cached != null) {
      await store.saveRecipient(
        cached.copyWith(
          name: updated.name,
          handle: updated.username.isEmpty ? '' : '@${updated.username}',
          isUsernameVisible: updated.username.isNotEmpty,
          description: updated.description,
          avatarUrl: updated.avatarUrl.isEmpty ? null : updated.avatarUrl,
          clearAvatarUrl: updated.avatarUrl.isEmpty,
          memberCount: updated.memberCount.toInt(),
          membersCanSendMessages: updated.membersCanSendMessages,
          membersCanSendMedia: updated.membersCanSendMedia,
          membersCanSendStickersGifs: updated.membersCanSendStickersGifs,
          membersCanEmbedLinks: updated.membersCanEmbedLinks,
          membersCanAddMembers: updated.membersCanAddMembers,
          membersCanChangeInfo: updated.membersCanChangeInfo,
          membersCanReact: updated.membersCanReact,
          membersCanForward: updated.membersCanForward,
          slowModeSeconds: updated.slowModeSeconds,
          visibility: updated.visibility,
        ),
      );
    }
    return updated;
  }

  Future<void> addMember({
    required String groupChannelId,
    required String userId,
    required bool isChannel,
  }) async {
    await _requireAuthenticatedClient().groups.addMember(
      pb.Empty(),
      options: grpc.CallOptions(
        metadata: {
          'group-channel-id': groupChannelId,
          'user-id': userId,
          'role': isChannel ? 'subscriber' : 'member',
        },
      ),
    );
  }

  Future<List<pb.GroupChannelMember>> listMembers({
    required String groupChannelId,
  }) async {
    final response = await _requireAuthenticatedClient().groups.listMembers(
      pb.Empty(),
      options: grpc.CallOptions(metadata: {'group-channel-id': groupChannelId}),
    );
    return response.members;
  }

  Future<pb.ListGroupChannelMembersPageResponse> listMembersPage({
    required String groupChannelId,
    required int offset,
    int pageSize = 50,
    bool forceRefresh = false,
  }) async {
    if (groupChannelId.isEmpty || offset < 0) {
      throw ArgumentError(
        'A room id and non-negative page offset are required.',
      );
    }
    final requestingAccountId = store.loadSession()?.userId;
    if (requestingAccountId == null || requestingAccountId.isEmpty) {
      throw StateError('A signed-in account is required to load members.');
    }
    final boundedPageSize = pageSize.clamp(1, 100).toInt();
    final cached = store.loadRoomMembersPage(
      roomId: groupChannelId,
      offset: offset,
      pageSize: boundedPageSize,
    );
    final now = DateTime.now().toUtc();
    if (!forceRefresh && cached != null) {
      final age = now.difference(cached.fetchedAt);
      final retryAge = now.difference(cached.lastAttemptAt);
      if (age < _memberPageFreshFor || retryAge < _memberPageRetryBackoff) {
        await _persistCachedMemberCount(groupChannelId, cached.totalCount);
        return _pageFromCache(cached);
      }
    }

    final key = '$requestingAccountId:$groupChannelId:$offset:$boundedPageSize';
    final pending = _memberPageLookups[key];
    if (pending != null) return pending;
    if (!forceRefresh && cached == null) {
      final previousAttempt = _memberPageAttemptsWithoutCache[key];
      if (previousAttempt != null &&
          now.difference(previousAttempt) < _memberPageRetryBackoff) {
        throw StateError('Member page refresh is temporarily backed off.');
      }
    }

    final request = _fetchAndCacheMembersPage(
      groupChannelId: groupChannelId,
      accountId: requestingAccountId,
      offset: offset,
      pageSize: boundedPageSize,
      cached: cached,
      key: key,
    );
    _memberPageLookups[key] = request;
    try {
      return await request;
    } finally {
      if (identical(_memberPageLookups[key], request)) {
        _memberPageLookups.remove(key);
      }
    }
  }

  pb.ListGroupChannelMembersPageResponse? loadCachedMembersPage({
    required String groupChannelId,
    required int offset,
    int pageSize = 50,
  }) {
    final boundedPageSize = pageSize.clamp(1, 100).toInt();
    final cached = store.loadRoomMembersPage(
      roomId: groupChannelId,
      offset: offset,
      pageSize: boundedPageSize,
    );
    return cached == null ? null : _pageFromCache(cached);
  }

  Future<pb.ListGroupChannelMembersPageResponse> _fetchAndCacheMembersPage({
    required String groupChannelId,
    required String accountId,
    required int offset,
    required int pageSize,
    required CachedRoomMembersPage? cached,
    required String key,
  }) async {
    final attemptedAt = DateTime.now().toUtc();
    if (cached == null) {
      _memberPageAttemptsWithoutCache[key] = attemptedAt;
      if (_memberPageAttemptsWithoutCache.length > 64) {
        final oldestKey = _memberPageAttemptsWithoutCache.entries
            .reduce(
              (oldest, entry) =>
                  entry.value.isBefore(oldest.value) ? entry : oldest,
            )
            .key;
        _memberPageAttemptsWithoutCache.remove(oldestKey);
      }
    } else {
      store.markRoomMembersPageRefreshAttempt(
        roomId: groupChannelId,
        offset: offset,
        pageSize: pageSize,
        attemptedAt: attemptedAt,
      );
    }

    final pb.ListGroupChannelMembersPageResponse response;
    try {
      response = await _requireAuthenticatedClient().groups.listMembersPage(
        pb.ListGroupChannelMembersPageRequest(
          groupChannelId: groupChannelId,
          pageSize: pageSize,
          offset: fixnum.Int64(offset),
        ),
        options: grpc.CallOptions(timeout: _memberPageRequestTimeout),
      );
    } catch (_) {
      if (store.loadSession()?.userId != accountId) rethrow;
      final latestCache = store.loadRoomMembersPage(
        roomId: groupChannelId,
        offset: offset,
        pageSize: pageSize,
      );
      if (latestCache != null) {
        await _persistCachedMemberCount(groupChannelId, latestCache.totalCount);
        return _pageFromCache(latestCache);
      }
      rethrow;
    }
    if (store.loadSession()?.userId != accountId) {
      throw StateError('The active account changed while loading members.');
    }
    final fetchedAt = DateTime.now().toUtc();
    final page = CachedRoomMembersPage(
      roomId: groupChannelId,
      offset: offset,
      pageSize: pageSize,
      members: response.members
          .map(
            (member) => CachedRoomMember(
              userId: member.userId,
              role: member.role,
              joinedAt: member.joinedAt.toInt(),
              displayName: member.displayName,
              username: member.username,
              avatarUrl: member.avatarUrl,
            ),
          )
          .toList(growable: false),
      totalCount: response.totalCount.toInt(),
      nextOffset: response.nextOffset.toInt(),
      hasMore: response.hasMore,
      fetchedAt: fetchedAt,
      lastAttemptAt: attemptedAt,
    );
    await store.saveRoomMembersPage(page);
    await _persistCachedMemberCount(groupChannelId, page.totalCount);
    _memberPageAttemptsWithoutCache.remove(key);
    return _pageFromCache(page);
  }

  Future<void> _persistCachedMemberCount(String roomId, int totalCount) async {
    final recipient = store.loadRecipient(roomId);
    if (recipient == null || recipient.memberCount == totalCount) return;
    await store.saveRecipient(recipient.copyWith(memberCount: totalCount));
  }

  pb.ListGroupChannelMembersPageResponse _pageFromCache(
    CachedRoomMembersPage page,
  ) => pb.ListGroupChannelMembersPageResponse(
    members: page.members
        .map(
          (member) => pb.GroupChannelMember(
            userId: member.userId,
            role: member.role,
            joinedAt: fixnum.Int64(member.joinedAt),
            displayName: member.displayName,
            username: member.username,
            avatarUrl: member.avatarUrl,
          ),
        )
        .toList(growable: false),
    totalCount: fixnum.Int64(page.totalCount),
    nextOffset: fixnum.Int64(page.nextOffset),
    hasMore: page.hasMore,
  );

  Future<int> loadOnlineGroupMemberCount({required String groupId}) async {
    final response = await _requireAuthenticatedClient().groups
        .getOnlineMemberCount(
          pb.GetGroupOnlineMemberCountRequest(groupId: groupId),
        );
    return response.onlineMemberCount.toInt();
  }

  Future<void> leaveGroupChannel({required String groupChannelId}) async {
    final session = store.loadSession();
    if (session == null || session.userId.isEmpty) {
      throw StateError(
        'Uma sessão autenticada é necessária para sair do grupo.',
      );
    }
    await removeMember(groupChannelId: groupChannelId, userId: session.userId);
    store.deleteRecipient(groupChannelId);
  }

  Future<void> updateMemberRole({
    required String groupChannelId,
    required String userId,
    required String role,
  }) async {
    await _requireAuthenticatedClient().groups.updateMemberRole(
      pb.Empty(),
      options: grpc.CallOptions(
        metadata: {
          'group-channel-id': groupChannelId,
          'user-id': userId,
          'role': role,
        },
      ),
    );
  }

  Future<void> updateMembersCanSendMessages({
    required String groupChannelId,
    required bool isChannel,
    required bool allowed,
  }) async {
    final grpcClient = _requireAuthenticatedClient();
    final request = pb.UpdateGroupChannelSendPermissionRequest(
      groupChannelId: groupChannelId,
      membersCanSendMessages: allowed,
    );
    final response = isChannel
        ? await grpcClient.channels.updateChannelSendPermission(request)
        : await grpcClient.groups.updateGroupSendPermission(request);
    final cached = store.loadRecipient(groupChannelId);
    if (cached == null) return;
    await store.saveRecipient(
      cached.copyWith(
        membersCanSendMessages: response.membersCanSendMessages,
        canSendMessages:
            cached.composerRole == 'owner' ||
            cached.composerRole == 'admin' ||
            response.membersCanSendMessages,
      ),
    );
  }

  Future<pb.GroupChannel> updatePermissions({
    required String groupChannelId,
    required bool isChannel,
    required Map<String, bool> permissions,
    int slowModeSeconds = 0,
  }) async {
    final grpcClient = _requireAuthenticatedClient();
    final request = pb.UpdateGroupChannelPermissionsRequest(
      groupChannelId: groupChannelId,
      membersCanSendMessages: permissions['send_messages'] ?? false,
      membersCanSendMedia: permissions['send_media'] ?? false,
      membersCanSendStickersGifs: permissions['send_stickers'] ?? false,
      membersCanEmbedLinks: permissions['embed_links'] ?? false,
      membersCanAddMembers: permissions['add_members'] ?? false,
      membersCanChangeInfo: permissions['change_info'] ?? false,
      membersCanReact: permissions['can_reactions'] ?? false,
      membersCanForward: permissions['can_forward'] ?? false,
      slowModeSeconds: slowModeSeconds,
    );
    final updated = isChannel
        ? await grpcClient.channels.updateChannelPermissions(request)
        : await grpcClient.groups.updateGroupPermissions(request);
    final cached = store.loadRecipient(groupChannelId);
    final recipient = _recipientFromGroupChannel(updated).copyWith(
      lastMessage: cached?.lastMessage,
      unreadCount: cached?.unreadCount ?? 0,
      isOnline: cached?.isOnline ?? false,
      isTyping: cached?.isTyping ?? false,
    );
    await store.saveRecipient(recipient);
    return updated;
  }

  Future<void> removeMember({
    required String groupChannelId,
    required String userId,
  }) async {
    await _requireAuthenticatedClient().groups.removeMember(
      pb.Empty(),
      options: grpc.CallOptions(
        metadata: {'group-channel-id': groupChannelId, 'user-id': userId},
      ),
    );
  }

  Future<void> banMember({
    required String groupChannelId,
    required String userId,
  }) async {
    await _requireAuthenticatedClient().groups.banUser(
      pb.Empty(),
      options: grpc.CallOptions(
        metadata: {'group-channel-id': groupChannelId, 'user-id': userId},
      ),
    );
  }

  GrpcClient _requireAuthenticatedClient() {
    final grpcClient = client();
    if (grpcClient == null || !grpcClient.hasAccessToken) {
      throw StateError('A connected signed-in device is required.');
    }
    return grpcClient;
  }
}
