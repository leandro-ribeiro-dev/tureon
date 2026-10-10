import 'chat_message.dart';

/// Sealed hierarchy for message list display items (Date Dividers & Messages).
sealed class MessageListItem {
  const MessageListItem();
}

/// Item representing a calendar date divider pill (e.g. "Hoje", "Ontem", "10/09").
class DateDividerItem extends MessageListItem {
  const DateDividerItem(this.date);
  final DateTime date;
}

/// Item representing a chat message (user bubble or system message).
class ChatMessageItem extends MessageListItem {
  const ChatMessageItem(this.message);
  final ChatMessage message;
}

/// Utility for grouping chat messages chronologically and inserting date dividers.
abstract final class MessageDateGrouper {
  static List<MessageListItem> groupMessagesWithDates(
    List<ChatMessage> messages,
  ) {
    if (messages.isEmpty) return const [];

    final orderedMessages = List<ChatMessage>.of(messages)
      ..sort((first, second) {
        final timestampOrder = first.createdAt.compareTo(second.createdAt);
        return timestampOrder != 0
            ? timestampOrder
            : first.messageId.compareTo(second.messageId);
      });
    final List<MessageListItem> result = [];
    DateTime? lastDate;

    for (final msg in orderedMessages) {
      final msgDate = DateTime(
        msg.createdAt.year,
        msg.createdAt.month,
        msg.createdAt.day,
      );

      if (lastDate == null || !_isSameDay(lastDate, msgDate)) {
        result.add(DateDividerItem(msgDate));
        lastDate = msgDate;
      }

      result.add(ChatMessageItem(msg));
    }

    return result;
  }

  static bool _isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }
}
