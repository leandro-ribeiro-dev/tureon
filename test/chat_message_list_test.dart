import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tureon/features/chats/domain/chat_message.dart';
import 'package:tureon/features/chats/domain/message_date_grouper.dart';
import 'package:tureon/features/chats/presentation/widgets/chat_message_list.dart';

void main() {
  testWidgets('requests older history when the user reaches the list start', (
    tester,
  ) async {
    final controller = ScrollController();
    var reachedStartCount = 0;
    final items = List<MessageListItem>.generate(
      40,
      (index) => ChatMessageItem(
        ChatMessage(
          messageId: 'message-$index',
          chatId: 'chat',
          senderRecipientId: 'peer',
          body: 'Message $index',
          createdAt: DateTime.utc(2026, 1, 1).add(Duration(minutes: index)),
        ),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChatMessageList(
            controller: controller,
            items: items,
            itemKey: (index) => ValueKey<String>(
              (items[index] as ChatMessageItem).message.messageId,
            ),
            itemBuilder: (context, index) => SizedBox(
              height: 64,
              child: Text((items[index] as ChatMessageItem).message.body),
            ),
            empty: const SizedBox.shrink(),
            isLoadingEarlier: false,
            onReachStart: () => reachedStartCount++,
            onUserScroll: (UserScrollNotification _) => false,
            onMetricsChanged: () {},
          ),
        ),
      ),
    );
    addTearDown(controller.dispose);

    controller.jumpTo(controller.position.maxScrollExtent);
    await tester.pump();
    await tester.drag(find.byType(ListView), const Offset(0, 2500));
    await tester.pumpAndSettle();

    expect(controller.offset, controller.position.minScrollExtent);
    expect(reachedStartCount, greaterThan(0));
  });
}
