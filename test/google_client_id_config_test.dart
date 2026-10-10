import 'package:flutter_test/flutter_test.dart';
import 'package:tureon/features/auth/data/google_client_id_config.dart';

const _compileTimeClientId = String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');

void main() {
  test('uses the configured web client ID by default', () {
    expect(resolveServerClientId(''), googleWebClientId);
  });

  test('uses GOOGLE_SERVER_CLIENT_ID when configured', () {
    expect(
      resolveServerClientId('fork-web-client.apps.googleusercontent.com'),
      'fork-web-client.apps.googleusercontent.com',
    );
  });

  test('uses the configured desktop client ID by default', () {
    expect(resolveLinuxDesktopClientId(''), googleDesktopClientId);
  });

  test('uses the configured desktop client ID', () {
    expect(
      resolveLinuxDesktopClientId(
        'custom-desktop-client.apps.googleusercontent.com',
      ),
      'custom-desktop-client.apps.googleusercontent.com',
    );
  });

  test(
    'uses the value compiled from GOOGLE_SERVER_CLIENT_ID when supplied',
    () {
      expect(
        resolveServerClientId(_compileTimeClientId),
        _compileTimeClientId.isEmpty ? googleWebClientId : _compileTimeClientId,
      );
    },
  );
}
