import 'package:flutter/material.dart';

/// Competitor-styled System Message Bubble (e.g. E2EE notices, group events, member joins).
/// Renders a centered pill badge with subtle surface container background.
class SystemMessageBubble extends StatelessWidget {
  const SystemMessageBubble({super.key, required this.message, this.icon});

  final String message;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Check if the message contains encryption or lock keywords for auto lock icon
    final isSecurityNotice =
        icon != null ||
        message.contains('criptografia') ||
        message.contains('E2EE') ||
        message.contains('protegida');

    final effectiveIcon =
        icon ?? (isSecurityNotice ? Icons.lock_outline_rounded : null);

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (effectiveIcon != null) ...[
              Icon(effectiveIcon, size: 14, color: colorScheme.primary),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurfaceVariant,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
