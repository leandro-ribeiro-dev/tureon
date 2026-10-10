import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cryptography/cryptography.dart';

import '../storage/local_store.dart';
import 'secret_chat_crypto_service.dart';

final class LocalSignalRecordStorage implements SignalRecordStorage {
  LocalSignalRecordStorage({
    required this.store,
    required this.secureStorage,
    required String userId,
    required String deviceId,
  }) : _prefix = 'signal/v1/$userId/$deviceId/';

  static const _keySuffix = 'storage-key';
  static final _cipher = AesGcm.with256bits();

  final LocalStore store;
  final FlutterSecureStorage secureStorage;
  final String _prefix;
  Future<SecretKey>? _key;

  Future<SecretKey> _encryptionKey() => _key ??= _loadOrCreateKey();

  Future<SecretKey> _loadOrCreateKey() async {
    final storageKey = '$_prefix$_keySuffix';
    final encoded = await secureStorage.read(key: storageKey);
    if (encoded != null) {
      final bytes = base64Decode(encoded);
      if (bytes.length != 32) {
        throw StateError('Invalid encrypted Signal storage key length.');
      }
      return SecretKey(bytes);
    }
    final bytes = List<int>.generate(32, (_) => Random.secure().nextInt(256));
    await secureStorage.write(key: storageKey, value: base64Encode(bytes));
    return SecretKey(bytes);
  }

  @override
  Future<Uint8List?> read(String key) async {
    final stored = store.readSignalProtocolRecord('$_prefix$key');
    if (stored == null) return null;
    if (stored.length < 12 + 16) {
      throw StateError('Encrypted Signal record is truncated.');
    }
    final nonce = stored.sublist(0, 12);
    final mac = Mac(stored.sublist(stored.length - 16));
    final ciphertext = stored.sublist(12, stored.length - 16);
    final cleartext = await _cipher.decrypt(
      SecretBox(ciphertext, nonce: nonce, mac: mac),
      secretKey: await _encryptionKey(),
      aad: utf8.encode('$_prefix$key'),
    );
    return Uint8List.fromList(cleartext);
  }

  @override
  Future<void> write(String key, Uint8List value) async {
    final secretBox = await _cipher.encrypt(
      value,
      secretKey: await _encryptionKey(),
      aad: utf8.encode('$_prefix$key'),
    );
    store.writeSignalProtocolRecord(
      '$_prefix$key',
      Uint8List.fromList([
        ...secretBox.nonce,
        ...secretBox.cipherText,
        ...secretBox.mac.bytes,
      ]),
    );
  }

  @override
  Future<void> delete(String key) async {
    store.deleteSignalProtocolRecord('$_prefix$key');
  }

  @override
  Future<List<String>> keys(String prefix) async {
    return store
        .listSignalProtocolRecordKeys('$_prefix$prefix')
        .map((key) => key.substring(_prefix.length))
        .toList(growable: false);
  }
}
