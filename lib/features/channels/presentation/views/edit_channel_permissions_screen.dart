import 'package:flutter/material.dart';

import '../../../../core/design_system/app_section_group.dart';
import '../../../../core/protocol/recipient.dart';
import '../../../../generated/proto/tureon.pb.dart' as pb;
import '../../../../l10n/app_localizations_extensions.dart';
import '../../../groups/presentation/views/manage_admins_screen.dart';

/// Screen for managing persisted channel subscriber permissions and admins.
/// styled with clean, borderless AppSectionGroup components.
class EditChannelPermissionsScreen extends StatefulWidget {
  const EditChannelPermissionsScreen({
    super.key,
    required this.channel,
    this.members = const [],
    this.onSavePermissions,
    this.onPromoteAdmin,
    this.onDemoteAdmin,
    this.onTransferOwnership,
  });

  final Recipient channel;
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
  State<EditChannelPermissionsScreen> createState() =>
      _EditChannelPermissionsScreenState();
}

class _EditChannelPermissionsScreenState
    extends State<EditChannelPermissionsScreen> {
  static const _slowModePresets = [0, 5, 10, 30, 60, 300, 900, 3600];

  late bool _canReactions;
  late bool _canForwardPosts;
  late bool _membersCanSendMessages;
  late int _slowModeSeconds;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _canReactions = widget.channel.membersCanReact;
    _canForwardPosts = widget.channel.membersCanForward;
    _membersCanSendMessages = widget.channel.membersCanSendMessages;
    _slowModeSeconds = widget.channel.slowModeSeconds.clamp(0, 3600).toInt();
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
        'send_messages': _membersCanSendMessages,
        'can_reactions': _canReactions,
        'can_forward': _canForwardPosts,
      }, _slowModeSeconds);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permissões do canal salvas!')),
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
            'Sua conta precisa de permissão para gerenciar admins do canal.',
          ),
        ),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ManageAdminsScreen(
          groupChannel: widget.channel,
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
        title: const Text('Permissões do Canal'),
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
              title: 'PERMISSÕES DE INSCRITOS E CONTEÚDO',
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  secondary: const Icon(Icons.campaign_outlined),
                  title: Text(
                    context.safeLocalizations.channelSubscribersCanPublishTitle,
                  ),
                  subtitle: Text(
                    context
                        .safeLocalizations
                        .channelSubscribersCanPublishSubtitle,
                  ),
                  value: _membersCanSendMessages,
                  onChanged: (value) =>
                      setState(() => _membersCanSendMessages = value),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  secondary: const Icon(Icons.add_reaction_outlined),
                  title: const Text('Reações com Emojis'),
                  subtitle: const Text(
                    'Permitir reações em mensagens enviadas',
                  ),
                  value: _canReactions,
                  onChanged: (v) => setState(() => _canReactions = v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  secondary: const Icon(Icons.shortcut_rounded),
                  title: const Text('Encaminhar Publicações'),
                  subtitle: const Text(
                    'Permitir cópia e encaminhamento de posts',
                  ),
                  value: _canForwardPosts,
                  onChanged: (v) => setState(() => _canForwardPosts = v),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.timer_outlined),
                  title: const Text('Intervalo entre publicações'),
                  subtitle: const Text(
                    'Inscritos aguardam esse tempo entre envios. '
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
              ],
            ),
            const SizedBox(height: 16),
            AppSectionGroup(
              title: 'ADMINISTRADORES E GERENCIAMENTO',
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.admin_panel_settings_outlined),
                  title: const Text('Administradores do Canal'),
                  subtitle: Text(
                    '${widget.members.where((m) => m.role == 'admin' || m.role == 'owner').length} administradores com direitos de publicação',
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

  String _slowModeLabel(int seconds) {
    if (seconds == 0) return 'Desativado';
    if (seconds < 60) return '$seconds s';
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    if (remainingSeconds == 0) return '$minutes min';
    return '$minutes min $remainingSeconds s';
  }
}
