import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:grpc/grpc.dart';
import 'package:tureon/core/storage/message_records.dart';
import 'package:tureon/features/auth/data/auth_gateway.dart';
import 'package:tureon/features/auth/data/google_auth_data_source.dart';
import 'package:tureon/features/auth/presentation/auth_controller.dart';

void main() {
  test('cached account is visible before any asynchronous restoration', () {
    final gateway = _FakeGateway(loginResult: _session());
    final controller = _controller(gateway: gateway, savedSession: _session());
    addTearDown(controller.dispose);

    expect(controller.state.status, AuthStatus.offline);
    expect(controller.state.session?.userId, 'user-1');
    expect(gateway.refreshedToken, isNull);
  });

  test(
    'deadline at startup recovers with the saved credential when reachable',
    () async {
      final gateway = _FakeGateway(
        loginResult: _session(),
        refreshFailure: GrpcError.deadlineExceeded('slow network'),
      );
      final tokens = _FakeTokenStore('saved-refresh');
      final persisted = <UserSession?>[];
      final controller = _controller(
        gateway: gateway,
        refreshTokens: tokens,
        savedSession: _session(),
        onPersist: persisted.add,
      );
      addTearDown(controller.dispose);

      await controller.restore();
      expect(controller.state.status, AuthStatus.offline);
      expect(tokens.value, 'saved-refresh');
      expect(persisted, isEmpty);

      gateway.refreshFailure = null;
      await controller.retryRestoreWhenReachable();
      expect(gateway.refreshedToken, 'saved-refresh');
      expect(controller.state.status, AuthStatus.authenticated);
      expect(persisted.single?.userId, 'user-1');
    },
  );

  test('Google login routes new accounts to username setup', () async {
    final session = _session(needsUsername: true);
    final gateway = _FakeGateway(loginResult: session);
    final controller = _controller(gateway: gateway);

    await controller.signInWithGoogle();

    expect(controller.state.status, AuthStatus.needsUsername);
    expect(gateway.loginToken, 'fake-google-token');
    expect(controller.state.error, isNull);
  });

  test('username setup completes authentication', () async {
    final gateway = _FakeGateway(
      loginResult: _session(needsUsername: true),
      usernameResult: _session(username: 'tureon_user'),
    );
    final controller = _controller(gateway: gateway);

    await controller.signInWithGoogle();
    await controller.chooseUsername('tureon_user');

    expect(controller.state.status, AuthStatus.authenticated);
    expect(gateway.submittedUsername, 'tureon_user');
  });

  test(
    'username setup ignores calls without a pending authenticated session',
    () async {
      final gateway = _FakeGateway(loginResult: _session(needsUsername: true));
      final controller = _controller(gateway: gateway);

      await controller.chooseUsername('new_user');

      expect(gateway.usernameCalls, 0);
      expect(controller.state.status, AuthStatus.unauthenticated);
    },
  );

  test('parallel username submissions share one server request', () async {
    final usernameCompleter = Completer<UserSession>();
    final gateway = _FakeGateway(
      loginResult: _session(needsUsername: true),
      usernameCompleter: usernameCompleter,
    );
    final controller = _controller(gateway: gateway);

    await controller.signInWithGoogle();
    final first = controller.chooseUsername('new_user');
    final second = controller.chooseUsername('new_user');
    await Future<void>.delayed(Duration.zero);

    expect(gateway.usernameCalls, 1);
    usernameCompleter.complete(_session(username: 'new_user'));
    await Future.wait([first, second]);
    expect(controller.state.status, AuthStatus.authenticated);
  });

  test(
    'Google cancellation leaves the user unauthenticated without error',
    () async {
      final controller = _controller(google: _FakeGoogle(token: null));

      await controller.signInWithGoogle();

      expect(controller.state.status, AuthStatus.unauthenticated);
      expect(controller.state.error, isNull);
    },
  );

  test('suspended accounts enter the restricted state after login', () async {
    final controller = _controller(
      gateway: _FakeGateway(loginResult: _session(accountStatus: 'suspended')),
    );

    await controller.signInWithGoogle();

    expect(controller.state.status, AuthStatus.restricted);
  });

  test('accounts under review can sign in to the app', () async {
    final controller = _controller(
      gateway: _FakeGateway(
        loginResult: _session(accountStatus: 'under_review'),
      ),
    );

    await controller.signInWithGoogle();

    expect(controller.state.status, AuthStatus.authenticated);
  });

  test('temporarily restricted accounts can enter the app', () async {
    final controller = _controller(
      gateway: _FakeGateway(loginResult: _session(accountStatus: 'restricted')),
    );

    await controller.signInWithGoogle();

    expect(controller.state.status, AuthStatus.authenticated);
  });

  test('banned accounts enter the restricted state after login', () async {
    final controller = _controller(
      gateway: _FakeGateway(loginResult: _session(accountStatus: 'banned')),
    );

    await controller.signInWithGoogle();

    expect(controller.state.status, AuthStatus.restricted);
  });

  test('under-review accounts can complete required username setup', () async {
    final controller = _controller(
      gateway: _FakeGateway(
        loginResult: _session(
          needsUsername: true,
          accountStatus: 'under_review',
        ),
      ),
    );

    await controller.signInWithGoogle();

    expect(controller.state.status, AuthStatus.needsUsername);
  });

  test('restricted state takes precedence over username setup', () async {
    final controller = _controller(
      gateway: _FakeGateway(
        loginResult: _session(needsUsername: true, accountStatus: 'suspended'),
      ),
    );

    await controller.signInWithGoogle();

    expect(controller.state.status, AuthStatus.restricted);
  });

  test(
    'startup rotates a stored refresh token and persists the replacement',
    () async {
      final replacement = _session(
        accessToken: 'new-access',
        refreshToken: 'new-refresh',
      );
      final tokens = _FakeTokenStore('old-refresh');
      final gateway = _FakeGateway(
        loginResult: _session(),
        refreshResult: replacement,
      );
      final persisted = <UserSession?>[];
      final controller = _controller(
        gateway: gateway,
        refreshTokens: tokens,
        savedSession: _session(),
        onPersist: persisted.add,
      );

      await controller.restore();

      expect(gateway.refreshedToken, 'old-refresh');
      expect(tokens.value, 'new-refresh');
      expect(persisted.single?.accessToken, 'new-access');
      expect(controller.state.status, AuthStatus.authenticated);
    },
  );

  test(
    'startup exposes the cached account while validating a saved session',
    () async {
      final refresh = Completer<UserSession>();
      final controller = _controller(
        gateway: _FakeGateway(
          loginResult: _session(),
          refreshCompleter: refresh,
        ),
        refreshTokens: _FakeTokenStore('old-refresh'),
        savedSession: _session(),
      );

      final restore = controller.restore();
      await Future<void>.delayed(Duration.zero);
      expect(controller.state.status, AuthStatus.offline);

      refresh.complete(_session());
      await restore;
      expect(controller.state.status, AuthStatus.authenticated);
    },
  );

  test('parallel Google sign-in taps create only one OAuth attempt', () async {
    final google = _FakeGoogle(authenticateCompleter: Completer<String?>());
    final controller = _controller(google: google);

    final firstAttempt = controller.signInWithGoogle();
    final duplicateAttempt = controller.signInWithGoogle();
    await Future<void>.delayed(Duration.zero);

    expect(controller.state.status, AuthStatus.authenticating);
    expect(google.authenticateCalls, 1);

    google.authenticateCompleter!.complete('fake-google-token');
    await Future.wait([firstAttempt, duplicateAttempt]);

    expect(controller.state.status, AuthStatus.authenticated);
    expect(google.authenticateCalls, 1);
  });

  test(
    'transient restore failures preserve the refresh token for retry',
    () async {
      final tokens = _FakeTokenStore('old-refresh');
      final persisted = <UserSession?>[];
      final controller = _controller(
        gateway: _FakeGateway(
          loginResult: _session(),
          refreshFailure: GrpcError.unavailable('offline'),
        ),
        refreshTokens: tokens,
        savedSession: _session(),
        onPersist: persisted.add,
      );

      await controller.restore();

      expect(tokens.value, 'old-refresh');
      expect(persisted, isEmpty);
      expect(controller.state.status, AuthStatus.offline);
      expect(controller.state.error, isNull);
    },
  );

  test('incomplete login responses are rejected before persistence', () async {
    final tokens = _FakeTokenStore(null);
    final persisted = <UserSession?>[];
    final controller = _controller(
      gateway: _FakeGateway(loginResult: _session(accessToken: '')),
      refreshTokens: tokens,
      onPersist: persisted.add,
    );

    await controller.signInWithGoogle();

    expect(controller.state.status, AuthStatus.unauthenticated);
    expect(controller.state.error, contains('access token'));
    expect(tokens.value, isNull);
    expect(persisted, isEmpty);
  });

  test(
    'incomplete refresh responses clear the unusable persisted session',
    () async {
      final tokens = _FakeTokenStore('old-refresh');
      final persisted = <UserSession?>[];
      final controller = _controller(
        gateway: _FakeGateway(
          loginResult: _session(),
          refreshResult: _session(refreshToken: ''),
        ),
        refreshTokens: tokens,
        savedSession: _session(),
        onPersist: persisted.add,
      );

      await controller.restore();

      expect(tokens.value, isNull);
      expect(persisted, [isNull]);
      expect(controller.state.status, AuthStatus.unauthenticated);
      expect(controller.state.error, contains('refresh token'));
    },
  );

  test('missing either persisted session component clears the other', () async {
    final tokens = _FakeTokenStore('orphan-refresh');
    final persisted = <UserSession?>[];
    final controller = _controller(
      refreshTokens: tokens,
      onPersist: persisted.add,
    );

    await controller.restore();

    expect(tokens.value, isNull);
    expect(persisted, [isNull]);
    expect(controller.state.status, AuthStatus.unauthenticated);
  });

  test(
    'sign-out attempts all local cleanup steps after a storage failure',
    () async {
      final tokens = _FakeTokenStore('refresh')
        ..clearFailure = StateError('secure storage unavailable');
      final google = _FakeGoogle();
      final gateway = _FakeGateway(loginResult: _session());
      final persisted = <UserSession?>[];
      final controller = _controller(
        gateway: gateway,
        google: google,
        refreshTokens: tokens,
        savedSession: _session(),
        onPersist: persisted.add,
      );

      await expectLater(controller.signOut(), throwsA(isA<StateError>()));

      expect(gateway.logoutDeviceId, 'device-1');
      expect(persisted, [isNull]);
      expect(google.signOutCalls, 1);
      expect(controller.state.status, AuthStatus.unauthenticated);
    },
  );

  test('five sequential login and logout cycles remain idempotent', () async {
    final tokens = _FakeTokenStore(null);
    final gateway = _FakeGateway(loginResult: _session());
    final persisted = <UserSession?>[];
    final google = _FakeGoogle();
    final controller = _controller(
      gateway: gateway,
      google: google,
      refreshTokens: tokens,
      onPersist: persisted.add,
    );

    for (var index = 0; index < 5; index++) {
      await controller.signInWithGoogle();
      expect(controller.state.status, AuthStatus.authenticated);
      await controller.signOut();
      expect(controller.state.status, AuthStatus.unauthenticated);
      expect(tokens.value, isNull);
    }

    expect(gateway.logoutCalls, 5);
    expect(google.signOutCalls, 5);
    expect(persisted.where((session) => session != null), hasLength(5));
    expect(persisted.where((session) => session == null), hasLength(5));
  });

  test(
    'failed session activation rolls back token and persisted session',
    () async {
      final tokens = _FakeTokenStore(null);
      final persisted = <UserSession?>[];
      final controller = AuthController(
        gateway: _FakeGateway(loginResult: _session()),
        google: _FakeGoogle(),
        refreshTokens: tokens,
        savedSession: null,
        persistSession: (session) async {
          persisted.add(session);
          if (session != null) throw StateError('profile bootstrap failed');
        },
      );

      await controller.signInWithGoogle();

      expect(controller.state.status, AuthStatus.unauthenticated);
      expect(controller.state.error, contains('profile bootstrap failed'));
      expect(tokens.value, isNull);
      expect(persisted, hasLength(2));
      expect(persisted.last, isNull);
    },
  );
}

AuthController _controller({
  AuthGateway? gateway,
  GoogleAuthDataSource? google,
  RefreshTokenStore? refreshTokens,
  UserSession? savedSession,
  void Function(UserSession?)? onPersist,
}) => AuthController(
  gateway: gateway ?? _FakeGateway(loginResult: _session()),
  google: google ?? _FakeGoogle(),
  refreshTokens: refreshTokens ?? _FakeTokenStore(null),
  savedSession: savedSession,
  persistSession: (session) async {
    onPersist?.call(session);
  },
);

UserSession _session({
  String username = '',
  String accessToken = 'access',
  String refreshToken = 'refresh',
  String accountStatus = 'active',
  int signalDeviceId = 1,
  bool needsUsername = false,
}) => UserSession(
  userId: 'user-1',
  accessToken: accessToken,
  refreshToken: refreshToken,
  deviceId: 'device-1',
  signalDeviceId: signalDeviceId,
  username: username,
  accountStatus: accountStatus,
  needsUsername: needsUsername,
);

class _FakeGoogle implements GoogleAuthDataSource {
  _FakeGoogle({this.token = 'fake-google-token', this.authenticateCompleter});

  final String? token;
  final Completer<String?>? authenticateCompleter;
  int authenticateCalls = 0;
  int signOutCalls = 0;

  @override
  Future<void> initialize() async {}

  @override
  Future<String?> authenticate() {
    authenticateCalls++;
    return authenticateCompleter?.future ?? Future<String?>.value(token);
  }

  @override
  Future<void> signOut() async {
    signOutCalls++;
  }
}

class _FakeGateway implements AuthGateway {
  _FakeGateway({
    required this.loginResult,
    this.usernameResult,
    this.refreshResult,
    this.refreshFailure,
    this.refreshCompleter,
    this.usernameCompleter,
  });

  final UserSession loginResult;
  final UserSession? usernameResult;
  final UserSession? refreshResult;
  Object? refreshFailure;
  final Completer<UserSession>? refreshCompleter;
  final Completer<UserSession>? usernameCompleter;
  String? loginToken;
  String? submittedUsername;
  String? refreshedToken;
  String? logoutDeviceId;
  int logoutCalls = 0;
  int usernameCalls = 0;

  @override
  Future<UserSession> loginWithGoogle(
    String idToken, {
    String? deviceId,
  }) async {
    loginToken = idToken;
    return loginResult;
  }

  @override
  Future<UserSession> refresh(String refreshToken, String deviceId) async {
    refreshedToken = refreshToken;
    if (refreshFailure != null) throw refreshFailure!;
    final pending = refreshCompleter;
    if (pending != null) return pending.future;
    return refreshResult ?? _session();
  }

  @override
  Future<UserSession> setUsername(String username) async {
    usernameCalls++;
    submittedUsername = username;
    if (usernameCompleter != null) return usernameCompleter!.future;
    return usernameResult ?? _session(username: username);
  }

  @override
  Future<void> logout(String deviceId) async {
    logoutDeviceId = deviceId;
    logoutCalls++;
  }

  @override
  Future<List<DeviceSession>> listDevices() async => const [];

  @override
  Future<void> revokeDevice(String deviceId) async {}
}

class _FakeTokenStore implements RefreshTokenStore {
  _FakeTokenStore(this.value);

  String? value;
  Object? clearFailure;

  @override
  Future<String?> read() async => value;

  @override
  Future<void> write(String token) async => value = token;

  @override
  Future<void> clear() async {
    if (clearFailure != null) throw clearFailure!;
    value = null;
  }
}
