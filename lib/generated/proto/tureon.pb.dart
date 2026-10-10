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

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import '../google/protobuf/field_mask.pb.dart' as $1;
import 'tureon.pbenum.dart';

export 'tureon.pbenum.dart';

class SendMessageRequest extends $pb.GeneratedMessage {
  factory SendMessageRequest({
    $core.String? messageId,
    $core.String? chatId,
    $core.String? senderRecipientId,
    $core.String? senderDeviceId,
    $core.String? targetRecipientId,
    ChatKind? chatKind,
    MessageType? messageType,
    $core.List<$core.int>? payload,
    $core.String? targetDeviceId,
  }) {
    final $result = create();
    if (messageId != null) {
      $result.messageId = messageId;
    }
    if (chatId != null) {
      $result.chatId = chatId;
    }
    if (senderRecipientId != null) {
      $result.senderRecipientId = senderRecipientId;
    }
    if (senderDeviceId != null) {
      $result.senderDeviceId = senderDeviceId;
    }
    if (targetRecipientId != null) {
      $result.targetRecipientId = targetRecipientId;
    }
    if (chatKind != null) {
      $result.chatKind = chatKind;
    }
    if (messageType != null) {
      $result.messageType = messageType;
    }
    if (payload != null) {
      $result.payload = payload;
    }
    if (targetDeviceId != null) {
      $result.targetDeviceId = targetDeviceId;
    }
    return $result;
  }
  SendMessageRequest._() : super();
  factory SendMessageRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SendMessageRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SendMessageRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'tureon.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'messageId')
    ..aOS(2, _omitFieldNames ? '' : 'chatId')
    ..aOS(3, _omitFieldNames ? '' : 'senderRecipientId')
    ..aOS(4, _omitFieldNames ? '' : 'senderDeviceId')
    ..aOS(5, _omitFieldNames ? '' : 'targetRecipientId')
    ..e<ChatKind>(6, _omitFieldNames ? '' : 'chatKind', $pb.PbFieldType.OE, defaultOrMaker: ChatKind.CHAT_KIND_UNSPECIFIED, valueOf: ChatKind.valueOf, enumValues: ChatKind.values)
    ..e<MessageType>(7, _omitFieldNames ? '' : 'messageType', $pb.PbFieldType.OE, defaultOrMaker: MessageType.MESSAGE_TYPE_UNSPECIFIED, valueOf: MessageType.valueOf, enumValues: MessageType.values)
    ..a<$core.List<$core.int>>(8, _omitFieldNames ? '' : 'payload', $pb.PbFieldType.OY)
    ..aOS(9, _omitFieldNames ? '' : 'targetDeviceId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SendMessageRequest clone() => SendMessageRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SendMessageRequest copyWith(void Function(SendMessageRequest) updates) => super.copyWith((message) => updates(message as SendMessageRequest)) as SendMessageRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SendMessageRequest create() => SendMessageRequest._();
  SendMessageRequest createEmptyInstance() => create();
  static $pb.PbList<SendMessageRequest> createRepeated() => $pb.PbList<SendMessageRequest>();
  @$core.pragma('dart2js:noInline')
  static SendMessageRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SendMessageRequest>(create);
  static SendMessageRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get messageId => $_getSZ(0);
  @$pb.TagNumber(1)
  set messageId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasMessageId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessageId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get chatId => $_getSZ(1);
  @$pb.TagNumber(2)
  set chatId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasChatId() => $_has(1);
  @$pb.TagNumber(2)
  void clearChatId() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get senderRecipientId => $_getSZ(2);
  @$pb.TagNumber(3)
  set senderRecipientId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasSenderRecipientId() => $_has(2);
  @$pb.TagNumber(3)
  void clearSenderRecipientId() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get senderDeviceId => $_getSZ(3);
  @$pb.TagNumber(4)
  set senderDeviceId($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasSenderDeviceId() => $_has(3);
  @$pb.TagNumber(4)
  void clearSenderDeviceId() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get targetRecipientId => $_getSZ(4);
  @$pb.TagNumber(5)
  set targetRecipientId($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasTargetRecipientId() => $_has(4);
  @$pb.TagNumber(5)
  void clearTargetRecipientId() => clearField(5);

  @$pb.TagNumber(6)
  ChatKind get chatKind => $_getN(5);
  @$pb.TagNumber(6)
  set chatKind(ChatKind v) { setField(6, v); }
  @$pb.TagNumber(6)
  $core.bool hasChatKind() => $_has(5);
  @$pb.TagNumber(6)
  void clearChatKind() => clearField(6);

  @$pb.TagNumber(7)
  MessageType get messageType => $_getN(6);
  @$pb.TagNumber(7)
  set messageType(MessageType v) { setField(7, v); }
  @$pb.TagNumber(7)
  $core.bool hasMessageType() => $_has(6);
  @$pb.TagNumber(7)
  void clearMessageType() => clearField(7);

  /// UTF-8 text for normal chats and opaque ciphertext for secret chats.
  @$pb.TagNumber(8)
  $core.List<$core.int> get payload => $_getN(7);
  @$pb.TagNumber(8)
  set payload($core.List<$core.int> v) { $_setBytes(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasPayload() => $_has(7);
  @$pb.TagNumber(8)
  void clearPayload() => clearField(8);

  /// Required for secret chats, which are bound to one recipient device.
  @$pb.TagNumber(9)
  $core.String get targetDeviceId => $_getSZ(8);
  @$pb.TagNumber(9)
  set targetDeviceId($core.String v) { $_setString(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasTargetDeviceId() => $_has(8);
  @$pb.TagNumber(9)
  void clearTargetDeviceId() => clearField(9);
}

class SendMessageResponse extends $pb.GeneratedMessage {
  factory SendMessageResponse({
    $core.String? messageId,
    $core.int? queuedDevices,
    $fixnum.Int64? serverTimestamp,
    SendMessageStatus? status,
    $fixnum.Int64? serverTimestampMicros,
  }) {
    final $result = create();
    if (messageId != null) {
      $result.messageId = messageId;
    }
    if (queuedDevices != null) {
      $result.queuedDevices = queuedDevices;
    }
    if (serverTimestamp != null) {
      $result.serverTimestamp = serverTimestamp;
    }
    if (status != null) {
      $result.status = status;
    }
    if (serverTimestampMicros != null) {
      $result.serverTimestampMicros = serverTimestampMicros;
    }
    return $result;
  }
  SendMessageResponse._() : super();
  factory SendMessageResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SendMessageResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SendMessageResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'tureon.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'messageId')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'queuedDevices', $pb.PbFieldType.O3)
    ..aInt64(3, _omitFieldNames ? '' : 'serverTimestamp')
    ..e<SendMessageStatus>(4, _omitFieldNames ? '' : 'status', $pb.PbFieldType.OE, defaultOrMaker: SendMessageStatus.SEND_MESSAGE_STATUS_UNSPECIFIED, valueOf: SendMessageStatus.valueOf, enumValues: SendMessageStatus.values)
    ..aInt64(5, _omitFieldNames ? '' : 'serverTimestampMicros')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SendMessageResponse clone() => SendMessageResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SendMessageResponse copyWith(void Function(SendMessageResponse) updates) => super.copyWith((message) => updates(message as SendMessageResponse)) as SendMessageResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SendMessageResponse create() => SendMessageResponse._();
  SendMessageResponse createEmptyInstance() => create();
  static $pb.PbList<SendMessageResponse> createRepeated() => $pb.PbList<SendMessageResponse>();
  @$core.pragma('dart2js:noInline')
  static SendMessageResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SendMessageResponse>(create);
  static SendMessageResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get messageId => $_getSZ(0);
  @$pb.TagNumber(1)
  set messageId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasMessageId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessageId() => clearField(1);

  /// Number of device-specific delivery rows created. Shared room-log messages
  /// create no per-device rows and return zero; clients sync them by cursor.
  @$pb.TagNumber(2)
  $core.int get queuedDevices => $_getIZ(1);
  @$pb.TagNumber(2)
  set queuedDevices($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasQueuedDevices() => $_has(1);
  @$pb.TagNumber(2)
  void clearQueuedDevices() => clearField(2);

  /// Unix timestamp in seconds, preserved for duplicate requests.
  @$pb.TagNumber(3)
  $fixnum.Int64 get serverTimestamp => $_getI64(2);
  @$pb.TagNumber(3)
  set serverTimestamp($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasServerTimestamp() => $_has(2);
  @$pb.TagNumber(3)
  void clearServerTimestamp() => clearField(3);

  @$pb.TagNumber(4)
  SendMessageStatus get status => $_getN(3);
  @$pb.TagNumber(4)
  set status(SendMessageStatus v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasStatus() => $_has(3);
  @$pb.TagNumber(4)
  void clearStatus() => clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get serverTimestampMicros => $_getI64(4);
  @$pb.TagNumber(5)
  set serverTimestampMicros($fixnum.Int64 v) { $_setInt64(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasServerTimestampMicros() => $_has(4);
  @$pb.TagNumber(5)
  void clearServerTimestampMicros() => clearField(5);
}

class MessageDelivery extends $pb.GeneratedMessage {
  factory MessageDelivery({
    $core.String? deliveryId,
    $core.String? messageId,
    $core.String? chatId,
    $core.String? senderRecipientId,
    $core.String? targetRecipientId,
    $core.String? targetDeviceId,
    ChatKind? chatKind,
    MessageType? messageType,
    $core.List<$core.int>? payload,
    $fixnum.Int64? createdAt,
    $core.String? senderDeviceId,
    MessageDeliveryEventType? eventType,
    DeliveryStatus? receiptStatus,
    $core.String? eventId,
    $fixnum.Int64? createdAtMicros,
    $fixnum.Int64? roomSequence,
    $core.String? roomId,
  }) {
    final $result = create();
    if (deliveryId != null) {
      $result.deliveryId = deliveryId;
    }
    if (messageId != null) {
      $result.messageId = messageId;
    }
    if (chatId != null) {
      $result.chatId = chatId;
    }
    if (senderRecipientId != null) {
      $result.senderRecipientId = senderRecipientId;
    }
    if (targetRecipientId != null) {
      $result.targetRecipientId = targetRecipientId;
    }
    if (targetDeviceId != null) {
      $result.targetDeviceId = targetDeviceId;
    }
    if (chatKind != null) {
      $result.chatKind = chatKind;
    }
    if (messageType != null) {
      $result.messageType = messageType;
    }
    if (payload != null) {
      $result.payload = payload;
    }
    if (createdAt != null) {
      $result.createdAt = createdAt;
    }
    if (senderDeviceId != null) {
      $result.senderDeviceId = senderDeviceId;
    }
    if (eventType != null) {
      $result.eventType = eventType;
    }
    if (receiptStatus != null) {
      $result.receiptStatus = receiptStatus;
    }
    if (eventId != null) {
      $result.eventId = eventId;
    }
    if (createdAtMicros != null) {
      $result.createdAtMicros = createdAtMicros;
    }
    if (roomSequence != null) {
      $result.roomSequence = roomSequence;
    }
    if (roomId != null) {
      $result.roomId = roomId;
    }
    return $result;
  }
  MessageDelivery._() : super();
  factory MessageDelivery.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MessageDelivery.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MessageDelivery', package: const $pb.PackageName(_omitMessageNames ? '' : 'tureon.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'deliveryId')
    ..aOS(2, _omitFieldNames ? '' : 'messageId')
    ..aOS(3, _omitFieldNames ? '' : 'chatId')
    ..aOS(4, _omitFieldNames ? '' : 'senderRecipientId')
    ..aOS(5, _omitFieldNames ? '' : 'targetRecipientId')
    ..aOS(6, _omitFieldNames ? '' : 'targetDeviceId')
    ..e<ChatKind>(7, _omitFieldNames ? '' : 'chatKind', $pb.PbFieldType.OE, defaultOrMaker: ChatKind.CHAT_KIND_UNSPECIFIED, valueOf: ChatKind.valueOf, enumValues: ChatKind.values)
    ..e<MessageType>(8, _omitFieldNames ? '' : 'messageType', $pb.PbFieldType.OE, defaultOrMaker: MessageType.MESSAGE_TYPE_UNSPECIFIED, valueOf: MessageType.valueOf, enumValues: MessageType.values)
    ..a<$core.List<$core.int>>(9, _omitFieldNames ? '' : 'payload', $pb.PbFieldType.OY)
    ..aInt64(10, _omitFieldNames ? '' : 'createdAt')
    ..aOS(11, _omitFieldNames ? '' : 'senderDeviceId')
    ..e<MessageDeliveryEventType>(12, _omitFieldNames ? '' : 'eventType', $pb.PbFieldType.OE, defaultOrMaker: MessageDeliveryEventType.MESSAGE_DELIVERY_EVENT_TYPE_UNSPECIFIED, valueOf: MessageDeliveryEventType.valueOf, enumValues: MessageDeliveryEventType.values)
    ..e<DeliveryStatus>(13, _omitFieldNames ? '' : 'receiptStatus', $pb.PbFieldType.OE, defaultOrMaker: DeliveryStatus.DELIVERY_STATUS_UNSPECIFIED, valueOf: DeliveryStatus.valueOf, enumValues: DeliveryStatus.values)
    ..aOS(14, _omitFieldNames ? '' : 'eventId')
    ..aInt64(15, _omitFieldNames ? '' : 'createdAtMicros')
    ..aInt64(16, _omitFieldNames ? '' : 'roomSequence')
    ..aOS(17, _omitFieldNames ? '' : 'roomId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MessageDelivery clone() => MessageDelivery()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MessageDelivery copyWith(void Function(MessageDelivery) updates) => super.copyWith((message) => updates(message as MessageDelivery)) as MessageDelivery;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MessageDelivery create() => MessageDelivery._();
  MessageDelivery createEmptyInstance() => create();
  static $pb.PbList<MessageDelivery> createRepeated() => $pb.PbList<MessageDelivery>();
  @$core.pragma('dart2js:noInline')
  static MessageDelivery getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MessageDelivery>(create);
  static MessageDelivery? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get deliveryId => $_getSZ(0);
  @$pb.TagNumber(1)
  set deliveryId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasDeliveryId() => $_has(0);
  @$pb.TagNumber(1)
  void clearDeliveryId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get messageId => $_getSZ(1);
  @$pb.TagNumber(2)
  set messageId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMessageId() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessageId() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get chatId => $_getSZ(2);
  @$pb.TagNumber(3)
  set chatId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasChatId() => $_has(2);
  @$pb.TagNumber(3)
  void clearChatId() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get senderRecipientId => $_getSZ(3);
  @$pb.TagNumber(4)
  set senderRecipientId($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasSenderRecipientId() => $_has(3);
  @$pb.TagNumber(4)
  void clearSenderRecipientId() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get targetRecipientId => $_getSZ(4);
  @$pb.TagNumber(5)
  set targetRecipientId($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasTargetRecipientId() => $_has(4);
  @$pb.TagNumber(5)
  void clearTargetRecipientId() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get targetDeviceId => $_getSZ(5);
  @$pb.TagNumber(6)
  set targetDeviceId($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasTargetDeviceId() => $_has(5);
  @$pb.TagNumber(6)
  void clearTargetDeviceId() => clearField(6);

  @$pb.TagNumber(7)
  ChatKind get chatKind => $_getN(6);
  @$pb.TagNumber(7)
  set chatKind(ChatKind v) { setField(7, v); }
  @$pb.TagNumber(7)
  $core.bool hasChatKind() => $_has(6);
  @$pb.TagNumber(7)
  void clearChatKind() => clearField(7);

  @$pb.TagNumber(8)
  MessageType get messageType => $_getN(7);
  @$pb.TagNumber(8)
  set messageType(MessageType v) { setField(8, v); }
  @$pb.TagNumber(8)
  $core.bool hasMessageType() => $_has(7);
  @$pb.TagNumber(8)
  void clearMessageType() => clearField(8);

  @$pb.TagNumber(9)
  $core.List<$core.int> get payload => $_getN(8);
  @$pb.TagNumber(9)
  set payload($core.List<$core.int> v) { $_setBytes(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasPayload() => $_has(8);
  @$pb.TagNumber(9)
  void clearPayload() => clearField(9);

  @$pb.TagNumber(10)
  $fixnum.Int64 get createdAt => $_getI64(9);
  @$pb.TagNumber(10)
  set createdAt($fixnum.Int64 v) { $_setInt64(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasCreatedAt() => $_has(9);
  @$pb.TagNumber(10)
  void clearCreatedAt() => clearField(10);

  @$pb.TagNumber(11)
  $core.String get senderDeviceId => $_getSZ(10);
  @$pb.TagNumber(11)
  set senderDeviceId($core.String v) { $_setString(10, v); }
  @$pb.TagNumber(11)
  $core.bool hasSenderDeviceId() => $_has(10);
  @$pb.TagNumber(11)
  void clearSenderDeviceId() => clearField(11);

  @$pb.TagNumber(12)
  MessageDeliveryEventType get eventType => $_getN(11);
  @$pb.TagNumber(12)
  set eventType(MessageDeliveryEventType v) { setField(12, v); }
  @$pb.TagNumber(12)
  $core.bool hasEventType() => $_has(11);
  @$pb.TagNumber(12)
  void clearEventType() => clearField(12);

  @$pb.TagNumber(13)
  DeliveryStatus get receiptStatus => $_getN(12);
  @$pb.TagNumber(13)
  set receiptStatus(DeliveryStatus v) { setField(13, v); }
  @$pb.TagNumber(13)
  $core.bool hasReceiptStatus() => $_has(12);
  @$pb.TagNumber(13)
  void clearReceiptStatus() => clearField(13);

  @$pb.TagNumber(14)
  $core.String get eventId => $_getSZ(13);
  @$pb.TagNumber(14)
  set eventId($core.String v) { $_setString(13, v); }
  @$pb.TagNumber(14)
  $core.bool hasEventId() => $_has(13);
  @$pb.TagNumber(14)
  void clearEventId() => clearField(14);

  @$pb.TagNumber(15)
  $fixnum.Int64 get createdAtMicros => $_getI64(14);
  @$pb.TagNumber(15)
  set createdAtMicros($fixnum.Int64 v) { $_setInt64(14, v); }
  @$pb.TagNumber(15)
  $core.bool hasCreatedAtMicros() => $_has(14);
  @$pb.TagNumber(15)
  void clearCreatedAtMicros() => clearField(15);

  /// Monotonic position in a shared group/channel log. Zero for direct
  /// per-device deliveries. Clients use it to detect duplicate or missing room
  /// events while the server persists the acknowledged room cursor.
  @$pb.TagNumber(16)
  $fixnum.Int64 get roomSequence => $_getI64(15);
  @$pb.TagNumber(16)
  set roomSequence($fixnum.Int64 v) { $_setInt64(15, v); }
  @$pb.TagNumber(16)
  $core.bool hasRoomSequence() => $_has(15);
  @$pb.TagNumber(16)
  void clearRoomSequence() => clearField(16);

  /// Explicit group/channel scope. Kept alongside chat_id for clients that
  /// distinguish direct chats from room events.
  @$pb.TagNumber(17)
  $core.String get roomId => $_getSZ(16);
  @$pb.TagNumber(17)
  set roomId($core.String v) { $_setString(16, v); }
  @$pb.TagNumber(17)
  $core.bool hasRoomId() => $_has(16);
  @$pb.TagNumber(17)
  void clearRoomId() => clearField(17);
}

class DeliveryAcknowledgement extends $pb.GeneratedMessage {
  factory DeliveryAcknowledgement({
    $core.String? deliveryId,
    $core.String? targetDeviceId,
  }) {
    final $result = create();
    if (deliveryId != null) {
      $result.deliveryId = deliveryId;
    }
    if (targetDeviceId != null) {
      $result.targetDeviceId = targetDeviceId;
    }
    return $result;
  }
  DeliveryAcknowledgement._() : super();
  factory DeliveryAcknowledgement.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DeliveryAcknowledgement.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DeliveryAcknowledgement', package: const $pb.PackageName(_omitMessageNames ? '' : 'tureon.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'deliveryId')
    ..aOS(2, _omitFieldNames ? '' : 'targetDeviceId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DeliveryAcknowledgement clone() => DeliveryAcknowledgement()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DeliveryAcknowledgement copyWith(void Function(DeliveryAcknowledgement) updates) => super.copyWith((message) => updates(message as DeliveryAcknowledgement)) as DeliveryAcknowledgement;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeliveryAcknowledgement create() => DeliveryAcknowledgement._();
  DeliveryAcknowledgement createEmptyInstance() => create();
  static $pb.PbList<DeliveryAcknowledgement> createRepeated() => $pb.PbList<DeliveryAcknowledgement>();
  @$core.pragma('dart2js:noInline')
  static DeliveryAcknowledgement getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DeliveryAcknowledgement>(create);
  static DeliveryAcknowledgement? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get deliveryId => $_getSZ(0);
  @$pb.TagNumber(1)
  set deliveryId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasDeliveryId() => $_has(0);
  @$pb.TagNumber(1)
  void clearDeliveryId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get targetDeviceId => $_getSZ(1);
  @$pb.TagNumber(2)
  set targetDeviceId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasTargetDeviceId() => $_has(1);
  @$pb.TagNumber(2)
  void clearTargetDeviceId() => clearField(2);
}

class AckDeliveryRequest extends $pb.GeneratedMessage {
  factory AckDeliveryRequest({
    $core.String? deliveryId,
    $core.String? targetDeviceId,
    $core.Iterable<DeliveryAcknowledgement>? deliveries,
  }) {
    final $result = create();
    if (deliveryId != null) {
      $result.deliveryId = deliveryId;
    }
    if (targetDeviceId != null) {
      $result.targetDeviceId = targetDeviceId;
    }
    if (deliveries != null) {
      $result.deliveries.addAll(deliveries);
    }
    return $result;
  }
  AckDeliveryRequest._() : super();
  factory AckDeliveryRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AckDeliveryRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AckDeliveryRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'tureon.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'deliveryId')
    ..aOS(2, _omitFieldNames ? '' : 'targetDeviceId')
    ..pc<DeliveryAcknowledgement>(3, _omitFieldNames ? '' : 'deliveries', $pb.PbFieldType.PM, subBuilder: DeliveryAcknowledgement.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AckDeliveryRequest clone() => AckDeliveryRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AckDeliveryRequest copyWith(void Function(AckDeliveryRequest) updates) => super.copyWith((message) => updates(message as AckDeliveryRequest)) as AckDeliveryRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AckDeliveryRequest create() => AckDeliveryRequest._();
  AckDeliveryRequest createEmptyInstance() => create();
  static $pb.PbList<AckDeliveryRequest> createRepeated() => $pb.PbList<AckDeliveryRequest>();
  @$core.pragma('dart2js:noInline')
  static AckDeliveryRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AckDeliveryRequest>(create);
  static AckDeliveryRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get deliveryId => $_getSZ(0);
  @$pb.TagNumber(1)
  set deliveryId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasDeliveryId() => $_has(0);
  @$pb.TagNumber(1)
  void clearDeliveryId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get targetDeviceId => $_getSZ(1);
  @$pb.TagNumber(2)
  set targetDeviceId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasTargetDeviceId() => $_has(1);
  @$pb.TagNumber(2)
  void clearTargetDeviceId() => clearField(2);

  @$pb.TagNumber(3)
  $core.List<DeliveryAcknowledgement> get deliveries => $_getList(2);
}

class SendReadReceiptRequest extends $pb.GeneratedMessage {
  factory SendReadReceiptRequest({
    $core.String? senderRecipientId,
    $core.String? messageId,
  }) {
    final $result = create();
    if (senderRecipientId != null) {
      $result.senderRecipientId = senderRecipientId;
    }
    if (messageId != null) {
      $result.messageId = messageId;
    }
    return $result;
  }
  SendReadReceiptRequest._() : super();
  factory SendReadReceiptRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SendReadReceiptRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SendReadReceiptRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'tureon.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'senderRecipientId')
    ..aOS(2, _omitFieldNames ? '' : 'messageId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SendReadReceiptRequest clone() => SendReadReceiptRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SendReadReceiptRequest copyWith(void Function(SendReadReceiptRequest) updates) => super.copyWith((message) => updates(message as SendReadReceiptRequest)) as SendReadReceiptRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SendReadReceiptRequest create() => SendReadReceiptRequest._();
  SendReadReceiptRequest createEmptyInstance() => create();
  static $pb.PbList<SendReadReceiptRequest> createRepeated() => $pb.PbList<SendReadReceiptRequest>();
  @$core.pragma('dart2js:noInline')
  static SendReadReceiptRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SendReadReceiptRequest>(create);
  static SendReadReceiptRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get senderRecipientId => $_getSZ(0);
  @$pb.TagNumber(1)
  set senderRecipientId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSenderRecipientId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSenderRecipientId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get messageId => $_getSZ(1);
  @$pb.TagNumber(2)
  set messageId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMessageId() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessageId() => clearField(2);
}

class SendMessageMutationRequest extends $pb.GeneratedMessage {
  factory SendMessageMutationRequest({
    $core.String? mutationId,
    $core.String? messageId,
    $core.String? chatId,
    $core.String? senderRecipientId,
    $core.String? senderDeviceId,
    $core.String? targetRecipientId,
    $core.String? targetDeviceId,
    ChatKind? chatKind,
    MessageMutationType? mutationType,
    $core.List<$core.int>? payload,
  }) {
    final $result = create();
    if (mutationId != null) {
      $result.mutationId = mutationId;
    }
    if (messageId != null) {
      $result.messageId = messageId;
    }
    if (chatId != null) {
      $result.chatId = chatId;
    }
    if (senderRecipientId != null) {
      $result.senderRecipientId = senderRecipientId;
    }
    if (senderDeviceId != null) {
      $result.senderDeviceId = senderDeviceId;
    }
    if (targetRecipientId != null) {
      $result.targetRecipientId = targetRecipientId;
    }
    if (targetDeviceId != null) {
      $result.targetDeviceId = targetDeviceId;
    }
    if (chatKind != null) {
      $result.chatKind = chatKind;
    }
    if (mutationType != null) {
      $result.mutationType = mutationType;
    }
    if (payload != null) {
      $result.payload = payload;
    }
    return $result;
  }
  SendMessageMutationRequest._() : super();
  factory SendMessageMutationRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SendMessageMutationRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SendMessageMutationRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'tureon.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'mutationId')
    ..aOS(2, _omitFieldNames ? '' : 'messageId')
    ..aOS(3, _omitFieldNames ? '' : 'chatId')
    ..aOS(4, _omitFieldNames ? '' : 'senderRecipientId')
    ..aOS(5, _omitFieldNames ? '' : 'senderDeviceId')
    ..aOS(6, _omitFieldNames ? '' : 'targetRecipientId')
    ..aOS(7, _omitFieldNames ? '' : 'targetDeviceId')
    ..e<ChatKind>(8, _omitFieldNames ? '' : 'chatKind', $pb.PbFieldType.OE, defaultOrMaker: ChatKind.CHAT_KIND_UNSPECIFIED, valueOf: ChatKind.valueOf, enumValues: ChatKind.values)
    ..e<MessageMutationType>(9, _omitFieldNames ? '' : 'mutationType', $pb.PbFieldType.OE, defaultOrMaker: MessageMutationType.MESSAGE_MUTATION_TYPE_UNSPECIFIED, valueOf: MessageMutationType.valueOf, enumValues: MessageMutationType.values)
    ..a<$core.List<$core.int>>(10, _omitFieldNames ? '' : 'payload', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SendMessageMutationRequest clone() => SendMessageMutationRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SendMessageMutationRequest copyWith(void Function(SendMessageMutationRequest) updates) => super.copyWith((message) => updates(message as SendMessageMutationRequest)) as SendMessageMutationRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SendMessageMutationRequest create() => SendMessageMutationRequest._();
  SendMessageMutationRequest createEmptyInstance() => create();
  static $pb.PbList<SendMessageMutationRequest> createRepeated() => $pb.PbList<SendMessageMutationRequest>();
  @$core.pragma('dart2js:noInline')
  static SendMessageMutationRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SendMessageMutationRequest>(create);
  static SendMessageMutationRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get mutationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set mutationId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasMutationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMutationId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get messageId => $_getSZ(1);
  @$pb.TagNumber(2)
  set messageId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMessageId() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessageId() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get chatId => $_getSZ(2);
  @$pb.TagNumber(3)
  set chatId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasChatId() => $_has(2);
  @$pb.TagNumber(3)
  void clearChatId() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get senderRecipientId => $_getSZ(3);
  @$pb.TagNumber(4)
  set senderRecipientId($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasSenderRecipientId() => $_has(3);
  @$pb.TagNumber(4)
  void clearSenderRecipientId() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get senderDeviceId => $_getSZ(4);
  @$pb.TagNumber(5)
  set senderDeviceId($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasSenderDeviceId() => $_has(4);
  @$pb.TagNumber(5)
  void clearSenderDeviceId() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get targetRecipientId => $_getSZ(5);
  @$pb.TagNumber(6)
  set targetRecipientId($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasTargetRecipientId() => $_has(5);
  @$pb.TagNumber(6)
  void clearTargetRecipientId() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get targetDeviceId => $_getSZ(6);
  @$pb.TagNumber(7)
  set targetDeviceId($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasTargetDeviceId() => $_has(6);
  @$pb.TagNumber(7)
  void clearTargetDeviceId() => clearField(7);

  @$pb.TagNumber(8)
  ChatKind get chatKind => $_getN(7);
  @$pb.TagNumber(8)
  set chatKind(ChatKind v) { setField(8, v); }
  @$pb.TagNumber(8)
  $core.bool hasChatKind() => $_has(7);
  @$pb.TagNumber(8)
  void clearChatKind() => clearField(8);

  @$pb.TagNumber(9)
  MessageMutationType get mutationType => $_getN(8);
  @$pb.TagNumber(9)
  set mutationType(MessageMutationType v) { setField(9, v); }
  @$pb.TagNumber(9)
  $core.bool hasMutationType() => $_has(8);
  @$pb.TagNumber(9)
  void clearMutationType() => clearField(9);

  @$pb.TagNumber(10)
  $core.List<$core.int> get payload => $_getN(9);
  @$pb.TagNumber(10)
  set payload($core.List<$core.int> v) { $_setBytes(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasPayload() => $_has(9);
  @$pb.TagNumber(10)
  void clearPayload() => clearField(10);
}

class ChatStreamOpen extends $pb.GeneratedMessage {
  factory ChatStreamOpen({
    $core.String? recipientId,
    $core.String? deviceId,
  }) {
    final $result = create();
    if (recipientId != null) {
      $result.recipientId = recipientId;
    }
    if (deviceId != null) {
      $result.deviceId = deviceId;
    }
    return $result;
  }
  ChatStreamOpen._() : super();
  factory ChatStreamOpen.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ChatStreamOpen.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ChatStreamOpen', package: const $pb.PackageName(_omitMessageNames ? '' : 'tureon.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'recipientId')
    ..aOS(2, _omitFieldNames ? '' : 'deviceId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ChatStreamOpen clone() => ChatStreamOpen()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ChatStreamOpen copyWith(void Function(ChatStreamOpen) updates) => super.copyWith((message) => updates(message as ChatStreamOpen)) as ChatStreamOpen;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ChatStreamOpen create() => ChatStreamOpen._();
  ChatStreamOpen createEmptyInstance() => create();
  static $pb.PbList<ChatStreamOpen> createRepeated() => $pb.PbList<ChatStreamOpen>();
  @$core.pragma('dart2js:noInline')
  static ChatStreamOpen getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ChatStreamOpen>(create);
  static ChatStreamOpen? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get recipientId => $_getSZ(0);
  @$pb.TagNumber(1)
  set recipientId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasRecipientId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRecipientId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get deviceId => $_getSZ(1);
  @$pb.TagNumber(2)
  set deviceId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasDeviceId() => $_has(1);
  @$pb.TagNumber(2)
  void clearDeviceId() => clearField(2);
}

enum ChatStreamBatchCommand_Command {
  sendMessage, 
  interactBot, 
  notSet
}

class ChatStreamBatchCommand extends $pb.GeneratedMessage {
  factory ChatStreamBatchCommand({
    $core.String? commandId,
    SendMessageRequest? sendMessage,
    InteractBotRequest? interactBot,
  }) {
    final $result = create();
    if (commandId != null) {
      $result.commandId = commandId;
    }
    if (sendMessage != null) {
      $result.sendMessage = sendMessage;
    }
    if (interactBot != null) {
      $result.interactBot = interactBot;
    }
    return $result;
  }
  ChatStreamBatchCommand._() : super();
  factory ChatStreamBatchCommand.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ChatStreamBatchCommand.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static const $core.Map<$core.int, ChatStreamBatchCommand_Command> _ChatStreamBatchCommand_CommandByTag = {
    2 : ChatStreamBatchCommand_Command.sendMessage,
    3 : ChatStreamBatchCommand_Command.interactBot,
    0 : ChatStreamBatchCommand_Command.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ChatStreamBatchCommand', package: const $pb.PackageName(_omitMessageNames ? '' : 'tureon.v1'), createEmptyInstance: create)
    ..oo(0, [2, 3])
    ..aOS(1, _omitFieldNames ? '' : 'commandId')
    ..aOM<SendMessageRequest>(2, _omitFieldNames ? '' : 'sendMessage', subBuilder: SendMessageRequest.create)
    ..aOM<InteractBotRequest>(3, _omitFieldNames ? '' : 'interactBot', subBuilder: InteractBotRequest.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ChatStreamBatchCommand clone() => ChatStreamBatchCommand()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ChatStreamBatchCommand copyWith(void Function(ChatStreamBatchCommand) updates) => super.copyWith((message) => updates(message as ChatStreamBatchCommand)) as ChatStreamBatchCommand;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ChatStreamBatchCommand create() => ChatStreamBatchCommand._();
  ChatStreamBatchCommand createEmptyInstance() => create();
  static $pb.PbList<ChatStreamBatchCommand> createRepeated() => $pb.PbList<ChatStreamBatchCommand>();
  @$core.pragma('dart2js:noInline')
  static ChatStreamBatchCommand getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ChatStreamBatchCommand>(create);
  static ChatStreamBatchCommand? _defaultInstance;

  ChatStreamBatchCommand_Command whichCommand() => _ChatStreamBatchCommand_CommandByTag[$_whichOneof(0)]!;
  void clearCommand() => clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  $core.String get commandId => $_getSZ(0);
  @$pb.TagNumber(1)
  set commandId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasCommandId() => $_has(0);
  @$pb.TagNumber(1)
  void clearCommandId() => clearField(1);

  @$pb.TagNumber(2)
  SendMessageRequest get sendMessage => $_getN(1);
  @$pb.TagNumber(2)
  set sendMessage(SendMessageRequest v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasSendMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearSendMessage() => clearField(2);
  @$pb.TagNumber(2)
  SendMessageRequest ensureSendMessage() => $_ensure(1);

  @$pb.TagNumber(3)
  InteractBotRequest get interactBot => $_getN(2);
  @$pb.TagNumber(3)
  set interactBot(InteractBotRequest v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasInteractBot() => $_has(2);
  @$pb.TagNumber(3)
  void clearInteractBot() => clearField(3);
  @$pb.TagNumber(3)
  InteractBotRequest ensureInteractBot() => $_ensure(2);
}

class ChatStreamBatchRequest extends $pb.GeneratedMessage {
  factory ChatStreamBatchRequest({
    $core.Iterable<ChatStreamBatchCommand>? commands,
  }) {
    final $result = create();
    if (commands != null) {
      $result.commands.addAll(commands);
    }
    return $result;
  }
  ChatStreamBatchRequest._() : super();
  factory ChatStreamBatchRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ChatStreamBatchRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ChatStreamBatchRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'tureon.v1'), createEmptyInstance: create)
    ..pc<ChatStreamBatchCommand>(1, _omitFieldNames ? '' : 'commands', $pb.PbFieldType.PM, subBuilder: ChatStreamBatchCommand.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ChatStreamBatchRequest clone() => ChatStreamBatchRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ChatStreamBatchRequest copyWith(void Function(ChatStreamBatchRequest) updates) => super.copyWith((message) => updates(message as ChatStreamBatchRequest)) as ChatStreamBatchRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ChatStreamBatchRequest create() => ChatStreamBatchRequest._();
  ChatStreamBatchRequest createEmptyInstance() => create();
  static $pb.PbList<ChatStreamBatchRequest> createRepeated() => $pb.PbList<ChatStreamBatchRequest>();
  @$core.pragma('dart2js:noInline')
  static ChatStreamBatchRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ChatStreamBatchRequest>(create);
  static ChatStreamBatchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<ChatStreamBatchCommand> get commands => $_getList(0);
}

enum ChatStreamBatchResult_Result {
  sendMessage, 
  botInteraction, 
  notSet
}

class ChatStreamBatchResult extends $pb.GeneratedMessage {
  factory ChatStreamBatchResult({
    $core.String? commandId,
    SendMessageResponse? sendMessage,
    InteractBotResponse? botInteraction,
    $core.int? statusCode,
    $core.String? message,
  }) {
    final $result = create();
    if (commandId != null) {
      $result.commandId = commandId;
    }
    if (sendMessage != null) {
      $result.sendMessage = sendMessage;
    }
    if (botInteraction != null) {
      $result.botInteraction = botInteraction;
    }
    if (statusCode != null) {
      $result.statusCode = statusCode;
    }
    if (message != null) {
      $result.message = message;
    }
    return $result;
  }
  ChatStreamBatchResult._() : super();
  factory ChatStreamBatchResult.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ChatStreamBatchResult.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static const $core.Map<$core.int, ChatStreamBatchResult_Result> _ChatStreamBatchResult_ResultByTag = {
    2 : ChatStreamBatchResult_Result.sendMessage,
    3 : ChatStreamBatchResult_Result.botInteraction,
    0 : ChatStreamBatchResult_Result.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ChatStreamBatchResult', package: const $pb.PackageName(_omitMessageNames ? '' : 'tureon.v1'), createEmptyInstance: create)
    ..oo(0, [2, 3])
    ..aOS(1, _omitFieldNames ? '' : 'commandId')
    ..aOM<SendMessageResponse>(2, _omitFieldNames ? '' : 'sendMessage', subBuilder: SendMessageResponse.create)
    ..aOM<InteractBotResponse>(3, _omitFieldNames ? '' : 'botInteraction', subBuilder: InteractBotResponse.create)
    ..a<$core.int>(4, _omitFieldNames ? '' : 'statusCode', $pb.PbFieldType.O3)
    ..aOS(5, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ChatStreamBatchResult clone() => ChatStreamBatchResult()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ChatStreamBatchResult copyWith(void Function(ChatStreamBatchResult) updates) => super.copyWith((message) => updates(message as ChatStreamBatchResult)) as ChatStreamBatchResult;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ChatStreamBatchResult create() => ChatStreamBatchResult._();
  ChatStreamBatchResult createEmptyInstance() => create();
  static $pb.PbList<ChatStreamBatchResult> createRepeated() => $pb.PbList<ChatStreamBatchResult>();
  @$core.pragma('dart2js:noInline')
  static ChatStreamBatchResult getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ChatStreamBatchResult>(create);
  static ChatStreamBatchResult? _defaultInstance;

  ChatStreamBatchResult_Result whichResult() => _ChatStreamBatchResult_ResultByTag[$_whichOneof(0)]!;
  void clearResult() => clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  $core.String get commandId => $_getSZ(0);
  @$pb.TagNumber(1)
  set commandId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasCommandId() => $_has(0);
  @$pb.TagNumber(1)
  void clearCommandId() => clearField(1);

  @$pb.TagNumber(2)
  SendMessageResponse get sendMessage => $_getN(1);
  @$pb.TagNumber(2)
  set sendMessage(SendMessageResponse v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasSendMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearSendMessage() => clearField(2);
  @$pb.TagNumber(2)
  SendMessageResponse ensureSendMessage() => $_ensure(1);

  @$pb.TagNumber(3)
  InteractBotResponse get botInteraction => $_getN(2);
  @$pb.TagNumber(3)
  set botInteraction(InteractBotResponse v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasBotInteraction() => $_has(2);
  @$pb.TagNumber(3)
  void clearBotInteraction() => clearField(3);
  @$pb.TagNumber(3)
  InteractBotResponse ensureBotInteraction() => $_ensure(2);

  @$pb.TagNumber(4)
  $core.int get statusCode => $_getIZ(3);
  @$pb.TagNumber(4)
  set statusCode($core.int v) { $_setSignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasStatusCode() => $_has(3);
  @$pb.TagNumber(4)
  void clearStatusCode() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get message => $_getSZ(4);
  @$pb.TagNumber(5)
  set message($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasMessage() => $_has(4);
  @$pb.TagNumber(5)
  void clearMessage() => clearField(5);
}

class ChatStreamBatchResponse extends $pb.GeneratedMessage {
  factory ChatStreamBatchResponse({
    $core.Iterable<ChatStreamBatchResult>? results,
  }) {
    final $result = create();
    if (results != null) {
      $result.results.addAll(results);
    }
    return $result;
  }
  ChatStreamBatchResponse._() : super();
  factory ChatStreamBatchResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ChatStreamBatchResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ChatStreamBatchResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'tureon.v1'), createEmptyInstance: create)
    ..pc<ChatStreamBatchResult>(1, _omitFieldNames ? '' : 'results', $pb.PbFieldType.PM, subBuilder: ChatStreamBatchResult.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ChatStreamBatchResponse clone() => ChatStreamBatchResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ChatStreamBatchResponse copyWith(void Function(ChatStreamBatchResponse) updates) => super.copyWith((message) => updates(message as ChatStreamBatchResponse)) as ChatStreamBatchResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ChatStreamBatchResponse create() => ChatStreamBatchResponse._();
  ChatStreamBatchResponse createEmptyInstance() => create();
  static $pb.PbList<ChatStreamBatchResponse> createRepeated() => $pb.PbList<ChatStreamBatchResponse>();
  @$core.pragma('dart2js:noInline')
  static ChatStreamBatchResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ChatStreamBatchResponse>(create);
  static ChatStreamBatchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<ChatStreamBatchResult> get results => $_getList(0);
}

enum ChatStreamRequest_Command {
  open, 
  sendMessage, 
  acknowledge, 
  readReceipt, 
  mutateMessage, 
  interactBot, 
  batch, 
  notSet
}

class ChatStreamRequest extends $pb.GeneratedMessage {
  factory ChatStreamRequest({
    $core.String? requestId,
    ChatStreamOpen? open,
    SendMessageRequest? sendMessage,
    AckDeliveryRequest? acknowledge,
    SendReadReceiptRequest? readReceipt,
    SendMessageMutationRequest? mutateMessage,
    InteractBotRequest? interactBot,
    ChatStreamBatchRequest? batch,
  }) {
    final $result = create();
    if (requestId != null) {
      $result.requestId = requestId;
    }
    if (open != null) {
      $result.open = open;
    }
    if (sendMessage != null) {
      $result.sendMessage = sendMessage;
    }
    if (acknowledge != null) {
      $result.acknowledge = acknowledge;
    }
    if (readReceipt != null) {
      $result.readReceipt = readReceipt;
    }
    if (mutateMessage != null) {
      $result.mutateMessage = mutateMessage;
    }
    if (interactBot != null) {
      $result.interactBot = interactBot;
    }
    if (batch != null) {
      $result.batch = batch;
    }
    return $result;
  }
  ChatStreamRequest._() : super();
  factory ChatStreamRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ChatStreamRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static const $core.Map<$core.int, ChatStreamRequest_Command> _ChatStreamRequest_CommandByTag = {
    2 : ChatStreamRequest_Command.open,
    3 : ChatStreamRequest_Command.sendMessage,
    4 : ChatStreamRequest_Command.acknowledge,
    5 : ChatStreamRequest_Command.readReceipt,
    6 : ChatStreamRequest_Command.mutateMessage,
    7 : ChatStreamRequest_Command.interactBot,
    8 : ChatStreamRequest_Command.batch,
    0 : ChatStreamRequest_Command.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ChatStreamRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'tureon.v1'), createEmptyInstance: create)
    ..oo(0, [2, 3, 4, 5, 6, 7, 8])
    ..aOS(1, _omitFieldNames ? '' : 'requestId')
    ..aOM<ChatStreamOpen>(2, _omitFieldNames ? '' : 'open', subBuilder: ChatStreamOpen.create)
    ..aOM<SendMessageRequest>(3, _omitFieldNames ? '' : 'sendMessage', subBuilder: SendMessageRequest.create)
    ..aOM<AckDeliveryRequest>(4, _omitFieldNames ? '' : 'acknowledge', subBuilder: AckDeliveryRequest.create)
    ..aOM<SendReadReceiptRequest>(5, _omitFieldNames ? '' : 'readReceipt', subBuilder: SendReadReceiptRequest.create)
    ..aOM<SendMessageMutationRequest>(6, _omitFieldNames ? '' : 'mutateMessage', subBuilder: SendMessageMutationRequest.create)
    ..aOM<InteractBotRequest>(7, _omitFieldNames ? '' : 'interactBot', subBuilder: InteractBotRequest.create)
    ..aOM<ChatStreamBatchRequest>(8, _omitFieldNames ? '' : 'batch', subBuilder: ChatStreamBatchRequest.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ChatStreamRequest clone() => ChatStreamRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ChatStreamRequest copyWith(void Function(ChatStreamRequest) updates) => super.copyWith((message) => updates(message as ChatStreamRequest)) as ChatStreamRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ChatStreamRequest create() => ChatStreamRequest._();
  ChatStreamRequest createEmptyInstance() => create();
  static $pb.PbList<ChatStreamRequest> createRepeated() => $pb.PbList<ChatStreamRequest>();
  @$core.pragma('dart2js:noInline')
  static ChatStreamRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ChatStreamRequest>(create);
  static ChatStreamRequest? _defaultInstance;

  ChatStreamRequest_Command whichCommand() => _ChatStreamRequest_CommandByTag[$_whichOneof(0)]!;
  void clearCommand() => clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  $core.String get requestId => $_getSZ(0);
  @$pb.TagNumber(1)
  set requestId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestId() => clearField(1);

  @$pb.TagNumber(2)
  ChatStreamOpen get open => $_getN(1);
  @$pb.TagNumber(2)
  set open(ChatStreamOpen v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasOpen() => $_has(1);
  @$pb.TagNumber(2)
  void clearOpen() => clearField(2);
  @$pb.TagNumber(2)
  ChatStreamOpen ensureOpen() => $_ensure(1);

  @$pb.TagNumber(3)
  SendMessageRequest get sendMessage => $_getN(2);
  @$pb.TagNumber(3)
  set sendMessage(SendMessageRequest v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasSendMessage() => $_has(2);
  @$pb.TagNumber(3)
  void clearSendMessage() => clearField(3);
  @$pb.TagNumber(3)
  SendMessageRequest ensureSendMessage() => $_ensure(2);

  @$pb.TagNumber(4)
  AckDeliveryRequest get acknowledge => $_getN(3);
  @$pb.TagNumber(4)
  set acknowledge(AckDeliveryRequest v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasAcknowledge() => $_has(3);
  @$pb.TagNumber(4)
  void clearAcknowledge() => clearField(4);
  @$pb.TagNumber(4)
  AckDeliveryRequest ensureAcknowledge() => $_ensure(3);

  @$pb.TagNumber(5)
  SendReadReceiptRequest get readReceipt => $_getN(4);
  @$pb.TagNumber(5)
  set readReceipt(SendReadReceiptRequest v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasReadReceipt() => $_has(4);
  @$pb.TagNumber(5)
  void clearReadReceipt() => clearField(5);
  @$pb.TagNumber(5)
  SendReadReceiptRequest ensureReadReceipt() => $_ensure(4);

  @$pb.TagNumber(6)
  SendMessageMutationRequest get mutateMessage => $_getN(5);
  @$pb.TagNumber(6)
  set mutateMessage(SendMessageMutationRequest v) { setField(6, v); }
  @$pb.TagNumber(6)
  $core.bool hasMutateMessage() => $_has(5);
  @$pb.TagNumber(6)
  void clearMutateMessage() => clearField(6);
  @$pb.TagNumber(6)
  SendMessageMutationRequest ensureMutateMessage() => $_ensure(5);

  @$pb.TagNumber(7)
  InteractBotRequest get interactBot => $_getN(6);
  @$pb.TagNumber(7)
  set interactBot(InteractBotRequest v) { setField(7, v); }
  @$pb.TagNumber(7)
  $core.bool hasInteractBot() => $_has(6);
  @$pb.TagNumber(7)
  void clearInteractBot() => clearField(7);
  @$pb.TagNumber(7)
  InteractBotRequest ensureInteractBot() => $_ensure(6);

  @$pb.TagNumber(8)
  ChatStreamBatchRequest get batch => $_getN(7);
  @$pb.TagNumber(8)
  set batch(ChatStreamBatchRequest v) { setField(8, v); }
  @$pb.TagNumber(8)
  $core.bool hasBatch() => $_has(7);
  @$pb.TagNumber(8)
  void clearBatch() => clearField(8);
  @$pb.TagNumber(8)
  ChatStreamBatchRequest ensureBatch() => $_ensure(7);
}

class ChatStreamReady extends $pb.GeneratedMessage {
  factory ChatStreamReady({
    $core.String? recipientId,
    $core.String? deviceId,
  }) {
    final $result = create();
    if (recipientId != null) {
      $result.recipientId = recipientId;
    }
    if (deviceId != null) {
      $result.deviceId = deviceId;
    }
    return $result;
  }
  ChatStreamReady._() : super();
  factory ChatStreamReady.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ChatStreamReady.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ChatStreamReady', package: const $pb.PackageName(_omitMessageNames ? '' : 'tureon.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'recipientId')
    ..aOS(2, _omitFieldNames ? '' : 'deviceId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ChatStreamReady clone() => ChatStreamReady()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ChatStreamReady copyWith(void Function(ChatStreamReady) updates) => super.copyWith((message) => updates(message as ChatStreamReady)) as ChatStreamReady;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ChatStreamReady create() => ChatStreamReady._();
  ChatStreamReady createEmptyInstance() => create();
  static $pb.PbList<ChatStreamReady> createRepeated() => $pb.PbList<ChatStreamReady>();
  @$core.pragma('dart2js:noInline')
  static ChatStreamReady getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ChatStreamReady>(create);
  static ChatStreamReady? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get recipientId => $_getSZ(0);
  @$pb.TagNumber(1)
  set recipientId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasRecipientId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRecipientId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get deviceId => $_getSZ(1);
  @$pb.TagNumber(2)
  set deviceId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasDeviceId() => $_has(1);
  @$pb.TagNumber(2)
  void clearDeviceId() => clearField(2);
}

class ChatStreamCommandResult extends $pb.GeneratedMessage {
  factory ChatStreamCommandResult({
    $core.bool? accepted,
    $core.int? statusCode,
    $core.String? message,
  }) {
    final $result = create();
    if (accepted != null) {
      $result.accepted = accepted;
    }
    if (statusCode != null) {
      $result.statusCode = statusCode;
    }
    if (message != null) {
      $result.message = message;
    }
    return $result;
  }
  ChatStreamCommandResult._() : super();
  factory ChatStreamCommandResult.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ChatStreamCommandResult.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ChatStreamCommandResult', package: const $pb.PackageName(_omitMessageNames ? '' : 'tureon.v1'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'accepted')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'statusCode', $pb.PbFieldType.O3)
    ..aOS(3, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ChatStreamCommandResult clone() => ChatStreamCommandResult()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ChatStreamCommandResult copyWith(void Function(ChatStreamCommandResult) updates) => super.copyWith((message) => updates(message as ChatStreamCommandResult)) as ChatStreamCommandResult;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ChatStreamCommandResult create() => ChatStreamCommandResult._();
  ChatStreamCommandResult createEmptyInstance() => create();
  static $pb.PbList<ChatStreamCommandResult> createRepeated() => $pb.PbList<ChatStreamCommandResult>();
  @$core.pragma('dart2js:noInline')
  static ChatStreamCommandResult getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ChatStreamCommandResult>(create);
  static ChatStreamCommandResult? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get accepted => $_getBF(0);
  @$pb.TagNumber(1)
  set accepted($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAccepted() => $_has(0);
  @$pb.TagNumber(1)
  void clearAccepted() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get statusCode => $_getIZ(1);
  @$pb.TagNumber(2)
  set statusCode($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasStatusCode() => $_has(1);
  @$pb.TagNumber(2)
  void clearStatusCode() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get message => $_getSZ(2);
  @$pb.TagNumber(3)
  set message($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasMessage() => $_has(2);
  @$pb.TagNumber(3)
  void clearMessage() => clearField(3);
}

enum ChatStreamResponse_Event {
  ready, 
  delivery, 
  sendMessage, 
  commandResult, 
  botInteraction, 
  batch, 
  notSet
}

class ChatStreamResponse extends $pb.GeneratedMessage {
  factory ChatStreamResponse({
    $core.String? requestId,
    ChatStreamReady? ready,
    MessageDelivery? delivery,
    SendMessageResponse? sendMessage,
    ChatStreamCommandResult? commandResult,
    InteractBotResponse? botInteraction,
    ChatStreamBatchResponse? batch,
  }) {
    final $result = create();
    if (requestId != null) {
      $result.requestId = requestId;
    }
    if (ready != null) {
      $result.ready = ready;
    }
    if (delivery != null) {
      $result.delivery = delivery;
    }
    if (sendMessage != null) {
      $result.sendMessage = sendMessage;
    }
    if (commandResult != null) {
      $result.commandResult = commandResult;
    }
    if (botInteraction != null) {
      $result.botInteraction = botInteraction;
    }
    if (batch != null) {
      $result.batch = batch;
    }
    return $result;
  }
  ChatStreamResponse._() : super();
  factory ChatStreamResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ChatStreamResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static const $core.Map<$core.int, ChatStreamResponse_Event> _ChatStreamResponse_EventByTag = {
    2 : ChatStreamResponse_Event.ready,
    3 : ChatStreamResponse_Event.delivery,
    4 : ChatStreamResponse_Event.sendMessage,
    5 : ChatStreamResponse_Event.commandResult,
    6 : ChatStreamResponse_Event.botInteraction,
    7 : ChatStreamResponse_Event.batch,
    0 : ChatStreamResponse_Event.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ChatStreamResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'tureon.v1'), createEmptyInstance: create)
    ..oo(0, [2, 3, 4, 5, 6, 7])
    ..aOS(1, _omitFieldNames ? '' : 'requestId')
    ..aOM<ChatStreamReady>(2, _omitFieldNames ? '' : 'ready', subBuilder: ChatStreamReady.create)
    ..aOM<MessageDelivery>(3, _omitFieldNames ? '' : 'delivery', subBuilder: MessageDelivery.create)
    ..aOM<SendMessageResponse>(4, _omitFieldNames ? '' : 'sendMessage', subBuilder: SendMessageResponse.create)
    ..aOM<ChatStreamCommandResult>(5, _omitFieldNames ? '' : 'commandResult', subBuilder: ChatStreamCommandResult.create)
    ..aOM<InteractBotResponse>(6, _omitFieldNames ? '' : 'botInteraction', subBuilder: InteractBotResponse.create)
    ..aOM<ChatStreamBatchResponse>(7, _omitFieldNames ? '' : 'batch', subBuilder: ChatStreamBatchResponse.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ChatStreamResponse clone() => ChatStreamResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ChatStreamResponse copyWith(void Function(ChatStreamResponse) updates) => super.copyWith((message) => updates(message as ChatStreamResponse)) as ChatStreamResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ChatStreamResponse create() => ChatStreamResponse._();
  ChatStreamResponse createEmptyInstance() => create();
  static $pb.PbList<ChatStreamResponse> createRepeated() => $pb.PbList<ChatStreamResponse>();
  @$core.pragma('dart2js:noInline')
  static ChatStreamResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ChatStreamResponse>(create);
  static ChatStreamResponse? _defaultInstance;

  ChatStreamResponse_Event whichEvent() => _ChatStreamResponse_EventByTag[$_whichOneof(0)]!;
  void clearEvent() => clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  $core.String get requestId => $_getSZ(0);
  @$pb.TagNumber(1)
  set requestId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestId() => clearField(1);

  @$pb.TagNumber(2)
  ChatStreamReady get ready => $_getN(1);
  @$pb.TagNumber(2)
  set ready(ChatStreamReady v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasReady() => $_has(1);
  @$pb.TagNumber(2)
  void clearReady() => clearField(2);
  @$pb.TagNumber(2)
  ChatStreamReady ensureReady() => $_ensure(1);

  @$pb.TagNumber(3)
  MessageDelivery get delivery => $_getN(2);
  @$pb.TagNumber(3)
  set delivery(MessageDelivery v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasDelivery() => $_has(2);
  @$pb.TagNumber(3)
  void clearDelivery() => clearField(3);
  @$pb.TagNumber(3)
  MessageDelivery ensureDelivery() => $_ensure(2);

  @$pb.TagNumber(4)
  SendMessageResponse get sendMessage => $_getN(3);
  @$pb.TagNumber(4)
  set sendMessage(SendMessageResponse v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasSendMessage() => $_has(3);
  @$pb.TagNumber(4)
  void clearSendMessage() => clearField(4);
  @$pb.TagNumber(4)
  SendMessageResponse ensureSendMessage() => $_ensure(3);

  @$pb.TagNumber(5)
  ChatStreamCommandResult get commandResult => $_getN(4);
  @$pb.TagNumber(5)
  set commandResult(ChatStreamCommandResult v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasCommandResult() => $_has(4);
  @$pb.TagNumber(5)
  void clearCommandResult() => clearField(5);
  @$pb.TagNumber(5)
  ChatStreamCommandResult ensureCommandResult() => $_ensure(4);

  @$pb.TagNumber(6)
  InteractBotResponse get botInteraction => $_getN(5);
  @$pb.TagNumber(6)
  set botInteraction(InteractBotResponse v) { setField(6, v); }
  @$pb.TagNumber(6)
  $core.bool hasBotInteraction() => $_has(5);
  @$pb.TagNumber(6)
  void clearBotInteraction() => clearField(6);
  @$pb.TagNumber(6)
  InteractBotResponse ensureBotInteraction() => $_ensure(5);

  @$pb.TagNumber(7)
  ChatStreamBatchResponse get batch => $_getN(6);
  @$pb.TagNumber(7)
  set batch(ChatStreamBatchResponse v) { setField(7, v); }
  @$pb.TagNumber(7)
  $core.bool hasBatch() => $_has(6);
  @$pb.TagNumber(7)
  void clearBatch() => clearField(7);
  @$pb.TagNumber(7)
  ChatStreamBatchResponse ensureBatch() => $_ensure(6);
}

class TypingIndicator extends $pb.GeneratedMessage {
  factory TypingIndicator({
    $core.String? senderRecipientId,
    $core.String? targetRecipientId,
    $core.bool? isTyping,
  }) {
    final $result = create();
    if (senderRecipientId != null) {
      $result.senderRecipientId = senderRecipientId;
    }
    if (targetRecipientId != null) {
      $result.targetRecipientId = targetRecipientId;
    }
    if (isTyping != null) {
      $result.isTyping = isTyping;
    }
    return $result;
  }
  TypingIndicator._() : super();
  factory TypingIndicator.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TypingIndicator.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TypingIndicator', package: const $pb.PackageName(_omitMessageNames ? '' : 'tureon.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'senderRecipientId')
    ..aOS(2, _omitFieldNames ? '' : 'targetRecipientId')
    ..aOB(3, _omitFieldNames ? '' : 'isTyping')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TypingIndicator clone() => TypingIndicator()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TypingIndicator copyWith(void Function(TypingIndicator) updates) => super.copyWith((message) => updates(message as TypingIndicator)) as TypingIndicator;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TypingIndicator create() => TypingIndicator._();
  TypingIndicator createEmptyInstance() => create();
  static $pb.PbList<TypingIndicator> createRepeated() => $pb.PbList<TypingIndicator>();
  @$core.pragma('dart2js:noInline')
  static TypingIndicator getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TypingIndicator>(create);
  static TypingIndicator? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get senderRecipientId => $_getSZ(0);
  @$pb.TagNumber(1)
  set senderRecipientId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSenderRecipientId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSenderRecipientId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get targetRecipientId => $_getSZ(1);
  @$pb.TagNumber(2)
  set targetRecipientId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasTargetRecipientId() => $_has(1);
  @$pb.TagNumber(2)
  void clearTargetRecipientId() => clearField(2);

  @$pb.TagNumber(3)
  $core.bool get isTyping => $_getBF(2);
  @$pb.TagNumber(3)
  set isTyping($core.bool v) { $_setBool(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasIsTyping() => $_has(2);
  @$pb.TagNumber(3)
  void clearIsTyping() => clearField(3);
}

class PresenceUpdate extends $pb.GeneratedMessage {
  factory PresenceUpdate({
    $core.String? recipientId,
    $core.bool? online,
    $fixnum.Int64? lastSeen,
    $core.bool? presenceVisible,
  }) {
    final $result = create();
    if (recipientId != null) {
      $result.recipientId = recipientId;
    }
    if (online != null) {
      $result.online = online;
    }
    if (lastSeen != null) {
      $result.lastSeen = lastSeen;
    }
    if (presenceVisible != null) {
      $result.presenceVisible = presenceVisible;
    }
    return $result;
  }
  PresenceUpdate._() : super();
  factory PresenceUpdate.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PresenceUpdate.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PresenceUpdate', package: const $pb.PackageName(_omitMessageNames ? '' : 'tureon.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'recipientId')
    ..aOB(2, _omitFieldNames ? '' : 'online')
    ..aInt64(3, _omitFieldNames ? '' : 'lastSeen')
    ..aOB(4, _omitFieldNames ? '' : 'presenceVisible')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PresenceUpdate clone() => PresenceUpdate()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PresenceUpdate copyWith(void Function(PresenceUpdate) updates) => super.copyWith((message) => updates(message as PresenceUpdate)) as PresenceUpdate;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PresenceUpdate create() => PresenceUpdate._();
  PresenceUpdate createEmptyInstance() => create();
  static $pb.PbList<PresenceUpdate> createRepeated() => $pb.PbList<PresenceUpdate>();
  @$core.pragma('dart2js:noInline')
  static PresenceUpdate getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PresenceUpdate>(create);
  static PresenceUpdate? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get recipientId => $_getSZ(0);
  @$pb.TagNumber(1)
  set recipientId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasRecipientId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRecipientId() => clearField(1);

  @$pb.TagNumber(2)
  $core.bool get online => $_getBF(1);
  @$pb.TagNumber(2)
  set online($core.bool v) { $_setBool(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasOnline() => $_has(1);
  @$pb.TagNumber(2)
  void clearOnline() => clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get lastSeen => $_getI64(2);
  @$pb.TagNumber(3)
  set lastSeen($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasLastSeen() => $_has(2);
  @$pb.TagNumber(3)
  void clearLastSeen() => clearField(3);

  /// Explicit privacy decision, independent of whether last_seen exists.
  /// Clients retain timestamp-based compatibility with older servers.
  @$pb.TagNumber(4)
  $core.bool get presenceVisible => $_getBF(3);
  @$pb.TagNumber(4)
  set presenceVisible($core.bool v) { $_setBool(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasPresenceVisible() => $_has(3);
  @$pb.TagNumber(4)
  void clearPresenceVisible() => clearField(4);
}

class PresenceHeartbeat extends $pb.GeneratedMessage {
  factory PresenceHeartbeat({
    $core.bool? online,
  }) {
    final $result = create();
    if (online != null) {
      $result.online = online;
    }
    return $result;
  }
  PresenceHeartbeat._() : super();
  factory PresenceHeartbeat.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PresenceHeartbeat.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PresenceHeartbeat', package: const $pb.PackageName(_omitMessageNames ? '' : 'tureon.v1'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'online')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PresenceHeartbeat clone() => PresenceHeartbeat()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PresenceHeartbeat copyWith(void Function(PresenceHeartbeat) updates) => super.copyWith((message) => updates(message as PresenceHeartbeat)) as PresenceHeartbeat;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PresenceHeartbeat create() => PresenceHeartbeat._();
  PresenceHeartbeat createEmptyInstance() => create();
  static $pb.PbList<PresenceHeartbeat> createRepeated() => $pb.PbList<PresenceHeartbeat>();
  @$core.pragma('dart2js:noInline')
  static PresenceHeartbeat getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PresenceHeartbeat>(create);
  static PresenceHeartbeat? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get online => $_getBF(0);
  @$pb.TagNumber(1)
  set online($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasOnline() => $_has(0);
  @$pb.TagNumber(1)
  void clearOnline() => clearField(1);
}

class PresenceWatch extends $pb.GeneratedMessage {
  factory PresenceWatch({
    $core.Iterable<$core.String>? recipientIds,
  }) {
    final $result = create();
    if (recipientIds != null) {
      $result.recipientIds.addAll(recipientIds);
    }
    return $result;
  }
  PresenceWatch._() : super();
  factory PresenceWatch.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PresenceWatch.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PresenceWatch', package: const $pb.PackageName(_omitMessageNames ? '' : 'tureon.v1'), createEmptyInstance: create)
    ..pPS(1, _omitFieldNames ? '' : 'recipientIds')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PresenceWatch clone() => PresenceWatch()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PresenceWatch copyWith(void Function(PresenceWatch) updates) => super.copyWith((message) => updates(message as PresenceWatch)) as PresenceWatch;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PresenceWatch create() => PresenceWatch._();
  PresenceWatch createEmptyInstance() => create();
  static $pb.PbList<PresenceWatch> createRepeated() => $pb.PbList<PresenceWatch>();
  @$core.pragma('dart2js:noInline')
  static PresenceWatch getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PresenceWatch>(create);
  static PresenceWatch? _defaultInstance;

  /// Current local user conversations; the server applies each user's privacy.
  @$pb.TagNumber(1)
  $core.List<$core.String> get recipientIds => $_getList(0);
}

enum PresenceClientEvent_Event {
  heartbeat, 
  typing, 
  watch, 
  notSet
}

class PresenceClientEvent extends $pb.GeneratedMessage {
  factory PresenceClientEvent({
    PresenceHeartbeat? heartbeat,
    TypingIndicator? typing,
    PresenceWatch? watch,
  }) {
    final $result = create();
    if (heartbeat != null) {
      $result.heartbeat = heartbeat;
    }
    if (typing != null) {
      $result.typing = typing;
    }
    if (watch != null) {
      $result.watch = watch;
    }
    return $result;
  }
  PresenceClientEvent._() : super();
  factory PresenceClientEvent.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PresenceClientEvent.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static const $core.Map<$core.int, PresenceClientEvent_Event> _PresenceClientEvent_EventByTag = {
    1 : PresenceClientEvent_Event.heartbeat,
    2 : PresenceClientEvent_Event.typing,
    3 : PresenceClientEvent_Event.watch,
    0 : PresenceClientEvent_Event.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PresenceClientEvent', package: const $pb.PackageName(_omitMessageNames ? '' : 'tureon.v1'), createEmptyInstance: create)
    ..oo(0, [1, 2, 3])
    ..aOM<PresenceHeartbeat>(1, _omitFieldNames ? '' : 'heartbeat', subBuilder: PresenceHeartbeat.create)
    ..aOM<TypingIndicator>(2, _omitFieldNames ? '' : 'typing', subBuilder: TypingIndicator.create)
    ..aOM<PresenceWatch>(3, _omitFieldNames ? '' : 'watch', subBuilder: PresenceWatch.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PresenceClientEvent clone() => PresenceClientEvent()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PresenceClientEvent copyWith(void Function(PresenceClientEvent) updates) => super.copyWith((message) => updates(message as PresenceClientEvent)) as PresenceClientEvent;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PresenceClientEvent create() => PresenceClientEvent._();
  PresenceClientEvent createEmptyInstance() => create();
  static $pb.PbList<PresenceClientEvent> createRepeated() => $pb.PbList<PresenceClientEvent>();
  @$core.pragma('dart2js:noInline')
  static PresenceClientEvent getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PresenceClientEvent>(create);
  static PresenceClientEvent? _defaultInstance;

  PresenceClientEvent_Event whichEvent() => _PresenceClientEvent_EventByTag[$_whichOneof(0)]!;
  void clearEvent() => clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  PresenceHeartbeat get heartbeat => $_getN(0);
  @$pb.TagNumber(1)
  set heartbeat(PresenceHeartbeat v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasHeartbeat() => $_has(0);
  @$pb.TagNumber(1)
  void clearHeartbeat() => clearField(1);
  @$pb.TagNumber(1)
  PresenceHeartbeat ensureHeartbeat() => $_ensure(0);

  @$pb.TagNumber(2)
  TypingIndicator get typing => $_getN(1);
  @$pb.TagNumber(2)
  set typing(TypingIndicator v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasTyping() => $_has(1);
  @$pb.TagNumber(2)
  void clearTyping() => clearField(2);
  @$pb.TagNumber(2)
  TypingIndicator ensureTyping() => $_ensure(1);

  @$pb.TagNumber(3)
  PresenceWatch get watch => $_getN(2);
  @$pb.TagNumber(3)
  set watch(PresenceWatch v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasWatch() => $_has(2);
  @$pb.TagNumber(3)
  void clearWatch() => clearField(3);
  @$pb.TagNumber(3)
  PresenceWatch ensureWatch() => $_ensure(2);
}

enum PresenceServerEvent_Event {
  presence, 
  typing, 
  notSet
}

class PresenceServerEvent extends $pb.GeneratedMessage {
  factory PresenceServerEvent({
    PresenceUpdate? presence,
    TypingIndicator? typing,
  }) {
    final $result = create();
    if (presence != null) {
      $result.presence = presence;
    }
    if (typing != null) {
      $result.typing = typing;
    }
    return $result;
  }
  PresenceServerEvent._() : super();
  factory PresenceServerEvent.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PresenceServerEvent.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static const $core.Map<$core.int, PresenceServerEvent_Event> _PresenceServerEvent_EventByTag = {
    1 : PresenceServerEvent_Event.presence,
    2 : PresenceServerEvent_Event.typing,
    0 : PresenceServerEvent_Event.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PresenceServerEvent', package: const $pb.PackageName(_omitMessageNames ? '' : 'tureon.v1'), createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<PresenceUpdate>(1, _omitFieldNames ? '' : 'presence', subBuilder: PresenceUpdate.create)
    ..aOM<TypingIndicator>(2, _omitFieldNames ? '' : 'typing', subBuilder: TypingIndicator.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PresenceServerEvent clone() => PresenceServerEvent()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PresenceServerEvent copyWith(void Function(PresenceServerEvent) updates) => super.copyWith((message) => updates(message as PresenceServerEvent)) as PresenceServerEvent;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PresenceServerEvent create() => PresenceServerEvent._();
  PresenceServerEvent createEmptyInstance() => create();
  static $pb.PbList<PresenceServerEvent> createRepeated() => $pb.PbList<PresenceServerEvent>();
  @$core.pragma('dart2js:noInline')
  static PresenceServerEvent getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PresenceServerEvent>(create);
  static PresenceServerEvent? _defaultInstance;

  PresenceServerEvent_Event whichEvent() => _PresenceServerEvent_EventByTag[$_whichOneof(0)]!;
  void clearEvent() => clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  PresenceUpdate get presence => $_getN(0);
  @$pb.TagNumber(1)
  set presence(PresenceUpdate v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasPresence() => $_has(0);
  @$pb.TagNumber(1)
  void clearPresence() => clearField(1);
  @$pb.TagNumber(1)
  PresenceUpdate ensurePresence() => $_ensure(0);

  @$pb.TagNumber(2)
  TypingIndicator get typing => $_getN(1);
  @$pb.TagNumber(2)
  set typing(TypingIndicator v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasTyping() => $_has(1);
  @$pb.TagNumber(2)
  void clearTyping() => clearField(2);
  @$pb.TagNumber(2)
  TypingIndicator ensureTyping() => $_ensure(1);
}

class SystemMessage extends $pb.GeneratedMessage {
  factory SystemMessage({
    SystemEventType? eventType,
    $core.String? actorUserId,
    $core.String? targetUserId,
    $core.String? groupId,
    $core.String? channelId,
    $core.String? reason,
    $core.Map<$core.String, $core.String>? metadata,
    $fixnum.Int64? timestamp,
  }) {
    final $result = create();
    if (eventType != null) {
      $result.eventType = eventType;
    }
    if (actorUserId != null) {
      $result.actorUserId = actorUserId;
    }
    if (targetUserId != null) {
      $result.targetUserId = targetUserId;
    }
    if (groupId != null) {
      $result.groupId = groupId;
    }
    if (channelId != null) {
      $result.channelId = channelId;
    }
    if (reason != null) {
      $result.reason = reason;
    }
    if (metadata != null) {
      $result.metadata.addAll(metadata);
    }
    if (timestamp != null) {
      $result.timestamp = timestamp;
    }
    return $result;
  }
  SystemMessage._() : super();
  factory SystemMessage.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SystemMessage.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SystemMessage', package: const $pb.PackageName(_omitMessageNames ? '' : 'tureon.v1'), createEmptyInstance: create)
    ..e<SystemEventType>(1, _omitFieldNames ? '' : 'eventType', $pb.PbFieldType.OE, defaultOrMaker: SystemEventType.SYSTEM_EVENT_TYPE_UNSPECIFIED, valueOf: SystemEventType.valueOf, enumValues: SystemEventType.values)
    ..aOS(2, _omitFieldNames ? '' : 'actorUserId')
    ..aOS(3, _omitFieldNames ? '' : 'targetUserId')
    ..aOS(4, _omitFieldNames ? '' : 'groupId')
    ..aOS(5, _omitFieldNames ? '' : 'channelId')
    ..aOS(6, _omitFieldNames ? '' : 'reason')
    ..m<$core.String, $core.String>(7, _omitFieldNames ? '' : 'metadata', entryClassName: 'SystemMessage.MetadataEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OS, packageName: const $pb.PackageName('tureon.v1'))
    ..aInt64(8, _omitFieldNames ? '' : 'timestamp')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SystemMessage clone() => SystemMessage()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SystemMessage copyWith(void Function(SystemMessage) updates) => super.copyWith((message) => updates(message as SystemMessage)) as SystemMessage;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SystemMessage create() => SystemMessage._();
  SystemMessage createEmptyInstance() => create();
  static $pb.PbList<SystemMessage> createRepeated() => $pb.PbList<SystemMessage>();
  @$core.pragma('dart2js:noInline')
  static SystemMessage getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SystemMessage>(create);
  static SystemMessage? _defaultInstance;

  @$pb.TagNumber(1)
  SystemEventType get eventType => $_getN(0);
  @$pb.TagNumber(1)
  set eventType(SystemEventType v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasEventType() => $_has(0);
  @$pb.TagNumber(1)
  void clearEventType() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get actorUserId => $_getSZ(1);
  @$pb.TagNumber(2)
  set actorUserId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasActorUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearActorUserId() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get targetUserId => $_getSZ(2);
  @$pb.TagNumber(3)
  set targetUserId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasTargetUserId() => $_has(2);
  @$pb.TagNumber(3)
  void clearTargetUserId() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get groupId => $_getSZ(3);
  @$pb.TagNumber(4)
  set groupId($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasGroupId() => $_has(3);
  @$pb.TagNumber(4)
  void clearGroupId() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get channelId => $_getSZ(4);
  @$pb.TagNumber(5)
  set channelId($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasChannelId() => $_has(4);
  @$pb.TagNumber(5)
  void clearChannelId() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get reason => $_getSZ(5);
  @$pb.TagNumber(6)
  set reason($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasReason() => $_has(5);
  @$pb.TagNumber(6)
  void clearReason() => clearField(6);

  @$pb.TagNumber(7)
  $core.Map<$core.String, $core.String> get metadata => $_getMap(6);

  @$pb.TagNumber(8)
  $fixnum.Int64 get timestamp => $_getI64(7);
  @$pb.TagNumber(8)
  set timestamp($fixnum.Int64 v) { $_setInt64(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasTimestamp() => $_has(7);
  @$pb.TagNumber(8)
  void clearTimestamp() => clearField(8);
}

class Empty extends $pb.GeneratedMessage {
  factory Empty() => create();
  Empty._() : super();
  factory Empty.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Empty.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Empty', package: const $pb.PackageName(_omitMessageNames ? '' : 'tureon.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Empty clone() => Empty()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Empty copyWith(void Function(Empty) updates) => super.copyWith((message) => updates(message as Empty)) as Empty;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Empty create() => Empty._();
  Empty createEmptyInstance() => create();
  static $pb.PbList<Empty> createRepeated() => $pb.PbList<Empty>();
  @$core.pragma('dart2js:noInline')
  static Empty getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Empty>(create);
  static Empty? _defaultInstance;
}

class AuthRequest extends $pb.GeneratedMessage {
  factory AuthRequest({
    $core.String? googleIdToken,
    $core.String? deviceName,
    $core.String? platform,
    $core.String? deviceId,
  }) {
    final $result = create();
    if (googleIdToken != null) {
      $result.googleIdToken = googleIdToken;
    }
    if (deviceName != null) {
      $result.deviceName = deviceName;
    }
    if (platform != null) {
      $result.platform = platform;
    }
    if (deviceId != null) {
      $result.deviceId = deviceId;
    }
    return $result;
  }
  AuthRequest._() : super();
  factory AuthRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AuthRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AuthRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'tureon.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'googleIdToken')
    ..aOS(2, _omitFieldNames ? '' : 'deviceName')
    ..aOS(3, _omitFieldNames ? '' : 'platform')
    ..aOS(4, _omitFieldNames ? '' : 'deviceId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AuthRequest clone() => AuthRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AuthRequest copyWith(void Function(AuthRequest) updates) => super.copyWith((message) => updates(message as AuthRequest)) as AuthRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AuthRequest create() => AuthRequest._();
  AuthRequest createEmptyInstance() => create();
  static $pb.PbList<AuthRequest> createRepeated() => $pb.PbList<AuthRequest>();
  @$core.pragma('dart2js:noInline')
  static AuthRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AuthRequest>(create);
  static AuthRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get googleIdToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set googleIdToken($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasGoogleIdToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearGoogleIdToken() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get deviceName => $_getSZ(1);
  @$pb.TagNumber(2)
  set deviceName($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasDeviceName() => $_has(1);
  @$pb.TagNumber(2)
  void clearDeviceName() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get platform => $_getSZ(2);
  @$pb.TagNumber(3)
  set platform($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasPlatform() => $_has(2);
  @$pb.TagNumber(3)
  void clearPlatform() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get deviceId => $_getSZ(3);
  @$pb.TagNumber(4)
  set deviceId($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasDeviceId() => $_has(3);
  @$pb.TagNumber(4)
  void clearDeviceId() => clearField(4);
}

class TestAccountLoginRequest extends $pb.GeneratedMessage {
  factory TestAccountLoginRequest({
    $core.String? label,
    $core.String? deviceName,
    $core.String? platform,
    $core.String? deviceId,
  }) {
    final $result = create();
    if (label != null) {
      $result.label = label;
    }
    if (deviceName != null) {
      $result.deviceName = deviceName;
    }
    if (platform != null) {
      $result.platform = platform;
    }
    if (deviceId != null) {
      $result.deviceId = deviceId;
    }
    return $result;
  }
  TestAccountLoginRequest._() : super();
  factory TestAccountLoginRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TestAccountLoginRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TestAccountLoginRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'tureon.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'label')
    ..aOS(2, _omitFieldNames ? '' : 'deviceName')
    ..aOS(3, _omitFieldNames ? '' : 'platform')
    ..aOS(4, _omitFieldNames ? '' : 'deviceId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TestAccountLoginRequest clone() => TestAccountLoginRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TestAccountLoginRequest copyWith(void Function(TestAccountLoginRequest) updates) => super.copyWith((message) => updates(message as TestAccountLoginRequest)) as TestAccountLoginRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TestAccountLoginRequest create() => TestAccountLoginRequest._();
  TestAccountLoginRequest createEmptyInstance() => create();
  static $pb.PbList<TestAccountLoginRequest> createRepeated() => $pb.PbList<TestAccountLoginRequest>();
  @$core.pragma('dart2js:noInline')
  static TestAccountLoginRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TestAccountLoginRequest>(create);
  static TestAccountLoginRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get label => $_getSZ(0);
  @$pb.TagNumber(1)
  set label($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasLabel() => $_has(0);
  @$pb.TagNumber(1)
  void clearLabel() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get deviceName => $_getSZ(1);
  @$pb.TagNumber(2)
  set deviceName($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasDeviceName() => $_has(1);
  @$pb.TagNumber(2)
  void clearDeviceName() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get platform => $_getSZ(2);
  @$pb.TagNumber(3)
  set platform($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasPlatform() => $_has(2);
  @$pb.TagNumber(3)
  void clearPlatform() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get deviceId => $_getSZ(3);
  @$pb.TagNumber(4)
  set deviceId($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasDeviceId() => $_has(3);
  @$pb.TagNumber(4)
  void clearDeviceId() => clearField(4);
}

class AuthResponse extends $pb.GeneratedMessage {
  factory AuthResponse({
    $core.String? accessToken,
    $core.String? refreshToken,
    $core.String? deviceId,
    $core.String? userId,
    $core.String? email,
    $core.String? username,
    $core.String? displayName,
    $core.String? avatarUrl,
    $core.bool? needsUsername,
    $core.String? accountStatus,
    $fixnum.Int64? accessExpiresAt,
    $fixnum.Int64? refreshExpiresAt,
    $core.int? signalDeviceId,
  }) {
    final $result = create();
    if (accessToken != null) {
      $result.accessToken = accessToken;
    }
    if (refreshToken != null) {
      $result.refreshToken = refreshToken;
    }
    if (deviceId != null) {
      $result.deviceId = deviceId;
    }
    if (userId != null) {
      $result.userId = userId;
    }
    if (email != null) {
      $result.email = email;
    }
    if (username != null) {
      $result.username = username;
    }
    if (displayName != null) {
      $result.displayName = displayName;
    }
    if (avatarUrl != null) {
      $result.avatarUrl = avatarUrl;
    }
    if (needsUsername != null) {
      $result.needsUsername = needsUsername;
    }
    if (accountStatus != null) {
      $result.accountStatus = accountStatus;
    }
    if (accessExpiresAt != null) {
      $result.accessExpiresAt = accessExpiresAt;
    }
    if (refreshExpiresAt != null) {
      $result.refreshExpiresAt = refreshExpiresAt;
    }
    if (signalDeviceId != null) {
      $result.signalDeviceId = signalDeviceId;
    }
    return $result;
  }
  AuthResponse._() : super();
  factory AuthResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AuthResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AuthResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'tureon.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'accessToken')
    ..aOS(2, _omitFieldNames ? '' : 'refreshToken')
    ..aOS(3, _omitFieldNames ? '' : 'deviceId')
    ..aOS(4, _omitFieldNames ? '' : 'userId')
    ..aOS(5, _omitFieldNames ? '' : 'email')
    ..aOS(6, _omitFieldNames ? '' : 'username')
    ..aOS(7, _omitFieldNames ? '' : 'displayName')
    ..aOS(8, _omitFieldNames ? '' : 'avatarUrl')
    ..aOB(9, _omitFieldNames ? '' : 'needsUsername')
    ..aOS(10, _omitFieldNames ? '' : 'accountStatus')
    ..aInt64(11, _omitFieldNames ? '' : 'accessExpiresAt')
    ..aInt64(12, _omitFieldNames ? '' : 'refreshExpiresAt')
    ..a<$core.int>(13, _omitFieldNames ? '' : 'signalDeviceId', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AuthResponse clone() => AuthResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AuthResponse copyWith(void Function(AuthResponse) updates) => super.copyWith((message) => updates(message as AuthResponse)) as AuthResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AuthResponse create() => AuthResponse._();
  AuthResponse createEmptyInstance() => create();
  static $pb.PbList<AuthResponse> createRepeated() => $pb.PbList<AuthResponse>();
  @$core.pragma('dart2js:noInline')
  static AuthResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AuthResponse>(create);
  static AuthResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get accessToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set accessToken($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAccessToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearAccessToken() => clearField(1);

  /// Empty for SetUsername, which does not rotate or recover the raw refresh token.
  @$pb.TagNumber(2)
  $core.String get refreshToken => $_getSZ(1);
  @$pb.TagNumber(2)
  set refreshToken($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasRefreshToken() => $_has(1);
  @$pb.TagNumber(2)
  void clearRefreshToken() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get deviceId => $_getSZ(2);
  @$pb.TagNumber(3)
  set deviceId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasDeviceId() => $_has(2);
  @$pb.TagNumber(3)
  void clearDeviceId() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get userId => $_getSZ(3);
  @$pb.TagNumber(4)
  set userId($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasUserId() => $_has(3);
  @$pb.TagNumber(4)
  void clearUserId() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get email => $_getSZ(4);
  @$pb.TagNumber(5)
  set email($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasEmail() => $_has(4);
  @$pb.TagNumber(5)
  void clearEmail() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get username => $_getSZ(5);
  @$pb.TagNumber(6)
  set username($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasUsername() => $_has(5);
  @$pb.TagNumber(6)
  void clearUsername() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get displayName => $_getSZ(6);
  @$pb.TagNumber(7)
  set displayName($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasDisplayName() => $_has(6);
  @$pb.TagNumber(7)
  void clearDisplayName() => clearField(7);

  @$pb.TagNumber(8)
  $core.String get avatarUrl => $_getSZ(7);
  @$pb.TagNumber(8)
  set avatarUrl($core.String v) { $_setString(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasAvatarUrl() => $_has(7);
  @$pb.TagNumber(8)
  void clearAvatarUrl() => clearField(8);

  @$pb.TagNumber(9)
  $core.bool get needsUsername => $_getBF(8);
  @$pb.TagNumber(9)
  set needsUsername($core.bool v) { $_setBool(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasNeedsUsername() => $_has(8);
  @$pb.TagNumber(9)
  void clearNeedsUsername() => clearField(9);

  @$pb.TagNumber(10)
  $core.String get accountStatus => $_getSZ(9);
  @$pb.TagNumber(10)
  set accountStatus($core.String v) { $_setString(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasAccountStatus() => $_has(9);
  @$pb.TagNumber(10)
  void clearAccountStatus() => clearField(10);

  @$pb.TagNumber(11)
  $fixnum.Int64 get accessExpiresAt => $_getI64(10);
  @$pb.TagNumber(11)
  set accessExpiresAt($fixnum.Int64 v) { $_setInt64(10, v); }
  @$pb.TagNumber(11)
  $core.bool hasAccessExpiresAt() => $_has(10);
  @$pb.TagNumber(11)
  void clearAccessExpiresAt() => clearField(11);

  @$pb.TagNumber(12)
  $fixnum.Int64 get refreshExpiresAt => $_getI64(11);
  @$pb.TagNumber(12)
  set refreshExpiresAt($fixnum.Int64 v) { $_setInt64(11, v); }
  @$pb.TagNumber(12)
  $core.bool hasRefreshExpiresAt() => $_has(11);
  @$pb.TagNumber(12)
  void clearRefreshExpiresAt() => clearField(12);

  @$pb.TagNumber(13)
  $core.int get signalDeviceId => $_getIZ(12);
  @$pb.TagNumber(13)
  set signalDeviceId($core.int v) { $_setSignedInt32(12, v); }
  @$pb.TagNumber(13)
  $core.bool hasSignalDeviceId() => $_has(12);
  @$pb.TagNumber(13)
  void clearSignalDeviceId() => clearField(13);
}

class SetUsernameRequest extends $pb.GeneratedMessage {
  factory SetUsernameRequest({
    $core.String? username,
  }) {
    final $result = create();
    if (username != null) {
      $result.username = username;
    }
    return $result;
  }
  SetUsernameRequest._() : super();
  factory SetUsernameRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SetUsernameRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SetUsernameRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'tureon.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'username')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SetUsernameRequest clone() => SetUsernameRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SetUsernameRequest copyWith(void Function(SetUsernameRequest) updates) => super.copyWith((message) => updates(message as SetUsernameRequest)) as SetUsernameRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetUsernameRequest create() => SetUsernameRequest._();
  SetUsernameRequest createEmptyInstance() => create();
  static $pb.PbList<SetUsernameRequest> createRepeated() => $pb.PbList<SetUsernameRequest>();
  @$core.pragma('dart2js:noInline')
  static SetUsernameRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SetUsernameRequest>(create);
  static SetUsernameRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get username => $_getSZ(0);
  @$pb.TagNumber(1)
  set username($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasUsername() => $_has(0);
  @$pb.TagNumber(1)
  void clearUsername() => clearField(1);
}

class RefreshTokenRequest extends $pb.GeneratedMessage {
  factory RefreshTokenRequest({
    $core.String? refreshToken,
    $core.String? deviceId,
  }) {
    final $result = create();
    if (refreshToken != null) {
      $result.refreshToken = refreshToken;
    }
    if (deviceId != null) {
      $result.deviceId = deviceId;
    }
    return $result;
  }
  RefreshTokenRequest._() : super();
  factory RefreshTokenRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory RefreshTokenRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RefreshTokenRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'tureon.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'refreshToken')
    ..aOS(2, _omitFieldNames ? '' : 'deviceId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  RefreshTokenRequest clone() => RefreshTokenRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  RefreshTokenRequest copyWith(void Function(RefreshTokenRequest) updates) => super.copyWith((message) => updates(message as RefreshTokenRequest)) as RefreshTokenRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RefreshTokenRequest create() => RefreshTokenRequest._();
  RefreshTokenRequest createEmptyInstance() => create();
  static $pb.PbList<RefreshTokenRequest> createRepeated() => $pb.PbList<RefreshTokenRequest>();
  @$core.pragma('dart2js:noInline')
  static RefreshTokenRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RefreshTokenRequest>(create);
  static RefreshTokenRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get refreshToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set refreshToken($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasRefreshToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearRefreshToken() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get deviceId => $_getSZ(1);
  @$pb.TagNumber(2)
  set deviceId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasDeviceId() => $_has(1);
  @$pb.TagNumber(2)
  void clearDeviceId() => clearField(2);
}

class LogoutRequest extends $pb.GeneratedMessage {
  factory LogoutRequest({
    $core.String? deviceId,
  }) {
    final $result = create();
    if (deviceId != null) {
      $result.deviceId = deviceId;
    }
    return $result;
  }
  LogoutRequest._() : super();
  factory LogoutRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory LogoutRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LogoutRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'tureon.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'deviceId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  LogoutRequest clone() => LogoutRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  LogoutRequest copyWith(void Function(LogoutRequest) updates) => super.copyWith((message) => updates(message as LogoutRequest)) as LogoutRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LogoutRequest create() => LogoutRequest._();
  LogoutRequest createEmptyInstance() => create();
  static $pb.PbList<LogoutRequest> createRepeated() => $pb.PbList<LogoutRequest>();
  @$core.pragma('dart2js:noInline')
  static LogoutRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LogoutRequest>(create);
  static LogoutRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get deviceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set deviceId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasDeviceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearDeviceId() => clearField(1);
}

class DeviceInfo extends $pb.GeneratedMessage {
  factory DeviceInfo({
    $core.String? deviceId,
    $core.String? deviceName,
    $core.String? platform,
    $fixnum.Int64? lastActiveAt,
    $core.bool? isCurrent,
  }) {
    final $result = create();
    if (deviceId != null) {
      $result.deviceId = deviceId;
    }
    if (deviceName != null) {
      $result.deviceName = deviceName;
    }
    if (platform != null) {
      $result.platform = platform;
    }
    if (lastActiveAt != null) {
      $result.lastActiveAt = lastActiveAt;
    }
    if (isCurrent != null) {
      $result.isCurrent = isCurrent;
    }
    return $result;
  }
  DeviceInfo._() : super();
  factory DeviceInfo.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DeviceInfo.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DeviceInfo', package: const $pb.PackageName(_omitMessageNames ? '' : 'tureon.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'deviceId')
    ..aOS(2, _omitFieldNames ? '' : 'deviceName')
    ..aOS(3, _omitFieldNames ? '' : 'platform')
    ..aInt64(4, _omitFieldNames ? '' : 'lastActiveAt')
    ..aOB(5, _omitFieldNames ? '' : 'isCurrent')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DeviceInfo clone() => DeviceInfo()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DeviceInfo copyWith(void Function(DeviceInfo) updates) => super.copyWith((message) => updates(message as DeviceInfo)) as DeviceInfo;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeviceInfo create() => DeviceInfo._();
  DeviceInfo createEmptyInstance() => create();
  static $pb.PbList<DeviceInfo> createRepeated() => $pb.PbList<DeviceInfo>();
  @$core.pragma('dart2js:noInline')
  static DeviceInfo getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DeviceInfo>(create);
  static DeviceInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get deviceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set deviceId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasDeviceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearDeviceId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get deviceName => $_getSZ(1);
  @$pb.TagNumber(2)
  set deviceName($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasDeviceName() => $_has(1);
  @$pb.TagNumber(2)
  void clearDeviceName() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get platform => $_getSZ(2);
  @$pb.TagNumber(3)
  set platform($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasPlatform() => $_has(2);
  @$pb.TagNumber(3)
  void clearPlatform() => clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get lastActiveAt => $_getI64(3);
  @$pb.TagNumber(4)
  set lastActiveAt($fixnum.Int64 v) { $_setInt64(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasLastActiveAt() => $_has(3);
  @$pb.TagNumber(4)
  void clearLastActiveAt() => clearField(4);

  @$pb.TagNumber(5)
  $core.bool get isCurrent => $_getBF(4);
  @$pb.TagNumber(5)
  set isCurrent($core.bool v) { $_setBool(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasIsCurrent() => $_has(4);
  @$pb.TagNumber(5)
  void clearIsCurrent() => clearField(5);
}

class ListDevicesResponse extends $pb.GeneratedMessage {
  factory ListDevicesResponse({
    $core.Iterable<DeviceInfo>? devices,
  }) {
    final $result = create();
    if (devices != null) {
      $result.devices.addAll(devices);
    }
    return $result;
  }
  ListDevicesResponse._() : super();
  factory ListDevicesResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListDevicesResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListDevicesResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'tureon.v1'), createEmptyInstance: create)
    ..pc<DeviceInfo>(1, _omitFieldNames ? '' : 'devices', $pb.PbFieldType.PM, subBuilder: DeviceInfo.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListDevicesResponse clone() => ListDevicesResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListDevicesResponse copyWith(void Function(ListDevicesResponse) updates) => super.copyWith((message) => updates(message as ListDevicesResponse)) as ListDevicesResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListDevicesResponse create() => ListDevicesResponse._();
  ListDevicesResponse createEmptyInstance() => create();
  static $pb.PbList<ListDevicesResponse> createRepeated() => $pb.PbList<ListDevicesResponse>();
  @$core.pragma('dart2js:noInline')
  static ListDevicesResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListDevicesResponse>(create);
  static ListDevicesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<DeviceInfo> get devices => $_getList(0);
}

class KeyBundleUploadRequest extends $pb.GeneratedMessage {
  factory KeyBundleUploadRequest({
    $core.String? deviceId,
    $core.String? identityPublicKey,
    $core.String? signedPrekeyPublic,
    $core.int? signedPrekeyId,
    $core.String? signedPrekeySignature,
    $core.Iterable<OneTimePreKey>? oneTimePrekeys,
    $core.int? registrationId,
    $core.int? kyberPrekeyId,
    $core.String? kyberPrekeyPublic,
    $core.String? kyberPrekeySignature,
    $core.int? signalDeviceId,
  }) {
    final $result = create();
    if (deviceId != null) {
      $result.deviceId = deviceId;
    }
    if (identityPublicKey != null) {
      $result.identityPublicKey = identityPublicKey;
    }
    if (signedPrekeyPublic != null) {
      $result.signedPrekeyPublic = signedPrekeyPublic;
    }
    if (signedPrekeyId != null) {
      $result.signedPrekeyId = signedPrekeyId;
    }
    if (signedPrekeySignature != null) {
      $result.signedPrekeySignature = signedPrekeySignature;
    }
    if (oneTimePrekeys != null) {
      $result.oneTimePrekeys.addAll(oneTimePrekeys);
    }
    if (registrationId != null) {
      $result.registrationId = registrationId;
    }
    if (kyberPrekeyId != null) {
      $result.kyberPrekeyId = kyberPrekeyId;
    }
    if (kyberPrekeyPublic != null) {
      $result.kyberPrekeyPublic = kyberPrekeyPublic;
    }
    if (kyberPrekeySignature != null) {
      $result.kyberPrekeySignature = kyberPrekeySignature;
    }
    if (signalDeviceId != null) {
      $result.signalDeviceId = signalDeviceId;
    }
    return $result;
  }
  KeyBundleUploadRequest._() : super();
  factory KeyBundleUploadRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory KeyBundleUploadRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'KeyBundleUploadRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'tureon.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'deviceId')
    ..aOS(2, _omitFieldNames ? '' : 'identityPublicKey')
    ..aOS(3, _omitFieldNames ? '' : 'signedPrekeyPublic')
    ..a<$core.int>(4, _omitFieldNames ? '' : 'signedPrekeyId', $pb.PbFieldType.O3)
    ..aOS(5, _omitFieldNames ? '' : 'signedPrekeySignature')
    ..pc<OneTimePreKey>(6, _omitFieldNames ? '' : 'oneTimePrekeys', $pb.PbFieldType.PM, subBuilder: OneTimePreKey.create)
    ..a<$core.int>(7, _omitFieldNames ? '' : 'registrationId', $pb.PbFieldType.O3)
    ..a<$core.int>(8, _omitFieldNames ? '' : 'kyberPrekeyId', $pb.PbFieldType.O3)
    ..aOS(9, _omitFieldNames ? '' : 'kyberPrekeyPublic')
    ..aOS(10, _omitFieldNames ? '' : 'kyberPrekeySignature')
    ..a<$core.int>(11, _omitFieldNames ? '' : 'signalDeviceId', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  KeyBundleUploadRequest clone() => KeyBundleUploadRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  KeyBundleUploadRequest copyWith(void Function(KeyBundleUploadRequest) updates) => super.copyWith((message) => updates(message as KeyBundleUploadRequest)) as KeyBundleUploadRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static KeyBundleUploadRequest create() => KeyBundleUploadRequest._();
  KeyBundleUploadRequest createEmptyInstance() => create();
  static $pb.PbList<KeyBundleUploadRequest> createRepeated() => $pb.PbList<KeyBundleUploadRequest>();
  @$core.pragma('dart2js:noInline')
  static KeyBundleUploadRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<KeyBundleUploadRequest>(create);
  static KeyBundleUploadRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get deviceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set deviceId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasDeviceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearDeviceId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get identityPublicKey => $_getSZ(1);
  @$pb.TagNumber(2)
  set identityPublicKey($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasIdentityPublicKey() => $_has(1);
  @$pb.TagNumber(2)
  void clearIdentityPublicKey() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get signedPrekeyPublic => $_getSZ(2);
  @$pb.TagNumber(3)
  set signedPrekeyPublic($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasSignedPrekeyPublic() => $_has(2);
  @$pb.TagNumber(3)
  void clearSignedPrekeyPublic() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get signedPrekeyId => $_getIZ(3);
  @$pb.TagNumber(4)
  set signedPrekeyId($core.int v) { $_setSignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasSignedPrekeyId() => $_has(3);
  @$pb.TagNumber(4)
  void clearSignedPrekeyId() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get signedPrekeySignature => $_getSZ(4);
  @$pb.TagNumber(5)
  set signedPrekeySignature($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasSignedPrekeySignature() => $_has(4);
  @$pb.TagNumber(5)
  void clearSignedPrekeySignature() => clearField(5);

  @$pb.TagNumber(6)
  $core.List<OneTimePreKey> get oneTimePrekeys => $_getList(5);

  @$pb.TagNumber(7)
  $core.int get registrationId => $_getIZ(6);
  @$pb.TagNumber(7)
  set registrationId($core.int v) { $_setSignedInt32(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasRegistrationId() => $_has(6);
  @$pb.TagNumber(7)
  void clearRegistrationId() => clearField(7);

  @$pb.TagNumber(8)
  $core.int get kyberPrekeyId => $_getIZ(7);
  @$pb.TagNumber(8)
  set kyberPrekeyId($core.int v) { $_setSignedInt32(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasKyberPrekeyId() => $_has(7);
  @$pb.TagNumber(8)
  void clearKyberPrekeyId() => clearField(8);

  @$pb.TagNumber(9)
  $core.String get kyberPrekeyPublic => $_getSZ(8);
  @$pb.TagNumber(9)
  set kyberPrekeyPublic($core.String v) { $_setString(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasKyberPrekeyPublic() => $_has(8);
  @$pb.TagNumber(9)
  void clearKyberPrekeyPublic() => clearField(9);

  @$pb.TagNumber(10)
  $core.String get kyberPrekeySignature => $_getSZ(9);
  @$pb.TagNumber(10)
  set kyberPrekeySignature($core.String v) { $_setString(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasKyberPrekeySignature() => $_has(9);
  @$pb.TagNumber(10)
  void clearKyberPrekeySignature() => clearField(10);

  @$pb.TagNumber(11)
  $core.int get signalDeviceId => $_getIZ(10);
  @$pb.TagNumber(11)
  set signalDeviceId($core.int v) { $_setSignedInt32(10, v); }
  @$pb.TagNumber(11)
  $core.bool hasSignalDeviceId() => $_has(10);
  @$pb.TagNumber(11)
  void clearSignalDeviceId() => clearField(11);
}

class OneTimePreKey extends $pb.GeneratedMessage {
  factory OneTimePreKey({
    $core.int? keyId,
    $core.String? publicKey,
  }) {
    final $result = create();
    if (keyId != null) {
      $result.keyId = keyId;
    }
    if (publicKey != null) {
      $result.publicKey = publicKey;
    }
    return $result;
  }
  OneTimePreKey._() : super();
  factory OneTimePreKey.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory OneTimePreKey.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'OneTimePreKey', package: const $pb.PackageName(_omitMessageNames ? '' : 'tureon.v1'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'keyId', $pb.PbFieldType.O3)
    ..aOS(2, _omitFieldNames ? '' : 'publicKey')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  OneTimePreKey clone() => OneTimePreKey()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  OneTimePreKey copyWith(void Function(OneTimePreKey) updates) => super.copyWith((message) => updates(message as OneTimePreKey)) as OneTimePreKey;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static OneTimePreKey create() => OneTimePreKey._();
  OneTimePreKey createEmptyInstance() => create();
  static $pb.PbList<OneTimePreKey> createRepeated() => $pb.PbList<OneTimePreKey>();
  @$core.pragma('dart2js:noInline')
  static OneTimePreKey getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<OneTimePreKey>(create);
  static OneTimePreKey? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get keyId => $_getIZ(0);
  @$pb.TagNumber(1)
  set keyId($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasKeyId() => $_has(0);
  @$pb.TagNumber(1)
  void clearKeyId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get publicKey => $_getSZ(1);
  @$pb.TagNumber(2)
  set publicKey($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasPublicKey() => $_has(1);
  @$pb.TagNumber(2)
  void clearPublicKey() => clearField(2);
}

class KeyBundle extends $pb.GeneratedMessage {
  factory KeyBundle({
    $core.String? deviceId,
    $core.String? identityPublicKey,
    $core.String? signedPrekeyPublic,
    $core.int? signedPrekeyId,
    $core.String? signedPrekeySignature,
    $core.Iterable<OneTimePreKey>? oneTimePrekeys,
    $core.int? registrationId,
    $core.int? kyberPrekeyId,
    $core.String? kyberPrekeyPublic,
    $core.String? kyberPrekeySignature,
    $core.int? signalDeviceId,
  }) {
    final $result = create();
    if (deviceId != null) {
      $result.deviceId = deviceId;
    }
    if (identityPublicKey != null) {
      $result.identityPublicKey = identityPublicKey;
    }
    if (signedPrekeyPublic != null) {
      $result.signedPrekeyPublic = signedPrekeyPublic;
    }
    if (signedPrekeyId != null) {
      $result.signedPrekeyId = signedPrekeyId;
    }
    if (signedPrekeySignature != null) {
      $result.signedPrekeySignature = signedPrekeySignature;
    }
    if (oneTimePrekeys != null) {
      $result.oneTimePrekeys.addAll(oneTimePrekeys);
    }
    if (registrationId != null) {
      $result.registrationId = registrationId;
    }
    if (kyberPrekeyId != null) {
      $result.kyberPrekeyId = kyberPrekeyId;
    }
    if (kyberPrekeyPublic != null) {
      $result.kyberPrekeyPublic = kyberPrekeyPublic;
    }
    if (kyberPrekeySignature != null) {
      $result.kyberPrekeySignature = kyberPrekeySignature;
    }
    if (signalDeviceId != null) {
      $result.signalDeviceId = signalDeviceId;
    }
    return $result;
  }
  KeyBundle._() : super();
  factory KeyBundle.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory KeyBundle.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'KeyBundle', package: const $pb.PackageName(_omitMessageNames ? '' : 'tureon.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'deviceId')
    ..aOS(2, _omitFieldNames ? '' : 'identityPublicKey')
    ..aOS(3, _omitFieldNames ? '' : 'signedPrekeyPublic')
    ..a<$core.int>(4, _omitFieldNames ? '' : 'signedPrekeyId', $pb.PbFieldType.O3)
    ..aOS(5, _omitFieldNames ? '' : 'signedPrekeySignature')
    ..pc<OneTimePreKey>(6, _omitFieldNames ? '' : 'oneTimePrekeys', $pb.PbFieldType.PM, subBuilder: OneTimePreKey.create)
    ..a<$core.int>(7, _omitFieldNames ? '' : 'registrationId', $pb.PbFieldType.O3)
    ..a<$core.int>(8, _omitFieldNames ? '' : 'kyberPrekeyId', $pb.PbFieldType.O3)
    ..aOS(9, _omitFieldNames ? '' : 'kyberPrekeyPublic')
    ..aOS(10, _omitFieldNames ? '' : 'kyberPrekeySignature')
    ..a<$core.int>(11, _omitFieldNames ? '' : 'signalDeviceId', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  KeyBundle clone() => KeyBundle()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  KeyBundle copyWith(void Function(KeyBundle) updates) => super.copyWith((message) => updates(message as KeyBundle)) as KeyBundle;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static KeyBundle create() => KeyBundle._();
  KeyBundle createEmptyInstance() => create();
  static $pb.PbList<KeyBundle> createRepeated() => $pb.PbList<KeyBundle>();
  @$core.pragma('dart2js:noInline')
  static KeyBundle getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<KeyBundle>(create);
  static KeyBundle? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get deviceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set deviceId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasDeviceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearDeviceId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get identityPublicKey => $_getSZ(1);
  @$pb.TagNumber(2)
  set identityPublicKey($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasIdentityPublicKey() => $_has(1);
  @$pb.TagNumber(2)
  void clearIdentityPublicKey() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get signedPrekeyPublic => $_getSZ(2);
  @$pb.TagNumber(3)
  set signedPrekeyPublic($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasSignedPrekeyPublic() => $_has(2);
  @$pb.TagNumber(3)
  void clearSignedPrekeyPublic() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get signedPrekeyId => $_getIZ(3);
  @$pb.TagNumber(4)
  set signedPrekeyId($core.int v) { $_setSignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasSignedPrekeyId() => $_has(3);
  @$pb.TagNumber(4)
  void clearSignedPrekeyId() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get signedPrekeySignature => $_getSZ(4);
  @$pb.TagNumber(5)
  set signedPrekeySignature($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasSignedPrekeySignature() => $_has(4);
  @$pb.TagNumber(5)
  void clearSignedPrekeySignature() => clearField(5);

  @$pb.TagNumber(6)
  $core.List<OneTimePreKey> get oneTimePrekeys => $_getList(5);

  @$pb.TagNumber(7)
  $core.int get registrationId => $_getIZ(6);
  @$pb.TagNumber(7)
  set registrationId($core.int v) { $_setSignedInt32(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasRegistrationId() => $_has(6);
  @$pb.TagNumber(7)
  void clearRegistrationId() => clearField(7);

  @$pb.TagNumber(8)
  $core.int get kyberPrekeyId => $_getIZ(7);
  @$pb.TagNumber(8)
  set kyberPrekeyId($core.int v) { $_setSignedInt32(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasKyberPrekeyId() => $_has(7);
  @$pb.TagNumber(8)
  void clearKyberPrekeyId() => clearField(8);

  @$pb.TagNumber(9)
  $core.String get kyberPrekeyPublic => $_getSZ(8);
  @$pb.TagNumber(9)
  set kyberPrekeyPublic($core.String v) { $_setString(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasKyberPrekeyPublic() => $_has(8);
  @$pb.TagNumber(9)
  void clearKyberPrekeyPublic() => clearField(9);

  @$pb.TagNumber(10)
  $core.String get kyberPrekeySignature => $_getSZ(9);
  @$pb.TagNumber(10)
  set kyberPrekeySignature($core.String v) { $_setString(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasKyberPrekeySignature() => $_has(9);
  @$pb.TagNumber(10)
  void clearKyberPrekeySignature() => clearField(10);

  @$pb.TagNumber(11)
  $core.int get signalDeviceId => $_getIZ(10);
  @$pb.TagNumber(11)
  set signalDeviceId($core.int v) { $_setSignedInt32(10, v); }
  @$pb.TagNumber(11)
  $core.bool hasSignalDeviceId() => $_has(10);
  @$pb.TagNumber(11)
  void clearSignalDeviceId() => clearField(11);
}

class GetKeyBundleRequest extends $pb.GeneratedMessage {
  factory GetKeyBundleRequest({
    $core.String? recipientId,
    $core.String? deviceId,
  }) {
    final $result = create();
    if (recipientId != null) {
      $result.recipientId = recipientId;
    }
    if (deviceId != null) {
      $result.deviceId = deviceId;
    }
    return $result;
  }
  GetKeyBundleRequest._() : super();
  factory GetKeyBundleRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetKeyBundleRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetKeyBundleRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'tureon.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'recipientId')
    ..aOS(2, _omitFieldNames ? '' : 'deviceId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetKeyBundleRequest clone() => GetKeyBundleRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetKeyBundleRequest copyWith(void Function(GetKeyBundleRequest) updates) => super.copyWith((message) => updates(message as GetKeyBundleRequest)) as GetKeyBundleRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetKeyBundleRequest create() => GetKeyBundleRequest._();
  GetKeyBundleRequest createEmptyInstance() => create();
  static $pb.PbList<GetKeyBundleRequest> createRepeated() => $pb.PbList<GetKeyBundleRequest>();
  @$core.pragma('dart2js:noInline')
  static GetKeyBundleRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetKeyBundleRequest>(create);
  static GetKeyBundleRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get recipientId => $_getSZ(0);
  @$pb.TagNumber(1)
  set recipientId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasRecipientId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRecipientId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get deviceId => $_getSZ(1);
  @$pb.TagNumber(2)
  set deviceId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasDeviceId() => $_has(1);
  @$pb.TagNumber(2)
  void clearDeviceId() => clearField(2);
}

class RefillOneTimePrekeysRequest extends $pb.GeneratedMessage {
  factory RefillOneTimePrekeysRequest({
    $core.Iterable<OneTimePreKey>? oneTimePrekeys,
  }) {
    final $result = create();
    if (oneTimePrekeys != null) {
      $result.oneTimePrekeys.addAll(oneTimePrekeys);
    }
    return $result;
  }
  RefillOneTimePrekeysRequest._() : super();
  factory RefillOneTimePrekeysRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory RefillOneTimePrekeysRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RefillOneTimePrekeysRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'tureon.v1'), createEmptyInstance: create)
    ..pc<OneTimePreKey>(1, _omitFieldNames ? '' : 'oneTimePrekeys', $pb.PbFieldType.PM, subBuilder: OneTimePreKey.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  RefillOneTimePrekeysRequest clone() => RefillOneTimePrekeysRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  RefillOneTimePrekeysRequest copyWith(void Function(RefillOneTimePrekeysRequest) updates) => super.copyWith((message) => updates(message as RefillOneTimePrekeysRequest)) as RefillOneTimePrekeysRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RefillOneTimePrekeysRequest create() => RefillOneTimePrekeysRequest._();
  RefillOneTimePrekeysRequest createEmptyInstance() => create();
  static $pb.PbList<RefillOneTimePrekeysRequest> createRepeated() => $pb.PbList<RefillOneTimePrekeysRequest>();
  @$core.pragma('dart2js:noInline')
  static RefillOneTimePrekeysRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RefillOneTimePrekeysRequest>(create);
  static RefillOneTimePrekeysRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<OneTimePreKey> get oneTimePrekeys => $_getList(0);
}

class GetPreKeyCountResponse extends $pb.GeneratedMessage {
  factory GetPreKeyCountResponse({
    $core.int? count,
    $core.int? lowWatermark,
  }) {
    final $result = create();
    if (count != null) {
      $result.count = count;
    }
    if (lowWatermark != null) {
      $result.lowWatermark = lowWatermark;
    }
    return $result;
  }
  GetPreKeyCountResponse._() : super();
  factory GetPreKeyCountResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetPreKeyCountResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetPreKeyCountResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'tureon.v1'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'count', $pb.PbFieldType.O3)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'lowWatermark', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetPreKeyCountResponse clone() => GetPreKeyCountResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetPreKeyCountResponse copyWith(void Function(GetPreKeyCountResponse) updates) => super.copyWith((message) => updates(message as GetPreKeyCountResponse)) as GetPreKeyCountResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetPreKeyCountResponse create() => GetPreKeyCountResponse._();
  GetPreKeyCountResponse createEmptyInstance() => create();
  static $pb.PbList<GetPreKeyCountResponse> createRepeated() => $pb.PbList<GetPreKeyCountResponse>();
  @$core.pragma('dart2js:noInline')
  static GetPreKeyCountResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetPreKeyCountResponse>(create);
  static GetPreKeyCountResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get count => $_getIZ(0);
  @$pb.TagNumber(1)
  set count($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasCount() => $_has(0);
  @$pb.TagNumber(1)
  void clearCount() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get lowWatermark => $_getIZ(1);
  @$pb.TagNumber(2)
  set lowWatermark($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasLowWatermark() => $_has(1);
  @$pb.TagNumber(2)
  void clearLowWatermark() => clearField(2);
}

class ListRecipientKeyDevicesRequest extends $pb.GeneratedMessage {
  factory ListRecipientKeyDevicesRequest({
    $core.String? recipientId,
  }) {
    final $result = create();
    if (recipientId != null) {
      $result.recipientId = recipientId;
    }
    return $result;
  }
  ListRecipientKeyDevicesRequest._() : super();
  factory ListRecipientKeyDevicesRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListRecipientKeyDevicesRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListRecipientKeyDevicesRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'tureon.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'recipientId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListRecipientKeyDevicesRequest clone() => ListRecipientKeyDevicesRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListRecipientKeyDevicesRequest copyWith(void Function(ListRecipientKeyDevicesRequest) updates) => super.copyWith((message) => updates(message as ListRecipientKeyDevicesRequest)) as ListRecipientKeyDevicesRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListRecipientKeyDevicesRequest create() => ListRecipientKeyDevicesRequest._();
  ListRecipientKeyDevicesRequest createEmptyInstance() => create();
  static $pb.PbList<ListRecipientKeyDevicesRequest> createRepeated() => $pb.PbList<ListRecipientKeyDevicesRequest>();
  @$core.pragma('dart2js:noInline')
  static ListRecipientKeyDevicesRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListRecipientKeyDevicesRequest>(create);
  static ListRecipientKeyDevicesRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get recipientId => $_getSZ(0);
  @$pb.TagNumber(1)
  set recipientId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasRecipientId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRecipientId() => clearField(1);
}

class KeyDeviceInfo extends $pb.GeneratedMessage {
  factory KeyDeviceInfo({
    $core.String? deviceId,
    $core.String? deviceName,
    $core.String? platform,
    $core.int? signalDeviceId,
    $core.int? oneTimePrekeyCount,
  }) {
    final $result = create();
    if (deviceId != null) {
      $result.deviceId = deviceId;
    }
    if (deviceName != null) {
      $result.deviceName = deviceName;
    }
    if (platform != null) {
      $result.platform = platform;
    }
    if (signalDeviceId != null) {
      $result.signalDeviceId = signalDeviceId;
    }
    if (oneTimePrekeyCount != null) {
      $result.oneTimePrekeyCount = oneTimePrekeyCount;
    }
    return $result;
  }
  KeyDeviceInfo._() : super();
  factory KeyDeviceInfo.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory KeyDeviceInfo.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'KeyDeviceInfo', package: const $pb.PackageName(_omitMessageNames ? '' : 'tureon.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'deviceId')
    ..aOS(2, _omitFieldNames ? '' : 'deviceName')
    ..aOS(3, _omitFieldNames ? '' : 'platform')
    ..a<$core.int>(4, _omitFieldNames ? '' : 'signalDeviceId', $pb.PbFieldType.O3)
    ..a<$core.int>(5, _omitFieldNames ? '' : 'oneTimePrekeyCount', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  KeyDeviceInfo clone() => KeyDeviceInfo()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  KeyDeviceInfo copyWith(void Function(KeyDeviceInfo) updates) => super.copyWith((message) => updates(message as KeyDeviceInfo)) as KeyDeviceInfo;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static KeyDeviceInfo create() => KeyDeviceInfo._();
  KeyDeviceInfo createEmptyInstance() => create();
  static $pb.PbList<KeyDeviceInfo> createRepeated() => $pb.PbList<KeyDeviceInfo>();
  @$core.pragma('dart2js:noInline')
  static KeyDeviceInfo getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<KeyDeviceInfo>(create);
  static KeyDeviceInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get deviceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set deviceId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasDeviceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearDeviceId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get deviceName => $_getSZ(1);
  @$pb.TagNumber(2)
  set deviceName($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasDeviceName() => $_has(1);
  @$pb.TagNumber(2)
  void clearDeviceName() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get platform => $_getSZ(2);
  @$pb.TagNumber(3)
  set platform($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasPlatform() => $_has(2);
  @$pb.TagNumber(3)
  void clearPlatform() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get signalDeviceId => $_getIZ(3);
  @$pb.TagNumber(4)
  set signalDeviceId($core.int v) { $_setSignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasSignalDeviceId() => $_has(3);
  @$pb.TagNumber(4)
  void clearSignalDeviceId() => clearField(4);

  @$pb.TagNumber(5)
  $core.int get oneTimePrekeyCount => $_getIZ(4);
  @$pb.TagNumber(5)
  set oneTimePrekeyCount($core.int v) { $_setSignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasOneTimePrekeyCount() => $_has(4);
  @$pb.TagNumber(5)
  void clearOneTimePrekeyCount() => clearField(5);
}

class ListRecipientKeyDevicesResponse extends $pb.GeneratedMessage {
  factory ListRecipientKeyDevicesResponse({
    $core.Iterable<KeyDeviceInfo>? devices,
  }) {
    final $result = create();
    if (devices != null) {
      $result.devices.addAll(devices);
    }
    return $result;
  }
  ListRecipientKeyDevicesResponse._() : super();
  factory ListRecipientKeyDevicesResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListRecipientKeyDevicesResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListRecipientKeyDevicesResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'tureon.v1'), createEmptyInstance: create)
    ..pc<KeyDeviceInfo>(1, _omitFieldNames ? '' : 'devices', $pb.PbFieldType.PM, subBuilder: KeyDeviceInfo.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListRecipientKeyDevicesResponse clone() => ListRecipientKeyDevicesResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListRecipientKeyDevicesResponse copyWith(void Function(ListRecipientKeyDevicesResponse) updates) => super.copyWith((message) => updates(message as ListRecipientKeyDevicesResponse)) as ListRecipientKeyDevicesResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListRecipientKeyDevicesResponse create() => ListRecipientKeyDevicesResponse._();
  ListRecipientKeyDevicesResponse createEmptyInstance() => create();
  static $pb.PbList<ListRecipientKeyDevicesResponse> createRepeated() => $pb.PbList<ListRecipientKeyDevicesResponse>();
  @$core.pragma('dart2js:noInline')
  static ListRecipientKeyDevicesResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListRecipientKeyDevicesResponse>(create);
  static ListRecipientKeyDevicesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<KeyDeviceInfo> get devices => $_getList(0);
}

class SearchUsersByUsernameRequest extends $pb.GeneratedMessage {
  factory SearchUsersByUsernameRequest({
    $core.String? query,
  }) {
    final $result = create();
    if (query != null) {
      $result.query = query;
    }
    return $result;
  }
  SearchUsersByUsernameRequest._() : super();
  factory SearchUsersByUsernameRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SearchUsersByUsernameRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SearchUsersByUsernameRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'tureon.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'query')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SearchUsersByUsernameRequest clone() => SearchUsersByUsernameRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SearchUsersByUsernameRequest copyWith(void Function(SearchUsersByUsernameRequest) updates) => super.copyWith((message) => updates(message as SearchUsersByUsernameRequest)) as SearchUsersByUsernameRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SearchUsersByUsernameRequest create() => SearchUsersByUsernameRequest._();
  SearchUsersByUsernameRequest createEmptyInstance() => create();
  static $pb.PbList<SearchUsersByUsernameRequest> createRepeated() => $pb.PbList<SearchUsersByUsernameRequest>();
  @$core.pragma('dart2js:noInline')
  static SearchUsersByUsernameRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SearchUsersByUsernameRequest>(create);
  static SearchUsersByUsernameRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get query => $_getSZ(0);
  @$pb.TagNumber(1)
  set query($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasQuery() => $_has(0);
  @$pb.TagNumber(1)
  void clearQuery() => clearField(1);
}

class UserSearchResult extends $pb.GeneratedMessage {
  factory UserSearchResult({
    $core.String? recipientId,
    $core.String? username,
    $core.String? displayName,
    $core.String? avatarUrl,
    $core.String? verificationBadge,
    $core.String? recipientType,
    $core.String? description,
    $core.String? countryCode,
    $fixnum.Int64? createdAt,
  }) {
    final $result = create();
    if (recipientId != null) {
      $result.recipientId = recipientId;
    }
    if (username != null) {
      $result.username = username;
    }
    if (displayName != null) {
      $result.displayName = displayName;
    }
    if (avatarUrl != null) {
      $result.avatarUrl = avatarUrl;
    }
    if (verificationBadge != null) {
      $result.verificationBadge = verificationBadge;
    }
    if (recipientType != null) {
      $result.recipientType = recipientType;
    }
    if (description != null) {
      $result.description = description;
    }
    if (countryCode != null) {
      $result.countryCode = countryCode;
    }
    if (createdAt != null) {
      $result.createdAt = createdAt;
    }
    return $result;
  }
  UserSearchResult._() : super();
  factory UserSearchResult.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UserSearchResult.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UserSearchResult', package: const $pb.PackageName(_omitMessageNames ? '' : 'tureon.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'recipientId')
    ..aOS(2, _omitFieldNames ? '' : 'username')
    ..aOS(3, _omitFieldNames ? '' : 'displayName')
    ..aOS(4, _omitFieldNames ? '' : 'avatarUrl')
    ..aOS(5, _omitFieldNames ? '' : 'verificationBadge')
    ..aOS(6, _omitFieldNames ? '' : 'recipientType')
    ..aOS(7, _omitFieldNames ? '' : 'description')
    ..aOS(8, _omitFieldNames ? '' : 'countryCode')
    ..aInt64(9, _omitFieldNames ? '' : 'createdAt')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UserSearchResult clone() => UserSearchResult()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UserSearchResult copyWith(void Function(UserSearchResult) updates) => super.copyWith((message) => updates(message as UserSearchResult)) as UserSearchResult;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UserSearchResult create() => UserSearchResult._();
  UserSearchResult createEmptyInstance() => create();
  static $pb.PbList<UserSearchResult> createRepeated() => $pb.PbList<UserSearchResult>();
  @$core.pragma('dart2js:noInline')
  static UserSearchResult getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UserSearchResult>(create);
  static UserSearchResult? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get recipientId => $_getSZ(0);
  @$pb.TagNumber(1)
  set recipientId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasRecipientId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRecipientId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get username => $_getSZ(1);
  @$pb.TagNumber(2)
  set username($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasUsername() => $_has(1);
  @$pb.TagNumber(2)
  void clearUsername() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get displayName => $_getSZ(2);
  @$pb.TagNumber(3)
  set displayName($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasDisplayName() => $_has(2);
  @$pb.TagNumber(3)
  void clearDisplayName() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get avatarUrl => $_getSZ(3);
  @$pb.TagNumber(4)
  set avatarUrl($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasAvatarUrl() => $_has(3);
  @$pb.TagNumber(4)
  void clearAvatarUrl() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get verificationBadge => $_getSZ(4);
  @$pb.TagNumber(5)
  set verificationBadge($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasVerificationBadge() => $_has(4);
  @$pb.TagNumber(5)
  void clearVerificationBadge() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get recipientType => $_getSZ(5);
  @$pb.TagNumber(6)
  set recipientType($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasRecipientType() => $_has(5);
  @$pb.TagNumber(6)
  void clearRecipientType() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get description => $_getSZ(6);
  @$pb.TagNumber(7)
  set description($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasDescription() => $_has(6);
  @$pb.TagNumber(7)
  void clearDescription() => clearField(7);

  @$pb.TagNumber(8)
  $core.String get countryCode => $_getSZ(7);
  @$pb.TagNumber(8)
  set countryCode($core.String v) { $_setString(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasCountryCode() => $_has(7);
  @$pb.TagNumber(8)
  void clearCountryCode() => clearField(8);

  @$pb.TagNumber(9)
  $fixnum.Int64 get createdAt => $_getI64(8);
  @$pb.TagNumber(9)
  set createdAt($fixnum.Int64 v) { $_setInt64(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasCreatedAt() => $_has(8);
  @$pb.TagNumber(9)
  void clearCreatedAt() => clearField(9);
}

class SearchUsersByUsernameResponse extends $pb.GeneratedMessage {
  factory SearchUsersByUsernameResponse({
    $core.Iterable<UserSearchResult>? users,
  }) {
    final $result = create();
    if (users != null) {
      $result.users.addAll(users);
    }
    return $result;
  }
  SearchUsersByUsernameResponse._() : super();
  factory SearchUsersByUsernameResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SearchUsersByUsernameResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SearchUsersByUsernameResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'tureon.v1'), createEmptyInstance: create)
    ..pc<UserSearchResult>(1, _omitFieldNames ? '' : 'users', $pb.PbFieldType.PM, subBuilder: UserSearchResult.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SearchUsersByUsernameResponse clone() => SearchUsersByUsernameResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SearchUsersByUsernameResponse copyWith(void Function(SearchUsersByUsernameResponse) updates) => super.copyWith((message) => updates(message as SearchUsersByUsernameResponse)) as SearchUsersByUsernameResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SearchUsersByUsernameResponse create() => SearchUsersByUsernameResponse._();
  SearchUsersByUsernameResponse createEmptyInstance() => create();
  static $pb.PbList<SearchUsersByUsernameResponse> createRepeated() => $pb.PbList<SearchUsersByUsernameResponse>();
  @$core.pragma('dart2js:noInline')
  static SearchUsersByUsernameResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SearchUsersByUsernameResponse>(create);
  static SearchUsersByUsernameResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<UserSearchResult> get users => $_getList(0);
}

class ProfilePrivacySetting extends $pb.GeneratedMessage {
  factory ProfilePrivacySetting({
    $core.String? field_1,
    $core.String? visibility,
  }) {
    final $result = create();
    if (field_1 != null) {
      $result.field_1 = field_1;
    }
    if (visibility != null) {
      $result.visibility = visibility;
    }
    return $result;
  }
  ProfilePrivacySetting._() : super();
  factory ProfilePrivacySetting.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ProfilePrivacySetting.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ProfilePrivacySetting', package: const $pb.PackageName(_omitMessageNames ? '' : 'tureon.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'field')
    ..aOS(2, _omitFieldNames ? '' : 'visibility')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ProfilePrivacySetting clone() => ProfilePrivacySetting()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ProfilePrivacySetting copyWith(void Function(ProfilePrivacySetting) updates) => super.copyWith((message) => updates(message as ProfilePrivacySetting)) as ProfilePrivacySetting;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ProfilePrivacySetting create() => ProfilePrivacySetting._();
  ProfilePrivacySetting createEmptyInstance() => create();
  static $pb.PbList<ProfilePrivacySetting> createRepeated() => $pb.PbList<ProfilePrivacySetting>();
  @$core.pragma('dart2js:noInline')
  static ProfilePrivacySetting getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ProfilePrivacySetting>(create);
  static ProfilePrivacySetting? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get field_1 => $_getSZ(0);
  @$pb.TagNumber(1)
  set field_1($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasField_1() => $_has(0);
  @$pb.TagNumber(1)
  void clearField_1() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get visibility => $_getSZ(1);
  @$pb.TagNumber(2)
  set visibility($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasVisibility() => $_has(1);
  @$pb.TagNumber(2)
  void clearVisibility() => clearField(2);
}

class GetProfileRequest extends $pb.GeneratedMessage {
  factory GetProfileRequest({
    $core.String? recipientId,
  }) {
    final $result = create();
    if (recipientId != null) {
      $result.recipientId = recipientId;
    }
    return $result;
  }
  GetProfileRequest._() : super();
  factory GetProfileRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetProfileRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetProfileRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'tureon.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'recipientId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetProfileRequest clone() => GetProfileRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetProfileRequest copyWith(void Function(GetProfileRequest) updates) => super.copyWith((message) => updates(message as GetProfileRequest)) as GetProfileRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetProfileRequest create() => GetProfileRequest._();
  GetProfileRequest createEmptyInstance() => create();
  static $pb.PbList<GetProfileRequest> createRepeated() => $pb.PbList<GetProfileRequest>();
  @$core.pragma('dart2js:noInline')
  static GetProfileRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetProfileRequest>(create);
  static GetProfileRequest? _defaultInstance;

  /// Empty means the authenticated user's own profile.
  @$pb.TagNumber(1)
  $core.String get recipientId => $_getSZ(0);
  @$pb.TagNumber(1)
  set recipientId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasRecipientId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRecipientId() => clearField(1);
}

class ProfileResponse extends $pb.GeneratedMessage {
  factory ProfileResponse({
    $core.String? recipientId,
    $core.String? username,
    $core.String? displayName,
    $core.String? bio,
    $core.String? phoneE164,
    $core.String? birthday,
    $core.String? avatarUrl,
    $core.Iterable<ProfilePrivacySetting>? privacySettings,
    $core.String? verificationBadge,
    $fixnum.Int64? profileVersion,
    $core.String? countryCode,
    $fixnum.Int64? createdAt,
  }) {
    final $result = create();
    if (recipientId != null) {
      $result.recipientId = recipientId;
    }
    if (username != null) {
      $result.username = username;
    }
    if (displayName != null) {
      $result.displayName = displayName;
    }
    if (bio != null) {
      $result.bio = bio;
    }
    if (phoneE164 != null) {
      $result.phoneE164 = phoneE164;
    }
    if (birthday != null) {
      $result.birthday = birthday;
    }
    if (avatarUrl != null) {
      $result.avatarUrl = avatarUrl;
    }
    if (privacySettings != null) {
      $result.privacySettings.addAll(privacySettings);
    }
    if (verificationBadge != null) {
      $result.verificationBadge = verificationBadge;
    }
    if (profileVersion != null) {
      $result.profileVersion = profileVersion;
    }
    if (countryCode != null) {
      $result.countryCode = countryCode;
    }
    if (createdAt != null) {
      $result.createdAt = createdAt;
    }
    return $result;
  }
  ProfileResponse._() : super();
  factory ProfileResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ProfileResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ProfileResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'tureon.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'recipientId')
    ..aOS(2, _omitFieldNames ? '' : 'username')
    ..aOS(3, _omitFieldNames ? '' : 'displayName')
    ..aOS(4, _omitFieldNames ? '' : 'bio')
    ..aOS(5, _omitFieldNames ? '' : 'phoneE164')
    ..aOS(6, _omitFieldNames ? '' : 'birthday')
    ..aOS(7, _omitFieldNames ? '' : 'avatarUrl')
    ..pc<ProfilePrivacySetting>(8, _omitFieldNames ? '' : 'privacySettings', $pb.PbFieldType.PM, subBuilder: ProfilePrivacySetting.create)
    ..aOS(9, _omitFieldNames ? '' : 'verificationBadge')
    ..aInt64(10, _omitFieldNames ? '' : 'profileVersion')
    ..aOS(11, _omitFieldNames ? '' : 'countryCode')
    ..aInt64(12, _omitFieldNames ? '' : 'createdAt')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ProfileResponse clone() => ProfileResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ProfileResponse copyWith(void Function(ProfileResponse) updates) => super.copyWith((message) => updates(message as ProfileResponse)) as ProfileResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ProfileResponse create() => ProfileResponse._();
  ProfileResponse createEmptyInstance() => create();
  static $pb.PbList<ProfileResponse> createRepeated() => $pb.PbList<ProfileResponse>();
  @$core.pragma('dart2js:noInline')
  static ProfileResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ProfileResponse>(create);
  static ProfileResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get recipientId => $_getSZ(0);
  @$pb.TagNumber(1)
  set recipientId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasRecipientId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRecipientId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get username => $_getSZ(1);
  @$pb.TagNumber(2)
  set username($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasUsername() => $_has(1);
  @$pb.TagNumber(2)
  void clearUsername() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get displayName => $_getSZ(2);
  @$pb.TagNumber(3)
  set displayName($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasDisplayName() => $_has(2);
  @$pb.TagNumber(3)
  void clearDisplayName() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get bio => $_getSZ(3);
  @$pb.TagNumber(4)
  set bio($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasBio() => $_has(3);
  @$pb.TagNumber(4)
  void clearBio() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get phoneE164 => $_getSZ(4);
  @$pb.TagNumber(5)
  set phoneE164($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasPhoneE164() => $_has(4);
  @$pb.TagNumber(5)
  void clearPhoneE164() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get birthday => $_getSZ(5);
  @$pb.TagNumber(6)
  set birthday($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasBirthday() => $_has(5);
  @$pb.TagNumber(6)
  void clearBirthday() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get avatarUrl => $_getSZ(6);
  @$pb.TagNumber(7)
  set avatarUrl($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasAvatarUrl() => $_has(6);
  @$pb.TagNumber(7)
  void clearAvatarUrl() => clearField(7);

  @$pb.TagNumber(8)
  $core.List<ProfilePrivacySetting> get privacySettings => $_getList(7);

  @$pb.TagNumber(9)
  $core.String get verificationBadge => $_getSZ(8);
  @$pb.TagNumber(9)
  set verificationBadge($core.String v) { $_setString(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasVerificationBadge() => $_has(8);
  @$pb.TagNumber(9)
  void clearVerificationBadge() => clearField(9);

  /// Monotonic privacy-safe cache version for this profile.
  @$pb.TagNumber(10)
  $fixnum.Int64 get profileVersion => $_getI64(9);
  @$pb.TagNumber(10)
  set profileVersion($fixnum.Int64 v) { $_setInt64(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasProfileVersion() => $_has(9);
  @$pb.TagNumber(10)
  void clearProfileVersion() => clearField(10);

  @$pb.TagNumber(11)
  $core.String get countryCode => $_getSZ(10);
  @$pb.TagNumber(11)
  set countryCode($core.String v) { $_setString(10, v); }
  @$pb.TagNumber(11)
  $core.bool hasCountryCode() => $_has(10);
  @$pb.TagNumber(11)
  void clearCountryCode() => clearField(11);

  @$pb.TagNumber(12)
  $fixnum.Int64 get createdAt => $_getI64(11);
  @$pb.TagNumber(12)
  set createdAt($fixnum.Int64 v) { $_setInt64(11, v); }
  @$pb.TagNumber(12)
  $core.bool hasCreatedAt() => $_has(11);
  @$pb.TagNumber(12)
  void clearCreatedAt() => clearField(12);
}

class UpdateProfileRequest extends $pb.GeneratedMessage {
  factory UpdateProfileRequest({
    $core.String? username,
    $core.String? displayName,
    $core.String? bio,
    $core.String? phoneE164,
    $core.String? birthday,
    $core.String? avatarUrl,
    $fixnum.Int64? expectedProfileVersion,
    $core.String? countryCode,
  }) {
    final $result = create();
    if (username != null) {
      $result.username = username;
    }
    if (displayName != null) {
      $result.displayName = displayName;
    }
    if (bio != null) {
      $result.bio = bio;
    }
    if (phoneE164 != null) {
      $result.phoneE164 = phoneE164;
    }
    if (birthday != null) {
      $result.birthday = birthday;
    }
    if (avatarUrl != null) {
      $result.avatarUrl = avatarUrl;
    }
    if (expectedProfileVersion != null) {
      $result.expectedProfileVersion = expectedProfileVersion;
    }
    if (countryCode != null) {
      $result.countryCode = countryCode;
    }
    return $result;
  }
  UpdateProfileRequest._() : super();
  factory UpdateProfileRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UpdateProfileRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UpdateProfileRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'tureon.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'username')
    ..aOS(2, _omitFieldNames ? '' : 'displayName')
    ..aOS(3, _omitFieldNames ? '' : 'bio')
    ..aOS(4, _omitFieldNames ? '' : 'phoneE164')
    ..aOS(5, _omitFieldNames ? '' : 'birthday')
    ..aOS(6, _omitFieldNames ? '' : 'avatarUrl')
    ..aInt64(7, _omitFieldNames ? '' : 'expectedProfileVersion')
    ..aOS(8, _omitFieldNames ? '' : 'countryCode')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UpdateProfileRequest clone() => UpdateProfileRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UpdateProfileRequest copyWith(void Function(UpdateProfileRequest) updates) => super.copyWith((message) => updates(message as UpdateProfileRequest)) as UpdateProfileRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateProfileRequest create() => UpdateProfileRequest._();
  UpdateProfileRequest createEmptyInstance() => create();
  static $pb.PbList<UpdateProfileRequest> createRepeated() => $pb.PbList<UpdateProfileRequest>();
  @$core.pragma('dart2js:noInline')
  static UpdateProfileRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UpdateProfileRequest>(create);
  static UpdateProfileRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get username => $_getSZ(0);
  @$pb.TagNumber(1)
  set username($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasUsername() => $_has(0);
  @$pb.TagNumber(1)
  void clearUsername() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get displayName => $_getSZ(1);
  @$pb.TagNumber(2)
  set displayName($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasDisplayName() => $_has(1);
  @$pb.TagNumber(2)
  void clearDisplayName() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get bio => $_getSZ(2);
  @$pb.TagNumber(3)
  set bio($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasBio() => $_has(2);
  @$pb.TagNumber(3)
  void clearBio() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get phoneE164 => $_getSZ(3);
  @$pb.TagNumber(4)
  set phoneE164($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasPhoneE164() => $_has(3);
  @$pb.TagNumber(4)
  void clearPhoneE164() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get birthday => $_getSZ(4);
  @$pb.TagNumber(5)
  set birthday($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasBirthday() => $_has(4);
  @$pb.TagNumber(5)
  void clearBirthday() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get avatarUrl => $_getSZ(5);
  @$pb.TagNumber(6)
  set avatarUrl($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasAvatarUrl() => $_has(5);
  @$pb.TagNumber(6)
  void clearAvatarUrl() => clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get expectedProfileVersion => $_getI64(6);
  @$pb.TagNumber(7)
  set expectedProfileVersion($fixnum.Int64 v) { $_setInt64(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasExpectedProfileVersion() => $_has(6);
  @$pb.TagNumber(7)
  void clearExpectedProfileVersion() => clearField(7);

  @$pb.TagNumber(8)
  $core.String get countryCode => $_getSZ(7);
  @$pb.TagNumber(8)
  set countryCode($core.String v) { $_setString(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasCountryCode() => $_has(7);
  @$pb.TagNumber(8)
  void clearCountryCode() => clearField(8);
}

class UpdatePrivacySettingRequest extends $pb.GeneratedMessage {
  factory UpdatePrivacySettingRequest({
    $core.String? field_1,
    $core.String? visibility,
  }) {
    final $result = create();
    if (field_1 != null) {
      $result.field_1 = field_1;
    }
    if (visibility != null) {
      $result.visibility = visibility;
    }
    return $result;
  }
  UpdatePrivacySettingRequest._() : super();
  factory UpdatePrivacySettingRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UpdatePrivacySettingRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UpdatePrivacySettingRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'tureon.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'field')
    ..aOS(2, _omitFieldNames ? '' : 'visibility')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UpdatePrivacySettingRequest clone() => UpdatePrivacySettingRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UpdatePrivacySettingRequest copyWith(void Function(UpdatePrivacySettingRequest) updates) => super.copyWith((message) => updates(message as UpdatePrivacySettingRequest)) as UpdatePrivacySettingRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdatePrivacySettingRequest create() => UpdatePrivacySettingRequest._();
  UpdatePrivacySettingRequest createEmptyInstance() => create();
  static $pb.PbList<UpdatePrivacySettingRequest> createRepeated() => $pb.PbList<UpdatePrivacySettingRequest>();
  @$core.pragma('dart2js:noInline')
  static UpdatePrivacySettingRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UpdatePrivacySettingRequest>(create);
  static UpdatePrivacySettingRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get field_1 => $_getSZ(0);
  @$pb.TagNumber(1)
  set field_1($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasField_1() => $_has(0);
  @$pb.TagNumber(1)
  void clearField_1() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get visibility => $_getSZ(1);
  @$pb.TagNumber(2)
  set visibility($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasVisibility() => $_has(1);
  @$pb.TagNumber(2)
  void clearVisibility() => clearField(2);
}

class ProfileChange extends $pb.GeneratedMessage {
  factory ProfileChange({
    $fixnum.Int64? profileVersion,
    $core.String? recipientId,
    $core.String? accountStatus,
    $core.String? verificationBadge,
  }) {
    final $result = create();
    if (profileVersion != null) {
      $result.profileVersion = profileVersion;
    }
    if (recipientId != null) {
      $result.recipientId = recipientId;
    }
    if (accountStatus != null) {
      $result.accountStatus = accountStatus;
    }
    if (verificationBadge != null) {
      $result.verificationBadge = verificationBadge;
    }
    return $result;
  }
  ProfileChange._() : super();
  factory ProfileChange.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ProfileChange.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ProfileChange', package: const $pb.PackageName(_omitMessageNames ? '' : 'tureon.v1'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'profileVersion')
    ..aOS(2, _omitFieldNames ? '' : 'recipientId')
    ..aOS(3, _omitFieldNames ? '' : 'accountStatus')
    ..aOS(4, _omitFieldNames ? '' : 'verificationBadge')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ProfileChange clone() => ProfileChange()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ProfileChange copyWith(void Function(ProfileChange) updates) => super.copyWith((message) => updates(message as ProfileChange)) as ProfileChange;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ProfileChange create() => ProfileChange._();
  ProfileChange createEmptyInstance() => create();
  static $pb.PbList<ProfileChange> createRepeated() => $pb.PbList<ProfileChange>();
  @$core.pragma('dart2js:noInline')
  static ProfileChange getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ProfileChange>(create);
  static ProfileChange? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get profileVersion => $_getI64(0);
  @$pb.TagNumber(1)
  set profileVersion($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasProfileVersion() => $_has(0);
  @$pb.TagNumber(1)
  void clearProfileVersion() => clearField(1);

  /// The profile changed for this recipient. Empty on the authenticated user's
  /// own legacy stream update, where the session already identifies the user.
  @$pb.TagNumber(2)
  $core.String get recipientId => $_getSZ(1);
  @$pb.TagNumber(2)
  set recipientId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasRecipientId() => $_has(1);
  @$pb.TagNumber(2)
  void clearRecipientId() => clearField(2);

  /// These fields are populated only for the authenticated user's own profile.
  @$pb.TagNumber(3)
  $core.String get accountStatus => $_getSZ(2);
  @$pb.TagNumber(3)
  set accountStatus($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasAccountStatus() => $_has(2);
  @$pb.TagNumber(3)
  void clearAccountStatus() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get verificationBadge => $_getSZ(3);
  @$pb.TagNumber(4)
  set verificationBadge($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasVerificationBadge() => $_has(3);
  @$pb.TagNumber(4)
  void clearVerificationBadge() => clearField(4);
}

class ProfileWatchCursor extends $pb.GeneratedMessage {
  factory ProfileWatchCursor({
    $core.String? recipientId,
    $fixnum.Int64? profileVersion,
    $core.String? verificationBadge,
  }) {
    final $result = create();
    if (recipientId != null) {
      $result.recipientId = recipientId;
    }
    if (profileVersion != null) {
      $result.profileVersion = profileVersion;
    }
    if (verificationBadge != null) {
      $result.verificationBadge = verificationBadge;
    }
    return $result;
  }
  ProfileWatchCursor._() : super();
  factory ProfileWatchCursor.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ProfileWatchCursor.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ProfileWatchCursor', package: const $pb.PackageName(_omitMessageNames ? '' : 'tureon.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'recipientId')
    ..aInt64(2, _omitFieldNames ? '' : 'profileVersion')
    ..aOS(3, _omitFieldNames ? '' : 'verificationBadge')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ProfileWatchCursor clone() => ProfileWatchCursor()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ProfileWatchCursor copyWith(void Function(ProfileWatchCursor) updates) => super.copyWith((message) => updates(message as ProfileWatchCursor)) as ProfileWatchCursor;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ProfileWatchCursor create() => ProfileWatchCursor._();
  ProfileWatchCursor createEmptyInstance() => create();
  static $pb.PbList<ProfileWatchCursor> createRepeated() => $pb.PbList<ProfileWatchCursor>();
  @$core.pragma('dart2js:noInline')
  static ProfileWatchCursor getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ProfileWatchCursor>(create);
  static ProfileWatchCursor? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get recipientId => $_getSZ(0);
  @$pb.TagNumber(1)
  set recipientId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasRecipientId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRecipientId() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get profileVersion => $_getI64(1);
  @$pb.TagNumber(2)
  set profileVersion($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasProfileVersion() => $_has(1);
  @$pb.TagNumber(2)
  void clearProfileVersion() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get verificationBadge => $_getSZ(2);
  @$pb.TagNumber(3)
  set verificationBadge($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasVerificationBadge() => $_has(2);
  @$pb.TagNumber(3)
  void clearVerificationBadge() => clearField(3);
}

class ProfileWatchRequest extends $pb.GeneratedMessage {
  factory ProfileWatchRequest({
    $core.Iterable<ProfileWatchCursor>? cursors,
  }) {
    final $result = create();
    if (cursors != null) {
      $result.cursors.addAll(cursors);
    }
    return $result;
  }
  ProfileWatchRequest._() : super();
  factory ProfileWatchRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ProfileWatchRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ProfileWatchRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'tureon.v1'), createEmptyInstance: create)
    ..pc<ProfileWatchCursor>(1, _omitFieldNames ? '' : 'cursors', $pb.PbFieldType.PM, subBuilder: ProfileWatchCursor.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ProfileWatchRequest clone() => ProfileWatchRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ProfileWatchRequest copyWith(void Function(ProfileWatchRequest) updates) => super.copyWith((message) => updates(message as ProfileWatchRequest)) as ProfileWatchRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ProfileWatchRequest create() => ProfileWatchRequest._();
  ProfileWatchRequest createEmptyInstance() => create();
  static $pb.PbList<ProfileWatchRequest> createRepeated() => $pb.PbList<ProfileWatchRequest>();
  @$core.pragma('dart2js:noInline')
  static ProfileWatchRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ProfileWatchRequest>(create);
  static ProfileWatchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<ProfileWatchCursor> get cursors => $_getList(0);
}

class MembershipChange extends $pb.GeneratedMessage {
  factory MembershipChange({
    $core.String? resourceId,
    $core.String? resourceType,
  }) {
    final $result = create();
    if (resourceId != null) {
      $result.resourceId = resourceId;
    }
    if (resourceType != null) {
      $result.resourceType = resourceType;
    }
    return $result;
  }
  MembershipChange._() : super();
  factory MembershipChange.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MembershipChange.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MembershipChange', package: const $pb.PackageName(_omitMessageNames ? '' : 'tureon.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'resourceId')
    ..aOS(2, _omitFieldNames ? '' : 'resourceType')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MembershipChange clone() => MembershipChange()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MembershipChange copyWith(void Function(MembershipChange) updates) => super.copyWith((message) => updates(message as MembershipChange)) as MembershipChange;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MembershipChange create() => MembershipChange._();
  MembershipChange createEmptyInstance() => create();
  static $pb.PbList<MembershipChange> createRepeated() => $pb.PbList<MembershipChange>();
  @$core.pragma('dart2js:noInline')
  static MembershipChange getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MembershipChange>(create);
  static MembershipChange? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get resourceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set resourceId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasResourceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearResourceId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get resourceType => $_getSZ(1);
  @$pb.TagNumber(2)
  set resourceType($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasResourceType() => $_has(1);
  @$pb.TagNumber(2)
  void clearResourceType() => clearField(2);
}

class ServerHealthResponse extends $pb.GeneratedMessage {
  factory ServerHealthResponse({
    $core.bool? serving,
  }) {
    final $result = create();
    if (serving != null) {
      $result.serving = serving;
    }
    return $result;
  }
  ServerHealthResponse._() : super();
  factory ServerHealthResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ServerHealthResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ServerHealthResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'tureon.v1'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'serving')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ServerHealthResponse clone() => ServerHealthResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ServerHealthResponse copyWith(void Function(ServerHealthResponse) updates) => super.copyWith((message) => updates(message as ServerHealthResponse)) as ServerHealthResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ServerHealthResponse create() => ServerHealthResponse._();
  ServerHealthResponse createEmptyInstance() => create();
  static $pb.PbList<ServerHealthResponse> createRepeated() => $pb.PbList<ServerHealthResponse>();
  @$core.pragma('dart2js:noInline')
  static ServerHealthResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ServerHealthResponse>(create);
  static ServerHealthResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get serving => $_getBF(0);
  @$pb.TagNumber(1)
  set serving($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasServing() => $_has(0);
  @$pb.TagNumber(1)
  void clearServing() => clearField(1);
}

class CreateGroupRequest extends $pb.GeneratedMessage {
  factory CreateGroupRequest({
    $core.String? name,
    $core.String? description,
    $core.String? avatarUrl,
    $core.String? visibility,
  }) {
    final $result = create();
    if (name != null) {
      $result.name = name;
    }
    if (description != null) {
      $result.description = description;
    }
    if (avatarUrl != null) {
      $result.avatarUrl = avatarUrl;
    }
    if (visibility != null) {
      $result.visibility = visibility;
    }
    return $result;
  }
  CreateGroupRequest._() : super();
  factory CreateGroupRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateGroupRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateGroupRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'tureon.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOS(2, _omitFieldNames ? '' : 'description')
    ..aOS(3, _omitFieldNames ? '' : 'avatarUrl')
    ..aOS(4, _omitFieldNames ? '' : 'visibility')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreateGroupRequest clone() => CreateGroupRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreateGroupRequest copyWith(void Function(CreateGroupRequest) updates) => super.copyWith((message) => updates(message as CreateGroupRequest)) as CreateGroupRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateGroupRequest create() => CreateGroupRequest._();
  CreateGroupRequest createEmptyInstance() => create();
  static $pb.PbList<CreateGroupRequest> createRepeated() => $pb.PbList<CreateGroupRequest>();
  @$core.pragma('dart2js:noInline')
  static CreateGroupRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateGroupRequest>(create);
  static CreateGroupRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get description => $_getSZ(1);
  @$pb.TagNumber(2)
  set description($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasDescription() => $_has(1);
  @$pb.TagNumber(2)
  void clearDescription() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get avatarUrl => $_getSZ(2);
  @$pb.TagNumber(3)
  set avatarUrl($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasAvatarUrl() => $_has(2);
  @$pb.TagNumber(3)
  void clearAvatarUrl() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get visibility => $_getSZ(3);
  @$pb.TagNumber(4)
  set visibility($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasVisibility() => $_has(3);
  @$pb.TagNumber(4)
  void clearVisibility() => clearField(4);
}

class CreateGroupResponse extends $pb.GeneratedMessage {
  factory CreateGroupResponse({
    GroupChannel? group,
  }) {
    final $result = create();
    if (group != null) {
      $result.group = group;
    }
    return $result;
  }
  CreateGroupResponse._() : super();
  factory CreateGroupResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateGroupResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateGroupResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'tureon.v1'), createEmptyInstance: create)
    ..aOM<GroupChannel>(1, _omitFieldNames ? '' : 'group', subBuilder: GroupChannel.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreateGroupResponse clone() => CreateGroupResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreateGroupResponse copyWith(void Function(CreateGroupResponse) updates) => super.copyWith((message) => updates(message as CreateGroupResponse)) as CreateGroupResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateGroupResponse create() => CreateGroupResponse._();
  CreateGroupResponse createEmptyInstance() => create();
  static $pb.PbList<CreateGroupResponse> createRepeated() => $pb.PbList<CreateGroupResponse>();
  @$core.pragma('dart2js:noInline')
  static CreateGroupResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateGroupResponse>(create);
  static CreateGroupResponse? _defaultInstance;

  @$pb.TagNumber(1)
  GroupChannel get group => $_getN(0);
  @$pb.TagNumber(1)
  set group(GroupChannel v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasGroup() => $_has(0);
  @$pb.TagNumber(1)
  void clearGroup() => clearField(1);
  @$pb.TagNumber(1)
  GroupChannel ensureGroup() => $_ensure(0);
}

class GroupChannel extends $pb.GeneratedMessage {
  factory GroupChannel({
    $core.String? id,
    $core.String? type,
    $core.String? name,
    $core.String? description,
    $core.String? avatarUrl,
    $core.String? visibility,
    $core.String? ownerUserId,
    $fixnum.Int64? createdAt,
    $core.String? memberRole,
    $core.bool? membersCanSendMessages,
    $fixnum.Int64? memberCount,
    $core.bool? isOfficial,
    $core.String? username,
    $core.bool? membersCanSendMedia,
    $core.bool? membersCanSendStickersGifs,
    $core.bool? membersCanEmbedLinks,
    $core.bool? membersCanAddMembers,
    $core.bool? membersCanChangeInfo,
    $core.bool? membersCanReact,
    $core.bool? membersCanForward,
    $core.int? slowModeSeconds,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (type != null) {
      $result.type = type;
    }
    if (name != null) {
      $result.name = name;
    }
    if (description != null) {
      $result.description = description;
    }
    if (avatarUrl != null) {
      $result.avatarUrl = avatarUrl;
    }
    if (visibility != null) {
      $result.visibility = visibility;
    }
    if (ownerUserId != null) {
      $result.ownerUserId = ownerUserId;
    }
    if (createdAt != null) {
      $result.createdAt = createdAt;
    }
    if (memberRole != null) {
      $result.memberRole = memberRole;
    }
    if (membersCanSendMessages != null) {
      $result.membersCanSendMessages = membersCanSendMessages;
    }
    if (memberCount != null) {
      $result.memberCount = memberCount;
    }
    if (isOfficial != null) {
      $result.isOfficial = isOfficial;
    }
    if (username != null) {
      $result.username = username;
    }
    if (membersCanSendMedia != null) {
      $result.membersCanSendMedia = membersCanSendMedia;
    }
    if (membersCanSendStickersGifs != null) {
      $result.membersCanSendStickersGifs = membersCanSendStickersGifs;
    }
    if (membersCanEmbedLinks != null) {
      $result.membersCanEmbedLinks = membersCanEmbedLinks;
    }
    if (membersCanAddMembers != null) {
      $result.membersCanAddMembers = membersCanAddMembers;
    }
    if (membersCanChangeInfo != null) {
      $result.membersCanChangeInfo = membersCanChangeInfo;
    }
    if (membersCanReact != null) {
      $result.membersCanReact = membersCanReact;
    }
    if (membersCanForward != null) {
      $result.membersCanForward = membersCanForward;
    }
    if (slowModeSeconds != null) {
      $result.slowModeSeconds = slowModeSeconds;
    }
    return $result;
  }
  GroupChannel._() : super();
  factory GroupChannel.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GroupChannel.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GroupChannel', package: const $pb.PackageName(_omitMessageNames ? '' : 'tureon.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'type')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..aOS(4, _omitFieldNames ? '' : 'description')
    ..aOS(5, _omitFieldNames ? '' : 'avatarUrl')
    ..aOS(6, _omitFieldNames ? '' : 'visibility')
    ..aOS(7, _omitFieldNames ? '' : 'ownerUserId')
    ..aInt64(8, _omitFieldNames ? '' : 'createdAt')
    ..aOS(9, _omitFieldNames ? '' : 'memberRole')
    ..aOB(10, _omitFieldNames ? '' : 'membersCanSendMessages')
    ..aInt64(11, _omitFieldNames ? '' : 'memberCount')
    ..aOB(12, _omitFieldNames ? '' : 'isOfficial')
    ..aOS(13, _omitFieldNames ? '' : 'username')
    ..aOB(14, _omitFieldNames ? '' : 'membersCanSendMedia')
    ..aOB(15, _omitFieldNames ? '' : 'membersCanSendStickersGifs')
    ..aOB(16, _omitFieldNames ? '' : 'membersCanEmbedLinks')
    ..aOB(17, _omitFieldNames ? '' : 'membersCanAddMembers')
    ..aOB(18, _omitFieldNames ? '' : 'membersCanChangeInfo')
    ..aOB(19, _omitFieldNames ? '' : 'membersCanReact')
    ..aOB(20, _omitFieldNames ? '' : 'membersCanForward')
    ..a<$core.int>(21, _omitFieldNames ? '' : 'slowModeSeconds', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GroupChannel clone() => GroupChannel()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GroupChannel copyWith(void Function(GroupChannel) updates) => super.copyWith((message) => updates(message as GroupChannel)) as GroupChannel;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GroupChannel create() => GroupChannel._();
  GroupChannel createEmptyInstance() => create();
  static $pb.PbList<GroupChannel> createRepeated() => $pb.PbList<GroupChannel>();
  @$core.pragma('dart2js:noInline')
  static GroupChannel getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GroupChannel>(create);
  static GroupChannel? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get type => $_getSZ(1);
  @$pb.TagNumber(2)
  set type($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasType() => $_has(1);
  @$pb.TagNumber(2)
  void clearType() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get name => $_getSZ(2);
  @$pb.TagNumber(3)
  set name($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasName() => $_has(2);
  @$pb.TagNumber(3)
  void clearName() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get description => $_getSZ(3);
  @$pb.TagNumber(4)
  set description($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasDescription() => $_has(3);
  @$pb.TagNumber(4)
  void clearDescription() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get avatarUrl => $_getSZ(4);
  @$pb.TagNumber(5)
  set avatarUrl($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasAvatarUrl() => $_has(4);
  @$pb.TagNumber(5)
  void clearAvatarUrl() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get visibility => $_getSZ(5);
  @$pb.TagNumber(6)
  set visibility($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasVisibility() => $_has(5);
  @$pb.TagNumber(6)
  void clearVisibility() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get ownerUserId => $_getSZ(6);
  @$pb.TagNumber(7)
  set ownerUserId($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasOwnerUserId() => $_has(6);
  @$pb.TagNumber(7)
  void clearOwnerUserId() => clearField(7);

  @$pb.TagNumber(8)
  $fixnum.Int64 get createdAt => $_getI64(7);
  @$pb.TagNumber(8)
  set createdAt($fixnum.Int64 v) { $_setInt64(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasCreatedAt() => $_has(7);
  @$pb.TagNumber(8)
  void clearCreatedAt() => clearField(8);

  @$pb.TagNumber(9)
  $core.String get memberRole => $_getSZ(8);
  @$pb.TagNumber(9)
  set memberRole($core.String v) { $_setString(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasMemberRole() => $_has(8);
  @$pb.TagNumber(9)
  void clearMemberRole() => clearField(9);

  @$pb.TagNumber(10)
  $core.bool get membersCanSendMessages => $_getBF(9);
  @$pb.TagNumber(10)
  set membersCanSendMessages($core.bool v) { $_setBool(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasMembersCanSendMessages() => $_has(9);
  @$pb.TagNumber(10)
  void clearMembersCanSendMessages() => clearField(10);

  @$pb.TagNumber(11)
  $fixnum.Int64 get memberCount => $_getI64(10);
  @$pb.TagNumber(11)
  set memberCount($fixnum.Int64 v) { $_setInt64(10, v); }
  @$pb.TagNumber(11)
  $core.bool hasMemberCount() => $_has(10);
  @$pb.TagNumber(11)
  void clearMemberCount() => clearField(11);

  @$pb.TagNumber(12)
  $core.bool get isOfficial => $_getBF(11);
  @$pb.TagNumber(12)
  set isOfficial($core.bool v) { $_setBool(11, v); }
  @$pb.TagNumber(12)
  $core.bool hasIsOfficial() => $_has(11);
  @$pb.TagNumber(12)
  void clearIsOfficial() => clearField(12);

  /// Public handle for sharing a group or channel, unique across recipients.
  @$pb.TagNumber(13)
  $core.String get username => $_getSZ(12);
  @$pb.TagNumber(13)
  set username($core.String v) { $_setString(12, v); }
  @$pb.TagNumber(13)
  $core.bool hasUsername() => $_has(12);
  @$pb.TagNumber(13)
  void clearUsername() => clearField(13);

  @$pb.TagNumber(14)
  $core.bool get membersCanSendMedia => $_getBF(13);
  @$pb.TagNumber(14)
  set membersCanSendMedia($core.bool v) { $_setBool(13, v); }
  @$pb.TagNumber(14)
  $core.bool hasMembersCanSendMedia() => $_has(13);
  @$pb.TagNumber(14)
  void clearMembersCanSendMedia() => clearField(14);

  @$pb.TagNumber(15)
  $core.bool get membersCanSendStickersGifs => $_getBF(14);
  @$pb.TagNumber(15)
  set membersCanSendStickersGifs($core.bool v) { $_setBool(14, v); }
  @$pb.TagNumber(15)
  $core.bool hasMembersCanSendStickersGifs() => $_has(14);
  @$pb.TagNumber(15)
  void clearMembersCanSendStickersGifs() => clearField(15);

  @$pb.TagNumber(16)
  $core.bool get membersCanEmbedLinks => $_getBF(15);
  @$pb.TagNumber(16)
  set membersCanEmbedLinks($core.bool v) { $_setBool(15, v); }
  @$pb.TagNumber(16)
  $core.bool hasMembersCanEmbedLinks() => $_has(15);
  @$pb.TagNumber(16)
  void clearMembersCanEmbedLinks() => clearField(16);

  @$pb.TagNumber(17)
  $core.bool get membersCanAddMembers => $_getBF(16);
  @$pb.TagNumber(17)
  set membersCanAddMembers($core.bool v) { $_setBool(16, v); }
  @$pb.TagNumber(17)
  $core.bool hasMembersCanAddMembers() => $_has(16);
  @$pb.TagNumber(17)
  void clearMembersCanAddMembers() => clearField(17);

  @$pb.TagNumber(18)
  $core.bool get membersCanChangeInfo => $_getBF(17);
  @$pb.TagNumber(18)
  set membersCanChangeInfo($core.bool v) { $_setBool(17, v); }
  @$pb.TagNumber(18)
  $core.bool hasMembersCanChangeInfo() => $_has(17);
  @$pb.TagNumber(18)
  void clearMembersCanChangeInfo() => clearField(18);

  @$pb.TagNumber(19)
  $core.bool get membersCanReact => $_getBF(18);
  @$pb.TagNumber(19)
  set membersCanReact($core.bool v) { $_setBool(18, v); }
  @$pb.TagNumber(19)
  $core.bool hasMembersCanReact() => $_has(18);
  @$pb.TagNumber(19)
  void clearMembersCanReact() => clearField(19);

  @$pb.TagNumber(20)
  $core.bool get membersCanForward => $_getBF(19);
  @$pb.TagNumber(20)
  set membersCanForward($core.bool v) { $_setBool(19, v); }
  @$pb.TagNumber(20)
  $core.bool hasMembersCanForward() => $_has(19);
  @$pb.TagNumber(20)
  void clearMembersCanForward() => clearField(20);

  /// Minimum time in seconds between regular members' messages in a group.
  /// Zero disables slow mode. Owners and admins are exempt.
  @$pb.TagNumber(21)
  $core.int get slowModeSeconds => $_getIZ(20);
  @$pb.TagNumber(21)
  set slowModeSeconds($core.int v) { $_setSignedInt32(20, v); }
  @$pb.TagNumber(21)
  $core.bool hasSlowModeSeconds() => $_has(20);
  @$pb.TagNumber(21)
  void clearSlowModeSeconds() => clearField(21);
}

class UpdateGroupChannelSendPermissionRequest extends $pb.GeneratedMessage {
  factory UpdateGroupChannelSendPermissionRequest({
    $core.String? groupChannelId,
    $core.bool? membersCanSendMessages,
  }) {
    final $result = create();
    if (groupChannelId != null) {
      $result.groupChannelId = groupChannelId;
    }
    if (membersCanSendMessages != null) {
      $result.membersCanSendMessages = membersCanSendMessages;
    }
    return $result;
  }
  UpdateGroupChannelSendPermissionRequest._() : super();
  factory UpdateGroupChannelSendPermissionRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UpdateGroupChannelSendPermissionRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UpdateGroupChannelSendPermissionRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'tureon.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'groupChannelId')
    ..aOB(2, _omitFieldNames ? '' : 'membersCanSendMessages')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UpdateGroupChannelSendPermissionRequest clone() => UpdateGroupChannelSendPermissionRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UpdateGroupChannelSendPermissionRequest copyWith(void Function(UpdateGroupChannelSendPermissionRequest) updates) => super.copyWith((message) => updates(message as UpdateGroupChannelSendPermissionRequest)) as UpdateGroupChannelSendPermissionRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateGroupChannelSendPermissionRequest create() => UpdateGroupChannelSendPermissionRequest._();
  UpdateGroupChannelSendPermissionRequest createEmptyInstance() => create();
  static $pb.PbList<UpdateGroupChannelSendPermissionRequest> createRepeated() => $pb.PbList<UpdateGroupChannelSendPermissionRequest>();
  @$core.pragma('dart2js:noInline')
  static UpdateGroupChannelSendPermissionRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UpdateGroupChannelSendPermissionRequest>(create);
  static UpdateGroupChannelSendPermissionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get groupChannelId => $_getSZ(0);
  @$pb.TagNumber(1)
  set groupChannelId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasGroupChannelId() => $_has(0);
  @$pb.TagNumber(1)
  void clearGroupChannelId() => clearField(1);

  @$pb.TagNumber(2)
  $core.bool get membersCanSendMessages => $_getBF(1);
  @$pb.TagNumber(2)
  set membersCanSendMessages($core.bool v) { $_setBool(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMembersCanSendMessages() => $_has(1);
  @$pb.TagNumber(2)
  void clearMembersCanSendMessages() => clearField(2);
}

class UpdateGroupChannelSendPermissionResponse extends $pb.GeneratedMessage {
  factory UpdateGroupChannelSendPermissionResponse({
    $core.bool? membersCanSendMessages,
  }) {
    final $result = create();
    if (membersCanSendMessages != null) {
      $result.membersCanSendMessages = membersCanSendMessages;
    }
    return $result;
  }
  UpdateGroupChannelSendPermissionResponse._() : super();
  factory UpdateGroupChannelSendPermissionResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UpdateGroupChannelSendPermissionResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UpdateGroupChannelSendPermissionResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'tureon.v1'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'membersCanSendMessages')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UpdateGroupChannelSendPermissionResponse clone() => UpdateGroupChannelSendPermissionResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UpdateGroupChannelSendPermissionResponse copyWith(void Function(UpdateGroupChannelSendPermissionResponse) updates) => super.copyWith((message) => updates(message as UpdateGroupChannelSendPermissionResponse)) as UpdateGroupChannelSendPermissionResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateGroupChannelSendPermissionResponse create() => UpdateGroupChannelSendPermissionResponse._();
  UpdateGroupChannelSendPermissionResponse createEmptyInstance() => create();
  static $pb.PbList<UpdateGroupChannelSendPermissionResponse> createRepeated() => $pb.PbList<UpdateGroupChannelSendPermissionResponse>();
  @$core.pragma('dart2js:noInline')
  static UpdateGroupChannelSendPermissionResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UpdateGroupChannelSendPermissionResponse>(create);
  static UpdateGroupChannelSendPermissionResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get membersCanSendMessages => $_getBF(0);
  @$pb.TagNumber(1)
  set membersCanSendMessages($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasMembersCanSendMessages() => $_has(0);
  @$pb.TagNumber(1)
  void clearMembersCanSendMessages() => clearField(1);
}

class UpdateGroupChannelRequest extends $pb.GeneratedMessage {
  factory UpdateGroupChannelRequest({
    $core.String? groupChannelId,
    $core.String? name,
    $core.String? description,
    $core.String? avatarUrl,
    $core.String? visibility,
    $1.FieldMask? updateMask,
    $core.String? username,
  }) {
    final $result = create();
    if (groupChannelId != null) {
      $result.groupChannelId = groupChannelId;
    }
    if (name != null) {
      $result.name = name;
    }
    if (description != null) {
      $result.description = description;
    }
    if (avatarUrl != null) {
      $result.avatarUrl = avatarUrl;
    }
    if (visibility != null) {
      $result.visibility = visibility;
    }
    if (updateMask != null) {
      $result.updateMask = updateMask;
    }
    if (username != null) {
      $result.username = username;
    }
    return $result;
  }
  UpdateGroupChannelRequest._() : super();
  factory UpdateGroupChannelRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UpdateGroupChannelRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UpdateGroupChannelRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'tureon.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'groupChannelId')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'description')
    ..aOS(4, _omitFieldNames ? '' : 'avatarUrl')
    ..aOS(5, _omitFieldNames ? '' : 'visibility')
    ..aOM<$1.FieldMask>(6, _omitFieldNames ? '' : 'updateMask', subBuilder: $1.FieldMask.create)
    ..aOS(7, _omitFieldNames ? '' : 'username')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UpdateGroupChannelRequest clone() => UpdateGroupChannelRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UpdateGroupChannelRequest copyWith(void Function(UpdateGroupChannelRequest) updates) => super.copyWith((message) => updates(message as UpdateGroupChannelRequest)) as UpdateGroupChannelRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateGroupChannelRequest create() => UpdateGroupChannelRequest._();
  UpdateGroupChannelRequest createEmptyInstance() => create();
  static $pb.PbList<UpdateGroupChannelRequest> createRepeated() => $pb.PbList<UpdateGroupChannelRequest>();
  @$core.pragma('dart2js:noInline')
  static UpdateGroupChannelRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UpdateGroupChannelRequest>(create);
  static UpdateGroupChannelRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get groupChannelId => $_getSZ(0);
  @$pb.TagNumber(1)
  set groupChannelId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasGroupChannelId() => $_has(0);
  @$pb.TagNumber(1)
  void clearGroupChannelId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get description => $_getSZ(2);
  @$pb.TagNumber(3)
  set description($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasDescription() => $_has(2);
  @$pb.TagNumber(3)
  void clearDescription() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get avatarUrl => $_getSZ(3);
  @$pb.TagNumber(4)
  set avatarUrl($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasAvatarUrl() => $_has(3);
  @$pb.TagNumber(4)
  void clearAvatarUrl() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get visibility => $_getSZ(4);
  @$pb.TagNumber(5)
  set visibility($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasVisibility() => $_has(4);
  @$pb.TagNumber(5)
  void clearVisibility() => clearField(5);

  @$pb.TagNumber(6)
  $1.FieldMask get updateMask => $_getN(5);
  @$pb.TagNumber(6)
  set updateMask($1.FieldMask v) { setField(6, v); }
  @$pb.TagNumber(6)
  $core.bool hasUpdateMask() => $_has(5);
  @$pb.TagNumber(6)
  void clearUpdateMask() => clearField(6);
  @$pb.TagNumber(6)
  $1.FieldMask ensureUpdateMask() => $_ensure(5);

  @$pb.TagNumber(7)
  $core.String get username => $_getSZ(6);
  @$pb.TagNumber(7)
  set username($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasUsername() => $_has(6);
  @$pb.TagNumber(7)
  void clearUsername() => clearField(7);
}

class UpdateGroupChannelPermissionsRequest extends $pb.GeneratedMessage {
  factory UpdateGroupChannelPermissionsRequest({
    $core.String? groupChannelId,
    $core.bool? membersCanSendMessages,
    $core.bool? membersCanSendMedia,
    $core.bool? membersCanSendStickersGifs,
    $core.bool? membersCanEmbedLinks,
    $core.bool? membersCanAddMembers,
    $core.bool? membersCanChangeInfo,
    $core.bool? membersCanReact,
    $core.bool? membersCanForward,
    $core.int? slowModeSeconds,
  }) {
    final $result = create();
    if (groupChannelId != null) {
      $result.groupChannelId = groupChannelId;
    }
    if (membersCanSendMessages != null) {
      $result.membersCanSendMessages = membersCanSendMessages;
    }
    if (membersCanSendMedia != null) {
      $result.membersCanSendMedia = membersCanSendMedia;
    }
    if (membersCanSendStickersGifs != null) {
      $result.membersCanSendStickersGifs = membersCanSendStickersGifs;
    }
    if (membersCanEmbedLinks != null) {
      $result.membersCanEmbedLinks = membersCanEmbedLinks;
    }
    if (membersCanAddMembers != null) {
      $result.membersCanAddMembers = membersCanAddMembers;
    }
    if (membersCanChangeInfo != null) {
      $result.membersCanChangeInfo = membersCanChangeInfo;
    }
    if (membersCanReact != null) {
      $result.membersCanReact = membersCanReact;
    }
    if (membersCanForward != null) {
      $result.membersCanForward = membersCanForward;
    }
    if (slowModeSeconds != null) {
      $result.slowModeSeconds = slowModeSeconds;
    }
    return $result;
  }
  UpdateGroupChannelPermissionsRequest._() : super();
  factory UpdateGroupChannelPermissionsRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UpdateGroupChannelPermissionsRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UpdateGroupChannelPermissionsRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'tureon.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'groupChannelId')
    ..aOB(2, _omitFieldNames ? '' : 'membersCanSendMessages')
    ..aOB(3, _omitFieldNames ? '' : 'membersCanSendMedia')
    ..aOB(4, _omitFieldNames ? '' : 'membersCanSendStickersGifs')
    ..aOB(5, _omitFieldNames ? '' : 'membersCanEmbedLinks')
    ..aOB(6, _omitFieldNames ? '' : 'membersCanAddMembers')
    ..aOB(7, _omitFieldNames ? '' : 'membersCanChangeInfo')
    ..aOB(8, _omitFieldNames ? '' : 'membersCanReact')
    ..aOB(9, _omitFieldNames ? '' : 'membersCanForward')
    ..a<$core.int>(10, _omitFieldNames ? '' : 'slowModeSeconds', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UpdateGroupChannelPermissionsRequest clone() => UpdateGroupChannelPermissionsRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UpdateGroupChannelPermissionsRequest copyWith(void Function(UpdateGroupChannelPermissionsRequest) updates) => super.copyWith((message) => updates(message as UpdateGroupChannelPermissionsRequest)) as UpdateGroupChannelPermissionsRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateGroupChannelPermissionsRequest create() => UpdateGroupChannelPermissionsRequest._();
  UpdateGroupChannelPermissionsRequest createEmptyInstance() => create();
  static $pb.PbList<UpdateGroupChannelPermissionsRequest> createRepeated() => $pb.PbList<UpdateGroupChannelPermissionsRequest>();
  @$core.pragma('dart2js:noInline')
  static UpdateGroupChannelPermissionsRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UpdateGroupChannelPermissionsRequest>(create);
  static UpdateGroupChannelPermissionsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get groupChannelId => $_getSZ(0);
  @$pb.TagNumber(1)
  set groupChannelId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasGroupChannelId() => $_has(0);
  @$pb.TagNumber(1)
  void clearGroupChannelId() => clearField(1);

  @$pb.TagNumber(2)
  $core.bool get membersCanSendMessages => $_getBF(1);
  @$pb.TagNumber(2)
  set membersCanSendMessages($core.bool v) { $_setBool(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMembersCanSendMessages() => $_has(1);
  @$pb.TagNumber(2)
  void clearMembersCanSendMessages() => clearField(2);

  @$pb.TagNumber(3)
  $core.bool get membersCanSendMedia => $_getBF(2);
  @$pb.TagNumber(3)
  set membersCanSendMedia($core.bool v) { $_setBool(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasMembersCanSendMedia() => $_has(2);
  @$pb.TagNumber(3)
  void clearMembersCanSendMedia() => clearField(3);

  @$pb.TagNumber(4)
  $core.bool get membersCanSendStickersGifs => $_getBF(3);
  @$pb.TagNumber(4)
  set membersCanSendStickersGifs($core.bool v) { $_setBool(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasMembersCanSendStickersGifs() => $_has(3);
  @$pb.TagNumber(4)
  void clearMembersCanSendStickersGifs() => clearField(4);

  @$pb.TagNumber(5)
  $core.bool get membersCanEmbedLinks => $_getBF(4);
  @$pb.TagNumber(5)
  set membersCanEmbedLinks($core.bool v) { $_setBool(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasMembersCanEmbedLinks() => $_has(4);
  @$pb.TagNumber(5)
  void clearMembersCanEmbedLinks() => clearField(5);

  @$pb.TagNumber(6)
  $core.bool get membersCanAddMembers => $_getBF(5);
  @$pb.TagNumber(6)
  set membersCanAddMembers($core.bool v) { $_setBool(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasMembersCanAddMembers() => $_has(5);
  @$pb.TagNumber(6)
  void clearMembersCanAddMembers() => clearField(6);

  @$pb.TagNumber(7)
  $core.bool get membersCanChangeInfo => $_getBF(6);
  @$pb.TagNumber(7)
  set membersCanChangeInfo($core.bool v) { $_setBool(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasMembersCanChangeInfo() => $_has(6);
  @$pb.TagNumber(7)
  void clearMembersCanChangeInfo() => clearField(7);

  @$pb.TagNumber(8)
  $core.bool get membersCanReact => $_getBF(7);
  @$pb.TagNumber(8)
  set membersCanReact($core.bool v) { $_setBool(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasMembersCanReact() => $_has(7);
  @$pb.TagNumber(8)
  void clearMembersCanReact() => clearField(8);

  @$pb.TagNumber(9)
  $core.bool get membersCanForward => $_getBF(8);
  @$pb.TagNumber(9)
  set membersCanForward($core.bool v) { $_setBool(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasMembersCanForward() => $_has(8);
  @$pb.TagNumber(9)
  void clearMembersCanForward() => clearField(9);

  /// Applies to groups and channels. Zero disables slow mode.
  @$pb.TagNumber(10)
  $core.int get slowModeSeconds => $_getIZ(9);
  @$pb.TagNumber(10)
  set slowModeSeconds($core.int v) { $_setSignedInt32(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasSlowModeSeconds() => $_has(9);
  @$pb.TagNumber(10)
  void clearSlowModeSeconds() => clearField(10);
}

class GetGroupChannelRequest extends $pb.GeneratedMessage {
  factory GetGroupChannelRequest({
    $core.String? groupChannelId,
  }) {
    final $result = create();
    if (groupChannelId != null) {
      $result.groupChannelId = groupChannelId;
    }
    return $result;
  }
  GetGroupChannelRequest._() : super();
  factory GetGroupChannelRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetGroupChannelRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetGroupChannelRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'tureon.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'groupChannelId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetGroupChannelRequest clone() => GetGroupChannelRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetGroupChannelRequest copyWith(void Function(GetGroupChannelRequest) updates) => super.copyWith((message) => updates(message as GetGroupChannelRequest)) as GetGroupChannelRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetGroupChannelRequest create() => GetGroupChannelRequest._();
  GetGroupChannelRequest createEmptyInstance() => create();
  static $pb.PbList<GetGroupChannelRequest> createRepeated() => $pb.PbList<GetGroupChannelRequest>();
  @$core.pragma('dart2js:noInline')
  static GetGroupChannelRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetGroupChannelRequest>(create);
  static GetGroupChannelRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get groupChannelId => $_getSZ(0);
  @$pb.TagNumber(1)
  set groupChannelId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasGroupChannelId() => $_has(0);
  @$pb.TagNumber(1)
  void clearGroupChannelId() => clearField(1);
}

class GetGroupChannelResponse extends $pb.GeneratedMessage {
  factory GetGroupChannelResponse({
    GroupChannel? groupChannel,
  }) {
    final $result = create();
    if (groupChannel != null) {
      $result.groupChannel = groupChannel;
    }
    return $result;
  }
  GetGroupChannelResponse._() : super();
  factory GetGroupChannelResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetGroupChannelResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetGroupChannelResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'tureon.v1'), createEmptyInstance: create)
    ..aOM<GroupChannel>(1, _omitFieldNames ? '' : 'groupChannel', subBuilder: GroupChannel.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetGroupChannelResponse clone() => GetGroupChannelResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetGroupChannelResponse copyWith(void Function(GetGroupChannelResponse) updates) => super.copyWith((message) => updates(message as GetGroupChannelResponse)) as GetGroupChannelResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetGroupChannelResponse create() => GetGroupChannelResponse._();
  GetGroupChannelResponse createEmptyInstance() => create();
  static $pb.PbList<GetGroupChannelResponse> createRepeated() => $pb.PbList<GetGroupChannelResponse>();
  @$core.pragma('dart2js:noInline')
  static GetGroupChannelResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetGroupChannelResponse>(create);
  static GetGroupChannelResponse? _defaultInstance;

  @$pb.TagNumber(1)
  GroupChannel get groupChannel => $_getN(0);
  @$pb.TagNumber(1)
  set groupChannel(GroupChannel v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasGroupChannel() => $_has(0);
  @$pb.TagNumber(1)
  void clearGroupChannel() => clearField(1);
  @$pb.TagNumber(1)
  GroupChannel ensureGroupChannel() => $_ensure(0);
}

class UpdateGroupChannelResponse extends $pb.GeneratedMessage {
  factory UpdateGroupChannelResponse({
    GroupChannel? groupChannel,
  }) {
    final $result = create();
    if (groupChannel != null) {
      $result.groupChannel = groupChannel;
    }
    return $result;
  }
  UpdateGroupChannelResponse._() : super();
  factory UpdateGroupChannelResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UpdateGroupChannelResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UpdateGroupChannelResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'tureon.v1'), createEmptyInstance: create)
    ..aOM<GroupChannel>(1, _omitFieldNames ? '' : 'groupChannel', subBuilder: GroupChannel.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UpdateGroupChannelResponse clone() => UpdateGroupChannelResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UpdateGroupChannelResponse copyWith(void Function(UpdateGroupChannelResponse) updates) => super.copyWith((message) => updates(message as UpdateGroupChannelResponse)) as UpdateGroupChannelResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateGroupChannelResponse create() => UpdateGroupChannelResponse._();
  UpdateGroupChannelResponse createEmptyInstance() => create();
  static $pb.PbList<UpdateGroupChannelResponse> createRepeated() => $pb.PbList<UpdateGroupChannelResponse>();
  @$core.pragma('dart2js:noInline')
  static UpdateGroupChannelResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UpdateGroupChannelResponse>(create);
  static UpdateGroupChannelResponse? _defaultInstance;

  @$pb.TagNumber(1)
  GroupChannel get groupChannel => $_getN(0);
  @$pb.TagNumber(1)
  set groupChannel(GroupChannel v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasGroupChannel() => $_has(0);
  @$pb.TagNumber(1)
  void clearGroupChannel() => clearField(1);
  @$pb.TagNumber(1)
  GroupChannel ensureGroupChannel() => $_ensure(0);
}

class CreateChannelRequest extends $pb.GeneratedMessage {
  factory CreateChannelRequest({
    $core.String? name,
    $core.String? description,
    $core.String? avatarUrl,
    $core.String? visibility,
  }) {
    final $result = create();
    if (name != null) {
      $result.name = name;
    }
    if (description != null) {
      $result.description = description;
    }
    if (avatarUrl != null) {
      $result.avatarUrl = avatarUrl;
    }
    if (visibility != null) {
      $result.visibility = visibility;
    }
    return $result;
  }
  CreateChannelRequest._() : super();
  factory CreateChannelRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateChannelRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateChannelRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'tureon.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOS(2, _omitFieldNames ? '' : 'description')
    ..aOS(3, _omitFieldNames ? '' : 'avatarUrl')
    ..aOS(4, _omitFieldNames ? '' : 'visibility')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreateChannelRequest clone() => CreateChannelRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreateChannelRequest copyWith(void Function(CreateChannelRequest) updates) => super.copyWith((message) => updates(message as CreateChannelRequest)) as CreateChannelRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateChannelRequest create() => CreateChannelRequest._();
  CreateChannelRequest createEmptyInstance() => create();
  static $pb.PbList<CreateChannelRequest> createRepeated() => $pb.PbList<CreateChannelRequest>();
  @$core.pragma('dart2js:noInline')
  static CreateChannelRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateChannelRequest>(create);
  static CreateChannelRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get description => $_getSZ(1);
  @$pb.TagNumber(2)
  set description($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasDescription() => $_has(1);
  @$pb.TagNumber(2)
  void clearDescription() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get avatarUrl => $_getSZ(2);
  @$pb.TagNumber(3)
  set avatarUrl($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasAvatarUrl() => $_has(2);
  @$pb.TagNumber(3)
  void clearAvatarUrl() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get visibility => $_getSZ(3);
  @$pb.TagNumber(4)
  set visibility($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasVisibility() => $_has(3);
  @$pb.TagNumber(4)
  void clearVisibility() => clearField(4);
}

class CreateChannelResponse extends $pb.GeneratedMessage {
  factory CreateChannelResponse({
    GroupChannel? channel,
  }) {
    final $result = create();
    if (channel != null) {
      $result.channel = channel;
    }
    return $result;
  }
  CreateChannelResponse._() : super();
  factory CreateChannelResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateChannelResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateChannelResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'tureon.v1'), createEmptyInstance: create)
    ..aOM<GroupChannel>(1, _omitFieldNames ? '' : 'channel', subBuilder: GroupChannel.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreateChannelResponse clone() => CreateChannelResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreateChannelResponse copyWith(void Function(CreateChannelResponse) updates) => super.copyWith((message) => updates(message as CreateChannelResponse)) as CreateChannelResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateChannelResponse create() => CreateChannelResponse._();
  CreateChannelResponse createEmptyInstance() => create();
  static $pb.PbList<CreateChannelResponse> createRepeated() => $pb.PbList<CreateChannelResponse>();
  @$core.pragma('dart2js:noInline')
  static CreateChannelResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateChannelResponse>(create);
  static CreateChannelResponse? _defaultInstance;

  @$pb.TagNumber(1)
  GroupChannel get channel => $_getN(0);
  @$pb.TagNumber(1)
  set channel(GroupChannel v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasChannel() => $_has(0);
  @$pb.TagNumber(1)
  void clearChannel() => clearField(1);
  @$pb.TagNumber(1)
  GroupChannel ensureChannel() => $_ensure(0);
}

class ListMyGroupsResponse extends $pb.GeneratedMessage {
  factory ListMyGroupsResponse({
    $core.Iterable<GroupChannel>? groups,
  }) {
    final $result = create();
    if (groups != null) {
      $result.groups.addAll(groups);
    }
    return $result;
  }
  ListMyGroupsResponse._() : super();
  factory ListMyGroupsResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListMyGroupsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListMyGroupsResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'tureon.v1'), createEmptyInstance: create)
    ..pc<GroupChannel>(1, _omitFieldNames ? '' : 'groups', $pb.PbFieldType.PM, subBuilder: GroupChannel.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListMyGroupsResponse clone() => ListMyGroupsResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListMyGroupsResponse copyWith(void Function(ListMyGroupsResponse) updates) => super.copyWith((message) => updates(message as ListMyGroupsResponse)) as ListMyGroupsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListMyGroupsResponse create() => ListMyGroupsResponse._();
  ListMyGroupsResponse createEmptyInstance() => create();
  static $pb.PbList<ListMyGroupsResponse> createRepeated() => $pb.PbList<ListMyGroupsResponse>();
  @$core.pragma('dart2js:noInline')
  static ListMyGroupsResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListMyGroupsResponse>(create);
  static ListMyGroupsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<GroupChannel> get groups => $_getList(0);
}

class ListMyChannelsResponse extends $pb.GeneratedMessage {
  factory ListMyChannelsResponse({
    $core.Iterable<GroupChannel>? channels,
  }) {
    final $result = create();
    if (channels != null) {
      $result.channels.addAll(channels);
    }
    return $result;
  }
  ListMyChannelsResponse._() : super();
  factory ListMyChannelsResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListMyChannelsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListMyChannelsResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'tureon.v1'), createEmptyInstance: create)
    ..pc<GroupChannel>(1, _omitFieldNames ? '' : 'channels', $pb.PbFieldType.PM, subBuilder: GroupChannel.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListMyChannelsResponse clone() => ListMyChannelsResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListMyChannelsResponse copyWith(void Function(ListMyChannelsResponse) updates) => super.copyWith((message) => updates(message as ListMyChannelsResponse)) as ListMyChannelsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListMyChannelsResponse create() => ListMyChannelsResponse._();
  ListMyChannelsResponse createEmptyInstance() => create();
  static $pb.PbList<ListMyChannelsResponse> createRepeated() => $pb.PbList<ListMyChannelsResponse>();
  @$core.pragma('dart2js:noInline')
  static ListMyChannelsResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListMyChannelsResponse>(create);
  static ListMyChannelsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<GroupChannel> get channels => $_getList(0);
}

class SearchPublicGroupsRequest extends $pb.GeneratedMessage {
  factory SearchPublicGroupsRequest({
    $core.String? query,
  }) {
    final $result = create();
    if (query != null) {
      $result.query = query;
    }
    return $result;
  }
  SearchPublicGroupsRequest._() : super();
  factory SearchPublicGroupsRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SearchPublicGroupsRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SearchPublicGroupsRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'tureon.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'query')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SearchPublicGroupsRequest clone() => SearchPublicGroupsRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SearchPublicGroupsRequest copyWith(void Function(SearchPublicGroupsRequest) updates) => super.copyWith((message) => updates(message as SearchPublicGroupsRequest)) as SearchPublicGroupsRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SearchPublicGroupsRequest create() => SearchPublicGroupsRequest._();
  SearchPublicGroupsRequest createEmptyInstance() => create();
  static $pb.PbList<SearchPublicGroupsRequest> createRepeated() => $pb.PbList<SearchPublicGroupsRequest>();
  @$core.pragma('dart2js:noInline')
  static SearchPublicGroupsRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SearchPublicGroupsRequest>(create);
  static SearchPublicGroupsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get query => $_getSZ(0);
  @$pb.TagNumber(1)
  set query($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasQuery() => $_has(0);
  @$pb.TagNumber(1)
  void clearQuery() => clearField(1);
}

class SearchPublicGroupsResponse extends $pb.GeneratedMessage {
  factory SearchPublicGroupsResponse({
    $core.Iterable<GroupChannel>? groups,
  }) {
    final $result = create();
    if (groups != null) {
      $result.groups.addAll(groups);
    }
    return $result;
  }
  SearchPublicGroupsResponse._() : super();
  factory SearchPublicGroupsResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SearchPublicGroupsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SearchPublicGroupsResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'tureon.v1'), createEmptyInstance: create)
    ..pc<GroupChannel>(1, _omitFieldNames ? '' : 'groups', $pb.PbFieldType.PM, subBuilder: GroupChannel.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SearchPublicGroupsResponse clone() => SearchPublicGroupsResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SearchPublicGroupsResponse copyWith(void Function(SearchPublicGroupsResponse) updates) => super.copyWith((message) => updates(message as SearchPublicGroupsResponse)) as SearchPublicGroupsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SearchPublicGroupsResponse create() => SearchPublicGroupsResponse._();
  SearchPublicGroupsResponse createEmptyInstance() => create();
  static $pb.PbList<SearchPublicGroupsResponse> createRepeated() => $pb.PbList<SearchPublicGroupsResponse>();
  @$core.pragma('dart2js:noInline')
  static SearchPublicGroupsResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SearchPublicGroupsResponse>(create);
  static SearchPublicGroupsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<GroupChannel> get groups => $_getList(0);
}

class JoinPublicGroupRequest extends $pb.GeneratedMessage {
  factory JoinPublicGroupRequest({
    $core.String? groupId,
  }) {
    final $result = create();
    if (groupId != null) {
      $result.groupId = groupId;
    }
    return $result;
  }
  JoinPublicGroupRequest._() : super();
  factory JoinPublicGroupRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory JoinPublicGroupRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'JoinPublicGroupRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'tureon.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'groupId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  JoinPublicGroupRequest clone() => JoinPublicGroupRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  JoinPublicGroupRequest copyWith(void Function(JoinPublicGroupRequest) updates) => super.copyWith((message) => updates(message as JoinPublicGroupRequest)) as JoinPublicGroupRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static JoinPublicGroupRequest create() => JoinPublicGroupRequest._();
  JoinPublicGroupRequest createEmptyInstance() => create();
  static $pb.PbList<JoinPublicGroupRequest> createRepeated() => $pb.PbList<JoinPublicGroupRequest>();
  @$core.pragma('dart2js:noInline')
  static JoinPublicGroupRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<JoinPublicGroupRequest>(create);
  static JoinPublicGroupRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get groupId => $_getSZ(0);
  @$pb.TagNumber(1)
  set groupId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasGroupId() => $_has(0);
  @$pb.TagNumber(1)
  void clearGroupId() => clearField(1);
}

class JoinPublicGroupResponse extends $pb.GeneratedMessage {
  factory JoinPublicGroupResponse({
    GroupChannel? group,
  }) {
    final $result = create();
    if (group != null) {
      $result.group = group;
    }
    return $result;
  }
  JoinPublicGroupResponse._() : super();
  factory JoinPublicGroupResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory JoinPublicGroupResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'JoinPublicGroupResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'tureon.v1'), createEmptyInstance: create)
    ..aOM<GroupChannel>(1, _omitFieldNames ? '' : 'group', subBuilder: GroupChannel.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  JoinPublicGroupResponse clone() => JoinPublicGroupResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  JoinPublicGroupResponse copyWith(void Function(JoinPublicGroupResponse) updates) => super.copyWith((message) => updates(message as JoinPublicGroupResponse)) as JoinPublicGroupResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static JoinPublicGroupResponse create() => JoinPublicGroupResponse._();
  JoinPublicGroupResponse createEmptyInstance() => create();
  static $pb.PbList<JoinPublicGroupResponse> createRepeated() => $pb.PbList<JoinPublicGroupResponse>();
  @$core.pragma('dart2js:noInline')
  static JoinPublicGroupResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<JoinPublicGroupResponse>(create);
  static JoinPublicGroupResponse? _defaultInstance;

  @$pb.TagNumber(1)
  GroupChannel get group => $_getN(0);
  @$pb.TagNumber(1)
  set group(GroupChannel v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasGroup() => $_has(0);
  @$pb.TagNumber(1)
  void clearGroup() => clearField(1);
  @$pb.TagNumber(1)
  GroupChannel ensureGroup() => $_ensure(0);
}

class SearchPublicChannelsRequest extends $pb.GeneratedMessage {
  factory SearchPublicChannelsRequest({
    $core.String? query,
  }) {
    final $result = create();
    if (query != null) {
      $result.query = query;
    }
    return $result;
  }
  SearchPublicChannelsRequest._() : super();
  factory SearchPublicChannelsRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SearchPublicChannelsRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SearchPublicChannelsRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'tureon.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'query')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SearchPublicChannelsRequest clone() => SearchPublicChannelsRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SearchPublicChannelsRequest copyWith(void Function(SearchPublicChannelsRequest) updates) => super.copyWith((message) => updates(message as SearchPublicChannelsRequest)) as SearchPublicChannelsRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SearchPublicChannelsRequest create() => SearchPublicChannelsRequest._();
  SearchPublicChannelsRequest createEmptyInstance() => create();
  static $pb.PbList<SearchPublicChannelsRequest> createRepeated() => $pb.PbList<SearchPublicChannelsRequest>();
  @$core.pragma('dart2js:noInline')
  static SearchPublicChannelsRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SearchPublicChannelsRequest>(create);
  static SearchPublicChannelsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get query => $_getSZ(0);
  @$pb.TagNumber(1)
  set query($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasQuery() => $_has(0);
  @$pb.TagNumber(1)
  void clearQuery() => clearField(1);
}

class SearchPublicChannelsResponse extends $pb.GeneratedMessage {
  factory SearchPublicChannelsResponse({
    $core.Iterable<GroupChannel>? channels,
  }) {
    final $result = create();
    if (channels != null) {
      $result.channels.addAll(channels);
    }
    return $result;
  }
  SearchPublicChannelsResponse._() : super();
  factory SearchPublicChannelsResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SearchPublicChannelsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SearchPublicChannelsResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'tureon.v1'), createEmptyInstance: create)
    ..pc<GroupChannel>(1, _omitFieldNames ? '' : 'channels', $pb.PbFieldType.PM, subBuilder: GroupChannel.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SearchPublicChannelsResponse clone() => SearchPublicChannelsResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SearchPublicChannelsResponse copyWith(void Function(SearchPublicChannelsResponse) updates) => super.copyWith((message) => updates(message as SearchPublicChannelsResponse)) as SearchPublicChannelsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SearchPublicChannelsResponse create() => SearchPublicChannelsResponse._();
  SearchPublicChannelsResponse createEmptyInstance() => create();
  static $pb.PbList<SearchPublicChannelsResponse> createRepeated() => $pb.PbList<SearchPublicChannelsResponse>();
  @$core.pragma('dart2js:noInline')
  static SearchPublicChannelsResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SearchPublicChannelsResponse>(create);
  static SearchPublicChannelsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<GroupChannel> get channels => $_getList(0);
}

class JoinPublicChannelRequest extends $pb.GeneratedMessage {
  factory JoinPublicChannelRequest({
    $core.String? channelId,
  }) {
    final $result = create();
    if (channelId != null) {
      $result.channelId = channelId;
    }
    return $result;
  }
  JoinPublicChannelRequest._() : super();
  factory JoinPublicChannelRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory JoinPublicChannelRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'JoinPublicChannelRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'tureon.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'channelId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  JoinPublicChannelRequest clone() => JoinPublicChannelRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  JoinPublicChannelRequest copyWith(void Function(JoinPublicChannelRequest) updates) => super.copyWith((message) => updates(message as JoinPublicChannelRequest)) as JoinPublicChannelRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static JoinPublicChannelRequest create() => JoinPublicChannelRequest._();
  JoinPublicChannelRequest createEmptyInstance() => create();
  static $pb.PbList<JoinPublicChannelRequest> createRepeated() => $pb.PbList<JoinPublicChannelRequest>();
  @$core.pragma('dart2js:noInline')
  static JoinPublicChannelRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<JoinPublicChannelRequest>(create);
  static JoinPublicChannelRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get channelId => $_getSZ(0);
  @$pb.TagNumber(1)
  set channelId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasChannelId() => $_has(0);
  @$pb.TagNumber(1)
  void clearChannelId() => clearField(1);
}

class JoinPublicChannelResponse extends $pb.GeneratedMessage {
  factory JoinPublicChannelResponse({
    GroupChannel? channel,
  }) {
    final $result = create();
    if (channel != null) {
      $result.channel = channel;
    }
    return $result;
  }
  JoinPublicChannelResponse._() : super();
  factory JoinPublicChannelResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory JoinPublicChannelResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'JoinPublicChannelResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'tureon.v1'), createEmptyInstance: create)
    ..aOM<GroupChannel>(1, _omitFieldNames ? '' : 'channel', subBuilder: GroupChannel.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  JoinPublicChannelResponse clone() => JoinPublicChannelResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  JoinPublicChannelResponse copyWith(void Function(JoinPublicChannelResponse) updates) => super.copyWith((message) => updates(message as JoinPublicChannelResponse)) as JoinPublicChannelResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static JoinPublicChannelResponse create() => JoinPublicChannelResponse._();
  JoinPublicChannelResponse createEmptyInstance() => create();
  static $pb.PbList<JoinPublicChannelResponse> createRepeated() => $pb.PbList<JoinPublicChannelResponse>();
  @$core.pragma('dart2js:noInline')
  static JoinPublicChannelResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<JoinPublicChannelResponse>(create);
  static JoinPublicChannelResponse? _defaultInstance;

  @$pb.TagNumber(1)
  GroupChannel get channel => $_getN(0);
  @$pb.TagNumber(1)
  set channel(GroupChannel v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasChannel() => $_has(0);
  @$pb.TagNumber(1)
  void clearChannel() => clearField(1);
  @$pb.TagNumber(1)
  GroupChannel ensureChannel() => $_ensure(0);
}

class GroupChannelMember extends $pb.GeneratedMessage {
  factory GroupChannelMember({
    $core.String? userId,
    $core.String? role,
    $fixnum.Int64? joinedAt,
    $core.String? displayName,
    $core.String? username,
    $core.String? avatarUrl,
  }) {
    final $result = create();
    if (userId != null) {
      $result.userId = userId;
    }
    if (role != null) {
      $result.role = role;
    }
    if (joinedAt != null) {
      $result.joinedAt = joinedAt;
    }
    if (displayName != null) {
      $result.displayName = displayName;
    }
    if (username != null) {
      $result.username = username;
    }
    if (avatarUrl != null) {
      $result.avatarUrl = avatarUrl;
    }
    return $result;
  }
  GroupChannelMember._() : super();
  factory GroupChannelMember.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GroupChannelMember.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GroupChannelMember', package: const $pb.PackageName(_omitMessageNames ? '' : 'tureon.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOS(2, _omitFieldNames ? '' : 'role')
    ..aInt64(3, _omitFieldNames ? '' : 'joinedAt')
    ..aOS(4, _omitFieldNames ? '' : 'displayName')
    ..aOS(5, _omitFieldNames ? '' : 'username')
    ..aOS(6, _omitFieldNames ? '' : 'avatarUrl')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GroupChannelMember clone() => GroupChannelMember()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GroupChannelMember copyWith(void Function(GroupChannelMember) updates) => super.copyWith((message) => updates(message as GroupChannelMember)) as GroupChannelMember;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GroupChannelMember create() => GroupChannelMember._();
  GroupChannelMember createEmptyInstance() => create();
  static $pb.PbList<GroupChannelMember> createRepeated() => $pb.PbList<GroupChannelMember>();
  @$core.pragma('dart2js:noInline')
  static GroupChannelMember getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GroupChannelMember>(create);
  static GroupChannelMember? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get role => $_getSZ(1);
  @$pb.TagNumber(2)
  set role($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasRole() => $_has(1);
  @$pb.TagNumber(2)
  void clearRole() => clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get joinedAt => $_getI64(2);
  @$pb.TagNumber(3)
  set joinedAt($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasJoinedAt() => $_has(2);
  @$pb.TagNumber(3)
  void clearJoinedAt() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get displayName => $_getSZ(3);
  @$pb.TagNumber(4)
  set displayName($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasDisplayName() => $_has(3);
  @$pb.TagNumber(4)
  void clearDisplayName() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get username => $_getSZ(4);
  @$pb.TagNumber(5)
  set username($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasUsername() => $_has(4);
  @$pb.TagNumber(5)
  void clearUsername() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get avatarUrl => $_getSZ(5);
  @$pb.TagNumber(6)
  set avatarUrl($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasAvatarUrl() => $_has(5);
  @$pb.TagNumber(6)
  void clearAvatarUrl() => clearField(6);
}

class ListGroupChannelMembersResponse extends $pb.GeneratedMessage {
  factory ListGroupChannelMembersResponse({
    $core.Iterable<GroupChannelMember>? members,
  }) {
    final $result = create();
    if (members != null) {
      $result.members.addAll(members);
    }
    return $result;
  }
  ListGroupChannelMembersResponse._() : super();
  factory ListGroupChannelMembersResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListGroupChannelMembersResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListGroupChannelMembersResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'tureon.v1'), createEmptyInstance: create)
    ..pc<GroupChannelMember>(1, _omitFieldNames ? '' : 'members', $pb.PbFieldType.PM, subBuilder: GroupChannelMember.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListGroupChannelMembersResponse clone() => ListGroupChannelMembersResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListGroupChannelMembersResponse copyWith(void Function(ListGroupChannelMembersResponse) updates) => super.copyWith((message) => updates(message as ListGroupChannelMembersResponse)) as ListGroupChannelMembersResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListGroupChannelMembersResponse create() => ListGroupChannelMembersResponse._();
  ListGroupChannelMembersResponse createEmptyInstance() => create();
  static $pb.PbList<ListGroupChannelMembersResponse> createRepeated() => $pb.PbList<ListGroupChannelMembersResponse>();
  @$core.pragma('dart2js:noInline')
  static ListGroupChannelMembersResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListGroupChannelMembersResponse>(create);
  static ListGroupChannelMembersResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<GroupChannelMember> get members => $_getList(0);
}

class ListGroupChannelMembersPageRequest extends $pb.GeneratedMessage {
  factory ListGroupChannelMembersPageRequest({
    $core.String? groupChannelId,
    $core.int? pageSize,
    $fixnum.Int64? offset,
  }) {
    final $result = create();
    if (groupChannelId != null) {
      $result.groupChannelId = groupChannelId;
    }
    if (pageSize != null) {
      $result.pageSize = pageSize;
    }
    if (offset != null) {
      $result.offset = offset;
    }
    return $result;
  }
  ListGroupChannelMembersPageRequest._() : super();
  factory ListGroupChannelMembersPageRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListGroupChannelMembersPageRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListGroupChannelMembersPageRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'tureon.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'groupChannelId')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'pageSize', $pb.PbFieldType.O3)
    ..aInt64(3, _omitFieldNames ? '' : 'offset')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListGroupChannelMembersPageRequest clone() => ListGroupChannelMembersPageRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListGroupChannelMembersPageRequest copyWith(void Function(ListGroupChannelMembersPageRequest) updates) => super.copyWith((message) => updates(message as ListGroupChannelMembersPageRequest)) as ListGroupChannelMembersPageRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListGroupChannelMembersPageRequest create() => ListGroupChannelMembersPageRequest._();
  ListGroupChannelMembersPageRequest createEmptyInstance() => create();
  static $pb.PbList<ListGroupChannelMembersPageRequest> createRepeated() => $pb.PbList<ListGroupChannelMembersPageRequest>();
  @$core.pragma('dart2js:noInline')
  static ListGroupChannelMembersPageRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListGroupChannelMembersPageRequest>(create);
  static ListGroupChannelMembersPageRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get groupChannelId => $_getSZ(0);
  @$pb.TagNumber(1)
  set groupChannelId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasGroupChannelId() => $_has(0);
  @$pb.TagNumber(1)
  void clearGroupChannelId() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get pageSize => $_getIZ(1);
  @$pb.TagNumber(2)
  set pageSize($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasPageSize() => $_has(1);
  @$pb.TagNumber(2)
  void clearPageSize() => clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get offset => $_getI64(2);
  @$pb.TagNumber(3)
  set offset($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasOffset() => $_has(2);
  @$pb.TagNumber(3)
  void clearOffset() => clearField(3);
}

class ListGroupChannelMembersPageResponse extends $pb.GeneratedMessage {
  factory ListGroupChannelMembersPageResponse({
    $core.Iterable<GroupChannelMember>? members,
    $fixnum.Int64? totalCount,
    $fixnum.Int64? nextOffset,
    $core.bool? hasMore,
  }) {
    final $result = create();
    if (members != null) {
      $result.members.addAll(members);
    }
    if (totalCount != null) {
      $result.totalCount = totalCount;
    }
    if (nextOffset != null) {
      $result.nextOffset = nextOffset;
    }
    if (hasMore != null) {
      $result.hasMore = hasMore;
    }
    return $result;
  }
  ListGroupChannelMembersPageResponse._() : super();
  factory ListGroupChannelMembersPageResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListGroupChannelMembersPageResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListGroupChannelMembersPageResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'tureon.v1'), createEmptyInstance: create)
    ..pc<GroupChannelMember>(1, _omitFieldNames ? '' : 'members', $pb.PbFieldType.PM, subBuilder: GroupChannelMember.create)
    ..aInt64(2, _omitFieldNames ? '' : 'totalCount')
    ..aInt64(3, _omitFieldNames ? '' : 'nextOffset')
    ..aOB(4, _omitFieldNames ? '' : 'hasMore')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListGroupChannelMembersPageResponse clone() => ListGroupChannelMembersPageResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListGroupChannelMembersPageResponse copyWith(void Function(ListGroupChannelMembersPageResponse) updates) => super.copyWith((message) => updates(message as ListGroupChannelMembersPageResponse)) as ListGroupChannelMembersPageResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListGroupChannelMembersPageResponse create() => ListGroupChannelMembersPageResponse._();
  ListGroupChannelMembersPageResponse createEmptyInstance() => create();
  static $pb.PbList<ListGroupChannelMembersPageResponse> createRepeated() => $pb.PbList<ListGroupChannelMembersPageResponse>();
  @$core.pragma('dart2js:noInline')
  static ListGroupChannelMembersPageResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListGroupChannelMembersPageResponse>(create);
  static ListGroupChannelMembersPageResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<GroupChannelMember> get members => $_getList(0);

  @$pb.TagNumber(2)
  $fixnum.Int64 get totalCount => $_getI64(1);
  @$pb.TagNumber(2)
  set totalCount($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasTotalCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotalCount() => clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get nextOffset => $_getI64(2);
  @$pb.TagNumber(3)
  set nextOffset($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasNextOffset() => $_has(2);
  @$pb.TagNumber(3)
  void clearNextOffset() => clearField(3);

  @$pb.TagNumber(4)
  $core.bool get hasMore => $_getBF(3);
  @$pb.TagNumber(4)
  set hasMore($core.bool v) { $_setBool(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasHasMore() => $_has(3);
  @$pb.TagNumber(4)
  void clearHasMore() => clearField(4);
}

class GetGroupOnlineMemberCountRequest extends $pb.GeneratedMessage {
  factory GetGroupOnlineMemberCountRequest({
    $core.String? groupId,
  }) {
    final $result = create();
    if (groupId != null) {
      $result.groupId = groupId;
    }
    return $result;
  }
  GetGroupOnlineMemberCountRequest._() : super();
  factory GetGroupOnlineMemberCountRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetGroupOnlineMemberCountRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetGroupOnlineMemberCountRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'tureon.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'groupId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetGroupOnlineMemberCountRequest clone() => GetGroupOnlineMemberCountRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetGroupOnlineMemberCountRequest copyWith(void Function(GetGroupOnlineMemberCountRequest) updates) => super.copyWith((message) => updates(message as GetGroupOnlineMemberCountRequest)) as GetGroupOnlineMemberCountRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetGroupOnlineMemberCountRequest create() => GetGroupOnlineMemberCountRequest._();
  GetGroupOnlineMemberCountRequest createEmptyInstance() => create();
  static $pb.PbList<GetGroupOnlineMemberCountRequest> createRepeated() => $pb.PbList<GetGroupOnlineMemberCountRequest>();
  @$core.pragma('dart2js:noInline')
  static GetGroupOnlineMemberCountRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetGroupOnlineMemberCountRequest>(create);
  static GetGroupOnlineMemberCountRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get groupId => $_getSZ(0);
  @$pb.TagNumber(1)
  set groupId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasGroupId() => $_has(0);
  @$pb.TagNumber(1)
  void clearGroupId() => clearField(1);
}

class GetGroupOnlineMemberCountResponse extends $pb.GeneratedMessage {
  factory GetGroupOnlineMemberCountResponse({
    $fixnum.Int64? onlineMemberCount,
  }) {
    final $result = create();
    if (onlineMemberCount != null) {
      $result.onlineMemberCount = onlineMemberCount;
    }
    return $result;
  }
  GetGroupOnlineMemberCountResponse._() : super();
  factory GetGroupOnlineMemberCountResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetGroupOnlineMemberCountResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetGroupOnlineMemberCountResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'tureon.v1'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'onlineMemberCount')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetGroupOnlineMemberCountResponse clone() => GetGroupOnlineMemberCountResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetGroupOnlineMemberCountResponse copyWith(void Function(GetGroupOnlineMemberCountResponse) updates) => super.copyWith((message) => updates(message as GetGroupOnlineMemberCountResponse)) as GetGroupOnlineMemberCountResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetGroupOnlineMemberCountResponse create() => GetGroupOnlineMemberCountResponse._();
  GetGroupOnlineMemberCountResponse createEmptyInstance() => create();
  static $pb.PbList<GetGroupOnlineMemberCountResponse> createRepeated() => $pb.PbList<GetGroupOnlineMemberCountResponse>();
  @$core.pragma('dart2js:noInline')
  static GetGroupOnlineMemberCountResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetGroupOnlineMemberCountResponse>(create);
  static GetGroupOnlineMemberCountResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get onlineMemberCount => $_getI64(0);
  @$pb.TagNumber(1)
  set onlineMemberCount($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasOnlineMemberCount() => $_has(0);
  @$pb.TagNumber(1)
  void clearOnlineMemberCount() => clearField(1);
}

class Bot extends $pb.GeneratedMessage {
  factory Bot({
    $core.String? id,
    $core.String? username,
    $core.String? displayName,
    $core.String? description,
    $fixnum.Int64? createdAt,
    $core.String? verificationBadge,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (username != null) {
      $result.username = username;
    }
    if (displayName != null) {
      $result.displayName = displayName;
    }
    if (description != null) {
      $result.description = description;
    }
    if (createdAt != null) {
      $result.createdAt = createdAt;
    }
    if (verificationBadge != null) {
      $result.verificationBadge = verificationBadge;
    }
    return $result;
  }
  Bot._() : super();
  factory Bot.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Bot.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Bot', package: const $pb.PackageName(_omitMessageNames ? '' : 'tureon.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'username')
    ..aOS(3, _omitFieldNames ? '' : 'displayName')
    ..aOS(4, _omitFieldNames ? '' : 'description')
    ..aInt64(7, _omitFieldNames ? '' : 'createdAt')
    ..aOS(8, _omitFieldNames ? '' : 'verificationBadge')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Bot clone() => Bot()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Bot copyWith(void Function(Bot) updates) => super.copyWith((message) => updates(message as Bot)) as Bot;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Bot create() => Bot._();
  Bot createEmptyInstance() => create();
  static $pb.PbList<Bot> createRepeated() => $pb.PbList<Bot>();
  @$core.pragma('dart2js:noInline')
  static Bot getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Bot>(create);
  static Bot? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get username => $_getSZ(1);
  @$pb.TagNumber(2)
  set username($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasUsername() => $_has(1);
  @$pb.TagNumber(2)
  void clearUsername() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get displayName => $_getSZ(2);
  @$pb.TagNumber(3)
  set displayName($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasDisplayName() => $_has(2);
  @$pb.TagNumber(3)
  void clearDisplayName() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get description => $_getSZ(3);
  @$pb.TagNumber(4)
  set description($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasDescription() => $_has(3);
  @$pb.TagNumber(4)
  void clearDescription() => clearField(4);

  @$pb.TagNumber(7)
  $fixnum.Int64 get createdAt => $_getI64(4);
  @$pb.TagNumber(7)
  set createdAt($fixnum.Int64 v) { $_setInt64(4, v); }
  @$pb.TagNumber(7)
  $core.bool hasCreatedAt() => $_has(4);
  @$pb.TagNumber(7)
  void clearCreatedAt() => clearField(7);

  @$pb.TagNumber(8)
  $core.String get verificationBadge => $_getSZ(5);
  @$pb.TagNumber(8)
  set verificationBadge($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(8)
  $core.bool hasVerificationBadge() => $_has(5);
  @$pb.TagNumber(8)
  void clearVerificationBadge() => clearField(8);
}

class InteractBotRequest extends $pb.GeneratedMessage {
  factory InteractBotRequest({
    $core.String? botUsername,
    $core.String? text,
    $core.String? clientMessageId,
  }) {
    final $result = create();
    if (botUsername != null) {
      $result.botUsername = botUsername;
    }
    if (text != null) {
      $result.text = text;
    }
    if (clientMessageId != null) {
      $result.clientMessageId = clientMessageId;
    }
    return $result;
  }
  InteractBotRequest._() : super();
  factory InteractBotRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory InteractBotRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'InteractBotRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'tureon.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'botUsername')
    ..aOS(2, _omitFieldNames ? '' : 'text')
    ..aOS(3, _omitFieldNames ? '' : 'clientMessageId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  InteractBotRequest clone() => InteractBotRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  InteractBotRequest copyWith(void Function(InteractBotRequest) updates) => super.copyWith((message) => updates(message as InteractBotRequest)) as InteractBotRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static InteractBotRequest create() => InteractBotRequest._();
  InteractBotRequest createEmptyInstance() => create();
  static $pb.PbList<InteractBotRequest> createRepeated() => $pb.PbList<InteractBotRequest>();
  @$core.pragma('dart2js:noInline')
  static InteractBotRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<InteractBotRequest>(create);
  static InteractBotRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get botUsername => $_getSZ(0);
  @$pb.TagNumber(1)
  set botUsername($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasBotUsername() => $_has(0);
  @$pb.TagNumber(1)
  void clearBotUsername() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get text => $_getSZ(1);
  @$pb.TagNumber(2)
  set text($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasText() => $_has(1);
  @$pb.TagNumber(2)
  void clearText() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get clientMessageId => $_getSZ(2);
  @$pb.TagNumber(3)
  set clientMessageId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasClientMessageId() => $_has(2);
  @$pb.TagNumber(3)
  void clearClientMessageId() => clearField(3);
}

class InteractBotResponse extends $pb.GeneratedMessage {
  factory InteractBotResponse({
    Bot? bot,
    $core.String? responseText,
    $core.bool? firstInteraction,
    $core.String? eventId,
  }) {
    final $result = create();
    if (bot != null) {
      $result.bot = bot;
    }
    if (responseText != null) {
      $result.responseText = responseText;
    }
    if (firstInteraction != null) {
      $result.firstInteraction = firstInteraction;
    }
    if (eventId != null) {
      $result.eventId = eventId;
    }
    return $result;
  }
  InteractBotResponse._() : super();
  factory InteractBotResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory InteractBotResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'InteractBotResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'tureon.v1'), createEmptyInstance: create)
    ..aOM<Bot>(1, _omitFieldNames ? '' : 'bot', subBuilder: Bot.create)
    ..aOS(2, _omitFieldNames ? '' : 'responseText')
    ..aOB(3, _omitFieldNames ? '' : 'firstInteraction')
    ..aOS(4, _omitFieldNames ? '' : 'eventId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  InteractBotResponse clone() => InteractBotResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  InteractBotResponse copyWith(void Function(InteractBotResponse) updates) => super.copyWith((message) => updates(message as InteractBotResponse)) as InteractBotResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static InteractBotResponse create() => InteractBotResponse._();
  InteractBotResponse createEmptyInstance() => create();
  static $pb.PbList<InteractBotResponse> createRepeated() => $pb.PbList<InteractBotResponse>();
  @$core.pragma('dart2js:noInline')
  static InteractBotResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<InteractBotResponse>(create);
  static InteractBotResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Bot get bot => $_getN(0);
  @$pb.TagNumber(1)
  set bot(Bot v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasBot() => $_has(0);
  @$pb.TagNumber(1)
  void clearBot() => clearField(1);
  @$pb.TagNumber(1)
  Bot ensureBot() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.String get responseText => $_getSZ(1);
  @$pb.TagNumber(2)
  set responseText($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasResponseText() => $_has(1);
  @$pb.TagNumber(2)
  void clearResponseText() => clearField(2);

  @$pb.TagNumber(3)
  $core.bool get firstInteraction => $_getBF(2);
  @$pb.TagNumber(3)
  set firstInteraction($core.bool v) { $_setBool(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasFirstInteraction() => $_has(2);
  @$pb.TagNumber(3)
  void clearFirstInteraction() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get eventId => $_getSZ(3);
  @$pb.TagNumber(4)
  set eventId($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasEventId() => $_has(3);
  @$pb.TagNumber(4)
  void clearEventId() => clearField(4);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
