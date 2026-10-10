import 'dart:async';
import 'dart:developer' as developer;

import 'package:grpc/grpc.dart';

import '../../../core/protocol/recipient.dart';
import '../../../core/protocol/recipient_type.dart';
import '../../../core/storage/local_store.dart';
import '../../../core/storage/message_records.dart';
import '../../../generated/proto/tureon.pb.dart' as pb;
import '../../../generated/proto/tureon.pbgrpc.dart' show PresenceServiceClient;

abstract interface class PresenceRpc {
  Stream<pb.PresenceServerEvent> realtime(
    Stream<pb.PresenceClientEvent> requests,
  );
}

class GrpcPresenceRpc implements PresenceRpc {
  const GrpcPresenceRpc(this.client);

  final PresenceServiceClient client;

  @override
  Stream<pb.PresenceServerEvent> realtime(
    Stream<pb.PresenceClientEvent> requests,
  ) => client.realtime(requests);
}

typedef PresenceUpdateHandler = void Function(Recipient recipient);

class PresenceRepository {
  PresenceRepository({
    required this.rpc,
    required this.store,
    required this.onPresenceUpdate,
    this.heartbeatInterval = const Duration(seconds: 20),
    this.onStreamFailure,
  });

  final PresenceRpc rpc;
  final LocalStore store;
  final PresenceUpdateHandler onPresenceUpdate;
  final Duration heartbeatInterval;
  final void Function()? onStreamFailure;

  StreamSubscription<pb.PresenceServerEvent>? _subscription;
  StreamController<pb.PresenceClientEvent>? _requestController;
  Completer<void>? _streamEnded;
  Future<void>? _streamCleanup;
  int _streamGeneration = 0;
  Timer? _heartbeatTimer;
  UserSession? _session;
  bool _running = false;
  bool _foreground = true;
  Future<void> _lifecycleTail = Future<void>.value();
  StreamSubscription<List<Recipient>>? _recipientSubscription;
  Timer? _recipientRefreshTimer;
  String? _recipientSignature;

  Future<void> startSync({bool foreground = true}) =>
      _serializeLifecycle(() async {
        final session = store.loadSession();
        if (session == null) {
          await _stopSync();
          return;
        }
        final current = _session;
        if (current != null &&
            (current.userId != session.userId ||
                current.deviceId != session.deviceId)) {
          await _stopSync(sendOffline: true);
        }
        _session = session;
        _running = true;
        _foreground = foreground;
        _watchRecipients();
        if (_foreground) {
          await _startForegroundSync();
        }
      });

  Future<void> setForeground(bool foreground) => _serializeLifecycle(() async {
    if (_foreground == foreground) return;
    _foreground = foreground;
    if (!_running) return;
    if (foreground) {
      await _startForegroundSync();
      return;
    }

    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    await _stopRealtime(sendOffline: true);
    _clearEphemeralPresence();
    _cancelTypingTimers();
  });

  Future<void> stopSync({bool sendOffline = false}) =>
      _serializeLifecycle(() => _stopSync(sendOffline: sendOffline));

  Future<void> _stopSync({bool sendOffline = false}) async {
    final wasActive = _running && _foreground;
    _running = false;
    _foreground = false;
    _recipientRefreshTimer?.cancel();
    _recipientRefreshTimer = null;
    await _recipientSubscription?.cancel();
    _recipientSubscription = null;
    _recipientSignature = null;
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    _clearEphemeralPresence();
    _cancelTypingTimers();
    await _stopRealtime(sendOffline: sendOffline && wasActive);
    _session = null;
  }

  final Map<String, Timer> _typingTimers = {};
  final Map<String, String> _typingDisplayRecipientIds = {};
  final Map<
    String,
    ({bool isOnline, bool isPresenceVisible, DateTime? lastSeenAt})
  >
  _presenceByRecipient = {};

  void handleTypingIndicator({
    required String senderRecipientId,
    required String targetRecipientId,
    required bool isTyping,
  }) {
    if (senderRecipientId.isEmpty || targetRecipientId.isEmpty) return;
    final targetIsAuthenticatedUser = targetRecipientId == _session?.userId;
    final displayRecipientId = targetIsAuthenticatedUser
        ? senderRecipientId
        : targetRecipientId;
    final key = '$targetRecipientId:$senderRecipientId';
    _typingTimers.remove(key)?.cancel();
    _typingDisplayRecipientIds.remove(key);

    final recipient = store.loadRecipient(displayRecipientId);
    if (recipient == null) return;

    if (isTyping) {
      _typingDisplayRecipientIds[key] = displayRecipientId;
      _typingTimers[key] = Timer(const Duration(seconds: 5), () {
        _typingTimers.remove(key);
        _typingDisplayRecipientIds.remove(key);
        _emitEphemeralUpdate(recipient);
      });
    }
    _emitEphemeralUpdate(recipient);
  }

  Future<void> sendTypingIndicator({
    required String targetRecipientId,
    required bool isTyping,
  }) async {
    final session = _session;
    final requests = _requestController;
    if (!_running || !_foreground || session == null || requests == null) {
      return;
    }
    requests.add(
      pb.PresenceClientEvent(
        typing: pb.TypingIndicator(
          senderRecipientId: session.userId,
          targetRecipientId: targetRecipientId,
          isTyping: isTyping,
        ),
      ),
    );
  }

  Future<void> _startForegroundSync() async {
    if (!_running || !_foreground || _session == null) return;
    await _startRealtime();
    if (!_running || !_foreground || _session == null) return;
    if (_heartbeatTimer == null) {
      _sendHeartbeat(online: true);
      _heartbeatTimer = Timer.periodic(heartbeatInterval, (_) {
        _sendHeartbeat(online: true);
      });
    }
  }

  void _watchRecipients() {
    if (_recipientSubscription != null) return;
    String signature(List<Recipient> recipients) {
      final ids =
          recipients
              .where((recipient) => recipient.type == RecipientType.user)
              .map((recipient) => recipient.id)
              .toList()
            ..sort();
      return ids.join(',');
    }

    _recipientSignature = signature(store.loadRecipients());
    _recipientSubscription = store.watchRecipients().listen(
      (recipients) {
        final next = signature(recipients);
        if (next == _recipientSignature) return;
        _recipientSignature = next;
        _recipientRefreshTimer?.cancel();
        if (!_running || !_foreground) return;
        // Coalesce newly synchronized conversations and update the existing
        // stream's target set without interrupting heartbeats or typing.
        _recipientRefreshTimer = Timer(const Duration(milliseconds: 100), () {
          _recipientRefreshTimer = null;
          if (!_running || !_foreground) return;
          _sendPresenceWatch();
        });
      },
      onError: (Object error, StackTrace stackTrace) {
        developer.log(
          'Could not observe presence subscription targets',
          name: 'tureon.presence',
          error: error,
          stackTrace: stackTrace,
        );
        onStreamFailure?.call();
      },
    );
  }

  Future<void> reconnect() => _serializeLifecycle(() async {
    if (!_running) return;
    await _stopRealtime();
    if (!_running || !_foreground) return;
    await _startRealtime();
    _sendHeartbeat(online: true);
  });

  Future<void> _serializeLifecycle(Future<void> Function() action) {
    final next = _lifecycleTail.then((_) => action());
    _lifecycleTail = next.catchError((_) {});
    return next;
  }

  Future<void> _startRealtime() async {
    final cleanup = _streamCleanup;
    if (cleanup != null) await cleanup;
    if (!_running ||
        !_foreground ||
        _session == null ||
        _subscription != null) {
      return;
    }
    final generation = ++_streamGeneration;
    final session = _session!;
    final requests = StreamController<pb.PresenceClientEvent>();
    final ended = Completer<void>();
    _requestController = requests;
    _streamEnded = ended;
    try {
      _subscription = rpc
          .realtime(requests.stream)
          .listen(
            (event) {
              final current = store.loadSession();
              if (generation == _streamGeneration &&
                  current?.userId == session.userId &&
                  current?.deviceId == session.deviceId) {
                _receiveServerEvent(event);
              }
            },
            onError: (Object error, StackTrace stackTrace) {
              developer.log(
                'Presence realtime stream failed',
                name: 'tureon.presence',
                error: error,
                stackTrace: stackTrace,
              );
              _handleRealtimeStreamEnd(
                generation,
                retry:
                    error is! GrpcError ||
                    error.code != StatusCode.unimplemented,
              );
              if (!ended.isCompleted) ended.complete();
            },
            onDone: () {
              _handleRealtimeStreamEnd(generation);
              if (!ended.isCompleted) ended.complete();
            },
            cancelOnError: true,
          );
    } catch (error, stackTrace) {
      developer.log(
        'Could not open presence realtime stream',
        name: 'tureon.presence',
        error: error,
        stackTrace: stackTrace,
      );
      _handleRealtimeStreamEnd(generation);
      if (!ended.isCompleted) ended.complete();
    }
    _sendPresenceWatch();
  }

  void _sendPresenceWatch() {
    final requests = _requestController;
    if (!_running || !_foreground || requests == null || requests.isClosed) {
      return;
    }
    final ids = store
        .loadRecipients()
        .where((recipient) => recipient.type == RecipientType.user)
        .map((recipient) => recipient.id)
        .take(4096)
        .toList();
    requests.add(
      pb.PresenceClientEvent(watch: pb.PresenceWatch(recipientIds: ids)),
    );
  }

  void _sendHeartbeat({required bool online}) {
    final requests = _requestController;
    if (requests == null || requests.isClosed) return;
    requests.add(
      pb.PresenceClientEvent(heartbeat: pb.PresenceHeartbeat(online: online)),
    );
  }

  void _receivePresence(pb.PresenceUpdate update) {
    if (update.recipientId.isEmpty) return;
    final recipient = store.loadRecipient(update.recipientId);
    if (recipient == null) return;

    final lastSeenSeconds = update.lastSeen.toInt();
    final validLastSeen =
        lastSeenSeconds > 0 && lastSeenSeconds <= 8640000000000;
    final visible = update.hasPresenceVisible()
        ? update.presenceVisible
        : validLastSeen;
    final lastSeenAt = visible && validLastSeen
        ? DateTime.fromMillisecondsSinceEpoch(
            lastSeenSeconds * 1000,
            isUtc: true,
          )
        : null;
    _presenceByRecipient[recipient.id] = (
      isOnline: visible && update.online,
      isPresenceVisible: visible,
      lastSeenAt: lastSeenAt,
    );
    _emitEphemeralUpdate(recipient);
  }

  void _receiveServerEvent(pb.PresenceServerEvent event) {
    switch (event.whichEvent()) {
      case pb.PresenceServerEvent_Event.presence:
        _receivePresence(event.presence);
        break;
      case pb.PresenceServerEvent_Event.typing:
        _receiveTypingIndicator(event.typing);
        break;
      case pb.PresenceServerEvent_Event.notSet:
        break;
    }
  }

  void _emitEphemeralUpdate(Recipient recipient, {bool? isTyping}) {
    final presence = _presenceByRecipient[recipient.id];
    onPresenceUpdate(
      recipient.copyWith(
        isOnline: presence?.isOnline ?? recipient.isOnline,
        isPresenceVisible:
            presence?.isPresenceVisible ?? recipient.isPresenceVisible,
        lastSeenAt: presence?.lastSeenAt,
        clearLastSeenAt: presence != null && presence.lastSeenAt == null,
        isTyping:
            isTyping ??
            _typingDisplayRecipientIds.values.contains(recipient.id),
        presenceUpdate: true,
      ),
    );
  }

  void _clearEphemeralPresence() {
    final recipientIds = {
      ..._presenceByRecipient.keys,
      ..._typingDisplayRecipientIds.values,
    };
    for (final recipientId in recipientIds) {
      final recipient = store.loadRecipient(recipientId);
      if (recipient == null) continue;
      onPresenceUpdate(
        recipient.copyWith(
          isOnline: false,
          isPresenceVisible: false,
          clearLastSeenAt: true,
          isTyping: false,
          presenceUpdate: true,
        ),
      );
    }
    _presenceByRecipient.clear();
  }

  void _handleRealtimeStreamEnd(int generation, {bool retry = true}) {
    if (generation != _streamGeneration) return;
    _streamGeneration++;
    final subscription = _subscription;
    _subscription = null;
    _clearEphemeralPresence();
    _cancelTypingTimers();
    final requests = _requestController;
    _requestController = null;
    _streamEnded = null;
    final cleanup = _disposeStreamResources(requests, subscription);
    _streamCleanup = cleanup;
    unawaited(
      cleanup.whenComplete(() {
        if (identical(_streamCleanup, cleanup)) _streamCleanup = null;
      }),
    );
    if (!_running || !_foreground || !retry) return;
    onStreamFailure?.call();
  }

  void _receiveTypingIndicator(pb.TypingIndicator update) {
    final session = _session;
    if (session == null || update.senderRecipientId.isEmpty) return;
    if (update.senderRecipientId == session.userId) return;
    handleTypingIndicator(
      senderRecipientId: update.senderRecipientId,
      targetRecipientId: update.targetRecipientId,
      isTyping: update.isTyping,
    );
  }

  void _cancelTypingTimers() {
    for (final timer in _typingTimers.values) {
      timer.cancel();
    }
    _typingTimers.clear();
    _typingDisplayRecipientIds.clear();
  }

  Future<void> _stopRealtime({bool sendOffline = false}) async {
    final previousCleanup = _streamCleanup;
    if (previousCleanup != null) await previousCleanup;
    _streamGeneration++;
    final requests = _requestController;
    final subscription = _subscription;
    final ended = _streamEnded;
    _requestController = null;
    _subscription = null;
    _streamEnded = null;
    if (sendOffline && requests != null && !requests.isClosed) {
      requests.add(
        pb.PresenceClientEvent(heartbeat: pb.PresenceHeartbeat(online: false)),
      );
    }
    final cleanup = _disposeStreamResources(
      requests,
      subscription,
      ended: ended,
    );
    _streamCleanup = cleanup;
    try {
      await cleanup;
    } finally {
      if (identical(_streamCleanup, cleanup)) _streamCleanup = null;
    }
  }

  Future<void> _disposeStreamResources(
    StreamController<pb.PresenceClientEvent>? requests,
    StreamSubscription<pb.PresenceServerEvent>? subscription, {
    Completer<void>? ended,
  }) async {
    if (requests != null && !requests.isClosed) {
      try {
        await requests.close();
      } catch (_) {
        // The RPC may already have closed the request side after a stream error.
      }
    }
    if (ended != null) {
      try {
        await ended.future.timeout(const Duration(seconds: 3));
      } on TimeoutException {
        await _cancelSubscription(subscription);
      }
    }
    await _cancelSubscription(subscription);
  }

  Future<void> _cancelSubscription(
    StreamSubscription<pb.PresenceServerEvent>? subscription,
  ) async {
    try {
      await subscription?.cancel();
    } catch (error, stackTrace) {
      developer.log(
        'Presence stream cancellation ended with a transport error',
        name: 'tureon.presence',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}

class TypingIndicatorDebouncer {
  TypingIndicatorDebouncer({
    required this.send,
    this.interval = const Duration(seconds: 3),
  });

  final Future<void> Function(bool isTyping) send;
  final Duration interval;
  Timer? _timer;
  bool _active = false;
  bool _disposed = false;

  void setTyping(bool active) {
    if (_disposed) return;
    if (!active) {
      _timer?.cancel();
      _timer = null;
      if (_active) {
        _active = false;
        _send(false);
      }
      return;
    }

    _active = true;
    if (_timer == null) {
      _send(true);
      _scheduleNext();
    }
  }

  void _scheduleNext() {
    _timer = Timer(interval, () {
      _timer = null;
      if (!_active || _disposed) return;
      _send(true);
      _scheduleNext();
    });
  }

  void _send(bool isTyping) {
    unawaited(send(isTyping).catchError((Object _) {}));
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _timer?.cancel();
    _timer = null;
    if (_active) {
      _active = false;
      _send(false);
    }
  }
}
