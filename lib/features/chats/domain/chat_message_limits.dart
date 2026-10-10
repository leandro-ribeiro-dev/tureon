abstract final class ChatMessageLimits {
  static const maxTextLength = 4096;
  static const outboxRetention = Duration(days: 45);
}
