import 'package:flutter_test/flutter_test.dart';
import 'package:tureon/core/storage/cached_room_members_page.dart';
import 'package:tureon/core/storage/local_store.dart';
import 'package:tureon/core/storage/message_records.dart';
import 'package:tureon/features/groups/data/group_channel_service.dart';

void main() {
  late LocalStore store;
  late GroupChannelService service;

  setUp(() {
    store = LocalStore.inMemory();
    store.saveSession(
      const UserSession(userId: 'account-a', deviceId: 'device-a'),
    );
    service = GroupChannelService(store: store, client: () => null);
  });

  tearDown(() => store.close());

  test('a fresh member page opens from SQLite while disconnected', () async {
    final now = DateTime.now().toUtc();
    await store.saveRoomMembersPage(
      CachedRoomMembersPage(
        roomId: 'group-1',
        offset: 0,
        pageSize: 50,
        members: const [
          CachedRoomMember(
            userId: 'member-1',
            role: 'owner',
            joinedAt: 100,
            displayName: 'Group Owner',
            username: 'owner',
            avatarUrl: 'https://example.test/avatar.png',
          ),
        ],
        totalCount: 1,
        nextOffset: 1,
        hasMore: false,
        fetchedAt: now,
        lastAttemptAt: now,
      ),
    );

    final page = await service.listMembersPage(
      groupChannelId: 'group-1',
      offset: 0,
    );

    expect(page.members.single.userId, 'member-1');
    expect(page.members.single.displayName, 'Group Owner');
    expect(page.totalCount.toInt(), 1);
  });

  test('an expired page remains available when refresh is offline', () async {
    final now = DateTime.now().toUtc();
    final fetchedAt = now.subtract(const Duration(minutes: 10));
    await store.saveRoomMembersPage(
      CachedRoomMembersPage(
        roomId: 'group-2',
        offset: 0,
        pageSize: 50,
        members: const [
          CachedRoomMember(
            userId: 'member-2',
            role: 'member',
            joinedAt: 200,
            displayName: 'Saved Member',
            username: 'saved_member',
            avatarUrl: '',
          ),
        ],
        totalCount: 8,
        nextOffset: 1,
        hasMore: true,
        fetchedAt: fetchedAt,
        lastAttemptAt: fetchedAt,
      ),
    );

    final page = await service.listMembersPage(
      groupChannelId: 'group-2',
      offset: 0,
    );

    expect(page.members.single.userId, 'member-2');
    expect(page.totalCount.toInt(), 8);
    expect(
      store
          .loadRoomMembersPage(roomId: 'group-2', offset: 0, pageSize: 50)!
          .lastAttemptAt
          .isAfter(fetchedAt),
      isTrue,
    );
  });

  test(
    'member pages are isolated by account and first-page refresh trims old pages',
    () async {
      final now = DateTime.now().toUtc();
      CachedRoomMembersPage makePage(int offset, String userId) =>
          CachedRoomMembersPage(
            roomId: 'group-3',
            offset: offset,
            pageSize: 50,
            members: [
              CachedRoomMember(
                userId: userId,
                role: 'member',
                joinedAt: 300,
                displayName: userId,
                username: userId,
                avatarUrl: '',
              ),
            ],
            totalCount: 2,
            nextOffset: offset + 1,
            hasMore: offset == 0,
            fetchedAt: now,
            lastAttemptAt: now,
          );

      await store.saveRoomMembersPage(makePage(0, 'member-a'));
      await store.saveRoomMembersPage(makePage(50, 'member-b'));
      expect(store.loadRoomMemberPages('group-3'), hasLength(2));

      store.saveSession(
        const UserSession(userId: 'account-b', deviceId: 'device-b'),
      );
      expect(store.loadRoomMemberPages('group-3'), isEmpty);

      store.saveSession(
        const UserSession(userId: 'account-a', deviceId: 'device-a'),
      );
      await store.saveRoomMembersPage(makePage(0, 'member-a-updated'));
      final pages = store.loadRoomMemberPages('group-3');
      expect(pages, hasLength(1));
      expect(pages.single.members.single.userId, 'member-a-updated');
    },
  );
}
