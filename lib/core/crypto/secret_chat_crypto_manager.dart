import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../features/chats/data/grpc_secret_chat_key_bundle_api.dart';
import '../../features/chats/domain/secret_chat_device.dart';
import '../../generated/proto/tureon.pb.dart' as pb;
import '../network/grpc_client.dart';
import '../storage/local_store.dart';
import '../storage/message_records.dart';
import 'local_signal_record_storage.dart';
import 'prekey_refill_policy.dart';
import 'secret_chat_crypto_service.dart';

class SecretChatCryptoManager {
  SecretChatCryptoManager({required this.store});

  final LocalStore store;
  SecretChatCryptoService? _service;
  Future<SecretChatCryptoService>? _serviceInitialization;
  String? _initializationKey;
  String? _serviceKey;
  int _generation = 0;

  SecretChatCryptoService? get service => _service;

  Future<SecretChatCryptoService> ensureReady({
    required GrpcClient client,
    required UserSession session,
  }) async {
    final generation = _generation;
    final key =
        '${session.userId}/${session.deviceId}/${session.signalDeviceId}';
    final crypto = await _ensureService(
      client: client,
      session: session,
      key: key,
      generation: generation,
    );
    _ensureSessionIsCurrent(session, generation);

    final keyApi = GrpcSecretChatKeyBundleApi(
      client: client.keys,
      localDeviceId: session.deviceId,
    );
    final preKeyStatus = await keyApi.getPreKeyStatus();
    await refillOneTimePrekeysIfLow(
      count: preKeyStatus.count,
      lowWatermark: preKeyStatus.lowWatermark,
      refill: crypto.refillOneTimePreKeys,
    );
    _ensureSessionIsCurrent(session, generation);

    return crypto;
  }

  Future<SecretChatCryptoService> _ensureService({
    required GrpcClient client,
    required UserSession session,
    required String key,
    required int generation,
  }) async {
    if (_serviceKey == key && _service != null) return _service!;
    if (_initializationKey == key && _serviceInitialization != null) {
      return _serviceInitialization!;
    }

    final initialization = _initializeService(client, session);
    _serviceInitialization = initialization;
    _initializationKey = key;
    try {
      final crypto = await initialization;
      _ensureSessionIsCurrent(session, generation);
      _service = crypto;
      _serviceKey = key;
      return crypto;
    } finally {
      if (identical(_serviceInitialization, initialization)) {
        _serviceInitialization = null;
        _initializationKey = null;
      }
    }
  }

  Future<SecretChatCryptoService> _initializeService(
    GrpcClient client,
    UserSession session,
  ) async {
    final keyApi = GrpcSecretChatKeyBundleApi(
      client: client.keys,
      localDeviceId: session.deviceId,
    );
    final crypto = SecretChatCryptoService(
      localUserId: session.userId,
      localSignalDeviceId: session.signalDeviceId,
      storage: LocalSignalRecordStorage(
        store: store,
        secureStorage: const FlutterSecureStorage(),
        userId: session.userId,
        deviceId: session.deviceId,
      ),
      keyBundleApi: keyApi,
    );
    await crypto.initialize();
    return crypto;
  }

  void _ensureSessionIsCurrent(UserSession session, int generation) {
    final activeSession = store.loadSession();
    if (generation != _generation ||
        activeSession?.userId != session.userId ||
        activeSession?.deviceId != session.deviceId ||
        activeSession?.signalDeviceId != session.signalDeviceId) {
      throw StateError('The active session changed during Signal setup.');
    }
  }

  Future<List<SecretChatDevice>> listDevices({
    required GrpcClient client,
    required String recipientId,
  }) async {
    final response = await client.keys.listRecipientKeyDevices(
      pb.ListRecipientKeyDevicesRequest(recipientId: recipientId),
    );
    return response.devices
        .map(
          (device) => SecretChatDevice(
            deviceId: device.deviceId,
            name: device.deviceName.isEmpty
                ? (device.platform.isEmpty ? 'Dispositivo' : device.platform)
                : device.deviceName,
            platform: device.platform,
            signalDeviceId: device.signalDeviceId,
          ),
        )
        .toList(growable: false);
  }

  void reset() {
    _generation++;
    _service = null;
    _serviceKey = null;
    _serviceInitialization = null;
    _initializationKey = null;
  }
}
