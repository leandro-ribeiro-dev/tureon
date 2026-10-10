//
//  Generated code. Do not modify.
//  source: proto/tureon.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class MessageType extends $pb.ProtobufEnum {
  static const MessageType MESSAGE_TYPE_UNSPECIFIED = MessageType._(0, _omitEnumNames ? '' : 'MESSAGE_TYPE_UNSPECIFIED');
  static const MessageType MESSAGE_TYPE_TEXT = MessageType._(1, _omitEnumNames ? '' : 'MESSAGE_TYPE_TEXT');
  static const MessageType MESSAGE_TYPE_IMAGE = MessageType._(2, _omitEnumNames ? '' : 'MESSAGE_TYPE_IMAGE');
  static const MessageType MESSAGE_TYPE_VIDEO = MessageType._(3, _omitEnumNames ? '' : 'MESSAGE_TYPE_VIDEO');
  static const MessageType MESSAGE_TYPE_AUDIO = MessageType._(4, _omitEnumNames ? '' : 'MESSAGE_TYPE_AUDIO');
  static const MessageType MESSAGE_TYPE_VOICE_NOTE = MessageType._(5, _omitEnumNames ? '' : 'MESSAGE_TYPE_VOICE_NOTE');
  static const MessageType MESSAGE_TYPE_FILE = MessageType._(6, _omitEnumNames ? '' : 'MESSAGE_TYPE_FILE');
  static const MessageType MESSAGE_TYPE_STICKER = MessageType._(7, _omitEnumNames ? '' : 'MESSAGE_TYPE_STICKER');
  static const MessageType MESSAGE_TYPE_GIF = MessageType._(8, _omitEnumNames ? '' : 'MESSAGE_TYPE_GIF');
  static const MessageType MESSAGE_TYPE_LOCATION = MessageType._(9, _omitEnumNames ? '' : 'MESSAGE_TYPE_LOCATION');
  static const MessageType MESSAGE_TYPE_CONTACT_CARD = MessageType._(10, _omitEnumNames ? '' : 'MESSAGE_TYPE_CONTACT_CARD');
  static const MessageType MESSAGE_TYPE_REPLY = MessageType._(11, _omitEnumNames ? '' : 'MESSAGE_TYPE_REPLY');
  static const MessageType MESSAGE_TYPE_FORWARD = MessageType._(12, _omitEnumNames ? '' : 'MESSAGE_TYPE_FORWARD');
  static const MessageType MESSAGE_TYPE_REACTION = MessageType._(13, _omitEnumNames ? '' : 'MESSAGE_TYPE_REACTION');
  static const MessageType MESSAGE_TYPE_EDIT = MessageType._(14, _omitEnumNames ? '' : 'MESSAGE_TYPE_EDIT');
  static const MessageType MESSAGE_TYPE_DELETE = MessageType._(15, _omitEnumNames ? '' : 'MESSAGE_TYPE_DELETE');
  static const MessageType MESSAGE_TYPE_SYSTEM = MessageType._(16, _omitEnumNames ? '' : 'MESSAGE_TYPE_SYSTEM');

  static const $core.List<MessageType> values = <MessageType> [
    MESSAGE_TYPE_UNSPECIFIED,
    MESSAGE_TYPE_TEXT,
    MESSAGE_TYPE_IMAGE,
    MESSAGE_TYPE_VIDEO,
    MESSAGE_TYPE_AUDIO,
    MESSAGE_TYPE_VOICE_NOTE,
    MESSAGE_TYPE_FILE,
    MESSAGE_TYPE_STICKER,
    MESSAGE_TYPE_GIF,
    MESSAGE_TYPE_LOCATION,
    MESSAGE_TYPE_CONTACT_CARD,
    MESSAGE_TYPE_REPLY,
    MESSAGE_TYPE_FORWARD,
    MESSAGE_TYPE_REACTION,
    MESSAGE_TYPE_EDIT,
    MESSAGE_TYPE_DELETE,
    MESSAGE_TYPE_SYSTEM,
  ];

  static final $core.Map<$core.int, MessageType> _byValue = $pb.ProtobufEnum.initByValue(values);
  static MessageType? valueOf($core.int value) => _byValue[value];

  const MessageType._($core.int v, $core.String n) : super(v, n);
}

class RecipientType extends $pb.ProtobufEnum {
  static const RecipientType RECIPIENT_TYPE_UNSPECIFIED = RecipientType._(0, _omitEnumNames ? '' : 'RECIPIENT_TYPE_UNSPECIFIED');
  static const RecipientType RECIPIENT_TYPE_USER = RecipientType._(1, _omitEnumNames ? '' : 'RECIPIENT_TYPE_USER');
  static const RecipientType RECIPIENT_TYPE_GROUP = RecipientType._(2, _omitEnumNames ? '' : 'RECIPIENT_TYPE_GROUP');
  static const RecipientType RECIPIENT_TYPE_CHANNEL = RecipientType._(3, _omitEnumNames ? '' : 'RECIPIENT_TYPE_CHANNEL');
  static const RecipientType RECIPIENT_TYPE_BOT = RecipientType._(4, _omitEnumNames ? '' : 'RECIPIENT_TYPE_BOT');

  static const $core.List<RecipientType> values = <RecipientType> [
    RECIPIENT_TYPE_UNSPECIFIED,
    RECIPIENT_TYPE_USER,
    RECIPIENT_TYPE_GROUP,
    RECIPIENT_TYPE_CHANNEL,
    RECIPIENT_TYPE_BOT,
  ];

  static final $core.Map<$core.int, RecipientType> _byValue = $pb.ProtobufEnum.initByValue(values);
  static RecipientType? valueOf($core.int value) => _byValue[value];

  const RecipientType._($core.int v, $core.String n) : super(v, n);
}

class DeliveryStatus extends $pb.ProtobufEnum {
  static const DeliveryStatus DELIVERY_STATUS_UNSPECIFIED = DeliveryStatus._(0, _omitEnumNames ? '' : 'DELIVERY_STATUS_UNSPECIFIED');
  static const DeliveryStatus DELIVERY_STATUS_SENT = DeliveryStatus._(1, _omitEnumNames ? '' : 'DELIVERY_STATUS_SENT');
  static const DeliveryStatus DELIVERY_STATUS_DELIVERED = DeliveryStatus._(2, _omitEnumNames ? '' : 'DELIVERY_STATUS_DELIVERED');
  static const DeliveryStatus DELIVERY_STATUS_READ = DeliveryStatus._(3, _omitEnumNames ? '' : 'DELIVERY_STATUS_READ');

  static const $core.List<DeliveryStatus> values = <DeliveryStatus> [
    DELIVERY_STATUS_UNSPECIFIED,
    DELIVERY_STATUS_SENT,
    DELIVERY_STATUS_DELIVERED,
    DELIVERY_STATUS_READ,
  ];

  static final $core.Map<$core.int, DeliveryStatus> _byValue = $pb.ProtobufEnum.initByValue(values);
  static DeliveryStatus? valueOf($core.int value) => _byValue[value];

  const DeliveryStatus._($core.int v, $core.String n) : super(v, n);
}

class ChatKind extends $pb.ProtobufEnum {
  static const ChatKind CHAT_KIND_UNSPECIFIED = ChatKind._(0, _omitEnumNames ? '' : 'CHAT_KIND_UNSPECIFIED');
  static const ChatKind CHAT_KIND_NORMAL = ChatKind._(1, _omitEnumNames ? '' : 'CHAT_KIND_NORMAL');
  static const ChatKind CHAT_KIND_SECRET = ChatKind._(2, _omitEnumNames ? '' : 'CHAT_KIND_SECRET');

  static const $core.List<ChatKind> values = <ChatKind> [
    CHAT_KIND_UNSPECIFIED,
    CHAT_KIND_NORMAL,
    CHAT_KIND_SECRET,
  ];

  static final $core.Map<$core.int, ChatKind> _byValue = $pb.ProtobufEnum.initByValue(values);
  static ChatKind? valueOf($core.int value) => _byValue[value];

  const ChatKind._($core.int v, $core.String n) : super(v, n);
}

class SendMessageStatus extends $pb.ProtobufEnum {
  static const SendMessageStatus SEND_MESSAGE_STATUS_UNSPECIFIED = SendMessageStatus._(0, _omitEnumNames ? '' : 'SEND_MESSAGE_STATUS_UNSPECIFIED');
  static const SendMessageStatus SEND_MESSAGE_STATUS_ACCEPTED = SendMessageStatus._(1, _omitEnumNames ? '' : 'SEND_MESSAGE_STATUS_ACCEPTED');
  static const SendMessageStatus SEND_MESSAGE_STATUS_DUPLICATE = SendMessageStatus._(2, _omitEnumNames ? '' : 'SEND_MESSAGE_STATUS_DUPLICATE');

  static const $core.List<SendMessageStatus> values = <SendMessageStatus> [
    SEND_MESSAGE_STATUS_UNSPECIFIED,
    SEND_MESSAGE_STATUS_ACCEPTED,
    SEND_MESSAGE_STATUS_DUPLICATE,
  ];

  static final $core.Map<$core.int, SendMessageStatus> _byValue = $pb.ProtobufEnum.initByValue(values);
  static SendMessageStatus? valueOf($core.int value) => _byValue[value];

  const SendMessageStatus._($core.int v, $core.String n) : super(v, n);
}

class MessageDeliveryEventType extends $pb.ProtobufEnum {
  static const MessageDeliveryEventType MESSAGE_DELIVERY_EVENT_TYPE_UNSPECIFIED = MessageDeliveryEventType._(0, _omitEnumNames ? '' : 'MESSAGE_DELIVERY_EVENT_TYPE_UNSPECIFIED');
  static const MessageDeliveryEventType MESSAGE_DELIVERY_EVENT_TYPE_MESSAGE = MessageDeliveryEventType._(1, _omitEnumNames ? '' : 'MESSAGE_DELIVERY_EVENT_TYPE_MESSAGE');
  static const MessageDeliveryEventType MESSAGE_DELIVERY_EVENT_TYPE_RECEIPT = MessageDeliveryEventType._(2, _omitEnumNames ? '' : 'MESSAGE_DELIVERY_EVENT_TYPE_RECEIPT');
  static const MessageDeliveryEventType MESSAGE_DELIVERY_EVENT_TYPE_EDITED = MessageDeliveryEventType._(3, _omitEnumNames ? '' : 'MESSAGE_DELIVERY_EVENT_TYPE_EDITED');
  static const MessageDeliveryEventType MESSAGE_DELIVERY_EVENT_TYPE_DELETED = MessageDeliveryEventType._(4, _omitEnumNames ? '' : 'MESSAGE_DELIVERY_EVENT_TYPE_DELETED');

  static const $core.List<MessageDeliveryEventType> values = <MessageDeliveryEventType> [
    MESSAGE_DELIVERY_EVENT_TYPE_UNSPECIFIED,
    MESSAGE_DELIVERY_EVENT_TYPE_MESSAGE,
    MESSAGE_DELIVERY_EVENT_TYPE_RECEIPT,
    MESSAGE_DELIVERY_EVENT_TYPE_EDITED,
    MESSAGE_DELIVERY_EVENT_TYPE_DELETED,
  ];

  static final $core.Map<$core.int, MessageDeliveryEventType> _byValue = $pb.ProtobufEnum.initByValue(values);
  static MessageDeliveryEventType? valueOf($core.int value) => _byValue[value];

  const MessageDeliveryEventType._($core.int v, $core.String n) : super(v, n);
}

class MessageMutationType extends $pb.ProtobufEnum {
  static const MessageMutationType MESSAGE_MUTATION_TYPE_UNSPECIFIED = MessageMutationType._(0, _omitEnumNames ? '' : 'MESSAGE_MUTATION_TYPE_UNSPECIFIED');
  static const MessageMutationType MESSAGE_MUTATION_TYPE_EDIT = MessageMutationType._(1, _omitEnumNames ? '' : 'MESSAGE_MUTATION_TYPE_EDIT');
  static const MessageMutationType MESSAGE_MUTATION_TYPE_DELETE = MessageMutationType._(2, _omitEnumNames ? '' : 'MESSAGE_MUTATION_TYPE_DELETE');

  static const $core.List<MessageMutationType> values = <MessageMutationType> [
    MESSAGE_MUTATION_TYPE_UNSPECIFIED,
    MESSAGE_MUTATION_TYPE_EDIT,
    MESSAGE_MUTATION_TYPE_DELETE,
  ];

  static final $core.Map<$core.int, MessageMutationType> _byValue = $pb.ProtobufEnum.initByValue(values);
  static MessageMutationType? valueOf($core.int value) => _byValue[value];

  const MessageMutationType._($core.int v, $core.String n) : super(v, n);
}

class SystemEventType extends $pb.ProtobufEnum {
  static const SystemEventType SYSTEM_EVENT_TYPE_UNSPECIFIED = SystemEventType._(0, _omitEnumNames ? '' : 'SYSTEM_EVENT_TYPE_UNSPECIFIED');
  static const SystemEventType SYSTEM_EVENT_TYPE_USER_JOINED_GROUP = SystemEventType._(1, _omitEnumNames ? '' : 'SYSTEM_EVENT_TYPE_USER_JOINED_GROUP');
  static const SystemEventType SYSTEM_EVENT_TYPE_USER_LEFT_GROUP = SystemEventType._(2, _omitEnumNames ? '' : 'SYSTEM_EVENT_TYPE_USER_LEFT_GROUP');
  static const SystemEventType SYSTEM_EVENT_TYPE_USER_ADDED_TO_GROUP = SystemEventType._(3, _omitEnumNames ? '' : 'SYSTEM_EVENT_TYPE_USER_ADDED_TO_GROUP');
  static const SystemEventType SYSTEM_EVENT_TYPE_USER_REMOVED_FROM_GROUP = SystemEventType._(4, _omitEnumNames ? '' : 'SYSTEM_EVENT_TYPE_USER_REMOVED_FROM_GROUP');
  static const SystemEventType SYSTEM_EVENT_TYPE_USER_BANNED_FROM_GROUP = SystemEventType._(5, _omitEnumNames ? '' : 'SYSTEM_EVENT_TYPE_USER_BANNED_FROM_GROUP');
  static const SystemEventType SYSTEM_EVENT_TYPE_USER_UNBANNED_FROM_GROUP = SystemEventType._(6, _omitEnumNames ? '' : 'SYSTEM_EVENT_TYPE_USER_UNBANNED_FROM_GROUP');
  static const SystemEventType SYSTEM_EVENT_TYPE_GROUP_CREATED = SystemEventType._(7, _omitEnumNames ? '' : 'SYSTEM_EVENT_TYPE_GROUP_CREATED');
  static const SystemEventType SYSTEM_EVENT_TYPE_GROUP_RENAMED = SystemEventType._(8, _omitEnumNames ? '' : 'SYSTEM_EVENT_TYPE_GROUP_RENAMED');
  static const SystemEventType SYSTEM_EVENT_TYPE_GROUP_AVATAR_CHANGED = SystemEventType._(9, _omitEnumNames ? '' : 'SYSTEM_EVENT_TYPE_GROUP_AVATAR_CHANGED');
  static const SystemEventType SYSTEM_EVENT_TYPE_USER_JOINED_CHANNEL = SystemEventType._(10, _omitEnumNames ? '' : 'SYSTEM_EVENT_TYPE_USER_JOINED_CHANNEL');
  static const SystemEventType SYSTEM_EVENT_TYPE_USER_LEFT_CHANNEL = SystemEventType._(11, _omitEnumNames ? '' : 'SYSTEM_EVENT_TYPE_USER_LEFT_CHANNEL');
  static const SystemEventType SYSTEM_EVENT_TYPE_CHANNEL_CREATED = SystemEventType._(12, _omitEnumNames ? '' : 'SYSTEM_EVENT_TYPE_CHANNEL_CREATED');
  static const SystemEventType SYSTEM_EVENT_TYPE_CHANNEL_RENAMED = SystemEventType._(13, _omitEnumNames ? '' : 'SYSTEM_EVENT_TYPE_CHANNEL_RENAMED');
  static const SystemEventType SYSTEM_EVENT_TYPE_CHANNEL_BROADCAST = SystemEventType._(14, _omitEnumNames ? '' : 'SYSTEM_EVENT_TYPE_CHANNEL_BROADCAST');
  static const SystemEventType SYSTEM_EVENT_TYPE_USER_MUTED = SystemEventType._(15, _omitEnumNames ? '' : 'SYSTEM_EVENT_TYPE_USER_MUTED');
  static const SystemEventType SYSTEM_EVENT_TYPE_USER_UNMUTED = SystemEventType._(16, _omitEnumNames ? '' : 'SYSTEM_EVENT_TYPE_USER_UNMUTED');
  static const SystemEventType SYSTEM_EVENT_TYPE_BOT_ADDED = SystemEventType._(17, _omitEnumNames ? '' : 'SYSTEM_EVENT_TYPE_BOT_ADDED');
  static const SystemEventType SYSTEM_EVENT_TYPE_BOT_REMOVED = SystemEventType._(18, _omitEnumNames ? '' : 'SYSTEM_EVENT_TYPE_BOT_REMOVED');
  static const SystemEventType SYSTEM_EVENT_TYPE_GROUP_UPDATED = SystemEventType._(19, _omitEnumNames ? '' : 'SYSTEM_EVENT_TYPE_GROUP_UPDATED');
  static const SystemEventType SYSTEM_EVENT_TYPE_USER_ADDED_TO_CHANNEL = SystemEventType._(20, _omitEnumNames ? '' : 'SYSTEM_EVENT_TYPE_USER_ADDED_TO_CHANNEL');
  static const SystemEventType SYSTEM_EVENT_TYPE_USER_REMOVED_FROM_CHANNEL = SystemEventType._(21, _omitEnumNames ? '' : 'SYSTEM_EVENT_TYPE_USER_REMOVED_FROM_CHANNEL');
  static const SystemEventType SYSTEM_EVENT_TYPE_USER_BANNED_FROM_CHANNEL = SystemEventType._(22, _omitEnumNames ? '' : 'SYSTEM_EVENT_TYPE_USER_BANNED_FROM_CHANNEL');
  static const SystemEventType SYSTEM_EVENT_TYPE_USER_ROLE_CHANGED = SystemEventType._(23, _omitEnumNames ? '' : 'SYSTEM_EVENT_TYPE_USER_ROLE_CHANGED');
  static const SystemEventType SYSTEM_EVENT_TYPE_CHANNEL_UPDATED = SystemEventType._(24, _omitEnumNames ? '' : 'SYSTEM_EVENT_TYPE_CHANNEL_UPDATED');
  static const SystemEventType SYSTEM_EVENT_TYPE_GROUP_POLICY_CHANGED = SystemEventType._(25, _omitEnumNames ? '' : 'SYSTEM_EVENT_TYPE_GROUP_POLICY_CHANGED');
  static const SystemEventType SYSTEM_EVENT_TYPE_CHANNEL_POLICY_CHANGED = SystemEventType._(26, _omitEnumNames ? '' : 'SYSTEM_EVENT_TYPE_CHANNEL_POLICY_CHANGED');

  static const $core.List<SystemEventType> values = <SystemEventType> [
    SYSTEM_EVENT_TYPE_UNSPECIFIED,
    SYSTEM_EVENT_TYPE_USER_JOINED_GROUP,
    SYSTEM_EVENT_TYPE_USER_LEFT_GROUP,
    SYSTEM_EVENT_TYPE_USER_ADDED_TO_GROUP,
    SYSTEM_EVENT_TYPE_USER_REMOVED_FROM_GROUP,
    SYSTEM_EVENT_TYPE_USER_BANNED_FROM_GROUP,
    SYSTEM_EVENT_TYPE_USER_UNBANNED_FROM_GROUP,
    SYSTEM_EVENT_TYPE_GROUP_CREATED,
    SYSTEM_EVENT_TYPE_GROUP_RENAMED,
    SYSTEM_EVENT_TYPE_GROUP_AVATAR_CHANGED,
    SYSTEM_EVENT_TYPE_USER_JOINED_CHANNEL,
    SYSTEM_EVENT_TYPE_USER_LEFT_CHANNEL,
    SYSTEM_EVENT_TYPE_CHANNEL_CREATED,
    SYSTEM_EVENT_TYPE_CHANNEL_RENAMED,
    SYSTEM_EVENT_TYPE_CHANNEL_BROADCAST,
    SYSTEM_EVENT_TYPE_USER_MUTED,
    SYSTEM_EVENT_TYPE_USER_UNMUTED,
    SYSTEM_EVENT_TYPE_BOT_ADDED,
    SYSTEM_EVENT_TYPE_BOT_REMOVED,
    SYSTEM_EVENT_TYPE_GROUP_UPDATED,
    SYSTEM_EVENT_TYPE_USER_ADDED_TO_CHANNEL,
    SYSTEM_EVENT_TYPE_USER_REMOVED_FROM_CHANNEL,
    SYSTEM_EVENT_TYPE_USER_BANNED_FROM_CHANNEL,
    SYSTEM_EVENT_TYPE_USER_ROLE_CHANGED,
    SYSTEM_EVENT_TYPE_CHANNEL_UPDATED,
    SYSTEM_EVENT_TYPE_GROUP_POLICY_CHANGED,
    SYSTEM_EVENT_TYPE_CHANNEL_POLICY_CHANGED,
  ];

  static final $core.Map<$core.int, SystemEventType> _byValue = $pb.ProtobufEnum.initByValue(values);
  static SystemEventType? valueOf($core.int value) => _byValue[value];

  const SystemEventType._($core.int v, $core.String n) : super(v, n);
}


const _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
