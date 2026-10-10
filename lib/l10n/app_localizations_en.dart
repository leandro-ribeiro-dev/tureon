// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get chatPresenceOnline => 'online';

  @override
  String get chatPresenceOffline => 'offline';

  @override
  String get chatPresenceUnavailable => 'status unavailable';

  @override
  String get appTitle => 'Tureon';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get aboutTitle => 'About';

  @override
  String get aboutSettingsSubtitle => 'Tureon information and contributors';

  @override
  String get aboutDescription => 'Private, simple, connected messaging.';

  @override
  String get aboutContributorsTitle => 'Tureon contributors';

  @override
  String get aboutContributorsLoading => 'Loading contributors';

  @override
  String get aboutContributorsEmpty => 'No contributors were found.';

  @override
  String get aboutContributorsError =>
      'Could not load contributors from GitHub.';

  @override
  String get aboutRetry => 'Try again';

  @override
  String get aboutCommunityTitle => 'Community';

  @override
  String get aboutContributeLabel => 'Contribute to Tureon';

  @override
  String get aboutGithubLabel => 'View on GitHub';

  @override
  String get mainNavChats => 'Chats';

  @override
  String get mainNavContacts => 'Contacts';

  @override
  String get mainNavProfile => 'Profile';

  @override
  String get languageSettingsTitle => 'Language and Translation';

  @override
  String get appLanguageSection => 'APP INTERFACE LANGUAGE';

  @override
  String get messageTranslationSection => 'MESSAGE TRANSLATION';

  @override
  String get translateMessages => 'Automatic translation';

  @override
  String get translateMessagesHint =>
      'Translate incoming messages into the app language locally on supported devices.';

  @override
  String get understoodLanguages =>
      'LANGUAGES YOU UNDERSTAND (DO NOT TRANSLATE)';

  @override
  String get understoodLanguagesHint =>
      'Messages in these languages will not show a translation suggestion.';

  @override
  String get translationInProgress => 'Translating…';

  @override
  String get translationUnavailable =>
      'On-device translation is available only on Android and iOS.';

  @override
  String get translationFailed => 'This message could not be translated.';

  @override
  String get searchAppLanguage => 'Search app language...';

  @override
  String get languageNoResults => 'No matching languages found.';

  @override
  String get searchMessageLanguage => 'Search language...';

  @override
  String uiLanguageChanged(Object language) {
    return 'Interface language changed to $language';
  }

  @override
  String get languagePortuguese => 'Portuguese';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Spanish';

  @override
  String get languageFrench => 'French';

  @override
  String get languageGerman => 'German';

  @override
  String get languageItalian => 'Italian';

  @override
  String get languageJapanese => 'Japanese';

  @override
  String get languageChinese => 'Chinese';

  @override
  String get languageRussian => 'Russian';

  @override
  String get languageArabic => 'Arabic';

  @override
  String get languageNamePortuguese => 'Português (Brasil)';

  @override
  String get languageNameEnglish => 'English (US)';

  @override
  String get languageNameSpanish => 'Español';

  @override
  String get languageNameFrench => 'Français';

  @override
  String get languageNameGerman => 'Deutsch';

  @override
  String get languageNameItalian => 'Italiano';

  @override
  String get languageNameJapanese => '日本語';

  @override
  String get languageNameChinese => '中文';

  @override
  String get languageNameRussian => 'Русский';

  @override
  String get languageNameArabic => 'العربية';

  @override
  String translatedFrom(Object language) {
    return 'Translated from $language';
  }

  @override
  String get original => 'Original';

  @override
  String get viewOriginal => 'View original';

  @override
  String get viewTranslation => 'View translation';

  @override
  String get translateMessage => 'Translate message';

  @override
  String get translateConversation => 'Translate this conversation';

  @override
  String get copyCode => 'Copy code';

  @override
  String get openLinkFailed => 'Could not open this link.';

  @override
  String get officialBotReadOnlyText =>
      'This official bot sends account notices and does not accept messages.';

  @override
  String get channelReadOnlyText =>
      'Only administrators can post in this channel.';

  @override
  String get groupMembersCanSendMessagesTitle => 'Members can send messages';

  @override
  String get groupMembersCanSendMessagesSubtitle =>
      'When off, only admins and the owner can send.';

  @override
  String get channelSubscribersCanPublishTitle => 'Subscribers can publish';

  @override
  String get channelSubscribersCanPublishSubtitle =>
      'When off, only admins and the owner can publish.';

  @override
  String get groupRestrictedText =>
      'You are restricted from sending messages in this group.';

  @override
  String groupSlowModeCountdownText(Object seconds) {
    return 'You can send again in $seconds s.';
  }

  @override
  String groupRestrictedUntilText(Object until) {
    return 'You are restricted from sending messages in this group until $until.';
  }

  @override
  String get botStartButton => 'START';

  @override
  String get moderationRateLimited =>
      'Your account is temporarily rate limited. Please try again shortly.';

  @override
  String get moderationBanned =>
      'Your account has been suspended for violating guidelines.';

  @override
  String get moderationUnderReview =>
      'Your account is under moderation review.';

  @override
  String get composerHintNormal => 'Write a message...';

  @override
  String get composerHintSecret => 'Secret message...';

  @override
  String get addAttachment => 'Add attachment';

  @override
  String get sendMessage => 'Send message';

  @override
  String get retrySendingMessage => 'Failed to send. Retry';

  @override
  String get chatMenuPinConversation => 'Pin Conversation';

  @override
  String get chatMenuUnpinConversation => 'Unpin Conversation';

  @override
  String get chatMenuArchiveConversation => 'Archive Conversation';

  @override
  String get chatMenuUnarchiveConversation => 'Unarchive Conversation';

  @override
  String get chatMenuMuteNotifications => 'Mute Notifications';

  @override
  String get chatMenuMarkAsRead => 'Mark as Read';

  @override
  String get chatMenuMarkAsUnread => 'Mark as Unread';

  @override
  String get chatMenuDeleteConversation => 'Delete Conversation';

  @override
  String get chatMenuDeleteConfirmTitle => 'Delete Conversation?';

  @override
  String chatMenuDeleteConfirmBody(Object name) {
    return 'The conversation with $name will be permanently deleted.';
  }

  @override
  String get msgMenuSectionActions => 'ACTIONS';

  @override
  String get msgMenuSectionDanger => 'DANGER ZONE';

  @override
  String get msgMenuReply => 'Reply';

  @override
  String get msgMenuForward => 'Forward';

  @override
  String get msgMenuCopyText => 'Copy Text';

  @override
  String get msgMenuSelect => 'Select';

  @override
  String get msgMenuPin => 'Pin Message';

  @override
  String get msgMenuEdit => 'Edit Message';

  @override
  String get msgMenuDelete => 'Delete Message';

  @override
  String get msgMenuDeleteConfirmTitle => 'Delete message?';

  @override
  String get msgMenuDeleteConfirmBody =>
      'This message will be removed for all participants.';

  @override
  String get msgMenuCopied => 'Text copied to clipboard';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionSave => 'Save';

  @override
  String get actionClearHistory => 'Clear History';

  @override
  String get clearHistoryConfirmTitle => 'Clear History?';

  @override
  String get clearHistoryConfirmBody =>
      'All messages in this conversation will be deleted for you.';

  @override
  String get chatMenuViewProfile => 'View Profile';

  @override
  String get chatMenuClearHistory => 'Clear History';

  @override
  String notificationsMutedSnack(Object name) {
    return 'Notifications for $name muted';
  }

  @override
  String get autoTranslateSubtitle =>
      'Automatically translate incoming messages in this conversation';

  @override
  String get secretChatUnavailableTitle => 'Secret chat unavailable';

  @override
  String get secretChatUnavailableSubtitle =>
      'E2EE encryption is not yet configured in this app.';

  @override
  String get editMessageTitle => 'Edit message';

  @override
  String get devicesScreenTitle => 'Connected devices';

  @override
  String get devicesCurrent => 'This device';

  @override
  String devicesLastActive(Object date) {
    return 'Last active: $date';
  }

  @override
  String get devicesEmpty => 'No connected devices.';

  @override
  String get devicesRefresh => 'Refresh devices';

  @override
  String get devicesRevoke => 'End session';

  @override
  String get devicesRevokeConfirmTitle => 'End this session?';

  @override
  String devicesRevokeConfirmBody(Object name) {
    return 'Device $name will be disconnected and its pending deliveries will be removed.';
  }

  @override
  String get devicesRevokeSuccess => 'Session ended.';

  @override
  String devicesRevokeFailed(Object error) {
    return 'Could not end the session: $error';
  }

  @override
  String devicesLoadFailed(Object error) {
    return 'Could not load devices: $error';
  }

  @override
  String get profileUserTitle => 'Profile';

  @override
  String get profileBack => 'Back';

  @override
  String get profileGroupTitle => 'Group profile';

  @override
  String get profileChannelTitle => 'Channel profile';

  @override
  String get profileBotTitle => 'Bot profile';

  @override
  String get profileStatusOnline => 'Online';

  @override
  String get profileStatusLastSeen => 'Last seen recently';

  @override
  String get profileSubtitleGroup => 'Group';

  @override
  String get profileSubtitleChannel => 'Channel';

  @override
  String get profileSubtitleBot => 'Bot';

  @override
  String get profileOpenConversation => 'Open conversation';

  @override
  String get profileStartSecretChat => 'Start secret chat';

  @override
  String get profileMuteNotifications => 'Mute notifications';

  @override
  String get profileConnectToSeeMembers => 'Connect to see participants.';

  @override
  String profileMembersCount(int count) {
    return 'Members ($count)';
  }

  @override
  String profileSubscribersCount(int count) {
    return 'Subscribers ($count)';
  }

  @override
  String get profileMembersLoadFailed => 'Could not load participants.';

  @override
  String get profileRetry => 'Try again';

  @override
  String get profileEmptyMembers => 'No participants.';

  @override
  String get profileParticipantActions => 'Participant actions';

  @override
  String get profileRoleOwner => 'Owner';

  @override
  String get profileRoleAdmin => 'Administrator';

  @override
  String get profileRoleSubscriber => 'Subscriber';

  @override
  String get profileRoleMember => 'Member';

  @override
  String get profilePromoteAdmin => 'Promote to administrator';

  @override
  String get profileDemoteAdmin => 'Remove administrator role';

  @override
  String get profileRemoveMember => 'Remove from conversation';

  @override
  String get profileBanMember => 'Ban participant';

  @override
  String get profileLeaveTitle => 'Leave conversation?';

  @override
  String get profileRemoveTitle => 'Remove participant?';

  @override
  String get profileBanTitle => 'Ban participant?';

  @override
  String get profileLeaveBody =>
      'You will stop receiving messages from this conversation.';

  @override
  String profileRemoveBody(String name) {
    return 'This action will apply to $name.';
  }

  @override
  String get profileConfirm => 'Confirm';

  @override
  String get profilePromoteSuccess => 'Participant promoted to administrator.';

  @override
  String get profileDemoteSuccess => 'Administrator role removed.';

  @override
  String get profileRemoveSuccess => 'Participant removed.';

  @override
  String get profileLeaveSuccess => 'You left the conversation.';

  @override
  String get profileBanSuccess => 'Participant banned.';

  @override
  String profileActionFailed(String error) {
    return 'Could not complete the action: $error';
  }

  @override
  String get onboardingRealtimeTitle => 'Chat in real time';

  @override
  String get onboardingRealtimeDescription =>
      'Send messages and follow conversations with fast delivery across your devices.';

  @override
  String get onboardingSecretTitle => 'Privacy comes first';

  @override
  String get onboardingSecretDescription =>
      'Secret chats are designed for private conversations. End-to-end encryption depends on app configuration.';

  @override
  String get onboardingGroupsChannelsTitle => 'Groups and channels';

  @override
  String get onboardingGroupsChannelsDescription =>
      'Bring people together in groups and follow updates in channels.';

  @override
  String get onboardingDevicesTitle => 'Your conversations, your devices';

  @override
  String get onboardingDevicesDescription =>
      'Use your account across devices and keep your conversations in sync.';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get loginWithGoogle => 'Continue with Google';

  @override
  String get debugTestLoginWarning => 'DEBUG — TEST LOGIN (development only)';

  @override
  String get debugTestAccountLabel => 'Test account label';

  @override
  String get debugLoginWithTestAccount => 'Sign in with test account';

  @override
  String debugTestAccountShortcut(Object number) {
    return 'Test Account $number';
  }

  @override
  String get chatFiltersTitle => 'Conversation Filters & Tabs';

  @override
  String get enableFilterChips => 'Show filter bar in list';

  @override
  String get enableFilterChipsHint =>
      'Displays filter chips above the chat list';

  @override
  String get showUnreadCountBadge => 'Unread count on tabs';

  @override
  String get showUnreadCountBadgeHint =>
      'Displays unread message count on each filter';

  @override
  String get yourFilterTabs => 'YOUR FILTER TABS';

  @override
  String get dragToReorder => 'Drag to reorder';

  @override
  String get addFilterTab => 'Add Tab';

  @override
  String get resetDefaultTabs => 'Reset Default';

  @override
  String get filterTabAll => 'All';

  @override
  String get filterTabFavorites => 'Favorites';

  @override
  String get filterTabUnread => 'Unread';

  @override
  String get filterTabGroups => 'Groups';

  @override
  String get filterTabChannels => 'Channels';

  @override
  String get filterTabContacts => 'Direct Messages';
}
