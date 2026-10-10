import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tureon/core/protocol/recipient.dart';
import 'package:tureon/core/protocol/recipient_type.dart';
import 'package:tureon/core/storage/local_store.dart';
import 'package:tureon/core/storage/message_records.dart';
import 'package:tureon/features/home/data/local_home_repository.dart';
import 'package:tureon/features/home/home_providers.dart';
import 'package:tureon/features/home/presentation/home_view_model.dart';

void main() {
  late LocalStore store;
  late ProviderContainer container;

  setUp(() {
    store = LocalStore.inMemory();
    container = ProviderContainer(
      overrides: [
        homeRepositoryProvider.overrideWithValue(LocalHomeRepository(store)),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await store.close();
  });

  test(
    'subscribes to repository changes and exposes immutable state',
    () async {
      final subscription = container.listen(homeViewModelProvider, (_, _) {});
      final viewModel = container.read(homeViewModelProvider.notifier);
      const recipient = Recipient(
        id: 'recipient-1',
        type: RecipientType.user,
        name: 'Peer',
        handle: '@peer',
      );

      viewModel.upsertRecipient(recipient);

      expect(
        container.read(homeViewModelProvider).recipients.single.id,
        recipient.id,
      );
      expect(
        () => container.read(homeViewModelProvider).recipients.clear(),
        throwsUnsupportedError,
      );
      subscription.close();
    },
  );

  test('updates pin and archive commands through the local repository', () {
    const recipient = Recipient(
      id: 'recipient-1',
      type: RecipientType.user,
      name: 'Peer',
      handle: '@peer',
    );
    final viewModel = container.read(homeViewModelProvider.notifier);

    viewModel.togglePinned(recipient);
    viewModel.toggleArchived(recipient);

    final state = container.read(homeViewModelProvider);
    expect(state.isPinned(recipient), isTrue);
    expect(state.isArchived(recipient), isTrue);
    expect(state.activeRecipients, isEmpty);
    expect(
      container.read(homeRepositoryProvider)!.loadPinnedConversationIds(),
      {recipient.id},
    );
    expect(
      container.read(homeRepositoryProvider)!.loadArchivedConversationIds(),
      {recipient.id},
    );
  });

  test('keeps pinned order stable and excludes archived recipients', () {
    const firstPinned = Recipient(
      id: 'pinned-1',
      type: RecipientType.user,
      name: 'First pinned',
      handle: '',
    );
    const archived = Recipient(
      id: 'archived',
      type: RecipientType.user,
      name: 'Archived',
      handle: '',
    );
    const secondPinned = Recipient(
      id: 'pinned-2',
      type: RecipientType.user,
      name: 'Second pinned',
      handle: '',
    );
    final state = HomeState(
      recipients: [firstPinned, archived, secondPinned],
      pinnedIds: const {'pinned-1', 'pinned-2'},
      archivedIds: const {'archived'},
    );

    expect(state.activeRecipients, [firstPinned, secondPinned]);
    expect(state.archivedRecipients, [archived]);
    expect(() => state.activeRecipients.clear(), throwsUnsupportedError);
  });

  test('applies ephemeral presence without writing it to SQLite', () async {
    store.saveSession(
      const UserSession(userId: 'account-a', deviceId: 'device-a'),
    );
    const recipient = Recipient(
      id: 'presence-peer',
      type: RecipientType.user,
      name: 'Peer',
      handle: '',
    );
    await store.saveRecipient(recipient);
    final subscription = container.listen(homeViewModelProvider, (_, _) {});
    final viewModel = container.read(homeViewModelProvider.notifier);

    viewModel.applyPresenceUpdate(
      recipient.copyWith(
        isOnline: true,
        isPresenceVisible: true,
        presenceUpdate: true,
      ),
    );
    await _waitUntil(
      () => container.read(homeViewModelProvider).recipients.length == 1,
    );
    expect(
      container.read(homeViewModelProvider).recipients.single.isOnline,
      isTrue,
    );
    expect(store.loadRecipient(recipient.id)?.isOnline, isFalse);

    await store.saveRecipient(recipient.copyWith(name: 'Peer updated'));
    await Future<void>.delayed(Duration.zero);
    final updated = container.read(homeViewModelProvider).recipients.single;
    expect(updated.name, 'Peer updated');
    expect(updated.isOnline, isTrue);
    expect(store.loadRecipient(recipient.id)?.isOnline, isFalse);
    subscription.close();
  });

  test(
    'clears the selected recipient when the active account changes',
    () async {
      store.saveSession(
        const UserSession(userId: 'account-a', deviceId: 'device-a'),
      );
      const recipient = Recipient(
        id: 'private-recipient-a',
        type: RecipientType.user,
        name: 'Private account A contact',
        handle: '',
      );
      await store.saveRecipient(recipient);
      final viewModel = container.read(homeViewModelProvider.notifier);
      final stateSubscription = container.listen(
        homeViewModelProvider,
        (_, _) {},
      );
      viewModel.selectRecipient(recipient);

      final accountChanged = Completer<void>();
      final accountSubscription = container.listen(homeViewModelProvider, (
        _,
        next,
      ) {
        if (next.recipients.isEmpty &&
            next.selectedRecipient == null &&
            !accountChanged.isCompleted) {
          accountChanged.complete();
        }
      });

      store.saveSession(
        const UserSession(userId: 'account-b', deviceId: 'device-b'),
      );
      await accountChanged.future.timeout(const Duration(seconds: 1));

      expect(container.read(homeViewModelProvider).selectedRecipient, isNull);
      expect(container.read(homeViewModelProvider).recipients, isEmpty);
      accountSubscription.close();
      stateSubscription.close();
    },
  );
}

Future<void> _waitUntil(bool Function() condition) async {
  final deadline = DateTime.now().add(const Duration(seconds: 1));
  while (!condition()) {
    if (DateTime.now().isAfter(deadline)) {
      throw TimeoutException('Condition was not met');
    }
    await Future<void>.delayed(Duration.zero);
  }
}
