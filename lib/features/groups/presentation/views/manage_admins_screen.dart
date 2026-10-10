import 'package:flutter/material.dart';

import '../../../../core/design_system/app_avatar.dart';
import '../../../../core/design_system/app_section_group.dart';
import '../../../../core/protocol/recipient.dart';
import '../../../../core/protocol/recipient_type.dart';
import '../../../../generated/proto/tureon.pb.dart' as pb;

/// Screen for managing Group & Channel Administrators, promoting/demoting members
/// styled with clean, borderless AppSectionGroup components.
class ManageAdminsScreen extends StatefulWidget {
  const ManageAdminsScreen({
    super.key,
    required this.groupChannel,
    required this.members,
    required this.onPromoteAdmin,
    required this.onDemoteAdmin,
    required this.onTransferOwnership,
  });

  final Recipient groupChannel;
  final List<pb.GroupChannelMember> members;
  final Future<void> Function(String userId) onPromoteAdmin;
  final Future<void> Function(String userId) onDemoteAdmin;
  final Future<void> Function(String userId) onTransferOwnership;

  @override
  State<ManageAdminsScreen> createState() => _ManageAdminsScreenState();
}

class _ManageAdminsScreenState extends State<ManageAdminsScreen> {
  late List<pb.GroupChannelMember> _members;

  @override
  void initState() {
    super.initState();
    _members = List.from(widget.members);
  }

  List<pb.GroupChannelMember> get _adminsAndOwners =>
      _members.where((m) => m.role == 'owner' || m.role == 'admin').toList();

  List<pb.GroupChannelMember> get _regularMembers =>
      _members.where((m) => m.role != 'owner' && m.role != 'admin').toList();

  Future<void> _promoteMember(
    pb.GroupChannelMember member,
    ScaffoldMessengerState messenger,
  ) async {
    final name = member.displayName.isNotEmpty
        ? member.displayName
        : member.username.isNotEmpty
            ? member.username
            : member.userId;
    try {
      await widget.onPromoteAdmin(member.userId);
      if (mounted) {
        setState(() {
          _members = _members.map((m) {
            if (m.userId == member.userId) {
              return m..role = 'admin';
            }
            return m;
          }).toList();
        });
      }
      messenger.showSnackBar(
        SnackBar(content: Text('$name promovido a administrador!')),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Erro ao promover: $e')),
      );
    }
  }

  void _showAddAdminDialog() {
    final regulars = _regularMembers;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Promover Administrador',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                if (regulars.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: Text('Nenhum participante elegível para promoção.'),
                    ),
                  )
                else
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: regulars.length,
                      itemBuilder: (context, index) {
                        final member = regulars[index];
                        final name = member.displayName.isNotEmpty
                            ? member.displayName
                            : member.username.isNotEmpty
                                ? member.username
                                : member.userId;
                        return ListTile(
                          leading: CircleAvatar(
                            child: Text(
                              name.substring(0, 1).toUpperCase(),
                            ),
                          ),
                          title: Text(name),
                          subtitle: Text('@${member.username}'),
                          trailing: const Icon(Icons.add_moderator_rounded),
                          onTap: () {
                            final messenger = ScaffoldMessenger.of(context);
                            Navigator.pop(sheetContext);
                            _promoteMember(member, messenger);
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDemoteAdmin(pb.GroupChannelMember member) {
    final name = member.displayName.isNotEmpty
        ? member.displayName
        : member.username;

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remover Administrador'),
        content: Text('Deseja remover as permissões de administrador de $name?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await widget.onDemoteAdmin(member.userId);
                if (mounted) {
                  setState(() {
                    _members = _members.map((m) {
                      if (m.userId == member.userId) {
                        return m
                          ..role = widget.groupChannel.type == RecipientType.group
                              ? 'member'
                              : 'subscriber';
                      }
                      return m;
                    }).toList();
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Permissões de administrador de $name removidas.'),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro ao rebaixar administrador: $e')),
                  );
                }
              }
            },
            child: const Text('Remover'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final admins = _adminsAndOwners;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Administradores'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          children: [
            AppSectionGroup(
              title: 'ADMINISTRADORES E DONO (${admins.length})',
              children: [
                for (final member in admins) ...[
                  Builder(
                    builder: (context) {
                      final name = member.displayName.isNotEmpty
                          ? member.displayName
                          : member.username.isNotEmpty
                              ? member.username
                              : member.userId;
                      final isOwner = member.role == 'owner';

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: AppAvatar(
                          name: name,
                          imageUrl: member.avatarUrl.isEmpty
                              ? null
                              : member.avatarUrl,
                          radius: 20,
                        ),
                        title: Text(
                          name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle:
                            Text(isOwner ? 'Dono da conversa' : 'Administrador'),
                        trailing: isOwner
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Dono',
                                  style: TextStyle(
                                    color: colorScheme.onPrimaryContainer,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            : IconButton(
                                icon: const Icon(
                                  Icons.remove_circle_outline_rounded,
                                ),
                                color: colorScheme.error,
                                tooltip: 'Remover Administrador',
                                onPressed: () => _confirmDemoteAdmin(member),
                              ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Adicionar Admin'),
        onPressed: _showAddAdminDialog,
      ),
    );
  }
}
