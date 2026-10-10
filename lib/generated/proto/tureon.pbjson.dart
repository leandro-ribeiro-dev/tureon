//
//  Generated code. Do not modify.
//  source: proto/tureon.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use messageTypeDescriptor instead')
const MessageType$json = {
  '1': 'MessageType',
  '2': [
    {'1': 'MESSAGE_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'MESSAGE_TYPE_TEXT', '2': 1},
    {'1': 'MESSAGE_TYPE_IMAGE', '2': 2},
    {'1': 'MESSAGE_TYPE_VIDEO', '2': 3},
    {'1': 'MESSAGE_TYPE_AUDIO', '2': 4},
    {'1': 'MESSAGE_TYPE_VOICE_NOTE', '2': 5},
    {'1': 'MESSAGE_TYPE_FILE', '2': 6},
    {'1': 'MESSAGE_TYPE_STICKER', '2': 7},
    {'1': 'MESSAGE_TYPE_GIF', '2': 8},
    {'1': 'MESSAGE_TYPE_LOCATION', '2': 9},
    {'1': 'MESSAGE_TYPE_CONTACT_CARD', '2': 10},
    {'1': 'MESSAGE_TYPE_REPLY', '2': 11},
    {'1': 'MESSAGE_TYPE_FORWARD', '2': 12},
    {'1': 'MESSAGE_TYPE_REACTION', '2': 13},
    {'1': 'MESSAGE_TYPE_EDIT', '2': 14},
    {'1': 'MESSAGE_TYPE_DELETE', '2': 15},
    {'1': 'MESSAGE_TYPE_SYSTEM', '2': 16},
  ],
};

/// Descriptor for `MessageType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List messageTypeDescriptor = $convert.base64Decode(
    'CgtNZXNzYWdlVHlwZRIcChhNRVNTQUdFX1RZUEVfVU5TUEVDSUZJRUQQABIVChFNRVNTQUdFX1'
    'RZUEVfVEVYVBABEhYKEk1FU1NBR0VfVFlQRV9JTUFHRRACEhYKEk1FU1NBR0VfVFlQRV9WSURF'
    'TxADEhYKEk1FU1NBR0VfVFlQRV9BVURJTxAEEhsKF01FU1NBR0VfVFlQRV9WT0lDRV9OT1RFEA'
    'USFQoRTUVTU0FHRV9UWVBFX0ZJTEUQBhIYChRNRVNTQUdFX1RZUEVfU1RJQ0tFUhAHEhQKEE1F'
    'U1NBR0VfVFlQRV9HSUYQCBIZChVNRVNTQUdFX1RZUEVfTE9DQVRJT04QCRIdChlNRVNTQUdFX1'
    'RZUEVfQ09OVEFDVF9DQVJEEAoSFgoSTUVTU0FHRV9UWVBFX1JFUExZEAsSGAoUTUVTU0FHRV9U'
    'WVBFX0ZPUldBUkQQDBIZChVNRVNTQUdFX1RZUEVfUkVBQ1RJT04QDRIVChFNRVNTQUdFX1RZUE'
    'VfRURJVBAOEhcKE01FU1NBR0VfVFlQRV9ERUxFVEUQDxIXChNNRVNTQUdFX1RZUEVfU1lTVEVN'
    'EBA=');

@$core.Deprecated('Use recipientTypeDescriptor instead')
const RecipientType$json = {
  '1': 'RecipientType',
  '2': [
    {'1': 'RECIPIENT_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'RECIPIENT_TYPE_USER', '2': 1},
    {'1': 'RECIPIENT_TYPE_GROUP', '2': 2},
    {'1': 'RECIPIENT_TYPE_CHANNEL', '2': 3},
    {'1': 'RECIPIENT_TYPE_BOT', '2': 4},
  ],
};

/// Descriptor for `RecipientType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List recipientTypeDescriptor = $convert.base64Decode(
    'Cg1SZWNpcGllbnRUeXBlEh4KGlJFQ0lQSUVOVF9UWVBFX1VOU1BFQ0lGSUVEEAASFwoTUkVDSV'
    'BJRU5UX1RZUEVfVVNFUhABEhgKFFJFQ0lQSUVOVF9UWVBFX0dST1VQEAISGgoWUkVDSVBJRU5U'
    'X1RZUEVfQ0hBTk5FTBADEhYKElJFQ0lQSUVOVF9UWVBFX0JPVBAE');

@$core.Deprecated('Use deliveryStatusDescriptor instead')
const DeliveryStatus$json = {
  '1': 'DeliveryStatus',
  '2': [
    {'1': 'DELIVERY_STATUS_UNSPECIFIED', '2': 0},
    {'1': 'DELIVERY_STATUS_SENT', '2': 1},
    {'1': 'DELIVERY_STATUS_DELIVERED', '2': 2},
    {'1': 'DELIVERY_STATUS_READ', '2': 3},
  ],
};

/// Descriptor for `DeliveryStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List deliveryStatusDescriptor = $convert.base64Decode(
    'Cg5EZWxpdmVyeVN0YXR1cxIfChtERUxJVkVSWV9TVEFUVVNfVU5TUEVDSUZJRUQQABIYChRERU'
    'xJVkVSWV9TVEFUVVNfU0VOVBABEh0KGURFTElWRVJZX1NUQVRVU19ERUxJVkVSRUQQAhIYChRE'
    'RUxJVkVSWV9TVEFUVVNfUkVBRBAD');

@$core.Deprecated('Use chatKindDescriptor instead')
const ChatKind$json = {
  '1': 'ChatKind',
  '2': [
    {'1': 'CHAT_KIND_UNSPECIFIED', '2': 0},
    {'1': 'CHAT_KIND_NORMAL', '2': 1},
    {'1': 'CHAT_KIND_SECRET', '2': 2},
  ],
};

/// Descriptor for `ChatKind`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List chatKindDescriptor = $convert.base64Decode(
    'CghDaGF0S2luZBIZChVDSEFUX0tJTkRfVU5TUEVDSUZJRUQQABIUChBDSEFUX0tJTkRfTk9STU'
    'FMEAESFAoQQ0hBVF9LSU5EX1NFQ1JFVBAC');

@$core.Deprecated('Use sendMessageStatusDescriptor instead')
const SendMessageStatus$json = {
  '1': 'SendMessageStatus',
  '2': [
    {'1': 'SEND_MESSAGE_STATUS_UNSPECIFIED', '2': 0},
    {'1': 'SEND_MESSAGE_STATUS_ACCEPTED', '2': 1},
    {'1': 'SEND_MESSAGE_STATUS_DUPLICATE', '2': 2},
  ],
};

/// Descriptor for `SendMessageStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List sendMessageStatusDescriptor = $convert.base64Decode(
    'ChFTZW5kTWVzc2FnZVN0YXR1cxIjCh9TRU5EX01FU1NBR0VfU1RBVFVTX1VOU1BFQ0lGSUVEEA'
    'ASIAocU0VORF9NRVNTQUdFX1NUQVRVU19BQ0NFUFRFRBABEiEKHVNFTkRfTUVTU0FHRV9TVEFU'
    'VVNfRFVQTElDQVRFEAI=');

@$core.Deprecated('Use messageDeliveryEventTypeDescriptor instead')
const MessageDeliveryEventType$json = {
  '1': 'MessageDeliveryEventType',
  '2': [
    {'1': 'MESSAGE_DELIVERY_EVENT_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'MESSAGE_DELIVERY_EVENT_TYPE_MESSAGE', '2': 1},
    {'1': 'MESSAGE_DELIVERY_EVENT_TYPE_RECEIPT', '2': 2},
    {'1': 'MESSAGE_DELIVERY_EVENT_TYPE_EDITED', '2': 3},
    {'1': 'MESSAGE_DELIVERY_EVENT_TYPE_DELETED', '2': 4},
  ],
};

/// Descriptor for `MessageDeliveryEventType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List messageDeliveryEventTypeDescriptor = $convert.base64Decode(
    'ChhNZXNzYWdlRGVsaXZlcnlFdmVudFR5cGUSKwonTUVTU0FHRV9ERUxJVkVSWV9FVkVOVF9UWV'
    'BFX1VOU1BFQ0lGSUVEEAASJwojTUVTU0FHRV9ERUxJVkVSWV9FVkVOVF9UWVBFX01FU1NBR0UQ'
    'ARInCiNNRVNTQUdFX0RFTElWRVJZX0VWRU5UX1RZUEVfUkVDRUlQVBACEiYKIk1FU1NBR0VfRE'
    'VMSVZFUllfRVZFTlRfVFlQRV9FRElURUQQAxInCiNNRVNTQUdFX0RFTElWRVJZX0VWRU5UX1RZ'
    'UEVfREVMRVRFRBAE');

@$core.Deprecated('Use messageMutationTypeDescriptor instead')
const MessageMutationType$json = {
  '1': 'MessageMutationType',
  '2': [
    {'1': 'MESSAGE_MUTATION_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'MESSAGE_MUTATION_TYPE_EDIT', '2': 1},
    {'1': 'MESSAGE_MUTATION_TYPE_DELETE', '2': 2},
  ],
};

/// Descriptor for `MessageMutationType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List messageMutationTypeDescriptor = $convert.base64Decode(
    'ChNNZXNzYWdlTXV0YXRpb25UeXBlEiUKIU1FU1NBR0VfTVVUQVRJT05fVFlQRV9VTlNQRUNJRk'
    'lFRBAAEh4KGk1FU1NBR0VfTVVUQVRJT05fVFlQRV9FRElUEAESIAocTUVTU0FHRV9NVVRBVElP'
    'Tl9UWVBFX0RFTEVURRAC');

@$core.Deprecated('Use systemEventTypeDescriptor instead')
const SystemEventType$json = {
  '1': 'SystemEventType',
  '2': [
    {'1': 'SYSTEM_EVENT_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'SYSTEM_EVENT_TYPE_USER_JOINED_GROUP', '2': 1},
    {'1': 'SYSTEM_EVENT_TYPE_USER_LEFT_GROUP', '2': 2},
    {'1': 'SYSTEM_EVENT_TYPE_USER_ADDED_TO_GROUP', '2': 3},
    {'1': 'SYSTEM_EVENT_TYPE_USER_REMOVED_FROM_GROUP', '2': 4},
    {'1': 'SYSTEM_EVENT_TYPE_USER_BANNED_FROM_GROUP', '2': 5},
    {'1': 'SYSTEM_EVENT_TYPE_USER_UNBANNED_FROM_GROUP', '2': 6},
    {'1': 'SYSTEM_EVENT_TYPE_GROUP_CREATED', '2': 7},
    {'1': 'SYSTEM_EVENT_TYPE_GROUP_RENAMED', '2': 8},
    {'1': 'SYSTEM_EVENT_TYPE_GROUP_AVATAR_CHANGED', '2': 9},
    {'1': 'SYSTEM_EVENT_TYPE_USER_JOINED_CHANNEL', '2': 10},
    {'1': 'SYSTEM_EVENT_TYPE_USER_LEFT_CHANNEL', '2': 11},
    {'1': 'SYSTEM_EVENT_TYPE_CHANNEL_CREATED', '2': 12},
    {'1': 'SYSTEM_EVENT_TYPE_CHANNEL_RENAMED', '2': 13},
    {'1': 'SYSTEM_EVENT_TYPE_CHANNEL_BROADCAST', '2': 14},
    {'1': 'SYSTEM_EVENT_TYPE_USER_MUTED', '2': 15},
    {'1': 'SYSTEM_EVENT_TYPE_USER_UNMUTED', '2': 16},
    {'1': 'SYSTEM_EVENT_TYPE_BOT_ADDED', '2': 17},
    {'1': 'SYSTEM_EVENT_TYPE_BOT_REMOVED', '2': 18},
    {'1': 'SYSTEM_EVENT_TYPE_GROUP_UPDATED', '2': 19},
    {'1': 'SYSTEM_EVENT_TYPE_USER_ADDED_TO_CHANNEL', '2': 20},
    {'1': 'SYSTEM_EVENT_TYPE_USER_REMOVED_FROM_CHANNEL', '2': 21},
    {'1': 'SYSTEM_EVENT_TYPE_USER_BANNED_FROM_CHANNEL', '2': 22},
    {'1': 'SYSTEM_EVENT_TYPE_USER_ROLE_CHANGED', '2': 23},
    {'1': 'SYSTEM_EVENT_TYPE_CHANNEL_UPDATED', '2': 24},
    {'1': 'SYSTEM_EVENT_TYPE_GROUP_POLICY_CHANGED', '2': 25},
    {'1': 'SYSTEM_EVENT_TYPE_CHANNEL_POLICY_CHANGED', '2': 26},
  ],
};

/// Descriptor for `SystemEventType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List systemEventTypeDescriptor = $convert.base64Decode(
    'Cg9TeXN0ZW1FdmVudFR5cGUSIQodU1lTVEVNX0VWRU5UX1RZUEVfVU5TUEVDSUZJRUQQABInCi'
    'NTWVNURU1fRVZFTlRfVFlQRV9VU0VSX0pPSU5FRF9HUk9VUBABEiUKIVNZU1RFTV9FVkVOVF9U'
    'WVBFX1VTRVJfTEVGVF9HUk9VUBACEikKJVNZU1RFTV9FVkVOVF9UWVBFX1VTRVJfQURERURfVE'
    '9fR1JPVVAQAxItCilTWVNURU1fRVZFTlRfVFlQRV9VU0VSX1JFTU9WRURfRlJPTV9HUk9VUBAE'
    'EiwKKFNZU1RFTV9FVkVOVF9UWVBFX1VTRVJfQkFOTkVEX0ZST01fR1JPVVAQBRIuCipTWVNURU'
    '1fRVZFTlRfVFlQRV9VU0VSX1VOQkFOTkVEX0ZST01fR1JPVVAQBhIjCh9TWVNURU1fRVZFTlRf'
    'VFlQRV9HUk9VUF9DUkVBVEVEEAcSIwofU1lTVEVNX0VWRU5UX1RZUEVfR1JPVVBfUkVOQU1FRB'
    'AIEioKJlNZU1RFTV9FVkVOVF9UWVBFX0dST1VQX0FWQVRBUl9DSEFOR0VEEAkSKQolU1lTVEVN'
    'X0VWRU5UX1RZUEVfVVNFUl9KT0lORURfQ0hBTk5FTBAKEicKI1NZU1RFTV9FVkVOVF9UWVBFX1'
    'VTRVJfTEVGVF9DSEFOTkVMEAsSJQohU1lTVEVNX0VWRU5UX1RZUEVfQ0hBTk5FTF9DUkVBVEVE'
    'EAwSJQohU1lTVEVNX0VWRU5UX1RZUEVfQ0hBTk5FTF9SRU5BTUVEEA0SJwojU1lTVEVNX0VWRU'
    '5UX1RZUEVfQ0hBTk5FTF9CUk9BRENBU1QQDhIgChxTWVNURU1fRVZFTlRfVFlQRV9VU0VSX01V'
    'VEVEEA8SIgoeU1lTVEVNX0VWRU5UX1RZUEVfVVNFUl9VTk1VVEVEEBASHwobU1lTVEVNX0VWRU'
    '5UX1RZUEVfQk9UX0FEREVEEBESIQodU1lTVEVNX0VWRU5UX1RZUEVfQk9UX1JFTU9WRUQQEhIj'
    'Ch9TWVNURU1fRVZFTlRfVFlQRV9HUk9VUF9VUERBVEVEEBMSKwonU1lTVEVNX0VWRU5UX1RZUE'
    'VfVVNFUl9BRERFRF9UT19DSEFOTkVMEBQSLworU1lTVEVNX0VWRU5UX1RZUEVfVVNFUl9SRU1P'
    'VkVEX0ZST01fQ0hBTk5FTBAVEi4KKlNZU1RFTV9FVkVOVF9UWVBFX1VTRVJfQkFOTkVEX0ZST0'
    '1fQ0hBTk5FTBAWEicKI1NZU1RFTV9FVkVOVF9UWVBFX1VTRVJfUk9MRV9DSEFOR0VEEBcSJQoh'
    'U1lTVEVNX0VWRU5UX1RZUEVfQ0hBTk5FTF9VUERBVEVEEBgSKgomU1lTVEVNX0VWRU5UX1RZUE'
    'VfR1JPVVBfUE9MSUNZX0NIQU5HRUQQGRIsCihTWVNURU1fRVZFTlRfVFlQRV9DSEFOTkVMX1BP'
    'TElDWV9DSEFOR0VEEBo=');

@$core.Deprecated('Use sendMessageRequestDescriptor instead')
const SendMessageRequest$json = {
  '1': 'SendMessageRequest',
  '2': [
    {'1': 'message_id', '3': 1, '4': 1, '5': 9, '10': 'messageId'},
    {'1': 'chat_id', '3': 2, '4': 1, '5': 9, '10': 'chatId'},
    {'1': 'sender_recipient_id', '3': 3, '4': 1, '5': 9, '10': 'senderRecipientId'},
    {'1': 'sender_device_id', '3': 4, '4': 1, '5': 9, '10': 'senderDeviceId'},
    {'1': 'target_recipient_id', '3': 5, '4': 1, '5': 9, '10': 'targetRecipientId'},
    {'1': 'chat_kind', '3': 6, '4': 1, '5': 14, '6': '.tureon.v1.ChatKind', '10': 'chatKind'},
    {'1': 'message_type', '3': 7, '4': 1, '5': 14, '6': '.tureon.v1.MessageType', '10': 'messageType'},
    {'1': 'payload', '3': 8, '4': 1, '5': 12, '10': 'payload'},
    {'1': 'target_device_id', '3': 9, '4': 1, '5': 9, '10': 'targetDeviceId'},
  ],
};

/// Descriptor for `SendMessageRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sendMessageRequestDescriptor = $convert.base64Decode(
    'ChJTZW5kTWVzc2FnZVJlcXVlc3QSHQoKbWVzc2FnZV9pZBgBIAEoCVIJbWVzc2FnZUlkEhcKB2'
    'NoYXRfaWQYAiABKAlSBmNoYXRJZBIuChNzZW5kZXJfcmVjaXBpZW50X2lkGAMgASgJUhFzZW5k'
    'ZXJSZWNpcGllbnRJZBIoChBzZW5kZXJfZGV2aWNlX2lkGAQgASgJUg5zZW5kZXJEZXZpY2VJZB'
    'IuChN0YXJnZXRfcmVjaXBpZW50X2lkGAUgASgJUhF0YXJnZXRSZWNpcGllbnRJZBIwCgljaGF0'
    'X2tpbmQYBiABKA4yEy50dXJlb24udjEuQ2hhdEtpbmRSCGNoYXRLaW5kEjkKDG1lc3NhZ2VfdH'
    'lwZRgHIAEoDjIWLnR1cmVvbi52MS5NZXNzYWdlVHlwZVILbWVzc2FnZVR5cGUSGAoHcGF5bG9h'
    'ZBgIIAEoDFIHcGF5bG9hZBIoChB0YXJnZXRfZGV2aWNlX2lkGAkgASgJUg50YXJnZXREZXZpY2'
    'VJZA==');

@$core.Deprecated('Use sendMessageResponseDescriptor instead')
const SendMessageResponse$json = {
  '1': 'SendMessageResponse',
  '2': [
    {'1': 'message_id', '3': 1, '4': 1, '5': 9, '10': 'messageId'},
    {'1': 'queued_devices', '3': 2, '4': 1, '5': 5, '10': 'queuedDevices'},
    {'1': 'server_timestamp', '3': 3, '4': 1, '5': 3, '10': 'serverTimestamp'},
    {'1': 'status', '3': 4, '4': 1, '5': 14, '6': '.tureon.v1.SendMessageStatus', '10': 'status'},
    {'1': 'server_timestamp_micros', '3': 5, '4': 1, '5': 3, '10': 'serverTimestampMicros'},
  ],
};

/// Descriptor for `SendMessageResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sendMessageResponseDescriptor = $convert.base64Decode(
    'ChNTZW5kTWVzc2FnZVJlc3BvbnNlEh0KCm1lc3NhZ2VfaWQYASABKAlSCW1lc3NhZ2VJZBIlCg'
    '5xdWV1ZWRfZGV2aWNlcxgCIAEoBVINcXVldWVkRGV2aWNlcxIpChBzZXJ2ZXJfdGltZXN0YW1w'
    'GAMgASgDUg9zZXJ2ZXJUaW1lc3RhbXASNAoGc3RhdHVzGAQgASgOMhwudHVyZW9uLnYxLlNlbm'
    'RNZXNzYWdlU3RhdHVzUgZzdGF0dXMSNgoXc2VydmVyX3RpbWVzdGFtcF9taWNyb3MYBSABKANS'
    'FXNlcnZlclRpbWVzdGFtcE1pY3Jvcw==');

@$core.Deprecated('Use messageDeliveryDescriptor instead')
const MessageDelivery$json = {
  '1': 'MessageDelivery',
  '2': [
    {'1': 'delivery_id', '3': 1, '4': 1, '5': 9, '10': 'deliveryId'},
    {'1': 'message_id', '3': 2, '4': 1, '5': 9, '10': 'messageId'},
    {'1': 'chat_id', '3': 3, '4': 1, '5': 9, '10': 'chatId'},
    {'1': 'sender_recipient_id', '3': 4, '4': 1, '5': 9, '10': 'senderRecipientId'},
    {'1': 'target_recipient_id', '3': 5, '4': 1, '5': 9, '10': 'targetRecipientId'},
    {'1': 'target_device_id', '3': 6, '4': 1, '5': 9, '10': 'targetDeviceId'},
    {'1': 'chat_kind', '3': 7, '4': 1, '5': 14, '6': '.tureon.v1.ChatKind', '10': 'chatKind'},
    {'1': 'message_type', '3': 8, '4': 1, '5': 14, '6': '.tureon.v1.MessageType', '10': 'messageType'},
    {'1': 'payload', '3': 9, '4': 1, '5': 12, '10': 'payload'},
    {'1': 'created_at', '3': 10, '4': 1, '5': 3, '10': 'createdAt'},
    {'1': 'sender_device_id', '3': 11, '4': 1, '5': 9, '10': 'senderDeviceId'},
    {'1': 'event_type', '3': 12, '4': 1, '5': 14, '6': '.tureon.v1.MessageDeliveryEventType', '10': 'eventType'},
    {'1': 'receipt_status', '3': 13, '4': 1, '5': 14, '6': '.tureon.v1.DeliveryStatus', '10': 'receiptStatus'},
    {'1': 'event_id', '3': 14, '4': 1, '5': 9, '10': 'eventId'},
    {'1': 'created_at_micros', '3': 15, '4': 1, '5': 3, '10': 'createdAtMicros'},
    {'1': 'room_sequence', '3': 16, '4': 1, '5': 3, '10': 'roomSequence'},
    {'1': 'room_id', '3': 17, '4': 1, '5': 9, '10': 'roomId'},
  ],
};

/// Descriptor for `MessageDelivery`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List messageDeliveryDescriptor = $convert.base64Decode(
    'Cg9NZXNzYWdlRGVsaXZlcnkSHwoLZGVsaXZlcnlfaWQYASABKAlSCmRlbGl2ZXJ5SWQSHQoKbW'
    'Vzc2FnZV9pZBgCIAEoCVIJbWVzc2FnZUlkEhcKB2NoYXRfaWQYAyABKAlSBmNoYXRJZBIuChNz'
    'ZW5kZXJfcmVjaXBpZW50X2lkGAQgASgJUhFzZW5kZXJSZWNpcGllbnRJZBIuChN0YXJnZXRfcm'
    'VjaXBpZW50X2lkGAUgASgJUhF0YXJnZXRSZWNpcGllbnRJZBIoChB0YXJnZXRfZGV2aWNlX2lk'
    'GAYgASgJUg50YXJnZXREZXZpY2VJZBIwCgljaGF0X2tpbmQYByABKA4yEy50dXJlb24udjEuQ2'
    'hhdEtpbmRSCGNoYXRLaW5kEjkKDG1lc3NhZ2VfdHlwZRgIIAEoDjIWLnR1cmVvbi52MS5NZXNz'
    'YWdlVHlwZVILbWVzc2FnZVR5cGUSGAoHcGF5bG9hZBgJIAEoDFIHcGF5bG9hZBIdCgpjcmVhdG'
    'VkX2F0GAogASgDUgljcmVhdGVkQXQSKAoQc2VuZGVyX2RldmljZV9pZBgLIAEoCVIOc2VuZGVy'
    'RGV2aWNlSWQSQgoKZXZlbnRfdHlwZRgMIAEoDjIjLnR1cmVvbi52MS5NZXNzYWdlRGVsaXZlcn'
    'lFdmVudFR5cGVSCWV2ZW50VHlwZRJACg5yZWNlaXB0X3N0YXR1cxgNIAEoDjIZLnR1cmVvbi52'
    'MS5EZWxpdmVyeVN0YXR1c1INcmVjZWlwdFN0YXR1cxIZCghldmVudF9pZBgOIAEoCVIHZXZlbn'
    'RJZBIqChFjcmVhdGVkX2F0X21pY3JvcxgPIAEoA1IPY3JlYXRlZEF0TWljcm9zEiMKDXJvb21f'
    'c2VxdWVuY2UYECABKANSDHJvb21TZXF1ZW5jZRIXCgdyb29tX2lkGBEgASgJUgZyb29tSWQ=');

@$core.Deprecated('Use deliveryAcknowledgementDescriptor instead')
const DeliveryAcknowledgement$json = {
  '1': 'DeliveryAcknowledgement',
  '2': [
    {'1': 'delivery_id', '3': 1, '4': 1, '5': 9, '10': 'deliveryId'},
    {'1': 'target_device_id', '3': 2, '4': 1, '5': 9, '10': 'targetDeviceId'},
  ],
};

/// Descriptor for `DeliveryAcknowledgement`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deliveryAcknowledgementDescriptor = $convert.base64Decode(
    'ChdEZWxpdmVyeUFja25vd2xlZGdlbWVudBIfCgtkZWxpdmVyeV9pZBgBIAEoCVIKZGVsaXZlcn'
    'lJZBIoChB0YXJnZXRfZGV2aWNlX2lkGAIgASgJUg50YXJnZXREZXZpY2VJZA==');

@$core.Deprecated('Use ackDeliveryRequestDescriptor instead')
const AckDeliveryRequest$json = {
  '1': 'AckDeliveryRequest',
  '2': [
    {'1': 'delivery_id', '3': 1, '4': 1, '5': 9, '10': 'deliveryId'},
    {'1': 'target_device_id', '3': 2, '4': 1, '5': 9, '10': 'targetDeviceId'},
    {'1': 'deliveries', '3': 3, '4': 3, '5': 11, '6': '.tureon.v1.DeliveryAcknowledgement', '10': 'deliveries'},
  ],
};

/// Descriptor for `AckDeliveryRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List ackDeliveryRequestDescriptor = $convert.base64Decode(
    'ChJBY2tEZWxpdmVyeVJlcXVlc3QSHwoLZGVsaXZlcnlfaWQYASABKAlSCmRlbGl2ZXJ5SWQSKA'
    'oQdGFyZ2V0X2RldmljZV9pZBgCIAEoCVIOdGFyZ2V0RGV2aWNlSWQSQgoKZGVsaXZlcmllcxgD'
    'IAMoCzIiLnR1cmVvbi52MS5EZWxpdmVyeUFja25vd2xlZGdlbWVudFIKZGVsaXZlcmllcw==');

@$core.Deprecated('Use sendReadReceiptRequestDescriptor instead')
const SendReadReceiptRequest$json = {
  '1': 'SendReadReceiptRequest',
  '2': [
    {'1': 'sender_recipient_id', '3': 1, '4': 1, '5': 9, '10': 'senderRecipientId'},
    {'1': 'message_id', '3': 2, '4': 1, '5': 9, '10': 'messageId'},
  ],
};

/// Descriptor for `SendReadReceiptRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sendReadReceiptRequestDescriptor = $convert.base64Decode(
    'ChZTZW5kUmVhZFJlY2VpcHRSZXF1ZXN0Ei4KE3NlbmRlcl9yZWNpcGllbnRfaWQYASABKAlSEX'
    'NlbmRlclJlY2lwaWVudElkEh0KCm1lc3NhZ2VfaWQYAiABKAlSCW1lc3NhZ2VJZA==');

@$core.Deprecated('Use sendMessageMutationRequestDescriptor instead')
const SendMessageMutationRequest$json = {
  '1': 'SendMessageMutationRequest',
  '2': [
    {'1': 'mutation_id', '3': 1, '4': 1, '5': 9, '10': 'mutationId'},
    {'1': 'message_id', '3': 2, '4': 1, '5': 9, '10': 'messageId'},
    {'1': 'chat_id', '3': 3, '4': 1, '5': 9, '10': 'chatId'},
    {'1': 'sender_recipient_id', '3': 4, '4': 1, '5': 9, '10': 'senderRecipientId'},
    {'1': 'sender_device_id', '3': 5, '4': 1, '5': 9, '10': 'senderDeviceId'},
    {'1': 'target_recipient_id', '3': 6, '4': 1, '5': 9, '10': 'targetRecipientId'},
    {'1': 'target_device_id', '3': 7, '4': 1, '5': 9, '10': 'targetDeviceId'},
    {'1': 'chat_kind', '3': 8, '4': 1, '5': 14, '6': '.tureon.v1.ChatKind', '10': 'chatKind'},
    {'1': 'mutation_type', '3': 9, '4': 1, '5': 14, '6': '.tureon.v1.MessageMutationType', '10': 'mutationType'},
    {'1': 'payload', '3': 10, '4': 1, '5': 12, '10': 'payload'},
  ],
};

/// Descriptor for `SendMessageMutationRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sendMessageMutationRequestDescriptor = $convert.base64Decode(
    'ChpTZW5kTWVzc2FnZU11dGF0aW9uUmVxdWVzdBIfCgttdXRhdGlvbl9pZBgBIAEoCVIKbXV0YX'
    'Rpb25JZBIdCgptZXNzYWdlX2lkGAIgASgJUgltZXNzYWdlSWQSFwoHY2hhdF9pZBgDIAEoCVIG'
    'Y2hhdElkEi4KE3NlbmRlcl9yZWNpcGllbnRfaWQYBCABKAlSEXNlbmRlclJlY2lwaWVudElkEi'
    'gKEHNlbmRlcl9kZXZpY2VfaWQYBSABKAlSDnNlbmRlckRldmljZUlkEi4KE3RhcmdldF9yZWNp'
    'cGllbnRfaWQYBiABKAlSEXRhcmdldFJlY2lwaWVudElkEigKEHRhcmdldF9kZXZpY2VfaWQYBy'
    'ABKAlSDnRhcmdldERldmljZUlkEjAKCWNoYXRfa2luZBgIIAEoDjITLnR1cmVvbi52MS5DaGF0'
    'S2luZFIIY2hhdEtpbmQSQwoNbXV0YXRpb25fdHlwZRgJIAEoDjIeLnR1cmVvbi52MS5NZXNzYW'
    'dlTXV0YXRpb25UeXBlUgxtdXRhdGlvblR5cGUSGAoHcGF5bG9hZBgKIAEoDFIHcGF5bG9hZA==');

@$core.Deprecated('Use chatStreamOpenDescriptor instead')
const ChatStreamOpen$json = {
  '1': 'ChatStreamOpen',
  '2': [
    {'1': 'recipient_id', '3': 1, '4': 1, '5': 9, '10': 'recipientId'},
    {'1': 'device_id', '3': 2, '4': 1, '5': 9, '10': 'deviceId'},
  ],
};

/// Descriptor for `ChatStreamOpen`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List chatStreamOpenDescriptor = $convert.base64Decode(
    'Cg5DaGF0U3RyZWFtT3BlbhIhCgxyZWNpcGllbnRfaWQYASABKAlSC3JlY2lwaWVudElkEhsKCW'
    'RldmljZV9pZBgCIAEoCVIIZGV2aWNlSWQ=');

@$core.Deprecated('Use chatStreamBatchCommandDescriptor instead')
const ChatStreamBatchCommand$json = {
  '1': 'ChatStreamBatchCommand',
  '2': [
    {'1': 'command_id', '3': 1, '4': 1, '5': 9, '10': 'commandId'},
    {'1': 'send_message', '3': 2, '4': 1, '5': 11, '6': '.tureon.v1.SendMessageRequest', '9': 0, '10': 'sendMessage'},
    {'1': 'interact_bot', '3': 3, '4': 1, '5': 11, '6': '.tureon.v1.InteractBotRequest', '9': 0, '10': 'interactBot'},
  ],
  '8': [
    {'1': 'command'},
  ],
};

/// Descriptor for `ChatStreamBatchCommand`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List chatStreamBatchCommandDescriptor = $convert.base64Decode(
    'ChZDaGF0U3RyZWFtQmF0Y2hDb21tYW5kEh0KCmNvbW1hbmRfaWQYASABKAlSCWNvbW1hbmRJZB'
    'JCCgxzZW5kX21lc3NhZ2UYAiABKAsyHS50dXJlb24udjEuU2VuZE1lc3NhZ2VSZXF1ZXN0SABS'
    'C3NlbmRNZXNzYWdlEkIKDGludGVyYWN0X2JvdBgDIAEoCzIdLnR1cmVvbi52MS5JbnRlcmFjdE'
    'JvdFJlcXVlc3RIAFILaW50ZXJhY3RCb3RCCQoHY29tbWFuZA==');

@$core.Deprecated('Use chatStreamBatchRequestDescriptor instead')
const ChatStreamBatchRequest$json = {
  '1': 'ChatStreamBatchRequest',
  '2': [
    {'1': 'commands', '3': 1, '4': 3, '5': 11, '6': '.tureon.v1.ChatStreamBatchCommand', '10': 'commands'},
  ],
};

/// Descriptor for `ChatStreamBatchRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List chatStreamBatchRequestDescriptor = $convert.base64Decode(
    'ChZDaGF0U3RyZWFtQmF0Y2hSZXF1ZXN0Ej0KCGNvbW1hbmRzGAEgAygLMiEudHVyZW9uLnYxLk'
    'NoYXRTdHJlYW1CYXRjaENvbW1hbmRSCGNvbW1hbmRz');

@$core.Deprecated('Use chatStreamBatchResultDescriptor instead')
const ChatStreamBatchResult$json = {
  '1': 'ChatStreamBatchResult',
  '2': [
    {'1': 'command_id', '3': 1, '4': 1, '5': 9, '10': 'commandId'},
    {'1': 'send_message', '3': 2, '4': 1, '5': 11, '6': '.tureon.v1.SendMessageResponse', '9': 0, '10': 'sendMessage'},
    {'1': 'bot_interaction', '3': 3, '4': 1, '5': 11, '6': '.tureon.v1.InteractBotResponse', '9': 0, '10': 'botInteraction'},
    {'1': 'status_code', '3': 4, '4': 1, '5': 5, '10': 'statusCode'},
    {'1': 'message', '3': 5, '4': 1, '5': 9, '10': 'message'},
  ],
  '8': [
    {'1': 'result'},
  ],
};

/// Descriptor for `ChatStreamBatchResult`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List chatStreamBatchResultDescriptor = $convert.base64Decode(
    'ChVDaGF0U3RyZWFtQmF0Y2hSZXN1bHQSHQoKY29tbWFuZF9pZBgBIAEoCVIJY29tbWFuZElkEk'
    'MKDHNlbmRfbWVzc2FnZRgCIAEoCzIeLnR1cmVvbi52MS5TZW5kTWVzc2FnZVJlc3BvbnNlSABS'
    'C3NlbmRNZXNzYWdlEkkKD2JvdF9pbnRlcmFjdGlvbhgDIAEoCzIeLnR1cmVvbi52MS5JbnRlcm'
    'FjdEJvdFJlc3BvbnNlSABSDmJvdEludGVyYWN0aW9uEh8KC3N0YXR1c19jb2RlGAQgASgFUgpz'
    'dGF0dXNDb2RlEhgKB21lc3NhZ2UYBSABKAlSB21lc3NhZ2VCCAoGcmVzdWx0');

@$core.Deprecated('Use chatStreamBatchResponseDescriptor instead')
const ChatStreamBatchResponse$json = {
  '1': 'ChatStreamBatchResponse',
  '2': [
    {'1': 'results', '3': 1, '4': 3, '5': 11, '6': '.tureon.v1.ChatStreamBatchResult', '10': 'results'},
  ],
};

/// Descriptor for `ChatStreamBatchResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List chatStreamBatchResponseDescriptor = $convert.base64Decode(
    'ChdDaGF0U3RyZWFtQmF0Y2hSZXNwb25zZRI6CgdyZXN1bHRzGAEgAygLMiAudHVyZW9uLnYxLk'
    'NoYXRTdHJlYW1CYXRjaFJlc3VsdFIHcmVzdWx0cw==');

@$core.Deprecated('Use chatStreamRequestDescriptor instead')
const ChatStreamRequest$json = {
  '1': 'ChatStreamRequest',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 9, '10': 'requestId'},
    {'1': 'open', '3': 2, '4': 1, '5': 11, '6': '.tureon.v1.ChatStreamOpen', '9': 0, '10': 'open'},
    {'1': 'send_message', '3': 3, '4': 1, '5': 11, '6': '.tureon.v1.SendMessageRequest', '9': 0, '10': 'sendMessage'},
    {'1': 'acknowledge', '3': 4, '4': 1, '5': 11, '6': '.tureon.v1.AckDeliveryRequest', '9': 0, '10': 'acknowledge'},
    {'1': 'read_receipt', '3': 5, '4': 1, '5': 11, '6': '.tureon.v1.SendReadReceiptRequest', '9': 0, '10': 'readReceipt'},
    {'1': 'mutate_message', '3': 6, '4': 1, '5': 11, '6': '.tureon.v1.SendMessageMutationRequest', '9': 0, '10': 'mutateMessage'},
    {'1': 'interact_bot', '3': 7, '4': 1, '5': 11, '6': '.tureon.v1.InteractBotRequest', '9': 0, '10': 'interactBot'},
    {'1': 'batch', '3': 8, '4': 1, '5': 11, '6': '.tureon.v1.ChatStreamBatchRequest', '9': 0, '10': 'batch'},
  ],
  '8': [
    {'1': 'command'},
  ],
};

/// Descriptor for `ChatStreamRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List chatStreamRequestDescriptor = $convert.base64Decode(
    'ChFDaGF0U3RyZWFtUmVxdWVzdBIdCgpyZXF1ZXN0X2lkGAEgASgJUglyZXF1ZXN0SWQSLwoEb3'
    'BlbhgCIAEoCzIZLnR1cmVvbi52MS5DaGF0U3RyZWFtT3BlbkgAUgRvcGVuEkIKDHNlbmRfbWVz'
    'c2FnZRgDIAEoCzIdLnR1cmVvbi52MS5TZW5kTWVzc2FnZVJlcXVlc3RIAFILc2VuZE1lc3NhZ2'
    'USQQoLYWNrbm93bGVkZ2UYBCABKAsyHS50dXJlb24udjEuQWNrRGVsaXZlcnlSZXF1ZXN0SABS'
    'C2Fja25vd2xlZGdlEkYKDHJlYWRfcmVjZWlwdBgFIAEoCzIhLnR1cmVvbi52MS5TZW5kUmVhZF'
    'JlY2VpcHRSZXF1ZXN0SABSC3JlYWRSZWNlaXB0Ek4KDm11dGF0ZV9tZXNzYWdlGAYgASgLMiUu'
    'dHVyZW9uLnYxLlNlbmRNZXNzYWdlTXV0YXRpb25SZXF1ZXN0SABSDW11dGF0ZU1lc3NhZ2USQg'
    'oMaW50ZXJhY3RfYm90GAcgASgLMh0udHVyZW9uLnYxLkludGVyYWN0Qm90UmVxdWVzdEgAUgtp'
    'bnRlcmFjdEJvdBI5CgViYXRjaBgIIAEoCzIhLnR1cmVvbi52MS5DaGF0U3RyZWFtQmF0Y2hSZX'
    'F1ZXN0SABSBWJhdGNoQgkKB2NvbW1hbmQ=');

@$core.Deprecated('Use chatStreamReadyDescriptor instead')
const ChatStreamReady$json = {
  '1': 'ChatStreamReady',
  '2': [
    {'1': 'recipient_id', '3': 1, '4': 1, '5': 9, '10': 'recipientId'},
    {'1': 'device_id', '3': 2, '4': 1, '5': 9, '10': 'deviceId'},
  ],
};

/// Descriptor for `ChatStreamReady`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List chatStreamReadyDescriptor = $convert.base64Decode(
    'Cg9DaGF0U3RyZWFtUmVhZHkSIQoMcmVjaXBpZW50X2lkGAEgASgJUgtyZWNpcGllbnRJZBIbCg'
    'lkZXZpY2VfaWQYAiABKAlSCGRldmljZUlk');

@$core.Deprecated('Use chatStreamCommandResultDescriptor instead')
const ChatStreamCommandResult$json = {
  '1': 'ChatStreamCommandResult',
  '2': [
    {'1': 'accepted', '3': 1, '4': 1, '5': 8, '10': 'accepted'},
    {'1': 'status_code', '3': 2, '4': 1, '5': 5, '10': 'statusCode'},
    {'1': 'message', '3': 3, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `ChatStreamCommandResult`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List chatStreamCommandResultDescriptor = $convert.base64Decode(
    'ChdDaGF0U3RyZWFtQ29tbWFuZFJlc3VsdBIaCghhY2NlcHRlZBgBIAEoCFIIYWNjZXB0ZWQSHw'
    'oLc3RhdHVzX2NvZGUYAiABKAVSCnN0YXR1c0NvZGUSGAoHbWVzc2FnZRgDIAEoCVIHbWVzc2Fn'
    'ZQ==');

@$core.Deprecated('Use chatStreamResponseDescriptor instead')
const ChatStreamResponse$json = {
  '1': 'ChatStreamResponse',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 9, '10': 'requestId'},
    {'1': 'ready', '3': 2, '4': 1, '5': 11, '6': '.tureon.v1.ChatStreamReady', '9': 0, '10': 'ready'},
    {'1': 'delivery', '3': 3, '4': 1, '5': 11, '6': '.tureon.v1.MessageDelivery', '9': 0, '10': 'delivery'},
    {'1': 'send_message', '3': 4, '4': 1, '5': 11, '6': '.tureon.v1.SendMessageResponse', '9': 0, '10': 'sendMessage'},
    {'1': 'command_result', '3': 5, '4': 1, '5': 11, '6': '.tureon.v1.ChatStreamCommandResult', '9': 0, '10': 'commandResult'},
    {'1': 'bot_interaction', '3': 6, '4': 1, '5': 11, '6': '.tureon.v1.InteractBotResponse', '9': 0, '10': 'botInteraction'},
    {'1': 'batch', '3': 7, '4': 1, '5': 11, '6': '.tureon.v1.ChatStreamBatchResponse', '9': 0, '10': 'batch'},
  ],
  '8': [
    {'1': 'event'},
  ],
};

/// Descriptor for `ChatStreamResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List chatStreamResponseDescriptor = $convert.base64Decode(
    'ChJDaGF0U3RyZWFtUmVzcG9uc2USHQoKcmVxdWVzdF9pZBgBIAEoCVIJcmVxdWVzdElkEjIKBX'
    'JlYWR5GAIgASgLMhoudHVyZW9uLnYxLkNoYXRTdHJlYW1SZWFkeUgAUgVyZWFkeRI4CghkZWxp'
    'dmVyeRgDIAEoCzIaLnR1cmVvbi52MS5NZXNzYWdlRGVsaXZlcnlIAFIIZGVsaXZlcnkSQwoMc2'
    'VuZF9tZXNzYWdlGAQgASgLMh4udHVyZW9uLnYxLlNlbmRNZXNzYWdlUmVzcG9uc2VIAFILc2Vu'
    'ZE1lc3NhZ2USSwoOY29tbWFuZF9yZXN1bHQYBSABKAsyIi50dXJlb24udjEuQ2hhdFN0cmVhbU'
    'NvbW1hbmRSZXN1bHRIAFINY29tbWFuZFJlc3VsdBJJCg9ib3RfaW50ZXJhY3Rpb24YBiABKAsy'
    'Hi50dXJlb24udjEuSW50ZXJhY3RCb3RSZXNwb25zZUgAUg5ib3RJbnRlcmFjdGlvbhI6CgViYX'
    'RjaBgHIAEoCzIiLnR1cmVvbi52MS5DaGF0U3RyZWFtQmF0Y2hSZXNwb25zZUgAUgViYXRjaEIH'
    'CgVldmVudA==');

@$core.Deprecated('Use typingIndicatorDescriptor instead')
const TypingIndicator$json = {
  '1': 'TypingIndicator',
  '2': [
    {'1': 'sender_recipient_id', '3': 1, '4': 1, '5': 9, '10': 'senderRecipientId'},
    {'1': 'target_recipient_id', '3': 2, '4': 1, '5': 9, '10': 'targetRecipientId'},
    {'1': 'is_typing', '3': 3, '4': 1, '5': 8, '10': 'isTyping'},
  ],
};

/// Descriptor for `TypingIndicator`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List typingIndicatorDescriptor = $convert.base64Decode(
    'Cg9UeXBpbmdJbmRpY2F0b3ISLgoTc2VuZGVyX3JlY2lwaWVudF9pZBgBIAEoCVIRc2VuZGVyUm'
    'VjaXBpZW50SWQSLgoTdGFyZ2V0X3JlY2lwaWVudF9pZBgCIAEoCVIRdGFyZ2V0UmVjaXBpZW50'
    'SWQSGwoJaXNfdHlwaW5nGAMgASgIUghpc1R5cGluZw==');

@$core.Deprecated('Use presenceUpdateDescriptor instead')
const PresenceUpdate$json = {
  '1': 'PresenceUpdate',
  '2': [
    {'1': 'recipient_id', '3': 1, '4': 1, '5': 9, '10': 'recipientId'},
    {'1': 'online', '3': 2, '4': 1, '5': 8, '10': 'online'},
    {'1': 'last_seen', '3': 3, '4': 1, '5': 3, '10': 'lastSeen'},
    {'1': 'presence_visible', '3': 4, '4': 1, '5': 8, '9': 0, '10': 'presenceVisible', '17': true},
  ],
  '8': [
    {'1': '_presence_visible'},
  ],
};

/// Descriptor for `PresenceUpdate`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List presenceUpdateDescriptor = $convert.base64Decode(
    'Cg5QcmVzZW5jZVVwZGF0ZRIhCgxyZWNpcGllbnRfaWQYASABKAlSC3JlY2lwaWVudElkEhYKBm'
    '9ubGluZRgCIAEoCFIGb25saW5lEhsKCWxhc3Rfc2VlbhgDIAEoA1IIbGFzdFNlZW4SLgoQcHJl'
    'c2VuY2VfdmlzaWJsZRgEIAEoCEgAUg9wcmVzZW5jZVZpc2libGWIAQFCEwoRX3ByZXNlbmNlX3'
    'Zpc2libGU=');

@$core.Deprecated('Use presenceHeartbeatDescriptor instead')
const PresenceHeartbeat$json = {
  '1': 'PresenceHeartbeat',
  '2': [
    {'1': 'online', '3': 1, '4': 1, '5': 8, '10': 'online'},
  ],
};

/// Descriptor for `PresenceHeartbeat`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List presenceHeartbeatDescriptor = $convert.base64Decode(
    'ChFQcmVzZW5jZUhlYXJ0YmVhdBIWCgZvbmxpbmUYASABKAhSBm9ubGluZQ==');

@$core.Deprecated('Use presenceWatchDescriptor instead')
const PresenceWatch$json = {
  '1': 'PresenceWatch',
  '2': [
    {'1': 'recipient_ids', '3': 1, '4': 3, '5': 9, '10': 'recipientIds'},
  ],
};

/// Descriptor for `PresenceWatch`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List presenceWatchDescriptor = $convert.base64Decode(
    'Cg1QcmVzZW5jZVdhdGNoEiMKDXJlY2lwaWVudF9pZHMYASADKAlSDHJlY2lwaWVudElkcw==');

@$core.Deprecated('Use presenceClientEventDescriptor instead')
const PresenceClientEvent$json = {
  '1': 'PresenceClientEvent',
  '2': [
    {'1': 'heartbeat', '3': 1, '4': 1, '5': 11, '6': '.tureon.v1.PresenceHeartbeat', '9': 0, '10': 'heartbeat'},
    {'1': 'typing', '3': 2, '4': 1, '5': 11, '6': '.tureon.v1.TypingIndicator', '9': 0, '10': 'typing'},
    {'1': 'watch', '3': 3, '4': 1, '5': 11, '6': '.tureon.v1.PresenceWatch', '9': 0, '10': 'watch'},
  ],
  '8': [
    {'1': 'event'},
  ],
};

/// Descriptor for `PresenceClientEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List presenceClientEventDescriptor = $convert.base64Decode(
    'ChNQcmVzZW5jZUNsaWVudEV2ZW50EjwKCWhlYXJ0YmVhdBgBIAEoCzIcLnR1cmVvbi52MS5Qcm'
    'VzZW5jZUhlYXJ0YmVhdEgAUgloZWFydGJlYXQSNAoGdHlwaW5nGAIgASgLMhoudHVyZW9uLnYx'
    'LlR5cGluZ0luZGljYXRvckgAUgZ0eXBpbmcSMAoFd2F0Y2gYAyABKAsyGC50dXJlb24udjEuUH'
    'Jlc2VuY2VXYXRjaEgAUgV3YXRjaEIHCgVldmVudA==');

@$core.Deprecated('Use presenceServerEventDescriptor instead')
const PresenceServerEvent$json = {
  '1': 'PresenceServerEvent',
  '2': [
    {'1': 'presence', '3': 1, '4': 1, '5': 11, '6': '.tureon.v1.PresenceUpdate', '9': 0, '10': 'presence'},
    {'1': 'typing', '3': 2, '4': 1, '5': 11, '6': '.tureon.v1.TypingIndicator', '9': 0, '10': 'typing'},
  ],
  '8': [
    {'1': 'event'},
  ],
};

/// Descriptor for `PresenceServerEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List presenceServerEventDescriptor = $convert.base64Decode(
    'ChNQcmVzZW5jZVNlcnZlckV2ZW50EjcKCHByZXNlbmNlGAEgASgLMhkudHVyZW9uLnYxLlByZX'
    'NlbmNlVXBkYXRlSABSCHByZXNlbmNlEjQKBnR5cGluZxgCIAEoCzIaLnR1cmVvbi52MS5UeXBp'
    'bmdJbmRpY2F0b3JIAFIGdHlwaW5nQgcKBWV2ZW50');

@$core.Deprecated('Use systemMessageDescriptor instead')
const SystemMessage$json = {
  '1': 'SystemMessage',
  '2': [
    {'1': 'event_type', '3': 1, '4': 1, '5': 14, '6': '.tureon.v1.SystemEventType', '10': 'eventType'},
    {'1': 'actor_user_id', '3': 2, '4': 1, '5': 9, '10': 'actorUserId'},
    {'1': 'target_user_id', '3': 3, '4': 1, '5': 9, '10': 'targetUserId'},
    {'1': 'group_id', '3': 4, '4': 1, '5': 9, '10': 'groupId'},
    {'1': 'channel_id', '3': 5, '4': 1, '5': 9, '10': 'channelId'},
    {'1': 'reason', '3': 6, '4': 1, '5': 9, '10': 'reason'},
    {'1': 'metadata', '3': 7, '4': 3, '5': 11, '6': '.tureon.v1.SystemMessage.MetadataEntry', '10': 'metadata'},
    {'1': 'timestamp', '3': 8, '4': 1, '5': 3, '10': 'timestamp'},
  ],
  '3': [SystemMessage_MetadataEntry$json],
};

@$core.Deprecated('Use systemMessageDescriptor instead')
const SystemMessage_MetadataEntry$json = {
  '1': 'MetadataEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `SystemMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List systemMessageDescriptor = $convert.base64Decode(
    'Cg1TeXN0ZW1NZXNzYWdlEjkKCmV2ZW50X3R5cGUYASABKA4yGi50dXJlb24udjEuU3lzdGVtRX'
    'ZlbnRUeXBlUglldmVudFR5cGUSIgoNYWN0b3JfdXNlcl9pZBgCIAEoCVILYWN0b3JVc2VySWQS'
    'JAoOdGFyZ2V0X3VzZXJfaWQYAyABKAlSDHRhcmdldFVzZXJJZBIZCghncm91cF9pZBgEIAEoCV'
    'IHZ3JvdXBJZBIdCgpjaGFubmVsX2lkGAUgASgJUgljaGFubmVsSWQSFgoGcmVhc29uGAYgASgJ'
    'UgZyZWFzb24SQgoIbWV0YWRhdGEYByADKAsyJi50dXJlb24udjEuU3lzdGVtTWVzc2FnZS5NZX'
    'RhZGF0YUVudHJ5UghtZXRhZGF0YRIcCgl0aW1lc3RhbXAYCCABKANSCXRpbWVzdGFtcBo7Cg1N'
    'ZXRhZGF0YUVudHJ5EhAKA2tleRgBIAEoCVIDa2V5EhQKBXZhbHVlGAIgASgJUgV2YWx1ZToCOA'
    'E=');

@$core.Deprecated('Use emptyDescriptor instead')
const Empty$json = {
  '1': 'Empty',
};

/// Descriptor for `Empty`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List emptyDescriptor = $convert.base64Decode(
    'CgVFbXB0eQ==');

@$core.Deprecated('Use authRequestDescriptor instead')
const AuthRequest$json = {
  '1': 'AuthRequest',
  '2': [
    {'1': 'google_id_token', '3': 1, '4': 1, '5': 9, '10': 'googleIdToken'},
    {'1': 'device_name', '3': 2, '4': 1, '5': 9, '10': 'deviceName'},
    {'1': 'platform', '3': 3, '4': 1, '5': 9, '10': 'platform'},
    {'1': 'device_id', '3': 4, '4': 1, '5': 9, '10': 'deviceId'},
  ],
};

/// Descriptor for `AuthRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List authRequestDescriptor = $convert.base64Decode(
    'CgtBdXRoUmVxdWVzdBImCg9nb29nbGVfaWRfdG9rZW4YASABKAlSDWdvb2dsZUlkVG9rZW4SHw'
    'oLZGV2aWNlX25hbWUYAiABKAlSCmRldmljZU5hbWUSGgoIcGxhdGZvcm0YAyABKAlSCHBsYXRm'
    'b3JtEhsKCWRldmljZV9pZBgEIAEoCVIIZGV2aWNlSWQ=');

@$core.Deprecated('Use testAccountLoginRequestDescriptor instead')
const TestAccountLoginRequest$json = {
  '1': 'TestAccountLoginRequest',
  '2': [
    {'1': 'label', '3': 1, '4': 1, '5': 9, '10': 'label'},
    {'1': 'device_name', '3': 2, '4': 1, '5': 9, '10': 'deviceName'},
    {'1': 'platform', '3': 3, '4': 1, '5': 9, '10': 'platform'},
    {'1': 'device_id', '3': 4, '4': 1, '5': 9, '10': 'deviceId'},
  ],
};

/// Descriptor for `TestAccountLoginRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List testAccountLoginRequestDescriptor = $convert.base64Decode(
    'ChdUZXN0QWNjb3VudExvZ2luUmVxdWVzdBIUCgVsYWJlbBgBIAEoCVIFbGFiZWwSHwoLZGV2aW'
    'NlX25hbWUYAiABKAlSCmRldmljZU5hbWUSGgoIcGxhdGZvcm0YAyABKAlSCHBsYXRmb3JtEhsK'
    'CWRldmljZV9pZBgEIAEoCVIIZGV2aWNlSWQ=');

@$core.Deprecated('Use authResponseDescriptor instead')
const AuthResponse$json = {
  '1': 'AuthResponse',
  '2': [
    {'1': 'access_token', '3': 1, '4': 1, '5': 9, '10': 'accessToken'},
    {'1': 'refresh_token', '3': 2, '4': 1, '5': 9, '10': 'refreshToken'},
    {'1': 'device_id', '3': 3, '4': 1, '5': 9, '10': 'deviceId'},
    {'1': 'user_id', '3': 4, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'email', '3': 5, '4': 1, '5': 9, '10': 'email'},
    {'1': 'username', '3': 6, '4': 1, '5': 9, '10': 'username'},
    {'1': 'display_name', '3': 7, '4': 1, '5': 9, '10': 'displayName'},
    {'1': 'avatar_url', '3': 8, '4': 1, '5': 9, '10': 'avatarUrl'},
    {'1': 'needs_username', '3': 9, '4': 1, '5': 8, '10': 'needsUsername'},
    {'1': 'account_status', '3': 10, '4': 1, '5': 9, '10': 'accountStatus'},
    {'1': 'access_expires_at', '3': 11, '4': 1, '5': 3, '10': 'accessExpiresAt'},
    {'1': 'refresh_expires_at', '3': 12, '4': 1, '5': 3, '10': 'refreshExpiresAt'},
    {'1': 'signal_device_id', '3': 13, '4': 1, '5': 5, '10': 'signalDeviceId'},
  ],
};

/// Descriptor for `AuthResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List authResponseDescriptor = $convert.base64Decode(
    'CgxBdXRoUmVzcG9uc2USIQoMYWNjZXNzX3Rva2VuGAEgASgJUgthY2Nlc3NUb2tlbhIjCg1yZW'
    'ZyZXNoX3Rva2VuGAIgASgJUgxyZWZyZXNoVG9rZW4SGwoJZGV2aWNlX2lkGAMgASgJUghkZXZp'
    'Y2VJZBIXCgd1c2VyX2lkGAQgASgJUgZ1c2VySWQSFAoFZW1haWwYBSABKAlSBWVtYWlsEhoKCH'
    'VzZXJuYW1lGAYgASgJUgh1c2VybmFtZRIhCgxkaXNwbGF5X25hbWUYByABKAlSC2Rpc3BsYXlO'
    'YW1lEh0KCmF2YXRhcl91cmwYCCABKAlSCWF2YXRhclVybBIlCg5uZWVkc191c2VybmFtZRgJIA'
    'EoCFINbmVlZHNVc2VybmFtZRIlCg5hY2NvdW50X3N0YXR1cxgKIAEoCVINYWNjb3VudFN0YXR1'
    'cxIqChFhY2Nlc3NfZXhwaXJlc19hdBgLIAEoA1IPYWNjZXNzRXhwaXJlc0F0EiwKEnJlZnJlc2'
    'hfZXhwaXJlc19hdBgMIAEoA1IQcmVmcmVzaEV4cGlyZXNBdBIoChBzaWduYWxfZGV2aWNlX2lk'
    'GA0gASgFUg5zaWduYWxEZXZpY2VJZA==');

@$core.Deprecated('Use setUsernameRequestDescriptor instead')
const SetUsernameRequest$json = {
  '1': 'SetUsernameRequest',
  '2': [
    {'1': 'username', '3': 1, '4': 1, '5': 9, '10': 'username'},
  ],
};

/// Descriptor for `SetUsernameRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setUsernameRequestDescriptor = $convert.base64Decode(
    'ChJTZXRVc2VybmFtZVJlcXVlc3QSGgoIdXNlcm5hbWUYASABKAlSCHVzZXJuYW1l');

@$core.Deprecated('Use refreshTokenRequestDescriptor instead')
const RefreshTokenRequest$json = {
  '1': 'RefreshTokenRequest',
  '2': [
    {'1': 'refresh_token', '3': 1, '4': 1, '5': 9, '10': 'refreshToken'},
    {'1': 'device_id', '3': 2, '4': 1, '5': 9, '10': 'deviceId'},
  ],
};

/// Descriptor for `RefreshTokenRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List refreshTokenRequestDescriptor = $convert.base64Decode(
    'ChNSZWZyZXNoVG9rZW5SZXF1ZXN0EiMKDXJlZnJlc2hfdG9rZW4YASABKAlSDHJlZnJlc2hUb2'
    'tlbhIbCglkZXZpY2VfaWQYAiABKAlSCGRldmljZUlk');

@$core.Deprecated('Use logoutRequestDescriptor instead')
const LogoutRequest$json = {
  '1': 'LogoutRequest',
  '2': [
    {'1': 'device_id', '3': 1, '4': 1, '5': 9, '10': 'deviceId'},
  ],
};

/// Descriptor for `LogoutRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List logoutRequestDescriptor = $convert.base64Decode(
    'Cg1Mb2dvdXRSZXF1ZXN0EhsKCWRldmljZV9pZBgBIAEoCVIIZGV2aWNlSWQ=');

@$core.Deprecated('Use deviceInfoDescriptor instead')
const DeviceInfo$json = {
  '1': 'DeviceInfo',
  '2': [
    {'1': 'device_id', '3': 1, '4': 1, '5': 9, '10': 'deviceId'},
    {'1': 'device_name', '3': 2, '4': 1, '5': 9, '10': 'deviceName'},
    {'1': 'platform', '3': 3, '4': 1, '5': 9, '10': 'platform'},
    {'1': 'last_active_at', '3': 4, '4': 1, '5': 3, '10': 'lastActiveAt'},
    {'1': 'is_current', '3': 5, '4': 1, '5': 8, '10': 'isCurrent'},
  ],
};

/// Descriptor for `DeviceInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deviceInfoDescriptor = $convert.base64Decode(
    'CgpEZXZpY2VJbmZvEhsKCWRldmljZV9pZBgBIAEoCVIIZGV2aWNlSWQSHwoLZGV2aWNlX25hbW'
    'UYAiABKAlSCmRldmljZU5hbWUSGgoIcGxhdGZvcm0YAyABKAlSCHBsYXRmb3JtEiQKDmxhc3Rf'
    'YWN0aXZlX2F0GAQgASgDUgxsYXN0QWN0aXZlQXQSHQoKaXNfY3VycmVudBgFIAEoCFIJaXNDdX'
    'JyZW50');

@$core.Deprecated('Use listDevicesResponseDescriptor instead')
const ListDevicesResponse$json = {
  '1': 'ListDevicesResponse',
  '2': [
    {'1': 'devices', '3': 1, '4': 3, '5': 11, '6': '.tureon.v1.DeviceInfo', '10': 'devices'},
  ],
};

/// Descriptor for `ListDevicesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listDevicesResponseDescriptor = $convert.base64Decode(
    'ChNMaXN0RGV2aWNlc1Jlc3BvbnNlEi8KB2RldmljZXMYASADKAsyFS50dXJlb24udjEuRGV2aW'
    'NlSW5mb1IHZGV2aWNlcw==');

@$core.Deprecated('Use keyBundleUploadRequestDescriptor instead')
const KeyBundleUploadRequest$json = {
  '1': 'KeyBundleUploadRequest',
  '2': [
    {'1': 'device_id', '3': 1, '4': 1, '5': 9, '10': 'deviceId'},
    {'1': 'identity_public_key', '3': 2, '4': 1, '5': 9, '10': 'identityPublicKey'},
    {'1': 'signed_prekey_public', '3': 3, '4': 1, '5': 9, '10': 'signedPrekeyPublic'},
    {'1': 'signed_prekey_id', '3': 4, '4': 1, '5': 5, '10': 'signedPrekeyId'},
    {'1': 'signed_prekey_signature', '3': 5, '4': 1, '5': 9, '10': 'signedPrekeySignature'},
    {'1': 'one_time_prekeys', '3': 6, '4': 3, '5': 11, '6': '.tureon.v1.OneTimePreKey', '10': 'oneTimePrekeys'},
    {'1': 'registration_id', '3': 7, '4': 1, '5': 5, '10': 'registrationId'},
    {'1': 'kyber_prekey_id', '3': 8, '4': 1, '5': 5, '10': 'kyberPrekeyId'},
    {'1': 'kyber_prekey_public', '3': 9, '4': 1, '5': 9, '10': 'kyberPrekeyPublic'},
    {'1': 'kyber_prekey_signature', '3': 10, '4': 1, '5': 9, '10': 'kyberPrekeySignature'},
    {'1': 'signal_device_id', '3': 11, '4': 1, '5': 5, '10': 'signalDeviceId'},
  ],
};

/// Descriptor for `KeyBundleUploadRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List keyBundleUploadRequestDescriptor = $convert.base64Decode(
    'ChZLZXlCdW5kbGVVcGxvYWRSZXF1ZXN0EhsKCWRldmljZV9pZBgBIAEoCVIIZGV2aWNlSWQSLg'
    'oTaWRlbnRpdHlfcHVibGljX2tleRgCIAEoCVIRaWRlbnRpdHlQdWJsaWNLZXkSMAoUc2lnbmVk'
    'X3ByZWtleV9wdWJsaWMYAyABKAlSEnNpZ25lZFByZWtleVB1YmxpYxIoChBzaWduZWRfcHJla2'
    'V5X2lkGAQgASgFUg5zaWduZWRQcmVrZXlJZBI2ChdzaWduZWRfcHJla2V5X3NpZ25hdHVyZRgF'
    'IAEoCVIVc2lnbmVkUHJla2V5U2lnbmF0dXJlEkIKEG9uZV90aW1lX3ByZWtleXMYBiADKAsyGC'
    '50dXJlb24udjEuT25lVGltZVByZUtleVIOb25lVGltZVByZWtleXMSJwoPcmVnaXN0cmF0aW9u'
    'X2lkGAcgASgFUg5yZWdpc3RyYXRpb25JZBImCg9reWJlcl9wcmVrZXlfaWQYCCABKAVSDWt5Ym'
    'VyUHJla2V5SWQSLgoTa3liZXJfcHJla2V5X3B1YmxpYxgJIAEoCVIRa3liZXJQcmVrZXlQdWJs'
    'aWMSNAoWa3liZXJfcHJla2V5X3NpZ25hdHVyZRgKIAEoCVIUa3liZXJQcmVrZXlTaWduYXR1cm'
    'USKAoQc2lnbmFsX2RldmljZV9pZBgLIAEoBVIOc2lnbmFsRGV2aWNlSWQ=');

@$core.Deprecated('Use oneTimePreKeyDescriptor instead')
const OneTimePreKey$json = {
  '1': 'OneTimePreKey',
  '2': [
    {'1': 'key_id', '3': 1, '4': 1, '5': 5, '10': 'keyId'},
    {'1': 'public_key', '3': 2, '4': 1, '5': 9, '10': 'publicKey'},
  ],
};

/// Descriptor for `OneTimePreKey`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List oneTimePreKeyDescriptor = $convert.base64Decode(
    'Cg1PbmVUaW1lUHJlS2V5EhUKBmtleV9pZBgBIAEoBVIFa2V5SWQSHQoKcHVibGljX2tleRgCIA'
    'EoCVIJcHVibGljS2V5');

@$core.Deprecated('Use keyBundleDescriptor instead')
const KeyBundle$json = {
  '1': 'KeyBundle',
  '2': [
    {'1': 'device_id', '3': 1, '4': 1, '5': 9, '10': 'deviceId'},
    {'1': 'identity_public_key', '3': 2, '4': 1, '5': 9, '10': 'identityPublicKey'},
    {'1': 'signed_prekey_public', '3': 3, '4': 1, '5': 9, '10': 'signedPrekeyPublic'},
    {'1': 'signed_prekey_id', '3': 4, '4': 1, '5': 5, '10': 'signedPrekeyId'},
    {'1': 'signed_prekey_signature', '3': 5, '4': 1, '5': 9, '10': 'signedPrekeySignature'},
    {'1': 'one_time_prekeys', '3': 6, '4': 3, '5': 11, '6': '.tureon.v1.OneTimePreKey', '10': 'oneTimePrekeys'},
    {'1': 'registration_id', '3': 7, '4': 1, '5': 5, '10': 'registrationId'},
    {'1': 'kyber_prekey_id', '3': 8, '4': 1, '5': 5, '10': 'kyberPrekeyId'},
    {'1': 'kyber_prekey_public', '3': 9, '4': 1, '5': 9, '10': 'kyberPrekeyPublic'},
    {'1': 'kyber_prekey_signature', '3': 10, '4': 1, '5': 9, '10': 'kyberPrekeySignature'},
    {'1': 'signal_device_id', '3': 11, '4': 1, '5': 5, '10': 'signalDeviceId'},
  ],
};

/// Descriptor for `KeyBundle`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List keyBundleDescriptor = $convert.base64Decode(
    'CglLZXlCdW5kbGUSGwoJZGV2aWNlX2lkGAEgASgJUghkZXZpY2VJZBIuChNpZGVudGl0eV9wdW'
    'JsaWNfa2V5GAIgASgJUhFpZGVudGl0eVB1YmxpY0tleRIwChRzaWduZWRfcHJla2V5X3B1Ymxp'
    'YxgDIAEoCVISc2lnbmVkUHJla2V5UHVibGljEigKEHNpZ25lZF9wcmVrZXlfaWQYBCABKAVSDn'
    'NpZ25lZFByZWtleUlkEjYKF3NpZ25lZF9wcmVrZXlfc2lnbmF0dXJlGAUgASgJUhVzaWduZWRQ'
    'cmVrZXlTaWduYXR1cmUSQgoQb25lX3RpbWVfcHJla2V5cxgGIAMoCzIYLnR1cmVvbi52MS5Pbm'
    'VUaW1lUHJlS2V5Ug5vbmVUaW1lUHJla2V5cxInCg9yZWdpc3RyYXRpb25faWQYByABKAVSDnJl'
    'Z2lzdHJhdGlvbklkEiYKD2t5YmVyX3ByZWtleV9pZBgIIAEoBVINa3liZXJQcmVrZXlJZBIuCh'
    'NreWJlcl9wcmVrZXlfcHVibGljGAkgASgJUhFreWJlclByZWtleVB1YmxpYxI0ChZreWJlcl9w'
    'cmVrZXlfc2lnbmF0dXJlGAogASgJUhRreWJlclByZWtleVNpZ25hdHVyZRIoChBzaWduYWxfZG'
    'V2aWNlX2lkGAsgASgFUg5zaWduYWxEZXZpY2VJZA==');

@$core.Deprecated('Use getKeyBundleRequestDescriptor instead')
const GetKeyBundleRequest$json = {
  '1': 'GetKeyBundleRequest',
  '2': [
    {'1': 'recipient_id', '3': 1, '4': 1, '5': 9, '10': 'recipientId'},
    {'1': 'device_id', '3': 2, '4': 1, '5': 9, '10': 'deviceId'},
  ],
};

/// Descriptor for `GetKeyBundleRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getKeyBundleRequestDescriptor = $convert.base64Decode(
    'ChNHZXRLZXlCdW5kbGVSZXF1ZXN0EiEKDHJlY2lwaWVudF9pZBgBIAEoCVILcmVjaXBpZW50SW'
    'QSGwoJZGV2aWNlX2lkGAIgASgJUghkZXZpY2VJZA==');

@$core.Deprecated('Use refillOneTimePrekeysRequestDescriptor instead')
const RefillOneTimePrekeysRequest$json = {
  '1': 'RefillOneTimePrekeysRequest',
  '2': [
    {'1': 'one_time_prekeys', '3': 1, '4': 3, '5': 11, '6': '.tureon.v1.OneTimePreKey', '10': 'oneTimePrekeys'},
  ],
};

/// Descriptor for `RefillOneTimePrekeysRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List refillOneTimePrekeysRequestDescriptor = $convert.base64Decode(
    'ChtSZWZpbGxPbmVUaW1lUHJla2V5c1JlcXVlc3QSQgoQb25lX3RpbWVfcHJla2V5cxgBIAMoCz'
    'IYLnR1cmVvbi52MS5PbmVUaW1lUHJlS2V5Ug5vbmVUaW1lUHJla2V5cw==');

@$core.Deprecated('Use getPreKeyCountResponseDescriptor instead')
const GetPreKeyCountResponse$json = {
  '1': 'GetPreKeyCountResponse',
  '2': [
    {'1': 'count', '3': 1, '4': 1, '5': 5, '10': 'count'},
    {'1': 'low_watermark', '3': 2, '4': 1, '5': 5, '10': 'lowWatermark'},
  ],
};

/// Descriptor for `GetPreKeyCountResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getPreKeyCountResponseDescriptor = $convert.base64Decode(
    'ChZHZXRQcmVLZXlDb3VudFJlc3BvbnNlEhQKBWNvdW50GAEgASgFUgVjb3VudBIjCg1sb3dfd2'
    'F0ZXJtYXJrGAIgASgFUgxsb3dXYXRlcm1hcms=');

@$core.Deprecated('Use listRecipientKeyDevicesRequestDescriptor instead')
const ListRecipientKeyDevicesRequest$json = {
  '1': 'ListRecipientKeyDevicesRequest',
  '2': [
    {'1': 'recipient_id', '3': 1, '4': 1, '5': 9, '10': 'recipientId'},
  ],
};

/// Descriptor for `ListRecipientKeyDevicesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listRecipientKeyDevicesRequestDescriptor = $convert.base64Decode(
    'Ch5MaXN0UmVjaXBpZW50S2V5RGV2aWNlc1JlcXVlc3QSIQoMcmVjaXBpZW50X2lkGAEgASgJUg'
    'tyZWNpcGllbnRJZA==');

@$core.Deprecated('Use keyDeviceInfoDescriptor instead')
const KeyDeviceInfo$json = {
  '1': 'KeyDeviceInfo',
  '2': [
    {'1': 'device_id', '3': 1, '4': 1, '5': 9, '10': 'deviceId'},
    {'1': 'device_name', '3': 2, '4': 1, '5': 9, '10': 'deviceName'},
    {'1': 'platform', '3': 3, '4': 1, '5': 9, '10': 'platform'},
    {'1': 'signal_device_id', '3': 4, '4': 1, '5': 5, '10': 'signalDeviceId'},
    {'1': 'one_time_prekey_count', '3': 5, '4': 1, '5': 5, '10': 'oneTimePrekeyCount'},
  ],
};

/// Descriptor for `KeyDeviceInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List keyDeviceInfoDescriptor = $convert.base64Decode(
    'Cg1LZXlEZXZpY2VJbmZvEhsKCWRldmljZV9pZBgBIAEoCVIIZGV2aWNlSWQSHwoLZGV2aWNlX2'
    '5hbWUYAiABKAlSCmRldmljZU5hbWUSGgoIcGxhdGZvcm0YAyABKAlSCHBsYXRmb3JtEigKEHNp'
    'Z25hbF9kZXZpY2VfaWQYBCABKAVSDnNpZ25hbERldmljZUlkEjEKFW9uZV90aW1lX3ByZWtleV'
    '9jb3VudBgFIAEoBVISb25lVGltZVByZWtleUNvdW50');

@$core.Deprecated('Use listRecipientKeyDevicesResponseDescriptor instead')
const ListRecipientKeyDevicesResponse$json = {
  '1': 'ListRecipientKeyDevicesResponse',
  '2': [
    {'1': 'devices', '3': 1, '4': 3, '5': 11, '6': '.tureon.v1.KeyDeviceInfo', '10': 'devices'},
  ],
};

/// Descriptor for `ListRecipientKeyDevicesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listRecipientKeyDevicesResponseDescriptor = $convert.base64Decode(
    'Ch9MaXN0UmVjaXBpZW50S2V5RGV2aWNlc1Jlc3BvbnNlEjIKB2RldmljZXMYASADKAsyGC50dX'
    'Jlb24udjEuS2V5RGV2aWNlSW5mb1IHZGV2aWNlcw==');

@$core.Deprecated('Use searchUsersByUsernameRequestDescriptor instead')
const SearchUsersByUsernameRequest$json = {
  '1': 'SearchUsersByUsernameRequest',
  '2': [
    {'1': 'query', '3': 1, '4': 1, '5': 9, '10': 'query'},
  ],
};

/// Descriptor for `SearchUsersByUsernameRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List searchUsersByUsernameRequestDescriptor = $convert.base64Decode(
    'ChxTZWFyY2hVc2Vyc0J5VXNlcm5hbWVSZXF1ZXN0EhQKBXF1ZXJ5GAEgASgJUgVxdWVyeQ==');

@$core.Deprecated('Use userSearchResultDescriptor instead')
const UserSearchResult$json = {
  '1': 'UserSearchResult',
  '2': [
    {'1': 'recipient_id', '3': 1, '4': 1, '5': 9, '10': 'recipientId'},
    {'1': 'username', '3': 2, '4': 1, '5': 9, '10': 'username'},
    {'1': 'display_name', '3': 3, '4': 1, '5': 9, '10': 'displayName'},
    {'1': 'avatar_url', '3': 4, '4': 1, '5': 9, '10': 'avatarUrl'},
    {'1': 'verification_badge', '3': 5, '4': 1, '5': 9, '10': 'verificationBadge'},
    {'1': 'recipient_type', '3': 6, '4': 1, '5': 9, '10': 'recipientType'},
    {'1': 'description', '3': 7, '4': 1, '5': 9, '10': 'description'},
    {'1': 'country_code', '3': 8, '4': 1, '5': 9, '10': 'countryCode'},
    {'1': 'created_at', '3': 9, '4': 1, '5': 3, '10': 'createdAt'},
  ],
};

/// Descriptor for `UserSearchResult`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userSearchResultDescriptor = $convert.base64Decode(
    'ChBVc2VyU2VhcmNoUmVzdWx0EiEKDHJlY2lwaWVudF9pZBgBIAEoCVILcmVjaXBpZW50SWQSGg'
    'oIdXNlcm5hbWUYAiABKAlSCHVzZXJuYW1lEiEKDGRpc3BsYXlfbmFtZRgDIAEoCVILZGlzcGxh'
    'eU5hbWUSHQoKYXZhdGFyX3VybBgEIAEoCVIJYXZhdGFyVXJsEi0KEnZlcmlmaWNhdGlvbl9iYW'
    'RnZRgFIAEoCVIRdmVyaWZpY2F0aW9uQmFkZ2USJQoOcmVjaXBpZW50X3R5cGUYBiABKAlSDXJl'
    'Y2lwaWVudFR5cGUSIAoLZGVzY3JpcHRpb24YByABKAlSC2Rlc2NyaXB0aW9uEiEKDGNvdW50cn'
    'lfY29kZRgIIAEoCVILY291bnRyeUNvZGUSHQoKY3JlYXRlZF9hdBgJIAEoA1IJY3JlYXRlZEF0');

@$core.Deprecated('Use searchUsersByUsernameResponseDescriptor instead')
const SearchUsersByUsernameResponse$json = {
  '1': 'SearchUsersByUsernameResponse',
  '2': [
    {'1': 'users', '3': 1, '4': 3, '5': 11, '6': '.tureon.v1.UserSearchResult', '10': 'users'},
  ],
};

/// Descriptor for `SearchUsersByUsernameResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List searchUsersByUsernameResponseDescriptor = $convert.base64Decode(
    'Ch1TZWFyY2hVc2Vyc0J5VXNlcm5hbWVSZXNwb25zZRIxCgV1c2VycxgBIAMoCzIbLnR1cmVvbi'
    '52MS5Vc2VyU2VhcmNoUmVzdWx0UgV1c2Vycw==');

@$core.Deprecated('Use profilePrivacySettingDescriptor instead')
const ProfilePrivacySetting$json = {
  '1': 'ProfilePrivacySetting',
  '2': [
    {'1': 'field', '3': 1, '4': 1, '5': 9, '10': 'field'},
    {'1': 'visibility', '3': 2, '4': 1, '5': 9, '10': 'visibility'},
  ],
};

/// Descriptor for `ProfilePrivacySetting`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List profilePrivacySettingDescriptor = $convert.base64Decode(
    'ChVQcm9maWxlUHJpdmFjeVNldHRpbmcSFAoFZmllbGQYASABKAlSBWZpZWxkEh4KCnZpc2liaW'
    'xpdHkYAiABKAlSCnZpc2liaWxpdHk=');

@$core.Deprecated('Use getProfileRequestDescriptor instead')
const GetProfileRequest$json = {
  '1': 'GetProfileRequest',
  '2': [
    {'1': 'recipient_id', '3': 1, '4': 1, '5': 9, '10': 'recipientId'},
  ],
};

/// Descriptor for `GetProfileRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getProfileRequestDescriptor = $convert.base64Decode(
    'ChFHZXRQcm9maWxlUmVxdWVzdBIhCgxyZWNpcGllbnRfaWQYASABKAlSC3JlY2lwaWVudElk');

@$core.Deprecated('Use profileResponseDescriptor instead')
const ProfileResponse$json = {
  '1': 'ProfileResponse',
  '2': [
    {'1': 'recipient_id', '3': 1, '4': 1, '5': 9, '10': 'recipientId'},
    {'1': 'username', '3': 2, '4': 1, '5': 9, '10': 'username'},
    {'1': 'display_name', '3': 3, '4': 1, '5': 9, '10': 'displayName'},
    {'1': 'bio', '3': 4, '4': 1, '5': 9, '10': 'bio'},
    {'1': 'phone_e164', '3': 5, '4': 1, '5': 9, '10': 'phoneE164'},
    {'1': 'birthday', '3': 6, '4': 1, '5': 9, '10': 'birthday'},
    {'1': 'avatar_url', '3': 7, '4': 1, '5': 9, '10': 'avatarUrl'},
    {'1': 'privacy_settings', '3': 8, '4': 3, '5': 11, '6': '.tureon.v1.ProfilePrivacySetting', '10': 'privacySettings'},
    {'1': 'verification_badge', '3': 9, '4': 1, '5': 9, '10': 'verificationBadge'},
    {'1': 'profile_version', '3': 10, '4': 1, '5': 3, '10': 'profileVersion'},
    {'1': 'country_code', '3': 11, '4': 1, '5': 9, '10': 'countryCode'},
    {'1': 'created_at', '3': 12, '4': 1, '5': 3, '10': 'createdAt'},
  ],
};

/// Descriptor for `ProfileResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List profileResponseDescriptor = $convert.base64Decode(
    'Cg9Qcm9maWxlUmVzcG9uc2USIQoMcmVjaXBpZW50X2lkGAEgASgJUgtyZWNpcGllbnRJZBIaCg'
    'h1c2VybmFtZRgCIAEoCVIIdXNlcm5hbWUSIQoMZGlzcGxheV9uYW1lGAMgASgJUgtkaXNwbGF5'
    'TmFtZRIQCgNiaW8YBCABKAlSA2JpbxIdCgpwaG9uZV9lMTY0GAUgASgJUglwaG9uZUUxNjQSGg'
    'oIYmlydGhkYXkYBiABKAlSCGJpcnRoZGF5Eh0KCmF2YXRhcl91cmwYByABKAlSCWF2YXRhclVy'
    'bBJLChBwcml2YWN5X3NldHRpbmdzGAggAygLMiAudHVyZW9uLnYxLlByb2ZpbGVQcml2YWN5U2'
    'V0dGluZ1IPcHJpdmFjeVNldHRpbmdzEi0KEnZlcmlmaWNhdGlvbl9iYWRnZRgJIAEoCVIRdmVy'
    'aWZpY2F0aW9uQmFkZ2USJwoPcHJvZmlsZV92ZXJzaW9uGAogASgDUg5wcm9maWxlVmVyc2lvbh'
    'IhCgxjb3VudHJ5X2NvZGUYCyABKAlSC2NvdW50cnlDb2RlEh0KCmNyZWF0ZWRfYXQYDCABKANS'
    'CWNyZWF0ZWRBdA==');

@$core.Deprecated('Use updateProfileRequestDescriptor instead')
const UpdateProfileRequest$json = {
  '1': 'UpdateProfileRequest',
  '2': [
    {'1': 'username', '3': 1, '4': 1, '5': 9, '10': 'username'},
    {'1': 'display_name', '3': 2, '4': 1, '5': 9, '10': 'displayName'},
    {'1': 'bio', '3': 3, '4': 1, '5': 9, '10': 'bio'},
    {'1': 'phone_e164', '3': 4, '4': 1, '5': 9, '10': 'phoneE164'},
    {'1': 'birthday', '3': 5, '4': 1, '5': 9, '10': 'birthday'},
    {'1': 'avatar_url', '3': 6, '4': 1, '5': 9, '10': 'avatarUrl'},
    {'1': 'expected_profile_version', '3': 7, '4': 1, '5': 3, '10': 'expectedProfileVersion'},
    {'1': 'country_code', '3': 8, '4': 1, '5': 9, '9': 0, '10': 'countryCode', '17': true},
  ],
  '8': [
    {'1': '_country_code'},
  ],
};

/// Descriptor for `UpdateProfileRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateProfileRequestDescriptor = $convert.base64Decode(
    'ChRVcGRhdGVQcm9maWxlUmVxdWVzdBIaCgh1c2VybmFtZRgBIAEoCVIIdXNlcm5hbWUSIQoMZG'
    'lzcGxheV9uYW1lGAIgASgJUgtkaXNwbGF5TmFtZRIQCgNiaW8YAyABKAlSA2JpbxIdCgpwaG9u'
    'ZV9lMTY0GAQgASgJUglwaG9uZUUxNjQSGgoIYmlydGhkYXkYBSABKAlSCGJpcnRoZGF5Eh0KCm'
    'F2YXRhcl91cmwYBiABKAlSCWF2YXRhclVybBI4ChhleHBlY3RlZF9wcm9maWxlX3ZlcnNpb24Y'
    'ByABKANSFmV4cGVjdGVkUHJvZmlsZVZlcnNpb24SJgoMY291bnRyeV9jb2RlGAggASgJSABSC2'
    'NvdW50cnlDb2RliAEBQg8KDV9jb3VudHJ5X2NvZGU=');

@$core.Deprecated('Use updatePrivacySettingRequestDescriptor instead')
const UpdatePrivacySettingRequest$json = {
  '1': 'UpdatePrivacySettingRequest',
  '2': [
    {'1': 'field', '3': 1, '4': 1, '5': 9, '10': 'field'},
    {'1': 'visibility', '3': 2, '4': 1, '5': 9, '10': 'visibility'},
  ],
};

/// Descriptor for `UpdatePrivacySettingRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updatePrivacySettingRequestDescriptor = $convert.base64Decode(
    'ChtVcGRhdGVQcml2YWN5U2V0dGluZ1JlcXVlc3QSFAoFZmllbGQYASABKAlSBWZpZWxkEh4KCn'
    'Zpc2liaWxpdHkYAiABKAlSCnZpc2liaWxpdHk=');

@$core.Deprecated('Use profileChangeDescriptor instead')
const ProfileChange$json = {
  '1': 'ProfileChange',
  '2': [
    {'1': 'profile_version', '3': 1, '4': 1, '5': 3, '10': 'profileVersion'},
    {'1': 'recipient_id', '3': 2, '4': 1, '5': 9, '10': 'recipientId'},
    {'1': 'account_status', '3': 3, '4': 1, '5': 9, '10': 'accountStatus'},
    {'1': 'verification_badge', '3': 4, '4': 1, '5': 9, '10': 'verificationBadge'},
  ],
};

/// Descriptor for `ProfileChange`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List profileChangeDescriptor = $convert.base64Decode(
    'Cg1Qcm9maWxlQ2hhbmdlEicKD3Byb2ZpbGVfdmVyc2lvbhgBIAEoA1IOcHJvZmlsZVZlcnNpb2'
    '4SIQoMcmVjaXBpZW50X2lkGAIgASgJUgtyZWNpcGllbnRJZBIlCg5hY2NvdW50X3N0YXR1cxgD'
    'IAEoCVINYWNjb3VudFN0YXR1cxItChJ2ZXJpZmljYXRpb25fYmFkZ2UYBCABKAlSEXZlcmlmaW'
    'NhdGlvbkJhZGdl');

@$core.Deprecated('Use profileWatchCursorDescriptor instead')
const ProfileWatchCursor$json = {
  '1': 'ProfileWatchCursor',
  '2': [
    {'1': 'recipient_id', '3': 1, '4': 1, '5': 9, '10': 'recipientId'},
    {'1': 'profile_version', '3': 2, '4': 1, '5': 3, '10': 'profileVersion'},
    {'1': 'verification_badge', '3': 3, '4': 1, '5': 9, '10': 'verificationBadge'},
  ],
};

/// Descriptor for `ProfileWatchCursor`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List profileWatchCursorDescriptor = $convert.base64Decode(
    'ChJQcm9maWxlV2F0Y2hDdXJzb3ISIQoMcmVjaXBpZW50X2lkGAEgASgJUgtyZWNpcGllbnRJZB'
    'InCg9wcm9maWxlX3ZlcnNpb24YAiABKANSDnByb2ZpbGVWZXJzaW9uEi0KEnZlcmlmaWNhdGlv'
    'bl9iYWRnZRgDIAEoCVIRdmVyaWZpY2F0aW9uQmFkZ2U=');

@$core.Deprecated('Use profileWatchRequestDescriptor instead')
const ProfileWatchRequest$json = {
  '1': 'ProfileWatchRequest',
  '2': [
    {'1': 'cursors', '3': 1, '4': 3, '5': 11, '6': '.tureon.v1.ProfileWatchCursor', '10': 'cursors'},
  ],
};

/// Descriptor for `ProfileWatchRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List profileWatchRequestDescriptor = $convert.base64Decode(
    'ChNQcm9maWxlV2F0Y2hSZXF1ZXN0EjcKB2N1cnNvcnMYASADKAsyHS50dXJlb24udjEuUHJvZm'
    'lsZVdhdGNoQ3Vyc29yUgdjdXJzb3Jz');

@$core.Deprecated('Use membershipChangeDescriptor instead')
const MembershipChange$json = {
  '1': 'MembershipChange',
  '2': [
    {'1': 'resource_id', '3': 1, '4': 1, '5': 9, '10': 'resourceId'},
    {'1': 'resource_type', '3': 2, '4': 1, '5': 9, '10': 'resourceType'},
  ],
};

/// Descriptor for `MembershipChange`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List membershipChangeDescriptor = $convert.base64Decode(
    'ChBNZW1iZXJzaGlwQ2hhbmdlEh8KC3Jlc291cmNlX2lkGAEgASgJUgpyZXNvdXJjZUlkEiMKDX'
    'Jlc291cmNlX3R5cGUYAiABKAlSDHJlc291cmNlVHlwZQ==');

@$core.Deprecated('Use serverHealthResponseDescriptor instead')
const ServerHealthResponse$json = {
  '1': 'ServerHealthResponse',
  '2': [
    {'1': 'serving', '3': 1, '4': 1, '5': 8, '10': 'serving'},
  ],
};

/// Descriptor for `ServerHealthResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List serverHealthResponseDescriptor = $convert.base64Decode(
    'ChRTZXJ2ZXJIZWFsdGhSZXNwb25zZRIYCgdzZXJ2aW5nGAEgASgIUgdzZXJ2aW5n');

@$core.Deprecated('Use createGroupRequestDescriptor instead')
const CreateGroupRequest$json = {
  '1': 'CreateGroupRequest',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'description', '3': 2, '4': 1, '5': 9, '10': 'description'},
    {'1': 'avatar_url', '3': 3, '4': 1, '5': 9, '10': 'avatarUrl'},
    {'1': 'visibility', '3': 4, '4': 1, '5': 9, '10': 'visibility'},
  ],
};

/// Descriptor for `CreateGroupRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createGroupRequestDescriptor = $convert.base64Decode(
    'ChJDcmVhdGVHcm91cFJlcXVlc3QSEgoEbmFtZRgBIAEoCVIEbmFtZRIgCgtkZXNjcmlwdGlvbh'
    'gCIAEoCVILZGVzY3JpcHRpb24SHQoKYXZhdGFyX3VybBgDIAEoCVIJYXZhdGFyVXJsEh4KCnZp'
    'c2liaWxpdHkYBCABKAlSCnZpc2liaWxpdHk=');

@$core.Deprecated('Use createGroupResponseDescriptor instead')
const CreateGroupResponse$json = {
  '1': 'CreateGroupResponse',
  '2': [
    {'1': 'group', '3': 1, '4': 1, '5': 11, '6': '.tureon.v1.GroupChannel', '10': 'group'},
  ],
};

/// Descriptor for `CreateGroupResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createGroupResponseDescriptor = $convert.base64Decode(
    'ChNDcmVhdGVHcm91cFJlc3BvbnNlEi0KBWdyb3VwGAEgASgLMhcudHVyZW9uLnYxLkdyb3VwQ2'
    'hhbm5lbFIFZ3JvdXA=');

@$core.Deprecated('Use groupChannelDescriptor instead')
const GroupChannel$json = {
  '1': 'GroupChannel',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'type', '3': 2, '4': 1, '5': 9, '10': 'type'},
    {'1': 'name', '3': 3, '4': 1, '5': 9, '10': 'name'},
    {'1': 'description', '3': 4, '4': 1, '5': 9, '10': 'description'},
    {'1': 'avatar_url', '3': 5, '4': 1, '5': 9, '10': 'avatarUrl'},
    {'1': 'visibility', '3': 6, '4': 1, '5': 9, '10': 'visibility'},
    {'1': 'owner_user_id', '3': 7, '4': 1, '5': 9, '10': 'ownerUserId'},
    {'1': 'created_at', '3': 8, '4': 1, '5': 3, '10': 'createdAt'},
    {'1': 'member_role', '3': 9, '4': 1, '5': 9, '10': 'memberRole'},
    {'1': 'members_can_send_messages', '3': 10, '4': 1, '5': 8, '10': 'membersCanSendMessages'},
    {'1': 'member_count', '3': 11, '4': 1, '5': 3, '10': 'memberCount'},
    {'1': 'is_official', '3': 12, '4': 1, '5': 8, '10': 'isOfficial'},
    {'1': 'username', '3': 13, '4': 1, '5': 9, '10': 'username'},
    {'1': 'members_can_send_media', '3': 14, '4': 1, '5': 8, '10': 'membersCanSendMedia'},
    {'1': 'members_can_send_stickers_gifs', '3': 15, '4': 1, '5': 8, '10': 'membersCanSendStickersGifs'},
    {'1': 'members_can_embed_links', '3': 16, '4': 1, '5': 8, '10': 'membersCanEmbedLinks'},
    {'1': 'members_can_add_members', '3': 17, '4': 1, '5': 8, '10': 'membersCanAddMembers'},
    {'1': 'members_can_change_info', '3': 18, '4': 1, '5': 8, '10': 'membersCanChangeInfo'},
    {'1': 'members_can_react', '3': 19, '4': 1, '5': 8, '10': 'membersCanReact'},
    {'1': 'members_can_forward', '3': 20, '4': 1, '5': 8, '10': 'membersCanForward'},
    {'1': 'slow_mode_seconds', '3': 21, '4': 1, '5': 5, '10': 'slowModeSeconds'},
  ],
};

/// Descriptor for `GroupChannel`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List groupChannelDescriptor = $convert.base64Decode(
    'CgxHcm91cENoYW5uZWwSDgoCaWQYASABKAlSAmlkEhIKBHR5cGUYAiABKAlSBHR5cGUSEgoEbm'
    'FtZRgDIAEoCVIEbmFtZRIgCgtkZXNjcmlwdGlvbhgEIAEoCVILZGVzY3JpcHRpb24SHQoKYXZh'
    'dGFyX3VybBgFIAEoCVIJYXZhdGFyVXJsEh4KCnZpc2liaWxpdHkYBiABKAlSCnZpc2liaWxpdH'
    'kSIgoNb3duZXJfdXNlcl9pZBgHIAEoCVILb3duZXJVc2VySWQSHQoKY3JlYXRlZF9hdBgIIAEo'
    'A1IJY3JlYXRlZEF0Eh8KC21lbWJlcl9yb2xlGAkgASgJUgptZW1iZXJSb2xlEjkKGW1lbWJlcn'
    'NfY2FuX3NlbmRfbWVzc2FnZXMYCiABKAhSFm1lbWJlcnNDYW5TZW5kTWVzc2FnZXMSIQoMbWVt'
    'YmVyX2NvdW50GAsgASgDUgttZW1iZXJDb3VudBIfCgtpc19vZmZpY2lhbBgMIAEoCFIKaXNPZm'
    'ZpY2lhbBIaCgh1c2VybmFtZRgNIAEoCVIIdXNlcm5hbWUSMwoWbWVtYmVyc19jYW5fc2VuZF9t'
    'ZWRpYRgOIAEoCFITbWVtYmVyc0NhblNlbmRNZWRpYRJCCh5tZW1iZXJzX2Nhbl9zZW5kX3N0aW'
    'NrZXJzX2dpZnMYDyABKAhSGm1lbWJlcnNDYW5TZW5kU3RpY2tlcnNHaWZzEjUKF21lbWJlcnNf'
    'Y2FuX2VtYmVkX2xpbmtzGBAgASgIUhRtZW1iZXJzQ2FuRW1iZWRMaW5rcxI1ChdtZW1iZXJzX2'
    'Nhbl9hZGRfbWVtYmVycxgRIAEoCFIUbWVtYmVyc0NhbkFkZE1lbWJlcnMSNQoXbWVtYmVyc19j'
    'YW5fY2hhbmdlX2luZm8YEiABKAhSFG1lbWJlcnNDYW5DaGFuZ2VJbmZvEioKEW1lbWJlcnNfY2'
    'FuX3JlYWN0GBMgASgIUg9tZW1iZXJzQ2FuUmVhY3QSLgoTbWVtYmVyc19jYW5fZm9yd2FyZBgU'
    'IAEoCFIRbWVtYmVyc0NhbkZvcndhcmQSKgoRc2xvd19tb2RlX3NlY29uZHMYFSABKAVSD3Nsb3'
    'dNb2RlU2Vjb25kcw==');

@$core.Deprecated('Use updateGroupChannelSendPermissionRequestDescriptor instead')
const UpdateGroupChannelSendPermissionRequest$json = {
  '1': 'UpdateGroupChannelSendPermissionRequest',
  '2': [
    {'1': 'group_channel_id', '3': 1, '4': 1, '5': 9, '10': 'groupChannelId'},
    {'1': 'members_can_send_messages', '3': 2, '4': 1, '5': 8, '10': 'membersCanSendMessages'},
  ],
};

/// Descriptor for `UpdateGroupChannelSendPermissionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateGroupChannelSendPermissionRequestDescriptor = $convert.base64Decode(
    'CidVcGRhdGVHcm91cENoYW5uZWxTZW5kUGVybWlzc2lvblJlcXVlc3QSKAoQZ3JvdXBfY2hhbm'
    '5lbF9pZBgBIAEoCVIOZ3JvdXBDaGFubmVsSWQSOQoZbWVtYmVyc19jYW5fc2VuZF9tZXNzYWdl'
    'cxgCIAEoCFIWbWVtYmVyc0NhblNlbmRNZXNzYWdlcw==');

@$core.Deprecated('Use updateGroupChannelSendPermissionResponseDescriptor instead')
const UpdateGroupChannelSendPermissionResponse$json = {
  '1': 'UpdateGroupChannelSendPermissionResponse',
  '2': [
    {'1': 'members_can_send_messages', '3': 1, '4': 1, '5': 8, '10': 'membersCanSendMessages'},
  ],
};

/// Descriptor for `UpdateGroupChannelSendPermissionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateGroupChannelSendPermissionResponseDescriptor = $convert.base64Decode(
    'CihVcGRhdGVHcm91cENoYW5uZWxTZW5kUGVybWlzc2lvblJlc3BvbnNlEjkKGW1lbWJlcnNfY2'
    'FuX3NlbmRfbWVzc2FnZXMYASABKAhSFm1lbWJlcnNDYW5TZW5kTWVzc2FnZXM=');

@$core.Deprecated('Use updateGroupChannelRequestDescriptor instead')
const UpdateGroupChannelRequest$json = {
  '1': 'UpdateGroupChannelRequest',
  '2': [
    {'1': 'group_channel_id', '3': 1, '4': 1, '5': 9, '10': 'groupChannelId'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'description', '3': 3, '4': 1, '5': 9, '10': 'description'},
    {'1': 'avatar_url', '3': 4, '4': 1, '5': 9, '10': 'avatarUrl'},
    {'1': 'visibility', '3': 5, '4': 1, '5': 9, '10': 'visibility'},
    {'1': 'update_mask', '3': 6, '4': 1, '5': 11, '6': '.google.protobuf.FieldMask', '10': 'updateMask'},
    {'1': 'username', '3': 7, '4': 1, '5': 9, '10': 'username'},
  ],
};

/// Descriptor for `UpdateGroupChannelRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateGroupChannelRequestDescriptor = $convert.base64Decode(
    'ChlVcGRhdGVHcm91cENoYW5uZWxSZXF1ZXN0EigKEGdyb3VwX2NoYW5uZWxfaWQYASABKAlSDm'
    'dyb3VwQ2hhbm5lbElkEhIKBG5hbWUYAiABKAlSBG5hbWUSIAoLZGVzY3JpcHRpb24YAyABKAlS'
    'C2Rlc2NyaXB0aW9uEh0KCmF2YXRhcl91cmwYBCABKAlSCWF2YXRhclVybBIeCgp2aXNpYmlsaX'
    'R5GAUgASgJUgp2aXNpYmlsaXR5EjsKC3VwZGF0ZV9tYXNrGAYgASgLMhouZ29vZ2xlLnByb3Rv'
    'YnVmLkZpZWxkTWFza1IKdXBkYXRlTWFzaxIaCgh1c2VybmFtZRgHIAEoCVIIdXNlcm5hbWU=');

@$core.Deprecated('Use updateGroupChannelPermissionsRequestDescriptor instead')
const UpdateGroupChannelPermissionsRequest$json = {
  '1': 'UpdateGroupChannelPermissionsRequest',
  '2': [
    {'1': 'group_channel_id', '3': 1, '4': 1, '5': 9, '10': 'groupChannelId'},
    {'1': 'members_can_send_messages', '3': 2, '4': 1, '5': 8, '10': 'membersCanSendMessages'},
    {'1': 'members_can_send_media', '3': 3, '4': 1, '5': 8, '10': 'membersCanSendMedia'},
    {'1': 'members_can_send_stickers_gifs', '3': 4, '4': 1, '5': 8, '10': 'membersCanSendStickersGifs'},
    {'1': 'members_can_embed_links', '3': 5, '4': 1, '5': 8, '10': 'membersCanEmbedLinks'},
    {'1': 'members_can_add_members', '3': 6, '4': 1, '5': 8, '10': 'membersCanAddMembers'},
    {'1': 'members_can_change_info', '3': 7, '4': 1, '5': 8, '10': 'membersCanChangeInfo'},
    {'1': 'members_can_react', '3': 8, '4': 1, '5': 8, '10': 'membersCanReact'},
    {'1': 'members_can_forward', '3': 9, '4': 1, '5': 8, '10': 'membersCanForward'},
    {'1': 'slow_mode_seconds', '3': 10, '4': 1, '5': 5, '10': 'slowModeSeconds'},
  ],
};

/// Descriptor for `UpdateGroupChannelPermissionsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateGroupChannelPermissionsRequestDescriptor = $convert.base64Decode(
    'CiRVcGRhdGVHcm91cENoYW5uZWxQZXJtaXNzaW9uc1JlcXVlc3QSKAoQZ3JvdXBfY2hhbm5lbF'
    '9pZBgBIAEoCVIOZ3JvdXBDaGFubmVsSWQSOQoZbWVtYmVyc19jYW5fc2VuZF9tZXNzYWdlcxgC'
    'IAEoCFIWbWVtYmVyc0NhblNlbmRNZXNzYWdlcxIzChZtZW1iZXJzX2Nhbl9zZW5kX21lZGlhGA'
    'MgASgIUhNtZW1iZXJzQ2FuU2VuZE1lZGlhEkIKHm1lbWJlcnNfY2FuX3NlbmRfc3RpY2tlcnNf'
    'Z2lmcxgEIAEoCFIabWVtYmVyc0NhblNlbmRTdGlja2Vyc0dpZnMSNQoXbWVtYmVyc19jYW5fZW'
    '1iZWRfbGlua3MYBSABKAhSFG1lbWJlcnNDYW5FbWJlZExpbmtzEjUKF21lbWJlcnNfY2FuX2Fk'
    'ZF9tZW1iZXJzGAYgASgIUhRtZW1iZXJzQ2FuQWRkTWVtYmVycxI1ChdtZW1iZXJzX2Nhbl9jaG'
    'FuZ2VfaW5mbxgHIAEoCFIUbWVtYmVyc0NhbkNoYW5nZUluZm8SKgoRbWVtYmVyc19jYW5fcmVh'
    'Y3QYCCABKAhSD21lbWJlcnNDYW5SZWFjdBIuChNtZW1iZXJzX2Nhbl9mb3J3YXJkGAkgASgIUh'
    'FtZW1iZXJzQ2FuRm9yd2FyZBIqChFzbG93X21vZGVfc2Vjb25kcxgKIAEoBVIPc2xvd01vZGVT'
    'ZWNvbmRz');

@$core.Deprecated('Use getGroupChannelRequestDescriptor instead')
const GetGroupChannelRequest$json = {
  '1': 'GetGroupChannelRequest',
  '2': [
    {'1': 'group_channel_id', '3': 1, '4': 1, '5': 9, '10': 'groupChannelId'},
  ],
};

/// Descriptor for `GetGroupChannelRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getGroupChannelRequestDescriptor = $convert.base64Decode(
    'ChZHZXRHcm91cENoYW5uZWxSZXF1ZXN0EigKEGdyb3VwX2NoYW5uZWxfaWQYASABKAlSDmdyb3'
    'VwQ2hhbm5lbElk');

@$core.Deprecated('Use getGroupChannelResponseDescriptor instead')
const GetGroupChannelResponse$json = {
  '1': 'GetGroupChannelResponse',
  '2': [
    {'1': 'group_channel', '3': 1, '4': 1, '5': 11, '6': '.tureon.v1.GroupChannel', '10': 'groupChannel'},
  ],
};

/// Descriptor for `GetGroupChannelResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getGroupChannelResponseDescriptor = $convert.base64Decode(
    'ChdHZXRHcm91cENoYW5uZWxSZXNwb25zZRI8Cg1ncm91cF9jaGFubmVsGAEgASgLMhcudHVyZW'
    '9uLnYxLkdyb3VwQ2hhbm5lbFIMZ3JvdXBDaGFubmVs');

@$core.Deprecated('Use updateGroupChannelResponseDescriptor instead')
const UpdateGroupChannelResponse$json = {
  '1': 'UpdateGroupChannelResponse',
  '2': [
    {'1': 'group_channel', '3': 1, '4': 1, '5': 11, '6': '.tureon.v1.GroupChannel', '10': 'groupChannel'},
  ],
};

/// Descriptor for `UpdateGroupChannelResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateGroupChannelResponseDescriptor = $convert.base64Decode(
    'ChpVcGRhdGVHcm91cENoYW5uZWxSZXNwb25zZRI8Cg1ncm91cF9jaGFubmVsGAEgASgLMhcudH'
    'VyZW9uLnYxLkdyb3VwQ2hhbm5lbFIMZ3JvdXBDaGFubmVs');

@$core.Deprecated('Use createChannelRequestDescriptor instead')
const CreateChannelRequest$json = {
  '1': 'CreateChannelRequest',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'description', '3': 2, '4': 1, '5': 9, '10': 'description'},
    {'1': 'avatar_url', '3': 3, '4': 1, '5': 9, '10': 'avatarUrl'},
    {'1': 'visibility', '3': 4, '4': 1, '5': 9, '10': 'visibility'},
  ],
};

/// Descriptor for `CreateChannelRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createChannelRequestDescriptor = $convert.base64Decode(
    'ChRDcmVhdGVDaGFubmVsUmVxdWVzdBISCgRuYW1lGAEgASgJUgRuYW1lEiAKC2Rlc2NyaXB0aW'
    '9uGAIgASgJUgtkZXNjcmlwdGlvbhIdCgphdmF0YXJfdXJsGAMgASgJUglhdmF0YXJVcmwSHgoK'
    'dmlzaWJpbGl0eRgEIAEoCVIKdmlzaWJpbGl0eQ==');

@$core.Deprecated('Use createChannelResponseDescriptor instead')
const CreateChannelResponse$json = {
  '1': 'CreateChannelResponse',
  '2': [
    {'1': 'channel', '3': 1, '4': 1, '5': 11, '6': '.tureon.v1.GroupChannel', '10': 'channel'},
  ],
};

/// Descriptor for `CreateChannelResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createChannelResponseDescriptor = $convert.base64Decode(
    'ChVDcmVhdGVDaGFubmVsUmVzcG9uc2USMQoHY2hhbm5lbBgBIAEoCzIXLnR1cmVvbi52MS5Hcm'
    '91cENoYW5uZWxSB2NoYW5uZWw=');

@$core.Deprecated('Use listMyGroupsResponseDescriptor instead')
const ListMyGroupsResponse$json = {
  '1': 'ListMyGroupsResponse',
  '2': [
    {'1': 'groups', '3': 1, '4': 3, '5': 11, '6': '.tureon.v1.GroupChannel', '10': 'groups'},
  ],
};

/// Descriptor for `ListMyGroupsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listMyGroupsResponseDescriptor = $convert.base64Decode(
    'ChRMaXN0TXlHcm91cHNSZXNwb25zZRIvCgZncm91cHMYASADKAsyFy50dXJlb24udjEuR3JvdX'
    'BDaGFubmVsUgZncm91cHM=');

@$core.Deprecated('Use listMyChannelsResponseDescriptor instead')
const ListMyChannelsResponse$json = {
  '1': 'ListMyChannelsResponse',
  '2': [
    {'1': 'channels', '3': 1, '4': 3, '5': 11, '6': '.tureon.v1.GroupChannel', '10': 'channels'},
  ],
};

/// Descriptor for `ListMyChannelsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listMyChannelsResponseDescriptor = $convert.base64Decode(
    'ChZMaXN0TXlDaGFubmVsc1Jlc3BvbnNlEjMKCGNoYW5uZWxzGAEgAygLMhcudHVyZW9uLnYxLk'
    'dyb3VwQ2hhbm5lbFIIY2hhbm5lbHM=');

@$core.Deprecated('Use searchPublicGroupsRequestDescriptor instead')
const SearchPublicGroupsRequest$json = {
  '1': 'SearchPublicGroupsRequest',
  '2': [
    {'1': 'query', '3': 1, '4': 1, '5': 9, '10': 'query'},
  ],
};

/// Descriptor for `SearchPublicGroupsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List searchPublicGroupsRequestDescriptor = $convert.base64Decode(
    'ChlTZWFyY2hQdWJsaWNHcm91cHNSZXF1ZXN0EhQKBXF1ZXJ5GAEgASgJUgVxdWVyeQ==');

@$core.Deprecated('Use searchPublicGroupsResponseDescriptor instead')
const SearchPublicGroupsResponse$json = {
  '1': 'SearchPublicGroupsResponse',
  '2': [
    {'1': 'groups', '3': 1, '4': 3, '5': 11, '6': '.tureon.v1.GroupChannel', '10': 'groups'},
  ],
};

/// Descriptor for `SearchPublicGroupsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List searchPublicGroupsResponseDescriptor = $convert.base64Decode(
    'ChpTZWFyY2hQdWJsaWNHcm91cHNSZXNwb25zZRIvCgZncm91cHMYASADKAsyFy50dXJlb24udj'
    'EuR3JvdXBDaGFubmVsUgZncm91cHM=');

@$core.Deprecated('Use joinPublicGroupRequestDescriptor instead')
const JoinPublicGroupRequest$json = {
  '1': 'JoinPublicGroupRequest',
  '2': [
    {'1': 'group_id', '3': 1, '4': 1, '5': 9, '10': 'groupId'},
  ],
};

/// Descriptor for `JoinPublicGroupRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List joinPublicGroupRequestDescriptor = $convert.base64Decode(
    'ChZKb2luUHVibGljR3JvdXBSZXF1ZXN0EhkKCGdyb3VwX2lkGAEgASgJUgdncm91cElk');

@$core.Deprecated('Use joinPublicGroupResponseDescriptor instead')
const JoinPublicGroupResponse$json = {
  '1': 'JoinPublicGroupResponse',
  '2': [
    {'1': 'group', '3': 1, '4': 1, '5': 11, '6': '.tureon.v1.GroupChannel', '10': 'group'},
  ],
};

/// Descriptor for `JoinPublicGroupResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List joinPublicGroupResponseDescriptor = $convert.base64Decode(
    'ChdKb2luUHVibGljR3JvdXBSZXNwb25zZRItCgVncm91cBgBIAEoCzIXLnR1cmVvbi52MS5Hcm'
    '91cENoYW5uZWxSBWdyb3Vw');

@$core.Deprecated('Use searchPublicChannelsRequestDescriptor instead')
const SearchPublicChannelsRequest$json = {
  '1': 'SearchPublicChannelsRequest',
  '2': [
    {'1': 'query', '3': 1, '4': 1, '5': 9, '10': 'query'},
  ],
};

/// Descriptor for `SearchPublicChannelsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List searchPublicChannelsRequestDescriptor = $convert.base64Decode(
    'ChtTZWFyY2hQdWJsaWNDaGFubmVsc1JlcXVlc3QSFAoFcXVlcnkYASABKAlSBXF1ZXJ5');

@$core.Deprecated('Use searchPublicChannelsResponseDescriptor instead')
const SearchPublicChannelsResponse$json = {
  '1': 'SearchPublicChannelsResponse',
  '2': [
    {'1': 'channels', '3': 1, '4': 3, '5': 11, '6': '.tureon.v1.GroupChannel', '10': 'channels'},
  ],
};

/// Descriptor for `SearchPublicChannelsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List searchPublicChannelsResponseDescriptor = $convert.base64Decode(
    'ChxTZWFyY2hQdWJsaWNDaGFubmVsc1Jlc3BvbnNlEjMKCGNoYW5uZWxzGAEgAygLMhcudHVyZW'
    '9uLnYxLkdyb3VwQ2hhbm5lbFIIY2hhbm5lbHM=');

@$core.Deprecated('Use joinPublicChannelRequestDescriptor instead')
const JoinPublicChannelRequest$json = {
  '1': 'JoinPublicChannelRequest',
  '2': [
    {'1': 'channel_id', '3': 1, '4': 1, '5': 9, '10': 'channelId'},
  ],
};

/// Descriptor for `JoinPublicChannelRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List joinPublicChannelRequestDescriptor = $convert.base64Decode(
    'ChhKb2luUHVibGljQ2hhbm5lbFJlcXVlc3QSHQoKY2hhbm5lbF9pZBgBIAEoCVIJY2hhbm5lbE'
    'lk');

@$core.Deprecated('Use joinPublicChannelResponseDescriptor instead')
const JoinPublicChannelResponse$json = {
  '1': 'JoinPublicChannelResponse',
  '2': [
    {'1': 'channel', '3': 1, '4': 1, '5': 11, '6': '.tureon.v1.GroupChannel', '10': 'channel'},
  ],
};

/// Descriptor for `JoinPublicChannelResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List joinPublicChannelResponseDescriptor = $convert.base64Decode(
    'ChlKb2luUHVibGljQ2hhbm5lbFJlc3BvbnNlEjEKB2NoYW5uZWwYASABKAsyFy50dXJlb24udj'
    'EuR3JvdXBDaGFubmVsUgdjaGFubmVs');

@$core.Deprecated('Use groupChannelMemberDescriptor instead')
const GroupChannelMember$json = {
  '1': 'GroupChannelMember',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'role', '3': 2, '4': 1, '5': 9, '10': 'role'},
    {'1': 'joined_at', '3': 3, '4': 1, '5': 3, '10': 'joinedAt'},
    {'1': 'display_name', '3': 4, '4': 1, '5': 9, '10': 'displayName'},
    {'1': 'username', '3': 5, '4': 1, '5': 9, '10': 'username'},
    {'1': 'avatar_url', '3': 6, '4': 1, '5': 9, '10': 'avatarUrl'},
  ],
};

/// Descriptor for `GroupChannelMember`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List groupChannelMemberDescriptor = $convert.base64Decode(
    'ChJHcm91cENoYW5uZWxNZW1iZXISFwoHdXNlcl9pZBgBIAEoCVIGdXNlcklkEhIKBHJvbGUYAi'
    'ABKAlSBHJvbGUSGwoJam9pbmVkX2F0GAMgASgDUghqb2luZWRBdBIhCgxkaXNwbGF5X25hbWUY'
    'BCABKAlSC2Rpc3BsYXlOYW1lEhoKCHVzZXJuYW1lGAUgASgJUgh1c2VybmFtZRIdCgphdmF0YX'
    'JfdXJsGAYgASgJUglhdmF0YXJVcmw=');

@$core.Deprecated('Use listGroupChannelMembersResponseDescriptor instead')
const ListGroupChannelMembersResponse$json = {
  '1': 'ListGroupChannelMembersResponse',
  '2': [
    {'1': 'members', '3': 1, '4': 3, '5': 11, '6': '.tureon.v1.GroupChannelMember', '10': 'members'},
  ],
};

/// Descriptor for `ListGroupChannelMembersResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listGroupChannelMembersResponseDescriptor = $convert.base64Decode(
    'Ch9MaXN0R3JvdXBDaGFubmVsTWVtYmVyc1Jlc3BvbnNlEjcKB21lbWJlcnMYASADKAsyHS50dX'
    'Jlb24udjEuR3JvdXBDaGFubmVsTWVtYmVyUgdtZW1iZXJz');

@$core.Deprecated('Use listGroupChannelMembersPageRequestDescriptor instead')
const ListGroupChannelMembersPageRequest$json = {
  '1': 'ListGroupChannelMembersPageRequest',
  '2': [
    {'1': 'group_channel_id', '3': 1, '4': 1, '5': 9, '10': 'groupChannelId'},
    {'1': 'page_size', '3': 2, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'offset', '3': 3, '4': 1, '5': 3, '10': 'offset'},
  ],
};

/// Descriptor for `ListGroupChannelMembersPageRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listGroupChannelMembersPageRequestDescriptor = $convert.base64Decode(
    'CiJMaXN0R3JvdXBDaGFubmVsTWVtYmVyc1BhZ2VSZXF1ZXN0EigKEGdyb3VwX2NoYW5uZWxfaW'
    'QYASABKAlSDmdyb3VwQ2hhbm5lbElkEhsKCXBhZ2Vfc2l6ZRgCIAEoBVIIcGFnZVNpemUSFgoG'
    'b2Zmc2V0GAMgASgDUgZvZmZzZXQ=');

@$core.Deprecated('Use listGroupChannelMembersPageResponseDescriptor instead')
const ListGroupChannelMembersPageResponse$json = {
  '1': 'ListGroupChannelMembersPageResponse',
  '2': [
    {'1': 'members', '3': 1, '4': 3, '5': 11, '6': '.tureon.v1.GroupChannelMember', '10': 'members'},
    {'1': 'total_count', '3': 2, '4': 1, '5': 3, '10': 'totalCount'},
    {'1': 'next_offset', '3': 3, '4': 1, '5': 3, '10': 'nextOffset'},
    {'1': 'has_more', '3': 4, '4': 1, '5': 8, '10': 'hasMore'},
  ],
};

/// Descriptor for `ListGroupChannelMembersPageResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listGroupChannelMembersPageResponseDescriptor = $convert.base64Decode(
    'CiNMaXN0R3JvdXBDaGFubmVsTWVtYmVyc1BhZ2VSZXNwb25zZRI3CgdtZW1iZXJzGAEgAygLMh'
    '0udHVyZW9uLnYxLkdyb3VwQ2hhbm5lbE1lbWJlclIHbWVtYmVycxIfCgt0b3RhbF9jb3VudBgC'
    'IAEoA1IKdG90YWxDb3VudBIfCgtuZXh0X29mZnNldBgDIAEoA1IKbmV4dE9mZnNldBIZCghoYX'
    'NfbW9yZRgEIAEoCFIHaGFzTW9yZQ==');

@$core.Deprecated('Use getGroupOnlineMemberCountRequestDescriptor instead')
const GetGroupOnlineMemberCountRequest$json = {
  '1': 'GetGroupOnlineMemberCountRequest',
  '2': [
    {'1': 'group_id', '3': 1, '4': 1, '5': 9, '10': 'groupId'},
  ],
};

/// Descriptor for `GetGroupOnlineMemberCountRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getGroupOnlineMemberCountRequestDescriptor = $convert.base64Decode(
    'CiBHZXRHcm91cE9ubGluZU1lbWJlckNvdW50UmVxdWVzdBIZCghncm91cF9pZBgBIAEoCVIHZ3'
    'JvdXBJZA==');

@$core.Deprecated('Use getGroupOnlineMemberCountResponseDescriptor instead')
const GetGroupOnlineMemberCountResponse$json = {
  '1': 'GetGroupOnlineMemberCountResponse',
  '2': [
    {'1': 'online_member_count', '3': 1, '4': 1, '5': 3, '10': 'onlineMemberCount'},
  ],
};

/// Descriptor for `GetGroupOnlineMemberCountResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getGroupOnlineMemberCountResponseDescriptor = $convert.base64Decode(
    'CiFHZXRHcm91cE9ubGluZU1lbWJlckNvdW50UmVzcG9uc2USLgoTb25saW5lX21lbWJlcl9jb3'
    'VudBgBIAEoA1IRb25saW5lTWVtYmVyQ291bnQ=');

@$core.Deprecated('Use botDescriptor instead')
const Bot$json = {
  '1': 'Bot',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'username', '3': 2, '4': 1, '5': 9, '10': 'username'},
    {'1': 'display_name', '3': 3, '4': 1, '5': 9, '10': 'displayName'},
    {'1': 'description', '3': 4, '4': 1, '5': 9, '10': 'description'},
    {'1': 'created_at', '3': 7, '4': 1, '5': 3, '10': 'createdAt'},
    {'1': 'verification_badge', '3': 8, '4': 1, '5': 9, '10': 'verificationBadge'},
  ],
  '9': [
    {'1': 5, '2': 6},
    {'1': 6, '2': 7},
  ],
};

/// Descriptor for `Bot`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List botDescriptor = $convert.base64Decode(
    'CgNCb3QSDgoCaWQYASABKAlSAmlkEhoKCHVzZXJuYW1lGAIgASgJUgh1c2VybmFtZRIhCgxkaX'
    'NwbGF5X25hbWUYAyABKAlSC2Rpc3BsYXlOYW1lEiAKC2Rlc2NyaXB0aW9uGAQgASgJUgtkZXNj'
    'cmlwdGlvbhIdCgpjcmVhdGVkX2F0GAcgASgDUgljcmVhdGVkQXQSLQoSdmVyaWZpY2F0aW9uX2'
    'JhZGdlGAggASgJUhF2ZXJpZmljYXRpb25CYWRnZUoECAUQBkoECAYQBw==');

@$core.Deprecated('Use interactBotRequestDescriptor instead')
const InteractBotRequest$json = {
  '1': 'InteractBotRequest',
  '2': [
    {'1': 'bot_username', '3': 1, '4': 1, '5': 9, '10': 'botUsername'},
    {'1': 'text', '3': 2, '4': 1, '5': 9, '10': 'text'},
    {'1': 'client_message_id', '3': 3, '4': 1, '5': 9, '10': 'clientMessageId'},
  ],
};

/// Descriptor for `InteractBotRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List interactBotRequestDescriptor = $convert.base64Decode(
    'ChJJbnRlcmFjdEJvdFJlcXVlc3QSIQoMYm90X3VzZXJuYW1lGAEgASgJUgtib3RVc2VybmFtZR'
    'ISCgR0ZXh0GAIgASgJUgR0ZXh0EioKEWNsaWVudF9tZXNzYWdlX2lkGAMgASgJUg9jbGllbnRN'
    'ZXNzYWdlSWQ=');

@$core.Deprecated('Use interactBotResponseDescriptor instead')
const InteractBotResponse$json = {
  '1': 'InteractBotResponse',
  '2': [
    {'1': 'bot', '3': 1, '4': 1, '5': 11, '6': '.tureon.v1.Bot', '10': 'bot'},
    {'1': 'response_text', '3': 2, '4': 1, '5': 9, '10': 'responseText'},
    {'1': 'first_interaction', '3': 3, '4': 1, '5': 8, '10': 'firstInteraction'},
    {'1': 'event_id', '3': 4, '4': 1, '5': 9, '10': 'eventId'},
  ],
};

/// Descriptor for `InteractBotResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List interactBotResponseDescriptor = $convert.base64Decode(
    'ChNJbnRlcmFjdEJvdFJlc3BvbnNlEiAKA2JvdBgBIAEoCzIOLnR1cmVvbi52MS5Cb3RSA2JvdB'
    'IjCg1yZXNwb25zZV90ZXh0GAIgASgJUgxyZXNwb25zZVRleHQSKwoRZmlyc3RfaW50ZXJhY3Rp'
    'b24YAyABKAhSEGZpcnN0SW50ZXJhY3Rpb24SGQoIZXZlbnRfaWQYBCABKAlSB2V2ZW50SWQ=');

