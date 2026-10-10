import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/protocol/protocol_models.dart';
import '../../../../l10n/app_localizations_extensions.dart';
import '../../domain/chat_message.dart' as chat_domain;

enum _MessageContextAction { reply, edit, delete, translate, copy }

Future<void> showMessageContextMenu({
  required BuildContext context,
  required Offset globalPosition,
  required WidgetRef ref,
  required MessageItem message,
  required chat_domain.ChatMessage serverMessage,
  required String? localUserId,
  bool allowMessageMutations = true,
  required Function(MessageItem, {String? sourceLanguage}) onTranslate,
  required Function(chat_domain.ChatMessage) onEdit,
  required Function(chat_domain.ChatMessage) onDelete,
  required Function(chat_domain.ChatMessage) onReply,
}) async {
  final l10n = context.safeLocalizations;
  final isMine = serverMessage.senderRecipientId == localUserId;
  final overlay = Navigator.of(context).overlay?.context.findRenderObject();
  if (overlay is! RenderBox) return;
  final localPosition = overlay.globalToLocal(globalPosition);
  final anchor = RelativeRect.fromRect(
    localPosition & Size.zero,
    Offset.zero & overlay.size,
  );
  final canTranslate = !isMine;

  final action = await showMenu<_MessageContextAction>(
    context: context,
    position: anchor,
    items: [
      PopupMenuItem(
        value: _MessageContextAction.reply,
        child: _MessageMenuItem(icon: Icons.reply_rounded, label: 'Responder'),
      ),
      if (canTranslate)
        PopupMenuItem(
          value: _MessageContextAction.translate,
          child: _MessageMenuItem(
            icon: Icons.translate_rounded,
            label: l10n.translateMessage,
          ),
        ),
      PopupMenuItem(
        value: _MessageContextAction.copy,
        child: _MessageMenuItem(
          icon: Icons.copy_rounded,
          label: l10n.msgMenuCopyText,
        ),
      ),
      if (isMine && allowMessageMutations)
        PopupMenuItem(
          value: _MessageContextAction.edit,
          child: _MessageMenuItem(
            icon: Icons.edit_outlined,
            label: l10n.msgMenuEdit,
          ),
        ),
      if (isMine && allowMessageMutations)
        PopupMenuItem(
          value: _MessageContextAction.delete,
          child: _MessageMenuItem(
            icon: Icons.delete_outline_rounded,
            label: l10n.msgMenuDelete,
            color: Theme.of(context).colorScheme.error,
          ),
        ),
    ],
  );

  if (!context.mounted || action == null) return;

  switch (action) {
    case _MessageContextAction.reply:
      onReply(serverMessage);
      break;
    case _MessageContextAction.edit:
      onEdit(serverMessage);
      break;
    case _MessageContextAction.delete:
      onDelete(serverMessage);
      break;
    case _MessageContextAction.translate:
      onTranslate(message);
      break;
    case _MessageContextAction.copy:
      await Clipboard.setData(ClipboardData(text: message.text ?? ''));
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.msgMenuCopied)));
      break;
  }
}

class _MessageMenuItem extends StatelessWidget {
  const _MessageMenuItem({required this.icon, required this.label, this.color});

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final foregroundColor = color ?? Theme.of(context).colorScheme.onSurface;
    return Row(
      children: [
        Icon(icon, size: 20, color: foregroundColor),
        const SizedBox(width: 12),
        Text(label, style: TextStyle(color: foregroundColor)),
      ],
    );
  }
}
