enum RecipientType { unspecified, user, group, channel, bot }

String recipientTypeLabel(RecipientType type) => switch (type) {
  RecipientType.user => 'Pessoa',
  RecipientType.group => 'Grupo',
  RecipientType.channel => 'Canal',
  RecipientType.bot => 'Bot',
  RecipientType.unspecified => 'Desconhecido',
};
