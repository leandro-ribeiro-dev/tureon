import 'dart:async';
import 'dart:developer' as developer;
import 'package:tureon/core/protocol/recipient.dart';
import 'package:tureon/core/protocol/recipient_type.dart';
import 'room_system_snapshot.dart';
import 'package:tureon/core/protocol/verification_badge.dart';
import 'package:tureon/core/storage/chat_store.dart';
import 'package:tureon/core/storage/message_records.dart';
import 'system_message_delivery_mapper.dart';

/// Resolves recipients and applies versioned room snapshots to local history.
class ChatConversationResolver {
  ChatConversationResolver({
    required this.store,
    required this.isCurrentSession,
    this.resolveRecipient,
    this.resolveRoomRecipient,
  });
  final ChatStore store;
  final bool Function(UserSession) isCurrentSession;
  final Future<Recipient> Function(String)? resolveRecipient;
  final Future<Recipient?> Function(String, RecipientType, bool)?
  resolveRoomRecipient;

  Future<Recipient> resolve(
    String recipientId, {
    RecipientType? roomType,
    UserSession? session,
    bool refreshRoomMetadata = false,
  }) async {
    final cached = store.loadRecipient(recipientId);
    if (roomType != null) {
      if (cached != null &&
          cached.type == roomType &&
          !_isIncompleteRoomRecipient(cached)) {
        if (refreshRoomMetadata) {
          _scheduleRoomRecipientResolution(
            recipientId,
            roomType,
            session,
            forceRefresh: true,
          );
        }
        return cached;
      }
      _scheduleRoomRecipientResolution(
        recipientId,
        roomType,
        session,
        forceRefresh: refreshRoomMetadata,
      );
      return cached != null && cached.type == roomType
          ? cached
          : _fallbackRoomRecipient(recipientId, roomType, cached);
    }
    if (cached != null && cached.name != 'Usuário') return cached;
    final resolver = resolveRecipient;
    if (resolver != null) return resolver(recipientId);
    return cached ??
        Recipient(
          id: recipientId,
          type: RecipientType.user,
          name: 'Usuário',
          handle: '',
        );
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

  static const _snapshots = RoomSystemSnapshot();
  final Map<(String?, String?, String), Object> _roomResolutions = {};

  Recipient applySnapshot(
    Recipient recipient,
    RoomSystemMessageDelivery delivery,
    String currentUserId,
  ) => _snapshots.applySnapshot(recipient, delivery, currentUserId);

  bool isCurrentUserRemoved(
    RoomSystemMessageDelivery delivery,
    String currentUserId,
  ) => _snapshots.isCurrentUserRemoved(delivery, currentUserId);

  void invalidateRoom(String id) =>
      _roomResolutions.removeWhere((key, _) => key.$3 == id);

  void _scheduleRoomRecipientResolution(
    String recipientId,
    RecipientType roomType,
    UserSession? session, {
    bool forceRefresh = false,
  }) {
    final resolver = resolveRoomRecipient;
    final activeSession = session ?? store.loadSession();
    final key = (activeSession?.userId, activeSession?.deviceId, recipientId);
    if (resolver == null || _roomResolutions.containsKey(key)) return;
    // Hydration is optional; durable delivery never waits for these RPCs.
    // Bound enrichment under a burst of distinct rooms. Later deliveries and
    // opening a conversation can retry rooms outside this window.
    if (_roomResolutions.length >= 64) return;
    final ticket = Object();
    _roomResolutions[key] = ticket;
    final before = store.loadRecipient(recipientId);
    final initialVersion = before?.roomVersion ?? 0;
    unawaited(() async {
      try {
        final resolved = await resolver(recipientId, roomType, forceRefresh);
        if (resolved == null) {
          developer.log(
            'Room metadata is not in the membership list; keeping incoming system messages under the delivery chat id',
            name: 'tureon.messaging',
          );
          return;
        }
        if (resolved.id != recipientId ||
            resolved.type != roomType ||
            (activeSession != null && !isCurrentSession(activeSession)) ||
            !identical(_roomResolutions[key], ticket)) {
          return;
        }
        // Metadata can finish loading after the message batch is persisted.
        // Merge live conversation state so enrichment never resets its preview
        // or unread counter.
        final latest = store.loadRecipient(recipientId);
        if ((before != null && latest == null) ||
            (latest?.roomVersion ?? 0) > initialVersion) {
          return;
        }
        await store.saveRecipient(
          resolved.copyWith(
            lastMessage: latest?.lastMessage,
            unreadCount: latest?.unreadCount ?? 0,
            isOnline: latest?.isOnline ?? false,
            isTyping: latest?.isTyping ?? false,
            roomVersion: latest?.roomVersion ?? resolved.roomVersion,
          ),
        );
      } catch (error, stackTrace) {
        developer.log(
          'Could not resolve room metadata after saving an incoming system message',
          name: 'tureon.messaging',
          error: error,
          stackTrace: stackTrace,
        );
      } finally {
        if (identical(_roomResolutions[key], ticket)) {
          _roomResolutions.remove(key);
        }
      }
    }());
  }

  Recipient _fallbackRoomRecipient(
    String recipientId,
    RecipientType roomType,
    Recipient? cached,
  ) {
    final cachedRoom = cached?.type == roomType ? cached : null;
    final isGroup = roomType == RecipientType.group;
    return Recipient(
      id: recipientId,
      type: roomType,
      name: cachedRoom?.name ?? (isGroup ? 'Grupo' : 'Canal'),
      handle: cachedRoom?.handle ?? '',
      avatarUrl: cachedRoom?.avatarUrl,
      description: cachedRoom?.description ?? '',
      isOnline: cachedRoom?.isOnline ?? false,
      isUsernameVisible: cachedRoom?.isUsernameVisible ?? false,
      isPresenceVisible: cachedRoom?.isPresenceVisible ?? false,
      presenceUpdate: cachedRoom?.presenceUpdate ?? false,
      lastMessage: cached?.lastMessage,
      unreadCount: cached?.unreadCount ?? 0,
      isTyping: cachedRoom?.isTyping ?? false,
      composerRole: cachedRoom?.composerRole ?? 'member',
      canSendMessages: cachedRoom?.canSendMessages ?? false,
      membersCanSendMessages: cachedRoom?.membersCanSendMessages ?? false,
      membersCanSendMedia: cachedRoom?.membersCanSendMedia ?? false,
      membersCanSendStickersGifs:
          cachedRoom?.membersCanSendStickersGifs ?? false,
      membersCanEmbedLinks: cachedRoom?.membersCanEmbedLinks ?? false,
      membersCanAddMembers: cachedRoom?.membersCanAddMembers ?? false,
      membersCanChangeInfo: cachedRoom?.membersCanChangeInfo ?? false,
      membersCanReact: cachedRoom?.membersCanReact ?? false,
      membersCanForward: cachedRoom?.membersCanForward ?? false,
      slowModeSeconds: cachedRoom?.slowModeSeconds ?? 0,
      memberCount: cachedRoom?.memberCount ?? 0,
      isOfficial: cachedRoom?.isOfficial ?? false,
      visibility: cachedRoom?.visibility ?? 'private',
      isMember: cachedRoom?.isMember ?? false,
      profileVersion: cachedRoom?.profileVersion ?? 0,
      roomVersion: cachedRoom?.roomVersion ?? 0,
      verificationBadge:
          cachedRoom?.verificationBadge ?? VerificationBadge.none,
    );
  }
}
