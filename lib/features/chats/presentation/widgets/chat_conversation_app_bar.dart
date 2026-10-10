import 'package:flutter/material.dart';

import '../../../../core/design_system/app_avatar.dart';
import '../../../../core/design_system/compact_count.dart';
import '../../../../core/design_system/verified_name.dart';
import '../../../../core/protocol/protocol_models.dart';
import '../../../../l10n/app_localizations_extensions.dart';

class ChatConversationAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const ChatConversationAppBar({
    required this.recipient,
    required this.isSecret,
    required this.isBrowsingHistory,
    required this.onBack,
    required this.onViewProfile,
    required this.onMore,
    this.onlineMemberCount,
    super.key,
  });

  final Recipient recipient;
  final bool isSecret;
  final bool isBrowsingHistory;
  final VoidCallback onBack;
  final ValueChanged<Recipient> onViewProfile;
  final VoidCallback onMore;
  final int? onlineMemberCount;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final localizations = context.safeLocalizations;
    final presenceLabel = recipient.isOnline
        ? localizations.chatPresenceOnline
        : recipient.isPresenceVisible
        ? localizations.chatPresenceOffline
        : localizations.chatPresenceUnavailable;
    return AppBar(
      backgroundColor: isBrowsingHistory
          ? colors.surfaceContainerHigh
          : colors.surface,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      leading: IconButton(
        tooltip: 'Voltar para conversas',
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: onBack,
      ),
      titleSpacing: 0,
      title: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onViewProfile(recipient),
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: double.infinity,
            height: kToolbarHeight,
            child: Row(
              children: [
                AppAvatar.fromRecipient(recipient, radius: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (isSecret) ...[
                            Icon(
                              Icons.lock_rounded,
                              size: 16,
                              color: colors.tertiary,
                            ),
                            const SizedBox(width: 4),
                          ],
                          Flexible(
                            child: VerifiedName(
                              name: recipient.name,
                              badge: recipient.verificationBadge,
                              maxLines: 1,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (recipient.isTyping)
                        _subtitle('digitando...', colors.primary)
                      else if (recipient.type == RecipientType.channel)
                        _subtitle(
                          '${formatCompactCount(recipient.memberCount)} inscritos',
                          colors.onSurfaceVariant,
                        )
                      else if (recipient.type == RecipientType.group)
                        _subtitle(
                          onlineMemberCount == null
                              ? 'Grupo'
                              : '${formatCompactCount(onlineMemberCount!)} online',
                          onlineMemberCount != null && onlineMemberCount! > 0
                              ? colors.primary
                              : colors.onSurfaceVariant,
                        )
                      else if (recipient.type == RecipientType.bot &&
                          recipient.description.isNotEmpty)
                        _subtitle(
                          recipient.description,
                          colors.onSurfaceVariant,
                        )
                      else if (recipient.type == RecipientType.user)
                        _subtitle(
                          presenceLabel,
                          recipient.isOnline
                              ? colors.primary
                              : colors.onSurfaceVariant,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          tooltip: 'Mais opções',
          icon: const Icon(Icons.more_vert_rounded),
          onPressed: onMore,
        ),
      ],
    );
  }

  Widget _subtitle(String value, Color color) => Text(
    value,
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    style: TextStyle(color: color, fontSize: 13),
  );
}
