import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:grpc/grpc.dart';
import 'package:tureon/features/auth/data/device_metadata.dart';
import 'package:tureon/features/auth/data/grpc_auth_gateway.dart';
import 'package:tureon/generated/proto/tureon.pb.dart' as pb;
import 'package:tureon/generated/proto/tureon.pbgrpc.dart' as rpc;

void main() {
  late _Auth auth;
  late ClientChannel channel;
  setUp(() async {
    auth = _Auth();
    final server = Server.create(services: [auth]);
    await server.serve(address: '127.0.0.1', port: 0);
    addTearDown(server.shutdown);
    channel = ClientChannel(
      '127.0.0.1',
      port: server.port!,
      options: const ChannelOptions(credentials: ChannelCredentials.insecure()),
    );
    addTearDown(channel.shutdown);
  });
  test(
    'failed device metadata can retry and successful metadata is cached',
    () async {
      var loads = 0;
      final gateway = GrpcAuthGateway(
        rpc.AuthServiceClient(channel),
        loadDeviceMetadata: () async {
          if (++loads == 1) throw StateError('temporary plugin error');
          return const DeviceMetadata(name: 'Phone', platform: 'android');
        },
      );
      await expectLater(gateway.loginWithGoogle('token'), throwsStateError);
      expect((await gateway.loginWithGoogle('token')).userId, 'new-account');
      await gateway.loginWithGoogle('token');
      expect(loads, 2);
      expect(auth.logins, 2);
    },
  );
  test('a new login never joins the previous session refresh', () async {
    final gateway = GrpcAuthGateway(
      rpc.AuthServiceClient(channel),
      loadDeviceMetadata: () async =>
          const DeviceMetadata(name: 'Phone', platform: 'android'),
    );
    final old = gateway.refresh('old-refresh', 'old-phone');
    final oldFailure = expectLater(old, throwsStateError);
    await auth.oldStarted.future;
    await gateway.loginWithGoogle('token');
    final current = gateway.refresh('new-refresh', 'new-phone');
    final joined = gateway.refresh('new-refresh', 'new-phone');
    expect(identical(current, joined), isTrue);
    expect((await current).userId, 'new-account');
    auth.oldResponse.complete(_response('old-account', 'old-phone'));
    await oldFailure;
    expect(auth.refreshes, 2);
  });
}

pb.AuthResponse _response(String user, String device) => pb.AuthResponse(
  userId: user,
  deviceId: device,
  signalDeviceId: 1,
  accessToken: 'access',
  refreshToken: 'refresh',
  username: 'alice',
  accountStatus: 'active',
);

class _Auth extends rpc.AuthServiceBase {
  int logins = 0;
  int refreshes = 0;
  final oldStarted = Completer<void>();
  final oldResponse = Completer<pb.AuthResponse>();
  @override
  Future<pb.AuthResponse> loginWithGoogle(
    ServiceCall call,
    pb.AuthRequest request,
  ) async {
    logins++;
    return _response('new-account', 'new-phone');
  }

  @override
  Future<pb.AuthResponse> refreshToken(
    ServiceCall call,
    pb.RefreshTokenRequest request,
  ) async {
    refreshes++;
    if (request.refreshToken == 'old-refresh') {
      oldStarted.complete();
      return oldResponse.future;
    }
    return _response('new-account', 'new-phone');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
