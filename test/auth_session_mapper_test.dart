import 'package:flutter_test/flutter_test.dart';
import 'package:tureon/core/storage/message_records.dart';
import 'package:tureon/features/auth/data/auth_session_mapper.dart';
import 'package:tureon/features/auth/data/auth_session_validator.dart';
import 'package:tureon/generated/proto/tureon.pb.dart' as pb;

void main() {
  const previous = UserSession(
    userId: 'user-1',
    deviceId: 'device-1',
    signalDeviceId: 3,
    accessToken: 'old-access',
    refreshToken: 'current-refresh',
    needsUsername: true,
  );

  test('username setup preserves the current refresh token', () {
    final session = authSessionFromResponse(
      _response(refreshToken: '', accessToken: 'new-access'),
      previousSession: previous,
    );

    expect(session.refreshToken, 'current-refresh');
    expect(session.accessToken, 'new-access');
    expect(session.username, 'new_user');
    expect(session.needsUsername, isFalse);
  });

  test('a normal authentication response must include a refresh token', () {
    expect(
      () => authSessionFromResponse(_response(refreshToken: '')),
      throwsA(isA<InvalidAuthSessionException>()),
    );
  });

  test('a returned refresh token replaces the previous token', () {
    final session = authSessionFromResponse(
      _response(refreshToken: 'rotated-refresh'),
      previousSession: previous,
    );

    expect(session.refreshToken, 'rotated-refresh');
  });

  test('username setup cannot change the active account or device', () {
    expect(
      () => authSessionFromResponse(
        _response(userId: 'other-user', refreshToken: ''),
        previousSession: previous,
      ),
      throwsStateError,
    );
  });
}

pb.AuthResponse _response({
  String userId = 'user-1',
  String deviceId = 'device-1',
  String accessToken = 'new-access',
  required String refreshToken,
}) => pb.AuthResponse(
  userId: userId,
  deviceId: deviceId,
  signalDeviceId: 3,
  accessToken: accessToken,
  refreshToken: refreshToken,
  username: 'new_user',
  accountStatus: 'active',
);
