import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cryptography/cryptography.dart';

import 'google_auth_data_source.dart';

typedef LinuxGoogleBrowserLauncher = Future<void> Function(Uri uri);

class LinuxGoogleAuthDataSource implements GoogleAuthDataSource {
  LinuxGoogleAuthDataSource({
    required this.clientId,
    this.clientSecret = '',
    Random? random,
    LinuxGoogleBrowserLauncher? launchBrowser,
    Uri? tokenEndpoint,
  }) : _random = random ?? Random.secure(),
       _launchBrowser = launchBrowser ?? _launchSystemBrowser,
       _tokenEndpoint = tokenEndpoint ?? Uri.parse(_tokenEndpointUrl);

  static const _authorizationEndpoint =
      'https://accounts.google.com/o/oauth2/v2/auth';
  static const _tokenEndpointUrl = 'https://oauth2.googleapis.com/token';
  static const _authorizationTimeout = Duration(minutes: 3);
  static const _tokenTimeout = Duration(seconds: 20);
  static const _maxTokenResponseBytes = 64 * 1024;

  final String clientId;
  final String clientSecret;
  final Random _random;
  final LinuxGoogleBrowserLauncher _launchBrowser;
  final Uri _tokenEndpoint;

  @override
  Future<void> initialize() async {}

  @override
  Future<String?> authenticate() async {
    if (clientId.isEmpty) {
      throw StateError('The Linux Google OAuth client ID is not configured.');
    }
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final redirectUri = Uri(
      scheme: 'http',
      host: InternetAddress.loopbackIPv4.address,
      port: server.port,
    );
    final state = _createRandomValue(32);
    final nonce = _createRandomValue(32);
    final codeVerifier = _createRandomValue(64);
    final codeChallenge = _base64UrlNoPadding(
      (await Sha256().hash(ascii.encode(codeVerifier))).bytes,
    );
    final callback = Completer<Uri>();
    final subscription = server.listen((request) {
      _handleCallback(request, expectedState: state, callback: callback);
    });

    try {
      final authorizationUri = Uri.parse(_authorizationEndpoint).replace(
        queryParameters: {
          'client_id': clientId,
          'redirect_uri': redirectUri.toString(),
          'response_type': 'code',
          'scope': 'openid email profile',
          'state': state,
          'nonce': nonce,
          'code_challenge': codeChallenge,
          'code_challenge_method': 'S256',
          'prompt': 'select_account',
        },
      );
      await _launchBrowser(authorizationUri);

      final callbackUri = await callback.future.timeout(
        _authorizationTimeout,
        onTimeout: () =>
            throw TimeoutException('Google sign-in was not completed in time.'),
      );
      final query = callbackUri.queryParameters;
      final error = query['error'];
      if (error == 'access_denied') return null;
      if (error != null) {
        throw StateError('Google authorization failed: $error.');
      }
      final code = query['code'];
      if (code == null || code.isEmpty) {
        throw StateError('Google authorization did not return a code.');
      }

      final idToken = await _exchangeCode(
        code: code,
        codeVerifier: codeVerifier,
        redirectUri: redirectUri,
      );
      _validateNonce(idToken, nonce);
      return idToken;
    } finally {
      await subscription.cancel();
      await server.close(force: true);
    }
  }

  @override
  Future<void> signOut() async {}

  static Future<void> _launchSystemBrowser(Uri uri) async {
    await Process.start('xdg-open', [
      uri.toString(),
    ], mode: ProcessStartMode.detached);
  }

  String _createRandomValue(int byteCount) => _base64UrlNoPadding(
    List<int>.generate(byteCount, (_) => _random.nextInt(256)),
  );

  String _base64UrlNoPadding(List<int> bytes) =>
      base64Url.encode(bytes).replaceAll('=', '');

  void _handleCallback(
    HttpRequest request, {
    required String expectedState,
    required Completer<Uri> callback,
  }) {
    final response = request.response;
    if (request.method != 'GET' || request.uri.path != '/') {
      response.statusCode = HttpStatus.notFound;
      unawaited(response.close());
      return;
    }
    if (request.uri.queryParameters['state'] != expectedState) {
      response.statusCode = HttpStatus.badRequest;
      unawaited(response.close());
      return;
    }

    final hasError = request.uri.queryParameters['error']?.isNotEmpty == true;
    final hasCode = request.uri.queryParameters['code']?.isNotEmpty == true;
    final validResponse = hasError || hasCode;
    if (!validResponse) response.statusCode = HttpStatus.badRequest;
    _writeCallbackPage(response, request.uri, validResponse: validResponse);
    unawaited(response.close());
    if (!callback.isCompleted) callback.complete(request.uri);
  }

  void _writeCallbackPage(
    HttpResponse response,
    Uri callbackUri, {
    required bool validResponse,
  }) {
    final error = callbackUri.queryParameters['error'];
    final cancelled = error == 'access_denied';
    final success = validResponse && error == null;
    final status = success
        ? 'AUTORIZAÇÃO RECEBIDA'
        : cancelled
        ? 'ENTRADA CANCELADA'
        : 'NÃO FOI POSSÍVEL CONCLUIR';
    final heading = success
        ? 'Volte ao Tureon'
        : cancelled
        ? 'Nenhuma alteração foi feita'
        : 'Tente novamente pelo Tureon';
    final description = success
        ? 'Sua autorização do Google foi recebida. Retorne ao aplicativo para '
              'concluir a entrada com segurança.'
        : cancelled
        ? 'O acesso não foi autorizado. Você pode voltar ao aplicativo e '
              'iniciar novamente quando quiser.'
        : 'A autorização não foi concluída. Volte ao aplicativo para tentar '
              'entrar novamente.';
    final hint = success
        ? 'Esta aba já pode ser fechada.'
        : 'O Tureon continua aberto no seu computador.';
    final icon = success
        ? '&#10003;'
        : cancelled
        ? '&#8592;'
        : '&#8635;';
    final tone = success
        ? 'success'
        : cancelled
        ? 'cancelled'
        : 'error';

    response.headers
      ..contentType = ContentType('text', 'html', charset: 'utf-8')
      ..set(HttpHeaders.cacheControlHeader, 'no-store')
      ..set(
        'Content-Security-Policy',
        "default-src 'none'; style-src 'unsafe-inline'; base-uri 'none'; form-action 'none'; frame-ancestors 'none'",
      )
      ..set('X-Content-Type-Options', 'nosniff')
      ..set('X-Frame-Options', 'DENY')
      ..set('Referrer-Policy', 'no-referrer');
    response.write('''
<!doctype html>
<html lang="pt-BR">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="color-scheme" content="light dark">
  <title>$heading · Tureon</title>
  <style>
    :root {
      color-scheme: light dark;
      font-family: Inter, ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
    }
    * { box-sizing: border-box; }
    body {
      --tone: #554b67;
      --tone-soft: #f0edf6;
      --accent: #2b8a68;
      --accent-soft: #e2f4ed;
      min-height: 100vh;
      margin: 0;
      padding: 28px;
      display: grid;
      place-items: center;
      color: #211d27;
      background:
        radial-gradient(circle at 12% 8%, #e7ddff 0, transparent 34%),
        radial-gradient(circle at 92% 90%, #d7f5ed 0, transparent 30%),
        #f7f5fa;
    }
    body.cancelled {
      --accent: #9a7b34;
      --accent-soft: #f5efd9;
    }
    body.error {
      --accent: #a34c55;
      --accent-soft: #f7e7e9;
    }
    main {
      width: min(100%, 470px);
      padding: 38px;
      border: 1px solid rgba(77, 64, 96, .12);
      border-radius: 28px;
      background: rgba(255, 255, 255, .88);
      box-shadow: 0 24px 80px rgba(42, 31, 59, .12);
    }
    .brand {
      display: flex;
      align-items: center;
      gap: 11px;
      color: var(--tone);
      font-size: 15px;
      font-weight: 750;
      letter-spacing: .02em;
    }
    .mark {
      width: 34px;
      height: 34px;
      display: grid;
      place-items: center;
      border-radius: 12px;
      color: white;
      background: linear-gradient(145deg, #7762a8, #51476c);
      font-size: 18px;
      font-weight: 800;
    }
    .status {
      display: inline-flex;
      align-items: center;
      gap: 8px;
      margin-top: 38px;
      padding: 8px 12px;
      border-radius: 999px;
      color: var(--tone);
      background: var(--tone-soft);
      font-size: 11px;
      font-weight: 800;
      letter-spacing: .09em;
    }
    .status::before {
      width: 7px;
      height: 7px;
      border-radius: 50%;
      background: var(--accent);
      content: "";
    }
    .icon {
      width: 58px;
      height: 58px;
      display: grid;
      place-items: center;
      margin-top: 24px;
      border-radius: 20px;
      color: var(--accent);
      background: var(--accent-soft);
      font-size: 27px;
      font-weight: 700;
    }
    h1 {
      margin: 22px 0 10px;
      font-size: clamp(25px, 6vw, 32px);
      line-height: 1.15;
      letter-spacing: -.04em;
    }
    p {
      margin: 0;
      color: #625d69;
      font-size: 15px;
      line-height: 1.65;
    }
    .hint {
      display: flex;
      align-items: center;
      gap: 10px;
      margin-top: 27px;
      padding-top: 20px;
      border-top: 1px solid #ece9f0;
      color: #625d69;
      font-size: 13px;
    }
    .hint span:first-child {
      width: 22px;
      height: 22px;
      display: grid;
      place-items: center;
      border-radius: 50%;
      color: var(--tone);
      background: var(--tone-soft);
      font-size: 12px;
      font-weight: 800;
    }
    @media (prefers-color-scheme: dark) {
      body {
        color: #f2edf8;
        background:
          radial-gradient(circle at 12% 8%, #322a43 0, transparent 34%),
          radial-gradient(circle at 92% 90%, #1d3732 0, transparent 30%),
          #15131a;
      }
      main {
        border-color: rgba(220, 208, 239, .12);
        background: rgba(35, 32, 42, .92);
        box-shadow: 0 24px 80px rgba(0, 0, 0, .3);
      }
      .brand, .hint { color: #d4cde0; }
      p { color: #bdb6c7; }
      .hint { border-color: #413c48; }
    }
    @media (max-width: 520px) {
      body { padding: 18px; }
      main { padding: 28px 24px; border-radius: 24px; }
      .status { margin-top: 30px; }
    }
  </style>
</head>
<body class="$tone">
  <main>
    <div class="brand"><span class="mark">T</span><span>Tureon</span></div>
    <div class="status" role="status" aria-live="polite">$status</div>
    <div class="icon" aria-hidden="true">$icon</div>
    <h1>$heading</h1>
    <p>$description</p>
    <div class="hint"><span aria-hidden="true">i</span><span>$hint</span></div>
  </main>
</body>
</html>
''');
  }

  Future<String> _exchangeCode({
    required String code,
    required String codeVerifier,
    required Uri redirectUri,
  }) async {
    final client = HttpClient()..connectionTimeout = _tokenTimeout;
    try {
      final request = await client
          .postUrl(_tokenEndpoint)
          .timeout(_tokenTimeout);
      // Authorization codes and the PKCE verifier must never be forwarded to
      // another host if the token endpoint responds with a redirect.
      request.followRedirects = false;
      request.headers.contentType = ContentType(
        'application',
        'x-www-form-urlencoded',
        charset: 'utf-8',
      );
      final parameters = <String, String>{
        'client_id': clientId,
        'code': code,
        'code_verifier': codeVerifier,
        'grant_type': 'authorization_code',
        'redirect_uri': redirectUri.toString(),
      };
      if (clientSecret.trim().isNotEmpty) {
        parameters['client_secret'] = clientSecret.trim();
      }
      final body = Uri(queryParameters: parameters).query;
      request.contentLength = utf8.encode(body).length;
      request.headers.set(HttpHeaders.acceptHeader, ContentType.json.mimeType);
      request.write(body);
      final response = await request.close().timeout(_tokenTimeout);
      final responseBytes = await response
          .fold<List<int>>(<int>[], (buffer, chunk) {
            if (buffer.length + chunk.length > _maxTokenResponseBytes) {
              throw const FormatException('OAuth response is too large.');
            }
            return buffer..addAll(chunk);
          })
          .timeout(_tokenTimeout);
      final responseBody = utf8.decode(responseBytes);
      final decoded = jsonDecode(responseBody);
      if (decoded is! Map<String, dynamic>) {
        throw StateError('Google returned an invalid token response.');
      }
      if (response.statusCode != HttpStatus.ok) {
        final error = decoded['error'] as String? ?? 'unknown_error';
        final description = decoded['error_description'] as String? ?? '';
        throw StateError(
          description.isEmpty
              ? 'Google token exchange failed: $error.'
              : 'Google token exchange failed: $error. $description',
        );
      }
      final idToken = decoded['id_token'] as String?;
      if (idToken == null || idToken.isEmpty) {
        throw StateError('Google did not return an OpenID ID token.');
      }
      return idToken;
    } finally {
      client.close(force: true);
    }
  }

  void _validateNonce(String idToken, String expectedNonce) {
    final parts = idToken.split('.');
    if (parts.length != 3) {
      throw StateError('Google returned a malformed ID token.');
    }
    final payload = jsonDecode(
      utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
    );
    if (payload is! Map<String, dynamic> || payload['nonce'] != expectedNonce) {
      throw StateError('Google ID token nonce validation failed.');
    }
  }
}
