import 'dart:typed_data';

import 'secret_chat_crypto_service.dart';

abstract interface class SecretChatCryptoPort {
  Future<Uint8List> encrypt({
    required String secretChatId,
    required String recipientServerDeviceId,
    required Uint8List plaintext,
  });

  Future<Uint8List> decrypt({
    required String secretChatId,
    required Uint8List ciphertext,
  });
}

final class SecretChatCryptoAdapter implements SecretChatCryptoPort {
  const SecretChatCryptoAdapter(this.service);

  final SecretChatCryptoService service;

  @override
  Future<Uint8List> encrypt({
    required String secretChatId,
    required String recipientServerDeviceId,
    required Uint8List plaintext,
  }) => service.encrypt(
    secretChatId: secretChatId,
    recipientServerDeviceId: recipientServerDeviceId,
    plaintext: plaintext,
  );

  @override
  Future<Uint8List> decrypt({
    required String secretChatId,
    required Uint8List ciphertext,
  }) => service.decrypt(secretChatId: secretChatId, ciphertext: ciphertext);
}
