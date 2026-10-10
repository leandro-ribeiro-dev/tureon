import 'package:flutter/material.dart';

import '../../../../core/design_system/app_avatar.dart';
import '../../../../core/design_system/verified_name.dart';
import '../../../../core/protocol/verification_badge.dart';
import '../../../../core/storage/message_records.dart';

class SettingsHeaderTile extends StatelessWidget {
  const SettingsHeaderTile({
    super.key,
    required this.user,
    required this.onTap,
  });

  final UserProfile? user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = user?.displayName ?? 'Usuário Tureon';
    final username = user?.username ?? 'usuario_tureon';
    final bioText = user?.bio?.isNotEmpty == true
        ? user!.bio!
        : 'Compartilhe um pensamento';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: AppAvatar(
        name: name,
        id: user?.userId,
        imageUrl: user?.avatarUrl,
        radius: 28,
        verificationBadge: user?.verificationBadge ?? VerificationBadge.none,
      ),
      title: VerifiedName(
        name: name,
        badge: user?.verificationBadge ?? VerificationBadge.none,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      subtitle: Text(
        '@$username • $bioText',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
      ),
      trailing: Icon(Icons.qr_code_2_rounded, color: theme.colorScheme.primary),
      onTap: onTap,
    );
  }
}
