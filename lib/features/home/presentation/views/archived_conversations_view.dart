import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/app_avatar.dart';
import '../../../../core/design_system/app_bottom_sheet.dart';
import '../../../../core/design_system/verified_name.dart';
import '../../../../core/protocol/recipient.dart';
import '../home_view_model.dart';

void _noopRecipientCallback(Recipient _) {}

/// Reactive Archived Conversations View matching competitor real-time updates (Telegram/Signal/WhatsApp).
class ArchivedConversationsView extends ConsumerStatefulWidget {
  const ArchivedConversationsView({
    super.key,
    this.state,
    this.onChanged,
    this.onTogglePinned = _noopRecipientCallback,
    this.onToggleArchived = _noopRecipientCallback,
    this.onDeleteConversation = _noopRecipientCallback,
    required this.onSelect,
  });

  final HomeState? state;
  final VoidCallback? onChanged;
  final ValueChanged<Recipient> onTogglePinned;
  final ValueChanged<Recipient> onToggleArchived;
  final ValueChanged<Recipient> onDeleteConversation;
  final ValueChanged<Recipient> onSelect;

  @override
  ConsumerState<ArchivedConversationsView> createState() =>
      _ArchivedConversationsViewState();
}

class _ArchivedConversationsViewState
    extends ConsumerState<ArchivedConversationsView> {
  final Set<String> _selectedIds = {};

  bool get _isSelectionMode => _selectedIds.isNotEmpty;

  void _toggleSelection(Recipient recipient) {
    setState(() {
      if (_selectedIds.contains(recipient.id)) {
        _selectedIds.remove(recipient.id);
      } else {
        _selectedIds.add(recipient.id);
      }
    });
  }

  void _selectAll(List<Recipient> list) {
    setState(() {
      _selectedIds.addAll(list.map((r) => r.id));
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedIds.clear();
    });
  }

  void _unarchiveSelected(List<Recipient> archivedList) {
    final selected = archivedList
        .where((r) => _selectedIds.contains(r.id))
        .toList();
    if (selected.isEmpty) return;

    ref.read(homeViewModelProvider.notifier).toggleArchivedBatch(selected);
    _clearSelection();
    widget.onChanged?.call();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Conversas desarquivadas!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _deleteSelected(List<Recipient> archivedList) async {
    if (_selectedIds.length != 1) return;
    final recipient = archivedList
        .where((r) => _selectedIds.contains(r.id))
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
      widget.onChanged?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Conversa com ${recipient.name} apagada.'),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final homeState = ref.watch(homeViewModelProvider);
    final archived = homeState.archivedRecipients;

    return Scaffold(
      appBar: _isSelectionMode
          ? AppBar(
              elevation: 2,
              backgroundColor: theme.colorScheme.surfaceContainerHigh,
              leading: IconButton(
                icon: const Icon(Icons.close_rounded),
                tooltip: 'Cancelar seleção',
                onPressed: _clearSelection,
              ),
              title: Text(
                '${_selectedIds.length} selecionada(s)',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.unarchive_outlined),
                  tooltip: 'Desarquivar selecionadas',
                  onPressed: () => _unarchiveSelected(archived),
                ),
                if (_selectedIds.length == 1)
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded),
                    tooltip: 'Apagar conversa',
                    onPressed: () => _deleteSelected(archived),
                  ),
                IconButton(
                  icon: const Icon(Icons.select_all_rounded),
                  tooltip: 'Selecionar todas',
                  onPressed: () => _selectAll(archived),
                ),
              ],
            )
          : AppBar(title: const Text('Conversas arquivadas')),
      body: archived.isEmpty
          ? Center(
              child: Text(
                'Nenhuma conversa arquivada',
                style: theme.textTheme.bodyLarge,
              ),
            )
          : ListView.separated(
              itemCount: archived.length,
              separatorBuilder: (_, _) => const Divider(height: 1, indent: 72),
              itemBuilder: (context, index) {
                final recipient = archived[index];
                final isSelected = _selectedIds.contains(recipient.id);

                return Material(
                  color: isSelected
                      ? theme.colorScheme.primaryContainer.withValues(
                          alpha: 0.3,
                        )
                      : Colors.transparent,
                  child: ListTile(
                    leading: isSelected
                        ? Stack(
                            alignment: Alignment.center,
                            children: [
                              AppAvatar.fromRecipient(
                                recipient,
                                radius: 22,
                                isExpandable: false,
                              ),
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withValues(
                                    alpha: 0.85,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ],
                          )
                        : AppAvatar.fromRecipient(
                            recipient,
                            radius: 22,
                            isExpandable: !_isSelectionMode,
                          ),
                    title: VerifiedName(
                      name: recipient.name,
                      badge: recipient.verificationBadge,
                      type: recipient.type,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      recipient.lastMessage ?? recipient.handle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: homeState.isPinned(recipient)
                        ? Icon(
                            Icons.push_pin_rounded,
                            size: 16,
                            color: theme.colorScheme.primary,
                          )
                        : null,
                    onTap: () {
                      if (_isSelectionMode) {
                        _toggleSelection(recipient);
                      } else {
                        widget.onSelect(recipient);
                      }
                    },
                    onLongPress: () {
                      if (!_isSelectionMode) {
                        HapticFeedback.mediumImpact();
                        _toggleSelection(recipient);
                      } else {
                        _showActions(context, recipient, homeState);
                      }
                    },
                  ),
                );
              },
            ),
    );
  }

  void _showActions(
    BuildContext context,
    Recipient recipient,
    HomeState homeState,
  ) {
    AppBottomSheet.show<void>(
      context: context,
      builder: (sheetContext) => AppBottomSheetContainer(
        title: recipient.name,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBottomSheetTile(
              icon: Icons.unarchive_outlined,
              title: 'Desarquivar',
              onTap: () {
                ref
                    .read(homeViewModelProvider.notifier)
                    .toggleArchived(recipient);
                Navigator.pop(sheetContext);
                widget.onChanged?.call();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Conversa com ${recipient.name} desarquivada!',
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            AppBottomSheetTile(
              icon: Icons.push_pin_outlined,
              title: homeState.isPinned(recipient) ? 'Desfixar' : 'Fixar',
              onTap: () {
                final success = ref
                    .read(homeViewModelProvider.notifier)
                    .togglePinned(recipient);
                Navigator.pop(sheetContext);
                widget.onChanged?.call();
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
              },
            ),
            AppBottomSheetTile(
              icon: Icons.delete_outline_rounded,
              title: 'Apagar conversa',
              isDestructive: true,
              onTap: () {
                ref
                    .read(homeViewModelProvider.notifier)
                    .deleteConversation(recipient);
                Navigator.pop(sheetContext);
                widget.onChanged?.call();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Conversa com ${recipient.name} apagada.'),
                    duration: const Duration(seconds: 3),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
