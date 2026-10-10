import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:tureon/core/protocol/recipient.dart';
import 'package:tureon/core/protocol/recipient_type.dart';
import 'package:tureon/core/storage/local_store.dart';
import 'package:tureon/core/storage/message_records.dart';
import 'package:tureon/features/home/data/local_home_repository.dart';

void main() {
  late LocalStore store;
  late LocalHomeRepository repository;

  setUp(() {
    store = LocalStore.inMemory();
    repository = LocalHomeRepository(store);
  });

  tearDown(() {
    store.close();
  });

  test(
    'watches the initial recipient list and local database changes',
    () async {
      final initial = Completer<List<Recipient>>();
      final updated = Completer<List<Recipient>>();
      var emissionCount = 0;
      final subscription = repository.watchRecipients().listen((recipients) {
        if (emissionCount++ == 0) {
          initial.complete(recipients);
        } else {
          updated.complete(recipients);
        }
      });

      expect(await initial.future, isEmpty);
      const recipient = Recipient(
        id: 'recipient-1',
        type: RecipientType.user,
        name: 'Peer',
        handle: '@peer',
      );
      await store.saveRecipient(recipient);

      expect((await updated.future).single.id, recipient.id);
      await subscription.cancel();
    },
  );

  test(
    'keeps the conversation list available offline from local storage alone',
    () async {
      final recipient = Recipient(
        id: 'offline-recipient',
        type: RecipientType.user,
        name: 'Offline Peer',
        handle: '@offline',
      );

      final recipients = repository.watchRecipients().where(
        (items) => items.any((item) => item.id == recipient.id),
      );

      await store.saveRecipient(recipient);

      final offlineList = await recipients.first;
      expect(offlineList.single.id, recipient.id);
      expect(
        (await repository.watchRecipients().first).single.id,
        recipient.id,
      );
    },
  );

  test('scopes pinned and archived conversations to the active account', () {
    store.saveSession(
      const UserSession(userId: 'account-a', deviceId: 'device-a'),
    );
    repository.savePinnedConversationIds({'pinned-a'});
    repository.saveArchivedConversationIds({'archived-a'});

    store.saveSession(
      const UserSession(userId: 'account-b', deviceId: 'device-b'),
    );
    expect(repository.loadPinnedConversationIds(), isEmpty);
    expect(repository.loadArchivedConversationIds(), isEmpty);

    store.saveSession(
      const UserSession(userId: 'account-a', deviceId: 'device-a'),
    );
    expect(repository.loadPinnedConversationIds(), {'pinned-a'});
    expect(repository.loadArchivedConversationIds(), {'archived-a'});
  });
}
