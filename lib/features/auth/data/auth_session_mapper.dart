import '../../../core/storage/message_records.dart';
import '../../../generated/proto/tureon.pb.dart' as pb;
import 'auth_session_validator.dart';

/// Maps authoritative account/session fields from the server response.
///
/// Username setup returns a fresh access token but cannot return the raw
/// refresh token again. In that case only the already-authenticated session's
/// refresh token may be carried forward.
UserSession authSessionFromResponse(
  pb.AuthResponse response, {
  UserSession? previousSession,
}) {
  if (previousSession != null &&
      (response.userId != previousSession.userId ||
          response.deviceId != previousSession.deviceId)) {
    throw StateError('The server response changed the authenticated session.');
  }

  final refreshToken = response.refreshToken.isNotEmpty
      ? response.refreshToken
      : previousSession?.refreshToken ?? '';
  return validateAuthSession(
    UserSession(
      userId: response.userId,
      accessToken: response.accessToken,
      refreshToken: refreshToken,
      deviceId: response.deviceId,
      signalDeviceId: response.signalDeviceId,
      username: response.username,
      email: response.email,
      displayName: response.displayName,
      avatarUrl: response.avatarUrl.isEmpty ? null : response.avatarUrl,
      accountStatus: response.accountStatus,
      needsUsername: response.needsUsername,
    ),
  );
}
