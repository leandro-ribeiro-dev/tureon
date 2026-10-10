import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/domain/auth_gateway.dart';
import '../features/auth/presentation/auth_controller.dart';
import '../features/auth/presentation/auth_screens.dart';
import '../features/home/presentation/views/home_page.dart';

class AppRouter {
  const AppRouter();

  static GoRouter startup() => GoRouter(
    routes: [
      GoRoute(path: '/', builder: (context, state) => const _AppStartupPage()),
    ],
  );

  static GoRouter homeOnly() => GoRouter(
    routes: [GoRoute(path: '/', builder: (context, state) => const HomePage())],
  );

  static GoRouter create({required AuthController controller}) {
    return GoRouter(
      refreshListenable: _AuthRouterRefresh(controller),
      routes: [
        GoRoute(
          path: '/startup',
          builder: (context, state) => const _AppStartupPage(),
        ),
        GoRoute(path: '/', builder: (context, state) => const HomePage()),
        GoRoute(
          path: '/login',
          builder: (context, state) => LoginScreen(controller: controller),
        ),
        GoRoute(
          path: '/username',
          builder: (context, state) =>
              UsernameSetupScreen(controller: controller),
        ),
        GoRoute(
          path: '/restricted',
          builder: (context, state) =>
              RestrictedAccountScreen(onLogout: controller.signOut),
        ),
      ],
      redirect: (context, state) {
        final destination = destinationFor(controller.currentState);
        return state.uri.path == destination ? null : destination;
      },
    );
  }

  static String destinationFor(AuthState state) => switch (state.status) {
    AuthStatus.restoringSession => '/startup',
    AuthStatus.offline => '/',
    AuthStatus.unauthenticated => '/login',
    AuthStatus.authenticating => '/login',
    AuthStatus.needsUsername => '/username',
    AuthStatus.authenticated => '/',
    AuthStatus.restricted => '/restricted',
  };
}

class _AppStartupPage extends StatelessWidget {
  const _AppStartupPage();

  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FlutterLogo(size: 56),
          SizedBox(height: 20),
          CircularProgressIndicator(),
        ],
      ),
    ),
  );
}

class _AuthRouterRefresh extends ChangeNotifier {
  _AuthRouterRefresh(AuthController controller) {
    _removeListener = controller.listen((_) => notifyListeners());
  }

  late final VoidCallback _removeListener;

  @override
  void dispose() {
    _removeListener();
    super.dispose();
  }
}
