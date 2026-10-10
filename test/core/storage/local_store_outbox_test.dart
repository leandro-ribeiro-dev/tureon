import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:tureon/core/storage/local_store.dart';
import 'package:tureon/core/storage/message_records.dart';
import 'package:tureon/core/protocol/protocol_models.dart';
import 'package:tureon/features/chats/domain/chat_message.dart';

void main() {
  late LocalStore store;

  setUp(() {
    store = LocalStore.inMemory();
  });

  tearDown(() {
    store.close();
  });

  test(
    'outbox migrations persist pending ciphertext per account and device',
    () {
      const sessionA = UserSession(userId: 'account-a', deviceId: 'device-a');
      store.saveSession(sessionA);
      final message = _message('secret-message', 'account-a');
      final outbox = _outbox(
        accountId: sessionA.userId,
        message: message,
        deviceId: sessionA.deviceId,
        payload: [0, 255, 17, 128],
        isSecret: true,
      );

      store.saveOutgoingMessage(message, outbox);

      expect(
        store.loadChatMessage(message.messageId)?.status,
        ChatDeliveryStatus.pending,
      );
      final persisted = store.loadOutboxQueue(
        sessionA.userId,
        sessionA.deviceId,
      );
      expect(persisted.single.payload, [0, 255, 17, 128]);
      expect(persisted.single.status, OutboxStatus.pending);

      store.saveSession(
        const UserSession(userId: 'account-b', deviceId: 'device-b'),
      );
      expect(store.loadOutboxQueue('account-b', 'device-b'), isEmpty);
      expect(store.loadOutboxQueue('account-a', 'device-a'), hasLength(1));

      store.saveSession(sessionA);
      store.markOutboxSending(persisted.single);
      expect(
        store.loadChatMessage(message.messageId)?.status,
        ChatDeliveryStatus.sending,
      );
      store.resetSendingOutbox(sessionA.userId);
      expect(
        store.loadOutboxQueue(sessionA.userId, sessionA.deviceId).single.status,
        OutboxStatus.pending,
      );
      expect(
        store.loadChatMessage(message.messageId)?.status,
        ChatDeliveryStatus.pending,
      );

      final reloaded = store.loadOutboxQueue(
        sessionA.userId,
        sessionA.deviceId,
      );
      store.markOutboxSent(reloaded.single);
      expect(
        store.loadOutboxQueue(sessionA.userId, sessionA.deviceId),
        isEmpty,
      );
      expect(
        store.loadChatMessage(message.messageId)?.status,
        ChatDeliveryStatus.sent,
      );
    },
  );

  test('persists optimistic mutations and read receipts atomically', () async {
    const session = UserSession(userId: 'account-a', deviceId: 'device-a');
    store.saveSession(session);
    await store.saveRecipient(
      const Recipient(
        id: 'peer',
        type: RecipientType.user,
        name: 'Peer',
        handle: '@peer',
        unreadCount: 1,
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 2));
    await store.saveRecipient(
      const Recipient(
        id: 'newer-peer',
        type: RecipientType.user,
        name: 'Newer peer',
        handle: '@newer',
        lastMessage: 'recent activity',
      ),
    );
    final orderBeforeRead = store.loadRecipients().map((r) => r.id).toList();
    final incoming = ChatMessage(
      messageId: 'incoming-message',
      chatId: 'peer',
      senderRecipientId: 'peer',
      body: 'hello',
      createdAt: DateTime.utc(2026),
    );
    store.saveChatMessage(incoming);
    final now = DateTime.now().toUtc();
    final readCommand = PendingChatCommand(
      accountId: session.userId,
      commandId: 'read:incoming-message',
      relatedMessageId: 'incoming-message',
      type: PendingChatCommandType.readReceipt,
      payload: Uint8List.fromList([4, 5]),
      attempts: 0,
      nextAttemptAt: now,
      createdAt: now,
    );

    store.enqueueReadReceipts(
      commands: [readCommand],
      readMessageIds: [incoming.messageId],
      peerRecipientId: 'peer',
    );
    expect(store.loadRecipients().map((r) => r.id).toList(), orderBeforeRead);
    expect(
      store.loadChatMessage(incoming.messageId)?.status,
      ChatDeliveryStatus.read,
    );
    expect(store.loadRecipient('peer')?.unreadCount, 0);
    expect(
      store.loadPendingChatCommands(session.userId, limit: 10).single.payload,
      [4, 5],
    );

    final edited = ChatMessage(
      messageId: incoming.messageId,
      chatId: incoming.chatId,
      senderRecipientId: incoming.senderRecipientId,
      body: 'edited offline',
      createdAt: incoming.createdAt,
      editedAt: now,
      status: ChatDeliveryStatus.read,
    );
    store.enqueueMessageMutation(
      command: PendingChatCommand(
        accountId: session.userId,
        commandId: 'edit-1',
        relatedMessageId: incoming.messageId,
        type: PendingChatCommandType.messageMutation,
        payload: Uint8List.fromList([6, 7]),
        attempts: 0,
        nextAttemptAt: now,
        createdAt: now,
      ),
      editedMessage: edited,
    );
    expect(store.loadChatMessage(incoming.messageId)?.body, 'edited offline');
    expect(
      store
          .loadPendingChatCommands(session.userId, limit: 10)
          .map((command) => command.commandId),
      ['read:incoming-message', 'edit-1'],
    );

    store.enqueueMessageMutation(
      command: PendingChatCommand(
        accountId: session.userId,
        commandId: 'delete-1',
        relatedMessageId: incoming.messageId,
        type: PendingChatCommandType.messageMutation,
        payload: Uint8List.fromList([8]),
        attempts: 0,
        nextAttemptAt: now,
        createdAt: now,
      ),
      deletedMessageId: incoming.messageId,
    );
    expect(store.loadChatMessage(incoming.messageId), isNull);
    expect(store.isChatMessageDeleted(incoming.messageId), isTrue);
    expect(
      store
          .loadPendingChatCommands(session.userId, limit: 10)
          .map((command) => command.commandId),
      ['read:incoming-message', 'edit-1', 'delete-1'],
    );
  });

  test('message and outbox insert roll back together on duplicate id', () {
    store.saveSession(
      const UserSession(userId: 'account-a', deviceId: 'device-a'),
    );
    final original = _message('same-id', 'first body');
    store.saveOutgoingMessage(
      original,
      _outbox(
        accountId: 'account-a',
        message: original,
        deviceId: 'device-a',
        payload: [1],
      ),
    );

    final duplicate = _message('same-id', 'must not replace');
    expect(
      () => store.saveOutgoingMessage(
        duplicate,
        _outbox(
          accountId: 'account-a',
          message: duplicate,
          deviceId: 'device-a',
          payload: [2],
        ),
      ),
      throwsA(anything),
    );

    expect(store.loadChatMessage('same-id')?.body, 'first body');
    expect(store.loadOutboxQueue('account-a', 'device-a').single.payload, [1]);
  });

  test('outbox head query bounds results and preserves per-chat ordering', () {
    store.saveSession(
      const UserSession(userId: 'account-a', deviceId: 'device-a'),
    );
    final firstA = _message('a-first', 'a first', chatId: 'chat-a');
    final secondA = _message(
      'a-second',
      'a second',
      chatId: 'chat-a',
      createdAt: DateTime.utc(2026, 10, 3),
    );
    final firstB = _message('b-first', 'b first', chatId: 'chat-b');
    for (final message in [firstA, secondA, firstB]) {
      store.saveOutgoingMessage(
        message,
        _outbox(
          accountId: 'account-a',
          message: message,
          deviceId: 'device-a',
          payload: [1],
        ),
      );
    }

    final heads = store.loadOutboxHeads('account-a', 'device-a', limit: 2);

    expect(heads.map((record) => record.messageId), ['a-first', 'b-first']);
  });

  test('outbox order uses message creation micros, not random ids', () {
    store.saveSession(
      const UserSession(userId: 'account-a', deviceId: 'device-a'),
    );
    final first = _message(
      'z-first',
      'first',
      createdAt: DateTime.utc(2026, 10, 2).add(const Duration(microseconds: 1)),
    );
    final second = _message(
      'a-second',
      'second',
      createdAt: DateTime.utc(2026, 10, 2).add(const Duration(microseconds: 2)),
    );
    for (final message in [first, second]) {
      store.saveOutgoingMessage(
        message,
        _outbox(
          accountId: 'account-a',
          message: message,
          deviceId: 'device-a',
          payload: [1],
        ),
      );
    }

    expect(
      store.loadOutboxHeads('account-a', 'device-a', limit: 1).single.messageId,
      first.messageId,
    );
  });

  test('secret preparation intent becomes sendable only after encryption', () {
    store.saveSession(
      const UserSession(userId: 'account-a', deviceId: 'device-a'),
    );
    final message = _message('secret-preparing', 'secret body');
    final outbox = _outbox(
      accountId: 'account-a',
      message: message,
      deviceId: 'device-a',
      payload: [115, 101, 99, 114, 101, 116],
      isSecret: true,
      status: OutboxStatus.preparing,
    );

    store.saveOutgoingMessage(message, outbox);

    final preparing = store.loadPreparingSecretOutbox(
      'account-a',
      'device-a',
      limit: 1,
    );
    expect(preparing.single.payload, [115, 101, 99, 114, 101, 116]);
    expect(preparing.single.status, OutboxStatus.preparing);

    store.markOutboxEncrypted(outbox, [0, 255, 128]);

    expect(
      store.loadPreparingSecretOutbox('account-a', 'device-a', limit: 1),
      isEmpty,
    );
    expect(store.loadOutboxQueue('account-a', 'device-a').single.payload, [
      0,
      255,
      128,
    ]);
    expect(
      store.loadOutboxQueue('account-a', 'device-a').single.status,
      OutboxStatus.pending,
    );
  });

  test('device handoff reassigns normal messages but pins secret messages', () {
    store.saveSession(
      const UserSession(userId: 'account-a', deviceId: 'device-a'),
    );
    final normal = _message('normal-message', 'normal');
    final secret = _message('secret-message', 'secret');
    store.saveOutgoingMessage(
      normal,
      _outbox(
        accountId: 'account-a',
        message: normal,
        deviceId: 'device-a',
        payload: [1],
      ),
    );
    store.saveOutgoingMessage(
      secret,
      _outbox(
        accountId: 'account-a',
        message: secret,
        deviceId: 'device-a',
        payload: [2],
        isSecret: true,
      ),
    );

    store.reassignNormalOutbox('account-a', 'device-b');

    expect(
      store.loadOutboxQueue('account-a', 'device-b').single.messageId,
      'normal-message',
    );
    expect(
      store.loadOutboxQueue('account-a', 'device-a').single.messageId,
      'secret-message',
    );
    expect(store.loadOutboxQueue('account-b', 'device-b'), isEmpty);
  });

  test('failed messages can be requeued only by their originating device', () {
    store.saveSession(
      const UserSession(userId: 'account-a', deviceId: 'device-a'),
    );
    final message = _message('failed-id', 'body');
    final outbox = _outbox(
      accountId: 'account-a',
      message: message,
      deviceId: 'device-a',
      payload: [4, 5],
    );
    store.saveOutgoingMessage(message, outbox);
    store.retryOutboxLater(
      outbox,
      nextAttemptAt: DateTime.utc(2026, 10, 2),
      failed: true,
    );

    expect(
      store.retryFailedOutbox('account-a', 'other-device', 'failed-id'),
      isFalse,
    );
    expect(
      store.retryFailedOutbox('account-a', 'device-a', 'failed-id'),
      isTrue,
    );
    expect(
      store.loadChatMessage('failed-id')?.status,
      ChatDeliveryStatus.pending,
    );
    expect(store.loadOutboxQueue('account-a', 'device-a').single.attempts, 0);
  });

  test('outbox expires after 24 hours and manual retry restarts its TTL', () {
    store.saveSession(
      const UserSession(userId: 'account-a', deviceId: 'device-a'),
    );
    final createdAt = DateTime.now().toUtc().subtract(
      const Duration(hours: 25),
    );
    final message = ChatMessage(
      messageId: 'expired-message',
      chatId: 'peer',
      senderRecipientId: 'account-a',
      body: 'body',
      createdAt: createdAt,
      status: ChatDeliveryStatus.pending,
    );
    final outbox = OutboxRecord(
      accountId: 'account-a',
      messageId: message.messageId,
      senderDeviceId: 'device-a',
      localChatId: message.chatId,
      chatId: message.chatId,
      senderRecipientId: message.senderRecipientId,
      targetRecipientId: 'peer',
      targetDeviceId: null,
      isSecret: false,
      messageType: 1,
      payload: Uint8List.fromList([1]),
      status: OutboxStatus.pending,
      attempts: 1,
      nextAttemptAt: createdAt,
      createdAt: createdAt,
      expiresAt: createdAt.add(const Duration(hours: 24)),
    );
    store.saveOutgoingMessage(message, outbox);

    store.expireOutbox(outbox);

    expect(
      store.loadChatMessage(message.messageId)?.status,
      ChatDeliveryStatus.failed,
    );
    expect(
      store.loadOutboxQueue('account-a', 'device-a').single.status,
      OutboxStatus.failed,
    );
    expect(store.loadOutboxHeads('account-a', 'device-a', limit: 10), isEmpty);

    expect(
      store.retryFailedOutbox('account-a', 'device-a', message.messageId),
      isTrue,
    );
    final retried = store.loadOutboxQueue('account-a', 'device-a').single;
    expect(retried.status, OutboxStatus.pending);
    expect(retried.attempts, 0);
    expect(retried.expiresAt.isAfter(DateTime.now().toUtc()), isTrue);
  });

  test('receipt status survives message arrival and never regresses', () {
    store.saveSession(
      const UserSession(userId: 'account-a', deviceId: 'device-a'),
    );
    store.saveMessageReceiptStatus('receipt-first', ChatDeliveryStatus.read);

    final message = _message('receipt-first', 'body');
    store.saveOutgoingMessage(
      message,
      _outbox(
        accountId: 'account-a',
        message: message,
        deviceId: 'device-a',
        payload: [1],
      ),
    );

    expect(
      store.loadChatMessage(message.messageId)?.status,
      ChatDeliveryStatus.read,
    );
    expect(store.loadOutboxQueue('account-a', 'device-a'), isEmpty);

    store.saveMessageReceiptStatus(
      message.messageId,
      ChatDeliveryStatus.delivered,
    );
    expect(
      store.loadChatMessage(message.messageId)?.status,
      ChatDeliveryStatus.read,
    );
  });

  test('pending receipt status is isolated between accounts', () {
    store.saveSession(
      const UserSession(userId: 'account-a', deviceId: 'device-a'),
    );
    store.saveMessageReceiptStatus('shared-id', ChatDeliveryStatus.read);

    store.saveSession(
      const UserSession(userId: 'account-b', deviceId: 'device-b'),
    );
    final message = ChatMessage(
      messageId: 'shared-id',
      chatId: 'peer',
      senderRecipientId: 'account-b',
      body: 'body',
      createdAt: DateTime.utc(2026, 10, 2),
      status: ChatDeliveryStatus.pending,
    );
    store.saveOutgoingMessage(
      message,
      _outbox(
        accountId: 'account-b',
        message: message,
        deviceId: 'device-b',
        payload: [1],
      ),
    );

    expect(
      store.loadChatMessage('shared-id')?.status,
      ChatDeliveryStatus.pending,
    );
    expect(store.loadOutboxQueue('account-b', 'device-b'), hasLength(1));
  });

  test(
    'deletion tombstones are account-scoped and block message resurrection',
    () {
      store.saveSession(
        const UserSession(userId: 'account-a', deviceId: 'device-a'),
      );
      final deleted = _message('deleted-id', 'body');
      store.saveChatMessage(deleted);
      store.deleteChatMessage(deleted.messageId);
      expect(store.isChatMessageDeleted(deleted.messageId), isTrue);
      expect(
        store.saveIncomingMessage(
          deleted,
          const Recipient(
            id: 'peer',
            type: RecipientType.user,
            name: 'Peer',
            handle: '@peer',
          ),
        ),
        isFalse,
      );
      expect(store.loadChatMessage(deleted.messageId), isNull);

      store.saveSession(
        const UserSession(userId: 'account-b', deviceId: 'device-b'),
      );
      expect(store.isChatMessageDeleted(deleted.messageId), isFalse);
      expect(
        store.saveIncomingMessage(
          ChatMessage(
            messageId: deleted.messageId,
            chatId: 'peer',
            senderRecipientId: 'peer',
            body: 'other account message',
            createdAt: DateTime.utc(2026, 10, 2),
          ),
          const Recipient(
            id: 'peer',
            type: RecipientType.user,
            name: 'Peer',
            handle: '@peer',
          ),
        ),
        isTrue,
      );
      expect(
        store.loadChatMessage(deleted.messageId)?.body,
        'other account message',
      );
    },
  );

  test('mutation application is durable and scoped by account', () {
    store.saveSession(
      const UserSession(userId: 'account-a', deviceId: 'device-a'),
    );
    final original = _message('mutation-source', 'before');
    store.saveChatMessage(original);
    store.applyChatMessageEdit(
      ChatMessage(
        messageId: original.messageId,
        chatId: original.chatId,
        senderRecipientId: original.senderRecipientId,
        body: 'after',
        createdAt: original.createdAt,
        editedAt: DateTime.utc(2026, 10, 2, 12),
      ),
      'edit-event-1',
    );
    expect(store.hasAppliedMessageMutation('edit-event-1'), isTrue);
    expect(store.loadChatMessage(original.messageId)?.body, 'after');

    store.applyChatMessageDeletion(original.messageId, 'delete-event-1');
    expect(store.hasAppliedMessageMutation('delete-event-1'), isTrue);
    expect(store.isChatMessageDeleted(original.messageId), isTrue);

    store.saveSession(
      const UserSession(userId: 'account-b', deviceId: 'device-b'),
    );
    expect(store.hasAppliedMessageMutation('edit-event-1'), isFalse);
    expect(store.hasAppliedMessageMutation('delete-event-1'), isFalse);
    expect(store.isChatMessageDeleted(original.messageId), isFalse);
  });
}

ChatMessage _message(
  String id,
  String body, {
  String chatId = 'peer',
  DateTime? createdAt,
}) => ChatMessage(
  messageId: id,
  chatId: chatId,
  senderRecipientId: 'account-a',
  body: body,
  createdAt: createdAt ?? DateTime.utc(2026, 10, 2),
  status: ChatDeliveryStatus.pending,
);

OutboxRecord _outbox({
  required String accountId,
  required ChatMessage message,
  required String deviceId,
  required List<int> payload,
  bool isSecret = false,
  OutboxStatus status = OutboxStatus.pending,
}) => OutboxRecord(
  accountId: accountId,
  messageId: message.messageId,
  senderDeviceId: deviceId,
  localChatId: message.chatId,
  chatId: message.chatId,
  senderRecipientId: message.senderRecipientId,
  targetRecipientId: 'peer',
  targetDeviceId: null,
  isSecret: isSecret,
  messageType: 1,
  payload: Uint8List.fromList(payload),
  status: status,
  attempts: 0,
  nextAttemptAt: DateTime.utc(2026, 10, 2),
  createdAt: message.createdAt,
  expiresAt: message.createdAt.add(const Duration(hours: 24)),
);
