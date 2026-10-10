import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/settings_providers.dart';
import '../../../../core/storage/message_records.dart';

class AccountStatusBanner extends ConsumerWidget {
  const AccountStatusBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    UserSession? session;
    try {
      final sessionAsync = ref.watch(activeSessionProvider);
      session = sessionAsync.asData?.value;
    } catch (_) {
      session = null;
    }

    final status = session?.accountStatus ?? 'active';

    if (status == 'active' || status.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final isUnderReview = status == 'under_review';
    final bgColor = theme.colorScheme.tertiaryContainer;
    final fgColor = theme.colorScheme.onTertiaryContainer;

    final titleText = isUnderReview
        ? 'Conta sob análise'
        : 'Conta com restrições';
    final messageText = isUnderReview
        ? 'Sua conta está sob análise de moderação. O envio de novas mensagens pode estar temporariamente limitado.'
        : 'Sua conta possui limitações temporárias de envio impostas pela moderação.';

    return MaterialBanner(
      backgroundColor: bgColor,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      leading: Icon(
        isUnderReview
            ? Icons.info_outline_rounded
            : Icons.warning_amber_rounded,
        color: fgColor,
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            titleText,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: fgColor,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 2),
          Text(messageText, style: TextStyle(color: fgColor, fontSize: 13)),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'A análise da moderação é processada automaticamente.',
                ),
              ),
            );
          },
          child: Text(
            'Saber mais',
            style: TextStyle(color: fgColor, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
