import 'dart:developer' as developer;

import 'package:fixnum/fixnum.dart' as fixnum;
import 'package:grpc/grpc.dart' as grpc;

import '../../../core/network/grpc_client.dart';
import '../../../core/protocol/protocol_models.dart';
import '../../../core/storage/local_store.dart';
import '../../../core/storage/message_records.dart';
import '../../../core/validation/username_feedback.dart';
import '../../../generated/proto/tureon.pb.dart' as pb;
import 'profile_repository.dart';
import 'profile_sync_manager.dart';
import 'profile_sync_repository.dart';

typedef GroupChannelSnapshot = ({
  List<pb.GroupChannel> groups,
  List<pb.GroupChannel> channels,
});

class ProfileRuntimeCoordinator {
  ProfileRuntimeCoordinator({
    required this.store,
    required this.repository,
    required this._client,
    required this._sessionGeneration,
    this._profileLoader,
    this._groupChannelsLoader,
  }) : _syncManager = ProfileSyncManager(
         store: store,
         profileRepository: repository,
       ) {
    repository.recoverProfile = _recoverProfileFromServer;
  }

  final LocalStore store;
  final ProfileRepository repository;
  final GrpcClient? Function() _client;
  final int Function() _sessionGeneration;
  final Future<UserProfile> Function(String userId)? _profileLoader;
  final Future<GroupChannelSnapshot> Function(String userId)?
  _groupChannelsLoader;
  final ProfileSyncManager _syncManager;
  ProfileSyncRepository? _syncRepository;
  Future<void>? _groupBootstrap;
  bool _groupBootstrapRequested = false;
  bool _recipientProfilesEnabled = true;

  void connect(
    GrpcClient client, {
    required void Function() onStreamFailure,
    required Future<void> Function(String accountStatus) onAccountStatusChange,
  }) {
    _syncRepository = ProfileSyncRepository(
      rpc: GrpcProfileUpdatesRpc(client.profiles),
      store: store,
      onProfileChange: handleProfileChange,
      onRecipientProfileChange: handleRecipientProfileChange,
      onAccountStatusChange: onAccountStatusChange,
      onVerificationBadgeChange: handleOwnVerificationBadgeChange,
      recipientProfilesEnabled: _recipientProfilesEnabled,
      onStreamFailure: onStreamFailure,
    );
  }

  void reset() => _syncManager.reset();

  Future<void> startSync({required bool active}) =>
      _syncRepository?.startSync(active: active) ?? Future<void>.value();

  Future<void> setActive(bool active) =>
      _syncRepository?.setActive(active) ?? Future<void>.value();

  Future<void> stopSync() =>
      _syncRepository?.stopSync() ?? Future<void>.value();

  Future<void> reconnect() =>
      _syncRepository?.reconnect() ?? Future<void>.value();

  Future<void> setRecipientProfileWatchEnabled(bool enabled) async {
    _recipientProfilesEnabled = enabled;
    await _syncRepository?.setRecipientProfilesEnabled(enabled);
  }

  Future<void> disconnect() async {
    await _syncRepository?.stopSync();
    _syncRepository = null;
    _syncManager.reset();
  }

  Future<UserProfile> loadProfile({String? recipientId}) async {
    final session = store.loadSession();
    final targetId = recipientId ?? session?.userId;
    if (session != null && targetId == session.userId) {
      final localProfile = repository.loadUser(session.userId);
      if (localProfile != null && !repository.needsBootstrap(session.userId)) {
        return localProfile;
      }
      try {
        return await refreshOwnProfileFromServer(session.userId);
      } catch (_) {
        if (localProfile != null) return localProfile;
        rethrow;
      }
    }
    final profile = await _loadProfileFromServer(targetId ?? '');
    if (session != null && targetId != session.userId) {
      await _cacheRecipientProfile(profile, session.userId);
    }
    return profile;
  }

  Future<UserProfile> _loadProfileFromServer(String recipientId) async {
    final profileLoader = _profileLoader;
    if (profileLoader != null) {
      final profile = await profileLoader(recipientId);
      if (profile.userId != recipientId || profile.userId.isEmpty) {
        throw StateError('The server returned an invalid user profile.');
      }
      return profile;
    }
    final client = _client();
    if (client == null || !client.hasAccessToken) {
      throw StateError('A connected signed-in device is required.');
    }
    final response = await client.profiles.getProfile(
      pb.GetProfileRequest(recipientId: recipientId),
      options: grpc.CallOptions(timeout: const Duration(seconds: 10)),
    );
    final profile = _profileFromResponse(response);
    if (profile.userId != recipientId || profile.userId.isEmpty) {
      throw StateError('The server returned an invalid user profile.');
    }
    return profile;
  }

  Future<void> bootstrapGroupsAndChannels() {
    _groupBootstrapRequested = true;
    final running = _groupBootstrap;
    if (running != null) return running;
    late final Future<void> bootstrap;
    bootstrap = _drainGroupBootstraps().whenComplete(() {
      if (identical(_groupBootstrap, bootstrap)) _groupBootstrap = null;
    });
    _groupBootstrap = bootstrap;
    return bootstrap;
  }

  Future<void> _drainGroupBootstraps() async {
    while (_groupBootstrapRequested) {
      _groupBootstrapRequested = false;
      await _loadAndCacheGroupsAndChannels();
    }
  }

  Future<void> _loadAndCacheGroupsAndChannels() async {
    final userId = store.loadSession()?.userId;
    if (userId == null) return;
    final generation = _sessionGeneration();
    final client = _client();
    final loader = _groupChannelsLoader;
    late final List<pb.GroupChannel> groups;
    late final List<pb.GroupChannel> channels;
    if (loader != null) {
      final snapshot = await loader(userId);
      groups = snapshot.groups;
      channels = snapshot.channels;
    } else {
      if (client == null || !client.hasAccessToken) return;
      // Independent snapshots share a bounded deadline and start together.
      // Apply neither snapshot unless both succeed, preserving the local cache
      // when one service is unavailable.
      final snapshots = await Future.wait([
        client.groups
            .listMyGroups(
              pb.Empty(),
              options: grpc.CallOptions(timeout: const Duration(seconds: 10)),
            )
            .then((response) => response.groups),
        client.channels
            .listMyChannels(
              pb.Empty(),
              options: grpc.CallOptions(timeout: const Duration(seconds: 10)),
            )
            .then((response) => response.channels),
      ]);
      groups = snapshots[0];
      channels = snapshots[1];
    }
    // A slow snapshot from a previous login must never delete or overwrite the
    // groups and channels cached for the newly active account.
    if (_sessionGeneration() != generation ||
        store.loadSession()?.userId != userId) {
      return;
    }
    final groupChannelIds = {
      ...groups.map((item) => item.id),
      ...channels.map((item) => item.id),
    };
    for (final recipient in store.loadRecipients()) {
      final isGroupChannel =
          recipient.type == RecipientType.group ||
          recipient.type == RecipientType.channel;
      if (isGroupChannel && !groupChannelIds.contains(recipient.id)) {
        store.deleteRecipient(recipient.id);
      }
    }
    await _cacheGroupChannels(groups, recipientType: RecipientType.group);
    await _cacheGroupChannels(channels, recipientType: RecipientType.channel);
  }

  Future<void> _cacheGroupChannels(
    Iterable<pb.GroupChannel> groupChannels, {
    required RecipientType recipientType,
  }) async {
    for (final groupChannel in groupChannels) {
      final cached = store.loadRecipient(groupChannel.id);
      final role = groupChannel.memberRole.isEmpty
          ? groupChannel.ownerUserId == store.loadSession()?.userId
                ? 'owner'
                : 'member'
          : groupChannel.memberRole;
      final recipient = Recipient(
        id: groupChannel.id,
        type: recipientType,
        name: groupChannel.name.isEmpty
            ? (recipientType == RecipientType.group ? 'Grupo' : 'Canal')
            : groupChannel.name,
        handle: groupChannel.name.isEmpty ? '' : '@${groupChannel.name}',
        avatarUrl: groupChannel.avatarUrl.isEmpty
            ? cached?.avatarUrl
            : groupChannel.avatarUrl,
        lastMessage: cached?.lastMessage,
        unreadCount: cached?.unreadCount ?? 0,
        isOnline: cached?.isOnline ?? false,
        isUsernameVisible: cached?.isUsernameVisible ?? false,
        isPresenceVisible: cached?.isPresenceVisible ?? false,
        composerRole: role,
        canSendMessages:
            role == 'owner' ||
            role == 'admin' ||
            groupChannel.membersCanSendMessages,
        membersCanSendMessages: groupChannel.membersCanSendMessages,
        slowModeSeconds: groupChannel.slowModeSeconds,
        verificationBadge: cached?.verificationBadge ?? VerificationBadge.none,
      );
      await store.saveRecipient(recipient);
    }
  }

  Future<UserProfile> refreshOwnProfileFromServer(
    String userId, [
    int? expectedGeneration,
  ]) {
    final generation = expectedGeneration ?? _sessionGeneration();
    return _syncManager.refreshProfile(
      userId: userId,
      fetchServerProfile: (recipientId) async {
        final profile = await _loadProfileFromServer(recipientId);
        if (generation != _sessionGeneration() ||
            store.loadSession()?.userId != recipientId) {
          throw StateError(
            'The active account changed during profile refresh.',
          );
        }
        return profile;
      },
    );
  }

  Future<UserProfile?> _recoverProfileFromServer(String userId) async {
    if (store.loadSession()?.userId != userId) return null;
    try {
      return await refreshOwnProfileFromServer(userId);
    } catch (error, stackTrace) {
      developer.log(
        'Could not repair local profile',
        name: 'tureon.profile',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> handleProfileChange(int version) async {
    final session = store.loadSession();
    if (session == null) return;
    final current = repository.loadUser(session.userId);
    if (current != null && version <= current.profileVersion) {
      if (repository.pendingSyncRevision(session.userId) != null) {
        await syncPendingChanges();
      }
      return;
    }
    final updated = await refreshOwnProfileFromServer(session.userId);
    if (updated.profileVersion < version) {
      throw StateError(
        'Profile snapshot version ${updated.profileVersion} is older than event $version.',
      );
    }
  }

  Future<void> handleOwnVerificationBadgeChange(String badge) async {
    final session = store.loadSession();
    if (session == null) return;
    final current = repository.loadUser(session.userId);
    if (current?.verificationBadge.name == badge) return;
    final updated = await refreshOwnProfileFromServer(session.userId);
    if (updated.verificationBadge.name != badge) {
      throw StateError(
        'The profile snapshot does not contain the announced badge.',
      );
    }
  }

  Future<void> handleRecipientProfileChange(
    String recipientId,
    int expectedVersion,
  ) async {
    final session = store.loadSession();
    if (session == null || session.userId == recipientId) return;
    final generation = _sessionGeneration();
    final profile = await _loadProfileFromServer(recipientId);
    if (generation != _sessionGeneration() ||
        store.loadSession()?.userId != session.userId) {
      return;
    }
    if (profile.profileVersion < expectedVersion) {
      throw StateError(
        'Recipient profile version ${profile.profileVersion} is older than event $expectedVersion.',
      );
    }
    await _cacheRecipientProfile(profile, session.userId);
  }

  Future<void> _cacheRecipientProfile(
    UserProfile profile,
    String accountUserId,
  ) async {
    if (store.loadSession()?.userId != accountUserId) return;
    final cached = store.loadRecipient(profile.userId);
    if (cached != null && cached.type != RecipientType.user) return;
    final username = profile.username.trim();
    final displayName = profile.displayName.trim();
    final recipient = Recipient(
      id: profile.userId,
      type: RecipientType.user,
      name: displayName.isNotEmpty
          ? displayName
          : username.isNotEmpty
          ? username
          : cached?.name ?? 'Usuário',
      handle: username.isEmpty ? '' : '@$username',
      avatarUrl: profile.avatarUrl,
      description: profile.bio ?? '',
      lastMessage: cached?.lastMessage,
      unreadCount: cached?.unreadCount ?? 0,
      isOnline: cached?.isOnline ?? false,
      isUsernameVisible: username.isNotEmpty,
      isPresenceVisible: cached?.isPresenceVisible ?? false,
      verificationBadge: profile.verificationBadge,
      profileVersion: profile.profileVersion,
      countryCode: profile.countryCode,
      createdAt: profile.createdAt,
    );
    await store.saveRecipient(recipient);
  }

  Future<void> reconcileOnResume(String userId) async {
    try {
      await refreshOwnProfileFromServer(userId);
      await syncPendingChanges();
      await setActive(true);
    } catch (error, stackTrace) {
      developer.log(
        'Could not reconcile profile after app resume',
        name: 'tureon.profile',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<UserProfile> updateProfile(UserProfile profile) async {
    final session = store.loadSession();
    if (session == null) {
      throw StateError('A connected signed-in device is required.');
    }
    _ensureAccountCanWrite(session);
    if (profile.userId != session.userId) {
      throw ArgumentError('Only the authenticated user profile can be edited.');
    }
    final previousProfile = repository.loadUser(session.userId);
    if (previousProfile == null) {
      throw StateError('The local profile has not been initialized.');
    }
    final previousRevision = repository.pendingSyncRevision(session.userId);
    repository.saveLocal(profile, markForSync: true);
    final submittedRevision = repository.pendingSyncRevision(session.userId);
    try {
      await syncPendingChanges();
      if (repository.pendingSyncRevision(session.userId) != null) {
        throw StateError('No authenticated server connection is available.');
      }
      return repository.loadUser(session.userId) ?? profile;
    } catch (error) {
      if (profile.username != previousProfile.username &&
          UsernameFeedback.errorMessage(error) != null &&
          submittedRevision != null) {
        repository.saveLocal(previousProfile);
        repository.restoreSyncRevision(
          session.userId,
          submittedRevision,
          previousRevision,
        );
        rethrow;
      }
      throw ProfileSyncPendingException(profile, error);
    }
  }

  Future<UserProfile> updatePrivacySetting({
    required String field,
    required String visibility,
  }) async {
    final session = store.loadSession();
    if (session == null) {
      throw StateError('A connected signed-in device is required.');
    }
    _ensureAccountCanWrite(session);
    if (!const {
      'phone',
      'last_seen',
      'profile_photo',
      'bio',
      'birthday',
      'country',
      'username',
      'read_receipts',
    }.contains(field)) {
      throw ArgumentError.value(field, 'field', 'Unsupported privacy field.');
    }
    if (!const {'everyone', 'contacts', 'nobody'}.contains(visibility)) {
      throw ArgumentError.value(
        visibility,
        'visibility',
        'Unsupported privacy visibility.',
      );
    }
    if (field == 'read_receipts' && visibility == 'contacts') {
      throw ArgumentError.value(
        visibility,
        'visibility',
        'Read receipt privacy must be everyone or nobody.',
      );
    }
    final current = repository.loadUser(session.userId);
    if (current == null) {
      throw StateError('The local profile has not been initialized.');
    }
    final updated = current.copyWith(
      privacySettings: {...current.privacySettings, field: visibility},
    );
    repository.saveLocal(updated, markForSync: true);
    try {
      await syncPendingChanges();
      if (repository.pendingSyncRevision(session.userId) != null) {
        throw StateError('No authenticated server connection is available.');
      }
      return repository.loadUser(session.userId) ?? updated;
    } catch (error) {
      throw ProfileSyncPendingException(updated, error);
    }
  }

  void _ensureAccountCanWrite(UserSession session) {
    if (session.accountStatus != 'active' &&
        session.accountStatus != 'under_review') {
      throw StateError('Account is restricted from write operations.');
    }
  }

  Future<void> syncPendingChanges() async {
    final client = _client();
    final session = store.loadSession();
    if (client == null || session == null || !client.hasAccessToken) return;
    var conflictRetries = 0;
    while (true) {
      final revision = repository.pendingSyncRevision(session.userId);
      if (revision == null) return;
      final profile = repository.loadUser(session.userId);
      if (profile == null) {
        throw StateError('Pending profile sync has no local profile.');
      }
      pb.ProfileResponse response;
      try {
        response = await client.profiles.updateProfile(
          pb.UpdateProfileRequest(
            username: profile.username,
            displayName: profile.displayName,
            bio: profile.bio ?? '',
            phoneE164: profile.phoneE164,
            birthday: profile.birthday,
            avatarUrl: profile.avatarUrl ?? '',
            countryCode: profile.countryCode,
            expectedProfileVersion: fixnum.Int64(profile.profileVersion),
          ),
        );
      } on grpc.GrpcError catch (error) {
        if (error.code != grpc.StatusCode.aborted || conflictRetries >= 3) {
          rethrow;
        }
        conflictRetries++;
        await refreshOwnProfileFromServer(session.userId);
        continue;
      }
      var serverProfile = _profileFromResponse(response);
      for (final field in const [
        'phone',
        'last_seen',
        'profile_photo',
        'bio',
        'birthday',
        'country',
        'username',
        'read_receipts',
      ]) {
        final visibility = profile.privacySettings[field];
        if (visibility == null ||
            serverProfile.privacySettings[field] == visibility) {
          continue;
        }
        final privacyResponse = await client.profiles.updatePrivacySetting(
          pb.UpdatePrivacySettingRequest(
            field_1: field,
            visibility: visibility,
          ),
        );
        serverProfile = _profileFromResponse(privacyResponse);
      }
      repository.completeSync(session.userId, revision, serverProfile);
      conflictRetries = 0;
    }
  }

  UserProfile _profileFromResponse(pb.ProfileResponse response) => UserProfile(
    userId: response.recipientId,
    username: response.username,
    displayName: response.displayName,
    bio: response.bio.isEmpty ? null : response.bio,
    phoneE164: response.phoneE164,
    birthday: response.birthday,
    countryCode: response.countryCode,
    createdAt: response.createdAt.toInt() == 0
        ? null
        : DateTime.fromMillisecondsSinceEpoch(
            response.createdAt.toInt() * 1000,
            isUtc: true,
          ),
    avatarUrl: response.avatarUrl.isEmpty ? null : response.avatarUrl,
    profileVersion: response.profileVersion.toInt(),
    verificationBadge: verificationBadgeFromServer(response.verificationBadge),
    privacySettings: {
      for (final setting in response.privacySettings)
        setting.field_1: setting.visibility,
    },
  );
}
