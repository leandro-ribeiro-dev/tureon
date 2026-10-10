/// A device-local translation. The original message remains unchanged and is
/// still used for delivery and synchronization.
class MessageTranslation {
  const MessageTranslation({
    required this.messageId,
    required this.sourceText,
    required this.targetLanguage,
    required this.sourceLanguage,
    required this.translatedText,
    required this.updatedAt,
  });

  final String messageId;

  /// The source text this result was produced from, read from the message row.
  /// It is not duplicated in the translations table.
  final String sourceText;
  final String targetLanguage;
  final String sourceLanguage;
  final String translatedText;
  final DateTime updatedAt;
}
