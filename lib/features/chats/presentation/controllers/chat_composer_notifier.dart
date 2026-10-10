import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/protocol/protocol_models.dart';
import '../../../home/home_providers.dart';
import '../../domain/chat_composer_state.dart';

class ChatComposerParams {
  const ChatComposerParams({
    required this.chatId,
    required this.recipientType,
    this.userRole = ChatUserRole.member,
    this.canSendInGroup = true,
    this.restrictedUntil,
    this.moderationReason,
    this.moderationRetryAt,
    this.hasExchangedMessages = false,
    this.hasLastMessage = false,
    this.isOfficialSystemBot = false,
    this.isMember = true,
    this.slowModeSeconds = 0,
    this.slowModeCooldownKey,
  });

  final String chatId;
  final RecipientType recipientType;
  final ChatUserRole userRole;
  final bool canSendInGroup;
  final DateTime? restrictedUntil;
  final ModerationReason? moderationReason;
  final DateTime? moderationRetryAt;
  final bool hasExchangedMessages;
  final bool hasLastMessage;
  final bool isOfficialSystemBot;
  final bool isMember;
  final int slowModeSeconds;
  final String? slowModeCooldownKey;

  String get effectiveSlowModeCooldownKey => slowModeCooldownKey ?? chatId;

  ChatComposerParams copyWith({
    String? chatId,
    RecipientType? recipientType,
    ChatUserRole? userRole,
    bool? canSendInGroup,
    DateTime? restrictedUntil,
    ModerationReason? moderationReason,
    DateTime? moderationRetryAt,
    bool? hasExchangedMessages,
    bool? hasLastMessage,
    bool? isOfficialSystemBot,
    bool? isMember,
    int? slowModeSeconds,
    String? slowModeCooldownKey,
  }) {
    return ChatComposerParams(
      chatId: chatId ?? this.chatId,
      recipientType: recipientType ?? this.recipientType,
      userRole: userRole ?? this.userRole,
      canSendInGroup: canSendInGroup ?? this.canSendInGroup,
      restrictedUntil: restrictedUntil ?? this.restrictedUntil,
      moderationReason: moderationReason ?? this.moderationReason,
      moderationRetryAt: moderationRetryAt ?? this.moderationRetryAt,
      hasExchangedMessages: hasExchangedMessages ?? this.hasExchangedMessages,
      hasLastMessage: hasLastMessage ?? this.hasLastMessage,
      isOfficialSystemBot: isOfficialSystemBot ?? this.isOfficialSystemBot,
      isMember: isMember ?? this.isMember,
      slowModeSeconds: slowModeSeconds ?? this.slowModeSeconds,
      slowModeCooldownKey: slowModeCooldownKey ?? this.slowModeCooldownKey,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatComposerParams &&
          runtimeType == other.runtimeType &&
          chatId == other.chatId &&
          recipientType == other.recipientType &&
          userRole == other.userRole &&
          canSendInGroup == other.canSendInGroup &&
          restrictedUntil == other.restrictedUntil &&
          moderationReason == other.moderationReason &&
          moderationRetryAt == other.moderationRetryAt &&
          hasExchangedMessages == other.hasExchangedMessages &&
          hasLastMessage == other.hasLastMessage &&
          isOfficialSystemBot == other.isOfficialSystemBot &&
          isMember == other.isMember &&
          slowModeSeconds == other.slowModeSeconds &&
          slowModeCooldownKey == other.slowModeCooldownKey;

  @override
  int get hashCode =>
      chatId.hashCode ^
      recipientType.hashCode ^
      userRole.hashCode ^
      canSendInGroup.hashCode ^
      restrictedUntil.hashCode ^
      moderationReason.hashCode ^
      moderationRetryAt.hashCode ^
      hasExchangedMessages.hashCode ^
      hasLastMessage.hashCode ^
      isOfficialSystemBot.hashCode ^
      isMember.hashCode ^
      slowModeSeconds.hashCode ^
      slowModeCooldownKey.hashCode;
}

class ChatComposerNotifier extends Notifier<ChatComposerState> {
  ChatComposerNotifier(this._params);

  final ChatComposerParams _params;
  bool _hasReceivedRecipient = false;
  StreamSubscription<Recipient?>? _subscription;

  @override
  ChatComposerState build() {
    if (!_params.isMember &&
        (_params.recipientType == RecipientType.group ||
            _params.recipientType == RecipientType.channel)) {
      return computeState(_params);
    }
    final repository = ref.watch(homeRepositoryProvider);
    _subscription?.cancel();
    if (repository != null) {
      _subscription = repository
          .watchRecipient(_params.chatId)
          .listen(
            (recipient) {
              if (recipient == null) {
                _hasReceivedRecipient = false;
                state = const ChatComposerState.disabled();
                return;
              }
              _hasReceivedRecipient = true;
              updateRecipient(recipient);
            },
            onError: (Object error, StackTrace stackTrace) {
              debugPrint(
                'Chat composer stream error for ${_params.chatId}: $error',
              );
              if (!_hasReceivedRecipient) {
                state = const ChatComposerState.disabled();
              }
            },
          );
      ref.onDispose(() => unawaited(_subscription?.cancel()));
      return const ChatComposerState.disabled();
    } else {
      _hasReceivedRecipient = true;
      return computeState(_params);
    }
  }

  ChatComposerParams get params => _params;

  static ChatComposerState computeState(
    ChatComposerParams params, {
    DateTime? now,
  }) {
    if (params.moderationReason != null) {
      return ChatComposerState.moderationBlocked(
        params.moderationReason!,
        retryAt: params.moderationRetryAt,
      );
    }

    if (params.isOfficialSystemBot) {
      return const ChatComposerState.officialBotReadOnly();
    }

    if (!params.isMember &&
        (params.recipientType == RecipientType.group ||
            params.recipientType == RecipientType.channel)) {
      return const ChatComposerState.joinRequired();
    }

    if (params.recipientType == RecipientType.channel) {
      if (params.userRole != ChatUserRole.admin &&
          params.userRole != ChatUserRole.owner) {
        return const ChatComposerState.channelReadOnly();
      }
      return const ChatComposerState.normal();
    }

    if (params.recipientType == RecipientType.group) {
      final isRestrictedByUntil =
          params.restrictedUntil != null &&
          params.restrictedUntil!.isAfter(now ?? DateTime.now());
      if (!params.canSendInGroup || isRestrictedByUntil) {
        return ChatComposerState.restrictedInGroup(
          until: params.restrictedUntil,
        );
      }
      return const ChatComposerState.normal();
    }

    if (params.recipientType == RecipientType.bot) {
      final hasEverHadMessages =
          params.hasExchangedMessages || params.hasLastMessage;
      if (!hasEverHadMessages) {
        return const ChatComposerState.botNeedsStart();
      }
      return const ChatComposerState.normal();
    }

    return const ChatComposerState.normal();
  }

  void markMessageExchanged() {
    if (!_hasReceivedRecipient) return;
    final nextParams = _params.copyWith(hasExchangedMessages: true);
    state = computeState(nextParams);
  }

  void updateRecipient(Recipient recipient) {
    _hasReceivedRecipient = true;
    updateParams(
      userRole: switch (recipient.composerRole) {
        'owner' => ChatUserRole.owner,
        'admin' => ChatUserRole.admin,
        _ => ChatUserRole.member,
      },
      canSendInGroup: recipient.canSendMessages,
      isMember: recipient.isMember,
      restrictedUntil: recipient.restrictedUntil,
      slowModeSeconds: recipient.slowModeSeconds,
    );
  }

  void closeRecipient() {
    _hasReceivedRecipient = false;
    state = const ChatComposerState.disabled();
  }

  void handleStreamError(Object error, StackTrace stackTrace) {
    debugPrint('Chat composer stream error for ${_params.chatId}: $error');
    if (!_hasReceivedRecipient) {
      state = const ChatComposerState.disabled();
    }
  }

  void updateParams({
    ChatUserRole? userRole,
    bool? canSendInGroup,
    DateTime? restrictedUntil,
    ModerationReason? moderationReason,
    DateTime? moderationRetryAt,
    bool? hasExchangedMessages,
    bool? hasLastMessage,
    bool? isOfficialSystemBot,
    bool? isMember,
    int? slowModeSeconds,
  }) {
    final nextParams = _params.copyWith(
      userRole: userRole,
      canSendInGroup: canSendInGroup,
      restrictedUntil: restrictedUntil,
      moderationReason: moderationReason,
      moderationRetryAt: moderationRetryAt,
      hasExchangedMessages: hasExchangedMessages,
      hasLastMessage: hasLastMessage,
      isOfficialSystemBot: isOfficialSystemBot,
      isMember: isMember,
      slowModeSeconds: slowModeSeconds,
    );
    if (!_hasReceivedRecipient) {
      state = const ChatComposerState.disabled();
      return;
    }
    state = computeState(nextParams);
  }
}

final chatComposerProvider = NotifierProvider.autoDispose
    .family<ChatComposerNotifier, ChatComposerState, ChatComposerParams>(
      ChatComposerNotifier.new,
    );
