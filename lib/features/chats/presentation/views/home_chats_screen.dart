import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/app/connection_status.dart';
import '../../../../core/design_system/app_bottom_sheet.dart';
import '../../../../core/protocol/recipient.dart';
import '../../../../core/providers/settings_providers.dart';
import '../../../home/presentation/home_view_model.dart';
import '../../../home/presentation/views/archived_conversations_view.dart';
import '../widgets/chats_search_bar.dart';
import '../widgets/chats_home_menu.dart';
import '../widgets/chat_selection_app_bar.dart';
import '../controllers/chat_conversation_filters.dart';
import '../widgets/chat_conversation_tile.dart';
import '../widgets/chats_filter_chips.dart';
import 'chats_search_view.dart';
import '../../../home/presentation/widgets/account_status_banner.dart';

/// Main conversations view styled like modern WhatsApp / Telegram layout:
/// Header with contextual selection action bar, pill search bar, customizable filter chips row,
/// archived tile, conversation items with avatars & timestamps, and floating chat button.
void _noopRecipientCallback(Recipient _) {}

class HomeChatsScreen extends ConsumerStatefulWidget {
  const HomeChatsScreen({
    super.key,
    required this.state,
    required this.onSelectRecipient,
    this.connectionStatus = ConnectionStatus.connected,
    this.onSearchUsers,
    this.onSearchPublicGroupChannels,
    this.onCreateGroupChannel,
    required this.onOpenContactsTab,
    required this.onOpenSettings,
    this.onTogglePinned = _noopRecipientCallback,
    this.onToggleArchived = _noopRecipientCallback,
    this.onDeleteConversation = _noopRecipientCallback,
    this.filterTabs,
  });

  final HomeState state;
  final ValueChanged<Recipient> onSelectRecipient;
  final ConnectionStatus connectionStatus;
  final Future<List<Recipient>> Function(String query)? onSearchUsers;
  final Future<List<Recipient>> Function(String query)?
  onSearchPublicGroupChannels;
  final ValueChanged<bool>? onCreateGroupChannel;
  final VoidCallback onOpenContactsTab;
  final VoidCallback onOpenSettings;
  final ValueChanged<Recipient> onTogglePinned;
  final ValueChanged<Recipient> onToggleArchived;
  final ValueChanged<Recipient> onDeleteConversation;
  final List<ChatFilterTab>? filterTabs;

  @override
  ConsumerState<HomeChatsScreen> createState() => _HomeChatsScreenState();
}

class _HomeChatsScreenState extends ConsumerState<HomeChatsScreen> {
  /// Selected filter tab ID or label (fallback 'all' / 'Tudo')
  String _selectedTabId = 'all';

  /// Multi-selection mode state
  final Set<String> _selectedRecipientIds = {};

  bool get _isSelectionMode => _selectedRecipientIds.isNotEmpty;

  void _toggleSelection(Recipient recipient) {
    setState(() {
      if (_selectedRecipientIds.contains(recipient.id)) {
        _selectedRecipientIds.remove(recipient.id);
      } else {
        _selectedRecipientIds.add(recipient.id);
      }
    });
  }

  void _selectAll(List<Recipient> list) {
    setState(() {
      _selectedRecipientIds.addAll(list.map((r) => r.id));
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedRecipientIds.clear();
    });
  }

  void _pinSelected(List<Recipient> activeList) {
    final selectedRecipients = activeList
        .where((r) => _selectedRecipientIds.contains(r.id))
        .toList();
    if (selectedRecipients.isEmpty) return;
    final success = ref
        .read(homeViewModelProvider.notifier)
        .togglePinnedBatch(selectedRecipients);
    _clearSelection();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Status de fixação atualizado!'
              : 'Limite de 5 conversas fixadas atingido.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _archiveSelected(List<Recipient> activeList) {
    final selectedRecipients = activeList
        .where((r) => _selectedRecipientIds.contains(r.id))
        .toList();
    if (selectedRecipients.isEmpty) return;
    ref
        .read(homeViewModelProvider.notifier)
        .toggleArchivedBatch(selectedRecipients);
    _clearSelection();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Conversas arquivadas!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _deleteSelected(List<Recipient> activeList) async {
    if (_selectedRecipientIds.length != 1) return;
    final recipient = activeList
        .where((r) => _selectedRecipientIds.contains(r.id))
        .firstOrNull;
    if (recipient == null) return;

    final confirmed = await AppBottomSheet.showConfirmation(
      context: context,
      title: 'Apagar conversa?',
      message:
          'Apagar a conversa com ${recipient.name} e todas as mensagens e dados locais deste dispositivo?',
      confirmLabel: 'Apagar',
      isDestructive: true,
    );

    if (confirmed == true && mounted) {
      ref.read(homeViewModelProvider.notifier).deleteConversation(recipient);
      _clearSelection();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Conversa com ${recipient.name} apagada.'),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showOverflowMenu(BuildContext context) => showChatsHomeMenu(
    context,
    onOpenContactsTab: widget.onOpenContactsTab,
    onOpenSettings: widget.onOpenSettings,
  );

  int _calculateUnreadForTab(ChatFilterTab tab, List<Recipient> list) =>
      ChatConversationFilters.unread(tab, list, widget.state.isPinned);
  List<Recipient> _filterActiveRecipients(
    ChatFilterTab tab,
    List<Recipient> list,
  ) => ChatConversationFilters.matching(tab, list, widget.state.isPinned);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final glassToken = theme.colorScheme;
    final accentColor = theme.colorScheme.primary;

    // Load configured filter tabs from settings
    List<ChatFilterTab> allFilterTabs;
    bool showUnreadBadges = true;
    bool showFilterChipsRow = true;
    try {
      allFilterTabs = widget.filterTabs ?? ref.watch(chatFilterTabsProvider);
      showUnreadBadges = ref.watch(showFilterUnreadBadgesProvider);
      showFilterChipsRow = ref.watch(showFilterChipsRowProvider);
    } catch (_) {
      allFilterTabs = widget.filterTabs ?? ChatFilterTabsNotifier.defaultTabs();
    }

    // Active tabs enabled in settings ("so aparece se tiver ativo")
    final activeTabs = allFilterTabs.where((t) => t.isEnabled).toList();
    final bool shouldShowChips = showFilterChipsRow && activeTabs.isNotEmpty;
    final activeRecipients = widget.state.activeRecipients;
    final archivedRecipients = widget.state.archivedRecipients;

    // Selected tab: if chips bar is hidden or activeTabs is empty, fallback to 'all' filter type
    final ChatFilterTab selectedTab = shouldShowChips
        ? activeTabs.firstWhere(
            (t) => t.id == _selectedTabId || t.label == _selectedTabId,
            orElse: () => activeTabs.first,
          )
        : const ChatFilterTab(
            id: 'all',
            label: 'Tudo',
            filterType: 'all',
            isBuiltIn: true,
            isEnabled: true,
          );

    final chipItems = activeTabs.map((tab) {
      final unread = showUnreadBadges
          ? _calculateUnreadForTab(tab, activeRecipients)
          : 0;
      return FilterChipItem(id: tab.id, label: tab.label, unreadCount: unread);
    }).toList();

    final activeList = _filterActiveRecipients(selectedTab, activeRecipients);
    final activeIndexById = {
      for (var index = 0; index < activeList.length; index++)
        activeList[index].id: index,
    };
    final showArchivedTile =
        archivedRecipients.isNotEmpty &&
        selectedTab.filterType == 'all' &&
        !_isSelectionMode;

    return Scaffold(
      appBar: _isSelectionMode
          ? ChatSelectionAppBar(
              selectedCount: _selectedRecipientIds.length,
              onClear: _clearSelection,
              onPin: () => _pinSelected(activeList),
              onArchive: () => _archiveSelected(activeList),
              onDelete: () => _deleteSelected(activeList),
              onSelectAll: () => _selectAll(activeList),
            )
          : AppBar(
              automaticallyImplyLeading: false,
              elevation: 0,
              backgroundColor: theme.scaffoldBackgroundColor,
              title: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: Text(
                  widget.connectionStatus.label,
                  key: ValueKey(widget.connectionStatus),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: accentColor,
                    fontWeight: FontWeight.bold,
                    fontSize:
                        widget.connectionStatus == ConnectionStatus.connected
                        ? 24
                        : 18,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              actions: [
                if (widget.onCreateGroupChannel != null)
                  PopupMenuButton<bool>(
                    tooltip: 'Criar grupo ou canal',
                    icon: Icon(
                      Icons.add_circle_outline_rounded,
                      color: theme.colorScheme.onSurface,
                    ),
                    onSelected: widget.onCreateGroupChannel!,
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: false,
                        child: ListTile(
                          leading: Icon(Icons.groups_outlined),
                          title: Text('Novo grupo'),
                        ),
                      ),
                      PopupMenuItem(
                        value: true,
                        child: ListTile(
                          leading: Icon(Icons.campaign_outlined),
                          title: Text('Novo canal'),
                        ),
                      ),
                    ],
                  ),
                IconButton(
                  tooltip: 'Câmera',
                  icon: Icon(
                    Icons.camera_alt_outlined,
                    color: theme.colorScheme.onSurface,
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Câmera em breve')),
                    );
                  },
                ),
                IconButton(
                  tooltip: 'Mais opções',
                  icon: Icon(
                    Icons.more_vert_rounded,
                    color: theme.colorScheme.onSurface,
                  ),
                  onPressed: () => _showOverflowMenu(context),
                ),
              ],
            ),
      body: SafeArea(
        child: Column(
          children: [
            const AccountStatusBanner(),

            // Pill Search Bar opening dedicated ChatsSearchView
            if (!_isSelectionMode)
              ChatsSearchBar(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ChatsSearchView(
                        state: widget.state,
                        onSelectRecipient: widget.onSelectRecipient,
                        onSearchUsers: widget.onSearchUsers,
                        onSearchPublicGroupChannels:
                            widget.onSearchPublicGroupChannels,
                      ),
                    ),
                  );
                },
              ),

            // Dynamic Filter Chips Row based on active settings
            if (shouldShowChips && !_isSelectionMode) ...[
              ChatsFilterChipsRow(
                items: chipItems,
                selectedFilter: selectedTab.id,
                onSelected: (tabId) => setState(() => _selectedTabId = tabId),
              ),
              const SizedBox(height: 4),
            ],

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 80),
                scrollCacheExtent: const ScrollCacheExtent.pixels(480),
                itemCount:
                    (showArchivedTile ? 1 : 0) +
                    (activeList.isEmpty ? 1 : activeList.length),
                findChildIndexCallback: (key) {
                  if (key == const ValueKey<String>('archived-tile')) {
                    return showArchivedTile ? 0 : null;
                  }
                  if (key is! ValueKey<String>) return null;
                  final itemIndex = activeIndexById[key.value];
                  return itemIndex == null
                      ? null
                      : itemIndex + (showArchivedTile ? 1 : 0);
                },
                itemBuilder: (context, index) {
                  if (showArchivedTile && index == 0) {
                    return _buildArchivedTile(
                      context,
                      archivedRecipients.length,
                    );
                  }
                  final itemIndex = index - (showArchivedTile ? 1 : 0);
                  if (activeList.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Center(
                        child: Text(
                          selectedTab.filterType == 'all'
                              ? 'Nenhuma conversa disponível no momento.'
                              : 'Nenhuma conversa em "${selectedTab.label}".',
                          style: TextStyle(
                            color: glassToken.onSurfaceVariant,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  }
                  return _buildRecipientTile(context, activeList[itemIndex]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArchivedTile(BuildContext context, int count) {
    final theme = Theme.of(context);
    return InkWell(
      key: const ValueKey<String>('archived-tile'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => ArchivedConversationsView(
              state: widget.state,
              onChanged: () {
                if (mounted) setState(() {});
              },
              onTogglePinned: widget.onTogglePinned,
              onToggleArchived: widget.onToggleArchived,
              onDeleteConversation: widget.onDeleteConversation,
              onSelect: (recipient) {
                Navigator.pop(context);
                widget.onSelectRecipient(recipient);
              },
            ),
          ),
        ).then((_) {
          if (mounted) setState(() {});
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              Icons.archive_outlined,
              color: theme.colorScheme.onSurfaceVariant,
              size: 22,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                'Arquivadas',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            if (count > 0)
              Text(
                '$count',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipientTile(BuildContext context, Recipient recipient) =>
      ChatConversationTile(
        recipient: recipient,
        isPinned: widget.state.isPinned(recipient),
        isSelected: _selectedRecipientIds.contains(recipient.id),
        isSelectionMode: _isSelectionMode,
        onSelect: () => widget.onSelectRecipient(recipient),
        onToggleSelection: () => _toggleSelection(recipient),
      );
}
