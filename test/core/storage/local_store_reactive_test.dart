import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;
import 'package:tureon/core/protocol/recipient.dart';
import 'package:tureon/core/protocol/recipient_type.dart';
import 'package:tureon/core/storage/chat_store.dart';
import 'package:tureon/core/storage/local_store.dart';
import 'package:tureon/core/storage/message_records.dart';
import 'package:tureon/features/chats/domain/chat_message.dart';
import 'package:tureon/features/chats/domain/message_translation.dart';

void main() {
  late LocalStore store;

  setUp(() {
    store = LocalStore.inMemory();
    store.saveSession(
      const UserSession(userId: 'account-1', deviceId: 'device-1'),
    );
  });

  tearDown(() async {
    await store.close();
  });

  test('Drift streams reflect message and conversation writes', () async {
    final messageSnapshots = StreamIterator(store.watchChatMessages('peer-1'));
    final recipientSnapshots = StreamIterator(store.watchRecipients());

    expect(await messageSnapshots.moveNext(), isTrue);
    expect(messageSnapshots.current, isEmpty);
    expect(await recipientSnapshots.moveNext(), isTrue);
    expect(recipientSnapshots.current, isEmpty);

    final original = ChatMessage(
      messageId: 'message-1',
      chatId: 'peer-1',
      senderRecipientId: 'peer-1',
      body: 'hello',
      createdAt: DateTime.utc(2026, 10, 3),
    );
    const recipient = Recipient(
      id: 'peer-1',
      type: RecipientType.user,
      name: 'Peer',
      handle: '@peer',
    );

    expect(store.saveIncomingMessage(original, recipient), isTrue);
    expect(await messageSnapshots.moveNext(), isTrue);
    expect(messageSnapshots.current.single.body, 'hello');
    expect(await recipientSnapshots.moveNext(), isTrue);
    expect(recipientSnapshots.current.single.lastMessage, 'hello');

    store.saveMessageReceiptStatus(
      original.messageId,
      ChatDeliveryStatus.delivered,
    );
    expect(await messageSnapshots.moveNext(), isTrue);
    expect(
      messageSnapshots.current.single.status,
      ChatDeliveryStatus.delivered,
    );

    store.applyChatMessageEdit(
      ChatMessage(
        messageId: original.messageId,
        chatId: original.chatId,
        senderRecipientId: original.senderRecipientId,
        body: 'edited',
        createdAt: original.createdAt,
        editedAt: DateTime.utc(2026, 10, 3, 1),
        status: ChatDeliveryStatus.delivered,
      ),
      'mutation-1',
    );
    expect(await messageSnapshots.moveNext(), isTrue);
    expect(messageSnapshots.current.single.body, 'edited');

    store.applyChatMessageDeletion(original.messageId, 'mutation-2');
    expect(await messageSnapshots.moveNext(), isTrue);
    expect(messageSnapshots.current, isEmpty);

    await messageSnapshots.cancel();
    await recipientSnapshots.cancel();
  });

  test('incoming message batch commits and notifies watchers once', () async {
    final snapshots = StreamIterator(store.watchChatMessages('peer-batch'));
    expect(await snapshots.moveNext(), isTrue);
    expect(snapshots.current, isEmpty);

    final tableChanges = <Set<String>>[];
    final changesSubscription = store.watchTableChanges().listen(
      tableChanges.add,
    );
    const recipient = Recipient(
      id: 'peer-batch',
      type: RecipientType.user,
      name: 'Peer',
      handle: '@peer',
    );
    final saved = await store.saveIncomingMessages([
      for (final index in [1, 2])
        IncomingMessageWrite(
          message: ChatMessage(
            messageId: 'batch-$index',
            chatId: recipient.id,
            senderRecipientId: recipient.id,
            body: 'message $index',
            createdAt: DateTime.utc(2026, 10, 3, 0, index),
          ),
          recipient: recipient,
        ),
    ]);

    expect(saved, [true, true]);
    expect(tableChanges, hasLength(1));
    expect(await snapshots.moveNext(), isTrue);
    expect(snapshots.current, hasLength(2));
    expect(store.loadRecipient(recipient.id)?.unreadCount, 2);

    await changesSubscription.cancel();
    await snapshots.cancel();
  });

  test(
    'message translations persist locally per account and target language',
    () {
      final message = ChatMessage(
        messageId: 'translated-1',
        chatId: 'peer-1',
        senderRecipientId: 'peer-1',
        body: 'Hello there',
        createdAt: DateTime.utc(2026, 10, 3),
      );
      store.saveChatMessage(message);
      store.saveMessageTranslation(
        MessageTranslation(
          messageId: message.messageId,
          sourceText: message.body,
          targetLanguage: 'pt',
          sourceLanguage: 'en',
          translatedText: 'Olá',
          updatedAt: DateTime.utc(2026, 10, 3, 1),
        ),
      );

      expect(store.loadChatMessage(message.messageId)?.body, 'Hello there');
      expect(
        store.loadMessageTranslations([
          message.messageId,
        ], targetLanguage: 'pt')[message.messageId]?.translatedText,
        'Olá',
      );
      expect(
        store.loadMessageTranslations([
          message.messageId,
        ], targetLanguage: 'es'),
        isEmpty,
      );

      store.saveSession(
        const UserSession(userId: 'account-2', deviceId: 'device-2'),
      );
      expect(
        store.loadMessageTranslations([
          message.messageId,
        ], targetLanguage: 'pt'),
        isEmpty,
      );
      store.saveChatMessage(message);
      expect(
        store.loadMessageTranslations([
          message.messageId,
        ], targetLanguage: 'pt'),
        isEmpty,
      );

      store.saveSession(
        const UserSession(userId: 'account-1', deviceId: 'device-1'),
      );
      store.saveMessageTranslation(
        MessageTranslation(
          messageId: message.messageId,
          sourceText: message.body,
          targetLanguage: 'pt',
          sourceLanguage: 'en',
          translatedText: 'Olá',
          updatedAt: DateTime.utc(2026, 10, 3, 2),
        ),
      );
      store.applyChatMessageEdit(
        ChatMessage(
          messageId: message.messageId,
          chatId: message.chatId,
          senderRecipientId: message.senderRecipientId,
          body: 'Hello again',
          createdAt: message.createdAt,
          editedAt: DateTime.utc(2026, 10, 3, 3),
        ),
        'translation-edit-1',
      );
      expect(store.loadChatMessage(message.messageId)?.body, 'Hello again');
      expect(
        store.loadMessageTranslations([
          message.messageId,
        ], targetLanguage: 'pt'),
        isEmpty,
      );
      expect(
        store.saveMessageTranslation(
          MessageTranslation(
            messageId: message.messageId,
            sourceText: message.body,
            targetLanguage: 'pt',
            sourceLanguage: 'en',
            translatedText: 'Olá',
            updatedAt: DateTime.utc(2026, 10, 3, 4),
          ),
        ),
        isFalse,
      );
      store.deleteChatMessage(message.messageId);
      expect(
        store.loadMessageTranslations([
          message.messageId,
        ], targetLanguage: 'pt'),
        isEmpty,
      );
    },
  );

  test('secret delivery and message persist as one completed unit', () {
    const recipient = Recipient(
      id: 'peer-secret',
      type: RecipientType.user,
      name: 'Peer',
      handle: '@peer',
    );
    final message = ChatMessage(
      messageId: 'secret-message-1',
      chatId: 'secret-chat-1',
      senderRecipientId: recipient.id,
      body: 'decrypted on device',
      createdAt: DateTime.utc(2026, 10, 3),
    );
    final delivery = SecretDeliveryRecord(
      deliveryId: 'secret-delivery-1',
      messageId: message.messageId,
      chatId: message.chatId,
      senderRecipientId: recipient.id,
      targetRecipientId: 'account-1',
      messageType: 1,
      ciphertext: Uint8List.fromList([1, 2, 3]),
      timestamp: message.createdAt,
    );

    store.saveIncomingSecretMessage(
      delivery: delivery,
      message: message,
      recipient: recipient,
    );

    expect(store.loadChatMessage(message.messageId)?.body, message.body);
    expect(store.hasCompletedSecretDelivery(delivery.deliveryId), isTrue);
    expect(
      store.loadSecretDeliveries(message.chatId).single.deliveryId,
      delivery.deliveryId,
    );
  });

  test('secret delivery marker rolls back when message insert fails', () async {
    final database = sqlite.sqlite3.openInMemory();
    final transactionStore = LocalStore.migrateForTesting(database);
    transactionStore.saveSession(
      const UserSession(userId: 'account-transaction', deviceId: 'device-1'),
    );
    database.execute('''
      CREATE TRIGGER reject_incoming_chat_message
      BEFORE INSERT ON account_chat_messages
      BEGIN
        SELECT RAISE(ABORT, 'injected incoming message failure');
      END;
      ''');
    const recipient = Recipient(
      id: 'peer-transaction',
      type: RecipientType.user,
      name: 'Peer',
      handle: '@peer',
    );
    final message = ChatMessage(
      messageId: 'secret-message-transaction',
      chatId: 'secret-chat-transaction',
      senderRecipientId: recipient.id,
      body: 'decrypted on device',
      createdAt: DateTime.utc(2026, 10, 3),
    );
    final delivery = SecretDeliveryRecord(
      deliveryId: 'secret-delivery-transaction',
      messageId: message.messageId,
      chatId: message.chatId,
      senderRecipientId: recipient.id,
      targetRecipientId: 'account-transaction',
      messageType: 1,
      ciphertext: Uint8List.fromList([1, 2, 3]),
      timestamp: message.createdAt,
    );

    try {
      expect(
        () => transactionStore.saveIncomingSecretMessage(
          delivery: delivery,
          message: message,
          recipient: recipient,
        ),
        throwsA(anything),
      );
      expect(
        transactionStore.hasCompletedSecretDelivery(delivery.deliveryId),
        isFalse,
      );
      expect(transactionStore.loadSecretDeliveries(message.chatId), isEmpty);
      expect(transactionStore.loadChatMessage(message.messageId), isNull);
    } finally {
      await transactionStore.close();
    }
  });

  test(
    'message order uses microseconds when timestamps share a millisecond',
    () async {
      const recipient = Recipient(
        id: 'peer-micro-order',
        type: RecipientType.user,
        name: 'Peer',
        handle: '@peer',
      );
      final older = ChatMessage(
        messageId: 'z-older',
        chatId: recipient.id,
        senderRecipientId: recipient.id,
        body: 'older',
        createdAt: DateTime.utc(2026, 10, 7, 12, 0, 0, 100, 100),
      );
      final newer = ChatMessage(
        messageId: 'a-newer',
        chatId: recipient.id,
        senderRecipientId: recipient.id,
        body: 'newer',
        createdAt: DateTime.utc(2026, 10, 7, 12, 0, 0, 100, 900),
      );
      expect(
        older.createdAt.millisecondsSinceEpoch,
        newer.createdAt.millisecondsSinceEpoch,
      );

      await store.saveIncomingMessages([
        IncomingMessageWrite(message: older, recipient: recipient),
        IncomingMessageWrite(message: newer, recipient: recipient),
      ]);

      expect(
        store.loadChatMessages(recipient.id).map((message) => message.body),
        ['older', 'newer'],
      );
      expect(
        store
            .loadEarlierChatMessages(
              chatId: recipient.id,
              before: newer,
              limit: 1,
            )
            .single
            .body,
        'older',
      );
    },
  );

  test('Forja request and reply appear in the regular chat history', () async {
    final snapshots = StreamIterator(
      store.watchChatMessages('f04a0000-0000-4000-8000-000000000001'),
    );
    expect(await snapshots.moveNext(), isTrue);
    expect(snapshots.current, isEmpty);
    const forja = Recipient(
      id: 'f04a0000-0000-4000-8000-000000000001',
      type: RecipientType.bot,
      name: 'Forja',
      handle: '@forja_bot',
    );

    await store.saveIncomingMessages([
      IncomingMessageWrite(
        message: ChatMessage(
          messageId: 'forja-request',
          chatId: forja.id,
          senderRecipientId: 'account-1',
          body: '/start',
          createdAt: DateTime.utc(2026, 10, 7),
          status: ChatDeliveryStatus.sent,
        ),
        recipient: forja,
        incrementUnread: false,
      ),
      IncomingMessageWrite(
        message: ChatMessage(
          messageId: 'forja-reply',
          chatId: forja.id,
          senderRecipientId: forja.id,
          body: 'Olá! Envie /newbot.',
          createdAt: DateTime.utc(2026, 10, 7, 0, 0, 0, 1),
          status: ChatDeliveryStatus.sent,
        ),
        recipient: forja.copyWith(lastMessage: 'Olá! Envie /newbot.'),
        incrementUnread: false,
      ),
    ]);

    expect(await snapshots.moveNext(), isTrue);
    expect(snapshots.current, hasLength(2));
    expect(snapshots.current.first.body, '/start');
    expect(snapshots.current.last.senderRecipientId, forja.id);
    expect(snapshots.current.last.body, 'Olá! Envie /newbot.');
    expect(store.loadRecipient(forja.id)?.unreadCount, 0);
    await snapshots.cancel();
  });

  test('chat history is bounded and earlier pages use a stable cursor', () {
    for (var index = 0; index < 140; index++) {
      store.saveChatMessage(
        _message(
          'message-${index.toString().padLeft(3, '0')}',
          createdAt: DateTime.utc(2026, 10, 3).add(Duration(seconds: index)),
        ),
      );
    }

    final snapshots = StreamIterator(
      store.watchChatMessages('peer-1', limit: 20),
    );

    return snapshots.moveNext().then((hasSnapshot) async {
      expect(hasSnapshot, isTrue);
      expect(snapshots.current, hasLength(20));
      expect(snapshots.current.first.messageId, 'message-120');
      expect(snapshots.current.last.messageId, 'message-139');

      final earlier = store.loadEarlierChatMessages(
        chatId: 'peer-1',
        before: snapshots.current.first,
        limit: 10,
      );

      expect(earlier, hasLength(10));
      expect(earlier.first.messageId, 'message-110');
      expect(earlier.last.messageId, 'message-119');
      await snapshots.cancel();
    });
  });

  test(
    'account-scoped watchers rebind when the active session changes',
    () async {
      final messageSnapshots = StreamIterator(
        store.watchChatMessages('peer-1'),
      );
      final recipientSnapshots = StreamIterator(store.watchRecipients());

      expect(await messageSnapshots.moveNext(), isTrue);
      expect(messageSnapshots.current, isEmpty);
      expect(await recipientSnapshots.moveNext(), isTrue);
      expect(recipientSnapshots.current, isEmpty);

      store.saveIncomingMessage(
        ChatMessage(
          messageId: 'account-one-message',
          chatId: 'peer-1',
          senderRecipientId: 'peer-1',
          body: 'account one',
          createdAt: DateTime.utc(2026, 10, 3),
        ),
        const Recipient(
          id: 'peer-1',
          type: RecipientType.user,
          name: 'Peer one',
          handle: '@peer-one',
        ),
      );
      expect(await messageSnapshots.moveNext(), isTrue);
      expect(messageSnapshots.current.single.body, 'account one');
      expect(await recipientSnapshots.moveNext(), isTrue);
      expect(recipientSnapshots.current.single.name, 'Peer one');

      store.saveSession(
        const UserSession(userId: 'account-2', deviceId: 'device-2'),
      );
      expect(await messageSnapshots.moveNext(), isTrue);
      expect(messageSnapshots.current, isEmpty);
      expect(await recipientSnapshots.moveNext(), isTrue);
      expect(recipientSnapshots.current, isEmpty);

      store.saveIncomingMessage(
        ChatMessage(
          messageId: 'account-two-message',
          chatId: 'peer-1',
          senderRecipientId: 'peer-1',
          body: 'account two',
          createdAt: DateTime.utc(2026, 10, 3, 1),
        ),
        const Recipient(
          id: 'peer-1',
          type: RecipientType.user,
          name: 'Peer two',
          handle: '@peer-two',
        ),
      );
      expect(await messageSnapshots.moveNext(), isTrue);
      expect(messageSnapshots.current.single.body, 'account two');
      expect(await recipientSnapshots.moveNext(), isTrue);
      expect(recipientSnapshots.current.single.name, 'Peer two');

      await messageSnapshots.cancel();
      await recipientSnapshots.cancel();
    },
  );

  test(
    'clearLocalHistory emits empty message and recipient snapshots',
    () async {
      final messageSnapshots = StreamIterator(
        store.watchChatMessages('peer-1'),
      );
      final recipientSnapshots = StreamIterator(store.watchRecipients());
      expect(await messageSnapshots.moveNext(), isTrue);
      expect(await recipientSnapshots.moveNext(), isTrue);

      store.saveIncomingMessage(_message('history-message'), _recipient);
      expect(await messageSnapshots.moveNext(), isTrue);
      expect(await recipientSnapshots.moveNext(), isTrue);

      store.clearLocalHistory();

      expect(await _moveNext(messageSnapshots), isTrue);
      expect(messageSnapshots.current, isEmpty);
      expect(await _moveNext(recipientSnapshots), isTrue);
      expect(recipientSnapshots.current, isEmpty);

      await messageSnapshots.cancel();
      await recipientSnapshots.cancel();
    },
  );

  test(
    'clearSessionAndProfile emits profile and account-scoped snapshots',
    () async {
      store.saveCurrentUser(_profile);
      store.saveIncomingMessage(_message('session-message'), _recipient);
      final profileChanges = StreamIterator(store.watchProfileChanges());
      final messageSnapshots = StreamIterator(
        store.watchChatMessages('peer-1'),
      );
      final recipientSnapshots = StreamIterator(store.watchRecipients());
      expect(await messageSnapshots.moveNext(), isTrue);
      expect(messageSnapshots.current, hasLength(1));
      expect(await recipientSnapshots.moveNext(), isTrue);
      expect(recipientSnapshots.current, hasLength(1));
      final profileChange = _moveNext(profileChanges);

      store.clearSessionAndProfile();

      expect(await profileChange, isTrue);
      expect(await _moveNext(messageSnapshots), isTrue);
      expect(messageSnapshots.current, isEmpty);
      expect(await _moveNext(recipientSnapshots), isTrue);
      expect(recipientSnapshots.current, isEmpty);

      await profileChanges.cancel();
      await messageSnapshots.cancel();
      await recipientSnapshots.cancel();
    },
  );

  test('clearCurrentUser emits profile changes', () async {
    store.saveCurrentUser(_profile);
    final profileChanges = StreamIterator(store.watchProfileChanges());
    final profileChange = _moveNext(profileChanges);

    store.clearCurrentUser();

    expect(await profileChange, isTrue);
    await profileChanges.cancel();
  });

  test('clearProfile emits profile changes', () async {
    store.saveCurrentUser(_profile);
    final profileChanges = StreamIterator(store.watchProfileChanges());
    final profileChange = _moveNext(profileChanges);

    store.clearProfile('account-1');

    expect(await profileChange, isTrue);
    await profileChanges.cancel();
  });

  test('watchRecipient emits insert, update and delete snapshots', () async {
    final recipientSnapshots = StreamIterator(store.watchRecipient('peer-1'));
    expect(await recipientSnapshots.moveNext(), isTrue);
    expect(recipientSnapshots.current, isNull);

    await store.saveRecipient(_recipient);
    expect(await recipientSnapshots.moveNext(), isTrue);
    expect(recipientSnapshots.current?.name, 'Peer');

    await store.saveRecipient(_recipient.copyWith(name: 'Updated peer'));
    expect(await recipientSnapshots.moveNext(), isTrue);
    expect(recipientSnapshots.current?.name, 'Updated peer');

    store.deleteRecipient('peer-1');
    expect(await recipientSnapshots.moveNext(), isTrue);
    expect(recipientSnapshots.current, isNull);
    await _expectNoNext(recipientSnapshots);
    await recipientSnapshots.cancel();
  });

  test('a multi-statement transaction emits once per affected table', () async {
    store.saveMessageReceiptStatus(
      'batched-message',
      ChatDeliveryStatus.delivered,
    );
    final messageSnapshots = StreamIterator(store.watchChatMessages('peer-1'));
    final recipientSnapshots = StreamIterator(store.watchRecipients());
    expect(await messageSnapshots.moveNext(), isTrue);
    expect(await recipientSnapshots.moveNext(), isTrue);

    store.saveIncomingMessage(_message('batched-message'), _recipient);

    expect(await messageSnapshots.moveNext(), isTrue);
    expect(
      messageSnapshots.current.single.status,
      ChatDeliveryStatus.delivered,
    );
    expect(await recipientSnapshots.moveNext(), isTrue);
    expect(recipientSnapshots.current.single.lastMessage, 'hello');
    await _expectNoNext(messageSnapshots);
    await _expectNoNext(recipientSnapshots);

    await messageSnapshots.cancel();
    await recipientSnapshots.cancel();
  });

  test('writes publish one post-commit table batch', () async {
    final changes = <Set<String>>[];
    final subscription = store.watchTableChanges().listen(changes.add);

    store.saveIncomingMessage(_message('table-batch-message'), _recipient);

    expect(changes, [
      {'account_chat_messages', 'account_recipients'},
    ]);

    changes.clear();
    store.saveCurrentUser(_profile);
    expect(changes, [
      {'current_user', 'profile_sync_state'},
    ]);

    changes.clear();
    store.saveSetting('theme', 'dark');
    expect(changes, [
      <String>{'app_settings'},
    ]);

    await subscription.cancel();
  });

  test('a rolled back message transaction does not emit a snapshot', () async {
    final messageSnapshots = StreamIterator(store.watchChatMessages('peer-1'));
    final tableChanges = <Set<String>>[];
    final tableChangeSubscription = store.watchTableChanges().listen(
      tableChanges.add,
    );
    expect(await messageSnapshots.moveNext(), isTrue);
    expect(messageSnapshots.current, isEmpty);

    final message = _message('rollback-message');
    final outbox = _outbox(message.messageId);
    store.saveOutgoingMessage(message, outbox);
    expect(tableChanges, hasLength(1));
    tableChanges.clear();
    expect(await messageSnapshots.moveNext(), isTrue);
    expect(messageSnapshots.current.single.messageId, message.messageId);

    store.deleteChatMessage(message.messageId);
    expect(tableChanges, hasLength(1));
    tableChanges.clear();
    expect(await messageSnapshots.moveNext(), isTrue);
    expect(messageSnapshots.current, isEmpty);

    expect(() => store.saveOutgoingMessage(message, outbox), throwsA(anything));
    expect(store.loadChatMessages('peer-1'), isEmpty);
    expect(tableChanges, isEmpty);
    await _expectNoNext(messageSnapshots);
    await messageSnapshots.cancel();
    await tableChangeSubscription.cancel();
  });
}

const _watcherTimeout = Duration(milliseconds: 250);

Future<bool> _moveNext<T>(StreamIterator<T> iterator) =>
    iterator.moveNext().timeout(_watcherTimeout);

Future<void> _expectNoNext<T>(StreamIterator<T> iterator) async {
  await expectLater(_moveNext(iterator), throwsA(isA<TimeoutException>()));
}

ChatMessage _message(String id, {DateTime? createdAt}) => ChatMessage(
  messageId: id,
  chatId: 'peer-1',
  senderRecipientId: 'peer-1',
  body: 'hello',
  createdAt: createdAt ?? DateTime.utc(2026, 10, 3),
);

const _recipient = Recipient(
  id: 'peer-1',
  type: RecipientType.user,
  name: 'Peer',
  handle: '@peer',
);

const _profile = UserProfile(
  userId: 'account-1',
  username: 'account_1',
  displayName: 'Account One',
);

OutboxRecord _outbox(String messageId) {
  final timestamp = DateTime.utc(2026, 10, 3);
  return OutboxRecord(
    accountId: 'account-1',
    messageId: messageId,
    senderDeviceId: 'device-1',
    localChatId: 'peer-1',
    chatId: 'peer-1',
    senderRecipientId: 'account-1',
    targetRecipientId: 'peer-1',
    targetDeviceId: null,
    isSecret: false,
    messageType: 1,
    payload: Uint8List.fromList([1]),
    status: OutboxStatus.pending,
    attempts: 0,
    nextAttemptAt: timestamp,
    createdAt: timestamp,
    expiresAt: timestamp.add(const Duration(hours: 24)),
  );
}
