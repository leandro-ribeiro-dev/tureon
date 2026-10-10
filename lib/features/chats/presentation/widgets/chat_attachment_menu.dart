import 'package:flutter/material.dart';

import '../../../../core/design_system/app_bottom_sheet.dart';

export '../../domain/chat_attachment_action.dart';
import '../../domain/chat_attachment_action.dart';

Future<ChatAttachmentAction?> showAttachmentMenu(BuildContext context) =>
    AppBottomSheet.show<ChatAttachmentAction>(
      context: context,
      builder: (sheetContext) => AppBottomSheetContainer(
        title: 'Compartilhar',
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Wrap(
            spacing: 20,
            runSpacing: 22,
            alignment: WrapAlignment.center,
            children: [
              _AttachmentOption(
                icon: Icons.photo_outlined,
                label: 'Foto',
                color: Colors.blueAccent,
                value: ChatAttachmentAction.photo,
                parentContext: sheetContext,
              ),
              _AttachmentOption(
                icon: Icons.camera_alt_outlined,
                label: 'Câmera',
                color: Colors.pinkAccent,
                value: ChatAttachmentAction.camera,
                parentContext: sheetContext,
              ),
              _AttachmentOption(
                icon: Icons.videocam_outlined,
                label: 'Vídeo',
                color: Colors.deepPurpleAccent,
                value: ChatAttachmentAction.video,
                parentContext: sheetContext,
              ),
              _AttachmentOption(
                icon: Icons.gif_box_outlined,
                label: 'GIF',
                color: Colors.cyan,
                value: ChatAttachmentAction.gif,
                parentContext: sheetContext,
              ),
              _AttachmentOption(
                icon: Icons.insert_drive_file_outlined,
                label: 'Arquivo',
                color: Colors.orangeAccent,
                value: ChatAttachmentAction.file,
                parentContext: sheetContext,
              ),
              _AttachmentOption(
                icon: Icons.location_on_outlined,
                label: 'Localização',
                color: Theme.of(context).colorScheme.primary,
                value: ChatAttachmentAction.location,
                parentContext: sheetContext,
              ),
              _AttachmentOption(
                icon: Icons.mic_none_rounded,
                label: 'Áudio',
                color: Colors.teal,
                value: ChatAttachmentAction.voice,
                parentContext: sheetContext,
              ),
            ],
          ),
        ),
      ),
    );

class _AttachmentOption extends StatelessWidget {
  const _AttachmentOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.value,
    required this.parentContext,
  });

  final IconData icon;
  final String label;
  final Color color;
  final ChatAttachmentAction value;
  final BuildContext parentContext;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 76,
      child: InkWell(
        onTap: () => Navigator.pop(parentContext, value),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Icon(icon, color: color, size: 25),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
