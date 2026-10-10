import 'dart:async';
import 'dart:developer' as developer;
import 'package:tureon/core/storage/chat_store.dart';
import 'package:tureon/core/storage/message_records.dart';
import 'package:tureon/core/crypto/secret_chat_crypto_port.dart';
import 'package:tureon/generated/proto/tureon.pb.dart' as pb;
import 'chat_ack_queue.dart';
import 'chat_inbound_stream_handler.dart';
import 'chat_mutation_delivery_handler.dart';
import 'chat_outbox_processor.dart';
import 'chat_secret_outbox_preparer.dart';
import 'chat_delivery_router.dart';
import 'messaging_rpc.dart';

/// Owns one authenticated stream, readiness, reconnect coalescing and backpressure.
class ChatStreamCoordinator {
  ChatStreamCoordinator({
    required this.rpc,
    required this.store,
    required this.ackQueue,
    required this.inbound,
    required this.mutations,
    required this.outbox,
    required this.secretPreparer,
    required this.deliveryRouter,
    required this.secretCrypto,
    required this.maxConcurrentDeliveryHandlers,
    required this.streamHandshakeTimeout,
    this.onStreamFailure,
    this.onCloseMedia,
  });
  final MessagingRpc rpc;
  final ChatStore store;
  final ChatAckQueue ackQueue;
  final ChatInboundStreamHandler inbound;
  final ChatMutationDeliveryHandler mutations;
  final ChatOutboxProcessor outbox;
  final ChatSecretOutboxPreparer secretPreparer;
  final ChatDeliveryRouter deliveryRouter;
  final SecretChatCryptoPort? Function() secretCrypto;
  final int maxConcurrentDeliveryHandlers;
  final Duration streamHandshakeTimeout;
  final void Function()? onStreamFailure;
  final void Function()? onCloseMedia;
  bool get isStopped => _syncStopped;
  Stream<bool> get readinessChanges => _streamReadinessController.stream;
  late final StreamSubscription<bool> _readinessSubscription;

  final Map<String, int> _lastRoomSequences = {};
  final Set<String> _roomReplayRequested = {};
  final StreamController<bool> _streamReadinessController =
      StreamController<bool>.broadcast(sync: true);
  StreamSubscription<pb.MessageDelivery>? _subscription;
  Timer? _streamHandshakeTimer;
  Future<void>? _streamStartInFlight;
  Future<void>? _reconnectInFlight;
  bool _reconnectRequestedWhileInFlight = false;
  int _streamGeneration = 0;
  int _activeDeliveryHandlers = 0;
  bool _deliveryPaused = false;
  UserSession? _streamSession;
  bool _hasStartedSync = false;
  bool _syncStopped = false;

  void listenToReadiness() {
    _readinessSubscription = rpc.readinessChanges.listen((ready) {
      if (ready) {
        _streamHandshakeTimer?.cancel();
        _streamHandshakeTimer = null;
        final session = store.loadSession();
        final crypto = secretCrypto();
        if (session != null && crypto != null && !_syncStopped) {
          unawaited(
            secretPreparer.recover(session).catchError((Object error) {
              developer.log(
                'Could not resume secret media preparation',
                name: 'tureon.messaging',
                error: error,
              );
            }),
          );
        }
        unawaited(
          ackQueue.flushAcknowledgements().catchError((
            Object error,
            StackTrace stackTrace,
          ) {
            developer.log(
              'Could not resume delivery acknowledgement queue',
              name: 'tureon.messaging',
              error: error,
              stackTrace: stackTrace,
            );
          }),
        );
        outbox.scheduleOutboxWorker();
      } else {
        outbox.stop();
        final session = store.loadSession();
        if (!_syncStopped && session != null) {
          store.resetSendingOutbox(session.userId);
          outbox.scheduleExpirationChecks();
        }
      }
      if (!_streamReadinessController.isClosed) {
        _streamReadinessController.add(ready);
      }
    });
  }

  Future<void> startSync() async {
    final session = store.loadSession();
    if (session == null) {
      await stopSync();
      return;
    }
    final activeSession = _streamSession;
    if (activeSession != null &&
        (activeSession.userId != session.userId ||
            activeSession.deviceId != session.deviceId)) {
      await stopSync();
    }
    final wasStopped = _syncStopped || !_hasStartedSync;
    _hasStartedSync = true;
    _syncStopped = false;
    ackQueue.start();
    if (wasStopped) {
      outbox.incrementGeneration();
      store.reassignNormalOutbox(session.userId, session.deviceId);
      store.resetSendingOutbox(session.userId);
    }
    await secretPreparer.recover(session);
    await _startStream(session);
    outbox.scheduleExpirationChecks();
    if (rpc.isReady) outbox.scheduleOutboxWorker();
  }

  Future<void> stopSync() async {
    _syncStopped = true;
    _reconnectRequestedWhileInFlight = false;
    _streamGeneration++;
    final reconnect = _reconnectInFlight;
    if (reconnect != null) await reconnect;
    _lastRoomSequences.clear();
    _roomReplayRequested.clear();
    _streamHandshakeTimer?.cancel();
    _streamHandshakeTimer = null;
    inbound.stop();
    mutations.clearDeferred();
    ackQueue.stop();
    outbox.stop();
    await _subscription?.cancel();
    _subscription = null;
    _deliveryPaused = false;
    _streamSession = null;
    if (rpc.isReady) outbox.stop();
    if (!_streamReadinessController.isClosed) {
      _streamReadinessController.add(false);
    }
  }

  Future<void> close() async {
    await stopSync();
    await _readinessSubscription.cancel();
    onCloseMedia?.call();
    await rpc.close();
    await _streamReadinessController.close();
  }

  Future<void> _startStream(UserSession session) {
    if (_syncStopped || _subscription != null) return Future<void>.value();
    final pending = _streamStartInFlight;
    if (pending != null) {
      return pending.then((_) async {
        // An old device activation can still be finishing resetStream after
        // sign-out. Its completion does not mean this device opened a stream.
        if (isCurrentSession(session) && _subscription == null) {
          await _startStream(session);
        }
      });
    }
    late final Future<void> start;
    start = _openStream(session).whenComplete(() {
      if (identical(_streamStartInFlight, start)) {
        _streamStartInFlight = null;
      }
    });
    _streamStartInFlight = start;
    return start;
  }

  Future<void> _openStream(UserSession session) async {
    final generation = ++_streamGeneration;
    _streamSession = session;
    await rpc.resetStream();
    if (_syncStopped || generation != _streamGeneration) return;
    _deliveryPaused = false;
    _subscription = rpc
        .streamMessages(
          pb.ChatStreamOpen(
            recipientId: session.userId,
            deviceId: session.deviceId,
          ),
        )
        .listen(
          (delivery) async {
            if (_syncStopped || generation != _streamGeneration) return;
            _activeDeliveryHandlers++;
            if (_activeDeliveryHandlers >= maxConcurrentDeliveryHandlers &&
                !_deliveryPaused) {
              _deliveryPaused = true;
              _subscription?.pause();
            }
            try {
              await deliveryRouter.handle(delivery, session);
            } finally {
              _activeDeliveryHandlers--;
              if (_activeDeliveryHandlers <=
                      maxConcurrentDeliveryHandlers ~/ 2 &&
                  !_syncStopped &&
                  _deliveryPaused) {
                // Old handlers can finish after reconnect. They must release
                // pressure on the current stream, rather than a cancelled one.
                _deliveryPaused = false;
                _subscription?.resume();
              }
            }
          },
          onError: (Object error, StackTrace stackTrace) {
            _handleStreamFailure(error, stackTrace, generation);
          },
          onDone: () => _handleStreamFailure(
            StateError('Message delivery stream closed.'),
            StackTrace.current,
            generation,
          ),
          cancelOnError: true,
        );
    if (!rpc.isReady) {
      _streamHandshakeTimer?.cancel();
      _streamHandshakeTimer = Timer(streamHandshakeTimeout, () {
        _streamHandshakeTimer = null;
        if (_syncStopped || generation != _streamGeneration || rpc.isReady) {
          return;
        }
        final subscription = _subscription;
        _subscription = null;
        unawaited(subscription?.cancel());
        _handleStreamFailure(
          TimeoutException(
            'Chat stream did not complete its ready handshake.',
            streamHandshakeTimeout,
          ),
          StackTrace.current,
          generation,
        );
      });
    }
  }

  Future<void> reconnect() {
    if (_syncStopped) return Future<void>.value();
    final running = _reconnectInFlight;
    if (running != null) {
      _reconnectRequestedWhileInFlight = true;
      return running;
    }
    late final Future<void> reconnect;
    reconnect = _reconnectOnce().whenComplete(() {
      if (identical(_reconnectInFlight, reconnect)) {
        _reconnectInFlight = null;
        if (_reconnectRequestedWhileInFlight && !_syncStopped) {
          _reconnectRequestedWhileInFlight = false;
          unawaited(this.reconnect());
        }
      }
    });
    _reconnectInFlight = reconnect;
    return reconnect;
  }

  Future<void> _reconnectOnce() async {
    final starting = _streamStartInFlight;
    if (starting != null) {
      try {
        await starting;
      } catch (error, stackTrace) {
        developer.log(
          'Initial chat stream start failed before reconnect; retrying it',
          name: 'tureon.messaging',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }
    if (_syncStopped) return;
    _roomReplayRequested.clear();
    _streamGeneration++;
    _streamHandshakeTimer?.cancel();
    _streamHandshakeTimer = null;
    final subscription = _subscription;
    _subscription = null;
    await subscription?.cancel();
    if (_syncStopped) return;
    final session = store.loadSession();
    if (session != null) {
      store.resetSendingOutbox(session.userId);
      await secretPreparer.recover(session);
      await _startStream(session);
    }
  }

  bool isCurrentSession(UserSession session) {
    final activeSession = store.loadSession();
    return !_syncStopped &&
        activeSession?.userId == session.userId &&
        activeSession?.deviceId == session.deviceId;
  }

  void observeRoomSequence(pb.MessageDelivery delivery) {
    final sequence = delivery.roomSequence.toInt();
    if (sequence <= 0) return;
    final roomId = delivery.roomId.isNotEmpty
        ? delivery.roomId
        : delivery.chatId;
    if (roomId.isEmpty) return;
    final previous = _lastRoomSequences[roomId];
    if (previous != null) {
      if (sequence <= previous) return;
      if (sequence > previous + 1) {
        if (_roomReplayRequested.add(roomId)) {
          developer.log(
            'Detected a room delivery sequence gap; requesting cursor replay',
            name: 'tureon.messaging',
            error: 'room=$roomId expected=${previous + 1} received=$sequence',
          );
          onStreamFailure?.call();
        }
        return;
      }
    }
    if (previous == null && _lastRoomSequences.length >= 4096) {
      final evictedRoomId = _lastRoomSequences.keys.first;
      _lastRoomSequences.remove(evictedRoomId);
      _roomReplayRequested.remove(evictedRoomId);
    }
    _lastRoomSequences[roomId] = sequence;
    _roomReplayRequested.remove(roomId);
  }

  void _handleStreamFailure(
    Object error,
    StackTrace stackTrace,
    int generation,
  ) {
    if (generation != _streamGeneration) return;
    _streamGeneration++;
    _subscription = null;
    _streamHandshakeTimer?.cancel();
    _streamHandshakeTimer = null;
    if (_syncStopped) return;
    developer.log(
      'Message delivery stream failed',
      error: error,
      stackTrace: stackTrace,
    );
    onStreamFailure?.call();
  }
}
