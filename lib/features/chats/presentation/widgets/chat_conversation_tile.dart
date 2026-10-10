import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/design_system/app_avatar.dart';
import '../../../../core/design_system/verified_name.dart';
import '../../../../core/protocol/recipient.dart';
import '../../../presence/presentation/presence_status_label.dart';

class ChatConversationTile extends StatelessWidget {
  const ChatConversationTile({
    super.key,
    required this.recipient,
    required this.isPinned,
    required this.isSelected,
    required this.isSelectionMode,
    required this.onSelect,
    required this.onToggleSelection,
  });
  final Recipient recipient;
  final bool isPinned;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback onSelect;
  final VoidCallback onToggleSelection;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final presenceLabel = presenceStatusLabel(recipient);

    return Column(
      key: ValueKey(recipient.id),
      children: [
        Material(
          color: isSelected
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
              : Colors.transparent,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            leading: isSelected
                ? Stack(
                    alignment: Alignment.center,
                    children: [
                      AppAvatar.fromRecipient(
                        recipient,
                        radius: 26,
                        isExpandable: false,
                      ),
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.85,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ],
                  )
                : AppAvatar.fromRecipient(
                    recipient,
                    radius: 26,
                    isExpandable: !isSelectionMode,
                  ),
            title: Row(
              children: [
                Expanded(
                  child: VerifiedName(
                    name: recipient.name,
                    badge: recipient.verificationBadge,
                    type: recipient.type,
                    maxLines: 1,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (recipient.isTyping || presenceLabel != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        recipient.isTyping ? 'digitando...' : presenceLabel!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: recipient.isTyping || recipient.isOnline
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant,
                          fontWeight: recipient.isTyping || recipient.isOnline
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          recipient.lastMessage ??
                              (recipient.isUsernameVisible
                                  ? recipient.handle
                                  : 'Nova conversa'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      if (isPinned) ...[
                        const SizedBox(width: 6),
                        Icon(
                          Icons.push_pin_rounded,
                          size: 16,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ],
                      if (recipient.unreadCount > 0) ...[
                        const SizedBox(width: 8),
                        Badge.count(
                          count: recipient.unreadCount,
                          child: const SizedBox(width: 12, height: 12),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            onTap: () {
              if (isSelectionMode) {
                onToggleSelection();
              } else {
                onSelect();
              }
            },
            onLongPress: () {
              if (!isSelectionMode) {
                HapticFeedback.mediumImpact();
                onToggleSelection();
              }
            },
          ),
        ),
        Divider(
          height: 1,
          indent: 80,
          endIndent: 16,
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ],
    );
  }
}
