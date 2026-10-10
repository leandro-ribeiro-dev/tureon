import '../../../../core/protocol/recipient.dart';
import '../../../../core/protocol/recipient_type.dart';
import '../../../../core/providers/settings_providers.dart' show ChatFilterTab;

/// One predicate powers visible rows and unread totals, preventing filter drift.
abstract final class ChatConversationFilters {
  static bool Function(Recipient) _predicate(
    ChatFilterTab tab,
    bool Function(Recipient) isPinned,
  ) {
    final ids = tab.customRecipientIds.toSet();
    final label = tab.label.toLowerCase();
    return switch (tab.filterType) {
      'favorites' => isPinned,
      'unread' => (r) => r.unreadCount > 0,
      'groups' => (r) => r.type == RecipientType.group,
      'channels' => (r) => r.type == RecipientType.channel,
      'contacts' => (r) => r.type == RecipientType.user,
      'all' => (_) => true,
      _ => (r) => ids.contains(r.id) || r.name.toLowerCase().contains(label),
    };
  }

  static List<Recipient> matching(
    ChatFilterTab tab,
    List<Recipient> rows,
    bool Function(Recipient) isPinned,
  ) => tab.filterType == 'all'
      ? rows
      : rows.where(_predicate(tab, isPinned)).toList();
  static int unread(
    ChatFilterTab tab,
    List<Recipient> rows,
    bool Function(Recipient) isPinned,
  ) => rows
      .where(_predicate(tab, isPinned))
      .fold(0, (sum, r) => sum + r.unreadCount);
}
