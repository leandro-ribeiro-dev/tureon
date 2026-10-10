import '../../../../core/protocol/protocol_models.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/chat_message.dart' as chat_domain;

/// UI-only text, receipt and language-label mapping; never mutates messages.
abstract final class ChatMessagePresentation {
  static MessageItem toMessageItem(
    chat_domain.ChatMessage message, {
    required String? userId,
    required String senderName,
  }) {
    final isMine = message.senderRecipientId == userId;
    return MessageItem.text(
      id: message.messageId,
      senderName: isMine ? 'Você' : senderName,
      text: message.body,
      timestamp: message.createdAt,
      status: switch (message.status) {
        chat_domain.ChatDeliveryStatus.sent => DeliveryStatus.sent,
        chat_domain.ChatDeliveryStatus.delivered => DeliveryStatus.delivered,
        chat_domain.ChatDeliveryStatus.read => DeliveryStatus.read,
        chat_domain.ChatDeliveryStatus.pending => DeliveryStatus.pending,
        chat_domain.ChatDeliveryStatus.sending => DeliveryStatus.sending,
        chat_domain.ChatDeliveryStatus.failed => DeliveryStatus.failed,
        chat_domain.ChatDeliveryStatus.unspecified =>
          DeliveryStatus.unspecified,
      },
    );
  }

  static String previewText(chat_domain.ChatMessage message) {
    if (message.body.trim().isNotEmpty) return message.body.trim();
    return switch (message.type) {
      chat_domain.ChatMessageType.image => 'Foto',
      chat_domain.ChatMessageType.video => 'Vídeo',
      chat_domain.ChatMessageType.gif => 'GIF',
      chat_domain.ChatMessageType.audio ||
      chat_domain.ChatMessageType.voiceNote => 'Áudio',
      chat_domain.ChatMessageType.file =>
        message.attachment?.fileName ?? 'Arquivo',
      chat_domain.ChatMessageType.location => 'Localização',
      _ => 'Mensagem',
    };
  }

  static String languageName(String code, AppLocalizations l10n) =>
      switch (code) {
        'pt' => l10n.languagePortuguese,
        'en' => l10n.languageEnglish,
        'es' => l10n.languageSpanish,
        'de' => l10n.languageGerman,
        'fr' => l10n.languageFrench,
        'it' => l10n.languageItalian,
        'ja' => l10n.languageJapanese,
        'zh' => l10n.languageChinese,
        'ru' => l10n.languageRussian,
        'ar' => l10n.languageArabic,
        _ => code,
      };
}
