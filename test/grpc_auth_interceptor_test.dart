import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:grpc/grpc.dart';
import 'package:tureon/core/network/grpc_auth_interceptor.dart';

void main() {
  test('authenticated requests include credentials', () async {
    const token = 'test-token';
    final interceptor = GrpcAuthInterceptor(accessToken: () => token);
    final method = ClientMethod<String, String>(
      '/test.Service/Call',
      (_) => const [],
      (_) => '',
    );
    CallOptions? capturedOptions;

    interceptor.interceptUnary<String, String>(method, '', CallOptions(), (
      _,
      _,
      options,
    ) {
      capturedOptions = options;
      final call = ClientCall<String, String>(
        method,
        const Stream<String>.empty(),
        options,
      );
      return ResponseFuture<String>(call);
    });

    expect(capturedOptions!.timeout, const Duration(seconds: 30));
    final metadata = <String, String>{};
    for (final provider in capturedOptions!.metadataProviders) {
      await provider(metadata, '');
    }

    expect(metadata['authorization'], ['Bearer', token].join(' '));
  });

  test('authenticated streaming calls send the bearer access token', () async {
    const token = 'test-stream-token';
    final interceptor = GrpcAuthInterceptor(accessToken: () => token);
    final method = ClientMethod<String, String>(
      '/test.Service/Stream',
      (_) => const [],
      (_) => '',
    );
    CallOptions? capturedOptions;

    interceptor.interceptStreaming<String, String>(
      method,
      const Stream<String>.empty(),
      CallOptions(),
      (_, requests, options) {
        capturedOptions = options;
        return ResponseStream<String>(
          ClientCall<String, String>(method, requests, options),
        );
      },
    );

    final metadata = <String, String>{};
    for (final provider in capturedOptions!.metadataProviders) {
      await provider(metadata, '');
    }

    expect(metadata['authorization'], ['Bearer', token].join(' '));
  });

  test('unary calls preserve an explicit deadline', () {
    final interceptor = GrpcAuthInterceptor(accessToken: () => null);
    final method = ClientMethod<String, String>(
      '/test.Service/Call',
      (_) => const [],
      (_) => '',
    );
    CallOptions? capturedOptions;

    interceptor.interceptUnary<String, String>(
      method,
      '',
      CallOptions(timeout: const Duration(seconds: 5)),
      (_, _, options) {
        capturedOptions = options;
        final call = ClientCall<String, String>(
          method,
          const Stream<String>.empty(),
          options,
        );
        return ResponseFuture<String>(call);
      },
    );

    expect(capturedOptions!.timeout, const Duration(seconds: 5));
  });

  test('unauthenticated calls do not send an authorization header', () async {
    final interceptor = GrpcAuthInterceptor(accessToken: () => null);
    final method = ClientMethod<String, String>(
      '/test.Service/Call',
      (_) => const [],
      (_) => '',
    );
    CallOptions? capturedOptions;

    interceptor.interceptUnary<String, String>(method, '', CallOptions(), (
      _,
      _,
      options,
    ) {
      capturedOptions = options;
      final call = ClientCall<String, String>(
        method,
        const Stream<String>.empty(),
        options,
      );
      return ResponseFuture<String>(call);
    });

    final metadata = <String, String>{};
    for (final provider in capturedOptions!.metadataProviders) {
      await provider(metadata, '');
    }

    expect(metadata.containsKey('authorization'), isFalse);
  });

  test(
    'concurrent unauthenticated calls share one refresh and each retry once',
    () async {
      var token = 'expired';
      var refreshCalls = 0;
      var retries = 0;
      final refreshStarted = Completer<void>();
      final refreshGate = Completer<void>();
      final interceptor = GrpcAuthInterceptor(accessToken: () => token)
        ..onRefresh = (failedToken) async {
          expect(failedToken, 'expired');
          refreshCalls++;
          refreshStarted.complete();
          await refreshGate.future;
          token = 'refreshed';
        };

      final calls = List.generate(
        5,
        (_) => interceptor.retryUnary<int>(
          failedAccessToken: 'expired',
          firstAttempt: () =>
              Future<int>.error(GrpcError.unauthenticated('expired')),
          retryAttempt: () async {
            retries++;
            return 7;
          },
        ),
      );
      await refreshStarted.future;
      expect(refreshCalls, 1);

      refreshGate.complete();
      expect(await Future.wait(calls), everyElement(7));
      expect(retries, 5);
      expect(refreshCalls, 1);
    },
  );

  test(
    'expired refresh credentials log out once and do not retry calls',
    () async {
      var refreshCalls = 0;
      var logoutCalls = 0;
      var retryCalls = 0;
      final interceptor = GrpcAuthInterceptor(accessToken: () => 'expired')
        ..onRefresh = (_) async {
          refreshCalls++;
          throw GrpcError.unauthenticated('refresh rejected');
        }
        ..onRefreshFailure = () async {
          logoutCalls++;
        };

      final calls = List.generate(
        4,
        (_) => interceptor
            .retryUnary<int>(
              failedAccessToken: 'expired',
              firstAttempt: () =>
                  Future<int>.error(GrpcError.unauthenticated('expired')),
              retryAttempt: () async {
                retryCalls++;
                return 0;
              },
            )
            .then<Object?>((value) => value, onError: (Object error) => error),
      );

      final results = await Future.wait(calls);
      expect(results, everyElement(isA<GrpcError>()));
      expect(refreshCalls, 1);
      expect(logoutCalls, 1);
      expect(retryCalls, 0);
    },
  );

  test('transient refresh failures do not expire the local session', () async {
    var logoutCalls = 0;
    final interceptor = GrpcAuthInterceptor(accessToken: () => 'expired')
      ..onRefresh = (_) async {
        throw GrpcError.unavailable('offline');
      }
      ..onRefreshFailure = () async {
        logoutCalls++;
      };

    await expectLater(
      interceptor.retryUnary<int>(
        failedAccessToken: 'expired',
        firstAttempt: () =>
            Future<int>.error(GrpcError.unauthenticated('expired')),
        retryAttempt: () async => 7,
      ),
      throwsA(isA<GrpcError>()),
    );

    expect(logoutCalls, 0);
  });

  test('allows one retry when refresh returns the same access token', () async {
    final interceptor = GrpcAuthInterceptor(accessToken: () => 'same-token')
      ..onRefresh = (_) async {};
    var retries = 0;

    final result = await interceptor.retryUnary<int>(
      failedAccessToken: 'same-token',
      firstAttempt: () => Future<int>.error(
        GrpcError.unauthenticated('first attempt rejected'),
      ),
      retryAttempt: () async {
        retries++;
        return 1;
      },
    );

    expect(result, 1);
    expect(retries, 1);
  });
}
