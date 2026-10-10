import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/design_system/app_avatar.dart';
import '../../../../core/protocol/protocol_models.dart';
import '../../../home/presentation/home_view_model.dart';
import '../widgets/chats_filter_chips.dart';
import '../widgets/chat_search_results.dart';
import '../controllers/chat_search_controller.dart';

/// Dedicated Full-Screen Search View for conversas, mensagens e contatos.
/// Inspired by top messaging apps (Telegram, WhatsApp, Signal).
class ChatsSearchView extends StatefulWidget {
  const ChatsSearchView({
    super.key,
    required this.state,
    required this.onSelectRecipient,
    this.onSearchUsers,
    this.onSearchPublicGroupChannels,
    this.initialQuery,
  });

  final HomeState state;
  final ValueChanged<Recipient> onSelectRecipient;
  final Future<List<Recipient>> Function(String query)? onSearchUsers;
  final Future<List<Recipient>> Function(String query)?
  onSearchPublicGroupChannels;
  final String? initialQuery;

  @override
  State<ChatsSearchView> createState() => _ChatsSearchViewState();
}

class _ChatsSearchViewState extends State<ChatsSearchView> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _selectedCategory = 'Tudo';
  late final ChatSearchController _remoteSearch;
  String get _searchQuery => _remoteSearch.query;
  List<Recipient> get _remoteResults => _remoteSearch.results;
  String? get _remoteError => _remoteSearch.error;
  bool get _isSearchingRemote => _remoteSearch.isSearching;

  static const List<String> _categories = [
    'Tudo',
    'Conversas',
    'Mensagens',
    'Mídias',
  ];

  @override
  void initState() {
    super.initState();
    _remoteSearch = ChatSearchController(
      searchUsers: () => widget.onSearchUsers,
      searchGroups: () => widget.onSearchPublicGroupChannels,
      initialQuery: widget.initialQuery,
    )..addListener(_onRemoteSearchChanged);
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _controller.text = widget.initialQuery!;
    }
    _controller.addListener(_onSearchInputChanged);
  }

  @override
  void dispose() {
    _remoteSearch.dispose();
    _controller.removeListener(_onSearchInputChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchInputChanged() => _remoteSearch.search(_controller.text);
  void _onRemoteSearchChanged() {
    if (mounted) setState(() {});
  }

  void _selectRecipientAndClose(Recipient recipient) {
    Navigator.pop(context);
    widget.onSelectRecipient(recipient);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final normalizedQuery = _searchQuery.trim().toLowerCase();

    // Local matching recipients
    final matchingLocalRecipients = widget.state.activeRecipients.where((r) {
      if (normalizedQuery.isEmpty) return false;
      return r.name.toLowerCase().contains(normalizedQuery) ||
          r.handle.toLowerCase().contains(normalizedQuery) ||
          (r.lastMessage?.toLowerCase().contains(normalizedQuery) ?? false);
    }).toList();

    // Local matching messages
    final matchingLocalMessages = widget.state.messages.where((m) {
      if (normalizedQuery.isEmpty) return false;
      final text = m.text ?? '';
      return text.toLowerCase().contains(normalizedQuery);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.pop(context),
            ),
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                autofocus: true,
                style: TextStyle(fontSize: 16, color: colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: 'Buscar mensagens, contatos e grupos...',
                  hintStyle: TextStyle(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  filled: false,
                ),
              ),
            ),
            if (_searchQuery.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () {
                  _controller.clear();
                },
              ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Filter Chips Row
          ChatsFilterChipsRow(
            options: _categories,
            selectedFilter: _selectedCategory,
            onSelected: (cat) => setState(() => _selectedCategory = cat),
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
          Expanded(
            child: _searchQuery.trim().isEmpty
                ? _buildEmptyQueryContent(context)
                : _buildSearchResultsContent(
                    context,
                    matchingLocalRecipients: matchingLocalRecipients,
                    matchingLocalMessages: matchingLocalMessages,
                    normalizedQuery: normalizedQuery,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyQueryContent(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final recentRecipients = widget.state.activeRecipients.take(8).toList();

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        if (recentRecipients.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Frequentes / Recentes',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
          ),
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: recentRecipients.length,
              itemBuilder: (context, index) {
                final recipient = recentRecipients[index];
                return InkWell(
                  onTap: () => _selectRecipientAndClose(recipient),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 76,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 6,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppAvatar.fromRecipient(recipient, radius: 24),
                        const SizedBox(height: 6),
                        Text(
                          recipient.name.split(' ').first,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Divider(
            height: 24,
            thickness: 1,
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ],
        Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.search_rounded,
                  size: 64,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                ),
                const SizedBox(height: 12),
                Text(
                  'Pesquise no Tureon',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Procure por conversas locais, mensagens ou usuários pela rede com @username.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResultsContent(
    BuildContext context, {
    required List<Recipient> matchingLocalRecipients,
    required List<MessageItem> matchingLocalMessages,
    required String normalizedQuery,
  }) => ChatSearchResults(
    matchingLocalRecipients: matchingLocalRecipients,
    matchingLocalMessages: matchingLocalMessages,
    normalizedQuery: normalizedQuery,
    selectedCategory: _selectedCategory,
    remoteResults: _remoteResults,
    remoteError: _remoteError,
    isSearching: _isSearchingRemote,
    recipients: widget.state.recipients,
    onSelect: _selectRecipientAndClose,
  );
}
