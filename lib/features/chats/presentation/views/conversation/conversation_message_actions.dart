part of '../chat_screen.dart';

/// Presentation coordination for conversation message actions.
mixin _ConversationMessageActions on _ChatConversationState {
  Future<void> _retryMessage(String messageId) async {
    final conversationGeneration = _conversationGeneration;
    try {
      final repository = widget.services?.chatRepository;
      if (repository == null) {
        throw StateError(
          'Conecte-se e entre na conta para reenviar mensagens.',
        );
      }
      await repository.retryMessage(messageId);
      if (mounted && conversationGeneration == _conversationGeneration) {
        setState(() => _chatLoadError = null);
      }
    } catch (error) {
      if (mounted && conversationGeneration == _conversationGeneration) {
        setState(() => _chatLoadError = _failureMessage(error));
      }
    }
  }

  void _beginMessageEdit(chat_domain.ChatMessage message) {
    setState(() {
      _editingMessageId = message.messageId;
      _replyToMessage = null;
    });
    _textController.value = TextEditingValue(
      text: message.body,
      selection: TextSelection.collapsed(offset: message.body.length),
    );
    _composerFocusNode.requestFocus();
  }

  void _cancelMessageEdit() {
    setState(() {
      _editingMessageId = null;
      _textController.clear();
    });
    _composerFocusNode.unfocus();
  }

  @override
  Future<void> _saveMessageEdit(String updatedBody) async {
    final conversationGeneration = _conversationGeneration;
    final messageId = _editingMessageId;
    final repository = widget.services?.chatRepository;
    if (messageId == null || repository == null) return;
    try {
      await repository.editMessage(
        messageId: messageId,
        chatId: widget.recipient.id,
        targetRecipientId: widget.recipient.id,
        isSecret: _secretMode,
        targetDeviceId: widget.secretChatDevice?.deviceId,
        body: updatedBody,
      );
      if (!mounted || conversationGeneration != _conversationGeneration) return;
      setState(() {
        _editingMessageId = null;
        _chatLoadError = null;
      });
      _textController.clear();
      _composerFocusNode.unfocus();
    } catch (error) {
      if (mounted && conversationGeneration == _conversationGeneration) {
        setState(() => _chatLoadError = _failureMessage(error));
      }
    }
  }

  Future<void> _translateMessage(
    MessageItem message, {
    String? sourceLanguage,
    String? targetLanguage,
    bool automatic = false,
  }) => _translationController.translate(
    message,
    sourceLanguage: sourceLanguage,
    targetLanguage: targetLanguage,
    automatic: automatic,
  );

  Future<void> _showMessageContextMenu(
    BuildContext context,
    MessageItem message,
    chat_domain.ChatMessage serverMessage,
    Offset globalPosition,
  ) async {
    await showMessageContextMenu(
      context: context,
      globalPosition: globalPosition,
      ref: ref,
      message: message,
      serverMessage: serverMessage,
      localUserId: _localUserId,
      allowMessageMutations:
          (widget.services?.chatSendRestriction ?? ChatSendRestriction.none) ==
          ChatSendRestriction.none,
      onTranslate: (MessageItem msg, {String? sourceLanguage}) {
        _translateMessage(msg, sourceLanguage: sourceLanguage);
      },
      onEdit: _editServerMessage,
      onDelete: _confirmDeleteServerMessage,
      onReply: (message) {
        setState(() => _replyToMessage = message);
        _composerFocusNode.requestFocus();
      },
    );
  }

  Future<void> _editServerMessage(chat_domain.ChatMessage message) async {
    _beginMessageEdit(message);
  }

  Future<void> _confirmDeleteServerMessage(
    chat_domain.ChatMessage message,
  ) async {
    final conversationGeneration = _conversationGeneration;
    final confirmed = await ChatDialogs.confirmDeleteMessage(context);
    if (confirmed != true ||
        !mounted ||
        conversationGeneration != _conversationGeneration) {
      return;
    }
    final repository = widget.services?.chatRepository;
    if (repository == null) return;
    try {
      await repository.deleteMessage(
        messageId: message.messageId,
        chatId: widget.recipient.id,
        targetRecipientId: widget.recipient.id,
        isSecret: _secretMode,
        targetDeviceId: widget.secretChatDevice?.deviceId,
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_failureMessage(error))));
      }
    }
  }
}
