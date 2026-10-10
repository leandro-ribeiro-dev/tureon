import 'package:flutter/material.dart';

import '../../../../core/design_system/app_bottom_sheet.dart';
import '../../../../core/protocol/protocol_models.dart';

class ChatOverflowMenuBottomSheet extends StatelessWidget {
  const ChatOverflowMenuBottomSheet({
    super.key,
    required this.recipient,
    required this.isSecretMode,
    required this.onViewProfile,
    required this.onClearHistory,
    required this.onDeleteConversation,
    this.onAddMember,
  });

  final Recipient recipient;
  final bool isSecretMode;
  final ValueChanged<Recipient> onViewProfile;
  final VoidCallback onClearHistory;
  final VoidCallback onDeleteConversation;
  final VoidCallback? onAddMember;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AppBottomSheetContainer(
      title: recipient.name,
      subtitle: recipient.type == RecipientType.group
          ? 'Opções do Grupo'
          : recipient.type == RecipientType.channel
          ? 'Opções do Canal'
          : 'Opções da Conversa',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppBottomSheetTile(
            icon: Icons.person_outlined,
            title: 'Ver Perfil',
            onTap: () {
              Navigator.pop(context);
              onViewProfile(recipient);
            },
          ),
          if (onAddMember != null)
            AppBottomSheetTile(
              icon: Icons.person_add_alt_1_outlined,
              title: 'Adicionar participante',
              onTap: () {
                Navigator.pop(context);
                onAddMember!();
              },
            ),
          if (isSecretMode)
            AppBottomSheetTile(
              icon: Icons.lock_outline_rounded,
              title: 'Chat secreto indisponível',
              subtitle: 'A criptografia E2EE ainda não está configurada.',
              iconColor: colorScheme.tertiary,
              onTap: () {},
            ),
          AppBottomSheetTile(
            icon: Icons.notifications_off_outlined,
            title: 'Silenciar Notificações',
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Notificações de ${recipient.name} silenciadas',
                  ),
                ),
              );
            },
          ),
          AppBottomSheetTile(
            icon: Icons.cleaning_services_outlined,
            title: 'Limpar Histórico',
            onTap: () {
              Navigator.pop(context);
              onClearHistory();
            },
          ),
          AppBottomSheetTile(
            icon: Icons.delete_outline_rounded,
            title: 'Apagar Conversa',
            isDestructive: true,
            onTap: () {
              Navigator.pop(context);
              onDeleteConversation();
            },
          ),
        ],
      ),
    );
  }
}
