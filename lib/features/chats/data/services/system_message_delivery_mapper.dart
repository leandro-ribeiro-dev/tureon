import 'dart:developer' as developer;

import 'package:tureon/core/protocol/protocol_models.dart';
import 'package:tureon/features/chats/data/mappers/chat_message_mapper.dart';
import 'package:tureon/features/chats/domain/chat_message.dart' as domain;
import 'package:tureon/generated/proto/tureon.pb.dart' as pb;

class RoomSystemMessageDelivery {
  const RoomSystemMessageDelivery({
    required this.message,
    required this.eventId,
    required this.roomId,
    required this.roomSequence,
    required this.roomType,
    required this.systemEvent,
    required this.roomMetadata,
  });

  final domain.ChatMessage message;
  final String eventId;
  final String roomId;
  final int roomSequence;
  final RecipientType? roomType;
  final SystemMessage? systemEvent;
  final Map<String, String> roomMetadata;
}

/// Converts a server-authored room event into the chat timeline model and
/// exposes its bounded room snapshot for local cache updates. The delivery
/// route and actor are checked before snapshot data is trusted.
class SystemMessageDeliveryMapper {
  const SystemMessageDeliveryMapper();

  RoomSystemMessageDelivery map(
    pb.MessageDelivery delivery, {
    required String currentUserId,
  }) {
    SystemMessage? event;
    Map<String, String> roomMetadata = const <String, String>{};
    try {
      final protoEvent = pb.SystemMessage.fromBuffer(delivery.payload);
      event = ChatMessageMapper.systemMessageFromProto(protoEvent);
      roomMetadata = Map<String, String>.unmodifiable(protoEvent.metadata);
    } catch (error, stackTrace) {
      developer.log(
        'Could not decode a room system event; preserving it as a fallback message',
        name: 'tureon.messaging',
        error: error,
        stackTrace: stackTrace,
      );
    }

    final envelopeRoomId = delivery.roomId.isNotEmpty
        ? delivery.roomId
        : delivery.chatId;
    final envelopeRoomMatches = envelopeRoomId == delivery.chatId;
    final payloadRoomId = _payloadRoomId(event);
    final payloadRouteMatches =
        payloadRoomId == null || payloadRoomId == envelopeRoomId;
    final actorMatches =
        event == null ||
        event.actorUserId.isEmpty ||
        event.actorUserId == delivery.senderRecipientId;
    if (!payloadRouteMatches || !actorMatches) {
      developer.log(
        'Room system event payload does not match its server delivery envelope',
        name: 'tureon.messaging',
      );
    }

    final validatedEvent =
        envelopeRoomMatches && payloadRoomId == envelopeRoomId && actorMatches
        ? event
        : null;
    final body = _render(validatedEvent, currentUserId);
    final validatedRoomMetadata = validatedEvent == null
        ? const <String, String>{}
        : roomMetadata;
    return RoomSystemMessageDelivery(
      message: domain.ChatMessage(
        messageId: delivery.messageId,
        chatId: delivery.chatId,
        senderRecipientId: delivery.senderRecipientId,
        body: body,
        createdAt: ChatMessageMapper.createdAtFromDelivery(delivery),
        type: domain.ChatMessageType.system,
      ),
      eventId: delivery.eventId,
      roomId: delivery.roomId.isNotEmpty ? delivery.roomId : delivery.chatId,
      roomSequence: delivery.roomSequence.toInt(),
      roomType: _roomType(validatedEvent, trustPayloadTarget: true),
      systemEvent: validatedEvent,
      roomMetadata: validatedRoomMetadata,
    );
  }

  String? _payloadRoomId(SystemMessage? event) {
    if (event == null) return null;
    final groupId = event.groupId;
    final channelId = event.channelId;
    final hasGroup = groupId?.isNotEmpty == true;
    final hasChannel = channelId?.isNotEmpty == true;
    if (hasGroup == hasChannel) return null;
    return hasGroup ? groupId : channelId;
  }

  RecipientType? _roomType(
    SystemMessage? event, {
    required bool trustPayloadTarget,
  }) {
    if (event == null) return null;
    final hasGroup = event.groupId?.isNotEmpty == true;
    final hasChannel = event.channelId?.isNotEmpty == true;
    if (trustPayloadTarget && hasGroup != hasChannel) {
      return hasGroup ? RecipientType.group : RecipientType.channel;
    }
    return switch (event.eventType) {
      SystemEventType.userJoinedGroup ||
      SystemEventType.userLeftGroup ||
      SystemEventType.userAddedToGroup ||
      SystemEventType.userRemovedFromGroup ||
      SystemEventType.userBannedFromGroup ||
      SystemEventType.userUnbannedFromGroup ||
      SystemEventType.groupCreated ||
      SystemEventType.groupRenamed ||
      SystemEventType.groupAvatarChanged ||
      SystemEventType.userMuted ||
      SystemEventType.userUnmuted ||
      SystemEventType.groupUpdated ||
      SystemEventType.groupPolicyChanged => RecipientType.group,
      SystemEventType.userJoinedChannel ||
      SystemEventType.userLeftChannel ||
      SystemEventType.userAddedToChannel ||
      SystemEventType.userRemovedFromChannel ||
      SystemEventType.userBannedFromChannel ||
      SystemEventType.userRoleChanged ||
      SystemEventType.channelCreated ||
      SystemEventType.channelRenamed ||
      SystemEventType.channelBroadcast ||
      SystemEventType.botAdded ||
      SystemEventType.botRemoved ||
      SystemEventType.channelUpdated ||
      SystemEventType.channelPolicyChanged => RecipientType.channel,
      SystemEventType.unspecified => null,
    };
  }

  String _render(SystemMessage? event, String currentUserId) {
    if (event == null) return 'Atualização do sistema';
    try {
      final actorUsername = event.actorUsername?.trim() ?? '';
      final targetUsername = event.targetUsername?.trim() ?? '';
      return event.renderText(
        actorName: event.actorUserId == currentUserId
            ? 'Você'
            : actorUsername.isEmpty
            ? 'Alguém'
            : '@$actorUsername',
        targetName: event.targetUserId == currentUserId
            ? 'você'
            : targetUsername.isEmpty
            ? 'um membro'
            : '@$targetUsername',
      );
    } catch (error, stackTrace) {
      developer.log(
        'Could not render a room system event; using a safe fallback',
        name: 'tureon.messaging',
        error: error,
        stackTrace: stackTrace,
      );
      return 'Atualização do sistema';
    }
  }
}
