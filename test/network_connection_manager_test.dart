import 'package:flutter_test/flutter_test.dart';
import 'package:grpc/grpc.dart' as grpc;
import 'package:tureon/core/app/connection_status.dart';
import 'package:tureon/core/network/network_connection_manager.dart';

void main() {
  group('NetworkConnectionManager without a local session', () {
    late NetworkConnectionManager manager;

    setUp(() => manager = NetworkConnectionManager());
    tearDown(() => manager.close());

    test('shows connecting while the gRPC transport connects', () {
      manager.mapGrpcState(grpc.ConnectionState.connecting);
      manager.publish(
        isAuthenticating: false,
        hasSession: false,
        chatStreamReady: false,
      );

      expect(manager.status, ConnectionStatus.connecting);
    });

    test('shows connected when the server is reachable before login', () {
      manager.mapGrpcState(grpc.ConnectionState.ready);
      manager.publish(
        isAuthenticating: false,
        hasSession: false,
        chatStreamReady: false,
      );

      expect(manager.status, ConnectionStatus.connected);
    });

    test('shows reconnecting while the transport recovers', () {
      manager.mapGrpcState(grpc.ConnectionState.ready);
      manager.publish(
        isAuthenticating: false,
        hasSession: false,
        chatStreamReady: false,
      );
      manager.mapGrpcState(grpc.ConnectionState.transientFailure);
      manager.publish(
        isAuthenticating: false,
        hasSession: false,
        chatStreamReady: false,
      );

      expect(manager.status, ConnectionStatus.reconnecting);
    });
  });
}
