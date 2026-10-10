class CachedRoomMember {
  const CachedRoomMember({
    required this.userId,
    required this.role,
    required this.joinedAt,
    required this.displayName,
    required this.username,
    required this.avatarUrl,
  });

  final String userId;
  final String role;
  final int joinedAt;
  final String displayName;
  final String username;
  final String avatarUrl;

  Map<String, Object?> toJson() => {
    'user_id': userId,
    'role': role,
    'joined_at': joinedAt,
    'display_name': displayName,
    'username': username,
    'avatar_url': avatarUrl,
  };

  factory CachedRoomMember.fromJson(Map<String, Object?> json) =>
      CachedRoomMember(
        userId: json['user_id'] as String? ?? '',
        role: json['role'] as String? ?? '',
        joinedAt: json['joined_at'] as int? ?? 0,
        displayName: json['display_name'] as String? ?? '',
        username: json['username'] as String? ?? '',
        avatarUrl: json['avatar_url'] as String? ?? '',
      );
}

class CachedRoomMembersPage {
  const CachedRoomMembersPage({
    required this.roomId,
    required this.offset,
    required this.pageSize,
    required this.members,
    required this.totalCount,
    required this.nextOffset,
    required this.hasMore,
    required this.fetchedAt,
    required this.lastAttemptAt,
  });

  final String roomId;
  final int offset;
  final int pageSize;
  final List<CachedRoomMember> members;
  final int totalCount;
  final int nextOffset;
  final bool hasMore;
  final DateTime fetchedAt;
  final DateTime lastAttemptAt;
}
