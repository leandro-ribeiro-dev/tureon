import 'dart:async';
import 'package:flutter/material.dart';

import '../core/background/outbox_background_scheduler.dart';
import '../core/background/outbox_background_task.dart';
import '../core/app/app_runtime.dart';
import '../core/network/grpc_transport_config.dart';
import '../features/auth/data/google_auth_data_source.dart';
import '../features/auth/data/google_client_id_config.dart';
import 'app.dart';

/// Prepares local data and routing without starting network or native workers.
Future<AppRuntime> bootstrapRuntime({
  Future<AppRuntime> Function() openRuntime = AppRuntime.open,
  GoogleAuthDataSource Function()? createGoogleAuth,
}) async {
  final runtime = await openRuntime();
  try {
    final host = resolveGrpcHost();
    await runtime.connect(
      host: host,
      port: grpcServerPort,
      secure: resolveGrpcTransportSecurity(host),
      // Cached credentials must not open protected streams before validation.
      accessToken: '',
      startNetwork: false,
    );
    final googleAuth =
        createGoogleAuth?.call() ??
        GoogleAuthDataSource.create(
          serverClientId: resolveServerClientId(
            const String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID'),
          ),
          iosClientId: const String.fromEnvironment('GOOGLE_IOS_CLIENT_ID'),
          desktopClientId: const String.fromEnvironment(
            'GOOGLE_LINUX_CLIENT_ID',
          ),
          desktopClientSecret: const String.fromEnvironment(
            'GOOGLE_LINUX_CLIENT_SECRET',
          ),
        );
    // Google authentication initializes lazily on an interactive login.
    await runtime.configureAuth(googleAuth, restoreSession: false);
    return runtime;
  } catch (_) {
    await runtime.close();
    rethrow;
  }
}

Future<bool> _initializeOutboxScheduler() async {
  try {
    await OutboxBackgroundScheduler.initialize(outboxBackgroundTaskDispatcher);
    return true;
  } catch (error, stackTrace) {
    debugPrint('Could not initialize Android message outbox work: $error');
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'tureon.messaging',
      ),
    );
    return false;
  }
}

Future<void> _startBackgroundServices(AppRuntime runtime) async {
  try {
    runtime.startNetworkServices();
    await runtime.restoreAuthentication();
  } catch (error, stackTrace) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'tureon.connection',
        context: ErrorDescription('while initializing the server connection'),
      ),
    );
  }
}

Future<void> _startOutboxScheduler() async {
  if (await _initializeOutboxScheduler()) {
    await OutboxBackgroundScheduler.enqueue();
  }
}

Future<void> runTureon() async {
  WidgetsFlutterBinding.ensureInitialized();
  final runtime = await bootstrapRuntime();
  runApp(TureonApp(runtime: runtime));
  WidgetsBinding.instance.addPostFrameCallback((_) {
    unawaited(_startBackgroundServices(runtime));
    unawaited(_startOutboxScheduler());
  });
}
