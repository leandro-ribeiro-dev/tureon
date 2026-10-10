import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/app_bottom_sheet.dart';
import '../../../../core/providers/settings_providers.dart';
import '../../../../core/storage/message_records.dart';
import '../../../support/presentation/views/help_support_view.dart';
import '../widgets/profile_header_card.dart';
import '../widgets/profile_qr_code_sheet.dart';
import 'appearance_view.dart';

/// Clean, borderless ProfileView matching MyProfileScreen layout style across all sections.
class ProfileView extends ConsumerWidget {
  const ProfileView({super.key, this.currentUser});

  final UserProfile? currentUser;

  String _themeSubtitle(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.system => 'Padrão do sistema',
      ThemeMode.light => 'Modo claro',
      ThemeMode.dark => 'Modo noite',
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final glassToken = Theme.of(context).colorScheme;
    final user = currentUser;
    final themeMode = ref.watch(appThemeModeProvider);
    final displayName = user?.displayName ?? 'Usuário';
    final userId = user?.userId ?? '';

    return Material(
      color: glassToken.surface,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero Card Header (identical to MyProfileScreen)
            ProfileHeaderCard(
              profile: user,
              displayName: displayName,
              userId: userId,
              showSecurityIcon: true,
              securityLabel: 'Chaves E2EE Ativas',
              securityDialogTitle: 'Chaves de Criptografia E2EE',
              securityDialogMessage:
                  'Suas chaves de criptografia Signal Protocol estão ativadas e geradas com segurança no seu dispositivo. Todas as suas conversas privadas estão prontas e 100% protegidas por E2EE.',
              onShowQrCode: () {
                AppBottomSheet.show<void>(
                  context: context,
                  builder: (_) => ProfileQrCodeBottomSheet(profile: user),
                );
              },
            ),

            // Clean Borderless Sections
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CONFIGURAÇÕES E OTIMIZAÇÕES',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: glassToken.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _tile(
                    context,
                    Icons.palette_outlined,
                    'Aparência e Tema',
                    _themeSubtitle(themeMode),
                    () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AppearanceView()),
                    ),
                  ),
                  Divider(color: glassToken.outlineVariant, height: 1),
                  _tile(
                    context,
                    Icons.notifications_none_rounded,
                    'Notificações e Sons',
                    'Mensagens, grupos e chamadas',
                    () {},
                  ),
                  Divider(color: glassToken.outlineVariant, height: 1),
                  _tile(
                    context,
                    Icons.lock_outline_rounded,
                    'Privacidade e Segurança',
                    'Bloqueio e verificação em duas etapas',
                    () {},
                  ),
                  Divider(color: glassToken.outlineVariant, height: 1),
                  _tile(
                    context,
                    Icons.help_outline_rounded,
                    'Ajuda e Suporte',
                    'FAQ e políticas de privacidade',
                    () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const HelpSupportView()),
                    ),
                  ),
                  Divider(color: glassToken.outlineVariant, height: 1),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    final glassToken = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: glassToken.primary),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: glassToken.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13,
          color: glassToken.onSurfaceVariant,
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}
