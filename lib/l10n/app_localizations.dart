import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('pt'),
  ];

  /// No description provided for @chatPresenceOnline.
  ///
  /// In pt, this message translates to:
  /// **'online'**
  String get chatPresenceOnline;

  /// No description provided for @chatPresenceOffline.
  ///
  /// In pt, this message translates to:
  /// **'offline'**
  String get chatPresenceOffline;

  /// No description provided for @chatPresenceUnavailable.
  ///
  /// In pt, this message translates to:
  /// **'status indisponível'**
  String get chatPresenceUnavailable;

  /// No description provided for @appTitle.
  ///
  /// In pt, this message translates to:
  /// **'Tureon'**
  String get appTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Configurações'**
  String get settingsTitle;

  /// No description provided for @aboutTitle.
  ///
  /// In pt, this message translates to:
  /// **'Sobre'**
  String get aboutTitle;

  /// No description provided for @aboutSettingsSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Informações do Tureon e colaboradores'**
  String get aboutSettingsSubtitle;

  /// No description provided for @aboutDescription.
  ///
  /// In pt, this message translates to:
  /// **'Mensagens privadas, simples e conectadas.'**
  String get aboutDescription;

  /// No description provided for @aboutContributorsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Colaboradores do Tureon'**
  String get aboutContributorsTitle;

  /// No description provided for @aboutContributorsLoading.
  ///
  /// In pt, this message translates to:
  /// **'Carregando colaboradores'**
  String get aboutContributorsLoading;

  /// No description provided for @aboutContributorsEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum colaborador foi encontrado.'**
  String get aboutContributorsEmpty;

  /// No description provided for @aboutContributorsError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar os colaboradores do GitHub.'**
  String get aboutContributorsError;

  /// No description provided for @aboutRetry.
  ///
  /// In pt, this message translates to:
  /// **'Tentar novamente'**
  String get aboutRetry;

  /// No description provided for @aboutCommunityTitle.
  ///
  /// In pt, this message translates to:
  /// **'Comunidade'**
  String get aboutCommunityTitle;

  /// No description provided for @aboutContributeLabel.
  ///
  /// In pt, this message translates to:
  /// **'Contribua com o Tureon'**
  String get aboutContributeLabel;

  /// No description provided for @aboutGithubLabel.
  ///
  /// In pt, this message translates to:
  /// **'Ver no GitHub'**
  String get aboutGithubLabel;

  /// No description provided for @mainNavChats.
  ///
  /// In pt, this message translates to:
  /// **'Conversas'**
  String get mainNavChats;

  /// No description provided for @mainNavContacts.
  ///
  /// In pt, this message translates to:
  /// **'Contatos'**
  String get mainNavContacts;

  /// No description provided for @mainNavProfile.
  ///
  /// In pt, this message translates to:
  /// **'Perfil'**
  String get mainNavProfile;

  /// No description provided for @languageSettingsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Idioma e Tradução'**
  String get languageSettingsTitle;

  /// No description provided for @appLanguageSection.
  ///
  /// In pt, this message translates to:
  /// **'IDIOMA DA INTERFACE DO APP'**
  String get appLanguageSection;

  /// No description provided for @messageTranslationSection.
  ///
  /// In pt, this message translates to:
  /// **'TRADUÇÃO DE MENSAGENS'**
  String get messageTranslationSection;

  /// No description provided for @translateMessages.
  ///
  /// In pt, this message translates to:
  /// **'Tradução automática'**
  String get translateMessages;

  /// No description provided for @translateMessagesHint.
  ///
  /// In pt, this message translates to:
  /// **'Traduz mensagens recebidas para o idioma do app localmente nos aparelhos compatíveis.'**
  String get translateMessagesHint;

  /// No description provided for @understoodLanguages.
  ///
  /// In pt, this message translates to:
  /// **'IDIOMAS QUE VOCÊ COMPREENDE (NÃO TRADUZIR)'**
  String get understoodLanguages;

  /// No description provided for @understoodLanguagesHint.
  ///
  /// In pt, this message translates to:
  /// **'Mensagens nestes idiomas não terão sugestão de tradução.'**
  String get understoodLanguagesHint;

  /// No description provided for @translationInProgress.
  ///
  /// In pt, this message translates to:
  /// **'Traduzindo…'**
  String get translationInProgress;

  /// No description provided for @translationUnavailable.
  ///
  /// In pt, this message translates to:
  /// **'A tradução no dispositivo está disponível apenas no Android e iOS.'**
  String get translationUnavailable;

  /// No description provided for @translationFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível traduzir esta mensagem.'**
  String get translationFailed;

  /// No description provided for @searchAppLanguage.
  ///
  /// In pt, this message translates to:
  /// **'Buscar idioma do app...'**
  String get searchAppLanguage;

  /// No description provided for @languageNoResults.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum idioma encontrado.'**
  String get languageNoResults;

  /// No description provided for @searchMessageLanguage.
  ///
  /// In pt, this message translates to:
  /// **'Buscar idioma...'**
  String get searchMessageLanguage;

  /// No description provided for @uiLanguageChanged.
  ///
  /// In pt, this message translates to:
  /// **'Idioma da interface alterado para {language}'**
  String uiLanguageChanged(Object language);

  /// No description provided for @languagePortuguese.
  ///
  /// In pt, this message translates to:
  /// **'Português'**
  String get languagePortuguese;

  /// No description provided for @languageEnglish.
  ///
  /// In pt, this message translates to:
  /// **'Inglês'**
  String get languageEnglish;

  /// No description provided for @languageSpanish.
  ///
  /// In pt, this message translates to:
  /// **'Espanhol'**
  String get languageSpanish;

  /// No description provided for @languageFrench.
  ///
  /// In pt, this message translates to:
  /// **'Francês'**
  String get languageFrench;

  /// No description provided for @languageGerman.
  ///
  /// In pt, this message translates to:
  /// **'Alemão'**
  String get languageGerman;

  /// No description provided for @languageItalian.
  ///
  /// In pt, this message translates to:
  /// **'Italiano'**
  String get languageItalian;

  /// No description provided for @languageJapanese.
  ///
  /// In pt, this message translates to:
  /// **'Japonês'**
  String get languageJapanese;

  /// No description provided for @languageChinese.
  ///
  /// In pt, this message translates to:
  /// **'Chinês'**
  String get languageChinese;

  /// No description provided for @languageRussian.
  ///
  /// In pt, this message translates to:
  /// **'Russo'**
  String get languageRussian;

  /// No description provided for @languageArabic.
  ///
  /// In pt, this message translates to:
  /// **'Árabe'**
  String get languageArabic;

  /// No description provided for @languageNamePortuguese.
  ///
  /// In pt, this message translates to:
  /// **'Português (Brasil)'**
  String get languageNamePortuguese;

  /// No description provided for @languageNameEnglish.
  ///
  /// In pt, this message translates to:
  /// **'English (US)'**
  String get languageNameEnglish;

  /// No description provided for @languageNameSpanish.
  ///
  /// In pt, this message translates to:
  /// **'Español'**
  String get languageNameSpanish;

  /// No description provided for @languageNameFrench.
  ///
  /// In pt, this message translates to:
  /// **'Français'**
  String get languageNameFrench;

  /// No description provided for @languageNameGerman.
  ///
  /// In pt, this message translates to:
  /// **'Deutsch'**
  String get languageNameGerman;

  /// No description provided for @languageNameItalian.
  ///
  /// In pt, this message translates to:
  /// **'Italiano'**
  String get languageNameItalian;

  /// No description provided for @languageNameJapanese.
  ///
  /// In pt, this message translates to:
  /// **'日本語'**
  String get languageNameJapanese;

  /// No description provided for @languageNameChinese.
  ///
  /// In pt, this message translates to:
  /// **'中文'**
  String get languageNameChinese;

  /// No description provided for @languageNameRussian.
  ///
  /// In pt, this message translates to:
  /// **'Русский'**
  String get languageNameRussian;

  /// No description provided for @languageNameArabic.
  ///
  /// In pt, this message translates to:
  /// **'العربية'**
  String get languageNameArabic;

  /// No description provided for @translatedFrom.
  ///
  /// In pt, this message translates to:
  /// **'Traduzido do {language}'**
  String translatedFrom(Object language);

  /// No description provided for @original.
  ///
  /// In pt, this message translates to:
  /// **'Original'**
  String get original;

  /// No description provided for @viewOriginal.
  ///
  /// In pt, this message translates to:
  /// **'Ver original'**
  String get viewOriginal;

  /// No description provided for @viewTranslation.
  ///
  /// In pt, this message translates to:
  /// **'Ver tradução'**
  String get viewTranslation;

  /// No description provided for @translateMessage.
  ///
  /// In pt, this message translates to:
  /// **'Traduzir mensagem'**
  String get translateMessage;

  /// No description provided for @translateConversation.
  ///
  /// In pt, this message translates to:
  /// **'Traduzir esta conversa'**
  String get translateConversation;

  /// No description provided for @copyCode.
  ///
  /// In pt, this message translates to:
  /// **'Copiar código'**
  String get copyCode;

  /// No description provided for @openLinkFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível abrir este link.'**
  String get openLinkFailed;

  /// No description provided for @officialBotReadOnlyText.
  ///
  /// In pt, this message translates to:
  /// **'Este bot oficial envia avisos da conta e não recebe mensagens.'**
  String get officialBotReadOnlyText;

  /// No description provided for @channelReadOnlyText.
  ///
  /// In pt, this message translates to:
  /// **'Só administradores podem publicar neste canal.'**
  String get channelReadOnlyText;

  /// No description provided for @groupMembersCanSendMessagesTitle.
  ///
  /// In pt, this message translates to:
  /// **'Membros podem enviar mensagens'**
  String get groupMembersCanSendMessagesTitle;

  /// No description provided for @groupMembersCanSendMessagesSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Desativado: apenas admins e o proprietário podem enviar.'**
  String get groupMembersCanSendMessagesSubtitle;

  /// No description provided for @channelSubscribersCanPublishTitle.
  ///
  /// In pt, this message translates to:
  /// **'Inscritos podem publicar'**
  String get channelSubscribersCanPublishTitle;

  /// No description provided for @channelSubscribersCanPublishSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Desativado: apenas admins e o proprietário podem publicar.'**
  String get channelSubscribersCanPublishSubtitle;

  /// No description provided for @groupRestrictedText.
  ///
  /// In pt, this message translates to:
  /// **'Você foi restrito de enviar mensagens neste grupo.'**
  String get groupRestrictedText;

  /// No description provided for @groupSlowModeCountdownText.
  ///
  /// In pt, this message translates to:
  /// **'Você poderá enviar novamente em {seconds} s.'**
  String groupSlowModeCountdownText(Object seconds);

  /// No description provided for @groupRestrictedUntilText.
  ///
  /// In pt, this message translates to:
  /// **'Você foi restrito de enviar mensagens neste grupo até {until}.'**
  String groupRestrictedUntilText(Object until);

  /// No description provided for @botStartButton.
  ///
  /// In pt, this message translates to:
  /// **'INICIAR'**
  String get botStartButton;

  /// No description provided for @moderationRateLimited.
  ///
  /// In pt, this message translates to:
  /// **'Sua conta está temporariamente limitada. Tente novamente em alguns momentos.'**
  String get moderationRateLimited;

  /// No description provided for @moderationBanned.
  ///
  /// In pt, this message translates to:
  /// **'Sua conta foi suspensa por violação das diretrizes.'**
  String get moderationBanned;

  /// No description provided for @moderationUnderReview.
  ///
  /// In pt, this message translates to:
  /// **'Sua conta está em análise de moderação.'**
  String get moderationUnderReview;

  /// No description provided for @composerHintNormal.
  ///
  /// In pt, this message translates to:
  /// **'Escreva uma mensagem...'**
  String get composerHintNormal;

  /// No description provided for @composerHintSecret.
  ///
  /// In pt, this message translates to:
  /// **'Mensagem secreta...'**
  String get composerHintSecret;

  /// No description provided for @addAttachment.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar anexo'**
  String get addAttachment;

  /// No description provided for @sendMessage.
  ///
  /// In pt, this message translates to:
  /// **'Enviar mensagem'**
  String get sendMessage;

  /// No description provided for @retrySendingMessage.
  ///
  /// In pt, this message translates to:
  /// **'Falha ao enviar. Tentar novamente'**
  String get retrySendingMessage;

  /// No description provided for @chatMenuPinConversation.
  ///
  /// In pt, this message translates to:
  /// **'Fixar Conversa'**
  String get chatMenuPinConversation;

  /// No description provided for @chatMenuUnpinConversation.
  ///
  /// In pt, this message translates to:
  /// **'Desafixar Conversa'**
  String get chatMenuUnpinConversation;

  /// No description provided for @chatMenuArchiveConversation.
  ///
  /// In pt, this message translates to:
  /// **'Arquivar Conversa'**
  String get chatMenuArchiveConversation;

  /// No description provided for @chatMenuUnarchiveConversation.
  ///
  /// In pt, this message translates to:
  /// **'Desarquivar Conversa'**
  String get chatMenuUnarchiveConversation;

  /// No description provided for @chatMenuMuteNotifications.
  ///
  /// In pt, this message translates to:
  /// **'Silenciar Notificações'**
  String get chatMenuMuteNotifications;

  /// No description provided for @chatMenuMarkAsRead.
  ///
  /// In pt, this message translates to:
  /// **'Marcar como Lida'**
  String get chatMenuMarkAsRead;

  /// No description provided for @chatMenuMarkAsUnread.
  ///
  /// In pt, this message translates to:
  /// **'Marcar como Não Lida'**
  String get chatMenuMarkAsUnread;

  /// No description provided for @chatMenuDeleteConversation.
  ///
  /// In pt, this message translates to:
  /// **'Apagar Conversa'**
  String get chatMenuDeleteConversation;

  /// No description provided for @chatMenuDeleteConfirmTitle.
  ///
  /// In pt, this message translates to:
  /// **'Apagar Conversa?'**
  String get chatMenuDeleteConfirmTitle;

  /// No description provided for @chatMenuDeleteConfirmBody.
  ///
  /// In pt, this message translates to:
  /// **'A conversa com {name} será apagada permanentemente.'**
  String chatMenuDeleteConfirmBody(Object name);

  /// No description provided for @msgMenuSectionActions.
  ///
  /// In pt, this message translates to:
  /// **'AÇÕES'**
  String get msgMenuSectionActions;

  /// No description provided for @msgMenuSectionDanger.
  ///
  /// In pt, this message translates to:
  /// **'ZONA DE PERIGO'**
  String get msgMenuSectionDanger;

  /// No description provided for @msgMenuReply.
  ///
  /// In pt, this message translates to:
  /// **'Responder'**
  String get msgMenuReply;

  /// No description provided for @msgMenuForward.
  ///
  /// In pt, this message translates to:
  /// **'Encaminhar'**
  String get msgMenuForward;

  /// No description provided for @msgMenuCopyText.
  ///
  /// In pt, this message translates to:
  /// **'Copiar Texto'**
  String get msgMenuCopyText;

  /// No description provided for @msgMenuSelect.
  ///
  /// In pt, this message translates to:
  /// **'Selecionar'**
  String get msgMenuSelect;

  /// No description provided for @msgMenuPin.
  ///
  /// In pt, this message translates to:
  /// **'Fixar Mensagem'**
  String get msgMenuPin;

  /// No description provided for @msgMenuEdit.
  ///
  /// In pt, this message translates to:
  /// **'Editar Mensagem'**
  String get msgMenuEdit;

  /// No description provided for @msgMenuDelete.
  ///
  /// In pt, this message translates to:
  /// **'Apagar Mensagem'**
  String get msgMenuDelete;

  /// No description provided for @msgMenuDeleteConfirmTitle.
  ///
  /// In pt, this message translates to:
  /// **'Apagar mensagem?'**
  String get msgMenuDeleteConfirmTitle;

  /// No description provided for @msgMenuDeleteConfirmBody.
  ///
  /// In pt, this message translates to:
  /// **'Esta mensagem será removida para todos os participantes.'**
  String get msgMenuDeleteConfirmBody;

  /// No description provided for @msgMenuCopied.
  ///
  /// In pt, this message translates to:
  /// **'Texto copiado para a área de transferência'**
  String get msgMenuCopied;

  /// No description provided for @actionCancel.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get actionCancel;

  /// No description provided for @actionDelete.
  ///
  /// In pt, this message translates to:
  /// **'Apagar'**
  String get actionDelete;

  /// No description provided for @actionSave.
  ///
  /// In pt, this message translates to:
  /// **'Salvar'**
  String get actionSave;

  /// No description provided for @actionClearHistory.
  ///
  /// In pt, this message translates to:
  /// **'Limpar Histórico'**
  String get actionClearHistory;

  /// No description provided for @clearHistoryConfirmTitle.
  ///
  /// In pt, this message translates to:
  /// **'Limpar Histórico?'**
  String get clearHistoryConfirmTitle;

  /// No description provided for @clearHistoryConfirmBody.
  ///
  /// In pt, this message translates to:
  /// **'Todas as mensagens desta conversa serão apagadas para você.'**
  String get clearHistoryConfirmBody;

  /// No description provided for @chatMenuViewProfile.
  ///
  /// In pt, this message translates to:
  /// **'Ver Perfil'**
  String get chatMenuViewProfile;

  /// No description provided for @chatMenuClearHistory.
  ///
  /// In pt, this message translates to:
  /// **'Limpar Histórico'**
  String get chatMenuClearHistory;

  /// No description provided for @notificationsMutedSnack.
  ///
  /// In pt, this message translates to:
  /// **'Notificações de {name} silenciadas'**
  String notificationsMutedSnack(Object name);

  /// No description provided for @autoTranslateSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Traduzir mensagens recebidas nesta conversa automaticamente'**
  String get autoTranslateSubtitle;

  /// No description provided for @secretChatUnavailableTitle.
  ///
  /// In pt, this message translates to:
  /// **'Chat secreto indisponível'**
  String get secretChatUnavailableTitle;

  /// No description provided for @secretChatUnavailableSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'A criptografia E2EE ainda não está configurada neste app.'**
  String get secretChatUnavailableSubtitle;

  /// No description provided for @editMessageTitle.
  ///
  /// In pt, this message translates to:
  /// **'Editar mensagem'**
  String get editMessageTitle;

  /// No description provided for @devicesScreenTitle.
  ///
  /// In pt, this message translates to:
  /// **'Dispositivos conectados'**
  String get devicesScreenTitle;

  /// No description provided for @devicesCurrent.
  ///
  /// In pt, this message translates to:
  /// **'Este dispositivo'**
  String get devicesCurrent;

  /// No description provided for @devicesLastActive.
  ///
  /// In pt, this message translates to:
  /// **'Última atividade: {date}'**
  String devicesLastActive(Object date);

  /// No description provided for @devicesEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum dispositivo conectado.'**
  String get devicesEmpty;

  /// No description provided for @devicesRefresh.
  ///
  /// In pt, this message translates to:
  /// **'Atualizar dispositivos'**
  String get devicesRefresh;

  /// No description provided for @devicesRevoke.
  ///
  /// In pt, this message translates to:
  /// **'Encerrar sessão'**
  String get devicesRevoke;

  /// No description provided for @devicesRevokeConfirmTitle.
  ///
  /// In pt, this message translates to:
  /// **'Encerrar esta sessão?'**
  String get devicesRevokeConfirmTitle;

  /// No description provided for @devicesRevokeConfirmBody.
  ///
  /// In pt, this message translates to:
  /// **'O dispositivo {name} será desconectado e as entregas pendentes serão removidas.'**
  String devicesRevokeConfirmBody(Object name);

  /// No description provided for @devicesRevokeSuccess.
  ///
  /// In pt, this message translates to:
  /// **'Sessão encerrada.'**
  String get devicesRevokeSuccess;

  /// No description provided for @devicesRevokeFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível encerrar a sessão: {error}'**
  String devicesRevokeFailed(Object error);

  /// No description provided for @devicesLoadFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar os dispositivos: {error}'**
  String devicesLoadFailed(Object error);

  /// No description provided for @profileUserTitle.
  ///
  /// In pt, this message translates to:
  /// **'Perfil'**
  String get profileUserTitle;

  /// No description provided for @profileBack.
  ///
  /// In pt, this message translates to:
  /// **'Voltar'**
  String get profileBack;

  /// No description provided for @profileGroupTitle.
  ///
  /// In pt, this message translates to:
  /// **'Perfil do grupo'**
  String get profileGroupTitle;

  /// No description provided for @profileChannelTitle.
  ///
  /// In pt, this message translates to:
  /// **'Perfil do canal'**
  String get profileChannelTitle;

  /// No description provided for @profileBotTitle.
  ///
  /// In pt, this message translates to:
  /// **'Perfil do bot'**
  String get profileBotTitle;

  /// No description provided for @profileStatusOnline.
  ///
  /// In pt, this message translates to:
  /// **'Online'**
  String get profileStatusOnline;

  /// No description provided for @profileStatusLastSeen.
  ///
  /// In pt, this message translates to:
  /// **'Visto por último recentemente'**
  String get profileStatusLastSeen;

  /// No description provided for @profileSubtitleGroup.
  ///
  /// In pt, this message translates to:
  /// **'Grupo'**
  String get profileSubtitleGroup;

  /// No description provided for @profileSubtitleChannel.
  ///
  /// In pt, this message translates to:
  /// **'Canal'**
  String get profileSubtitleChannel;

  /// No description provided for @profileSubtitleBot.
  ///
  /// In pt, this message translates to:
  /// **'Bot'**
  String get profileSubtitleBot;

  /// No description provided for @profileOpenConversation.
  ///
  /// In pt, this message translates to:
  /// **'Abrir conversa'**
  String get profileOpenConversation;

  /// No description provided for @profileStartSecretChat.
  ///
  /// In pt, this message translates to:
  /// **'Iniciar chat secreto'**
  String get profileStartSecretChat;

  /// No description provided for @profileMuteNotifications.
  ///
  /// In pt, this message translates to:
  /// **'Silenciar notificações'**
  String get profileMuteNotifications;

  /// No description provided for @profileConnectToSeeMembers.
  ///
  /// In pt, this message translates to:
  /// **'Conecte-se para ver os participantes.'**
  String get profileConnectToSeeMembers;

  /// No description provided for @profileMembersCount.
  ///
  /// In pt, this message translates to:
  /// **'Membros ({count})'**
  String profileMembersCount(int count);

  /// No description provided for @profileSubscribersCount.
  ///
  /// In pt, this message translates to:
  /// **'Inscritos ({count})'**
  String profileSubscribersCount(int count);

  /// No description provided for @profileMembersLoadFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar os participantes.'**
  String get profileMembersLoadFailed;

  /// No description provided for @profileRetry.
  ///
  /// In pt, this message translates to:
  /// **'Tentar novamente'**
  String get profileRetry;

  /// No description provided for @profileEmptyMembers.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum participante.'**
  String get profileEmptyMembers;

  /// No description provided for @profileParticipantActions.
  ///
  /// In pt, this message translates to:
  /// **'Ações do participante'**
  String get profileParticipantActions;

  /// No description provided for @profileRoleOwner.
  ///
  /// In pt, this message translates to:
  /// **'Dono'**
  String get profileRoleOwner;

  /// No description provided for @profileRoleAdmin.
  ///
  /// In pt, this message translates to:
  /// **'Administrador'**
  String get profileRoleAdmin;

  /// No description provided for @profileRoleSubscriber.
  ///
  /// In pt, this message translates to:
  /// **'Inscrito'**
  String get profileRoleSubscriber;

  /// No description provided for @profileRoleMember.
  ///
  /// In pt, this message translates to:
  /// **'Membro'**
  String get profileRoleMember;

  /// No description provided for @profilePromoteAdmin.
  ///
  /// In pt, this message translates to:
  /// **'Promover a administrador'**
  String get profilePromoteAdmin;

  /// No description provided for @profileDemoteAdmin.
  ///
  /// In pt, this message translates to:
  /// **'Remover administrador'**
  String get profileDemoteAdmin;

  /// No description provided for @profileRemoveMember.
  ///
  /// In pt, this message translates to:
  /// **'Remover da conversa'**
  String get profileRemoveMember;

  /// No description provided for @profileBanMember.
  ///
  /// In pt, this message translates to:
  /// **'Banir participante'**
  String get profileBanMember;

  /// No description provided for @profileLeaveTitle.
  ///
  /// In pt, this message translates to:
  /// **'Sair da conversa?'**
  String get profileLeaveTitle;

  /// No description provided for @profileRemoveTitle.
  ///
  /// In pt, this message translates to:
  /// **'Remover participante?'**
  String get profileRemoveTitle;

  /// No description provided for @profileBanTitle.
  ///
  /// In pt, this message translates to:
  /// **'Banir participante?'**
  String get profileBanTitle;

  /// No description provided for @profileLeaveBody.
  ///
  /// In pt, this message translates to:
  /// **'Você deixará de receber mensagens desta conversa.'**
  String get profileLeaveBody;

  /// No description provided for @profileRemoveBody.
  ///
  /// In pt, this message translates to:
  /// **'Esta ação será aplicada a {name}.'**
  String profileRemoveBody(String name);

  /// No description provided for @profileConfirm.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar'**
  String get profileConfirm;

  /// No description provided for @profilePromoteSuccess.
  ///
  /// In pt, this message translates to:
  /// **'Participante promovido a administrador.'**
  String get profilePromoteSuccess;

  /// No description provided for @profileDemoteSuccess.
  ///
  /// In pt, this message translates to:
  /// **'Permissão de administrador removida.'**
  String get profileDemoteSuccess;

  /// No description provided for @profileRemoveSuccess.
  ///
  /// In pt, this message translates to:
  /// **'Participante removido.'**
  String get profileRemoveSuccess;

  /// No description provided for @profileLeaveSuccess.
  ///
  /// In pt, this message translates to:
  /// **'Você saiu da conversa.'**
  String get profileLeaveSuccess;

  /// No description provided for @profileBanSuccess.
  ///
  /// In pt, this message translates to:
  /// **'Participante banido.'**
  String get profileBanSuccess;

  /// No description provided for @profileActionFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível concluir a ação: {error}'**
  String profileActionFailed(String error);

  /// No description provided for @onboardingRealtimeTitle.
  ///
  /// In pt, this message translates to:
  /// **'Converse em tempo real'**
  String get onboardingRealtimeTitle;

  /// No description provided for @onboardingRealtimeDescription.
  ///
  /// In pt, this message translates to:
  /// **'Envie mensagens e acompanhe as conversas com entrega rápida entre seus dispositivos.'**
  String get onboardingRealtimeDescription;

  /// No description provided for @onboardingSecretTitle.
  ///
  /// In pt, this message translates to:
  /// **'Privacidade em primeiro lugar'**
  String get onboardingSecretTitle;

  /// No description provided for @onboardingSecretDescription.
  ///
  /// In pt, this message translates to:
  /// **'Chats secretos foram criados para conversas privadas. A criptografia ponta a ponta depende da configuração do app.'**
  String get onboardingSecretDescription;

  /// No description provided for @onboardingGroupsChannelsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Grupos e canais'**
  String get onboardingGroupsChannelsTitle;

  /// No description provided for @onboardingGroupsChannelsDescription.
  ///
  /// In pt, this message translates to:
  /// **'Reúna pessoas em grupos e acompanhe novidades em canais.'**
  String get onboardingGroupsChannelsDescription;

  /// No description provided for @onboardingDevicesTitle.
  ///
  /// In pt, this message translates to:
  /// **'Suas conversas, seus dispositivos'**
  String get onboardingDevicesTitle;

  /// No description provided for @onboardingDevicesDescription.
  ///
  /// In pt, this message translates to:
  /// **'Acesse sua conta em diferentes dispositivos e mantenha suas conversas sincronizadas.'**
  String get onboardingDevicesDescription;

  /// No description provided for @onboardingSkip.
  ///
  /// In pt, this message translates to:
  /// **'Pular'**
  String get onboardingSkip;

  /// No description provided for @loginWithGoogle.
  ///
  /// In pt, this message translates to:
  /// **'Entrar com Google'**
  String get loginWithGoogle;

  /// No description provided for @debugTestLoginWarning.
  ///
  /// In pt, this message translates to:
  /// **'DEBUG — LOGIN DE TESTE (somente desenvolvimento)'**
  String get debugTestLoginWarning;

  /// No description provided for @debugTestAccountLabel.
  ///
  /// In pt, this message translates to:
  /// **'Identificador da conta de teste'**
  String get debugTestAccountLabel;

  /// No description provided for @debugLoginWithTestAccount.
  ///
  /// In pt, this message translates to:
  /// **'Entrar com conta de teste'**
  String get debugLoginWithTestAccount;

  /// No description provided for @debugTestAccountShortcut.
  ///
  /// In pt, this message translates to:
  /// **'Conta de Teste {number}'**
  String debugTestAccountShortcut(Object number);

  /// No description provided for @chatFiltersTitle.
  ///
  /// In pt, this message translates to:
  /// **'Filtros e Abas de Conversa'**
  String get chatFiltersTitle;

  /// No description provided for @enableFilterChips.
  ///
  /// In pt, this message translates to:
  /// **'Exibir barra de filtros na lista'**
  String get enableFilterChips;

  /// No description provided for @enableFilterChipsHint.
  ///
  /// In pt, this message translates to:
  /// **'Exibe os chips de filtro acima da lista de conversas'**
  String get enableFilterChipsHint;

  /// No description provided for @showUnreadCountBadge.
  ///
  /// In pt, this message translates to:
  /// **'Contador de mensagens não lidas nas abas'**
  String get showUnreadCountBadge;

  /// No description provided for @showUnreadCountBadgeHint.
  ///
  /// In pt, this message translates to:
  /// **'Exibe a quantidade de não lidas em cada filtro'**
  String get showUnreadCountBadgeHint;

  /// No description provided for @yourFilterTabs.
  ///
  /// In pt, this message translates to:
  /// **'SUAS ABAS DE FILTRO'**
  String get yourFilterTabs;

  /// No description provided for @dragToReorder.
  ///
  /// In pt, this message translates to:
  /// **'Arraste para reordenar'**
  String get dragToReorder;

  /// No description provided for @addFilterTab.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar Aba'**
  String get addFilterTab;

  /// No description provided for @resetDefaultTabs.
  ///
  /// In pt, this message translates to:
  /// **'Restaurar Padrão'**
  String get resetDefaultTabs;

  /// No description provided for @filterTabAll.
  ///
  /// In pt, this message translates to:
  /// **'Tudo'**
  String get filterTabAll;

  /// No description provided for @filterTabFavorites.
  ///
  /// In pt, this message translates to:
  /// **'Favoritos'**
  String get filterTabFavorites;

  /// No description provided for @filterTabUnread.
  ///
  /// In pt, this message translates to:
  /// **'Não lidas'**
  String get filterTabUnread;

  /// No description provided for @filterTabGroups.
  ///
  /// In pt, this message translates to:
  /// **'Grupos'**
  String get filterTabGroups;

  /// No description provided for @filterTabChannels.
  ///
  /// In pt, this message translates to:
  /// **'Canais'**
  String get filterTabChannels;

  /// No description provided for @filterTabContacts.
  ///
  /// In pt, this message translates to:
  /// **'Privados'**
  String get filterTabContacts;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
