import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:typed_data';
import 'package:tureon/core/crypto/secret_chat_crypto_port.dart';
import 'package:tureon/core/protocol/recipient_type.dart';
import 'package:tureon/core/storage/chat_store.dart';
import 'package:tureon/core/storage/message_records.dart';
import 'package:tureon/generated/proto/tureon.pb.dart' as pb;
import '../../domain/chat_message.dart' as domain;
import '../../domain/chat_repository.dart';
import '../../domain/chat_message_placeholders.dart';
import '../mappers/chat_message_mapper.dart';
import 'system_message_delivery_mapper.dart';
import 'chat_ack_queue.dart';
import 'chat_mutation_delivery_handler.dart';
import 'chat_inbound_stream_handler.dart';
import 'chat_conversation_resolver.dart';

/// Persists incoming deliveries and mutations before queueing acknowledgements.
class ChatDeliveryRouter {
  ChatDeliveryRouter({
    required this.store,
    required this.secretCrypto,
    required this.isCurrentSession,
    required this.isDeliveryAddressed,
    required this.observeRoomSequence,
    required this.ackQueue,
    required this.mutations,
    required this.inbound,
    required this.conversations,
    required this.isChatBeingWatched,
    required this.queueReadReceipts,
  });
  final ChatStore store;
  final SecretChatCryptoPort? Function() secretCrypto;
  final bool Function(UserSession) isCurrentSession;
  final bool Function(pb.MessageDelivery, UserSession) isDeliveryAddressed;
  final void Function(pb.MessageDelivery) observeRoomSequence;
  final ChatAckQueue ackQueue;
  final ChatMutationDeliveryHandler mutations;
  final ChatInboundStreamHandler inbound;
  final ChatConversationResolver conversations;
  final bool Function(String) isChatBeingWatched;
  final void Function(List<pb.MessageDelivery>, UserSession) queueReadReceipts;
  final Map<String, Completer<void>> _pendingIncomingMessageWrites = {};
  static const _systemMessageMapper = SystemMessageDeliveryMapper();
  Future<void> handle(pb.MessageDelivery delivery, UserSession session) async {
    Completer<void>? pendingIncomingWrite;
    var ownsPendingIncomingWrite = false;
    var wasRemovedFromRoom = false;
    try {
      if (!isCurrentSession(session)) return;
      if (!isDeliveryAddressed(delivery, session)) {
        developer.log(
          'Dropped a delivery not addressed to the active device',
          name: 'tureon.messaging',
        );
        return;
      }
      observeRoomSequence(delivery);
      final eventType = delivery.eventType;
      final isIncomingMessageEvent =
          eventType ==
              pb
                  .MessageDeliveryEventType
                  .MESSAGE_DELIVERY_EVENT_TYPE_UNSPECIFIED ||
          eventType ==
              pb.MessageDeliveryEventType.MESSAGE_DELIVERY_EVENT_TYPE_MESSAGE;
      if (isIncomingMessageEvent &&
          delivery.receiptStatus ==
              pb.DeliveryStatus.DELIVERY_STATUS_UNSPECIFIED &&
          (delivery.chatKind == pb.ChatKind.CHAT_KIND_NORMAL ||
              delivery.chatKind == pb.ChatKind.CHAT_KIND_SECRET) &&
          store.loadChatMessage(delivery.messageId) == null) {
        final newWrite = Completer<void>();
        pendingIncomingWrite = _pendingIncomingMessageWrites.putIfAbsent(
          delivery.messageId,
          () => newWrite,
        );
        ownsPendingIncomingWrite = identical(pendingIncomingWrite, newWrite);
        if (ownsPendingIncomingWrite) {
          unawaited(pendingIncomingWrite.future.catchError((_) {}));
        }
      }
      try {
        final hasReceiptStatus =
            delivery.receiptStatus !=
            pb.DeliveryStatus.DELIVERY_STATUS_UNSPECIFIED;
        if (hasReceiptStatus ||
            eventType ==
                pb
                    .MessageDeliveryEventType
                    .MESSAGE_DELIVERY_EVENT_TYPE_RECEIPT) {
          final status = switch (delivery.receiptStatus) {
            pb.DeliveryStatus.DELIVERY_STATUS_DELIVERED =>
              domain.ChatDeliveryStatus.delivered,
            pb.DeliveryStatus.DELIVERY_STATUS_READ =>
              domain.ChatDeliveryStatus.read,
            _ => domain.ChatDeliveryStatus.unspecified,
          };
          if (status != domain.ChatDeliveryStatus.unspecified) {
            store.saveMessageReceiptStatus(delivery.messageId, status);
          }
          ackQueue.acknowledgePersisted(delivery);
          return;
        }
        final isMessageMutation =
            eventType ==
                pb
                    .MessageDeliveryEventType
                    .MESSAGE_DELIVERY_EVENT_TYPE_EDITED ||
            eventType ==
                pb.MessageDeliveryEventType.MESSAGE_DELIVERY_EVENT_TYPE_DELETED;
        if (isMessageMutation) {
          final originalWrite =
              _pendingIncomingMessageWrites[delivery.messageId];
          if (originalWrite != null) await originalWrite.future;
          await mutations.enqueue(delivery, session);
          return;
        }
        if (!isIncomingMessageEvent) {
          developer.log(
            'Dropped a message delivery with an unsupported event type',
            name: 'tureon.messaging',
          );
          return;
        }
        if (delivery.chatKind == pb.ChatKind.CHAT_KIND_SECRET) {
          if (store.hasCompletedSecretDelivery(delivery.deliveryId)) {
            ackQueue.acknowledgePersisted(delivery);
            return;
          }
          domain.ChatMessage message;
          try {
            final crypto = secretCrypto();
            if (crypto == null) {
              throw StateError(
                'Secret-chat encryption must be initialized before delivery.',
              );
            }
            final plaintext = await crypto.decrypt(
              secretChatId: delivery.senderRecipientId,
              ciphertext: Uint8List.fromList(delivery.payload),
            );
            final type = ChatMessageMapper.messageTypeFromProto(
              delivery.messageType,
            );
            final decoded = ChatMessageMapper.decodePayload(type, plaintext);
            message = domain.ChatMessage(
              messageId: delivery.messageId,
              chatId: secretChatLocalId(
                recipientId: delivery.senderRecipientId,
                firstDeviceId: session.deviceId,
                secondDeviceId: delivery.senderDeviceId,
              ),
              senderRecipientId: delivery.senderRecipientId,
              body: decoded.body,
              createdAt: ChatMessageMapper.createdAtFromDelivery(delivery),
              type: type,
              replyToMessageId: decoded.replyToMessageId,
              attachment: decoded.attachment,
            );
          } catch (_) {
            developer.log(
              'Failed to decrypt secret message payload',
              name: 'tureon.messaging',
            );
            message = domain.ChatMessage(
              messageId: delivery.messageId,
              chatId: secretChatLocalId(
                recipientId: delivery.senderRecipientId,
                firstDeviceId: session.deviceId,
                secondDeviceId: delivery.senderDeviceId,
              ),
              senderRecipientId: delivery.senderRecipientId,
              body: secretMessageDecryptionFailed,
              createdAt: ChatMessageMapper.createdAtFromDelivery(delivery),
              type: ChatMessageMapper.messageTypeFromProto(
                delivery.messageType,
              ),
            );
          }
          final recipient = await conversations.resolve(
            delivery.senderRecipientId,
          );
          if (!isCurrentSession(session)) return;
          store.saveIncomingSecretMessage(
            message: message,
            recipient: recipient,
            delivery: SecretDeliveryRecord(
              deliveryId: delivery.deliveryId,
              messageId: delivery.messageId,
              chatId: message.chatId,
              senderRecipientId: delivery.senderRecipientId,
              targetRecipientId: delivery.targetRecipientId,
              messageType: delivery.messageType.value,
              ciphertext: Uint8List.fromList(delivery.payload),
              timestamp: message.createdAt,
            ),
          );
          await mutations.replayDeferred(message.messageId, session);
          if (!isCurrentSession(session)) return;
          developer.log(
            'Saved incoming secret message',
            name: 'tureon.messaging',
          );
          final savedMessage =
              store.loadChatMessage(message.messageId) ?? message;
          if (delivery.senderRecipientId != session.userId &&
              isChatBeingWatched(savedMessage.chatId)) {
            queueReadReceipts([delivery], session);
          }
          ackQueue.acknowledgePersisted(delivery);
          return;
        }
        if (delivery.chatKind != pb.ChatKind.CHAT_KIND_NORMAL) {
          return;
        }
        final isSystemMessage =
            delivery.messageType == pb.MessageType.MESSAGE_TYPE_SYSTEM;
        final RoomSystemMessageDelivery? systemDelivery = isSystemMessage
            ? _systemMessageMapper.map(delivery, currentUserId: session.userId)
            : null;
        final conversationId = delivery.chatId;
        final type = ChatMessageMapper.messageTypeFromProto(
          delivery.messageType,
        );
        final decoded = isSystemMessage
            ? null
            : ChatMessageMapper.decodePayload(type, delivery.payload);
        final message =
            systemDelivery?.message ??
            domain.ChatMessage(
              messageId: delivery.messageId,
              chatId: conversationId,
              senderRecipientId: delivery.senderRecipientId,
              body:
                  decoded?.body ??
                  utf8.decode(delivery.payload, allowMalformed: true),
              createdAt: ChatMessageMapper.createdAtFromDelivery(delivery),
              type: type,
              replyToMessageId: decoded?.replyToMessageId,
              attachment: decoded?.attachment,
            );
        final hasRoomSnapshot =
            systemDelivery?.roomMetadata['room_type'] ==
                (systemDelivery?.roomType == RecipientType.group
                    ? 'group'
                    : 'channel') &&
            systemDelivery?.roomMetadata['room_member_count'] != null;
        // Membership snapshots arrive with current server events. For
        // older or incomplete payloads, refresh the room recipient
        // even when its timeline is not open so chat lists do not keep
        // a stale member count.
        final resolvedRecipient = await conversations.resolve(
          conversationId,
          roomType: systemDelivery?.roomType,
          session: session,
          refreshRoomMetadata: isSystemMessage && !hasRoomSnapshot,
        );
        if (!isCurrentSession(session)) return;
        final recipient = systemDelivery == null
            ? resolvedRecipient
            : conversations.applySnapshot(
                resolvedRecipient,
                systemDelivery,
                session.userId,
              );
        wasRemovedFromRoom =
            systemDelivery != null &&
            !recipient.isMember &&
            conversations.isCurrentUserRemoved(systemDelivery, session.userId);
        await inbound.queueIncomingMessage(
          delivery: delivery,
          message: message,
          recipient: recipient,
          session: session,
        );
        if (wasRemovedFromRoom) {
          conversations.invalidateRoom(conversationId);
          store.deleteRecipient(conversationId);
        }
        await mutations.replayDeferred(message.messageId, session);
      } catch (error, stackTrace) {
        developer.log(
          'Failed to process message delivery',
          error: error,
          stackTrace: stackTrace,
        );
      }
    } finally {
      if (ownsPendingIncomingWrite && pendingIncomingWrite != null) {
        if (!pendingIncomingWrite.isCompleted) {
          if (store.loadChatMessage(delivery.messageId) != null ||
              store.isChatMessageDeleted(delivery.messageId) ||
              wasRemovedFromRoom) {
            pendingIncomingWrite.complete();
          } else {
            pendingIncomingWrite.completeError(
              StateError(
                'Incoming message was not persisted before stream processing ended.',
              ),
            );
          }
        }
        if (identical(
          _pendingIncomingMessageWrites[delivery.messageId],
          pendingIncomingWrite,
        )) {
          _pendingIncomingMessageWrites.remove(delivery.messageId);
        }
      }
    }
  }
}
