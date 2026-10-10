import 'dart:async';

import '../../../core/crypto/secret_chat_crypto_manager.dart';
import '../../../core/crypto/secret_chat_crypto_port.dart';
import '../../../core/network/grpc_client.dart';
import '../../../core/protocol/protocol_models.dart';
import '../../../core/storage/local_store.dart';
import '../../../core/storage/message_records.dart';
import '../domain/chat_repository.dart';
import '../domain/secret_chat_device.dart';
import 'grpc_chat_repository.dart';
import 'grpc_messaging_rpc.dart';
import 'services/chat_media_transfer_service.dart';

class ChatRuntimeCoordinator {
  ChatRuntimeCoordinator({
    required this.store,
    required this.resolveRecipient,
    required this.resolveRoomRecipient,
    required this.onStreamFailure,
  }) : _cryptoManager = SecretChatCryptoManager(store: store);

  final LocalStore store;
  final Future<Recipient> Function(String recipientId) resolveRecipient;
  final Future<Recipient?> Function(
    String recipientId,
    RecipientType type,
    bool forceRefresh,
  )
  resolveRoomRecipient;
  final void Function() onStreamFailure;

  final SecretChatCryptoManager _cryptoManager;
  GrpcChatRepository? _repository;

  ChatRepository? get chatRepository => _repository;

  void connect(
    GrpcClient client, {
    required String host,
    bool secure = false,
    int mediaPort = 8081,
  }) {
    final mediaTransfer = ChatMediaTransferService(
      host: host,
      port: mediaPort,
      secure: secure,
      store: store,
    );
    final repository = GrpcChatRepository(
      rpc: GrpcMessagingRpc(
        client: client.messaging,
        connectionStateChanges: client.connectionStateChanges,
      ),
      store: store,
      mediaTransfer: mediaTransfer,
      resolveRecipient: resolveRecipient,
      resolveRoomRecipient: resolveRoomRecipient,
      onStreamFailure: onStreamFailure,
    );
    _repository = repository;
  }

  Future<void> startSync() => _repository?.startSync() ?? Future<void>.value();

  Future<void> stopSync() => _repository?.stopSync() ?? Future<void>.value();

  Future<void> reconnect() => _repository?.reconnect() ?? Future<void>.value();

  void resetSecretCrypto() {
    _cryptoManager.reset();
    _repository?.configureSecretCrypto(null);
  }

  Future<void> ensureSecretChatReady({
    required GrpcClient client,
    required UserSession session,
  }) async {
    final crypto = await _cryptoManager.ensureReady(
      client: client,
      session: session,
    );
    _repository?.configureSecretCrypto(SecretChatCryptoAdapter(crypto));
  }

  Future<List<SecretChatDevice>> listSecretChatDevices({
    required GrpcClient client,
    required String recipientId,
  }) => _cryptoManager.listDevices(client: client, recipientId: recipientId);

  Future<void> disconnect() async {
    await _repository?.close();
    _repository = null;
    _cryptoManager.reset();
  }
}
