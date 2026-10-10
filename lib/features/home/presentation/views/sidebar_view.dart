import 'package:flutter/material.dart';

import '../../../../core/design_system/app_avatar.dart';
import '../../../../core/design_system/app_bottom_sheet.dart';
import '../../../../core/design_system/verified_name.dart';
import '../../../../core/protocol/recipient.dart';
import '../../../../core/protocol/verification_badge.dart';
import '../../../../core/storage/message_records.dart';
import '../home_view_model.dart';
import '../widgets/avatar_widget.dart';

/// Navigation Sidebar listing active conversations and user info.
void _noopSidebarRecipientCallback(Recipient _) {}

class Sidebar extends StatelessWidget {
  const Sidebar({
    super.key,
    required this.state,
    required this.onSelect,
    required this.onChanged,
    required this.onOpenArchived,
    required this.onOpenProfile,
    this.onTogglePinned = _noopSidebarRecipientCallback,
    this.onToggleArchived = _noopSidebarRecipientCallback,
    this.onDeleteConversation = _noopSidebarRecipientCallback,
    this.currentUser,
  });

  final HomeState state;
  final ValueChanged<Recipient> onSelect;
  final VoidCallback onChanged;
  final VoidCallback onOpenArchived;
  final VoidCallback onOpenProfile;
  final ValueChanged<Recipient> onTogglePinned;
  final ValueChanged<Recipient> onToggleArchived;
  final ValueChanged<Recipient> onDeleteConversation;
  final UserProfile? currentUser;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayName = currentUser?.displayName ?? 'Usuário';
    return Container(
      color: theme.scaffoldBackgroundColor,
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar conversas',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: theme.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.dividerColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.dividerColor),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 26, 16, 10),
            child: Text(
              'CONVERSAS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          if (state.archivedRecipients.isNotEmpty)
            ListTile(
              leading: Icon(
                Icons.archive_outlined,
                color: theme.colorScheme.primary,
              ),
              title: const Text('Arquivadas'),
              subtitle: Text('${state.archivedRecipients.length} conversas'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: onOpenArchived,
            ),
          Expanded(
            child: ListView.builder(
              itemCount: state.activeRecipients.length,
              itemBuilder: (context, index) {
                final recipient = state.activeRecipients[index];
                return Material(
                  color: Colors.transparent,
                  child: ListTile(
                    selected: recipient.id == state.selectedRecipient?.id,
                    selectedTileColor: theme.colorScheme.primaryContainer,
                    leading: Avatar(recipient: recipient),
                    title: VerifiedName(
                      name: recipient.name,
                      badge: recipient.verificationBadge,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      recipient.lastMessage ?? recipient.handle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (state.isPinned(recipient))
                          Icon(
                            Icons.push_pin_rounded,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                        if (recipient.unreadCount > 0)
                          CircleAvatar(
                            radius: 10,
                            backgroundColor: theme.colorScheme.primary,
                            child: Text(
                              '${recipient.unreadCount}',
                              style: TextStyle(
                                color: theme.colorScheme.onPrimary,
                                fontSize: 11,
                              ),
                            ),
                          ),
                      ],
                    ),
                    onTap: () => onSelect(recipient),
                    onLongPress: () =>
                        _showConversationActions(context, recipient),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onOpenProfile,
              child: Row(
                children: [
                  _UserAvatar(user: currentUser),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showConversationActions(BuildContext context, Recipient recipient) {
    AppBottomSheet.show<void>(
      context: context,
      builder: (sheetContext) => AppBottomSheetContainer(
        title: recipient.name,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBottomSheetTile(
              icon: Icons.push_pin_outlined,
              title: state.isPinned(recipient) ? 'Desfixar' : 'Fixar',
              onTap: () {
                onTogglePinned(recipient);
                Navigator.pop(sheetContext);
                onChanged();
              },
            ),
            AppBottomSheetTile(
              icon: Icons.archive_outlined,
              title: 'Arquivar',
              onTap: () {
                onToggleArchived(recipient);
                Navigator.pop(sheetContext);
                onChanged();
              },
            ),
            AppBottomSheetTile(
              icon: Icons.delete_outline_rounded,
              title: 'Apagar conversa',
              isDestructive: true,
              onTap: () {
                Navigator.pop(sheetContext);
                _confirmDelete(context, recipient);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Recipient recipient) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Apagar conversa?'),
        content: Text(
          'A conversa com ${recipient.name} será removida deste dispositivo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              onDeleteConversation(recipient);
              Navigator.pop(dialogContext);
              onChanged();
            },
            child: const Text('Apagar'),
          ),
        ],
      ),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  const _UserAvatar({required this.user});

  final UserProfile? user;

  @override
  Widget build(BuildContext context) {
    return AppAvatar(
      name: user?.displayName ?? 'U',
      imageUrl: user?.avatarUrl,
      radius: 18,
      verificationBadge: user?.verificationBadge ?? VerificationBadge.none,
    );
  }
}
