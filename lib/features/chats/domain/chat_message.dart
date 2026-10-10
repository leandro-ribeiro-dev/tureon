// `system` keeps its historic local ordinal at 5. New types are appended so
// existing SQLite rows do not change meaning during an app upgrade.
enum ChatMessageType {
  unspecified,
  text,
  image,
  video,
  audio,
  system,
  voiceNote,
  file,
  sticker,
  gif,
  location,
  contactCard,
  reply,
  forward,
  reaction,
  edit,
  delete,
}

class ChatAttachment {
  static const locationMimeType = 'application/vnd.tureon.location+json';

  const ChatAttachment({
    this.mediaId,
    required this.fileName,
    required this.mimeType,
    this.sizeBytes = 0,
    this.sha256,
    this.localPath,
    this.latitude,
    this.longitude,
    this.placeName,
    this.durationMillis,
    this.encryptionKey,
    this.encryptionNonce,
    this.encryptionMac,
  });

  final String? mediaId;
  final String fileName;
  final String mimeType;
  final int sizeBytes;
  final String? sha256;
  final String? localPath;
  final double? latitude;
  final double? longitude;
  final String? placeName;
  final int? durationMillis;
  // Secret-chat attachment keys are carried only inside Signal-encrypted
  // message payloads. They are never sent as upload headers or server metadata.
  final String? encryptionKey;
  final String? encryptionNonce;
  final String? encryptionMac;

  bool get isLocation {
    final lat = latitude;
    final lng = longitude;
    return mimeType == locationMimeType &&
        lat != null &&
        lng != null &&
        lat.isFinite &&
        lng.isFinite &&
        lat >= -90 &&
        lat <= 90 &&
        lng >= -180 &&
        lng <= 180;
  }

  bool get isEncrypted => encryptionKey != null;

  ChatAttachment copyWith({
    String? mediaId,
    String? fileName,
    String? mimeType,
    int? sizeBytes,
    String? sha256,
    String? localPath,
    bool clearLocalPath = false,
  }) => ChatAttachment(
    mediaId: mediaId ?? this.mediaId,
    fileName: fileName ?? this.fileName,
    mimeType: mimeType ?? this.mimeType,
    sizeBytes: sizeBytes ?? this.sizeBytes,
    sha256: sha256 ?? this.sha256,
    localPath: clearLocalPath ? null : localPath ?? this.localPath,
    latitude: latitude,
    longitude: longitude,
    placeName: placeName,
    durationMillis: durationMillis,
    encryptionKey: encryptionKey,
    encryptionNonce: encryptionNonce,
    encryptionMac: encryptionMac,
  );

  Map<String, Object?> toJson({bool includeLocalPath = true}) => {
    if (mediaId != null) 'media_id': mediaId,
    'file_name': fileName,
    'mime_type': mimeType,
    'size_bytes': sizeBytes,
    if (sha256 != null) 'sha256': sha256,
    if (includeLocalPath && localPath != null) 'local_path': localPath,
    if (latitude != null) 'latitude': latitude,
    if (longitude != null) 'longitude': longitude,
    if (placeName != null) 'place_name': placeName,
    if (durationMillis != null) 'duration_millis': durationMillis,
    if (encryptionKey != null) 'encryption_key': encryptionKey,
    if (encryptionNonce != null) 'encryption_nonce': encryptionNonce,
    if (encryptionMac != null) 'encryption_mac': encryptionMac,
  };

  factory ChatAttachment.fromJson(Map<String, Object?> json) => ChatAttachment(
    mediaId: _safeMediaId(json['media_id']),
    fileName: _safeFileName(json['file_name']),
    mimeType: _safeMimeType(json['mime_type']),
    sizeBytes: _safeSize(json['size_bytes']),
    sha256: _safeSha256(json['sha256']),
    localPath: json['local_path'] as String?,
    latitude: _safeLatitude(json['latitude']),
    longitude: _safeLongitude(json['longitude']),
    placeName: _safePlaceName(json['place_name']),
    durationMillis: _safeDuration(json['duration_millis']),
    encryptionKey: _boundedString(json['encryption_key'], 128),
    encryptionNonce: _boundedString(json['encryption_nonce'], 64),
    encryptionMac: _boundedString(json['encryption_mac'], 64),
  );
}

String? _safeMediaId(Object? value) {
  if (value is! String ||
      !RegExp(
        r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
      ).hasMatch(value)) {
    return null;
  }
  return value.toLowerCase();
}

String _safeFileName(Object? value) {
  if (value is! String) return 'Anexo';
  final name = value
      .replaceAll('\\', '/')
      .split('/')
      .last
      .replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '')
      .trim();
  if (name.isEmpty) return 'Anexo';
  return String.fromCharCodes(name.runes.take(180));
}

String _safeMimeType(Object? value) {
  if (value is! String ||
      value.length > 127 ||
      !RegExp(
        r'^[A-Za-z0-9!#$&^_.+-]+/[A-Za-z0-9!#$&^_.+-]+$',
      ).hasMatch(value)) {
    return 'application/octet-stream';
  }
  return value.toLowerCase();
}

int _safeSize(Object? value) {
  if (value is! num || !value.isFinite || value < 0) return 0;
  return value.toInt().clamp(0, 50 * 1024 * 1024 + 32);
}

String? _safeSha256(Object? value) =>
    value is String && RegExp(r'^[0-9a-fA-F]{64}$').hasMatch(value)
    ? value.toLowerCase()
    : null;

double? _safeLatitude(Object? value) {
  if (value is! num || !value.isFinite || value < -90 || value > 90) {
    return null;
  }
  return value.toDouble();
}

double? _safeLongitude(Object? value) {
  if (value is! num || !value.isFinite || value < -180 || value > 180) {
    return null;
  }
  return value.toDouble();
}

int? _safeDuration(Object? value) {
  if (value is! num || !value.isFinite || value < 0) return null;
  return value.toInt().clamp(0, const Duration(hours: 24).inMilliseconds);
}

String? _safePlaceName(Object? value) =>
    _boundedString(value, 256)?.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '');

String? _boundedString(Object? value, int maxLength) =>
    value is String && value.length <= maxLength ? value : null;

class ChatMessage {
  const ChatMessage({
    required this.messageId,
    required this.chatId,
    required this.senderRecipientId,
    required this.body,
    required this.createdAt,
    this.type = ChatMessageType.text,
    this.replyToMessageId,
    this.attachment,
    this.editedAt,
    this.status = ChatDeliveryStatus.sent,
    this.isDeleted = false,
  });

  final String messageId;
  final String chatId;
  final String senderRecipientId;
  final String body;
  final DateTime createdAt;
  final ChatMessageType type;
  final String? replyToMessageId;
  final ChatAttachment? attachment;
  final DateTime? editedAt;
  final ChatDeliveryStatus status;
  final bool isDeleted;
}

enum ChatDeliveryStatus {
  unspecified,
  sent,
  delivered,
  read,
  pending,
  sending,
  failed,
}
