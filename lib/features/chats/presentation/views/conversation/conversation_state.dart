part of '../chat_screen.dart';

/// Shared view state and explicit coordination contract between concerns.
/// Durable message state remains in ChatRepository and the reactive store.
abstract class _ChatConversationState extends ConsumerState<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _composerFocusNode = FocusNode();
  final ScrollController _messagesScrollController = ScrollController();
  ChatAttachmentInputs get _attachmentInputs =>
      ref.read(chatAttachmentInputsProvider);
  late TypingIndicatorDebouncer _typingIndicator;
  late bool _secretMode;
  String? _editingMessageId;
  chat_domain.ChatMessage? _replyToMessage;
  bool _isBrowsingHistory = false;
  bool _showJumpToLatest = false;
  bool _hasPositionedInitialMessages = false;
  bool _latestPositionUpdateScheduled = false;
  String? _lastObservedLatestMessageId;

  late final ChatTranslationController _translationController;
  StreamSubscription<Recipient?>? _recipientSubscription;
  late final ChatSlowModeCooldownNotifier _slowModeCooldown;
  StreamSubscription<bool>? _chatReadinessSubscription;
  late bool _chatStreamReady;
  Recipient? _liveRecipient;
  int? _onlineMemberCount;
  Timer? _onlineMemberCountRefreshTimer;
  bool _onlineMemberCountLoading = false;
  int _onlineMemberCountGeneration = 0;
  String? _chatLoadError;
  List<chat_domain.ChatMessage> _olderMessages = const [];
  bool _isLoadingOlderMessages = false;
  bool _isJoiningPublicGroupChannel = false;
  bool _hasMoreHistory = true;
  int _conversationGeneration = 0;
  late ({String? accountId, String chatId}) _activeDraftKey;
  final Map<({String? accountId, String chatId}), TextEditingValue>
  _composerDrafts = {};
  bool _suppressTypingUpdates = false;

  String? get _localUserId => widget.services?.chatIdentity?.userId;

  ({String? accountId, String chatId}) get _currentDraftKey =>
      (accountId: _localUserId, chatId: _localChatId);

  String get _localChatId {
    if (!_secretMode) return widget.recipient.id;
    final deviceId = widget.services?.chatIdentity?.deviceId;
    final peerDevice = widget.secretChatDevice;
    if (deviceId == null || peerDevice == null) {
      return 'secret/${widget.recipient.id}';
    }
    return secretChatLocalId(
      recipientId: widget.recipient.id,
      firstDeviceId: deviceId,
      secondDeviceId: peerDevice.deviceId,
    );
  }

  String _failureMessage(Object error) => error is ChatFailure
      ? error.message
      : 'Não foi possível comunicar com o servidor de mensagens.';

  String _messagePreviewText(chat_domain.ChatMessage message) =>
      ChatMessagePresentation.previewText(message);

  Future<void> _sendConversationReadReceipts(ChatRepository repository);
  void _updateScrollPosition();
  bool _isRoomAdmin(Recipient recipient);
  int _roomSlowModeRemainingSeconds(Recipient recipient);
  void _startRoomSlowModeCooldown(
    Recipient recipient, {
    int? retryAfterSeconds,
  });
  String? _attachmentPermissionError(ChatAttachmentAction action);
  Future<void> _saveMessageEdit(String updatedBody);
}
