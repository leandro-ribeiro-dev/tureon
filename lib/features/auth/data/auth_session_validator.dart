import '../../../core/storage/message_records.dart';

class InvalidAuthSessionException implements Exception {
  const InvalidAuthSessionException(this.field);

  final String field;

  @override
  String toString() => 'The authentication response is missing $field.';
}

UserSession validateAuthSession(UserSession session) {
  if (session.userId.trim().isEmpty) {
    throw const InvalidAuthSessionException('the user id');
  }
  if (session.deviceId.trim().isEmpty) {
    throw const InvalidAuthSessionException('the device id');
  }
  if (session.accessToken.trim().isEmpty) {
    throw const InvalidAuthSessionException('the access token');
  }
  if (session.refreshToken.trim().isEmpty) {
    throw const InvalidAuthSessionException('the refresh token');
  }
  if (session.signalDeviceId <= 0) {
    throw const InvalidAuthSessionException('the Signal device id');
  }
  if (session.accountStatus.trim().isEmpty) {
    throw const InvalidAuthSessionException('the account status');
  }
  return session;
}
