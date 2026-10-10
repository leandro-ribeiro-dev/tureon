import 'dart:async';
import 'dart:developer' as developer;

import 'package:fixnum/fixnum.dart';

import '../../../core/storage/local_store.dart';
import '../../../core/storage/message_records.dart';
import '../../../generated/proto/tureon.pb.dart' as pb;
import '../../../generated/proto/tureon.pbgrpc.dart';

abstract interface class ProfileUpdatesRpc {
  Stream<pb.ProfileChange> streamProfileChanges(pb.Empty request);

  Stream<pb.ProfileChange> streamRecipientProfileChanges(
    pb.ProfileWatchRequest request,
  );
}

class GrpcProfileUpdatesRpc implements ProfileUpdatesRpc {
  const GrpcProfileUpdatesRpc(this.client);

  final ProfileServiceClient client;

  @override
  Stream<pb.ProfileChange> streamProfileChanges(pb.Empty request) =>
      client.streamProfileChanges(request);

  @override
  Stream<pb.ProfileChange> streamRecipientProfileChanges(
    pb.ProfileWatchRequest request,
  ) => client.streamRecipientProfileChanges(request);
}

typedef ProfileChangeHandler = Future<void> Function(int profileVersion);
typedef RecipientProfileChangeHandler =
    Future<void> Function(String recipientId, int profileVersion);
typedef AccountStatusChangeHandler =
    Future<void> Function(String accountStatus);
typedef VerificationBadgeChangeHandler = Future<void> Function(String badge);

Future<void> _ignoreRecipientProfileChange(String _, int _) async {}
Future<void> _ignoreAccountStatusChange(String _) async {}
Future<void> _ignoreVerificationBadgeChange(String _) async {}

class ProfileSyncRepository {
  ProfileSyncRepository({
    required this.rpc,
    required this.store,
    required this.onProfileChange,
    this.onRecipientProfileChange = _ignoreRecipientProfileChange,
    this.onAccountStatusChange = _ignoreAccountStatusChange,
    this.onVerificationBadgeChange = _ignoreVerificationBadgeChange,
    this.recipientProfilesEnabled = true,
    this.onStreamFailure,
  });

  static const maxWatchedRecipients = 64;
  static const _recipientWatchDebounce = Duration(milliseconds: 250);

  final ProfileUpdatesRpc rpc;
  final LocalStore store;
  final ProfileChangeHandler onProfileChange;
  final RecipientProfileChangeHandler onRecipientProfileChange;
  final AccountStatusChangeHandler onAccountStatusChange;
  final VerificationBadgeChangeHandler onVerificationBadgeChange;
  final void Function()? onStreamFailure;
  bool recipientProfilesEnabled;

  StreamSubscription<pb.ProfileChange>? _subscription;
  StreamSubscription<pb.ProfileChange>? _recipientSubscription;
  StreamSubscription<void>? _conversationChangesSubscription;
  Timer? _recipientRefreshTimer;
  UserSession? _session;
  int _generation = 0;
  int _recipientGeneration = 0;
  bool _running = false;
  bool _active = true;
  int _pendingProfileVersion = 0;
  final Map<String, int> _pendingRecipientVersions = {};
  String? _recipientStreamKey;
  bool _accountStatusRefreshRunning = false;
  String? _pendingAccountStatus;
  Timer? _accountStatusRetryTimer;
  int _accountStatusRetryAttempts = 0;
  Future<void>? _changeDrain;
  Future<void>? _recipientChangeDrain;
  Future<void> _lifecycleTail = Future<void>.value();

  Future<void> startSync({bool active = true}) => _serializeLifecycle(() async {
    final session = store.loadSession();
    if (session == null) {
      await _stopSync();
      return;
    }
    final current = _session;
    if (current != null &&
        (current.userId != session.userId ||
            current.deviceId != session.deviceId)) {
      await _stopSync();
    }
    _session = session;
    _running = true;
    _active = active;
    if (_active) await _startActiveStreams();
  });

  Future<void> reconnect() => _serializeLifecycle(() async {
    if (!_running || !_active) return;
    _generation++;
    _recipientGeneration++;
    await _cancelOwnStream();
    await _cancelRecipientStream();
    _startOwnStream();
    await _refreshRecipientStream(force: true);
  });

  Future<void> setActive(bool active) => _serializeLifecycle(() async {
    if (_active == active) return;
    _active = active;
    if (!_running) return;
    if (active) {
      await _startActiveStreams();
      final pendingStatus = _pendingAccountStatus;
      if (pendingStatus != null) _refreshAccountStatus(pendingStatus);
      return;
    }
    _accountStatusRetryTimer?.cancel();
    _accountStatusRetryTimer = null;
    _generation++;
    _recipientGeneration++;
    await _cancelOwnStream();
    await _cancelRecipientStream();
    await _stopConversationWatcher();
  });

  Future<void> stopSync() => _serializeLifecycle(_stopSync);

  Future<void> setRecipientProfilesEnabled(bool enabled) =>
      _serializeLifecycle(() async {
        if (recipientProfilesEnabled == enabled) return;
        recipientProfilesEnabled = enabled;
        if (!enabled) {
          _recipientGeneration++;
          _pendingRecipientVersions.clear();
          _recipientStreamKey = null;
          await _cancelRecipientStream();
          await _stopConversationWatcher();
          return;
        }
        if (_running && _active) {
          _startConversationWatcher();
          await _refreshRecipientStream(force: true);
        }
      });

  Future<void> _startActiveStreams() async {
    _startOwnStream();
    if (recipientProfilesEnabled) {
      _startConversationWatcher();
      await _refreshRecipientStream(force: true);
    }
  }

  Future<void> _stopSync() async {
    _running = false;
    _active = false;
    _generation++;
    _recipientGeneration++;
    _pendingProfileVersion = 0;
    _pendingRecipientVersions.clear();
    _pendingAccountStatus = null;
    _accountStatusRetryTimer?.cancel();
    _accountStatusRetryTimer = null;
    await _cancelOwnStream();
    await _cancelRecipientStream();
    await _stopConversationWatcher();
    _session = null;
  }

  Future<void> _serializeLifecycle(Future<void> Function() action) {
    final next = _lifecycleTail.then((_) => action());
    _lifecycleTail = next.catchError((_) {});
    return next;
  }

  void _startOwnStream() {
    if (!_running || !_active || _session == null || _subscription != null) {
      return;
    }
    final generation = ++_generation;
    try {
      _subscription = rpc
          .streamProfileChanges(pb.Empty())
          .listen(
            (change) {
              if (generation != _generation) return;
              final version = change.profileVersion.toInt();
              if (version > _pendingProfileVersion) {
                _pendingProfileVersion = version;
              }
              _scheduleChangeDrain(generation);
              final currentSession = store.loadSession();
              final localProfile = currentSession == null
                  ? null
                  : store.loadCurrentUser(userId: currentSession.userId);
              if (change.verificationBadge.isNotEmpty &&
                  localProfile != null &&
                  version <= localProfile.profileVersion &&
                  change.verificationBadge !=
                      localProfile.verificationBadge.name) {
                unawaited(
                  onVerificationBadgeChange(
                    change.verificationBadge,
                  ).catchError((Object error, StackTrace stackTrace) {
                    developer.log(
                      'Could not reconcile own verification badge',
                      name: 'tureon.profile',
                      error: error,
                      stackTrace: stackTrace,
                    );
                  }),
                );
              }
              final status = change.accountStatus;
              final session = store.loadSession();
              if (status.isNotEmpty &&
                  session != null &&
                  status != session.accountStatus) {
                _refreshAccountStatus(status);
              }
            },
            onError: (Object error, StackTrace stackTrace) {
              developer.log(
                'Profile change stream failed',
                name: 'tureon.profile',
                error: error,
                stackTrace: stackTrace,
              );
              _handleOwnStreamEnd(generation);
            },
            onDone: () => _handleOwnStreamEnd(generation),
            cancelOnError: true,
          );
    } catch (error, stackTrace) {
      developer.log(
        'Could not open profile change stream',
        name: 'tureon.profile',
        error: error,
        stackTrace: stackTrace,
      );
      _handleOwnStreamEnd(generation);
    }
  }

  void _startConversationWatcher() {
    if (!recipientProfilesEnabled || _conversationChangesSubscription != null) {
      return;
    }
    _conversationChangesSubscription = store.watchConversationChanges().listen(
      (_) => _scheduleRecipientWatchRefresh(),
      onError: (Object error, StackTrace stackTrace) {
        developer.log(
          'Conversation profile watch could not observe local changes',
          name: 'tureon.profile',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );
  }

  Future<void> _stopConversationWatcher() async {
    _recipientRefreshTimer?.cancel();
    _recipientRefreshTimer = null;
    final subscription = _conversationChangesSubscription;
    _conversationChangesSubscription = null;
    try {
      await subscription?.cancel();
    } catch (error, stackTrace) {
      developer.log(
        'Conversation profile watch cancellation failed',
        name: 'tureon.profile',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  void _scheduleRecipientWatchRefresh({bool force = false}) {
    if (!recipientProfilesEnabled) return;
    _recipientRefreshTimer?.cancel();
    _recipientRefreshTimer = Timer(_recipientWatchDebounce, () {
      _recipientRefreshTimer = null;
      unawaited(
        _serializeLifecycle(() async {
          if (_running && _active) {
            await _refreshRecipientStream(force: force);
          }
        }),
      );
    });
  }

  Future<void> _refreshRecipientStream({bool force = false}) async {
    if (!_running ||
        !_active ||
        _session == null ||
        !recipientProfilesEnabled) {
      return;
    }
    final recipients = store.loadRecentUserRecipients(
      limit: maxWatchedRecipients,
    );
    final sortedRecipients = [...recipients]
      ..sort((first, second) => first.id.compareTo(second.id));
    final streamKey = sortedRecipients.map((item) => item.id).join(',');
    if (!force && streamKey == _recipientStreamKey) return;
    _recipientGeneration++;
    final generation = _recipientGeneration;
    await _cancelRecipientStream();
    _recipientStreamKey = streamKey;
    if (sortedRecipients.isEmpty) return;
    final request = pb.ProfileWatchRequest(
      cursors: sortedRecipients
          .map(
            (recipient) => pb.ProfileWatchCursor(
              recipientId: recipient.id,
              profileVersion: Int64(recipient.profileVersion),
              verificationBadge: recipient.verificationBadge.name,
            ),
          )
          .toList(growable: false),
    );
    try {
      _recipientSubscription = rpc
          .streamRecipientProfileChanges(request)
          .listen(
            (change) {
              if (generation != _recipientGeneration) return;
              final recipientId = change.recipientId;
              if (recipientId.isEmpty) {
                _scheduleRecipientWatchRefresh(force: true);
                return;
              }
              final version = change.profileVersion.toInt();
              final cached = store.loadRecipient(recipientId);
              final badgeChanged =
                  change.verificationBadge.isNotEmpty &&
                  cached?.verificationBadge.name != change.verificationBadge;
              if (version > (_pendingRecipientVersions[recipientId] ?? -1) ||
                  badgeChanged) {
                _pendingRecipientVersions[recipientId] = version;
                _scheduleRecipientChangeDrain(generation);
              }
            },
            onError: (Object error, StackTrace stackTrace) {
              developer.log(
                'Recipient profile change stream failed',
                name: 'tureon.profile',
                error: error,
                stackTrace: stackTrace,
              );
              _handleRecipientStreamEnd(generation);
            },
            onDone: () => _handleRecipientStreamEnd(generation),
            cancelOnError: true,
          );
    } catch (error, stackTrace) {
      developer.log(
        'Could not open recipient profile stream',
        name: 'tureon.profile',
        error: error,
        stackTrace: stackTrace,
      );
      _handleRecipientStreamEnd(generation);
    }
  }

  void _scheduleChangeDrain(int generation) {
    if (_changeDrain != null) return;
    final drain = _drainChanges(generation);
    _changeDrain = drain;
    unawaited(
      drain.whenComplete(() {
        if (identical(_changeDrain, drain)) _changeDrain = null;
        if (_pendingProfileVersion > 0 && _running && _active) {
          _scheduleChangeDrain(_generation);
        }
      }),
    );
  }

  Future<void> _drainChanges(int generation) async {
    while (_running && _active && generation == _generation) {
      final version = _pendingProfileVersion;
      if (version <= 0) return;
      _pendingProfileVersion = 0;
      try {
        await onProfileChange(version);
      } catch (error, stackTrace) {
        developer.log(
          'Could not apply a profile change; reconnecting for a fresh snapshot',
          name: 'tureon.profile',
          error: error,
          stackTrace: stackTrace,
        );
        _handleOwnStreamEnd(generation);
        return;
      }
    }
  }

  void _scheduleRecipientChangeDrain(int generation) {
    if (_recipientChangeDrain != null) return;
    final drain = _drainRecipientChanges(generation);
    _recipientChangeDrain = drain;
    unawaited(
      drain.whenComplete(() {
        if (identical(_recipientChangeDrain, drain)) {
          _recipientChangeDrain = null;
        }
        if (_pendingRecipientVersions.isNotEmpty && _running && _active) {
          _scheduleRecipientChangeDrain(_recipientGeneration);
        }
      }),
    );
  }

  Future<void> _drainRecipientChanges(int generation) async {
    while (_running && _active && generation == _recipientGeneration) {
      if (_pendingRecipientVersions.isEmpty) return;
      final recipientId = _pendingRecipientVersions.keys.first;
      final version = _pendingRecipientVersions.remove(recipientId) ?? 0;
      try {
        await onRecipientProfileChange(recipientId, version);
      } catch (error, stackTrace) {
        developer.log(
          'Could not refresh a conversation profile',
          name: 'tureon.profile',
          error: error,
          stackTrace: stackTrace,
        );
        _handleRecipientStreamEnd(generation);
        return;
      }
    }
  }

  void _refreshAccountStatus(String accountStatus) {
    _pendingAccountStatus = accountStatus;
    if (!_running || !_active || _accountStatusRefreshRunning) return;
    _accountStatusRetryTimer?.cancel();
    _accountStatusRetryTimer = null;
    _accountStatusRefreshRunning = true;
    unawaited(() async {
      String? statusBeingRefreshed;
      try {
        while (_pendingAccountStatus != null && _running && _active) {
          statusBeingRefreshed = _pendingAccountStatus;
          _pendingAccountStatus = null;
          await onAccountStatusChange(statusBeingRefreshed!);
          statusBeingRefreshed = null;
          _accountStatusRetryAttempts = 0;
        }
      } catch (error, stackTrace) {
        _pendingAccountStatus ??= statusBeingRefreshed;
        developer.log(
          'Could not reconcile account status from the server',
          name: 'tureon.auth',
          error: error,
          stackTrace: stackTrace,
        );
      } finally {
        _accountStatusRefreshRunning = false;
        if (_pendingAccountStatus != null &&
            _running &&
            _active &&
            store.loadSession() != null) {
          _scheduleAccountStatusRetry();
        }
      }
    }());
  }

  void _scheduleAccountStatusRetry() {
    if (_accountStatusRetryTimer != null ||
        _pendingAccountStatus == null ||
        !_running ||
        !_active) {
      return;
    }
    final exponent = _accountStatusRetryAttempts.clamp(0, 5).toInt();
    final delaySeconds = (1 << exponent).clamp(1, 30).toInt();
    _accountStatusRetryAttempts++;
    _accountStatusRetryTimer = Timer(Duration(seconds: delaySeconds), () {
      _accountStatusRetryTimer = null;
      final status = _pendingAccountStatus;
      if (status != null) _refreshAccountStatus(status);
    });
  }

  void _handleOwnStreamEnd(int generation) {
    if (!_running || generation != _generation || _session == null) return;
    final subscription = _subscription;
    _subscription = null;
    if (subscription != null) unawaited(_cancelOwnStream(subscription));
    onStreamFailure?.call();
  }

  void _handleRecipientStreamEnd(int generation) {
    if (!_running || generation != _recipientGeneration || _session == null) {
      return;
    }
    final subscription = _recipientSubscription;
    _recipientSubscription = null;
    if (subscription != null) {
      unawaited(_cancelRecipientStream(subscription));
    }
    onStreamFailure?.call();
  }

  Future<void> _cancelOwnStream([
    StreamSubscription<pb.ProfileChange>? explicit,
  ]) async {
    final subscription = explicit ?? _subscription;
    if (identical(_subscription, subscription)) _subscription = null;
    if (subscription == null) return;
    try {
      await subscription.cancel();
    } catch (error, stackTrace) {
      developer.log(
        'Profile stream cancellation ended with a transport error',
        name: 'tureon.profile',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _cancelRecipientStream([
    StreamSubscription<pb.ProfileChange>? explicit,
  ]) async {
    final subscription = explicit ?? _recipientSubscription;
    if (identical(_recipientSubscription, subscription)) {
      _recipientSubscription = null;
    }
    if (subscription == null) return;
    try {
      await subscription.cancel();
    } catch (error, stackTrace) {
      developer.log(
        'Recipient profile stream cancellation ended with a transport error',
        name: 'tureon.profile',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}
