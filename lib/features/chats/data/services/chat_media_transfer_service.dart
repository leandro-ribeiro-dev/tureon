import 'dart:convert';
import 'dart:io';

import 'package:cryptography/cryptography.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../../domain/chat_message.dart';
import '../../../../core/storage/chat_store.dart';
import '../../../../core/storage/message_records.dart';

/// Moves binary data over a bounded HTTP endpoint. The real-time message
/// stream carries only a compact JSON reference and caption.
class ChatMediaTransferService {
  ChatMediaTransferService({
    required String host,
    required int port,
    required bool secure,
    required this.store,
    HttpClient? client,
  }) : _baseUri = Uri(
         scheme: secure ? 'https' : 'http',
         host: host,
         port: port,
       ),
       _client = client ?? HttpClient()
         ..connectionTimeout = const Duration(seconds: 15)
         ..idleTimeout = const Duration(seconds: 30);

  static const maxUploadBytes = 50 * 1024 * 1024;
  static const maxSecretUploadBytes = 10 * 1024 * 1024;
  static const _transferTimeout = Duration(minutes: 15);

  final Uri _baseUri;
  final HttpClient _client;
  final ChatStore store;
  final AesGcm _secretAttachmentCipher = AesGcm.with256bits();

  /// Prepares the message wire payload. If a draft contains a local file, the
  /// upload uses the stable media id persisted with the outbox, so retry is
  /// idempotent without reusing a secret message's server-visible ID.
  Future<List<int>> prepareOutboxPayload(OutboxRecord outbox) async {
    final decoded = _tryDecodeEnvelope(outbox.payload);
    if (decoded == null) return outbox.payload;
    final attachmentJson = decoded['attachment'];
    if (attachmentJson is! Map<String, Object?>) return outbox.payload;
    var attachment = ChatAttachment.fromJson(attachmentJson);
    final localPath = attachment.localPath;
    if (localPath != null) {
      if (attachment.mediaId == null || !_isUuid(attachment.mediaId!)) {
        throw StateError('O identificador local da mídia é inválido.');
      }
      final file = File(localPath);
      if (!await file.exists()) {
        throw StateError('O arquivo local não está mais disponível.');
      }
      final size = await file.length();
      final maxBytes = outbox.isSecret
          ? maxSecretUploadBytes + 32
          : maxUploadBytes;
      if (size <= 0 || size > maxBytes) {
        throw StateError('O arquivo ultrapassa o limite de envio.');
      }
      final session = store.loadSession();
      if (session == null || session.accessToken.isEmpty) {
        throw StateError(
          'Uma sessão autenticada é necessária para enviar mídia.',
        );
      }
      final response = await _upload(
        file: file,
        mediaId: attachment.mediaId!,
        chatId: outbox.chatId,
        // Secret-chat file names and MIME types remain inside the encrypted
        // message payload. The media server sees opaque ciphertext only.
        fileName: outbox.isSecret ? 'encrypted.bin' : attachment.fileName,
        mimeType: outbox.isSecret
            ? 'application/octet-stream'
            : attachment.mimeType,
        token: session.accessToken,
      );
      attachment = attachment.copyWith(
        mediaId: response['media_id'] as String? ?? attachment.mediaId,
        sizeBytes: attachment.sizeBytes == 0
            ? (response['size_bytes'] as int? ?? size)
            : attachment.sizeBytes,
        sha256: outbox.isSecret
            ? attachment.sha256
            : response['sha256'] as String?,
        clearLocalPath: true,
      );
      decoded['attachment'] = attachment.toJson(includeLocalPath: false);
    }
    decoded.remove('draft');
    return utf8.encode(jsonEncode(decoded));
  }

  /// Encrypts a secret-chat file before it is queued or uploaded. Only the
  /// Signal-encrypted message payload contains the AES key and nonce.
  Future<ChatAttachment> encryptSecretAttachment({
    required String sourcePath,
    required String mediaId,
    required String fileName,
    required String mimeType,
    required int durationMillis,
  }) async {
    final source = File(sourcePath);
    final size = await source.length();
    if (size <= 0 || size > maxSecretUploadBytes) {
      throw StateError('Anexos em chat secreto têm limite de 10 MB.');
    }
    final temporaryDirectory = await getApplicationSupportDirectory();
    final secretDirectory = Directory(
      path.join(temporaryDirectory.path, 'tureon_secret_media'),
    );
    await secretDirectory.create(recursive: true);
    final encryptedPath = path.join(secretDirectory.path, '$mediaId.enc');
    final key = await _secretAttachmentCipher.newSecretKey();
    final keyBytes = await key.extractBytes();
    final nonce = _secretAttachmentCipher.newNonce();
    final cleartext = await source.readAsBytes();
    final encrypted = await _secretAttachmentCipher.encrypt(
      cleartext,
      secretKey: key,
      nonce: nonce,
    );
    await File(encryptedPath).writeAsBytes(<int>[
      ...encrypted.cipherText,
      ...encrypted.mac.bytes,
    ], flush: true);
    return ChatAttachment(
      mediaId: mediaId,
      fileName: fileName,
      mimeType: mimeType,
      sizeBytes: size,
      localPath: encryptedPath,
      durationMillis: durationMillis,
      encryptionKey: base64UrlEncode(keyBytes),
      encryptionNonce: base64UrlEncode(nonce),
      encryptionMac: base64UrlEncode(encrypted.mac.bytes),
    );
  }

  /// Downloads only after the recipient opens the attachment, then caches it
  /// under an opaque media id. Secret-chat files are authenticated/decrypted
  /// locally before they are exposed to the platform viewer.
  Future<String> resolveLocalPath(ChatAttachment attachment) async {
    if (attachment.localPath != null) {
      final localFile = File(attachment.localPath!);
      if (await localFile.exists() && !attachment.isEncrypted) {
        return localFile.path;
      }
    }
    final mediaId = attachment.mediaId;
    if (mediaId == null || !_isUuid(mediaId)) {
      throw StateError('Esta mídia não tem uma referência válida.');
    }
    final cacheDirectory = await getTemporaryDirectory();
    final mediaDirectory = Directory(
      path.join(cacheDirectory.path, 'tureon_media'),
    );
    await mediaDirectory.create(recursive: true);
    final extension = _safeExtension(attachment.fileName);
    final outputPath = path.join(mediaDirectory.path, '$mediaId$extension');
    final output = File(outputPath);
    if (await output.exists()) return output.path;

    if (attachment.isEncrypted && attachment.localPath != null) {
      final localEncryptedFile = File(attachment.localPath!);
      if (await localEncryptedFile.exists()) {
        await _decryptSecretFile(localEncryptedFile, output, attachment);
        return output.path;
      }
    }

    final session = store.loadSession();
    if (session == null || session.accessToken.isEmpty) {
      throw StateError('Conecte-se para baixar este anexo.');
    }

    final request = await _client.getUrl(_mediaUri(mediaId));
    request.headers.set(
      HttpHeaders.authorizationHeader,
      'Bearer ${session.accessToken}',
    );
    final response = await request.close().timeout(_transferTimeout);
    if (response.statusCode != HttpStatus.ok) {
      final body = await _readSmallResponse(response);
      throw HttpException(
        'Download de mídia falhou (${response.statusCode}): $body',
      );
    }
    final maxBytes = attachment.isEncrypted
        ? maxSecretUploadBytes + 32
        : maxUploadBytes;
    if (response.contentLength > maxBytes) {
      await response.drain<void>();
      throw StateError('O anexo baixado ultrapassa o limite local.');
    }
    final stagedPath = '$outputPath.part';
    final staged = File(stagedPath);
    await staged.parent.create(recursive: true);
    try {
      var receivedBytes = 0;
      final sink = staged.openWrite();
      try {
        await for (final chunk in response.timeout(_transferTimeout)) {
          receivedBytes += chunk.length;
          if (receivedBytes > maxBytes) {
            throw StateError('O anexo baixado ultrapassa o limite local.');
          }
          sink.add(chunk);
        }
        await sink.flush();
      } finally {
        await sink.close();
      }
      if (attachment.isEncrypted) {
        if (attachment.sizeBytes > 0 &&
            receivedBytes != attachment.sizeBytes + 16) {
          throw StateError('O tamanho do anexo secreto não confere.');
        }
        await _decryptSecretFile(staged, output, attachment);
        await staged.delete();
      } else {
        if (attachment.sizeBytes > 0 && receivedBytes != attachment.sizeBytes) {
          throw StateError('O tamanho do anexo não confere.');
        }
        if (await output.exists()) await output.delete();
        await staged.rename(output.path);
      }
    } catch (_) {
      if (await staged.exists()) await staged.delete();
      rethrow;
    }
    return output.path;
  }

  Future<void> _decryptSecretFile(
    File encryptedFile,
    File output,
    ChatAttachment attachment,
  ) async {
    final keyText = attachment.encryptionKey;
    final nonceText = attachment.encryptionNonce;
    final macText = attachment.encryptionMac;
    if (keyText == null || nonceText == null || macText == null) {
      throw StateError('Os metadados do anexo secreto estão incompletos.');
    }
    final encryptedBytes = await encryptedFile.readAsBytes();
    if (encryptedBytes.length < 16 ||
        encryptedBytes.length > maxSecretUploadBytes + 32) {
      throw StateError('O arquivo secreto tem tamanho inválido.');
    }
    final mac = base64Url.decode(macText);
    if (mac.length != 16 || encryptedBytes.length < mac.length) {
      throw StateError('A autenticação do anexo secreto é inválida.');
    }
    final cipherText = encryptedBytes.sublist(
      0,
      encryptedBytes.length - mac.length,
    );
    final secretBox = SecretBox(
      cipherText,
      nonce: base64Url.decode(nonceText),
      mac: Mac(mac),
    );
    final cleartext = await _secretAttachmentCipher.decrypt(
      secretBox,
      secretKey: SecretKey(base64Url.decode(keyText)),
    );
    if (attachment.sizeBytes > 0 && cleartext.length != attachment.sizeBytes) {
      throw StateError('O tamanho do anexo secreto não confere.');
    }
    await output.parent.create(recursive: true);
    final stagedOutput = File('${output.path}.decrypt.part');
    try {
      await stagedOutput.writeAsBytes(cleartext, flush: true);
      if (await output.exists()) await output.delete();
      await stagedOutput.rename(output.path);
    } catch (_) {
      if (await stagedOutput.exists()) await stagedOutput.delete();
      rethrow;
    }
  }

  Future<Map<String, Object?>> _upload({
    required File file,
    required String mediaId,
    required String chatId,
    required String fileName,
    required String mimeType,
    required String token,
  }) async {
    final request = await _client.putUrl(_mediaUri(mediaId));
    request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
    request.headers.set('X-Chat-ID', chatId);
    request.headers.set('X-File-Name', Uri.encodeComponent(fileName));
    request.headers.contentType = ContentType.parse(mimeType);
    request.contentLength = await file.length();
    await request.addStream(file.openRead()).timeout(_transferTimeout);
    final response = await request.close().timeout(_transferTimeout);
    final body = await _readSmallResponse(response);
    if (response.statusCode != HttpStatus.created &&
        response.statusCode != HttpStatus.ok) {
      throw HttpException(
        'Upload de mídia falhou (${response.statusCode}): $body',
      );
    }
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, Object?>) {
      throw const FormatException('Resposta inválida do servidor de mídia.');
    }
    return decoded;
  }

  Future<String> _readSmallResponse(HttpClientResponse response) async {
    final bytes = await response.fold<List<int>>(<int>[], (result, chunk) {
      if (result.length + chunk.length > 16 * 1024) {
        throw const FormatException('Resposta de mídia muito grande.');
      }
      return result..addAll(chunk);
    });
    return utf8.decode(bytes, allowMalformed: true);
  }

  Uri _mediaUri(String mediaId) => _baseUri.replace(path: '/v1/media/$mediaId');

  Map<String, Object?>? _tryDecodeEnvelope(List<int> payload) {
    try {
      final decoded = jsonDecode(utf8.decode(payload));
      return decoded is Map<String, Object?> && decoded['version'] == 1
          ? decoded
          : null;
    } on FormatException {
      return null;
    }
  }

  String _safeExtension(String fileName) {
    final extension = path.extension(fileName);
    return RegExp(r'^\.[A-Za-z0-9]{1,10}$').hasMatch(extension)
        ? extension.toLowerCase()
        : '';
  }

  bool _isUuid(String value) => RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  ).hasMatch(value);

  void close() => _client.close(force: true);
}
