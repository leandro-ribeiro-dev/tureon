import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:grpc/grpc.dart';

import '../../../../core/storage/message_records.dart';
import '../../data/auth_session_validator.dart';
import '../../data/google_auth_data_source.dart';
import '../../domain/auth_gateway.dart';

class AuthController extends ValueNotifier<AuthState> {
  AuthController({
    required this.gateway,
    required this.google,
    required this.refreshTokens,
    required this.savedSession,
    required this.persistSession,
  }) : super(
         AuthState(
           status: savedSession == null
               ? AuthStatus.unauthenticated
               : _localStatus(savedSession),
           session: savedSession,
         ),
       );

  AuthState get state => value;
  set state(AuthState newState) => value = newState;

  AuthState get currentState => value;

  final AuthGateway gateway;
  final GoogleAuthDataSource google;
  final RefreshTokenStore refreshTokens;
  final UserSession? savedSession;
  final Future<void> Function(UserSession?) persistSession;
  UserSession? _session;
  bool _restoreShouldRetryWhenReachable = false;
  Future<void>? _restoreOperation;
  Future<void> _operationTail = Future<void>.value();
  bool _signInInFlight = false;
  bool _usernameSetupInFlight = false;

  static AuthStatus _localStatus(UserSession session) =>
      switch (session.accountStatus) {
        'banned' || 'suspended' => AuthStatus.restricted,
        _ when session.needsUsername => AuthStatus.needsUsername,
        _ => AuthStatus.offline,
      };

  VoidCallback listen(void Function(AuthState state) listener) {
    void callback() => listener(value);
    super.addListener(callback);
    return () => removeListener(callback);
  }

  Future<void> restore({bool serverReachable = false}) {
    final running = _restoreOperation;
    if (running != null) return running;

    late final Future<void> operation;
    operation =
        _serialize(() async {
          final saved = savedSession;
          if (saved != null) {
            // The local session is enough to show this device's cached data.
            // Refresh it in the background without sending the user back to login.
            state = _stateFromLocalSession(saved);
            _restoreShouldRetryWhenReachable = true;
          }

          UserSession? refreshedSession;
          try {
            final refreshToken = await refreshTokens.read();
            if (saved == null) {
              if (refreshToken != null && refreshToken.isNotEmpty) {
                await _clearSession();
              }
              return;
            }
            if (refreshToken == null || refreshToken.isEmpty) {
              if (serverReachable) {
                _restoreShouldRetryWhenReachable = false;
                await _clearSession(
                  error: 'Sua sessão expirou. Entre novamente.',
                );
              }
              return;
            }
            refreshedSession = await gateway.refresh(
              refreshToken,
              saved.deviceId,
            );
          } catch (error) {
            if (saved != null &&
                state.status == AuthStatus.unauthenticated &&
                _session == null) {
              _restoreShouldRetryWhenReachable = false;
              state = AuthState(
                status: AuthStatus.unauthenticated,
                error: error.toString(),
              );
            } else if (_isTerminalSessionFailure(error)) {
              _restoreShouldRetryWhenReachable = false;
              try {
                await _clearSession(
                  error: error is InvalidAuthSessionException
                      ? error.toString()
                      : 'Sua sessão expirou. Entre novamente.',
                );
              } catch (cleanupError) {
                state = AuthState(
                  status: AuthStatus.unauthenticated,
                  error: '$error; local session cleanup failed: $cleanupError',
                );
              }
            } else if (saved == null) {
              state = AuthState(
                status: AuthStatus.unauthenticated,
                error: error.toString(),
              );
            } else {
              // Network and temporary server failures keep the last signed-in
              // account available from SQLite. A ready transport retries refresh.
              _restoreShouldRetryWhenReachable = true;
              state = _stateFromLocalSession(saved);
            }
            return;
          }

          try {
            await _accept(refreshedSession);
            _restoreShouldRetryWhenReachable = false;
          } catch (error) {
            _restoreShouldRetryWhenReachable = false;
            try {
              await _clearSession(error: error.toString());
            } catch (cleanupError) {
              state = AuthState(
                status: AuthStatus.unauthenticated,
                error: '$error; local session cleanup failed: $cleanupError',
              );
            }
          }
        }).whenComplete(() {
          if (identical(_restoreOperation, operation)) {
            _restoreOperation = null;
          }
        });
    _restoreOperation = operation;
    return operation;
  }

  Future<void> retryRestoreWhenReachable() async {
    final inFlight = _restoreOperation;
    if (inFlight != null) await inFlight;
    if (!_restoreShouldRetryWhenReachable ||
        !{
          AuthStatus.offline,
          AuthStatus.needsUsername,
          AuthStatus.restricted,
        }.contains(state.status)) {
      return;
    }
    await restore(serverReachable: true);
  }

  Future<void> refreshCurrentSession() => _serialize(() async {
    final session = state.session ?? _session ?? savedSession;
    if (session == null) return;
    final refreshToken = await refreshTokens.read();
    if (refreshToken == null || refreshToken.isEmpty) {
      await _clearSession(error: 'Sua sessão expirou. Entre novamente.');
      return;
    }
    try {
      final refreshed = await gateway.refresh(refreshToken, session.deviceId);
      await _accept(refreshed);
    } catch (error) {
      if (!_isTerminalSessionFailure(error)) rethrow;
      await _clearSession(error: 'Sua sessão foi encerrada neste dispositivo.');
      await google.signOut();
    }
  });

  AuthState _stateFromLocalSession(UserSession session) {
    return AuthState(status: _localStatus(session), session: session);
  }

  Future<void> signInWithGoogle() {
    if (_signInInFlight || state.status != AuthStatus.unauthenticated) {
      return Future<void>.value();
    }
    _signInInFlight = true;
    return _signIn((deviceId) async {
      final idToken = await google.authenticate();
      if (idToken == null) return null;
      return gateway.loginWithGoogle(idToken, deviceId: deviceId);
    }).whenComplete(() => _signInInFlight = false);
  }

  Future<void> _signIn(
    Future<UserSession?> Function(String? deviceId) authenticate,
  ) => _serialize(() async {
    state = const AuthState(status: AuthStatus.authenticating);
    try {
      final session = await authenticate(savedSession?.deviceId);
      if (session == null) {
        state = const AuthState(status: AuthStatus.unauthenticated);
        return;
      }
      await _accept(session);
    } catch (error) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        error: error.toString(),
      );
    }
  });

  Future<void> chooseUsername(String username) {
    if (_usernameSetupInFlight ||
        state.status != AuthStatus.needsUsername ||
        state.session == null ||
        username.trim().isEmpty) {
      return Future<void>.value();
    }
    _usernameSetupInFlight = true;
    return _serialize(() async {
      final pendingSession = state.session;
      if (state.status != AuthStatus.needsUsername || pendingSession == null) {
        return;
      }
      late final UserSession session;
      try {
        session = await gateway.setUsername(username.trim());
      } catch (error) {
        state = AuthState(
          status: AuthStatus.needsUsername,
          session: pendingSession,
          usernameError: error.toString(),
        );
        return;
      }
      try {
        await _accept(session);
      } catch (error) {
        state = AuthState(
          status: AuthStatus.unauthenticated,
          error: error.toString(),
        );
      }
    }).whenComplete(() => _usernameSetupInFlight = false);
  }

  Future<void> signOut() => _serialize(() async {
    final session = state.session ?? _session ?? savedSession;
    final failures = <Object>[];
    if (session != null) {
      try {
        await gateway.logout(session.deviceId);
      } catch (error) {
        failures.add(error);
      }
    }
    try {
      await _clearSession();
    } catch (error) {
      failures.add(error);
    }
    try {
      await google.signOut();
    } catch (error) {
      failures.add(error);
    }
    if (failures.isNotEmpty) {
      throw StateError(
        'Sign-out completed locally with cleanup failures: '
        '${failures.join('; ')}',
      );
    }
  });

  Future<void> expireSession() => _serialize(() async {
    await _clearSession();
    await google.signOut();
  });

  Future<void> _accept(UserSession session) async {
    session = validateAuthSession(session);
    _restoreShouldRetryWhenReachable = false;
    _session = session;
    try {
      await refreshTokens.write(session.refreshToken);
      await persistSession(session);
    } catch (error) {
      _session = null;
      final cleanupFailures = <Object>[];
      try {
        await refreshTokens.clear();
      } catch (cleanupError) {
        cleanupFailures.add(cleanupError);
      }
      try {
        await persistSession(null);
      } catch (cleanupError) {
        cleanupFailures.add(cleanupError);
      }
      if (cleanupFailures.isNotEmpty) {
        throw StateError(
          'Session initialization failed: $error; rollback failed: '
          '${cleanupFailures.join('; ')}',
        );
      }
      rethrow;
    }
    final authStatus = switch (session.accountStatus) {
      'active' =>
        session.needsUsername
            ? AuthStatus.needsUsername
            : AuthStatus.authenticated,
      'under_review' =>
        session.needsUsername
            ? AuthStatus.needsUsername
            : AuthStatus.authenticated,
      'banned' || 'suspended' => AuthStatus.restricted,
      _ => AuthStatus.authenticated,
    };
    state = AuthState(status: authStatus, session: session);
  }

  Future<void> _clearSession({String? error}) async {
    _session = null;
    _restoreShouldRetryWhenReachable = false;
    Object? tokenClearFailure;
    Object? persistedSessionFailure;
    try {
      await refreshTokens.clear();
    } catch (failure) {
      tokenClearFailure = failure;
    }
    try {
      await persistSession(null);
    } catch (failure) {
      persistedSessionFailure = failure;
    }
    final cleanupFailures = [?tokenClearFailure, ?persistedSessionFailure];
    state = AuthState(
      status: AuthStatus.unauthenticated,
      error:
          error ??
          (cleanupFailures.isEmpty ? null : cleanupFailures.join('; ')),
    );
    if (cleanupFailures.isNotEmpty) {
      throw StateError('Session cleanup failed: ${cleanupFailures.join('; ')}');
    }
  }

  bool _isTerminalSessionFailure(Object error) =>
      error is InvalidAuthSessionException ||
      error is GrpcError &&
          {
            StatusCode.unauthenticated,
            StatusCode.permissionDenied,
            StatusCode.notFound,
          }.contains(error.code);

  Future<T> _serialize<T>(Future<T> Function() operation) {
    final completer = Completer<T>();
    final previous = _operationTail;
    final release = Completer<void>();
    _operationTail = release.future;
    () async {
      await previous;
      try {
        completer.complete(await operation());
      } catch (error, stackTrace) {
        completer.completeError(error, stackTrace);
      } finally {
        release.complete();
      }
    }();
    return completer.future;
  }
}
