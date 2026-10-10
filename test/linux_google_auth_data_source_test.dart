import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tureon/features/auth/data/linux_google_auth_data_source.dart';

void main() {
  test(
    'uses loopback, state, nonce, and PKCE without an optional client secret',
    () async {
      final tokenServer = await HttpServer.bind(
        InternetAddress.loopbackIPv4,
        0,
      );
      final tokenRequest = Completer<Map<String, String>>();
      final browserNonce = Completer<String>();
      final browserChallenge = Completer<String>();
      final tokenSubscription = tokenServer.listen((request) {
        unawaited(() async {
          final body = await utf8.decoder.bind(request).join();
          final form = Uri.splitQueryString(body);
          if (!tokenRequest.isCompleted) {
            tokenRequest.complete(form);
          }
          request.response.headers.contentType = ContentType.json;
          request.response.write(
            jsonEncode({'id_token': _idToken(await browserNonce.future)}),
          );
          await request.response.close();
        }());
      });
      addTearDown(() async {
        await tokenSubscription.cancel();
        await tokenServer.close(force: true);
      });

      final repository = LinuxGoogleAuthDataSource(
        clientId: 'desktop-client.apps.googleusercontent.com',
        tokenEndpoint: Uri(
          scheme: 'http',
          host: InternetAddress.loopbackIPv4.address,
          port: tokenServer.port,
          path: '/token',
        ),
        launchBrowser: (authorizationUri) async {
          final authorization = authorizationUri.queryParameters;
          expect(authorizationUri.scheme, 'https');
          expect(authorizationUri.host, 'accounts.google.com');
          expect(
            authorization['client_id'],
            'desktop-client.apps.googleusercontent.com',
          );
          expect(authorization['response_type'], 'code');
          expect(authorization['scope'], 'openid email profile');
          expect(authorization['code_challenge_method'], 'S256');
          expect(authorization['nonce'], isNotEmpty);
          browserNonce.complete(authorization['nonce']!);
          browserChallenge.complete(authorization['code_challenge']!);

          final redirectUri = Uri.parse(authorization['redirect_uri']!);
          expect(redirectUri.host, '127.0.0.1');
          expect(redirectUri.hasPort, isTrue);

          final rejectedStatus = await _requestStatus(
            redirectUri.replace(
              queryParameters: {'state': 'incorrect', 'code': 'ignored'},
            ),
          );
          expect(rejectedStatus, HttpStatus.badRequest);

          final callback = await _requestResponse(
            redirectUri.replace(
              queryParameters: {
                'state': authorization['state']!,
                'code': 'authorization-code',
              },
            ),
          );
          expect(callback.$1, HttpStatus.ok);
          expect(callback.$2, contains('AUTORIZAÇÃO RECEBIDA'));
          expect(callback.$2, contains('Volte ao Tureon'));
          expect(callback.$2, contains('Esta aba já pode ser fechada.'));
          expect(callback.$2, isNot(contains('Você pode fechar esta página')));
        },
      );

      final idToken = await repository.authenticate();
      expect(idToken, isNotEmpty);

      final exchange = await tokenRequest.future;
      expect(
        exchange['client_id'],
        'desktop-client.apps.googleusercontent.com',
      );
      expect(exchange.containsKey('client_secret'), isFalse);
      expect(exchange['code'], 'authorization-code');
      expect(exchange['grant_type'], 'authorization_code');
      expect(exchange['redirect_uri'], startsWith('http://127.0.0.1:'));
      expect(exchange['code_verifier']!.length, inInclusiveRange(43, 128));

      final authorizationChallenge = await browserChallenge.future;
      final digest = await Sha256().hash(
        ascii.encode(exchange['code_verifier']!),
      );
      expect(
        authorizationChallenge,
        base64Url.encode(digest.bytes).replaceAll('=', ''),
      );
    },
  );

  test(
    'includes the configured desktop client secret in token exchange',
    () async {
      final tokenServer = await HttpServer.bind(
        InternetAddress.loopbackIPv4,
        0,
      );
      final tokenRequest = Completer<Map<String, String>>();
      final authorizationNonce = Completer<String>();
      final tokenSubscription = tokenServer.listen((request) {
        unawaited(() async {
          final body = await utf8.decoder.bind(request).join();
          tokenRequest.complete(Uri.splitQueryString(body));
          request.response.headers.contentType = ContentType.json;
          request.response.write(
            jsonEncode({'id_token': _idToken(await authorizationNonce.future)}),
          );
          await request.response.close();
        }());
      });
      addTearDown(() async {
        await tokenSubscription.cancel();
        await tokenServer.close(force: true);
      });

      final repository = LinuxGoogleAuthDataSource(
        clientId: 'desktop-client.apps.googleusercontent.com',
        clientSecret: 'desktop-client-secret',
        tokenEndpoint: Uri(
          scheme: 'http',
          host: InternetAddress.loopbackIPv4.address,
          port: tokenServer.port,
          path: '/token',
        ),
        launchBrowser: (authorizationUri) async {
          final authorization = authorizationUri.queryParameters;
          authorizationNonce.complete(authorization['nonce']!);
          final redirectUri = Uri.parse(authorization['redirect_uri']!);
          await _requestStatus(
            redirectUri.replace(
              queryParameters: {
                'state': authorization['state']!,
                'code': 'authorization-code',
              },
            ),
          );
        },
      );

      await repository.authenticate();

      final exchange = await tokenRequest.future;
      expect(exchange['client_secret'], 'desktop-client-secret');
      expect(exchange['code_verifier'], isNotEmpty);
    },
  );

  test(
    'shows a clear browser page when the user cancels Google sign-in',
    () async {
      late String callbackPage;
      final repository = LinuxGoogleAuthDataSource(
        clientId: 'desktop-client.apps.googleusercontent.com',
        launchBrowser: (authorizationUri) async {
          final authorization = authorizationUri.queryParameters;
          final callback = await _requestResponse(
            Uri.parse(authorization['redirect_uri']!).replace(
              queryParameters: {
                'state': authorization['state']!,
                'error': 'access_denied',
              },
            ),
          );
          expect(callback.$1, HttpStatus.ok);
          callbackPage = callback.$2;
        },
      );

      expect(await repository.authenticate(), isNull);
      expect(callbackPage, contains('ENTRADA CANCELADA'));
      expect(callbackPage, contains('Nenhuma alteração foi feita'));
    },
  );

  test('surfaces Google error descriptions from the token endpoint', () async {
    final tokenServer = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final tokenSubscription = tokenServer.listen((request) {
      unawaited(() async {
        await utf8.decoder.bind(request).join();
        request.response.statusCode = HttpStatus.badRequest;
        request.response.headers.contentType = ContentType.json;
        request.response.write(
          jsonEncode({
            'error': 'invalid_request',
            'error_description': 'The desktop client needs configuration.',
          }),
        );
        await request.response.close();
      }());
    });
    addTearDown(() async {
      await tokenSubscription.cancel();
      await tokenServer.close(force: true);
    });

    final repository = LinuxGoogleAuthDataSource(
      clientId: 'desktop-client.apps.googleusercontent.com',
      tokenEndpoint: Uri(
        scheme: 'http',
        host: InternetAddress.loopbackIPv4.address,
        port: tokenServer.port,
        path: '/token',
      ),
      launchBrowser: (authorizationUri) async {
        final authorization = authorizationUri.queryParameters;
        final redirectUri = Uri.parse(authorization['redirect_uri']!);
        await _requestStatus(
          redirectUri.replace(
            queryParameters: {
              'state': authorization['state']!,
              'code': 'authorization-code',
            },
          ),
        );
      },
    );

    await expectLater(
      repository.authenticate(),
      throwsA(
        isA<StateError>().having(
          (error) => error.message.toString(),
          'message',
          contains('The desktop client needs configuration.'),
        ),
      ),
    );
  });

  test('rejects oversized token endpoint responses', () async {
    final tokenServer = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final tokenSubscription = tokenServer.listen((request) {
      unawaited(() async {
        await utf8.decoder.bind(request).join();
        request.response.headers.contentType = ContentType.json;
        request.response.write(' ' * (64 * 1024 + 1));
        await request.response.close();
      }());
    });
    addTearDown(() async {
      await tokenSubscription.cancel();
      await tokenServer.close(force: true);
    });

    final repository = LinuxGoogleAuthDataSource(
      clientId: 'desktop-client.apps.googleusercontent.com',
      tokenEndpoint: Uri(
        scheme: 'http',
        host: InternetAddress.loopbackIPv4.address,
        port: tokenServer.port,
        path: '/token',
      ),
      launchBrowser: (authorizationUri) async {
        final authorization = authorizationUri.queryParameters;
        final redirectUri = Uri.parse(authorization['redirect_uri']!);
        await _requestStatus(
          redirectUri.replace(
            queryParameters: {
              'state': authorization['state']!,
              'code': 'authorization-code',
            },
          ),
        );
      },
    );

    await expectLater(repository.authenticate(), throwsFormatException);
  });
}

String _idToken(String nonce) {
  final claims = base64Url
      .encode(utf8.encode(jsonEncode({'nonce': nonce})))
      .replaceAll('=', '');
  return 'e30.$claims.signature';
}

Future<int> _requestStatus(Uri uri) async {
  return (await _requestResponse(uri)).$1;
}

Future<(int, String)> _requestResponse(Uri uri) async {
  final client = HttpClient();
  try {
    final request = await client.getUrl(uri);
    final response = await request.close();
    final body = await utf8.decoder.bind(response).join();
    return (response.statusCode, body);
  } finally {
    client.close(force: true);
  }
}
