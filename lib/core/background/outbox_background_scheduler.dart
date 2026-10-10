import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';

class OutboxBackgroundScheduler {
  OutboxBackgroundScheduler._();

  static Future<void>? _initialization;

  static bool get _isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  static Future<void> initialize(Function callbackDispatcher) async {
    if (!_isAndroid) return;
    final initialization = _initialization ??= Workmanager().initialize(
      callbackDispatcher,
    );
    try {
      await initialization;
    } catch (_) {
      _initialization = null;
      rethrow;
    }
  }

  static Future<void> enqueue() async {
    if (!_isAndroid) return;
    try {
      final initialization = _initialization;
      if (initialization == null) {
        throw StateError(
          'Android message outbox scheduling was not initialized.',
        );
      }
      await initialization;
      await Workmanager().registerOneOffTask(
        'tureon-message-outbox',
        'tureon.message-outbox',
        constraints: Constraints(networkType: NetworkType.connected),
        existingWorkPolicy: ExistingWorkPolicy.append,
        backoffPolicy: BackoffPolicy.exponential,
        backoffPolicyDelay: const Duration(seconds: 30),
      );
    } catch (error, stackTrace) {
      developer.log(
        'Could not schedule Android message outbox work',
        name: 'tureon.messaging',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}
