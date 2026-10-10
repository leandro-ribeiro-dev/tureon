import 'recipient_type.dart';
import 'verification_badge.dart';

class Recipient {
  const Recipient({
    required this.id,
    required this.type,
    required this.name,
    required this.handle,
    this.avatarUrl,
    this.description = '',
    this.lastMessage,
    this.unreadCount = 0,
    this.isOnline = false,
    this.isUsernameVisible = false,
    this.isPresenceVisible = false,
    this.lastSeenAt,
    this.presenceUpdate = false,
    this.composerRole = 'member',
    this.canSendMessages = true,
    this.membersCanSendMessages = true,
    this.membersCanSendMedia = true,
    this.membersCanSendStickersGifs = true,
    this.membersCanEmbedLinks = true,
    this.membersCanAddMembers = true,
    this.membersCanChangeInfo = false,
    this.membersCanReact = true,
    this.membersCanForward = true,
    this.slowModeSeconds = 0,
    this.memberCount = 0,
    this.isOfficial = false,
    this.visibility = 'public',
    this.restrictedUntil,
    this.verificationBadge = VerificationBadge.none,
    this.profileVersion = 0,
    this.roomVersion = 0,
    this.countryCode = '',
    this.createdAt,
    this.isTyping = false,
    this.isMember = true,
  });
  final String id;
  final RecipientType type;
  final String name;
  final String handle;
  final String? avatarUrl;
  final String description;
  final String? lastMessage;
  final int unreadCount;
  final bool isOnline;
  final bool isUsernameVisible;
  final bool isPresenceVisible;
  final DateTime? lastSeenAt;
  final bool presenceUpdate;
  final String composerRole;
  final bool canSendMessages;
  final bool membersCanSendMessages;
  final bool membersCanSendMedia;
  final bool membersCanSendStickersGifs;
  final bool membersCanEmbedLinks;
  final bool membersCanAddMembers;
  final bool membersCanChangeInfo;
  final bool membersCanReact;
  final bool membersCanForward;
  final int slowModeSeconds;
  final int memberCount;
  final bool isOfficial;
  final String visibility;
  final DateTime? restrictedUntil;
  final VerificationBadge verificationBadge;
  final int profileVersion;
  final int roomVersion;
  final String countryCode;
  final DateTime? createdAt;
  final bool isTyping;
  final bool isMember;

  Recipient copyWith({
    String? id,
    RecipientType? type,
    String? name,
    String? handle,
    String? avatarUrl,
    String? description,
    bool clearAvatarUrl = false,
    String? lastMessage,
    int? unreadCount,
    bool? isOnline,
    bool? isUsernameVisible,
    bool? isPresenceVisible,
    DateTime? lastSeenAt,
    bool clearLastSeenAt = false,
    bool? presenceUpdate,
    String? composerRole,
    bool? canSendMessages,
    bool? membersCanSendMessages,
    bool? membersCanSendMedia,
    bool? membersCanSendStickersGifs,
    bool? membersCanEmbedLinks,
    bool? membersCanAddMembers,
    bool? membersCanChangeInfo,
    bool? membersCanReact,
    bool? membersCanForward,
    int? slowModeSeconds,
    int? memberCount,
    bool? isOfficial,
    String? visibility,
    DateTime? restrictedUntil,
    VerificationBadge? verificationBadge,
    int? profileVersion,
    int? roomVersion,
    String? countryCode,
    DateTime? createdAt,
    bool? isTyping,
    bool? isMember,
  }) => Recipient(
    id: id ?? this.id,
    type: type ?? this.type,
    name: name ?? this.name,
    handle: handle ?? this.handle,
    avatarUrl: clearAvatarUrl ? null : (avatarUrl ?? this.avatarUrl),
    description: description ?? this.description,
    lastMessage: lastMessage ?? this.lastMessage,
    unreadCount: unreadCount ?? this.unreadCount,
    isOnline: isOnline ?? this.isOnline,
    isUsernameVisible: isUsernameVisible ?? this.isUsernameVisible,
    isPresenceVisible: isPresenceVisible ?? this.isPresenceVisible,
    lastSeenAt: clearLastSeenAt ? null : (lastSeenAt ?? this.lastSeenAt),
    presenceUpdate: presenceUpdate ?? this.presenceUpdate,
    composerRole: composerRole ?? this.composerRole,
    canSendMessages: canSendMessages ?? this.canSendMessages,
    membersCanSendMessages:
        membersCanSendMessages ?? this.membersCanSendMessages,
    membersCanSendMedia: membersCanSendMedia ?? this.membersCanSendMedia,
    membersCanSendStickersGifs:
        membersCanSendStickersGifs ?? this.membersCanSendStickersGifs,
    membersCanEmbedLinks: membersCanEmbedLinks ?? this.membersCanEmbedLinks,
    membersCanAddMembers: membersCanAddMembers ?? this.membersCanAddMembers,
    membersCanChangeInfo: membersCanChangeInfo ?? this.membersCanChangeInfo,
    membersCanReact: membersCanReact ?? this.membersCanReact,
    membersCanForward: membersCanForward ?? this.membersCanForward,
    slowModeSeconds: slowModeSeconds ?? this.slowModeSeconds,
    memberCount: memberCount ?? this.memberCount,
    isOfficial: isOfficial ?? this.isOfficial,
    visibility: visibility ?? this.visibility,
    restrictedUntil: restrictedUntil ?? this.restrictedUntil,
    verificationBadge: verificationBadge ?? this.verificationBadge,
    profileVersion: profileVersion ?? this.profileVersion,
    roomVersion: roomVersion ?? this.roomVersion,
    countryCode: countryCode ?? this.countryCode,
    createdAt: createdAt ?? this.createdAt,
    isTyping: isTyping ?? this.isTyping,
    isMember: isMember ?? this.isMember,
  );
}
