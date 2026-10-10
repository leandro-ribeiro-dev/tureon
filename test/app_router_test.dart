import 'package:flutter_test/flutter_test.dart';
import 'package:tureon/app/router.dart';
import 'package:tureon/core/storage/message_records.dart';
import 'package:tureon/features/auth/domain/auth_gateway.dart';

void main() {
  test('restoring a saved session stays on the startup screen', () {
    expect(
      AppRouter.destinationFor(
        const AuthState(status: AuthStatus.restoringSession),
      ),
      '/startup',
    );
  });

  test('interactive Google authentication stays on the login screen', () {
    expect(
      AppRouter.destinationFor(
        const AuthState(
          status: AuthStatus.authenticating,
          session: UserSession(userId: 'saved-user', deviceId: 'device-1'),
        ),
      ),
      '/login',
    );
  });

  test('fresh unauthenticated sessions still route to login', () {
    expect(
      AppRouter.destinationFor(
        const AuthState(status: AuthStatus.unauthenticated),
      ),
      '/login',
    );
  });

  test('username setup and restricted accounts keep their own routes', () {
    expect(
      AppRouter.destinationFor(
        const AuthState(status: AuthStatus.needsUsername),
      ),
      '/username',
    );
    expect(
      AppRouter.destinationFor(const AuthState(status: AuthStatus.restricted)),
      '/restricted',
    );
  });
}
