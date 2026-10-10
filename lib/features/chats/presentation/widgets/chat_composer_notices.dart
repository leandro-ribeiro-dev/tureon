import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';

class SlowModeCountdownNotice extends StatelessWidget {
  const SlowModeCountdownNotice({
    super.key,
    required this.message,
    required this.colorScheme,
    required this.accent,
  });

  final String message;
  final ColorScheme colorScheme;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 56),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.hourglass_top_rounded, color: accent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A centered icon + text notice used for read-only / restricted / moderation states.
class ChatComposerNotice extends StatelessWidget {
  const ChatComposerNotice({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.text,
    required this.glassToken,
  });

  final IconData icon;
  final Color iconColor;
  final String text;
  final ColorScheme glassToken;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: glassToken.onSurfaceVariant,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatJoinAction extends StatelessWidget {
  const ChatJoinAction({
    super.key,
    required this.label,
    required this.isJoining,
    required this.onJoin,
    required this.colorScheme,
  });

  final String label;
  final bool isJoining;
  final VoidCallback? onJoin;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: FilledButton.icon(
      onPressed: isJoining ? null : onJoin,
      icon: isJoining
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.group_add_outlined),
      label: Text(isJoining ? 'Entrando…' : label),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
    ),
  );
}

/// The prominent START button for bot chats that haven't exchanged messages yet.
class ChatBotStartButton extends StatelessWidget {
  const ChatBotStartButton({
    super.key,
    required this.accent,
    required this.l10n,
    required this.onStartBot,
  });

  final Color accent;
  final AppLocalizations l10n;
  final VoidCallback onStartBot;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onStartBot,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                l10n.botStartButton,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
