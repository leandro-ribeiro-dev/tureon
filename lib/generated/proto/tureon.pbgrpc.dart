//
//  Generated code. Do not modify.
//  source: proto/tureon.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'tureon.pb.dart' as $0;

export 'tureon.pb.dart';

@$pb.GrpcServiceName('tureon.v1.HealthService')
class HealthServiceClient extends $grpc.Client {
  static final _$check = $grpc.ClientMethod<$0.Empty, $0.ServerHealthResponse>(
      '/tureon.v1.HealthService/Check',
      ($0.Empty value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.ServerHealthResponse.fromBuffer(value));

  HealthServiceClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options,
        interceptors: interceptors);

  $grpc.ResponseFuture<$0.ServerHealthResponse> check($0.Empty request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$check, request, options: options);
  }
}

@$pb.GrpcServiceName('tureon.v1.HealthService')
abstract class HealthServiceBase extends $grpc.Service {
  $core.String get $name => 'tureon.v1.HealthService';

  HealthServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.ServerHealthResponse>(
        'Check',
        check_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.ServerHealthResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.ServerHealthResponse> check_Pre($grpc.ServiceCall call, $async.Future<$0.Empty> request) async {
    return check(call, await request);
  }

  $async.Future<$0.ServerHealthResponse> check($grpc.ServiceCall call, $0.Empty request);
}
@$pb.GrpcServiceName('tureon.v1.AuthService')
class AuthServiceClient extends $grpc.Client {
  static final _$loginWithGoogle = $grpc.ClientMethod<$0.AuthRequest, $0.AuthResponse>(
      '/tureon.v1.AuthService/LoginWithGoogle',
      ($0.AuthRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.AuthResponse.fromBuffer(value));
  static final _$loginWithTestAccount = $grpc.ClientMethod<$0.TestAccountLoginRequest, $0.AuthResponse>(
      '/tureon.v1.AuthService/LoginWithTestAccount',
      ($0.TestAccountLoginRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.AuthResponse.fromBuffer(value));
  static final _$setUsername = $grpc.ClientMethod<$0.SetUsernameRequest, $0.AuthResponse>(
      '/tureon.v1.AuthService/SetUsername',
      ($0.SetUsernameRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.AuthResponse.fromBuffer(value));
  static final _$refreshToken = $grpc.ClientMethod<$0.RefreshTokenRequest, $0.AuthResponse>(
      '/tureon.v1.AuthService/RefreshToken',
      ($0.RefreshTokenRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.AuthResponse.fromBuffer(value));
  static final _$logout = $grpc.ClientMethod<$0.LogoutRequest, $0.Empty>(
      '/tureon.v1.AuthService/Logout',
      ($0.LogoutRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Empty.fromBuffer(value));
  static final _$registerDevice = $grpc.ClientMethod<$0.AuthRequest, $0.AuthResponse>(
      '/tureon.v1.AuthService/RegisterDevice',
      ($0.AuthRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.AuthResponse.fromBuffer(value));
  static final _$listDevices = $grpc.ClientMethod<$0.Empty, $0.ListDevicesResponse>(
      '/tureon.v1.AuthService/ListDevices',
      ($0.Empty value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.ListDevicesResponse.fromBuffer(value));
  static final _$revokeDevice = $grpc.ClientMethod<$0.LogoutRequest, $0.Empty>(
      '/tureon.v1.AuthService/RevokeDevice',
      ($0.LogoutRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Empty.fromBuffer(value));

  AuthServiceClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options,
        interceptors: interceptors);

  $grpc.ResponseFuture<$0.AuthResponse> loginWithGoogle($0.AuthRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$loginWithGoogle, request, options: options);
  }

  $grpc.ResponseFuture<$0.AuthResponse> loginWithTestAccount($0.TestAccountLoginRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$loginWithTestAccount, request, options: options);
  }

  $grpc.ResponseFuture<$0.AuthResponse> setUsername($0.SetUsernameRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$setUsername, request, options: options);
  }

  $grpc.ResponseFuture<$0.AuthResponse> refreshToken($0.RefreshTokenRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$refreshToken, request, options: options);
  }

  $grpc.ResponseFuture<$0.Empty> logout($0.LogoutRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$logout, request, options: options);
  }

  $grpc.ResponseFuture<$0.AuthResponse> registerDevice($0.AuthRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$registerDevice, request, options: options);
  }

  $grpc.ResponseFuture<$0.ListDevicesResponse> listDevices($0.Empty request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$listDevices, request, options: options);
  }

  $grpc.ResponseFuture<$0.Empty> revokeDevice($0.LogoutRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$revokeDevice, request, options: options);
  }
}

@$pb.GrpcServiceName('tureon.v1.AuthService')
abstract class AuthServiceBase extends $grpc.Service {
  $core.String get $name => 'tureon.v1.AuthService';

  AuthServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.AuthRequest, $0.AuthResponse>(
        'LoginWithGoogle',
        loginWithGoogle_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.AuthRequest.fromBuffer(value),
        ($0.AuthResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.TestAccountLoginRequest, $0.AuthResponse>(
        'LoginWithTestAccount',
        loginWithTestAccount_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.TestAccountLoginRequest.fromBuffer(value),
        ($0.AuthResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SetUsernameRequest, $0.AuthResponse>(
        'SetUsername',
        setUsername_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.SetUsernameRequest.fromBuffer(value),
        ($0.AuthResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.RefreshTokenRequest, $0.AuthResponse>(
        'RefreshToken',
        refreshToken_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.RefreshTokenRequest.fromBuffer(value),
        ($0.AuthResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.LogoutRequest, $0.Empty>(
        'Logout',
        logout_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.LogoutRequest.fromBuffer(value),
        ($0.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.AuthRequest, $0.AuthResponse>(
        'RegisterDevice',
        registerDevice_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.AuthRequest.fromBuffer(value),
        ($0.AuthResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.ListDevicesResponse>(
        'ListDevices',
        listDevices_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.ListDevicesResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.LogoutRequest, $0.Empty>(
        'RevokeDevice',
        revokeDevice_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.LogoutRequest.fromBuffer(value),
        ($0.Empty value) => value.writeToBuffer()));
  }

  $async.Future<$0.AuthResponse> loginWithGoogle_Pre($grpc.ServiceCall call, $async.Future<$0.AuthRequest> request) async {
    return loginWithGoogle(call, await request);
  }

  $async.Future<$0.AuthResponse> loginWithTestAccount_Pre($grpc.ServiceCall call, $async.Future<$0.TestAccountLoginRequest> request) async {
    return loginWithTestAccount(call, await request);
  }

  $async.Future<$0.AuthResponse> setUsername_Pre($grpc.ServiceCall call, $async.Future<$0.SetUsernameRequest> request) async {
    return setUsername(call, await request);
  }

  $async.Future<$0.AuthResponse> refreshToken_Pre($grpc.ServiceCall call, $async.Future<$0.RefreshTokenRequest> request) async {
    return refreshToken(call, await request);
  }

  $async.Future<$0.Empty> logout_Pre($grpc.ServiceCall call, $async.Future<$0.LogoutRequest> request) async {
    return logout(call, await request);
  }

  $async.Future<$0.AuthResponse> registerDevice_Pre($grpc.ServiceCall call, $async.Future<$0.AuthRequest> request) async {
    return registerDevice(call, await request);
  }

  $async.Future<$0.ListDevicesResponse> listDevices_Pre($grpc.ServiceCall call, $async.Future<$0.Empty> request) async {
    return listDevices(call, await request);
  }

  $async.Future<$0.Empty> revokeDevice_Pre($grpc.ServiceCall call, $async.Future<$0.LogoutRequest> request) async {
    return revokeDevice(call, await request);
  }

  $async.Future<$0.AuthResponse> loginWithGoogle($grpc.ServiceCall call, $0.AuthRequest request);
  $async.Future<$0.AuthResponse> loginWithTestAccount($grpc.ServiceCall call, $0.TestAccountLoginRequest request);
  $async.Future<$0.AuthResponse> setUsername($grpc.ServiceCall call, $0.SetUsernameRequest request);
  $async.Future<$0.AuthResponse> refreshToken($grpc.ServiceCall call, $0.RefreshTokenRequest request);
  $async.Future<$0.Empty> logout($grpc.ServiceCall call, $0.LogoutRequest request);
  $async.Future<$0.AuthResponse> registerDevice($grpc.ServiceCall call, $0.AuthRequest request);
  $async.Future<$0.ListDevicesResponse> listDevices($grpc.ServiceCall call, $0.Empty request);
  $async.Future<$0.Empty> revokeDevice($grpc.ServiceCall call, $0.LogoutRequest request);
}
@$pb.GrpcServiceName('tureon.v1.KeyService')
class KeyServiceClient extends $grpc.Client {
  static final _$uploadKeyBundle = $grpc.ClientMethod<$0.KeyBundleUploadRequest, $0.Empty>(
      '/tureon.v1.KeyService/UploadKeyBundle',
      ($0.KeyBundleUploadRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Empty.fromBuffer(value));
  static final _$getKeyBundle = $grpc.ClientMethod<$0.GetKeyBundleRequest, $0.KeyBundle>(
      '/tureon.v1.KeyService/GetKeyBundle',
      ($0.GetKeyBundleRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.KeyBundle.fromBuffer(value));
  static final _$refillOneTimePrekeys = $grpc.ClientMethod<$0.RefillOneTimePrekeysRequest, $0.Empty>(
      '/tureon.v1.KeyService/RefillOneTimePrekeys',
      ($0.RefillOneTimePrekeysRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Empty.fromBuffer(value));
  static final _$getPreKeyCount = $grpc.ClientMethod<$0.Empty, $0.GetPreKeyCountResponse>(
      '/tureon.v1.KeyService/GetPreKeyCount',
      ($0.Empty value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.GetPreKeyCountResponse.fromBuffer(value));
  static final _$listRecipientKeyDevices = $grpc.ClientMethod<$0.ListRecipientKeyDevicesRequest, $0.ListRecipientKeyDevicesResponse>(
      '/tureon.v1.KeyService/ListRecipientKeyDevices',
      ($0.ListRecipientKeyDevicesRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.ListRecipientKeyDevicesResponse.fromBuffer(value));

  KeyServiceClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options,
        interceptors: interceptors);

  $grpc.ResponseFuture<$0.Empty> uploadKeyBundle($0.KeyBundleUploadRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$uploadKeyBundle, request, options: options);
  }

  $grpc.ResponseFuture<$0.KeyBundle> getKeyBundle($0.GetKeyBundleRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getKeyBundle, request, options: options);
  }

  $grpc.ResponseFuture<$0.Empty> refillOneTimePrekeys($0.RefillOneTimePrekeysRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$refillOneTimePrekeys, request, options: options);
  }

  $grpc.ResponseFuture<$0.GetPreKeyCountResponse> getPreKeyCount($0.Empty request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getPreKeyCount, request, options: options);
  }

  $grpc.ResponseFuture<$0.ListRecipientKeyDevicesResponse> listRecipientKeyDevices($0.ListRecipientKeyDevicesRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$listRecipientKeyDevices, request, options: options);
  }
}

@$pb.GrpcServiceName('tureon.v1.KeyService')
abstract class KeyServiceBase extends $grpc.Service {
  $core.String get $name => 'tureon.v1.KeyService';

  KeyServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.KeyBundleUploadRequest, $0.Empty>(
        'UploadKeyBundle',
        uploadKeyBundle_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.KeyBundleUploadRequest.fromBuffer(value),
        ($0.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetKeyBundleRequest, $0.KeyBundle>(
        'GetKeyBundle',
        getKeyBundle_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GetKeyBundleRequest.fromBuffer(value),
        ($0.KeyBundle value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.RefillOneTimePrekeysRequest, $0.Empty>(
        'RefillOneTimePrekeys',
        refillOneTimePrekeys_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.RefillOneTimePrekeysRequest.fromBuffer(value),
        ($0.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.GetPreKeyCountResponse>(
        'GetPreKeyCount',
        getPreKeyCount_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.GetPreKeyCountResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ListRecipientKeyDevicesRequest, $0.ListRecipientKeyDevicesResponse>(
        'ListRecipientKeyDevices',
        listRecipientKeyDevices_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ListRecipientKeyDevicesRequest.fromBuffer(value),
        ($0.ListRecipientKeyDevicesResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.Empty> uploadKeyBundle_Pre($grpc.ServiceCall call, $async.Future<$0.KeyBundleUploadRequest> request) async {
    return uploadKeyBundle(call, await request);
  }

  $async.Future<$0.KeyBundle> getKeyBundle_Pre($grpc.ServiceCall call, $async.Future<$0.GetKeyBundleRequest> request) async {
    return getKeyBundle(call, await request);
  }

  $async.Future<$0.Empty> refillOneTimePrekeys_Pre($grpc.ServiceCall call, $async.Future<$0.RefillOneTimePrekeysRequest> request) async {
    return refillOneTimePrekeys(call, await request);
  }

  $async.Future<$0.GetPreKeyCountResponse> getPreKeyCount_Pre($grpc.ServiceCall call, $async.Future<$0.Empty> request) async {
    return getPreKeyCount(call, await request);
  }

  $async.Future<$0.ListRecipientKeyDevicesResponse> listRecipientKeyDevices_Pre($grpc.ServiceCall call, $async.Future<$0.ListRecipientKeyDevicesRequest> request) async {
    return listRecipientKeyDevices(call, await request);
  }

  $async.Future<$0.Empty> uploadKeyBundle($grpc.ServiceCall call, $0.KeyBundleUploadRequest request);
  $async.Future<$0.KeyBundle> getKeyBundle($grpc.ServiceCall call, $0.GetKeyBundleRequest request);
  $async.Future<$0.Empty> refillOneTimePrekeys($grpc.ServiceCall call, $0.RefillOneTimePrekeysRequest request);
  $async.Future<$0.GetPreKeyCountResponse> getPreKeyCount($grpc.ServiceCall call, $0.Empty request);
  $async.Future<$0.ListRecipientKeyDevicesResponse> listRecipientKeyDevices($grpc.ServiceCall call, $0.ListRecipientKeyDevicesRequest request);
}
@$pb.GrpcServiceName('tureon.v1.MessagingService')
class MessagingServiceClient extends $grpc.Client {
  static final _$chatStream = $grpc.ClientMethod<$0.ChatStreamRequest, $0.ChatStreamResponse>(
      '/tureon.v1.MessagingService/ChatStream',
      ($0.ChatStreamRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.ChatStreamResponse.fromBuffer(value));

  MessagingServiceClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options,
        interceptors: interceptors);

  $grpc.ResponseStream<$0.ChatStreamResponse> chatStream($async.Stream<$0.ChatStreamRequest> request, {$grpc.CallOptions? options}) {
    return $createStreamingCall(_$chatStream, request, options: options);
  }
}

@$pb.GrpcServiceName('tureon.v1.MessagingService')
abstract class MessagingServiceBase extends $grpc.Service {
  $core.String get $name => 'tureon.v1.MessagingService';

  MessagingServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.ChatStreamRequest, $0.ChatStreamResponse>(
        'ChatStream',
        chatStream,
        true,
        true,
        ($core.List<$core.int> value) => $0.ChatStreamRequest.fromBuffer(value),
        ($0.ChatStreamResponse value) => value.writeToBuffer()));
  }

  $async.Stream<$0.ChatStreamResponse> chatStream($grpc.ServiceCall call, $async.Stream<$0.ChatStreamRequest> request);
}
@$pb.GrpcServiceName('tureon.v1.PresenceService')
class PresenceServiceClient extends $grpc.Client {
  static final _$realtime = $grpc.ClientMethod<$0.PresenceClientEvent, $0.PresenceServerEvent>(
      '/tureon.v1.PresenceService/Realtime',
      ($0.PresenceClientEvent value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.PresenceServerEvent.fromBuffer(value));
  static final _$updatePresence = $grpc.ClientMethod<$0.PresenceUpdate, $0.Empty>(
      '/tureon.v1.PresenceService/UpdatePresence',
      ($0.PresenceUpdate value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Empty.fromBuffer(value));
  static final _$streamPresence = $grpc.ClientMethod<$0.Empty, $0.PresenceUpdate>(
      '/tureon.v1.PresenceService/StreamPresence',
      ($0.Empty value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.PresenceUpdate.fromBuffer(value));
  static final _$sendTypingIndicator = $grpc.ClientMethod<$0.TypingIndicator, $0.Empty>(
      '/tureon.v1.PresenceService/SendTypingIndicator',
      ($0.TypingIndicator value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Empty.fromBuffer(value));
  static final _$streamTyping = $grpc.ClientMethod<$0.Empty, $0.TypingIndicator>(
      '/tureon.v1.PresenceService/StreamTyping',
      ($0.Empty value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.TypingIndicator.fromBuffer(value));

  PresenceServiceClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options,
        interceptors: interceptors);

  $grpc.ResponseStream<$0.PresenceServerEvent> realtime($async.Stream<$0.PresenceClientEvent> request, {$grpc.CallOptions? options}) {
    return $createStreamingCall(_$realtime, request, options: options);
  }

  $grpc.ResponseFuture<$0.Empty> updatePresence($0.PresenceUpdate request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$updatePresence, request, options: options);
  }

  $grpc.ResponseStream<$0.PresenceUpdate> streamPresence($0.Empty request, {$grpc.CallOptions? options}) {
    return $createStreamingCall(_$streamPresence, $async.Stream.fromIterable([request]), options: options);
  }

  $grpc.ResponseFuture<$0.Empty> sendTypingIndicator($0.TypingIndicator request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$sendTypingIndicator, request, options: options);
  }

  $grpc.ResponseStream<$0.TypingIndicator> streamTyping($0.Empty request, {$grpc.CallOptions? options}) {
    return $createStreamingCall(_$streamTyping, $async.Stream.fromIterable([request]), options: options);
  }
}

@$pb.GrpcServiceName('tureon.v1.PresenceService')
abstract class PresenceServiceBase extends $grpc.Service {
  $core.String get $name => 'tureon.v1.PresenceService';

  PresenceServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.PresenceClientEvent, $0.PresenceServerEvent>(
        'Realtime',
        realtime,
        true,
        true,
        ($core.List<$core.int> value) => $0.PresenceClientEvent.fromBuffer(value),
        ($0.PresenceServerEvent value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.PresenceUpdate, $0.Empty>(
        'UpdatePresence',
        updatePresence_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.PresenceUpdate.fromBuffer(value),
        ($0.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.PresenceUpdate>(
        'StreamPresence',
        streamPresence_Pre,
        false,
        true,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.PresenceUpdate value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.TypingIndicator, $0.Empty>(
        'SendTypingIndicator',
        sendTypingIndicator_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.TypingIndicator.fromBuffer(value),
        ($0.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.TypingIndicator>(
        'StreamTyping',
        streamTyping_Pre,
        false,
        true,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.TypingIndicator value) => value.writeToBuffer()));
  }

  $async.Future<$0.Empty> updatePresence_Pre($grpc.ServiceCall call, $async.Future<$0.PresenceUpdate> request) async {
    return updatePresence(call, await request);
  }

  $async.Stream<$0.PresenceUpdate> streamPresence_Pre($grpc.ServiceCall call, $async.Future<$0.Empty> request) async* {
    yield* streamPresence(call, await request);
  }

  $async.Future<$0.Empty> sendTypingIndicator_Pre($grpc.ServiceCall call, $async.Future<$0.TypingIndicator> request) async {
    return sendTypingIndicator(call, await request);
  }

  $async.Stream<$0.TypingIndicator> streamTyping_Pre($grpc.ServiceCall call, $async.Future<$0.Empty> request) async* {
    yield* streamTyping(call, await request);
  }

  $async.Stream<$0.PresenceServerEvent> realtime($grpc.ServiceCall call, $async.Stream<$0.PresenceClientEvent> request);
  $async.Future<$0.Empty> updatePresence($grpc.ServiceCall call, $0.PresenceUpdate request);
  $async.Stream<$0.PresenceUpdate> streamPresence($grpc.ServiceCall call, $0.Empty request);
  $async.Future<$0.Empty> sendTypingIndicator($grpc.ServiceCall call, $0.TypingIndicator request);
  $async.Stream<$0.TypingIndicator> streamTyping($grpc.ServiceCall call, $0.Empty request);
}
@$pb.GrpcServiceName('tureon.v1.ContactsService')
class ContactsServiceClient extends $grpc.Client {
  static final _$searchUsersByUsername = $grpc.ClientMethod<$0.SearchUsersByUsernameRequest, $0.SearchUsersByUsernameResponse>(
      '/tureon.v1.ContactsService/SearchUsersByUsername',
      ($0.SearchUsersByUsernameRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.SearchUsersByUsernameResponse.fromBuffer(value));
  static final _$addContact = $grpc.ClientMethod<$0.Empty, $0.Empty>(
      '/tureon.v1.ContactsService/AddContact',
      ($0.Empty value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Empty.fromBuffer(value));
  static final _$blockUser = $grpc.ClientMethod<$0.Empty, $0.Empty>(
      '/tureon.v1.ContactsService/BlockUser',
      ($0.Empty value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Empty.fromBuffer(value));
  static final _$listContacts = $grpc.ClientMethod<$0.Empty, $0.Empty>(
      '/tureon.v1.ContactsService/ListContacts',
      ($0.Empty value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Empty.fromBuffer(value));

  ContactsServiceClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options,
        interceptors: interceptors);

  $grpc.ResponseFuture<$0.SearchUsersByUsernameResponse> searchUsersByUsername($0.SearchUsersByUsernameRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$searchUsersByUsername, request, options: options);
  }

  $grpc.ResponseFuture<$0.Empty> addContact($0.Empty request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$addContact, request, options: options);
  }

  $grpc.ResponseFuture<$0.Empty> blockUser($0.Empty request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$blockUser, request, options: options);
  }

  $grpc.ResponseFuture<$0.Empty> listContacts($0.Empty request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$listContacts, request, options: options);
  }
}

@$pb.GrpcServiceName('tureon.v1.ContactsService')
abstract class ContactsServiceBase extends $grpc.Service {
  $core.String get $name => 'tureon.v1.ContactsService';

  ContactsServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.SearchUsersByUsernameRequest, $0.SearchUsersByUsernameResponse>(
        'SearchUsersByUsername',
        searchUsersByUsername_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.SearchUsersByUsernameRequest.fromBuffer(value),
        ($0.SearchUsersByUsernameResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.Empty>(
        'AddContact',
        addContact_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.Empty>(
        'BlockUser',
        blockUser_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.Empty>(
        'ListContacts',
        listContacts_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.Empty value) => value.writeToBuffer()));
  }

  $async.Future<$0.SearchUsersByUsernameResponse> searchUsersByUsername_Pre($grpc.ServiceCall call, $async.Future<$0.SearchUsersByUsernameRequest> request) async {
    return searchUsersByUsername(call, await request);
  }

  $async.Future<$0.Empty> addContact_Pre($grpc.ServiceCall call, $async.Future<$0.Empty> request) async {
    return addContact(call, await request);
  }

  $async.Future<$0.Empty> blockUser_Pre($grpc.ServiceCall call, $async.Future<$0.Empty> request) async {
    return blockUser(call, await request);
  }

  $async.Future<$0.Empty> listContacts_Pre($grpc.ServiceCall call, $async.Future<$0.Empty> request) async {
    return listContacts(call, await request);
  }

  $async.Future<$0.SearchUsersByUsernameResponse> searchUsersByUsername($grpc.ServiceCall call, $0.SearchUsersByUsernameRequest request);
  $async.Future<$0.Empty> addContact($grpc.ServiceCall call, $0.Empty request);
  $async.Future<$0.Empty> blockUser($grpc.ServiceCall call, $0.Empty request);
  $async.Future<$0.Empty> listContacts($grpc.ServiceCall call, $0.Empty request);
}
@$pb.GrpcServiceName('tureon.v1.GroupService')
class GroupServiceClient extends $grpc.Client {
  static final _$createGroup = $grpc.ClientMethod<$0.CreateGroupRequest, $0.CreateGroupResponse>(
      '/tureon.v1.GroupService/CreateGroup',
      ($0.CreateGroupRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.CreateGroupResponse.fromBuffer(value));
  static final _$updateGroup = $grpc.ClientMethod<$0.UpdateGroupChannelRequest, $0.UpdateGroupChannelResponse>(
      '/tureon.v1.GroupService/UpdateGroup',
      ($0.UpdateGroupChannelRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.UpdateGroupChannelResponse.fromBuffer(value));
  static final _$listMyGroups = $grpc.ClientMethod<$0.Empty, $0.ListMyGroupsResponse>(
      '/tureon.v1.GroupService/ListMyGroups',
      ($0.Empty value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.ListMyGroupsResponse.fromBuffer(value));
  static final _$searchPublicGroups = $grpc.ClientMethod<$0.SearchPublicGroupsRequest, $0.SearchPublicGroupsResponse>(
      '/tureon.v1.GroupService/SearchPublicGroups',
      ($0.SearchPublicGroupsRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.SearchPublicGroupsResponse.fromBuffer(value));
  static final _$joinPublicGroup = $grpc.ClientMethod<$0.JoinPublicGroupRequest, $0.JoinPublicGroupResponse>(
      '/tureon.v1.GroupService/JoinPublicGroup',
      ($0.JoinPublicGroupRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.JoinPublicGroupResponse.fromBuffer(value));
  static final _$listMembers = $grpc.ClientMethod<$0.Empty, $0.ListGroupChannelMembersResponse>(
      '/tureon.v1.GroupService/ListMembers',
      ($0.Empty value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.ListGroupChannelMembersResponse.fromBuffer(value));
  static final _$listMembersPage = $grpc.ClientMethod<$0.ListGroupChannelMembersPageRequest, $0.ListGroupChannelMembersPageResponse>(
      '/tureon.v1.GroupService/ListMembersPage',
      ($0.ListGroupChannelMembersPageRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.ListGroupChannelMembersPageResponse.fromBuffer(value));
  static final _$getOnlineMemberCount = $grpc.ClientMethod<$0.GetGroupOnlineMemberCountRequest, $0.GetGroupOnlineMemberCountResponse>(
      '/tureon.v1.GroupService/GetOnlineMemberCount',
      ($0.GetGroupOnlineMemberCountRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.GetGroupOnlineMemberCountResponse.fromBuffer(value));
  static final _$addMember = $grpc.ClientMethod<$0.Empty, $0.Empty>(
      '/tureon.v1.GroupService/AddMember',
      ($0.Empty value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Empty.fromBuffer(value));
  static final _$removeMember = $grpc.ClientMethod<$0.Empty, $0.Empty>(
      '/tureon.v1.GroupService/RemoveMember',
      ($0.Empty value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Empty.fromBuffer(value));
  static final _$banUser = $grpc.ClientMethod<$0.Empty, $0.Empty>(
      '/tureon.v1.GroupService/BanUser',
      ($0.Empty value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Empty.fromBuffer(value));
  static final _$updateMemberRole = $grpc.ClientMethod<$0.Empty, $0.Empty>(
      '/tureon.v1.GroupService/UpdateMemberRole',
      ($0.Empty value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Empty.fromBuffer(value));
  static final _$updateGroupSendPermission = $grpc.ClientMethod<$0.UpdateGroupChannelSendPermissionRequest, $0.UpdateGroupChannelSendPermissionResponse>(
      '/tureon.v1.GroupService/UpdateGroupSendPermission',
      ($0.UpdateGroupChannelSendPermissionRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.UpdateGroupChannelSendPermissionResponse.fromBuffer(value));
  static final _$updateGroupPermissions = $grpc.ClientMethod<$0.UpdateGroupChannelPermissionsRequest, $0.GroupChannel>(
      '/tureon.v1.GroupService/UpdateGroupPermissions',
      ($0.UpdateGroupChannelPermissionsRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.GroupChannel.fromBuffer(value));
  static final _$getGroupChannel = $grpc.ClientMethod<$0.GetGroupChannelRequest, $0.GetGroupChannelResponse>(
      '/tureon.v1.GroupService/GetGroupChannel',
      ($0.GetGroupChannelRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.GetGroupChannelResponse.fromBuffer(value));

  GroupServiceClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options,
        interceptors: interceptors);

  $grpc.ResponseFuture<$0.CreateGroupResponse> createGroup($0.CreateGroupRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$createGroup, request, options: options);
  }

  $grpc.ResponseFuture<$0.UpdateGroupChannelResponse> updateGroup($0.UpdateGroupChannelRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$updateGroup, request, options: options);
  }

  $grpc.ResponseFuture<$0.ListMyGroupsResponse> listMyGroups($0.Empty request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$listMyGroups, request, options: options);
  }

  $grpc.ResponseFuture<$0.SearchPublicGroupsResponse> searchPublicGroups($0.SearchPublicGroupsRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$searchPublicGroups, request, options: options);
  }

  $grpc.ResponseFuture<$0.JoinPublicGroupResponse> joinPublicGroup($0.JoinPublicGroupRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$joinPublicGroup, request, options: options);
  }

  $grpc.ResponseFuture<$0.ListGroupChannelMembersResponse> listMembers($0.Empty request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$listMembers, request, options: options);
  }

  $grpc.ResponseFuture<$0.ListGroupChannelMembersPageResponse> listMembersPage($0.ListGroupChannelMembersPageRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$listMembersPage, request, options: options);
  }

  $grpc.ResponseFuture<$0.GetGroupOnlineMemberCountResponse> getOnlineMemberCount($0.GetGroupOnlineMemberCountRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getOnlineMemberCount, request, options: options);
  }

  $grpc.ResponseFuture<$0.Empty> addMember($0.Empty request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$addMember, request, options: options);
  }

  $grpc.ResponseFuture<$0.Empty> removeMember($0.Empty request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$removeMember, request, options: options);
  }

  $grpc.ResponseFuture<$0.Empty> banUser($0.Empty request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$banUser, request, options: options);
  }

  $grpc.ResponseFuture<$0.Empty> updateMemberRole($0.Empty request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$updateMemberRole, request, options: options);
  }

  $grpc.ResponseFuture<$0.UpdateGroupChannelSendPermissionResponse> updateGroupSendPermission($0.UpdateGroupChannelSendPermissionRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$updateGroupSendPermission, request, options: options);
  }

  $grpc.ResponseFuture<$0.GroupChannel> updateGroupPermissions($0.UpdateGroupChannelPermissionsRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$updateGroupPermissions, request, options: options);
  }

  $grpc.ResponseFuture<$0.GetGroupChannelResponse> getGroupChannel($0.GetGroupChannelRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getGroupChannel, request, options: options);
  }
}

@$pb.GrpcServiceName('tureon.v1.GroupService')
abstract class GroupServiceBase extends $grpc.Service {
  $core.String get $name => 'tureon.v1.GroupService';

  GroupServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.CreateGroupRequest, $0.CreateGroupResponse>(
        'CreateGroup',
        createGroup_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.CreateGroupRequest.fromBuffer(value),
        ($0.CreateGroupResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.UpdateGroupChannelRequest, $0.UpdateGroupChannelResponse>(
        'UpdateGroup',
        updateGroup_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.UpdateGroupChannelRequest.fromBuffer(value),
        ($0.UpdateGroupChannelResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.ListMyGroupsResponse>(
        'ListMyGroups',
        listMyGroups_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.ListMyGroupsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SearchPublicGroupsRequest, $0.SearchPublicGroupsResponse>(
        'SearchPublicGroups',
        searchPublicGroups_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.SearchPublicGroupsRequest.fromBuffer(value),
        ($0.SearchPublicGroupsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.JoinPublicGroupRequest, $0.JoinPublicGroupResponse>(
        'JoinPublicGroup',
        joinPublicGroup_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.JoinPublicGroupRequest.fromBuffer(value),
        ($0.JoinPublicGroupResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.ListGroupChannelMembersResponse>(
        'ListMembers',
        listMembers_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.ListGroupChannelMembersResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ListGroupChannelMembersPageRequest, $0.ListGroupChannelMembersPageResponse>(
        'ListMembersPage',
        listMembersPage_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ListGroupChannelMembersPageRequest.fromBuffer(value),
        ($0.ListGroupChannelMembersPageResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetGroupOnlineMemberCountRequest, $0.GetGroupOnlineMemberCountResponse>(
        'GetOnlineMemberCount',
        getOnlineMemberCount_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GetGroupOnlineMemberCountRequest.fromBuffer(value),
        ($0.GetGroupOnlineMemberCountResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.Empty>(
        'AddMember',
        addMember_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.Empty>(
        'RemoveMember',
        removeMember_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.Empty>(
        'BanUser',
        banUser_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.Empty>(
        'UpdateMemberRole',
        updateMemberRole_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.UpdateGroupChannelSendPermissionRequest, $0.UpdateGroupChannelSendPermissionResponse>(
        'UpdateGroupSendPermission',
        updateGroupSendPermission_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.UpdateGroupChannelSendPermissionRequest.fromBuffer(value),
        ($0.UpdateGroupChannelSendPermissionResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.UpdateGroupChannelPermissionsRequest, $0.GroupChannel>(
        'UpdateGroupPermissions',
        updateGroupPermissions_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.UpdateGroupChannelPermissionsRequest.fromBuffer(value),
        ($0.GroupChannel value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetGroupChannelRequest, $0.GetGroupChannelResponse>(
        'GetGroupChannel',
        getGroupChannel_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GetGroupChannelRequest.fromBuffer(value),
        ($0.GetGroupChannelResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.CreateGroupResponse> createGroup_Pre($grpc.ServiceCall call, $async.Future<$0.CreateGroupRequest> request) async {
    return createGroup(call, await request);
  }

  $async.Future<$0.UpdateGroupChannelResponse> updateGroup_Pre($grpc.ServiceCall call, $async.Future<$0.UpdateGroupChannelRequest> request) async {
    return updateGroup(call, await request);
  }

  $async.Future<$0.ListMyGroupsResponse> listMyGroups_Pre($grpc.ServiceCall call, $async.Future<$0.Empty> request) async {
    return listMyGroups(call, await request);
  }

  $async.Future<$0.SearchPublicGroupsResponse> searchPublicGroups_Pre($grpc.ServiceCall call, $async.Future<$0.SearchPublicGroupsRequest> request) async {
    return searchPublicGroups(call, await request);
  }

  $async.Future<$0.JoinPublicGroupResponse> joinPublicGroup_Pre($grpc.ServiceCall call, $async.Future<$0.JoinPublicGroupRequest> request) async {
    return joinPublicGroup(call, await request);
  }

  $async.Future<$0.ListGroupChannelMembersResponse> listMembers_Pre($grpc.ServiceCall call, $async.Future<$0.Empty> request) async {
    return listMembers(call, await request);
  }

  $async.Future<$0.ListGroupChannelMembersPageResponse> listMembersPage_Pre($grpc.ServiceCall call, $async.Future<$0.ListGroupChannelMembersPageRequest> request) async {
    return listMembersPage(call, await request);
  }

  $async.Future<$0.GetGroupOnlineMemberCountResponse> getOnlineMemberCount_Pre($grpc.ServiceCall call, $async.Future<$0.GetGroupOnlineMemberCountRequest> request) async {
    return getOnlineMemberCount(call, await request);
  }

  $async.Future<$0.Empty> addMember_Pre($grpc.ServiceCall call, $async.Future<$0.Empty> request) async {
    return addMember(call, await request);
  }

  $async.Future<$0.Empty> removeMember_Pre($grpc.ServiceCall call, $async.Future<$0.Empty> request) async {
    return removeMember(call, await request);
  }

  $async.Future<$0.Empty> banUser_Pre($grpc.ServiceCall call, $async.Future<$0.Empty> request) async {
    return banUser(call, await request);
  }

  $async.Future<$0.Empty> updateMemberRole_Pre($grpc.ServiceCall call, $async.Future<$0.Empty> request) async {
    return updateMemberRole(call, await request);
  }

  $async.Future<$0.UpdateGroupChannelSendPermissionResponse> updateGroupSendPermission_Pre($grpc.ServiceCall call, $async.Future<$0.UpdateGroupChannelSendPermissionRequest> request) async {
    return updateGroupSendPermission(call, await request);
  }

  $async.Future<$0.GroupChannel> updateGroupPermissions_Pre($grpc.ServiceCall call, $async.Future<$0.UpdateGroupChannelPermissionsRequest> request) async {
    return updateGroupPermissions(call, await request);
  }

  $async.Future<$0.GetGroupChannelResponse> getGroupChannel_Pre($grpc.ServiceCall call, $async.Future<$0.GetGroupChannelRequest> request) async {
    return getGroupChannel(call, await request);
  }

  $async.Future<$0.CreateGroupResponse> createGroup($grpc.ServiceCall call, $0.CreateGroupRequest request);
  $async.Future<$0.UpdateGroupChannelResponse> updateGroup($grpc.ServiceCall call, $0.UpdateGroupChannelRequest request);
  $async.Future<$0.ListMyGroupsResponse> listMyGroups($grpc.ServiceCall call, $0.Empty request);
  $async.Future<$0.SearchPublicGroupsResponse> searchPublicGroups($grpc.ServiceCall call, $0.SearchPublicGroupsRequest request);
  $async.Future<$0.JoinPublicGroupResponse> joinPublicGroup($grpc.ServiceCall call, $0.JoinPublicGroupRequest request);
  $async.Future<$0.ListGroupChannelMembersResponse> listMembers($grpc.ServiceCall call, $0.Empty request);
  $async.Future<$0.ListGroupChannelMembersPageResponse> listMembersPage($grpc.ServiceCall call, $0.ListGroupChannelMembersPageRequest request);
  $async.Future<$0.GetGroupOnlineMemberCountResponse> getOnlineMemberCount($grpc.ServiceCall call, $0.GetGroupOnlineMemberCountRequest request);
  $async.Future<$0.Empty> addMember($grpc.ServiceCall call, $0.Empty request);
  $async.Future<$0.Empty> removeMember($grpc.ServiceCall call, $0.Empty request);
  $async.Future<$0.Empty> banUser($grpc.ServiceCall call, $0.Empty request);
  $async.Future<$0.Empty> updateMemberRole($grpc.ServiceCall call, $0.Empty request);
  $async.Future<$0.UpdateGroupChannelSendPermissionResponse> updateGroupSendPermission($grpc.ServiceCall call, $0.UpdateGroupChannelSendPermissionRequest request);
  $async.Future<$0.GroupChannel> updateGroupPermissions($grpc.ServiceCall call, $0.UpdateGroupChannelPermissionsRequest request);
  $async.Future<$0.GetGroupChannelResponse> getGroupChannel($grpc.ServiceCall call, $0.GetGroupChannelRequest request);
}
@$pb.GrpcServiceName('tureon.v1.ChannelService')
class ChannelServiceClient extends $grpc.Client {
  static final _$createChannel = $grpc.ClientMethod<$0.CreateChannelRequest, $0.CreateChannelResponse>(
      '/tureon.v1.ChannelService/CreateChannel',
      ($0.CreateChannelRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.CreateChannelResponse.fromBuffer(value));
  static final _$updateChannel = $grpc.ClientMethod<$0.UpdateGroupChannelRequest, $0.UpdateGroupChannelResponse>(
      '/tureon.v1.ChannelService/UpdateChannel',
      ($0.UpdateGroupChannelRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.UpdateGroupChannelResponse.fromBuffer(value));
  static final _$listMyChannels = $grpc.ClientMethod<$0.Empty, $0.ListMyChannelsResponse>(
      '/tureon.v1.ChannelService/ListMyChannels',
      ($0.Empty value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.ListMyChannelsResponse.fromBuffer(value));
  static final _$searchPublicChannels = $grpc.ClientMethod<$0.SearchPublicChannelsRequest, $0.SearchPublicChannelsResponse>(
      '/tureon.v1.ChannelService/SearchPublicChannels',
      ($0.SearchPublicChannelsRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.SearchPublicChannelsResponse.fromBuffer(value));
  static final _$joinPublicChannel = $grpc.ClientMethod<$0.JoinPublicChannelRequest, $0.JoinPublicChannelResponse>(
      '/tureon.v1.ChannelService/JoinPublicChannel',
      ($0.JoinPublicChannelRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.JoinPublicChannelResponse.fromBuffer(value));
  static final _$subscribe = $grpc.ClientMethod<$0.Empty, $0.Empty>(
      '/tureon.v1.ChannelService/Subscribe',
      ($0.Empty value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Empty.fromBuffer(value));
  static final _$banUser = $grpc.ClientMethod<$0.Empty, $0.Empty>(
      '/tureon.v1.ChannelService/BanUser',
      ($0.Empty value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Empty.fromBuffer(value));
  static final _$updateChannelSendPermission = $grpc.ClientMethod<$0.UpdateGroupChannelSendPermissionRequest, $0.UpdateGroupChannelSendPermissionResponse>(
      '/tureon.v1.ChannelService/UpdateChannelSendPermission',
      ($0.UpdateGroupChannelSendPermissionRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.UpdateGroupChannelSendPermissionResponse.fromBuffer(value));
  static final _$updateChannelPermissions = $grpc.ClientMethod<$0.UpdateGroupChannelPermissionsRequest, $0.GroupChannel>(
      '/tureon.v1.ChannelService/UpdateChannelPermissions',
      ($0.UpdateGroupChannelPermissionsRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.GroupChannel.fromBuffer(value));
  static final _$getGroupChannel = $grpc.ClientMethod<$0.GetGroupChannelRequest, $0.GetGroupChannelResponse>(
      '/tureon.v1.ChannelService/GetGroupChannel',
      ($0.GetGroupChannelRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.GetGroupChannelResponse.fromBuffer(value));

  ChannelServiceClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options,
        interceptors: interceptors);

  $grpc.ResponseFuture<$0.CreateChannelResponse> createChannel($0.CreateChannelRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$createChannel, request, options: options);
  }

  $grpc.ResponseFuture<$0.UpdateGroupChannelResponse> updateChannel($0.UpdateGroupChannelRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$updateChannel, request, options: options);
  }

  $grpc.ResponseFuture<$0.ListMyChannelsResponse> listMyChannels($0.Empty request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$listMyChannels, request, options: options);
  }

  $grpc.ResponseFuture<$0.SearchPublicChannelsResponse> searchPublicChannels($0.SearchPublicChannelsRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$searchPublicChannels, request, options: options);
  }

  $grpc.ResponseFuture<$0.JoinPublicChannelResponse> joinPublicChannel($0.JoinPublicChannelRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$joinPublicChannel, request, options: options);
  }

  $grpc.ResponseFuture<$0.Empty> subscribe($0.Empty request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$subscribe, request, options: options);
  }

  $grpc.ResponseFuture<$0.Empty> banUser($0.Empty request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$banUser, request, options: options);
  }

  $grpc.ResponseFuture<$0.UpdateGroupChannelSendPermissionResponse> updateChannelSendPermission($0.UpdateGroupChannelSendPermissionRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$updateChannelSendPermission, request, options: options);
  }

  $grpc.ResponseFuture<$0.GroupChannel> updateChannelPermissions($0.UpdateGroupChannelPermissionsRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$updateChannelPermissions, request, options: options);
  }

  $grpc.ResponseFuture<$0.GetGroupChannelResponse> getGroupChannel($0.GetGroupChannelRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getGroupChannel, request, options: options);
  }
}

@$pb.GrpcServiceName('tureon.v1.ChannelService')
abstract class ChannelServiceBase extends $grpc.Service {
  $core.String get $name => 'tureon.v1.ChannelService';

  ChannelServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.CreateChannelRequest, $0.CreateChannelResponse>(
        'CreateChannel',
        createChannel_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.CreateChannelRequest.fromBuffer(value),
        ($0.CreateChannelResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.UpdateGroupChannelRequest, $0.UpdateGroupChannelResponse>(
        'UpdateChannel',
        updateChannel_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.UpdateGroupChannelRequest.fromBuffer(value),
        ($0.UpdateGroupChannelResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.ListMyChannelsResponse>(
        'ListMyChannels',
        listMyChannels_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.ListMyChannelsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SearchPublicChannelsRequest, $0.SearchPublicChannelsResponse>(
        'SearchPublicChannels',
        searchPublicChannels_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.SearchPublicChannelsRequest.fromBuffer(value),
        ($0.SearchPublicChannelsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.JoinPublicChannelRequest, $0.JoinPublicChannelResponse>(
        'JoinPublicChannel',
        joinPublicChannel_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.JoinPublicChannelRequest.fromBuffer(value),
        ($0.JoinPublicChannelResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.Empty>(
        'Subscribe',
        subscribe_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.Empty>(
        'BanUser',
        banUser_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.UpdateGroupChannelSendPermissionRequest, $0.UpdateGroupChannelSendPermissionResponse>(
        'UpdateChannelSendPermission',
        updateChannelSendPermission_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.UpdateGroupChannelSendPermissionRequest.fromBuffer(value),
        ($0.UpdateGroupChannelSendPermissionResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.UpdateGroupChannelPermissionsRequest, $0.GroupChannel>(
        'UpdateChannelPermissions',
        updateChannelPermissions_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.UpdateGroupChannelPermissionsRequest.fromBuffer(value),
        ($0.GroupChannel value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetGroupChannelRequest, $0.GetGroupChannelResponse>(
        'GetGroupChannel',
        getGroupChannel_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GetGroupChannelRequest.fromBuffer(value),
        ($0.GetGroupChannelResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.CreateChannelResponse> createChannel_Pre($grpc.ServiceCall call, $async.Future<$0.CreateChannelRequest> request) async {
    return createChannel(call, await request);
  }

  $async.Future<$0.UpdateGroupChannelResponse> updateChannel_Pre($grpc.ServiceCall call, $async.Future<$0.UpdateGroupChannelRequest> request) async {
    return updateChannel(call, await request);
  }

  $async.Future<$0.ListMyChannelsResponse> listMyChannels_Pre($grpc.ServiceCall call, $async.Future<$0.Empty> request) async {
    return listMyChannels(call, await request);
  }

  $async.Future<$0.SearchPublicChannelsResponse> searchPublicChannels_Pre($grpc.ServiceCall call, $async.Future<$0.SearchPublicChannelsRequest> request) async {
    return searchPublicChannels(call, await request);
  }

  $async.Future<$0.JoinPublicChannelResponse> joinPublicChannel_Pre($grpc.ServiceCall call, $async.Future<$0.JoinPublicChannelRequest> request) async {
    return joinPublicChannel(call, await request);
  }

  $async.Future<$0.Empty> subscribe_Pre($grpc.ServiceCall call, $async.Future<$0.Empty> request) async {
    return subscribe(call, await request);
  }

  $async.Future<$0.Empty> banUser_Pre($grpc.ServiceCall call, $async.Future<$0.Empty> request) async {
    return banUser(call, await request);
  }

  $async.Future<$0.UpdateGroupChannelSendPermissionResponse> updateChannelSendPermission_Pre($grpc.ServiceCall call, $async.Future<$0.UpdateGroupChannelSendPermissionRequest> request) async {
    return updateChannelSendPermission(call, await request);
  }

  $async.Future<$0.GroupChannel> updateChannelPermissions_Pre($grpc.ServiceCall call, $async.Future<$0.UpdateGroupChannelPermissionsRequest> request) async {
    return updateChannelPermissions(call, await request);
  }

  $async.Future<$0.GetGroupChannelResponse> getGroupChannel_Pre($grpc.ServiceCall call, $async.Future<$0.GetGroupChannelRequest> request) async {
    return getGroupChannel(call, await request);
  }

  $async.Future<$0.CreateChannelResponse> createChannel($grpc.ServiceCall call, $0.CreateChannelRequest request);
  $async.Future<$0.UpdateGroupChannelResponse> updateChannel($grpc.ServiceCall call, $0.UpdateGroupChannelRequest request);
  $async.Future<$0.ListMyChannelsResponse> listMyChannels($grpc.ServiceCall call, $0.Empty request);
  $async.Future<$0.SearchPublicChannelsResponse> searchPublicChannels($grpc.ServiceCall call, $0.SearchPublicChannelsRequest request);
  $async.Future<$0.JoinPublicChannelResponse> joinPublicChannel($grpc.ServiceCall call, $0.JoinPublicChannelRequest request);
  $async.Future<$0.Empty> subscribe($grpc.ServiceCall call, $0.Empty request);
  $async.Future<$0.Empty> banUser($grpc.ServiceCall call, $0.Empty request);
  $async.Future<$0.UpdateGroupChannelSendPermissionResponse> updateChannelSendPermission($grpc.ServiceCall call, $0.UpdateGroupChannelSendPermissionRequest request);
  $async.Future<$0.GroupChannel> updateChannelPermissions($grpc.ServiceCall call, $0.UpdateGroupChannelPermissionsRequest request);
  $async.Future<$0.GetGroupChannelResponse> getGroupChannel($grpc.ServiceCall call, $0.GetGroupChannelRequest request);
}
@$pb.GrpcServiceName('tureon.v1.ProfileService')
class ProfileServiceClient extends $grpc.Client {
  static final _$updateProfile = $grpc.ClientMethod<$0.UpdateProfileRequest, $0.ProfileResponse>(
      '/tureon.v1.ProfileService/UpdateProfile',
      ($0.UpdateProfileRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.ProfileResponse.fromBuffer(value));
  static final _$getProfile = $grpc.ClientMethod<$0.GetProfileRequest, $0.ProfileResponse>(
      '/tureon.v1.ProfileService/GetProfile',
      ($0.GetProfileRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.ProfileResponse.fromBuffer(value));
  static final _$updatePrivacySetting = $grpc.ClientMethod<$0.UpdatePrivacySettingRequest, $0.ProfileResponse>(
      '/tureon.v1.ProfileService/UpdatePrivacySetting',
      ($0.UpdatePrivacySettingRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.ProfileResponse.fromBuffer(value));
  static final _$streamProfileChanges = $grpc.ClientMethod<$0.Empty, $0.ProfileChange>(
      '/tureon.v1.ProfileService/StreamProfileChanges',
      ($0.Empty value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.ProfileChange.fromBuffer(value));
  static final _$streamRecipientProfileChanges = $grpc.ClientMethod<$0.ProfileWatchRequest, $0.ProfileChange>(
      '/tureon.v1.ProfileService/StreamRecipientProfileChanges',
      ($0.ProfileWatchRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.ProfileChange.fromBuffer(value));

  ProfileServiceClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options,
        interceptors: interceptors);

  $grpc.ResponseFuture<$0.ProfileResponse> updateProfile($0.UpdateProfileRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$updateProfile, request, options: options);
  }

  $grpc.ResponseFuture<$0.ProfileResponse> getProfile($0.GetProfileRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getProfile, request, options: options);
  }

  $grpc.ResponseFuture<$0.ProfileResponse> updatePrivacySetting($0.UpdatePrivacySettingRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$updatePrivacySetting, request, options: options);
  }

  $grpc.ResponseStream<$0.ProfileChange> streamProfileChanges($0.Empty request, {$grpc.CallOptions? options}) {
    return $createStreamingCall(_$streamProfileChanges, $async.Stream.fromIterable([request]), options: options);
  }

  $grpc.ResponseStream<$0.ProfileChange> streamRecipientProfileChanges($0.ProfileWatchRequest request, {$grpc.CallOptions? options}) {
    return $createStreamingCall(_$streamRecipientProfileChanges, $async.Stream.fromIterable([request]), options: options);
  }
}

@$pb.GrpcServiceName('tureon.v1.ProfileService')
abstract class ProfileServiceBase extends $grpc.Service {
  $core.String get $name => 'tureon.v1.ProfileService';

  ProfileServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.UpdateProfileRequest, $0.ProfileResponse>(
        'UpdateProfile',
        updateProfile_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.UpdateProfileRequest.fromBuffer(value),
        ($0.ProfileResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetProfileRequest, $0.ProfileResponse>(
        'GetProfile',
        getProfile_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GetProfileRequest.fromBuffer(value),
        ($0.ProfileResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.UpdatePrivacySettingRequest, $0.ProfileResponse>(
        'UpdatePrivacySetting',
        updatePrivacySetting_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.UpdatePrivacySettingRequest.fromBuffer(value),
        ($0.ProfileResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.ProfileChange>(
        'StreamProfileChanges',
        streamProfileChanges_Pre,
        false,
        true,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.ProfileChange value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ProfileWatchRequest, $0.ProfileChange>(
        'StreamRecipientProfileChanges',
        streamRecipientProfileChanges_Pre,
        false,
        true,
        ($core.List<$core.int> value) => $0.ProfileWatchRequest.fromBuffer(value),
        ($0.ProfileChange value) => value.writeToBuffer()));
  }

  $async.Future<$0.ProfileResponse> updateProfile_Pre($grpc.ServiceCall call, $async.Future<$0.UpdateProfileRequest> request) async {
    return updateProfile(call, await request);
  }

  $async.Future<$0.ProfileResponse> getProfile_Pre($grpc.ServiceCall call, $async.Future<$0.GetProfileRequest> request) async {
    return getProfile(call, await request);
  }

  $async.Future<$0.ProfileResponse> updatePrivacySetting_Pre($grpc.ServiceCall call, $async.Future<$0.UpdatePrivacySettingRequest> request) async {
    return updatePrivacySetting(call, await request);
  }

  $async.Stream<$0.ProfileChange> streamProfileChanges_Pre($grpc.ServiceCall call, $async.Future<$0.Empty> request) async* {
    yield* streamProfileChanges(call, await request);
  }

  $async.Stream<$0.ProfileChange> streamRecipientProfileChanges_Pre($grpc.ServiceCall call, $async.Future<$0.ProfileWatchRequest> request) async* {
    yield* streamRecipientProfileChanges(call, await request);
  }

  $async.Future<$0.ProfileResponse> updateProfile($grpc.ServiceCall call, $0.UpdateProfileRequest request);
  $async.Future<$0.ProfileResponse> getProfile($grpc.ServiceCall call, $0.GetProfileRequest request);
  $async.Future<$0.ProfileResponse> updatePrivacySetting($grpc.ServiceCall call, $0.UpdatePrivacySettingRequest request);
  $async.Stream<$0.ProfileChange> streamProfileChanges($grpc.ServiceCall call, $0.Empty request);
  $async.Stream<$0.ProfileChange> streamRecipientProfileChanges($grpc.ServiceCall call, $0.ProfileWatchRequest request);
}
@$pb.GrpcServiceName('tureon.v1.MembershipService')
class MembershipServiceClient extends $grpc.Client {
  static final _$streamMembershipChanges = $grpc.ClientMethod<$0.Empty, $0.MembershipChange>(
      '/tureon.v1.MembershipService/StreamMembershipChanges',
      ($0.Empty value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.MembershipChange.fromBuffer(value));

  MembershipServiceClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options,
        interceptors: interceptors);

  $grpc.ResponseStream<$0.MembershipChange> streamMembershipChanges($0.Empty request, {$grpc.CallOptions? options}) {
    return $createStreamingCall(_$streamMembershipChanges, $async.Stream.fromIterable([request]), options: options);
  }
}

@$pb.GrpcServiceName('tureon.v1.MembershipService')
abstract class MembershipServiceBase extends $grpc.Service {
  $core.String get $name => 'tureon.v1.MembershipService';

  MembershipServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.MembershipChange>(
        'StreamMembershipChanges',
        streamMembershipChanges_Pre,
        false,
        true,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.MembershipChange value) => value.writeToBuffer()));
  }

  $async.Stream<$0.MembershipChange> streamMembershipChanges_Pre($grpc.ServiceCall call, $async.Future<$0.Empty> request) async* {
    yield* streamMembershipChanges(call, await request);
  }

  $async.Stream<$0.MembershipChange> streamMembershipChanges($grpc.ServiceCall call, $0.Empty request);
}
