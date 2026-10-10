import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/design_system/app_avatar.dart';
import '../../../../core/design_system/app_bottom_sheet.dart';
import '../../../../core/design_system/verified_name.dart';
import '../../../../core/protocol/recipient_type.dart';
import '../../../../core/protocol/verification_badge.dart';
import '../../../../core/storage/message_records.dart';

/// Top Header Card for Profile views.
/// Renders Avatar, Display Name, Full-width clickable Copy ID row,
/// Competitor-styled E2EE Security Badge, and Edit button for owners/admins.
class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({
    super.key,
    required this.profile,
    required this.displayName,
    required this.userId,
    required this.onShowQrCode,
    this.subtitle,
    this.showSecurityIcon = false,
    this.isSecurityError = false,
    this.securityLabel,
    this.securityDialogTitle,
    this.securityDialogMessage,
    this.onFixSecurityKeys,
    this.canEdit = false,
    this.onEdit,
    this.type,
  });

  final UserProfile? profile;
  final String displayName;
  final String userId;
  final VoidCallback onShowQrCode;
  final String? subtitle;
  final bool showSecurityIcon;
  final bool isSecurityError;
  final String? securityLabel;
  final String? securityDialogTitle;
  final String? securityDialogMessage;
  final VoidCallback? onFixSecurityKeys;
  final bool canEdit;
  final VoidCallback? onEdit;
  final RecipientType? type;

  void _showCompetitorSecurityModal(BuildContext context) {
    final defaultOkTitle = 'Criptografia Ponta a Ponta';
    final defaultOkMessage =
        'Mensagens, chamadas e mídias são protegidas com criptografia Signal Protocol. Ninguém fora deste chat pode lê-las ou ouvi-las.';

    final defaultErrTitle = 'Atenção com as Chaves E2EE';
    final defaultErrMessage =
        'Não foi possível verificar ou inicializar as chaves locais de criptografia Signal Protocol.';

    AppBottomSheet.showSecurityModal(
      context: context,
      title: isSecurityError
          ? (securityDialogTitle ?? defaultErrTitle)
          : (securityDialogTitle ?? defaultOkTitle),
      message: isSecurityError
          ? (securityDialogMessage ?? defaultErrMessage)
          : (securityDialogMessage ?? defaultOkMessage),
      isError: isSecurityError,
      onFix: onFixSecurityKeys,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final headerColor = colorScheme.surfaceContainer;

    // Filter out `@username` from top subtitle so username is ONLY in INFORMAÇÕES E PRIVACIDADE
    final filteredSubtitle =
        (subtitle != null && !subtitle!.startsWith('@')) ? subtitle : null;

    final effectiveUserId =
        userId.isNotEmpty ? userId : (profile?.userId ?? '');

    return Container(
      color: headerColor,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (canEdit && onEdit != null)
                IconButton(
                  tooltip: type == RecipientType.channel
                      ? 'Editar Canal'
                      : type == RecipientType.group
                          ? 'Editar Grupo'
                          : 'Editar Perfil',
                  onPressed: onEdit,
                  icon: Icon(
                    Icons.edit_outlined,
                    color: colorScheme.primary,
                  ),
                )
              else
                const SizedBox(width: 48),
              IconButton(
                tooltip: 'Meu QR Code',
                onPressed: onShowQrCode,
                icon: Icon(
                  Icons.qr_code_2_rounded,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          AppAvatar(
            name: displayName,
            id: effectiveUserId,
            imageUrl: profile?.avatarUrl,
            radius: 56,
            type: type ?? RecipientType.user,
            verificationBadge:
                profile?.verificationBadge ?? VerificationBadge.none,
          ),
          const SizedBox(height: 12),
          VerifiedName(
            name: displayName,
            badge: profile?.verificationBadge ?? VerificationBadge.none,
            type: type,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          if (filteredSubtitle != null && filteredSubtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              filteredSubtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          const SizedBox(height: 6),

          // Full-width clickable Copy ID item
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                if (effectiveUserId.isNotEmpty) {
                  Clipboard.setData(ClipboardData(text: effectiveUserId));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('ID copiado para a área de transferência!'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'ID: $effectiveUserId',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.copy_rounded,
                      size: 16,
                      color: colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),

          if (showSecurityIcon) ...[
            const SizedBox(height: 6),
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _showCompetitorSecurityModal(context),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSecurityError
                      ? colorScheme.errorContainer.withValues(alpha: 0.7)
                      : colorScheme.primaryContainer.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSecurityError
                          ? Icons.warning_amber_rounded
                          : Icons.shield_outlined,
                      size: 16,
                      color: isSecurityError
                          ? colorScheme.error
                          : colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      securityLabel ??
                          (isSecurityError
                              ? 'Atenção nas Chaves E2EE'
                              : 'Segurança OK (E2EE)'),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: isSecurityError
                            ? colorScheme.error
                            : colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
