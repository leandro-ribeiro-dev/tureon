import 'package:flutter/foundation.dart';

const _configuredGrpcHost = String.fromEnvironment('TUREON_GRPC_HOST');
const grpcServerPort = int.fromEnvironment(
  'TUREON_GRPC_PORT',
  defaultValue: 50051,
);
const mediaServerPort = int.fromEnvironment(
  'TUREON_MEDIA_PORT',
  defaultValue: 8081,
);

String resolveGrpcHost({TargetPlatform? platform}) {
  if (_configuredGrpcHost.trim().isNotEmpty) {
    return _configuredGrpcHost.trim();
  }

  // run-dev.sh installs adb reverse rules for attached Android devices, so
  // Android Emulator and USB devices can share the same local endpoint.
  // Linux also reaches the development server through loopback.
  return '127.0.0.1';
}

bool resolveGrpcTransportSecurity(String host) {
  const forceSecure = bool.fromEnvironment('TUREON_GRPC_SECURE');
  // The local development server has no TLS certificate. Keep plaintext
  // limited to loopback, including an installed Linux build; all remote hosts
  // use TLS regardless of build mode.
  return forceSecure || !_isLocalDevelopmentHost(host);
}

bool _isLocalDevelopmentHost(String value) {
  var host = value.trim().toLowerCase();
  if (host.startsWith('[') && host.endsWith(']')) {
    host = host.substring(1, host.length - 1);
  }
  if (host.endsWith('.')) host = host.substring(0, host.length - 1);

  return host == 'localhost' ||
      host == '::1' ||
      host == '10.0.2.2' ||
      host == '10.0.3.2' ||
      host == '127.0.0.1' ||
      host.startsWith('127.');
}
