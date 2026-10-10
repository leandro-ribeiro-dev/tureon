import 'package:flutter/material.dart';

import '../../../../core/design_system/app_avatar.dart';
import '../../../../core/design_system/app_bottom_sheet.dart';
import '../../../../core/design_system/verified_name.dart';
import '../../../../core/protocol/recipient.dart';
import '../../../home/presentation/home_view_model.dart';

/// Displays contacts in a Material list with online status and search.
class ContactsListScreen extends StatefulWidget {
  const ContactsListScreen({
    super.key,
    required this.state,
    required this.onSelectContact,
    required this.onViewContactProfile,
  });

  final HomeState state;
  final ValueChanged<Recipient> onSelectContact;
  final ValueChanged<Recipient> onViewContactProfile;

  @override
  State<ContactsListScreen> createState() => _ContactsListScreenState();
}

class _ContactsListScreenState extends State<ContactsListScreen> {
  String _searchQuery = '';
  bool _sortByStatus = false;

  void _showOverflowMenu(BuildContext context) {
    AppBottomSheet.show<void>(
      context: context,
      builder: (sheetContext) => AppBottomSheetContainer(
        title: 'Opções de Contatos',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBottomSheetTile(
              icon: Icons.person_add_alt_1_outlined,
              title: 'Adicionar Contato',
              onTap: () {
                Navigator.pop(sheetContext);
                _showAddContactDialog(context);
              },
            ),
            AppBottomSheetTile(
              icon: Icons.sort_by_alpha_outlined,
              title: _sortByStatus ? 'Ordenar por Nome' : 'Ordenar por Status',
              onTap: () {
                Navigator.pop(sheetContext);
                setState(() => _sortByStatus = !_sortByStatus);
              },
            ),
            AppBottomSheetTile(
              icon: Icons.share_outlined,
              title: 'Convidar Amigos para o Tureon',
              onTap: () {
                Navigator.pop(sheetContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Link de convite do Tureon copiado!'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddContactDialog(BuildContext context) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Adicionar Contato'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Número / Username'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Contato salvo com sucesso!')),
              );
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final glassToken = Theme.of(context).colorScheme;

    // Filter contacts
    var contacts = widget.state.recipients.where((recipient) {
      final query = _searchQuery.toLowerCase();
      return recipient.name.toLowerCase().contains(query) ||
          recipient.handle.toLowerCase().contains(query);
    }).toList();

    if (_sortByStatus) {
      contacts.sort(
        (a, b) => (b.isOnline ? 1 : 0).compareTo(a.isOnline ? 1 : 0),
      );
    } else {
      contacts.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contatos'),
        actions: [
          IconButton(
            tooltip: 'Adicionar contato',
            icon: const Icon(Icons.person_add_alt_1_outlined),
            onPressed: () => _showAddContactDialog(context),
          ),
          IconButton(
            tooltip: 'Mais opções',
            icon: const Icon(Icons.more_vert_rounded),
            onPressed: () => _showOverflowMenu(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: SearchBar(
                hintText: 'Buscar contatos...',
                onChanged: (val) => setState(() => _searchQuery = val),
              ),
            ),

            // Alphabetical / Status Contacts List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 16),
                itemCount: contacts.length,
                itemBuilder: (context, index) {
                  final recipient = contacts[index];
                  final firstLetter = recipient.name.isNotEmpty
                      ? recipient.name[0].toUpperCase()
                      : '?';
                  final showHeader =
                      !_sortByStatus &&
                      (index == 0 ||
                          contacts[index - 1].name[0].toUpperCase() !=
                              firstLetter);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (showHeader)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 16, 12, 6),
                          child: Text(
                            firstLetter,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: glassToken.primary,
                            ),
                          ),
                        ),
                      Column(
                        children: [
                          ListTile(
                            leading: AppAvatar.fromRecipient(
                              recipient,
                              radius: 22,
                            ),
                            title: VerifiedName(
                              name: recipient.name,
                              badge: recipient.verificationBadge,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: recipient.isPresenceVisible
                                ? Text(
                                    recipient.isOnline ? 'online' : 'offline',
                                    style: TextStyle(
                                      color: recipient.isOnline
                                          ? glassToken.primary
                                          : glassToken.onSurfaceVariant,
                                    ),
                                  )
                                : recipient.isUsernameVisible
                                ? Text(recipient.handle)
                                : null,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.chat_bubble_outline_rounded,
                                    size: 20,
                                  ),
                                  onPressed: () =>
                                      widget.onSelectContact(recipient),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.info_outline_rounded,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    widget.onViewContactProfile(recipient);
                                  },
                                ),
                              ],
                            ),
                            onTap: () => widget.onSelectContact(recipient),
                          ),
                          const Divider(height: 1, indent: 72),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
