import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tureon/core/app/app_lifecycle_coordinator.dart';

void main() {
  test('notifies only when foreground state changes', () async {
    final transitions = <bool>[];
    final coordinator = AppLifecycleCoordinator(
      onStateChanged: (isForeground) async => transitions.add(isForeground),
    );

    coordinator.didChangeAppLifecycleState(AppLifecycleState.paused);
    coordinator.didChangeAppLifecycleState(AppLifecycleState.inactive);
    coordinator.didChangeAppLifecycleState(AppLifecycleState.resumed);

    expect(transitions, [false, true]);
    expect(coordinator.isForeground, isTrue);
    coordinator.dispose();
  });

  test('logs callback failures without losing foreground state', () async {
    final coordinator = AppLifecycleCoordinator(
      onStateChanged: (_) async => throw StateError('transition failed'),
    );

    coordinator.didChangeAppLifecycleState(AppLifecycleState.paused);
    await Future<void>.delayed(Duration.zero);

    expect(coordinator.isForeground, isFalse);
    coordinator.dispose();
  });
}
