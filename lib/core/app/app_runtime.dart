import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:grpc/grpc.dart' as grpc;

import '../../features/auth/data/google_auth_data_source.dart';
import '../../features/auth/data/auth_runtime_coordinator.dart';
import '../../features/auth/presentation/auth_controller.dart';
import '../../features/auth/domain/auth_gateway.dart';
import '../../features/chats/data/chat_runtime_coordinator.dart';
import '../../features/chats/domain/chat_feature_services.dart';
import '../../features/chats/domain/chat_repository.dart';
import '../../features/chats/domain/secret_chat_device.dart';
import '../../features/groups/data/group_channel_service.dart';
import '../../features/groups/data/membership_sync_repository.dart';
import '../../features/presence/data/presence_runtime_coordinator.dart';
import '../../features/profile/data/profile_repository.dart';
import '../../features/profile/data/profile_runtime_coordinator.dart';
import '../../generated/proto/tureon.pb.dart' as pb;
import '../network/grpc_client.dart';
import '../network/grpc_transport_config.dart';
import '../network/network_connection_manager.dart';
import '../network/realtime_stream_manager.dart';
import '../protocol/recipient.dart';
import '../protocol/recipient_type.dart';
import '../protocol/official_bots.dart';
import '../protocol/verification_badge.dart';
import '../storage/local_store.dart';
import '../storage/message_records.dart';
import 'app_lifecycle_coordinator.dart';
import 'connection_status.dart';

typedef GroupChannelSnapshot = ({
  List<pb.GroupChannel> groups,
  List<pb.GroupChannel> channels,
});

class AppRuntime implements ChatFeatureServices {
  AppRuntime._({
    required this.store,
    Future<UserProfile> Function(String)? profileLoader,
    Future<GroupChannelSnapshot> Function(String userId)? groupChannelsLoader,
    bool observeLifecycle = false,
  }) : profileRepository = ProfileRepository(store) {
    _lifecycleCoordinator = AppLifecycleCoordinator(
      onStateChanged: _handleLifecycleState,
    );
    _authRuntime = AuthRuntimeCoordinator(
      store: store,
      persistSession: _persistAuthSession,
      onSessionRefreshed: (session) async {
        try {
          await _refreshOwnProfileFromServer(session.userId);
        } catch (error, stackTrace) {
          developer.log(
            'Profile refresh after access-token rotation failed',
            name: 'tureon.auth',
            error: error,
            stackTrace: stackTrace,
          );
        }
      },
      onAuthStateChanged: _handleAuthStateChanged,
      onControllerChanged: (controller) {
        if (!_authControllerUpdates.isClosed) {
          _authControllerUpdates.add(controller);
        }
      },
      onAuthenticationRecoveryChanged: (isAuthenticating) {
        _publishConnectionStatus(
          force: isAuthenticating ? ConnectionStatus.authenticating : null,
        );
      },
    );
    _profileRuntime = ProfileRuntimeCoordinator(
      store: store,
      repository: profileRepository,
      client: () => _client,
      sessionGeneration: () => _sessionGeneration,
      profileLoader: profileLoader,
      groupChannelsLoader: groupChannelsLoader,
    );
    _chatRuntime = ChatRuntimeCoordinator(
      store: store,
      resolveRecipient: _resolveIncomingRecipient,
      resolveRoomRecipient: _resolveIncomingRoomRecipient,
      onStreamFailure: _realtimeStreamManager.requestReconnect,
    );
    _groupChannelService = GroupChannelService(
      store: store,
      client: () => _client,
    );
    _presenceRuntime = PresenceRuntimeCoordinator(
      store: store,
      onPresenceUpdate: _presenceUpdates.add,
      onStreamFailure: _realtimeStreamManager.requestReconnect,
    );
    if (observeLifecycle) _lifecycleCoordinator.start();
  }

  @visibleForTesting
  factory AppRuntime.forTesting({
    required LocalStore store,
    required Future<UserProfile> Function(String userId) loadProfile,
    Future<GroupChannelSnapshot> Function(String userId)? loadGroupChannels,
  }) => AppRuntime._(
    store: store,
    profileLoader: loadProfile,
    groupChannelsLoader: loadGroupChannels,
  );

  final LocalStore store;
  final ProfileRepository profileRepository;

  late final NetworkConnectionManager _connectionManager =
      NetworkConnectionManager();
  late final RealtimeStreamManager _realtimeStreamManager =
      RealtimeStreamManager(reconnectAll: _reconnectRealtimeStreams);
  late final AuthRuntimeCoordinator _authRuntime;
  late final ProfileRuntimeCoordinator _profileRuntime;
  late final AppLifecycleCoordinator _lifecycleCoordinator;
  late final ChatRuntimeCoordinator _chatRuntime;
  late final GroupChannelService _groupChannelService;
  late final PresenceRuntimeCoordinator _presenceRuntime;
  MembershipSyncRepository? _membershipSyncRepository;
  bool get _isForeground => _lifecycleCoordinator.isForeground;

  GrpcClient? _client;
  StreamSubscription<grpc.ConnectionState>? _connectionStateSubscription;
  StreamSubscription<bool>? _chatReadinessSubscription;
  Future<void>? _sessionBootstrapInFlight;
  bool _grpcConnectionWasRecovering = false;
  final StreamController<Recipient> _presenceUpdates =
      StreamController<Recipient>.broadcast();
  final StreamController<AuthController?> _authControllerUpdates =
      StreamController<AuthController?>.broadcast(sync: true);

  int _sessionGeneration = 0;

  @override
  ChatRepository? get chatRepository => _chatRuntime.chatRepository;
  ConnectionStatus get connectionStatus => _connectionManager.status;
  Stream<ConnectionStatus> get connectionStatusUpdates =>
      _connectionManager.updates;
  @override
  bool get isChatStreamReady =>
      _chatRuntime.chatRepository?.isStreamReady ?? false;
  @override
  Stream<bool> get chatStreamReadinessChanges =>
      _chatRuntime.chatRepository?.streamReadinessChanges ??
      const Stream<bool>.empty();
  Stream<Recipient> get presenceUpdates => _presenceUpdates.stream;
  AuthController? get authController => _authRuntime.controller;
  Stream<AuthController?> get authControllerUpdates =>
      _authControllerUpdates.stream;

  UserSession? get currentSession => store.loadSession();
  Stream<UserSession?> watchSession() => store.watchSession();
  UserProfile? get currentUser => profileRepository.currentUser;
  bool get hasActiveSession => currentSession != null;
  bool get canWriteAccount => currentSession?.accountStatus == 'active';
  bool get canEditProfile =>
      currentSession?.accountStatus == 'active' || isUnderReview;
  bool get isUnderReview => currentSession?.accountStatus == 'under_review';
  @override
  ChatIdentity? get chatIdentity {
    final session = currentSession;
    if (session == null) return null;
    return (userId: session.userId, deviceId: session.deviceId);
  }

  @override
  ChatSendRestriction get chatSendRestriction =>
      switch (currentSession?.accountStatus) {
        'banned' || 'suspended' => ChatSendRestriction.blocked,
        'under_review' => ChatSendRestriction.underReview,
        _ => ChatSendRestriction.none,
      };

  String? get currentUserId => currentSession?.userId;
  String? get currentDeviceId => currentSession?.deviceId;

  String get accountStatus => currentSession?.accountStatus ?? 'active';

  @override
  String? loadSetting(String key) => store.loadSetting(key);

  void clearLocalHistory() => store.clearLocalHistory();

  void saveSetting(String key, String value) => store.saveSetting(key, value);

  static Future<AppRuntime> open() async {
    final runtime = AppRuntime._(
      store: await LocalStore.open(),
      observeLifecycle: true,
    );
    return runtime;
  }

  Future<void> _handleLifecycleState(bool foreground) async {
    final updates = <Future<void>>[
      _presenceRuntime.setForeground(foreground),
      _profileRuntime.setActive(foreground),
      _membershipSyncRepository?.setActive(foreground) ?? Future<void>.value(),
    ];
    if (foreground) {
      if (_connectionManager.transportStatus == ConnectionStatus.connected) {
        updates.add(_retrySessionRestoreWhenReachable());
      }
      final session = store.loadSession();
      final userId = session?.userId;
      if (session != null &&
          !_accountBlocksRealtime(session) &&
          userId != null &&
          _hasAuthenticatedClient(userId)) {
        updates.add(_reconcileProfileOnResume(userId));
        updates.add(_reconcileGroupMembershipOnResume());
        updates.add(_resumeChatSynchronization());
      }
    }
    await Future.wait(updates);
  }

  Future<void> connect({
    required String host,
    int port = 50051,
    String? accessToken,
    bool secure = false,
    bool startNetwork = true,
  }) async {
    await disconnect();
    final client = GrpcClient(
      host: host,
      port: port,
      accessToken: accessToken ?? store.loadSession()?.accessToken,
      secure: secure,
    );
    _client = client;
    _authRuntime.connect(client);
    _connectionStateSubscription = client.connectionStateChanges.listen(
      _handleGrpcConnectionState,
      onError: (Object error, StackTrace stackTrace) {
        developer.log(
          'gRPC channel state monitoring failed',
          name: 'tureon.connection',
          error: error,
          stackTrace: stackTrace,
        );
        _connectionManager.resetTransport();
        _publishConnectionStatus();
      },
    );
    _presenceRuntime.connect(client);
    _profileRuntime.connect(
      client,
      onStreamFailure: _realtimeStreamManager.requestReconnect,
      onAccountStatusChange: (_) => _authRuntime.refreshCurrentSession(),
    );
    _membershipSyncRepository = MembershipSyncRepository(
      rpc: GrpcMembershipChangesRpc(client.memberships),
      store: store,
      refreshSnapshot: _bootstrapMyGroupsAndChannels,
      refreshChatRoomSubscriptions: () async {
        await _chatRuntime.reconnect();
        await _presenceRuntime.reconnect();
      },
      onStreamFailure: _realtimeStreamManager.requestReconnect,
    );

    _chatRuntime.connect(
      client,
      host: host,
      secure: secure,
      mediaPort: mediaServerPort,
    );
    _chatReadinessSubscription?.cancel();
    _chatReadinessSubscription = _chatRuntime
        .chatRepository
        ?.streamReadinessChanges
        .listen((_) => _publishConnectionStatus());

    if (client.hasAccessToken) {
      final session = store.loadSession();
      if (session != null) {
        _publishConnectionStatus();
      }
      _publishConnectionStatus();
    }

    if (startNetwork) startNetworkServices();
  }

  /// Starts transport and session validation after the local UI is visible.
  void startNetworkServices() {
    final client = _client;
    if (client == null) return;
    _realtimeStreamManager.start();
    unawaited(_probeServer(client));
  }

  Future<void> _probeServer(GrpcClient client) async {
    try {
      await client.checkServerHealth();
    } catch (error, stackTrace) {
      if (!identical(_client, client)) return;
      developer.log(
        'Initial gRPC server health check failed',
        name: 'tureon.connection',
        error: error,
        stackTrace: stackTrace,
      );
      _realtimeStreamManager.requestReconnect();
    }
  }

  Future<void> saveSession(UserSession session) async {
    _sessionGeneration++;
    _sessionBootstrapInFlight = null;
    _profileRuntime.reset();
    final generation = _sessionGeneration;
    final previous = store.loadSession();
    if (previous != null &&
        (previous.userId != session.userId ||
            previous.deviceId != session.deviceId)) {
      await _chatRuntime.stopSync();
      await _presenceRuntime.stopSync(sendOffline: true);
      await _membershipSyncRepository?.stopSync();
      await _profileRuntime.stopSync();
      _chatRuntime.resetSecretCrypto();
    }
    if (generation != _sessionGeneration) return;
    try {
      store.saveSession(session);
      _client?.setAccessToken(session.accessToken);
      if (session.needsUsername) return;
      if (_accountBlocksRealtime(session)) {
        await _profileRuntime.setRecipientProfileWatchEnabled(false);
        await _profileRuntime.startSync(active: _isForeground);
        _publishConnectionStatus();
        return;
      }
      await _refreshOwnProfileFromServer(session.userId, generation);
      await _bootstrapMyGroupsAndChannels();
    } catch (error, stackTrace) {
      developer.log(
        'Could not complete profile bootstrap for the new session',
        name: 'tureon.auth',
        error: error,
        stackTrace: stackTrace,
      );
      if (generation == _sessionGeneration) {
        await _rollbackIncompleteSession();
      }
      rethrow;
    }
    await _resumePreviouslyUsedSecretChat(session);
    await _chatRuntime.startSync();
    await _presenceRuntime.startSync(foreground: _isForeground);
    await _profileRuntime.startSync(active: _isForeground);
    await _membershipSyncRepository?.startSync(active: _isForeground);
    try {
      await _syncPendingProfileChanges();
    } catch (error) {
      debugPrint('Local profile remains pending server sync: $error');
    }
    _publishConnectionStatus();
  }

  Future<void> _persistAuthenticatedSession(UserSession session) async {
    _sessionGeneration++;
    _sessionBootstrapInFlight = null;
    _profileRuntime.reset();
    final generation = _sessionGeneration;
    final previous = store.loadSession();
    final accountStatusChanged =
        previous != null && previous.accountStatus != session.accountStatus;
    if (previous != null &&
        (previous.userId != session.userId ||
            previous.deviceId != session.deviceId ||
            accountStatusChanged)) {
      await _chatRuntime.stopSync();
      await _presenceRuntime.stopSync();
      await _membershipSyncRepository?.stopSync();
      await _profileRuntime.stopSync();
      _chatRuntime.resetSecretCrypto();
    }
    // A newer login or refresh may have started while old streams were being
    // stopped. Never let this stale activation overwrite its session.
    if (generation != _sessionGeneration) return;
    store.saveSession(session);
    _client?.setAccessToken(session.accessToken);
    _publishConnectionStatus();
    if (!session.needsUsername) {
      unawaited(_finishSessionActivation(session, generation));
    }
  }

  Future<void> _finishSessionActivation(
    UserSession session,
    int generation,
  ) async {
    if (generation != _sessionGeneration) return;
    try {
      if (_accountBlocksRealtime(session)) {
        await _chatRuntime.stopSync();
        await _presenceRuntime.stopSync(sendOffline: true);
        await _membershipSyncRepository?.stopSync();
        await _profileRuntime.setRecipientProfileWatchEnabled(false);
        await _profileRuntime.startSync(active: _isForeground);
        if (generation != _sessionGeneration) return;
        _publishConnectionStatus();
        return;
      }
      await _profileRuntime.setRecipientProfileWatchEnabled(true);
      await Future.wait([
        _chatRuntime.startSync(),
        _presenceRuntime.startSync(foreground: _isForeground),
        _profileRuntime.startSync(active: _isForeground),
        _membershipSyncRepository?.startSync(active: _isForeground) ??
            Future<void>.value(),
      ]);
      if (generation != _sessionGeneration) return;
      _publishConnectionStatus();
      unawaited(_resumePreviouslyUsedSecretChat(session));
      unawaited(_bootstrapSessionData(session, generation));
    } catch (error, stackTrace) {
      developer.log(
        'Could not start realtime services after authentication',
        name: 'tureon.auth',
        error: error,
        stackTrace: stackTrace,
      );
      if (generation == _sessionGeneration) {
        _realtimeStreamManager.requestReconnect();
      }
    }
  }

  Future<void> _bootstrapSessionData(UserSession session, int generation) {
    if (session.needsUsername || generation != _sessionGeneration) {
      return Future<void>.value();
    }
    final current = _sessionBootstrapInFlight;
    if (current != null) return current;

    late final Future<void> bootstrap;
    bootstrap =
        Future.wait([
          _refreshOwnProfileFromServer(
            session.userId,
            generation,
          ).timeout(const Duration(seconds: 10)).then<void>((_) {}).catchError((
            Object error,
            StackTrace stackTrace,
          ) {
            if (generation == _sessionGeneration) {
              _realtimeStreamManager.requestReconnect();
            }
            developer.log(
              'Could not load profile after authentication; will retry when connected',
              name: 'tureon.auth',
              error: error,
              stackTrace: stackTrace,
            );
          }),
          _bootstrapMyGroupsAndChannels()
              .timeout(const Duration(seconds: 10))
              .catchError((Object error, StackTrace stackTrace) {
                if (generation == _sessionGeneration) {
                  _realtimeStreamManager.requestReconnect();
                }
                developer.log(
                  'Could not load groups and channels after authentication; will retry when connected',
                  name: 'tureon.auth',
                  error: error,
                  stackTrace: stackTrace,
                );
              }),
        ]).then((_) {}).whenComplete(() {
          if (identical(_sessionBootstrapInFlight, bootstrap)) {
            _sessionBootstrapInFlight = null;
            _publishConnectionStatus();
          }
        });
    _sessionBootstrapInFlight = bootstrap;
    _publishConnectionStatus();
    return bootstrap;
  }

  void saveCurrentUser(UserProfile profile) =>
      profileRepository.saveLocal(profile, markForSync: true);

  @override
  Future<void> sendTypingIndicator({
    required String targetRecipientId,
    required bool isTyping,
  }) async {
    await _presenceRuntime.sendTypingIndicator(
      targetRecipientId: targetRecipientId,
      isTyping: isTyping,
    );
  }

  Future<Recipient> createGroup({
    required String name,
    String description = '',
    String avatarUrl = '',
    String visibility = 'public',
  }) => _groupChannelService.createGroup(
    name: name,
    description: description,
    avatarUrl: avatarUrl,
    visibility: visibility,
  );

  @override
  Future<void> sendBotMessage({
    required Recipient recipient,
    required String body,
  }) async {
    if (recipient.id == tureonBotId ||
        recipient.handle.toLowerCase() == tureonBotUsername) {
      throw StateError('The official Tureon bot only sends account notices.');
    }
    final session = currentSession;
    if (session == null) {
      throw StateError('A signed-in device is required to talk to bots.');
    }
    final chatRepository = _chatRuntime.chatRepository;
    if (chatRepository == null) {
      throw StateError('The real-time chat stream is not connected.');
    }
    await chatRepository.sendBotMessage(
      recipient: recipient,
      senderRecipientId: session.userId,
      body: body,
    );
  }

  Future<Recipient> createChannel({
    required String name,
    String description = '',
    String avatarUrl = '',
    String visibility = 'public',
  }) => _groupChannelService.createChannel(
    name: name,
    description: description,
    avatarUrl: avatarUrl,
    visibility: visibility,
  );

  Future<pb.GroupChannel> loadGroupChannelProfile({
    required String groupChannelId,
    required bool isChannel,
  }) => _groupChannelService.loadProfile(
    groupChannelId: groupChannelId,
    isChannel: isChannel,
  );

  Future<pb.GroupChannel> updateGroupChannelProfile({
    required String groupChannelId,
    required bool isChannel,
    required String name,
    required String username,
    required String description,
    required String avatarUrl,
    required String visibility,
  }) => _groupChannelService.updateProfile(
    groupChannelId: groupChannelId,
    isChannel: isChannel,
    name: name,
    username: username,
    description: description,
    avatarUrl: avatarUrl,
    visibility: visibility,
  );

  @override
  Future<void> addMemberToGroupChannel({
    required String groupChannelId,
    required String userId,
    required bool isChannel,
  }) => _groupChannelService.addMember(
    groupChannelId: groupChannelId,
    userId: userId,
    isChannel: isChannel,
  );

  Future<List<pb.GroupChannelMember>> listGroupChannelMembers({
    required String groupChannelId,
  }) => _groupChannelService.listMembers(groupChannelId: groupChannelId);

  Future<pb.ListGroupChannelMembersPageResponse> listGroupChannelMembersPage({
    required String groupChannelId,
    required int offset,
    int pageSize = 50,
    bool forceRefresh = false,
  }) => _groupChannelService.listMembersPage(
    groupChannelId: groupChannelId,
    offset: offset,
    pageSize: pageSize,
    forceRefresh: forceRefresh,
  );

  pb.ListGroupChannelMembersPageResponse? loadCachedGroupChannelMembersPage({
    required String groupChannelId,
    required int offset,
    int pageSize = 50,
  }) => _groupChannelService.loadCachedMembersPage(
    groupChannelId: groupChannelId,
    offset: offset,
    pageSize: pageSize,
  );

  @override
  Future<int> loadOnlineGroupMemberCount({required String groupId}) =>
      _groupChannelService.loadOnlineGroupMemberCount(groupId: groupId);

  Future<void> leaveGroupChannel({required String groupChannelId}) =>
      _groupChannelService.leaveGroupChannel(groupChannelId: groupChannelId);

  Future<void> updateGroupChannelMemberRole({
    required String groupChannelId,
    required String userId,
    required String role,
  }) => _groupChannelService.updateMemberRole(
    groupChannelId: groupChannelId,
    userId: userId,
    role: role,
  );

  Future<void> updateGroupChannelSendPermission({
    required String groupChannelId,
    required bool isChannel,
    required bool membersCanSendMessages,
  }) => _groupChannelService.updateMembersCanSendMessages(
    groupChannelId: groupChannelId,
    isChannel: isChannel,
    allowed: membersCanSendMessages,
  );

  Future<pb.GroupChannel> updateGroupChannelPermissions({
    required String groupChannelId,
    required bool isChannel,
    required Map<String, bool> permissions,
    int slowModeSeconds = 0,
  }) => _groupChannelService.updatePermissions(
    groupChannelId: groupChannelId,
    isChannel: isChannel,
    permissions: permissions,
    slowModeSeconds: slowModeSeconds,
  );

  Future<void> removeGroupChannelMember({
    required String groupChannelId,
    required String userId,
  }) => _groupChannelService.removeMember(
    groupChannelId: groupChannelId,
    userId: userId,
  );

  Future<void> banGroupChannelMember({
    required String groupChannelId,
    required String userId,
  }) => _groupChannelService.banMember(
    groupChannelId: groupChannelId,
    userId: userId,
  );

  Future<UserProfile> loadProfile({String? recipientId}) async {
    return _profileRuntime.loadProfile(recipientId: recipientId);
  }

  Future<void> _bootstrapMyGroupsAndChannels() =>
      _profileRuntime.bootstrapGroupsAndChannels();

  Future<UserProfile> _refreshOwnProfileFromServer(
    String userId, [
    int? expectedGeneration,
  ]) => _profileRuntime.refreshOwnProfileFromServer(userId, expectedGeneration);

  Future<void> _reconcileProfileOnResume(String userId) =>
      _profileRuntime.reconcileOnResume(userId);

  Future<void> _reconcileGroupMembershipOnResume() async {
    try {
      await _bootstrapMyGroupsAndChannels();
    } catch (error, stackTrace) {
      developer.log(
        'Could not reconcile group and channel membership after app resume',
        name: 'tureon.groups',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  bool _accountBlocksRealtime(UserSession session) =>
      session.accountStatus == 'banned' || session.accountStatus == 'suspended';

  Future<void> _enterRestrictedAccountState() async {
    await _profileRuntime.setRecipientProfileWatchEnabled(false);
    await Future.wait([
      _chatRuntime.stopSync(),
      _presenceRuntime.stopSync(sendOffline: true),
      _membershipSyncRepository?.stopSync() ?? Future<void>.value(),
    ]);
  }

  bool _hasAuthenticatedClient(String userId) {
    final state = _authRuntime.currentState;
    final authenticated =
        state?.status == AuthStatus.authenticated ||
        state?.status == AuthStatus.restricted;
    return authenticated &&
        state?.session?.userId == userId &&
        _client?.hasAccessToken == true;
  }

  Future<void> _resumeChatSynchronization() async {
    try {
      await _chatRuntime.startSync();
    } catch (error, stackTrace) {
      developer.log(
        'Could not resume message synchronization',
        name: 'tureon.messaging',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _rollbackIncompleteSession() async {
    _sessionGeneration++;
    _profileRuntime.reset();
    Object? syncStopFailure;
    Object? localClearFailure;
    Object? tokenClearFailure;
    try {
      await _chatRuntime.stopSync();
    } catch (error) {
      syncStopFailure = error;
    }
    try {
      await _presenceRuntime.stopSync(sendOffline: true);
    } catch (error) {
      syncStopFailure ??= error;
    }
    try {
      await _profileRuntime.stopSync();
    } catch (error) {
      syncStopFailure ??= error;
    }
    try {
      await _membershipSyncRepository?.stopSync();
    } catch (error) {
      syncStopFailure ??= error;
    }
    try {
      profileRepository.clearSessionAndProfile();
    } catch (error) {
      localClearFailure = error;
    }
    _chatRuntime.resetSecretCrypto();
    _client?.setAccessToken(null);
    _connectionManager.resetTransport();
    _publishConnectionStatus(force: ConnectionStatus.disconnected);
    final failures = [?syncStopFailure, ?localClearFailure, ?tokenClearFailure];
    if (failures.isNotEmpty) {
      throw StateError(
        'Could not fully roll back the incomplete session: '
        '${failures.join('; ')}',
      );
    }
  }

  Future<Recipient> _resolveIncomingRecipient(String recipientId) async {
    final cached = store.loadRecipient(recipientId);
    if (recipientId == tureonBotId) {
      return Recipient(
        id: recipientId,
        type: RecipientType.bot,
        name: 'Tureon',
        handle: tureonBotUsername,
        description: tureonBotDescription,
        lastMessage: cached?.lastMessage,
        unreadCount: cached?.unreadCount ?? 0,
        isUsernameVisible: true,
        canSendMessages: false,
        verificationBadge: VerificationBadge.verified,
      );
    }
    try {
      final profile = await loadProfile(recipientId: recipientId);
      final username = profile.username.trim();
      final displayName = profile.displayName.trim();
      return Recipient(
        id: recipientId,
        type: RecipientType.user,
        name: displayName.isNotEmpty
            ? displayName
            : username.isNotEmpty
            ? username
            : cached?.name ?? 'Usuário',
        handle: username.isEmpty ? cached?.handle ?? '' : '@$username',
        avatarUrl: profile.avatarUrl,
        lastMessage: cached?.lastMessage,
        unreadCount: cached?.unreadCount ?? 0,
        isUsernameVisible: username.isNotEmpty,
        verificationBadge: profile.verificationBadge,
      );
    } catch (error, stackTrace) {
      debugPrint('Could not load sender profile for $recipientId: $error');
      debugPrintStack(stackTrace: stackTrace);
      return cached ??
          Recipient(
            id: recipientId,
            type: RecipientType.user,
            name: 'Usuário',
            handle: '',
          );
    }
  }

  Future<Recipient?> _resolveIncomingRoomRecipient(
    String recipientId,
    RecipientType type,
    bool forceRefresh,
  ) => _groupChannelService.resolveRoomRecipient(
    recipientId,
    type: type,
    forceRefresh: forceRefresh,
  );

  Future<UserProfile> updateProfile(UserProfile profile) =>
      _profileRuntime.updateProfile(profile);

  Future<UserProfile> updatePrivacySetting({
    required String field,
    required String visibility,
  }) => _profileRuntime.updatePrivacySetting(
    field: field,
    visibility: visibility,
  );

  Future<void> _syncPendingProfileChanges() =>
      _profileRuntime.syncPendingChanges();

  Future<void> _resumePreviouslyUsedSecretChat(UserSession session) async {
    if (!_secretChatWasUsed(session)) return;
    try {
      await ensureSecretChatReady();
    } catch (error, stackTrace) {
      debugPrint(
        'Could not resume secret chat after session activation: $error',
      );
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> _persistAuthSession(UserSession? session) async {
    if (session != null) {
      await _persistAuthenticatedSession(session);
      return;
    }
    _sessionGeneration++;
    _sessionBootstrapInFlight = null;
    _profileRuntime.reset();
    Object? streamStopFailure;
    Object? sessionStoreFailure;
    try {
      await _chatRuntime.stopSync();
    } catch (error) {
      streamStopFailure = error;
    }
    try {
      await _presenceRuntime.stopSync(sendOffline: true);
    } catch (error) {
      streamStopFailure ??= error;
    }
    try {
      await _profileRuntime.stopSync();
    } catch (error) {
      streamStopFailure ??= error;
    }
    try {
      await _membershipSyncRepository?.stopSync();
    } catch (error) {
      streamStopFailure ??= error;
    }
    try {
      profileRepository.clearSessionAndProfile();
    } catch (error) {
      sessionStoreFailure = error;
    }
    _chatRuntime.resetSecretCrypto();
    _client?.setAccessToken(null);
    _connectionManager.resetTransport();
    _publishConnectionStatus(force: ConnectionStatus.disconnected);
    final failures = [?streamStopFailure, ?sessionStoreFailure];
    if (failures.isNotEmpty) {
      throw StateError('Local sign-out cleanup failed: ${failures.join('; ')}');
    }
  }

  void _handleAuthStateChanged(AuthState state) {
    if (state.status == AuthStatus.authenticating ||
        state.status == AuthStatus.restoringSession) {
      _publishConnectionStatus(force: ConnectionStatus.authenticating);
    } else {
      _publishConnectionStatus();
      if (state.status == AuthStatus.authenticated ||
          state.status == AuthStatus.needsUsername ||
          state.status == AuthStatus.restricted) {
        final session = state.session;
        if (session != null && _client?.hasAccessToken == true) {
          if (_accountBlocksRealtime(session)) {
            unawaited(_enterRestrictedAccountState());
          } else {
            unawaited(_bootstrapSessionData(session, _sessionGeneration));
          }
        }
      }
    }
  }

  Future<void> configureAuth(
    GoogleAuthDataSource google, {
    bool restoreSession = true,
  }) => _authRuntime.configure(
    google,
    restoreSession: restoreSession,
    serverReachable:
        _connectionManager.transportStatus == ConnectionStatus.connected,
  );

  Future<void> restoreAuthentication() => _authRuntime.restoreSession(
    serverReachable:
        _connectionManager.transportStatus == ConnectionStatus.connected,
  );

  Future<List<DeviceSession>> listDevices() => _authRuntime.listDevices();

  Future<void> revokeDevice(String deviceId) =>
      _authRuntime.revokeDevice(deviceId);

  Future<void> ensureSecretChatReady() async {
    final client = _client;
    final session = store.loadSession();
    if (client == null || session == null) {
      throw StateError('A connected signed-in device is required.');
    }
    await _chatRuntime.ensureSecretChatReady(client: client, session: session);
    saveSetting(_secretChatUsageKey(session), 'true');
  }

  bool _secretChatWasUsed(UserSession session) =>
      loadSetting(_secretChatUsageKey(session)) == 'true';

  String _secretChatUsageKey(UserSession session) =>
      'secret_chat_used_${session.userId}_${session.deviceId}';

  Future<List<SecretChatDevice>> listSecretChatDevices(
    String recipientId,
  ) async {
    final client = _client;
    if (client == null) throw StateError('The gRPC client is not connected.');
    return _chatRuntime.listSecretChatDevices(
      client: client,
      recipientId: recipientId,
    );
  }

  @override
  Future<List<Recipient>> searchUsersByUsername(String query) async {
    final client = _client;
    if (client == null || !client.hasAccessToken) {
      throw StateError('Sign in to search users by username.');
    }
    final response = await client.contacts.searchUsersByUsername(
      pb.SearchUsersByUsernameRequest(query: query),
    );
    return response.users
        .map(
          (user) => Recipient(
            id: user.recipientId,
            type: user.recipientType == 'bot'
                ? RecipientType.bot
                : RecipientType.user,
            name: user.displayName.isEmpty ? user.username : user.displayName,
            handle: user.username.isEmpty ? '' : '@${user.username}',
            avatarUrl: user.avatarUrl.isEmpty ? null : user.avatarUrl,
            description: user.description,
            isUsernameVisible: user.username.isNotEmpty,
            verificationBadge: verificationBadgeFromServer(
              user.verificationBadge,
            ),
            countryCode: user.countryCode,
            createdAt: user.createdAt.toInt() == 0
                ? null
                : DateTime.fromMillisecondsSinceEpoch(
                    user.createdAt.toInt() * 1000,
                    isUtc: true,
                  ),
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<List<Recipient>> searchPublicGroupChannels(String query) =>
      _groupChannelService.searchPublicGroupsAndChannels(query);

  @override
  Future<Recipient> joinPublicGroupChannel(Recipient recipient) =>
      _groupChannelService.joinPublicGroupChannel(recipient);

  Future<void> disconnect() async {
    _sessionGeneration++;
    _profileRuntime.reset();
    await _realtimeStreamManager.stop();
    await _connectionStateSubscription?.cancel();
    _connectionStateSubscription = null;
    _grpcConnectionWasRecovering = false;
    _connectionManager.resetTransport();
    _publishConnectionStatus(force: ConnectionStatus.disconnected);
    await _presenceRuntime.disconnect();
    await _profileRuntime.disconnect();
    await _membershipSyncRepository?.stopSync();
    _membershipSyncRepository = null;
    await _chatRuntime.disconnect();
    await _chatReadinessSubscription?.cancel();
    _chatReadinessSubscription = null;
    await _authRuntime.disconnect();
    final client = _client;
    _client = null;
    await client?.shutdown();
  }

  Future<void> close() async {
    await disconnect();
    _lifecycleCoordinator.dispose();
    await _presenceUpdates.close();
    await _authControllerUpdates.close();
    await _connectionManager.close();
    await store.close();
  }

  void _handleGrpcConnectionState(grpc.ConnectionState state) {
    _connectionManager.mapGrpcState(state);
    developer.log(
      'gRPC transport state changed: ${state.name}',
      name: 'tureon.connection',
    );
    if (state == grpc.ConnectionState.transientFailure) {
      _grpcConnectionWasRecovering = true;
    }
    _publishConnectionStatus();
    if (state == grpc.ConnectionState.ready) {
      unawaited(_retrySessionRestoreWhenReachable());
    }
    final authStatus = _authRuntime.currentState?.status;
    final sessionReady =
        (authStatus == AuthStatus.authenticated ||
            authStatus == AuthStatus.restricted) &&
        _client?.hasAccessToken == true;
    if (state == grpc.ConnectionState.ready && sessionReady) {
      if (_grpcConnectionWasRecovering) {
        _grpcConnectionWasRecovering = false;
        unawaited(_realtimeStreamManager.onConnectionReady());
      }
      final session = store.loadSession();
      if (session != null) {
        unawaited(_bootstrapSessionData(session, _sessionGeneration));
      }
      unawaited(
        _syncPendingProfileChanges().catchError((
          Object error,
          StackTrace stackTrace,
        ) {
          developer.log(
            'Could not resume pending profile synchronization',
            name: 'tureon.profile',
            error: error,
            stackTrace: stackTrace,
          );
        }),
      );
    }
  }

  Future<void> _reconnectRealtimeStreams() async {
    final client = _client;
    final session = store.loadSession();
    if (client == null) return;
    if (session == null || !_hasAuthenticatedClient(session.userId)) {
      // Probe even before authentication so backoff can recover an offline
      // startup. Successful restoration activates its own protected streams.
      await client.checkServerHealth();
      await _retrySessionRestoreWhenReachable();
      return;
    }
    if (session.needsUsername || _accountBlocksRealtime(session)) {
      // Connectivity changes can arrive while local session restoration is
      // still waiting for a refresh token. Do not open authenticated streams
      // with an empty access token; session activation starts them once the
      // refresh succeeds.
      return;
    }
    await client.checkServerHealth();
    await Future.wait([
      _chatRuntime.reconnect(),
      _presenceRuntime.reconnect(),
      _profileRuntime.reconnect(),
      _membershipSyncRepository?.reconnect() ?? Future<void>.value(),
    ]);
    // A transient snapshot failure can leave a fresh device without cached
    // metadata even though its transport never disconnected. Retry snapshots
    // along with streams, rather than waiting for another channel state change.
    if (store.loadSession()?.userId == session.userId &&
        store.loadSession()?.deviceId == session.deviceId) {
      await _bootstrapSessionData(session, _sessionGeneration);
    }
  }

  Future<void> _retrySessionRestoreWhenReachable() async {
    try {
      await _authRuntime.retrySessionRestoreWhenReachable();
    } catch (error, stackTrace) {
      developer.log(
        'Could not restore the local session after connectivity returned',
        name: 'tureon.auth',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  void _publishConnectionStatus({ConnectionStatus? force}) {
    _connectionManager.publish(
      force: force,
      isAuthenticating:
          _authRuntime.currentState?.status == AuthStatus.authenticating ||
          _authRuntime.currentState?.status == AuthStatus.restoringSession,
      hasSession: store.loadSession() != null,
      chatStreamReady: isChatStreamReady,
      isSynchronizing: _sessionBootstrapInFlight != null,
    );
  }
}
