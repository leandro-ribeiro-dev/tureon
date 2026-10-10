import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tureon/l10n/app_localizations.dart';

import '../../../../core/design_system/app_avatar.dart';
import '../../../../core/design_system/verified_name.dart';
import '../../../../core/providers/profile_providers.dart';
import '../../../../core/providers/settings_providers.dart';
import '../../../../core/protocol/verification_badge.dart';
import '../../../../core/storage/message_records.dart';
import '../../../support/presentation/views/help_support_view.dart';
import '../../../profile/presentation/views/edit_field_screen.dart';
import '../../../profile/presentation/views/edit_profile_screen.dart';
import '../../../about/presentation/views/about_view.dart';
import '../../data/settings_registry.dart';
import 'devices_screen.dart';
import '../../../profile/presentation/views/appearance_view.dart';
import 'language_settings_screen.dart';
import 'settings_section_screen.dart';
import 'chat_filters_settings_screen.dart';
import '../widgets/settings_logout_dialog.dart';

/// SettingsHomeScreen styled according to modern Settings View (View 3):
/// Top hero section with speech bubble, accent avatar, name with plus badge,
/// QR & search action icons, and clean settings menu items with descriptions.
class SettingsHomeScreen extends ConsumerWidget {
  static const _bioPreviewMaxLength = 80;

  const SettingsHomeScreen({
    super.key,
    this.currentUser,
    this.onLoadProfile,
    this.onUpdateProfile,
    this.onUpdatePrivacySetting,
    this.onLogout,
    this.isSessionActive,
    this.onLoadDevices,
    this.onRevokeDevice,
    this.canEditProfile = true,
    this.isAccountUnderReview = false,
  });

  final UserProfile? currentUser;
  final Future<UserProfile> Function()? onLoadProfile;
  final Future<UserProfile> Function(UserProfile profile)? onUpdateProfile;
  final Future<UserProfile> Function(String field, String visibility)?
  onUpdatePrivacySetting;
  final bool canEditProfile;
  final bool isAccountUnderReview;
  final Future<void> Function(bool deleteLocalData)? onLogout;
  final bool Function()? isSessionActive;
  final Future<List<DeviceSession>> Function()? onLoadDevices;
  final Future<void> Function(String deviceId)? onRevokeDevice;

  Future<void> _confirmLogout(BuildContext context) async {
    final deleteLocalData = await SettingsLogoutDialog.show(context);
    if (deleteLocalData == null) return;
    try {
      await onLogout?.call(deleteLocalData);
      if (context.mounted) {
        await Navigator.of(context).maybePop();
      }
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível concluir logout: $error')),
      );
      if (isSessionActive?.call() == false) {
        await Navigator.of(context).maybePop();
      }
    }
  }

  void _openSection(BuildContext context, WidgetRef ref, String sectionId) {
    if (sectionId == 'chat_folders' || sectionId == 'chat_filters') {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ChatFiltersSettingsScreen()),
      );
      return;
    }
    if (sectionId == 'devices' &&
        onLoadDevices != null &&
        onRevokeDevice != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => DevicesScreen(
            loadDevices: onLoadDevices!,
            revokeDevice: onRevokeDevice!,
          ),
        ),
      );
      return;
    }
    final section = SettingsRegistry.sections[sectionId];
    if (section != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SettingsSectionScreen(
            section: section,
            onLoadProfile: onLoadProfile,
            onUpdatePrivacySetting: canEditProfile
                ? onUpdatePrivacySetting
                : null,
            isAccountUnderReview: isAccountUnderReview,
            onNavigateRoute: (route) {
              if (route == 'devices') {
                _openSection(context, ref, 'devices');
              } else if (route == '/profile/edit/name') {
                _openEditField(context, ProfileFieldType.displayName);
              } else if (route == '/profile/edit/username') {
                _openEditField(context, ProfileFieldType.username);
              } else if (route == '/profile/edit/bio') {
                _openEditField(context, ProfileFieldType.bio);
              } else if (route == '/profile/edit/phone') {
                _openEditField(context, ProfileFieldType.phone);
              } else if (route == '/profile/edit/birthday') {
                _openEditField(context, ProfileFieldType.birthday);
              } else if (route == '/profile/edit/country') {
                _openEditField(context, ProfileFieldType.country);
              } else if (route == '/profile/edit/avatar') {
                _openEditField(context, ProfileFieldType.avatarUrl);
              } else if (route == '/profile/edit') {
                _openEditProfile(context);
              }
            },
            onSelectionChanged: (entryId, value) {
              if (entryId == 'night_mode') {
                ref.read(appThemeModeProvider.notifier).setThemeMode(
                  switch (value) {
                    'Claro' => ThemeMode.light,
                    'Escuro' => ThemeMode.dark,
                    _ => ThemeMode.system,
                  },
                );
              }
            },
          ),
        ),
      );
    }
  }

  Future<void> _openEditField(
    BuildContext context,
    ProfileFieldType fieldType,
  ) async {
    if (!canEditProfile) return;
    final saveProfile = onUpdateProfile;
    if (saveProfile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conecte-se para editar o perfil.')),
      );
      return;
    }
    try {
      final profile = await onLoadProfile?.call() ?? currentUser;
      if (profile == null || !context.mounted) return;
      await Navigator.of(context).push<UserProfile>(
        MaterialPageRoute(
          builder: (_) => EditFieldScreen(
            fieldType: fieldType,
            currentUser: profile,
            onSave: saveProfile,
          ),
        ),
      );
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Não foi possível carregar o perfil: $error')),
        );
      }
    }
  }

  Future<void> _openEditProfile(BuildContext context) async {
    if (!canEditProfile) return;
    final saveProfile = onUpdateProfile;
    if (saveProfile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conecte-se para editar o perfil.')),
      );
      return;
    }
    try {
      final profile = await onLoadProfile?.call() ?? currentUser;
      if (profile == null || !context.mounted) return;
      await Navigator.of(context).push<UserProfile>(
        MaterialPageRoute(
          builder: (_) =>
              EditProfileScreen(currentUser: profile, onSave: saveProfile),
        ),
      );
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Não foi possível carregar o perfil: $error')),
        );
      }
    }
  }

  void _openLanguageScreen(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const LanguageSettingsScreen()));
  }

  Widget _menuTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 24, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpeechBubble(BuildContext context, String text) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bubbleBg = isDark
        ? theme.colorScheme.surfaceContainerHigh
        : theme.colorScheme.surface;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: bubbleBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        CustomPaint(
          size: const Size(12, 6),
          painter: _BubbleTailPainter(color: bubbleBg),
        ),
      ],
    );
  }

  String _bioPreview(String bio) {
    final runes = bio.runes.toList(growable: false);
    if (runes.length <= _bioPreviewMaxLength) return bio;
    return '${String.fromCharCodes(runes.take(_bioPreviewMaxLength)).trimRight()}...';
  }

  Widget _buildProfileHeader(
    BuildContext context, {
    required UserProfile? user,
    required String name,
    required String username,
    required String bioText,
    required Color accentColor,
  }) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSpeechBubble(context, _bioPreview(bioText)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: canEditProfile ? () => _openEditProfile(context) : null,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: accentColor.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 44,
              backgroundColor: accentColor,
              child: AppAvatar(
                name: name,
                imageUrl: user?.avatarUrl,
                radius: 42,
                verificationBadge:
                    user?.verificationBadge ?? VerificationBadge.none,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: VerifiedName(
                name: name,
                badge: user?.verificationBadge ?? VerificationBadge.none,
                textAlign: TextAlign.center,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(width: 6),
            if (canEditProfile) ...[
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => _openEditProfile(context),
                child: Icon(
                  Icons.add_circle_rounded,
                  size: 20,
                  color: accentColor,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            final idToCopy = user?.userId ?? username;
            if (idToCopy.isNotEmpty) {
              Clipboard.setData(ClipboardData(text: idToCopy));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('ID copiado para a área de transferência!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'ID: ${user?.userId ?? username}',
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(Icons.copy_rounded, size: 16, color: accentColor),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final repository = ref.watch(profileRepositoryProvider);
    final profileState = ref.watch(currentUserProfileProvider);
    final user = repository == null
        ? currentUser
        : profileState.when(
            data: (profile) => profile,
            error: (error, stackTrace) => null,
            loading: () => currentUser,
          );
    final name = user?.displayName ?? 'Usuário Tureon';
    final username = user?.username ?? 'usuario_tureon';
    final bioText = user?.bio?.isNotEmpty == true
        ? user!.bio!
        : 'Compartilhe um pensamento';

    final accentColor = theme.colorScheme.primary;
    final menuItems = <Widget>[
      _menuTile(
        context,
        icon: Icons.key_outlined,
        title: 'Conta',
        subtitle: 'Notificações de segurança, mudar número, username, bio',
        onTap: () => _openSection(context, ref, 'account'),
      ),
      _menuTile(
        context,
        icon: Icons.lock_outline_rounded,
        title: 'Privacidade',
        subtitle: 'Bloqueio de contatos, mensagens temporárias, visibilidade',
        onTap: () => _openSection(context, ref, 'privacy_security'),
      ),
      _menuTile(
        context,
        icon: Icons.palette_outlined,
        title: 'Aparência',
        subtitle: 'Tema claro/escuro e aparência das conversas',
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const AppearanceView())),
      ),
      _menuTile(
        context,
        icon: Icons.chat_outlined,
        title: 'Conversas',
        subtitle: 'Tema, papéis de parede, histórico de conversas',
        onTap: () => _openSection(context, ref, 'chat_settings'),
      ),
      _menuTile(
        context,
        icon: Icons.notifications_none_rounded,
        title: 'Notificações',
        subtitle: 'Sons de mensagens, grupos e chamadas',
        onTap: () => _openSection(context, ref, 'notifications'),
      ),
      _menuTile(
        context,
        icon: Icons.filter_list_rounded,
        title: 'Filtros e Abas de Conversa',
        subtitle: 'Ative, desative, adicione e remova abas da tela principal',
        onTap: () => _openSection(context, ref, 'chat_folders'),
      ),
      _menuTile(
        context,
        icon: Icons.devices_rounded,
        title: 'Dispositivos',
        subtitle: 'Sessões ativas no Web, Desktop e outros aparelhos',
        onTap: () => _openSection(context, ref, 'devices'),
      ),
      _menuTile(
        context,
        icon: Icons.language_rounded,
        title: 'Idioma do App',
        subtitle: 'Idioma da interface e tradução de mensagens',
        onTap: () => _openLanguageScreen(context),
      ),
      _menuTile(
        context,
        icon: Icons.help_outline_rounded,
        title: 'Ajuda e Suporte',
        subtitle: 'Central de ajuda, fale conosco, política de privacidade',
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const HelpSupportView())),
      ),
      _menuTile(
        context,
        icon: Icons.info_outline_rounded,
        title: l10n.aboutTitle,
        subtitle: l10n.aboutSettingsSubtitle,
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const AboutView())),
      ),
      if (onLogout != null)
        _menuTile(
          context,
          icon: Icons.logout_rounded,
          title: 'Sair da Conta',
          subtitle: 'Encerrar a sessão neste dispositivo',
          onTap: () => _confirmLogout(context),
        ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
        leading: IconButton(
          tooltip: 'Voltar',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          IconButton(
            tooltip: 'Código QR',
            icon: const Icon(Icons.qr_code_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Código QR do perfil')),
              );
            },
          ),
          IconButton(
            tooltip: 'Buscar',
            icon: const Icon(Icons.search_rounded),
            onPressed: () => _openSection(context, ref, 'account'),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          if (profileState.hasError)
            SliverToBoxAdapter(
              child: MaterialBanner(
                content: const Text(
                  'Não foi possível observar o perfil salvo neste dispositivo.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => ref.invalidate(currentUserProfileProvider),
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
              child: _buildProfileHeader(
                context,
                user: user,
                name: name,
                username: username,
                bioText: bioText,
                accentColor: accentColor,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Text(
                'Configurações',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => menuItems[index],
              childCount: menuItems.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

class _BubbleTailPainter extends CustomPainter {
  const _BubbleTailPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
