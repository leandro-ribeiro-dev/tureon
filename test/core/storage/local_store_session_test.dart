import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:tureon/core/protocol/recipient.dart';
import 'package:tureon/core/protocol/recipient_type.dart';
import 'package:tureon/core/storage/local_store.dart';
import 'package:tureon/core/storage/local_store_schema.dart';
import 'package:tureon/core/storage/message_records.dart';

void main() {
  test(
    'session stream emits the saved snapshot and subsequent changes',
    () async {
      final store = LocalStore.inMemory();
      addTearDown(store.close);
      store.saveSession(
        const UserSession(
          userId: 'user-1',
          deviceId: 'device-1',
          accountStatus: 'under_review',
        ),
      );

      final sessions = StreamIterator(store.watchSession());
      addTearDown(sessions.cancel);

      expect(await sessions.moveNext(), isTrue);
      expect(sessions.current?.accountStatus, 'under_review');

      store.saveSession(
        const UserSession(
          userId: 'user-1',
          deviceId: 'device-1',
          accountStatus: 'restricted',
        ),
      );

      expect(await sessions.moveNext(), isTrue);
      expect(sessions.current?.accountStatus, 'restricted');
    },
  );

  test('session migration preserves account status with an active default', () {
    final database = sqlite3.openInMemory();
    database.execute('''
      CREATE TABLE session (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        user_id TEXT NOT NULL,
        access_token TEXT NOT NULL,
        refresh_token TEXT NOT NULL,
        device_id TEXT NOT NULL,
        signal_device_id INTEGER NOT NULL DEFAULT 1,
        updated_at INTEGER NOT NULL
      );
    ''');
    database.execute('''
      INSERT INTO session (
        id, user_id, access_token, refresh_token, device_id,
        signal_device_id, updated_at
      ) VALUES (1, 'user-1', '', '', 'device-1', 1, 1);
    ''');
    database.userVersion = 1;
    final store = LocalStore.migrateForTesting(database);
    addTearDown(store.close);

    expect(store.loadSession()?.accountStatus, 'active');
    store.saveSession(
      const UserSession(
        userId: 'user-1',
        deviceId: 'device-1',
        accountStatus: 'under_review',
      ),
    );

    expect(store.loadSession()?.accountStatus, 'under_review');
    expect(database.userVersion, LocalStoreSchema.version);
  });

  test('local schema migration removes the retired bot metadata cache', () {
    final database = sqlite3.openInMemory();
    database.execute('''
      CREATE TABLE account_owned_bots (
        account_id TEXT NOT NULL,
        bot_id TEXT NOT NULL,
        username TEXT NOT NULL,
        display_name TEXT NOT NULL,
        description TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        PRIMARY KEY (account_id, bot_id)
      );
    ''');
    database.userVersion = 5;

    final store = LocalStore.migrateForTesting(database);
    addTearDown(store.close);

    expect(database.select('PRAGMA table_info(account_owned_bots)'), isEmpty);
    expect(database.userVersion, LocalStoreSchema.version);
  });

  test('group and channel roles survive local recipient caching', () async {
    final store = LocalStore.inMemory();
    addTearDown(store.close);
    store.saveSession(
      const UserSession(userId: 'user-1', deviceId: 'device-1'),
    );
    const channel = Recipient(
      id: 'channel-id',
      type: RecipientType.channel,
      name: 'Updates',
      handle: '',
      composerRole: 'owner',
      canSendMessages: true,
      membersCanSendMessages: false,
    );

    await store.saveRecipient(channel);

    final restored = store.loadRecipient(channel.id);
    expect(restored?.composerRole, 'owner');
    expect(restored?.canSendMessages, isTrue);
    expect(restored?.membersCanSendMessages, isFalse);
  });

  test('local migration assigns group and channel send-policy defaults', () {
    final database = sqlite3.openInMemory();
    addTearDown(database.close);
    LocalStoreSchema.migrate(database);
    database.execute(
      'ALTER TABLE account_recipients DROP COLUMN members_can_send_messages',
    );
    database.execute('''
      INSERT INTO account_recipients(
        account_id, recipient_id, recipient_type, name, handle, updated_at
      ) VALUES
        ('account-1', 'group-1', ${RecipientType.group.index}, 'Group', '', 1),
        ('account-1', 'channel-1', ${RecipientType.channel.index}, 'Channel', '', 1)
    ''');
    database.userVersion = 3;

    LocalStoreSchema.migrate(database);

    final rows = database.select('''
      SELECT recipient_id, members_can_send_messages
      FROM account_recipients WHERE account_id = 'account-1'
      ORDER BY recipient_id
    ''');
    expect(rows.map((row) => row['members_can_send_messages']), [0, 1]);
    expect(database.userVersion, LocalStoreSchema.version);
  });
}
