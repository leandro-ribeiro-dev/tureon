import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'google_client_id_config.dart';
import 'linux_google_auth_data_source.dart';

abstract interface class GoogleAuthDataSource {
  Future<void> initialize();

  Future<String?> authenticate();

  Future<void> signOut();

  /// Platform factory selecting the optimal Google Auth Implementation:
  /// - Android/iOS/Web: Native Google Sign-In SDK (`GoogleSignInDataSource`)
  /// - Linux/macOS/Windows: Loopback OAuth 2.0 PKCE (`LinuxGoogleAuthDataSource`)
  static GoogleAuthDataSource create({
    required String serverClientId,
    String? iosClientId,
    String? desktopClientId,
    String? desktopClientSecret,
  }) {
    if (kIsWeb) {
      return GoogleSignInDataSource(
        serverClientId: serverClientId,
        clientId: serverClientId,
      );
    }

    return switch (defaultTargetPlatform) {
      TargetPlatform.linux ||
      TargetPlatform.macOS ||
      TargetPlatform.windows => LinuxGoogleAuthDataSource(
        clientId: resolveLinuxDesktopClientId(desktopClientId ?? ''),
        clientSecret: desktopClientSecret?.trim() ?? '',
      ),
      TargetPlatform.iOS => GoogleSignInDataSource(
        serverClientId: serverClientId,
        clientId: iosClientId,
      ),
      _ => GoogleSignInDataSource(serverClientId: serverClientId),
    };
  }
}

class GoogleSignInDataSource implements GoogleAuthDataSource {
  GoogleSignInDataSource({
    required this.serverClientId,
    this.clientId,
    GoogleSignIn? googleSignIn,
  }) : _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  final String serverClientId;
  final String? clientId;
  final GoogleSignIn _googleSignIn;
  Future<void>? _initialization;
  static Future<void>? _singletonInitialization;
  static String? _singletonConfiguration;

  @override
  Future<void> initialize() {
    final normalizedServerClientId = serverClientId.trim();
    final normalizedClientId = clientId?.trim() ?? '';
    final configuration = '$normalizedClientId/$normalizedServerClientId';
    Future<void> initializeGoogle() => _googleSignIn.initialize(
      serverClientId: normalizedServerClientId.isEmpty
          ? null
          : normalizedServerClientId,
      clientId: normalizedClientId.isEmpty ? null : normalizedClientId,
    );

    if (identical(_googleSignIn, GoogleSignIn.instance)) {
      final previousConfiguration = _singletonConfiguration;
      if (previousConfiguration != null &&
          previousConfiguration != configuration) {
        return Future<void>.error(
          StateError(
            'Google Sign-In was initialized with different client IDs.',
          ),
        );
      }
      _singletonConfiguration ??= configuration;
      final current = _singletonInitialization;
      if (current != null) return current;
      final pending = initializeGoogle();
      _singletonInitialization = pending;
      return pending.catchError((Object error, StackTrace stackTrace) {
        if (identical(_singletonInitialization, pending)) {
          _singletonInitialization = null;
          _singletonConfiguration = null;
        }
        Error.throwWithStackTrace(error, stackTrace);
      });
    }
    final current = _initialization;
    if (current != null) return current;
    final pending = initializeGoogle();
    _initialization = pending;
    return pending.catchError((Object error, StackTrace stackTrace) {
      if (identical(_initialization, pending)) _initialization = null;
      Error.throwWithStackTrace(error, stackTrace);
    });
  }

  @override
  Future<String?> authenticate() async {
    await initialize();
    if (!_googleSignIn.supportsAuthenticate()) {
      throw UnsupportedError('Google authentication is not supported here.');
    }
    try {
      final account = await _googleSignIn.authenticate();
      final token = account.authentication.idToken;
      if (token == null || token.isEmpty) {
        throw StateError('Google Sign-In did not return an ID token.');
      }
      return token;
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) return null;
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    await initialize();
    await _googleSignIn.signOut();
  }
}
