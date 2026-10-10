import 'package:flutter_test/flutter_test.dart';
import 'package:tureon/features/auth/data/device_metadata.dart';

void main() {
  test('device display label includes cleaned model and operating system', () {
    expect(
      DeviceMetadata.formatName(
        '  Google   Pixel 9 ',
        'Android',
        ' 16 ',
        'Android device',
      ),
      'Google Pixel 9 · Android 16',
    );
  });

  test('device display label has a useful fallback without model/version', () {
    expect(
      DeviceMetadata.formatName('', 'iOS', null, 'iOS device'),
      'iOS device · iOS',
    );
  });
}
