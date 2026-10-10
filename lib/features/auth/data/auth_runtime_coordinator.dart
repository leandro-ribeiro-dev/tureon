import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

import '../../../core/network/grpc_client.dart';
import '../../../core/storage/local_store.dart';
import '../../../core/storage/message_records.dart';
import 'auth_gateway.dart';
import 'google_auth_data_source.dart';
import 'grpc_auth_gateway.dart';
import '../presentation/auth_controller.dart';

class AuthRuntimeCoordinator {
  AuthRuntimeCoordinator({
    required this.store,
    required this.persistSession,
    required this.onSessionRefreshed,
    required this.onAuthStateChanged,
    required this.onAuthenticationRecoveryChanged,
    required this.onControllerChanged,
  });

  final LocalStore store;
  final Future<void> Function(UserSession? session) persistSession;
  final Future<void> Function(UserSession session) onSessionRefreshed;
  final void Function(AuthState state) onAuthStateChanged;
  final void Function(bool isAuthenticating) onAuthenticationRecoveryChanged;
  final void Function(AuthController? controller) onControllerChanged;

  GrpcClient? _client;
  GrpcAuthGateway? _gateway;
  AuthController? _controller;
  VoidCallback? _removeStateListener;

  AuthController? get controller => _controller;
  AuthState? get currentState => _controller?.currentState;

  void connect(GrpcClient client) {
    _client = client;
    _gateway = GrpcAuthGateway(client.auth);
  }

  Future<void> configure(
    GoogleAuthDataSource google, {
    bool serverReachable = false,
    bool restoreSession = true,
  }) async {
    final client = _client;
    final gateway = _gateway;
    if (client == null || gateway == null) {
      throw StateError('Connect the gRPC client before auth setup.');
    }
    await _disposeController();
    gateway.onSessionChanged = (session) async {
      final activeSession = store.loadSession();
      if (activeSession == null ||
          activeSession.userId != session.userId ||
          activeSession.deviceId != session.deviceId) {
        throw StateError(
          'The authenticated account changed while refreshing the session.',
        );
      }
      await SecureRefreshTokenStore().write(session.refreshToken);
      store.saveSession(session);
      client.setAccessToken(session.accessToken);
      // Publish credentials before notifying data synchronization. A profile
      // request can be awaiting this authentication recovery; awaiting its
      // single-flight refresh here would create a circular dependency.
      unawaited(
        Future<void>.sync(() => onSessionRefreshed(session)).catchError((
          Object error,
          StackTrace stackTrace,
        ) {
          developer.log(
            'Post-refresh synchronization failed',
            name: 'tureon.auth',
            error: error,
            stackTrace: stackTrace,
          );
        }),
      );
    };

    final controller = AuthController(
      gateway: gateway,
      google: google,
      refreshTokens: SecureRefreshTokenStore(),
      savedSession: store.loadSession(),
      persistSession: persistSession,
    );
    _controller = controller;
    _removeStateListener = controller.listen(onAuthStateChanged);
    onAuthStateChanged(controller.currentState);
    client.setAuthenticationRecovery(
      refresh: (failedAccessToken) async {
        onAuthenticationRecoveryChanged(true);
        try {
          await gateway.refreshAfterUnauthenticated(failedAccessToken);
        } finally {
          onAuthenticationRecoveryChanged(false);
        }
      },
      onRefreshFailure: () async {
        await _controller?.expireSession();
      },
    );
    onControllerChanged(controller);
    if (restoreSession) {
      await controller.restore(serverReachable: serverReachable);
    }
  }

  Future<void> restoreSession({bool serverReachable = false}) =>
      _controller?.restore(serverReachable: serverReachable) ??
      Future<void>.value();

  Future<List<DeviceSession>> listDevices() {
    final gateway = _gateway;
    if (gateway == null) throw StateError('Authentication is not connected.');
    return gateway.listDevices();
  }

  Future<void> revokeDevice(String deviceId) {
    final gateway = _gateway;
    if (gateway == null) throw StateError('Authentication is not connected.');
    return gateway.revokeDevice(deviceId);
  }

  Future<void> retrySessionRestoreWhenReachable() =>
      _controller?.retryRestoreWhenReachable() ?? Future<void>.value();

  Future<void> refreshCurrentSession() =>
      _controller?.refreshCurrentSession() ?? Future<void>.value();

  Future<void> disconnect() async {
    await _disposeController();
    _gateway = null;
    _client = null;
  }

  Future<void> _disposeController() async {
    _removeStateListener?.call();
    _removeStateListener = null;
    final controller = _controller;
    _controller = null;
    onControllerChanged(null);
    controller?.dispose();
  }
}
