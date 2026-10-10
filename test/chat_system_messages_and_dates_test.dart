import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tureon/features/chats/domain/chat_message.dart';
import 'package:tureon/features/chats/domain/message_date_grouper.dart';
import 'package:tureon/features/chats/presentation/widgets/date_divider_bubble.dart';
import 'package:tureon/features/chats/presentation/widgets/system_message_bubble.dart';

void main() {
  group('Message Date Grouper Unit Tests', () {
    test('inserts DateDividerItems when calendar day changes', () {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));

      final msg1 = ChatMessage(
        messageId: 'm1',
        chatId: 'chat-1',
        senderRecipientId: 'user-1',
        type: ChatMessageType.text,
        body: 'Mensagem de ontem',
        createdAt: yesterday,
        status: ChatDeliveryStatus.read,
      );

      final msg2 = ChatMessage(
        messageId: 'm2',
        chatId: 'chat-1',
        senderRecipientId: 'user-1',
        type: ChatMessageType.text,
        body: 'Mensagem de hoje',
        createdAt: now,
        status: ChatDeliveryStatus.read,
      );

      final grouped = MessageDateGrouper.groupMessagesWithDates([msg1, msg2]);

      // Expect: DateDivider(Yesterday), msg1, DateDivider(Today), msg2
      expect(grouped.length, equals(4));
      expect(grouped[0], isA<DateDividerItem>());
      expect((grouped[0] as DateDividerItem).date.day, equals(yesterday.day));
      expect(grouped[1], isA<ChatMessageItem>());
      expect(grouped[2], isA<DateDividerItem>());
      expect((grouped[2] as DateDividerItem).date.day, equals(now.day));
      expect(grouped[3], isA<ChatMessageItem>());
    });

    test('orders out-of-order message sources before grouping by date', () {
      final older = ChatMessage(
        messageId: 'z-older',
        chatId: 'chat-1',
        senderRecipientId: 'user-1',
        body: 'older',
        createdAt: DateTime.utc(2026, 10, 6),
      );
      final newer = ChatMessage(
        messageId: 'a-newer',
        chatId: 'chat-1',
        senderRecipientId: 'user-1',
        body: 'newer',
        createdAt: DateTime.utc(2026, 10, 7),
      );

      final grouped = MessageDateGrouper.groupMessagesWithDates([newer, older]);

      expect(
        grouped.whereType<ChatMessageItem>().map((item) => item.message.body),
        ['older', 'newer'],
      );
    });
  });

  group('System Message & Date Divider Widget Tests', () {
    testWidgets('DateDividerBubble renders "Hoje" for current date', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DateDividerBubble(date: DateTime.now())),
        ),
      );

      expect(find.text('Hoje'), findsOneWidget);
    });

    testWidgets('DateDividerBubble renders "Ontem" for yesterday date', (
      tester,
    ) async {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DateDividerBubble(date: yesterday)),
        ),
      );

      expect(find.text('Ontem'), findsOneWidget);
    });

    testWidgets(
      'SystemMessageBubble renders group event notices (e.g. member added)',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SystemMessageBubble(
                message: 'João adicionou você ao grupo',
              ),
            ),
          ),
        );

        expect(find.text('João adicionou você ao grupo'), findsOneWidget);
      },
    );

    testWidgets(
      'SystemMessageBubble renders pill badge with lock icon for security notices',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SystemMessageBubble(
                message:
                    'Esta conversa é protegida por criptografia ponta a ponta.',
              ),
            ),
          ),
        );

        expect(
          find.text(
            'Esta conversa é protegida por criptografia ponta a ponta.',
          ),
          findsOneWidget,
        );
        expect(find.byIcon(Icons.lock_outline_rounded), findsOneWidget);
      },
    );
  });
}
