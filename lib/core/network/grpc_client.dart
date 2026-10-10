import 'package:grpc/grpc.dart';
import 'package:grpc/grpc.dart' as grpc;

import '../../generated/proto/tureon.pbgrpc.dart';
import 'grpc_auth_interceptor.dart';

class GrpcClient {
  GrpcClient({
    required String host,
    int port = 50051,
    String? accessToken,
    bool secure = false,
  }) : _channel = ClientChannel(
         host,
         port: port,
         options: ChannelOptions(
           credentials: secure
               ? const ChannelCredentials.secure()
               : const ChannelCredentials.insecure(),
           codecRegistry: CodecRegistry(
             codecs: const [GzipCodec(), IdentityCodec()],
           ),
         ),
       ) {
    _accessToken = accessToken;
    authInterceptor = GrpcAuthInterceptor(accessToken: () => _accessToken);
    final interceptors = [authInterceptor];
    health = HealthServiceClient(_channel);
    auth = AuthServiceClient(_channel, interceptors: interceptors);
    messaging = MessagingServiceClient(_channel, interceptors: interceptors);
    presence = PresenceServiceClient(_channel, interceptors: interceptors);
    contacts = ContactsServiceClient(_channel, interceptors: interceptors);
    groups = GroupServiceClient(_channel, interceptors: interceptors);
    channels = ChannelServiceClient(_channel, interceptors: interceptors);
    profiles = ProfileServiceClient(_channel, interceptors: interceptors);
    memberships = MembershipServiceClient(_channel, interceptors: interceptors);
    keys = KeyServiceClient(_channel, interceptors: interceptors);
  }

  final ClientChannel _channel;
  String? _accessToken;
  late final GrpcAuthInterceptor authInterceptor;
  late final AuthServiceClient auth;
  late final HealthServiceClient health;
  late final MessagingServiceClient messaging;
  late final PresenceServiceClient presence;
  late final ContactsServiceClient contacts;
  late final GroupServiceClient groups;
  late final ChannelServiceClient channels;
  late final ProfileServiceClient profiles;
  late final MembershipServiceClient memberships;
  late final KeyServiceClient keys;
  CallOptions get callOptions => CallOptions();

  bool get hasAccessToken => _accessToken?.isNotEmpty == true;

  Future<void> checkServerHealth() async {
    final response = await health
        .check(
          Empty(),
          options: CallOptions(timeout: const Duration(seconds: 4)),
        )
        .timeout(const Duration(seconds: 5));
    if (!response.serving) {
      throw StateError('The gRPC server is reachable but not serving.');
    }
  }

  Stream<grpc.ConnectionState> get connectionStateChanges =>
      _channel.onConnectionStateChanged;

  void setAccessToken(String? token) => _accessToken = token;

  void setAuthenticationRecovery({
    required Future<void> Function(String? failedAccessToken) refresh,
    required Future<void> Function() onRefreshFailure,
  }) {
    authInterceptor.onRefresh = refresh;
    authInterceptor.onRefreshFailure = onRefreshFailure;
  }

  Future<void> shutdown() => _channel.shutdown();
}
