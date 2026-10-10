//
//  Generated code. Do not modify.
//  source: tureon.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'tureon.pb.dart' as $1;
import 'tureon.pbjson.dart';

export 'tureon.pb.dart';

abstract class HealthServiceBase extends $pb.GeneratedService {
  $async.Future<$1.ServerHealthResponse> check($pb.ServerContext ctx, $1.Empty request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'Check': return $1.Empty();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'Check': return this.check(ctx, request as $1.Empty);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => HealthServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => HealthServiceBase$messageJson;
}

abstract class AuthServiceBase extends $pb.GeneratedService {
  $async.Future<$1.AuthResponse> loginWithGoogle($pb.ServerContext ctx, $1.AuthRequest request);
  $async.Future<$1.AuthResponse> loginWithTestAccount($pb.ServerContext ctx, $1.TestAccountLoginRequest request);
  $async.Future<$1.AuthResponse> setUsername($pb.ServerContext ctx, $1.SetUsernameRequest request);
  $async.Future<$1.AuthResponse> refreshToken($pb.ServerContext ctx, $1.RefreshTokenRequest request);
  $async.Future<$1.Empty> logout($pb.ServerContext ctx, $1.LogoutRequest request);
  $async.Future<$1.AuthResponse> registerDevice($pb.ServerContext ctx, $1.AuthRequest request);
  $async.Future<$1.ListDevicesResponse> listDevices($pb.ServerContext ctx, $1.Empty request);
  $async.Future<$1.Empty> revokeDevice($pb.ServerContext ctx, $1.LogoutRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'LoginWithGoogle': return $1.AuthRequest();
      case 'LoginWithTestAccount': return $1.TestAccountLoginRequest();
      case 'SetUsername': return $1.SetUsernameRequest();
      case 'RefreshToken': return $1.RefreshTokenRequest();
      case 'Logout': return $1.LogoutRequest();
      case 'RegisterDevice': return $1.AuthRequest();
      case 'ListDevices': return $1.Empty();
      case 'RevokeDevice': return $1.LogoutRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'LoginWithGoogle': return this.loginWithGoogle(ctx, request as $1.AuthRequest);
      case 'LoginWithTestAccount': return this.loginWithTestAccount(ctx, request as $1.TestAccountLoginRequest);
      case 'SetUsername': return this.setUsername(ctx, request as $1.SetUsernameRequest);
      case 'RefreshToken': return this.refreshToken(ctx, request as $1.RefreshTokenRequest);
      case 'Logout': return this.logout(ctx, request as $1.LogoutRequest);
      case 'RegisterDevice': return this.registerDevice(ctx, request as $1.AuthRequest);
      case 'ListDevices': return this.listDevices(ctx, request as $1.Empty);
      case 'RevokeDevice': return this.revokeDevice(ctx, request as $1.LogoutRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => AuthServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => AuthServiceBase$messageJson;
}

abstract class KeyServiceBase extends $pb.GeneratedService {
  $async.Future<$1.Empty> uploadKeyBundle($pb.ServerContext ctx, $1.KeyBundleUploadRequest request);
  $async.Future<$1.KeyBundle> getKeyBundle($pb.ServerContext ctx, $1.GetKeyBundleRequest request);
  $async.Future<$1.Empty> refillOneTimePrekeys($pb.ServerContext ctx, $1.RefillOneTimePrekeysRequest request);
  $async.Future<$1.GetPreKeyCountResponse> getPreKeyCount($pb.ServerContext ctx, $1.Empty request);
  $async.Future<$1.ListRecipientKeyDevicesResponse> listRecipientKeyDevices($pb.ServerContext ctx, $1.ListRecipientKeyDevicesRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'UploadKeyBundle': return $1.KeyBundleUploadRequest();
      case 'GetKeyBundle': return $1.GetKeyBundleRequest();
      case 'RefillOneTimePrekeys': return $1.RefillOneTimePrekeysRequest();
      case 'GetPreKeyCount': return $1.Empty();
      case 'ListRecipientKeyDevices': return $1.ListRecipientKeyDevicesRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'UploadKeyBundle': return this.uploadKeyBundle(ctx, request as $1.KeyBundleUploadRequest);
      case 'GetKeyBundle': return this.getKeyBundle(ctx, request as $1.GetKeyBundleRequest);
      case 'RefillOneTimePrekeys': return this.refillOneTimePrekeys(ctx, request as $1.RefillOneTimePrekeysRequest);
      case 'GetPreKeyCount': return this.getPreKeyCount(ctx, request as $1.Empty);
      case 'ListRecipientKeyDevices': return this.listRecipientKeyDevices(ctx, request as $1.ListRecipientKeyDevicesRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => KeyServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => KeyServiceBase$messageJson;
}

abstract class MessagingServiceBase extends $pb.GeneratedService {
  $async.Future<$1.ChatStreamResponse> chatStream($pb.ServerContext ctx, $1.ChatStreamRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'ChatStream': return $1.ChatStreamRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'ChatStream': return this.chatStream(ctx, request as $1.ChatStreamRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => MessagingServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => MessagingServiceBase$messageJson;
}

abstract class PresenceServiceBase extends $pb.GeneratedService {
  $async.Future<$1.PresenceServerEvent> realtime($pb.ServerContext ctx, $1.PresenceClientEvent request);
  $async.Future<$1.Empty> updatePresence($pb.ServerContext ctx, $1.PresenceUpdate request);
  $async.Future<$1.PresenceUpdate> streamPresence($pb.ServerContext ctx, $1.Empty request);
  $async.Future<$1.Empty> sendTypingIndicator($pb.ServerContext ctx, $1.TypingIndicator request);
  $async.Future<$1.TypingIndicator> streamTyping($pb.ServerContext ctx, $1.Empty request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'Realtime': return $1.PresenceClientEvent();
      case 'UpdatePresence': return $1.PresenceUpdate();
      case 'StreamPresence': return $1.Empty();
      case 'SendTypingIndicator': return $1.TypingIndicator();
      case 'StreamTyping': return $1.Empty();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'Realtime': return this.realtime(ctx, request as $1.PresenceClientEvent);
      case 'UpdatePresence': return this.updatePresence(ctx, request as $1.PresenceUpdate);
      case 'StreamPresence': return this.streamPresence(ctx, request as $1.Empty);
      case 'SendTypingIndicator': return this.sendTypingIndicator(ctx, request as $1.TypingIndicator);
      case 'StreamTyping': return this.streamTyping(ctx, request as $1.Empty);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => PresenceServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => PresenceServiceBase$messageJson;
}

abstract class ContactsServiceBase extends $pb.GeneratedService {
  $async.Future<$1.SearchUsersByUsernameResponse> searchUsersByUsername($pb.ServerContext ctx, $1.SearchUsersByUsernameRequest request);
  $async.Future<$1.Empty> addContact($pb.ServerContext ctx, $1.Empty request);
  $async.Future<$1.Empty> blockUser($pb.ServerContext ctx, $1.Empty request);
  $async.Future<$1.Empty> listContacts($pb.ServerContext ctx, $1.Empty request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'SearchUsersByUsername': return $1.SearchUsersByUsernameRequest();
      case 'AddContact': return $1.Empty();
      case 'BlockUser': return $1.Empty();
      case 'ListContacts': return $1.Empty();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'SearchUsersByUsername': return this.searchUsersByUsername(ctx, request as $1.SearchUsersByUsernameRequest);
      case 'AddContact': return this.addContact(ctx, request as $1.Empty);
      case 'BlockUser': return this.blockUser(ctx, request as $1.Empty);
      case 'ListContacts': return this.listContacts(ctx, request as $1.Empty);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => ContactsServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => ContactsServiceBase$messageJson;
}

abstract class GroupServiceBase extends $pb.GeneratedService {
  $async.Future<$1.CreateGroupResponse> createGroup($pb.ServerContext ctx, $1.CreateGroupRequest request);
  $async.Future<$1.UpdateGroupChannelResponse> updateGroup($pb.ServerContext ctx, $1.UpdateGroupChannelRequest request);
  $async.Future<$1.ListMyGroupsResponse> listMyGroups($pb.ServerContext ctx, $1.Empty request);
  $async.Future<$1.SearchPublicGroupsResponse> searchPublicGroups($pb.ServerContext ctx, $1.SearchPublicGroupsRequest request);
  $async.Future<$1.JoinPublicGroupResponse> joinPublicGroup($pb.ServerContext ctx, $1.JoinPublicGroupRequest request);
  $async.Future<$1.ListGroupChannelMembersResponse> listMembers($pb.ServerContext ctx, $1.Empty request);
  $async.Future<$1.ListGroupChannelMembersPageResponse> listMembersPage($pb.ServerContext ctx, $1.ListGroupChannelMembersPageRequest request);
  $async.Future<$1.GetGroupOnlineMemberCountResponse> getOnlineMemberCount($pb.ServerContext ctx, $1.GetGroupOnlineMemberCountRequest request);
  $async.Future<$1.Empty> addMember($pb.ServerContext ctx, $1.Empty request);
  $async.Future<$1.Empty> removeMember($pb.ServerContext ctx, $1.Empty request);
  $async.Future<$1.Empty> banUser($pb.ServerContext ctx, $1.Empty request);
  $async.Future<$1.Empty> updateMemberRole($pb.ServerContext ctx, $1.Empty request);
  $async.Future<$1.UpdateGroupChannelSendPermissionResponse> updateGroupSendPermission($pb.ServerContext ctx, $1.UpdateGroupChannelSendPermissionRequest request);
  $async.Future<$1.GroupChannel> updateGroupPermissions($pb.ServerContext ctx, $1.UpdateGroupChannelPermissionsRequest request);
  $async.Future<$1.GetGroupChannelResponse> getGroupChannel($pb.ServerContext ctx, $1.GetGroupChannelRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'CreateGroup': return $1.CreateGroupRequest();
      case 'UpdateGroup': return $1.UpdateGroupChannelRequest();
      case 'ListMyGroups': return $1.Empty();
      case 'SearchPublicGroups': return $1.SearchPublicGroupsRequest();
      case 'JoinPublicGroup': return $1.JoinPublicGroupRequest();
      case 'ListMembers': return $1.Empty();
      case 'ListMembersPage': return $1.ListGroupChannelMembersPageRequest();
      case 'GetOnlineMemberCount': return $1.GetGroupOnlineMemberCountRequest();
      case 'AddMember': return $1.Empty();
      case 'RemoveMember': return $1.Empty();
      case 'BanUser': return $1.Empty();
      case 'UpdateMemberRole': return $1.Empty();
      case 'UpdateGroupSendPermission': return $1.UpdateGroupChannelSendPermissionRequest();
      case 'UpdateGroupPermissions': return $1.UpdateGroupChannelPermissionsRequest();
      case 'GetGroupChannel': return $1.GetGroupChannelRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'CreateGroup': return this.createGroup(ctx, request as $1.CreateGroupRequest);
      case 'UpdateGroup': return this.updateGroup(ctx, request as $1.UpdateGroupChannelRequest);
      case 'ListMyGroups': return this.listMyGroups(ctx, request as $1.Empty);
      case 'SearchPublicGroups': return this.searchPublicGroups(ctx, request as $1.SearchPublicGroupsRequest);
      case 'JoinPublicGroup': return this.joinPublicGroup(ctx, request as $1.JoinPublicGroupRequest);
      case 'ListMembers': return this.listMembers(ctx, request as $1.Empty);
      case 'ListMembersPage': return this.listMembersPage(ctx, request as $1.ListGroupChannelMembersPageRequest);
      case 'GetOnlineMemberCount': return this.getOnlineMemberCount(ctx, request as $1.GetGroupOnlineMemberCountRequest);
      case 'AddMember': return this.addMember(ctx, request as $1.Empty);
      case 'RemoveMember': return this.removeMember(ctx, request as $1.Empty);
      case 'BanUser': return this.banUser(ctx, request as $1.Empty);
      case 'UpdateMemberRole': return this.updateMemberRole(ctx, request as $1.Empty);
      case 'UpdateGroupSendPermission': return this.updateGroupSendPermission(ctx, request as $1.UpdateGroupChannelSendPermissionRequest);
      case 'UpdateGroupPermissions': return this.updateGroupPermissions(ctx, request as $1.UpdateGroupChannelPermissionsRequest);
      case 'GetGroupChannel': return this.getGroupChannel(ctx, request as $1.GetGroupChannelRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => GroupServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => GroupServiceBase$messageJson;
}

abstract class ChannelServiceBase extends $pb.GeneratedService {
  $async.Future<$1.CreateChannelResponse> createChannel($pb.ServerContext ctx, $1.CreateChannelRequest request);
  $async.Future<$1.UpdateGroupChannelResponse> updateChannel($pb.ServerContext ctx, $1.UpdateGroupChannelRequest request);
  $async.Future<$1.ListMyChannelsResponse> listMyChannels($pb.ServerContext ctx, $1.Empty request);
  $async.Future<$1.SearchPublicChannelsResponse> searchPublicChannels($pb.ServerContext ctx, $1.SearchPublicChannelsRequest request);
  $async.Future<$1.JoinPublicChannelResponse> joinPublicChannel($pb.ServerContext ctx, $1.JoinPublicChannelRequest request);
  $async.Future<$1.Empty> subscribe($pb.ServerContext ctx, $1.Empty request);
  $async.Future<$1.Empty> banUser($pb.ServerContext ctx, $1.Empty request);
  $async.Future<$1.UpdateGroupChannelSendPermissionResponse> updateChannelSendPermission($pb.ServerContext ctx, $1.UpdateGroupChannelSendPermissionRequest request);
  $async.Future<$1.GroupChannel> updateChannelPermissions($pb.ServerContext ctx, $1.UpdateGroupChannelPermissionsRequest request);
  $async.Future<$1.GetGroupChannelResponse> getGroupChannel($pb.ServerContext ctx, $1.GetGroupChannelRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'CreateChannel': return $1.CreateChannelRequest();
      case 'UpdateChannel': return $1.UpdateGroupChannelRequest();
      case 'ListMyChannels': return $1.Empty();
      case 'SearchPublicChannels': return $1.SearchPublicChannelsRequest();
      case 'JoinPublicChannel': return $1.JoinPublicChannelRequest();
      case 'Subscribe': return $1.Empty();
      case 'BanUser': return $1.Empty();
      case 'UpdateChannelSendPermission': return $1.UpdateGroupChannelSendPermissionRequest();
      case 'UpdateChannelPermissions': return $1.UpdateGroupChannelPermissionsRequest();
      case 'GetGroupChannel': return $1.GetGroupChannelRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'CreateChannel': return this.createChannel(ctx, request as $1.CreateChannelRequest);
      case 'UpdateChannel': return this.updateChannel(ctx, request as $1.UpdateGroupChannelRequest);
      case 'ListMyChannels': return this.listMyChannels(ctx, request as $1.Empty);
      case 'SearchPublicChannels': return this.searchPublicChannels(ctx, request as $1.SearchPublicChannelsRequest);
      case 'JoinPublicChannel': return this.joinPublicChannel(ctx, request as $1.JoinPublicChannelRequest);
      case 'Subscribe': return this.subscribe(ctx, request as $1.Empty);
      case 'BanUser': return this.banUser(ctx, request as $1.Empty);
      case 'UpdateChannelSendPermission': return this.updateChannelSendPermission(ctx, request as $1.UpdateGroupChannelSendPermissionRequest);
      case 'UpdateChannelPermissions': return this.updateChannelPermissions(ctx, request as $1.UpdateGroupChannelPermissionsRequest);
      case 'GetGroupChannel': return this.getGroupChannel(ctx, request as $1.GetGroupChannelRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => ChannelServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => ChannelServiceBase$messageJson;
}

abstract class ProfileServiceBase extends $pb.GeneratedService {
  $async.Future<$1.ProfileResponse> updateProfile($pb.ServerContext ctx, $1.UpdateProfileRequest request);
  $async.Future<$1.ProfileResponse> getProfile($pb.ServerContext ctx, $1.GetProfileRequest request);
  $async.Future<$1.ProfileResponse> updatePrivacySetting($pb.ServerContext ctx, $1.UpdatePrivacySettingRequest request);
  $async.Future<$1.ProfileChange> streamProfileChanges($pb.ServerContext ctx, $1.Empty request);
  $async.Future<$1.ProfileChange> streamRecipientProfileChanges($pb.ServerContext ctx, $1.ProfileWatchRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'UpdateProfile': return $1.UpdateProfileRequest();
      case 'GetProfile': return $1.GetProfileRequest();
      case 'UpdatePrivacySetting': return $1.UpdatePrivacySettingRequest();
      case 'StreamProfileChanges': return $1.Empty();
      case 'StreamRecipientProfileChanges': return $1.ProfileWatchRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'UpdateProfile': return this.updateProfile(ctx, request as $1.UpdateProfileRequest);
      case 'GetProfile': return this.getProfile(ctx, request as $1.GetProfileRequest);
      case 'UpdatePrivacySetting': return this.updatePrivacySetting(ctx, request as $1.UpdatePrivacySettingRequest);
      case 'StreamProfileChanges': return this.streamProfileChanges(ctx, request as $1.Empty);
      case 'StreamRecipientProfileChanges': return this.streamRecipientProfileChanges(ctx, request as $1.ProfileWatchRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => ProfileServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => ProfileServiceBase$messageJson;
}

abstract class MembershipServiceBase extends $pb.GeneratedService {
  $async.Future<$1.MembershipChange> streamMembershipChanges($pb.ServerContext ctx, $1.Empty request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'StreamMembershipChanges': return $1.Empty();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'StreamMembershipChanges': return this.streamMembershipChanges(ctx, request as $1.Empty);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => MembershipServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => MembershipServiceBase$messageJson;
}

