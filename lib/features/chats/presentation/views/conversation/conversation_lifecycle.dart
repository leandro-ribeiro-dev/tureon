part of '../chat_screen.dart';

/// Presentation coordination for conversation lifecycle.
mixin _ConversationLifecycle on _ChatConversationState {
  @override
  void initState() {
    super.initState();
    _translationController = ChatTranslationController(
      accountId: () => _localUserId,
      generation: () => _conversationGeneration,
      repository: () => widget.services?.chatRepository,
      settings: () => ref.read(translationSettingsProvider),
      detector: () => ref.read(messageLanguageDetectorProvider),
      translator: () => ref.read(translationRepositoryProvider),
      targetLocale: () => ref.read(appLocaleProvider).languageCode,
      supportsOnDeviceTranslation: supportsOnDeviceTranslation,
      defer: (callback) => WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) callback();
      }),
      onError: (error) {
        if (!mounted) return;
        final l10n = context.safeLocalizations;
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          SnackBar(
            content: Text(
              error is UnsupportedError
                  ? l10n.translationUnavailable
                  : l10n.translationFailed,
            ),
          ),
        );
      },
    );
    _slowModeCooldown = ref.read(chatSlowModeCooldownProvider.notifier);
    _secretMode = widget.isSecretChat;
    _activeDraftKey = _currentDraftKey;
    _listenForChatReadiness();
    final homeRepository = ref.read(homeRepositoryProvider);
    _recipientSubscription = homeRepository
        ?.watchRecipient(widget.recipient.id)
        .listen(_handleWatchedRecipient);
    _typingIndicator = _createTypingIndicator(widget.recipient.id);
    _startOnlineGroupCountRefresh();
    _textController.addListener(_onComposerTextChanged);
    _messagesScrollController.addListener(_updateScrollPosition);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final repository = widget.services?.chatRepository;
      if (repository != null) {
        _sendConversationReadReceipts(repository);
      }
    });
  }

  @override
  void didUpdateWidget(covariant ChatScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.services != widget.services) _listenForChatReadiness();
    if (oldWidget.recipient.id == widget.recipient.id &&
        oldWidget.isSecretChat == widget.isSecretChat &&
        oldWidget.services?.chatIdentity?.userId ==
            widget.services?.chatIdentity?.userId &&
        oldWidget.services?.chatIdentity?.deviceId ==
            widget.services?.chatIdentity?.deviceId &&
        oldWidget.secretChatDevice?.deviceId ==
            widget.secretChatDevice?.deviceId) {
      return;
    }
    _composerDrafts[_activeDraftKey] = _editingMessageId == null
        ? _textController.value
        : TextEditingValue.empty;
    while (_composerDrafts.length > 20) {
      _composerDrafts.remove(_composerDrafts.keys.first);
    }
    _secretMode = widget.isSecretChat;
    _conversationGeneration++;
    _typingIndicator.dispose();
    _typingIndicator = _createTypingIndicator(widget.recipient.id);
    _activeDraftKey = _currentDraftKey;
    _editingMessageId = null;
    _suppressTypingUpdates = true;
    _textController.value =
        _composerDrafts.remove(_activeDraftKey) ?? TextEditingValue.empty;
    _suppressTypingUpdates = false;
    _recipientSubscription?.cancel();
    _recipientSubscription = ref
        .read(homeRepositoryProvider)
        ?.watchRecipient(widget.recipient.id)
        .listen(_handleWatchedRecipient);
    _liveRecipient = null;
    _onlineMemberCount = null;
    _startOnlineGroupCountRefresh();
    _olderMessages = const [];
    _isLoadingOlderMessages = false;
    _hasMoreHistory = true;
    _chatLoadError = null;
    _translationController.reset();
    _isBrowsingHistory = false;
    _showJumpToLatest = false;
    _hasPositionedInitialMessages = false;
    _latestPositionUpdateScheduled = false;
    _lastObservedLatestMessageId = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final repository = widget.services?.chatRepository;
      if (repository != null) {
        unawaited(_sendConversationReadReceipts(repository));
      }
    });
  }

  void _handleWatchedRecipient(Recipient? recipient) {
    if (!mounted) return;
    if (recipient == null) {
      if (widget.recipient.type != RecipientType.group &&
          widget.recipient.type != RecipientType.channel) {
        return;
      }
      final current = _liveRecipient ?? widget.recipient;
      _typingIndicator.setTyping(false);
      _composerFocusNode.unfocus();
      _composerDrafts.remove(_activeDraftKey);
      _suppressTypingUpdates = true;
      _textController.clear();
      _suppressTypingUpdates = false;
      setState(() {
        _liveRecipient = current.copyWith(
          isMember: false,
          canSendMessages: false,
        );
      });
      return;
    }
    if (recipient.id != widget.recipient.id) return;
    final wasMember = (_liveRecipient ?? widget.recipient).isMember;
    final previousMemberCount =
        _liveRecipient?.memberCount ?? widget.recipient.memberCount;
    if (wasMember && !recipient.isMember) {
      _typingIndicator.setTyping(false);
      _composerFocusNode.unfocus();
      _composerDrafts.remove(_activeDraftKey);
      _suppressTypingUpdates = true;
      _textController.clear();
      _suppressTypingUpdates = false;
    }
    setState(() => _liveRecipient = recipient);
    if (recipient.type == RecipientType.group &&
        recipient.memberCount != previousMemberCount) {
      _refreshGroupOnlineCount();
    }
  }

  void _listenForChatReadiness() {
    _chatReadinessSubscription?.cancel();
    _chatStreamReady = widget.services?.isChatStreamReady ?? true;
    _chatReadinessSubscription = widget.services?.chatStreamReadinessChanges
        .listen((ready) {
          if (!mounted || _chatStreamReady == ready) return;
          setState(() => _chatStreamReady = ready);
          if (ready) {
            final repository = widget.services?.chatRepository;
            if (repository != null) _sendConversationReadReceipts(repository);
          }
        });
  }

  void _onComposerTextChanged() {
    if (_suppressTypingUpdates) return;
    _typingIndicator.setTyping(_textController.text.trim().isNotEmpty);
  }

  TypingIndicatorDebouncer _createTypingIndicator(String recipientId) =>
      TypingIndicatorDebouncer(
        send: (isTyping) =>
            widget.services?.sendTypingIndicator(
              targetRecipientId: recipientId,
              isTyping: isTyping,
            ) ??
            Future<void>.value(),
      );

  @override
  void dispose() {
    _translationController.dispose();
    _textController.removeListener(_onComposerTextChanged);
    _typingIndicator.dispose();
    _onlineMemberCountGeneration++;
    _onlineMemberCountRefreshTimer?.cancel();
    _onlineMemberCountRefreshTimer = null;
    _textController.dispose();
    _composerFocusNode.dispose();
    _messagesScrollController.removeListener(_updateScrollPosition);
    _messagesScrollController.dispose();
    _recipientSubscription?.cancel();
    _chatReadinessSubscription?.cancel();
    super.dispose();
  }

  void _refreshGroupOnlineCount() {
    final recipient = widget.recipient;
    final services = widget.services;
    final generation = _onlineMemberCountGeneration;
    if (recipient.type != RecipientType.group ||
        services == null ||
        _onlineMemberCountLoading) {
      return;
    }
    _onlineMemberCountLoading = true;
    unawaited(() async {
      try {
        final count = await services.loadOnlineGroupMemberCount(
          groupId: recipient.id,
        );
        if (!mounted ||
            generation != _onlineMemberCountGeneration ||
            widget.recipient.id != recipient.id) {
          return;
        }
        setState(() => _onlineMemberCount = count);
      } catch (_) {
        // The group stays usable if the optional live-count snapshot fails.
      } finally {
        if (generation == _onlineMemberCountGeneration) {
          _onlineMemberCountLoading = false;
        }
      }
    }());
  }

  void _startOnlineGroupCountRefresh() {
    _onlineMemberCountGeneration++;
    _onlineMemberCountLoading = false;
    _onlineMemberCountRefreshTimer?.cancel();
    _onlineMemberCountRefreshTimer = null;
    if (widget.recipient.type != RecipientType.group) return;
    _refreshGroupOnlineCount();
    _onlineMemberCountRefreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _refreshGroupOnlineCount(),
    );
  }
}
