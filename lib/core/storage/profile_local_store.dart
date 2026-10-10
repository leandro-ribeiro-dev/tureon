import 'dart:convert';

import 'package:sqlite3/sqlite3.dart';

import '../protocol/verification_badge.dart';
import 'message_records.dart';

class ProfileLocalStore {
  ProfileLocalStore({required this.database, required this.onTablesChanged});

  final Database database;
  final void Function(Set<String> tables) onTablesChanged;

  T _writeAndNotify<T>(Set<String> tables, T Function() write) {
    final result = write();
    onTablesChanged(tables);
    return result;
  }

  void saveCurrentUser(UserProfile profile, {bool markForSync = false}) =>
      _writeAndNotify(const {'current_user', 'profile_sync_state'}, () {
        database.execute('BEGIN IMMEDIATE');
        try {
          final syncRows = database.select(
            'SELECT dirty FROM profile_sync_state WHERE user_id = ?',
            [profile.userId],
          );
          final alreadyPending =
              syncRows.isNotEmpty && syncRows.first['dirty'] == 1;
          final baseProfile = alreadyPending
              ? null
              : loadCurrentUser(userId: profile.userId);
          _writeCurrentUser(profile);
          if (markForSync) {
            if (alreadyPending) {
              database.execute(
                '''
                UPDATE profile_sync_state
                SET revision = revision + 1
                WHERE user_id = ? AND dirty = 1
                ''',
                [profile.userId],
              );
            } else {
              final baseline = baseProfile ?? profile;
              database.execute(
                '''
                INSERT INTO profile_sync_state(
                  user_id, dirty, revision, base_profile_json, base_version
                ) VALUES (?, 1, 1, ?, ?)
                ON CONFLICT(user_id) DO UPDATE SET
                  dirty = 1,
                  revision = profile_sync_state.revision + 1,
                  base_profile_json = excluded.base_profile_json,
                  base_version = excluded.base_version
                ''',
                [
                  profile.userId,
                  jsonEncode(baseline.toJson()),
                  baseline.profileVersion,
                ],
              );
            }
          }
          database.execute('COMMIT');
        } catch (_) {
          database.execute('ROLLBACK');
          rethrow;
        }
      });

  void _writeCurrentUser(UserProfile profile) {
    database.execute(
      '''
      INSERT INTO current_user(
        user_id, username, display_name, bio, avatar_url,
        phone_e164, country_code, birthday, created_at, privacy_settings, verification_badge,
        profile_initialized, profile_version, updated_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 1, ?, ?)
      ON CONFLICT(user_id) DO UPDATE SET
        username = excluded.username,
        display_name = excluded.display_name,
        bio = excluded.bio,
        avatar_url = excluded.avatar_url,
        phone_e164 = excluded.phone_e164,
        country_code = excluded.country_code,
        birthday = excluded.birthday,
        created_at = COALESCE(excluded.created_at, current_user.created_at),
        privacy_settings = excluded.privacy_settings,
        verification_badge = excluded.verification_badge,
        profile_initialized = 1,
        profile_version = excluded.profile_version,
        updated_at = excluded.updated_at;
      ''',
      [
        profile.userId,
        profile.username,
        profile.displayName,
        profile.bio,
        profile.avatarUrl,
        profile.phoneE164,
        profile.countryCode,
        profile.birthday,
        profile.createdAt?.toUtc().millisecondsSinceEpoch,
        jsonEncode(profile.privacySettings),
        profile.verificationBadge.name,
        profile.profileVersion,
        DateTime.now().millisecondsSinceEpoch,
      ],
    );
  }

  UserProfile? loadCurrentUser({String? userId}) {
    final rows = userId == null
        ? database.select(
            'SELECT * FROM current_user ORDER BY updated_at DESC LIMIT 1',
          )
        : database.select('SELECT * FROM current_user WHERE user_id = ?', [
            userId,
          ]);
    if (rows.isEmpty) return null;
    final row = rows.first;
    return UserProfile(
      userId: row['user_id'] as String,
      username: row['username'] as String,
      displayName: row['display_name'] as String,
      bio: row['bio'] as String?,
      avatarUrl: row['avatar_url'] as String?,
      phoneE164: row['phone_e164'] as String? ?? '',
      countryCode: row['country_code'] as String? ?? '',
      birthday: row['birthday'] as String? ?? '',
      createdAt: row['created_at'] is int
          ? DateTime.fromMillisecondsSinceEpoch(
              row['created_at']! as int,
              isUtc: true,
            )
          : null,
      privacySettings: (jsonDecode(row['privacy_settings'] as String) as Map)
          .cast<String, String>(),
      verificationBadge: verificationBadgeFromServer(
        row['verification_badge'] as String? ?? 'none',
      ),
      profileVersion: row['profile_version'] as int? ?? 1,
    );
  }

  UserProfile? loadProfileSyncBaseline(String userId) {
    final rows = database.select(
      'SELECT base_profile_json FROM profile_sync_state WHERE user_id = ? AND dirty = 1',
      [userId],
    );
    if (rows.isEmpty || rows.first['base_profile_json'] == null) return null;
    final decoded = jsonDecode(rows.first['base_profile_json'] as String);
    if (decoded is! Map) {
      throw const FormatException('Invalid profile baseline.');
    }
    return UserProfile.fromJson(decoded.cast<String, Object?>());
  }

  void acceptServerProfile(UserProfile profile) =>
      _writeAndNotify(const {'current_user', 'profile_sync_state'}, () {
        database.execute('BEGIN IMMEDIATE');
        try {
          _writeCurrentUser(profile);
          database.execute('DELETE FROM profile_sync_state WHERE user_id = ?', [
            profile.userId,
          ]);
          database.execute('COMMIT');
        } catch (_) {
          database.execute('ROLLBACK');
          rethrow;
        }
      });

  void rebasePendingProfileSync({
    required UserProfile serverProfile,
    required UserProfile mergedProfile,
  }) => _writeAndNotify(const {'current_user', 'profile_sync_state'}, () {
    database.execute('BEGIN IMMEDIATE');
    try {
      _writeCurrentUser(mergedProfile);
      database.execute(
        '''
        UPDATE profile_sync_state
        SET base_profile_json = ?, base_version = ?
        WHERE user_id = ? AND dirty = 1
        ''',
        [
          jsonEncode(serverProfile.toJson()),
          serverProfile.profileVersion,
          serverProfile.userId,
        ],
      );
      database.execute('COMMIT');
    } catch (_) {
      database.execute('ROLLBACK');
      rethrow;
    }
  });

  bool needsProfileBootstrap(String userId) {
    final rows = database.select(
      'SELECT profile_initialized FROM current_user WHERE user_id = ?',
      [userId],
    );
    return rows.isNotEmpty && rows.first['profile_initialized'] == 0;
  }

  void markProfileNeedsBootstrap(String userId) => _writeAndNotify(
    const {'current_user'},
    () => database.execute(
      'UPDATE current_user SET profile_initialized = 0 WHERE user_id = ?',
      [userId],
    ),
  );

  int? pendingProfileSyncRevision(String userId) {
    final rows = database.select(
      'SELECT revision FROM profile_sync_state WHERE user_id = ? AND dirty = 1',
      [userId],
    );
    return rows.isEmpty ? null : rows.first['revision'] as int;
  }

  void completeProfileSync(
    String userId,
    int revision,
    UserProfile serverProfile,
  ) => _writeAndNotify(const {'current_user', 'profile_sync_state'}, () {
    database.execute('BEGIN IMMEDIATE');
    try {
      final rows = database.select(
        'SELECT revision FROM profile_sync_state WHERE user_id = ? AND dirty = 1',
        [userId],
      );
      if (rows.isNotEmpty && rows.first['revision'] == revision) {
        _writeCurrentUser(serverProfile);
        database.execute(
          '''
          UPDATE profile_sync_state
          SET dirty = 0, base_profile_json = NULL, base_version = NULL
          WHERE user_id = ? AND dirty = 1 AND revision = ?
          ''',
          [userId, revision],
        );
      } else if (rows.isNotEmpty) {
        database.execute(
          'UPDATE current_user SET profile_version = ? WHERE user_id = ?',
          [serverProfile.profileVersion, userId],
        );
        database.execute(
          '''
          UPDATE profile_sync_state
          SET base_profile_json = ?, base_version = ?
          WHERE user_id = ? AND dirty = 1
          ''',
          [
            jsonEncode(serverProfile.toJson()),
            serverProfile.profileVersion,
            userId,
          ],
        );
      }
      database.execute('COMMIT');
    } catch (_) {
      database.execute('ROLLBACK');
      rethrow;
    }
  });

  void restoreProfileSyncRevision(
    String userId,
    int rejectedRevision,
    int? previousRevision,
  ) => _writeAndNotify(const {'profile_sync_state'}, () {
    if (previousRevision == null) {
      database.execute(
        '''
        UPDATE profile_sync_state
        SET dirty = 0, base_profile_json = NULL, base_version = NULL
        WHERE user_id = ? AND dirty = 1 AND revision = ?
        ''',
        [userId, rejectedRevision],
      );
      return;
    }
    database.execute(
      '''
      UPDATE profile_sync_state
      SET dirty = 1, revision = ?
      WHERE user_id = ? AND dirty = 1 AND revision = ?
      ''',
      [previousRevision, userId, rejectedRevision],
    );
  });

  void clearCurrentUser() =>
      _writeAndNotify(const {'current_user', 'profile_sync_state'}, () {
        database.execute('BEGIN IMMEDIATE');
        try {
          database.execute('DELETE FROM current_user');
          database.execute('DELETE FROM profile_sync_state');
          database.execute('COMMIT');
        } catch (_) {
          database.execute('ROLLBACK');
          rethrow;
        }
      });

  void clearProfile(String userId) =>
      _writeAndNotify(const {'current_user', 'profile_sync_state'}, () {
        database.execute('BEGIN IMMEDIATE');
        try {
          database.execute('DELETE FROM current_user WHERE user_id = ?', [
            userId,
          ]);
          database.execute('DELETE FROM profile_sync_state WHERE user_id = ?', [
            userId,
          ]);
          database.execute('COMMIT');
        } catch (_) {
          database.execute('ROLLBACK');
          rethrow;
        }
      });

  void clearSessionAndProfile() => _writeAndNotify(
    const {'session', 'current_user', 'profile_sync_state'},
    () {
      database.execute('BEGIN IMMEDIATE');
      try {
        database.execute('DELETE FROM session WHERE id = 1');
        database.execute('DELETE FROM current_user');
        database.execute('DELETE FROM profile_sync_state');
        database.execute('COMMIT');
      } catch (_) {
        database.execute('ROLLBACK');
        rethrow;
      }
    },
  );
}
