enum ModerationReason { rateLimited, banned, underReview }

enum ChatUserRole { member, admin, owner }

sealed class ChatComposerState {
  const ChatComposerState();

  const factory ChatComposerState.disabled() = ComposerDisabled;
  const factory ChatComposerState.normal() = ComposerNormal;
  const factory ChatComposerState.channelReadOnly() = ComposerChannelReadOnly;
  const factory ChatComposerState.restrictedInGroup({DateTime? until}) =
      ComposerRestricted;
  const factory ChatComposerState.moderationBlocked(
    ModerationReason reason, {
    DateTime? retryAt,
  }) = ComposerModerationBlocked;
  const factory ChatComposerState.botNeedsStart() = ComposerBotNeedsStart;
  const factory ChatComposerState.officialBotReadOnly() =
      ComposerOfficialBotReadOnly;
  const factory ChatComposerState.joinRequired() = ComposerJoinRequired;
}

final class ComposerDisabled extends ChatComposerState {
  const ComposerDisabled();
}

final class ComposerNormal extends ChatComposerState {
  const ComposerNormal();
}

final class ComposerChannelReadOnly extends ChatComposerState {
  const ComposerChannelReadOnly();
}

final class ComposerRestricted extends ChatComposerState {
  const ComposerRestricted({this.until});
  final DateTime? until;
}

final class ComposerModerationBlocked extends ChatComposerState {
  const ComposerModerationBlocked(this.reason, {this.retryAt});
  final ModerationReason reason;
  final DateTime? retryAt;
}

final class ComposerBotNeedsStart extends ChatComposerState {
  const ComposerBotNeedsStart();
}

final class ComposerOfficialBotReadOnly extends ChatComposerState {
  const ComposerOfficialBotReadOnly();
}

final class ComposerJoinRequired extends ChatComposerState {
  const ComposerJoinRequired();
}
