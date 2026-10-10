import 'package:sqlite3/sqlite3.dart';

class LocalStoreSchema {
  LocalStoreSchema._();

  static const version = 18;

  static void migrate(Database database) {
    final databaseHandle = database;
    final previousVersion = databaseHandle.userVersion;
    databaseHandle.execute('PRAGMA foreign_keys = ON;');
    databaseHandle.execute('PRAGMA journal_mode = WAL;');
    databaseHandle.execute('PRAGMA synchronous = FULL;');
    databaseHandle.execute('PRAGMA temp_store = MEMORY;');
    databaseHandle.execute('''
      CREATE TABLE IF NOT EXISTS schema_info (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      );
    ''');
    databaseHandle.execute('''
      CREATE TABLE IF NOT EXISTS envelopes (
        envelope_id TEXT PRIMARY KEY,
        sender_recipient_id TEXT NOT NULL,
        target_recipient_id TEXT NOT NULL,
        target_device_id TEXT NOT NULL,
        message_type INTEGER NOT NULL,
        ciphertext BLOB NOT NULL,
        timestamp INTEGER NOT NULL,
        delivery_status INTEGER NOT NULL,
        received_at INTEGER NOT NULL
      );
    ''');
    databaseHandle.execute('''
      CREATE TABLE IF NOT EXISTS system_messages (
        message_id TEXT PRIMARY KEY,
        recipient_id TEXT NOT NULL,
        event_type INTEGER NOT NULL,
        actor_user_id TEXT NOT NULL,
        target_user_id TEXT,
        group_id TEXT,
        channel_id TEXT,
        reason TEXT,
        metadata_json TEXT,
        timestamp INTEGER NOT NULL
      );
    ''');
    databaseHandle.execute('''
      CREATE TABLE IF NOT EXISTS sync_state (
        stream_name TEXT PRIMARY KEY,
        last_started_at INTEGER,
        last_error TEXT
      );
    ''');
    databaseHandle.execute('''
      CREATE TABLE IF NOT EXISTS current_user (
        user_id TEXT PRIMARY KEY,
        username TEXT NOT NULL,
        display_name TEXT NOT NULL,
        bio TEXT,
        avatar_url TEXT,
        phone_e164 TEXT NOT NULL DEFAULT '',
        country_code TEXT NOT NULL DEFAULT '',
        birthday TEXT NOT NULL DEFAULT '',
        created_at INTEGER,
        privacy_settings TEXT NOT NULL DEFAULT '{}',
        verification_badge TEXT NOT NULL DEFAULT 'none',
        profile_initialized INTEGER NOT NULL DEFAULT 1,
        profile_version INTEGER NOT NULL DEFAULT 1,
        updated_at INTEGER NOT NULL
      );
    ''');
    final currentUserColumns = databaseHandle.select(
      'PRAGMA table_info(current_user)',
    );
    if (!currentUserColumns.any((column) => column['name'] == 'phone_e164')) {
      databaseHandle.execute(
        "ALTER TABLE current_user ADD COLUMN phone_e164 TEXT NOT NULL DEFAULT ''",
      );
    }
    if (!currentUserColumns.any((column) => column['name'] == 'country_code')) {
      databaseHandle.execute(
        "ALTER TABLE current_user ADD COLUMN country_code TEXT NOT NULL DEFAULT ''",
      );
    }
    if (!currentUserColumns.any((column) => column['name'] == 'created_at')) {
      databaseHandle.execute(
        'ALTER TABLE current_user ADD COLUMN created_at INTEGER',
      );
    }
    if (!currentUserColumns.any(
      (column) => column['name'] == 'verification_badge',
    )) {
      databaseHandle.execute(
        "ALTER TABLE current_user ADD COLUMN verification_badge TEXT NOT NULL DEFAULT 'none'",
      );
    }
    if (!currentUserColumns.any((column) => column['name'] == 'birthday')) {
      databaseHandle.execute(
        "ALTER TABLE current_user ADD COLUMN birthday TEXT NOT NULL DEFAULT ''",
      );
    }
    if (!currentUserColumns.any(
      (column) => column['name'] == 'privacy_settings',
    )) {
      databaseHandle.execute(
        "ALTER TABLE current_user ADD COLUMN privacy_settings TEXT NOT NULL DEFAULT '{}'",
      );
    }
    if (!currentUserColumns.any(
      (column) => column['name'] == 'profile_initialized',
    )) {
      databaseHandle.execute(
        'ALTER TABLE current_user ADD COLUMN profile_initialized INTEGER NOT NULL DEFAULT 0',
      );
    }
    if (!currentUserColumns.any(
      (column) => column['name'] == 'profile_version',
    )) {
      databaseHandle.execute(
        'ALTER TABLE current_user ADD COLUMN profile_version INTEGER NOT NULL DEFAULT 1',
      );
    }
    databaseHandle.execute('''
      CREATE TABLE IF NOT EXISTS profile_sync_state (
        user_id TEXT PRIMARY KEY,
        dirty INTEGER NOT NULL DEFAULT 1,
        revision INTEGER NOT NULL DEFAULT 1,
        base_profile_json TEXT,
        base_version INTEGER
      );
    ''');
    final profileSyncColumns = databaseHandle.select(
      'PRAGMA table_info(profile_sync_state)',
    );
    if (!profileSyncColumns.any(
      (column) => column['name'] == 'base_profile_json',
    )) {
      databaseHandle.execute(
        'ALTER TABLE profile_sync_state ADD COLUMN base_profile_json TEXT',
      );
    }
    if (!profileSyncColumns.any((column) => column['name'] == 'base_version')) {
      databaseHandle.execute(
        'ALTER TABLE profile_sync_state ADD COLUMN base_version INTEGER',
      );
    }
    databaseHandle.execute('''
      CREATE TABLE IF NOT EXISTS session (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        user_id TEXT NOT NULL,
        access_token TEXT NOT NULL,
        refresh_token TEXT NOT NULL,
        device_id TEXT NOT NULL,
        signal_device_id INTEGER NOT NULL DEFAULT 1,
        account_status TEXT NOT NULL DEFAULT 'active',
        needs_username INTEGER NOT NULL DEFAULT 0,
        updated_at INTEGER NOT NULL
      );
    ''');
    final sessionColumns = databaseHandle.select('PRAGMA table_info(session)');
    if (!sessionColumns.any((column) => column['name'] == 'signal_device_id')) {
      databaseHandle.execute(
        'ALTER TABLE session ADD COLUMN signal_device_id INTEGER NOT NULL DEFAULT 1',
      );
    }
    if (!sessionColumns.any((column) => column['name'] == 'account_status')) {
      databaseHandle.execute(
        "ALTER TABLE session ADD COLUMN account_status TEXT NOT NULL DEFAULT 'active'",
      );
    }
    if (!sessionColumns.any((column) => column['name'] == 'needs_username')) {
      databaseHandle.execute(
        'ALTER TABLE session ADD COLUMN needs_username INTEGER NOT NULL DEFAULT 0',
      );
    }
    databaseHandle.execute('''
      CREATE TABLE IF NOT EXISTS app_settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      );
    ''');
    databaseHandle.execute(
      "UPDATE session SET access_token = '', refresh_token = ''",
    );
    databaseHandle.execute('''
      CREATE TABLE IF NOT EXISTS recipients (
        recipient_id TEXT PRIMARY KEY,
        recipient_type INTEGER NOT NULL,
        is_member INTEGER NOT NULL DEFAULT 1,
        name TEXT NOT NULL,
        handle TEXT NOT NULL,
        avatar_url TEXT,
        description TEXT NOT NULL DEFAULT '',
        is_username_visible INTEGER NOT NULL DEFAULT 0,
        last_message TEXT,
        unread_count INTEGER NOT NULL DEFAULT 0,
        is_online INTEGER NOT NULL DEFAULT 0,
        is_presence_visible INTEGER NOT NULL DEFAULT 0,
        verification_badge TEXT NOT NULL DEFAULT 'none',
        updated_at INTEGER NOT NULL
      );
    ''');
    final recipientColumns = databaseHandle.select(
      'PRAGMA table_info(recipients)',
    );
    if (!recipientColumns.any(
      (column) => column['name'] == 'verification_badge',
    )) {
      databaseHandle.execute(
        "ALTER TABLE recipients ADD COLUMN verification_badge TEXT NOT NULL DEFAULT 'none'",
      );
    }
    if (!recipientColumns.any((column) => column['name'] == 'avatar_url')) {
      databaseHandle.execute(
        'ALTER TABLE recipients ADD COLUMN avatar_url TEXT',
      );
    }
    if (!recipientColumns.any(
      (column) => column['name'] == 'is_username_visible',
    )) {
      databaseHandle.execute(
        'ALTER TABLE recipients ADD COLUMN is_username_visible INTEGER NOT NULL DEFAULT 0',
      );
    }
    if (!recipientColumns.any(
      (column) => column['name'] == 'is_presence_visible',
    )) {
      databaseHandle.execute(
        'ALTER TABLE recipients ADD COLUMN is_presence_visible INTEGER NOT NULL DEFAULT 0',
      );
    }
    databaseHandle.execute('''
      CREATE TABLE IF NOT EXISTS chat_messages (
        message_id TEXT PRIMARY KEY,
        chat_id TEXT NOT NULL,
        sender_recipient_id TEXT NOT NULL,
        body TEXT NOT NULL,
        message_type INTEGER NOT NULL,
        reply_to_message_id TEXT,
        created_at INTEGER NOT NULL,
        edited_at INTEGER,
        delivery_status INTEGER NOT NULL
      );
    ''');
    databaseHandle.execute('''
      CREATE TABLE IF NOT EXISTS secret_deliveries (
        delivery_id TEXT PRIMARY KEY,
        message_id TEXT NOT NULL,
        chat_id TEXT NOT NULL,
        sender_recipient_id TEXT NOT NULL,
        target_recipient_id TEXT NOT NULL,
        message_type INTEGER NOT NULL,
        ciphertext BLOB NOT NULL,
        timestamp INTEGER NOT NULL
      );
    ''');
    databaseHandle.execute('''
      CREATE TABLE IF NOT EXISTS signal_protocol_records (
        record_key TEXT PRIMARY KEY,
        encrypted_record BLOB NOT NULL
      );
    ''');
    databaseHandle.execute('''
      CREATE TABLE IF NOT EXISTS account_recipients (
        account_id TEXT NOT NULL,
        recipient_id TEXT NOT NULL,
        recipient_type INTEGER NOT NULL,
        is_member INTEGER NOT NULL DEFAULT 1,
        name TEXT NOT NULL,
        handle TEXT NOT NULL,
        avatar_url TEXT,
        is_username_visible INTEGER NOT NULL DEFAULT 0,
        last_message TEXT,
        unread_count INTEGER NOT NULL DEFAULT 0,
        is_online INTEGER NOT NULL DEFAULT 0,
        is_presence_visible INTEGER NOT NULL DEFAULT 0,
        composer_role TEXT NOT NULL DEFAULT 'member',
        can_send_messages INTEGER NOT NULL DEFAULT 1,
        members_can_send_messages INTEGER NOT NULL DEFAULT 1,
        members_can_send_media INTEGER NOT NULL DEFAULT 1,
        members_can_send_stickers_gifs INTEGER NOT NULL DEFAULT 1,
        members_can_embed_links INTEGER NOT NULL DEFAULT 1,
        members_can_add_members INTEGER NOT NULL DEFAULT 1,
        members_can_change_info INTEGER NOT NULL DEFAULT 0,
        members_can_react INTEGER NOT NULL DEFAULT 1,
        members_can_forward INTEGER NOT NULL DEFAULT 1,
        slow_mode_seconds INTEGER NOT NULL DEFAULT 0,
        member_count INTEGER NOT NULL DEFAULT 0,
        is_official INTEGER NOT NULL DEFAULT 0,
        visibility TEXT NOT NULL DEFAULT 'public',
        verification_badge TEXT NOT NULL DEFAULT 'none',
        profile_version INTEGER NOT NULL DEFAULT 0,
        room_version INTEGER NOT NULL DEFAULT 0,
        country_code TEXT NOT NULL DEFAULT '',
        created_at INTEGER,
        updated_at INTEGER NOT NULL,
        PRIMARY KEY (account_id, recipient_id)
      );
    ''');
    final newRecipientColumns = databaseHandle.select(
      'PRAGMA table_info(account_recipients)',
    );
    if (!newRecipientColumns.any((column) => column['name'] == 'is_member')) {
      databaseHandle.execute(
        'ALTER TABLE account_recipients ADD COLUMN is_member INTEGER NOT NULL DEFAULT 1',
      );
    }
    if (!newRecipientColumns.any(
      (column) => column['name'] == 'member_count',
    )) {
      databaseHandle.execute(
        'ALTER TABLE account_recipients ADD COLUMN member_count INTEGER NOT NULL DEFAULT 0',
      );
    }
    if (!newRecipientColumns.any((column) => column['name'] == 'is_official')) {
      databaseHandle.execute(
        'ALTER TABLE account_recipients ADD COLUMN is_official INTEGER NOT NULL DEFAULT 0',
      );
    }
    if (!newRecipientColumns.any((column) => column['name'] == 'visibility')) {
      databaseHandle.execute(
        "ALTER TABLE account_recipients ADD COLUMN visibility TEXT NOT NULL DEFAULT 'public'",
      );
    }
    if (!newRecipientColumns.any(
      (column) => column['name'] == 'room_version',
    )) {
      databaseHandle.execute(
        'ALTER TABLE account_recipients ADD COLUMN room_version INTEGER NOT NULL DEFAULT 0',
      );
    }
    if (!newRecipientColumns.any(
      (column) => column['name'] == 'country_code',
    )) {
      databaseHandle.execute(
        "ALTER TABLE account_recipients ADD COLUMN country_code TEXT NOT NULL DEFAULT ''",
      );
    }
    if (!newRecipientColumns.any((column) => column['name'] == 'created_at')) {
      databaseHandle.execute(
        'ALTER TABLE account_recipients ADD COLUMN created_at INTEGER',
      );
    }
    databaseHandle.execute('''
      CREATE INDEX IF NOT EXISTS idx_account_recipients_order
      ON account_recipients(account_id, updated_at DESC, recipient_id ASC);
    ''');
    databaseHandle.execute('''
      CREATE INDEX IF NOT EXISTS idx_account_recipient_profile_watch
      ON account_recipients(account_id, recipient_type, updated_at DESC, recipient_id ASC);
    ''');
    databaseHandle.execute('''
      CREATE TABLE IF NOT EXISTS account_room_member_pages (
        account_id TEXT NOT NULL,
        room_id TEXT NOT NULL,
        page_offset INTEGER NOT NULL CHECK (page_offset >= 0),
        page_size INTEGER NOT NULL CHECK (page_size > 0),
        members_json TEXT NOT NULL,
        total_count INTEGER NOT NULL DEFAULT 0,
        next_offset INTEGER NOT NULL DEFAULT 0,
        has_more INTEGER NOT NULL DEFAULT 0,
        fetched_at INTEGER NOT NULL,
        last_attempt_at INTEGER NOT NULL,
        PRIMARY KEY (account_id, room_id, page_offset, page_size)
      );
    ''');
    databaseHandle.execute('''
      CREATE INDEX IF NOT EXISTS idx_account_room_member_pages
      ON account_room_member_pages(account_id, room_id, page_offset);
    ''');
    if (previousVersion < 12) {
      databaseHandle.execute('DROP TABLE IF EXISTS account_owned_bots;');
    }
    final accountRecipientColumns = databaseHandle.select(
      'PRAGMA table_info(account_recipients)',
    );
    if (!accountRecipientColumns.any(
      (column) => column['name'] == 'description',
    )) {
      databaseHandle.execute(
        "ALTER TABLE account_recipients ADD COLUMN description TEXT NOT NULL DEFAULT ''",
      );
    }
    if (!accountRecipientColumns.any(
      (column) => column['name'] == 'composer_role',
    )) {
      databaseHandle.execute(
        "ALTER TABLE account_recipients ADD COLUMN composer_role TEXT NOT NULL DEFAULT 'member'",
      );
    }
    if (!accountRecipientColumns.any(
      (column) => column['name'] == 'can_send_messages',
    )) {
      databaseHandle.execute(
        'ALTER TABLE account_recipients ADD COLUMN can_send_messages INTEGER NOT NULL DEFAULT 1',
      );
    }
    if (!accountRecipientColumns.any(
      (column) => column['name'] == 'members_can_send_messages',
    )) {
      databaseHandle.execute(
        'ALTER TABLE account_recipients ADD COLUMN members_can_send_messages INTEGER NOT NULL DEFAULT 1',
      );
      databaseHandle.execute('''
        UPDATE account_recipients
        SET members_can_send_messages = CASE recipient_type
          WHEN 3 THEN 0
          ELSE 1
        END
        WHERE recipient_type IN (2, 3)
      ''');
    }
    for (final column in <(String, int)>[
      ('members_can_send_media', 1),
      ('members_can_send_stickers_gifs', 1),
      ('members_can_embed_links', 1),
      ('members_can_add_members', 1),
      ('members_can_change_info', 0),
      ('members_can_react', 1),
      ('members_can_forward', 1),
    ]) {
      if (!accountRecipientColumns.any(
        (existing) => existing['name'] == column.$1,
      )) {
        databaseHandle.execute(
          'ALTER TABLE account_recipients ADD COLUMN ${column.$1} INTEGER NOT NULL DEFAULT ${column.$2}',
        );
      }
    }
    if (!accountRecipientColumns.any(
      (column) => column['name'] == 'profile_version',
    )) {
      databaseHandle.execute(
        'ALTER TABLE account_recipients ADD COLUMN profile_version INTEGER NOT NULL DEFAULT 0',
      );
    }
    if (!accountRecipientColumns.any(
      (column) => column['name'] == 'slow_mode_seconds',
    )) {
      databaseHandle.execute(
        'ALTER TABLE account_recipients ADD COLUMN slow_mode_seconds INTEGER NOT NULL DEFAULT 0',
      );
    }
    _clearLegacyPersistedPresence(databaseHandle);
    databaseHandle.execute('''
      CREATE TABLE IF NOT EXISTS account_chat_messages (
        account_id TEXT NOT NULL,
        message_id TEXT NOT NULL,
        chat_id TEXT NOT NULL,
        sender_recipient_id TEXT NOT NULL,
        body TEXT NOT NULL,
        message_type INTEGER NOT NULL,
        reply_to_message_id TEXT,
        created_at INTEGER NOT NULL,
        created_at_order INTEGER NOT NULL DEFAULT 0,
        edited_at INTEGER,
        delivery_status INTEGER NOT NULL,
        PRIMARY KEY (account_id, message_id)
      );
    ''');
    final accountChatMessageColumns = databaseHandle.select(
      'PRAGMA table_info(account_chat_messages)',
    );
    if (!accountChatMessageColumns.any(
      (column) => column['name'] == 'attachment_json',
    )) {
      databaseHandle.execute(
        'ALTER TABLE account_chat_messages ADD COLUMN attachment_json TEXT',
      );
    }
    if (!accountChatMessageColumns.any(
      (column) => column['name'] == 'created_at_order',
    )) {
      databaseHandle.execute(
        'ALTER TABLE account_chat_messages ADD COLUMN created_at_order INTEGER NOT NULL DEFAULT 0',
      );
    }
    databaseHandle.execute('''
      UPDATE account_chat_messages
      SET created_at_order = created_at * 1000
      WHERE created_at_order = 0;
    ''');
    databaseHandle.execute('''
      CREATE INDEX IF NOT EXISTS idx_account_chat_messages_order
      ON account_chat_messages(account_id, chat_id, created_at_order, message_id);
    ''');
    databaseHandle.execute('''
      CREATE TABLE IF NOT EXISTS account_deleted_chat_messages (
        account_id TEXT NOT NULL,
        message_id TEXT NOT NULL,
        deleted_at INTEGER NOT NULL,
        PRIMARY KEY (account_id, message_id)
      );
    ''');
    databaseHandle.execute('''
      CREATE TABLE IF NOT EXISTS account_message_translations (
        account_id TEXT NOT NULL,
        message_id TEXT NOT NULL,
        target_language TEXT NOT NULL,
        source_language TEXT NOT NULL,
        translated_text TEXT NOT NULL,
        updated_at INTEGER NOT NULL,
        PRIMARY KEY (account_id, message_id, target_language),
        FOREIGN KEY (account_id, message_id)
          REFERENCES account_chat_messages(account_id, message_id)
          ON DELETE CASCADE
      );
    ''');
    databaseHandle.execute('''
      CREATE INDEX IF NOT EXISTS idx_account_message_translations_language
      ON account_message_translations(account_id, target_language, message_id);
    ''');
    databaseHandle.execute('''
      CREATE TABLE IF NOT EXISTS account_processed_message_mutations (
        account_id TEXT NOT NULL,
        mutation_id TEXT NOT NULL,
        message_id TEXT NOT NULL,
        processed_at INTEGER NOT NULL,
        PRIMARY KEY (account_id, mutation_id)
      );
    ''');
    databaseHandle.execute('''
      CREATE TABLE IF NOT EXISTS account_message_receipt_status (
        account_id TEXT NOT NULL,
        message_id TEXT NOT NULL,
        status INTEGER NOT NULL CHECK (status IN (2, 3)),
        PRIMARY KEY (account_id, message_id)
      );
    ''');
    databaseHandle.execute('''
      CREATE INDEX IF NOT EXISTS idx_account_chat_messages_chat
      ON account_chat_messages(account_id, chat_id, created_at, message_id);
    ''');
    databaseHandle.execute('''
      CREATE TABLE IF NOT EXISTS account_message_outbox (
        account_id TEXT NOT NULL,
        message_id TEXT NOT NULL,
        sender_device_id TEXT NOT NULL,
        local_chat_id TEXT NOT NULL,
        chat_id TEXT NOT NULL,
        sender_recipient_id TEXT NOT NULL,
        target_recipient_id TEXT NOT NULL,
        target_device_id TEXT,
        is_secret INTEGER NOT NULL,
        message_type INTEGER NOT NULL,
        payload BLOB NOT NULL,
        status INTEGER NOT NULL,
        attempts INTEGER NOT NULL DEFAULT 0,
        next_attempt_at INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        expires_at INTEGER NOT NULL DEFAULT 0,
        PRIMARY KEY (account_id, message_id)
      );
    ''');
    databaseHandle.execute('''
      CREATE TABLE IF NOT EXISTS account_chat_command_outbox (
        sequence INTEGER PRIMARY KEY AUTOINCREMENT,
        account_id TEXT NOT NULL,
        command_id TEXT NOT NULL,
        related_message_id TEXT NOT NULL,
        command_type INTEGER NOT NULL,
        payload BLOB NOT NULL,
        attempts INTEGER NOT NULL DEFAULT 0,
        next_attempt_at INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        UNIQUE (account_id, command_id)
      );
    ''');
    databaseHandle.execute('''
      CREATE INDEX IF NOT EXISTS idx_account_chat_command_outbox_queue
      ON account_chat_command_outbox(account_id, sequence);
    ''');
    final outboxColumns = databaseHandle.select(
      'PRAGMA table_info(account_message_outbox)',
    );
    if (!outboxColumns.any((column) => column['name'] == 'expires_at')) {
      databaseHandle.execute(
        'ALTER TABLE account_message_outbox ADD COLUMN expires_at INTEGER NOT NULL DEFAULT 0',
      );
    }
    databaseHandle.execute('''
      UPDATE account_message_outbox
      SET expires_at = created_at + 86400000
      WHERE expires_at = 0;
    ''');
    databaseHandle.execute('''
      CREATE INDEX IF NOT EXISTS idx_account_message_outbox_queue
      ON account_message_outbox(
        account_id, sender_device_id, local_chat_id, created_at, message_id
      );
    ''');
    databaseHandle.execute('''
      CREATE TABLE IF NOT EXISTS account_secret_deliveries (
        account_id TEXT NOT NULL,
        delivery_id TEXT NOT NULL,
        message_id TEXT NOT NULL,
        chat_id TEXT NOT NULL,
        sender_recipient_id TEXT NOT NULL,
        target_recipient_id TEXT NOT NULL,
        message_type INTEGER NOT NULL,
        ciphertext BLOB NOT NULL,
        timestamp INTEGER NOT NULL,
        PRIMARY KEY (account_id, delivery_id),
        UNIQUE (account_id, message_id)
      );
    ''');
    databaseHandle.execute('''
      CREATE TABLE IF NOT EXISTS account_envelopes (
        account_id TEXT NOT NULL,
        envelope_id TEXT NOT NULL,
        sender_recipient_id TEXT NOT NULL,
        target_recipient_id TEXT NOT NULL,
        target_device_id TEXT NOT NULL,
        message_type INTEGER NOT NULL,
        ciphertext BLOB NOT NULL,
        timestamp INTEGER NOT NULL,
        delivery_status INTEGER NOT NULL,
        received_at INTEGER NOT NULL,
        PRIMARY KEY (account_id, envelope_id)
      );
    ''');
    databaseHandle.execute('''
      CREATE TABLE IF NOT EXISTS account_system_messages (
        account_id TEXT NOT NULL,
        message_id TEXT NOT NULL,
        recipient_id TEXT NOT NULL,
        event_type INTEGER NOT NULL,
        actor_user_id TEXT NOT NULL,
        target_user_id TEXT,
        group_id TEXT,
        channel_id TEXT,
        reason TEXT,
        metadata_json TEXT,
        timestamp INTEGER NOT NULL,
        PRIMARY KEY (account_id, message_id)
      );
    ''');
    databaseHandle.execute('''
      CREATE TABLE IF NOT EXISTS account_signal_protocol_records (
        account_id TEXT NOT NULL,
        record_key TEXT NOT NULL,
        encrypted_record BLOB NOT NULL,
        PRIMARY KEY (account_id, record_key)
      );
    ''');
    databaseHandle.execute('''
      CREATE UNIQUE INDEX IF NOT EXISTS idx_secret_deliveries_message
      ON secret_deliveries(message_id);
    ''');
    _removeLegacyDemoRows(databaseHandle);
    databaseHandle.execute('''
      INSERT INTO schema_info(key, value) VALUES ('version', '11')
      ON CONFLICT(key) DO UPDATE SET value = excluded.value;
    ''');
    databaseHandle.userVersion = LocalStoreSchema.version;
  }

  static void _removeLegacyDemoRows(Database database) {
    final completed = database.select(
      'SELECT value FROM app_settings WHERE key = ?',
      ['legacy_demo_rows_removed_v1'],
    );
    if (completed.isNotEmpty) return;

    database.execute('BEGIN IMMEDIATE');
    try {
      database.execute('''
        DELETE FROM recipients
        WHERE recipient_id IN ('bot-forja', 'group-design', 'channel-news', 'user-leo');
        ''');
      database.execute(
        "DELETE FROM system_messages WHERE message_id = 'system-1';",
      );
      database.execute(
        "DELETE FROM envelopes WHERE envelope_id = 'demo-envelope';",
      );
      database.execute('''
        INSERT INTO app_settings(key, value)
        VALUES ('legacy_demo_rows_removed_v1', 'true')
        ON CONFLICT(key) DO NOTHING;
        ''');
      database.execute('COMMIT');
    } catch (_) {
      database.execute('ROLLBACK');
      rethrow;
    }
  }

  static void _clearLegacyPersistedPresence(Database database) {
    const marker = 'ephemeral_presence_reset_v1';
    final completed = database.select(
      'SELECT value FROM app_settings WHERE key = ?',
      [marker],
    );
    if (completed.isNotEmpty) return;

    database.execute('BEGIN IMMEDIATE');
    try {
      final completedInsideTransaction = database.select(
        'SELECT value FROM app_settings WHERE key = ?',
        [marker],
      );
      if (completedInsideTransaction.isEmpty) {
        database.execute('''
          UPDATE account_recipients
          SET is_online = 0, is_presence_visible = 0
          WHERE is_online != 0 OR is_presence_visible != 0
        ''');
        database.execute('INSERT INTO app_settings(key, value) VALUES (?, ?)', [
          marker,
          'true',
        ]);
      }
      database.execute('COMMIT');
    } catch (_) {
      database.execute('ROLLBACK');
      rethrow;
    }
  }
}
