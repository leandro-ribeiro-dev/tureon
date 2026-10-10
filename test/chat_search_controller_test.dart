import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:tureon/core/protocol/recipient.dart';
import 'package:tureon/features/chats/presentation/controllers/chat_search_controller.dart';

void main() {
  testWidgets('stale remote failure cannot replace newer search state', (
    tester,
  ) async {
    final pending = <String, Completer<List<Recipient>>>{};
    final controller = ChatSearchController(
      searchUsers: () => (query) {
        final result = Completer<List<Recipient>>();
        pending[query] = result;
        return result.future;
      },
      searchGroups: () => null,
    );
    controller.search('first');
    await tester.pump(const Duration(milliseconds: 300));
    controller.search('second');
    await tester.pump(const Duration(milliseconds: 300));
    pending['first']!.completeError(StateError('old failure'));
    await tester.pump();
    expect(controller.query, 'second');
    expect(controller.error, isNull);
    expect(controller.isSearching, isTrue);
    pending['second']!.complete([]);
    await tester.pump();
    expect(controller.isSearching, isFalse);
    controller.dispose();
  });
  testWidgets('disposal cancels debounced network lookup', (tester) async {
    var calls = 0;
    final controller = ChatSearchController(
      searchUsers: () => (query) async {
        calls++;
        return [];
      },
      searchGroups: () => null,
    );
    controller.search('username');
    controller.dispose();
    await tester.pump(const Duration(seconds: 1));
    expect(calls, 0);
  });
}
