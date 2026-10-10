// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get chatPresenceOnline => 'en línea';

  @override
  String get chatPresenceOffline => 'sin conexión';

  @override
  String get chatPresenceUnavailable => 'estado no disponible';

  @override
  String get appTitle => 'Tureon';

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get aboutTitle => 'Acerca de';

  @override
  String get aboutSettingsSubtitle => 'Información de Tureon y colaboradores';

  @override
  String get aboutDescription => 'Mensajería privada, sencilla y conectada.';

  @override
  String get aboutContributorsTitle => 'Colaboradores de Tureon';

  @override
  String get aboutContributorsLoading => 'Cargando colaboradores';

  @override
  String get aboutContributorsEmpty => 'No se encontraron colaboradores.';

  @override
  String get aboutContributorsError =>
      'No se pudieron cargar los colaboradores de GitHub.';

  @override
  String get aboutRetry => 'Intentar de nuevo';

  @override
  String get aboutCommunityTitle => 'Comunidad';

  @override
  String get aboutContributeLabel => 'Colabora con Tureon';

  @override
  String get aboutGithubLabel => 'Ver en GitHub';

  @override
  String get mainNavChats => 'Chats';

  @override
  String get mainNavContacts => 'Contactos';

  @override
  String get mainNavProfile => 'Perfil';

  @override
  String get languageSettingsTitle => 'Idioma y traducción';

  @override
  String get appLanguageSection => 'IDIOMA DE LA INTERFAZ';

  @override
  String get messageTranslationSection => 'TRADUCCIÓN DE MENSAJES';

  @override
  String get translateMessages => 'Traducción automática';

  @override
  String get translateMessagesHint =>
      'Traduce los mensajes recibidos al idioma de la aplicación localmente en los dispositivos compatibles.';

  @override
  String get understoodLanguages => 'IDIOMAS QUE ENTIENDES (NO TRADUCIR)';

  @override
  String get understoodLanguagesHint =>
      'Los mensajes en estos idiomas no mostrarán sugerencias de traducción.';

  @override
  String get translationInProgress => 'Traduciendo…';

  @override
  String get translationUnavailable =>
      'La traducción en el dispositivo solo está disponible en Android e iOS.';

  @override
  String get translationFailed => 'No se pudo traducir este mensaje.';

  @override
  String get searchAppLanguage => 'Buscar idioma de la aplicación...';

  @override
  String get languageNoResults => 'No se encontraron idiomas.';

  @override
  String get searchMessageLanguage => 'Buscar idioma...';

  @override
  String uiLanguageChanged(Object language) {
    return 'Idioma de la interfaz cambiado a $language';
  }

  @override
  String get languagePortuguese => 'Portugués';

  @override
  String get languageEnglish => 'Inglés';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageFrench => 'Francés';

  @override
  String get languageGerman => 'Alemán';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get languageJapanese => 'Japonés';

  @override
  String get languageChinese => 'Chino';

  @override
  String get languageRussian => 'Ruso';

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
    return 'Traducido del $language';
  }

  @override
  String get original => 'Original';

  @override
  String get viewOriginal => 'Ver original';

  @override
  String get viewTranslation => 'Ver traducción';

  @override
  String get translateMessage => 'Traducir mensaje';

  @override
  String get translateConversation => 'Traducir esta conversación';

  @override
  String get copyCode => 'Copiar código';

  @override
  String get openLinkFailed => 'No se pudo abrir este enlace.';

  @override
  String get officialBotReadOnlyText =>
      'Este bot oficial envía avisos de la cuenta y no acepta mensajes.';

  @override
  String get channelReadOnlyText =>
      'Solo los administradores pueden publicar en este canal.';

  @override
  String get groupMembersCanSendMessagesTitle =>
      'Los miembros pueden enviar mensajes';

  @override
  String get groupMembersCanSendMessagesSubtitle =>
      'Si se desactiva, solo los administradores y el propietario pueden enviar.';

  @override
  String get channelSubscribersCanPublishTitle =>
      'Los suscriptores pueden publicar';

  @override
  String get channelSubscribersCanPublishSubtitle =>
      'Si se desactiva, solo los administradores y el propietario pueden publicar.';

  @override
  String get groupRestrictedText =>
      'Se te restringió enviar mensajes en este grupo.';

  @override
  String groupSlowModeCountdownText(Object seconds) {
    return 'Podrás enviar de nuevo en $seconds s.';
  }

  @override
  String groupRestrictedUntilText(Object until) {
    return 'Se te restringió enviar mensajes en este grupo hasta $until.';
  }

  @override
  String get botStartButton => 'INICIAR';

  @override
  String get moderationRateLimited =>
      'Tu cuenta está temporalmente limitada. Inténtalo de nuevo más tarde.';

  @override
  String get moderationBanned =>
      'Tu cuenta ha sido suspendida por violar las normas.';

  @override
  String get moderationUnderReview =>
      'Tu cuenta está bajo revisión de moderación.';

  @override
  String get composerHintNormal => 'Escribe un mensaje...';

  @override
  String get composerHintSecret => 'Mensaje secreto...';

  @override
  String get addAttachment => 'Adjuntar archivo';

  @override
  String get sendMessage => 'Enviar mensaje';

  @override
  String get retrySendingMessage => 'Error al enviar. Reintentar';

  @override
  String get chatMenuPinConversation => 'Fijar Conversación';

  @override
  String get chatMenuUnpinConversation => 'Desfijar Conversación';

  @override
  String get chatMenuArchiveConversation => 'Archivar Conversación';

  @override
  String get chatMenuUnarchiveConversation => 'Desarchivar Conversación';

  @override
  String get chatMenuMuteNotifications => 'Silenciar Notificaciones';

  @override
  String get chatMenuMarkAsRead => 'Marcar como Leída';

  @override
  String get chatMenuMarkAsUnread => 'Marcar como No Leída';

  @override
  String get chatMenuDeleteConversation => 'Eliminar Conversación';

  @override
  String get chatMenuDeleteConfirmTitle => '¿Eliminar Conversación?';

  @override
  String chatMenuDeleteConfirmBody(Object name) {
    return 'La conversación con $name se eliminará permanentemente.';
  }

  @override
  String get msgMenuSectionActions => 'ACCIONES';

  @override
  String get msgMenuSectionDanger => 'ZONA DE PELIGRO';

  @override
  String get msgMenuReply => 'Responder';

  @override
  String get msgMenuForward => 'Reenviar';

  @override
  String get msgMenuCopyText => 'Copiar Texto';

  @override
  String get msgMenuSelect => 'Seleccionar';

  @override
  String get msgMenuPin => 'Fijar Mensaje';

  @override
  String get msgMenuEdit => 'Editar Mensaje';

  @override
  String get msgMenuDelete => 'Eliminar Mensaje';

  @override
  String get msgMenuDeleteConfirmTitle => '¿Eliminar mensaje?';

  @override
  String get msgMenuDeleteConfirmBody =>
      'Este mensaje se eliminará para todos los participantes.';

  @override
  String get msgMenuCopied => 'Texto copiado al portapapeles';

  @override
  String get actionCancel => 'Cancelar';

  @override
  String get actionDelete => 'Eliminar';

  @override
  String get actionSave => 'Guardar';

  @override
  String get actionClearHistory => 'Limpiar Historial';

  @override
  String get clearHistoryConfirmTitle => '¿Limpiar Historial?';

  @override
  String get clearHistoryConfirmBody =>
      'Todos los mensajes de esta conversación se eliminarán para ti.';

  @override
  String get chatMenuViewProfile => 'Ver Perfil';

  @override
  String get chatMenuClearHistory => 'Limpiar Historial';

  @override
  String notificationsMutedSnack(Object name) {
    return 'Notificaciones de $name silenciadas';
  }

  @override
  String get autoTranslateSubtitle =>
      'Traducir automáticamente los mensajes recibidos en esta conversación';

  @override
  String get secretChatUnavailableTitle => 'Chat secreto no disponible';

  @override
  String get secretChatUnavailableSubtitle =>
      'El cifrado E2EE aún no está configurado en esta app.';

  @override
  String get editMessageTitle => 'Editar mensaje';

  @override
  String get devicesScreenTitle => 'Dispositivos conectados';

  @override
  String get devicesCurrent => 'Este dispositivo';

  @override
  String devicesLastActive(Object date) {
    return 'Última actividad: $date';
  }

  @override
  String get devicesEmpty => 'No hay dispositivos conectados.';

  @override
  String get devicesRefresh => 'Actualizar dispositivos';

  @override
  String get devicesRevoke => 'Cerrar sesión';

  @override
  String get devicesRevokeConfirmTitle => '¿Cerrar esta sesión?';

  @override
  String devicesRevokeConfirmBody(Object name) {
    return 'El dispositivo $name se desconectará y se eliminarán sus entregas pendientes.';
  }

  @override
  String get devicesRevokeSuccess => 'Sesión cerrada.';

  @override
  String devicesRevokeFailed(Object error) {
    return 'No se pudo cerrar la sesión: $error';
  }

  @override
  String devicesLoadFailed(Object error) {
    return 'No se pudieron cargar los dispositivos: $error';
  }

  @override
  String get profileUserTitle => 'Perfil';

  @override
  String get profileBack => 'Volver';

  @override
  String get profileGroupTitle => 'Perfil del grupo';

  @override
  String get profileChannelTitle => 'Perfil del canal';

  @override
  String get profileBotTitle => 'Perfil del bot';

  @override
  String get profileStatusOnline => 'En línea';

  @override
  String get profileStatusLastSeen => 'Visto recientemente';

  @override
  String get profileSubtitleGroup => 'Grupo';

  @override
  String get profileSubtitleChannel => 'Canal';

  @override
  String get profileSubtitleBot => 'Bot';

  @override
  String get profileOpenConversation => 'Abrir conversación';

  @override
  String get profileStartSecretChat => 'Iniciar chat secreto';

  @override
  String get profileMuteNotifications => 'Silenciar notificaciones';

  @override
  String get profileConnectToSeeMembers =>
      'Conéctate para ver a los participantes.';

  @override
  String profileMembersCount(int count) {
    return 'Miembros ($count)';
  }

  @override
  String profileSubscribersCount(int count) {
    return 'Suscriptores ($count)';
  }

  @override
  String get profileMembersLoadFailed =>
      'No se pudieron cargar los participantes.';

  @override
  String get profileRetry => 'Reintentar';

  @override
  String get profileEmptyMembers => 'No hay participantes.';

  @override
  String get profileParticipantActions => 'Acciones del participante';

  @override
  String get profileRoleOwner => 'Propietario';

  @override
  String get profileRoleAdmin => 'Administrador';

  @override
  String get profileRoleSubscriber => 'Suscriptor';

  @override
  String get profileRoleMember => 'Miembro';

  @override
  String get profilePromoteAdmin => 'Promover a administrador';

  @override
  String get profileDemoteAdmin => 'Quitar rol de administrador';

  @override
  String get profileRemoveMember => 'Quitar de la conversación';

  @override
  String get profileBanMember => 'Expulsar participante';

  @override
  String get profileLeaveTitle => '¿Salir de la conversación?';

  @override
  String get profileRemoveTitle => '¿Quitar participante?';

  @override
  String get profileBanTitle => '¿Expulsar participante?';

  @override
  String get profileLeaveBody =>
      'Dejarás de recibir mensajes de esta conversación.';

  @override
  String profileRemoveBody(String name) {
    return 'Esta acción se aplicará a $name.';
  }

  @override
  String get profileConfirm => 'Confirmar';

  @override
  String get profilePromoteSuccess => 'Participante promovido a administrador.';

  @override
  String get profileDemoteSuccess => 'Se quitó el rol de administrador.';

  @override
  String get profileRemoveSuccess => 'Participante eliminado.';

  @override
  String get profileLeaveSuccess => 'Saliste de la conversación.';

  @override
  String get profileBanSuccess => 'Participante expulsado.';

  @override
  String profileActionFailed(String error) {
    return 'No se pudo completar la acción: $error';
  }

  @override
  String get onboardingRealtimeTitle => 'Chatea en tiempo real';

  @override
  String get onboardingRealtimeDescription =>
      'Envía mensajes y sigue las conversaciones con entrega rápida en tus dispositivos.';

  @override
  String get onboardingSecretTitle => 'La privacidad es lo primero';

  @override
  String get onboardingSecretDescription =>
      'Los chats secretos están diseñados para conversaciones privadas. El cifrado de extremo a extremo depende de la configuración de la app.';

  @override
  String get onboardingGroupsChannelsTitle => 'Grupos y canales';

  @override
  String get onboardingGroupsChannelsDescription =>
      'Reúne personas en grupos y sigue novedades en canales.';

  @override
  String get onboardingDevicesTitle => 'Tus conversaciones, tus dispositivos';

  @override
  String get onboardingDevicesDescription =>
      'Usa tu cuenta en varios dispositivos y mantén tus conversaciones sincronizadas.';

  @override
  String get onboardingSkip => 'Saltar';

  @override
  String get loginWithGoogle => 'Continuar con Google';

  @override
  String get debugTestLoginWarning =>
      'DEBUG — INICIO DE PRUEBA (solo desarrollo)';

  @override
  String get debugTestAccountLabel => 'Etiqueta de cuenta de prueba';

  @override
  String get debugLoginWithTestAccount => 'Entrar con cuenta de prueba';

  @override
  String debugTestAccountShortcut(Object number) {
    return 'Cuenta de Prueba $number';
  }

  @override
  String get chatFiltersTitle => 'Filtros y Pestañas de Conversación';

  @override
  String get enableFilterChips => 'Mostrar barra de filtros en la lista';

  @override
  String get enableFilterChipsHint =>
      'Muestra las pestañas de filtro sobre la lista de chats';

  @override
  String get showUnreadCountBadge => 'Contador de no leídos en pestañas';

  @override
  String get showUnreadCountBadgeHint =>
      'Muestra el número de mensajes no leídos en cada filtro';

  @override
  String get yourFilterTabs => 'TUS PESTAÑAS DE FILTRO';

  @override
  String get dragToReorder => 'Arrastra para reordenar';

  @override
  String get addFilterTab => 'Añadir Pestaña';

  @override
  String get resetDefaultTabs => 'Restablecer';

  @override
  String get filterTabAll => 'Todo';

  @override
  String get filterTabFavorites => 'Favoritos';

  @override
  String get filterTabUnread => 'No leídos';

  @override
  String get filterTabGroups => 'Grupos';

  @override
  String get filterTabChannels => 'Canales';

  @override
  String get filterTabContacts => 'Privados';
}
