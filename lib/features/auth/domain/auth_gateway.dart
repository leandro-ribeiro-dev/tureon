import '../../../core/storage/message_records.dart';

enum AuthStatus {
  restoringSession,
  offline,
  unauthenticated,
  authenticating,
  needsUsername,
  authenticated,
  restricted,
}

class AuthState {
  const AuthState({
    required this.status,
    this.session,
    this.error,
    this.usernameError,
  });

  final AuthStatus status;
  final UserSession? session;
  final String? error;
  final String? usernameError;
}

abstract interface class AuthGateway {
  Future<UserSession> loginWithGoogle(String idToken, {String? deviceId});

  Future<UserSession> refresh(String refreshToken, String deviceId);

  Future<UserSession> setUsername(String username);

  Future<void> logout(String deviceId);

  Future<List<DeviceSession>> listDevices();

  Future<void> revokeDevice(String deviceId);
}

abstract interface class RefreshTokenStore {
  Future<String?> read();

  Future<void> write(String token);

  Future<void> clear();
}
