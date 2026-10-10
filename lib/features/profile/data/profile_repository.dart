import '../../../core/storage/local_store.dart';
import '../../../core/storage/message_records.dart';
import '../domain/profile_repository.dart';
import 'dart:async';
import 'dart:developer' as developer;

class ProfileRepository implements ProfileRepositoryPort {
  ProfileRepository(this._store, {this.readLocalProfile});

  final LocalStore _store;
  final UserProfile? Function(String userId)? readLocalProfile;
  Future<UserProfile?> Function(String userId)? recoverProfile;
  final Set<String> _repairingProfiles = {};

  @override
  UserProfile? get currentUser {
    final userId = _store.loadSession()?.userId;
    if (userId == null) return null;
    return loadUser(userId);
  }

  @override
  Stream<UserProfile?> watchCurrentUser() {
    return Stream.multi((controller) {
      final subscription = _store.watchProfileChanges().listen(
        (_) => controller.add(currentUser),
        onError: (Object error, StackTrace stackTrace) {
          developer.log(
            'Failed to observe the local profile; scheduling repair',
            name: 'tureon.profile',
            error: error,
            stackTrace: stackTrace,
          );
          controller.add(null);
          final userId = _store.loadSession()?.userId;
          if (userId != null) _scheduleRepair(userId);
        },
      );
      controller.add(currentUser);
      controller.onCancel = subscription.cancel;
    });
  }

  @override
  UserProfile? loadUser(String userId) {
    try {
      final reader = readLocalProfile;
      return reader == null
          ? _store.loadCurrentUser(userId: userId)
          : reader(userId);
    } catch (error, stackTrace) {
      developer.log(
        'Failed to read the local profile; removing the invalid cache',
        name: 'tureon.profile',
        error: error,
        stackTrace: stackTrace,
      );
      try {
        _store.clearProfile(userId);
      } catch (clearError, clearStackTrace) {
        developer.log(
          'Failed to remove the invalid local profile',
          name: 'tureon.profile',
          error: clearError,
          stackTrace: clearStackTrace,
        );
      }
      _scheduleRepair(userId);
      return null;
    }
  }

  @override
  void saveLocal(UserProfile profile, {bool markForSync = false}) {
    _store.saveCurrentUser(profile, markForSync: markForSync);
  }

  @override
  Future<UserProfile> refreshFromServer(
    String userId,
    Future<UserProfile> Function(String userId) fetch,
  ) async {
    final profile = await fetch(userId);
    if (profile.userId != userId) {
      throw StateError('The server returned a different user profile.');
    }
    if (_store.loadSession()?.userId != userId) {
      throw StateError('The active account changed while loading the profile.');
    }
    final local = loadUser(userId);
    final pendingRevision = pendingSyncRevision(userId);
    if (pendingRevision != null && local == null) {
      throw StateError(
        'A pending profile edit exists without its local profile row.',
      );
    }
    if (pendingRevision == null) {
      _store.acceptServerProfile(profile);
      return profile;
    }
    final localProfile = local!;
    final baseline = _store.loadProfileSyncBaseline(userId);
    if (baseline == null) {
      developer.log(
        'Pending profile edit has no saved baseline; preserving local changes',
        name: 'tureon.profile',
      );
    }
    final merged = _mergeProfiles(baseline ?? profile, localProfile, profile);
    if (_sameProfileData(merged, profile)) {
      _store.acceptServerProfile(profile);
      return profile;
    }
    _store.rebasePendingProfileSync(
      serverProfile: profile,
      mergedProfile: merged,
    );
    return merged;
  }

  @override
  void clearSessionAndProfile() => _store.clearSessionAndProfile();

  @override
  void clearProfiles() => _store.clearCurrentUser();

  void _scheduleRepair(String userId) {
    final recovery = recoverProfile;
    if (recovery == null || !_repairingProfiles.add(userId)) return;
    unawaited(
      recovery(userId)
          .then<void>((_) {})
          .catchError((Object error, StackTrace stackTrace) {
            developer.log(
              'Could not recover the local profile from the server',
              name: 'tureon.profile',
              error: error,
              stackTrace: stackTrace,
            );
          })
          .whenComplete(() => _repairingProfiles.remove(userId)),
    );
  }

  @override
  bool needsBootstrap(String userId) => _store.needsProfileBootstrap(userId);

  @override
  void markNeedsBootstrap(String userId) =>
      _store.markProfileNeedsBootstrap(userId);

  @override
  int? pendingSyncRevision(String userId) =>
      _store.pendingProfileSyncRevision(userId);

  @override
  void restoreSyncRevision(
    String userId,
    int rejectedRevision,
    int? previousRevision,
  ) => _store.restoreProfileSyncRevision(
    userId,
    rejectedRevision,
    previousRevision,
  );

  @override
  void completeSync(String userId, int revision, UserProfile serverProfile) =>
      _store.completeProfileSync(userId, revision, serverProfile);

  UserProfile _mergeProfiles(
    UserProfile baseline,
    UserProfile local,
    UserProfile server,
  ) {
    String merge(String base, String pending, String remote) =>
        pending == base ? remote : pending;
    String? mergeNullable(String? base, String? pending, String? remote) =>
        pending == base ? remote : pending;

    final privacy = <String, String>{};
    final privacyFields = {
      ...baseline.privacySettings.keys,
      ...local.privacySettings.keys,
      ...server.privacySettings.keys,
    };
    for (final field in privacyFields) {
      final base = baseline.privacySettings[field];
      final pending = local.privacySettings[field];
      final remote = server.privacySettings[field];
      final value = pending == base ? remote : pending;
      if (value != null) privacy[field] = value;
    }

    return UserProfile(
      userId: server.userId,
      username: merge(baseline.username, local.username, server.username),
      displayName: merge(
        baseline.displayName,
        local.displayName,
        server.displayName,
      ),
      bio: mergeNullable(baseline.bio, local.bio, server.bio),
      avatarUrl: mergeNullable(
        baseline.avatarUrl,
        local.avatarUrl,
        server.avatarUrl,
      ),
      phoneE164: merge(baseline.phoneE164, local.phoneE164, server.phoneE164),
      countryCode: merge(
        baseline.countryCode,
        local.countryCode,
        server.countryCode,
      ),
      birthday: merge(baseline.birthday, local.birthday, server.birthday),
      createdAt: server.createdAt,
      privacySettings: privacy,
      verificationBadge: server.verificationBadge,
      profileVersion: server.profileVersion,
    );
  }

  bool _sameProfileData(UserProfile first, UserProfile second) =>
      first.username == second.username &&
      first.displayName == second.displayName &&
      first.bio == second.bio &&
      first.avatarUrl == second.avatarUrl &&
      first.phoneE164 == second.phoneE164 &&
      first.countryCode == second.countryCode &&
      first.birthday == second.birthday &&
      _sameMap(first.privacySettings, second.privacySettings);

  bool _sameMap(Map<String, String> first, Map<String, String> second) {
    if (first.length != second.length) return false;
    return first.entries.every((entry) => second[entry.key] == entry.value);
  }
}
