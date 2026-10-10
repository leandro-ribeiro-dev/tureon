import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:tureon/core/crypto/secret_chat_crypto_service.dart';

void main() {
  group('SecretChatCryptoService', () {
    test(
      'encrypts and decrypts initial PQXDH and subsequent messages',
      () async {
        final server = _FakeKeyServer();
        final alice = SecretChatCryptoService(
          localUserId: 'alice',
          localSignalDeviceId: 1,
          storage: _MemorySignalRecordStorage(),
          keyBundleApi: server.forDevice('alice', 'alice-server-device', 1),
          initialOneTimePreKeyCount: 2,
          refillBatchSize: 2,
        );
        final bob = SecretChatCryptoService(
          localUserId: 'bob',
          localSignalDeviceId: 1,
          storage: _MemorySignalRecordStorage(),
          keyBundleApi: server.forDevice('bob', 'bob-server-device', 1),
          initialOneTimePreKeyCount: 2,
          refillBatchSize: 2,
        );

        await Future.wait([alice.initialize(), bob.initialize()]);

        final first = await alice.encrypt(
          secretChatId: 'bob',
          recipientServerDeviceId: 'bob-server-device',
          plaintext: Uint8List.fromList([1, 2, 3]),
        );
        expect(await bob.decrypt(secretChatId: 'alice', ciphertext: first), [
          1,
          2,
          3,
        ]);

        final secondFromAlice = await alice.encrypt(
          secretChatId: 'bob',
          recipientServerDeviceId: 'bob-server-device',
          plaintext: Uint8List.fromList([7, 8, 9]),
        );
        expect(
          await bob.decrypt(secretChatId: 'alice', ciphertext: secondFromAlice),
          [7, 8, 9],
        );
        expect(server.bundleFetches['bob/bob-server-device'], 1);

        final second = await bob.encrypt(
          secretChatId: 'alice',
          recipientServerDeviceId: 'alice-server-device',
          plaintext: Uint8List.fromList([4, 5, 6]),
        );
        expect(await alice.decrypt(secretChatId: 'bob', ciphertext: second), [
          4,
          5,
          6,
        ]);
      },
    );

    test('rejects malformed framing before attempting decryption', () async {
      final service = SecretChatCryptoService(
        localUserId: 'alice',
        localSignalDeviceId: 1,
        storage: _MemorySignalRecordStorage(),
        keyBundleApi: _FakeKeyServer().forDevice(
          'alice',
          'alice-server-device',
          1,
        ),
      );
      await expectLater(
        service.decrypt(
          secretChatId: 'bob',
          ciphertext: Uint8List.fromList([1, 2, 3]),
        ),
        throwsFormatException,
      );
    });

    test(
      'generates and uploads a replacement pre-key batch on refill',
      () async {
        final server = _FakeKeyServer();
        final api = server.forDevice('alice', 'alice-server-device', 1);
        final service = SecretChatCryptoService(
          localUserId: 'alice',
          localSignalDeviceId: 1,
          storage: _MemorySignalRecordStorage(),
          keyBundleApi: api,
          initialOneTimePreKeyCount: 2,
          refillBatchSize: 3,
        );

        await service.initialize();
        await service.refillOneTimePreKeys();

        expect(
          server.bundleFor('alice', 'alice-server-device')!.oneTimePreKeys,
          hasLength(5),
        );
      },
    );
  });
}

final class _MemorySignalRecordStorage implements SignalRecordStorage {
  final Map<String, Uint8List> _records = {};

  @override
  Future<Uint8List?> read(String key) async {
    final value = _records[key];
    return value == null ? null : Uint8List.fromList(value);
  }

  @override
  Future<void> write(String key, Uint8List value) async {
    _records[key] = Uint8List.fromList(value);
  }

  @override
  Future<void> delete(String key) async {
    _records.remove(key);
  }

  @override
  Future<List<String>> keys(String prefix) async =>
      _records.keys.where((key) => key.startsWith(prefix)).toList();
}

final class _FakeKeyServer {
  final Map<String, SignalKeyBundle> _bundles = {};
  final Map<String, int> bundleFetches = {};

  SignalKeyBundle? bundleFor(String userId, String deviceId) =>
      _bundles['$userId/$deviceId'];

  SecretChatKeyBundleApi forDevice(
    String userId,
    String serverDeviceId,
    int signalDeviceId,
  ) => _FakeKeyBundleApi(this, userId, serverDeviceId, signalDeviceId);
}

final class _FakeKeyBundleApi implements SecretChatKeyBundleApi {
  _FakeKeyBundleApi(
    this._server,
    this._userId,
    this._serverDeviceId,
    this._signalDeviceId,
  );

  final _FakeKeyServer _server;
  final String _userId;
  final String _serverDeviceId;
  final int _signalDeviceId;

  @override
  Future<SignalKeyBundle> fetchKeyBundle({
    required String recipientId,
    required String serverDeviceId,
  }) async {
    _server.bundleFetches.update(
      '$recipientId/$serverDeviceId',
      (count) => count + 1,
      ifAbsent: () => 1,
    );
    final bundle = _server._bundles['$recipientId/$serverDeviceId'];
    if (bundle == null) {
      throw StateError('No published bundle for $recipientId');
    }
    final available = bundle.oneTimePreKeys;
    return SignalKeyBundle(
      registrationId: bundle.registrationId,
      signalDeviceId: bundle.signalDeviceId,
      identityPublicKey: bundle.identityPublicKey,
      signedPreKeyId: bundle.signedPreKeyId,
      signedPreKeyPublic: bundle.signedPreKeyPublic,
      signedPreKeySignature: bundle.signedPreKeySignature,
      kyberPreKeyId: bundle.kyberPreKeyId,
      kyberPreKeyPublic: bundle.kyberPreKeyPublic,
      kyberPreKeySignature: bundle.kyberPreKeySignature,
      oneTimePreKeys: available.isEmpty ? const [] : [available.first],
    );
  }

  @override
  Future<void> refillOneTimePreKeys(List<SignalOneTimePreKey> preKeys) async {
    final bundle = _server._bundles['$_userId/$_serverDeviceId'];
    if (bundle == null) throw StateError('No initial bundle was uploaded.');
    _server._bundles['$_userId/$_serverDeviceId'] = _withPreKeys(bundle, [
      ...bundle.oneTimePreKeys,
      ...preKeys,
    ]);
  }

  @override
  Future<void> uploadKeyBundle(SignalKeyBundle bundle) async {
    if (bundle.signalDeviceId != _signalDeviceId) {
      throw StateError('Device ID does not match the API client.');
    }
    _server._bundles['$_userId/$_serverDeviceId'] = bundle;
  }

  SignalKeyBundle _withPreKeys(
    SignalKeyBundle bundle,
    List<SignalOneTimePreKey> preKeys,
  ) => SignalKeyBundle(
    registrationId: bundle.registrationId,
    signalDeviceId: bundle.signalDeviceId,
    identityPublicKey: bundle.identityPublicKey,
    signedPreKeyId: bundle.signedPreKeyId,
    signedPreKeyPublic: bundle.signedPreKeyPublic,
    signedPreKeySignature: bundle.signedPreKeySignature,
    kyberPreKeyId: bundle.kyberPreKeyId,
    kyberPreKeyPublic: bundle.kyberPreKeyPublic,
    kyberPreKeySignature: bundle.kyberPreKeySignature,
    oneTimePreKeys: preKeys,
  );
}
