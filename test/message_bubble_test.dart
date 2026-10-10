import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tureon/core/design_system/message_bubble.dart';
import 'package:tureon/core/protocol/delivery_status.dart';
import 'package:tureon/l10n/app_localizations_pt.dart';

void main() {
  testWidgets('captions, sender, replies and metadata fit narrow bubbles', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    for (final isMine in [false, true]) {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          ),
          home: Scaffold(
            body: MessageBubble(
              text:
                  'Uma descrição longa da mídia que deve quebrar em várias linhas.',
              isMine: isMine,
              senderName: 'Maria',
              replyPreview: 'Mensagem anterior',
              timestamp: DateTime(2026, 10, 10, 12, 34),
              mediaIsVisual: true,
              mediaPreview: const SizedBox(
                width: 360,
                height: 160,
                child: ColoredBox(color: Colors.teal),
              ),
              translatedText:
                  'Uma tradução longa para conferir o comportamento em telas pequenas.',
              sourceLanguage: 'Português',
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('12:34'), findsOneWidget);
      expect(find.text('Mensagem anterior'), findsOneWidget);
      if (!isMine) {
        expect(
          tester.getTopLeft(find.text('Maria')).dy,
          lessThan(tester.getTopLeft(find.byType(ColoredBox).last).dy),
        );
      }
      final bubble = tester.getSize(find.byType(IntrinsicWidth));
      expect(bubble.width, lessThanOrEqualTo(320 * .84));
    }
  });

  testWidgets('uncaptioned visual media keeps timestamp over the preview', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MessageBubble(
            text: '',
            isMine: true,
            mediaIsVisual: true,
            timestamp: DateTime(2026, 10, 10, 12, 34),
            mediaPreview: const SizedBox(width: 280, height: 160),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.text('12:34'), findsOneWidget);
    expect(
      find.ancestor(of: find.text('12:34'), matching: find.byType(Positioned)),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.done_all_rounded), findsOneWidget);
  });

  testWidgets('short messages keep time on the text line', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MessageBubble(
            text: 'Olá!',
            isMine: true,
            timestamp: DateTime(2026, 10, 10, 12, 34),
          ),
        ),
      ),
    );
    final text = find.textContaining('Olá!');
    expect(tester.getSize(text).height, lessThan(32));
    expect(find.text('12:34'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('continuation bubbles do not repeat the sender', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MessageBubble(
            text: 'Continuação',
            isMine: false,
            senderName: 'Maria',
            isFirstInGroup: false,
          ),
        ),
      ),
    );
    expect(find.text('Maria'), findsNothing);
    expect(find.text('Continuação'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('failed outgoing messages expose a localized retry action', (
    tester,
  ) async {
    var retryCount = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(),
        home: Scaffold(
          body: MessageBubble(
            text: 'queued message',
            isMine: true,
            status: DeliveryStatus.failed,
            onRetry: () => retryCount++,
          ),
        ),
      ),
    );

    expect(
      find.byTooltip(AppLocalizationsPt().retrySendingMessage),
      findsOneWidget,
    );
    await tester.tap(find.byIcon(Icons.refresh_rounded));
    expect(retryCount, 1);
  });

  testWidgets('message bubbles render links and non-selectable code blocks', (
    tester,
  ) async {
    String? copiedText;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copiedText =
              (call.arguments as Map<Object?, Object?>)['text'] as String;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(),
        home: const Scaffold(
          body: Column(
            children: [
              MessageBubble(text: 'Visit https://example.com', isMine: false),
              MessageBubble(
                text: '```dart\nprint("hello");\n```',
                isMine: false,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.byType(SelectableText), findsNothing);
    expect(find.byTooltip(AppLocalizationsPt().copyCode), findsOneWidget);
    expect(find.text('print("hello");'), findsOneWidget);
    await tester.tap(find.byTooltip(AppLocalizationsPt().copyCode));
    expect(copiedText, 'print("hello");');
  });

  testWidgets('tapping a message reports its position for the popup menu', (
    tester,
  ) async {
    Offset? tapPosition;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MessageBubble(
            text: 'Open message actions',
            isMine: false,
            onTapAt: (position) => tapPosition = position,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open message actions'));

    expect(tapPosition, isNotNull);
  });
}
