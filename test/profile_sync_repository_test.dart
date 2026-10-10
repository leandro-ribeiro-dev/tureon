import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:fixnum/fixnum.dart';
import 'package:tureon/core/storage/local_store.dart';
import 'package:tureon/core/storage/message_records.dart';
import 'package:tureon/features/profile/data/profile_sync_repository.dart';
import 'package:tureon/generated/proto/tureon.pb.dart' as pb;

class _ProfileUpdatesRpc implements ProfileUpdatesRpc {
  final List<StreamController<pb.ProfileChange>> controllers = [];

  @override
  Stream<pb.ProfileChange> streamProfileChanges(pb.Empty request) {
    final controller = StreamController<pb.ProfileChange>.broadcast();
    controllers.add(controller);
    return controller.stream;
  }

  @override
  Stream<pb.ProfileChange> streamRecipientProfileChanges(
    pb.ProfileWatchRequest request,
  ) => const Stream<pb.ProfileChange>.empty();
}

void main() {
  test(
    'profile updates reconcile and stream resumes after foregrounding',
    () async {
      final store = LocalStore.inMemory();
      store.saveSession(
        const UserSession(userId: 'user-1', deviceId: 'device-1'),
      );
      final rpc = _ProfileUpdatesRpc();
      final received = Completer<int>();
      final repository = ProfileSyncRepository(
        rpc: rpc,
        store: store,
        onProfileChange: (version) async {
          if (!received.isCompleted) received.complete(version);
        },
      );

      await repository.startSync();
      expect(rpc.controllers, hasLength(1));
      rpc.controllers.first.add(pb.ProfileChange(profileVersion: Int64(7)));
      expect(await received.future.timeout(const Duration(seconds: 1)), 7);

      await repository.setActive(false);
      expect(rpc.controllers.first.hasListener, isFalse);
      await repository.setActive(true);
      expect(rpc.controllers, hasLength(2));
      expect(rpc.controllers.last.hasListener, isTrue);

      await repository.stopSync();
      for (final controller in rpc.controllers) {
        await controller.close();
      }
      store.close();
    },
  );

  test(
    'profile version events are reconciled serially and coalesced',
    () async {
      final store = LocalStore.inMemory();
      store.saveSession(
        const UserSession(userId: 'user-1', deviceId: 'device-1'),
      );
      final rpc = _ProfileUpdatesRpc();
      final entered = Completer<void>();
      final release = Completer<void>();
      final applied = <int>[];
      var concurrentCalls = 0;
      var maximumConcurrentCalls = 0;
      final repository = ProfileSyncRepository(
        rpc: rpc,
        store: store,
        onProfileChange: (version) async {
          concurrentCalls++;
          if (concurrentCalls > maximumConcurrentCalls) {
            maximumConcurrentCalls = concurrentCalls;
          }
          if (applied.isEmpty) {
            entered.complete();
            await release.future;
          }
          applied.add(version);
          concurrentCalls--;
        },
      );

      await repository.startSync();
      final stream = rpc.controllers.single;
      stream.add(pb.ProfileChange(profileVersion: Int64(4)));
      await entered.future.timeout(const Duration(seconds: 1));
      stream.add(pb.ProfileChange(profileVersion: Int64(5)));
      stream.add(pb.ProfileChange(profileVersion: Int64(6)));
      // The broadcast stream delivers on the next event-loop turn. Let both
      // changes reach the repository while version 4 is still being applied.
      await Future<void>.delayed(Duration.zero);
      release.complete();

      await _waitUntil(() => applied.length == 2);
      expect(applied, [4, 6]);
      expect(maximumConcurrentCalls, 1);

      await repository.stopSync();
      await stream.close();
      store.close();
    },
  );
}

Future<void> _waitUntil(bool Function() condition) async {
  final deadline = DateTime.now().add(const Duration(seconds: 1));
  while (!condition()) {
    if (DateTime.now().isAfter(deadline)) {
      throw TimeoutException('Condition was not met');
    }
    await Future<void>.delayed(const Duration(milliseconds: 1));
  }
}
