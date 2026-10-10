import 'package:flutter/material.dart';

import '../../../../core/design_system/verified_name.dart';
import '../../../../core/protocol/recipient.dart';
import '../../../../core/protocol/recipient_type.dart';
import '../../../home/presentation/home_view_model.dart';
import '../../../home/presentation/widgets/avatar_widget.dart';

/// View displaying the user's contacts list and options.
class ContactsView extends StatefulWidget {
  const ContactsView({
    super.key,
    required this.state,
    required this.onSelectContact,
  });

  final HomeState state;
  final ValueChanged<Recipient> onSelectContact;

  @override
  State<ContactsView> createState() => _ContactsViewState();
}

class _ContactsViewState extends State<ContactsView> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredContacts = widget.state.recipients.where((recipient) {
      final query = _searchQuery.toLowerCase();
      return recipient.name.toLowerCase().contains(query) ||
          recipient.handle.toLowerCase().contains(query);
    }).toList();

    return Column(
      children: [
        // Top Bar
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Row(
            children: [
              Text(
                'Contatos',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color:
                      theme.textTheme.titleLarge?.color ??
                      const Color(0xff1e293b),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.person_add_alt_1_rounded),
                color: theme.colorScheme.primary,
              ),
            ],
          ),
        ),

        // Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: TextField(
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: 'Buscar contatos...',
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: theme.cardColor,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.dividerColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.dividerColor),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Contacts List
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: filteredContacts.length,
            separatorBuilder: (context, index) =>
                Divider(height: 1, color: theme.dividerColor, indent: 64),
            itemBuilder: (context, index) {
              final recipient = filteredContacts[index];
              return Material(
                color: Colors.transparent,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  leading: Stack(
                    children: [
                      Avatar(recipient: recipient),
                      if (recipient.isOnline && recipient.isPresenceVisible)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: const Color(0xff22c55e),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: theme.scaffoldBackgroundColor,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  title: VerifiedName(
                    name: recipient.name,
                    badge: recipient.verificationBadge,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  subtitle: Text(
                    recipient.isUsernameVisible
                        ? '${recipientTypeLabel(recipient.type)} • ${recipient.handle}'
                        : recipientTypeLabel(recipient.type),
                    style: TextStyle(
                      color: theme.textTheme.bodyMedium?.color?.withValues(
                        alpha: 0.7,
                      ),
                      fontSize: 13,
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.chat_bubble_outline_rounded,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    onPressed: () => widget.onSelectContact(recipient),
                  ),
                  onTap: () => widget.onSelectContact(recipient),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
