import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:libsignal/libsignal.dart' as signal;

/// Durable encrypted storage for libsignal records.
///
/// Implementations must encrypt/authenticate records at rest, commit each
/// mutation durably before its future completes, and prevent rollback of
/// session records (for example by binding the database to a non-backed-up
/// installation marker). In-memory implementations are not suitable for
/// production.
abstract interface class SignalRecordStorage {
  Future<Uint8List?> read(String key);

  Future<void> write(String key, Uint8List value);

  Future<void> delete(String key);

  Future<List<String>> keys(String prefix);
}

/// Public-only key data exchanged with the authenticated KeyService API.
final class SignalOneTimePreKey {
  const SignalOneTimePreKey({required this.id, required this.publicKey});

  final int id;
  final Uint8List publicKey;
}

/// A PQXDH bundle. Kyber is mandatory for libsignal 7.4.1.
final class SignalKeyBundle {
  const SignalKeyBundle({
    required this.registrationId,
    required this.signalDeviceId,
    required this.identityPublicKey,
    required this.signedPreKeyId,
    required this.signedPreKeyPublic,
    required this.signedPreKeySignature,
    required this.kyberPreKeyId,
    required this.kyberPreKeyPublic,
    required this.kyberPreKeySignature,
    this.oneTimePreKeys = const [],
  });

  final int registrationId;
  final int signalDeviceId;
  final Uint8List identityPublicKey;
  final int signedPreKeyId;
  final Uint8List signedPreKeyPublic;
  final Uint8List signedPreKeySignature;
  final int kyberPreKeyId;
  final Uint8List kyberPreKeyPublic;
  final Uint8List kyberPreKeySignature;
  final List<SignalOneTimePreKey> oneTimePreKeys;
}

/// Injected transport boundary for key publication and bundle retrieval.
///
/// Upload operations must be idempotent: a process can stop after the server
/// accepted an upload but before the encrypted local marker was committed.
abstract interface class SecretChatKeyBundleApi {
  Future<void> uploadKeyBundle(SignalKeyBundle bundle);

  Future<SignalKeyBundle> fetchKeyBundle({
    required String recipientId,
    required String serverDeviceId,
  });

  Future<void> refillOneTimePreKeys(List<SignalOneTimePreKey> preKeys);
}

/// Signal-compatible crypto for secret chats.
///
/// All `package:libsignal` usage and its protocol stores are intentionally
/// contained in this implementation. Calls for each remote Signal address are
/// serialized around the complete load/ratchet/store operation.
final class SecretChatCryptoService {
  SecretChatCryptoService({
    required this.localUserId,
    required this.localSignalDeviceId,
    required SignalRecordStorage storage,
    required this._keyBundleApi,
    this.initialOneTimePreKeyCount = 100,
    this.refillBatchSize = 100,
  }) : _storage = storage,
       _stores = _PersistentSignalStores(storage) {
    if (localUserId.isEmpty) {
      throw ArgumentError.value(
        localUserId,
        'localUserId',
        'must not be empty',
      );
    }
    _validateDeviceId(localSignalDeviceId);
    if (initialOneTimePreKeyCount < 1 || refillBatchSize < 1) {
      throw ArgumentError('Pre-key batch sizes must be positive.');
    }
  }

  static const int _frameHeaderLength = 6;
  static const int _frameVersion = 1;
  static const List<int> _frameMagic = [0x53, 0x43];
  static Future<void>? _libsignalInitialization;

  final String localUserId;
  final int localSignalDeviceId;
  final SignalRecordStorage _storage;
  final SecretChatKeyBundleApi _keyBundleApi;
  final _PersistentSignalStores _stores;
  final int initialOneTimePreKeyCount;
  final int refillBatchSize;
  final Map<String, Future<void>> _addressLocks = {};
  Future<void>? _identityInitialization;
  signal.SessionCipher? _cipher;

  /// Initializes libsignal and lazily creates/publishes the local key bundle.
  Future<void> initialize() => ensureIdentity();

  /// Ensures the local long-term identity and public PQXDH bundle are durable.
  Future<void> ensureIdentity() {
    final active = _identityInitialization;
    if (active != null) return active;
    final operation = _ensureIdentity();
    _identityInitialization = operation;
    return operation.whenComplete(() {
      if (identical(_identityInitialization, operation)) {
        _identityInitialization = null;
      }
    });
  }

  Future<void> _ensureIdentity() async {
    await _initializeLibSignal();

    var identity = await _stores.readLocalIdentityKeyPair();
    if (identity == null) {
      identity = signal.IdentityKeyPair.generate();
      await _stores.writeLocalIdentityKeyPair(identity);
    }

    await _stores.ensureLocalRegistrationId();
    final signedPreKey = await _stores.ensureSignedPreKey(identity);
    final kyberPreKey = await _stores.ensureKyberPreKey(identity);

    if (await _storage.read(_publishedBundleKey) == null) {
      await _ensureLocalOneTimePreKeys(initialOneTimePreKeyCount);
      await _keyBundleApi.uploadKeyBundle(
        SignalKeyBundle(
          registrationId: await _stores.getLocalRegistrationId(),
          signalDeviceId: localSignalDeviceId,
          identityPublicKey: identity.publicKey,
          signedPreKeyId: signedPreKey.id(),
          signedPreKeyPublic: signedPreKey.publicKey(),
          signedPreKeySignature: signedPreKey.signature(),
          kyberPreKeyId: kyberPreKey.id(),
          kyberPreKeyPublic: kyberPreKey.getPublicKey().serialize(),
          kyberPreKeySignature: kyberPreKey.signature(),
          oneTimePreKeys: await _stores.getPublicPreKeys(),
        ),
      );
      await _stores.markPreKeysPublished(await _stores.getAllPreKeyIds());
      await _storage.write(_publishedBundleKey, Uint8List.fromList([1]));
    }
    _cipher ??= _createCipher();
  }

  static Future<void> _initializeLibSignal() {
    if (signal.LibSignal.isInitialized) return Future<void>.value();
    return _libsignalInitialization ??= signal.LibSignal.init().whenComplete(
      () {
        _libsignalInitialization = null;
      },
    );
  }

  /// Generates and uploads additional one-time pre-keys when called by the
  /// application or after a successful server-side pre-key consumption.
  Future<void> refillOneTimePreKeys() async {
    await ensureIdentity();
    await _withLock('local-prekey-refill', () async {
      if ((await _stores.getUnpublishedPreKeys()).isEmpty) {
        await _generateOneTimePreKeys(refillBatchSize);
      }
      final preKeys = await _stores.getUnpublishedPreKeys();
      if (preKeys.isNotEmpty) {
        await _keyBundleApi.refillOneTimePreKeys(preKeys);
        await _stores.markPreKeysPublished(
          preKeys.map((key) => key.id).toList(),
        );
      }
    });
  }

  /// Encrypts a payload for a remote user, establishing a PQXDH session when
  /// no session for the selected Signal device exists. `secretChatId` is the
  /// remote account ID used as the libsignal protocol name.
  Future<Uint8List> encrypt({
    required String secretChatId,
    required String recipientServerDeviceId,
    required Uint8List plaintext,
  }) async {
    await ensureIdentity();
    return _withLock(
      'outgoing/${_encodeName(secretChatId)}/${_encodeName(recipientServerDeviceId)}',
      () async {
        var signalDeviceId = await _stores.signalDeviceIdForServerDevice(
          recipientId: secretChatId,
          serverDeviceId: recipientServerDeviceId,
        );
        SignalKeyBundle? bundle;
        if (signalDeviceId == null) {
          bundle = await _keyBundleApi.fetchKeyBundle(
            recipientId: secretChatId,
            serverDeviceId: recipientServerDeviceId,
          );
          signalDeviceId = bundle.signalDeviceId;
          _validateDeviceId(signalDeviceId);
        }

        final mappedDeviceId = signalDeviceId;
        final address = signal.ProtocolAddress(
          name: secretChatId,
          deviceId: mappedDeviceId,
        );
        return _withAddressLock(address, () async {
          if (!await _stores.containsSession(address)) {
            final keyBundle =
                bundle ??
                await _keyBundleApi.fetchKeyBundle(
                  recipientId: secretChatId,
                  serverDeviceId: recipientServerDeviceId,
                );
            if (keyBundle.signalDeviceId != mappedDeviceId) {
              throw StateError(
                'KeyService returned a different Signal device for the server device.',
              );
            }
            await signal.SessionBuilder(
              localAddress: _localAddress(),
              sessionStore: _stores,
              identityKeyStore: _stores,
            ).processPreKeyBundle(address, _toLibSignalBundle(keyBundle));
            await _stores.saveServerSignalDeviceMapping(
              recipientId: secretChatId,
              serverDeviceId: recipientServerDeviceId,
              signalDeviceId: mappedDeviceId,
            );
          }
          final encrypted = await _cipher!.encrypt(address, plaintext);
          return _encodeFrame(
            senderSignalDeviceId: localSignalDeviceId,
            messageType: encrypted.type.value,
            ciphertext: encrypted.ciphertext,
          );
        });
      },
    );
  }

  /// Decrypts either a Signal message or the first PQXDH pre-key delivery.
  Future<Uint8List> decrypt({
    required String secretChatId,
    required Uint8List ciphertext,
  }) async {
    final frame = _decodeFrame(ciphertext);
    await ensureIdentity();
    final remoteAddress = signal.ProtocolAddress(
      name: secretChatId,
      deviceId: frame.senderSignalDeviceId,
    );

    return _withAddressLock(remoteAddress, () async {
      return _cipher!.decrypt(
        remoteAddress,
        signal.CiphertextMessage.fromRaw(
          messageType: frame.messageType,
          ciphertext: frame.ciphertext,
        ),
      );
    });
  }

  signal.ProtocolAddress _localAddress() =>
      signal.ProtocolAddress(name: localUserId, deviceId: localSignalDeviceId);

  signal.SessionCipher _createCipher() => signal.SessionCipher(
    localAddress: _localAddress(),
    sessionStore: _stores,
    identityKeyStore: _stores,
    preKeyStore: _stores,
    signedPreKeyStore: _stores,
    kyberPreKeyStore: _stores,
  );

  Future<List<SignalOneTimePreKey>> _ensureLocalOneTimePreKeys(
    int count,
  ) async {
    final current = await _stores.getAllPreKeyIds();
    final remaining = max(0, count - current.length);
    if (remaining == 0) return const [];
    return _generateOneTimePreKeys(remaining);
  }

  Future<List<SignalOneTimePreKey>> _generateOneTimePreKeys(int count) async {
    final generated = <SignalOneTimePreKey>[];
    for (var i = 0; i < count; i++) {
      final id = await _stores.allocateKeyId();
      final privateKey = signal.PrivateKey.generate();
      final record = signal.PreKeyRecord(
        id: id,
        publicKey: privateKey.getPublicKey(),
        privateKey: privateKey,
      );
      await _stores.storePreKey(id, record);
      generated.add(SignalOneTimePreKey(id: id, publicKey: record.publicKey()));
    }
    return generated;
  }

  signal.PreKeyBundle _toLibSignalBundle(SignalKeyBundle bundle) {
    final oneTimePreKey = bundle.oneTimePreKeys.isEmpty
        ? null
        : bundle.oneTimePreKeys.first;
    return signal.PreKeyBundle(
      registrationId: bundle.registrationId,
      deviceId: bundle.signalDeviceId,
      preKeyId: oneTimePreKey?.id,
      preKeyPublic: oneTimePreKey?.publicKey,
      signedPreKeyId: bundle.signedPreKeyId,
      signedPreKeyPublic: bundle.signedPreKeyPublic,
      signedPreKeySignature: bundle.signedPreKeySignature,
      identityKey: bundle.identityPublicKey,
      kyberPreKeyId: bundle.kyberPreKeyId,
      kyberPreKeyPublic: bundle.kyberPreKeyPublic,
      kyberPreKeySignature: bundle.kyberPreKeySignature,
    );
  }

  Future<T> _withAddressLock<T>(
    signal.ProtocolAddress address,
    Future<T> Function() action,
  ) => _withLock('${address.name()}/${address.deviceId()}', action);

  Future<T> _withLock<T>(String key, Future<T> Function() action) async {
    final previous = _addressLocks[key] ?? Future<void>.value();
    final release = Completer<void>();
    _addressLocks[key] = release.future;
    await previous;
    try {
      return await action();
    } finally {
      release.complete();
      if (identical(_addressLocks[key], release.future)) {
        _addressLocks.remove(key);
      }
    }
  }

  static String _encodeName(String value) =>
      base64Url.encode(utf8.encode(value)).replaceAll('=', '');

  static Uint8List _encodeFrame({
    required int senderSignalDeviceId,
    required int messageType,
    required Uint8List ciphertext,
  }) {
    _validateDeviceId(senderSignalDeviceId);
    if (messageType != 2 && messageType != 3) {
      throw FormatException('Unsupported libsignal message type: $messageType');
    }
    final frame = Uint8List(_frameHeaderLength + ciphertext.length);
    frame.setRange(0, 2, _frameMagic);
    frame[2] = _frameVersion;
    ByteData.sublistView(frame).setUint16(3, senderSignalDeviceId);
    frame[5] = messageType;
    frame.setRange(_frameHeaderLength, frame.length, ciphertext);
    return frame;
  }

  static _SignalFrame _decodeFrame(Uint8List frame) {
    if (frame.length <= _frameHeaderLength ||
        frame[0] != _frameMagic[0] ||
        frame[1] != _frameMagic[1] ||
        frame[2] != _frameVersion) {
      throw const FormatException('Invalid secret-chat ciphertext frame.');
    }
    final senderDeviceId = ByteData.sublistView(frame).getUint16(3);
    _validateDeviceId(senderDeviceId);
    final messageType = frame[5];
    if (messageType != 2 && messageType != 3) {
      throw FormatException('Unsupported libsignal message type: $messageType');
    }
    return _SignalFrame(
      senderSignalDeviceId: senderDeviceId,
      messageType: messageType,
      ciphertext: Uint8List.fromList(frame.sublist(_frameHeaderLength)),
    );
  }

  static void _validateDeviceId(int id) {
    if (id < 1 || id > 127) {
      throw ArgumentError.value(
        id,
        'signalDeviceId',
        'must be between 1 and 127',
      );
    }
  }

  String get _publishedBundleKey => 'signal/v1/published';
}

final class _SignalFrame {
  const _SignalFrame({
    required this.senderSignalDeviceId,
    required this.messageType,
    required this.ciphertext,
  });

  final int senderSignalDeviceId;
  final int messageType;
  final Uint8List ciphertext;
}

/// Durable libsignal store adapters over the injected encrypted KV boundary.
final class _PersistentSignalStores
    implements
        signal.IdentityKeyStore,
        signal.SessionStore,
        signal.PreKeyStore,
        signal.SignedPreKeyStore,
        signal.KyberPreKeyStore {
  _PersistentSignalStores(this._storage);

  final SignalRecordStorage _storage;
  static const _prefix = 'signal/v1/';
  static const _identityPairKey = '${_prefix}identity/pair';
  static const _registrationIdKey = '${_prefix}identity/registration-id';
  static const _keyCounterKey = '${_prefix}key-counter';

  String _sessionKey(signal.ProtocolAddress address) =>
      '${_prefix}sessions/${_encode(address.name())}/${address.deviceId()}';
  String _remoteIdentityKey(signal.ProtocolAddress address) =>
      '${_prefix}identities/${_encode(address.name())}/${address.deviceId()}';
  String _serverSignalDeviceMappingKey({
    required String recipientId,
    required String serverDeviceId,
  }) =>
      '${_prefix}server-device-mappings/${_encode(recipientId)}/${_encode(serverDeviceId)}';
  String _preKeyKey(int id) => '${_prefix}prekeys/$id';
  String _preKeyPublishedKey(int id) => '${_prefix}published-prekeys/$id';
  String _signedPreKeyKey(int id) => '${_prefix}signed-prekeys/$id';
  String _kyberPreKeyKey(int id) => '${_prefix}kyber-prekeys/$id';
  String _kyberUsedKey(int id) => '${_prefix}kyber-used/$id';

  static String _encode(String value) =>
      base64Url.encode(utf8.encode(value)).replaceAll('=', '');

  Future<signal.IdentityKeyPair?> readLocalIdentityKeyPair() async {
    final bytes = await _storage.read(_identityPairKey);
    return bytes == null
        ? null
        : signal.IdentityKeyPair.deserialize(bytes: bytes);
  }

  Future<void> writeLocalIdentityKeyPair(signal.IdentityKeyPair pair) async {
    await _storage.write(_identityPairKey, pair.serialize());
  }

  Future<void> ensureLocalRegistrationId() async {
    if (await _storage.read(_registrationIdKey) != null) return;
    final registrationId = Random.secure().nextInt(16380) + 1;
    await _storage.write(
      _registrationIdKey,
      Uint8List.fromList(utf8.encode('$registrationId')),
    );
  }

  Future<int> readLocalRegistrationId() async {
    final value = await _storage.read(_registrationIdKey);
    if (value == null) throw StateError('Local registration ID is missing.');
    return int.parse(utf8.decode(value));
  }

  Future<signal.SignedPreKeyRecord> ensureSignedPreKey(
    signal.IdentityKeyPair identity,
  ) async {
    final ids = await getAllSignedPreKeyIds();
    if (ids.isNotEmpty) {
      final record = await loadSignedPreKey(ids.last);
      if (record != null) return record;
    }
    final id = await allocateKeyId();
    final privateKey = signal.PrivateKey.generate();
    final publicKey = privateKey.getPublicKey();
    final record = signal.SignedPreKeyRecord(
      id: id,
      timestamp: BigInt.from(DateTime.now().millisecondsSinceEpoch),
      publicKey: publicKey,
      privateKey: privateKey,
      signature: identity.sign(message: publicKey.serialize()),
    );
    await storeSignedPreKey(id, record);
    return record;
  }

  Future<signal.KyberPreKeyRecord> ensureKyberPreKey(
    signal.IdentityKeyPair identity,
  ) async {
    final ids = await getAllKyberPreKeyIds();
    if (ids.isNotEmpty) {
      final record = await loadKyberPreKey(ids.last);
      if (record != null) return record;
    }
    final id = await allocateKeyId();
    final pair = signal.KyberKeyPair.generate();
    final record = signal.KyberPreKeyRecord.create(
      id: id,
      timestamp: BigInt.from(DateTime.now().millisecondsSinceEpoch),
      keyPair: pair,
      signature: identity.sign(message: pair.getPublicKey().serialize()),
    );
    await storeKyberPreKey(id, record);
    return record;
  }

  Future<int> allocateKeyId() async {
    final stored = await _storage.read(_keyCounterKey);
    final next = (stored == null ? 1 : int.parse(utf8.decode(stored)) + 1);
    await _storage.write(
      _keyCounterKey,
      Uint8List.fromList(utf8.encode('$next')),
    );
    return next;
  }

  @override
  Future<bool> saveIdentity(
    signal.ProtocolAddress address,
    signal.PublicKey identityKey,
  ) async {
    final key = _remoteIdentityKey(address);
    final previous = await _storage.read(key);
    final serialized = identityKey.serialize();
    if (previous != null && _bytesEqual(previous, serialized)) return false;
    await _storage.write(key, serialized);
    return true;
  }

  @override
  Future<signal.PublicKey?> getIdentity(signal.ProtocolAddress address) async {
    final bytes = await _storage.read(_remoteIdentityKey(address));
    return bytes == null ? null : signal.PublicKey.deserialize(bytes: bytes);
  }

  @override
  Future<bool> isTrustedIdentity(
    signal.ProtocolAddress address,
    signal.PublicKey identityKey,
    signal.Direction direction,
  ) async {
    final known = await getIdentity(address);
    return known == null ||
        _bytesEqual(known.serialize(), identityKey.serialize());
  }

  @override
  Future<int> getLocalRegistrationId() => readLocalRegistrationId();

  @override
  Future<signal.IdentityKeyPair> getIdentityKeyPair() async {
    final pair = await readLocalIdentityKeyPair();
    if (pair == null) throw StateError('Local identity key pair is missing.');
    return pair;
  }

  Future<List<SignalOneTimePreKey>> getPublicPreKeys() async {
    final keys = <SignalOneTimePreKey>[];
    for (final id in await getAllPreKeyIds()) {
      final record = await loadPreKey(id);
      if (record != null) {
        keys.add(SignalOneTimePreKey(id: id, publicKey: record.publicKey()));
      }
    }
    return keys;
  }

  Future<List<SignalOneTimePreKey>> getUnpublishedPreKeys() async {
    final keys = <SignalOneTimePreKey>[];
    for (final id in await getAllPreKeyIds()) {
      if (await _storage.read(_preKeyPublishedKey(id)) != null) continue;
      final record = await loadPreKey(id);
      if (record != null) {
        keys.add(SignalOneTimePreKey(id: id, publicKey: record.publicKey()));
      }
    }
    return keys;
  }

  Future<void> markPreKeysPublished(Iterable<int> ids) async {
    for (final id in ids) {
      await _storage.write(_preKeyPublishedKey(id), Uint8List.fromList([1]));
    }
  }

  Future<int?> signalDeviceIdForServerDevice({
    required String recipientId,
    required String serverDeviceId,
  }) async {
    final bytes = await _storage.read(
      _serverSignalDeviceMappingKey(
        recipientId: recipientId,
        serverDeviceId: serverDeviceId,
      ),
    );
    return bytes == null ? null : int.parse(utf8.decode(bytes));
  }

  Future<void> saveServerSignalDeviceMapping({
    required String recipientId,
    required String serverDeviceId,
    required int signalDeviceId,
  }) => _storage.write(
    _serverSignalDeviceMappingKey(
      recipientId: recipientId,
      serverDeviceId: serverDeviceId,
    ),
    Uint8List.fromList(utf8.encode('$signalDeviceId')),
  );

  @override
  Future<signal.SessionRecord?> loadSession(
    signal.ProtocolAddress address,
  ) async {
    final bytes = await _storage.read(_sessionKey(address));
    return bytes == null
        ? null
        : signal.SessionRecord.deserialize(bytes: bytes);
  }

  @override
  Future<void> storeSession(
    signal.ProtocolAddress address,
    signal.SessionRecord record,
  ) => _storage.write(_sessionKey(address), record.serialize());

  @override
  Future<bool> containsSession(signal.ProtocolAddress address) async =>
      await _storage.read(_sessionKey(address)) != null;

  @override
  Future<void> deleteSession(signal.ProtocolAddress address) =>
      _storage.delete(_sessionKey(address));

  @override
  Future<void> deleteAllSessions(String name) async {
    final prefix = '${_prefix}sessions/${_encode(name)}/';
    for (final key in await _storage.keys(prefix)) {
      await _storage.delete(key);
    }
  }

  @override
  Future<List<int>> getSubDeviceSessions(String name) async {
    final prefix = '${_prefix}sessions/${_encode(name)}/';
    return (await _storage.keys(prefix))
        .map((key) => int.parse(key.substring(prefix.length)))
        .toList(growable: false);
  }

  @override
  Future<signal.PreKeyRecord?> loadPreKey(int preKeyId) async {
    final bytes = await _storage.read(_preKeyKey(preKeyId));
    return bytes == null ? null : signal.PreKeyRecord.deserialize(bytes: bytes);
  }

  @override
  Future<void> storePreKey(int preKeyId, signal.PreKeyRecord record) =>
      _storage.write(_preKeyKey(preKeyId), record.serialize());

  @override
  Future<bool> containsPreKey(int preKeyId) async =>
      await _storage.read(_preKeyKey(preKeyId)) != null;

  @override
  Future<void> removePreKey(int preKeyId) async {
    await _storage.delete(_preKeyKey(preKeyId));
    await _storage.delete(_preKeyPublishedKey(preKeyId));
  }

  @override
  Future<List<int>> getAllPreKeyIds() => _recordIds('${_prefix}prekeys/');

  @override
  Future<signal.SignedPreKeyRecord?> loadSignedPreKey(
    int signedPreKeyId,
  ) async {
    final bytes = await _storage.read(_signedPreKeyKey(signedPreKeyId));
    return bytes == null
        ? null
        : signal.SignedPreKeyRecord.deserialize(bytes: bytes);
  }

  @override
  Future<void> storeSignedPreKey(
    int signedPreKeyId,
    signal.SignedPreKeyRecord record,
  ) => _storage.write(_signedPreKeyKey(signedPreKeyId), record.serialize());

  @override
  Future<bool> containsSignedPreKey(int signedPreKeyId) async =>
      await _storage.read(_signedPreKeyKey(signedPreKeyId)) != null;

  @override
  Future<void> removeSignedPreKey(int signedPreKeyId) =>
      _storage.delete(_signedPreKeyKey(signedPreKeyId));

  @override
  Future<List<int>> getAllSignedPreKeyIds() =>
      _recordIds('${_prefix}signed-prekeys/');

  @override
  Future<signal.KyberPreKeyRecord?> loadKyberPreKey(int kyberPreKeyId) async {
    final bytes = await _storage.read(_kyberPreKeyKey(kyberPreKeyId));
    return bytes == null
        ? null
        : signal.KyberPreKeyRecord.deserialize(bytes: bytes);
  }

  @override
  Future<void> storeKyberPreKey(
    int kyberPreKeyId,
    signal.KyberPreKeyRecord record,
  ) => _storage.write(_kyberPreKeyKey(kyberPreKeyId), record.serialize());

  @override
  Future<bool> containsKyberPreKey(int kyberPreKeyId) async =>
      await _storage.read(_kyberPreKeyKey(kyberPreKeyId)) != null;

  @override
  Future<void> markKyberPreKeyUsed(
    int kyberPreKeyId,
    int signedPreKeyId,
    signal.PublicKey baseKey,
  ) async {
    // Keep this Kyber key as last-resort so a temporarily empty OTPK pool does
    // not make incoming PQXDH deliveries undecryptable. The library invokes
    // this callback after decryption and cannot use it as a replay barrier;
    // retain the agreement marker for auditing rather than throwing here.
    final fingerprint = base64Url.encode(baseKey.serialize());
    await _storage.write(
      '${_kyberUsedKey(kyberPreKeyId)}/$signedPreKeyId/$fingerprint',
      Uint8List.fromList([1]),
    );
  }

  @override
  Future<void> removeKyberPreKey(int kyberPreKeyId) =>
      _storage.delete(_kyberPreKeyKey(kyberPreKeyId));

  @override
  Future<List<int>> getAllKyberPreKeyIds() =>
      _recordIds('${_prefix}kyber-prekeys/');

  Future<List<int>> _recordIds(String prefix) async =>
      (await _storage.keys(prefix))
          .map((key) => int.parse(key.substring(prefix.length)))
          .toList(growable: false);

  static bool _bytesEqual(List<int> left, List<int> right) {
    if (left.length != right.length) return false;
    var difference = 0;
    for (var i = 0; i < left.length; i++) {
      difference |= left[i] ^ right[i];
    }
    return difference == 0;
  }
}
