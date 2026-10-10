import 'dart:convert';
import 'dart:typed_data';

import '../../../core/crypto/secret_chat_crypto_service.dart';
import '../../../generated/proto/tureon.pb.dart' as pb;
import '../../../generated/proto/tureon.pbgrpc.dart';

class SecretChatPreKeyStatus {
  const SecretChatPreKeyStatus({
    required this.count,
    required this.lowWatermark,
  });

  final int count;
  final int lowWatermark;
}

final class GrpcSecretChatKeyBundleApi implements SecretChatKeyBundleApi {
  GrpcSecretChatKeyBundleApi({
    required this.client,
    required this.localDeviceId,
  });

  final KeyServiceClient client;
  final String localDeviceId;

  @override
  Future<void> uploadKeyBundle(SignalKeyBundle bundle) async {
    await client.uploadKeyBundle(
      pb.KeyBundleUploadRequest(
        deviceId: localDeviceId,
        identityPublicKey: base64Encode(bundle.identityPublicKey),
        signedPrekeyPublic: base64Encode(bundle.signedPreKeyPublic),
        signedPrekeyId: bundle.signedPreKeyId,
        signedPrekeySignature: base64Encode(bundle.signedPreKeySignature),
        registrationId: bundle.registrationId,
        signalDeviceId: bundle.signalDeviceId,
        kyberPrekeyId: bundle.kyberPreKeyId,
        kyberPrekeyPublic: base64Encode(bundle.kyberPreKeyPublic),
        kyberPrekeySignature: base64Encode(bundle.kyberPreKeySignature),
        oneTimePrekeys: bundle.oneTimePreKeys.map(
          (key) => pb.OneTimePreKey(
            keyId: key.id,
            publicKey: base64Encode(key.publicKey),
          ),
        ),
      ),
    );
  }

  @override
  Future<SignalKeyBundle> fetchKeyBundle({
    required String recipientId,
    required String serverDeviceId,
  }) async {
    final bundle = await client.getKeyBundle(
      pb.GetKeyBundleRequest(
        recipientId: recipientId,
        deviceId: serverDeviceId,
      ),
    );
    return SignalKeyBundle(
      registrationId: bundle.registrationId,
      signalDeviceId: bundle.signalDeviceId,
      identityPublicKey: _decode(bundle.identityPublicKey),
      signedPreKeyId: bundle.signedPrekeyId,
      signedPreKeyPublic: _decode(bundle.signedPrekeyPublic),
      signedPreKeySignature: _decode(bundle.signedPrekeySignature),
      kyberPreKeyId: bundle.kyberPrekeyId,
      kyberPreKeyPublic: _decode(bundle.kyberPrekeyPublic),
      kyberPreKeySignature: _decode(bundle.kyberPrekeySignature),
      oneTimePreKeys: bundle.oneTimePrekeys
          .map(
            (key) => SignalOneTimePreKey(
              id: key.keyId,
              publicKey: _decode(key.publicKey),
            ),
          )
          .toList(growable: false),
    );
  }

  @override
  Future<void> refillOneTimePreKeys(List<SignalOneTimePreKey> preKeys) async {
    await client.refillOneTimePrekeys(
      pb.RefillOneTimePrekeysRequest(
        oneTimePrekeys: preKeys.map(
          (key) => pb.OneTimePreKey(
            keyId: key.id,
            publicKey: base64Encode(key.publicKey),
          ),
        ),
      ),
    );
  }

  Future<SecretChatPreKeyStatus> getPreKeyStatus() async {
    final response = await client.getPreKeyCount(pb.Empty());
    return SecretChatPreKeyStatus(
      count: response.count,
      lowWatermark: response.lowWatermark,
    );
  }

  Uint8List _decode(String value) => Uint8List.fromList(base64Decode(value));
}
