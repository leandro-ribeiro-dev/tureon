part of 'chat_repository_test.dart';

void realtimeLoadCases() {
  test('4096 system events persist through the real SQLite pipeline', () async {
    const count = 4096;
    final store = LocalStore.inMemory();
    store.saveSession(
      const UserSession(userId: 'user-1', deviceId: 'device-1'),
    );
    await store.saveRecipient(
      const Recipient(
        id: 'room',
        type: RecipientType.group,
        name: 'Room',
        handle: '',
        isMember: true,
      ),
    );
    final rpc = _FakeMessagingRpc()
      ..deliveries = [
        for (var i = 1; i <= count; i++)
          _delivery(id: 'system-delivery-$i', messageId: 'system-message-$i')
            ..chatId = 'room'
            ..messageType = pb.MessageType.MESSAGE_TYPE_SYSTEM
            ..payload = pb.SystemMessage(
              eventType: pb.SystemEventType.SYSTEM_EVENT_TYPE_GROUP_RENAMED,
              actorUserId: 'user-2',
              groupId: 'room',
              metadata: {
                'room_type': 'group',
                'room_member_count': '2',
                'room_name': 'Room $i',
                'room_version': '$i',
              },
            ).writeToBuffer(),
      ];
    final repository = GrpcChatRepository(rpc: rpc, store: store);
    addTearDown(() async {
      await repository.stopSync();
      await store.close();
    });
    final stopwatch = Stopwatch()..start();
    await repository.startSync();
    await _waitForLoad(
      () => rpc.acknowledged.length == count,
      timeout: const Duration(seconds: 30),
    );
    stopwatch.stop();
    expect(store.loadChatMessages('room'), hasLength(count));
    expect(store.loadRecipient('room')?.roomVersion, count);
    expect(store.loadRecipient('room')?.name, 'Room $count');
    expect(store.loadRecipient('room')?.unreadCount, count);
    // ignore: avoid_print
    print(
      'SQLite system-event pipeline: $count persisted and ACKed in ${stopwatch.elapsedMilliseconds} ms (${(count * 1000000 / stopwatch.elapsedMicroseconds).round()} events/s); in-memory SQLite, simulated transport.',
    );
  });

  test(
    'own devices synchronize sends, edits and replay without unread duplicates',
    () async {
      final rpcA = _FakeMessagingRpc();
      final rpcB = _FakeMessagingRpc();
      final storeA = _FakeChatStore();
      final storeB = _FakeChatStore()
        ..session = const UserSession(userId: 'user-1', deviceId: 'device-2');
      final a = _createRepository(rpc: rpcA, store: storeA);
      final b = _createRepository(rpc: rpcB, store: storeB);
      addTearDown(a.stopSync);
      addTearDown(b.stopSync);
      await Future.wait([a.startSync(), b.startSync()]);
      late pb.MessageDelivery mirror;
      rpcA.beforeSend = () {
        final request = rpcA.lastSendRequest!;
        mirror = pb.MessageDelivery(
          deliveryId: 'mirror-copy',
          messageId: request.messageId,
          chatId: request.chatId,
          senderRecipientId: request.senderRecipientId,
          senderDeviceId: request.senderDeviceId,
          targetRecipientId: 'user-1',
          targetDeviceId: 'device-2',
          chatKind: request.chatKind,
          messageType: request.messageType,
          payload: request.payload,
          createdAt: Int64(rpcA.serverTimestampMicros ~/ 1000000),
        );
        rpcB._activeStream!.add(mirror);
      };
      final sent = await a.sendMessage(
        chatId: 'peer',
        senderRecipientId: 'user-1',
        body: 'sent on first device',
      );
      await _waitForLoad(
        () =>
            storeB.loadChatMessage(sent.messageId) != null &&
            storeA.outbox.isEmpty,
      );
      expect(
        storeB.loadChatMessage(sent.messageId)?.body,
        'sent on first device',
      );
      expect(storeB.outbox, isEmpty);
      expect(storeB.loadRecipient('peer')?.unreadCount, 0);

      rpcB.beforeMutation = (request) => rpcA._activeStream!.add(
        pb.MessageDelivery(
          deliveryId: 'mirror-edit',
          messageId: request.messageId,
          chatId: request.chatId,
          senderRecipientId: 'user-1',
          senderDeviceId: 'device-2',
          targetRecipientId: 'user-1',
          targetDeviceId: 'device-1',
          chatKind: request.chatKind,
          messageType: pb.MessageType.MESSAGE_TYPE_TEXT,
          payload: request.payload,
          eventType:
              pb.MessageDeliveryEventType.MESSAGE_DELIVERY_EVENT_TYPE_EDITED,
          createdAt: Int64(DateTime.now().millisecondsSinceEpoch ~/ 1000),
        ),
      );
      await b.editMessage(
        messageId: sent.messageId,
        chatId: 'peer',
        targetRecipientId: 'peer',
        isSecret: false,
        body: 'edited on second device',
      );
      await _waitForLoad(
        () =>
            storeA.loadChatMessage(sent.messageId)?.body ==
            'edited on second device',
      );
      expect(
        storeB.loadChatMessage(sent.messageId)?.body,
        'edited on second device',
      );

      rpcB.deliveries = [mirror, mirror];
      await b.reconnect();
      await _waitForLoad(() => rpcB.acknowledged.length >= 2);
      expect(storeB.loadChatMessages('peer'), hasLength(1));
      expect(
        storeB.loadChatMessages('peer').single.body,
        'edited on second device',
      );
      expect(storeB.loadRecipient('peer')?.unreadCount, 0);
    },
  );

  test(
    'new device opens its own stream after an old activation finishes',
    () async {
      final reset = Completer<void>();
      final rpc = _FakeMessagingRpc()..resetGate = reset;
      final store = _FakeChatStore();
      final repository = _createRepository(rpc: rpc, store: store);
      addTearDown(repository.stopSync);
      final oldStart = repository.startSync();
      await _waitForLoad(() => rpc.resetGate == null);
      await repository.stopSync();
      store.session = const UserSession(userId: 'user-1', deviceId: 'device-2');
      final newStart = repository.startSync();
      await Future<void>.delayed(Duration.zero);
      reset.complete();
      await Future.wait([oldStart, newStart]);

      expect(rpc.streamRequests, hasLength(1));
      expect(rpc.streamRequests.single.deviceId, 'device-2');
    },
  );

  test('reconnect releases pressure when previous handlers finish', () async {
    final oldGate = Completer<void>();
    final replacementGate = Completer<void>();
    final rpc = _FakeMessagingRpc()
      ..deliveries = [
        for (var index = 0; index < 2; index++)
          _delivery(id: 'old-$index', messageId: 'old-message-$index'),
      ];
    var resolutions = 0;
    final store = _FakeChatStore();
    final repository = _createRepository(
      rpc: rpc,
      store: store,
      maxConcurrentDeliveryHandlers: 2,
      resolveRecipient: (id) async {
        final isOld = resolutions++ < 2;
        await (isOld ? oldGate.future : replacementGate.future);
        return Recipient(
          id: id,
          type: RecipientType.user,
          name: 'Peer',
          handle: '@peer',
        );
      },
    );
    addTearDown(() async {
      if (!oldGate.isCompleted) oldGate.complete();
      if (!replacementGate.isCompleted) replacementGate.complete();
      await repository.stopSync();
    });
    await repository.startSync();
    await _waitForLoad(() => resolutions == 2);
    rpc.deliveries = [
      for (var index = 0; index < 3; index++)
        _delivery(id: 'new-$index', messageId: 'new-message-$index'),
    ];
    await repository.reconnect();
    await _waitForLoad(() => resolutions == 3);
    replacementGate.complete();
    await _waitForLoad(() => store.loadChatMessage('new-message-0') != null);
    oldGate.complete();
    await _waitForLoad(() => store.messages.length == 5);
    expect(store.loadChatMessage('new-message-2'), isNotNull);
  });

  test(
    'viewed messages retain failed read receipts in the durable outbox',
    () async {
      final rpc = _FakeMessagingRpc()
        ..readReceiptFailure = const GrpcError.unavailable('offline receipt')
        ..deliveries = [_delivery(id: 'viewed', messageId: 'viewed-message')];
      final store = _FakeChatStore();
      final repository = _createRepository(
        rpc: rpc,
        store: store,
        retryBaseDelay: const Duration(milliseconds: 5),
      );
      final subscription = repository
          .watchMessages(chatId: 'recipient-1')
          .listen((_) {});
      addTearDown(() async {
        await subscription.cancel();
        await repository.stopSync();
      });
      await repository.startSync();
      await _waitForLoad(
        () => store.queuedCommands.any((command) => command.attempts > 0),
      );
      expect(
        store.loadChatMessage('viewed-message')?.status,
        ChatDeliveryStatus.read,
      );
      expect(rpc.acknowledged, hasLength(1));
      rpc.readReceiptFailure = null;
      await _waitForLoad(() => store.queuedCommands.isEmpty);
      expect(rpc.sentReadReceipts.length, greaterThanOrEqualTo(2));
    },
  );

  test('a stopped worker cannot erase a replacement outbox worker', () async {
    final oldGate = Completer<void>();
    final newGate = Completer<void>();
    final rpc = _FakeMessagingRpc()..sendGate = oldGate;
    final store = _FakeChatStore();
    final repository = _createRepository(rpc: rpc, store: store);
    addTearDown(() async {
      if (!oldGate.isCompleted) oldGate.complete();
      if (!newGate.isCompleted) newGate.complete();
      await repository.stopSync();
    });
    await repository.sendMessage(
      chatId: 'peer',
      senderRecipientId: 'user-1',
      body: 'first',
    );
    await _waitForLoad(() => rpc.sentRequests.length == 1);
    rpc._setReady(false);
    rpc.sendGate = newGate;
    rpc._setReady(true);
    await _waitForLoad(() => rpc.sentRequests.length == 2);
    oldGate.complete();
    await Future<void>.delayed(Duration.zero);
    await repository.sendMessage(
      chatId: 'other',
      senderRecipientId: 'user-1',
      body: 'second',
    );
    await Future<void>.delayed(Duration.zero);
    expect(rpc.sentRequests, hasLength(2));
    newGate.complete();
    await _waitForLoad(() => store.outbox.isEmpty);
    expect(rpc.sentRequests, hasLength(3));
  });

  test('4000 receipt events persist while network ACKs are blocked', () async {
    final gate = Completer<void>();
    final rpc = _FakeMessagingRpc()
      ..ackGate = gate
      ..deliveries = [
        for (var index = 0; index < 4000; index++)
          _delivery(id: 'receipt-$index', messageId: 'sent-$index')
            ..eventType =
                pb.MessageDeliveryEventType.MESSAGE_DELIVERY_EVENT_TYPE_RECEIPT
            ..receiptStatus = pb.DeliveryStatus.DELIVERY_STATUS_READ,
      ];
    final store = _FakeChatStore();
    final repository = _createRepository(
      rpc: rpc,
      store: store,
      ackBatchWindow: const Duration(milliseconds: 25),
    );
    addTearDown(() async {
      if (!gate.isCompleted) gate.complete();
      await repository.stopSync();
    });
    await repository.startSync();
    await _waitForLoad(() => store._receiptStatuses.length == 4000);
    expect(rpc.acknowledged, isEmpty);
    gate.complete();
    await _waitForLoad(() => rpc.acknowledged.length == 4000);
    expect(
      rpc.acknowledgedBatches.every((batch) => batch.length <= 256),
      isTrue,
    );
  });

  test(
    '4096 mixed messages and events drain without losing persisted data',
    () async {
      final gate = Completer<void>();
      final rpc = _FakeMessagingRpc()
        ..ackGate = gate
        ..deliveries = [
          for (var index = 0; index < 2048; index++) ...[
            _delivery(id: 'message-$index', messageId: 'incoming-$index'),
            _delivery(id: 'status-$index', messageId: 'incoming-$index')
              ..eventType = pb
                  .MessageDeliveryEventType
                  .MESSAGE_DELIVERY_EVENT_TYPE_RECEIPT
              ..receiptStatus = pb.DeliveryStatus.DELIVERY_STATUS_READ,
          ],
        ];
      final store = _FakeChatStore();
      final repository = _createRepository(
        rpc: rpc,
        store: store,
        ackBatchWindow: const Duration(milliseconds: 25),
      );
      addTearDown(() async {
        if (!gate.isCompleted) gate.complete();
        await repository.stopSync();
      });
      await repository.startSync();
      await _waitForLoad(() => store.messages.length == 2048);
      expect(
        store.messages.every(
          (message) => message.status == ChatDeliveryStatus.read,
        ),
        isTrue,
      );
      expect(rpc.acknowledged, isEmpty);
      gate.complete();
      await _waitForLoad(() => rpc.acknowledged.length == 4096);
      expect(
        rpc.acknowledged.map((ack) => ack.deliveryId).toSet(),
        hasLength(4096),
      );
    },
  );

  test(
    'secret deliveries and mutations do not hold workers on network ACKs',
    () async {
      final gate = Completer<void>();
      final rpc = _FakeMessagingRpc()..ackGate = gate;
      final store = _FakeChatStore();
      for (var index = 0; index < 1024; index++) {
        store.saveChatMessage(
          ChatMessage(
            messageId: 'original-$index',
            chatId: 'recipient-1',
            senderRecipientId: 'user-2',
            body: 'original',
            createdAt: DateTime.utc(2026),
          ),
        );
      }
      rpc.deliveries = [
        for (var index = 0; index < 1024; index++) ...[
          _secretDelivery(id: 'secret-$index')..messageId = 'encrypted-$index',
          _delivery(id: 'edit-$index', messageId: 'original-$index')
            ..eventId = 'edit-event-$index'
            ..eventType =
                pb.MessageDeliveryEventType.MESSAGE_DELIVERY_EVENT_TYPE_EDITED
            ..payload = utf8.encode('edited'),
        ],
      ];
      final crypto = _FakeSecretChatCryptoPort();
      final repository = _createRepository(
        rpc: rpc,
        store: store,
        secretCrypto: crypto,
        ackBatchWindow: const Duration(milliseconds: 25),
      );
      addTearDown(() async {
        if (!gate.isCompleted) gate.complete();
        await repository.stopSync();
      });
      await repository.startSync();
      await _waitForLoad(
        () =>
            store.secretDeliveries.length == 1024 &&
            store._appliedMutations.length == 1024,
      );
      expect(crypto.decryptCount, 1024);
      expect(rpc.acknowledged, isEmpty);
      gate.complete();
      await _waitForLoad(() => rpc.acknowledged.length == 2048);
    },
  );

  test(
    '1024 sends and durable receipts alternate while preserving chat order',
    () async {
      final rpc = _FakeMessagingRpc().._setReady(false);
      final store = _FakeChatStore();
      final repository = _createRepository(rpc: rpc, store: store);
      addTearDown(repository.stopSync);
      final messageIds = <String>[];
      for (var index = 0; index < 1024; index++) {
        final sent = await repository.sendMessage(
          chatId: 'peer-${index % 8}',
          senderRecipientId: 'user-1',
          body: '$index',
        );
        messageIds.add(sent.messageId);
        store.saveChatMessage(
          ChatMessage(
            messageId: 'read-$index',
            chatId: 'received',
            senderRecipientId: 'peer-user',
            body: 'incoming',
            createdAt: DateTime.utc(2026),
          ),
        );
      }
      await repository.markConversationRead(
        chatId: 'received',
        peerRecipientId: 'peer-user',
      );
      rpc.beforeSend = () {
        if (rpc.sentRequests.length == 1) {
          expect(rpc.sentReadReceipts, isNotEmpty);
          expect(rpc.sentReadReceipts.length, lessThan(1024));
        }
      };
      rpc._setReady(true);
      await _waitForLoad(
        () => store.outbox.isEmpty && store.queuedCommands.isEmpty,
      );
      expect(rpc.sentRequests, hasLength(1024));
      expect(rpc.sentReadReceipts, hasLength(1024));
      expect(rpc.maxConcurrentSends, lessThanOrEqualTo(8));
      for (var peer = 0; peer < 8; peer++) {
        expect(
          rpc.sentRequests
              .where((request) => request.chatId == 'peer-$peer')
              .map((request) => request.messageId),
          [for (var index = peer; index < 1024; index += 8) messageIds[index]],
        );
      }
    },
  );
}

Future<void> _waitForLoad(
  bool Function() condition, {
  Duration timeout = const Duration(seconds: 10),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    if (condition()) return;
    await Future<void>.delayed(const Duration(milliseconds: 1));
  }
  fail('The bounded realtime pipeline did not drain the burst.');
}
