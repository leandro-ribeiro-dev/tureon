import 'package:grpc/grpc.dart';

import '../domain/chat_failure.dart';

ChatFailure mapChatGrpcFailure(Object error) {
  if (error is! GrpcError) {
    return ChatRemoteFailure(error.toString());
  }

  final trailers = error.trailers ?? const <String, String>{};
  final structuredCode =
      trailers['axiom-error-code'] ??
      trailers['error-code'] ??
      trailers['code'];
  final message = error.message ?? 'Falha na solicitação de mensagens.';
  final slowModeSeconds = RegExp(
    r'slow_mode_retry_after_seconds=(\d+)',
  ).firstMatch(message);
  if (error.code == StatusCode.resourceExhausted && slowModeSeconds != null) {
    return RoomSlowModeFailure(int.parse(slowModeSeconds.group(1)!));
  }

  return switch (structuredCode) {
    'AXIOM_ACCOUNT_BANNED' => AccountBannedFailure(message),
    'AXIOM_ACCOUNT_RATE_LIMITED' => RateLimitedFailure(message),
    _ => switch (error.code) {
      StatusCode.unauthenticated => UnauthenticatedFailure(message),
      StatusCode.permissionDenied => PermissionDeniedFailure(message),
      StatusCode.resourceExhausted => RateLimitedFailure(message),
      StatusCode.notFound => ChatNotFoundFailure(message),
      StatusCode.unavailable => ChatUnavailableFailure(message),
      _ => ChatRemoteFailure(message),
    },
  };
}
