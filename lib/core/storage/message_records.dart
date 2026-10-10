import 'dart:typed_data';

import '../protocol/protocol_models.dart';

class EnvelopeRecord {
  const EnvelopeRecord({
    required this.envelopeId,
    required this.senderRecipientId,
    required this.targetRecipientId,
    required this.targetDeviceId,
    required this.type,
    required this.ciphertext,
    required this.timestamp,
    required this.status,
  });

  final String envelopeId;
  final String senderRecipientId;
  final String targetRecipientId;
  final String targetDeviceId;
  final MessageType type;
  final Uint8List ciphertext;
  final DateTime timestamp;
  final DeliveryStatus status;
}

class SecretDeliveryRecord {
  const SecretDeliveryRecord({
    required this.deliveryId,
    required this.messageId,
    required this.chatId,
    required this.senderRecipientId,
    required this.targetRecipientId,
    required this.messageType,
    required this.ciphertext,
    required this.timestamp,
  });

  final String deliveryId;
  final String messageId;
  final String chatId;
  final String senderRecipientId;
  final String targetRecipientId;
  final int messageType;
  final Uint8List ciphertext;
  final DateTime timestamp;
}

/// A device-local translation of a message. The original message remains
/// unchanged and is still the value used for delivery and synchronization.
enum OutboxStatus { pending, sending, failed, preparing }

enum PendingChatCommandType { messageMutation, readReceipt }

class PendingChatCommand {
  const PendingChatCommand({
    required this.accountId,
    required this.commandId,
    required this.relatedMessageId,
    required this.type,
    required this.payload,
    required this.attempts,
    required this.nextAttemptAt,
    required this.createdAt,
  });

  final String accountId;
  final String commandId;
  final String relatedMessageId;
  final PendingChatCommandType type;
  final Uint8List payload;
  final int attempts;
  final DateTime nextAttemptAt;
  final DateTime createdAt;
}

class OutboxRecord {
  const OutboxRecord({
    required this.accountId,
    required this.messageId,
    required this.senderDeviceId,
    required this.localChatId,
    required this.chatId,
    required this.senderRecipientId,
    required this.targetRecipientId,
    required this.targetDeviceId,
    required this.isSecret,
    required this.messageType,
    required this.payload,
    required this.status,
    required this.attempts,
    required this.nextAttemptAt,
    required this.createdAt,
    required this.expiresAt,
  });

  final String accountId;
  final String messageId;
  final String senderDeviceId;
  final String localChatId;
  final String chatId;
  final String senderRecipientId;
  final String targetRecipientId;
  final String? targetDeviceId;
  final bool isSecret;
  final int messageType;
  final Uint8List payload;
  final OutboxStatus status;
  final int attempts;
  final DateTime nextAttemptAt;
  final DateTime createdAt;
  final DateTime expiresAt;
}

class SystemMessageRecord {
  const SystemMessageRecord({
    required this.messageId,
    required this.recipientId,
    required this.message,
  });

  final String messageId;
  final String recipientId;
  final SystemMessage message;
}

class UserSession {
  const UserSession({
    required this.userId,
    this.accessToken = '',
    this.refreshToken = '',
    required this.deviceId,
    this.signalDeviceId = 1,
    this.username = '',
    this.email = '',
    this.displayName = '',
    this.avatarUrl,
    this.accountStatus = 'active',
    this.needsUsername = false,
  });

  final String userId;
  final String accessToken;
  final String refreshToken;
  final String deviceId;
  final int signalDeviceId;
  final String username;
  final String email;
  final String displayName;
  final String? avatarUrl;
  final String accountStatus;
  final bool needsUsername;
}

class DeviceSession {
  const DeviceSession({
    required this.deviceId,
    required this.name,
    required this.platform,
    required this.lastActiveAt,
    required this.isCurrent,
  });

  final String deviceId;
  final String name;
  final String platform;
  final DateTime lastActiveAt;
  final bool isCurrent;
}

class UserProfile {
  const UserProfile({
    required this.userId,
    required this.username,
    required this.displayName,
    this.bio,
    this.avatarUrl,
    this.phoneE164 = '',
    this.countryCode = '',
    this.birthday = '',
    this.createdAt,
    this.privacySettings = const {},
    this.verificationBadge = VerificationBadge.none,
    this.profileVersion = 1,
  });

  final String userId;
  final String username;
  final String displayName;
  final String? bio;
  final String? avatarUrl;
  final String phoneE164;
  final String countryCode;
  final String birthday;
  final DateTime? createdAt;
  final Map<String, String> privacySettings;
  final VerificationBadge verificationBadge;
  final int profileVersion;

  UserProfile copyWith({
    String? username,
    String? displayName,
    String? bio,
    String? avatarUrl,
    bool clearAvatarUrl = false,
    String? phoneE164,
    String? countryCode,
    String? birthday,
    DateTime? createdAt,
    Map<String, String>? privacySettings,
    VerificationBadge? verificationBadge,
    int? profileVersion,
  }) => UserProfile(
    userId: userId,
    username: username ?? this.username,
    displayName: displayName ?? this.displayName,
    bio: bio ?? this.bio,
    avatarUrl: clearAvatarUrl ? null : avatarUrl ?? this.avatarUrl,
    phoneE164: phoneE164 ?? this.phoneE164,
    countryCode: countryCode ?? this.countryCode,
    birthday: birthday ?? this.birthday,
    createdAt: createdAt ?? this.createdAt,
    privacySettings: privacySettings ?? this.privacySettings,
    verificationBadge: verificationBadge ?? this.verificationBadge,
    profileVersion: profileVersion ?? this.profileVersion,
  );

  Map<String, Object?> toJson() => {
    'userId': userId,
    'username': username,
    'displayName': displayName,
    'bio': bio,
    'avatarUrl': avatarUrl,
    'phoneE164': phoneE164,
    'countryCode': countryCode,
    'birthday': birthday,
    'createdAt': createdAt?.toUtc().millisecondsSinceEpoch,
    'privacySettings': privacySettings,
    'verificationBadge': verificationBadge.name,
    'profileVersion': profileVersion,
  };

  factory UserProfile.fromJson(Map<String, Object?> json) => UserProfile(
    userId: json['userId']! as String,
    username: json['username']! as String,
    displayName: json['displayName']! as String,
    bio: json['bio'] as String?,
    avatarUrl: json['avatarUrl'] as String?,
    phoneE164: json['phoneE164'] as String? ?? '',
    countryCode: json['countryCode'] as String? ?? '',
    birthday: json['birthday'] as String? ?? '',
    createdAt: json['createdAt'] is int
        ? DateTime.fromMillisecondsSinceEpoch(
            json['createdAt']! as int,
            isUtc: true,
          )
        : null,
    privacySettings: (json['privacySettings'] as Map? ?? const {})
        .cast<String, String>(),
    verificationBadge: verificationBadgeFromServer(
      json['verificationBadge'] as String? ?? 'none',
    ),
    profileVersion: json['profileVersion'] as int? ?? 1,
  );
}

class ProfileSyncPendingException implements Exception {
  const ProfileSyncPendingException(this.profile, this.cause);

  final UserProfile profile;
  final Object cause;

  @override
  String toString() => 'Profile saved locally; server sync is pending: $cause';
}
