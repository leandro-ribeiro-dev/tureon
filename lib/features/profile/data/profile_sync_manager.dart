import 'dart:async';

import '../../../core/storage/local_store.dart';
import '../../../core/storage/message_records.dart';
import 'profile_repository.dart';
import 'profile_sync_repository.dart';

class ProfileSyncManager {
  ProfileSyncManager({
    required this.store,
    required this.profileRepository,
  });

  final LocalStore store;
  final ProfileRepository profileRepository;

  ProfileSyncRepository? syncRepository;
  final Map<String, Future<UserProfile>> _profileRefreshes = {};

  Future<UserProfile> refreshProfile({
    required String userId,
    required Future<UserProfile> Function(String userId) fetchServerProfile,
  }) {
    final existing = _profileRefreshes[userId];
    if (existing != null) return existing;

    final future = profileRepository
        .refreshFromServer(userId, fetchServerProfile)
        .whenComplete(() {
          _profileRefreshes.remove(userId);
        });

    _profileRefreshes[userId] = future;
    return future;
  }

  void reset() {
    syncRepository = null;
    _profileRefreshes.clear();
  }
}
