import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tureon/core/app/app_theme.dart';
import 'package:tureon/core/storage/message_records.dart';
import 'package:tureon/features/auth/data/auth_gateway.dart';
import 'package:tureon/features/auth/data/google_auth_data_source.dart';
import 'package:tureon/features/auth/presentation/auth_controller.dart';
import 'package:tureon/features/auth/presentation/auth_screens.dart';

void main() {
  testWidgets('login screen scrolls instead of overflowing on a short device', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = AuthController(
      gateway: _TestAuthGateway(
        loginError: StateError(
          'gRPC Error (code: 16, codeName: UNAUTHENTICATED, '
          'message: Google authentication failed, rawResponse: null)',
        ),
      ),
      google: _TestGoogleAuth(),
      refreshTokens: _TestRefreshTokenStore(),
      savedSession: null,
      persistSession: (_) async {},
    );
    addTearDown(controller.dispose);
    await controller.signInWithGoogle();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: LoginScreen(controller: controller),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Tureon'), findsOneWidget);
    expect(find.text('Entrar com Google'), findsOneWidget);
    expect(
      find.textContaining('O servidor recusou o login Google.'),
      findsOneWidget,
    );
    expect(find.textContaining('rawResponse'), findsNothing);
  });

  testWidgets('login screen explains recoverable connectivity failures', (
    tester,
  ) async {
    final controller = AuthController(
      gateway: _TestAuthGateway(
        loginError: StateError(
          'gRPC Error (code: 14, codeName: UNAVAILABLE, message: offline)',
        ),
      ),
      google: _TestGoogleAuth(),
      refreshTokens: _TestRefreshTokenStore(),
      savedSession: null,
      persistSession: (_) async {},
    );
    addTearDown(controller.dispose);
    await controller.signInWithGoogle();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: LoginScreen(controller: controller),
      ),
    );

    expect(
      find.textContaining('Não foi possível conectar ao servidor.'),
      findsOneWidget,
    );
  });

  testWidgets(
    'login screen explains desktop OAuth client configuration errors',
    (tester) async {
      final controller = AuthController(
        gateway: _TestAuthGateway(
          loginError: StateError(
            'Google token exchange failed: invalid_client. Client is not valid.',
          ),
        ),
        google: _TestGoogleAuth(),
        refreshTokens: _TestRefreshTokenStore(),
        savedSession: null,
        persistSession: (_) async {},
      );
      addTearDown(controller.dispose);
      await controller.signInWithGoogle();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: LoginScreen(controller: controller),
        ),
      );

      expect(
        find.textContaining('O Google recusou o Client ID do computador.'),
        findsOneWidget,
      );
      expect(find.textContaining('invalid_client'), findsNothing);
    },
  );

  testWidgets('login screen shows safe details for other Google OAuth errors', (
    tester,
  ) async {
    final controller = AuthController(
      gateway: _TestAuthGateway(
        loginError: StateError(
          'Google token exchange failed: invalid_request. Missing parameter.',
        ),
      ),
      google: _TestGoogleAuth(),
      refreshTokens: _TestRefreshTokenStore(),
      savedSession: null,
      persistSession: (_) async {},
    );
    addTearDown(controller.dispose);
    await controller.signInWithGoogle();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: LoginScreen(controller: controller),
      ),
    );

    expect(find.textContaining('invalid_request'), findsOneWidget);
    expect(find.textContaining('Missing parameter'), findsOneWidget);
  });

  testWidgets('login timeout is shown as a recoverable connection failure', (
    tester,
  ) async {
    final controller = AuthController(
      gateway: _TestAuthGateway(
        loginError: StateError(
          'TimeoutException after 0:00:15.000000: login timed out',
        ),
      ),
      google: _TestGoogleAuth(),
      refreshTokens: _TestRefreshTokenStore(),
      savedSession: null,
      persistSession: (_) async {},
    );
    addTearDown(controller.dispose);
    await controller.signInWithGoogle();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: LoginScreen(controller: controller),
      ),
    );

    expect(
      find.textContaining('Não foi possível conectar ao servidor.'),
      findsOneWidget,
    );
  });

  testWidgets('username setup translates structured server errors', (
    tester,
  ) async {
    final controller = AuthController(
      gateway: _TestAuthGateway(loginError: StateError('unused')),
      google: _TestGoogleAuth(),
      refreshTokens: _TestRefreshTokenStore(),
      savedSession: null,
      persistSession: (_) async {},
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(home: UsernameSetupScreen(controller: controller)),
    );

    const cases = <String, String>{
      'USERNAME_INVALID': 'Formato inválido.',
      'USERNAME_RESERVED': 'Esse nome de usuário é reservado',
      'USERNAME_TAKEN': 'Esse nome de usuário já está em uso.',
      'PREMIUM_USERNAME_UNAVAILABLE': 'Esse nome premium não está disponível',
    };
    for (final entry in cases.entries) {
      controller.state = AuthState(
        status: AuthStatus.needsUsername,
        session: const UserSession(userId: 'user-1', deviceId: 'device-1'),
        usernameError: 'gRPC error: ${entry.key}',
      );
      await tester.pump();
      expect(find.textContaining(entry.value), findsOneWidget);
    }
  });

  testWidgets('username setup blocks invalid formats before making an RPC', (
    tester,
  ) async {
    final gateway = _TestAuthGateway(loginError: StateError('unused'));
    final controller = AuthController(
      gateway: gateway,
      google: _TestGoogleAuth(),
      refreshTokens: _TestRefreshTokenStore(),
      savedSession: null,
      persistSession: (_) async {},
    );
    controller.state = AuthState(
      status: AuthStatus.needsUsername,
      session: const UserSession(userId: 'user-1', deviceId: 'device-1'),
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(home: UsernameSetupScreen(controller: controller)),
    );
    await tester.enterText(find.byType(TextField), 'bad!');
    await tester.tap(find.text('Continuar'));
    await tester.pump();

    expect(find.textContaining('Formato inválido.'), findsOneWidget);
    expect(gateway.usernameCalls, 0);
  });
}

class _TestAuthGateway implements AuthGateway {
  _TestAuthGateway({required this.loginError});

  final Object loginError;
  int usernameCalls = 0;

  @override
  Future<UserSession> loginWithGoogle(String idToken, {String? deviceId}) =>
      Future.error(loginError);

  @override
  Future<UserSession> setUsername(String username) async {
    usernameCalls++;
    throw StateError('unused');
  }

  @override
  Future<void> noSuchMethod(Invocation invocation) async {}
}

class _TestGoogleAuth implements GoogleAuthDataSource {
  @override
  Future<void> initialize() async {}

  @override
  Future<String?> authenticate() async => 'google-id-token';

  @override
  Future<void> signOut() async {}

  @override
  Future<void> noSuchMethod(Invocation invocation) async {}
}

class _TestRefreshTokenStore implements RefreshTokenStore {
  @override
  Future<void> noSuchMethod(Invocation invocation) async {}
}
