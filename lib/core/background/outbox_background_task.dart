import 'dart:async';
import 'dart:developer' as developer;
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:workmanager/workmanager.dart';

import '../../core/app/app_runtime.dart';
import '../../core/network/grpc_transport_config.dart';
import '../../core/storage/message_records.dart';
import '../../features/auth/data/google_auth_data_source.dart';
import '../../features/auth/data/google_client_id_config.dart';

const _outboxTaskName = 'tureon.message-outbox';

@pragma('vm:entry-point')
void outboxBackgroundTaskDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task != _outboxTaskName) return true;
    DartPluginRegistrant.ensureInitialized();
    WidgetsFlutterBinding.ensureInitialized();
    return _runOutboxTask();
  });
}

Future<bool> _runOutboxTask() async {
  AppRuntime? runtime;
  try {
    runtime = await AppRuntime.open();
    final host = resolveGrpcHost();
    await runtime.connect(
      host: host,
      port: grpcServerPort,
      secure: resolveGrpcTransportSecurity(host),
    );
    await runtime.configureAuth(
      GoogleAuthDataSource.create(
        serverClientId: resolveServerClientId(
          const String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID'),
        ),
        iosClientId: const String.fromEnvironment('GOOGLE_IOS_CLIENT_ID'),
        desktopClientId: const String.fromEnvironment('GOOGLE_LINUX_CLIENT_ID'),
        desktopClientSecret: const String.fromEnvironment(
          'GOOGLE_LINUX_CLIENT_SECRET',
        ),
      ),
    );

    final session = runtime.store.loadSession();
    if (session == null) return true;
    final initialQueue = runtime.store.loadOutboxQueue(
      session.userId,
      session.deviceId,
    );
    if (initialQueue.any((record) => record.status == OutboxStatus.preparing)) {
      await runtime.ensureSecretChatReady();
    }
    for (var attempt = 0; attempt < 420; attempt++) {
      final queue = runtime.store.loadOutboxQueue(
        session.userId,
        session.deviceId,
      );
      final hasWork = queue.any(
        (record) => record.status != OutboxStatus.failed,
      );
      if (!hasWork) return true;
      await Future<void>.delayed(const Duration(seconds: 1));
    }
    return false;
  } catch (error, stackTrace) {
    developer.log(
      'Android message outbox task failed',
      name: 'tureon.messaging',
      error: error,
      stackTrace: stackTrace,
    );
    return false;
  } finally {
    await runtime?.close();
  }
}
