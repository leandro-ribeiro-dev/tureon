import 'package:flutter/material.dart';

import '../../../../core/design_system/app_section_group.dart';
import '../../../../core/protocol/recipient.dart';
import '../../../../generated/proto/tureon.pb.dart' as pb;
import '../../../../l10n/app_localizations_extensions.dart';
import 'manage_admins_screen.dart';

/// Screen for managing persisted group member permissions and admin rights.
/// styled with clean, borderless AppSectionGroup components.
class EditGroupPermissionsScreen extends StatefulWidget {
  const EditGroupPermissionsScreen({
    super.key,
    required this.group,
    this.members = const [],
    this.onSavePermissions,
    this.onPromoteAdmin,
    this.onDemoteAdmin,
    this.onTransferOwnership,
  });

  final Recipient group;
  final List<pb.GroupChannelMember> members;
  final Future<void> Function(
    Map<String, bool> permissions,
    int slowModeSeconds,
  )?
  onSavePermissions;
  final Future<void> Function(String userId)? onPromoteAdmin;
  final Future<void> Function(String userId)? onDemoteAdmin;
  final Future<void> Function(String userId)? onTransferOwnership;

  @override
  State<EditGroupPermissionsScreen> createState() =>
      _EditGroupPermissionsScreenState();
}

class _EditGroupPermissionsScreenState
    extends State<EditGroupPermissionsScreen> {
  static const _slowModePresets = [0, 5, 10, 30, 60, 300, 900, 3600];

  late bool _canSendMessages;
  late bool _canSendMedia;
  late bool _canSendStickersGifs;
  late bool _canEmbedLinks;
  late bool _canAddMembers;
  late bool _canChangeInfo;
  late int _slowModeSeconds;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _canSendMessages = widget.group.membersCanSendMessages;
    _canSendMedia = widget.group.membersCanSendMedia;
    _canSendStickersGifs = widget.group.membersCanSendStickersGifs;
    _canEmbedLinks = widget.group.membersCanEmbedLinks;
    _canAddMembers = widget.group.membersCanAddMembers;
    _canChangeInfo = widget.group.membersCanChangeInfo;
    _slowModeSeconds = widget.group.slowModeSeconds.clamp(0, 3600).toInt();
  }

  Future<void> _save() async {
    final save = widget.onSavePermissions;
    if (save == null) {
      Navigator.pop(context);
      return;
    }
    setState(() => _isSaving = true);
    try {
      await save({
        'send_messages': _canSendMessages,
        'send_media': _canSendMedia,
        'send_stickers': _canSendStickersGifs,
        'embed_links': _canEmbedLinks,
        'add_members': _canAddMembers,
        'change_info': _canChangeInfo,
      }, _slowModeSeconds);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permissões do grupo salvas!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar permissões: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _openManageAdmins() {
    if (widget.onPromoteAdmin == null || widget.onDemoteAdmin == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Sua conta precisa de permissão para gerenciar admins.',
          ),
        ),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ManageAdminsScreen(
          groupChannel: widget.group,
          members: widget.members,
          onPromoteAdmin: widget.onPromoteAdmin!,
          onDemoteAdmin: widget.onDemoteAdmin!,
          onTransferOwnership: widget.onTransferOwnership ?? (_) async {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final slowModeOptions = <int>{
      ..._slowModePresets,
      _slowModeSeconds,
    }.toList()..sort();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Permissões do Grupo'),
        actions: [
          IconButton(
            tooltip: 'Salvar',
            icon: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check_rounded),
            onPressed: _isSaving ? null : _save,
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          children: [
            AppSectionGroup(
              title: 'O QUE OS PARTICIPANTES PODEM FAZER',
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  secondary: const Icon(Icons.chat_bubble_outline_rounded),
                  title: Text(
                    context.safeLocalizations.groupMembersCanSendMessagesTitle,
                  ),
                  subtitle: Text(
                    context
                        .safeLocalizations
                        .groupMembersCanSendMessagesSubtitle,
                  ),
                  value: _canSendMessages,
                  onChanged: (v) => setState(() => _canSendMessages = v),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.timer_outlined),
                  title: const Text('Intervalo entre mensagens'),
                  subtitle: const Text(
                    'Os participantes aguardam esse tempo entre envios. '
                    'Administradores e proprietários não aguardam.',
                  ),
                  trailing: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _slowModeSeconds,
                      items: slowModeOptions
                          .map(
                            (seconds) => DropdownMenuItem<int>(
                              value: seconds,
                              child: Text(_slowModeLabel(seconds)),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: _isSaving
                          ? null
                          : (seconds) {
                              if (seconds != null) {
                                setState(() => _slowModeSeconds = seconds);
                              }
                            },
                    ),
                  ),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  secondary: const Icon(Icons.photo_library_outlined),
                  title: const Text('Enviar Mídias e Fotos'),
                  value: _canSendMedia,
                  onChanged: (v) => setState(() => _canSendMedia = v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  secondary: const Icon(Icons.sticky_note_2_outlined),
                  title: const Text('Enviar Figurinhas e GIFs'),
                  value: _canSendStickersGifs,
                  onChanged: (v) => setState(() => _canSendStickersGifs = v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  secondary: const Icon(Icons.link_rounded),
                  title: const Text('Enviar links'),
                  subtitle: const Text('Permitir links em mensagens de texto'),
                  value: _canEmbedLinks,
                  onChanged: (v) => setState(() => _canEmbedLinks = v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  secondary: const Icon(Icons.person_add_outlined),
                  title: const Text('Adicionar Participantes'),
                  value: _canAddMembers,
                  onChanged: (v) => setState(() => _canAddMembers = v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  secondary: const Icon(Icons.edit_outlined),
                  title: const Text('Alterar Dados do Grupo'),
                  subtitle: const Text('Nome, foto e descrição do grupo'),
                  value: _canChangeInfo,
                  onChanged: (v) => setState(() => _canChangeInfo = v),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AppSectionGroup(
              title: 'ADMINISTRADORES E POSSE',
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.admin_panel_settings_outlined),
                  title: const Text('Administradores do Grupo'),
                  subtitle: Text(
                    '${widget.members.where((m) => m.role == 'admin' || m.role == 'owner').length} administradores',
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: _openManageAdmins,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _slowModeLabel(int seconds) {
    if (seconds == 0) return 'Desativado';
    if (seconds == 3600) return '1 hora';
    if (seconds % 60 == 0) return '${seconds ~/ 60} min';
    return '$seconds s';
  }
}
