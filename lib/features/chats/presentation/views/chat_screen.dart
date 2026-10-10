import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;

import '../../../home/presentation/home_view_model.dart';
import '../../../../features/presence/data/presence_repository.dart';
import '../../../../core/design_system/app_bottom_sheet.dart';
import '../../../../core/protocol/protocol_models.dart';
import '../../../../core/protocol/official_bots.dart';
import '../../../../core/providers/settings_providers.dart';
import '../../../../l10n/app_localizations_extensions.dart';
import '../../../home/home_providers.dart';
import '../../domain/chat_failure.dart';
import '../../domain/chat_send_policy.dart';
import '../../domain/chat_feature_services.dart';
import '../../domain/chat_composer_state.dart';
import '../../domain/chat_message.dart' as chat_domain;
import '../../domain/secret_chat_device.dart';
import '../../data/on_device_translation_support.dart';
import '../../data/services/chat_attachment_inputs.dart';
import '../../domain/chat_repository.dart'
    show ChatRepository, secretChatLocalId;
import '../controllers/chat_composer_notifier.dart';
import '../controllers/chat_slow_mode_cooldown.dart';
import '../controllers/chat_messages_provider.dart';
import '../controllers/chat_translation_controller.dart';
import '../controllers/chat_attachment_inputs_provider.dart';
import '../widgets/chat_attachment_menu.dart';
import '../widgets/chat_input_area.dart';
import '../widgets/message_context_menu.dart';
import '../widgets/chat_overflow_menu.dart';
import '../widgets/chat_dialogs.dart';
import '../widgets/chat_timeline.dart';
import '../controllers/chat_message_presentation.dart';
import '../widgets/chat_conversation_app_bar.dart';

part 'conversation/conversation_lifecycle.dart';
part 'conversation/conversation_history.dart';
part 'conversation/conversation_composer.dart';
part 'conversation/conversation_attachments.dart';
part 'conversation/conversation_message_actions.dart';
part 'conversation/conversation_room_actions.dart';
part 'conversation/conversation_state.dart';

const _recentMessageLimit = 100;
const _earlierMessagePageSize = 50;

/// Screen 3.3 & Section 3: ChatScreen
/// Active conversation view supporting normal and Secret Chat variants.
/// Message translations are local to this installation and never alter the
/// original message used by the outgoing message pipeline.
void _noopVoidCallback() {}

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({
    super.key,
    required this.state,
    required this.recipient,
    required this.onBack,
    required this.onViewProfile,
    this.onClearHistory = _noopVoidCallback,
    this.onDeleteConversation = _noopVoidCallback,
    this.services,
    this.isSecretChat = false,
    this.secretChatDevice,
  });
  final HomeState state;
  final Recipient recipient;
  final VoidCallback onBack;
  final ValueChanged<Recipient> onViewProfile;
  final VoidCallback onClearHistory;
  final VoidCallback onDeleteConversation;
  final ChatFeatureServices? services;
  final bool isSecretChat;
  final SecretChatDevice? secretChatDevice;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends _ChatConversationState
    with
        _ConversationLifecycle,
        _ConversationHistory,
        _ConversationComposer,
        _ConversationAttachments,
        _ConversationMessageActions,
        _ConversationRoomActions {
  @override
  Widget build(BuildContext context) {
    final glassToken = Theme.of(context).colorScheme;
    final presenceRecipient = ref.watch(
      homeViewModelProvider.select((homeState) {
        for (final item in homeState.recipients) {
          if (item.id == widget.recipient.id) return item;
        }
        return null;
      }),
    );
    final baseRecipient = _liveRecipient ?? widget.recipient;
    final recipient = presenceRecipient == null
        ? baseRecipient
        : baseRecipient.copyWith(
            isOnline: presenceRecipient.isOnline,
            isPresenceVisible: presenceRecipient.isPresenceVisible,
            lastSeenAt: presenceRecipient.lastSeenAt,
            clearLastSeenAt: presenceRecipient.lastSeenAt == null,
            isTyping: presenceRecipient.isTyping,
          );
    final settingsValues = ref.watch(settingsValuesProvider);
    final wallpaper = settingsValues['wallpaper'] as String? ?? 'Padrão';
    final messageFontSize = switch (settingsValues['font_size']) {
      'Pequeno (14px)' => 14.0,
      'Grande (18px)' => 18.0,
      'Muito Grande (20px)' => 20.0,
      _ => 16.0,
    };
    final wallpaperColor = switch (wallpaper) {
      'Verde' =>
        glassToken.brightness == Brightness.dark
            ? const Color(0xFF172D28)
            : const Color(0xFFEAF7F1),
      'Grafite' =>
        glassToken.brightness == Brightness.dark
            ? const Color(0xFF20242A)
            : const Color(0xFFE8EAED),
      _ => Colors.transparent,
    };

    final translationSettings = ref.watch(translationSettingsProvider);
    final translationTargetLanguage = ref.watch(appLocaleProvider).languageCode;
    final request = (chatId: _localChatId, limit: _recentMessageLimit);
    ref.listen<AsyncValue<List<chat_domain.ChatMessage>>>(
      chatMessagesStreamProvider(request),
      (_, next) => _handleMessageSnapshot(next, request.chatId),
    );
    final messagesAsync = ref.watch(chatMessagesStreamProvider(request));
    final currentMessages = messagesAsync.asData?.value ?? const [];
    final messagesForView = [..._olderMessages, ...currentMessages];

    final composerParams = _getComposerParams(
      recipient,
      hasMessages: currentMessages.isNotEmpty,
    );

    return Scaffold(
      backgroundColor: wallpaperColor == Colors.transparent
          ? Theme.of(context).scaffoldBackgroundColor
          : wallpaperColor,
      appBar: ChatConversationAppBar(
        recipient: recipient,
        onlineMemberCount: _onlineMemberCount,
        isSecret: _secretMode,
        isBrowsingHistory: _isBrowsingHistory,
        onBack: widget.onBack,
        onViewProfile: widget.onViewProfile,
        onMore: () => _showOverflowMenu(context),
      ),
      body: SafeArea(
        left: false,
        right: false,
        child: Column(
          children: [
            if (_chatLoadError != null)
              MaterialBanner(
                content: Text(_chatLoadError!),
                actions: [
                  TextButton(
                    onPressed: () => ref.invalidate(
                      chatMessagesStreamProvider((
                        chatId: _localChatId,
                        limit: _recentMessageLimit,
                      )),
                    ),
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: messagesAsync.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (error, stackTrace) => Center(
                        child: Text(
                          _failureMessage(error),
                          style: TextStyle(color: glassToken.onSurfaceVariant),
                        ),
                      ),
                      data: (_) {
                        return ChatTimeline(
                          messages: messagesForView,
                          controller: _messagesScrollController,
                          translations: _translationController,
                          userId: _localUserId,
                          senderName: widget.recipient.name,
                          repository: widget.services?.chatRepository,
                          isSecret: _secretMode,
                          fontSize: messageFontSize,
                          targetLanguage: translationTargetLanguage,
                          automaticTranslationEnabled:
                              translationSettings.isTranslationEnabled,
                          isLoadingEarlier: _isLoadingOlderMessages,
                          onReachStart: () =>
                              unawaited(_loadEarlierMessages(messagesForView)),
                          onUserScroll: _handleMessageScroll,
                          onMetricsChanged: _scheduleScrollMetricsUpdate,
                          onRetry: _retryMessage,
                          onReply: (message) {
                            setState(() => _replyToMessage = message);
                            _composerFocusNode.requestFocus();
                          },
                          onMessageMenu: (item, message, position) =>
                              _showMessageContextMenu(
                                context,
                                item,
                                message,
                                position,
                              ),
                        );
                      },
                    ),
                  ),
                  if (_showJumpToLatest)
                    Positioned(
                      right: 16,
                      bottom: 16,
                      child: FloatingActionButton.small(
                        heroTag: 'chat-jump-to-latest',
                        tooltip: 'Ir para as mensagens recentes',
                        onPressed: _scrollToLatestMessage,
                        child: const Icon(Icons.keyboard_arrow_down_rounded),
                      ),
                    ),
                ],
              ),
            ),

            // Composer Input Bar
            ChatInputArea(
              composerParams: composerParams,
              textController: _textController,
              focusNode: _composerFocusNode,
              onSendMessage: _sendMessage,
              onStartBot: _startBot,
              onAttachmentPressed: _handleAttachmentPressed,
              isSecretChat: _secretMode,
              isEditing: _editingMessageId != null,
              onCancelEdit: _cancelMessageEdit,
              replyPreview: _replyToMessage == null
                  ? null
                  : _messagePreviewText(_replyToMessage!),
              onCancelReply: () => setState(() => _replyToMessage = null),
              onJoin: _joinPublicGroupChannel,
              isJoining: _isJoiningPublicGroupChannel,
            ),
          ],
        ),
      ),
    );
  }
}
