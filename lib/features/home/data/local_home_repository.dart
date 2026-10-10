import 'dart:async';

import '../../../core/protocol/recipient.dart';
import '../../../core/storage/local_store.dart';
import '../domain/home_repository.dart';

class LocalHomeRepository
    implements
        HomeRepository,
        AccountScopedHomeRepository,
        CachedHomeRepository {
  LocalHomeRepository(this._store);

  final LocalStore _store;

  @override
  String? get activeAccountId => _store.loadSession()?.userId;

  @override
  List<Recipient> loadRecipients() => _store.loadRecipients();

  @override
  Stream<List<Recipient>> watchRecipients() => _store.watchRecipients();

  @override
  Stream<Recipient?> watchRecipient(String recipientId) =>
      _store.watchRecipient(recipientId);

  @override
  Set<String> loadPinnedConversationIds() => _loadIds('pinned_conversations');

  @override
  Set<String> loadArchivedConversationIds() =>
      _loadIds('archived_conversations');

  @override
  void savePinnedConversationIds(Set<String> recipientIds) =>
      _saveIds('pinned_conversations', recipientIds);

  @override
  void saveArchivedConversationIds(Set<String> recipientIds) =>
      _saveIds('archived_conversations', recipientIds);

  @override
  Future<void> saveRecipient(Recipient recipient) =>
      _store.saveRecipient(recipient);

  @override
  void deleteRecipient(String recipientId) =>
      _store.deleteRecipient(recipientId);

  Set<String> _loadIds(String key) {
    final accountId = _store.loadSession()?.userId ?? '__anonymous__';
    final value = _store.loadSetting('$key:$accountId');
    return value == null || value.isEmpty
        ? <String>{}
        : value.split(',').toSet();
  }

  void _saveIds(String key, Set<String> recipientIds) {
    final accountId = _store.loadSession()?.userId ?? '__anonymous__';
    _store.saveSetting('$key:$accountId', recipientIds.join(','));
  }
}
