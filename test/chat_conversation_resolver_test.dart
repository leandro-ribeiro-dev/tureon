import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:tureon/core/protocol/recipient.dart';
import 'package:tureon/core/protocol/recipient_type.dart';
import 'package:tureon/core/storage/local_store.dart';
import 'package:tureon/core/storage/message_records.dart';
import 'package:tureon/features/chats/data/services/chat_conversation_resolver.dart';

void main() {
  const session = UserSession(userId: 'account', deviceId: 'phone');
  const room = Recipient(
    id: 'room',
    type: RecipientType.group,
    name: 'Room',
    handle: '',
    isMember: true,
  );
  late LocalStore store;
  setUp(() {
    store = LocalStore.inMemory()..saveSession(session);
  });
  tearDown(() async {
    await Future<void>.delayed(Duration.zero);
    await store.close();
  });

  test('4096 events coalesce hydration and its local write', () async {
    final gate = Completer<Recipient?>();
    var calls = 0;
    var writes = 0;
    final changes = store.watchTableChanges().listen((tables) {
      if (tables.contains('account_recipients')) writes++;
    });
    addTearDown(changes.cancel);
    final resolver = ChatConversationResolver(
      store: store,
      isCurrentSession: (_) => true,
      resolveRoomRecipient: (_, _, _) {
        calls++;
        return gate.future;
      },
    );
    await Future.wait(
      List.generate(
        4096,
        (_) => resolver.resolve(
          'room',
          roomType: RecipientType.group,
          session: session,
        ),
      ),
    );
    expect(calls, 1);
    gate.complete(room);
    await Future<void>.delayed(Duration.zero);
    expect(writes, 1);
    expect(store.loadRecipient('room')?.name, 'Room');
  });

  test('late hydration cannot replace a newer durable room snapshot', () async {
    await store.saveRecipient(room);
    final gate = Completer<Recipient?>();
    final resolver = ChatConversationResolver(
      store: store,
      isCurrentSession: (_) => true,
      resolveRoomRecipient: (_, _, _) => gate.future,
    );
    await resolver.resolve(
      'room',
      roomType: RecipientType.group,
      session: session,
      refreshRoomMetadata: true,
    );
    await store.saveRecipient(
      room.copyWith(name: 'Latest', roomVersion: 42, unreadCount: 7),
    );
    gate.complete(room.copyWith(name: 'Outdated'));
    await Future<void>.delayed(Duration.zero);
    expect(store.loadRecipient('room')?.name, 'Latest');
    expect(store.loadRecipient('room')?.roomVersion, 42);
    expect(store.loadRecipient('room')?.unreadCount, 7);
  });

  test(
    'a removal prevents an in-flight lookup from recreating a room',
    () async {
      final gate = Completer<Recipient?>();
      final resolver = ChatConversationResolver(
        store: store,
        isCurrentSession: (_) => true,
        resolveRoomRecipient: (_, _, _) => gate.future,
      );
      await resolver.resolve(
        'room',
        roomType: RecipientType.group,
        session: session,
      );
      resolver.invalidateRoom('room');
      store.deleteRecipient('room');
      gate.complete(room);
      await Future<void>.delayed(Duration.zero);
      expect(store.loadRecipient('room'), isNull);
    },
  );

  test(
    'distinct-room enrichment stays bounded and old-account results are ignored',
    () async {
      final pending = <Completer<Recipient?>>[];
      var current = true;
      final resolver = ChatConversationResolver(
        store: store,
        isCurrentSession: (_) => current,
        resolveRoomRecipient: (_, _, _) {
          final gate = Completer<Recipient?>();
          pending.add(gate);
          return gate.future;
        },
      );
      for (var i = 0; i < 4096; i++) {
        final fallback = await resolver.resolve(
          'room-$i',
          roomType: RecipientType.group,
          session: session,
        );
        expect(fallback.id, 'room-$i');
      }
      expect(pending.length, 64);
      current = false;
      for (var i = 0; i < pending.length; i++) {
        pending[i].complete(room.copyWith(id: 'room-$i'));
      }
      await Future<void>.delayed(Duration.zero);
      expect(store.loadRecipients(), isEmpty);
    },
  );
}
