sealed class ChatFailure implements Exception {
  const ChatFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

final class AccountBannedFailure extends ChatFailure {
  const AccountBannedFailure([super.message = 'A conta está suspensa.']);
}

final class RateLimitedFailure extends ChatFailure {
  const RateLimitedFailure([
    super.message = 'Muitas solicitações. Tente novamente mais tarde.',
  ]);
}

final class RoomSlowModeFailure extends ChatFailure {
  const RoomSlowModeFailure(this.retryAfterSeconds)
    : super(
        'Aguarde $retryAfterSeconds segundos antes de enviar outra mensagem.',
      );

  final int retryAfterSeconds;
}

final class UnauthenticatedFailure extends ChatFailure {
  const UnauthenticatedFailure([
    super.message = 'É necessário entrar na conta.',
  ]);
}

final class PermissionDeniedFailure extends ChatFailure {
  const PermissionDeniedFailure([
    super.message = 'Você não tem permissão para esta ação.',
  ]);
}

final class ChatNotFoundFailure extends ChatFailure {
  const ChatNotFoundFailure([
    super.message = 'A conversa ou mensagem não foi encontrada.',
  ]);
}

final class ChatUnavailableFailure extends ChatFailure {
  const ChatUnavailableFailure([
    super.message = 'O serviço de mensagens está indisponível.',
  ]);
}

final class ChatRemoteFailure extends ChatFailure {
  const ChatRemoteFailure(super.message);
}
