import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/design_system/message_bubble.dart';
import '../../../../core/protocol/protocol_models.dart';
import '../../../../l10n/app_localizations_extensions.dart';
import '../../domain/chat_message.dart' as chat_domain;
import '../../domain/chat_repository.dart';
import '../../domain/message_date_grouper.dart';
import '../../data/on_device_translation_support.dart';
import '../controllers/chat_translation_controller.dart';
import '../controllers/chat_message_presentation.dart';
import 'chat_message_list.dart';
import 'chat_attachment_preview.dart';
import 'date_divider_bubble.dart';
import 'system_message_bubble.dart';

/// Lazy timeline composition, grouping, replies and translation presentation.
class ChatTimeline extends StatelessWidget {
  const ChatTimeline({
    super.key,
    required this.messages,
    required this.controller,
    required this.translations,
    required this.userId,
    required this.senderName,
    required this.repository,
    required this.isSecret,
    required this.fontSize,
    required this.targetLanguage,
    required this.automaticTranslationEnabled,
    required this.isLoadingEarlier,
    required this.onReachStart,
    required this.onUserScroll,
    required this.onMetricsChanged,
    required this.onRetry,
    required this.onReply,
    required this.onMessageMenu,
  });
  final List<chat_domain.ChatMessage> messages;
  final ScrollController controller;
  final ChatTranslationController translations;
  final String? userId;
  final String senderName;
  final ChatRepository? repository;
  final bool isSecret;
  final double fontSize;
  final String targetLanguage;
  final bool automaticTranslationEnabled;
  final bool isLoadingEarlier;
  final VoidCallback onReachStart;
  final bool Function(UserScrollNotification) onUserScroll;
  final VoidCallback onMetricsChanged;
  final Future<void> Function(String) onRetry;
  final ValueChanged<chat_domain.ChatMessage> onReply;
  final void Function(MessageItem, chat_domain.ChatMessage, Offset)
  onMessageMenu;
  @override
  Widget build(BuildContext context) {
    final messagesById = {
      for (final message in messages) message.messageId: message,
    };
    final l10n = context.safeLocalizations;
    final glassToken = Theme.of(context).colorScheme;
    return ListenableBuilder(
      listenable: translations,
      builder: (context, child) {
        final groupedItems = MessageDateGrouper.groupMessagesWithDates(
          messages,
        );

        return ChatMessageList(
          controller: controller,
          items: groupedItems,
          isLoadingEarlier: isLoadingEarlier,
          onReachStart: () => onReachStart(),
          onUserScroll: onUserScroll,
          onMetricsChanged: onMetricsChanged,
          empty: Center(
            child: Text(
              'Nenhuma mensagem nesta conversa.',
              style: TextStyle(color: glassToken.onSurfaceVariant),
            ),
          ),
          itemKey: (index) => switch (groupedItems[index]) {
            DateDividerItem(:final date) => ValueKey<String>(
              'date_${date.millisecondsSinceEpoch}',
            ),
            ChatMessageItem(:final message) => ValueKey<String>(
              'message_${message.messageId}',
            ),
          },
          itemBuilder: (context, itemIndex) {
            final listItem = groupedItems[itemIndex];

            return switch (listItem) {
              DateDividerItem(:final date) => DateDividerBubble(date: date),
              ChatMessageItem(:final message) => () {
                if (message.type == chat_domain.ChatMessageType.system) {
                  return SystemMessageBubble(message: message.body);
                }

                final messageItem = ChatMessagePresentation.toMessageItem(
                  message,
                  userId: userId,
                  senderName: senderName,
                );
                final isMine = message.senderRecipientId == userId;
                bool sameGroupAt(int index) {
                  if (index < 0 || index >= groupedItems.length) {
                    return false;
                  }
                  final adjacent = groupedItems[index];
                  if (adjacent is! ChatMessageItem) {
                    return false;
                  }
                  final other = adjacent.message;
                  return other.type != chat_domain.ChatMessageType.system &&
                      other.senderRecipientId == message.senderRecipientId &&
                      other.createdAt.difference(message.createdAt).abs() <
                          const Duration(minutes: 5);
                }

                final translationKey = translations.key(
                  messageItem.id,
                  targetLanguage,
                );
                final hasCurrentTranslation =
                    translations.text(translationKey, message.body) != null;
                if (messageItem.text?.trim().isNotEmpty == true &&
                    automaticTranslationEnabled &&
                    supportsOnDeviceTranslation &&
                    !isMine &&
                    !hasCurrentTranslation) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (translations.isActive) {
                      translations.queueAutomatic(messageItem, targetLanguage);
                    }
                  });
                }

                final replyMessage = messagesById[message.replyToMessageId];
                final replyPreview = replyMessage == null
                    ? (message.replyToMessageId == null
                          ? null
                          : 'Mensagem respondida')
                    : ChatMessagePresentation.previewText(replyMessage);
                final chatRepository = repository;
                return MessageBubble(
                  text: messageItem.text ?? '',
                  isFirstInGroup: !sameGroupAt(itemIndex - 1),
                  isLastInGroup: !sameGroupAt(itemIndex + 1),
                  mediaIsVisual:
                      message.type == chat_domain.ChatMessageType.image ||
                      message.type == chat_domain.ChatMessageType.gif,
                  mediaPreview:
                      message.attachment == null || chatRepository == null
                      ? null
                      : ChatAttachmentPreview(
                          message: message,
                          repository: chatRepository,
                        ),
                  replyPreview: replyPreview,
                  onReply: () => onReply(message),
                  isMine: isMine,
                  timestamp: messageItem.timestamp,
                  senderName: isMine ? null : messageItem.senderName,
                  status: messageItem.status,
                  isSecretChat: isSecret,
                  translatedText: hasCurrentTranslation
                      ? translations.text(translationKey, message.body)
                      : null,
                  isTranslating: translations.isTranslating(translationKey),
                  sourceLanguage:
                      translations.sourceLanguage(translationKey) == null
                      ? null
                      : ChatMessagePresentation.languageName(
                          translations.sourceLanguage(translationKey)!,
                          l10n,
                        ),
                  fontSize: fontSize,
                  isShowingOriginal: translations.showsOriginal(translationKey),
                  onToggleOriginal: () =>
                      translations.toggleOriginal(translationKey),
                  onRetry:
                      isMine &&
                          message.status ==
                              chat_domain.ChatDeliveryStatus.failed
                      ? () => unawaited(onRetry(message.messageId))
                      : null,
                  onTapAt: (position) =>
                      onMessageMenu(messageItem, message, position),
                  onLongPressAt: (position) =>
                      onMessageMenu(messageItem, message, position),
                );
              }(),
            };
          },
        );
      },
    );
  }
}
