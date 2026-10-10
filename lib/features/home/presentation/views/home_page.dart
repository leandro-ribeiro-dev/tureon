import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/app/app_runtime.dart';
import '../../../../core/app/connection_status.dart';
import '../../../../core/design_system/app_avatar.dart';
import '../../../../core/design_system/app_bottom_sheet.dart';
import '../../../../core/design_system/app_layout_tokens.dart';
import '../../../../core/protocol/recipient.dart';
import '../../../../core/protocol/recipient_type.dart';
import '../../../../core/providers/profile_providers.dart';
import '../../../../core/providers/settings_providers.dart';
import '../../../../core/storage/message_records.dart';
import '../../../chats/presentation/views/chat_screen.dart';
import '../../../chats/domain/secret_chat_device.dart';
import '../../../chats/presentation/views/home_chats_screen.dart';
import '../../../contacts/presentation/views/contact_profile_screen.dart';
import '../../../contacts/presentation/views/contacts_list_screen.dart';
import '../../../profile/presentation/views/my_profile_screen.dart';
import '../../../settings/presentation/views/settings_home_screen.dart';
import '../../../../l10n/app_localizations_extensions.dart';
import '../home_view_model.dart';

/// Main application page with Material 3 navigation adapted to window width.
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key, this.initialIndex = 0, this.searchUsers});

  final int initialIndex;
  final Future<List<Recipient>> Function(String query)? searchUsers;

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late int _selectedIndex;

  AppRuntime? get _runtime => ref.read(appRuntimeProvider);

  StreamSubscription<ConnectionStatus>? _connectionStatusSubscription;
  StreamSubscription<Recipient>? _presenceUpdateSubscription;
  late ConnectionStatus _connectionStatus;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex.clamp(0, 2).toInt();
    _connectionStatus =
        _runtime?.connectionStatus ?? ConnectionStatus.disconnected;
    _listenForConnectionUpdates();
    _presenceUpdateSubscription = _runtime?.presenceUpdates.listen((recipient) {
      if (!mounted || !recipient.presenceUpdate) return;
      ref.read(homeViewModelProvider.notifier).applyPresenceUpdate(recipient);
    });
  }

  void _listenForConnectionUpdates() {
    _connectionStatusSubscription?.cancel();
    _connectionStatusSubscription = _runtime?.connectionStatusUpdates.listen((
      status,
    ) {
      if (!mounted || _connectionStatus == status) return;
      setState(() => _connectionStatus = status);
    });
  }

  @override
  void dispose() {
    _connectionStatusSubscription?.cancel();
    _presenceUpdateSubscription?.cancel();
    super.dispose();
  }

  void _openChatWith(Recipient recipient, {bool isSecret = false}) {
    if (recipient.id.trim().isEmpty) {
      _showChatError('Não foi possível abrir uma conversa sem contato.');
      return;
    }
    if (recipient.type == RecipientType.user) {
      _refreshRecipientProfile(recipient.id);
    }
    if (isSecret) {
      _selectSecretChatDevice(recipient);
      return;
    }
    try {
      final viewModel = ref.read(homeViewModelProvider.notifier);
      final currentRecipient = ref
          .read(homeViewModelProvider)
          .recipients
          .where((item) => item.id == recipient.id)
          .firstOrNull;
      final conversation =
          currentRecipient ?? viewModel.upsertRecipient(recipient);
      viewModel.selectRecipient(conversation);
      _pushChat(conversation);
    } catch (error, stackTrace) {
      developer.log(
        'Could not persist conversation selected from search',
        name: 'tureon.chat',
        error: error,
        stackTrace: stackTrace,
      );
      _showChatError(
        'Não foi possível salvar esta conversa neste dispositivo. Tente novamente.',
      );
    }
  }

  void _refreshRecipientProfile(String recipientId) {
    final runtime = _runtime;
    if (runtime == null) return;
    unawaited(() async {
      try {
        await runtime.loadProfile(recipientId: recipientId);
      } catch (error, stackTrace) {
        developer.log(
          'Could not refresh the conversation profile when opening chat',
          name: 'tureon.profile',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }());
  }

  Future<void> _selectSecretChatDevice(Recipient recipient) async {
    final runtime = _runtime;
    if (runtime == null) {
      _showChatError('Conecte-se para iniciar um chat secreto.');
      return;
    }
    try {
      await runtime.ensureSecretChatReady();
      final devices = await runtime.listSecretChatDevices(recipient.id);
      if (!mounted) return;
      if (devices.isEmpty) {
        _showChatError(
          'Este contato ainda não publicou chaves de chat secreto em nenhum dispositivo.',
        );
        return;
      }
      final selectedDevice = await AppBottomSheet.show<SecretChatDevice>(
        context: context,
        builder: (sheetContext) => AppBottomSheetContainer(
          title: 'Escolha um dispositivo',
          subtitle: 'O chat secreto ficará vinculado a ele.',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final device in devices)
                AppBottomSheetTile(
                  icon: Icons.devices_other_rounded,
                  title: device.name,
                  subtitle: device.platform,
                  onTap: () => Navigator.pop(sheetContext, device),
                ),
            ],
          ),
        ),
      );
      if (!mounted || selectedDevice == null) return;
      ref.read(homeViewModelProvider.notifier).selectRecipient(recipient);
      _pushChat(recipient, isSecret: true, secretChatDevice: selectedDevice);
    } catch (error) {
      if (mounted) {
        _showChatError('Não foi possível iniciar o chat secreto: $error');
      }
    }
  }

  void _showChatError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _createGroupOrChannel({required bool isChannel}) async {
    final runtime = _runtime;
    if (runtime == null) {
      _showChatError('Conecte-se para criar um grupo ou canal.');
      return;
    }

    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    Map<String, String>? values;
    try {
      values = await showDialog<Map<String, String>>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(isChannel ? 'Novo canal' : 'Novo grupo'),
          content: Form(
            key: formKey,
            child: SizedBox(
              width: 360,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: isChannel ? 'Nome do canal' : 'Nome do grupo',
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Informe um nome.'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: descriptionController,
                    minLines: 2,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Descrição',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton.icon(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                Navigator.of(dialogContext).pop({
                  'name': nameController.text,
                  'description': descriptionController.text,
                });
              },
              icon: const Icon(Icons.check_rounded),
              label: const Text('Criar'),
            ),
          ],
        ),
      );
    } finally {
      nameController.dispose();
      descriptionController.dispose();
    }
    if (!mounted || values == null) return;

    try {
      final recipient = isChannel
          ? await runtime.createChannel(
              name: values['name'] ?? '',
              description: values['description'] ?? '',
            )
          : await runtime.createGroup(
              name: values['name'] ?? '',
              description: values['description'] ?? '',
            );
      if (!mounted) return;
      ref.read(homeViewModelProvider.notifier).upsertRecipient(recipient);
      setState(() => _selectedIndex = 0);
      _showChatError(
        isChannel ? 'Canal criado com sucesso.' : 'Grupo criado com sucesso.',
      );
    } catch (error) {
      if (mounted) _showChatError('Não foi possível criar: $error');
    }
  }

  void _openProfileFor(Recipient recipient) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ContactProfileScreen(
          recipientId: recipient.id,
          runtime: _runtime,
          onBack: () => Navigator.of(context).maybePop(),
          onOpenChat: (selected) {
            Navigator.of(context).pop();
            _openChatWith(selected);
          },
          onOpenSecretChat: (selected) {
            Navigator.of(context).pop();
            _openChatWith(selected, isSecret: true);
          },
          onLeftGroupChannel: (left) {
            ref.read(homeViewModelProvider.notifier).deleteConversation(left);
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
      ),
    );
  }

  void _pushChat(
    Recipient recipient, {
    bool isSecret = false,
    SecretChatDevice? secretChatDevice,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChatScreen(
          state: ref.watch(homeViewModelProvider),
          recipient: recipient,
          services: _runtime,
          isSecretChat: isSecret,
          secretChatDevice: secretChatDevice,
          onClearHistory: () =>
              ref.read(homeViewModelProvider.notifier).clearMessages(),
          onDeleteConversation: () => ref
              .read(homeViewModelProvider.notifier)
              .deleteConversation(recipient),
          onBack: () => Navigator.of(context).maybePop(),
          onViewProfile: _openProfileFor,
        ),
      ),
    );
  }

  void _openSettings() {
    final runtime = _runtime;
    final profile = ref
        .read(currentUserProfileProvider)
        .when(
          data: (value) => value,
          error: (error, stackTrace) => runtime?.currentUser,
          loading: () => runtime?.currentUser,
        );
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SettingsHomeScreen(
          currentUser: profile,
          onLoadProfile: runtime == null ? null : () => runtime.loadProfile(),
          onUpdateProfile: runtime?.updateProfile,
          onUpdatePrivacySetting: runtime?.canEditProfile == true
              ? (field, visibility) => runtime!.updatePrivacySetting(
                  field: field,
                  visibility: visibility,
                )
              : null,
          canEditProfile: runtime?.canEditProfile ?? true,
          isAccountUnderReview: runtime?.isUnderReview ?? false,
          isSessionActive: () => runtime?.hasActiveSession ?? false,
          onLoadDevices: runtime?.listDevices,
          onRevokeDevice: runtime?.revokeDevice,
          onLogout: (deleteLocalData) async {
            Object? logoutFailure;
            try {
              final controller = runtime?.authController;
              if (controller == null) {
                throw StateError(
                  'Não há uma sessão autenticada para encerrar.',
                );
              }
              await controller.signOut();
            } catch (error) {
              logoutFailure = error;
            } finally {
              if (deleteLocalData) {
                try {
                  runtime?.clearLocalHistory();
                } catch (error) {
                  logoutFailure ??= error;
                }
              }

              // AuthController performs server logout before clearing the
              // active session; invalidate only after that flow has finished.
              ref.invalidate(currentUserProfileProvider);
              ref.invalidate(homeViewModelProvider);
              ref.invalidate(chatFilterTabsProvider);
              ref.invalidate(showFilterChipsRowProvider);
              ref.invalidate(showFilterUnreadBadgesProvider);
            }

            if (logoutFailure != null) {
              throw StateError('Logout cleanup failed: $logoutFailure');
            }
          },
        ),
      ),
    );
  }

  Future<void> _openSearchedRecipient(Recipient recipient) async {
    try {
      if ((recipient.type == RecipientType.group ||
              recipient.type == RecipientType.channel) &&
          !recipient.isMember) {
        if (!mounted) return;
        _pushChat(recipient, isSecret: false);
        return;
      }
      final repository = _runtime?.chatRepository;
      final conversation = repository == null
          ? recipient
          : await repository.openOrCreateChat(
              recipientId: recipient.id,
              recipient: recipient,
            );
      if (!mounted) return;
      _openChatWith(conversation, isSecret: false);
    } catch (error, stackTrace) {
      developer.log(
        'Could not open chat selected from username search',
        name: 'tureon.chat',
        error: error,
        stackTrace: stackTrace,
      );
      if (mounted) {
        _showChatError(
          'Não foi possível abrir esta conversa. Tente novamente.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final runtime = _runtime;
    final currentUser = ref
        .watch(currentUserProfileProvider)
        .when(
          data: (profile) => profile,
          error: (error, stackTrace) => runtime?.currentUser,
          loading: () => runtime?.currentUser,
        );
    final homeState = ref.watch(homeViewModelProvider);
    final totalUnreadCount = homeState.activeRecipients.fold<int>(
      0,
      (sum, recipient) => sum + recipient.unreadCount,
    );
    final canWriteAccount = runtime?.canWriteAccount ?? true;
    final canEditProfile = runtime?.canEditProfile ?? true;
    final activeContent = IndexedStack(
      index: _selectedIndex,
      children: [
        // Tab 0: Chats
        HomeChatsScreen(
          state: homeState,
          connectionStatus: _connectionStatus,
          onSelectRecipient: (recipient) => _openSearchedRecipient(recipient),
          onCreateGroupChannel: canWriteAccount
              ? (isChannel) => _createGroupOrChannel(isChannel: isChannel)
              : null,
          onSearchUsers: widget.searchUsers ?? runtime?.searchUsersByUsername,
          onSearchPublicGroupChannels: runtime?.searchPublicGroupChannels,
          onOpenContactsTab: () => setState(() => _selectedIndex = 1),
          onOpenSettings: _openSettings,
          onTogglePinned: (recipient) =>
              ref.read(homeViewModelProvider.notifier).togglePinned(recipient),
          onToggleArchived: (recipient) => ref
              .read(homeViewModelProvider.notifier)
              .toggleArchived(recipient),
          onDeleteConversation: (recipient) => ref
              .read(homeViewModelProvider.notifier)
              .deleteConversation(recipient),
        ),

        // Tab 1: Contatos
        ContactsListScreen(
          state: homeState,
          onSelectContact: (recipient) =>
              _openChatWith(recipient, isSecret: false),
          onViewContactProfile: (recipient) => _openProfileFor(recipient),
        ),

        // Tab 2: Perfil
        MyProfileScreen(
          currentUser: currentUser,
          accountId: runtime?.currentUserId ?? currentUser?.userId,
          isOnline:
              runtime?.hasActiveSession == true &&
              _connectionStatus == ConnectionStatus.connected,
          onOpenSettings: _openSettings,
          onLoadProfile: runtime == null ? null : () => runtime.loadProfile(),
          onUpdateProfile: canEditProfile ? runtime?.updateProfile : null,
          canEditProfile: canEditProfile,
        ),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = AppBreakpoints.isCompact(constraints.maxWidth);
        final isExpanded = AppBreakpoints.isExpanded(constraints.maxWidth);
        final localizations = context.safeLocalizations;
        final navigationBarDestinations = [
          NavigationDestination(
            icon: _chatNavigationIcon(totalUnreadCount),
            selectedIcon: _selectedChatNavigationIcon(totalUnreadCount),
            label: localizations.mainNavChats,
          ),
          NavigationDestination(
            icon: const Icon(Icons.people_outline_rounded),
            selectedIcon: const Icon(Icons.people_rounded),
            label: localizations.mainNavContacts,
          ),
          NavigationDestination(
            icon: AppAvatar(
              name: currentUser?.displayName ?? localizations.mainNavProfile,
              id: currentUser?.userId,
              imageUrl: currentUser?.avatarUrl,
              radius: AppSpacing.medium,
              isExpandable: false,
            ),
            selectedIcon: _selectedProfileNavigationIcon(
              currentUser,
              localizations.mainNavProfile,
              Theme.of(context).colorScheme,
            ),
            label: localizations.mainNavProfile,
          ),
        ];
        final railDestinations = [
          NavigationRailDestination(
            icon: _chatNavigationIcon(totalUnreadCount),
            selectedIcon: _selectedChatNavigationIcon(totalUnreadCount),
            label: Text(localizations.mainNavChats),
          ),
          NavigationRailDestination(
            icon: const Icon(Icons.people_outline_rounded),
            selectedIcon: const Icon(Icons.people_rounded),
            label: Text(localizations.mainNavContacts),
          ),
          NavigationRailDestination(
            icon: const Icon(Icons.person_outline_rounded),
            selectedIcon: const Icon(Icons.person_rounded),
            label: Text(localizations.mainNavProfile),
          ),
        ];

        return Scaffold(
          extendBody: false,
          body: isCompact
              ? activeContent
              : Row(
                  children: [
                    SafeArea(
                      child: NavigationRail(
                        selectedIndex: _selectedIndex,
                        onDestinationSelected: _selectTab,
                        extended: isExpanded,
                        labelType: isExpanded
                            ? null
                            : NavigationRailLabelType.all,
                        destinations: railDestinations,
                      ),
                    ),
                    const VerticalDivider(width: 4.0),
                    Expanded(child: activeContent),
                  ],
                ),
          bottomNavigationBar: isCompact
              ? NavigationBar(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: _selectTab,
                  destinations: navigationBarDestinations,
                )
              : null,
        );
      },
    );
  }

  Widget _chatNavigationIcon(int unreadCount) => unreadCount > 0
      ? Badge.count(
          count: unreadCount,
          child: const Icon(Icons.chat_bubble_outline_rounded),
        )
      : const Icon(Icons.chat_bubble_outline_rounded);

  Widget _selectedChatNavigationIcon(int unreadCount) => unreadCount > 0
      ? Badge.count(
          count: unreadCount,
          child: const Icon(Icons.chat_bubble_rounded),
        )
      : const Icon(Icons.chat_bubble_rounded);

  Widget _selectedProfileNavigationIcon(
    UserProfile? currentUser,
    String fallbackName,
    ColorScheme colorScheme,
  ) => Container(
    padding: const EdgeInsets.all(2.0),
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: colorScheme.primary, width: 2.0),
    ),
    child: AppAvatar(
      name: currentUser?.displayName ?? fallbackName,
      id: currentUser?.userId,
      imageUrl: currentUser?.avatarUrl,
      radius: 10.0,
      isExpandable: false,
    ),
  );

  void _selectTab(int index) {
    setState(() => _selectedIndex = index);
  }
}
