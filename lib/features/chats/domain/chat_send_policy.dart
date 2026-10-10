import '../../../core/protocol/recipient.dart';
import '../../../core/protocol/recipient_type.dart';
import 'chat_attachment_action.dart';

enum ChatAttachmentRestriction { none, cannotSend, gifsDisabled, mediaDisabled }

/// Client send preflight; the server remains authoritative for room permissions.
abstract final class ChatSendPolicy {
  static bool isRoomAdmin(Recipient recipient) =>
      recipient.composerRole == 'owner' || recipient.composerRole == 'admin';
  static final _links = RegExp(
    r'(https?://|www\.)\S+|(?:^|[\s(])(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\.)+[a-z]{2,}(?:/[^\s]*)?',
    caseSensitive: false,
  );
  static bool containsLink(String text) => _links.hasMatch(text);
  static ChatAttachmentRestriction attachmentRestriction(
    Recipient recipient,
    ChatAttachmentAction action, {
    required bool isSecret,
  }) {
    if (isSecret ||
        (recipient.type != RecipientType.group &&
            recipient.type != RecipientType.channel) ||
        isRoomAdmin(recipient)) {
      return ChatAttachmentRestriction.none;
    }
    if (!recipient.canSendMessages) return ChatAttachmentRestriction.cannotSend;
    if (action == ChatAttachmentAction.gif &&
        recipient.type == RecipientType.group &&
        !recipient.membersCanSendStickersGifs) {
      return ChatAttachmentRestriction.gifsDisabled;
    }
    if (recipient.type == RecipientType.group &&
        !recipient.membersCanSendMedia) {
      return ChatAttachmentRestriction.mediaDisabled;
    }
    return ChatAttachmentRestriction.none;
  }
}
