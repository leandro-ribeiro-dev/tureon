import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tureon/core/network/realtime_stream_manager.dart';

void main() {
  test(
    'coalesces pending failures when the connection becomes ready',
    () async {
      final changes = StreamController<List<ConnectivityResult>>();
      var reconnectCount = 0;
      final manager = RealtimeStreamManager(
        connectivityChanges: changes.stream,
        reconnectAll: () {
          reconnectCount++;
          return Future<void>.value();
        },
        retryBaseDelay: const Duration(milliseconds: 5),
        retryMaxDelay: const Duration(milliseconds: 10),
      )..start();

      manager.requestReconnect();
      manager.requestReconnect();
      await manager.onConnectionReady();
      expect(reconnectCount, 1);

      manager.requestReconnect();
      await manager.onConnectionReady();
      expect(reconnectCount, 2);

      await manager.stop();
      await changes.close();
    },
  );

  test(
    'network route changes during a reconnect trigger a follow-up reconnect',
    () async {
      final changes = StreamController<List<ConnectivityResult>>();
      final reconnectGate = Completer<void>();
      var reconnectCount = 0;
      final manager = RealtimeStreamManager(
        connectivityChanges: changes.stream,
        reconnectAll: () async {
          reconnectCount++;
          await reconnectGate.future;
        },
      )..start();

      changes.add([ConnectivityResult.wifi]);
      changes.add([ConnectivityResult.wifi]);
      changes.add([ConnectivityResult.mobile]);
      changes.add([ConnectivityResult.mobile, ConnectivityResult.vpn]);
      changes.add([ConnectivityResult.mobile, ConnectivityResult.vpn]);
      await Future<void>.delayed(Duration.zero);

      expect(reconnectCount, 1);
      reconnectGate.complete();
      await _waitFor(() => reconnectCount == 2);
      await manager.stop();
      await changes.close();
    },
  );
}

Future<void> _waitFor(bool Function() condition) async {
  for (var attempt = 0; attempt < 100; attempt++) {
    if (condition()) return;
    await Future<void>.delayed(const Duration(milliseconds: 1));
  }
  fail('Condition was not met before the timeout.');
}
