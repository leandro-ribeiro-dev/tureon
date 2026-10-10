import 'package:flutter_test/flutter_test.dart';
import 'package:tureon/core/app/app_state.dart';
import 'package:tureon/core/protocol/recipient.dart';
import 'package:tureon/core/protocol/recipient_type.dart';

void main() {
  group('AppState conversation recipients', () {
    test('keeps groups and channels in the main conversation list', () {
      final state = AppState();
      state.upsertRecipient(_recipient('channel-1', RecipientType.channel));
      state.upsertRecipient(_recipient('user-1', RecipientType.user));
      state.upsertRecipient(_recipient('group-1', RecipientType.group));

      expect(
        state.activeRecipients.map((recipient) => recipient.id),
        containsAll(['channel-1', 'user-1', 'group-1']),
      );
    });

    test('archives groups and channels like other conversations', () {
      final state = AppState();
      final group = _recipient('group-1', RecipientType.group);
      state.upsertRecipient(group);
      state.toggleArchived(group);

      expect(state.activeRecipients, isEmpty);
      expect(state.archivedRecipients.map((recipient) => recipient.id), [
        group.id,
      ]);
    });
  });
}

Recipient _recipient(String id, RecipientType type) =>
    Recipient(id: id, type: type, name: id, handle: '');
