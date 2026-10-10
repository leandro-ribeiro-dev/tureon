import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../protocol/delivery_status.dart';
import '../../l10n/app_localizations_extensions.dart';

part 'message_bubble/message_text.dart';
part 'message_bubble/bubble_shape.dart';

/// Telegram-style conversation geometry using the app's existing theme.
/// Supports inline translation display with source language label and "Ver original" link.
class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.text,
    required this.isMine,
    this.timestamp,
    this.senderName,
    this.status = DeliveryStatus.read,
    this.isSecretChat = false,
    this.radius = 18.0,
    this.mediaIsVisual = false,
    this.isFirstInGroup = true,
    this.isLastInGroup = true,
    this.translatedText,
    this.isTranslating = false,
    this.sourceLanguage,
    this.fontSize = 15,
    this.isShowingOriginal = false,
    this.onToggleOriginal,
    this.onTapAt,
    this.onLongPressAt,
    this.onRetry,
    this.mediaPreview,
    this.replyPreview,
    this.onReply,
  });

  final String text;
  final bool isMine;
  final DateTime? timestamp;
  final String? senderName;
  final DeliveryStatus status;
  final bool isSecretChat;
  final double radius;

  final String? translatedText;
  final bool isTranslating;
  final String? sourceLanguage;
  final double fontSize;
  final bool isShowingOriginal;
  final VoidCallback? onToggleOriginal;
  final ValueChanged<Offset>? onTapAt;
  final ValueChanged<Offset>? onLongPressAt;
  final VoidCallback? onRetry;
  final Widget? mediaPreview;
  final bool mediaIsVisual;
  final bool isFirstInGroup;
  final bool isLastInGroup;
  final String? replyPreview;
  final VoidCallback? onReply;

  String _formatTime(DateTime? time) {
    if (time == null) return '';
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String? _codeContent(String text) {
    final fenced = RegExp(r'^```[^\n]*\n([\s\S]*?)\n?```$').firstMatch(text);
    if (fenced != null) return fenced.group(1);

    final inline = RegExp(r'^`([^`\n]+)`$').firstMatch(text);
    if (inline != null) return inline.group(1);
    return null;
  }

  Widget _buildMessageText(
    BuildContext context,
    String displayText,
    Color textColor, {
    Widget? trailing,
  }) {
    final code = _codeContent(displayText);
    if (code == null) {
      return _RichMessageText(
        text: displayText,
        color: textColor,
        fontSize: fontSize,
        trailing: trailing,
      );
    }

    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.safeLocalizations;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(10, 8, 4, 8),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              code,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: fontSize,
                height: 1.3,
                color: textColor,
                backgroundColor: colorScheme.primary.withValues(alpha: 0.12),
              ),
            ),
          ),
          IconButton(
            tooltip: l10n.copyCode,
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            icon: const Icon(Icons.copy_rounded, size: 16),
            onPressed: () => Clipboard.setData(ClipboardData(text: code)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(Color iconColor, String retryTooltip) {
    return switch (status) {
      DeliveryStatus.sent => Icon(
        Icons.check_rounded,
        size: 14,
        color: iconColor,
      ),
      DeliveryStatus.delivered => Icon(
        Icons.done_all_rounded,
        size: 14,
        color: iconColor.withValues(alpha: 0.7),
      ),
      DeliveryStatus.read => Icon(
        Icons.done_all_rounded,
        size: 14,
        color: iconColor,
      ),
      DeliveryStatus.pending || DeliveryStatus.sending => Icon(
        Icons.schedule_rounded,
        size: 14,
        color: iconColor,
      ),
      DeliveryStatus.failed when onRetry != null => IconButton(
        onPressed: onRetry,
        tooltip: retryTooltip,
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
        icon: Icon(Icons.refresh_rounded, size: 16, color: iconColor),
      ),
      DeliveryStatus.failed => Icon(
        Icons.error_outline_rounded,
        size: 14,
        color: iconColor,
      ),
      DeliveryStatus.unspecified => const SizedBox.shrink(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final glassToken = Theme.of(context).colorScheme;
    final l10n = context.safeLocalizations;

    // Determine opaque colors according to specs
    final Color bubbleColor;
    final Color textColor;
    final Color metaColor;

    if (isMine) {
      bubbleColor = isSecretChat
          ? glassToken.tertiaryContainer
          : glassToken.primaryContainer;
      textColor = isSecretChat
          ? glassToken.onTertiaryContainer
          : glassToken.onPrimaryContainer;
      metaColor = textColor.withValues(alpha: 0.68);
    } else {
      bubbleColor = glassToken.surfaceContainerHigh;
      textColor = glassToken.onSurface;
      metaColor = glassToken.onSurfaceVariant;
    }

    final borderRadius = BorderRadius.only(
      topLeft: Radius.circular(!isMine && !isFirstInGroup ? 5 : radius),
      topRight: Radius.circular(isMine && !isFirstInGroup ? 5 : radius),
      bottomLeft: Radius.circular(
        isMine
            ? radius
            : isLastInGroup
            ? 4
            : 5,
      ),
      bottomRight: Radius.circular(
        !isMine
            ? radius
            : isLastInGroup
            ? 4
            : 5,
      ),
    );

    final displayText = (translatedText != null && !isShowingOriginal)
        ? translatedText!
        : text;

    final inlineMetadata =
        (timestamp != null || isMine) &&
        displayText.trim().isNotEmpty &&
        _codeContent(displayText) == null;
    final overlayMetadata =
        mediaIsVisual &&
        mediaPreview != null &&
        displayText.trim().isEmpty &&
        translatedText == null &&
        !isTranslating;
    final metadata = Align(
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (timestamp != null) ...[
            Text(
              _formatTime(timestamp),
              style: TextStyle(fontSize: 11, color: metaColor),
            ),
            const SizedBox(width: 4),
          ],
          if (isMine) _buildStatusIcon(metaColor, l10n.retrySendingMessage),
        ],
      ),
    );
    final visualPreview = overlayMetadata
        ? Stack(
            children: [
              mediaPreview!,
              Positioned(
                right: 8,
                bottom: 8,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: .6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (timestamp != null)
                          Text(
                            _formatTime(timestamp),
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                            ),
                          ),
                        if (isMine) ...[
                          const SizedBox(width: 4),
                          _buildStatusIcon(
                            Colors.white,
                            l10n.retrySendingMessage,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          )
        : mediaPreview;

    return LayoutBuilder(
      builder: (context, constraints) => Align(
        alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
        child: GestureDetector(
          onTapUp: onTapAt == null
              ? null
              : (details) => onTapAt!(details.globalPosition),
          onLongPressStart: onLongPressAt == null
              ? null
              : (details) => onLongPressAt!(details.globalPosition),
          onHorizontalDragEnd: onReply == null
              ? null
              : (details) {
                  if ((details.primaryVelocity ?? 0) > 280) onReply!.call();
                },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
            constraints: BoxConstraints(
              maxWidth: (constraints.maxWidth * 0.84).clamp(0, 440),
            ),
            decoration: ShapeDecoration(
              color: bubbleColor,
              shape: _BubbleShape(
                borderRadius: borderRadius,
                isMine: isMine,
                tail: isLastInGroup && !overlayMetadata,
              ),
              shadows: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .06),
                  blurRadius: 1,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: IntrinsicWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children:
                    [
                          if (!isMine &&
                              isFirstInGroup &&
                              senderName != null &&
                              senderName!.isNotEmpty) ...[
                            Text(
                              senderName!,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: glassToken.primary,
                              ),
                            ),
                            const SizedBox(height: 2),
                          ],
                          if (replyPreview != null &&
                              replyPreview!.isNotEmpty) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: (isMine ? textColor : glassToken.primary)
                                    .withValues(alpha: 0.09),
                                borderRadius: BorderRadius.circular(8),
                                border: Border(
                                  left: BorderSide(
                                    color: isMine
                                        ? textColor
                                        : glassToken.primary,
                                    width: 3,
                                  ),
                                ),
                              ),
                              child: Text(
                                replyPreview!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: textColor.withValues(alpha: 0.82),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),
                          ],
                          if (mediaPreview != null) ...[
                            visualPreview!,
                            if (text.trim().isNotEmpty)
                              const SizedBox(height: 6),
                          ],

                          // Inline translation header label
                          if (translatedText != null) ...[
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Icon(
                                  Icons.translate_rounded,
                                  size: 13,
                                  color: isMine
                                      ? metaColor
                                      : glassToken.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isShowingOriginal
                                      ? l10n.original
                                      : l10n.translatedFrom(
                                          sourceLanguage ?? '',
                                        ),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: isMine
                                        ? metaColor
                                        : glassToken.primary,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                GestureDetector(
                                  onTap: onToggleOriginal,
                                  child: Text(
                                    isShowingOriginal
                                        ? l10n.viewTranslation
                                        : l10n.viewOriginal,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      decoration: TextDecoration.underline,
                                      color: isMine
                                          ? textColor
                                          : glassToken.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                          ],
                          if (isTranslating && translatedText == null) ...[
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 13,
                                  height: 13,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 1.8,
                                    color: isMine
                                        ? metaColor
                                        : glassToken.primary,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  l10n.translationInProgress,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: metaColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                          ],

                          if (displayText.trim().isNotEmpty) ...[
                            _buildMessageText(
                              context,
                              displayText,
                              textColor,
                              trailing: inlineMetadata
                                  ? Padding(
                                      padding: const EdgeInsets.only(
                                        left: 8,
                                        top: 3,
                                      ),
                                      child: metadata.child,
                                    )
                                  : null,
                            ),
                            const SizedBox(height: 4),
                          ],
                          if (!overlayMetadata && !inlineMetadata) metadata,
                        ]
                        .map(
                          (child) => Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal:
                                  child == visualPreview && mediaIsVisual
                                  ? 3
                                  : 10,
                            ),
                            child: child,
                          ),
                        )
                        .toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
