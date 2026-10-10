import 'package:flutter/material.dart';

import '../../../../core/design_system/app_avatar.dart';
import '../../../../core/protocol/recipient.dart';

/// Presentation view for Groups list and management adhering to Section 1.1 layout.
class GroupsView extends StatelessWidget {
  const GroupsView({
    super.key,
    required this.groups,
    required this.onSelectGroup,
    this.onCreateGroup,
  });

  final List<Recipient> groups;
  final ValueChanged<Recipient> onSelectGroup;
  final VoidCallback? onCreateGroup;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Grupos'),
        actions: [
          if (onCreateGroup != null)
            IconButton(
              tooltip: 'Criar Grupo',
              icon: const Icon(Icons.add_circle_outline_rounded),
              onPressed: onCreateGroup,
            ),
        ],
      ),
      body: groups.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.groups_outlined,
                      size: 64,
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Nenhum grupo participante',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Crie um grupo para conversar com vários participantes ao mesmo tempo.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              itemCount: groups.length,
              itemBuilder: (context, index) {
                final group = groups[index];
                return ListTile(
                  leading: AppAvatar.fromRecipient(group, radius: 24),
                  title: Text(
                    group.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    group.handle.isNotEmpty ? group.handle : 'Grupo privado',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: group.unreadCount > 0
                      ? Badge.count(count: group.unreadCount)
                      : const Icon(Icons.chevron_right_rounded),
                  onTap: () => onSelectGroup(group),
                );
              },
            ),
    );
  }
}
