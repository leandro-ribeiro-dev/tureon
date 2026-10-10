import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/verified_name.dart';
import '../../../../core/protocol/recipient_type.dart';
import '../../../../core/protocol/message_type.dart';
import '../../../../core/providers/settings_providers.dart';
import '../home_view_model.dart';
import '../widgets/avatar_widget.dart';

/// Active conversation thread view.
class Conversation extends ConsumerWidget {
  const Conversation({
    super.key,
    required this.state,
    required this.composer,
    required this.onSend,
    required this.onBack,
  });

  final HomeState state;
  final TextEditingController composer;
  final VoidCallback onSend;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final radius = ref.watch(messageBubbleRadiusProvider);
    final recipient = state.selectedRecipient;
    if (recipient == null) {
      return const Center(child: Text('Nenhuma conversa selecionada.'));
    }
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
          color: theme.colorScheme.surface,
          child: Row(
            children: [
              IconButton(
                onPressed: onBack,
                tooltip: 'Voltar para conversas',
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              const SizedBox(width: 4),
              Avatar(recipient: recipient),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    VerifiedName(
                      name: recipient.name,
                      badge: recipient.verificationBadge,
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${recipientTypeLabel(recipient.type)}  ${recipient.handle}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Color(0xff64748b)),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.more_horiz_rounded),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(32, 28, 32, 20),
            itemCount: state.messages.length,
            itemBuilder: (context, index) {
              final message = state.messages[index];
              if (message.type == MessageType.system) {
                return Center(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 18),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(radius),
                    ),
                    child: Text(
                      message.system!.renderText(actorName: 'Tureon'),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xff52635d),
                      ),
                    ),
                  ),
                );
              }
              final mine = message.senderName == 'Você';
              return Align(
                alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  constraints: const BoxConstraints(maxWidth: 540),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: mine
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(radius),
                  ),
                  child: Text(
                    message.text!,
                    style: TextStyle(
                      color: mine
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface,
                      fontSize: 15,
                      height: 1.35,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 22),
          child: TextField(
            controller: composer,
            onSubmitted: (_) => onSend(),
            decoration: InputDecoration(
              hintText: 'Escreva uma mensagem...',
              prefixIcon: const Icon(Icons.add_circle_outline_rounded),
              suffixIcon: IconButton(
                onPressed: onSend,
                icon: const Icon(Icons.arrow_upward_rounded),
              ),
              filled: true,
              fillColor: theme.colorScheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xffdce6e1)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
