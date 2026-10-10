import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tureon/core/protocol/recipient.dart';
import 'package:tureon/core/protocol/recipient_type.dart';
import 'package:tureon/features/home/presentation/controllers/home_view_model.dart';

void main() {
  group('Conversation Ordering Unit Tests', () {
    test('opening a chat does NOT reorder conversation list', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      const r1 = Recipient(
        id: 'r1',
        type: RecipientType.user,
        name: 'Chat 1',
        handle: '@r1',
        lastMessage: 'Msg 1',
      );
      const r2 = Recipient(
        id: 'r2',
        type: RecipientType.user,
        name: 'Chat 2',
        handle: '@r2',
        lastMessage: 'Msg 2',
      );

      final notifier = container.read(homeViewModelProvider.notifier);
      notifier.upsertRecipient(r1); // index 1
      notifier.upsertRecipient(r2); // index 0 (r2 at top, r1 second)

      final initialList = container.read(homeViewModelProvider).recipients;
      expect(initialList[0].id, equals('r2'));
      expect(initialList[1].id, equals('r1'));

      // Re-opening / upserting r1 WITHOUT a new lastMessage
      notifier.upsertRecipient(r1);

      final listAfterOpening = container.read(homeViewModelProvider).recipients;
      // Position MUST stay unchanged!
      expect(listAfterOpening[0].id, equals('r2'));
      expect(listAfterOpening[1].id, equals('r1'));
    });

    test('stale recipient snapshot does not reorder conversation list', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      const r1 = Recipient(
        id: 'r1',
        type: RecipientType.user,
        name: 'Chat 1',
        handle: '@r1',
        lastMessage: 'Msg 1',
      );
      const r2 = Recipient(
        id: 'r2',
        type: RecipientType.user,
        name: 'Chat 2',
        handle: '@r2',
        lastMessage: 'Msg 2',
      );

      final notifier = container.read(homeViewModelProvider.notifier);
      notifier.upsertRecipient(r1);
      notifier.upsertRecipient(r2);

      // A stale recipient merged while opening a chat may differ from the
      // current preview. Only the ordered storage stream may change ordering.
      final updatedR1 = r1.copyWith(lastMessage: 'Nova mensagem enviada!');
      notifier.upsertRecipient(updatedR1);

      final listAfterNewMessage = container
          .read(homeViewModelProvider)
          .recipients;
      expect(listAfterNewMessage[0].id, equals('r2'));
      expect(listAfterNewMessage[1].id, equals('r1'));
    });
  });
}
