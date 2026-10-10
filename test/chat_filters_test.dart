import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tureon/core/protocol/recipient.dart';
import 'package:tureon/core/protocol/recipient_type.dart';
import 'package:tureon/core/providers/settings_providers.dart';
import 'package:tureon/features/chats/presentation/views/home_chats_screen.dart';
import 'package:tureon/features/chats/presentation/widgets/chats_filter_chips.dart';
import 'package:tureon/features/home/presentation/home_view_model.dart';
import 'package:tureon/features/settings/presentation/views/chat_filters_settings_screen.dart';

void main() {
  group('ChatFilterTabsNotifier Unit Tests', () {
    test('defaultTabs contains built-in tabs and correct active defaults', () {
      final tabs = ChatFilterTabsNotifier.defaultTabs();
      expect(tabs.length, equals(6));
      expect(tabs[0].id, equals('all'));
      expect(tabs[0].isEnabled, isTrue);
      expect(tabs[1].id, equals('favorites'));
      expect(tabs[1].isEnabled, isTrue);
      expect(tabs[2].id, equals('unread'));
      expect(tabs[2].isEnabled, isTrue);
      expect(tabs[3].id, equals('groups'));
      expect(tabs[3].isEnabled, isTrue);
      expect(tabs[4].id, equals('channels'));
      expect(tabs[4].isEnabled, isTrue);
      expect(tabs[5].id, equals('contacts'));
      expect(tabs[5].isEnabled, isFalse);
    });

    test('toggleEnabled changes tab state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(chatFilterTabsProvider.notifier);
      expect(container.read(chatFilterTabsProvider)[0].isEnabled, isTrue);

      notifier.toggleEnabled('all', false);
      expect(container.read(chatFilterTabsProvider)[0].isEnabled, isFalse);
    });

    test('addTab, updateTab, removeTab, reorderTabs, resetToDefault work', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(chatFilterTabsProvider.notifier);
      const customTab = ChatFilterTab(
        id: 'custom_1',
        label: 'Trabalho',
        filterType: 'custom',
        isBuiltIn: false,
      );

      // Add
      notifier.addTab(customTab);
      expect(container.read(chatFilterTabsProvider).last.label, equals('Trabalho'));

      // Update
      notifier.updateTab(customTab.copyWith(label: 'Trabalho urgente'));
      expect(
        container.read(chatFilterTabsProvider).last.label,
        equals('Trabalho urgente'),
      );

      // Reorder
      notifier.reorderTabs(6, 0);
      expect(container.read(chatFilterTabsProvider).first.id, equals('custom_1'));

      // Remove
      notifier.removeTab('custom_1');
      expect(
        container.read(chatFilterTabsProvider).any((t) => t.id == 'custom_1'),
        isFalse,
      );

      // Reset
      notifier.resetToDefault();
      expect(container.read(chatFilterTabsProvider).length, equals(6));
    });
  });

  group('Chat Filters Widget Tests', () {
    testWidgets('ChatFiltersSettingsScreen renders tabs and options', (
      tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: ChatFiltersSettingsScreen()),
        ),
      );

      expect(find.text('Filtros e Abas de Conversa'), findsOneWidget);
      expect(find.text('Contador de não lidas nas abas'), findsOneWidget);
      expect(find.text('Tudo'), findsOneWidget);
      expect(find.text('Favoritos'), findsOneWidget);
      expect(find.text('Não lidas'), findsOneWidget);
      expect(find.text('Grupos'), findsOneWidget);
    });

    testWidgets('HomeChatsScreen displays only active filter tabs', (
      tester,
    ) async {
      const recipientGroup = Recipient(
        id: 'group_1',
        name: 'Grupo Devs',
        handle: '@grupo_devs',
        type: RecipientType.group,
        unreadCount: 2,
      );
      const recipientUser = Recipient(
        id: 'user_1',
        name: 'Alice',
        handle: '@alice',
        type: RecipientType.user,
        unreadCount: 0,
      );

      final homeState = HomeState(
        recipients: const [recipientGroup, recipientUser],
      );

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

      // Active tabs by default: Tudo, Favoritos, Não lidas, Grupos, Canais
      expect(find.byType(ChatsFilterChipsRow), findsOneWidget);
      expect(find.text('Tudo'), findsOneWidget);
      expect(find.text('Favoritos'), findsOneWidget);
      expect(find.text('Não lidas'), findsOneWidget);
      expect(find.text('Grupos'), findsOneWidget);
      expect(find.text('Canais'), findsOneWidget);

      // Inactive tab Privados should NOT appear by default
      expect(find.text('Privados'), findsNothing);

      // Both recipients visible in 'Tudo'
      expect(find.text('Grupo Devs'), findsOneWidget);
      expect(find.text('Alice'), findsOneWidget);

      // Tap on 'Grupos' chip
      await tester.tap(find.text('Grupos'));
      await tester.pumpAndSettle();

      // Only 'Grupo Devs' should be visible
      expect(find.text('Grupo Devs'), findsOneWidget);
      expect(find.text('Alice'), findsNothing);
    });

    testWidgets('HomeChatsScreen hides chips row when all tabs disabled', (
      tester,
    ) async {
      const recipientGroup = Recipient(
        id: 'group_1',
        name: 'Grupo Devs',
        handle: '@grupo_devs',
        type: RecipientType.group,
        unreadCount: 2,
      );

      final homeState = HomeState(
        recipients: const [recipientGroup],
      );

      // Pass all disabled tabs
      const disabledTabs = [
        ChatFilterTab(id: 'all', label: 'Tudo', filterType: 'all', isEnabled: false),
        ChatFilterTab(id: 'groups', label: 'Grupos', filterType: 'groups', isEnabled: false),
      ];

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: HomeChatsScreen(
              state: homeState,
              filterTabs: disabledTabs,
              onSelectRecipient: (_) {},
              onOpenContactsTab: () {},
              onOpenSettings: () {},
            ),
          ),
        ),
      );

      // Chips row MUST NOT be present at all
      expect(find.byType(ChatsFilterChipsRow), findsNothing);

      // Recipient is still rendered normally
      expect(find.text('Grupo Devs'), findsOneWidget);
    });
  });
}
