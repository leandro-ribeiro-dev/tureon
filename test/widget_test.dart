import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tureon/core/app/app_state.dart';
import 'package:tureon/core/app/app_theme.dart';
import 'package:tureon/core/app/connection_status.dart';
import 'package:tureon/core/design_system/app_avatar.dart';
import 'package:tureon/core/design_system/verified_name.dart';
import 'package:tureon/core/protocol/recipient.dart';
import 'package:tureon/core/protocol/recipient_type.dart';
import 'package:tureon/core/protocol/verification_badge.dart';
import 'package:tureon/core/providers/profile_providers.dart';
import 'package:tureon/core/providers/settings_providers.dart';
import 'package:tureon/core/storage/message_records.dart';
import 'package:tureon/core/storage/local_store.dart';
import 'package:tureon/core/validation/username_feedback.dart';
import 'package:tureon/features/profile/data/profile_repository.dart';
import 'package:tureon/features/settings/domain/settings_entry.dart';
import 'package:tureon/features/settings/presentation/views/settings_section_screen.dart';
import 'package:tureon/features/settings/presentation/views/settings_home_screen.dart';
import 'package:tureon/features/contacts/presentation/views/contact_profile_screen.dart';
import 'package:tureon/features/contacts/presentation/views/contacts_list_screen.dart';
import 'package:tureon/features/chats/presentation/views/home_chats_screen.dart';
import 'package:tureon/features/profile/presentation/views/edit_field_screen.dart';
import 'package:tureon/features/profile/presentation/views/my_profile_screen.dart';
import 'package:tureon/features/profile/presentation/views/appearance_view.dart';
import 'package:tureon/features/home/presentation/home_view_model.dart';
import 'package:tureon/features/home/presentation/views/home_page.dart';
import 'package:tureon/features/home/presentation/widgets/account_status_banner.dart';
import 'package:tureon/main.dart';
import 'package:tureon/l10n/app_localizations.dart';

void main() {
  testWidgets('home chats shows and updates the account status banner', (
    tester,
  ) async {
    final sessions = StreamController<UserSession?>.broadcast(sync: true);
    addTearDown(sessions.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          activeSessionProvider.overrideWith((ref) => sessions.stream),
        ],
        child: MaterialApp(
          home: HomeChatsScreen(
            state: HomeState(),
            onSelectRecipient: (_) {},
            onOpenContactsTab: () {},
            onOpenSettings: () {},
          ),
        ),
      ),
    );

    sessions.add(
      const UserSession(
        userId: 'user-1',
        deviceId: 'device-1',
        accountStatus: 'under_review',
      ),
    );
    await tester.pump();

    expect(find.text('Conta sob análise'), findsOneWidget);
    final banner = tester.widget<MaterialBanner>(find.byType(MaterialBanner));
    expect(banner.backgroundColor, ThemeData().colorScheme.tertiaryContainer);
    expect(
      tester.getTopLeft(find.byType(AccountStatusBanner)).dy,
      lessThan(tester.getTopLeft(find.byType(ListView).first).dy),
    );

    sessions.add(
      const UserSession(
        userId: 'user-1',
        deviceId: 'device-1',
        accountStatus: 'restricted',
      ),
    );
    await tester.pump();

    expect(find.text('Conta com restrições'), findsOneWidget);
    expect(find.text('Conta sob análise'), findsNothing);
  });

  testWidgets('renders the Tureon workspace without demo account data', (
    tester,
  ) async {
    await tester.pumpWidget(const TureonApp());

    expect(find.text('Desconectado'), findsOneWidget);
    expect(find.text('Forja'), findsNothing);
    expect(
      find.text(
        'Olá! Eu sou a Forja. Envie /start para começar a criar seu bot.',
      ),
      findsNothing,
    );
    expect(find.text('Conversas'), findsOneWidget);
    expect(find.text('Contatos'), findsOneWidget);
    expect(find.text('Perfil'), findsOneWidget);
  });

  testWidgets(
    'tapping a username search result opens the chat without crashing',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: HomePage(
              searchUsers: (query) async => const [
                Recipient(
                  id: 'user-42',
                  type: RecipientType.user,
                  name: 'Alice',
                  handle: '@alice',
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.text('Pesquisar conversas...'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'al');
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.tap(find.text('Alice').last);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Nenhuma mensagem nesta conversa.'), findsOneWidget);
    },
  );

  test('starts with no server-provided demo recipients or messages', () {
    final state = AppState();

    expect(state.recipients, isEmpty);
    expect(state.messages, isEmpty);
  });

  test('uses the default Material 3 themes for light and dark modes', () {
    final light = AppTheme.lightTheme;
    final dark = AppTheme.darkTheme;

    expect(light.useMaterial3, isTrue);
    expect(light.brightness, Brightness.light);
    expect(dark.brightness, Brightness.dark);
    expect(
      light.colorScheme,
      ColorScheme.fromSeed(
        seedColor: AppTheme.primaryColor,
        brightness: Brightness.light,
      ),
    );
    expect(
      dark.colorScheme,
      ColorScheme.fromSeed(
        seedColor: AppTheme.primaryColor,
        brightness: Brightness.dark,
      ),
    );
  });

  testWidgets('appearance screen switches between standard theme modes', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const AppearanceView(),
        ),
      ),
    );

    await tester.tap(find.text('Noite'));
    expect(container.read(appThemeModeProvider), ThemeMode.dark);
  });

  testWidgets('username field validates and saves through profile editor', (
    tester,
  ) async {
    UserProfile? savedProfile;
    await tester.pumpWidget(
      MaterialApp(
        home: EditFieldScreen(
          fieldType: ProfileFieldType.username,
          currentUser: const UserProfile(
            userId: 'user-1',
            username: 'old_name',
            displayName: 'Test User',
          ),
          onSave: (profile) async {
            savedProfile = profile;
            return profile;
          },
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField), 'abcd');
    await tester.tap(find.byTooltip('Salvar'));
    await tester.pump();
    expect(savedProfile, isNull);
    expect(find.text(UsernameFeedback.invalidFormatMessage), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'new_name');
    await tester.tap(find.byTooltip('Salvar'));
    await tester.pumpAndSettle();

    expect(savedProfile?.username, 'new_name');
  });

  testWidgets('recipient verification badges render for any recipient type', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppAvatar.fromRecipient(
            const Recipient(
              id: 'channel-1',
              type: RecipientType.channel,
              name: 'Canal oficial',
              handle: '',
              verificationBadge: VerificationBadge.celebrity,
            ),
          ),
        ),
      ),
    );

    expect(find.byTooltip('Celebridade'), findsOneWidget);
    expect(find.byIcon(Icons.stars_rounded), findsOneWidget);
  });

  testWidgets('verification badges render inline with names', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              VerifiedName(name: 'Verified', badge: VerificationBadge.verified),
              VerifiedName(
                name: 'Developer',
                badge: VerificationBadge.developer,
              ),
              VerifiedName(
                name: 'Celebrity',
                badge: VerificationBadge.celebrity,
              ),
              VerifiedName(name: 'Regular', badge: VerificationBadge.none),
            ],
          ),
        ),
      ),
    );

    expect(find.byTooltip('Verificado'), findsOneWidget);
    expect(find.byTooltip('Desenvolvedor'), findsOneWidget);
    expect(find.byTooltip('Celebridade'), findsOneWidget);
    expect(find.text('Regular'), findsOneWidget);
    expect(find.byIcon(Icons.verified_rounded), findsOneWidget);
    expect(find.byIcon(Icons.code_rounded), findsOneWidget);
    expect(find.byIcon(Icons.stars_rounded), findsOneWidget);
  });

  testWidgets('tapping a name badge explains that badge', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: VerifiedName(
            name: 'Developer',
            badge: VerificationBadge.developer,
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Desenvolvedor'));
    await tester.pumpAndSettle();

    expect(find.text('Selo desenvolvedor'), findsOneWidget);
    expect(
      find.textContaining('participante do desenvolvimento'),
      findsOneWidget,
    );
    expect(
      find.textContaining('não podem ser escolhidos ou alterados'),
      findsOneWidget,
    );
    await tester.tap(find.text('Entendi'));
    await tester.pumpAndSettle();
    expect(find.text('Selo desenvolvedor'), findsNothing);
  });

  testWidgets('tapping an avatar badge explains its verification type', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppAvatar(
            name: 'Canal oficial',
            type: RecipientType.channel,
            verificationBadge: VerificationBadge.celebrity,
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Celebridade'));
    await tester.pumpAndSettle();

    expect(find.text('Selo celebridade'), findsOneWidget);
    expect(find.textContaining('figura pública'), findsOneWidget);
  });

  testWidgets('renders newly registered settings entries generically', (
    tester,
  ) async {
    const section = SettingsSection(
      id: 'maintenance_test',
      titleKey: 'Teste de manutenção',
      entries: [
        SettingsEntry(
          id: 'future_setting',
          icon: Icons.tune_rounded,
          titleKey: 'Nova preferência',
          subtitleKey: 'Incluída somente como dado',
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(home: SettingsSectionScreen(section: section)),
      ),
    );

    expect(find.text('Nova preferência'), findsOneWidget);
    expect(find.text('Incluída somente como dado'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(ListTile),
        matching: find.byType(BackdropFilter),
      ),
      findsNothing,
    );
  });

  testWidgets('Material Card uses the standard surface without blur', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Card(child: Text('surface'))),
      ),
    );

    expect(find.byType(Card), findsOneWidget);
    expect(find.byType(BackdropFilter), findsNothing);
    expect(find.byType(Material), findsWidgets);
  });

  testWidgets('bottom navigation uses the Material 3 three-tab bar', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            bottomNavigationBar: NavigationBar(
              selectedIndex: 0,
              onDestinationSelected: _ignoreIndex,
              destinations: [
                NavigationDestination(
                  icon: Icon(Icons.chat_bubble_outline_rounded),
                  label: 'Chats',
                ),
                NavigationDestination(
                  icon: Icon(Icons.people_outline_rounded),
                  label: 'Contatos',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline_rounded),
                  label: 'Perfil',
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(BackdropFilter), findsNothing);
    expect(find.text('Chats'), findsOneWidget);
    expect(find.text('Contatos'), findsOneWidget);
    expect(find.text('Perfil'), findsOneWidget);
  });

  testWidgets('hides contact profile fields without explicit privacy access', (
    tester,
  ) async {
    const recipient = Recipient(
      id: 'private-contact',
      type: RecipientType.user,
      name: 'Contato Privado',
      handle: '@privado',
    );

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ContactProfileScreen(
            recipient: recipient,
            onBack: _noop,
            onOpenChat: _ignoreRecipient,
            onOpenSecretChat: _ignoreRecipient,
          ),
        ),
      ),
    );

    expect(find.text('@privado'), findsNothing);
    expect(find.text('Bio'), findsNothing);
    expect(find.text('Número de telefone'), findsNothing);
    expect(find.text('Data de nascimento'), findsNothing);
  });

  testWidgets('group and bot profiles expose only matching actions', (
    tester,
  ) async {
    const group = Recipient(
      id: 'group-profile',
      type: RecipientType.group,
      name: 'Equipe',
      handle: '@equipe',
    );
    const bot = Recipient(
      id: 'bot-profile',
      type: RecipientType.bot,
      name: 'Assistente',
      handle: '@assistente',
    );

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ContactProfileScreen(
            recipient: group,
            onBack: _noop,
            onOpenChat: _ignoreRecipient,
            onOpenSecretChat: _ignoreRecipient,
          ),
        ),
      ),
    );
    expect(find.text('Perfil do grupo'), findsOneWidget);
    expect(find.text('Iniciar chat secreto'), findsNothing);
    expect(find.text('Conecte-se para ver os participantes.'), findsOneWidget);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ContactProfileScreen(
            key: ValueKey('bot-profile-screen'),
            recipient: bot,
            onBack: _noop,
            onOpenChat: _ignoreRecipient,
            onOpenSecretChat: _ignoreRecipient,
          ),
        ),
      ),
    );
    expect(find.text('Perfil do bot'), findsOneWidget);
    expect(find.text('Bot'), findsOneWidget);
    expect(find.text('Enviar mensagem'), findsOneWidget);
    expect(find.text('Iniciar chat secreto'), findsNothing);
  });

  testWidgets('contacts hide handles and presence without permission flags', (
    tester,
  ) async {
    final state = HomeState();

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: ContactsListScreen(
            state: state,
            onSelectContact: (_) {},
            onViewContactProfile: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('@leomartins'), findsNothing);
    expect(find.text('online'), findsNothing);
  });

  testWidgets('conversation list uses flat rows and has no floating button', (
    tester,
  ) async {
    final state = HomeState(
      recipients: [
        Recipient(
          id: 'conversation-test',
          type: RecipientType.user,
          name: 'Contato de teste',
          handle: '@teste',
          lastMessage: 'Última mensagem',
          unreadCount: 2,
        ),
      ],
    );
    await tester.pumpWidget(
      MaterialApp(
        home: HomeChatsScreen(
          state: state,
          onSelectRecipient: _ignoreRecipient,
          onOpenContactsTab: _noop,
          onOpenSettings: _noop,
        ),
      ),
    );

    expect(find.text('Tureon'), findsOneWidget);
    expect(find.text('Contato de teste'), findsOneWidget);
    expect(find.text('Última mensagem'), findsOneWidget);
    expect(find.byType(ListTile), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsNothing);
    expect(find.byType(ListTile), findsOneWidget);
  });

  testWidgets('selecting a username result opens its direct chat', (
    tester,
  ) async {
    const recipient = Recipient(
      id: 'maria-user-id',
      type: RecipientType.user,
      name: 'Maria',
      handle: '@maria',
      isUsernameVisible: true,
    );
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: HomePage(searchUsers: (_) async => const [recipient]),
        ),
      ),
    );

    await tester.tap(find.text('Pesquisar conversas...'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'maria');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();
    expect(find.text('@maria'), findsOneWidget);

    await tester.tap(
      find.ancestor(of: find.text('@maria'), matching: find.byType(ListTile)),
    );
    await tester.pumpAndSettle();

    expect(find.byTooltip('Voltar para conversas'), findsOneWidget);
    expect(find.text('Maria'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('debounces username search and reuses a recent cached query', (
    tester,
  ) async {
    var searchCalls = 0;
    final state = HomeState();

    await tester.pumpWidget(
      MaterialApp(
        home: HomeChatsScreen(
          state: state,
          onSelectRecipient: _ignoreRecipient,
          onSearchUsers: (_) async {
            searchCalls++;
            return const [
              Recipient(
                id: 'cached-user',
                type: RecipientType.user,
                name: 'Cached User',
                handle: '@cached',
              ),
            ];
          },
          onOpenContactsTab: _noop,
          onOpenSettings: _noop,
        ),
      ),
    );

    await tester.tap(find.text('Pesquisar conversas...'));
    await tester.pumpAndSettle();
    final searchInput = find.byType(TextField);
    await tester.enterText(searchInput, 'ca');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.enterText(searchInput, 'cac');
    await tester.pump(const Duration(milliseconds: 299));
    expect(searchCalls, 0);
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pumpAndSettle();
    expect(searchCalls, 1);
    expect(find.text('Cached User'), findsOneWidget);

    await tester.enterText(searchInput, '');
    await tester.pump();
    await tester.enterText(searchInput, 'cac');
    await tester.pumpAndSettle();
    expect(searchCalls, 1);
    expect(find.text('Cached User'), findsOneWidget);
  });

  testWidgets('search shows public groups and channels as joinable results', (
    tester,
  ) async {
    for (final type in [RecipientType.group, RecipientType.channel]) {
      Recipient? selected;
      final resource = Recipient(
        id: type.name,
        type: type,
        name: type == RecipientType.group ? 'Public Group' : 'Public Channel',
        handle: type == RecipientType.group ? 'Grupo público' : 'Canal público',
        description: 'Public resource description',
        isMember: false,
      );
      await tester.pumpWidget(
        MaterialApp(
          home: HomeChatsScreen(
            state: HomeState(),
            onSelectRecipient: (recipient) => selected = recipient,
            onSearchPublicGroupChannels: (_) async => [resource],
            onOpenContactsTab: _noop,
            onOpenSettings: _noop,
          ),
        ),
      );

      await tester.tap(find.text('Pesquisar conversas...'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Public');
      await tester.pump(const Duration(milliseconds: 301));
      await tester.pumpAndSettle();

      expect(find.text('Entrar'), findsOneWidget);
      expect(find.text(resource.name), findsOneWidget);
      await tester.tap(find.text('Entrar'));
      expect(selected?.id, resource.id);
    }
  });

  testWidgets(
    'conversation toolbar shows status and app name only when ready',
    (tester) async {
      final state = HomeState();
      Widget buildScreen(ConnectionStatus status) => MaterialApp(
        home: HomeChatsScreen(
          state: state,
          connectionStatus: status,
          onSelectRecipient: _ignoreRecipient,
          onOpenContactsTab: _noop,
          onOpenSettings: _noop,
        ),
      );

      await tester.pumpWidget(buildScreen(ConnectionStatus.disconnected));
      expect(find.text('Desconectado'), findsOneWidget);
      expect(find.text('Tureon'), findsNothing);

      await tester.pumpWidget(buildScreen(ConnectionStatus.connecting));
      expect(find.text('Conectando...'), findsOneWidget);

      await tester.pumpWidget(buildScreen(ConnectionStatus.reconnecting));
      expect(find.text('Reconectando...'), findsOneWidget);

      await tester.pumpWidget(buildScreen(ConnectionStatus.authenticating));
      expect(find.text('Autenticando...'), findsOneWidget);

      await tester.pumpWidget(buildScreen(ConnectionStatus.connected));
      expect(find.text('Tureon'), findsOneWidget);
    },
  );

  testWidgets(
    'settings logout closes settings after local sign-out completes',
    (tester) async {
      var logoutCalls = 0;
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Home after logout'),
                      TextButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => SettingsHomeScreen(
                              onLogout: (_) async {
                                logoutCalls++;
                              },
                            ),
                          ),
                        ),
                        child: const Text('Open settings'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open settings'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Sair da Conta'),
        500,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Sair da Conta'));
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('manter'));
      await tester.pumpAndSettle();

      expect(logoutCalls, 1);
      expect(find.text('Home after logout'), findsOneWidget);
      expect(find.text('Sair da Conta'), findsNothing);
    },
  );

  testWidgets('own profile uses a Material app bar and a flat profile header', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ProviderScope(child: MyProfileScreen(onOpenSettings: _noop)),
      ),
    );

    expect(find.text('Meu Perfil'), findsOneWidget);
    expect(find.text('INFORMAÇÕES E PRIVACIDADE'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsNothing);
  });

  testWidgets('main conversation list includes groups and channels', (
    tester,
  ) async {
    final state = HomeState(
      recipients: [
        Recipient(
          id: 'group-1',
          type: RecipientType.group,
          name: 'Grupo',
          handle: '',
        ),
        Recipient(
          id: 'channel-1',
          type: RecipientType.channel,
          name: 'Canal',
          handle: '',
        ),
        Recipient(
          id: 'user-1',
          type: RecipientType.user,
          name: 'Contato',
          handle: '',
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: HomeChatsScreen(
          state: state,
          onSelectRecipient: _ignoreRecipient,
          onOpenContactsTab: _noop,
          onOpenSettings: _noop,
        ),
      ),
    );

    expect(find.text('Grupo'), findsOneWidget);
    expect(find.text('Canal'), findsOneWidget);
    expect(find.text('Contato'), findsOneWidget);
  });

  testWidgets('conversation list offers group and channel creation', (
    tester,
  ) async {
    bool? createdChannel;
    await tester.pumpWidget(
      MaterialApp(
        home: HomeChatsScreen(
          state: HomeState(),
          onSelectRecipient: _ignoreRecipient,
          onOpenContactsTab: _noop,
          onOpenSettings: _noop,
          onCreateGroupChannel: (isChannel) => createdChannel = isChannel,
        ),
      ),
    );

    await tester.tap(find.byTooltip('Criar grupo ou canal'));
    await tester.pumpAndSettle();
    expect(find.text('Novo grupo'), findsOneWidget);
    expect(find.text('Novo canal'), findsOneWidget);

    await tester.tap(find.text('Novo canal'));
    await tester.pumpAndSettle();
    expect(createdChannel, isTrue);
  });

  testWidgets(
    'settings is an independent route without the main bottom navigation',
    (tester) async {
      await tester.pumpWidget(const TureonApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Mais opções'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Configurações'));
      await tester.pumpAndSettle();
      expect(find.byType(NavigationBar), findsNothing);

      await tester.tap(find.text('Conta').first);
      await tester.pumpAndSettle();

      expect(find.text('Número de Telefone'), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);

      await tester.tap(find.text('Número de Telefone'));
      await tester.pumpAndSettle();
      expect(find.text('Conecte-se para editar o perfil.'), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);

      Navigator.of(tester.element(find.text('Conta').first)).pop();
      await tester.pumpAndSettle();
      Navigator.of(tester.element(find.text('Configurações').first)).pop();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Contatos'));
      await tester.pumpAndSettle();
      expect(find.text('Buscar contatos...'), findsOneWidget);
    },
  );

  testWidgets(
    'profile edits refresh the settings section and settings home immediately',
    (tester) async {
      final store = LocalStore.inMemory();
      store.saveSession(
        const UserSession(userId: 'user-1', deviceId: 'device-1'),
      );
      store.saveCurrentUser(
        const UserProfile(
          userId: 'user-1',
          username: 'leandro_1',
          displayName: 'Leandro',
          bio: 'Bio anterior',
        ),
      );
      addTearDown(store.close);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileRepositoryProvider.overrideWith(
              (ref) => ProfileRepository(store),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: SettingsHomeScreen(
              currentUser: store.loadCurrentUser(userId: 'user-1'),
              onUpdateProfile: (updated) async {
                store.saveCurrentUser(updated, markForSync: true);
                return updated;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Leandro'), findsOneWidget);
      await tester.tap(find.text('Conta').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Nome').first);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), 'Leandro Atualizado');
      await tester.tap(find.byTooltip('Salvar'));
      await tester.pumpAndSettle();

      expect(find.text('Leandro Atualizado'), findsWidgets);
      Navigator.of(tester.element(find.text('Conta').first)).pop();
      await tester.pumpAndSettle();
      expect(find.text('Leandro Atualizado'), findsOneWidget);
    },
  );

  testWidgets('my profile reacts to shared profile changes immediately', (
    tester,
  ) async {
    final store = LocalStore.inMemory();
    store.saveSession(
      const UserSession(userId: 'user-1', deviceId: 'device-1'),
    );
    store.saveCurrentUser(
      const UserProfile(
        userId: 'user-1',
        username: 'leandro_1',
        displayName: 'Leandro',
        bio: 'Bio anterior',
      ),
    );
    addTearDown(store.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          profileRepositoryProvider.overrideWith(
            (ref) => ProfileRepository(store),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: MyProfileScreen(
            currentUser: store.loadCurrentUser(userId: 'user-1'),
            onOpenSettings: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Leandro'), findsOneWidget);

    store.saveCurrentUser(
      store
          .loadCurrentUser(userId: 'user-1')!
          .copyWith(displayName: 'Leandro Atualizado', bio: 'Nova bio'),
    );
    await tester.pumpAndSettle();

    expect(find.text('Leandro Atualizado'), findsOneWidget);
    expect(find.text('Nova bio'), findsWidgets);
  });
}

void _noop() {}

void _ignoreRecipient(Recipient recipient) {}

void _ignoreIndex(int index) {}
