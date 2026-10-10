import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tureon/app/app.dart';
import 'package:tureon/app/bootstrap.dart';
import 'package:tureon/app/router.dart';
import 'package:tureon/core/app/app_runtime.dart';
import 'package:tureon/core/app/connection_status.dart';
import 'package:tureon/core/protocol/recipient.dart';
import 'package:tureon/core/protocol/recipient_type.dart';
import 'package:tureon/core/storage/local_store.dart';
import 'package:tureon/core/storage/message_records.dart';
import 'package:tureon/features/auth/data/google_auth_data_source.dart';
import 'package:tureon/features/auth/domain/auth_gateway.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'first frame displays cached conversations without a network startup',
    (tester) async {
      final store = LocalStore.inMemory();
      store.saveSession(_session());
      store.saveCurrentUser(
        const UserProfile(
          userId: 'cached-account',
          username: 'cached_user',
          displayName: 'Cached user',
        ),
      );
      await store.saveRecipient(
        const Recipient(
          id: 'local-peer',
          type: RecipientType.user,
          name: 'Cached conversation',
          handle: '@peer',
        ),
      );
      final runtime = AppRuntime.forTesting(
        store: store,
        loadProfile: (_) async =>
            throw StateError('No profile RPC during startup'),
      );
      await bootstrapRuntime(
        openRuntime: () async => runtime,
        createGoogleAuth: _UnavailableGoogle.new,
      );

      await tester.pumpWidget(TureonApp(runtime: runtime));
      expect(find.text('Cached conversation'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(runtime.connectionStatus, ConnectionStatus.disconnected);
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    },
  );

  for (final scenario in [
    (session: null, status: AuthStatus.unauthenticated, route: '/login'),
    (session: _session(), status: AuthStatus.offline, route: '/'),
    (
      session: _session(needsUsername: true),
      status: AuthStatus.needsUsername,
      route: '/username',
    ),
    (
      session: _session(accountStatus: 'banned', needsUsername: true),
      status: AuthStatus.restricted,
      route: '/restricted',
    ),
  ]) {
    test(
      'local startup routes to ${scenario.route} without Google or sync',
      () async {
        final store = LocalStore.inMemory();
        final session = scenario.session;
        if (session != null) store.saveSession(session);
        var profileLoads = 0;
        var membershipLoads = 0;
        final runtime = AppRuntime.forTesting(
          store: store,
          loadProfile: (_) async {
            profileLoads++;
            throw StateError('Startup must not fetch a profile');
          },
          loadGroupChannels: (_) async {
            membershipLoads++;
            throw StateError('Startup must not fetch memberships');
          },
        );
        addTearDown(runtime.close);
        final google = _UnavailableGoogle();

        await bootstrapRuntime(
          openRuntime: () async => runtime,
          createGoogleAuth: () => google,
        );

        final state = runtime.authController!.currentState;
        expect(state.status, scenario.status);
        expect(AppRouter.destinationFor(state), scenario.route);
        expect(state.session?.userId, session?.userId);
        expect(runtime.currentSession?.userId, session?.userId);
        expect(runtime.connectionStatus, ConnectionStatus.disconnected);
        expect(runtime.isChatStreamReady, isFalse);
        expect(google.initializeCalls, 0);
        expect(profileLoads, 0);
        expect(membershipLoads, 0);
      },
    );
  }
}

UserSession _session({
  bool needsUsername = false,
  String accountStatus = 'active',
}) => UserSession(
  userId: 'cached-account',
  deviceId: 'cached-device',
  accessToken: 'expired-access',
  needsUsername: needsUsername,
  accountStatus: accountStatus,
);

class _UnavailableGoogle implements GoogleAuthDataSource {
  int initializeCalls = 0;

  @override
  Future<void> initialize() async {
    initializeCalls++;
    throw StateError('Google SDK unavailable');
  }

  @override
  Future<String?> authenticate() async => throw StateError('Unexpected login');

  @override
  Future<void> signOut() async {}
}
