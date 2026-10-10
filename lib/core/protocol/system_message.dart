import 'system_event_type.dart';

class SystemMessage {
  const SystemMessage({
    required this.eventType,
    required this.actorUserId,
    required this.timestamp,
    this.actorUsername,
    this.targetUserId,
    this.targetUsername,
    this.groupId,
    this.channelId,
    this.reason,
    this.metadataJson,
    this.role,
    this.membersCanSendMessages,
    this.slowModeSeconds,
    this.changedFields = const <String>[],
    this.permissionValues = const <String, bool>{},
  });

  final SystemEventType eventType;
  final String actorUserId;
  final String? actorUsername;
  final String? targetUserId;
  final String? targetUsername;
  final String? groupId;
  final String? channelId;
  final String? reason;
  final String? metadataJson;
  final String? role;
  final bool? membersCanSendMessages;
  final int? slowModeSeconds;
  final List<String> changedFields;
  final Map<String, bool> permissionValues;
  final DateTime timestamp;

  String renderText({
    String actorName = 'Alguém',
    String targetName = 'um membro',
  }) => switch (eventType) {
    SystemEventType.userJoinedGroup => '$actorName entrou no grupo',
    SystemEventType.userLeftGroup => '$actorName saiu do grupo',
    SystemEventType.userAddedToGroup =>
      '$actorName adicionou $targetName ao grupo',
    SystemEventType.userRemovedFromGroup =>
      '$actorName removeu $targetName do grupo',
    SystemEventType.userBannedFromGroup =>
      '$actorName baniu $targetName do grupo',
    SystemEventType.userUnbannedFromGroup =>
      '$actorName removeu o banimento de $targetName do grupo',
    SystemEventType.groupCreated => '$actorName criou o grupo',
    SystemEventType.groupRenamed => '$actorName editou o nome do grupo',
    SystemEventType.groupAvatarChanged => '$actorName alterou a foto do grupo',
    SystemEventType.groupUpdated => _resourceUpdateText(actorName, 'grupo'),
    SystemEventType.userJoinedChannel => '$actorName entrou no canal',
    SystemEventType.userLeftChannel => '$actorName saiu do canal',
    SystemEventType.userAddedToChannel =>
      '$actorName adicionou $targetName ao canal',
    SystemEventType.userRemovedFromChannel =>
      '$actorName removeu $targetName do canal',
    SystemEventType.userBannedFromChannel =>
      '$actorName baniu $targetName do canal',
    SystemEventType.userRoleChanged =>
      '$actorName alterou o cargo de $targetName para ${_roleLabel(role)}',
    SystemEventType.channelCreated => '$actorName criou o canal',
    SystemEventType.channelRenamed => '$actorName editou o nome do canal',
    SystemEventType.channelUpdated => _resourceUpdateText(actorName, 'canal'),
    SystemEventType.groupPolicyChanged => _policyText(actorName, 'grupo'),
    SystemEventType.channelPolicyChanged => _policyText(actorName, 'canal'),
    SystemEventType.channelBroadcast => '$actorName publicou uma atualização',
    SystemEventType.userMuted => '$actorName silenciou $targetName',
    SystemEventType.userUnmuted =>
      '$actorName removeu o silêncio de $targetName',
    SystemEventType.botAdded => '$actorName adicionou um bot',
    SystemEventType.botRemoved => '$actorName removeu um bot',
    SystemEventType.unspecified => 'Atualização do sistema',
  };

  String _policyText(String actorName, String resource) {
    if (changedFields.isEmpty) {
      final sendingAllowed = membersCanSendMessages;
      if (resource == 'grupo') {
        return switch (sendingAllowed) {
          true =>
            '$actorName permitiu que os membros enviassem mensagens no grupo',
          false => '$actorName restringiu o envio de mensagens no grupo',
          null => '$actorName alterou as permissões do grupo',
        };
      }
      return switch (sendingAllowed) {
        true => '$actorName permitiu que os inscritos publicassem no canal',
        false => '$actorName restringiu as publicações no canal',
        null => '$actorName alterou as permissões do canal',
      };
    }
    const labels = <String, String>{
      'members_can_send_messages': 'envio de mensagens',
      'members_can_send_media': 'envio de mídias',
      'members_can_send_stickers_gifs': 'figurinhas e GIFs',
      'members_can_embed_links': 'envio de links',
      'members_can_add_members': 'adição de participantes',
      'members_can_change_info': 'edição das informações',
      'members_can_react': 'reações',
      'members_can_forward': 'encaminhamento',
    };
    final changes = changedFields
        .map((field) {
          if (field == 'slow_mode_seconds') {
            return 'intervalo entre mensagens: ${_slowModeLabel(slowModeSeconds)}';
          }
          final enabled =
              permissionValues[field] ??
              (field == 'members_can_send_messages'
                  ? membersCanSendMessages
                  : null);
          final label = labels[field] ?? 'permissões';
          final state = enabled == null
              ? 'atualizado'
              : enabled
              ? 'permitido'
              : 'bloqueado';
          return '$label: $state';
        })
        .join(', ');
    return '$actorName alterou as permissões do $resource: $changes';
  }

  String _slowModeLabel(int? seconds) {
    if (seconds == null) return 'atualizado';
    if (seconds == 0) return 'desativado';
    if (seconds < 60) return '$seconds segundos';
    if (seconds == 3600) return '1 hora';
    final minutes = seconds ~/ 60;
    return '$minutes ${minutes == 1 ? 'minuto' : 'minutos'}';
  }

  String _resourceUpdateText(String actorName, String resource) {
    if (changedFields.length != 1) {
      return '$actorName editou as informações do $resource';
    }
    return switch (changedFields.single) {
      'name' => '$actorName editou o nome do $resource',
      'username' => '$actorName alterou o nome de usuário do $resource',
      'description' => '$actorName editou a descrição do $resource',
      'avatar' || 'avatar_url' => '$actorName alterou a foto do $resource',
      'visibility' => '$actorName alterou a visibilidade do $resource',
      _ => '$actorName editou as informações do $resource',
    };
  }

  String _roleLabel(String? value) => switch (value) {
    'owner' => 'proprietário',
    'admin' => 'administrador',
    'member' => 'membro',
    'subscriber' => 'inscrito',
    _ => 'membro',
  };
}
