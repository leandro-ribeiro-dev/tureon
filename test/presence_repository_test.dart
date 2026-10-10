import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fixnum/fixnum.dart' as fixnum;
import 'package:flutter_test/flutter_test.dart';
import 'package:grpc/grpc.dart';
import 'package:tureon/core/protocol/recipient.dart';
import 'package:tureon/core/protocol/recipient_type.dart';
import 'package:tureon/core/network/realtime_stream_manager.dart';
import 'package:tureon/core/storage/local_store.dart';
import 'package:tureon/core/storage/message_records.dart';
import 'package:tureon/features/presence/data/presence_repository.dart';
import 'package:tureon/generated/proto/tureon.pb.dart' as pb;

void main() {
  late LocalStore store;
  late FakePresenceRpc rpc;
  late List<Recipient> updates;
  late PresenceRepository repository;
  late RealtimeStreamManager streamManager;
  var streamFailures = 0;

  setUp(() async {
    store = LocalStore.inMemory();
    store.saveSession(
      const UserSession(
        userId: 'me',
        accessToken: 'access',
        refreshToken: 'refresh',
        deviceId: 'device-1',
        signalDeviceId: 1,
      ),
    );
    await store.saveRecipient(
      const Recipient(
        id: 'peer',
        type: RecipientType.user,
        name: 'Peer',
        handle: '@peer',
      ),
    );
    rpc = FakePresenceRpc();
    updates = [];
    streamFailures = 0;
    streamManager = RealtimeStreamManager(
      connectivityChanges: const Stream<List<ConnectivityResult>>.empty(),
      reconnectAll: () => repository.reconnect(),
      retryBaseDelay: const Duration(milliseconds: 10),
      retryMaxDelay: const Duration(milliseconds: 100),
    )..start();
    repository = PresenceRepository(
      rpc: rpc,
      store: store,
      onPresenceUpdate: updates.add,
      onStreamFailure: () {
        streamFailures++;
        streamManager.requestReconnect();
      },
    );
  });

  tearDown(() async {
    await streamManager.stop();
    await repository.stopSync();
    store.close();
    await rpc.close();
  });

  test(
    'retries the stream with exponential delay and pauses/resumes',
    () async {
      await repository.startSync();
      await Future<void>.delayed(Duration.zero);
      expect(rpc.streamRequests, 1);
      expect(rpc.heartbeats.map((request) => request.online), [true]);

      rpc.streams.first.addError(StateError('disconnected'));
      await _waitForState(() => rpc.streamRequests == 2);

      rpc.streams[1].addError(StateError('disconnected again'));
      await _waitForState(() => rpc.streamRequests == 3);

      await repository.setForeground(false);
      expect(rpc.heartbeats.last.online, isFalse);
      expect(rpc.streams[2].hasListener, isFalse);
      await repository.setForeground(true);
      await _waitForState(() => rpc.streamRequests == 4);
      expect(rpc.streams.last.hasListener, isTrue);
      expect(rpc.heartbeats.last.online, isTrue);

      await repository.stopSync();
      final requestCount = rpc.streamRequests;
      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(rpc.streamRequests, requestCount);
    },
  );

  test(
    'keeps presence updates ephemeral and emits privacy-aware state',
    () async {
      await repository.startSync();
      final stream = rpc.streams.single;
      stream.add(
        pb.PresenceServerEvent(
          presence: pb.PresenceUpdate(
            recipientId: 'peer',
            online: true,
            lastSeen: fixnum.Int64(100),
          ),
        ),
      );
      await Future<void>.delayed(Duration.zero);

      var saved = store.loadRecipient('peer')!;
      expect(saved.isOnline, isFalse);
      expect(saved.isPresenceVisible, isFalse);
      expect(updates.single.presenceUpdate, isTrue);
      expect(updates.single.isOnline, isTrue);
      expect(updates.single.isPresenceVisible, isTrue);

      stream.add(
        pb.PresenceServerEvent(
          presence: pb.PresenceUpdate(
            recipientId: 'peer',
            online: true,
            lastSeen: fixnum.Int64.ZERO,
          ),
        ),
      );
      await Future<void>.delayed(Duration.zero);
      saved = store.loadRecipient('peer')!;
      expect(saved.isOnline, isFalse);
      expect(saved.isPresenceVisible, isFalse);
      expect(store.loadRecipients().single.isPresenceVisible, isFalse);
      expect(updates.last.isOnline, isFalse);
      expect(updates.last.isPresenceVisible, isFalse);
    },
  );

  test(
    'explicit visibility shows online without a previous last-seen date',
    () async {
      await repository.startSync();
      rpc.streams.single.add(
        pb.PresenceServerEvent(
          presence: pb.PresenceUpdate(
            recipientId: 'peer',
            online: true,
            presenceVisible: true,
          ),
        ),
      );
      await Future<void>.delayed(Duration.zero);
      expect(updates.last.isOnline, isTrue);
      expect(updates.last.isPresenceVisible, isTrue);
      expect(updates.last.lastSeenAt, isNull);
      rpc.streams.single.add(
        pb.PresenceServerEvent(
          presence: pb.PresenceUpdate(
            recipientId: 'peer',
            online: true,
            presenceVisible: false,
            lastSeen: fixnum.Int64(100),
          ),
        ),
      );
      await Future<void>.delayed(Duration.zero);
      expect(updates.last.isOnline, isFalse);
      expect(updates.last.isPresenceVisible, isFalse);
      expect(updates.last.lastSeenAt, isNull);
    },
  );

  test(
    'new synchronized conversations refresh presence subscriptions once',
    () async {
      await repository.startSync();
      for (var i = 0; i < 64; i++) {
        await store.saveRecipient(
          Recipient(
            id: 'new-peer-$i',
            type: RecipientType.user,
            name: 'Peer',
            handle: '',
          ),
        );
      }
      await Future<void>.delayed(const Duration(milliseconds: 160));
      expect(rpc.streamRequests, 1);
      expect(rpc.watches, hasLength(2));
      expect(rpc.watches.last.recipientIds, hasLength(65));
      expect(rpc.heartbeats.every((heartbeat) => heartbeat.online), isTrue);
      expect(streamFailures, 0);
    },
  );

  test(
    'intentional stream replacement does not schedule reconnect retries',
    () async {
      await repository.startSync();

      await repository.reconnect();
      await Future<void>.delayed(const Duration(milliseconds: 30));

      expect(rpc.streamRequests, 2);
      expect(streamFailures, 0);
    },
  );

  test('overlapping foreground transitions replace the stream once', () async {
    await repository.startSync();
    final oldStream = rpc.streams.single;

    await Future.wait([
      repository.setForeground(false),
      repository.setForeground(true),
    ]);

    expect(rpc.streamRequests, 2);
    expect(oldStream.hasListener, isFalse);
    expect(rpc.streams.last.hasListener, isTrue);
  });

  test(
    'does not retry Realtime when the server reports UNIMPLEMENTED',
    () async {
      await repository.startSync();
      rpc.streams.single.addError(GrpcError.unimplemented('unknown method'));

      await Future<void>.delayed(const Duration(milliseconds: 30));

      expect(streamFailures, 0);
      expect(rpc.streamRequests, 1);
    },
  );

  test(
    'incoming typing updates propagate through the recipient stream',
    () async {
      await repository.startSync();
      final stream = rpc.streams.single;

      stream.add(
        pb.PresenceServerEvent(
          typing: pb.TypingIndicator(
            senderRecipientId: 'peer',
            targetRecipientId: 'me',
            isTyping: true,
          ),
        ),
      );
      await Future<void>.delayed(Duration.zero);
      expect(updates.last.isTyping, isTrue);

      stream.add(
        pb.PresenceServerEvent(
          typing: pb.TypingIndicator(
            senderRecipientId: 'peer',
            targetRecipientId: 'me',
            isTyping: false,
          ),
        ),
      );
      await Future<void>.delayed(Duration.zero);
      expect(updates.last.isTyping, isFalse);
    },
  );

  test('room typing is scoped to its group and stays ephemeral', () async {
    await store.saveRecipient(
      const Recipient(
        id: 'room-1',
        type: RecipientType.group,
        name: 'Room',
        handle: '',
      ),
    );
    await repository.startSync();
    rpc.streams.single.add(
      pb.PresenceServerEvent(
        typing: pb.TypingIndicator(
          senderRecipientId: 'peer',
          targetRecipientId: 'room-1',
          isTyping: true,
        ),
      ),
    );
    await Future<void>.delayed(Duration.zero);

    expect(updates.last.id, 'room-1');
    expect(updates.last.isTyping, isTrue);
    expect(store.loadRecipient('room-1')!.isTyping, isFalse);

    rpc.streams.single.add(
      pb.PresenceServerEvent(
        typing: pb.TypingIndicator(
          senderRecipientId: 'peer',
          targetRecipientId: 'room-1',
          isTyping: false,
        ),
      ),
    );
    await Future<void>.delayed(Duration.zero);
    expect(updates.last.id, 'room-1');
    expect(updates.last.isTyping, isFalse);
  });

  test('sends typing changes through the active realtime stream', () async {
    await repository.startSync();
    await repository.sendTypingIndicator(
      targetRecipientId: 'peer',
      isTyping: true,
    );
    await Future<void>.delayed(Duration.zero);

    expect(rpc.sentTypingIndicators, hasLength(1));
    expect(rpc.sentTypingIndicators.single.senderRecipientId, 'me');
    expect(rpc.sentTypingIndicators.single.targetRecipientId, 'peer');
    expect(rpc.sentTypingIndicators.single.isTyping, isTrue);
  });

  test('typing indicators are rate-limited and false is immediate', () async {
    final sent = <bool>[];
    final typing = TypingIndicatorDebouncer(
      send: (isTyping) async => sent.add(isTyping),
      interval: const Duration(milliseconds: 40),
    );

    typing.setTyping(true);
    typing.setTyping(true);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(sent, [true]);
    await Future<void>.delayed(const Duration(milliseconds: 30));
    expect(sent, [true, true]);

    typing.setTyping(false);
    expect(sent, [true, true, false]);
    typing.setTyping(false);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(sent, [true, true, false]);
    typing.dispose();
  });

  test('disposing while typing sends a final false indicator', () async {
    final sent = <bool>[];
    final typing = TypingIndicatorDebouncer(
      send: (isTyping) async => sent.add(isTyping),
      interval: const Duration(seconds: 3),
    );

    typing.setTyping(true);
    typing.dispose();
    await Future<void>.delayed(Duration.zero);
    expect(sent, [true, false]);
  });
}

Future<void> _waitForState(bool Function() condition) async {
  for (var attempt = 0; attempt < 1000; attempt++) {
    if (condition()) return;
    await Future<void>.delayed(const Duration(milliseconds: 1));
  }
  fail('Timed out waiting for the presence repository state.');
}

class FakePresenceRpc implements PresenceRpc {
  final List<pb.PresenceWatch> watches = [];
  final List<pb.PresenceUpdate> heartbeats = [];
  final List<pb.TypingIndicator> sentTypingIndicators = [];
  final List<StreamController<pb.PresenceServerEvent>> streams = [];
  final List<StreamSubscription<pb.PresenceClientEvent>> requestSubscriptions =
      [];
  int streamRequests = 0;

  @override
  Stream<pb.PresenceServerEvent> realtime(
    Stream<pb.PresenceClientEvent> requests,
  ) {
    streamRequests++;
    final controller = StreamController<pb.PresenceServerEvent>();
    streams.add(controller);
    requestSubscriptions.add(
      requests.listen((event) {
        switch (event.whichEvent()) {
          case pb.PresenceClientEvent_Event.heartbeat:
            heartbeats.add(pb.PresenceUpdate(online: event.heartbeat.online));
            break;
          case pb.PresenceClientEvent_Event.typing:
            sentTypingIndicators.add(event.typing);
            break;
          case pb.PresenceClientEvent_Event.watch:
            watches.add(event.watch);
            break;
          case pb.PresenceClientEvent_Event.notSet:
            break;
        }
      }, onDone: controller.close),
    );
    return controller.stream;
  }

  Future<void> close() async {
    for (final requestSubscription in requestSubscriptions) {
      await requestSubscription.cancel();
    }
    for (final stream in streams) {
      await stream.close();
    }
  }
}
