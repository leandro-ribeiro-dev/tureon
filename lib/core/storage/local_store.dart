import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

import '../protocol/protocol_models.dart';
import '../../features/chats/domain/chat_message.dart';
import '../../features/chats/domain/message_translation.dart';
import 'chat_store.dart';
import 'cached_room_members_page.dart';
import 'local_store_schema.dart';
import 'message_records.dart';
import 'message_statement_cache.dart';
import 'profile_local_store.dart';
import 'signal_protocol_local_store.dart';

class LocalStore implements ChatStore {
  LocalStore._(this._database) {
    _profileStore = ProfileLocalStore(
      database: _database,
      onTablesChanged: _notifyTables,
    );
    _signalStore = SignalProtocolLocalStore(
      database: _database,
      accountId: () => _accountId,
      onWrite: () => _notifyTables(const {'account_signal_protocol_records'}),
    );
  }

  factory LocalStore.inMemory() {
    final store = LocalStore._(sqlite3.openInMemory());
    store._migrate();
    return store;
  }

  @visibleForTesting
  factory LocalStore.migrateForTesting(Database database) {
    final store = LocalStore._(database);
    store._migrate();
    return store;
  }

  final Database _database;
  late final _messageStatements = MessageStatementCache(_database);
  final StreamController<Set<String>> _tableChanges =
      StreamController<Set<String>>.broadcast(sync: true);
  late final ProfileLocalStore _profileStore;
  late final SignalProtocolLocalStore _signalStore;

  @visibleForTesting
  Stream<Set<String>> watchTableChanges() => _tableChanges.stream;

  T _writeAndNotify<T>(Set<String> affectedTables, T Function() write) {
    final result = write();
    _notifyTables(affectedTables);
    return result;
  }

  void _notifyTables(Set<String> affectedTables) =>
      _tableChanges.add(Set<String>.unmodifiable(affectedTables));

  @override
  Stream<List<ChatMessage>> watchChatMessages(
    String chatId, {
    int limit = 100,
  }) => limit < 1
      ? Stream.value(const [])
      : _watchAccountScope(
          affectedTables: const {'account_chat_messages'},
          load: () => _loadRecentChatMessages(chatId, limit),
        );

  List<ChatMessage> _loadRecentChatMessages(String chatId, int limit) {
    final rows = _database.select(
      '''
      SELECT * FROM account_chat_messages
      WHERE account_id = ? AND chat_id = ?
      ORDER BY created_at_order DESC, message_id DESC
      LIMIT ?
      ''',
      [_accountId, chatId, limit],
    );
    return rows
        .map(_chatMessageFromSqlRow)
        .toList(growable: false)
        .reversed
        .toList(growable: false);
  }

  Stream<List<Recipient>> watchRecipients() => _watchAccountScope(
    affectedTables: const {'account_recipients'},
    load: loadRecipients,
  );

  Stream<Recipient?> watchRecipient(String recipientId) =>
      _watchAccountScope<Recipient>(
        affectedTables: const {'account_recipients'},
        load: () {
          final recipient = loadRecipient(recipientId);
          return recipient == null ? const [] : [recipient];
        },
      ).map((recipients) => recipients.firstOrNull);

  Stream<List<CachedRoomMembersPage>> watchRoomMemberPages(String roomId) =>
      _watchAccountScope<CachedRoomMembersPage>(
        affectedTables: const {'account_room_member_pages'},
        load: () => loadRoomMemberPages(roomId),
      );

  List<CachedRoomMembersPage> loadRoomMemberPages(String roomId) {
    if (roomId.isEmpty) return const [];
    final rows = _database.select(
      '''
      SELECT * FROM account_room_member_pages
      WHERE account_id = ? AND room_id = ?
      ORDER BY page_offset ASC, page_size ASC
      ''',
      [_accountId, roomId],
    );
    return rows
        .map(_cachedRoomMembersPageFromRow)
        .whereType<CachedRoomMembersPage>()
        .toList(growable: false);
  }

  CachedRoomMembersPage? loadRoomMembersPage({
    required String roomId,
    required int offset,
    required int pageSize,
  }) {
    if (roomId.isEmpty || offset < 0 || pageSize < 1) return null;
    final rows = _database.select(
      '''
      SELECT * FROM account_room_member_pages
      WHERE account_id = ? AND room_id = ? AND page_offset = ? AND page_size = ?
      LIMIT 1
      ''',
      [_accountId, roomId, offset, pageSize],
    );
    return rows.isEmpty ? null : _cachedRoomMembersPageFromRow(rows.first);
  }

  CachedRoomMembersPage? _cachedRoomMembersPageFromRow(
    Map<String, Object?> row,
  ) {
    try {
      final decodedMembers = jsonDecode(row['members_json'] as String);
      if (decodedMembers is! List) return null;
      final members = decodedMembers
          .whereType<Map>()
          .map(
            (member) =>
                CachedRoomMember.fromJson(Map<String, Object?>.from(member)),
          )
          .toList(growable: false);
      return CachedRoomMembersPage(
        roomId: row['room_id'] as String,
        offset: row['page_offset'] as int,
        pageSize: row['page_size'] as int,
        members: members,
        totalCount: row['total_count'] as int,
        nextOffset: row['next_offset'] as int,
        hasMore: (row['has_more'] as int) == 1,
        fetchedAt: DateTime.fromMillisecondsSinceEpoch(
          row['fetched_at'] as int,
          isUtc: true,
        ),
        lastAttemptAt: DateTime.fromMillisecondsSinceEpoch(
          row['last_attempt_at'] as int,
          isUtc: true,
        ),
      );
    } on Object {
      return null;
    }
  }

  Future<void> saveRoomMembersPage(CachedRoomMembersPage page) async =>
      _writeAndNotify(const {'account_room_member_pages'}, () {
        _database.execute('BEGIN IMMEDIATE');
        try {
          _database.execute(
            '''
            DELETE FROM account_room_member_pages
            WHERE account_id = ? AND room_id = ? AND page_offset > ?
            ''',
            [_accountId, page.roomId, page.offset],
          );
          _database.execute(
            '''
            INSERT INTO account_room_member_pages(
              account_id, room_id, page_offset, page_size, members_json,
              total_count, next_offset, has_more, fetched_at, last_attempt_at
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ON CONFLICT(account_id, room_id, page_offset, page_size) DO UPDATE SET
              members_json = excluded.members_json,
              total_count = excluded.total_count,
              next_offset = excluded.next_offset,
              has_more = excluded.has_more,
              fetched_at = excluded.fetched_at,
              last_attempt_at = excluded.last_attempt_at
            ''',
            [
              _accountId,
              page.roomId,
              page.offset,
              page.pageSize,
              jsonEncode(
                page.members.map((member) => member.toJson()).toList(),
              ),
              page.totalCount,
              page.nextOffset,
              page.hasMore ? 1 : 0,
              page.fetchedAt.toUtc().millisecondsSinceEpoch,
              page.lastAttemptAt.toUtc().millisecondsSinceEpoch,
            ],
          );
          _database.execute('COMMIT');
        } catch (_) {
          _database.execute('ROLLBACK');
          rethrow;
        }
      });

  void markRoomMembersPageRefreshAttempt({
    required String roomId,
    required int offset,
    required int pageSize,
    required DateTime attemptedAt,
  }) => _writeAndNotify(const {'account_room_member_pages'}, () {
    _database.execute(
      '''
      UPDATE account_room_member_pages
      SET last_attempt_at = ?
      WHERE account_id = ? AND room_id = ? AND page_offset = ? AND page_size = ?
      ''',
      [
        attemptedAt.toUtc().millisecondsSinceEpoch,
        _accountId,
        roomId,
        offset,
        pageSize,
      ],
    );
  });

  void clearRoomMemberPages(String roomId) => _writeAndNotify(
    const {'account_room_member_pages'},
    () => _database.execute(
      'DELETE FROM account_room_member_pages WHERE account_id = ? AND room_id = ?',
      [_accountId, roomId],
    ),
  );

  Stream<List<T>> _watchAccountScope<T>({
    required Set<String> affectedTables,
    required List<T> Function() load,
  }) => Stream<List<T>>.multi((controller) {
    var isCancelled = false;

    void emitSnapshot() {
      if (isCancelled) return;
      try {
        controller.add(load());
      } catch (error, stackTrace) {
        controller.addError(error, stackTrace);
      }
    }

    emitSnapshot();
    final changesSubscription = watchTableChanges().listen((tables) {
      if (tables.contains('session') || tables.any(affectedTables.contains)) {
        emitSnapshot();
      }
    }, onError: controller.addError);
    controller.onCancel = () async {
      isCancelled = true;
      await changesSubscription.cancel();
    };
  });

  Stream<UserSession?> watchSession() =>
      Stream<UserSession?>.multi((controller) {
        final subscription = watchTableChanges()
            .where((tables) => tables.contains('session'))
            .map((_) => loadSession())
            .listen(controller.add, onError: controller.addError);
        controller.add(loadSession());
        controller.onCancel = subscription.cancel;
      });

  Stream<void> watchProfileChanges() => watchTableChanges()
      .where(
        (tables) =>
            tables.contains('current_user') || tables.contains('session'),
      )
      .map((_) {});

  Stream<void> watchConversationChanges() => watchTableChanges()
      .where(
        (tables) =>
            tables.contains('account_recipients') || tables.contains('session'),
      )
      .map((_) {});

  static Future<LocalStore> open() async {
    final directory = await getApplicationSupportDirectory();
    await directory.create(recursive: true);
    final database = sqlite3.open(path.join(directory.path, 'tureon.db'));
    final store = LocalStore._(database);
    store._migrate();
    return store;
  }

  void _migrate() => LocalStoreSchema.migrate(_database);

  String get _accountId => loadSession()?.userId ?? '__anonymous__';

  void saveSession(UserSession session) =>
      _writeAndNotify(const {'session'}, () {
        _database.execute(
          '''
      INSERT INTO session(
        id, user_id, access_token, refresh_token, device_id, signal_device_id,
        account_status, needs_username, updated_at
      )
      VALUES (1, ?, ?, ?, ?, ?, ?, ?, ?)
      ON CONFLICT(id) DO UPDATE SET
        user_id = excluded.user_id,
        access_token = excluded.access_token,
        refresh_token = excluded.refresh_token,
        device_id = excluded.device_id,
        signal_device_id = excluded.signal_device_id,
        account_status = excluded.account_status,
        needs_username = excluded.needs_username,
        updated_at = excluded.updated_at;
    ''',
          [
            session.userId,
            '',
            '',
            session.deviceId,
            session.signalDeviceId,
            session.accountStatus,
            session.needsUsername ? 1 : 0,
            DateTime.now().millisecondsSinceEpoch,
          ],
        );
        _database.execute(
          'UPDATE session SET access_token = ?, refresh_token = ? WHERE id = 1',
          ['', ''],
        );
      });

  @override
  UserSession? loadSession() {
    final rows = _database.select('SELECT * FROM session WHERE id = 1');
    if (rows.isEmpty) return null;
    final row = rows.first;
    return UserSession(
      userId: row['user_id'] as String,
      deviceId: row['device_id'] as String,
      signalDeviceId: row['signal_device_id'] as int,
      accountStatus: row['account_status'] as String,
      needsUsername: (row['needs_username'] as int? ?? 0) == 1,
    );
  }

  void saveCurrentUser(UserProfile profile, {bool markForSync = false}) =>
      _profileStore.saveCurrentUser(profile, markForSync: markForSync);

  UserProfile? loadCurrentUser({String? userId}) =>
      _profileStore.loadCurrentUser(userId: userId);

  UserProfile? loadProfileSyncBaseline(String userId) =>
      _profileStore.loadProfileSyncBaseline(userId);

  void acceptServerProfile(UserProfile profile) =>
      _profileStore.acceptServerProfile(profile);

  void rebasePendingProfileSync({
    required UserProfile serverProfile,
    required UserProfile mergedProfile,
  }) => _profileStore.rebasePendingProfileSync(
    serverProfile: serverProfile,
    mergedProfile: mergedProfile,
  );

  bool needsProfileBootstrap(String userId) =>
      _profileStore.needsProfileBootstrap(userId);

  void markProfileNeedsBootstrap(String userId) =>
      _profileStore.markProfileNeedsBootstrap(userId);

  int? pendingProfileSyncRevision(String userId) =>
      _profileStore.pendingProfileSyncRevision(userId);

  void completeProfileSync(
    String userId,
    int revision,
    UserProfile serverProfile,
  ) => _profileStore.completeProfileSync(userId, revision, serverProfile);

  void restoreProfileSyncRevision(
    String userId,
    int rejectedRevision,
    int? previousRevision,
  ) => _profileStore.restoreProfileSyncRevision(
    userId,
    rejectedRevision,
    previousRevision,
  );

  String? loadSetting(String key) {
    final rows = _database.select(
      'SELECT value FROM app_settings WHERE key = ?',
      [key],
    );
    return rows.isEmpty ? null : rows.first['value'] as String;
  }

  void saveSetting(String key, String value) => _writeAndNotify(
    const {'app_settings'},
    () => _database.execute(
      '''
      INSERT INTO app_settings(key, value) VALUES (?, ?)
      ON CONFLICT(key) DO UPDATE SET value = excluded.value;
      ''',
      [key, value],
    ),
  );

  void clearSession() => _writeAndNotify(const {
    'session',
  }, () => _database.execute('DELETE FROM session WHERE id = 1'));

  void clearCurrentUser() => _profileStore.clearCurrentUser();

  void clearSessionAndProfile() => _profileStore.clearSessionAndProfile();

  void clearProfile(String userId) => _profileStore.clearProfile(userId);

  void clearLocalHistory() => _writeAndNotify(
    const {
      'chat_messages',
      'secret_deliveries',
      'envelopes',
      'system_messages',
      'recipients',
      'signal_protocol_records',
      'account_chat_messages',
      'account_message_outbox',
      'account_secret_deliveries',
      'account_envelopes',
      'account_system_messages',
      'account_recipients',
      'account_room_member_pages',
      'account_signal_protocol_records',
    },
    () {
      _database.execute('BEGIN IMMEDIATE');
      try {
        _database.execute('DELETE FROM chat_messages');
        _database.execute('DELETE FROM secret_deliveries');
        _database.execute('DELETE FROM envelopes');
        _database.execute('DELETE FROM system_messages');
        _database.execute('DELETE FROM recipients');
        _database.execute('DELETE FROM signal_protocol_records');
        _database.execute('DELETE FROM account_chat_messages');
        _database.execute('DELETE FROM account_message_outbox');
        _database.execute('DELETE FROM account_secret_deliveries');
        _database.execute('DELETE FROM account_envelopes');
        _database.execute('DELETE FROM account_system_messages');
        _database.execute('DELETE FROM account_recipients');
        _database.execute('DELETE FROM account_room_member_pages');
        _database.execute('DELETE FROM account_signal_protocol_records');
        _database.execute('COMMIT');
      } catch (_) {
        _database.execute('ROLLBACK');
        rethrow;
      }
    },
  );

  @override
  Future<void> saveRecipient(Recipient recipient) async => _writeAndNotify(
    const {'account_recipients'},
    () => _database.execute(
      '''
      INSERT INTO account_recipients(
        account_id, recipient_id, recipient_type, is_member, name, handle, avatar_url, description,
        is_username_visible, last_message, unread_count, is_online,
        is_presence_visible, composer_role, can_send_messages,
        members_can_send_messages, members_can_send_media,
        members_can_send_stickers_gifs, members_can_embed_links,
        members_can_add_members, members_can_change_info, members_can_react,
        members_can_forward, slow_mode_seconds, member_count, is_official, visibility,
        verification_badge, profile_version, room_version, country_code, created_at, updated_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ON CONFLICT(account_id, recipient_id) DO UPDATE SET
        recipient_type = excluded.recipient_type,
        is_member = CASE
          WHEN excluded.room_version >= account_recipients.room_version THEN excluded.is_member
          ELSE account_recipients.is_member
        END,
        name = excluded.name,
        handle = excluded.handle,
        avatar_url = excluded.avatar_url,
        description = excluded.description,
        is_username_visible = excluded.is_username_visible,
        last_message = excluded.last_message,
        unread_count = excluded.unread_count,
        is_online = excluded.is_online,
        is_presence_visible = excluded.is_presence_visible,
        composer_role = excluded.composer_role,
        can_send_messages = excluded.can_send_messages,
        members_can_send_messages = excluded.members_can_send_messages,
        members_can_send_media = excluded.members_can_send_media,
        members_can_send_stickers_gifs = excluded.members_can_send_stickers_gifs,
        members_can_embed_links = excluded.members_can_embed_links,
        members_can_add_members = excluded.members_can_add_members,
        members_can_change_info = excluded.members_can_change_info,
        members_can_react = excluded.members_can_react,
        members_can_forward = excluded.members_can_forward,
        slow_mode_seconds = excluded.slow_mode_seconds,
        member_count = CASE
          WHEN excluded.room_version >= account_recipients.room_version THEN excluded.member_count
          ELSE account_recipients.member_count
        END,
        is_official = MAX(account_recipients.is_official, excluded.is_official),
        visibility = excluded.visibility,
        verification_badge = excluded.verification_badge,
        profile_version = MAX(account_recipients.profile_version, excluded.profile_version),
        room_version = MAX(account_recipients.room_version, excluded.room_version),
        country_code = excluded.country_code,
        created_at = COALESCE(excluded.created_at, account_recipients.created_at),
        updated_at = CASE
          WHEN excluded.last_message IS NOT NULL AND (account_recipients.last_message IS NULL OR excluded.last_message != account_recipients.last_message)
          THEN excluded.updated_at
          ELSE account_recipients.updated_at
        END;
      ''',
      [
        _accountId,
        recipient.id,
        recipient.type.index,
        recipient.isMember ? 1 : 0,
        recipient.name,
        recipient.handle,
        recipient.avatarUrl,
        recipient.description,
        recipient.isUsernameVisible ? 1 : 0,
        recipient.lastMessage,
        recipient.unreadCount,
        0,
        0,
        recipient.composerRole,
        recipient.canSendMessages ? 1 : 0,
        recipient.membersCanSendMessages ? 1 : 0,
        recipient.membersCanSendMedia ? 1 : 0,
        recipient.membersCanSendStickersGifs ? 1 : 0,
        recipient.membersCanEmbedLinks ? 1 : 0,
        recipient.membersCanAddMembers ? 1 : 0,
        recipient.membersCanChangeInfo ? 1 : 0,
        recipient.membersCanReact ? 1 : 0,
        recipient.membersCanForward ? 1 : 0,
        recipient.slowModeSeconds,
        recipient.memberCount,
        recipient.isOfficial ? 1 : 0,
        recipient.visibility,
        recipient.verificationBadge.name,
        recipient.profileVersion,
        recipient.roomVersion,
        recipient.countryCode,
        recipient.createdAt?.toUtc().millisecondsSinceEpoch,
        DateTime.now().millisecondsSinceEpoch,
      ],
    ),
  );

  @override
  Recipient? loadRecipient(String recipientId) {
    final rows = _messageStatements.select(
      'SELECT * FROM account_recipients WHERE account_id = ? AND recipient_id = ?',
      [_accountId, recipientId],
    );
    if (rows.isEmpty) return null;
    final row = rows.first;
    return Recipient(
      id: row['recipient_id'] as String,
      type: _enumAt(RecipientType.values, row['recipient_type'] as int),
      name: row['name'] as String,
      handle: row['handle'] as String,
      avatarUrl: row['avatar_url'] as String?,
      description: row['description'] as String? ?? '',
      lastMessage: row['last_message'] as String?,
      unreadCount: row['unread_count'] as int,
      isOnline: (row['is_online'] as int) == 1,
      isUsernameVisible: (row['is_username_visible'] as int) == 1,
      isPresenceVisible: (row['is_presence_visible'] as int) == 1,
      isMember: (row['is_member'] as int? ?? 1) == 1,
      composerRole: row['composer_role'] as String? ?? 'member',
      canSendMessages: (row['can_send_messages'] as int? ?? 1) == 1,
      membersCanSendMessages:
          (row['members_can_send_messages'] as int? ?? 1) == 1,
      membersCanSendMedia: (row['members_can_send_media'] as int? ?? 1) == 1,
      membersCanSendStickersGifs:
          (row['members_can_send_stickers_gifs'] as int? ?? 1) == 1,
      membersCanEmbedLinks: (row['members_can_embed_links'] as int? ?? 1) == 1,
      membersCanAddMembers: (row['members_can_add_members'] as int? ?? 1) == 1,
      membersCanChangeInfo: (row['members_can_change_info'] as int? ?? 0) == 1,
      membersCanReact: (row['members_can_react'] as int? ?? 1) == 1,
      membersCanForward: (row['members_can_forward'] as int? ?? 1) == 1,
      slowModeSeconds: row['slow_mode_seconds'] as int? ?? 0,
      memberCount: row['member_count'] as int? ?? 0,
      isOfficial: (row['is_official'] as int? ?? 0) == 1,
      visibility: row['visibility'] as String? ?? 'public',
      verificationBadge: verificationBadgeFromServer(
        row['verification_badge'] as String? ?? 'none',
      ),
      profileVersion: row['profile_version'] as int? ?? 0,
      roomVersion: row['room_version'] as int? ?? 0,
      countryCode: row['country_code'] as String? ?? '',
      createdAt: row['created_at'] is int
          ? DateTime.fromMillisecondsSinceEpoch(
              row['created_at']! as int,
              isUtc: true,
            )
          : null,
    );
  }

  @override
  bool saveIncomingMessage(
    ChatMessage message,
    Recipient recipient, {
    bool incrementUnread = true,
  }) => _writeAndNotify(
    const {'account_chat_messages', 'account_recipients'},
    () {
      _database.execute('BEGIN IMMEDIATE');
      try {
        final inserted = _saveIncomingMessageInTransaction(
          message,
          recipient,
          incrementUnread: incrementUnread,
        );
        _database.execute('COMMIT');
        return inserted;
      } catch (_) {
        _database.execute('ROLLBACK');
        rethrow;
      }
    },
  );

  @override
  Future<List<bool>> saveIncomingMessages(
    List<IncomingMessageWrite> messages,
  ) async {
    if (messages.isEmpty) return const <bool>[];
    return _writeAndNotify(
      const {'account_chat_messages', 'account_recipients'},
      () {
        _database.execute('BEGIN IMMEDIATE');
        try {
          final inserted = <bool>[];
          final recipientWrites =
              <String, ({IncomingMessageWrite write, int unreadIncrement})>{};
          for (final entry in messages) {
            final wasInserted = _saveIncomingMessageInTransaction(
              entry.message,
              entry.recipient,
              incrementUnread: false,
              updateRecipient: false,
            );
            inserted.add(wasInserted);
            final current = recipientWrites[entry.message.chatId];
            final isRoom =
                entry.recipient.type == RecipientType.group ||
                entry.recipient.type == RecipientType.channel;
            final currentIsRoom =
                current != null &&
                (current.write.recipient.type == RecipientType.group ||
                    current.write.recipient.type == RecipientType.channel);
            final isNewerSnapshot =
                current == null ||
                (isRoom &&
                    (!currentIsRoom ||
                        entry.recipient.roomVersion >=
                            current.write.recipient.roomVersion)) ||
                (!isRoom &&
                    !currentIsRoom &&
                    !entry.message.createdAt.isBefore(
                      current.write.message.createdAt,
                    ));
            recipientWrites[entry.message.chatId] = (
              write: isNewerSnapshot ? entry : current.write,
              unreadIncrement:
                  (current?.unreadIncrement ?? 0) +
                  (wasInserted && entry.incrementUnread ? 1 : 0),
            );
          }
          for (final update in recipientWrites.values) {
            _saveIncomingRecipientInTransaction(
              update.write.message,
              update.write.recipient,
              unreadIncrement: update.unreadIncrement,
            );
          }
          _database.execute('COMMIT');
          return inserted;
        } catch (_) {
          _database.execute('ROLLBACK');
          rethrow;
        }
      },
    );
  }

  bool _saveIncomingMessageInTransaction(
    ChatMessage message,
    Recipient recipient, {
    required bool incrementUnread,
    bool updateRecipient = true,
  }) {
    final deleted = _messageStatements.select(
      '''
        SELECT 1 FROM account_deleted_chat_messages
        WHERE account_id = ? AND message_id = ? LIMIT 1
        ''',
      [_accountId, message.messageId],
    );
    if (deleted.isNotEmpty) return false;
    _messageStatements.execute(
      '''
        INSERT OR IGNORE INTO account_chat_messages(
          account_id, message_id, chat_id, sender_recipient_id, body, message_type,
          reply_to_message_id, attachment_json, created_at, created_at_order, edited_at,
          delivery_status
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
        ''',
      [
        _accountId,
        message.messageId,
        message.chatId,
        message.senderRecipientId,
        message.body,
        message.type.index,
        message.replyToMessageId,
        message.attachment == null
            ? null
            : jsonEncode(message.attachment!.toJson()),
        message.createdAt.millisecondsSinceEpoch,
        message.createdAt.microsecondsSinceEpoch,
        message.editedAt?.millisecondsSinceEpoch,
        message.status.index,
      ],
    );
    final inserted = _database.updatedRows == 1;
    _applyQueuedReceiptStatus(message.messageId);
    if (updateRecipient) {
      final unreadIncrement = inserted && incrementUnread ? 1 : 0;
      _saveIncomingRecipientInTransaction(
        message,
        recipient,
        unreadIncrement: unreadIncrement,
      );
    }
    return inserted;
  }

  void _saveIncomingRecipientInTransaction(
    ChatMessage message,
    Recipient recipient, {
    required int unreadIncrement,
  }) {
    final latestMessageRows = _messageStatements.select(
      '''
        SELECT message_id, body, created_at_order, created_at
        FROM account_chat_messages
        WHERE account_id = ? AND chat_id = ?
        ORDER BY created_at_order DESC, message_id DESC
        LIMIT 1
        ''',
      [_accountId, message.chatId],
    );
    final isLatestMessage =
        latestMessageRows.isEmpty ||
        message.createdAt.microsecondsSinceEpoch >
            (latestMessageRows.first['created_at_order'] as int) ||
        (message.createdAt.microsecondsSinceEpoch ==
                (latestMessageRows.first['created_at_order'] as int) &&
            message.messageId.compareTo(
                  latestMessageRows.first['message_id'] as String,
                ) >=
                0);
    final latestMessage = latestMessageRows.isEmpty
        ? null
        : latestMessageRows.first;
    final activityMessageBody =
        latestMessage?['body'] as String? ?? message.body;
    final activityTimestamp =
        latestMessage?['created_at'] as int? ??
        message.createdAt.millisecondsSinceEpoch;
    _messageStatements.execute(
      '''
        INSERT INTO account_recipients(
          account_id, recipient_id, recipient_type, is_member, name, handle, avatar_url, description,
          is_username_visible, last_message, unread_count, is_online,
          verification_badge, composer_role, can_send_messages,
          members_can_send_messages, member_count, is_official, visibility,
          members_can_send_media, members_can_send_stickers_gifs,
          members_can_embed_links, members_can_add_members,
          members_can_change_info, members_can_react, members_can_forward,
          slow_mode_seconds, profile_version, room_version, country_code, created_at, updated_at
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ON CONFLICT(account_id, recipient_id) DO UPDATE SET
          recipient_type = excluded.recipient_type,
          is_member = CASE WHEN excluded.room_version >= account_recipients.room_version
            THEN excluded.is_member ELSE account_recipients.is_member END,
          name = CASE WHEN excluded.room_version >= account_recipients.room_version
            THEN excluded.name ELSE account_recipients.name END,
          handle = CASE WHEN excluded.room_version >= account_recipients.room_version
            THEN excluded.handle ELSE account_recipients.handle END,
          avatar_url = CASE WHEN excluded.room_version >= account_recipients.room_version
            THEN COALESCE(excluded.avatar_url, account_recipients.avatar_url)
            ELSE account_recipients.avatar_url END,
          description = CASE WHEN excluded.room_version >= account_recipients.room_version
            THEN excluded.description ELSE account_recipients.description END,
          is_username_visible = CASE WHEN excluded.room_version >= account_recipients.room_version
            THEN excluded.is_username_visible ELSE account_recipients.is_username_visible END,
          composer_role = CASE WHEN excluded.room_version >= account_recipients.room_version
            THEN excluded.composer_role ELSE account_recipients.composer_role END,
          can_send_messages = CASE WHEN excluded.room_version >= account_recipients.room_version
            THEN excluded.can_send_messages ELSE account_recipients.can_send_messages END,
          members_can_send_messages = CASE WHEN excluded.room_version >= account_recipients.room_version
            THEN excluded.members_can_send_messages ELSE account_recipients.members_can_send_messages END,
          members_can_send_media = CASE WHEN excluded.room_version >= account_recipients.room_version
            THEN excluded.members_can_send_media ELSE account_recipients.members_can_send_media END,
          members_can_send_stickers_gifs = CASE WHEN excluded.room_version >= account_recipients.room_version
            THEN excluded.members_can_send_stickers_gifs ELSE account_recipients.members_can_send_stickers_gifs END,
          members_can_embed_links = CASE WHEN excluded.room_version >= account_recipients.room_version
            THEN excluded.members_can_embed_links ELSE account_recipients.members_can_embed_links END,
          members_can_add_members = CASE WHEN excluded.room_version >= account_recipients.room_version
            THEN excluded.members_can_add_members ELSE account_recipients.members_can_add_members END,
          members_can_change_info = CASE WHEN excluded.room_version >= account_recipients.room_version
            THEN excluded.members_can_change_info ELSE account_recipients.members_can_change_info END,
          members_can_react = CASE WHEN excluded.room_version >= account_recipients.room_version
            THEN excluded.members_can_react ELSE account_recipients.members_can_react END,
          members_can_forward = CASE WHEN excluded.room_version >= account_recipients.room_version
            THEN excluded.members_can_forward ELSE account_recipients.members_can_forward END,
          slow_mode_seconds = CASE WHEN excluded.room_version >= account_recipients.room_version
            THEN excluded.slow_mode_seconds ELSE account_recipients.slow_mode_seconds END,
          member_count = CASE
            WHEN excluded.room_version >= account_recipients.room_version THEN excluded.member_count
            ELSE account_recipients.member_count
          END,
          visibility = CASE WHEN excluded.room_version >= account_recipients.room_version
            THEN excluded.visibility ELSE account_recipients.visibility END,
          is_official = MAX(account_recipients.is_official, excluded.is_official),
          last_message = CASE WHEN ? THEN excluded.last_message ELSE account_recipients.last_message END,
          unread_count = account_recipients.unread_count + ?,
          verification_badge = excluded.verification_badge,
          profile_version = MAX(account_recipients.profile_version, excluded.profile_version),
          room_version = MAX(account_recipients.room_version, excluded.room_version),
          country_code = COALESCE(NULLIF(excluded.country_code, ''), account_recipients.country_code),
          created_at = COALESCE(excluded.created_at, account_recipients.created_at),
          updated_at = CASE WHEN ? THEN excluded.updated_at ELSE account_recipients.updated_at END;
        ''',
      [
        _accountId,
        recipient.id,
        recipient.type.index,
        recipient.isMember ? 1 : 0,
        recipient.name,
        recipient.handle,
        recipient.avatarUrl,
        recipient.description,
        recipient.isUsernameVisible ? 1 : 0,
        activityMessageBody,
        unreadIncrement,
        0,
        recipient.verificationBadge.name,
        recipient.composerRole,
        recipient.canSendMessages ? 1 : 0,
        recipient.membersCanSendMessages ? 1 : 0,
        recipient.memberCount,
        recipient.isOfficial ? 1 : 0,
        recipient.visibility,
        recipient.membersCanSendMedia ? 1 : 0,
        recipient.membersCanSendStickersGifs ? 1 : 0,
        recipient.membersCanEmbedLinks ? 1 : 0,
        recipient.membersCanAddMembers ? 1 : 0,
        recipient.membersCanChangeInfo ? 1 : 0,
        recipient.membersCanReact ? 1 : 0,
        recipient.membersCanForward ? 1 : 0,
        recipient.slowModeSeconds,
        recipient.profileVersion,
        recipient.roomVersion,
        recipient.countryCode,
        recipient.createdAt?.toUtc().millisecondsSinceEpoch,
        activityTimestamp,
        isLatestMessage ? 1 : 0,
        unreadIncrement,
        isLatestMessage ? 1 : 0,
      ],
    );
  }

  @override
  void deleteRecipient(String recipientId) => _writeAndNotify(
    const {
      'account_recipients',
      'account_room_member_pages',
      'account_chat_messages',
      'account_deleted_chat_messages',
      'account_message_translations',
      'account_processed_message_mutations',
      'account_message_receipt_status',
      'account_message_outbox',
      'account_chat_command_outbox',
      'account_secret_deliveries',
      'account_system_messages',
      'app_settings',
    },
    () {
      _database.execute('BEGIN IMMEDIATE');
      try {
        // Remove dependent state first so this remains correct even when
        // foreign-key cascades are disabled by an older database connection.
        _database.execute(
          '''
          DELETE FROM account_message_translations
          WHERE account_id = ? AND message_id IN (
            SELECT message_id FROM account_chat_messages
            WHERE account_id = ? AND chat_id = ?
          )
          ''',
          [_accountId, _accountId, recipientId],
        );
        _database.execute(
          '''
          DELETE FROM account_processed_message_mutations
          WHERE account_id = ? AND message_id IN (
            SELECT message_id FROM account_chat_messages
            WHERE account_id = ? AND chat_id = ?
          )
          ''',
          [_accountId, _accountId, recipientId],
        );
        _database.execute(
          '''
          DELETE FROM account_message_receipt_status
          WHERE account_id = ? AND message_id IN (
            SELECT message_id FROM account_chat_messages
            WHERE account_id = ? AND chat_id = ?
          )
          ''',
          [_accountId, _accountId, recipientId],
        );
        _database.execute(
          '''
          DELETE FROM account_deleted_chat_messages
          WHERE account_id = ? AND message_id IN (
            SELECT message_id FROM account_chat_messages
            WHERE account_id = ? AND chat_id = ?
          )
          ''',
          [_accountId, _accountId, recipientId],
        );
        _database.execute(
          '''
          DELETE FROM account_chat_command_outbox
          WHERE account_id = ? AND related_message_id IN (
            SELECT message_id FROM account_chat_messages
            WHERE account_id = ? AND chat_id = ?
          )
          ''',
          [_accountId, _accountId, recipientId],
        );
        _database.execute(
          'DELETE FROM account_message_outbox WHERE account_id = ? AND (chat_id = ? OR local_chat_id = ?)',
          [_accountId, recipientId, recipientId],
        );
        _database.execute(
          'DELETE FROM account_secret_deliveries WHERE account_id = ? AND chat_id = ?',
          [_accountId, recipientId],
        );
        _database.execute(
          'DELETE FROM account_system_messages WHERE account_id = ? AND (recipient_id = ? OR group_id = ? OR channel_id = ?)',
          [_accountId, recipientId, recipientId, recipientId],
        );
        _database.execute(
          'DELETE FROM account_chat_messages WHERE account_id = ? AND chat_id = ?',
          [_accountId, recipientId],
        );
        _database.execute(
          'DELETE FROM account_room_member_pages WHERE account_id = ? AND room_id = ?',
          [_accountId, recipientId],
        );
        _database.execute(
          'DELETE FROM account_recipients WHERE account_id = ? AND recipient_id = ?',
          [_accountId, recipientId],
        );

        for (final key in const [
          'pinned_conversations',
          'archived_conversations',
        ]) {
          final settingKey = '$key:$_accountId';
          final rows = _database.select(
            'SELECT value FROM app_settings WHERE key = ?',
            [settingKey],
          );
          if (rows.isEmpty) continue;
          final ids = (rows.first['value'] as String)
              .split(',')
              .where((id) => id.isNotEmpty && id != recipientId)
              .toSet();
          _database.execute('UPDATE app_settings SET value = ? WHERE key = ?', [
            ids.join(','),
            settingKey,
          ]);
        }
        _database.execute('COMMIT');
      } catch (_) {
        _database.execute('ROLLBACK');
        rethrow;
      }
    },
  );

  List<Recipient> loadRecipients() {
    final rows = _database.select(
      'SELECT * FROM account_recipients WHERE account_id = ? ORDER BY updated_at DESC, recipient_id ASC',
      [_accountId],
    );
    return rows
        .map(
          (row) => Recipient(
            id: row['recipient_id'] as String,
            type: _enumAt(RecipientType.values, row['recipient_type'] as int),
            name: row['name'] as String,
            handle: row['handle'] as String,
            avatarUrl: row['avatar_url'] as String?,
            description: row['description'] as String? ?? '',
            lastMessage: row['last_message'] as String?,
            unreadCount: row['unread_count'] as int,
            isOnline: (row['is_online'] as int) == 1,
            isUsernameVisible: (row['is_username_visible'] as int) == 1,
            isPresenceVisible: (row['is_presence_visible'] as int) == 1,
            isMember: (row['is_member'] as int? ?? 1) == 1,
            composerRole: row['composer_role'] as String? ?? 'member',
            canSendMessages: (row['can_send_messages'] as int? ?? 1) == 1,
            membersCanSendMessages:
                (row['members_can_send_messages'] as int? ?? 1) == 1,
            membersCanSendMedia:
                (row['members_can_send_media'] as int? ?? 1) == 1,
            membersCanSendStickersGifs:
                (row['members_can_send_stickers_gifs'] as int? ?? 1) == 1,
            membersCanEmbedLinks:
                (row['members_can_embed_links'] as int? ?? 1) == 1,
            membersCanAddMembers:
                (row['members_can_add_members'] as int? ?? 1) == 1,
            membersCanChangeInfo:
                (row['members_can_change_info'] as int? ?? 0) == 1,
            membersCanReact: (row['members_can_react'] as int? ?? 1) == 1,
            membersCanForward: (row['members_can_forward'] as int? ?? 1) == 1,
            slowModeSeconds: row['slow_mode_seconds'] as int? ?? 0,
            memberCount: row['member_count'] as int? ?? 0,
            isOfficial: (row['is_official'] as int? ?? 0) == 1,
            visibility: row['visibility'] as String? ?? 'public',
            verificationBadge: verificationBadgeFromServer(
              row['verification_badge'] as String? ?? 'none',
            ),
            profileVersion: row['profile_version'] as int? ?? 0,
            roomVersion: row['room_version'] as int? ?? 0,
            countryCode: row['country_code'] as String? ?? '',
            createdAt: row['created_at'] is int
                ? DateTime.fromMillisecondsSinceEpoch(
                    row['created_at']! as int,
                    isUtc: true,
                  )
                : null,
          ),
        )
        .toList(growable: false);
  }

  List<Recipient> loadRecentUserRecipients({int limit = 64}) {
    final boundedLimit = limit.clamp(1, 64);
    final rows = _database.select(
      '''
      SELECT * FROM account_recipients
      WHERE account_id = ? AND recipient_type = ?
      ORDER BY updated_at DESC, recipient_id ASC
      LIMIT ?
      ''',
      [_accountId, RecipientType.user.index, boundedLimit],
    );
    return rows
        .map(
          (row) => Recipient(
            id: row['recipient_id'] as String,
            type: RecipientType.user,
            name: row['name'] as String,
            handle: row['handle'] as String,
            avatarUrl: row['avatar_url'] as String?,
            description: row['description'] as String? ?? '',
            lastMessage: row['last_message'] as String?,
            unreadCount: row['unread_count'] as int,
            isOnline: (row['is_online'] as int) == 1,
            isUsernameVisible: (row['is_username_visible'] as int) == 1,
            isPresenceVisible: (row['is_presence_visible'] as int) == 1,
            composerRole: row['composer_role'] as String? ?? 'member',
            canSendMessages: (row['can_send_messages'] as int? ?? 1) == 1,
            membersCanSendMessages:
                (row['members_can_send_messages'] as int? ?? 1) == 1,
            membersCanSendMedia:
                (row['members_can_send_media'] as int? ?? 1) == 1,
            membersCanSendStickersGifs:
                (row['members_can_send_stickers_gifs'] as int? ?? 1) == 1,
            membersCanEmbedLinks:
                (row['members_can_embed_links'] as int? ?? 1) == 1,
            membersCanAddMembers:
                (row['members_can_add_members'] as int? ?? 1) == 1,
            membersCanChangeInfo:
                (row['members_can_change_info'] as int? ?? 0) == 1,
            membersCanReact: (row['members_can_react'] as int? ?? 1) == 1,
            membersCanForward: (row['members_can_forward'] as int? ?? 1) == 1,
            slowModeSeconds: row['slow_mode_seconds'] as int? ?? 0,
            memberCount: row['member_count'] as int? ?? 0,
            isOfficial: (row['is_official'] as int? ?? 0) == 1,
            visibility: row['visibility'] as String? ?? 'public',
            verificationBadge: verificationBadgeFromServer(
              row['verification_badge'] as String? ?? 'none',
            ),
            profileVersion: row['profile_version'] as int? ?? 0,
            roomVersion: row['room_version'] as int? ?? 0,
            countryCode: row['country_code'] as String? ?? '',
            createdAt: row['created_at'] is int
                ? DateTime.fromMillisecondsSinceEpoch(
                    row['created_at']! as int,
                    isUtc: true,
                  )
                : null,
          ),
        )
        .toList(growable: false);
  }

  void saveEnvelope(EnvelopeRecord record) =>
      _writeAndNotify(const {'account_envelopes'}, () {
        final statement = _database.prepare('''
      INSERT INTO account_envelopes(
        account_id, envelope_id, sender_recipient_id, target_recipient_id,
        target_device_id, message_type, ciphertext, timestamp,
        delivery_status, received_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ON CONFLICT(account_id, envelope_id) DO UPDATE SET
        delivery_status = excluded.delivery_status,
        ciphertext = excluded.ciphertext;
    ''');
        try {
          statement.execute([
            _accountId,
            record.envelopeId,
            record.senderRecipientId,
            record.targetRecipientId,
            record.targetDeviceId,
            record.type.index,
            record.ciphertext,
            record.timestamp.millisecondsSinceEpoch,
            record.status.index,
            DateTime.now().millisecondsSinceEpoch,
          ]);
        } finally {
          statement.close();
        }
      });

  @override
  void saveChatMessage(ChatMessage message) => _writeAndNotify(
    const {
      'account_chat_messages',
      'account_message_receipt_status',
      'account_message_translations',
    },
    () {
      _database.execute('BEGIN IMMEDIATE');
      try {
        final existing = _database.select(
          '''
          SELECT body FROM account_chat_messages
          WHERE account_id = ? AND message_id = ?
          ''',
          [_accountId, message.messageId],
        );
        if (existing.isNotEmpty && existing.first['body'] != message.body) {
          _database.execute(
            '''
            DELETE FROM account_message_translations
            WHERE account_id = ? AND message_id = ?
            ''',
            [_accountId, message.messageId],
          );
        }
        _database.execute(
          '''
      INSERT INTO account_chat_messages(
        account_id, message_id, chat_id, sender_recipient_id, body, message_type,
        reply_to_message_id, attachment_json, created_at, created_at_order, edited_at,
        delivery_status
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ON CONFLICT(account_id, message_id) DO UPDATE SET
        body = excluded.body,
        message_type = excluded.message_type,
        reply_to_message_id = excluded.reply_to_message_id,
        attachment_json = excluded.attachment_json,
        created_at_order = excluded.created_at_order,
        edited_at = excluded.edited_at,
        delivery_status = excluded.delivery_status;
      ''',
          [
            _accountId,
            message.messageId,
            message.chatId,
            message.senderRecipientId,
            message.body,
            message.type.index,
            message.replyToMessageId,
            message.attachment == null
                ? null
                : jsonEncode(message.attachment!.toJson()),
            message.createdAt.millisecondsSinceEpoch,
            message.createdAt.microsecondsSinceEpoch,
            message.editedAt?.millisecondsSinceEpoch,
            message.status.index,
          ],
        );
        _applyQueuedReceiptStatus(message.messageId);
        _database.execute('COMMIT');
      } catch (_) {
        _database.execute('ROLLBACK');
        rethrow;
      }
    },
  );

  @override
  void saveOutgoingMessage(ChatMessage message, OutboxRecord outbox) =>
      _writeAndNotify(
        const {
          'account_chat_messages',
          'account_message_outbox',
          'account_message_receipt_status',
        },
        () {
          if (message.messageId != outbox.messageId ||
              message.chatId != outbox.localChatId ||
              outbox.accountId != _accountId) {
            throw ArgumentError(
              'Outgoing message and outbox account must match.',
            );
          }
          _database.execute('BEGIN IMMEDIATE');
          try {
            _database.execute(
              '''
        INSERT INTO account_chat_messages(
          account_id, message_id, chat_id, sender_recipient_id, body,
          message_type, reply_to_message_id, attachment_json, created_at, created_at_order, edited_at,
          delivery_status
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
        ''',
              [
                outbox.accountId,
                message.messageId,
                message.chatId,
                message.senderRecipientId,
                message.body,
                message.type.index,
                message.replyToMessageId,
                message.attachment == null
                    ? null
                    : jsonEncode(message.attachment!.toJson()),
                message.createdAt.millisecondsSinceEpoch,
                message.createdAt.microsecondsSinceEpoch,
                message.editedAt?.millisecondsSinceEpoch,
                ChatDeliveryStatus.pending.index,
              ],
            );
            _database.execute(
              '''
        INSERT INTO account_message_outbox(
          account_id, message_id, sender_device_id, local_chat_id, chat_id,
          sender_recipient_id, target_recipient_id, target_device_id,
          is_secret, message_type, payload, status, attempts,
          next_attempt_at, created_at, expires_at
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
        ''',
              [
                outbox.accountId,
                outbox.messageId,
                outbox.senderDeviceId,
                outbox.localChatId,
                outbox.chatId,
                outbox.senderRecipientId,
                outbox.targetRecipientId,
                outbox.targetDeviceId,
                outbox.isSecret ? 1 : 0,
                outbox.messageType,
                outbox.payload,
                outbox.status.index,
                0,
                outbox.nextAttemptAt.millisecondsSinceEpoch,
                outbox.createdAt.millisecondsSinceEpoch,
                outbox.expiresAt.millisecondsSinceEpoch,
              ],
            );
            _applyQueuedReceiptStatus(message.messageId);
            _database.execute('COMMIT');
          } catch (_) {
            _database.execute('ROLLBACK');
            rethrow;
          }
        },
      );

  @override
  void enqueueMessageMutation({
    required PendingChatCommand command,
    ChatMessage? editedMessage,
    String? deletedMessageId,
  }) {
    if (command.accountId != _accountId ||
        command.type != PendingChatCommandType.messageMutation ||
        (editedMessage == null) == (deletedMessageId == null)) {
      throw ArgumentError(
        'A message mutation and its local change are required.',
      );
    }
    if (editedMessage != null &&
        (editedMessage.messageId.isEmpty ||
            editedMessage.messageId !=
                loadChatMessage(editedMessage.messageId)?.messageId)) {
      throw StateError('The edited message is missing from the local store.');
    }
    _writeAndNotify(
      const {
        'account_chat_messages',
        'account_deleted_chat_messages',
        'account_chat_command_outbox',
        'account_message_translations',
      },
      () {
        _database.execute('BEGIN IMMEDIATE');
        try {
          _insertPendingChatCommand(command);
          if (editedMessage != null) {
            final previousBody = loadChatMessage(editedMessage.messageId)!.body;
            _database.execute(
              '''
              UPDATE account_chat_messages
              SET body = ?, edited_at = ?
              WHERE account_id = ? AND message_id = ?
              ''',
              [
                editedMessage.body,
                editedMessage.editedAt?.millisecondsSinceEpoch,
                _accountId,
                editedMessage.messageId,
              ],
            );
            if ((_database
                        .select('SELECT changes() AS changed')
                        .first['changed']
                    as int) !=
                1) {
              throw StateError(
                'The edited message disappeared from local storage.',
              );
            }
            if (previousBody != editedMessage.body) {
              _database.execute(
                '''
                DELETE FROM account_message_translations
                WHERE account_id = ? AND message_id = ?
                ''',
                [_accountId, editedMessage.messageId],
              );
            }
          } else {
            final messageId = deletedMessageId!;
            _database.execute(
              '''
              INSERT INTO account_deleted_chat_messages(account_id, message_id, deleted_at)
              VALUES (?, ?, ?)
              ON CONFLICT(account_id, message_id) DO UPDATE SET
                deleted_at = MAX(account_deleted_chat_messages.deleted_at, excluded.deleted_at)
              ''',
              [_accountId, messageId, DateTime.now().millisecondsSinceEpoch],
            );
            _database.execute(
              'DELETE FROM account_chat_messages WHERE account_id = ? AND message_id = ?',
              [_accountId, messageId],
            );
          }
          _database.execute('COMMIT');
        } catch (_) {
          _database.execute('ROLLBACK');
          rethrow;
        }
      },
    );
  }

  @override
  void enqueueReadReceipts({
    required List<PendingChatCommand> commands,
    required List<String> readMessageIds,
    required String peerRecipientId,
  }) => _writeAndNotify(
    const {
      'account_chat_command_outbox',
      'account_chat_messages',
      'account_recipients',
    },
    () {
      if (commands.any(
        (command) =>
            command.accountId != _accountId ||
            command.type != PendingChatCommandType.readReceipt,
      )) {
        throw ArgumentError('Only read receipts can be queued here.');
      }
      _database.execute('BEGIN IMMEDIATE');
      try {
        for (final command in commands) {
          _insertPendingChatCommand(command);
        }
        for (final messageId in readMessageIds) {
          _database.execute(
            '''
            UPDATE account_chat_messages
            SET delivery_status = ?
            WHERE account_id = ? AND message_id = ?
            ''',
            [ChatDeliveryStatus.read.index, _accountId, messageId],
          );
        }
        _database.execute(
          '''
          UPDATE account_recipients
          SET unread_count = 0
          WHERE account_id = ? AND recipient_id = ?
          ''',
          [_accountId, peerRecipientId],
        );
        _database.execute('COMMIT');
      } catch (_) {
        _database.execute('ROLLBACK');
        rethrow;
      }
    },
  );

  void _insertPendingChatCommand(PendingChatCommand command) {
    if (command.commandId.isEmpty || command.payload.isEmpty) {
      throw ArgumentError('A queued chat command needs an id and payload.');
    }
    _database.execute(
      '''
      INSERT INTO account_chat_command_outbox(
        account_id, command_id, related_message_id, command_type, payload, attempts,
        next_attempt_at, created_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
      ON CONFLICT(account_id, command_id) DO NOTHING
      ''',
      [
        command.accountId,
        command.commandId,
        command.relatedMessageId,
        command.type.index,
        command.payload,
        command.attempts,
        command.nextAttemptAt.millisecondsSinceEpoch,
        command.createdAt.microsecondsSinceEpoch,
      ],
    );
  }

  @override
  List<PendingChatCommand> loadPendingChatCommands(
    String accountId, {
    required int limit,
  }) {
    if (limit < 1) return const [];
    return _database
        .select(
          '''
          SELECT * FROM account_chat_command_outbox
          WHERE account_id = ?
          ORDER BY sequence
          LIMIT ?
          ''',
          [accountId, limit],
        )
        .map(
          (row) => PendingChatCommand(
            accountId: row['account_id'] as String,
            commandId: row['command_id'] as String,
            relatedMessageId: row['related_message_id'] as String,
            type: _enumAt(
              PendingChatCommandType.values,
              row['command_type'] as int,
            ),
            payload: Uint8List.fromList(row['payload'] as List<int>),
            attempts: row['attempts'] as int,
            nextAttemptAt: DateTime.fromMillisecondsSinceEpoch(
              row['next_attempt_at'] as int,
              isUtc: true,
            ),
            createdAt: DateTime.fromMicrosecondsSinceEpoch(
              row['created_at'] as int,
              isUtc: true,
            ),
          ),
        )
        .toList(growable: false);
  }

  @override
  bool hasPendingOutboxForMessage(String accountId, String messageId) =>
      _database
          .select(
            '''
            SELECT 1 FROM account_message_outbox
            WHERE account_id = ? AND message_id = ?
            LIMIT 1
            ''',
            [accountId, messageId],
          )
          .isNotEmpty;

  @override
  void removePendingChatCommand(String accountId, String commandId) =>
      _writeAndNotify(
        const {'account_chat_command_outbox'},
        () => _database.execute(
          '''
          DELETE FROM account_chat_command_outbox
          WHERE account_id = ? AND command_id = ?
          ''',
          [accountId, commandId],
        ),
      );

  @override
  void retryPendingChatCommand(
    PendingChatCommand command, {
    required DateTime nextAttemptAt,
  }) => _writeAndNotify(
    const {'account_chat_command_outbox'},
    () => _database.execute(
      '''
      UPDATE account_chat_command_outbox
      SET attempts = attempts + 1, next_attempt_at = ?
      WHERE account_id = ? AND command_id = ?
      ''',
      [
        nextAttemptAt.millisecondsSinceEpoch,
        command.accountId,
        command.commandId,
      ],
    ),
  );

  @override
  List<OutboxRecord> loadOutboxQueue(String accountId, String deviceId) =>
      _database
          .select(
            '''
            SELECT * FROM account_message_outbox
            WHERE account_id = ? AND sender_device_id = ?
            ORDER BY local_chat_id, created_at, message_id
            ''',
            [accountId, deviceId],
          )
          .map(_outboxRecordFromRow)
          .toList(growable: false);

  @override
  List<OutboxRecord> loadPreparingSecretOutbox(
    String accountId,
    String deviceId, {
    required int limit,
  }) {
    if (limit < 1) return const [];
    return _database
        .select(
          '''
          SELECT * FROM account_message_outbox
          WHERE account_id = ? AND sender_device_id = ?
            AND is_secret = 1 AND status = ?
          ORDER BY created_at, message_id
          LIMIT ?
          ''',
          [accountId, deviceId, OutboxStatus.preparing.index, limit],
        )
        .map(_outboxRecordFromRow)
        .toList(growable: false);
  }

  @override
  void markOutboxEncrypted(OutboxRecord outbox, List<int> ciphertext) =>
      _writeAndNotify(
        const {'account_message_outbox', 'account_chat_messages'},
        () {
          _database.execute('BEGIN IMMEDIATE');
          try {
            _database.execute(
              '''
          UPDATE account_message_outbox
          SET payload = ?, status = ?, next_attempt_at = ?
          WHERE account_id = ? AND message_id = ? AND sender_device_id = ?
            AND is_secret = 1 AND status = ?;
          ''',
              [
                ciphertext,
                OutboxStatus.pending.index,
                DateTime.now().millisecondsSinceEpoch,
                outbox.accountId,
                outbox.messageId,
                outbox.senderDeviceId,
                OutboxStatus.preparing.index,
              ],
            );
            _database.execute(
              '''
              UPDATE account_chat_messages
              SET delivery_status = CASE
                WHEN delivery_status IN (?, ?) THEN delivery_status
                ELSE ?
              END
              WHERE account_id = ? AND message_id = ?;
              ''',
              [
                ChatDeliveryStatus.delivered.index,
                ChatDeliveryStatus.read.index,
                ChatDeliveryStatus.pending.index,
                outbox.accountId,
                outbox.messageId,
              ],
            );
            _database.execute('COMMIT');
          } catch (_) {
            _database.execute('ROLLBACK');
            rethrow;
          }
        },
      );

  @override
  void markOutboxPayloadPrepared(OutboxRecord outbox, List<int> payload) =>
      _writeAndNotify(const {'account_message_outbox'}, () {
        _database.execute(
          '''
          UPDATE account_message_outbox
          SET payload = ?
          WHERE account_id = ? AND message_id = ? AND sender_device_id = ?
            AND is_secret = 0 AND status = ?;
          ''',
          [
            payload,
            outbox.accountId,
            outbox.messageId,
            outbox.senderDeviceId,
            OutboxStatus.sending.index,
          ],
        );
      });

  @override
  void markOutboxPreparationFailed(OutboxRecord outbox) => _writeAndNotify(
    const {'account_chat_messages'},
    () => _database.execute(
      '''
      UPDATE account_chat_messages
      SET delivery_status = ?
      WHERE account_id = ? AND message_id = ?
        AND delivery_status NOT IN (?, ?);
      ''',
      [
        ChatDeliveryStatus.failed.index,
        outbox.accountId,
        outbox.messageId,
        ChatDeliveryStatus.delivered.index,
        ChatDeliveryStatus.read.index,
      ],
    ),
  );

  @override
  List<OutboxRecord> loadOutboxHeads(
    String accountId,
    String deviceId, {
    required int limit,
  }) {
    if (limit < 1) return const [];
    return _database
        .select(
          '''
          SELECT outbox.*
          FROM account_message_outbox AS outbox
          INNER JOIN (
            SELECT queued.rowid,
                   ROW_NUMBER() OVER (
                     PARTITION BY queued.local_chat_id
                     ORDER BY COALESCE(
                       message_order.created_at_order,
                       queued.created_at * 1000
                     ), queued.message_id
                   ) AS queue_position
            FROM account_message_outbox AS queued
            LEFT JOIN account_chat_messages AS message_order
              ON message_order.account_id = queued.account_id
              AND message_order.message_id = queued.message_id
            WHERE queued.account_id = ? AND queued.sender_device_id = ?
              AND queued.status != ?
          ) AS heads ON heads.rowid = outbox.rowid
          WHERE heads.queue_position = 1
          ORDER BY outbox.created_at, outbox.message_id
          LIMIT ?
          ''',
          [accountId, deviceId, OutboxStatus.failed.index, limit],
        )
        .map(_outboxRecordFromRow)
        .toList(growable: false);
  }

  OutboxRecord _outboxRecordFromRow(Map<String, Object?> row) => OutboxRecord(
    accountId: row['account_id'] as String,
    messageId: row['message_id'] as String,
    senderDeviceId: row['sender_device_id'] as String,
    localChatId: row['local_chat_id'] as String,
    chatId: row['chat_id'] as String,
    senderRecipientId: row['sender_recipient_id'] as String,
    targetRecipientId: row['target_recipient_id'] as String,
    targetDeviceId: row['target_device_id'] as String?,
    isSecret: (row['is_secret'] as int) == 1,
    messageType: row['message_type'] as int,
    payload: Uint8List.fromList(row['payload'] as List<int>),
    status: _enumAt(OutboxStatus.values, row['status'] as int),
    attempts: row['attempts'] as int,
    nextAttemptAt: DateTime.fromMillisecondsSinceEpoch(
      row['next_attempt_at'] as int,
      isUtc: true,
    ),
    createdAt: DateTime.fromMillisecondsSinceEpoch(
      row['created_at'] as int,
      isUtc: true,
    ),
    expiresAt: DateTime.fromMillisecondsSinceEpoch(
      row['expires_at'] as int,
      isUtc: true,
    ),
  );

  @override
  void reassignNormalOutbox(String accountId, String deviceId) =>
      _writeAndNotify(
        const {'account_message_outbox'},
        () => _database.execute(
          '''
      UPDATE account_message_outbox
      SET sender_device_id = ?
      WHERE account_id = ? AND is_secret = 0;
      ''',
          [deviceId, accountId],
        ),
      );

  @override
  void markOutboxSending(OutboxRecord outbox) => _writeAndNotify(
    const {'account_message_outbox', 'account_chat_messages'},
    () {
      _database.execute('BEGIN IMMEDIATE');
      try {
        _database.execute(
          '''
        UPDATE account_message_outbox
        SET status = ?
        WHERE account_id = ? AND message_id = ? AND sender_device_id = ?
          AND status = ?;
        ''',
          [
            OutboxStatus.sending.index,
            outbox.accountId,
            outbox.messageId,
            outbox.senderDeviceId,
            OutboxStatus.pending.index,
          ],
        );
        _database.execute(
          '''
        UPDATE account_chat_messages
        SET delivery_status = CASE
          WHEN delivery_status IN (?, ?) THEN delivery_status
          ELSE ?
        END
        WHERE account_id = ? AND message_id = ?;
        ''',
          [
            ChatDeliveryStatus.delivered.index,
            ChatDeliveryStatus.read.index,
            ChatDeliveryStatus.sending.index,
            outbox.accountId,
            outbox.messageId,
          ],
        );
        _database.execute('COMMIT');
      } catch (_) {
        _database.execute('ROLLBACK');
        rethrow;
      }
    },
  );

  @override
  void retryOutboxLater(
    OutboxRecord outbox, {
    required DateTime nextAttemptAt,
    required bool failed,
    bool countAttempt = true,
  }) => _writeAndNotify(
    const {'account_message_outbox', 'account_chat_messages'},
    () {
      final status = failed ? OutboxStatus.failed : OutboxStatus.pending;
      final messageStatus = failed
          ? ChatDeliveryStatus.failed
          : ChatDeliveryStatus.pending;
      _database.execute('BEGIN IMMEDIATE');
      try {
        _database.execute(
          '''
        UPDATE account_message_outbox
        SET status = ?, attempts = attempts + ?, next_attempt_at = ?
        WHERE account_id = ? AND message_id = ? AND sender_device_id = ?;
        ''',
          [
            status.index,
            countAttempt ? 1 : 0,
            nextAttemptAt.millisecondsSinceEpoch,
            outbox.accountId,
            outbox.messageId,
            outbox.senderDeviceId,
          ],
        );
        _database.execute(
          '''
        UPDATE account_chat_messages
        SET delivery_status = CASE
          WHEN delivery_status IN (?, ?) THEN delivery_status
          ELSE ?
        END
        WHERE account_id = ? AND message_id = ?;
        ''',
          [
            ChatDeliveryStatus.delivered.index,
            ChatDeliveryStatus.read.index,
            messageStatus.index,
            outbox.accountId,
            outbox.messageId,
          ],
        );
        _database.execute('COMMIT');
      } catch (_) {
        _database.execute('ROLLBACK');
        rethrow;
      }
    },
  );

  @override
  void expireOutbox(OutboxRecord outbox) => _writeAndNotify(
    const {'account_message_outbox', 'account_chat_messages'},
    () {
      _database.execute('BEGIN IMMEDIATE');
      try {
        _database.execute(
          '''
        UPDATE account_message_outbox
        SET status = ?
        WHERE account_id = ? AND message_id = ? AND sender_device_id = ?
          AND status IN (?, ?, ?);
        ''',
          [
            OutboxStatus.failed.index,
            outbox.accountId,
            outbox.messageId,
            outbox.senderDeviceId,
            OutboxStatus.pending.index,
            OutboxStatus.sending.index,
            OutboxStatus.preparing.index,
          ],
        );
        _database.execute(
          '''
        UPDATE account_chat_messages
        SET delivery_status = ?
        WHERE account_id = ? AND message_id = ?
          AND delivery_status NOT IN (?, ?);
        ''',
          [
            ChatDeliveryStatus.failed.index,
            outbox.accountId,
            outbox.messageId,
            ChatDeliveryStatus.delivered.index,
            ChatDeliveryStatus.read.index,
          ],
        );
        _database.execute('COMMIT');
      } catch (_) {
        _database.execute('ROLLBACK');
        rethrow;
      }
    },
  );

  @override
  void markOutboxSent(OutboxRecord outbox, {DateTime? serverTimestamp}) =>
      _writeAndNotify(
        const {'account_message_outbox', 'account_chat_messages'},
        () {
          _database.execute('BEGIN IMMEDIATE');
          try {
            _database.execute(
              '''
        UPDATE account_chat_messages
        SET created_at = COALESCE(?, created_at),
          created_at_order = COALESCE(?, created_at_order),
          delivery_status = CASE
          WHEN delivery_status IN (?, ?) THEN delivery_status
          ELSE ?
        END
        WHERE account_id = ? AND message_id = ?;
        ''',
              [
                serverTimestamp?.millisecondsSinceEpoch,
                serverTimestamp?.microsecondsSinceEpoch,
                ChatDeliveryStatus.delivered.index,
                ChatDeliveryStatus.read.index,
                ChatDeliveryStatus.sent.index,
                outbox.accountId,
                outbox.messageId,
              ],
            );
            _database.execute(
              '''
        DELETE FROM account_message_outbox
        WHERE account_id = ? AND message_id = ? AND sender_device_id = ?;
        ''',
              [outbox.accountId, outbox.messageId, outbox.senderDeviceId],
            );
            _database.execute('COMMIT');
          } catch (_) {
            _database.execute('ROLLBACK');
            rethrow;
          }
        },
      );

  @override
  void resetSendingOutbox(String accountId) => _writeAndNotify(
    const {'account_message_outbox', 'account_chat_messages'},
    () {
      _database.execute('BEGIN IMMEDIATE');
      try {
        _database.execute(
          '''
        UPDATE account_message_outbox
        SET status = ?, next_attempt_at = ?
        WHERE account_id = ? AND status = ?;
        ''',
          [
            OutboxStatus.pending.index,
            DateTime.now().millisecondsSinceEpoch,
            accountId,
            OutboxStatus.sending.index,
          ],
        );
        _database.execute(
          '''
        UPDATE account_chat_messages
        SET delivery_status = ?
        WHERE account_id = ? AND message_id IN (
          SELECT message_id FROM account_message_outbox
          WHERE account_id = ? AND status = ?
        );
        ''',
          [
            ChatDeliveryStatus.pending.index,
            accountId,
            accountId,
            OutboxStatus.pending.index,
          ],
        );
        _database.execute('COMMIT');
      } catch (_) {
        _database.execute('ROLLBACK');
        rethrow;
      }
    },
  );

  @override
  bool retryFailedOutbox(String accountId, String deviceId, String messageId) =>
      _writeAndNotify(
        const {'account_message_outbox', 'account_chat_messages'},
        () {
          final retriedAt = DateTime.now().toUtc();
          _database.execute('BEGIN IMMEDIATE');
          try {
            _database.execute(
              '''
        UPDATE account_message_outbox
        SET status = CASE
              WHEN status = ? THEN ?
              ELSE ?
            END,
            attempts = 0, next_attempt_at = ?, expires_at = ?
        WHERE account_id = ? AND sender_device_id = ? AND message_id = ?
          AND status IN (?, ?);
        ''',
              [
                OutboxStatus.preparing.index,
                OutboxStatus.preparing.index,
                OutboxStatus.pending.index,
                retriedAt.millisecondsSinceEpoch,
                retriedAt.add(const Duration(hours: 24)).millisecondsSinceEpoch,
                accountId,
                deviceId,
                messageId,
                OutboxStatus.failed.index,
                OutboxStatus.preparing.index,
              ],
            );
            final updated =
                (_database
                        .select('SELECT changes() AS changed')
                        .first['changed']
                    as int) ==
                1;
            if (updated) {
              _database.execute(
                '''
          UPDATE account_chat_messages
          SET delivery_status = ?
          WHERE account_id = ? AND message_id = ?;
          ''',
                [ChatDeliveryStatus.pending.index, accountId, messageId],
              );
            }
            _database.execute('COMMIT');
            return updated;
          } catch (_) {
            _database.execute('ROLLBACK');
            rethrow;
          }
        },
      );

  @override
  List<ChatMessage> loadChatMessages(String chatId) => _database
      .select(
        'SELECT * FROM account_chat_messages WHERE account_id = ? AND chat_id = ? ORDER BY created_at_order, message_id',
        [_accountId, chatId],
      )
      .map(_chatMessageFromSqlRow)
      .toList(growable: false);

  @override
  List<ChatMessage> loadEarlierChatMessages({
    required String chatId,
    required ChatMessage before,
    required int limit,
  }) {
    if (limit < 1) return const [];
    final rows = _database.select(
      '''
      SELECT * FROM account_chat_messages
      WHERE account_id = ? AND chat_id = ?
        AND (created_at_order < ? OR (created_at_order = ? AND message_id < ?))
      ORDER BY created_at_order DESC, message_id DESC
      LIMIT ?
      ''',
      [
        _accountId,
        chatId,
        before.createdAt.microsecondsSinceEpoch,
        before.createdAt.microsecondsSinceEpoch,
        before.messageId,
        limit,
      ],
    );
    return rows
        .map(_chatMessageFromSqlRow)
        .toList(growable: false)
        .reversed
        .toList(growable: false);
  }

  ChatAttachment? _decodeChatAttachment(String? encoded) {
    if (encoded == null || encoded.isEmpty) return null;
    try {
      final decoded = jsonDecode(encoded);
      if (decoded is! Map<String, Object?>) return null;
      return ChatAttachment.fromJson(decoded);
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    }
  }

  ChatMessage _chatMessageFromSqlRow(Map<String, Object?> row) => ChatMessage(
    messageId: row['message_id'] as String,
    chatId: row['chat_id'] as String,
    senderRecipientId: row['sender_recipient_id'] as String,
    body: row['body'] as String,
    type: _enumAt(ChatMessageType.values, row['message_type'] as int),
    replyToMessageId: row['reply_to_message_id'] as String?,
    attachment: _decodeChatAttachment(row['attachment_json'] as String?),
    createdAt: DateTime.fromMicrosecondsSinceEpoch(
      row['created_at_order'] as int,
      isUtc: true,
    ),
    editedAt: row['edited_at'] == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(
            row['edited_at'] as int,
            isUtc: true,
          ),
    status: _enumAt(ChatDeliveryStatus.values, row['delivery_status'] as int),
  );

  @override
  ChatMessage? loadChatMessage(String messageId) {
    final rows = _messageStatements.select(
      'SELECT * FROM account_chat_messages WHERE account_id = ? AND message_id = ?',
      [_accountId, messageId],
    );
    if (rows.isEmpty) return null;
    final row = rows.first;
    return _chatMessageFromSqlRow(row);
  }

  @override
  Map<String, MessageTranslation> loadMessageTranslations(
    List<String> messageIds, {
    required String targetLanguage,
  }) {
    final uniqueIds = messageIds.toSet().where((id) => id.isNotEmpty).toList();
    if (uniqueIds.isEmpty || targetLanguage.isEmpty) return const {};
    final placeholders = List.filled(uniqueIds.length, '?').join(', ');
    final rows = _database.select(
      '''
      SELECT translations.message_id, messages.body AS source_text,
             translations.target_language, translations.source_language,
             translations.translated_text, translations.updated_at
      FROM account_message_translations AS translations
      INNER JOIN account_chat_messages AS messages
        ON messages.account_id = translations.account_id
        AND messages.message_id = translations.message_id
      WHERE translations.account_id = ?
        AND translations.target_language = ?
        AND translations.message_id IN ($placeholders)
      ''',
      [_accountId, targetLanguage, ...uniqueIds],
    );
    return {
      for (final row in rows)
        row['message_id'] as String: MessageTranslation(
          messageId: row['message_id'] as String,
          sourceText: row['source_text'] as String,
          targetLanguage: row['target_language'] as String,
          sourceLanguage: row['source_language'] as String,
          translatedText: row['translated_text'] as String,
          updatedAt: DateTime.fromMillisecondsSinceEpoch(
            row['updated_at'] as int,
            isUtc: true,
          ),
        ),
    };
  }

  @override
  bool saveMessageTranslation(MessageTranslation translation) {
    if (translation.messageId.trim().isEmpty ||
        translation.sourceText.trim().isEmpty ||
        translation.targetLanguage.trim().isEmpty ||
        translation.sourceLanguage.trim().isEmpty ||
        translation.translatedText.trim().isEmpty) {
      throw ArgumentError('Message translation fields must not be empty.');
    }
    return _writeAndNotify(const {'account_message_translations'}, () {
      _database.execute('BEGIN IMMEDIATE');
      try {
        final message = _database.select(
          '''
          SELECT body FROM account_chat_messages
          WHERE account_id = ? AND message_id = ?
          ''',
          [_accountId, translation.messageId],
        );
        if (message.isEmpty) {
          throw StateError(
            'Cannot translate a message outside the active account.',
          );
        }
        if (message.first['body'] != translation.sourceText) {
          _database.execute('COMMIT');
          return false;
        }
        _database.execute(
          '''
          INSERT INTO account_message_translations(
            account_id, message_id, target_language, source_language,
            translated_text, updated_at
          ) VALUES (?, ?, ?, ?, ?, ?)
          ON CONFLICT(account_id, message_id, target_language) DO UPDATE SET
            source_language = excluded.source_language,
            translated_text = excluded.translated_text,
            updated_at = excluded.updated_at
          ''',
          [
            _accountId,
            translation.messageId,
            translation.targetLanguage,
            translation.sourceLanguage,
            translation.translatedText,
            translation.updatedAt.millisecondsSinceEpoch,
          ],
        );
        _database.execute('COMMIT');
        return true;
      } catch (_) {
        _database.execute('ROLLBACK');
        rethrow;
      }
    });
  }

  @override
  void saveMessageReceiptStatus(String messageId, ChatDeliveryStatus status) {
    if (messageId.isEmpty) {
      throw ArgumentError.value(messageId, 'messageId', 'Must not be empty.');
    }
    if (status != ChatDeliveryStatus.delivered &&
        status != ChatDeliveryStatus.read) {
      throw ArgumentError.value(status, 'status', 'Receipt status is invalid.');
    }
    _writeAndNotify(
      const {
        'account_message_receipt_status',
        'account_chat_messages',
        'account_message_outbox',
      },
      () {
        _database.execute('BEGIN IMMEDIATE');
        try {
          _database.execute(
            '''
        INSERT INTO account_message_receipt_status(account_id, message_id, status)
        VALUES (?, ?, ?)
        ON CONFLICT(account_id, message_id) DO UPDATE SET
          status = CASE
            WHEN account_message_receipt_status.status = ? THEN ?
            WHEN excluded.status = ? THEN ?
            ELSE ?
          END;
        ''',
            [
              _accountId,
              messageId,
              status.index,
              ChatDeliveryStatus.read.index,
              ChatDeliveryStatus.read.index,
              ChatDeliveryStatus.read.index,
              ChatDeliveryStatus.read.index,
              ChatDeliveryStatus.delivered.index,
            ],
          );
          _applyQueuedReceiptStatus(messageId);
          _database.execute('COMMIT');
        } catch (_) {
          _database.execute('ROLLBACK');
          rethrow;
        }
      },
    );
  }

  @override
  bool hasAppliedMessageMutation(String mutationId) => _database
      .select(
        '''
    SELECT 1 FROM account_processed_message_mutations
    WHERE account_id = ? AND mutation_id = ? LIMIT 1
    ''',
        [_accountId, mutationId],
      )
      .isNotEmpty;

  @override
  void applyChatMessageEdit(ChatMessage message, String mutationId) =>
      _writeAndNotify(
        const {
          'account_chat_messages',
          'account_processed_message_mutations',
          'account_message_translations',
        },
        () {
          if (message.messageId.isEmpty || mutationId.isEmpty) {
            throw ArgumentError('A message and mutation id are required.');
          }
          _database.execute('BEGIN IMMEDIATE');
          try {
            if (hasAppliedMessageMutation(mutationId)) {
              _database.execute('COMMIT');
              return;
            }
            final previousBody = _database.select(
              '''
              SELECT body FROM account_chat_messages
              WHERE account_id = ? AND message_id = ?
              ''',
              [_accountId, message.messageId],
            );
            if (previousBody.isEmpty) {
              throw StateError('The edited message is not stored locally.');
            }
            _database.execute(
              '''
        UPDATE account_chat_messages
        SET body = ?, edited_at = ?
        WHERE account_id = ? AND message_id = ?;
        ''',
              [
                message.body,
                message.editedAt?.millisecondsSinceEpoch,
                _accountId,
                message.messageId,
              ],
            );
            final updated =
                (_database
                        .select('SELECT changes() AS changed')
                        .first['changed']
                    as int) ==
                1;
            if (!updated) {
              throw StateError('The edited message is not stored locally.');
            }
            if (previousBody.first['body'] != message.body) {
              _database.execute(
                '''
                DELETE FROM account_message_translations
                WHERE account_id = ? AND message_id = ?
                ''',
                [_accountId, message.messageId],
              );
            }
            _recordMessageMutation(mutationId, message.messageId);
            _database.execute('COMMIT');
          } catch (_) {
            _database.execute('ROLLBACK');
            rethrow;
          }
        },
      );

  @override
  void applyChatMessageDeletion(
    String messageId,
    String mutationId,
  ) => _writeAndNotify(
    const {
      'account_chat_messages',
      'account_deleted_chat_messages',
      'account_processed_message_mutations',
    },
    () {
      if (messageId.isEmpty || mutationId.isEmpty) {
        throw ArgumentError('A message and mutation id are required.');
      }
      _database.execute('BEGIN IMMEDIATE');
      try {
        if (hasAppliedMessageMutation(mutationId)) {
          _database.execute('COMMIT');
          return;
        }
        _database.execute(
          '''
        INSERT INTO account_deleted_chat_messages(account_id, message_id, deleted_at)
        VALUES (?, ?, ?)
        ON CONFLICT(account_id, message_id) DO UPDATE SET
          deleted_at = MAX(account_deleted_chat_messages.deleted_at, excluded.deleted_at);
        ''',
          [_accountId, messageId, DateTime.now().millisecondsSinceEpoch],
        );
        _database.execute(
          'DELETE FROM account_chat_messages WHERE account_id = ? AND message_id = ?',
          [_accountId, messageId],
        );
        _recordMessageMutation(mutationId, messageId);
        _database.execute('COMMIT');
      } catch (_) {
        _database.execute('ROLLBACK');
        rethrow;
      }
    },
  );

  void _recordMessageMutation(String mutationId, String messageId) {
    _database.execute(
      '''
      INSERT INTO account_processed_message_mutations(
        account_id, mutation_id, message_id, processed_at
      ) VALUES (?, ?, ?, ?);
      ''',
      [
        _accountId,
        mutationId,
        messageId,
        DateTime.now().millisecondsSinceEpoch,
      ],
    );
  }

  void _applyQueuedReceiptStatus(String messageId) {
    final queued = _messageStatements.select(
      '''
      SELECT status FROM account_message_receipt_status
      WHERE account_id = ? AND message_id = ?
      ''',
      [_accountId, messageId],
    );
    if (queued.isEmpty) return;
    final receiptStatus = queued.first['status'] as int;
    _messageStatements.execute(
      '''
      UPDATE account_chat_messages
      SET delivery_status = CASE
        WHEN delivery_status = ? OR ? = ? THEN ?
        ELSE ?
      END
      WHERE account_id = ? AND message_id = ?;
      ''',
      [
        ChatDeliveryStatus.read.index,
        receiptStatus,
        ChatDeliveryStatus.read.index,
        ChatDeliveryStatus.read.index,
        ChatDeliveryStatus.delivered.index,
        _accountId,
        messageId,
      ],
    );
    final updated = _database.updatedRows == 1;
    if (updated) {
      _messageStatements.execute(
        'DELETE FROM account_message_receipt_status WHERE account_id = ? AND message_id = ?',
        [_accountId, messageId],
      );
      _messageStatements.execute(
        'DELETE FROM account_message_outbox WHERE account_id = ? AND message_id = ?',
        [_accountId, messageId],
      );
    }
  }

  @override
  bool isChatMessageDeleted(String messageId) => _database
      .select(
        '''
    SELECT 1 FROM account_deleted_chat_messages
    WHERE account_id = ? AND message_id = ? LIMIT 1
    ''',
        [_accountId, messageId],
      )
      .isNotEmpty;

  @override
  bool hasCompletedSecretDelivery(String deliveryId) => _database
      .select(
        '''
        SELECT 1
        FROM account_secret_deliveries AS delivery
        INNER JOIN account_chat_messages AS message
          ON message.account_id = delivery.account_id
         AND message.message_id = delivery.message_id
         AND message.chat_id = delivery.chat_id
        WHERE delivery.account_id = ? AND delivery.delivery_id = ?
        LIMIT 1
        ''',
        [_accountId, deliveryId],
      )
      .isNotEmpty;

  @override
  bool saveIncomingSecretMessage({
    required SecretDeliveryRecord delivery,
    required ChatMessage message,
    required Recipient recipient,
  }) {
    if (delivery.deliveryId.isEmpty ||
        delivery.messageId != message.messageId ||
        delivery.chatId != message.chatId ||
        delivery.senderRecipientId != message.senderRecipientId) {
      throw ArgumentError('Secret delivery and local message metadata differ.');
    }
    return _writeAndNotify(
      const {'account_secret_deliveries', 'account_chat_messages'},
      () {
        _database.execute('BEGIN IMMEDIATE');
        try {
          _database.execute(
            '''
          INSERT INTO account_secret_deliveries(
            account_id, delivery_id, message_id, chat_id, sender_recipient_id,
            target_recipient_id, message_type, ciphertext, timestamp
          ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
          ON CONFLICT DO NOTHING;
            ''',
            [
              _accountId,
              delivery.deliveryId,
              delivery.messageId,
              delivery.chatId,
              delivery.senderRecipientId,
              delivery.targetRecipientId,
              delivery.messageType,
              delivery.ciphertext,
              delivery.timestamp.millisecondsSinceEpoch,
            ],
          );
          final inserted = _saveIncomingMessageInTransaction(
            message,
            recipient,
            incrementUnread: false,
            updateRecipient: false,
          );
          _database.execute('COMMIT');
          return inserted;
        } catch (_) {
          _database.execute('ROLLBACK');
          rethrow;
        }
      },
    );
  }

  @override
  void deleteChatMessage(String messageId) => _writeAndNotify(
    const {'account_chat_messages', 'account_deleted_chat_messages'},
    () {
      _database.execute('BEGIN IMMEDIATE');
      try {
        _database.execute(
          '''
        INSERT INTO account_deleted_chat_messages(account_id, message_id, deleted_at)
        VALUES (?, ?, ?)
        ON CONFLICT(account_id, message_id) DO UPDATE SET
          deleted_at = MAX(account_deleted_chat_messages.deleted_at, excluded.deleted_at);
        ''',
          [_accountId, messageId, DateTime.now().millisecondsSinceEpoch],
        );
        _database.execute(
          'DELETE FROM account_chat_messages WHERE account_id = ? AND message_id = ?',
          [_accountId, messageId],
        );
        _database.execute('COMMIT');
      } catch (_) {
        _database.execute('ROLLBACK');
        rethrow;
      }
    },
  );

  @override
  void saveSecretDelivery(SecretDeliveryRecord delivery) => _writeAndNotify(
    const {'account_secret_deliveries'},
    () => _database.execute(
      '''
      INSERT INTO account_secret_deliveries(
        account_id, delivery_id, message_id, chat_id, sender_recipient_id,
        target_recipient_id, message_type, ciphertext, timestamp
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
      ON CONFLICT DO NOTHING;
      ''',
      [
        _accountId,
        delivery.deliveryId,
        delivery.messageId,
        delivery.chatId,
        delivery.senderRecipientId,
        delivery.targetRecipientId,
        delivery.messageType,
        delivery.ciphertext,
        delivery.timestamp.millisecondsSinceEpoch,
      ],
    ),
  );

  @override
  void deleteSecretDelivery(String deliveryId) => _writeAndNotify(
    const {'account_secret_deliveries'},
    () => _database.execute(
      'DELETE FROM account_secret_deliveries WHERE account_id = ? AND delivery_id = ?',
      [_accountId, deliveryId],
    ),
  );

  @override
  List<SecretDeliveryRecord> loadSecretDeliveries(String chatId) => _database
      .select(
        '''
        SELECT * FROM account_secret_deliveries
        WHERE account_id = ? AND chat_id = ?
        ORDER BY timestamp, delivery_id
        ''',
        [_accountId, chatId],
      )
      .map(
        (row) => SecretDeliveryRecord(
          deliveryId: row['delivery_id'] as String,
          messageId: row['message_id'] as String,
          chatId: row['chat_id'] as String,
          senderRecipientId: row['sender_recipient_id'] as String,
          targetRecipientId: row['target_recipient_id'] as String,
          messageType: row['message_type'] as int,
          ciphertext: Uint8List.fromList(row['ciphertext'] as List<int>),
          timestamp: DateTime.fromMillisecondsSinceEpoch(
            row['timestamp'] as int,
            isUtc: true,
          ),
        ),
      )
      .toList(growable: false);

  Uint8List? readSignalProtocolRecord(String recordKey) {
    return _signalStore.read(recordKey);
  }

  void writeSignalProtocolRecord(String recordKey, Uint8List encryptedRecord) =>
      _signalStore.write(recordKey, encryptedRecord);

  void deleteSignalProtocolRecord(String recordKey) =>
      _signalStore.delete(recordKey);

  List<String> listSignalProtocolRecordKeys(String prefix) =>
      _signalStore.listKeys(prefix);

  void saveSystemMessage(SystemMessageRecord record) =>
      _writeAndNotify(const {'account_system_messages'}, () {
        final statement = _database.prepare('''
      INSERT INTO account_system_messages(
        account_id, message_id, recipient_id, event_type, actor_user_id,
        target_user_id, group_id, channel_id, reason, metadata_json, timestamp
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ON CONFLICT(account_id, message_id) DO NOTHING;
    ''');
        try {
          statement.execute([
            _accountId,
            record.messageId,
            record.recipientId,
            record.message.eventType.index,
            record.message.actorUserId,
            record.message.targetUserId,
            record.message.groupId,
            record.message.channelId,
            record.message.reason,
            record.message.metadataJson,
            record.message.timestamp.millisecondsSinceEpoch,
          ]);
        } finally {
          statement.close();
        }
      });

  List<EnvelopeRecord> loadEnvelopes({String? recipientId, int limit = 100}) {
    final rows = recipientId == null
        ? _database.select(
            'SELECT * FROM account_envelopes WHERE account_id = ? ORDER BY timestamp DESC LIMIT ?',
            [_accountId, limit],
          )
        : _database.select(
            '''
            SELECT * FROM account_envelopes
            WHERE account_id = ? AND
              (sender_recipient_id = ? OR target_recipient_id = ?)
            ORDER BY timestamp DESC LIMIT ?
          ''',
            [_accountId, recipientId, recipientId, limit],
          );
    return rows.map(_envelopeFromRow).toList(growable: false);
  }

  List<SystemMessageRecord> loadSystemMessages({
    String? recipientId,
    int limit = 100,
  }) {
    final rows = recipientId == null
        ? _database.select(
            'SELECT * FROM account_system_messages WHERE account_id = ? ORDER BY timestamp DESC LIMIT ?',
            [_accountId, limit],
          )
        : _database.select(
            '''
            SELECT * FROM account_system_messages
            WHERE account_id = ? AND recipient_id = ? ORDER BY timestamp DESC LIMIT ?
          ''',
            [_accountId, recipientId, limit],
          );
    return rows.map(_systemFromRow).toList(growable: false);
  }

  void setStreamStarted(String streamName, DateTime timestamp) =>
      _writeAndNotify(
        const {'sync_state'},
        () => _database.execute(
          '''
      INSERT INTO sync_state(stream_name, last_started_at, last_error)
      VALUES (?, ?, NULL)
      ON CONFLICT(stream_name) DO UPDATE SET
        last_started_at = excluded.last_started_at,
        last_error = NULL;
    ''',
          [streamName, timestamp.millisecondsSinceEpoch],
        ),
      );

  void setStreamError(String streamName, Object error) => _writeAndNotify(
    const {'sync_state'},
    () => _database.execute(
      '''
      INSERT INTO sync_state(stream_name, last_error)
      VALUES (?, ?)
      ON CONFLICT(stream_name) DO UPDATE SET last_error = excluded.last_error;
    ''',
      [streamName, error.toString()],
    ),
  );

  Future<void> close() async {
    await _tableChanges.close();
    _messageStatements.close();
    _database.close();
  }

  EnvelopeRecord _envelopeFromRow(Row row) => EnvelopeRecord(
    envelopeId: row['envelope_id'] as String,
    senderRecipientId: row['sender_recipient_id'] as String,
    targetRecipientId: row['target_recipient_id'] as String,
    targetDeviceId: row['target_device_id'] as String,
    type: _enumAt(MessageType.values, row['message_type'] as int),
    ciphertext: Uint8List.fromList(row['ciphertext'] as List<int>),
    timestamp: DateTime.fromMillisecondsSinceEpoch(row['timestamp'] as int),
    status: _enumAt(DeliveryStatus.values, row['delivery_status'] as int),
  );

  SystemMessageRecord _systemFromRow(Row row) => SystemMessageRecord(
    messageId: row['message_id'] as String,
    recipientId: row['recipient_id'] as String,
    message: SystemMessage(
      eventType: _enumAt(SystemEventType.values, row['event_type'] as int),
      actorUserId: row['actor_user_id'] as String,
      targetUserId: row['target_user_id'] as String?,
      groupId: row['group_id'] as String?,
      channelId: row['channel_id'] as String?,
      reason: row['reason'] as String?,
      metadataJson: row['metadata_json'] as String?,
      timestamp: DateTime.fromMillisecondsSinceEpoch(row['timestamp'] as int),
    ),
  );

  T _enumAt<T>(List<T> values, int index) =>
      values[index >= 0 && index < values.length ? index : 0];
}
