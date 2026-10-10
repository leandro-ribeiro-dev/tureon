import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../l10n/app_localizations_extensions.dart';
import '../../../../core/protocol/recipient_type.dart';
import '../../domain/chat_composer_state.dart';
import '../controllers/chat_composer_notifier.dart';
import '../controllers/chat_slow_mode_cooldown.dart';
import '../../domain/chat_message_limits.dart';
import 'normal_chat_composer.dart';
import 'chat_composer_notices.dart';

/// Unified composer area at the bottom of the ChatScreen.
///
/// Reads [ChatComposerState] and swaps the **content** inside the same
/// surface region — never hides the area entirely, never uses popup/snackbar.
/// Mirrors Telegram's behaviour of replacing the input field with an
/// informational notice when the user cannot send.
class ChatInputArea extends ConsumerWidget {
  static const maxMessageLength = ChatMessageLimits.maxTextLength;

  const ChatInputArea({
    super.key,
    required this.composerParams,
    required this.textController,
    this.focusNode,
    required this.onSendMessage,
    required this.onStartBot,
    required this.onAttachmentPressed,
    this.isSecretChat = false,
    this.isEditing = false,
    this.onCancelEdit,
    this.replyPreview,
    this.onCancelReply,
    this.onJoin,
    this.isJoining = false,
    this.margin = const EdgeInsets.only(top: 4),
  });

  final ChatComposerParams composerParams;
  final TextEditingController textController;
  final FocusNode? focusNode;
  final VoidCallback onSendMessage;
  final VoidCallback onStartBot;
  final VoidCallback onAttachmentPressed;
  final bool isSecretChat;
  final bool isEditing;
  final VoidCallback? onCancelEdit;
  final String? replyPreview;
  final VoidCallback? onCancelReply;
  final VoidCallback? onJoin;
  final bool isJoining;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(chatComposerProvider(composerParams));
    final cooldownProvider = chatSlowModeCooldownProvider.select(
      (cooldowns) =>
          cooldowns[composerParams.effectiveSlowModeCooldownKey] ?? 0,
    );
    ref.listen<int>(cooldownProvider, (previous, remaining) {
      if (remaining > 0) focusNode?.unfocus();
    });
    final slowModeRemaining = ref.watch(cooldownProvider);
    final slowModeCountdown =
        state is ComposerNormal &&
            !isEditing &&
            (composerParams.recipientType == RecipientType.group ||
                composerParams.recipientType == RecipientType.channel) &&
            composerParams.userRole == ChatUserRole.member &&
            composerParams.isMember &&
            composerParams.canSendInGroup &&
            slowModeRemaining > 0
        ? slowModeRemaining
        : null;
    final glassToken = Theme.of(context).colorScheme;
    final accent = isSecretChat ? glassToken.tertiary : glassToken.primary;
    final l10n = context.safeLocalizations;
    final surfaceColor =
        Theme.of(context).navigationBarTheme.backgroundColor ??
        Theme.of(context).colorScheme.surfaceContainer;

    return Padding(
      padding: margin,
      child: Container(
        decoration: BoxDecoration(
          color: surfaceColor,
          border: Border(
            top: BorderSide(
              color: glassToken.outlineVariant.withValues(alpha: 0.45),
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: slowModeCountdown != null
              ? SlowModeCountdownNotice(
                  message: l10n.groupSlowModeCountdownText(slowModeCountdown),
                  colorScheme: glassToken,
                  accent: accent,
                )
              : AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  child: _buildContent(state, glassToken, accent, l10n),
                ),
        ),
      ),
    );
  }

  Widget _buildContent(
    ChatComposerState state,
    ColorScheme glassToken,
    Color accent,
    AppLocalizations l10n,
  ) {
    return switch (state) {
      ComposerNormal() => NormalChatComposer(
        key: const ValueKey('composer_normal'),
        textController: textController,
        focusNode: focusNode,
        onSendMessage: onSendMessage,
        onAttachmentPressed: onAttachmentPressed,
        isEditing: isEditing,
        onCancelEdit: onCancelEdit,
        replyPreview: replyPreview,
        onCancelReply: onCancelReply,
        glassToken: glassToken,
        accent: accent,
        l10n: l10n,
        isSecretChat: isSecretChat,
      ),

      ComposerDisabled() => ChatComposerNotice(
        key: const ValueKey('composer_disabled'),
        icon: Icons.sync_rounded,
        iconColor: glassToken.onSurfaceVariant,
        text: 'Aguardando dados da conversa…',
        glassToken: glassToken,
      ),

      ComposerJoinRequired() => ChatJoinAction(
        key: const ValueKey('composer_join_required'),
        label: composerParams.recipientType == RecipientType.channel
            ? 'Entrar no canal'
            : 'Entrar no grupo',
        isJoining: isJoining,
        onJoin: onJoin,
        colorScheme: glassToken,
      ),

      ComposerChannelReadOnly() => ChatComposerNotice(
        key: const ValueKey('composer_channel_readonly'),
        icon: Icons.campaign_outlined,
        iconColor: glassToken.onSurfaceVariant,
        text: l10n.channelReadOnlyText,
        glassToken: glassToken,
      ),

      ComposerOfficialBotReadOnly() => ChatComposerNotice(
        key: const ValueKey('composer_official_bot_read_only'),
        icon: Icons.smart_toy_outlined,
        iconColor: glassToken.primary,
        text: l10n.officialBotReadOnlyText,
        glassToken: glassToken,
      ),

      ComposerRestricted(:final until) => ChatComposerNotice(
        key: const ValueKey('composer_restricted'),
        icon: Icons.block_rounded,
        iconColor: Colors.orangeAccent,
        text: until == null
            ? l10n.groupRestrictedText
            : l10n.groupRestrictedUntilText(_formatDateTime(until)),
        glassToken: glassToken,
      ),

      ComposerModerationBlocked(:final reason, :final retryAt) =>
        ChatComposerNotice(
          key: const ValueKey('composer_moderation'),
          icon: Icons.gavel_rounded,
          iconColor: Colors.redAccent.withValues(alpha: 0.9),
          text: _moderationText(reason, retryAt, l10n),
          glassToken: glassToken,
        ),

      ComposerBotNeedsStart() => ChatBotStartButton(
        key: const ValueKey('composer_bot_start'),
        accent: accent,
        l10n: l10n,
        onStartBot: onStartBot,
      ),
    };
  }

  String _moderationText(
    ModerationReason reason,
    DateTime? retryAt,
    AppLocalizations l10n,
  ) {
    switch (reason) {
      case ModerationReason.rateLimited:
        if (retryAt != null) {
          final diff = retryAt.difference(DateTime.now());
          final seconds = diff.inSeconds > 0 ? diff.inSeconds : 0;
          return '${l10n.moderationRateLimited} (${seconds}s)';
        }
        return l10n.moderationRateLimited;
      case ModerationReason.banned:
        return l10n.moderationBanned;
      case ModerationReason.underReview:
        return l10n.moderationUnderReview;
    }
  }

  String _formatDateTime(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final year = dt.year;
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }
}

// ---------------------------------------------------------------------------
// Private sub-widgets — keep the switch expression above clean.
// ---------------------------------------------------------------------------
