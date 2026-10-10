import 'package:flutter/material.dart';
import '../../../../core/design_system/app_avatar.dart';
import '../../../../core/design_system/verified_name.dart';
import '../../../../core/protocol/protocol_models.dart';

/// Search result sections and text highlighting, without lookup side effects.
class ChatSearchResults extends StatelessWidget {
  const ChatSearchResults({
    super.key,
    required this.matchingLocalRecipients,
    required this.matchingLocalMessages,
    required this.normalizedQuery,
    required this.selectedCategory,
    required this.remoteResults,
    required this.remoteError,
    required this.isSearching,
    required this.recipients,
    required this.onSelect,
  });
  final List<Recipient> matchingLocalRecipients;
  final List<MessageItem> matchingLocalMessages;
  final String normalizedQuery;
  final String selectedCategory;
  final List<Recipient> remoteResults;
  final String? remoteError;
  final bool isSearching;
  final List<Recipient> recipients;
  final ValueChanged<Recipient> onSelect;
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final filterChats =
        selectedCategory == 'Tudo' || selectedCategory == 'Conversas';
    final filterMessages =
        selectedCategory == 'Tudo' || selectedCategory == 'Mensagens';

    final hasLocalChats = filterChats && matchingLocalRecipients.isNotEmpty;
    final hasRemote =
        filterChats &&
        (remoteResults.isNotEmpty || isSearching || remoteError != null);
    final hasMessages = filterMessages && matchingLocalMessages.isNotEmpty;

    if (!hasLocalChats && !hasRemote && !hasMessages && !isSearching) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 56,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              ),
              const SizedBox(height: 12),
              Text(
                'Nenhum resultado encontrado',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Tente buscar com outros termos ou verifique o username.',
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        // Section: Local Conversations & Contacts
        if (hasLocalChats) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Conversas e Contatos',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
          ),
          for (final recipient in matchingLocalRecipients)
            ListTile(
              leading: AppAvatar.fromRecipient(recipient, radius: 22),
              title: VerifiedName(
                name: recipient.name,
                badge: recipient.verificationBadge,
                type: recipient.type,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                recipient.handle,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
              onTap: () => onSelect(recipient),
            ),
        ],

        // Section: Global Network Search (Server)
        if (filterChats) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Text(
                  'Resultados na Rede',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                if (isSearching) ...[
                  const SizedBox(width: 8),
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ],
              ],
            ),
          ),
          if (remoteError != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                remoteError!,
                style: TextStyle(color: colorScheme.error, fontSize: 13),
              ),
            ),
          if (!isSearching && remoteError == null && remoteResults.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                'Nenhum resultado público encontrado.',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
            ),
          for (final recipient in remoteResults)
            ListTile(
              leading: AppAvatar.fromRecipient(recipient, radius: 22),
              title: VerifiedName(
                name: recipient.name,
                badge: recipient.verificationBadge,
                type: recipient.type,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                recipient.description.isNotEmpty
                    ? recipient.description
                    : recipient.handle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  switch (recipient.type) {
                    RecipientType.group =>
                      recipient.isMember ? 'Grupo' : 'Entrar',
                    RecipientType.channel =>
                      recipient.isMember ? 'Canal' : 'Entrar',
                    _ => 'Global',
                  },
                  style: TextStyle(
                    color: colorScheme.onPrimaryContainer,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              onTap: () => onSelect(recipient),
            ),
        ],

        // Section: Message Content Search
        if (hasMessages) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Mensagens Encontradas',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
          ),
          for (final msg in matchingLocalMessages)
            _buildMessageResultTile(context, msg, normalizedQuery),
        ],
      ],
    );
  }

  Widget _buildMessageResultTile(
    BuildContext context,
    MessageItem msg,
    String query,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final senderName = msg.senderName.isNotEmpty ? msg.senderName : 'Contato';
    final recipient = recipients.firstWhere(
      (r) => r.name.toLowerCase() == senderName.toLowerCase(),
      orElse: () => Recipient(
        id: msg.id,
        type: RecipientType.user,
        name: senderName,
        handle: '@$senderName',
      ),
    );

    final text = msg.text ?? '';
    final matchIndex = text.toLowerCase().indexOf(query);

    return ListTile(
      leading: AppAvatar.fromRecipient(recipient, radius: 20),
      title: Text(
        recipient.name,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      subtitle: matchIndex != -1
          ? RichText(
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 13,
                ),
                children: [
                  TextSpan(text: text.substring(0, matchIndex)),
                  TextSpan(
                    text: text.substring(matchIndex, matchIndex + query.length),
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      backgroundColor: colorScheme.primaryContainer.withValues(
                        alpha: 0.5,
                      ),
                    ),
                  ),
                  TextSpan(text: text.substring(matchIndex + query.length)),
                ],
              ),
            )
          : Text(
              text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
      onTap: () => onSelect(recipient),
    );
  }
}
