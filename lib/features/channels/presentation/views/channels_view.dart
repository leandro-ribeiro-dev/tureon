import 'package:flutter/material.dart';

import '../../../../core/design_system/app_avatar.dart';
import '../../../../core/protocol/recipient.dart';

/// Presentation view for Channels list and management adhering to Section 1.1 layout.
class ChannelsView extends StatelessWidget {
  const ChannelsView({
    super.key,
    required this.channels,
    required this.onSelectChannel,
    this.onCreateChannel,
  });

  final List<Recipient> channels;
  final ValueChanged<Recipient> onSelectChannel;
  final VoidCallback? onCreateChannel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Canais'),
        actions: [
          if (onCreateChannel != null)
            IconButton(
              tooltip: 'Criar Canal',
              icon: const Icon(Icons.add_circle_outline_rounded),
              onPressed: onCreateChannel,
            ),
        ],
      ),
      body: channels.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.campaign_outlined,
                      size: 64,
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Nenhum canal inscrito',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Canais transmitem atualizações para públicos ilimitados.',
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
              itemCount: channels.length,
              itemBuilder: (context, index) {
                final channel = channels[index];
                return ListTile(
                  leading: AppAvatar.fromRecipient(channel, radius: 24),
                  title: Text(
                    channel.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    channel.handle.isNotEmpty ? channel.handle : 'Canal público',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: channel.unreadCount > 0
                      ? Badge.count(count: channel.unreadCount)
                      : const Icon(Icons.chevron_right_rounded),
                  onTap: () => onSelectChannel(channel),
                );
              },
            ),
    );
  }
}
