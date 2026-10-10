import 'dart:async';

import '../protocol/message_item.dart';
import '../protocol/recipient.dart';
import '../protocol/verification_badge.dart';
import '../../features/home/domain/home_repository.dart';

class AppState {
  AppState({this.repository})
    : isPrepared = true,
      recipients = <Recipient>[],
      selectedRecipient = null,
      messages = <MessageItem>[],
      _pinnedIds = repository?.loadPinnedConversationIds() ?? <String>{},
      _archivedIds = repository?.loadArchivedConversationIds() ?? <String>{};

  final HomeRepository? repository;
  final bool isPrepared;

  final List<Recipient> recipients;
  final Set<String> _pinnedIds;
  final Set<String> _archivedIds;
  Recipient? selectedRecipient;
  final List<MessageItem> messages;

  List<Recipient> get activeRecipients {
    final active = recipients
        .where((item) => !_archivedIds.contains(item.id))
        .toList();
    active.sort((a, b) {
      final pinOrder =
          (_pinnedIds.contains(b.id) ? 1 : 0) -
          (_pinnedIds.contains(a.id) ? 1 : 0);
      return pinOrder == 0
          ? recipients.indexOf(a).compareTo(recipients.indexOf(b))
          : pinOrder;
    });
    return active;
  }

  List<Recipient> get archivedRecipients =>
      recipients.where((item) => _archivedIds.contains(item.id)).toList();

  void replaceRecipients(List<Recipient> savedRecipients) {
    final selectedId = selectedRecipient?.id;
    recipients
      ..clear()
      ..addAll(savedRecipients);
    selectedRecipient = selectedId == null
        ? null
        : recipients.where((item) => item.id == selectedId).firstOrNull;
  }

  bool isPinned(Recipient recipient) => _pinnedIds.contains(recipient.id);

  bool isArchived(Recipient recipient) => _archivedIds.contains(recipient.id);

  void togglePinned(Recipient recipient) {
    _pinnedIds.contains(recipient.id)
        ? _pinnedIds.remove(recipient.id)
        : _pinnedIds.add(recipient.id);
    repository?.savePinnedConversationIds(_pinnedIds);
  }

  void toggleArchived(Recipient recipient) {
    _archivedIds.contains(recipient.id)
        ? _archivedIds.remove(recipient.id)
        : _archivedIds.add(recipient.id);
    repository?.saveArchivedConversationIds(_archivedIds);
  }

  void deleteConversation(Recipient recipient) {
    recipients.removeWhere((item) => item.id == recipient.id);
    _pinnedIds.remove(recipient.id);
    _archivedIds.remove(recipient.id);
    repository?.savePinnedConversationIds(_pinnedIds);
    repository?.saveArchivedConversationIds(_archivedIds);
    repository?.deleteRecipient(recipient.id);
    if (selectedRecipient?.id == recipient.id) {
      selectedRecipient = recipients.isEmpty ? null : recipients.first;
    }
  }

  void addRecipientIfAbsent(Recipient recipient) {
    upsertRecipient(recipient);
  }

  Recipient upsertRecipient(Recipient recipient) {
    final index = recipients.indexWhere((item) => item.id == recipient.id);
    if (index < 0) {
      final inserted = recipient.copyWith(presenceUpdate: false);
      unawaited(repository?.saveRecipient(inserted) ?? Future<void>.value());
      recipients.insert(0, inserted);
      return inserted;
    }
    final current = recipients[index];

    // Only move conversation to top if a new message was sent or received!
    final isNewMessage =
        recipient.lastMessage != null &&
        recipient.lastMessage != current.lastMessage;

    final updated = recipient.copyWith(
      lastMessage: recipient.lastMessage ?? current.lastMessage,
      unreadCount: recipient.unreadCount == 0 && recipient.lastMessage == null
          ? current.unreadCount
          : recipient.unreadCount,
      isOnline: recipient.presenceUpdate || recipient.isPresenceVisible
          ? recipient.isOnline
          : current.isOnline,
      isPresenceVisible: recipient.presenceUpdate
          ? recipient.isPresenceVisible
          : recipient.isPresenceVisible || current.isPresenceVisible,
      presenceUpdate: false,
      verificationBadge: recipient.verificationBadge == VerificationBadge.none
          ? current.verificationBadge
          : recipient.verificationBadge,
    );
    unawaited(repository?.saveRecipient(updated) ?? Future<void>.value());

    if (isNewMessage) {
      recipients
        ..removeAt(index)
        ..insert(0, updated);
    } else {
      recipients[index] = updated;
    }

    if (selectedRecipient?.id == updated.id) {
      selectedRecipient = updated;
    }
    return updated;
  }

  void refreshRecipientVerification(Recipient fromServer) {
    upsertRecipient(fromServer);
  }

  void select(Recipient recipient) => selectedRecipient = recipient;
}
