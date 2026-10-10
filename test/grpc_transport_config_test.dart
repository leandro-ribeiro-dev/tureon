import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tureon/core/network/grpc_transport_config.dart';

void main() {
  test('the default local endpoint works for desktop and Android', () {
    expect(resolveGrpcHost(platform: TargetPlatform.android), '127.0.0.1');
    expect(resolveGrpcHost(platform: TargetPlatform.linux), '127.0.0.1');
  });

  test('local debug hosts use plaintext by default', () {
    expect(resolveGrpcTransportSecurity('127.0.0.1'), isFalse);
    expect(resolveGrpcTransportSecurity('localhost'), isFalse);
    expect(resolveGrpcTransportSecurity('10.0.2.2'), isFalse);
  });

  test('explicit server hosts use TLS by default', () {
    expect(resolveGrpcTransportSecurity('chat.example.com'), isTrue);
  });
}
