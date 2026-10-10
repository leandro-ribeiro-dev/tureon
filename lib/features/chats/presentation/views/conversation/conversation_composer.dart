part of '../chat_screen.dart';

/// Presentation coordination for conversation composer.
mixin _ConversationComposer on _ChatConversationState {
  ChatComposerParams _getComposerParams(
    Recipient recipient, {
    bool hasMessages = false,
  }) {
    final hasExchangedMessages =
        widget.services?.loadSetting(
          'chat_ever_exchanged_${widget.recipient.id}',
        ) ==
        'true';
    final hasLastMessage =
        recipient.lastMessage != null && recipient.lastMessage!.isNotEmpty;
    final sendRestriction =
        widget.services?.chatSendRestriction ?? ChatSendRestriction.none;
    final recipientType = _secretMode ? RecipientType.user : recipient.type;
    return ChatComposerParams(
      chatId: recipient.id,
      recipientType: recipientType,
      userRole: switch (recipient.composerRole) {
        'owner' => ChatUserRole.owner,
        'admin' => ChatUserRole.admin,
        _ => ChatUserRole.member,
      },
      canSendInGroup: recipient.canSendMessages,
      restrictedUntil: recipient.restrictedUntil,
      hasExchangedMessages: hasExchangedMessages || hasMessages,
      hasLastMessage: hasLastMessage,
      isOfficialSystemBot:
          recipient.id == tureonBotId ||
          recipient.handle.toLowerCase() == tureonBotUsername,
      moderationReason: switch (sendRestriction) {
        ChatSendRestriction.blocked => ModerationReason.banned,
        ChatSendRestriction.underReview => ModerationReason.underReview,
        _ => null,
      },
      isMember: recipient.isMember,
      slowModeSeconds: _secretMode ? 0 : recipient.slowModeSeconds,
      slowModeCooldownKey: _slowModeCooldownKey(recipient),
    );
  }

  Future<void> _joinPublicGroupChannel() async {
    final services = widget.services;
    final recipient = _liveRecipient ?? widget.recipient;
    if (services == null ||
        recipient.isMember ||
        (recipient.type != RecipientType.group &&
            recipient.type != RecipientType.channel) ||
        _isJoiningPublicGroupChannel) {
      return;
    }
    setState(() => _isJoiningPublicGroupChannel = true);
    try {
      final joined = await services.joinPublicGroupChannel(recipient);
      if (!mounted) return;
      setState(() {
        _liveRecipient = joined;
        _isJoiningPublicGroupChannel = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            joined.type == RecipientType.channel
                ? 'Você entrou no canal.'
                : 'Você entrou no grupo.',
          ),
        ),
      );
    } catch (error, stackTrace) {
      developer.log(
        'Could not join public group or channel',
        name: 'tureon.chat',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      setState(() => _isJoiningPublicGroupChannel = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível entrar. Tente novamente.')),
      );
    }
  }

  Future<void> _startBot() async {
    _textController.text = '/start';
    await _sendMessage();
  }

  Future<void> _sendMessage() async {
    final conversationGeneration = _conversationGeneration;
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    if (widget.recipient.id == tureonBotId ||
        widget.recipient.handle.toLowerCase() == tureonBotUsername) {
      return;
    }
    if (_editingMessageId != null) {
      await _saveMessageEdit(text);
      return;
    }
    _typingIndicator.setTyping(false);
    if (widget.recipient.type == RecipientType.bot) {
      final services = widget.services;
      if (services == null) {
        setState(() {
          _chatLoadError = 'Conecte-se para conversar com este bot.';
        });
        return;
      }
      try {
        await services.sendBotMessage(recipient: widget.recipient, body: text);
        if (!mounted || conversationGeneration != _conversationGeneration) {
          return;
        }
        setState(() {
          _chatLoadError = null;
          _replyToMessage = null;
        });
        _textController.clear();
      } catch (error) {
        if (mounted && conversationGeneration == _conversationGeneration) {
          setState(() => _chatLoadError = _failureMessage(error));
        }
      }
      return;
    }
    if (_secretMode) {
      final secretDevice = widget.secretChatDevice;
      if (secretDevice == null) {
        setState(() {
          _chatLoadError =
              'Selecione um dispositivo para iniciar o chat secreto.';
        });
        return;
      }
      final repository = widget.services?.chatRepository;
      final senderRecipientId = _localUserId;
      if (repository == null || senderRecipientId == null) {
        setState(() {
          _chatLoadError = 'Conecte-se e entre na conta para enviar mensagens.';
        });
        return;
      }
      try {
        await repository.sendSecretMessage(
          chatId: widget.recipient.id,
          senderRecipientId: senderRecipientId,
          recipientServerDeviceId: secretDevice.deviceId,
          body: text,
          replyToMessageId: _replyToMessage?.messageId,
        );
        if (!mounted || conversationGeneration != _conversationGeneration) {
          return;
        }
        setState(() {
          _chatLoadError = null;
          _replyToMessage = null;
        });
        _textController.clear();
      } catch (error) {
        if (mounted && conversationGeneration == _conversationGeneration) {
          setState(() => _chatLoadError = _failureMessage(error));
        }
      }
      return;
    }

    final recipient = _liveRecipient ?? widget.recipient;
    if (_roomSlowModeRemainingSeconds(recipient) > 0) return;
    if (!_isRoomAdmin(recipient) &&
        (recipient.type == RecipientType.group ||
            recipient.type == RecipientType.channel)) {
      if (!recipient.canSendMessages) {
        setState(
          () => _chatLoadError =
              'Você não pode enviar mensagens neste grupo ou canal.',
        );
        return;
      }
      if (recipient.type == RecipientType.group &&
          !recipient.membersCanEmbedLinks &&
          _containsMessageLink(text)) {
        setState(
          () => _chatLoadError = 'O grupo não permite o envio de links.',
        );
        return;
      }
    }

    final repository = widget.services?.chatRepository;
    final senderRecipientId = _localUserId;
    if (repository == null || senderRecipientId == null) {
      setState(() {
        _chatLoadError = 'Conecte-se e entre na conta para enviar mensagens.';
      });
      return;
    }

    try {
      await repository.sendMessage(
        chatId: widget.recipient.id,
        senderRecipientId: senderRecipientId,
        body: text,
        replyToMessageId: _replyToMessage?.messageId,
      );
      _startRoomSlowModeCooldown(recipient);
      if (!mounted || conversationGeneration != _conversationGeneration) {
        return;
      }
      setState(() {
        _chatLoadError = null;
        _replyToMessage = null;
      });
      _textController.clear();
    } catch (error) {
      if (mounted && conversationGeneration == _conversationGeneration) {
        if (error is RoomSlowModeFailure) {
          _startRoomSlowModeCooldown(
            recipient,
            retryAfterSeconds: error.retryAfterSeconds,
          );
          setState(() => _chatLoadError = null);
        } else {
          setState(() => _chatLoadError = _failureMessage(error));
        }
      }
    }
  }

  @override
  bool _isRoomAdmin(Recipient recipient) =>
      ChatSendPolicy.isRoomAdmin(recipient);

  String _slowModeCooldownKey(Recipient recipient) =>
      '${_localUserId ?? 'anonymous'}:${recipient.id}';

  @override
  int _roomSlowModeRemainingSeconds(Recipient recipient) {
    if (_secretMode ||
        (recipient.type != RecipientType.group &&
            recipient.type != RecipientType.channel) ||
        _isRoomAdmin(recipient)) {
      return 0;
    }
    return _slowModeCooldown.remainingSeconds(_slowModeCooldownKey(recipient));
  }

  @override
  void _startRoomSlowModeCooldown(
    Recipient recipient, {
    int? retryAfterSeconds,
  }) {
    if (_secretMode ||
        (recipient.type != RecipientType.group &&
            recipient.type != RecipientType.channel) ||
        _isRoomAdmin(recipient)) {
      return;
    }
    final seconds = retryAfterSeconds ?? recipient.slowModeSeconds;
    if (seconds <= 0) return;
    _slowModeCooldown.start(_slowModeCooldownKey(recipient), seconds);
  }

  bool _containsMessageLink(String value) => ChatSendPolicy.containsLink(value);

  @override
  String? _attachmentPermissionError(ChatAttachmentAction action) =>
      switch (ChatSendPolicy.attachmentRestriction(
        _liveRecipient ?? widget.recipient,
        action,
        isSecret: _secretMode,
      )) {
        ChatAttachmentRestriction.none => null,
        ChatAttachmentRestriction.cannotSend =>
          'Você não pode publicar mensagens neste grupo ou canal.',
        ChatAttachmentRestriction.gifsDisabled =>
          'O grupo não permite figurinhas ou GIFs.',
        ChatAttachmentRestriction.mediaDisabled =>
          'O grupo não permite o envio de mídias.',
      };
}
