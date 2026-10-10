part of '../chat_screen.dart';

/// Presentation coordination for conversation room actions.
mixin _ConversationRoomActions on _ChatConversationState {
  void _showOverflowMenu(BuildContext context) {
    final recipient = _liveRecipient ?? widget.recipient;
    AppBottomSheet.show<void>(
      context: context,
      builder: (sheetContext) => ChatOverflowMenuBottomSheet(
        recipient: recipient,
        isSecretMode: _secretMode,
        onViewProfile: widget.onViewProfile,
        onClearHistory: () => _confirmClearHistory(context),
        onDeleteConversation: () => _confirmDeleteConversation(context),
        onAddMember: _canManageGroupChannel(recipient)
            ? () => _addGroupChannelMember(recipient)
            : null,
      ),
    );
  }

  bool _canManageGroupChannel(Recipient recipient) =>
      (widget.services?.chatSendRestriction ?? ChatSendRestriction.none) ==
          ChatSendRestriction.none &&
      (recipient.type == RecipientType.group ||
          recipient.type == RecipientType.channel) &&
      (_isRoomAdmin(recipient) ||
          (recipient.type == RecipientType.group &&
              recipient.isMember &&
              recipient.membersCanAddMembers));

  Future<void> _addGroupChannelMember(Recipient recipient) async {
    final services = widget.services;
    if (services == null) return;
    final queryController = TextEditingController();
    String? query;
    try {
      query = await showDialog<String>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Adicionar participante'),
          content: TextField(
            controller: queryController,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Nome de usuário',
              prefixText: '@',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (value) => Navigator.of(dialogContext).pop(value),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(queryController.text),
              child: const Text('Buscar'),
            ),
          ],
        ),
      );
    } finally {
      queryController.dispose();
    }
    if (!mounted || query == null || query.trim().isEmpty) return;

    try {
      final matches = await services.searchUsersByUsername(query.trim());
      if (!mounted) return;
      if (matches.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nenhum usuário encontrado.')),
        );
        return;
      }
      final selectedUser = await showDialog<Recipient>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Selecionar usuário'),
          content: SizedBox(
            width: 420,
            height: 300,
            child: ListView.separated(
              itemCount: matches.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final user = matches[index];
                return ListTile(
                  title: Text(user.name),
                  subtitle: Text(user.handle),
                  onTap: () => Navigator.of(dialogContext).pop(user),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      );
      if (selectedUser == null) return;
      await services.addMemberToGroupChannel(
        groupChannelId: recipient.id,
        userId: selectedUser.id,
        isChannel: recipient.type == RecipientType.channel,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${selectedUser.name} adicionado.')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Não foi possível adicionar: $error')),
        );
      }
    }
  }

  void _confirmClearHistory(BuildContext context) {
    ChatDialogs.confirmClearHistory(
      context: context,
      onConfirm: widget.onClearHistory,
    );
  }

  void _confirmDeleteConversation(BuildContext context) {
    ChatDialogs.confirmDeleteConversation(
      context: context,
      recipient: widget.recipient,
      onConfirm: () {
        widget.onDeleteConversation();
        widget.onBack();
      },
    );
  }
}
