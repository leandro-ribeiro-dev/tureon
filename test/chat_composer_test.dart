import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tureon/core/protocol/recipient.dart';
import 'package:tureon/core/protocol/recipient_type.dart';
import 'package:tureon/features/chats/domain/chat_composer_state.dart';
import 'package:tureon/features/chats/presentation/controllers/chat_composer_notifier.dart';
import 'package:tureon/features/chats/presentation/controllers/chat_slow_mode_cooldown.dart';
import 'package:tureon/features/chats/presentation/widgets/chat_input_area.dart';
import 'package:tureon/features/home/domain/home_repository.dart';
import 'package:tureon/features/home/home_providers.dart';
import 'package:tureon/l10n/app_localizations.dart';

class _TestHomeRepository implements HomeRepository {
  _TestHomeRepository({this.initialRecipient});

  final Recipient? initialRecipient;
  final StreamController<Recipient?> _controller = StreamController.broadcast();
  bool cancelCalled = false;

  void emit(Recipient? recipient) => _controller.add(recipient);

  @override
  Stream<List<Recipient>> watchRecipients() => const Stream.empty();

  @override
  Stream<Recipient?> watchRecipient(String recipientId) {
    final initial = initialRecipient == null
        ? Stream<Recipient?>.empty()
        : Stream<Recipient?>.value(initialRecipient);

    return Stream.multi((sink) {
      final initialSub = initial.listen(
        sink.add,
        onError: sink.addError,
        onDone: () {},
      );
      final liveSub = _controller.stream.listen(
        sink.add,
        onError: sink.addError,
        onDone: sink.close,
      );

      sink.onCancel = () async {
        cancelCalled = true;
        await initialSub.cancel();
        await liveSub.cancel();
      };
    });
  }

  @override
  Set<String> loadPinnedConversationIds() => const {};

  @override
  Set<String> loadArchivedConversationIds() => const {};

  @override
  void savePinnedConversationIds(Set<String> recipientIds) {}

  @override
  void saveArchivedConversationIds(Set<String> recipientIds) {}

  @override
  Future<void> saveRecipient(Recipient recipient) async {}

  @override
  void deleteRecipient(String recipientId) {}
}

class _ActiveCooldownNotifier extends ChatSlowModeCooldownNotifier {
  _ActiveCooldownNotifier(this.seconds);

  final int seconds;

  @override
  Map<String, int> build() => {'group': seconds};
}

void main() {
  group('ChatComposerNotifier Unit Tests', () {
    test('initial state is disabled until the first recipient emission', () {
      final container = ProviderContainer(
        overrides: [
          homeRepositoryProvider.overrideWithValue(_TestHomeRepository()),
        ],
      );
      addTearDown(container.dispose);

      const params = ChatComposerParams(
        chatId: 'user-123',
        recipientType: RecipientType.user,
      );

      final notifier = container.read(chatComposerProvider(params).notifier);
      expect(notifier.state, isA<ComposerDisabled>());
    });

    test('official Tureon bot is read-only', () {
      final container = ProviderContainer(
        overrides: [
          homeRepositoryProvider.overrideWithValue(
            _TestHomeRepository(
              initialRecipient: const Recipient(
                id: 'f04a0000-0000-4000-8000-000000000002',
                type: RecipientType.bot,
                name: 'Tureon',
                handle: '@tureon_bot',
                canSendMessages: false,
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      const params = ChatComposerParams(
        chatId: 'f04a0000-0000-4000-8000-000000000002',
        recipientType: RecipientType.bot,
        isOfficialSystemBot: true,
      );
      final notifier = container.read(chatComposerProvider(params).notifier);
      notifier.updateRecipient(
        const Recipient(
          id: 'f04a0000-0000-4000-8000-000000000002',
          type: RecipientType.bot,
          name: 'Tureon',
          handle: '@tureon_bot',
          canSendMessages: false,
        ),
      );

      expect(notifier.state, isA<ComposerOfficialBotReadOnly>());
    });

    test('offline status does not disable writable conversation composers', () {
      for (final type in [
        RecipientType.user,
        RecipientType.group,
        RecipientType.channel,
        RecipientType.bot,
      ]) {
        final state = ChatComposerNotifier.computeState(
          ChatComposerParams(
            chatId: 'chat',
            recipientType: type,
            userRole: ChatUserRole.owner,
            hasExchangedMessages: true,
          ),
        );
        expect(state, isA<ComposerNormal>(), reason: '$type');
      }
    });

    test('a non-member sees the join action in group and channel previews', () {
      for (final type in [RecipientType.group, RecipientType.channel]) {
        final state = ChatComposerNotifier.computeState(
          ChatComposerParams(
            chatId: 'public-resource',
            recipientType: type,
            isMember: false,
          ),
        );
        expect(state, isA<ComposerJoinRequired>(), reason: '$type');
      }
    });

    test('composer params distinguish member and non-member previews', () {
      const preview = ChatComposerParams(
        chatId: 'public-group',
        recipientType: RecipientType.group,
        isMember: false,
      );
      const member = ChatComposerParams(
        chatId: 'public-group',
        recipientType: RecipientType.group,
        isMember: true,
      );

      expect(preview, isNot(member));
      expect(preview.hashCode, isNot(member.hashCode));
    });

    test(
      'null recipient closes the composer and errors keep the last state',
      () {
        final container = ProviderContainer(
          overrides: [
            homeRepositoryProvider.overrideWithValue(_TestHomeRepository()),
          ],
        );
        addTearDown(container.dispose);

        const params = ChatComposerParams(
          chatId: 'group-1',
          recipientType: RecipientType.group,
        );
        final notifier = container.read(chatComposerProvider(params).notifier);

        notifier.updateRecipient(
          const Recipient(
            id: 'group-1',
            type: RecipientType.group,
            name: 'Group',
            handle: '',
            canSendMessages: true,
          ),
        );
        expect(notifier.state, isA<ComposerNormal>());

        notifier.closeRecipient();
        expect(notifier.state, isA<ComposerDisabled>());

        notifier.updateRecipient(
          const Recipient(
            id: 'group-1',
            type: RecipientType.group,
            name: 'Group',
            handle: '',
            canSendMessages: true,
          ),
        );
        expect(notifier.state, isA<ComposerNormal>());

        notifier.handleStreamError(StateError('boom'), StackTrace.empty);
        expect(notifier.state, isA<ComposerNormal>());
      },
    );

    test(
      'returns channelReadOnly state when user is regular member in channel',
      () {
        final container = ProviderContainer(
          overrides: [
            homeRepositoryProvider.overrideWithValue(_TestHomeRepository()),
          ],
        );
        addTearDown(container.dispose);

        const params = ChatComposerParams(
          chatId: 'channel-1',
          recipientType: RecipientType.channel,
        );
        final notifier = container.read(chatComposerProvider(params).notifier);

        notifier.updateRecipient(
          const Recipient(
            id: 'channel-1',
            type: RecipientType.channel,
            name: 'Channel',
            handle: '',
            composerRole: 'member',
          ),
        );

        expect(notifier.state, isA<ComposerChannelReadOnly>());
      },
    );

    test('returns normal state when user is admin or owner in channel', () {
      final adminContainer = ProviderContainer(
        overrides: [
          homeRepositoryProvider.overrideWithValue(_TestHomeRepository()),
        ],
      );
      addTearDown(adminContainer.dispose);

      const adminParams = ChatComposerParams(
        chatId: 'channel-1',
        recipientType: RecipientType.channel,
      );
      final adminNotifier = adminContainer.read(
        chatComposerProvider(adminParams).notifier,
      );
      adminNotifier.updateRecipient(
        const Recipient(
          id: 'channel-1',
          type: RecipientType.channel,
          name: 'Channel',
          handle: '',
          composerRole: 'admin',
        ),
      );
      expect(adminNotifier.state, isA<ComposerNormal>());

      final ownerContainer = ProviderContainer(
        overrides: [
          homeRepositoryProvider.overrideWithValue(_TestHomeRepository()),
        ],
      );
      addTearDown(ownerContainer.dispose);

      const ownerParams = ChatComposerParams(
        chatId: 'channel-2',
        recipientType: RecipientType.channel,
      );
      final ownerNotifier = ownerContainer.read(
        chatComposerProvider(ownerParams).notifier,
      );
      ownerNotifier.updateRecipient(
        const Recipient(
          id: 'channel-2',
          type: RecipientType.channel,
          name: 'Channel',
          handle: '',
          composerRole: 'owner',
        ),
      );
      expect(ownerNotifier.state, isA<ComposerNormal>());
    });

    test(
      'returns restrictedInGroup when group permissions disable member sending',
      () {
        final container = ProviderContainer(
          overrides: [
            homeRepositoryProvider.overrideWithValue(_TestHomeRepository()),
          ],
        );
        addTearDown(container.dispose);

        const params = ChatComposerParams(
          chatId: 'group-1',
          recipientType: RecipientType.group,
        );
        final notifier = container.read(chatComposerProvider(params).notifier);
        notifier.updateRecipient(
          const Recipient(
            id: 'group-1',
            type: RecipientType.group,
            name: 'Group',
            handle: '',
            canSendMessages: false,
          ),
        );

        expect(notifier.state, isA<ComposerRestricted>());
      },
    );

    test(
      'returns restrictedInGroup with until date when user is restricted until a timestamp',
      () {
        final container = ProviderContainer(
          overrides: [
            homeRepositoryProvider.overrideWithValue(_TestHomeRepository()),
          ],
        );
        addTearDown(container.dispose);

        const params = ChatComposerParams(
          chatId: 'group-1',
          recipientType: RecipientType.group,
        );
        final notifier = container.read(chatComposerProvider(params).notifier);
        final futureDate = DateTime.now().add(const Duration(hours: 2));

        notifier.updateRecipient(
          Recipient(
            id: 'group-1',
            type: RecipientType.group,
            name: 'Group',
            handle: '',
            canSendMessages: true,
            restrictedUntil: futureDate,
          ),
        );

        final state = notifier.state;
        expect(state, isA<ComposerRestricted>());
        expect((state as ComposerRestricted).until, equals(futureDate));
      },
    );

    test('updates composer permissions from a live recipient snapshot', () {
      final container = ProviderContainer(
        overrides: [
          homeRepositoryProvider.overrideWithValue(_TestHomeRepository()),
        ],
      );
      addTearDown(container.dispose);

      const params = ChatComposerParams(
        chatId: 'group-1',
        recipientType: RecipientType.group,
      );
      final notifier = container.read(chatComposerProvider(params).notifier);

      notifier.updateRecipient(
        const Recipient(
          id: 'group-1',
          type: RecipientType.group,
          name: 'Group',
          handle: '',
          canSendMessages: false,
        ),
      );
      expect(notifier.state, isA<ComposerRestricted>());

      notifier.updateRecipient(
        Recipient(
          id: 'group-1',
          type: RecipientType.group,
          name: 'Group',
          handle: '',
          canSendMessages: true,
          restrictedUntil: DateTime.now().add(const Duration(hours: 1)),
        ),
      );
      expect(notifier.state, isA<ComposerRestricted>());

      notifier.updateRecipient(
        const Recipient(
          id: 'group-1',
          type: RecipientType.group,
          name: 'Group',
          handle: '',
          canSendMessages: true,
        ),
      );
      expect(notifier.state, isA<ComposerNormal>());
    });

    test('returns moderationBlocked when account moderation is active', () {
      final container = ProviderContainer(
        overrides: [
          homeRepositoryProvider.overrideWithValue(_TestHomeRepository()),
        ],
      );
      addTearDown(container.dispose);

      const params = ChatComposerParams(
        chatId: 'user-123',
        recipientType: RecipientType.user,
      );
      final notifier = container.read(chatComposerProvider(params).notifier);
      notifier.updateRecipient(
        const Recipient(
          id: 'user-123',
          type: RecipientType.user,
          name: 'User',
          handle: '@user',
          canSendMessages: true,
        ),
      );
      notifier.updateParams(moderationReason: ModerationReason.rateLimited);

      final state = notifier.state;
      expect(state, isA<ComposerModerationBlocked>());
      expect(
        (state as ComposerModerationBlocked).reason,
        equals(ModerationReason.rateLimited),
      );
    });

    test(
      'bot chat starts in botNeedsStart state when no messages exchanged',
      () {
        final container = ProviderContainer(
          overrides: [
            homeRepositoryProvider.overrideWithValue(_TestHomeRepository()),
          ],
        );
        addTearDown(container.dispose);

        const params = ChatComposerParams(
          chatId: 'bot-helper',
          recipientType: RecipientType.bot,
        );
        final notifier = container.read(chatComposerProvider(params).notifier);
        notifier.updateRecipient(
          const Recipient(
            id: 'bot-helper',
            type: RecipientType.bot,
            name: 'Helper Bot',
            handle: '@helperbot',
            canSendMessages: true,
          ),
        );
        notifier.updateParams(
          hasExchangedMessages: false,
          hasLastMessage: false,
        );

        expect(notifier.state, isA<ComposerBotNeedsStart>());
      },
    );

    test(
      'bot chat transitions from botNeedsStart to normal after first /start message',
      () {
        final container = ProviderContainer(
          overrides: [
            homeRepositoryProvider.overrideWithValue(_TestHomeRepository()),
          ],
        );
        addTearDown(container.dispose);

        const params = ChatComposerParams(
          chatId: 'bot-helper',
          recipientType: RecipientType.bot,
        );
        final notifier = container.read(chatComposerProvider(params).notifier);
        notifier.updateRecipient(
          const Recipient(
            id: 'bot-helper',
            type: RecipientType.bot,
            name: 'Helper Bot',
            handle: '@helperbot',
            canSendMessages: true,
          ),
        );
        notifier.updateParams(
          hasExchangedMessages: false,
          hasLastMessage: false,
        );

        expect(notifier.state, isA<ComposerBotNeedsStart>());

        notifier.markMessageExchanged();
        expect(notifier.state, isA<ComposerNormal>());
      },
    );

    test('bot chat with existing lastMessage directly enters normal state', () {
      final container = ProviderContainer(
        overrides: [
          homeRepositoryProvider.overrideWithValue(_TestHomeRepository()),
        ],
      );
      addTearDown(container.dispose);

      const params = ChatComposerParams(
        chatId: 'bot-guarda',
        recipientType: RecipientType.bot,
      );
      final notifier = container.read(chatComposerProvider(params).notifier);
      notifier.updateRecipient(
        const Recipient(
          id: 'bot-guarda',
          type: RecipientType.bot,
          name: 'Guarda Bot',
          handle: '@guardabot',
          canSendMessages: true,
        ),
      );
      notifier.updateParams(hasLastMessage: true);

      expect(notifier.state, isA<ComposerNormal>());
    });
  });

  group('Provider lifecycle tests', () {
    test('dispose cancels the active watchRecipient subscription', () {
      final repository = _TestHomeRepository();
      final container = ProviderContainer(
        overrides: [homeRepositoryProvider.overrideWithValue(repository)],
      );

      const params = ChatComposerParams(
        chatId: 'dispose-chat',
        recipientType: RecipientType.user,
      );

      container.read(chatComposerProvider(params));
      expect(repository.cancelCalled, isFalse);

      container.dispose();
      expect(repository.cancelCalled, isTrue);
    });
  });

  group('ChatInputArea Widget Tests', () {
    Widget createWidgetUnderTest(
      ChatComposerParams composerParams, {
      VoidCallback? onStartBot,
      VoidCallback? onSendMessage,
      VoidCallback? onCancelEdit,
      VoidCallback? onJoin,
      bool isEditing = false,
      bool isJoining = false,
      Recipient? recipientOverride,
      int? slowModeRemainingSeconds,
    }) {
      final repository = _TestHomeRepository(
        initialRecipient:
            recipientOverride ??
            const Recipient(
              id: 'direct',
              type: RecipientType.user,
              name: 'Direct',
              handle: '@direct',
              canSendMessages: true,
            ),
      );
      return ProviderScope(
        overrides: [
          homeRepositoryProvider.overrideWithValue(repository),
          if (slowModeRemainingSeconds != null)
            chatSlowModeCooldownProvider.overrideWith(
              () => _ActiveCooldownNotifier(slowModeRemainingSeconds),
            ),
        ],
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('pt'),
          theme: ThemeData.dark(),
          home: Scaffold(
            body: ChatInputArea(
              composerParams: composerParams,
              textController: TextEditingController(),
              onSendMessage: onSendMessage ?? () {},
              onStartBot: onStartBot ?? () {},
              onAttachmentPressed: () {},
              isEditing: isEditing,
              onCancelEdit: onCancelEdit,
              onJoin: onJoin,
              isJoining: isJoining,
            ),
          ),
        ),
      );
    }

    testWidgets('renders input field in normal state', (tester) async {
      await tester.pumpWidget(
        createWidgetUnderTest(
          const ChatComposerParams(
            chatId: 'direct',
            recipientType: RecipientType.user,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Escreva uma mensagem...'), findsOneWidget);
      final input = tester.widget<TextField>(find.byType(TextField));
      expect(input.maxLength, ChatInputArea.maxMessageLength);
      expect(input.maxLines, 5);
      expect(input.minLines, 1);
    });

    testWidgets('hides the text input during group slow-mode countdown', (
      tester,
    ) async {
      await tester.pumpWidget(
        createWidgetUnderTest(
          const ChatComposerParams(
            chatId: 'group',
            recipientType: RecipientType.group,
          ),
          slowModeRemainingSeconds: 25,
          recipientOverride: const Recipient(
            id: 'group',
            type: RecipientType.group,
            name: 'Group',
            handle: '@group',
            canSendMessages: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsNothing);
      expect(
        find.text('Você poderá enviar novamente em 25 s.'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.hourglass_top_rounded), findsOneWidget);
    });

    testWidgets('shows the matching join action for a public preview', (
      tester,
    ) async {
      var joined = false;
      await tester.pumpWidget(
        createWidgetUnderTest(
          const ChatComposerParams(
            chatId: 'public-group',
            recipientType: RecipientType.group,
            isMember: false,
          ),
          onJoin: () => joined = true,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Entrar no grupo'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
      await tester.tap(find.text('Entrar no grupo'));
      expect(joined, isTrue);
    });

    testWidgets('composer fills the width with square outer edges', (
      tester,
    ) async {
      await tester.pumpWidget(
        createWidgetUnderTest(
          const ChatComposerParams(
            chatId: 'direct',
            recipientType: RecipientType.user,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final paddings = tester.widgetList<Padding>(find.byType(Padding));
      expect(
        paddings.any(
          (padding) => padding.padding == const EdgeInsets.only(top: 4),
        ),
        isTrue,
      );
      expect(tester.getSize(find.byType(ChatInputArea)).width, 800);
    });

    testWidgets('edits a message in the composer and exposes cancel action', (
      tester,
    ) async {
      var cancelled = false;
      await tester.pumpWidget(
        createWidgetUnderTest(
          const ChatComposerParams(
            chatId: 'direct',
            recipientType: RecipientType.user,
          ),
          isEditing: true,
          onCancelEdit: () => cancelled = true,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Editando mensagem'), findsOneWidget);
      expect(find.byTooltip('Salvar edição'), findsOneWidget);
      expect(find.byTooltip('Cancelar edição'), findsOneWidget);
      expect(find.byTooltip('Adicionar anexo'), findsNothing);

      await tester.tap(find.byTooltip('Cancelar edição'));
      expect(cancelled, isTrue);
    });

    testWidgets('renders channel read-only notice in channelReadOnly state', (
      tester,
    ) async {
      await tester.pumpWidget(
        createWidgetUnderTest(
          const ChatComposerParams(
            chatId: 'channel',
            recipientType: RecipientType.channel,
          ),
          recipientOverride: const Recipient(
            id: 'channel',
            type: RecipientType.channel,
            name: 'Channel',
            handle: '@channel',
            composerRole: 'member',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsNothing);
      expect(
        find.text('Só administradores podem publicar neste canal.'),
        findsOneWidget,
      );
    });

    testWidgets('renders group restriction notice in restrictedInGroup state', (
      tester,
    ) async {
      await tester.pumpWidget(
        createWidgetUnderTest(
          const ChatComposerParams(
            chatId: 'group',
            recipientType: RecipientType.group,
          ),
          recipientOverride: const Recipient(
            id: 'group',
            type: RecipientType.group,
            name: 'Group',
            handle: '@group',
            canSendMessages: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsNothing);
      expect(
        find.text('Você foi restrito de enviar mensagens neste grupo.'),
        findsOneWidget,
      );
    });
  });
}
