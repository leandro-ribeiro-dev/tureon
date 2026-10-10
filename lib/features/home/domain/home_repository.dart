import '../../../core/protocol/recipient.dart';

abstract interface class HomeRepository {
  Stream<List<Recipient>> watchRecipients();

  Stream<Recipient?> watchRecipient(String recipientId);

  Set<String> loadPinnedConversationIds();

  Set<String> loadArchivedConversationIds();

  void savePinnedConversationIds(Set<String> recipientIds);

  void saveArchivedConversationIds(Set<String> recipientIds);

  Future<void> saveRecipient(Recipient recipient);

  void deleteRecipient(String recipientId);
}

abstract interface class AccountScopedHomeRepository {
  String? get activeAccountId;
}

/// Supplies the local snapshot while the reactive subscription is starting.
abstract interface class CachedHomeRepository {
  List<Recipient> loadRecipients();
}
