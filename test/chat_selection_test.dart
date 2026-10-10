import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tureon/core/protocol/recipient.dart';
import 'package:tureon/core/protocol/recipient_type.dart';
import 'package:tureon/features/chats/presentation/views/home_chats_screen.dart';
import 'package:tureon/features/home/presentation/controllers/home_view_model.dart';

void main() {
  group('HomeViewModel Batch Operations Unit Tests', () {
    test('enforces max limit of 5 pinned conversations', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(homeViewModelProvider.notifier);

      for (int i = 1; i <= 6; i++) {
        final r = Recipient(
          id: 'r$i',
          type: RecipientType.user,
          name: 'Chat $i',
          handle: '@r$i',
        );
        notifier.upsertRecipient(r);
        final success = notifier.togglePinned(r);
        if (i <= 5) {
          expect(success, isTrue);
        } else {
          expect(success, isFalse); // 6th pin rejected
        }
      }

      expect(container.read(homeViewModelProvider).pinnedIds.length, equals(5));
    });

    test('undoDeleteConversation restores deleted recipient', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      const r1 = Recipient(
        id: 'r1',
        type: RecipientType.user,
        name: 'Chat 1',
        handle: '@r1',
      );

      final notifier = container.read(homeViewModelProvider.notifier);
      notifier.upsertRecipient(r1);
      expect(
        container.read(homeViewModelProvider).recipients.length,
        equals(1),
      );

      notifier.deleteConversation(r1);
      expect(container.read(homeViewModelProvider).recipients.isEmpty, isTrue);

      notifier.undoDeleteConversation(r1);
      expect(
        container.read(homeViewModelProvider).recipients.length,
        equals(1),
      );
    });

    test('togglePinnedBatch pins and unpins multiple conversations', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      const r1 = Recipient(
        id: 'r1',
        type: RecipientType.user,
        name: 'Chat 1',
        handle: '@r1',
      );
      const r2 = Recipient(
        id: 'r2',
        type: RecipientType.user,
        name: 'Chat 2',
        handle: '@r2',
      );

      final notifier = container.read(homeViewModelProvider.notifier);
      notifier.upsertRecipient(r1);
      notifier.upsertRecipient(r2);

      expect(container.read(homeViewModelProvider).pinnedIds.isEmpty, isTrue);

      // Pin batch
      notifier.togglePinnedBatch([r1, r2]);
      expect(
        container.read(homeViewModelProvider).pinnedIds.containsAll([
          'r1',
          'r2',
        ]),
        isTrue,
      );

      // Unpin batch
      notifier.togglePinnedBatch([r1, r2]);
      expect(container.read(homeViewModelProvider).pinnedIds.isEmpty, isTrue);
    });

    test('rejects oversized pin batches without partial changes', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(homeViewModelProvider.notifier);
      final recipients = [
        for (var index = 1; index <= 6; index++)
          Recipient(
            id: 'r$index',
            type: RecipientType.user,
            name: 'Chat $index',
            handle: '',
          ),
      ];
      for (final recipient in recipients.take(5)) {
        notifier.togglePinned(recipient);
      }
      final before = container.read(homeViewModelProvider).pinnedIds;

      expect(
        notifier.togglePinnedBatch([recipients.first, recipients.last]),
        isFalse,
      );
      expect(container.read(homeViewModelProvider).pinnedIds, before);
    });

    test(
      'updates another recipient without clearing the open conversation',
      () {
        final container = ProviderContainer();
        addTearDown(container.dispose);
        final notifier = container.read(homeViewModelProvider.notifier);
        final first = Recipient(
          id: 'open-chat',
          type: RecipientType.user,
          name: 'Open chat',
          handle: '',
        );
        final second = Recipient(
          id: 'other-chat',
          type: RecipientType.user,
          name: 'Other chat',
          handle: '',
        );
        notifier.upsertRecipient(first);
        notifier.upsertRecipient(second);
        notifier.selectRecipient(first);

        notifier.upsertRecipient(second.copyWith(lastMessage: 'New message'));

        expect(
          container.read(homeViewModelProvider).selectedRecipient?.id,
          first.id,
        );
      },
    );

    test(
      'toggleArchivedBatch archives and unarchives multiple conversations',
      () {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        const r1 = Recipient(
          id: 'r1',
          type: RecipientType.user,
          name: 'Chat 1',
          handle: '@r1',
        );
        const r2 = Recipient(
          id: 'r2',
          type: RecipientType.user,
          name: 'Chat 2',
          handle: '@r2',
        );

        final notifier = container.read(homeViewModelProvider.notifier);
        notifier.upsertRecipient(r1);
        notifier.upsertRecipient(r2);

        expect(
          container.read(homeViewModelProvider).archivedIds.isEmpty,
          isTrue,
        );

        // Archive batch
        notifier.toggleArchivedBatch([r1, r2]);
        expect(
          container.read(homeViewModelProvider).archivedIds.containsAll([
            'r1',
            'r2',
          ]),
          isTrue,
        );

        // Unarchive batch
        notifier.toggleArchivedBatch([r1, r2]);
        expect(
          container.read(homeViewModelProvider).archivedIds.isEmpty,
          isTrue,
        );
      },
    );

    test('deleteConversationBatch deletes multiple conversations', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      const r1 = Recipient(
        id: 'r1',
        type: RecipientType.user,
        name: 'Chat 1',
        handle: '@r1',
      );
      const r2 = Recipient(
        id: 'r2',
        type: RecipientType.user,
        name: 'Chat 2',
        handle: '@r2',
      );

      final notifier = container.read(homeViewModelProvider.notifier);
      notifier.upsertRecipient(r1);
      notifier.upsertRecipient(r2);

      expect(
        container.read(homeViewModelProvider).recipients.length,
        equals(2),
      );

      notifier.deleteConversationBatch([r1, r2]);
      expect(container.read(homeViewModelProvider).recipients.isEmpty, isTrue);
    });
  });

  group('Multi-Selection Mode Widget Tests', () {
    testWidgets('Hides delete icon when more than 1 item is selected', (
      tester,
    ) async {
      const r1 = Recipient(
        id: 'r1',
        type: RecipientType.user,
        name: 'Chat 1',
        handle: '@r1',
      );
      const r2 = Recipient(
        id: 'r2',
        type: RecipientType.user,
        name: 'Chat 2',
        handle: '@r2',
      );

      final homeState = HomeState(recipients: const [r1, r2]);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: HomeChatsScreen(
              state: homeState,
              onSelectRecipient: (_) {},
              onOpenContactsTab: () {},
              onOpenSettings: () {},
            ),
          ),
        ),
      );

      // Long press on Chat 1 (1 selected) -> Delete icon visible
      await tester.longPress(find.text('Chat 1'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget);

      // Tap on Chat 2 (2 selected) -> Delete icon hidden
      await tester.tap(find.text('Chat 2'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.delete_outline_rounded), findsNothing);
    });
  });
}
