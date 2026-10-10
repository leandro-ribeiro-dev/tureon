import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:tureon/features/chats/data/services/chat_ack_queue.dart';
import 'package:tureon/features/chats/data/services/messaging_rpc.dart';
import 'package:tureon/generated/proto/tureon.pb.dart' as pb;

void main() {
  test(
    'bounded ACK queue deduplicates and retains overflow for replay',
    () async {
      final rpc = _AckRpc()..ready = false;
      final queue = ChatAckQueue(
        rpc: rpc,
        ackBatchWindow: Duration.zero,
        maxAcknowledgementsPerRpc: 256,
        maxPendingAcknowledgements: 4096,
      );
      final pending = [
        for (var index = 0; index < 4096; index++)
          queue.queueAcknowledgement(_delivery('$index')),
      ];
      expect(queue.queueAcknowledgement(_delivery('0')), same(pending.first));
      await expectLater(
        queue.queueAcknowledgement(_delivery('overflow')),
        throwsStateError,
      );
      rpc.ready = true;
      await queue.flushAcknowledgements();
      await Future.wait(pending);
      expect(rpc.batches, hasLength(16));
      expect(rpc.batches.every((batch) => batch.length == 256), isTrue);
      expect(rpc.batches.expand((batch) => batch).toSet(), hasLength(4096));
      queue.stop();
    },
  );

  test(
    'stop prevents captured ACK batches from reaching a new session',
    () async {
      final rpc = _AckRpc()..gate = Completer<void>();
      final queue = ChatAckQueue(
        rpc: rpc,
        ackBatchWindow: Duration.zero,
        maxAcknowledgementsPerRpc: 1,
        maxPendingAcknowledgements: 4,
      );
      final first = queue.queueAcknowledgement(_delivery('old-first'));
      final firstFailure = expectLater(first, throwsStateError);
      await Future<void>.delayed(Duration.zero);
      final second = queue.queueAcknowledgement(_delivery('old-second'));
      final secondFailure = expectLater(second, throwsStateError);
      queue.stop();
      queue.start();
      final replacement = queue.queueAcknowledgement(_delivery('new-account'));
      rpc.gate!.complete();
      await Future.wait([firstFailure, secondFailure, replacement]);
      expect(rpc.batches, [
        ['old-first'],
        ['new-account'],
      ]);
      queue.stop();
    },
  );
}

pb.MessageDelivery _delivery(String id) =>
    pb.MessageDelivery(deliveryId: id, targetDeviceId: 'device');

class _AckRpc implements MessagingRpc {
  bool ready = true;
  Completer<void>? gate;
  final batches = <List<String>>[];

  @override
  bool get isReady => ready;

  @override
  Future<void> ackDeliveries(
    List<pb.DeliveryAcknowledgement> deliveries,
  ) async {
    batches.add([for (final delivery in deliveries) delivery.deliveryId]);
    await gate?.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
