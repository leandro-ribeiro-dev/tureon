import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Owns in-memory slow-mode countdowns while they are active.
/// The server remains authoritative and rejects sends that arrive too early.
class ChatSlowModeCooldownNotifier extends Notifier<Map<String, int>> {
  final Map<String, _SlowModeCooldown> _cooldowns = {};

  @override
  Map<String, int> build() {
    ref.onDispose(_dispose);
    return const {};
  }

  int remainingSeconds(String key) => state[key] ?? 0;

  void start(String key, int seconds) {
    if (seconds <= 0) {
      clear(key);
      return;
    }

    final previous = _cooldowns.remove(key);
    previous?.timer?.cancel();
    previous?.stopwatch.stop();
    final boundedSeconds = seconds.clamp(1, 3600).toInt();
    final cooldown = _SlowModeCooldown(Duration(seconds: boundedSeconds));
    _cooldowns[key] = cooldown;
    _setRemaining(key, boundedSeconds);
    _scheduleNextTick(key, cooldown);
  }

  void clear(String key) {
    final cooldown = _cooldowns.remove(key);
    cooldown?.timer?.cancel();
    cooldown?.stopwatch.stop();
    if (state.containsKey(key)) {
      final next = Map<String, int>.of(state)..remove(key);
      state = Map.unmodifiable(next);
    }
  }

  void _scheduleNextTick(String key, _SlowModeCooldown cooldown) {
    if (!identical(_cooldowns[key], cooldown)) return;

    final remainingMilliseconds =
        cooldown.duration.inMilliseconds -
        cooldown.stopwatch.elapsedMilliseconds;
    if (remainingMilliseconds <= 0) {
      clear(key);
      return;
    }

    final remaining = (remainingMilliseconds / 1000).ceil();
    _setRemaining(key, remaining);
    final millisecondsToNextBoundary =
        remainingMilliseconds - (remaining - 1) * 1000;
    cooldown.timer = Timer(
      Duration(milliseconds: millisecondsToNextBoundary.clamp(1, 1000).toInt()),
      () => _scheduleNextTick(key, cooldown),
    );
  }

  void _setRemaining(String key, int remaining) {
    if (state[key] == remaining) return;
    state = Map.unmodifiable({...state, key: remaining});
  }

  void _dispose() {
    for (final cooldown in _cooldowns.values) {
      cooldown.timer?.cancel();
      cooldown.stopwatch.stop();
    }
    _cooldowns.clear();
  }
}

class _SlowModeCooldown {
  _SlowModeCooldown(this.duration) : stopwatch = Stopwatch()..start();

  final Duration duration;
  final Stopwatch stopwatch;
  Timer? timer;
}

final chatSlowModeCooldownProvider =
    NotifierProvider<ChatSlowModeCooldownNotifier, Map<String, int>>(
      ChatSlowModeCooldownNotifier.new,
    );
