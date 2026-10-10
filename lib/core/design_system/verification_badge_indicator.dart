import 'package:flutter/material.dart';

import '../protocol/verification_badge.dart';

class VerificationBadgeIndicator extends StatelessWidget {
  const VerificationBadgeIndicator({
    super.key,
    required this.badge,
    required this.size,
  });

  final VerificationBadge badge;
  final double size;

  static ({IconData icon, Color color, String label, String explanation})
  _detailsFor(VerificationBadge badge, ColorScheme colorScheme) =>
      switch (badge) {
        VerificationBadge.verified => (
          icon: Icons.verified_rounded,
          color: colorScheme.primary,
          label: 'Verificado',
          explanation:
              'A equipe do Tureon confirmou a identidade deste perfil. '
              'O selo ajuda a distinguir a conta autêntica de perfis que '
              'possam tentar se passar por ela.',
        ),
        VerificationBadge.developer => (
          icon: Icons.code_rounded,
          color: colorScheme.tertiary,
          label: 'Desenvolvedor',
          explanation:
              'Este selo identifica uma conta reconhecida pela equipe do '
              'Tureon como participante do desenvolvimento do aplicativo '
              'ou de seus serviços.',
        ),
        VerificationBadge.celebrity => (
          icon: Icons.stars_rounded,
          color: colorScheme.secondary,
          label: 'Celebridade',
          explanation:
              'Este selo identifica uma figura pública reconhecida pela '
              'equipe do Tureon. Ele não significa que o Tureon endossa '
              'as opiniões ou o conteúdo publicado por essa pessoa.',
        ),
        VerificationBadge.none => (
          icon: Icons.verified_rounded,
          color: Colors.transparent,
          label: '',
          explanation: '',
        ),
      };

  static Future<void> showInformation(
    BuildContext context,
    VerificationBadge badge,
  ) {
    if (badge == VerificationBadge.none) return Future<void>.value();
    final details = _detailsFor(badge, Theme.of(context).colorScheme);
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(details.icon, color: details.color, size: 32),
        title: Text('Selo ${details.label.toLowerCase()}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(details.explanation),
            const SizedBox(height: 16),
            Text(
              'Os selos são atribuídos pela equipe do Tureon e não podem '
              'ser escolhidos ou alterados pelo titular da conta.',
              style: Theme.of(dialogContext).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Entendi'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (badge == VerificationBadge.none) return const SizedBox.shrink();
    final details = _detailsFor(badge, Theme.of(context).colorScheme);
    final tapTargetSize = size + 8;
    return Tooltip(
      message: details.label,
      child: Semantics(
        button: true,
        label: 'Selo ${details.label}. Toque para saber mais.',
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => showInformation(context, badge),
          child: SizedBox(
            width: tapTargetSize < 24 ? 24 : tapTargetSize,
            height: tapTargetSize < 24 ? 24 : tapTargetSize,
            child: Center(
              child: Icon(details.icon, size: size, color: details.color),
            ),
          ),
        ),
      ),
    );
  }
}
