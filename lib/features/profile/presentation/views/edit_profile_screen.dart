import 'package:flutter/material.dart';

import '../../../../core/design_system/app_avatar.dart';
import '../../../../core/storage/message_records.dart';
import 'edit_field_screen.dart';

/// Screen listing individual profile fields (WhatsApp / Telegram style).
/// Tapping any field opens a dedicated [EditFieldScreen] with title,
/// save checkmark in toolbar, input field, and detailed explanation text.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({
    super.key,
    required this.currentUser,
    required this.onSave,
  });

  final UserProfile currentUser;
  final Future<UserProfile> Function(UserProfile profile) onSave;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late UserProfile _profile;

  @override
  void initState() {
    super.initState();
    _profile = widget.currentUser;
  }

  Future<void> _openFieldEditor(ProfileFieldType fieldType) async {
    final updated = await Navigator.of(context).push<UserProfile>(
      MaterialPageRoute(
        builder: (_) => EditFieldScreen(
          fieldType: fieldType,
          currentUser: _profile,
          onSave: widget.onSave,
        ),
      ),
    );
    if (updated != null && mounted) {
      setState(() => _profile = updated);
    }
  }

  Widget _fieldTile(
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
                    subtitle.isEmpty ? 'Toque para adicionar' : subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: subtitle.isEmpty
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: const Text('Editar Perfil')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              // Avatar Preview Section
              Center(
                child: GestureDetector(
                  onTap: () => _openFieldEditor(ProfileFieldType.avatarUrl),
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: accentColor,
                        child: AppAvatar(
                          name: _profile.displayName,
                          imageUrl: _profile.avatarUrl,
                          radius: 48,
                          verificationBadge: _profile.verificationBadge,
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: accentColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.scaffoldBackgroundColor,
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Fields List
              _fieldTile(
                context,
                icon: Icons.person_outline_rounded,
                title: 'Nome',
                subtitle: _profile.displayName,
                onTap: () => _openFieldEditor(ProfileFieldType.displayName),
              ),

              _fieldTile(
                context,
                icon: Icons.alternate_email_rounded,
                title: 'Nome de usuário',
                subtitle: _profile.username.isEmpty
                    ? ''
                    : '@${_profile.username}',
                onTap: () => _openFieldEditor(ProfileFieldType.username),
              ),

              _fieldTile(
                context,
                icon: Icons.info_outline_rounded,
                title: 'Bio',
                subtitle: _profile.bio ?? '',
                onTap: () => _openFieldEditor(ProfileFieldType.bio),
              ),

              _fieldTile(
                context,
                icon: Icons.phone_outlined,
                title: 'Número de telefone',
                subtitle: _profile.phoneE164,
                onTap: () => _openFieldEditor(ProfileFieldType.phone),
              ),

              _fieldTile(
                context,
                icon: Icons.cake_outlined,
                title: 'Data de nascimento',
                subtitle: _profile.birthday,
                onTap: () => _openFieldEditor(ProfileFieldType.birthday),
              ),

              _fieldTile(
                context,
                icon: Icons.public_outlined,
                title: 'País (código ISO)',
                subtitle: _profile.countryCode,
                onTap: () => _openFieldEditor(ProfileFieldType.country),
              ),

              _fieldTile(
                context,
                icon: Icons.image_outlined,
                title: 'URL da Foto de Perfil',
                subtitle: _profile.avatarUrl ?? '',
                onTap: () => _openFieldEditor(ProfileFieldType.avatarUrl),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
