import 'dart:async';
import 'dart:developer' as developer;

import 'package:tureon/generated/proto/tureon.pb.dart' as pb;
import 'messaging_rpc.dart';

class QueuedDeliveryAcknowledgement {
  const QueuedDeliveryAcknowledgement({
    required this.acknowledgement,
    required this.completer,
    this.attempts = 0,
  });

  final pb.DeliveryAcknowledgement acknowledgement;
  final Completer<void> completer;
  final int attempts;
}

class ChatAckQueue {
  ChatAckQueue({
    required this.rpc,
    required this.ackBatchWindow,
    this.maxAcknowledgementsPerRpc = 256,
    this.maxPendingAcknowledgements = 4096,
  }) {
    if (maxAcknowledgementsPerRpc < 1 ||
        maxPendingAcknowledgements < maxAcknowledgementsPerRpc ||
        ackBatchWindow < Duration.zero) {
      throw ArgumentError('ACK batch limits and window must not be negative.');
    }
  }

  final MessagingRpc rpc;
  final Duration ackBatchWindow;
  final int maxAcknowledgementsPerRpc;
  final int maxPendingAcknowledgements;

  final List<QueuedDeliveryAcknowledgement> _pendingAcknowledgements = [];
  final Map<String, QueuedDeliveryAcknowledgement> _queuedByDeliveryId = {};
  Timer? _ackBatchTimer;
  Timer? _retryTimer;
  Future<void> _acknowledgementQueue = Future<void>.value();
  bool _stopped = false;
  int _generation = 0;

  void start() {
    if (!_stopped) return;
    _generation++;
    _stopped = false;
  }

  void stop() {
    _stopped = true;
    _generation++;
    _ackBatchTimer?.cancel();
    _ackBatchTimer = null;
    _retryTimer?.cancel();
    _retryTimer = null;
    for (final queued in _queuedByDeliveryId.values) {
      if (!queued.completer.isCompleted) {
        queued.completer.completeError(
          StateError('Message synchronization stopped before ACK delivery.'),
        );
      }
    }
    _pendingAcknowledgements.clear();
    _queuedByDeliveryId.clear();
  }

  Future<void> queueAcknowledgement(pb.MessageDelivery delivery) {
    if (_stopped) {
      return Future<void>.error(
        StateError('Message synchronization stopped before ACK delivery.'),
      );
    }
    final completer = Completer<void>();
    final acknowledgement = pb.DeliveryAcknowledgement(
      deliveryId: delivery.deliveryId,
      targetDeviceId: delivery.targetDeviceId,
    );
    final existing = _queuedByDeliveryId[delivery.deliveryId];
    if (existing != null) return existing.completer.future;
    if (_queuedByDeliveryId.length >= maxPendingAcknowledgements) {
      // The inbound handler has already persisted this delivery locally. Do not
      // ACK it under pressure; the server will replay it after reconnect and
      // the local message write is idempotent.
      return Future<void>.error(
        StateError('The bounded delivery ACK queue is full.'),
      );
    }
    final queued = QueuedDeliveryAcknowledgement(
      acknowledgement: acknowledgement,
      completer: completer,
    );
    _queuedByDeliveryId[delivery.deliveryId] = queued;
    _pendingAcknowledgements.add(queued);
    if (ackBatchWindow == Duration.zero ||
        _pendingAcknowledgements.length >= maxAcknowledgementsPerRpc) {
      _ackBatchTimer?.cancel();
      _ackBatchTimer = null;
      _flushInBackground();
    } else {
      _ackBatchTimer ??= Timer(ackBatchWindow, () {
        _ackBatchTimer = null;
        _flushInBackground();
      });
    }
    return completer.future;
  }

  /// Call only after the delivery has been committed locally. Waiting for the
  /// ACK here would deadlock when delivery backpressure pauses the same stream
  /// that carries the command response.
  void acknowledgePersisted(pb.MessageDelivery delivery) {
    unawaited(
      queueAcknowledgement(delivery).catchError((
        Object error,
        StackTrace stackTrace,
      ) {
        developer.log(
          'Persisted delivery remains unacknowledged for server replay',
          name: 'tureon.messaging',
          error: error,
          stackTrace: stackTrace,
        );
      }),
    );
  }

  Future<void> flushAcknowledgements() {
    if (_stopped) return Future<void>.value();
    if (_pendingAcknowledgements.isEmpty) return Future<void>.value();
    _retryTimer?.cancel();
    _retryTimer = null;
    if (!rpc.isReady) {
      // Keep the durable delivery pending locally until a replacement stream
      // completes its ready handshake. Sending during teardown only creates
      // avoidable "stream stopped" errors and delays the next retry.
      return Future<void>.value();
    }
    final pending = List<QueuedDeliveryAcknowledgement>.of(
      _pendingAcknowledgements,
    );
    _pendingAcknowledgements.clear();
    final generation = _generation;
    final operation = _acknowledgementQueue.then((_) async {
      for (
        var offset = 0;
        offset < pending.length;
        offset += maxAcknowledgementsPerRpc
      ) {
        // stop/start can change the account while an earlier RPC is in flight.
        // Never send a captured batch on a replacement account's stream.
        if (_stopped || generation != _generation) return;
        final chunk = pending.skip(offset).take(maxAcknowledgementsPerRpc);
        try {
          await rpc.ackDeliveries([
            for (final queued in chunk) queued.acknowledgement,
          ]);
          for (final queued in chunk) {
            if (identical(
              _queuedByDeliveryId[queued.acknowledgement.deliveryId],
              queued,
            )) {
              _queuedByDeliveryId.remove(queued.acknowledgement.deliveryId);
            }
            if (!queued.completer.isCompleted) queued.completer.complete();
          }
        } catch (error, stackTrace) {
          developer.log(
            'Failed to acknowledge a batch of message deliveries',
            error: error,
            stackTrace: stackTrace,
          );
          if (!_stopped && generation == _generation) {
            for (final queued in chunk) {
              if (identical(
                _queuedByDeliveryId[queued.acknowledgement.deliveryId],
                queued,
              )) {
                final retry = QueuedDeliveryAcknowledgement(
                  acknowledgement: queued.acknowledgement,
                  completer: queued.completer,
                  attempts: queued.attempts + 1,
                );
                _queuedByDeliveryId[queued.acknowledgement.deliveryId] = retry;
                _pendingAcknowledgements.add(retry);
              }
            }
            if (rpc.isReady) _scheduleRetry();
          } else {
            for (final queued in chunk) {
              if (identical(
                _queuedByDeliveryId[queued.acknowledgement.deliveryId],
                queued,
              )) {
                _queuedByDeliveryId.remove(queued.acknowledgement.deliveryId);
              }
              if (!queued.completer.isCompleted) {
                queued.completer.completeError(error, stackTrace);
              }
            }
          }
        }
      }
    });
    _acknowledgementQueue = operation;
    return operation;
  }

  void _flushInBackground() {
    unawaited(
      flushAcknowledgements().catchError((Object error, StackTrace stackTrace) {
        developer.log(
          'Unexpected failure while flushing delivery acknowledgements',
          error: error,
          stackTrace: stackTrace,
        );
      }),
    );
  }

  void _scheduleRetry() {
    if (_stopped || _retryTimer != null || _pendingAcknowledgements.isEmpty) {
      return;
    }
    final attempts = _pendingAcknowledgements
        .map((queued) => queued.attempts)
        .reduce((left, right) => left > right ? left : right);
    final exponent = (attempts - 1).clamp(0, 6).toInt();
    final delay = Duration(
      milliseconds: (500 * (1 << exponent)).clamp(500, 30000),
    );
    _retryTimer = Timer(delay, () {
      _retryTimer = null;
      _flushInBackground();
    });
  }
}
