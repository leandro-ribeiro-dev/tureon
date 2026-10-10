import 'package:flutter/material.dart';

import '../../../../core/protocol/recipient.dart';
import '../../../../core/protocol/recipient_type.dart';

/// Reusable Avatar widget for recipients based on type.
class Avatar extends StatelessWidget {
  const Avatar({super.key, required this.recipient});

  final Recipient recipient;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CircleAvatar(
      backgroundColor: recipient.type == RecipientType.bot
          ? theme.colorScheme.primaryContainer
          : theme.colorScheme.surfaceContainerHighest,
      child: Icon(
        switch (recipient.type) {
          RecipientType.bot => Icons.auto_awesome_rounded,
          RecipientType.group => Icons.groups_rounded,
          RecipientType.channel => Icons.campaign_rounded,
          _ => Icons.person_rounded,
        },
        color: theme.colorScheme.primary,
        size: 20,
      ),
    );
  }
}
