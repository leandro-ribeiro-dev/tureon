// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get chatPresenceOnline => 'online';

  @override
  String get chatPresenceOffline => 'offline';

  @override
  String get chatPresenceUnavailable => 'status indisponível';

  @override
  String get appTitle => 'Tureon';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get aboutTitle => 'Sobre';

  @override
  String get aboutSettingsSubtitle => 'Informações do Tureon e colaboradores';

  @override
  String get aboutDescription => 'Mensagens privadas, simples e conectadas.';

  @override
  String get aboutContributorsTitle => 'Colaboradores do Tureon';

  @override
  String get aboutContributorsLoading => 'Carregando colaboradores';

  @override
  String get aboutContributorsEmpty => 'Nenhum colaborador foi encontrado.';

  @override
  String get aboutContributorsError =>
      'Não foi possível carregar os colaboradores do GitHub.';

  @override
  String get aboutRetry => 'Tentar novamente';

  @override
  String get aboutCommunityTitle => 'Comunidade';

  @override
  String get aboutContributeLabel => 'Contribua com o Tureon';

  @override
  String get aboutGithubLabel => 'Ver no GitHub';

  @override
  String get mainNavChats => 'Conversas';

  @override
  String get mainNavContacts => 'Contatos';

  @override
  String get mainNavProfile => 'Perfil';

  @override
  String get languageSettingsTitle => 'Idioma e Tradução';

  @override
  String get appLanguageSection => 'IDIOMA DA INTERFACE DO APP';

  @override
  String get messageTranslationSection => 'TRADUÇÃO DE MENSAGENS';

  @override
  String get translateMessages => 'Tradução automática';

  @override
  String get translateMessagesHint =>
      'Traduz mensagens recebidas para o idioma do app localmente nos aparelhos compatíveis.';

  @override
  String get understoodLanguages =>
      'IDIOMAS QUE VOCÊ COMPREENDE (NÃO TRADUZIR)';

  @override
  String get understoodLanguagesHint =>
      'Mensagens nestes idiomas não terão sugestão de tradução.';

  @override
  String get translationInProgress => 'Traduzindo…';

  @override
  String get translationUnavailable =>
      'A tradução no dispositivo está disponível apenas no Android e iOS.';

  @override
  String get translationFailed => 'Não foi possível traduzir esta mensagem.';

  @override
  String get searchAppLanguage => 'Buscar idioma do app...';

  @override
  String get languageNoResults => 'Nenhum idioma encontrado.';

  @override
  String get searchMessageLanguage => 'Buscar idioma...';

  @override
  String uiLanguageChanged(Object language) {
    return 'Idioma da interface alterado para $language';
  }

  @override
  String get languagePortuguese => 'Português';

  @override
  String get languageEnglish => 'Inglês';

  @override
  String get languageSpanish => 'Espanhol';

  @override
  String get languageFrench => 'Francês';

  @override
  String get languageGerman => 'Alemão';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get languageJapanese => 'Japonês';

  @override
  String get languageChinese => 'Chinês';

  @override
  String get languageRussian => 'Russo';

  @override
  String get languageArabic => 'Árabe';

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
    return 'Traduzido do $language';
  }

  @override
  String get original => 'Original';

  @override
  String get viewOriginal => 'Ver original';

  @override
  String get viewTranslation => 'Ver tradução';

  @override
  String get translateMessage => 'Traduzir mensagem';

  @override
  String get translateConversation => 'Traduzir esta conversa';

  @override
  String get copyCode => 'Copiar código';

  @override
  String get openLinkFailed => 'Não foi possível abrir este link.';

  @override
  String get officialBotReadOnlyText =>
      'Este bot oficial envia avisos da conta e não recebe mensagens.';

  @override
  String get channelReadOnlyText =>
      'Só administradores podem publicar neste canal.';

  @override
  String get groupMembersCanSendMessagesTitle =>
      'Membros podem enviar mensagens';

  @override
  String get groupMembersCanSendMessagesSubtitle =>
      'Desativado: apenas admins e o proprietário podem enviar.';

  @override
  String get channelSubscribersCanPublishTitle => 'Inscritos podem publicar';

  @override
  String get channelSubscribersCanPublishSubtitle =>
      'Desativado: apenas admins e o proprietário podem publicar.';

  @override
  String get groupRestrictedText =>
      'Você foi restrito de enviar mensagens neste grupo.';

  @override
  String groupSlowModeCountdownText(Object seconds) {
    return 'Você poderá enviar novamente em $seconds s.';
  }

  @override
  String groupRestrictedUntilText(Object until) {
    return 'Você foi restrito de enviar mensagens neste grupo até $until.';
  }

  @override
  String get botStartButton => 'INICIAR';

  @override
  String get moderationRateLimited =>
      'Sua conta está temporariamente limitada. Tente novamente em alguns momentos.';

  @override
  String get moderationBanned =>
      'Sua conta foi suspensa por violação das diretrizes.';

  @override
  String get moderationUnderReview => 'Sua conta está em análise de moderação.';

  @override
  String get composerHintNormal => 'Escreva uma mensagem...';

  @override
  String get composerHintSecret => 'Mensagem secreta...';

  @override
  String get addAttachment => 'Adicionar anexo';

  @override
  String get sendMessage => 'Enviar mensagem';

  @override
  String get retrySendingMessage => 'Falha ao enviar. Tentar novamente';

  @override
  String get chatMenuPinConversation => 'Fixar Conversa';

  @override
  String get chatMenuUnpinConversation => 'Desafixar Conversa';

  @override
  String get chatMenuArchiveConversation => 'Arquivar Conversa';

  @override
  String get chatMenuUnarchiveConversation => 'Desarquivar Conversa';

  @override
  String get chatMenuMuteNotifications => 'Silenciar Notificações';

  @override
  String get chatMenuMarkAsRead => 'Marcar como Lida';

  @override
  String get chatMenuMarkAsUnread => 'Marcar como Não Lida';

  @override
  String get chatMenuDeleteConversation => 'Apagar Conversa';

  @override
  String get chatMenuDeleteConfirmTitle => 'Apagar Conversa?';

  @override
  String chatMenuDeleteConfirmBody(Object name) {
    return 'A conversa com $name será apagada permanentemente.';
  }

  @override
  String get msgMenuSectionActions => 'AÇÕES';

  @override
  String get msgMenuSectionDanger => 'ZONA DE PERIGO';

  @override
  String get msgMenuReply => 'Responder';

  @override
  String get msgMenuForward => 'Encaminhar';

  @override
  String get msgMenuCopyText => 'Copiar Texto';

  @override
  String get msgMenuSelect => 'Selecionar';

  @override
  String get msgMenuPin => 'Fixar Mensagem';

  @override
  String get msgMenuEdit => 'Editar Mensagem';

  @override
  String get msgMenuDelete => 'Apagar Mensagem';

  @override
  String get msgMenuDeleteConfirmTitle => 'Apagar mensagem?';

  @override
  String get msgMenuDeleteConfirmBody =>
      'Esta mensagem será removida para todos os participantes.';

  @override
  String get msgMenuCopied => 'Texto copiado para a área de transferência';

  @override
  String get actionCancel => 'Cancelar';

  @override
  String get actionDelete => 'Apagar';

  @override
  String get actionSave => 'Salvar';

  @override
  String get actionClearHistory => 'Limpar Histórico';

  @override
  String get clearHistoryConfirmTitle => 'Limpar Histórico?';

  @override
  String get clearHistoryConfirmBody =>
      'Todas as mensagens desta conversa serão apagadas para você.';

  @override
  String get chatMenuViewProfile => 'Ver Perfil';

  @override
  String get chatMenuClearHistory => 'Limpar Histórico';

  @override
  String notificationsMutedSnack(Object name) {
    return 'Notificações de $name silenciadas';
  }

  @override
  String get autoTranslateSubtitle =>
      'Traduzir mensagens recebidas nesta conversa automaticamente';

  @override
  String get secretChatUnavailableTitle => 'Chat secreto indisponível';

  @override
  String get secretChatUnavailableSubtitle =>
      'A criptografia E2EE ainda não está configurada neste app.';

  @override
  String get editMessageTitle => 'Editar mensagem';

  @override
  String get devicesScreenTitle => 'Dispositivos conectados';

  @override
  String get devicesCurrent => 'Este dispositivo';

  @override
  String devicesLastActive(Object date) {
    return 'Última atividade: $date';
  }

  @override
  String get devicesEmpty => 'Nenhum dispositivo conectado.';

  @override
  String get devicesRefresh => 'Atualizar dispositivos';

  @override
  String get devicesRevoke => 'Encerrar sessão';

  @override
  String get devicesRevokeConfirmTitle => 'Encerrar esta sessão?';

  @override
  String devicesRevokeConfirmBody(Object name) {
    return 'O dispositivo $name será desconectado e as entregas pendentes serão removidas.';
  }

  @override
  String get devicesRevokeSuccess => 'Sessão encerrada.';

  @override
  String devicesRevokeFailed(Object error) {
    return 'Não foi possível encerrar a sessão: $error';
  }

  @override
  String devicesLoadFailed(Object error) {
    return 'Não foi possível carregar os dispositivos: $error';
  }

  @override
  String get profileUserTitle => 'Perfil';

  @override
  String get profileBack => 'Voltar';

  @override
  String get profileGroupTitle => 'Perfil do grupo';

  @override
  String get profileChannelTitle => 'Perfil do canal';

  @override
  String get profileBotTitle => 'Perfil do bot';

  @override
  String get profileStatusOnline => 'Online';

  @override
  String get profileStatusLastSeen => 'Visto por último recentemente';

  @override
  String get profileSubtitleGroup => 'Grupo';

  @override
  String get profileSubtitleChannel => 'Canal';

  @override
  String get profileSubtitleBot => 'Bot';

  @override
  String get profileOpenConversation => 'Abrir conversa';

  @override
  String get profileStartSecretChat => 'Iniciar chat secreto';

  @override
  String get profileMuteNotifications => 'Silenciar notificações';

  @override
  String get profileConnectToSeeMembers =>
      'Conecte-se para ver os participantes.';

  @override
  String profileMembersCount(int count) {
    return 'Membros ($count)';
  }

  @override
  String profileSubscribersCount(int count) {
    return 'Inscritos ($count)';
  }

  @override
  String get profileMembersLoadFailed =>
      'Não foi possível carregar os participantes.';

  @override
  String get profileRetry => 'Tentar novamente';

  @override
  String get profileEmptyMembers => 'Nenhum participante.';

  @override
  String get profileParticipantActions => 'Ações do participante';

  @override
  String get profileRoleOwner => 'Dono';

  @override
  String get profileRoleAdmin => 'Administrador';

  @override
  String get profileRoleSubscriber => 'Inscrito';

  @override
  String get profileRoleMember => 'Membro';

  @override
  String get profilePromoteAdmin => 'Promover a administrador';

  @override
  String get profileDemoteAdmin => 'Remover administrador';

  @override
  String get profileRemoveMember => 'Remover da conversa';

  @override
  String get profileBanMember => 'Banir participante';

  @override
  String get profileLeaveTitle => 'Sair da conversa?';

  @override
  String get profileRemoveTitle => 'Remover participante?';

  @override
  String get profileBanTitle => 'Banir participante?';

  @override
  String get profileLeaveBody =>
      'Você deixará de receber mensagens desta conversa.';

  @override
  String profileRemoveBody(String name) {
    return 'Esta ação será aplicada a $name.';
  }

  @override
  String get profileConfirm => 'Confirmar';

  @override
  String get profilePromoteSuccess => 'Participante promovido a administrador.';

  @override
  String get profileDemoteSuccess => 'Permissão de administrador removida.';

  @override
  String get profileRemoveSuccess => 'Participante removido.';

  @override
  String get profileLeaveSuccess => 'Você saiu da conversa.';

  @override
  String get profileBanSuccess => 'Participante banido.';

  @override
  String profileActionFailed(String error) {
    return 'Não foi possível concluir a ação: $error';
  }

  @override
  String get onboardingRealtimeTitle => 'Converse em tempo real';

  @override
  String get onboardingRealtimeDescription =>
      'Envie mensagens e acompanhe as conversas com entrega rápida entre seus dispositivos.';

  @override
  String get onboardingSecretTitle => 'Privacidade em primeiro lugar';

  @override
  String get onboardingSecretDescription =>
      'Chats secretos foram criados para conversas privadas. A criptografia ponta a ponta depende da configuração do app.';

  @override
  String get onboardingGroupsChannelsTitle => 'Grupos e canais';

  @override
  String get onboardingGroupsChannelsDescription =>
      'Reúna pessoas em grupos e acompanhe novidades em canais.';

  @override
  String get onboardingDevicesTitle => 'Suas conversas, seus dispositivos';

  @override
  String get onboardingDevicesDescription =>
      'Acesse sua conta em diferentes dispositivos e mantenha suas conversas sincronizadas.';

  @override
  String get onboardingSkip => 'Pular';

  @override
  String get loginWithGoogle => 'Entrar com Google';

  @override
  String get debugTestLoginWarning =>
      'DEBUG — LOGIN DE TESTE (somente desenvolvimento)';

  @override
  String get debugTestAccountLabel => 'Identificador da conta de teste';

  @override
  String get debugLoginWithTestAccount => 'Entrar com conta de teste';

  @override
  String debugTestAccountShortcut(Object number) {
    return 'Conta de Teste $number';
  }

  @override
  String get chatFiltersTitle => 'Filtros e Abas de Conversa';

  @override
  String get enableFilterChips => 'Exibir barra de filtros na lista';

  @override
  String get enableFilterChipsHint =>
      'Exibe os chips de filtro acima da lista de conversas';

  @override
  String get showUnreadCountBadge => 'Contador de mensagens não lidas nas abas';

  @override
  String get showUnreadCountBadgeHint =>
      'Exibe a quantidade de não lidas em cada filtro';

  @override
  String get yourFilterTabs => 'SUAS ABAS DE FILTRO';

  @override
  String get dragToReorder => 'Arraste para reordenar';

  @override
  String get addFilterTab => 'Adicionar Aba';

  @override
  String get resetDefaultTabs => 'Restaurar Padrão';

  @override
  String get filterTabAll => 'Tudo';

  @override
  String get filterTabFavorites => 'Favoritos';

  @override
  String get filterTabUnread => 'Não lidas';

  @override
  String get filterTabGroups => 'Grupos';

  @override
  String get filterTabChannels => 'Canais';

  @override
  String get filterTabContacts => 'Privados';
}
