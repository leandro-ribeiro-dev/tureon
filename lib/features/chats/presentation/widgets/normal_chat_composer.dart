import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/chat_message_limits.dart';

/// The standard text-field + send button row.
class NormalChatComposer extends StatelessWidget {
  const NormalChatComposer({
    super.key,
    required this.textController,
    this.focusNode,
    required this.onSendMessage,
    required this.onAttachmentPressed,
    required this.isEditing,
    this.onCancelEdit,
    this.replyPreview,
    this.onCancelReply,
    required this.glassToken,
    required this.accent,
    required this.l10n,
    required this.isSecretChat,
  });

  final TextEditingController textController;
  final FocusNode? focusNode;
  final VoidCallback onSendMessage;
  final VoidCallback onAttachmentPressed;
  final bool isEditing;
  final VoidCallback? onCancelEdit;
  final String? replyPreview;
  final VoidCallback? onCancelReply;
  final ColorScheme glassToken;
  final Color accent;
  final AppLocalizations l10n;
  final bool isSecretChat;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (replyPreview != null && replyPreview!.isNotEmpty && !isEditing) ...[
          Row(
            children: [
              Icon(Icons.reply_rounded, size: 18, color: accent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  replyPreview!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: glassToken.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Cancelar resposta',
                visualDensity: VisualDensity.compact,
                onPressed: onCancelReply,
                icon: Icon(
                  Icons.close_rounded,
                  color: glassToken.onSurfaceVariant,
                ),
              ),
            ],
          ),
          Divider(height: 8, color: glassToken.outlineVariant),
        ],
        if (isEditing) ...[
          Row(
            children: [
              Icon(Icons.edit_outlined, size: 18, color: accent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Editando mensagem',
                  style: TextStyle(
                    color: accent,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Cancelar edição',
                visualDensity: VisualDensity.compact,
                onPressed: onCancelEdit,
                icon: Icon(
                  Icons.close_rounded,
                  color: glassToken.onSurfaceVariant,
                ),
              ),
            ],
          ),
          Divider(height: 8, color: glassToken.outlineVariant),
        ],
        Row(
          children: [
            if (!isEditing)
              IconButton(
                tooltip: l10n.addAttachment,
                icon: const Icon(Icons.add_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: glassToken.secondaryContainer,
                  foregroundColor: glassToken.onSecondaryContainer,
                ),
                onPressed: onAttachmentPressed,
              ),
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: glassToken.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  focusNode: focusNode,
                  controller: textController,
                  style: TextStyle(color: glassToken.onSurface, fontSize: 15),
                  minLines: 1,
                  maxLines: 5,
                  maxLength: ChatMessageLimits.maxTextLength,
                  maxLengthEnforcement: MaxLengthEnforcement.enforced,
                  buildCounter:
                      (
                        context, {
                        required currentLength,
                        required isFocused,
                        required maxLength,
                      }) => null,
                  textInputAction: TextInputAction.send,
                  keyboardType: TextInputType.multiline,
                  autocorrect: !isSecretChat,
                  enableSuggestions: !isSecretChat,
                  decoration: InputDecoration(
                    hintText: isSecretChat
                        ? l10n.composerHintSecret
                        : l10n.composerHintNormal,
                    hintStyle: TextStyle(
                      color: glassToken.onSurfaceVariant.withValues(alpha: 0.8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  onSubmitted: (_) => onSendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: textController,
              builder: (context, value, _) {
                final canSend = value.text.trim().isNotEmpty;
                return IconButton.filled(
                  tooltip: isEditing ? 'Salvar edição' : l10n.sendMessage,
                  onPressed: canSend ? onSendMessage : null,
                  style: IconButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: glassToken.outlineVariant,
                    disabledForegroundColor: glassToken.onSurfaceVariant,
                  ),
                  icon: Icon(
                    isEditing
                        ? Icons.check_rounded
                        : Icons.arrow_upward_rounded,
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}
