import 'package:tureon/core/protocol/recipient.dart';
import 'package:tureon/core/protocol/recipient_type.dart';
import 'package:tureon/core/protocol/system_event_type.dart';
import 'system_message_delivery_mapper.dart';

class RoomSystemSnapshot {
  const RoomSystemSnapshot();
  Recipient applySnapshot(
    Recipient recipient,
    RoomSystemMessageDelivery delivery,
    String currentUserId,
  ) {
    final metadata = delivery.roomMetadata;
    final expectedRoomType = recipient.type == RecipientType.group
        ? 'group'
        : recipient.type == RecipientType.channel
        ? 'channel'
        : null;
    if (expectedRoomType == null ||
        delivery.roomId != recipient.id ||
        delivery.roomType != recipient.type ||
        metadata['room_type'] != expectedRoomType ||
        metadata['room_member_count'] == null) {
      return recipient;
    }
    final snapshotVersion = delivery.roomSequence > 0
        ? delivery.roomSequence
        : int.tryParse(metadata['room_version'] ?? '');
    if (snapshotVersion != null && snapshotVersion <= recipient.roomVersion) {
      return recipient;
    }

    String? stringValue(String key) =>
        metadata.containsKey(key) ? metadata[key] : null;
    bool? booleanValue(String key) => switch (metadata[key]?.toLowerCase()) {
      'true' => true,
      'false' => false,
      _ => null,
    };
    final parsedMemberCount = int.tryParse(metadata['room_member_count']!);
    final event = delivery.systemEvent;
    var isMember = recipient.isMember;
    var composerRole = recipient.composerRole;
    if (event != null) {
      final isGroup = recipient.type == RecipientType.group;
      final joinedType = isGroup
          ? SystemEventType.userJoinedGroup
          : SystemEventType.userJoinedChannel;
      final leftType = isGroup
          ? SystemEventType.userLeftGroup
          : SystemEventType.userLeftChannel;
      final addedType = isGroup
          ? SystemEventType.userAddedToGroup
          : SystemEventType.userAddedToChannel;
      final removedType = isGroup
          ? SystemEventType.userRemovedFromGroup
          : SystemEventType.userRemovedFromChannel;
      final bannedType = isGroup
          ? SystemEventType.userBannedFromGroup
          : SystemEventType.userBannedFromChannel;
      if ((event.eventType == joinedType &&
              event.actorUserId == currentUserId) ||
          (event.eventType == addedType &&
              event.targetUserId == currentUserId)) {
        isMember = true;
        composerRole = event.role ?? (isGroup ? 'member' : 'subscriber');
      } else if ((event.eventType == leftType &&
              event.actorUserId == currentUserId) ||
          ((event.eventType == removedType || event.eventType == bannedType) &&
              event.targetUserId == currentUserId)) {
        isMember = false;
        composerRole = isGroup ? 'member' : 'subscriber';
      } else if (event.eventType == SystemEventType.userRoleChanged &&
          event.targetUserId == currentUserId &&
          event.role != null &&
          event.role!.isNotEmpty) {
        composerRole = event.role!;
      }
    }

    final canSendMessages =
        booleanValue('members_can_send_messages') ??
        recipient.membersCanSendMessages;
    final membersCanSendMedia =
        booleanValue('members_can_send_media') ?? recipient.membersCanSendMedia;
    final membersCanSendStickersGifs =
        booleanValue('members_can_send_stickers_gifs') ??
        recipient.membersCanSendStickersGifs;
    final membersCanEmbedLinks =
        booleanValue('members_can_embed_links') ??
        recipient.membersCanEmbedLinks;
    final membersCanAddMembers =
        booleanValue('members_can_add_members') ??
        recipient.membersCanAddMembers;
    final membersCanChangeInfo =
        booleanValue('members_can_change_info') ??
        recipient.membersCanChangeInfo;
    final membersCanReact =
        booleanValue('members_can_react') ?? recipient.membersCanReact;
    final membersCanForward =
        booleanValue('members_can_forward') ?? recipient.membersCanForward;
    final slowModeSeconds = int.tryParse(metadata['slow_mode_seconds'] ?? '');
    final changedFields =
        delivery.systemEvent?.changedFields ?? const <String>[];
    final canManage = composerRole == 'owner' || composerRole == 'admin';
    final canSend = isMember && (canManage || canSendMessages);
    final avatar = stringValue('room_avatar_url');
    final username = stringValue('room_username');

    return recipient.copyWith(
      name: stringValue('room_name') ?? recipient.name,
      handle: username == null
          ? recipient.handle
          : username.isEmpty
          ? ''
          : '@$username',
      isUsernameVisible: username == null
          ? recipient.isUsernameVisible
          : username.isNotEmpty,
      description: stringValue('room_description') ?? recipient.description,
      avatarUrl: avatar == null || avatar.isEmpty ? null : avatar,
      clearAvatarUrl: avatar?.isEmpty == true,
      composerRole: composerRole,
      canSendMessages: canSend,
      membersCanSendMessages: canSendMessages,
      membersCanSendMedia: membersCanSendMedia,
      membersCanSendStickersGifs: membersCanSendStickersGifs,
      membersCanEmbedLinks: membersCanEmbedLinks,
      membersCanAddMembers: membersCanAddMembers,
      membersCanChangeInfo: membersCanChangeInfo,
      membersCanReact: membersCanReact,
      membersCanForward: membersCanForward,
      slowModeSeconds:
          changedFields.contains('slow_mode_seconds') && slowModeSeconds != null
          ? slowModeSeconds
          : recipient.slowModeSeconds,
      memberCount: parsedMemberCount == null || parsedMemberCount < 0
          ? recipient.memberCount
          : parsedMemberCount,
      visibility: stringValue('room_visibility') ?? recipient.visibility,
      isMember: isMember,
      roomVersion: snapshotVersion ?? recipient.roomVersion,
    );
  }

  bool isCurrentUserRemoved(
    RoomSystemMessageDelivery delivery,
    String currentUserId,
  ) {
    final event = delivery.systemEvent;
    if (event == null || currentUserId.isEmpty) return false;
    final isGroup = delivery.roomType == RecipientType.group;
    final isChannel = delivery.roomType == RecipientType.channel;
    if (!isGroup && !isChannel) return false;
    final leftType = isGroup
        ? SystemEventType.userLeftGroup
        : SystemEventType.userLeftChannel;
    final removedType = isGroup
        ? SystemEventType.userRemovedFromGroup
        : SystemEventType.userRemovedFromChannel;
    final bannedType = isGroup
        ? SystemEventType.userBannedFromGroup
        : SystemEventType.userBannedFromChannel;
    return (event.eventType == leftType &&
            event.actorUserId == currentUserId) ||
        ((event.eventType == removedType || event.eventType == bannedType) &&
            event.targetUserId == currentUserId);
  }
}
