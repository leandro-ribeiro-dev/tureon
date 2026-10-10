import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tureon/core/app/app_theme.dart';
import 'package:tureon/core/design_system/app_avatar.dart';
import 'package:tureon/core/protocol/recipient.dart';
import 'package:tureon/core/protocol/recipient_type.dart';
import 'package:tureon/core/storage/message_records.dart';
import 'package:tureon/features/chats/presentation/views/chat_screen.dart';
import 'package:tureon/features/chats/presentation/views/home_chats_screen.dart';
import 'package:tureon/features/contacts/presentation/views/contact_profile_screen.dart';
import 'package:tureon/features/home/presentation/home_view_model.dart';
import 'package:tureon/features/contacts/presentation/views/contacts_list_screen.dart';
import 'package:tureon/features/profile/presentation/views/edit_profile_screen.dart';
import 'package:tureon/features/profile/presentation/views/edit_field_screen.dart';
import 'package:tureon/features/profile/presentation/views/my_profile_screen.dart';
import 'package:tureon/features/profile/presentation/views/profile_view.dart';
import 'package:tureon/features/settings/presentation/views/settings_home_screen.dart';

void main() {
  const profile = UserProfile(
    userId: 'user-1',
    username: 'alice',
    displayName: 'Alice Example',
    avatarUrl: null,
  );
  const recipient = Recipient(
    id: 'user-2',
    type: RecipientType.user,
    name: 'Bob Example',
    handle: '@bob',
    avatarUrl: null,
  );

  testWidgets('AppAvatar uses initials for null and empty image URLs', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Row(
            children: [
              AppAvatar(name: 'Alice Example', imageUrl: null),
              AppAvatar(name: 'Bob Example', imageUrl: ''),
            ],
          ),
        ),
      ),
    );

    expect(find.text('AE'), findsOneWidget);
    expect(find.text('BE'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('profile image is clipped to the circular avatar bounds', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppAvatar(
            name: 'Alice Example',
            imageUrl: 'https://example.test/avatar.png',
          ),
        ),
      ),
    );

    expect(
      find.ancestor(of: find.byType(Image), matching: find.byType(ClipOval)),
      findsOneWidget,
    );
  });

  testWidgets('clearing the avatar in the editor persists an explicit null', (
    tester,
  ) async {
    UserProfile? savedProfile;
    await tester.pumpWidget(
      MaterialApp(
        home: EditFieldScreen(
          fieldType: ProfileFieldType.avatarUrl,
          currentUser: profile.copyWith(
            avatarUrl: 'https://example.test/avatar.png',
          ),
          onSave: (value) async {
            savedProfile = value;
            return value;
          },
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField), '');
    await tester.tap(find.byTooltip('Salvar'));
    await tester.pumpAndSettle();

    expect(savedProfile?.avatarUrl, isNull);
  });

  testWidgets('null avatar renders in profile, edit and own-profile screens', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(body: ProfileView(currentUser: profile)),
        ),
      ),
    );
    expect(find.byType(AppAvatar), findsWidgets);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: EditProfileScreen(
          currentUser: profile,
          onSave: (value) async => value,
        ),
      ),
    );
    expect(find.byType(AppAvatar), findsWidgets);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: MyProfileScreen(currentUser: profile, onOpenSettings: () {}),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(AppAvatar), findsWidgets);
    expect(find.byType(AppBar), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('null recipient avatar renders in contacts and chat list rows', (
    tester,
  ) async {
    final state = HomeState(recipients: [recipient]);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: ContactsListScreen(
          state: state,
          onSelectContact: (_) {},
          onViewContactProfile: (_) {},
        ),
      ),
    );
    expect(find.byType(AppAvatar), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: HomeChatsScreen(
          state: state,
          onSelectRecipient: (_) {},
          onOpenContactsTab: () {},
          onOpenSettings: () {},
        ),
      ),
    );
    expect(find.byType(AppAvatar), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'null recipient avatar renders in contact profile and chat header',
    (tester) async {
      final state = HomeState(recipients: [recipient]);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ContactProfileScreen(
            recipient: recipient,
            onBack: () {},
            onOpenChat: (_) {},
            onOpenSecretChat: (_) {},
          ),
        ),
      );
      expect(find.byType(AppAvatar), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: ChatScreen(
              state: state,
              recipient: recipient,
              onBack: () {},
              onViewProfile: (_) {},
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(AppAvatar), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('null avatar renders in settings profile surfaces', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: SettingsHomeScreen(currentUser: profile),
        ),
      ),
    );

    expect(find.byType(AppAvatar), findsWidgets);
    expect(tester.takeException(), isNull);

    expect(find.byType(SliverAppBar), findsNothing);
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.text('Configurações'), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
