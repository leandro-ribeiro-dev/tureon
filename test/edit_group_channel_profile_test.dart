import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tureon/core/protocol/recipient.dart';
import 'package:tureon/core/protocol/recipient_type.dart';
import 'package:tureon/features/contacts/presentation/views/contact_profile_screen.dart';
import 'package:tureon/features/home/domain/home_repository.dart';
import 'package:tureon/features/home/home_providers.dart';

void main() {
  group('Edit Group/Channel Profile Tests', () {
    testWidgets(
      'Displays Edit icon button for Group Owner/Admin in ProfileHeaderCard',
      (tester) async {
        const groupOwner = Recipient(
          id: 'group-1',
          type: RecipientType.group,
          name: 'Grupo Devs',
          handle: '@grupodevs',
          composerRole: 'owner',
        );

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: ContactProfileScreen(
                recipient: groupOwner,
                onBack: () {},
                onOpenChat: (_) {},
                onOpenSecretChat: (_) {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Edit icon visible for owner
        expect(find.byIcon(Icons.edit_outlined), findsOneWidget);

        // Tap edit button to open EditGroupChannelProfileScreen
        await tester.tap(find.byIcon(Icons.edit_outlined));
        await tester.pumpAndSettle();

        expect(find.text('Editar Grupo'), findsOneWidget);
        expect(find.text('Nome do Grupo'), findsOneWidget);
      },
    );

    testWidgets('Hides Edit icon button for regular Group/Channel members', (
      tester,
    ) async {
      const groupMember = Recipient(
        id: 'group-2',
        type: RecipientType.group,
        name: 'Grupo Publico',
        handle: '@grupopublico',
        composerRole: 'member',
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ContactProfileScreen(
              recipient: groupMember,
              onBack: () {},
              onOpenChat: (_) {},
              onOpenSecretChat: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Edit icon hidden for regular member
      expect(find.byIcon(Icons.edit_outlined), findsNothing);
    });

    testWidgets('updates the member total when the room snapshot advances', (
      tester,
    ) async {
      final repository = _TestHomeRepository();
      const group = Recipient(
        id: 'group-live-count',
        type: RecipientType.group,
        name: 'Grupo ao vivo',
        handle: '@grupo',
        memberCount: 2,
        roomVersion: 1,
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [homeRepositoryProvider.overrideWithValue(repository)],
          child: MaterialApp(
            home: ContactProfileScreen(
              recipientId: group.id,
              recipient: group,
              onBack: () {},
              onOpenChat: (_) {},
              onOpenSecretChat: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('2 participantes'), findsOneWidget);

      repository.recipientUpdates.add(
        group.copyWith(memberCount: 3, roomVersion: 2),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('3 participantes'), findsOneWidget);
      await repository.dispose();
    });
  });
}

class _TestHomeRepository implements HomeRepository {
  final recipientUpdates = StreamController<Recipient?>.broadcast();

  @override
  Stream<List<Recipient>> watchRecipients() => const Stream.empty();

  @override
  Stream<Recipient?> watchRecipient(String recipientId) =>
      recipientUpdates.stream;

  @override
  Set<String> loadPinnedConversationIds() => <String>{};

  @override
  Set<String> loadArchivedConversationIds() => <String>{};

  @override
  void savePinnedConversationIds(Set<String> recipientIds) {}

  @override
  void saveArchivedConversationIds(Set<String> recipientIds) {}

  @override
  Future<void> saveRecipient(Recipient recipient) async {}

  @override
  void deleteRecipient(String recipientId) {}

  Future<void> dispose() => recipientUpdates.close();
}
