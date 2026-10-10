import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:tureon/core/app/app_state.dart';
import 'package:tureon/core/protocol/recipient.dart';
import 'package:tureon/core/protocol/recipient_type.dart';
import 'package:tureon/core/protocol/verification_badge.dart';
import 'package:tureon/features/profile/data/profile_repository.dart';
import 'package:tureon/core/storage/local_store.dart';
import 'package:tureon/features/home/data/local_home_repository.dart';
import 'package:tureon/core/storage/message_records.dart';
import 'package:tureon/features/chats/domain/chat_message.dart';

void main() {
  late LocalStore store;

  setUp(() {
    store = LocalStore.inMemory();
  });

  tearDown(() {
    store.close();
  });

  test('local profile edits remain authoritative and queue a replica sync', () {
    final profile = UserProfile(
      userId: 'user-1',
      username: 'alice_123',
      displayName: 'Alice',
      bio: 'Local profile',
      phoneE164: '+15551234567',
      countryCode: 'BR',
      createdAt: DateTime.utc(2020, 1, 2),
      privacySettings: {'bio': 'contacts'},
      verificationBadge: VerificationBadge.developer,
    );

    store.saveCurrentUser(profile, markForSync: true);

    expect(store.loadCurrentUser(userId: 'user-1')?.bio, 'Local profile');
    expect(store.loadCurrentUser(userId: 'user-1')?.countryCode, 'BR');
    expect(
      store.loadCurrentUser(userId: 'user-1')?.createdAt,
      DateTime.utc(2020, 1, 2),
    );
    expect(
      store.loadCurrentUser(userId: 'user-1')?.privacySettings['bio'],
      'contacts',
    );
    expect(
      store.loadCurrentUser(userId: 'user-1')?.verificationBadge,
      VerificationBadge.developer,
    );
    expect(store.pendingProfileSyncRevision('user-1'), 1);
  });

  test(
    'recipient verification badges persist locally for every recipient kind',
    () async {
      await store.saveRecipient(
        const Recipient(
          id: 'channel-1',
          type: RecipientType.channel,
          name: 'Canal oficial',
          handle: '',
          verificationBadge: VerificationBadge.celebrity,
        ),
      );

      expect(
        store.loadRecipients().single.verificationBadge,
        VerificationBadge.celebrity,
      );
    },
  );

  test(
    'recipient shared and user metadata survive local persistence',
    () async {
      await store.saveRecipient(
        Recipient(
          id: 'user-country',
          type: RecipientType.user,
          name: 'Alice',
          handle: '@alice',
          countryCode: 'BR',
          createdAt: DateTime.utc(2020, 1, 2),
        ),
      );

      final recipient = store.loadRecentUserRecipients().single;
      expect(recipient.countryCode, 'BR');
      expect(recipient.createdAt, DateTime.utc(2020, 1, 2));
    },
  );

  test('group slow mode policy persists locally per account', () async {
    await store.saveRecipient(
      const Recipient(
        id: 'group-slow-mode',
        type: RecipientType.group,
        name: 'Grupo',
        handle: '@grupo',
        slowModeSeconds: 300,
      ),
    );

    expect(store.loadRecipient('group-slow-mode')?.slowModeSeconds, 300);
  });

  test(
    'opening a new recipient persists its conversation metadata locally',
    () async {
      final state = AppState(repository: LocalHomeRepository(store));
      const recipient = Recipient(
        id: 'user-42',
        type: RecipientType.user,
        name: 'Alice',
        handle: '@alice',
      );

      final opened = state.upsertRecipient(recipient);
      await store
          .watchRecipient(recipient.id)
          .firstWhere((savedRecipient) => savedRecipient != null);

      expect(opened.id, recipient.id);
      expect(state.recipients.single.id, recipient.id);
      expect(store.loadRecipient(recipient.id)?.handle, '@alice');
      expect(store.loadChatMessages(recipient.id), isEmpty);
    },
  );

  test(
    'conversation history and metadata are isolated between accounts',
    () async {
      const sharedRecipientId = 'contact-1';
      ChatMessage messageFor(String body) => ChatMessage(
        messageId: 'message-1',
        chatId: sharedRecipientId,
        senderRecipientId: 'user-self',
        body: body,
        createdAt: DateTime.utc(2026, 10, 1),
      );

      store.saveSession(
        const UserSession(userId: 'account-a', deviceId: 'device-a'),
      );
      await store.saveRecipient(
        const Recipient(
          id: sharedRecipientId,
          type: RecipientType.user,
          name: 'Contact for A',
          handle: '@contact',
        ),
      );
      store.saveChatMessage(messageFor('Private history A'));

      store.saveSession(
        const UserSession(userId: 'account-b', deviceId: 'device-b'),
      );
      expect(store.loadRecipients(), isEmpty);
      expect(store.loadChatMessages(sharedRecipientId), isEmpty);
      await store.saveRecipient(
        const Recipient(
          id: sharedRecipientId,
          type: RecipientType.user,
          name: 'Contact for B',
          handle: '@contact',
        ),
      );
      store.saveChatMessage(messageFor('Private history B'));

      expect(store.loadRecipient(sharedRecipientId)?.name, 'Contact for B');
      expect(
        store.loadChatMessages(sharedRecipientId).single.body,
        'Private history B',
      );

      store.saveSession(
        const UserSession(userId: 'account-a', deviceId: 'device-a'),
      );
      expect(store.loadRecipient(sharedRecipientId)?.name, 'Contact for A');
      expect(
        store.loadChatMessages(sharedRecipientId).single.body,
        'Private history A',
      );
    },
  );

  test('incoming messages atomically create and deduplicate conversations', () {
    const sender = Recipient(
      id: 'sender-1',
      type: RecipientType.user,
      name: 'Alice',
      handle: '@alice',
      avatarUrl: 'https://example.test/alice.png',
      isUsernameVisible: true,
      verificationBadge: VerificationBadge.verified,
    );
    final message = ChatMessage(
      messageId: 'incoming-1',
      chatId: 'sender-1',
      senderRecipientId: 'sender-1',
      body: 'Hello',
      createdAt: DateTime.utc(2026, 10, 1),
    );

    expect(store.saveIncomingMessage(message, sender), isTrue);
    final savedRecipient = store.loadRecipient('sender-1');
    expect(savedRecipient?.name, 'Alice');
    expect(savedRecipient?.handle, '@alice');
    expect(savedRecipient?.avatarUrl, sender.avatarUrl);
    expect(savedRecipient?.lastMessage, 'Hello');
    expect(savedRecipient?.unreadCount, 1);
    expect(store.saveIncomingMessage(message, sender), isFalse);
    expect(store.loadRecipient('sender-1')?.unreadCount, 1);
    expect(store.loadChatMessages('sender-1'), hasLength(1));
  });

  test('a stale sync completion does not clear a newer local edit', () {
    const profile = UserProfile(
      userId: 'user-1',
      username: 'alice_123',
      displayName: 'Alice',
    );

    store.saveCurrentUser(profile, markForSync: true);
    store.saveCurrentUser(
      profile.copyWith(displayName: 'Alice Updated'),
      markForSync: true,
    );
    store.completeProfileSync('user-1', 1, profile);

    expect(
      store.loadCurrentUser(userId: 'user-1')?.displayName,
      'Alice Updated',
    );
    expect(store.pendingProfileSyncRevision('user-1'), 2);
  });

  test('profile sync completion clears only the matching revision', () {
    const profile = UserProfile(
      userId: 'user-1',
      username: 'alice_123',
      displayName: 'Alice',
    );

    store.saveCurrentUser(profile, markForSync: true);
    store.completeProfileSync('user-1', 1, profile);

    expect(store.pendingProfileSyncRevision('user-1'), isNull);
  });

  test('profile stream rereads committed SQLite state', () async {
    store.saveSession(
      const UserSession(userId: 'user-1', deviceId: 'device-1'),
    );
    final repository = ProfileRepository(store);
    final iterator = StreamIterator(repository.watchCurrentUser());

    expect(await iterator.moveNext(), isTrue);
    expect(iterator.current, isNull);
    store.saveCurrentUser(
      const UserProfile(
        userId: 'user-1',
        username: 'alice_123',
        displayName: 'Alice',
      ),
    );
    expect(await iterator.moveNext(), isTrue);
    expect(iterator.current?.displayName, 'Alice');

    store.saveCurrentUser(
      const UserProfile(
        userId: 'user-1',
        username: 'alice_123',
        displayName: 'Alice Updated',
      ),
    );
    expect(await iterator.moveNext(), isTrue);
    expect(iterator.current?.displayName, 'Alice Updated');

    await iterator.cancel();
  });

  test(
    'remote profile changes merge with pending local edits by field',
    () async {
      store.saveSession(
        const UserSession(userId: 'user-1', deviceId: 'device-1'),
      );
      const base = UserProfile(
        userId: 'user-1',
        username: 'alice_123',
        displayName: 'Alice',
        bio: 'Old bio',
        avatarUrl: 'https://cdn.example/avatar.png',
        profileVersion: 4,
      );
      store.saveCurrentUser(base);
      store.saveCurrentUser(
        base.copyWith(displayName: 'Local name'),
        markForSync: true,
      );

      final repository = ProfileRepository(store);
      final merged = await repository.refreshFromServer(
        'user-1',
        (_) async => const UserProfile(
          userId: 'user-1',
          username: 'alice_123',
          displayName: 'Server name',
          bio: 'Updated remotely',
          avatarUrl: null,
          profileVersion: 5,
        ),
      );

      expect(merged.displayName, 'Local name');
      expect(merged.bio, 'Updated remotely');
      expect(merged.avatarUrl, isNull);
      expect(merged.profileVersion, 5);
      expect(repository.pendingSyncRevision('user-1'), 1);
      expect(
        store.loadProfileSyncBaseline('user-1')?.displayName,
        'Server name',
      );
    },
  );

  test(
    'authoritative profile refresh clears explicitly removed avatar',
    () async {
      store.saveSession(
        const UserSession(userId: 'user-1', deviceId: 'device-1'),
      );
      store.saveCurrentUser(
        const UserProfile(
          userId: 'user-1',
          username: 'alice_123',
          displayName: 'Alice',
          avatarUrl: 'https://cdn.example/avatar.png',
        ),
      );
      final repository = ProfileRepository(store);

      final profile = await repository.refreshFromServer(
        'user-1',
        (_) async => const UserProfile(
          userId: 'user-1',
          username: 'alice_123',
          displayName: 'Alice',
          avatarUrl: null,
          profileVersion: 2,
        ),
      );

      expect(profile.avatarUrl, isNull);
      expect(store.loadCurrentUser(userId: 'user-1')?.avatarUrl, isNull);
    },
  );

  test('profile stream follows account switches and logout', () async {
    store.saveSession(
      const UserSession(userId: 'user-1', deviceId: 'device-1'),
    );
    store.saveCurrentUser(
      const UserProfile(
        userId: 'user-1',
        username: 'alice_123',
        displayName: 'Alice',
      ),
    );
    store.saveCurrentUser(
      const UserProfile(
        userId: 'user-2',
        username: 'bob_123',
        displayName: 'Bob',
      ),
    );
    final repository = ProfileRepository(store);
    final iterator = StreamIterator(repository.watchCurrentUser());

    expect(await iterator.moveNext(), isTrue);
    expect(iterator.current?.displayName, 'Alice');
    store.saveSession(
      const UserSession(userId: 'user-2', deviceId: 'device-2'),
    );
    expect(await iterator.moveNext(), isTrue);
    expect(iterator.current?.displayName, 'Bob');

    store.clearSession();
    expect(await iterator.moveNext(), isTrue);
    expect(iterator.current, isNull);

    await iterator.cancel();
  });

  test(
    'login refresh after avatar removal replaces the full profile after logout',
    () async {
      final repository = ProfileRepository(store);
      store.saveSession(
        const UserSession(userId: 'user-1', deviceId: 'device-1'),
      );
      repository.saveLocal(
        const UserProfile(
          userId: 'user-1',
          username: 'alice',
          displayName: 'Alice old',
          bio: 'old bio',
          avatarUrl: 'https://example.test/old-avatar.png',
          privacySettings: {'bio': 'contacts'},
        ),
      );

      final edited = store
          .loadCurrentUser(userId: 'user-1')!
          .copyWith(avatarUrl: null, clearAvatarUrl: true);
      repository.saveLocal(edited, markForSync: true);
      expect(store.loadCurrentUser(userId: 'user-1')?.avatarUrl, isNull);

      repository.clearSessionAndProfile();
      expect(store.loadCurrentUser(userId: 'user-1'), isNull);
      store.saveSession(
        const UserSession(userId: 'user-1', deviceId: 'device-1'),
      );

      final freshProfile = await repository.refreshFromServer(
        'user-1',
        (_) async => const UserProfile(
          userId: 'user-1',
          username: 'alice',
          displayName: 'Alice from server',
          avatarUrl: null,
          privacySettings: {'bio': 'nobody'},
        ),
      );

      expect(freshProfile.displayName, 'Alice from server');
      expect(freshProfile.avatarUrl, isNull);
      final persisted = store.loadCurrentUser(userId: 'user-1');
      expect(persisted?.displayName, 'Alice from server');
      expect(persisted?.avatarUrl, isNull);
      expect(persisted?.bio, isNull);
      expect(persisted?.privacySettings, {'bio': 'nobody'});
    },
  );

  test(
    'logout clears session and profile but preserves chat history',
    () async {
      final repository = ProfileRepository(store);
      store.saveSession(
        const UserSession(userId: 'user-1', deviceId: 'device-1'),
      );
      repository.saveLocal(
        const UserProfile(
          userId: 'user-1',
          username: 'alice',
          displayName: 'Alice',
          avatarUrl: 'https://example.test/avatar.png',
        ),
      );
      await store.saveRecipient(
        const Recipient(
          id: 'user-2',
          type: RecipientType.user,
          name: 'Bob',
          handle: '@bob',
        ),
      );
      store.saveChatMessage(
        ChatMessage(
          messageId: 'kept-message',
          chatId: 'user-2',
          senderRecipientId: 'user-1',
          body: 'keep me',
          createdAt: DateTime.utc(2026, 10, 2),
        ),
      );

      repository.clearSessionAndProfile();

      expect(store.loadSession(), isNull);
      expect(store.loadCurrentUser(userId: 'user-1'), isNull);
      expect(store.loadRecipient('user-2'), isNull);
      expect(store.loadChatMessages('user-2'), isEmpty);

      store.saveSession(
        const UserSession(userId: 'user-2', deviceId: 'device-2'),
      );
      expect(store.loadRecipient('user-2'), isNull);
      store.saveSession(
        const UserSession(userId: 'user-1', deviceId: 'device-1'),
      );
      expect(store.loadRecipient('user-2'), isNotNull);
      expect(store.loadChatMessages('user-2').single.body, 'keep me');
    },
  );

  test(
    'corrupt profile cache is deleted and recovered from the server',
    () async {
      var corruptRead = true;
      final repository = ProfileRepository(
        store,
        readLocalProfile: (userId) {
          if (corruptRead) throw const FormatException('invalid profile JSON');
          return store.loadCurrentUser(userId: userId);
        },
      );
      store.saveSession(
        const UserSession(userId: 'user-1', deviceId: 'device-1'),
      );
      repository.saveLocal(
        const UserProfile(
          userId: 'user-1',
          username: 'old',
          displayName: 'Corrupt cache',
        ),
      );
      final repaired = Completer<void>();
      repository.recoverProfile = (userId) async {
        corruptRead = false;
        const profile = UserProfile(
          userId: 'user-1',
          username: 'alice',
          displayName: 'Recovered profile',
          avatarUrl: null,
        );
        repository.saveLocal(profile);
        repaired.complete();
        return profile;
      };

      expect(repository.loadUser('user-1'), isNull);
      await repaired.future;

      expect(repository.loadUser('user-1')?.displayName, 'Recovered profile');
      expect(repository.loadUser('user-1')?.avatarUrl, isNull);
    },
  );

  test(
    'cancelled profile observers do not accumulate across repeated logins',
    () async {
      store.saveSession(
        const UserSession(userId: 'user-1', deviceId: 'device-1'),
      );
      final repository = ProfileRepository(store);
      for (var index = 0; index < 5; index++) {
        final subscription = repository.watchCurrentUser().listen((_) {});
        await Future<void>.delayed(Duration.zero);
        await subscription.cancel();
      }

      final events = <UserProfile?>[];
      final subscription = repository.watchCurrentUser().listen(events.add);
      await Future<void>.delayed(Duration.zero);
      events.clear();
      repository.saveLocal(
        const UserProfile(
          userId: 'user-1',
          username: 'alice',
          displayName: 'Alice',
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(events, hasLength(1));
      await subscription.cancel();
    },
  );
}
