import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grpc/grpc.dart';
import 'package:tureon/core/app/app_runtime.dart';
import 'package:tureon/core/network/grpc_client.dart';
import 'package:tureon/core/storage/local_store.dart';
import 'package:tureon/core/storage/message_records.dart';
import 'package:tureon/features/auth/data/auth_runtime_coordinator.dart';
import 'package:tureon/features/auth/data/google_auth_data_source.dart';
import 'package:tureon/generated/proto/tureon.pb.dart' as pb;
import 'package:tureon/generated/proto/tureon.pbgrpc.dart' as rpc;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'fresh second device retries failed metadata without a transport change',
    () async {
      FlutterSecureStorage.setMockInitialValues({
        'tureon.refresh_token': 'saved-refresh',
      });
      final server = Server.create(services: [_Auth(), _Health()]);
      await server.serve(address: '127.0.0.1', port: 0);
      addTearDown(server.shutdown);
      final store = LocalStore.inMemory();
      store.saveSession(
        const UserSession(
          userId: 'account',
          deviceId: 'second-device',
          signalDeviceId: 2,
          accessToken: 'saved-access',
          refreshToken: 'saved-refresh',
          accountStatus: 'active',
        ),
      );
      var profileLoads = 0;
      var roomLoads = 0;
      final ready = Completer<void>();
      void checkReady() {
        if (profileLoads >= 2 && roomLoads >= 2 && !ready.isCompleted) {
          ready.complete();
        }
      }

      final runtime = AppRuntime.forTesting(
        store: store,
        loadProfile: (_) async {
          profileLoads++;
          if (profileLoads == 1) {
            throw GrpcError.unavailable('Temporary profile failure');
          }
          checkReady();
          return const UserProfile(
            userId: 'account',
            username: 'alice',
            displayName: 'Alice',
          );
        },
        loadGroupChannels: (_) async {
          roomLoads++;
          if (roomLoads == 1) {
            throw GrpcError.unavailable('Temporary room failure');
          }
          checkReady();
          return (
            groups: [
              pb.GroupChannel(id: 'existing-group', name: 'Existing group'),
            ],
            channels: <pb.GroupChannel>[],
          );
        },
      );
      addTearDown(() async {
        await runtime.close();
        await Future<void>.delayed(const Duration(milliseconds: 100));
      });
      await runtime.connect(host: '127.0.0.1', port: server.port!);
      await runtime.configureAuth(_Google());
      await ready.future.timeout(const Duration(seconds: 5));
      // Let the successful snapshot persist after its loader returned.
      await Future<void>.delayed(Duration.zero);
      expect(runtime.currentUser?.userId, 'account');
      expect(store.loadRecipient('existing-group'), isNotNull);
      expect(runtime.currentDeviceId, 'second-device');
    },
  );

  test(
    'second-device profile request can recover authentication without a cycle',
    () async {
      FlutterSecureStorage.setMockInitialValues({
        'tureon.refresh_token': 'saved-refresh',
      });
      final auth = _Auth();
      final profiles = _Profiles();
      final server = Server.create(services: [auth, profiles]);
      await server.serve(address: '127.0.0.1', port: 0);
      addTearDown(server.shutdown);
      final client = GrpcClient(host: '127.0.0.1', port: server.port!);
      addTearDown(client.shutdown);
      final store = LocalStore.inMemory();
      addTearDown(store.close);
      store.saveSession(
        const UserSession(
          userId: 'account',
          deviceId: 'second-device',
          signalDeviceId: 2,
          accessToken: 'saved-access',
          refreshToken: 'saved-refresh',
          accountStatus: 'active',
        ),
      );
      late Future<pb.ProfileResponse> profileRequest;
      var notifications = 0;
      final coordinator = AuthRuntimeCoordinator(
        store: store,
        persistSession: (session) async {
          store.saveSession(session!);
          client.setAccessToken(session.accessToken);
        },
        onSessionRefreshed: (_) async {
          notifications++;
          // ProfileSyncManager shares this pending request with its callers.
          // Recovery must finish so the same request can retry and complete.
          await profileRequest;
        },
        onAuthStateChanged: (_) {},
        onAuthenticationRecoveryChanged: (_) {},
        onControllerChanged: (_) {},
      );
      coordinator.connect(client);
      addTearDown(coordinator.disconnect);
      await coordinator.configure(_Google());

      profileRequest = client.profiles.getProfile(
        pb.GetProfileRequest(recipientId: 'account'),
      );
      final profile = await profileRequest.timeout(const Duration(seconds: 3));

      expect(profile.recipientId, 'account');
      expect(auth.refreshes, 2);
      expect(profiles.requests, 2);
      expect(notifications, 1);
      expect(store.loadSession()?.deviceId, 'second-device');
      expect(store.loadSession()?.signalDeviceId, 2);
      expect(client.hasAccessToken, isTrue);
      expect(
        await const FlutterSecureStorage().read(key: 'tureon.refresh_token'),
        'refresh-2',
      );
    },
  );
}

class _Auth extends rpc.AuthServiceBase {
  int refreshes = 0;

  @override
  Future<pb.AuthResponse> refreshToken(
    ServiceCall call,
    pb.RefreshTokenRequest request,
  ) async {
    refreshes++;
    return pb.AuthResponse(
      userId: 'account',
      deviceId: 'second-device',
      signalDeviceId: 2,
      accessToken: 'access-$refreshes',
      refreshToken: 'refresh-$refreshes',
      username: 'alice',
      accountStatus: 'active',
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _Health extends rpc.HealthServiceBase {
  @override
  Future<pb.ServerHealthResponse> check(
    ServiceCall call,
    pb.Empty request,
  ) async => pb.ServerHealthResponse(serving: true);
}

class _Profiles extends rpc.ProfileServiceBase {
  int requests = 0;

  @override
  Future<pb.ProfileResponse> getProfile(
    ServiceCall call,
    pb.GetProfileRequest request,
  ) async {
    requests++;
    if (call.clientMetadata?['authorization'] != 'Bearer access-2') {
      throw GrpcError.unauthenticated('Expired test credential');
    }
    return pb.ProfileResponse(recipientId: 'account');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _Google implements GoogleAuthDataSource {
  @override
  Future<void> initialize() async {}
  @override
  Future<String?> authenticate() async => 'google-token';
  @override
  Future<void> signOut() async {}
}
