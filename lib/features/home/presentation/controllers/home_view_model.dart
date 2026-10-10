import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/protocol/message_item.dart';
import '../../../../core/protocol/recipient.dart';
import '../../../../core/protocol/verification_badge.dart';
import '../../home_providers.dart';
import '../../domain/home_repository.dart';

final homeViewModelProvider = NotifierProvider<HomeViewModel, HomeState>(
  HomeViewModel.new,
);

class HomeState {
  HomeState({
    List<Recipient> recipients = const [],
    this.selectedRecipient,
    Set<String> pinnedIds = const {},
    Set<String> archivedIds = const {},
    List<MessageItem> messages = const [],
    this.recipientLoadError,
  }) : recipients = List.unmodifiable(recipients),
       pinnedIds = Set.unmodifiable(pinnedIds),
       archivedIds = Set.unmodifiable(archivedIds),
       messages = List.unmodifiable(messages);

  final List<Recipient> recipients;
  final Recipient? selectedRecipient;
  final Set<String> pinnedIds;
  final Set<String> archivedIds;
  final List<MessageItem> messages;
  final Object? recipientLoadError;

  List<Recipient> get activeRecipients {
    final indexedRecipients = <({int index, Recipient recipient})>[];
    for (var index = 0; index < recipients.length; index++) {
      final recipient = recipients[index];
      if (!archivedIds.contains(recipient.id)) {
        indexedRecipients.add((index: index, recipient: recipient));
      }
    }
    indexedRecipients.sort((first, second) {
      final firstPinned = pinnedIds.contains(first.recipient.id);
      final secondPinned = pinnedIds.contains(second.recipient.id);
      if (firstPinned != secondPinned) return secondPinned ? 1 : -1;
      return first.index.compareTo(second.index);
    });
    return List<Recipient>.unmodifiable(
      indexedRecipients.map((entry) => entry.recipient),
    );
  }

  List<Recipient> get archivedRecipients => List<Recipient>.unmodifiable(
    recipients.where((recipient) => archivedIds.contains(recipient.id)),
  );

  bool isPinned(Recipient recipient) => pinnedIds.contains(recipient.id);

  bool isArchived(Recipient recipient) => archivedIds.contains(recipient.id);

  HomeState copyWith({
    List<Recipient>? recipients,
    Recipient? selectedRecipient,
    bool clearSelection = false,
    Set<String>? pinnedIds,
    Set<String>? archivedIds,
    List<MessageItem>? messages,
    Object? recipientLoadError,
    bool clearRecipientLoadError = false,
  }) => HomeState(
    recipients: recipients ?? this.recipients,
    selectedRecipient: clearSelection
        ? null
        : selectedRecipient ?? this.selectedRecipient,
    pinnedIds: pinnedIds ?? this.pinnedIds,
    archivedIds: archivedIds ?? this.archivedIds,
    messages: messages ?? this.messages,
    recipientLoadError: clearRecipientLoadError
        ? null
        : recipientLoadError ?? this.recipientLoadError,
  );
}

class HomeViewModel extends Notifier<HomeState> {
  HomeRepository? _repository;
  String? _observedAccountId;
  final Map<String, Recipient> _presenceOverrides = {};
  Recipient? _lastDeletedRecipient;
  bool _lastDeletedWasPinned = false;
  bool _lastDeletedWasArchived = false;

  @override
  HomeState build() {
    final repository = ref.watch(homeRepositoryProvider);
    _repository = repository;
    final recipientsAsync = ref.watch(recipientsStreamProvider);
    final accountScope = repository;
    final accountId = accountScope is AccountScopedHomeRepository
        ? (accountScope as AccountScopedHomeRepository).activeAccountId
        : null;
    final accountChanged = _observedAccountId != accountId;
    final cachedRepository = repository is CachedHomeRepository
        ? repository as CachedHomeRepository
        : null;
    // Paint cached conversations immediately, before the stream's first event.
    // On an account change, never reuse the preceding account's snapshot.
    final sourceRecipients = accountChanged
        ? cachedRepository?.loadRecipients() ??
              recipientsAsync.asData?.value ??
              const <Recipient>[]
        : recipientsAsync.asData?.value ??
              stateOrNull?.recipients ??
              cachedRepository?.loadRecipients() ??
              const <Recipient>[];
    if (accountChanged) {
      _presenceOverrides.clear();
      _observedAccountId = accountId;
    }
    final recipientIds = sourceRecipients
        .map((recipient) => recipient.id)
        .toSet();
    // Presence streams may deliver before the first local conversation
    // snapshot. Keep those transient updates until that snapshot is available
    // so an early online/typing event is not lost during startup.
    if (recipientsAsync.hasValue) {
      _presenceOverrides.removeWhere((id, _) => !recipientIds.contains(id));
    }
    final recipients = sourceRecipients
        .map((recipient) {
          final presence = _presenceOverrides[recipient.id];
          if (presence == null) return recipient;
          return recipient.copyWith(
            isOnline: presence.isOnline,
            isPresenceVisible: presence.isPresenceVisible,
            lastSeenAt: presence.lastSeenAt,
            clearLastSeenAt: presence.lastSeenAt == null,
            isTyping: presence.isTyping,
          );
        })
        .toList(growable: false);
    final selectedId = accountChanged
        ? null
        : stateOrNull?.selectedRecipient?.id;
    final selectedRecipient = selectedId == null
        ? null
        : recipients.where((item) => item.id == selectedId).firstOrNull;

    return HomeState(
      recipients: recipients,
      selectedRecipient: selectedRecipient,
      pinnedIds:
          repository?.loadPinnedConversationIds() ??
          stateOrNull?.pinnedIds ??
          const {},
      archivedIds:
          repository?.loadArchivedConversationIds() ??
          stateOrNull?.archivedIds ??
          const {},
      recipientLoadError:
          recipientsAsync.error ?? stateOrNull?.recipientLoadError,
    );
  }

  static const int maxPinnedLimit = 5;

  void selectRecipient(Recipient recipient) {
    state = state.copyWith(selectedRecipient: recipient);
  }

  void applyPresenceUpdate(Recipient recipient) {
    if (!recipient.presenceUpdate) return;
    final index = state.recipients.indexWhere(
      (item) => item.id == recipient.id,
    );
    if (index < 0) {
      _presenceOverrides[recipient.id] = recipient.copyWith(
        presenceUpdate: false,
      );
      return;
    }

    final current = state.recipients[index];
    final updated = current.copyWith(
      isOnline: recipient.isOnline,
      isPresenceVisible: recipient.isPresenceVisible,
      lastSeenAt: recipient.lastSeenAt,
      clearLastSeenAt: recipient.lastSeenAt == null,
      isTyping: recipient.isTyping,
    );
    _presenceOverrides[recipient.id] = updated;
    final recipients = [...state.recipients]..[index] = updated;
    state = state.copyWith(
      recipients: recipients,
      selectedRecipient: state.selectedRecipient?.id == updated.id
          ? updated
          : state.selectedRecipient,
    );
  }

  bool togglePinned(Recipient recipient) {
    final ids = {...state.pinnedIds};
    if (ids.contains(recipient.id)) {
      ids.remove(recipient.id);
    } else {
      if (ids.length >= maxPinnedLimit) {
        return false; // Limit reached
      }
      ids.add(recipient.id);
    }
    state = state.copyWith(pinnedIds: ids);
    _repository?.savePinnedConversationIds(ids);
    return true;
  }

  bool togglePinnedBatch(List<Recipient> items) {
    if (items.isEmpty) return true;
    final ids = {...state.pinnedIds};
    final itemIds = items.map((item) => item.id).toSet();
    final allPinned = itemIds.every(ids.contains);
    if (allPinned) {
      ids.removeAll(itemIds);
    } else {
      ids.addAll(itemIds);
      if (ids.length > maxPinnedLimit) return false;
    }
    state = state.copyWith(pinnedIds: ids);
    _repository?.savePinnedConversationIds(ids);
    return true;
  }

  void toggleArchived(Recipient recipient) {
    final ids = {...state.archivedIds};
    if (!ids.add(recipient.id)) ids.remove(recipient.id);
    state = state.copyWith(archivedIds: ids);
    _repository?.saveArchivedConversationIds(ids);
  }

  void toggleArchivedBatch(List<Recipient> items) {
    if (items.isEmpty) return;
    final ids = {...state.archivedIds};
    final allArchived = items.every((r) => ids.contains(r.id));
    for (final r in items) {
      if (allArchived) {
        ids.remove(r.id);
      } else {
        ids.add(r.id);
      }
    }
    state = state.copyWith(archivedIds: ids);
    _repository?.saveArchivedConversationIds(ids);
  }

  void deleteConversation(Recipient recipient) {
    _presenceOverrides.remove(recipient.id);
    _lastDeletedRecipient = recipient;
    _lastDeletedWasPinned = state.pinnedIds.contains(recipient.id);
    _lastDeletedWasArchived = state.archivedIds.contains(recipient.id);
    final recipients = state.recipients
        .where((item) => item.id != recipient.id)
        .toList();
    final pinnedIds = {...state.pinnedIds}..remove(recipient.id);
    final archivedIds = {...state.archivedIds}..remove(recipient.id);
    final selectedRecipient = state.selectedRecipient?.id == recipient.id;
    state = state.copyWith(
      recipients: recipients,
      pinnedIds: pinnedIds,
      archivedIds: archivedIds,
      selectedRecipient: selectedRecipient ? recipients.firstOrNull : null,
      clearSelection: !selectedRecipient,
    );
    _repository?.savePinnedConversationIds(pinnedIds);
    _repository?.saveArchivedConversationIds(archivedIds);
    _repository?.deleteRecipient(recipient.id);
  }

  void undoDeleteConversation(Recipient recipient) {
    if (_lastDeletedRecipient?.id != recipient.id) return;
    upsertRecipient(recipient);
    if (_lastDeletedWasPinned) {
      final pinnedIds = {...state.pinnedIds, recipient.id};
      state = state.copyWith(pinnedIds: pinnedIds);
      _repository?.savePinnedConversationIds(pinnedIds);
    }
    if (_lastDeletedWasArchived) {
      final archivedIds = {...state.archivedIds, recipient.id};
      state = state.copyWith(archivedIds: archivedIds);
      _repository?.saveArchivedConversationIds(archivedIds);
    }
    _lastDeletedRecipient = null;
  }

  void deleteConversationBatch(List<Recipient> items) {
    if (items.isEmpty) return;
    final itemIds = items.map((r) => r.id).toSet();
    _presenceOverrides.removeWhere((id, _) => itemIds.contains(id));
    final recipients = state.recipients
        .where((item) => !itemIds.contains(item.id))
        .toList();
    final pinnedIds = {...state.pinnedIds}..removeAll(itemIds);
    final archivedIds = {...state.archivedIds}..removeAll(itemIds);

    state = state.copyWith(
      recipients: recipients,
      pinnedIds: pinnedIds,
      archivedIds: archivedIds,
      clearSelection: true,
    );
    _repository?.savePinnedConversationIds(pinnedIds);
    _repository?.saveArchivedConversationIds(archivedIds);
    for (final r in items) {
      _repository?.deleteRecipient(r.id);
    }
  }

  Recipient upsertRecipient(Recipient recipient) {
    final index = state.recipients.indexWhere(
      (item) => item.id == recipient.id,
    );
    if (index < 0) {
      final inserted = recipient.copyWith(presenceUpdate: false);
      state = state.copyWith(recipients: [inserted, ...state.recipients]);
      unawaited(_repository?.saveRecipient(inserted) ?? Future<void>.value());
      return inserted;
    }

    final current = state.recipients[index];

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

    // This method merges contact metadata, not message activity. The ordered
    // recipient stream from storage is the source of truth for conversation
    // order; opening a chat or refreshing a stale recipient must not move it.
    final recipients = [...state.recipients]..[index] = updated;

    state = state.copyWith(
      recipients: recipients,
      selectedRecipient: state.selectedRecipient?.id == updated.id
          ? updated
          : state.selectedRecipient,
    );
    unawaited(_repository?.saveRecipient(updated) ?? Future<void>.value());
    return updated;
  }

  void refreshRecipientVerification(Recipient recipient) {
    upsertRecipient(recipient);
  }

  void clearMessages() {
    state = state.copyWith(messages: const []);
  }
}
