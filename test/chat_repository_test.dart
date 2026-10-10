import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:fixnum/fixnum.dart';
import 'package:grpc/grpc.dart';
import 'package:tureon/core/storage/chat_store.dart';
import 'package:tureon/core/storage/local_store.dart';
import 'package:tureon/core/storage/message_records.dart';
import 'package:tureon/core/protocol/recipient.dart';
import 'package:tureon/core/protocol/recipient_type.dart';
import 'package:tureon/core/protocol/verification_badge.dart';
import 'package:tureon/core/crypto/secret_chat_crypto_port.dart';
import 'package:tureon/features/chats/domain/chat_repository.dart';
import 'package:tureon/features/chats/data/grpc_chat_repository.dart';
import 'package:tureon/features/chats/data/services/messaging_rpc.dart';
import 'package:tureon/features/chats/domain/chat_message.dart';
import 'package:tureon/features/chats/domain/message_translation.dart';
import 'package:tureon/generated/proto/tureon.pb.dart' as pb;

part 'chat_repository_load_cases.dart';

void main() {
  realtimeLoadCases();
  test('sends normal chat payload and keeps sent message locally', () async {
    final rpc = _FakeMessagingRpc();
    final store = _FakeChatStore();
    await store.saveRecipient(
      const Recipient(
        id: 'recipient-1',
        type: RecipientType.user,
        name: 'Peer',
        handle: '@peer',
      ),
    );
    final repository = _createRepository(rpc: rpc, store: store);
    rpc.beforeSend = () {
      expect(store.messages.single.status, ChatDeliveryStatus.sending);
      expect(store.outbox.single.status, OutboxStatus.sending);
    };

    final sent = await repository.sendMessage(
      chatId: 'recipient-1',
      senderRecipientId: 'user-1',
      body: 'hello',
    );

    expect(sent.body, 'hello');
    expect(sent.status, ChatDeliveryStatus.pending);
    expect(
      store.loadChatMessage(sent.messageId)?.status,
      ChatDeliveryStatus.pending,
    );
    await _waitFor(
      () =>
          store.loadChatMessage(sent.messageId)?.status ==
          ChatDeliveryStatus.sent,
    );
    expect(rpc.lastSendRequest!.chatKind, pb.ChatKind.CHAT_KIND_NORMAL);
    expect(rpc.lastSendRequest!.senderDeviceId, 'device-1');
    expect(rpc.lastSendRequest!.targetRecipientId, 'recipient-1');
    expect(utf8.decode(rpc.lastSendRequest!.payload), 'hello');
    expect(store.messages.single.messageId, sent.messageId);
    expect(store.loadRecipient('recipient-1')?.lastMessage, 'hello');
    expect(
      store.canonicalTimestamps[sent.messageId],
      DateTime.fromMicrosecondsSinceEpoch(
        rpc.serverTimestampMicros,
        isUtc: true,
      ),
    );
    expect(
      repository.loadLocalHistory(chatId: 'recipient-1').single.body,
      'hello',
    );
  });

  test('opens a new local conversation and reuses existing metadata', () async {
    final rpc = _FakeMessagingRpc();
    final store = _FakeChatStore();
    final repository = _createRepository(rpc: rpc, store: store);
    const recipient = Recipient(
      id: 'recipient-1',
      type: RecipientType.user,
      name: 'Alice',
      handle: '@alice',
      avatarUrl: 'https://example.test/alice.png',
      isUsernameVisible: true,
      composerRole: 'owner',
      canSendMessages: true,
    );

    final opened = await repository.openOrCreateChat(
      recipientId: recipient.id,
      recipient: recipient,
    );
    expect(opened.id, recipient.id);
    expect(opened.name, recipient.name);
    expect(opened.avatarUrl, recipient.avatarUrl);
    expect(opened.composerRole, 'owner');
    expect(opened.canSendMessages, isTrue);
    expect(store.loadRecipient(recipient.id)?.name, recipient.name);
    expect(store.messages, isEmpty);
    expect(rpc.lastSendRequest, isNull);

    final existing = await repository.openOrCreateChat(
      recipientId: recipient.id,
      recipient: const Recipient(
        id: 'recipient-1',
        type: RecipientType.user,
        name: 'Changed search result',
        handle: '@changed',
      ),
    );
    expect(existing.name, recipient.name);
    expect(store.recipientWrites, 1);
  });

  test('queues new sends offline and transmits after stream readiness', () async {
    final rpc = _FakeMessagingRpc().._setReady(false);
    final store = _FakeChatStore();
    final repository = _createRepository(rpc: rpc, store: store);

    final message = await repository.sendMessage(
      chatId: 'recipient-1',
      senderRecipientId: 'user-1',
      body: 'deliver after reconnect',
    );

    expect(
      store.loadChatMessage(message.messageId)?.status,
      ChatDeliveryStatus.pending,
    );
    expect(
      RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
      ).hasMatch(message.messageId),
      isTrue,
    );
    expect(store.outbox.single.messageId, message.messageId);
    expect(rpc.sentRequests, isEmpty);

    rpc._setReady(true);
    await _waitFor(
      () =>
          store.loadChatMessage(message.messageId)?.status ==
          ChatDeliveryStatus.sent,
    );
    expect(rpc.sentRequests.single.messageId, message.messageId);
    expect(store.outbox, isEmpty);
  });

  test(
    'queues bot messages offline and stores the bot reply after reconnect',
    () async {
      final rpc = _FakeMessagingRpc().._setReady(false);
      final store = _FakeChatStore();
      const bot = Recipient(
        id: 'bot-1',
        type: RecipientType.bot,
        name: 'Forja',
        handle: '@forja_bot',
      );
      await store.saveRecipient(bot);
      final repository = _createRepository(rpc: rpc, store: store);

      final request = await repository.sendBotMessage(
        recipient: bot,
        senderRecipientId: 'user-1',
        body: '/help',
      );

      expect(request.status, ChatDeliveryStatus.pending);
      expect(store.outbox.single.messageId, request.messageId);
      expect(rpc.sentBotRequests, isEmpty);

      rpc._setReady(true);
      await _waitFor(
        () => store.loadChatMessage('${request.messageId}-reply') != null,
      );
      expect(rpc.sentBotRequests.single.botUsername, 'forja_bot');
      expect(rpc.sentBotRequests.single.clientMessageId, request.messageId);
      expect(
        store.loadChatMessage(request.messageId)?.status,
        ChatDeliveryStatus.sent,
      );
      expect(
        store.loadChatMessage('${request.messageId}-reply')?.body,
        'bot response',
      );
      expect(store.loadRecipient(bot.id)?.unreadCount, 1);
      expect(
        store.loadChatMessage('${request.messageId}-reply')?.status,
        ChatDeliveryStatus.sent,
      );
      expect(store.outbox, isEmpty);
    },
  );

  test(
    'returns an in-flight bot message to pending after stream loss',
    () async {
      final rpc = _FakeMessagingRpc();
      final store = _FakeChatStore();
      const bot = Recipient(
        id: 'bot-1',
        type: RecipientType.bot,
        name: 'Forja',
        handle: '@forja_bot',
      );
      await store.saveRecipient(bot);
      final repository = _createRepository(rpc: rpc, store: store);

      final request = await repository.sendBotMessage(
        recipient: bot,
        senderRecipientId: 'user-1',
        body: '/help',
      );
      rpc.beforeSend = () {
        rpc.sendFailure = GrpcError.unavailable('network offline');
        rpc._setReady(false);
      };

      await _waitFor(
        () =>
            rpc.sentBotRequests.length == 1 &&
            store.loadChatMessage(request.messageId)?.status ==
                ChatDeliveryStatus.pending,
      );
      expect(store.outbox.single.status, OutboxStatus.pending);
      expect(rpc.sentBotRequests, hasLength(1));

      rpc.beforeSend = null;
      rpc.sendFailure = null;
      rpc._setReady(true);
      await _waitFor(
        () => store.loadChatMessage('${request.messageId}-reply') != null,
      );

      expect(rpc.sentBotRequests, hasLength(2));
      expect(
        rpc.sentBotRequests.map((message) => message.clientMessageId).toSet(),
        {request.messageId},
      );
      expect(store.outbox, isEmpty);
      await repository.close();
    },
  );

  test('does not mark bot replies unread while the bot chat is open', () async {
    final rpc = _FakeMessagingRpc().._setReady(false);
    final store = _FakeChatStore();
    const bot = Recipient(
      id: 'bot-1',
      type: RecipientType.bot,
      name: 'Forja',
      handle: '@forja_bot',
    );
    await store.saveRecipient(bot);
    final repository = _createRepository(rpc: rpc, store: store);
    final subscription = repository
        .streamMessages(chatId: bot.id)
        .listen((_) {});

    final request = await repository.sendBotMessage(
      recipient: bot,
      senderRecipientId: 'user-1',
      body: '/help',
    );
    rpc._setReady(true);
    await _waitFor(
      () => store.loadChatMessage('${request.messageId}-reply') != null,
    );

    expect(store.loadRecipient(bot.id)?.unreadCount, 0);
    expect(
      store.loadChatMessage('${request.messageId}-reply')?.status,
      ChatDeliveryStatus.read,
    );
    await subscription.cancel();
    await repository.stopSync();
  });

  test('edits and deletes messages through mutation RPCs', () async {
    final rpc = _FakeMessagingRpc();
    final store = _FakeChatStore();
    store.saveChatMessage(
      ChatMessage(
        messageId: 'message-1',
        chatId: 'recipient-1',
        senderRecipientId: 'user-1',
        body: 'before',
        createdAt: DateTime.utc(2026),
      ),
    );
    final repository = _createRepository(rpc: rpc, store: store);

    final edited = await repository.editMessage(
      messageId: 'message-1',
      chatId: 'recipient-1',
      targetRecipientId: 'recipient-1',
      isSecret: false,
      body: 'after',
    );
    expect(edited.body, 'after');
    await _waitFor(() => rpc.sentMutations.length == 1);
    expect(
      rpc.sentMutations.single.mutationType,
      pb.MessageMutationType.MESSAGE_MUTATION_TYPE_EDIT,
    );
    expect(utf8.decode(rpc.sentMutations.single.payload), 'after');
    expect(store.loadChatMessage('message-1')?.body, 'after');

    await repository.deleteMessage(
      messageId: 'message-1',
      chatId: 'recipient-1',
      targetRecipientId: 'recipient-1',
      isSecret: false,
    );
    await _waitFor(() => rpc.sentMutations.length == 2);
    expect(rpc.sentMutations, hasLength(2));
    expect(
      rpc.sentMutations.last.mutationType,
      pb.MessageMutationType.MESSAGE_MUTATION_TYPE_DELETE,
    );
    expect(
      rpc.sentMutations.last.mutationId,
      isNot(rpc.sentMutations.first.mutationId),
    );
    expect(store.isChatMessageDeleted('message-1'), isTrue);
    expect(store.loadChatMessage('message-1'), isNull);
  });

  test(
    'keeps optimistic mutations queued when the stream command fails',
    () async {
      final rpc = _FakeMessagingRpc()
        ..failure = StateError('stream disconnected');
      final store = _FakeChatStore();
      final original = ChatMessage(
        messageId: 'message-rollback',
        chatId: 'recipient-1',
        senderRecipientId: 'user-1',
        body: 'before',
        createdAt: DateTime.utc(2026),
      );
      store.saveChatMessage(original);
      final repository = _createRepository(rpc: rpc, store: store);

      await repository.editMessage(
        messageId: original.messageId,
        chatId: original.chatId,
        targetRecipientId: original.chatId,
        isSecret: false,
        body: 'after',
      );
      expect(store.loadChatMessage(original.messageId)?.body, 'after');

      await repository.deleteMessage(
        messageId: original.messageId,
        chatId: original.chatId,
        targetRecipientId: original.chatId,
        isSecret: false,
      );
      expect(store.loadChatMessage(original.messageId), isNull);
      expect(store.isChatMessageDeleted(original.messageId), isTrue);
      expect(store.queuedCommands, hasLength(2));
      await repository.stopSync();
    },
  );

  test('secret message edits encrypt once before mutation RPC', () async {
    final rpc = _FakeMessagingRpc();
    final store = _FakeChatStore();
    final crypto = _FakeSecretChatCryptoPort();
    store.saveChatMessage(
      ChatMessage(
        messageId: 'secret-message',
        chatId: 'secret/recipient-1/device-1/recipient-device-1',
        senderRecipientId: 'user-1',
        body: 'before',
        createdAt: DateTime.utc(2026),
      ),
    );
    final repository = _createRepository(
      rpc: rpc,
      store: store,
      secretCrypto: crypto,
    );

    await repository.editMessage(
      messageId: 'secret-message',
      chatId: 'recipient-1',
      targetRecipientId: 'recipient-1',
      isSecret: true,
      targetDeviceId: 'recipient-device-1',
      body: 'private edit',
    );

    await _waitFor(() => rpc.sentMutations.length == 1);
    expect(crypto.encryptCount, 1);
    expect(crypto.plaintext, utf8.encode('private edit'));
    expect(rpc.sentMutations.single.chatKind, pb.ChatKind.CHAT_KIND_SECRET);
    expect(rpc.sentMutations.single.targetDeviceId, 'recipient-device-1');
    expect(rpc.sentMutations.single.payload, crypto.ciphertext);
  });

  test('queues offline message edits and deletions for reconnection', () async {
    final rpc = _FakeMessagingRpc().._setReady(false);
    final store = _FakeChatStore();
    store.saveChatMessage(
      ChatMessage(
        messageId: 'offline-edit',
        chatId: 'peer',
        senderRecipientId: 'user-1',
        body: 'before',
        createdAt: DateTime.utc(2026),
      ),
    );
    store.saveChatMessage(
      ChatMessage(
        messageId: 'offline-delete',
        chatId: 'peer',
        senderRecipientId: 'user-1',
        body: 'remove me',
        createdAt: DateTime.utc(2026),
      ),
    );
    final repository = _createRepository(rpc: rpc, store: store);

    final edited = await repository.editMessage(
      messageId: 'offline-edit',
      chatId: 'peer',
      targetRecipientId: 'peer',
      isSecret: false,
      body: 'edited offline',
    );
    await repository.deleteMessage(
      messageId: 'offline-delete',
      chatId: 'peer',
      targetRecipientId: 'peer',
      isSecret: false,
    );

    expect(edited.body, 'edited offline');
    expect(edited.editedAt, isNotNull);
    expect(store.loadChatMessage('offline-edit')?.body, 'edited offline');
    expect(store.loadChatMessage('offline-delete'), isNull);
    expect(store.isChatMessageDeleted('offline-delete'), isTrue);
    expect(store.queuedCommands, hasLength(2));
    expect(rpc.sentMutations, isEmpty);

    rpc._setReady(true);
    await _waitFor(() => rpc.sentMutations.length == 2);
    expect(store.queuedCommands, isEmpty);
    expect(
      rpc.sentMutations.map((request) => request.mutationType),
      containsAll([
        pb.MessageMutationType.MESSAGE_MUTATION_TYPE_EDIT,
        pb.MessageMutationType.MESSAGE_MUTATION_TYPE_DELETE,
      ]),
    );
  });

  test('serializes secret edits and deletion through the ratchet', () async {
    final rpc = _FakeMessagingRpc();
    final firstGate = Completer<void>();
    final secondGate = Completer<void>();
    rpc.mutationGates.addAll([firstGate, secondGate]);
    final store = _FakeChatStore();
    final crypto = _FakeSecretChatCryptoPort();
    store.saveChatMessage(
      ChatMessage(
        messageId: 'secret-message',
        chatId: 'secret/recipient-1/device-1/recipient-device-1',
        senderRecipientId: 'user-1',
        body: 'before',
        createdAt: DateTime.utc(2026),
      ),
    );
    final repository = _createRepository(
      rpc: rpc,
      store: store,
      secretCrypto: crypto,
    );
    final edit = repository.editMessage(
      messageId: 'secret-message',
      chatId: 'recipient-1',
      targetRecipientId: 'recipient-1',
      isSecret: true,
      targetDeviceId: 'recipient-device-1',
      body: 'after',
    );
    final deletion = repository.deleteMessage(
      messageId: 'secret-message',
      chatId: 'recipient-1',
      targetRecipientId: 'recipient-1',
      isSecret: true,
      targetDeviceId: 'recipient-device-1',
    );

    await _waitFor(() => rpc.sentMutations.length == 1);
    expect(crypto.encryptCount, 2);
    firstGate.complete();
    await _waitFor(() => rpc.sentMutations.length == 2);
    expect(crypto.encryptCount, 2);
    expect(rpc.sentMutations.map((request) => request.mutationType), [
      pb.MessageMutationType.MESSAGE_MUTATION_TYPE_EDIT,
      pb.MessageMutationType.MESSAGE_MUTATION_TYPE_DELETE,
    ]);
    secondGate.complete();
    await Future.wait([edit, deletion]);
  });

  test(
    'persists remote edits and deletion tombstones before acknowledging',
    () async {
      final rpc = _FakeMessagingRpc()
        ..deliveries = [
          pb.MessageDelivery(
            deliveryId: 'edit-delivery',
            messageId: 'message-1',
            chatId: 'peer-1',
            senderRecipientId: 'peer-1',
            targetRecipientId: 'user-1',
            targetDeviceId: 'device-1',
            chatKind: pb.ChatKind.CHAT_KIND_NORMAL,
            payload: utf8.encode('remote edit'),
            createdAt: Int64(1_790_000_001),
            eventId: 'mutation-edit',
            eventType:
                pb.MessageDeliveryEventType.MESSAGE_DELIVERY_EVENT_TYPE_EDITED,
          ),
          pb.MessageDelivery(
            deliveryId: 'delete-delivery',
            messageId: 'message-1',
            chatId: 'peer-1',
            senderRecipientId: 'peer-1',
            targetRecipientId: 'user-1',
            targetDeviceId: 'device-1',
            chatKind: pb.ChatKind.CHAT_KIND_NORMAL,
            createdAt: Int64(1_790_000_002),
            eventId: 'mutation-delete',
            eventType:
                pb.MessageDeliveryEventType.MESSAGE_DELIVERY_EVENT_TYPE_DELETED,
          ),
        ];
      final store = _FakeChatStore();
      store.saveChatMessage(
        ChatMessage(
          messageId: 'message-1',
          chatId: 'peer-1',
          senderRecipientId: 'peer-1',
          body: 'original',
          createdAt: DateTime.utc(2026),
        ),
      );
      final repository = _createRepository(rpc: rpc, store: store);
      await repository.startSync();
      final subscription = repository
          .streamMessages(chatId: 'peer-1')
          .listen((_) {}, onError: (Object _) {});

      await _waitFor(() => rpc.acknowledged.length == 2);
      expect(store.isChatMessageDeleted('message-1'), isTrue);
      expect(store.loadChatMessage('message-1'), isNull);
      await subscription.cancel();
      await repository.stopSync();
    },
  );

  test('defers a mutation until its original message arrives', () async {
    final rpc = _FakeMessagingRpc()
      ..deliveries = [
        pb.MessageDelivery(
          deliveryId: 'edit-first',
          messageId: 'message-late',
          chatId: 'peer-1',
          senderRecipientId: 'peer-1',
          targetRecipientId: 'user-1',
          targetDeviceId: 'device-1',
          chatKind: pb.ChatKind.CHAT_KIND_NORMAL,
          payload: utf8.encode('edited'),
          createdAt: Int64(1_790_000_001),
          eventId: 'mutation-first',
          eventType:
              pb.MessageDeliveryEventType.MESSAGE_DELIVERY_EVENT_TYPE_EDITED,
        ),
        pb.MessageDelivery(
          deliveryId: 'message-later',
          messageId: 'message-late',
          chatId: 'peer-1',
          senderRecipientId: 'peer-1',
          targetRecipientId: 'user-1',
          targetDeviceId: 'device-1',
          chatKind: pb.ChatKind.CHAT_KIND_NORMAL,
          payload: utf8.encode('original'),
          createdAt: Int64(1_790_000_000),
        ),
      ];
    final store = _FakeChatStore();
    final repository = _createRepository(rpc: rpc, store: store);
    await repository.startSync();
    final subscription = repository
        .streamMessages(chatId: 'peer-1')
        .listen((_) {}, onError: (Object _) {});

    await _waitFor(() => rpc.acknowledged.length == 2);

    expect(store.loadChatMessage('message-late')?.body, 'edited');
    expect(
      rpc.acknowledged.map((ack) => ack.deliveryId),
      containsAll(['edit-first', 'message-later']),
    );
    await subscription.cancel();
    await repository.stopSync();
  });

  test(
    'persists a message before applying its following stream mutation',
    () async {
      final rpc = _FakeMessagingRpc()
        ..deliveries = [
          pb.MessageDelivery(
            deliveryId: 'message-delivery',
            messageId: 'message-raced',
            chatId: 'peer-1',
            senderRecipientId: 'peer-1',
            targetRecipientId: 'user-1',
            targetDeviceId: 'device-1',
            chatKind: pb.ChatKind.CHAT_KIND_NORMAL,
            payload: utf8.encode('original'),
            createdAt: Int64(1_790_000_000),
          ),
          pb.MessageDelivery(
            deliveryId: 'edit-delivery',
            messageId: 'message-raced',
            chatId: 'peer-1',
            senderRecipientId: 'peer-1',
            targetRecipientId: 'user-1',
            targetDeviceId: 'device-1',
            chatKind: pb.ChatKind.CHAT_KIND_NORMAL,
            payload: utf8.encode('edited'),
            createdAt: Int64(1_790_000_001),
            eventId: 'mutation-raced',
            eventType:
                pb.MessageDeliveryEventType.MESSAGE_DELIVERY_EVENT_TYPE_EDITED,
          ),
        ];
      final store = _FakeChatStore();
      final repository = _createRepository(rpc: rpc, store: store);
      await repository.startSync();
      final subscription = repository
          .streamMessages(chatId: 'peer-1')
          .listen((_) {}, onError: (Object _) {});

      await _waitFor(() => rpc.acknowledged.length == 2);

      expect(store.loadChatMessage('message-raced')?.body, 'edited');
      await subscription.cancel();
      await repository.stopSync();
    },
  );

  test(
    'secret mutation decrypts once when a persisted delivery is repeated',
    () async {
      final event = pb.MessageDelivery(
        deliveryId: 'secret-edit-delivery',
        messageId: 'secret-message',
        chatId: 'peer-1',
        senderRecipientId: 'peer-1',
        senderDeviceId: 'peer-device',
        targetRecipientId: 'user-1',
        targetDeviceId: 'device-1',
        chatKind: pb.ChatKind.CHAT_KIND_SECRET,
        payload: [1, 2, 3],
        createdAt: Int64(1_790_000_010),
        eventId: 'secret-mutation',
        eventType:
            pb.MessageDeliveryEventType.MESSAGE_DELIVERY_EVENT_TYPE_EDITED,
      );
      final rpc = _FakeMessagingRpc()
        ..deliveries = [
          event,
          pb.MessageDelivery(
            deliveryId: 'secret-edit-retry',
            messageId: event.messageId,
            chatId: event.chatId,
            senderRecipientId: event.senderRecipientId,
            senderDeviceId: event.senderDeviceId,
            targetRecipientId: event.targetRecipientId,
            targetDeviceId: event.targetDeviceId,
            chatKind: event.chatKind,
            payload: event.payload,
            createdAt: event.createdAt,
            eventType: event.eventType,
            eventId: event.eventId,
          ),
        ];
      final store = _FakeChatStore();
      store.saveChatMessage(
        ChatMessage(
          messageId: 'secret-message',
          chatId: 'secret/peer-1/device-1/peer-device',
          senderRecipientId: 'peer-1',
          body: 'before',
          createdAt: DateTime.utc(2026),
        ),
      );
      final crypto = _FakeSecretChatCryptoPort()
        ..decryptedText = Uint8List.fromList(utf8.encode('private edit'));
      final repository = _createRepository(
        rpc: rpc,
        store: store,
        secretCrypto: crypto,
      );
      await repository.startSync();
      final subscription = repository
          .streamMessages(chatId: 'secret/peer-1/device-1/peer-device')
          .listen((_) {});

      await _waitFor(() => rpc.acknowledged.length == 2);
      expect(store.loadChatMessage('secret-message')?.body, 'private edit');
      expect(crypto.decryptCount, 1);
      await subscription.cancel();
      await repository.stopSync();
    },
  );

  test(
    'does not acknowledge a mutation when local persistence fails',
    () async {
      final rpc = _FakeMessagingRpc()
        ..deliveries = [
          pb.MessageDelivery(
            deliveryId: 'edit-delivery',
            messageId: 'message-1',
            chatId: 'peer-1',
            senderRecipientId: 'peer-1',
            targetRecipientId: 'user-1',
            targetDeviceId: 'device-1',
            chatKind: pb.ChatKind.CHAT_KIND_NORMAL,
            payload: utf8.encode('remote edit'),
            createdAt: Int64(1_790_000_001),
            eventId: 'mutation-edit',
            eventType:
                pb.MessageDeliveryEventType.MESSAGE_DELIVERY_EVENT_TYPE_EDITED,
          ),
        ];
      final store = _FakeChatStore()..failMessageWrites = true;
      store._messages['message-1'] = ChatMessage(
        messageId: 'message-1',
        chatId: 'peer-1',
        senderRecipientId: 'peer-1',
        body: 'original',
        createdAt: DateTime.utc(2026),
      );
      final repository = _createRepository(rpc: rpc, store: store);
      await repository.startSync();
      final subscription = repository
          .streamMessages(chatId: 'peer-1')
          .listen((_) {}, onError: (Object _) {});

      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(rpc.acknowledged, isEmpty);
      await subscription.cancel();
      await repository.stopSync();
    },
  );

  test(
    'encrypts secret text before any payload reaches the messaging RPC',
    () async {
      final rpc = _FakeMessagingRpc();
      final store = _FakeChatStore();
      final crypto = _FakeSecretChatCryptoPort();
      final repository = _createRepository(
        rpc: rpc,
        store: store,
        secretCrypto: crypto,
        retryBaseDelay: const Duration(milliseconds: 2),
        retryMaxDelay: const Duration(milliseconds: 2),
        random: math.Random(1),
      );
      rpc.beforeSend = () {
        expect(crypto.encryptCount, 1);
        expect(store.outbox.single.payload, crypto.ciphertext);
        rpc.sendFailure = rpc.sentRequests.length == 1
            ? GrpcError.unavailable('network offline')
            : null;
        if (rpc.sentRequests.length > 1) {
          rpc.sendStatus = pb.SendMessageStatus.SEND_MESSAGE_STATUS_DUPLICATE;
        }
      };

      final message = await repository.sendSecretMessage(
        chatId: 'recipient-1',
        senderRecipientId: 'user-1',
        recipientServerDeviceId: 'recipient-device-1',
        body: 'plaintext must stay local',
      );
      await _waitFor(
        () =>
            store.loadChatMessage(message.messageId)?.status ==
            ChatDeliveryStatus.sent,
      );

      expect(crypto.plaintext, utf8.encode('plaintext must stay local'));
      expect(rpc.lastSendRequest!.chatKind, pb.ChatKind.CHAT_KIND_SECRET);
      expect(rpc.lastSendRequest!.targetDeviceId, 'recipient-device-1');
      expect(rpc.lastSendRequest!.payload, crypto.ciphertext);
      expect(rpc.lastSendRequest!.payload, isNot(utf8.encode(message.body)));
      expect(rpc.sentRequests, hasLength(2));
      expect(rpc.sentRequests[0].messageId, rpc.sentRequests[1].messageId);
      expect(rpc.sentRequests[0].payload, rpc.sentRequests[1].payload);
      expect(crypto.encryptCount, 1);
      expect(store.messages.single.body, 'plaintext must stay local');
      expect(
        store.messages.single.chatId,
        secretChatLocalId(
          recipientId: 'recipient-1',
          firstDeviceId: 'device-1',
          secondDeviceId: 'recipient-device-1',
        ),
      );
    },
  );

  test('blocks secret sends when crypto is not initialized', () async {
    final rpc = _FakeMessagingRpc();
    final store = _FakeChatStore();
    final repository = _createRepository(rpc: rpc, store: store);

    await expectLater(
      repository.sendSecretMessage(
        chatId: 'recipient-1',
        senderRecipientId: 'user-1',
        recipientServerDeviceId: 'recipient-device-1',
        body: 'must never be sent as plaintext',
      ),
      throwsStateError,
    );

    expect(rpc.sentRequests, isEmpty);
    expect(store.outbox, isEmpty);
    expect(store.messages, isEmpty);
    await repository.stopSync();
  });

  test(
    'secret outbox stores no plaintext while ciphertext is being prepared',
    () async {
      final rpc = _FakeMessagingRpc();
      final store = _FakeChatStore();
      final crypto = _FakeSecretChatCryptoPort()
        ..encryptGate = Completer<void>();
      final repository = _createRepository(
        rpc: rpc,
        store: store,
        secretCrypto: crypto,
      );
      final sending = repository.sendSecretMessage(
        chatId: 'recipient-1',
        senderRecipientId: 'user-1',
        recipientServerDeviceId: 'recipient-device-1',
        body: 'local secret body',
      );

      await _waitFor(() => store.outbox.isNotEmpty);
      final preparing = store.outbox.single;
      expect(preparing.status, OutboxStatus.preparing);
      expect(preparing.payload, isEmpty);
      expect(
        store.loadChatMessage(preparing.messageId)?.status,
        ChatDeliveryStatus.pending,
      );

      crypto.encryptGate!.complete();
      final message = await sending;
      await _waitFor(
        () =>
            store.loadChatMessage(message.messageId)?.status ==
            ChatDeliveryStatus.sent,
      );
      expect(store.outbox, isEmpty);
      expect(rpc.sentRequests.single.payload, crypto.ciphertext);
      expect(crypto.encryptCount, 1);
    },
  );

  test(
    'recovers a persisted secret preparation after encryption fails',
    () async {
      final rpc = _FakeMessagingRpc();
      final store = _FakeChatStore();
      final crypto = _FakeSecretChatCryptoPort()
        ..encryptFailure = StateError('prekey server unavailable');
      final repository = _createRepository(
        rpc: rpc,
        store: store,
        secretCrypto: crypto,
      );

      await expectLater(
        repository.sendSecretMessage(
          chatId: 'recipient-1',
          senderRecipientId: 'user-1',
          recipientServerDeviceId: 'recipient-device-1',
          body: 'durable secret intent',
        ),
        throwsStateError,
      );
      expect(store.outbox.single.status, OutboxStatus.preparing);
      expect(store.messages.single.status, ChatDeliveryStatus.failed);
      expect(rpc.sentRequests, isEmpty);

      crypto.encryptFailure = null;
      await repository.retryMessage(store.messages.single.messageId);
      await _waitFor(
        () =>
            store.loadChatMessage(store.messages.single.messageId)?.status ==
            ChatDeliveryStatus.sent,
      );

      expect(crypto.encryptCount, 2);
      expect(crypto.plaintext, utf8.encode('durable secret intent'));
      expect(rpc.lastSendRequest!.payload, crypto.ciphertext);
      await repository.stopSync();
    },
  );

  test('startup re-encrypts secret intents left in preparing state', () async {
    final rpc = _FakeMessagingRpc();
    final store = _FakeChatStore();
    final crypto = _FakeSecretChatCryptoPort();
    final createdAt = DateTime.utc(2026, 10, 3);
    final message = ChatMessage(
      messageId: 'restart-secret-intent',
      chatId: secretChatLocalId(
        recipientId: 'recipient-1',
        firstDeviceId: 'device-1',
        secondDeviceId: 'recipient-device-1',
      ),
      senderRecipientId: 'user-1',
      body: 'resume after restart',
      createdAt: createdAt,
    );
    store.saveOutgoingMessage(
      message,
      OutboxRecord(
        accountId: 'user-1',
        messageId: message.messageId,
        senderDeviceId: 'device-1',
        localChatId: message.chatId,
        chatId: 'recipient-1',
        senderRecipientId: 'user-1',
        targetRecipientId: 'recipient-1',
        targetDeviceId: 'recipient-device-1',
        isSecret: true,
        messageType: ChatMessageType.text.index,
        payload: Uint8List.fromList(utf8.encode(message.body)),
        status: OutboxStatus.preparing,
        attempts: 0,
        nextAttemptAt: createdAt,
        createdAt: createdAt,
        expiresAt: DateTime.now().toUtc().add(const Duration(hours: 24)),
      ),
    );
    final repository = _createRepository(
      rpc: rpc,
      store: store,
      secretCrypto: crypto,
    );

    await repository.startSync();
    await _waitFor(
      () =>
          store.loadChatMessage(message.messageId)?.status ==
          ChatDeliveryStatus.sent,
    );

    expect(crypto.encryptCount, 1);
    expect(crypto.plaintext, utf8.encode(message.body));
    expect(rpc.sentRequests.single.payload, crypto.ciphertext);
    await repository.stopSync();
  });

  test('stores delivery locally before acknowledging the server', () async {
    final rpc = _FakeMessagingRpc()
      ..deliveries = [
        pb.MessageDelivery(
          deliveryId: 'delivery-1',
          messageId: 'message-1',
          chatId: 'recipient-1',
          senderRecipientId: 'user-2',
          senderDeviceId: 'peer-device',
          targetRecipientId: 'user-1',
          targetDeviceId: 'device-1',
          chatKind: pb.ChatKind.CHAT_KIND_NORMAL,
          messageType: pb.MessageType.MESSAGE_TYPE_TEXT,
          payload: utf8.encode('queued'),
          createdAt: Int64(1_790_000_000),
        ),
      ];
    final store = _FakeChatStore();
    final repository = _createRepository(rpc: rpc, store: store);
    await repository.startSync();

    await _waitFor(() => store.loadChatMessage('message-1') != null);

    expect(store.loadChatMessage('message-1')?.body, 'queued');
    expect(store.messages.single.body, 'queued');
    expect(rpc.acknowledged.single.deliveryId, 'delivery-1');
    expect(store.loadRecipient('recipient-1')?.unreadCount, 1);
    expect(rpc.lastStreamRequest!.single.recipientId, 'user-1');
    expect(rpc.lastStreamRequest!.single.deviceId, 'device-1');
    await repository.stopSync();
  });

  test('drops deliveries addressed to a different account or device', () async {
    final wrongRecipient = _delivery(
      id: 'wrong-recipient-delivery',
      messageId: 'wrong-recipient-message',
    )..targetRecipientId = 'another-account';
    final wrongDevice = _delivery(
      id: 'wrong-device-delivery',
      messageId: 'wrong-device-message',
    )..targetDeviceId = 'another-device';
    final rpc = _FakeMessagingRpc()..deliveries = [wrongRecipient, wrongDevice];
    final store = _FakeChatStore();
    final repository = _createRepository(rpc: rpc, store: store);

    await repository.startSync();
    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(store.messages, isEmpty);
    expect(rpc.acknowledged, isEmpty);
    await repository.stopSync();
  });

  test(
    'drops an inbound delivery if its account changes during resolution',
    () async {
      final rpc = _FakeMessagingRpc()
        ..deliveries = [
          _delivery(id: 'stale-delivery', messageId: 'stale-message'),
        ];
      final store = _FakeChatStore();
      final resolverStarted = Completer<void>();
      final resolverGate = Completer<Recipient>();
      final repository = _createRepository(
        rpc: rpc,
        store: store,
        resolveRecipient: (_) {
          if (!resolverStarted.isCompleted) resolverStarted.complete();
          return resolverGate.future;
        },
      );
      await repository.startSync();
      final subscription = repository
          .streamMessages(chatId: 'recipient-1')
          .listen((_) {});
      await resolverStarted.future;

      store.session = const UserSession(userId: 'user-2', deviceId: 'device-2');
      resolverGate.complete(
        const Recipient(
          id: 'recipient-1',
          type: RecipientType.user,
          name: 'Peer',
          handle: '@peer',
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(store.messages, isEmpty);
      expect(rpc.acknowledged, isEmpty);
      await subscription.cancel();
      await repository.stopSync();
    },
  );

  test('batches normal deliveries before acknowledging them', () async {
    final rpc = _FakeMessagingRpc()
      ..deliveries = [
        _delivery(id: 'batch-delivery-1', messageId: 'batch-message-1'),
        _delivery(id: 'batch-delivery-2', messageId: 'batch-message-2'),
      ];
    final store = _FakeChatStore();
    final repository = _createRepository(
      rpc: rpc,
      store: store,
      ackBatchWindow: const Duration(milliseconds: 50),
    );
    await repository.startSync();

    final subscription = repository
        .streamMessages(chatId: 'recipient-1')
        .listen((_) {});
    await _waitFor(() => rpc.acknowledged.length == 2);

    expect(store.incomingBatchCalls, 1);
    expect(
      store.messages.map((message) => message.messageId),
      unorderedEquals(['batch-message-1', 'batch-message-2']),
    );
    expect(rpc.acknowledged.map((delivery) => delivery.deliveryId), [
      'batch-delivery-1',
      'batch-delivery-2',
    ]);
    expect(rpc.acknowledgedBatches, hasLength(1));
    expect(rpc.acknowledgedBatches.single, hasLength(2));
    await subscription.cancel();
    await repository.stopSync();
  });

  test('flushes ACKs at the RPC batch limit before the timer', () async {
    final rpc = _FakeMessagingRpc()
      ..deliveries = [
        for (var index = 0; index < 4; index++)
          _delivery(
            id: 'high-water-delivery-$index',
            messageId: 'high-water-message-$index',
          ),
      ];
    final repository = _createRepository(
      rpc: rpc,
      store: _FakeChatStore(),
      maxAcknowledgementsPerRpc: 2,
      ackBatchWindow: const Duration(seconds: 1),
    );
    await repository.startSync();
    final subscription = repository
        .streamMessages(chatId: 'recipient-1')
        .listen((_) {});

    await _waitFor(() => rpc.acknowledged.length == 4);

    expect(rpc.acknowledgedBatches, hasLength(2));
    expect(rpc.acknowledgedBatches.map((batch) => batch.length), [2, 2]);
    await subscription.cancel();
    await repository.stopSync();
  });

  test('flushes incoming bursts in bounded persistence batches', () async {
    final rpc = _FakeMessagingRpc()
      ..deliveries = [
        for (var index = 0; index < 5; index++)
          _delivery(
            id: 'bounded-delivery-$index',
            messageId: 'bounded-message-$index',
          ),
      ];
    final store = _FakeChatStore();
    final repository = _createRepository(
      rpc: rpc,
      store: store,
      maxIncomingBatchSize: 2,
      incomingBatchWindow: const Duration(milliseconds: 1),
    );
    await repository.startSync();
    final subscription = repository
        .streamMessages(chatId: 'recipient-1')
        .listen((_) {});

    await _waitFor(() => store.messages.length == 5);

    expect(store.incomingBatchCalls, 3);
    expect(rpc.acknowledged, hasLength(5));
    await subscription.cancel();
    await repository.stopSync();
  });

  test(
    'pauses incoming stream when delivery handlers reach their limit',
    () async {
      final rpc = _FakeMessagingRpc()
        ..deliveries = [
          for (var index = 0; index < 6; index++)
            _delivery(
              id: 'backpressure-delivery-$index',
              messageId: 'backpressure-message-$index',
            ),
        ];
      final releaseResolvers = Completer<void>();
      var activeResolvers = 0;
      var maxActiveResolvers = 0;
      final store = _FakeChatStore();
      final repository = _createRepository(
        rpc: rpc,
        store: store,
        maxConcurrentDeliveryHandlers: 2,
        resolveRecipient: (recipientId) async {
          activeResolvers++;
          maxActiveResolvers = math.max(maxActiveResolvers, activeResolvers);
          try {
            await releaseResolvers.future;
          } finally {
            activeResolvers--;
          }
          return Recipient(
            id: recipientId,
            type: RecipientType.user,
            name: 'Peer',
            handle: '@peer',
          );
        },
      );
      await repository.startSync();
      final subscription = repository
          .streamMessages(chatId: 'recipient-1')
          .listen((_) {});

      await _waitFor(() => maxActiveResolvers == 2);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(activeResolvers, 2);
      releaseResolvers.complete();
      await _waitFor(() => store.messages.length == 6);

      expect(maxActiveResolvers, 2);
      await subscription.cancel();
      await repository.stopSync();
    },
  );

  test('does not ACK when local persistence fails', () async {
    final rpc = _FakeMessagingRpc()
      ..deliveries = [
        _delivery(id: 'delivery-unpersisted', messageId: 'message-unpersisted'),
      ];
    final store = _FakeChatStore()..failIncomingWrites = true;
    final repository = _createRepository(rpc: rpc, store: store);
    final subscription = repository
        .streamMessages(chatId: 'recipient-1')
        .listen((_) {}, onError: (Object _) {});

    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(store.loadChatMessage('message-unpersisted'), isNull);
    expect(rpc.acknowledged, isEmpty);
    await subscription.cancel();
    await repository.stopSync();
  });

  test(
    'persists a receipt event before ACK and advances sender status',
    () async {
      final store = _FakeChatStore();
      store.saveChatMessage(
        ChatMessage(
          messageId: 'outgoing-receipt',
          chatId: 'recipient-1',
          senderRecipientId: 'user-1',
          body: 'sent',
          createdAt: DateTime.utc(2026, 10, 2),
          status: ChatDeliveryStatus.sent,
        ),
      );
      final rpc = _FakeMessagingRpc()
        ..deliveries = [
          pb.MessageDelivery(
            deliveryId: 'receipt-delivery',
            messageId: 'outgoing-receipt',
            chatId: 'recipient-1',
            senderRecipientId: 'user-2',
            targetRecipientId: 'user-1',
            targetDeviceId: 'device-1',
            eventType:
                pb.MessageDeliveryEventType.MESSAGE_DELIVERY_EVENT_TYPE_RECEIPT,
            receiptStatus: pb.DeliveryStatus.DELIVERY_STATUS_READ,
          ),
        ];
      rpc.beforeAck = () {
        expect(
          store.loadChatMessage('outgoing-receipt')?.status,
          ChatDeliveryStatus.read,
        );
      };
      final repository = _createRepository(rpc: rpc, store: store);
      await repository.startSync();
      final subscription = repository
          .streamMessages(chatId: 'recipient-1')
          .listen((_) {});

      await _waitFor(() => rpc.acknowledged.isNotEmpty);

      expect(rpc.acknowledged.single.deliveryId, 'receipt-delivery');
      expect(
        store.loadChatMessage('outgoing-receipt')?.status,
        ChatDeliveryStatus.read,
      );
      await subscription.cancel();
      await repository.stopSync();
    },
  );

  test(
    'marks only incoming local messages read when conversation opens',
    () async {
      final store = _FakeChatStore();
      store.saveChatMessage(
        ChatMessage(
          messageId: 'incoming-read',
          chatId: 'peer',
          senderRecipientId: 'peer-user',
          body: 'hello',
          createdAt: DateTime.utc(2026, 10, 2),
        ),
      );
      store.saveChatMessage(
        ChatMessage(
          messageId: 'outgoing-read',
          chatId: 'peer',
          senderRecipientId: 'user-1',
          body: 'hello back',
          createdAt: DateTime.utc(2026, 10, 2),
        ),
      );
      final rpc = _FakeMessagingRpc();
      final repository = _createRepository(rpc: rpc, store: store);

      await repository.markConversationRead(
        chatId: 'peer',
        peerRecipientId: 'peer-user',
      );

      expect(store.queuedCommands, hasLength(1));
      expect(
        store.loadChatMessage('incoming-read')?.status,
        ChatDeliveryStatus.read,
      );
      await _waitFor(() => rpc.sentReadReceipts.length == 1);
      expect(rpc.sentReadReceipts, hasLength(1));
      expect(rpc.sentReadReceipts.single.senderRecipientId, 'peer-user');
      expect(rpc.sentReadReceipts.single.messageId, 'incoming-read');
    },
  );

  test(
    'the UI message watcher marks incoming messages read while the chat is open',
    () async {
      final rpc = _FakeMessagingRpc()
        ..deliveries = [
          _delivery(id: 'incoming-delivery', messageId: 'incoming-read'),
        ];
      rpc.beforeAck = () => expect(rpc.sentReadReceipts, isEmpty);
      final store = _FakeChatStore();
      final repository = _createRepository(rpc: rpc, store: store);
      await repository.startSync();
      final subscription = repository
          .watchMessages(chatId: 'recipient-1')
          .listen((_) {});

      await _waitFor(() => rpc.sentReadReceipts.isNotEmpty);

      expect(rpc.acknowledged.single.deliveryId, 'incoming-delivery');
      expect(rpc.sentReadReceipts.single.senderRecipientId, 'user-2');
      expect(rpc.sentReadReceipts.single.messageId, 'incoming-read');
      expect(store.loadRecipient('recipient-1')?.unreadCount, 0);
      expect(
        store.loadChatMessage('incoming-read')?.status,
        ChatDeliveryStatus.read,
      );
      await subscription.cancel();
      await repository.stopSync();
    },
  );

  test('restarts message sync when the signed-in account changes', () async {
    final rpc = _FakeMessagingRpc();
    final store = _FakeChatStore();
    final repository = _createRepository(rpc: rpc, store: store);

    await repository.startSync();
    store.session = const UserSession(
      userId: 'user-2',
      accessToken: 'token-2',
      refreshToken: 'refresh-2',
      deviceId: 'device-2',
    );
    await repository.startSync();

    expect(rpc.streamRequests, hasLength(2));
    expect(rpc.streamRequests.last.recipientId, 'user-2');
    expect(rpc.streamRequests.last.deviceId, 'device-2');
    await repository.stopSync();
  });

  test(
    'device handoff sends normal outbox but keeps secret bytes pinned',
    () async {
      final rpc = _FakeMessagingRpc();
      final store = _FakeChatStore();
      final normal = ChatMessage(
        messageId: 'normal-outbox',
        chatId: 'peer',
        senderRecipientId: 'user-1',
        body: 'normal',
        createdAt: DateTime.utc(2026, 10, 2),
        status: ChatDeliveryStatus.pending,
      );
      final secret = ChatMessage(
        messageId: 'secret-outbox',
        chatId: 'secret/peer/device-1/peer-device',
        senderRecipientId: 'user-1',
        body: 'secret',
        createdAt: DateTime.utc(2026, 10, 2, 0, 0, 1),
        status: ChatDeliveryStatus.pending,
      );
      store.saveOutgoingMessage(
        normal,
        OutboxRecord(
          accountId: 'user-1',
          messageId: normal.messageId,
          senderDeviceId: 'device-1',
          localChatId: normal.chatId,
          chatId: 'peer',
          senderRecipientId: 'user-1',
          targetRecipientId: 'peer',
          targetDeviceId: null,
          isSecret: false,
          messageType: pb.MessageType.MESSAGE_TYPE_TEXT.value,
          payload: utf8.encode(normal.body),
          status: OutboxStatus.pending,
          attempts: 0,
          nextAttemptAt: normal.createdAt,
          createdAt: normal.createdAt,
          expiresAt: DateTime.now().toUtc().add(const Duration(hours: 24)),
        ),
      );
      store.saveOutgoingMessage(
        secret,
        OutboxRecord(
          accountId: 'user-1',
          messageId: secret.messageId,
          senderDeviceId: 'device-1',
          localChatId: secret.chatId,
          chatId: 'peer',
          senderRecipientId: 'user-1',
          targetRecipientId: 'peer',
          targetDeviceId: 'peer-device',
          isSecret: true,
          messageType: pb.MessageType.MESSAGE_TYPE_TEXT.value,
          payload: Uint8List.fromList([1, 2, 3]),
          status: OutboxStatus.pending,
          attempts: 0,
          nextAttemptAt: secret.createdAt,
          createdAt: secret.createdAt,
          expiresAt: DateTime.now().toUtc().add(const Duration(hours: 24)),
        ),
      );
      store.session = const UserSession(userId: 'user-1', deviceId: 'device-2');
      final repository = _createRepository(rpc: rpc, store: store);

      await repository.startSync();
      await _waitFor(
        () =>
            store.loadChatMessage(normal.messageId)?.status ==
            ChatDeliveryStatus.sent,
      );

      expect(rpc.sentRequests.single.messageId, normal.messageId);
      expect(rpc.sentRequests.single.senderDeviceId, 'device-2');
      expect(
        store.loadOutboxQueue('user-1', 'device-1').single.messageId,
        secret.messageId,
      );
      expect(
        store.loadChatMessage(secret.messageId)?.status,
        ChatDeliveryStatus.pending,
      );
      await repository.stopSync();
    },
  );

  test('repeated sync starts reuse one stream until logout stops it', () async {
    final rpc = _FakeMessagingRpc();
    final repository = _createRepository(rpc: rpc, store: _FakeChatStore());

    await repository.startSync();
    await repository.startSync();
    await repository.startSync();
    expect(rpc.streamRequests, hasLength(1));

    await repository.stopSync();
    await repository.startSync();
    expect(rpc.streamRequests, hasLength(2));
    await repository.stopSync();
  });

  test('startSync resets a stream still closing after an error', () async {
    final rpc = _FakeMessagingRpc();
    var streamFailures = 0;
    final repository = _createRepository(
      rpc: rpc,
      store: _FakeChatStore(),
      onStreamFailure: () => streamFailures++,
    );
    await repository.startSync();
    rpc._activeStream!.addError(StateError('transport closed'));
    await _waitFor(() => streamFailures == 1);

    await repository.startSync();

    expect(rpc.streamRequests, hasLength(2));
    await repository.stopSync();
  });

  test(
    'intentional stream replacement does not schedule another reconnect',
    () async {
      final rpc = _FakeMessagingRpc();
      var streamFailures = 0;
      final repository = _createRepository(
        rpc: rpc,
        store: _FakeChatStore(),
        onStreamFailure: () => streamFailures++,
      );

      await repository.startSync();
      await repository.reconnect();
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(rpc.streamRequests, hasLength(2));
      expect(streamFailures, 0);
      await repository.stopSync();
    },
  );

  test(
    'reconnects when the chat stream never completes its ready handshake',
    () async {
      final rpc = _FakeMessagingRpc()..holdStreamHandshake = true;
      rpc._setReady(false);
      var streamFailures = 0;
      final repository = _createRepository(
        rpc: rpc,
        store: _FakeChatStore(),
        streamHandshakeTimeout: const Duration(milliseconds: 10),
        onStreamFailure: () => streamFailures++,
      );

      await repository.startSync();
      await Future<void>.delayed(const Duration(milliseconds: 30));

      expect(streamFailures, 1);
      await repository.stopSync();
    },
  );

  test(
    'retries an offline message with its original id after connectivity returns',
    () async {
      final rpc = _FakeMessagingRpc();
      final store = _FakeChatStore();
      final repository = _createRepository(
        rpc: rpc,
        store: store,
        retryBaseDelay: const Duration(milliseconds: 2),
        retryMaxDelay: const Duration(milliseconds: 2),
        random: math.Random(2),
      );
      rpc.beforeSend = () {
        rpc.sendFailure = rpc.sentRequests.length == 1
            ? GrpcError.unavailable('network offline')
            : null;
      };

      final message = await repository.sendMessage(
        chatId: 'recipient-1',
        senderRecipientId: 'user-1',
        body: 'offline first',
      );
      expect(
        store.loadChatMessage(message.messageId)?.status,
        ChatDeliveryStatus.pending,
      );
      expect(store.outbox.single.messageId, message.messageId);

      await _waitFor(
        () =>
            store.loadChatMessage(message.messageId)?.status ==
            ChatDeliveryStatus.sent,
      );
      expect(rpc.sentRequests, hasLength(2));
      expect(rpc.sentRequests.map((request) => request.messageId).toSet(), {
        message.messageId,
      });
      expect(store.messages, hasLength(1));
      expect(store.outbox, isEmpty);
    },
  );

  test('serializes queued messages in conversation order', () async {
    final rpc = _FakeMessagingRpc()..sendGate = Completer<void>();
    final store = _FakeChatStore();
    final repository = _createRepository(rpc: rpc, store: store);

    final first = await repository.sendMessage(
      chatId: 'recipient-1',
      senderRecipientId: 'user-1',
      body: 'first',
    );
    await _waitFor(
      () =>
          store.loadChatMessage(first.messageId)?.status ==
          ChatDeliveryStatus.sending,
    );
    final second = await repository.sendMessage(
      chatId: 'recipient-1',
      senderRecipientId: 'user-1',
      body: 'second',
    );
    final third = await repository.sendMessage(
      chatId: 'recipient-1',
      senderRecipientId: 'user-1',
      body: 'third',
    );
    expect(rpc.sentRequests, hasLength(1));

    rpc.sendGate!.complete();
    await _waitFor(() => store.outbox.isEmpty);
    expect(rpc.sentRequests.map((request) => utf8.decode(request.payload)), [
      'first',
      'second',
      'third',
    ]);
    expect(rpc.maxConcurrentSends, 1);
    expect(
      [
        first,
        second,
        third,
      ].map((message) => store.loadChatMessage(message.messageId)?.status),
      everyElement(ChatDeliveryStatus.sent),
    );
  });

  test('sends independent conversations concurrently', () async {
    final rpc = _FakeMessagingRpc()..sendGate = Completer<void>();
    final store = _FakeChatStore();
    final repository = _createRepository(rpc: rpc, store: store);

    final first = repository.sendMessage(
      chatId: 'recipient-1',
      senderRecipientId: 'user-1',
      body: 'first conversation',
    );
    final second = repository.sendMessage(
      chatId: 'recipient-2',
      senderRecipientId: 'user-1',
      body: 'second conversation',
    );
    await Future.wait([first, second]);
    await _waitFor(() => rpc.maxConcurrentSends == 2);

    expect(rpc.sentRequests, hasLength(2));
    expect(rpc.sentBatchSizes, contains(2));
    rpc.sendGate!.complete();
    await _waitFor(() => store.outbox.isEmpty);
    expect(rpc.maxConcurrentSends, 2);
  });

  test('recovers messages left SENDING when a new repository starts', () async {
    final store = _FakeChatStore();
    final interruptedRpc = _FakeMessagingRpc()..sendGate = Completer<void>();
    final interruptedRepository = _createRepository(
      rpc: interruptedRpc,
      store: store,
    );
    final message = await interruptedRepository.sendMessage(
      chatId: 'recipient-1',
      senderRecipientId: 'user-1',
      body: 'survives restart',
    );
    await _waitFor(
      () =>
          store.loadChatMessage(message.messageId)?.status ==
          ChatDeliveryStatus.sending,
    );
    await interruptedRepository.stopSync();
    interruptedRpc.sendGate!.complete();
    await Future<void>.delayed(const Duration(milliseconds: 2));
    expect(
      store.loadOutboxQueue('user-1', 'device-1').single.status,
      OutboxStatus.sending,
    );

    final resumedRpc = _FakeMessagingRpc();
    final resumedRepository = _createRepository(rpc: resumedRpc, store: store);
    await resumedRepository.startSync();
    await _waitFor(
      () =>
          store.loadChatMessage(message.messageId)?.status ==
          ChatDeliveryStatus.sent,
    );
    expect(resumedRpc.sentRequests.single.messageId, message.messageId);
    expect(resumedRpc.sentRequests.single.payload, utf8.encode(message.body));
    await resumedRepository.stopSync();
  });

  test(
    'deduplicates repeated message ids and acknowledges every delivery',
    () async {
      final rpc = _FakeMessagingRpc()
        ..deliveries = [
          _delivery(id: 'delivery-1', messageId: 'same-message'),
          _delivery(id: 'delivery-2', messageId: 'same-message'),
        ];
      final store = _FakeChatStore();
      final repository = _createRepository(rpc: rpc, store: store);
      final received = <ChatMessage>[];
      final subscription = repository
          .streamMessages(chatId: 'recipient-1')
          .listen(received.add);
      addTearDown(subscription.cancel);
      addTearDown(repository.stopSync);
      await repository.startSync();
      await _waitFor(() => received.isNotEmpty && rpc.acknowledged.length == 2);

      expect(received, hasLength(1));
      expect(store.messages, hasLength(1));
      expect(store.loadRecipient('recipient-1')?.unreadCount, 0);
      expect(rpc.acknowledged.map((request) => request.deliveryId), [
        'delivery-1',
        'delivery-2',
      ]);
      await subscription.cancel();
      await repository.stopSync();
    },
  );

  test(
    'keeps temporary failures pending for retry before expiration',
    () async {
      final rpc = _FakeMessagingRpc()
        ..sendFailure = GrpcError.unavailable('still offline');
      final store = _FakeChatStore();
      final repository = _createRepository(
        rpc: rpc,
        store: store,
        retryBaseDelay: const Duration(minutes: 1),
        retryMaxDelay: const Duration(minutes: 1),
        random: math.Random(3),
      );

      final message = await repository.sendMessage(
        chatId: 'recipient-1',
        senderRecipientId: 'user-1',
        body: 'temporary error',
      );
      await _waitFor(() => rpc.sentRequests.isNotEmpty);

      expect(rpc.sentRequests, hasLength(1));
      expect(
        store.loadChatMessage(message.messageId)?.status,
        ChatDeliveryStatus.pending,
      );
      expect(store.outbox.single.status, OutboxStatus.pending);
      await repository.stopSync();
    },
  );

  test(
    'incoming messages create conversations with resolved sender metadata',
    () async {
      final rpc = _FakeMessagingRpc()
        ..deliveries = [
          _delivery(id: 'delivery-profile', messageId: 'message-profile'),
        ];
      final store = _FakeChatStore();
      final repository = _createRepository(
        rpc: rpc,
        store: store,
        resolveRecipient: (recipientId) async => Recipient(
          id: recipientId,
          type: RecipientType.user,
          name: 'Maria',
          handle: '@maria',
          avatarUrl: 'https://example.test/maria.png',
          isUsernameVisible: true,
          verificationBadge: VerificationBadge.verified,
        ),
      );
      await repository.startSync();
      final messageSubscription = repository
          .streamMessages(chatId: 'recipient-1')
          .listen((_) {});
      await _waitFor(
        () =>
            store.loadRecipient('recipient-1') != null &&
            rpc.acknowledged.isNotEmpty,
      );

      final conversation = store.loadRecipient('recipient-1');
      expect(conversation?.name, 'Maria');
      expect(conversation?.handle, '@maria');
      expect(conversation?.avatarUrl, 'https://example.test/maria.png');
      expect(conversation?.lastMessage, 'queued');
      expect(conversation?.unreadCount, 0);
      expect(rpc.acknowledged.single.deliveryId, 'delivery-profile');

      await messageSubscription.cancel();
      await repository.stopSync();
    },
  );

  test(
    'fan-out to another device materializes the peer conversation locally',
    () async {
      final rpc = _FakeMessagingRpc()
        ..deliveries = [
          pb.MessageDelivery(
            deliveryId: 'delivery-fanout',
            messageId: 'message-fanout',
            chatId: 'peer-user',
            senderRecipientId: 'user-1',
            senderDeviceId: 'device-a',
            targetRecipientId: 'user-1',
            targetDeviceId: 'device-b',
            chatKind: pb.ChatKind.CHAT_KIND_NORMAL,
            messageType: pb.MessageType.MESSAGE_TYPE_TEXT,
            payload: utf8.encode('sent from device A'),
            createdAt: Int64(1_790_000_000),
          ),
        ];
      final store = _FakeChatStore()
        ..session = const UserSession(
          userId: 'user-1',
          accessToken: 'token',
          refreshToken: 'refresh',
          deviceId: 'device-b',
        );
      final repository = _createRepository(
        rpc: rpc,
        store: store,
        resolveRecipient: (recipientId) async => Recipient(
          id: recipientId,
          type: RecipientType.user,
          name: 'Peer',
          handle: '@peer',
        ),
      );
      await repository.startSync();
      final messageSubscription = repository
          .streamMessages(chatId: 'peer-user')
          .listen((_) {});
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(store.loadRecipient('peer-user')?.name, 'Peer');
      expect(
        store.loadChatMessages('peer-user').single.body,
        'sent from device A',
      );
      expect(store.loadRecipient('peer-user')?.unreadCount, 0);
      expect(rpc.acknowledged.single.deliveryId, 'delivery-fanout');

      await messageSubscription.cancel();
      await repository.stopSync();
    },
  );

  test(
    'decryption failures store a placeholder and encrypted retry marker',
    () async {
      final rpc = _FakeMessagingRpc()
        ..deliveries = [
          pb.MessageDelivery(
            deliveryId: 'secret-delivery',
            messageId: 'secret-message',
            chatId: 'secret-chat',
            senderRecipientId: 'user-2',
            senderDeviceId: 'peer-device',
            targetRecipientId: 'user-1',
            targetDeviceId: 'device-1',
            chatKind: pb.ChatKind.CHAT_KIND_SECRET,
            messageType: pb.MessageType.MESSAGE_TYPE_TEXT,
            payload: [1, 2, 3, 4],
            createdAt: Int64(1_790_000_000),
          ),
        ];
      final store = _FakeChatStore();
      rpc.beforeAck = () {
        expect(
          store.loadChatMessage('secret-message')?.body,
          secretMessageDecryptionFailed,
        );
        expect(
          store.loadChatMessage('secret-message')?.chatId,
          secretChatLocalId(
            recipientId: 'user-2',
            firstDeviceId: 'peer-device',
            secondDeviceId: 'device-1',
          ),
        );
        expect(store.secretDeliveries, hasLength(1));
        expect(store.secretDeliveries.single.deliveryId, 'secret-delivery');
      };
      final repository = _createRepository(
        rpc: rpc,
        store: store,
        secretCrypto: _FakeSecretChatCryptoPort(),
      );
      await repository.startSync();
      final subscription = repository
          .streamMessages(chatId: 'secret-chat')
          .listen((_) {});
      await _waitFor(
        () =>
            store.loadChatMessage('secret-message') != null &&
            rpc.acknowledged.isNotEmpty,
      );

      expect(store.secretDeliveries, hasLength(1));
      expect(
        store.loadChatMessage('secret-message')?.body,
        secretMessageDecryptionFailed,
      );
      expect(rpc.acknowledged.single.deliveryId, 'secret-delivery');
      await subscription.cancel();
      await repository.stopSync();
    },
  );

  test(
    'deduplicates repeated secret delivery ids and acknowledges once',
    () async {
      final rpc = _FakeMessagingRpc()
        ..deliveries = [
          _secretDelivery(id: 'secret-delivery-retry'),
          _secretDelivery(id: 'secret-delivery-retry'),
        ];
      final store = _FakeChatStore();
      final repository = _createRepository(
        rpc: rpc,
        store: store,
        secretCrypto: _FakeSecretChatCryptoPort(),
      );
      await repository.startSync();
      final subscription = repository
          .streamMessages(chatId: 'secret-chat')
          .listen((_) {});
      await _waitFor(
        () => store.messages.isNotEmpty && rpc.acknowledged.isNotEmpty,
      );

      expect(store.secretDeliveries, hasLength(1));
      expect(store.messages, hasLength(1));
      expect(rpc.acknowledged.map((request) => request.deliveryId), [
        'secret-delivery-retry',
      ]);
      await subscription.cancel();
      await repository.stopSync();
    },
  );

  test(
    'reprocesses an incomplete secret delivery marker before acknowledging',
    () async {
      final delivery = _secretDelivery(id: 'secret-delivery-incomplete');
      final rpc = _FakeMessagingRpc()..deliveries = [delivery];
      final store = _FakeChatStore()
        ..saveSecretDelivery(
          SecretDeliveryRecord(
            deliveryId: delivery.deliveryId,
            messageId: delivery.messageId,
            chatId: secretChatLocalId(
              recipientId: delivery.senderRecipientId,
              firstDeviceId: delivery.senderDeviceId,
              secondDeviceId: delivery.targetDeviceId,
            ),
            senderRecipientId: delivery.senderRecipientId,
            targetRecipientId: delivery.targetRecipientId,
            messageType: delivery.messageType.value,
            ciphertext: Uint8List.fromList(delivery.payload),
            timestamp: DateTime.fromMillisecondsSinceEpoch(
              delivery.createdAt.toInt() * 1000,
              isUtc: true,
            ),
          ),
        );
      final repository = _createRepository(
        rpc: rpc,
        store: store,
        secretCrypto: _FakeSecretChatCryptoPort(),
      );

      await repository.startSync();
      await _waitFor(() => rpc.acknowledged.isNotEmpty);

      expect(store.loadChatMessage(delivery.messageId), isNotNull);
      expect(rpc.acknowledged.single.deliveryId, delivery.deliveryId);
      expect(store.secretDeliveries, hasLength(1));
      await repository.stopSync();
    },
  );

  test(
    'does not persist or ACK a secret delivery when local write fails',
    () async {
      final delivery = _secretDelivery(id: 'secret-delivery-write-failure');
      final rpc = _FakeMessagingRpc()..deliveries = [delivery];
      final store = _FakeChatStore()..failIncomingWrites = true;
      final repository = _createRepository(
        rpc: rpc,
        store: store,
        secretCrypto: _FakeSecretChatCryptoPort(),
      );

      await repository.startSync();
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(store.secretDeliveries, isEmpty);
      expect(store.loadChatMessage(delivery.messageId), isNull);
      expect(rpc.acknowledged, isEmpty);
      await repository.stopSync();
    },
  );

  test(
    'permanent send failures stay local and can be retried manually',
    () async {
      final rpc = _FakeMessagingRpc()
        ..sendFailure = GrpcError.custom(
          StatusCode.permissionDenied,
          'account blocked',
          null,
          null,
          {'axiom-error-code': 'AXIOM_ACCOUNT_BANNED'},
        );
      final store = _FakeChatStore();
      final repository = _createRepository(rpc: rpc, store: store);

      final message = await repository.sendMessage(
        chatId: 'recipient-1',
        senderRecipientId: 'user-1',
        body: 'hello',
      );
      await _waitFor(
        () =>
            store.loadChatMessage(message.messageId)?.status ==
            ChatDeliveryStatus.failed,
      );
      expect(store.messages, hasLength(1));
      expect(store.outbox.single.status, OutboxStatus.failed);

      rpc.sendFailure = null;
      await repository.retryMessage(message.messageId);
      await _waitFor(
        () =>
            store.loadChatMessage(message.messageId)?.status ==
            ChatDeliveryStatus.sent,
      );
      expect(rpc.sentRequests.map((request) => request.messageId), [
        message.messageId,
        message.messageId,
      ]);
    },
  );

  test('manual retry can be queued while the stream is offline', () async {
    final rpc = _FakeMessagingRpc()
      ..sendFailure = GrpcError.custom(
        StatusCode.permissionDenied,
        'account blocked',
        null,
        null,
        {'axiom-error-code': 'AXIOM_ACCOUNT_BANNED'},
      );
    final store = _FakeChatStore();
    final repository = _createRepository(rpc: rpc, store: store);
    final message = await repository.sendMessage(
      chatId: 'recipient-1',
      senderRecipientId: 'user-1',
      body: 'retry offline',
    );
    await _waitFor(
      () =>
          store.loadChatMessage(message.messageId)?.status ==
          ChatDeliveryStatus.failed,
    );

    rpc.sendFailure = null;
    rpc._setReady(false);
    await repository.retryMessage(message.messageId);

    expect(
      store.loadChatMessage(message.messageId)?.status,
      ChatDeliveryStatus.pending,
    );
    expect(store.outbox.single.status, OutboxStatus.pending);
    expect(rpc.sentRequests, hasLength(1));

    rpc._setReady(true);
    await _waitFor(
      () =>
          store.loadChatMessage(message.messageId)?.status ==
          ChatDeliveryStatus.sent,
    );
    expect(rpc.sentRequests.last.messageId, message.messageId);
    await repository.stopSync();
  });
}

GrpcChatRepository _createRepository({
  required MessagingRpc rpc,
  required ChatStore store,
  SecretChatCryptoPort? secretCrypto,
  Future<Recipient> Function(String)? resolveRecipient,
  math.Random? random,
  Duration retryBaseDelay = const Duration(seconds: 1),
  Duration retryMaxDelay = const Duration(minutes: 5),
  int maxIncomingBatchSize = 128,
  int maxAcknowledgementsPerRpc = 256,
  int maxConcurrentDeliveryHandlers = 16,
  Duration incomingBatchWindow = const Duration(milliseconds: 1),
  Duration ackBatchWindow = Duration.zero,
  Duration streamHandshakeTimeout = const Duration(seconds: 15),
  void Function()? onStreamFailure,
}) => GrpcChatRepository(
  rpc: rpc,
  store: store,
  secretCrypto: secretCrypto,
  resolveRecipient: resolveRecipient,
  random: random,
  retryBaseDelay: retryBaseDelay,
  retryMaxDelay: retryMaxDelay,
  maxIncomingBatchSize: maxIncomingBatchSize,
  maxAcknowledgementsPerRpc: maxAcknowledgementsPerRpc,
  maxConcurrentDeliveryHandlers: maxConcurrentDeliveryHandlers,
  incomingBatchWindow: incomingBatchWindow,
  ackBatchWindow: ackBatchWindow,
  streamHandshakeTimeout: streamHandshakeTimeout,
  onStreamFailure: onStreamFailure,
);

Future<void> _waitFor(bool Function() condition) async {
  for (var attempt = 0; attempt < 200; attempt++) {
    if (condition()) return;
    await Future<void>.delayed(const Duration(milliseconds: 1));
  }
  fail('Timed out waiting for the expected asynchronous state.');
}

pb.MessageDelivery _delivery({required String id, required String messageId}) =>
    pb.MessageDelivery(
      deliveryId: id,
      messageId: messageId,
      chatId: 'recipient-1',
      senderRecipientId: 'user-2',
      targetRecipientId: 'user-1',
      targetDeviceId: 'device-1',
      senderDeviceId: 'peer-device',
      chatKind: pb.ChatKind.CHAT_KIND_NORMAL,
      messageType: pb.MessageType.MESSAGE_TYPE_TEXT,
      payload: utf8.encode('queued'),
      createdAt: Int64(1_790_000_000),
    );

pb.MessageDelivery _secretDelivery({required String id}) => pb.MessageDelivery(
  deliveryId: id,
  messageId: 'same-secret-message',
  chatId: 'secret-chat',
  senderRecipientId: 'user-2',
  targetRecipientId: 'user-1',
  targetDeviceId: 'device-1',
  chatKind: pb.ChatKind.CHAT_KIND_SECRET,
  messageType: pb.MessageType.MESSAGE_TYPE_TEXT,
  payload: [1, 2, 3],
  createdAt: Int64(1_790_000_000),
);

class _FakeMessagingRpc implements MessagingRpc {
  Object? failure;
  Object? sendFailure;
  Object? readReceiptFailure;
  pb.SendMessageStatus sendStatus =
      pb.SendMessageStatus.SEND_MESSAGE_STATUS_ACCEPTED;
  int serverTimestampMicros = DateTime.now().toUtc().microsecondsSinceEpoch;
  List<pb.MessageDelivery> deliveries = [];
  pb.SendMessageRequest? lastSendRequest;
  final List<pb.SendMessageRequest> sentRequests = [];
  final List<pb.InteractBotRequest> sentBotRequests = [];
  final List<int> sentBatchSizes = [];
  List<pb.ChatStreamOpen>? lastStreamRequest;
  final List<pb.ChatStreamOpen> streamRequests = [];
  final List<pb.AckDeliveryRequest> acknowledged = [];
  final List<List<pb.DeliveryAcknowledgement>> acknowledgedBatches = [];
  final List<pb.SendReadReceiptRequest> sentReadReceipts = [];
  final List<pb.SendMessageMutationRequest> sentMutations = [];
  final List<Completer<void>> mutationGates = [];
  void Function()? beforeAck;
  void Function()? beforeSend;
  void Function(pb.SendMessageMutationRequest)? beforeMutation;
  bool holdStreamHandshake = false;
  Completer<void>? sendGate;
  Completer<void>? ackGate;
  Completer<void>? resetGate;
  int activeSendCount = 0;
  int maxConcurrentSends = 0;
  bool _isReady = true;
  bool _streamActive = false;
  StreamController<pb.MessageDelivery>? _activeStream;
  final StreamController<bool> _readiness = StreamController<bool>.broadcast(
    sync: true,
  );

  @override
  Future<void> close() async {}

  @override
  Future<void> resetStream() async {
    final gate = resetGate;
    resetGate = null;
    await gate?.future;
    _streamActive = false;
    final activeStream = _activeStream;
    _activeStream = null;
    if (activeStream != null && !activeStream.isClosed) {
      await activeStream.close();
    }
  }

  @override
  bool get isReady => _isReady;

  @override
  Stream<bool> get readinessChanges => _readiness.stream;

  void _setReady(bool ready) {
    if (_isReady == ready) return;
    _isReady = ready;
    _readiness.add(ready);
  }

  @override
  Future<List<pb.ChatStreamBatchResult>> sendBatch(
    List<pb.ChatStreamBatchCommand> commands,
  ) async {
    sentBatchSizes.add(commands.length);
    activeSendCount += commands.length;
    maxConcurrentSends = math.max(maxConcurrentSends, activeSendCount);
    try {
      final results = [
        for (final command in commands)
          if (command.hasSendMessage()) ...[
            _fakeSendResult(command),
          ] else if (command.hasInteractBot()) ...[
            _fakeBotResult(command),
          ],
      ];
      await sendGate?.future;
      return results;
    } finally {
      activeSendCount -= commands.length;
    }
  }

  pb.ChatStreamBatchResult _fakeSendResult(pb.ChatStreamBatchCommand command) {
    final request = command.sendMessage;
    lastSendRequest = request;
    sentRequests.add(request);
    beforeSend?.call();
    final error = sendFailure ?? failure;
    if (error != null) {
      final grpcError = error is GrpcError
          ? error
          : GrpcError.unavailable(error.toString());
      return pb.ChatStreamBatchResult(
        commandId: command.commandId,
        statusCode: grpcError.code,
        message: grpcError.message ?? '',
      );
    }
    return pb.ChatStreamBatchResult(
      commandId: command.commandId,
      sendMessage: pb.SendMessageResponse(
        messageId: request.messageId,
        status: sendStatus,
        serverTimestamp: Int64(serverTimestampMicros ~/ 1000000),
        serverTimestampMicros: Int64(serverTimestampMicros),
      ),
    );
  }

  pb.ChatStreamBatchResult _fakeBotResult(pb.ChatStreamBatchCommand command) {
    sentBotRequests.add(command.interactBot);
    beforeSend?.call();
    final error = sendFailure ?? failure;
    if (error != null) {
      final grpcError = error is GrpcError
          ? error
          : GrpcError.unavailable(error.toString());
      return pb.ChatStreamBatchResult(
        commandId: command.commandId,
        statusCode: grpcError.code,
        message: grpcError.message ?? '',
      );
    }
    return pb.ChatStreamBatchResult(
      commandId: command.commandId,
      botInteraction: pb.InteractBotResponse(
        responseText: 'bot response',
        firstInteraction: true,
      ),
    );
  }

  @override
  Stream<pb.MessageDelivery> streamMessages(pb.ChatStreamOpen request) {
    if (_streamActive) {
      throw StateError('The fake chat stream is already running.');
    }
    _streamActive = true;
    lastStreamRequest = [request];
    streamRequests.add(request);
    late StreamController<pb.MessageDelivery> controller;
    controller = StreamController<pb.MessageDelivery>(
      onCancel: () => controller.close(),
    );
    _activeStream = controller;
    scheduleMicrotask(() {
      if (failure != null) {
        _setReady(false);
        controller.addError(failure!);
        return;
      }
      if (holdStreamHandshake) return;
      _setReady(true);
      for (final delivery in deliveries) {
        controller.add(delivery);
      }
    });
    return controller.stream;
  }

  @override
  Future<void> ackDelivery(pb.AckDeliveryRequest request) async {
    if (failure != null) throw failure!;
    beforeAck?.call();
    acknowledged.add(request);
  }

  @override
  Future<void> ackDeliveries(
    List<pb.DeliveryAcknowledgement> deliveries,
  ) async {
    if (failure != null) throw failure!;
    acknowledgedBatches.add(List.unmodifiable(deliveries));
    await ackGate?.future;
    for (final delivery in deliveries) {
      beforeAck?.call();
      acknowledged.add(
        pb.AckDeliveryRequest(
          deliveryId: delivery.deliveryId,
          targetDeviceId: delivery.targetDeviceId,
        ),
      );
    }
  }

  @override
  Future<void> sendReadReceipt(pb.SendReadReceiptRequest request) async {
    if (failure != null) throw failure!;
    sentReadReceipts.add(request);
    if (readReceiptFailure != null) throw readReceiptFailure!;
  }

  @override
  Future<void> sendMessageMutation(
    pb.SendMessageMutationRequest request,
  ) async {
    if (failure != null) throw failure!;
    sentMutations.add(request);
    beforeMutation?.call(request);
    if (mutationGates.isNotEmpty) {
      await mutationGates.removeAt(0).future;
    }
  }

  @override
  Future<pb.InteractBotResponse> interactBot(
    pb.InteractBotRequest request,
  ) async {
    if (failure != null) throw failure!;
    return pb.InteractBotResponse(
      responseText: 'bot response',
      firstInteraction: true,
    );
  }
}

class _FakeChatStore implements ChatStore {
  final Map<String, ChatMessage> _messages = {};
  final Map<String, Recipient> _recipients = {};
  final Map<String, OutboxRecord> _outbox = {};
  final Map<String, PendingChatCommand> _commands = {};
  final Map<String, ChatDeliveryStatus> _receiptStatuses = {};
  final Map<String, MessageTranslation> _translations = {};
  final Set<String> _deletedMessages = {};
  final Set<String> _appliedMutations = {};
  final List<SecretDeliveryRecord> secretDeliveries = [];
  final Map<String, Set<MultiStreamController<List<ChatMessage>>>>
  _messageWatchers = {};
  int recipientWrites = 0;
  int incomingBatchCalls = 0;
  bool failIncomingWrites = false;
  bool failMessageWrites = false;
  final Map<String, DateTime> canonicalTimestamps = {};

  UserSession session = const UserSession(
    userId: 'user-1',
    accessToken: 'token',
    refreshToken: 'refresh',
    deviceId: 'device-1',
  );

  List<ChatMessage> get messages => _messages.values.toList();

  List<OutboxRecord> get outbox => _outbox.values.toList();

  List<PendingChatCommand> get queuedCommands => _commands.values.toList();

  @override
  UserSession loadSession() => session;

  @override
  Future<void> saveRecipient(Recipient recipient) async {
    recipientWrites++;
    _recipients[recipient.id] = recipient;
  }

  @override
  void saveChatMessage(ChatMessage message) {
    if (failMessageWrites) throw StateError('SQLite message write failed.');
    _messages[message.messageId] = message;
    _applyQueuedReceiptStatus(message.messageId);
    _notifyMessageWatchers(message.chatId);
  }

  @override
  void saveOutgoingMessage(ChatMessage message, OutboxRecord outbox) {
    _messages[message.messageId] = message;
    _outbox[outbox.messageId] = outbox;
    _applyQueuedReceiptStatus(message.messageId);
    _notifyMessageWatchers(message.chatId);
  }

  @override
  void enqueueMessageMutation({
    required PendingChatCommand command,
    ChatMessage? editedMessage,
    String? deletedMessageId,
  }) {
    _commands[command.commandId] = command;
    if (editedMessage != null) {
      if (_messages[editedMessage.messageId]?.body != editedMessage.body) {
        _translations.removeWhere(
          (key, _) => key.startsWith('${editedMessage.messageId}:'),
        );
      }
      _messages[editedMessage.messageId] = editedMessage;
      _notifyMessageWatchers(editedMessage.chatId);
    } else if (deletedMessageId != null) {
      final existing = _messages.remove(deletedMessageId);
      _deletedMessages.add(deletedMessageId);
      if (existing != null) _notifyMessageWatchers(existing.chatId);
    }
  }

  @override
  void enqueueReadReceipts({
    required List<PendingChatCommand> commands,
    required List<String> readMessageIds,
    required String peerRecipientId,
  }) {
    for (final command in commands) {
      _commands.putIfAbsent(command.commandId, () => command);
    }
    for (final messageId in readMessageIds) {
      _setMessageStatus(messageId, ChatDeliveryStatus.read);
    }
    final recipient = _recipients[peerRecipientId];
    if (recipient != null) {
      _recipients[peerRecipientId] = recipient.copyWith(unreadCount: 0);
    }
  }

  @override
  List<PendingChatCommand> loadPendingChatCommands(
    String accountId, {
    required int limit,
  }) {
    final commands = _commands.values
        .where((command) => command.accountId == accountId)
        .toList();
    return commands.take(limit).toList(growable: false);
  }

  @override
  bool hasPendingOutboxForMessage(String accountId, String messageId) =>
      _outbox.values.any(
        (record) =>
            record.accountId == accountId && record.messageId == messageId,
      );

  @override
  void removePendingChatCommand(String accountId, String commandId) {
    final command = _commands[commandId];
    if (command?.accountId == accountId) _commands.remove(commandId);
  }

  @override
  void retryPendingChatCommand(
    PendingChatCommand command, {
    required DateTime nextAttemptAt,
  }) {
    _commands[command.commandId] = PendingChatCommand(
      accountId: command.accountId,
      commandId: command.commandId,
      relatedMessageId: command.relatedMessageId,
      type: command.type,
      payload: command.payload,
      attempts: command.attempts + 1,
      nextAttemptAt: nextAttemptAt,
      createdAt: command.createdAt,
    );
  }

  @override
  List<OutboxRecord> loadOutboxQueue(String accountId, String deviceId) =>
      _outbox.values
          .where(
            (record) =>
                record.accountId == accountId &&
                record.senderDeviceId == deviceId,
          )
          .toList()
        ..sort((left, right) {
          final conversation = left.localChatId.compareTo(right.localChatId);
          if (conversation != 0) return conversation;
          final created = left.createdAt.compareTo(right.createdAt);
          return created != 0
              ? created
              : left.messageId.compareTo(right.messageId);
        });

  @override
  List<OutboxRecord> loadOutboxHeads(
    String accountId,
    String deviceId, {
    required int limit,
  }) {
    final heads = <String, OutboxRecord>{};
    for (final record in loadOutboxQueue(accountId, deviceId)) {
      heads.putIfAbsent(record.localChatId, () => record);
    }
    final ordered = heads.values.toList()
      ..sort((left, right) {
        final created = left.createdAt.compareTo(right.createdAt);
        return created != 0
            ? created
            : left.messageId.compareTo(right.messageId);
      });
    return ordered.take(limit).toList(growable: false);
  }

  @override
  List<OutboxRecord> loadPreparingSecretOutbox(
    String accountId,
    String deviceId, {
    required int limit,
  }) => loadOutboxQueue(accountId, deviceId)
      .where(
        (record) => record.isSecret && record.status == OutboxStatus.preparing,
      )
      .take(limit)
      .toList(growable: false);

  @override
  void markOutboxEncrypted(OutboxRecord outbox, List<int> ciphertext) {
    _outbox[outbox.messageId] = _copyOutbox(
      outbox,
      payload: Uint8List.fromList(ciphertext),
      status: OutboxStatus.pending,
    );
    _setMessageStatus(outbox.messageId, ChatDeliveryStatus.pending);
  }

  @override
  void markOutboxPayloadPrepared(OutboxRecord outbox, List<int> payload) {
    final current = _outbox[outbox.messageId] ?? outbox;
    _outbox[outbox.messageId] = _copyOutbox(
      current,
      payload: Uint8List.fromList(payload),
    );
  }

  @override
  void markOutboxPreparationFailed(OutboxRecord outbox) {
    _setMessageStatus(outbox.messageId, ChatDeliveryStatus.failed);
  }

  @override
  void reassignNormalOutbox(String accountId, String deviceId) {
    for (final record in _outbox.values.toList()) {
      if (record.accountId == accountId && !record.isSecret) {
        _outbox[record.messageId] = _copyOutbox(
          record,
          senderDeviceId: deviceId,
        );
      }
    }
  }

  @override
  void markOutboxSending(OutboxRecord outbox) {
    _outbox[outbox.messageId] = _copyOutbox(
      outbox,
      status: OutboxStatus.sending,
    );
    _setMessageStatus(outbox.messageId, ChatDeliveryStatus.sending);
  }

  @override
  void retryOutboxLater(
    OutboxRecord outbox, {
    required DateTime nextAttemptAt,
    required bool failed,
    bool countAttempt = true,
  }) {
    _outbox[outbox.messageId] = _copyOutbox(
      outbox,
      status: failed ? OutboxStatus.failed : OutboxStatus.pending,
      attempts: outbox.attempts + (countAttempt ? 1 : 0),
      nextAttemptAt: nextAttemptAt,
    );
    _setMessageStatus(
      outbox.messageId,
      failed ? ChatDeliveryStatus.failed : ChatDeliveryStatus.pending,
    );
  }

  @override
  void expireOutbox(OutboxRecord outbox) {
    _outbox[outbox.messageId] = _copyOutbox(
      outbox,
      status: OutboxStatus.failed,
    );
    _setMessageStatus(outbox.messageId, ChatDeliveryStatus.failed);
  }

  @override
  void markOutboxSent(OutboxRecord outbox, {DateTime? serverTimestamp}) {
    _outbox.remove(outbox.messageId);
    if (serverTimestamp != null) {
      canonicalTimestamps[outbox.messageId] = serverTimestamp;
    }
    _setMessageStatus(outbox.messageId, ChatDeliveryStatus.sent);
  }

  @override
  void resetSendingOutbox(String accountId) {
    for (final record
        in _outbox.values
            .where((record) => record.accountId == accountId)
            .toList()) {
      if (record.status == OutboxStatus.sending) {
        _outbox[record.messageId] = _copyOutbox(
          record,
          status: OutboxStatus.pending,
          nextAttemptAt: DateTime.now().toUtc(),
        );
        _setMessageStatus(record.messageId, ChatDeliveryStatus.pending);
      }
    }
  }

  @override
  bool retryFailedOutbox(String accountId, String deviceId, String messageId) {
    final record = _outbox[messageId];
    if (record == null ||
        record.accountId != accountId ||
        record.senderDeviceId != deviceId ||
        (record.status != OutboxStatus.failed &&
            record.status != OutboxStatus.preparing)) {
      return false;
    }
    _outbox[messageId] = _copyOutbox(
      record,
      status: record.status == OutboxStatus.preparing
          ? OutboxStatus.preparing
          : OutboxStatus.pending,
      attempts: 0,
      nextAttemptAt: DateTime.now().toUtc(),
      expiresAt: DateTime.now().toUtc().add(const Duration(hours: 24)),
    );
    _setMessageStatus(messageId, ChatDeliveryStatus.pending);
    return true;
  }

  @override
  bool saveIncomingMessage(
    ChatMessage message,
    Recipient recipient, {
    bool incrementUnread = true,
  }) {
    if (failIncomingWrites) throw StateError('SQLite write failed.');
    if (_deletedMessages.contains(message.messageId)) return false;
    final inserted = !_messages.containsKey(message.messageId);
    _messages.putIfAbsent(message.messageId, () => message);
    _applyQueuedReceiptStatus(message.messageId);
    final current = _recipients[recipient.id];
    _recipients[recipient.id] = recipient.copyWith(
      lastMessage: message.body,
      unreadCount:
          (current?.unreadCount ?? recipient.unreadCount) +
          (inserted && incrementUnread ? 1 : 0),
    );
    _notifyMessageWatchers(message.chatId);
    return inserted;
  }

  @override
  Future<List<bool>> saveIncomingMessages(
    List<IncomingMessageWrite> entries,
  ) async {
    incomingBatchCalls++;
    if (failIncomingWrites) throw StateError('SQLite write failed.');
    final results = <bool>[];
    final changedChats = <String>{};
    for (final entry in entries) {
      final message = entry.message;
      final recipient = entry.recipient;
      if (_deletedMessages.contains(message.messageId)) {
        results.add(false);
        continue;
      }
      final inserted = !_messages.containsKey(message.messageId);
      _messages.putIfAbsent(message.messageId, () => message);
      _applyQueuedReceiptStatus(message.messageId);
      final current = _recipients[recipient.id];
      _recipients[recipient.id] = recipient.copyWith(
        lastMessage: message.body,
        unreadCount:
            (current?.unreadCount ?? recipient.unreadCount) +
            (inserted && entry.incrementUnread ? 1 : 0),
      );
      changedChats.add(message.chatId);
      results.add(inserted);
    }
    for (final chatId in changedChats) {
      _notifyMessageWatchers(chatId);
    }
    return results;
  }

  @override
  Recipient? loadRecipient(String recipientId) => _recipients[recipientId];

  @override
  void deleteRecipient(String recipientId) {
    _recipients.remove(recipientId);
    _messages.removeWhere((_, message) => message.chatId == recipientId);
  }

  @override
  Stream<List<ChatMessage>> watchChatMessages(
    String chatId, {
    int limit = 100,
  }) => Stream<List<ChatMessage>>.multi((controller) {
    final watchers = _messageWatchers.putIfAbsent(chatId, () => {});
    watchers.add(controller);
    final messages = loadChatMessages(chatId);
    controller.add(
      messages
          .skip(messages.length > limit ? messages.length - limit : 0)
          .toList(growable: false),
    );
    controller.onCancel = () {
      watchers.remove(controller);
      if (watchers.isEmpty) _messageWatchers.remove(chatId);
    };
  });

  @override
  List<ChatMessage> loadChatMessages(String chatId) =>
      _messages.values.where((message) => message.chatId == chatId).toList();

  @override
  List<ChatMessage> loadEarlierChatMessages({
    required String chatId,
    required ChatMessage before,
    required int limit,
  }) {
    final earlier =
        loadChatMessages(chatId).where((message) {
          final created = message.createdAt.compareTo(before.createdAt);
          return created < 0 ||
              (created == 0 &&
                  message.messageId.compareTo(before.messageId) < 0);
        }).toList()..sort((left, right) {
          final created = left.createdAt.compareTo(right.createdAt);
          return created != 0
              ? created
              : left.messageId.compareTo(right.messageId);
        });
    return earlier
        .skip(earlier.length > limit ? earlier.length - limit : 0)
        .toList(growable: false);
  }

  @override
  ChatMessage? loadChatMessage(String messageId) => _messages[messageId];

  @override
  Map<String, MessageTranslation> loadMessageTranslations(
    List<String> messageIds, {
    required String targetLanguage,
  }) => {
    for (final messageId in messageIds)
      if (_translations['$messageId:$targetLanguage'] != null)
        messageId: _translations['$messageId:$targetLanguage']!,
  };

  @override
  bool saveMessageTranslation(MessageTranslation translation) {
    if (!_messages.containsKey(translation.messageId)) {
      throw StateError('Translation requires a locally stored message.');
    }
    if (_messages[translation.messageId]!.body != translation.sourceText) {
      return false;
    }
    _translations['${translation.messageId}:${translation.targetLanguage}'] =
        translation;
    return true;
  }

  @override
  bool isChatMessageDeleted(String messageId) =>
      _deletedMessages.contains(messageId);

  @override
  bool hasAppliedMessageMutation(String mutationId) =>
      _appliedMutations.contains(mutationId);

  @override
  void applyChatMessageEdit(ChatMessage message, String mutationId) {
    if (failMessageWrites) throw StateError('SQLite message write failed.');
    if (_messages[message.messageId]?.body != message.body) {
      _translations.removeWhere(
        (key, _) => key.startsWith('${message.messageId}:'),
      );
    }
    _messages[message.messageId] = message;
    _appliedMutations.add(mutationId);
    _notifyMessageWatchers(message.chatId);
  }

  @override
  void applyChatMessageDeletion(String messageId, String mutationId) {
    final message = _messages[messageId];
    _deletedMessages.add(messageId);
    _messages.remove(messageId);
    _appliedMutations.add(mutationId);
    if (message != null) _notifyMessageWatchers(message.chatId);
  }

  @override
  void saveMessageReceiptStatus(String messageId, ChatDeliveryStatus status) {
    final previous = _receiptStatuses[messageId];
    final monotonicStatus =
        previous == ChatDeliveryStatus.read || status == ChatDeliveryStatus.read
        ? ChatDeliveryStatus.read
        : ChatDeliveryStatus.delivered;
    _receiptStatuses[messageId] = monotonicStatus;
    _applyQueuedReceiptStatus(messageId);
  }

  void _applyQueuedReceiptStatus(String messageId) {
    final receiptStatus = _receiptStatuses[messageId];
    if (receiptStatus == null || !_messages.containsKey(messageId)) return;
    _receiptStatuses.remove(messageId);
    _outbox.remove(messageId);
    _setMessageStatus(messageId, receiptStatus);
  }

  @override
  bool hasCompletedSecretDelivery(String deliveryId) => secretDeliveries.any(
    (delivery) =>
        delivery.deliveryId == deliveryId &&
        _messages.containsKey(delivery.messageId),
  );

  @override
  bool saveIncomingSecretMessage({
    required SecretDeliveryRecord delivery,
    required ChatMessage message,
    required Recipient recipient,
  }) {
    if (failIncomingWrites) throw StateError('SQLite write failed.');
    final inserted = saveIncomingMessage(message, recipient);
    saveSecretDelivery(delivery);
    return inserted;
  }

  @override
  void deleteChatMessage(String messageId) {
    final message = _messages[messageId];
    _deletedMessages.add(messageId);
    _messages.remove(messageId);
    if (message != null) _notifyMessageWatchers(message.chatId);
  }

  @override
  void saveSecretDelivery(SecretDeliveryRecord delivery) {
    if (!secretDeliveries.any(
      (existing) => existing.deliveryId == delivery.deliveryId,
    )) {
      secretDeliveries.add(delivery);
    }
  }

  @override
  void deleteSecretDelivery(String deliveryId) {
    secretDeliveries.removeWhere(
      (delivery) => delivery.deliveryId == deliveryId,
    );
  }

  @override
  List<SecretDeliveryRecord> loadSecretDeliveries(String chatId) =>
      secretDeliveries.where((delivery) => delivery.chatId == chatId).toList();

  void _setMessageStatus(String messageId, ChatDeliveryStatus status) {
    final message = _messages[messageId];
    if (message == null) return;
    if (message.status == ChatDeliveryStatus.read ||
        (message.status == ChatDeliveryStatus.delivered &&
            status != ChatDeliveryStatus.read)) {
      return;
    }
    _messages[messageId] = ChatMessage(
      messageId: message.messageId,
      chatId: message.chatId,
      senderRecipientId: message.senderRecipientId,
      body: message.body,
      createdAt: message.createdAt,
      type: message.type,
      replyToMessageId: message.replyToMessageId,
      editedAt: message.editedAt,
      status: status,
    );
    _notifyMessageWatchers(message.chatId);
  }

  void _notifyMessageWatchers(String chatId) {
    final watchers = _messageWatchers[chatId];
    if (watchers == null) return;
    final messages = loadChatMessages(chatId);
    for (final watcher in watchers.toList()) {
      watcher.add(messages);
    }
  }

  OutboxRecord _copyOutbox(
    OutboxRecord record, {
    String? senderDeviceId,
    Uint8List? payload,
    OutboxStatus? status,
    int? attempts,
    DateTime? nextAttemptAt,
    DateTime? expiresAt,
  }) => OutboxRecord(
    accountId: record.accountId,
    messageId: record.messageId,
    senderDeviceId: senderDeviceId ?? record.senderDeviceId,
    localChatId: record.localChatId,
    chatId: record.chatId,
    senderRecipientId: record.senderRecipientId,
    targetRecipientId: record.targetRecipientId,
    targetDeviceId: record.targetDeviceId,
    isSecret: record.isSecret,
    messageType: record.messageType,
    payload: payload ?? record.payload,
    status: status ?? record.status,
    attempts: attempts ?? record.attempts,
    nextAttemptAt: nextAttemptAt ?? record.nextAttemptAt,
    createdAt: record.createdAt,
    expiresAt: expiresAt ?? record.expiresAt,
  );
}

class _FakeSecretChatCryptoPort implements SecretChatCryptoPort {
  final Uint8List ciphertext = Uint8List.fromList([0xff, 0x81, 0x05, 0x00]);
  Uint8List? plaintext;
  Uint8List? decryptedText;
  Object? encryptFailure;
  Completer<void>? encryptGate;
  int encryptCount = 0;
  int decryptCount = 0;

  @override
  Future<Uint8List> encrypt({
    required String secretChatId,
    required String recipientServerDeviceId,
    required Uint8List plaintext,
  }) async {
    encryptCount++;
    final failure = encryptFailure;
    if (failure != null) throw failure;
    await encryptGate?.future;
    this.plaintext = Uint8List.fromList(plaintext);
    return ciphertext;
  }

  @override
  Future<Uint8List> decrypt({
    required String secretChatId,
    required Uint8List ciphertext,
  }) async {
    decryptCount++;
    final plaintext = decryptedText;
    if (plaintext == null) {
      throw StateError('not configured in this test');
    }
    return Uint8List.fromList(plaintext);
  }
}
