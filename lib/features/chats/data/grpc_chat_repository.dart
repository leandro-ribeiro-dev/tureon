export '../domain/chat_message_placeholders.dart'
    show secretMessageDecryptionFailed;

import 'dart:async';
import 'dart:developer' as developer;
import 'dart:math';

import 'package:tureon/core/crypto/secret_chat_crypto_port.dart';
import 'package:tureon/core/protocol/recipient.dart';
import 'package:tureon/core/protocol/recipient_type.dart';
import 'package:tureon/core/storage/chat_store.dart';
import 'package:tureon/core/storage/message_records.dart';
import 'package:tureon/generated/proto/tureon.pb.dart' as pb;
import 'package:tureon/core/background/outbox_background_scheduler.dart';
import 'package:tureon/features/chats/domain/chat_message.dart' as domain;
import 'package:tureon/features/chats/domain/message_translation.dart';
import '../domain/chat_repository.dart';
import 'services/chat_ack_queue.dart';
import 'services/chat_inbound_stream_handler.dart';
import 'services/chat_mutation_delivery_handler.dart';
import 'services/messaging_rpc.dart';
import 'services/chat_outbox_processor.dart';
import 'services/chat_media_transfer_service.dart';

import 'services/chat_conversation_resolver.dart';
import 'services/chat_secret_outbox_preparer.dart';
import 'services/chat_message_sender.dart';
import 'services/chat_attachment_sender.dart';
import 'services/chat_message_mutations.dart';
import 'services/chat_delivery_router.dart';
import 'services/chat_stream_coordinator.dart';
import 'services/chat_local_history.dart';
import 'services/chat_read_receipt_queue.dart';

class GrpcChatRepository implements ChatRepository {
  GrpcChatRepository({
    required this.rpc,
    required this.store,
    this.mediaTransfer,
    this.secretCrypto,
    this.resolveRecipient,
    this.resolveRoomRecipient,
    Random? random,
    this.retryBaseDelay = const Duration(seconds: 1),
    this.retryMaxDelay = const Duration(minutes: 5),
    this.maxConcurrentSends = 8,
    this.outboxBatchSize = 32,
    this.maxIncomingBatchSize = 128,
    this.maxAcknowledgementsPerRpc = 256,
    this.maxPendingAcknowledgements = 4096,
    this.maxConcurrentDeliveryHandlers = 16,
    this.incomingBatchWindow = const Duration(milliseconds: 1),
    this.ackBatchWindow = const Duration(milliseconds: 25),
    this.streamHandshakeTimeout = const Duration(seconds: 15),
    this.onStreamFailure,
  }) : _random = random ?? Random() {
    if (retryBaseDelay <= Duration.zero ||
        retryMaxDelay < retryBaseDelay ||
        maxConcurrentSends < 1 ||
        outboxBatchSize < maxConcurrentSends ||
        maxIncomingBatchSize < 1 ||
        maxAcknowledgementsPerRpc < 1 ||
        maxPendingAcknowledgements < maxAcknowledgementsPerRpc ||
        maxConcurrentDeliveryHandlers < 1 ||
        incomingBatchWindow < Duration.zero ||
        ackBatchWindow < Duration.zero ||
        streamHandshakeTimeout <= Duration.zero) {
      throw ArgumentError(
        'Retry settings must be positive and ordered, and the incoming batch window cannot be negative.',
      );
    }
    _history = ChatLocalHistory(
      store: store,
      scheduleOutbox: () => _outboxProcessor.scheduleOutboxWorker(),
    );
    _ackQueue = ChatAckQueue(
      rpc: rpc,
      ackBatchWindow: ackBatchWindow,
      maxAcknowledgementsPerRpc: maxAcknowledgementsPerRpc,
      maxPendingAcknowledgements: maxPendingAcknowledgements,
    );
    _mutationHandler = ChatMutationDeliveryHandler(
      store: store,
      ackQueue: _ackQueue,
      currentSession: _isCurrentSession,
      secretCrypto: () => secretCrypto,
      updatePreview: _history.updatePreviewFromHistory,
    );
    _outboxProcessor = ChatOutboxProcessor(
      rpc: rpc,
      store: store,
      retryBaseDelay: retryBaseDelay,
      retryMaxDelay: retryMaxDelay,
      maxConcurrentSends: maxConcurrentSends,
      outboxBatchSize: outboxBatchSize,
      isSyncStopped: () => _streamCoordinator.isStopped,
      isChatBeingWatched: _history.isBeingWatched,
      prepareMessagePayload: mediaTransfer?.prepareOutboxPayload,
      random: _random,
    );
    _readReceipts = ChatReadReceiptQueue(
      store: store,
      isCurrentSession: _isCurrentSession,
      scheduleOutbox: _outboxProcessor.scheduleOutboxWorker,
    );
    _inboundHandler = ChatInboundStreamHandler(
      store: store,
      ackQueue: _ackQueue,
      incomingBatchWindow: incomingBatchWindow,
      maxIncomingBatchSize: maxIncomingBatchSize,
      isCurrentSession: _isCurrentSession,
      isChatBeingWatched: _history.isBeingWatched,
      queueReadReceipts: _readReceipts.enqueue,
    );
    _conversations = ChatConversationResolver(
      store: store,
      isCurrentSession: _isCurrentSession,
      resolveRecipient: resolveRecipient,
      resolveRoomRecipient: resolveRoomRecipient,
    );
    _secretPreparer = ChatSecretOutboxPreparer(
      store: store,
      secretCrypto: () => secretCrypto,
      isCurrentSession: _isCurrentSession,
      outboxBatchSize: outboxBatchSize,
      mediaTransfer: mediaTransfer,
    );
    _sender = ChatMessageSender(
      store: store,
      secretCrypto: () => secretCrypto,
      newMessageId: _newMessageId,
      scheduleOutbox: _outboxProcessor.scheduleOutboxWorker,
      secretPreparer: _secretPreparer,
      updatePreview: _history.updatePreview,
    );
    _attachmentSender = ChatAttachmentSender(
      store: store,
      secretCrypto: () => secretCrypto,
      newMessageId: _newMessageId,
      scheduleOutbox: _outboxProcessor.scheduleOutboxWorker,
      secretPreparer: _secretPreparer,
      rpc: rpc,
      mediaTransfer: mediaTransfer,
    );
    _messageMutations = ChatMessageMutations(
      store: store,
      secretCrypto: () => secretCrypto,
      newMessageId: _newMessageId,
      scheduleOutbox: _outboxProcessor.scheduleOutboxWorker,
      updatePreview: _history.updatePreviewFromHistory,
    );
    _deliveryRouter = ChatDeliveryRouter(
      store: store,
      secretCrypto: () => secretCrypto,
      isCurrentSession: _isCurrentSession,
      isDeliveryAddressed: _isDeliveryAddressedToSession,
      observeRoomSequence: (delivery) =>
          _streamCoordinator.observeRoomSequence(delivery),
      ackQueue: _ackQueue,
      mutations: _mutationHandler,
      inbound: _inboundHandler,
      conversations: _conversations,
      isChatBeingWatched: _history.isBeingWatched,
      queueReadReceipts: _readReceipts.enqueue,
    );
    _streamCoordinator = ChatStreamCoordinator(
      rpc: rpc,
      store: store,
      ackQueue: _ackQueue,
      inbound: _inboundHandler,
      mutations: _mutationHandler,
      outbox: _outboxProcessor,
      secretPreparer: _secretPreparer,
      deliveryRouter: _deliveryRouter,
      secretCrypto: () => secretCrypto,
      maxConcurrentDeliveryHandlers: maxConcurrentDeliveryHandlers,
      streamHandshakeTimeout: streamHandshakeTimeout,
      onStreamFailure: onStreamFailure,
      onCloseMedia: mediaTransfer?.close,
    );
    _streamCoordinator.listenToReadiness();
  }

  final MessagingRpc rpc;
  final ChatStore store;
  final ChatMediaTransferService? mediaTransfer;
  final Future<Recipient> Function(String recipientId)? resolveRecipient;
  final Future<Recipient?> Function(
    String recipientId,
    RecipientType type,
    bool forceRefresh,
  )?
  resolveRoomRecipient;
  final Duration retryBaseDelay;
  final Duration retryMaxDelay;
  final int maxConcurrentSends;
  final int outboxBatchSize;
  final int maxIncomingBatchSize;
  final int maxAcknowledgementsPerRpc;
  final int maxPendingAcknowledgements;
  final int maxConcurrentDeliveryHandlers;
  final Duration incomingBatchWindow;
  final Duration ackBatchWindow;
  final Duration streamHandshakeTimeout;
  final void Function()? onStreamFailure;
  final Random _random;

  late final ChatConversationResolver _conversations;
  late final ChatSecretOutboxPreparer _secretPreparer;
  late final ChatMessageSender _sender;
  late final ChatAttachmentSender _attachmentSender;
  late final ChatMessageMutations _messageMutations;
  late final ChatDeliveryRouter _deliveryRouter;
  late final ChatLocalHistory _history;
  late final ChatAckQueue _ackQueue;
  late final ChatMutationDeliveryHandler _mutationHandler;
  late final ChatOutboxProcessor _outboxProcessor;
  late final ChatInboundStreamHandler _inboundHandler;
  late final ChatReadReceiptQueue _readReceipts;

  SecretChatCryptoPort? secretCrypto;
  late final ChatStreamCoordinator _streamCoordinator;
  bool _isCurrentSession(UserSession session) =>
      _streamCoordinator.isCurrentSession(session);
  @override
  Future<void> startSync() => _streamCoordinator.startSync();
  @override
  Future<void> stopSync() => _streamCoordinator.stopSync();
  Future<void> close() => _streamCoordinator.close();
  Future<void> reconnect() => _streamCoordinator.reconnect();
  bool _isDeliveryAddressedToSession(
    pb.MessageDelivery delivery,
    UserSession session,
  ) =>
      delivery.deliveryId.isNotEmpty &&
      delivery.messageId.isNotEmpty &&
      delivery.targetRecipientId == session.userId &&
      delivery.targetDeviceId == session.deviceId;

  @override
  bool get isStreamReady => rpc.isReady;

  @override
  Stream<bool> get streamReadinessChanges =>
      _streamCoordinator.readinessChanges;

  @override
  List<domain.ChatMessage> loadLocalHistory({required String chatId}) =>
      store.loadChatMessages(chatId);

  @override
  Map<String, MessageTranslation> loadMessageTranslations(
    List<String> messageIds, {
    required String targetLanguage,
  }) =>
      store.loadMessageTranslations(messageIds, targetLanguage: targetLanguage);

  @override
  Future<bool> saveMessageTranslation(MessageTranslation translation) async =>
      store.saveMessageTranslation(translation);

  @override
  List<domain.ChatMessage> loadEarlierMessages({
    required String chatId,
    required domain.ChatMessage before,
    int limit = 50,
  }) => store.loadEarlierChatMessages(
    chatId: chatId,
    before: before,
    limit: limit,
  );

  @override
  Future<Recipient> openOrCreateChat({
    required String recipientId,
    required Recipient recipient,
  }) async {
    if (recipientId.trim().isEmpty || recipient.id != recipientId) {
      throw ArgumentError(
        'A matching recipient id is required to open a chat.',
      );
    }
    final existing = store.loadRecipient(recipientId);
    if (existing != null) return existing;

    final conversation = Recipient(
      id: recipientId,
      type: recipient.type,
      name: recipient.name,
      handle: recipient.handle,
      avatarUrl: recipient.avatarUrl,
      isPresenceVisible: recipient.isPresenceVisible,
      isUsernameVisible: recipient.isUsernameVisible,
      composerRole: recipient.composerRole,
      canSendMessages: recipient.canSendMessages,
      membersCanSendMessages: recipient.membersCanSendMessages,
      membersCanSendMedia: recipient.membersCanSendMedia,
      membersCanSendStickersGifs: recipient.membersCanSendStickersGifs,
      membersCanEmbedLinks: recipient.membersCanEmbedLinks,
      membersCanAddMembers: recipient.membersCanAddMembers,
      membersCanChangeInfo: recipient.membersCanChangeInfo,
      membersCanReact: recipient.membersCanReact,
      membersCanForward: recipient.membersCanForward,
      slowModeSeconds: recipient.slowModeSeconds,
      memberCount: recipient.memberCount,
      isOfficial: recipient.isOfficial,
      visibility: recipient.visibility,
      restrictedUntil: recipient.restrictedUntil,
      verificationBadge: recipient.verificationBadge,
      isMember: recipient.isMember,
    );
    await store.saveRecipient(conversation);
    return conversation;
  }

  void configureSecretCrypto(SecretChatCryptoPort? crypto) {
    secretCrypto = crypto;
    if (crypto != null && !_streamCoordinator.isStopped) {
      final session = store.loadSession();
      if (session != null) {
        unawaited(
          _secretPreparer
              .recover(session)
              .catchError((Object error, StackTrace stackTrace) {
                developer.log(
                  'Could not recover prepared secret messages',
                  name: 'tureon.messaging',
                  error: error,
                  stackTrace: stackTrace,
                );
              })
              .whenComplete(_outboxProcessor.scheduleOutboxWorker),
        );
      }
    }
  }

  @override
  Future<domain.ChatMessage> sendSecretMessage({
    required String chatId,
    required String senderRecipientId,
    required String recipientServerDeviceId,
    required String body,
    String? replyToMessageId,
  }) => _sender.sendSecretMessage(
    chatId: chatId,
    senderRecipientId: senderRecipientId,
    recipientServerDeviceId: recipientServerDeviceId,
    body: body,
    replyToMessageId: replyToMessageId,
  );

  @override
  Future<domain.ChatMessage> sendMessage({
    required String chatId,
    required String senderRecipientId,
    required String body,
    String? replyToMessageId,
  }) => _sender.sendMessage(
    chatId: chatId,
    senderRecipientId: senderRecipientId,
    body: body,
    replyToMessageId: replyToMessageId,
  );

  @override
  Future<domain.ChatMessage> sendBotMessage({
    required Recipient recipient,
    required String senderRecipientId,
    required String body,
  }) => _sender.sendBotMessage(
    recipient: recipient,
    senderRecipientId: senderRecipientId,
    body: body,
  );

  @override
  Future<domain.ChatMessage> sendAttachment({
    required String chatId,
    required String senderRecipientId,
    required domain.ChatMessageType type,
    required String sourcePath,
    required String fileName,
    required String mimeType,
    required String caption,
    String? replyToMessageId,
    bool isSecret = false,
    String? recipientServerDeviceId,
    int? durationMillis,
  }) => _attachmentSender.sendAttachment(
    chatId: chatId,
    senderRecipientId: senderRecipientId,
    type: type,
    sourcePath: sourcePath,
    fileName: fileName,
    mimeType: mimeType,
    caption: caption,
    replyToMessageId: replyToMessageId,
    isSecret: isSecret,
    recipientServerDeviceId: recipientServerDeviceId,
    durationMillis: durationMillis,
  );

  @override
  Future<domain.ChatMessage> sendLocation({
    required String chatId,
    required String senderRecipientId,
    required double latitude,
    required double longitude,
    String? placeName,
    String caption = '',
    String? replyToMessageId,
    bool isSecret = false,
    String? recipientServerDeviceId,
  }) => _attachmentSender.sendLocation(
    chatId: chatId,
    senderRecipientId: senderRecipientId,
    latitude: latitude,
    longitude: longitude,
    placeName: placeName,
    caption: caption,
    replyToMessageId: replyToMessageId,
    isSecret: isSecret,
    recipientServerDeviceId: recipientServerDeviceId,
  );

  @override
  Future<String> resolveAttachmentLocalPath(domain.ChatAttachment attachment) =>
      _attachmentSender.resolveAttachmentLocalPath(attachment);

  @override
  Future<domain.ChatMessage> editMessage({
    required String messageId,
    required String chatId,
    required String targetRecipientId,
    required bool isSecret,
    String? targetDeviceId,
    required String body,
  }) => _messageMutations.editMessage(
    messageId: messageId,
    chatId: chatId,
    targetRecipientId: targetRecipientId,
    isSecret: isSecret,
    targetDeviceId: targetDeviceId,
    body: body,
  );

  @override
  Future<void> deleteMessage({
    required String messageId,
    required String chatId,
    required String targetRecipientId,
    required bool isSecret,
    String? targetDeviceId,
  }) => _messageMutations.deleteMessage(
    messageId: messageId,
    chatId: chatId,
    targetRecipientId: targetRecipientId,
    isSecret: isSecret,
    targetDeviceId: targetDeviceId,
  );

  @override
  Future<void> retryMessage(String messageId) async {
    final session = store.loadSession();
    if (session == null) return;
    store.retryFailedOutbox(session.userId, session.deviceId, messageId);
    await _secretPreparer.recover(session);
    _outboxProcessor.scheduleOutboxWorker();
    unawaited(OutboxBackgroundScheduler.enqueue());
  }

  @override
  Stream<List<domain.ChatMessage>> watchMessages({
    required String chatId,
    int limit = 100,
  }) => _history.watchMessages(chatId: chatId, limit: limit);
  @override
  Stream<domain.ChatMessage> streamMessages({required String chatId}) =>
      _history.streamMessages(chatId: chatId);
  @override
  Future<void> markConversationRead({
    required String chatId,
    required String peerRecipientId,
  }) => _history.markConversationRead(
    chatId: chatId,
    peerRecipientId: peerRecipientId,
  );

  void _requireStreamReady() {
    if (!rpc.isReady) {
      throw StateError(
        'A mensagem não foi enviada: conecte-se ao stream de mensagens em tempo real.',
      );
    }
  }

  @override
  Future<pb.InteractBotResponse> interactWithBot({
    required String username,
    required String text,
  }) {
    _requireStreamReady();
    return rpc.interactBot(
      pb.InteractBotRequest(botUsername: username, text: text),
    );
  }

  String _newMessageId() {
    final bytes = List<int>.generate(16, (_) => Random.secure().nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0'));
    final uuid = hex.join();
    return '${uuid.substring(0, 8)}-${uuid.substring(8, 12)}-'
        '${uuid.substring(12, 16)}-${uuid.substring(16, 20)}-'
        '${uuid.substring(20)}';
  }
}
