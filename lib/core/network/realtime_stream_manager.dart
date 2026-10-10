import 'dart:async';
import 'dart:developer' as developer;

import 'package:connectivity_plus/connectivity_plus.dart';

class RealtimeStreamManager {
  RealtimeStreamManager({
    required this._reconnectAll,
    this.retryBaseDelay = const Duration(seconds: 1),
    this.retryMaxDelay = const Duration(seconds: 32),
    Connectivity? connectivity,
    Stream<List<ConnectivityResult>>? connectivityChanges,
  }) : _connectivityChanges =
           connectivityChanges ??
           (connectivity ?? Connectivity()).onConnectivityChanged {
    if (retryBaseDelay <= Duration.zero || retryMaxDelay < retryBaseDelay) {
      throw ArgumentError(
        'Realtime retry delays must be positive and ordered.',
      );
    }
  }

  final Future<void> Function() _reconnectAll;
  final Duration retryBaseDelay;
  final Duration retryMaxDelay;
  final Stream<List<ConnectivityResult>> _connectivityChanges;

  Timer? _retryTimer;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Future<void>? _reconnectInFlight;
  int _retryAttempt = 0;
  bool _active = false;
  bool _reconnectRequestedWhileInFlight = false;
  String? _lastRoute;

  void start() {
    if (_active) return;
    _active = true;
    _reconnectRequestedWhileInFlight = false;
    _lastRoute = null;
    _connectivitySubscription = _connectivityChanges.listen(
      _handleConnectivityChange,
      onError: (Object error, StackTrace stackTrace) {
        developer.log(
          'Network route monitoring failed',
          name: 'tureon.connection',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );
  }

  Future<void> onConnectionReady() {
    if (!_active) return Future<void>.value();
    _retryTimer?.cancel();
    _retryTimer = null;
    _retryAttempt = 0;
    return _reconnect();
  }

  Future<void> onNetworkChanged() {
    if (!_active) return Future<void>.value();
    _retryTimer?.cancel();
    _retryTimer = null;
    _retryAttempt = 0;
    return _reconnect();
  }

  void requestReconnect() {
    if (!_active || _retryTimer != null) return;
    final exponent = _retryAttempt.clamp(0, 20).toInt();
    final multiplier = 1 << exponent;
    final delay = Duration(
      milliseconds: (retryBaseDelay.inMilliseconds * multiplier).clamp(
        1,
        retryMaxDelay.inMilliseconds,
      ),
    );
    _retryAttempt++;
    _retryTimer = Timer(delay, () {
      _retryTimer = null;
      if (_active) unawaited(_reconnect());
    });
  }

  Future<void> stop() async {
    _active = false;
    _reconnectRequestedWhileInFlight = false;
    _retryTimer?.cancel();
    _retryTimer = null;
    final connectivitySubscription = _connectivitySubscription;
    _connectivitySubscription = null;
    _lastRoute = null;
    await connectivitySubscription?.cancel();
    await _reconnectInFlight;
  }

  void _handleConnectivityChange(List<ConnectivityResult> results) {
    final route = results.map((result) => result.name).toSet().toList()..sort();
    final signature = route.join(',');
    final previous = _lastRoute;
    _lastRoute = signature;
    if (previous != null && previous != signature) {
      unawaited(onNetworkChanged());
    }
  }

  Future<void> _reconnect() {
    if (!_active) return Future<void>.value();
    final current = _reconnectInFlight;
    if (current != null) {
      _reconnectRequestedWhileInFlight = true;
      return current;
    }

    late final Future<void> reconnect;
    reconnect = _reconnectAll()
        .catchError((Object error, StackTrace stackTrace) {
          developer.log(
            'Coordinated realtime stream reconnection failed',
            name: 'tureon.realtime',
            error: error,
            stackTrace: stackTrace,
          );
          requestReconnect();
        })
        .whenComplete(() {
          if (identical(_reconnectInFlight, reconnect)) {
            _reconnectInFlight = null;
            if (_active && _reconnectRequestedWhileInFlight) {
              _reconnectRequestedWhileInFlight = false;
              unawaited(_reconnect());
            }
          }
        });
    _reconnectInFlight = reconnect;
    return reconnect;
  }
}
