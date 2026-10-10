import 'package:flutter_test/flutter_test.dart';
import 'package:tureon/core/app/app_runtime.dart';
import 'package:tureon/core/protocol/recipient.dart';
import 'package:tureon/core/protocol/recipient_type.dart';
import 'package:tureon/core/storage/local_store.dart';
import 'package:tureon/core/storage/message_records.dart';
import 'package:tureon/features/chats/domain/chat_feature_services.dart';
import 'package:tureon/generated/proto/tureon.pb.dart' as pb;

void main() {
  test('username setup sessions skip profile and group bootstrap', () async {
    final store = LocalStore.inMemory();
    addTearDown(store.close);
    var profileLoads = 0;
    var groupLoads = 0;
    final runtime = AppRuntime.forTesting(
      store: store,
      loadProfile: (_) async {
        profileLoads++;
        throw StateError('profile must wait for username setup');
      },
      loadGroupChannels: (_) async {
        groupLoads++;
        return (groups: <pb.GroupChannel>[], channels: <pb.GroupChannel>[]);
      },
    );
    const session = UserSession(
      userId: 'new-user',
      accessToken: 'access',
      refreshToken: 'refresh',
      deviceId: 'device-1',
      needsUsername: true,
      accountStatus: 'active',
    );

    await runtime.saveSession(session);

    expect(runtime.currentSession?.userId, 'new-user');
    expect(profileLoads, 0);
    expect(groupLoads, 0);
    await runtime.disconnect();
  });

  test(
    'under-review accounts can edit their local profile and privacy settings',
    () async {
      final store = LocalStore.inMemory();
      addTearDown(store.close);
      final runtime = AppRuntime.forTesting(
        store: store,
        loadProfile: (_) async => const UserProfile(
          userId: 'user-1',
          username: 'alice',
          displayName: 'Alice',
        ),
      );
      const session = UserSession(
        userId: 'user-1',
        accessToken: 'access',
        refreshToken: 'refresh',
        deviceId: 'device-1',
        accountStatus: 'under_review',
      );

      await runtime.saveSession(session);

      expect(runtime.canWriteAccount, isFalse);
      expect(runtime.isUnderReview, isTrue);
      expect(runtime.chatSendRestriction, ChatSendRestriction.underReview);
      await expectLater(
        runtime.updateProfile(
          runtime.currentUser!.copyWith(displayName: 'Changed'),
        ),
        throwsA(isA<ProfileSyncPendingException>()),
      );
      await expectLater(
        runtime.updatePrivacySetting(field: 'bio', visibility: 'nobody'),
        throwsA(isA<ProfileSyncPendingException>()),
      );
      expect(runtime.currentUser?.displayName, 'Changed');
      expect(runtime.currentUser?.privacySettings['bio'], 'nobody');
      expect(
        runtime.profileRepository.pendingSyncRevision('user-1'),
        isNotNull,
      );

      await runtime.disconnect();
    },
  );

  test(
    'chat restriction contract keeps restricted accounts distinct',
    () async {
      final store = LocalStore.inMemory();
      addTearDown(store.close);
      final runtime = AppRuntime.forTesting(
        store: store,
        loadProfile: (_) async => const UserProfile(
          userId: 'user-1',
          username: 'alice',
          displayName: 'Alice',
        ),
      );

      await runtime.saveSession(
        const UserSession(
          userId: 'user-1',
          deviceId: 'device-1',
          accountStatus: 'restricted',
        ),
      );

      expect(runtime.chatSendRestriction, ChatSendRestriction.none);
      await runtime.disconnect();
    },
  );

  test(
    'login caches all groups and channels and removes stale memberships',
    () async {
      final store = LocalStore.inMemory();
      addTearDown(store.close);
      const session = UserSession(
        userId: 'user-1',
        accessToken: 'access',
        refreshToken: 'refresh',
        deviceId: 'device-1',
      );
      store.saveSession(session);
      await store.saveRecipient(
        const Recipient(
          id: 'stale-group',
          type: RecipientType.group,
          name: 'Old group',
          handle: '',
        ),
      );
      final runtime = AppRuntime.forTesting(
        store: store,
        loadProfile: (_) async => const UserProfile(
          userId: 'user-1',
          username: 'alice',
          displayName: 'Alice',
        ),
        loadGroupChannels: (_) async => (
          groups: [
            pb.GroupChannel(
              id: 'group-1',
              type: 'group',
              name: 'Engineering',
              ownerUserId: 'user-1',
              memberRole: 'owner',
            ),
          ],
          channels: [
            pb.GroupChannel(
              id: 'channel-1',
              type: 'channel',
              name: 'Announcements',
              ownerUserId: 'other-user',
              memberRole: 'subscriber',
            ),
          ],
        ),
      );

      await runtime.saveSession(session);

      expect(store.loadRecipient('group-1')?.composerRole, 'owner');
      expect(store.loadRecipient('channel-1')?.composerRole, 'subscriber');
      expect(store.loadRecipient('channel-1')?.canSendMessages, isFalse);
      expect(store.loadRecipient('stale-group'), isNull);
      await runtime.disconnect();
    },
  );

  test(
    'every session activation fetches and replaces the complete server profile',
    () async {
      final store = LocalStore.inMemory();
      addTearDown(store.close);
      var profileFetches = 0;
      var serverProfile = const UserProfile(
        userId: 'user-1',
        username: 'alice',
        displayName: 'Alice',
        avatarUrl: 'https://example.test/old-avatar.png',
      );
      final runtime = AppRuntime.forTesting(
        store: store,
        loadProfile: (userId) async {
          profileFetches++;
          expect(userId, 'user-1');
          return serverProfile;
        },
      );
      const session = UserSession(
        userId: 'user-1',
        accessToken: 'access',
        refreshToken: 'refresh',
        deviceId: 'device-1',
        signalDeviceId: 1,
      );

      await runtime.saveSession(session);
      expect(profileFetches, 1);
      expect(
        runtime.currentUser?.avatarUrl,
        'https://example.test/old-avatar.png',
      );

      runtime.saveCurrentUser(
        runtime.currentUser!.copyWith(clearAvatarUrl: true),
      );
      expect(runtime.currentUser?.avatarUrl, isNull);
      serverProfile = const UserProfile(
        userId: 'user-1',
        username: 'alice',
        displayName: 'Alice updated on server',
        avatarUrl: null,
      );

      runtime.profileRepository.clearSessionAndProfile();
      await runtime.saveSession(session);

      expect(profileFetches, 2);
      expect(runtime.currentUser?.displayName, 'Alice updated on server');
      expect(runtime.currentUser?.avatarUrl, isNull);
      expect(store.loadCurrentUser(userId: 'user-1')?.avatarUrl, isNull);
      await runtime.disconnect();
    },
  );
}
