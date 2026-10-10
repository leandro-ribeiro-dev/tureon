import '../../../core/storage/message_records.dart';
import '../../../generated/proto/tureon.pb.dart' as pb;
import '../../../generated/proto/tureon.pbgrpc.dart';
import 'package:grpc/grpc.dart';

import '../domain/auth_gateway.dart';
import 'auth_session_mapper.dart';
import 'auth_session_validator.dart';
import 'device_metadata.dart';

const _authRpcTimeout = Duration(seconds: 15);
const _deviceRpcTimeout = Duration(seconds: 15);

class GrpcAuthGateway implements AuthGateway {
  GrpcAuthGateway(
    this._client, {
    Future<DeviceMetadata> Function()? loadDeviceMetadata,
  }) : _loadDeviceMetadata = loadDeviceMetadata ?? DeviceMetadata.load;

  final AuthServiceClient _client;
  final Future<DeviceMetadata> Function() _loadDeviceMetadata;
  Future<DeviceMetadata>? _deviceMetadata;
  UserSession? _session;
  Future<UserSession>? _refreshInFlight;
  int? _refreshGeneration;
  String? _refreshDevice;
  String? _refreshToken;
  int _sessionGeneration = 0;
  Future<void> Function(UserSession)? onSessionChanged;

  @override
  Future<UserSession> loginWithGoogle(
    String idToken, {
    String? deviceId,
  }) async {
    final generation = ++_sessionGeneration;
    final metadata = await _getDeviceMetadata();
    if (generation != _sessionGeneration) {
      throw StateError('The session changed while login was starting.');
    }
    final response = await _client.loginWithGoogle(
      pb.AuthRequest(
        googleIdToken: idToken,
        deviceId: deviceId ?? '',
        deviceName: metadata.name,
        platform: metadata.platform,
      ),
      options: CallOptions(timeout: _authRpcTimeout),
    );
    if (generation != _sessionGeneration) {
      throw StateError('The session changed while login was in progress.');
    }
    return _session = _fromResponse(response);
  }

  @override
  Future<UserSession> refresh(String refreshToken, String deviceId) {
    final current = _refreshInFlight;
    if (current != null &&
        _refreshGeneration == _sessionGeneration &&
        _refreshDevice == deviceId &&
        _refreshToken == refreshToken) {
      return current;
    }
    late final Future<UserSession> pending;
    pending = _rotateRefreshToken(refreshToken, deviceId).whenComplete(() {
      if (identical(_refreshInFlight, pending)) {
        _refreshInFlight = null;
        _refreshToken = null;
        _refreshDevice = null;
        _refreshGeneration = null;
      }
    });
    _refreshInFlight = pending;
    _refreshGeneration = _sessionGeneration;
    _refreshDevice = deviceId;
    _refreshToken = refreshToken;
    return pending;
  }

  Future<UserSession> _rotateRefreshToken(
    String refreshToken,
    String deviceId,
  ) async {
    final generation = _sessionGeneration;
    final response = await _client.refreshToken(
      pb.RefreshTokenRequest(refreshToken: refreshToken, deviceId: deviceId),
      options: CallOptions(timeout: _authRpcTimeout),
    );
    if (generation != _sessionGeneration) {
      throw StateError(
        'The session changed while the refresh was in progress.',
      );
    }
    return _session = _fromResponse(response);
  }

  Future<void> refreshAfterUnauthenticated(String? failedAccessToken) async {
    final generation = _sessionGeneration;
    final session = _session;
    if (session == null) {
      throw StateError('No authenticated session is available to refresh.');
    }
    if (failedAccessToken != null && session.accessToken != failedAccessToken) {
      return;
    }
    try {
      final updated = await _refreshCurrentSession();
      if (generation != _sessionGeneration ||
          _session?.deviceId != updated.deviceId) {
        throw StateError('The session changed while authentication recovered.');
      }
      await onSessionChanged?.call(updated);
    } on InvalidAuthSessionException catch (error) {
      throw GrpcError.unauthenticated(error.toString());
    }
  }

  Future<UserSession> _refreshCurrentSession() {
    final session = _session;
    if (session == null || session.refreshToken.isEmpty) {
      return Future.error(StateError('No refresh token is available.'));
    }
    return refresh(session.refreshToken, session.deviceId);
  }

  @override
  Future<UserSession> setUsername(String username) async {
    final generation = _sessionGeneration;
    if (_session == null) {
      throw StateError(
        'An authenticated session is required to set a username.',
      );
    }
    final response = await _client.setUsername(
      pb.SetUsernameRequest(username: username),
      options: CallOptions(timeout: _authRpcTimeout),
    );
    if (generation != _sessionGeneration) {
      throw StateError('The session changed while saving the username.');
    }
    final currentSession = _session;
    if (currentSession == null) {
      throw StateError(
        'The authenticated session ended while saving the username.',
      );
    }
    return _session = _fromResponse(response, previousSession: currentSession);
  }

  @override
  Future<void> logout(String deviceId) async {
    try {
      await _client.logout(
        pb.LogoutRequest(deviceId: deviceId),
        options: CallOptions(timeout: const Duration(seconds: 5)),
      );
    } finally {
      // Keep the current credential available while the interceptor retries
      // Logout after refreshing an expired access token.
      _sessionGeneration++;
      _session = null;
      _refreshInFlight = null;
    }
  }

  @override
  Future<List<DeviceSession>> listDevices() async {
    final response = await _client.listDevices(
      pb.Empty(),
      options: CallOptions(timeout: _deviceRpcTimeout),
    );
    return response.devices
        .map(
          (device) => DeviceSession(
            deviceId: device.deviceId,
            name: device.deviceName,
            platform: device.platform,
            lastActiveAt: DateTime.fromMillisecondsSinceEpoch(
              device.lastActiveAt.toInt() * 1000,
              isUtc: true,
            ),
            isCurrent: device.isCurrent,
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<void> revokeDevice(String deviceId) async {
    await _client.revokeDevice(
      pb.LogoutRequest(deviceId: deviceId),
      options: CallOptions(timeout: _deviceRpcTimeout),
    );
  }

  UserSession _fromResponse(
    pb.AuthResponse response, {
    UserSession? previousSession,
  }) => authSessionFromResponse(response, previousSession: previousSession);

  Future<DeviceMetadata> _getDeviceMetadata() {
    final current = _deviceMetadata;
    if (current != null) return current;
    late final Future<DeviceMetadata> pending;
    pending = Future<DeviceMetadata>.sync(_loadDeviceMetadata).catchError((
      Object error,
      StackTrace stack,
    ) {
      if (identical(_deviceMetadata, pending)) _deviceMetadata = null;
      Error.throwWithStackTrace(error, stack);
    });
    _deviceMetadata = pending;
    return pending;
  }
}
