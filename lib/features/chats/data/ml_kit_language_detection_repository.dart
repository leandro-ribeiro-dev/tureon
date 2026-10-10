import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';

import '../domain/language_detection_repository.dart';
import 'on_device_translation_support.dart';

class MlKitLanguageDetectionRepository implements MessageLanguageDetector {
  @override
  Future<String> identifyLanguage(String text) async {
    if (!supportsOnDeviceTranslation) {
      throw UnsupportedError(
        'On-device language detection is supported only on Android and iOS.',
      );
    }
    final identifier = LanguageIdentifier(confidenceThreshold: 0.5);
    try {
      return await identifier.identifyLanguage(text);
    } finally {
      await identifier.close();
    }
  }
}
