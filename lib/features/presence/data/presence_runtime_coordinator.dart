import '../../../core/network/grpc_client.dart';
import '../../../core/protocol/recipient.dart';
import '../../../core/storage/local_store.dart';
import 'presence_repository.dart';

class PresenceRuntimeCoordinator {
  PresenceRuntimeCoordinator({
    required this.store,
    required this.onPresenceUpdate,
    required this.onStreamFailure,
  });

  final LocalStore store;
  final void Function(Recipient recipient) onPresenceUpdate;
  final void Function() onStreamFailure;

  PresenceRepository? _repository;

  void connect(GrpcClient client) {
    _repository = PresenceRepository(
      rpc: GrpcPresenceRpc(client.presence),
      store: store,
      onPresenceUpdate: onPresenceUpdate,
      onStreamFailure: onStreamFailure,
    );
  }

  Future<void> startSync({required bool foreground}) =>
      _repository?.startSync(foreground: foreground) ?? Future<void>.value();

  Future<void> setForeground(bool foreground) =>
      _repository?.setForeground(foreground) ?? Future<void>.value();

  Future<void> stopSync({bool sendOffline = false}) =>
      _repository?.stopSync(sendOffline: sendOffline) ?? Future<void>.value();

  Future<void> sendTypingIndicator({
    required String targetRecipientId,
    required bool isTyping,
  }) =>
      _repository?.sendTypingIndicator(
        targetRecipientId: targetRecipientId,
        isTyping: isTyping,
      ) ??
      Future<void>.value();

  Future<void> reconnect() => _repository?.reconnect() ?? Future<void>.value();

  Future<void> disconnect() async {
    await _repository?.stopSync(sendOffline: true);
    _repository = null;
  }
}
