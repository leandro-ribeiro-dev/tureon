import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/chat_message.dart';
import '../../domain/chat_repository.dart';

/// Small, lazy previews for the supported attachment types. Images/GIFs load
/// while their row is visible; large files are fetched only when opened.
class ChatAttachmentPreview extends StatefulWidget {
  const ChatAttachmentPreview({
    super.key,
    required this.message,
    required this.repository,
  });

  final ChatMessage message;
  final ChatRepository repository;

  @override
  State<ChatAttachmentPreview> createState() => _ChatAttachmentPreviewState();
}

class _ChatAttachmentPreviewState extends State<ChatAttachmentPreview> {
  Future<String>? _imagePath;
  bool _opening = false;

  ChatAttachment? get _attachment => widget.message.attachment;

  @override
  void didUpdateWidget(covariant ChatAttachmentPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.message.attachment?.mediaId !=
        widget.message.attachment?.mediaId) {
      _imagePath = null;
    }
  }

  bool get _isInlineImage =>
      widget.message.type == ChatMessageType.image ||
      widget.message.type == ChatMessageType.gif;

  @override
  Widget build(BuildContext context) {
    final attachment = _attachment;
    if (attachment == null) return const SizedBox.shrink();
    if (attachment.isLocation) return _buildLocation(context, attachment);
    if (_isInlineImage) {
      _imagePath ??= widget.repository.resolveAttachmentLocalPath(attachment);
      return FutureBuilder<String>(
        future: _imagePath,
        builder: (context, snapshot) {
          final path = snapshot.data;
          if (path == null) {
            return _ImagePlaceholder(
              error: snapshot.hasError,
              onTap: snapshot.hasError ? _openAttachment : null,
            );
          }
          return GestureDetector(
            onTap: _openAttachment,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 360,
                  maxHeight: 360,
                ),
                child: Image.file(
                  File(path),
                  fit: BoxFit.cover,
                  cacheWidth: 900,
                  errorBuilder: (context, error, stackTrace) =>
                      _ImagePlaceholder(error: true, onTap: _openAttachment),
                ),
              ),
            ),
          );
        },
      );
    }
    return _buildFileCard(context, attachment);
  }

  Widget _buildLocation(BuildContext context, ChatAttachment attachment) {
    final colorScheme = Theme.of(context).colorScheme;
    final label = attachment.placeName?.trim().isNotEmpty == true
        ? attachment.placeName!.trim()
        : 'Localização';
    return InkWell(
      onTap: () async {
        final uri = Uri.https('www.google.com', '/maps/search/', {
          'api': '1',
          'query': '${attachment.latitude},${attachment.longitude}',
        });
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 300,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Icon(
                  Icons.location_on_rounded,
                  size: 48,
                  color: colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              '${attachment.latitude!.toStringAsFixed(5)}, ${attachment.longitude!.toStringAsFixed(5)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileCard(BuildContext context, ChatAttachment attachment) {
    final colorScheme = Theme.of(context).colorScheme;
    final icon = switch (widget.message.type) {
      ChatMessageType.video => Icons.play_circle_outline_rounded,
      ChatMessageType.audio => Icons.music_note_rounded,
      ChatMessageType.voiceNote => Icons.play_arrow_rounded,
      ChatMessageType.contactCard => Icons.person_rounded,
      ChatMessageType.sticker => Icons.emoji_emotions_outlined,
      _ => Icons.insert_drive_file_outlined,
    };
    return InkWell(
      onTap: _opening ? null : _openAttachment,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        constraints: const BoxConstraints(minWidth: 0, maxWidth: 320),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              child: _opening
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(icon),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.message.type == ChatMessageType.voiceNote)
                    ExcludeSemantics(
                      child: SizedBox(
                        width: 180,
                        height: 28,
                        child: CustomPaint(
                          painter: _VoiceWaveformPlaceholder(
                            colorScheme.primary,
                          ),
                        ),
                      ),
                    )
                  else
                    Text(
                      attachment.fileName.isEmpty
                          ? 'Anexo'
                          : attachment.fileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                    ),
                  Text(
                    _metadata(attachment),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _metadata(ChatAttachment attachment) {
    if (attachment.durationMillis != null && attachment.durationMillis! > 0) {
      final seconds = attachment.durationMillis! ~/ 1000;
      return '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
    }
    final size = attachment.sizeBytes;
    if (size <= 0) return 'Toque para abrir';
    if (size < 1024 * 1024) return '${(size / 1024).ceil()} KB · Abrir';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB · Abrir';
  }

  Future<void> _openAttachment() async {
    final attachment = _attachment;
    if (attachment == null || _opening || !mounted) return;
    setState(() => _opening = true);
    try {
      final path = await widget.repository.resolveAttachmentLocalPath(
        attachment,
      );
      if (!mounted) return;
      final result = await OpenFilex.open(path);
      if (result.type != ResultType.done && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.message.isEmpty
                  ? 'Não foi possível abrir o arquivo.'
                  : result.message,
            ),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Não foi possível abrir a mídia: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({required this.error, this.onTap});

  final bool error;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 300,
        height: 190,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: error
              ? Icon(Icons.download_rounded, color: colorScheme.primary)
              : const SizedBox.square(
                  dimension: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
        ),
      ),
    );
  }
}

/// A neutral voice-message motif while the protocol has no waveform samples.
/// This does not represent playback progress or the attachment's amplitude.
class _VoiceWaveformPlaceholder extends CustomPainter {
  const _VoiceWaveformPlaceholder(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: .55)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    const heights = [6.0, 10.0, 16.0, 22.0, 12.0, 18.0, 8.0];
    for (var i = 0; i < size.width / 4; i++) {
      final height = heights[i % heights.length];
      canvas.drawLine(
        Offset(i * 4 + 1, (size.height - height) / 2),
        Offset(i * 4 + 1, (size.height + height) / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _VoiceWaveformPlaceholder oldDelegate) =>
      color != oldDelegate.color;
}
