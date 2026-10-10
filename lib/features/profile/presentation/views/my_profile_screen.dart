import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/app_bottom_sheet.dart';
import '../../../../core/design_system/shared_media_showcase.dart';
import '../../../../core/providers/profile_providers.dart';
import '../../../../core/storage/message_records.dart';
import 'edit_profile_screen.dart';
import '../widgets/profile_header_card.dart';
import '../widgets/profile_qr_code_sheet.dart';

class MyProfileScreen extends ConsumerStatefulWidget {
  const MyProfileScreen({
    super.key,
    this.currentUser,
    this.accountId,
    this.isOnline = false,
    required this.onOpenSettings,
    this.onLoadProfile,
    this.onUpdateProfile,
    this.canEditProfile = true,
  });

  final UserProfile? currentUser;
  final String? accountId;
  final bool isOnline;
  final VoidCallback onOpenSettings;
  final Future<UserProfile> Function()? onLoadProfile;
  final Future<UserProfile> Function(UserProfile profile)? onUpdateProfile;
  final bool canEditProfile;

  @override
  ConsumerState<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends ConsumerState<MyProfileScreen> {
  UserProfile? _profile;
  String? _profileError;
  bool _loadingProfile = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProfile());
  }

  @override
  void didUpdateWidget(covariant MyProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentUser != oldWidget.currentUser) {
      _profile = widget.currentUser;
    }
  }

  void _applyProfile(UserProfile profile) {
    if (!mounted) return;
    setState(() => _profile = profile);
    ref.invalidate(currentUserProfileProvider);
  }

  Future<void> _loadProfile() async {
    final loadProfile = widget.onLoadProfile;
    if (loadProfile == null) return;
    setState(() {
      _loadingProfile = true;
      _profileError = null;
    });
    try {
      _applyProfile(await loadProfile());
    } catch (error) {
      if (mounted) setState(() => _profileError = '$error');
    } finally {
      if (mounted) setState(() => _loadingProfile = false);
    }
  }

  void _copyToClipboard(String text, String label) {
    if (text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copiado para a área de transferência!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _openEditProfile(UserProfile? profile) async {
    final saveProfile = widget.onUpdateProfile;
    if (profile == null || saveProfile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conecte-se para editar o perfil.')),
      );
      return;
    }
    final updated = await Navigator.of(context).push<UserProfile>(
      MaterialPageRoute(
        builder: (_) =>
            EditProfileScreen(currentUser: profile, onSave: saveProfile),
      ),
    );
    if (updated != null && mounted) _applyProfile(updated);
  }

  void _showQrCodeModal(UserProfile? profile) {
    AppBottomSheet.show<void>(
      context: context,
      builder: (_) => ProfileQrCodeBottomSheet(profile: profile),
    );
  }

  @override
  Widget build(BuildContext context) {
    final glassToken = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final profileState = ref.watch(currentUserProfileProvider);
    final profile =
        profileState.asData?.value ?? _profile ?? widget.currentUser;
    final displayName = profile?.displayName ?? 'Meu Perfil';
    final userId = widget.accountId ?? profile?.userId ?? '';
    final username = profile?.username ?? '';
    final phone = profile?.phoneE164 ?? '';
    final bio = profile?.bio ?? '';
    final birthday = profile?.birthday ?? '';
    final headerColor = colorScheme.surfaceContainer;
    final isDark = theme.brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: headerColor,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: headerColor,
        body: SafeArea(
          child: Material(
            color: glassToken.surface,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_loadingProfile) const LinearProgressIndicator(),
                  if (_profileError != null)
                    MaterialBanner(
                      content: Text(
                        'Não foi possível atualizar o perfil: $_profileError',
                      ),
                      actions: [
                        TextButton(
                          onPressed: _loadProfile,
                          child: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  if (profileState.hasError)
                    MaterialBanner(
                      content: const Text(
                        'Não foi possível observar o perfil salvo neste dispositivo.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () =>
                              ref.invalidate(currentUserProfileProvider),
                          child: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  ProfileHeaderCard(
                    profile: profile,
                    displayName: displayName,
                    userId: userId,
                    showSecurityIcon: true,
                    isSecurityError: profileState.hasError || _profileError != null,
                    securityLabel: (profileState.hasError || _profileError != null)
                        ? 'Atenção nas Chaves E2EE'
                        : 'Chaves E2EE Ativas',
                    securityDialogTitle: (profileState.hasError || _profileError != null)
                        ? 'Erro nas Chaves de Criptografia'
                        : 'Chaves de Criptografia E2EE',
                    securityDialogMessage: (profileState.hasError || _profileError != null)
                        ? 'Não foi possível verificar ou sincronizar suas chaves de criptografia E2EE. Faltam pré-chaves ativas ou ocorreu um erro na sessão.'
                        : 'Suas chaves de criptografia Signal Protocol estão ativadas e geradas com segurança no seu dispositivo. Todas as suas conversas privadas estão prontas e 100% protegidas por E2EE.',
                    onFixSecurityKeys: _loadProfile,
                    onShowQrCode: () => _showQrCodeModal(profile),
                  ),
                  Container(
                    color: headerColor,
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: Row(
                          children: [
                            if (widget.canEditProfile)
                              Expanded(
                                child: _buildActionButton(
                                  context,
                                  icon: Icons.add_a_photo_outlined,
                                  label: 'Definir Foto',
                                  onTap: () => _openEditProfile(profile),
                                ),
                              ),
                            if (widget.canEditProfile) const SizedBox(width: 8),
                            if (widget.canEditProfile)
                              Expanded(
                                child: _buildActionButton(
                                  context,
                                  icon: Icons.edit_outlined,
                                  label: 'Editar Informações',
                                  onTap: () => _openEditProfile(profile),
                                ),
                              ),
                            if (widget.canEditProfile) const SizedBox(width: 8),
                            Expanded(
                              child: _buildActionButton(
                                context,
                                icon: Icons.settings_outlined,
                                label: 'Configurações',
                                onTap: widget.onOpenSettings,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 120),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'INFORMAÇÕES E PRIVACIDADE',
                              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: glassToken.onSurfaceVariant,
                              ),
                            ),
                        const SizedBox(height: 8),
                        _buildInfoField(
                          context,
                          icon: Icons.phone_outlined,
                          title: phone.isEmpty ? 'Não informado' : phone,
                          subtitle: 'Celular',
                          onTap: phone.isEmpty
                              ? null
                              : () => _copyToClipboard(phone, 'Telefone'),
                        ),
                        Divider(color: glassToken.outlineVariant, height: 1),
                        _buildInfoField(
                          context,
                          icon: Icons.info_outline_rounded,
                          title: bio.isEmpty ? 'Não informado' : bio,
                          subtitle: 'Bio',
                          onTap: bio.isEmpty
                              ? null
                              : () => _copyToClipboard(bio, 'Bio'),
                        ),
                        Divider(color: glassToken.outlineVariant, height: 1),
                        _buildInfoField(
                          context,
                          icon: Icons.alternate_email_rounded,
                          title: username.isEmpty
                              ? 'Não informado'
                              : '@$username',
                          subtitle: 'Nome de usuário',
                          onTap: username.isEmpty
                              ? null
                              : () => _copyToClipboard(
                                  '@$username',
                                  'Nome de usuário',
                                ),
                        ),
                        Divider(color: glassToken.outlineVariant, height: 1),
                        _buildInfoField(
                          context,
                          icon: Icons.cake_outlined,
                          title: birthday.isEmpty ? 'Não informado' : birthday,
                          subtitle: 'Aniversário',
                        ),
                        Divider(color: glassToken.outlineVariant, height: 1),
                        const SizedBox(height: 24),

                        // Shared Media Section
                        const SharedMediaShowcase(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  ));
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 84),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 9),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: colorScheme.onPrimaryContainer, size: 22),
                const SizedBox(height: 5),
                Text(
                  label,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.1,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoField(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final glassToken = theme.colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          child: Row(
            children: [
              Icon(icon, size: 22, color: glassToken.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: glassToken.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: glassToken.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.copy_rounded,
                  size: 16,
                  color: glassToken.onSurfaceVariant.withValues(alpha: 0.5),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
