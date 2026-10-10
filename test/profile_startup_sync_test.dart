import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:grpc/grpc.dart';
import 'package:tureon/core/network/grpc_client.dart';
import 'package:tureon/core/protocol/recipient.dart';
import 'package:tureon/core/protocol/recipient_type.dart';
import 'package:tureon/core/storage/local_store.dart';
import 'package:tureon/core/storage/message_records.dart';
import 'package:tureon/features/profile/data/profile_repository.dart';
import 'package:tureon/features/profile/data/profile_runtime_coordinator.dart';
import 'package:tureon/generated/proto/tureon.pb.dart' as pb;
import 'package:tureon/generated/proto/tureon.pbgrpc.dart' as services;

void main() {
  for (final failChannels in [false, true]) {
    test(
      'startup requests both snapshots concurrently, channel failure: $failChannels',
      () async {
        final groups = _Groups();
        final channels = _Channels();
        final server = Server.create(services: [groups, channels]);
        await server.serve(address: '127.0.0.1', port: 0);
        addTearDown(server.shutdown);
        final client = GrpcClient(
          host: '127.0.0.1',
          port: server.port!,
          accessToken: 'access',
        );
        addTearDown(client.shutdown);
        final store = LocalStore.inMemory();
        addTearDown(store.close);
        store.saveSession(
          const UserSession(userId: 'account', deviceId: 'device'),
        );
        await store.saveRecipient(
          const Recipient(
            id: 'cached-group',
            type: RecipientType.group,
            name: 'Cached',
            handle: '',
          ),
        );
        final coordinator = ProfileRuntimeCoordinator(
          store: store,
          repository: ProfileRepository(store),
          client: () => client,
          sessionGeneration: () => 0,
        );

        final operation = coordinator.bootstrapGroupsAndChannels();
        final result = failChannels
            ? expectLater(operation, throwsA(isA<GrpcError>()))
            : operation;
        // The group reply is still blocked: sequential requests would never
        // reach the channel service and this assertion would time out.
        await Future.wait([
          groups.started.future,
          channels.started.future,
        ]).timeout(const Duration(seconds: 3));
        expect(store.loadRecipient('cached-group'), isNotNull);
        groups.reply.complete(
          pb.ListMyGroupsResponse(
            groups: [pb.GroupChannel(id: 'new-group', name: 'New')],
          ),
        );
        if (failChannels) {
          channels.reply.completeError(
            GrpcError.unavailable('Temporary failure'),
          );
        } else {
          channels.reply.complete(
            pb.ListMyChannelsResponse(
              channels: [pb.GroupChannel(id: 'new-channel', name: 'Channel')],
            ),
          );
        }
        await result;

        if (failChannels) {
          expect(store.loadRecipient('cached-group'), isNotNull);
          expect(store.loadRecipient('new-group'), isNull);
        } else {
          expect(store.loadRecipient('cached-group'), isNull);
          expect(store.loadRecipient('new-group')?.type, RecipientType.group);
          expect(
            store.loadRecipient('new-channel')?.type,
            RecipientType.channel,
          );
        }
      },
    );
  }
}

class _Groups extends services.GroupServiceBase {
  final started = Completer<void>();
  final reply = Completer<pb.ListMyGroupsResponse>();

  @override
  Future<pb.ListMyGroupsResponse> listMyGroups(
    ServiceCall call,
    pb.Empty request,
  ) {
    started.complete();
    return reply.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _Channels extends services.ChannelServiceBase {
  final started = Completer<void>();
  final reply = Completer<pb.ListMyChannelsResponse>();

  @override
  Future<pb.ListMyChannelsResponse> listMyChannels(
    ServiceCall call,
    pb.Empty request,
  ) {
    started.complete();
    return reply.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}
