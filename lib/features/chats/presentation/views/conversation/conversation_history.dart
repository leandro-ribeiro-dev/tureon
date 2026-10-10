part of '../chat_screen.dart';

/// Presentation coordination for conversation history.
mixin _ConversationHistory on _ChatConversationState {
  @override
  Future<void> _sendConversationReadReceipts(ChatRepository repository) async {
    try {
      await repository.markConversationRead(
        chatId: _localChatId,
        peerRecipientId: widget.recipient.id,
      );
    } catch (error, stackTrace) {
      developer.log(
        'Failed to send read receipts for viewed conversation',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _loadEarlierMessages(
    List<chat_domain.ChatMessage> visibleMessages,
  ) async {
    if (_isLoadingOlderMessages ||
        !_hasMoreHistory ||
        visibleMessages.isEmpty) {
      return;
    }
    final repository = widget.services?.chatRepository;
    if (repository == null) return;

    final before = visibleMessages.first;
    final previousMaxExtent = _messagesScrollController.hasClients
        ? _messagesScrollController.position.maxScrollExtent
        : 0.0;
    setState(() => _isLoadingOlderMessages = true);
    try {
      final page = repository.loadEarlierMessages(
        chatId: _localChatId,
        before: before,
        limit: _earlierMessagePageSize,
      );
      if (!mounted) return;
      setState(() {
        _olderMessages = [...page, ..._olderMessages];
        _isLoadingOlderMessages = false;
        _hasMoreHistory = page.length == _earlierMessagePageSize;
      });
      _translationController.hydrate(
        page,
        ref.read(appLocaleProvider).languageCode,
      );
      if (page.isEmpty) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_messagesScrollController.hasClients) return;
        final position = _messagesScrollController.position;
        if (!position.hasContentDimensions) return;
        final insertedExtent = position.maxScrollExtent - previousMaxExtent;
        _messagesScrollController.jumpTo(
          (position.pixels + insertedExtent).clamp(
            position.minScrollExtent,
            position.maxScrollExtent,
          ),
        );
      });
    } catch (error, stackTrace) {
      if (mounted) setState(() => _isLoadingOlderMessages = false);
      developer.log(
        'Failed to load earlier chat messages',
        name: 'tureon.messaging',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  bool _handleMessageScroll(UserScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical) return false;
    final browsingHistory =
        notification.direction == ScrollDirection.forward &&
        notification.metrics.pixels > notification.metrics.minScrollExtent + 24;
    if (_isBrowsingHistory != browsingHistory) {
      setState(() => _isBrowsingHistory = browsingHistory);
    }
    return false;
  }

  @override
  void _updateScrollPosition() {
    if (!mounted || !_messagesScrollController.hasClients) return;
    final position = _messagesScrollController.position;
    if (!position.hasContentDimensions) return;
    final showJump = position.maxScrollExtent - position.pixels > 160;
    final browsingHistory = showJump && _isBrowsingHistory;
    if (_showJumpToLatest != showJump ||
        (_isBrowsingHistory && !browsingHistory)) {
      setState(() {
        _showJumpToLatest = showJump;
        _isBrowsingHistory = browsingHistory;
      });
    }
  }

  void _scheduleScrollMetricsUpdate() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _updateScrollPosition();
    });
  }

  void _scrollToLatestMessage() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_messagesScrollController.hasClients) return;
      final position = _messagesScrollController.position;
      if (!position.hasContentDimensions) return;
      _messagesScrollController.animateTo(
        position.maxScrollExtent,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
      );
      if (_isBrowsingHistory) {
        setState(() => _isBrowsingHistory = false);
      }
    });
  }

  void _handleMessageSnapshot(
    AsyncValue<List<chat_domain.ChatMessage>> next,
    String chatId,
  ) {
    final messages = next.asData?.value;
    if (messages == null) return;
    _translationController.hydrate(
      messages,
      ref.read(appLocaleProvider).languageCode,
    );
    if (messages.isEmpty) {
      _lastObservedLatestMessageId = null;
      return;
    }
    final isInitialPosition = !_hasPositionedInitialMessages;
    final latestMessageId = messages.last.messageId;
    final latestMessageChanged =
        latestMessageId != _lastObservedLatestMessageId;
    if (!isInitialPosition && !latestMessageChanged) return;
    if (isInitialPosition) _hasPositionedInitialMessages = true;
    _lastObservedLatestMessageId = latestMessageId;

    var shouldFollowLatest =
        isInitialPosition || !_messagesScrollController.hasClients;
    if (!shouldFollowLatest && _messagesScrollController.hasClients) {
      final position = _messagesScrollController.position;
      shouldFollowLatest =
          position.hasContentDimensions &&
          position.maxScrollExtent - position.pixels <= 96;
    }
    if (!shouldFollowLatest) return;

    if (_latestPositionUpdateScheduled) return;
    _latestPositionUpdateScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _latestPositionUpdateScheduled = false;
      if (!mounted ||
          _localChatId != chatId ||
          !_messagesScrollController.hasClients) {
        return;
      }
      final position = _messagesScrollController.position;
      if (!position.hasContentDimensions) return;
      if (isInitialPosition) {
        _messagesScrollController.jumpTo(position.maxScrollExtent);
      } else {
        _messagesScrollController.animateTo(
          position.maxScrollExtent,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
        );
      }
    });
  }
}
