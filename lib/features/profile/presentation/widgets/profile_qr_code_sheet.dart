import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/design_system/app_bottom_sheet.dart';
import '../../../../core/storage/message_records.dart';

class ProfileQrCodeBottomSheet extends StatelessWidget {
  const ProfileQrCodeBottomSheet({
    super.key,
    required this.profile,
  });

  final UserProfile? profile;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final username = profile?.username ?? 'usuario';
    final shareLink = 'https://tureon.app/u/$username';

    return AppBottomSheetContainer(
      title: 'QR Code do Contato',
      subtitle: 'Aponte a câmera para iniciar uma conversa no Tureon',
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.qr_code_2_rounded,
                  size: 180,
                  color: Colors.grey[900],
                ),
                const SizedBox(height: 8),
                Text(
                  '@$username',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SelectableText(
            shareLink,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton.icon(
              onPressed: () {
                Navigator.pop(context);
                Clipboard.setData(ClipboardData(text: shareLink));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Link de perfil copiado!')),
                );
              },
              icon: const Icon(Icons.copy_rounded),
              label: const Text('Copiar link'),
            ),
          ),
        ],
      ),
    );
  }
}
