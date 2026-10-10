import 'dart:async';

import 'package:grpc/grpc.dart' as grpc;

import '../app/connection_status.dart';

class NetworkConnectionManager {
  final StreamController<ConnectionStatus> _updates =
      StreamController<ConnectionStatus>.broadcast(sync: true);

  ConnectionStatus _status = ConnectionStatus.disconnected;
  ConnectionStatus _transportStatus = ConnectionStatus.disconnected;

  ConnectionStatus get status => _status;
  ConnectionStatus get transportStatus => _transportStatus;
  Stream<ConnectionStatus> get updates => _updates.stream;

  ConnectionStatus mapGrpcState(grpc.ConnectionState state) {
    _transportStatus = switch (state) {
      grpc.ConnectionState.connecting => ConnectionStatus.connecting,
      grpc.ConnectionState.ready => ConnectionStatus.connected,
      grpc.ConnectionState.transientFailure => ConnectionStatus.reconnecting,
      grpc.ConnectionState.idle ||
      grpc.ConnectionState.shutdown => ConnectionStatus.disconnected,
    };
    return _transportStatus;
  }

  void publish({
    ConnectionStatus? force,
    required bool isAuthenticating,
    required bool hasSession,
    required bool chatStreamReady,
    bool isSynchronizing = false,
  }) {
    final ConnectionStatus next;
    if (force != null) {
      next = force;
    } else if (isAuthenticating) {
      next = ConnectionStatus.authenticating;
    } else if (_transportStatus != ConnectionStatus.connected) {
      next =
          hasSession ||
              _transportStatus == ConnectionStatus.connecting ||
              _transportStatus == ConnectionStatus.reconnecting
          ? _transportStatus
          : ConnectionStatus.disconnected;
    } else if (!hasSession) {
      next = ConnectionStatus.connected;
    } else if (isSynchronizing) {
      next = ConnectionStatus.synchronizing;
    } else if (chatStreamReady) {
      next = ConnectionStatus.connected;
    } else {
      next = ConnectionStatus.synchronizing;
    }
    if (_status == next) return;
    _status = next;
    if (!_updates.isClosed) {
      _updates.add(next);
    }
  }

  void resetTransport() {
    _transportStatus = ConnectionStatus.disconnected;
  }

  Future<void> close() async {
    await _updates.close();
  }
}
