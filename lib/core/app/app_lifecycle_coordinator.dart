import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/widgets.dart';

typedef AppLifecycleStateHandler = Future<void> Function(bool isForeground);

class AppLifecycleCoordinator with WidgetsBindingObserver {
  AppLifecycleCoordinator({required this.onStateChanged});

  final AppLifecycleStateHandler onStateChanged;
  bool _isForeground = true;
  bool _isObserving = false;

  bool get isForeground => _isForeground;

  void start() {
    if (_isObserving) return;
    WidgetsBinding.instance.addObserver(this);
    _isObserving = true;
    final state = WidgetsBinding.instance.lifecycleState;
    _isForeground = state == null || state == AppLifecycleState.resumed;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final isForeground = state == AppLifecycleState.resumed;
    if (_isForeground == isForeground) return;
    _isForeground = isForeground;
    unawaited(_notifyStateChanged(isForeground));
  }

  Future<void> _notifyStateChanged(bool isForeground) async {
    try {
      await onStateChanged(isForeground);
    } catch (error, stackTrace) {
      developer.log(
        'Failed to coordinate application lifecycle transition',
        name: 'tureon.lifecycle',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  void dispose() {
    if (!_isObserving) return;
    WidgetsBinding.instance.removeObserver(this);
    _isObserving = false;
  }
}
