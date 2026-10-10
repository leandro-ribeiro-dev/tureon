import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/app/app_runtime.dart';
import '../core/app/app_theme.dart';
import '../core/providers/settings_providers.dart';
import '../features/home/data/local_home_repository.dart';
import '../features/home/home_providers.dart';
import '../l10n/app_localizations.dart';
import '../features/auth/presentation/auth_controller.dart';
import 'router.dart';

class TureonApp extends StatefulWidget {
  const TureonApp({super.key, this.runtime});

  final AppRuntime? runtime;

  @override
  State<TureonApp> createState() => _TureonAppState();
}

class _TureonAppState extends State<TureonApp> {
  late GoRouter _router;
  StreamSubscription<AuthController?>? _authControllerSubscription;
  AuthController? _activeAuthController;

  @override
  void initState() {
    super.initState();
    final runtime = widget.runtime;
    if (runtime == null) {
      _router = AppRouter.homeOnly();
      return;
    }
    _router = AppRouter.startup();
    _authControllerSubscription = runtime.authControllerUpdates.listen(
      _handleAuthControllerChanged,
    );
    _handleAuthControllerChanged(runtime.authController);
  }

  void _handleAuthControllerChanged(AuthController? controller) {
    if (controller == null || identical(controller, _activeAuthController)) {
      return;
    }
    final previousRouter = _router;
    _activeAuthController = controller;
    _router = AppRouter.create(controller: controller);
    previousRouter.dispose();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _authControllerSubscription?.cancel();
    _router.dispose();
    unawaited(widget.runtime?.close() ?? Future<void>.value());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final homeRepository = widget.runtime == null
        ? null
        : LocalHomeRepository(widget.runtime!.store);

    return ProviderScope(
      overrides: [
        appRuntimeProvider.overrideWithValue(widget.runtime),
        homeRepositoryProvider.overrideWithValue(homeRepository),
      ],
      child: Consumer(
        builder: (context, ref, _) {
          final themeMode = ref.watch(appThemeModeProvider);
          return MaterialApp.router(
            title: 'Tureon',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            locale: ref.watch(appLocaleProvider),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: _router,
          );
        },
      ),
    );
  }
}
