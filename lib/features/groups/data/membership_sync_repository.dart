import 'dart:async';
import 'dart:developer' as developer;

import '../../../core/storage/local_store.dart';
import '../../../generated/proto/tureon.pb.dart' as pb;
import '../../../generated/proto/tureon.pbgrpc.dart';

abstract interface class MembershipChangesRpc {
  Stream<pb.MembershipChange> streamMembershipChanges(pb.Empty request);
}

class GrpcMembershipChangesRpc implements MembershipChangesRpc {
  const GrpcMembershipChangesRpc(this.client);

  final MembershipServiceClient client;

  @override
  Stream<pb.MembershipChange> streamMembershipChanges(pb.Empty request) =>
      client.streamMembershipChanges(request);
}

class MembershipSyncRepository {
  MembershipSyncRepository({
    required this.rpc,
    required this.store,
    required this.refreshSnapshot,
    this.refreshChatRoomSubscriptions,
    this.onStreamFailure,
  });

  final MembershipChangesRpc rpc;
  final LocalStore store;
  final Future<void> Function() refreshSnapshot;
  final Future<void> Function()? refreshChatRoomSubscriptions;
  final void Function()? onStreamFailure;

  static const _snapshotDebounce = Duration(milliseconds: 250);

  StreamSubscription<pb.MembershipChange>? _subscription;
  bool _running = false;
  bool _active = true;
  bool _snapshotRequested = false;
  bool _chatRoomRefreshRequested = false;
  int _generation = 0;
  Future<void>? _snapshotDrain;
  Timer? _snapshotDebounceTimer;
  Future<void> _lifecycleTail = Future<void>.value();

  Future<void> startSync({bool active = true}) => _serialize(() async {
    if (store.loadSession() == null) {
      await _stopSync();
      return;
    }
    _running = true;
    _active = active;
    if (_active) _startStream();
  });

  Future<void> setActive(bool active) => _serialize(() async {
    if (_active == active) return;
    _active = active;
    if (!_running) return;
    if (active) {
      _startStream();
      return;
    }
    _snapshotDebounceTimer?.cancel();
    _snapshotDebounceTimer = null;
    _snapshotRequested = false;
    _chatRoomRefreshRequested = false;
    _generation++;
    await _cancelStream();
  });

  Future<void> reconnect() => _serialize(() async {
    if (!_running || !_active) return;
    _generation++;
    await _cancelStream();
    _startStream();
  });

  Future<void> stopSync() => _serialize(_stopSync);

  Future<void> _stopSync() async {
    _running = false;
    _active = false;
    _generation++;
    _snapshotRequested = false;
    _chatRoomRefreshRequested = false;
    _snapshotDebounceTimer?.cancel();
    _snapshotDebounceTimer = null;
    await _cancelStream();
  }

  Future<void> _serialize(Future<void> Function() action) {
    final next = _lifecycleTail.then((_) => action());
    _lifecycleTail = next.catchError((_) {});
    return next;
  }

  void _startStream() {
    if (!_running || !_active || _subscription != null) return;
    final generation = ++_generation;
    var receivedInitialSignal = false;
    try {
      _subscription = rpc
          .streamMembershipChanges(pb.Empty())
          .listen(
            (_) {
              final isInitialSignal = !receivedInitialSignal;
              receivedInitialSignal = true;
              _scheduleSnapshotRefresh(refreshChatRooms: !isInitialSignal);
            },
            onError: (Object error, StackTrace stackTrace) {
              developer.log(
                'Membership change stream failed',
                name: 'tureon.groups',
                error: error,
                stackTrace: stackTrace,
              );
              _handleStreamEnd(generation);
            },
            onDone: () => _handleStreamEnd(generation),
            cancelOnError: true,
          );
    } catch (error, stackTrace) {
      developer.log(
        'Could not open membership change stream',
        name: 'tureon.groups',
        error: error,
        stackTrace: stackTrace,
      );
      _handleStreamEnd(generation);
    }
  }

  void _scheduleSnapshotRefresh({bool refreshChatRooms = false}) {
    if (!_running || !_active) return;
    _snapshotRequested = true;
    _chatRoomRefreshRequested |= refreshChatRooms;
    if (_snapshotDrain != null || _snapshotDebounceTimer != null) return;
    // Membership changes often arrive in bursts (bulk adds, joins, sync after
    // reconnect). Collapse each burst into one snapshot and one room refresh.
    _snapshotDebounceTimer = Timer(_snapshotDebounce, () {
      _snapshotDebounceTimer = null;
      if (!_running || !_active || _snapshotDrain != null) return;
      _startSnapshotDrain();
    });
  }

  void _startSnapshotDrain() {
    if (!_running || !_active || _snapshotDrain != null) return;
    late final Future<void> drain;
    drain = _drainSnapshots().whenComplete(() {
      if (identical(_snapshotDrain, drain)) _snapshotDrain = null;
      if (_snapshotRequested && _running && _active) {
        _scheduleSnapshotRefresh();
      }
    });
    _snapshotDrain = drain;
  }

  Future<void> _drainSnapshots() async {
    if (!_snapshotRequested || !_running || !_active) return;
    _snapshotRequested = false;
    try {
      await refreshSnapshot();
      if (_chatRoomRefreshRequested) {
        _chatRoomRefreshRequested = false;
        await refreshChatRoomSubscriptions?.call();
      }
    } catch (error, stackTrace) {
      developer.log(
        'Could not refresh group and channel membership',
        name: 'tureon.groups',
        error: error,
        stackTrace: stackTrace,
      );
      _handleStreamEnd(_generation);
    }
  }

  void _handleStreamEnd(int generation) {
    if (!_running || !_active || generation != _generation) return;
    final subscription = _subscription;
    _subscription = null;
    if (subscription != null) unawaited(_cancelStream(subscription));
    onStreamFailure?.call();
  }

  Future<void> _cancelStream([
    StreamSubscription<pb.MembershipChange>? explicit,
  ]) async {
    final subscription = explicit ?? _subscription;
    if (identical(_subscription, subscription)) _subscription = null;
    if (subscription == null) return;
    try {
      await subscription.cancel();
    } catch (error, stackTrace) {
      developer.log(
        'Membership stream cancellation failed',
        name: 'tureon.groups',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}
