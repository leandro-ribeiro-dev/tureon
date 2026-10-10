import '../../../core/storage/message_records.dart';

abstract interface class ProfileRepositoryPort {
  UserProfile? get currentUser;

  Stream<UserProfile?> watchCurrentUser();

  UserProfile? loadUser(String userId);

  void saveLocal(UserProfile profile, {bool markForSync = false});

  Future<UserProfile> refreshFromServer(
    String userId,
    Future<UserProfile> Function(String userId) fetch,
  );

  void clearSessionAndProfile();

  void clearProfiles();

  bool needsBootstrap(String userId);

  void markNeedsBootstrap(String userId);

  int? pendingSyncRevision(String userId);

  void restoreSyncRevision(
    String userId,
    int rejectedRevision,
    int? previousRevision,
  );

  void completeSync(String userId, int revision, UserProfile serverProfile);
}
