/// Abstract contract for message translation.
///
/// Requirement 0.3: Must operate on-device to support E2EE (Secret Chats)
/// without sending plain text messages to an external server.
abstract class TranslationRepository {
  /// Translates [text] to [targetLanguage] (e.g. 'pt', 'en', 'es').
  Future<String> translate(
    String text, {
    required String targetLanguage,
    String? sourceLanguage,
  });
}
