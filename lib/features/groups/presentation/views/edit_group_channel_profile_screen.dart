import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/app/app_runtime.dart';
import '../../../../core/design_system/app_avatar.dart';
import '../../../../core/protocol/recipient.dart';
import '../../../../core/protocol/recipient_type.dart';
import '../../../home/presentation/home_view_model.dart';

/// Screen for Group/Channel Owners & Admins to edit group/channel profile details
/// (Name, Avatar Photo URL, Bio / Description) adhering to AGENTS.md.
class EditGroupChannelProfileScreen extends ConsumerStatefulWidget {
  const EditGroupChannelProfileScreen({
    super.key,
    required this.recipient,
    this.runtime,
  });

  final Recipient recipient;
  final AppRuntime? runtime;

  @override
  ConsumerState<EditGroupChannelProfileScreen> createState() =>
      _EditGroupChannelProfileScreenState();
}

class _EditGroupChannelProfileScreenState
    extends ConsumerState<EditGroupChannelProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _avatarUrlController;
  late final TextEditingController _bioController;
  bool _saving = false;
  bool _loadingMetadata = false;
  bool _metadataLoaded = false;
  String _visibility = 'public';
  Object? _metadataLoadError;

  bool get _isChannel => widget.recipient.type == RecipientType.channel;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.recipient.name);
    _usernameController = TextEditingController(
      text: widget.recipient.handle.replaceFirst(RegExp(r'^@'), ''),
    );
    _avatarUrlController = TextEditingController(
      text: widget.recipient.avatarUrl ?? '',
    );
    _bioController = TextEditingController();
    final runtime = widget.runtime;
    if (runtime != null) {
      _loadingMetadata = true;
      unawaited(_loadMetadata(runtime));
    }
  }

  Future<void> _loadMetadata(AppRuntime runtime) async {
    try {
      final profile = await runtime.loadGroupChannelProfile(
        groupChannelId: widget.recipient.id,
        isChannel: _isChannel,
      );
      if (!mounted) return;
      setState(() {
        _nameController.text = profile.name;
        _usernameController.text = profile.username;
        _avatarUrlController.text = profile.avatarUrl;
        _bioController.text = profile.description;
        _visibility = profile.visibility;
        _metadataLoaded = true;
        _metadataLoadError = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _metadataLoadError = error);
    } finally {
      if (mounted) setState(() => _loadingMetadata = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _avatarUrlController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_metadataLoaded || widget.runtime == null) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      final newName = _nameController.text.trim();
      final newUsername = _usernameController.text.trim().replaceFirst(
        RegExp(r'^@'),
        '',
      );
      final newAvatarUrl = _avatarUrlController.text.trim();
      final newBio = _bioController.text.trim();

      final profile = await widget.runtime!.updateGroupChannelProfile(
        groupChannelId: widget.recipient.id,
        isChannel: _isChannel,
        name: newName,
        username: newUsername,
        description: newBio,
        avatarUrl: newAvatarUrl,
        visibility: _visibility,
      );
      final updated = widget.recipient.copyWith(
        name: profile.name,
        handle: profile.username.isEmpty ? '' : '@${profile.username}',
        isUsernameVisible: profile.username.isNotEmpty,
        avatarUrl: profile.avatarUrl,
        clearAvatarUrl: profile.avatarUrl.isEmpty,
        description: profile.description,
        composerRole: profile.memberRole,
        membersCanSendMessages: profile.membersCanSendMessages,
        membersCanSendMedia: profile.membersCanSendMedia,
        membersCanSendStickersGifs: profile.membersCanSendStickersGifs,
        membersCanEmbedLinks: profile.membersCanEmbedLinks,
        membersCanAddMembers: profile.membersCanAddMembers,
        membersCanChangeInfo: profile.membersCanChangeInfo,
        membersCanReact: profile.membersCanReact,
        membersCanForward: profile.membersCanForward,
        slowModeSeconds: profile.slowModeSeconds,
        memberCount: profile.memberCount.toInt(),
        visibility: profile.visibility,
        canSendMessages:
            profile.memberRole == 'owner' ||
            profile.memberRole == 'admin' ||
            profile.membersCanSendMessages,
      );

      // Persist in SSOT HomeViewModel and LocalStore
      ref.read(homeViewModelProvider.notifier).upsertRecipient(updated);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isChannel
                  ? 'Perfil do canal atualizado!'
                  : 'Perfil do grupo atualizado!',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop(updated);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Não foi possível salvar as alterações: $error'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final previewAvatarUrl = _avatarUrlController.text.trim();

    return Scaffold(
      appBar: AppBar(
        title: Text(_isChannel ? 'Editar Canal' : 'Editar Grupo'),
        actions: [
          IconButton(
            tooltip: 'Salvar',
            onPressed: _saving || _loadingMetadata || !_metadataLoaded
                ? null
                : _save,
            icon: _saving
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Avatar Preview
                Center(
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      AppAvatar(
                        name: _nameController.text.isEmpty
                            ? 'T'
                            : _nameController.text,
                        imageUrl: previewAvatarUrl.isNotEmpty
                            ? previewAvatarUrl
                            : null,
                        radius: 48,
                        type: widget.recipient.type,
                        isExpandable: false,
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Group/Channel Name Field
                TextFormField(
                  controller: _nameController,
                  autofocus: true,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: _isChannel ? 'Nome do Canal' : 'Nome do Grupo',
                    hintText: _isChannel
                        ? 'Ex: Canal de Notícias'
                        : 'Ex: Grupo de Devs',
                    prefixIcon: Icon(
                      _isChannel
                          ? Icons.campaign_rounded
                          : Icons.groups_rounded,
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'O nome é obrigatório.';
                    }
                    return null;
                  },
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _usernameController,
                  autocorrect: false,
                  enableSuggestions: false,
                  textCapitalization: TextCapitalization.none,
                  decoration: const InputDecoration(
                    labelText: 'Nome de usuário',
                    hintText: 'exemplo_grupo',
                    prefixText: '@',
                    prefixIcon: Icon(Icons.alternate_email_rounded),
                    helperText:
                        'Use de 5 a 32 letras, números ou _; precisa ser único.',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final username = (value ?? '').trim().replaceFirst(
                      RegExp(r'^@'),
                      '',
                    );
                    if (username.length < 5 || username.length > 32) {
                      return 'Use de 5 a 32 caracteres.';
                    }
                    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username) ||
                        username.contains('__') ||
                        username.toLowerCase().endsWith('_bot')) {
                      return 'Use letras, números e _ em um formato válido.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Avatar Image URL Field
                TextFormField(
                  controller: _avatarUrlController,
                  keyboardType: TextInputType.url,
                  maxLength: 2048,
                  decoration: InputDecoration(
                    labelText: 'URL da Foto / Avatar (HTTPS)',
                    hintText: 'https://exemplo.com/foto.jpg',
                    prefixIcon: const Icon(Icons.link_rounded),
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),

                // Handle / Description Field
                TextFormField(
                  controller: _bioController,
                  maxLines: 3,
                  maxLength: 150,
                  decoration: InputDecoration(
                    labelText: _isChannel
                        ? 'Descrição do Canal'
                        : 'Descrição do Grupo',
                    hintText: _isChannel
                        ? 'Descreva o objetivo do canal...'
                        : 'Descreva as regras ou assunto do grupo...',
                    prefixIcon: const Icon(Icons.info_outline_rounded),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),

                DropdownButtonFormField<String>(
                  initialValue: _visibility,
                  decoration: const InputDecoration(
                    labelText: 'Visibilidade',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'public', child: Text('Público')),
                    DropdownMenuItem(value: 'private', child: Text('Privado')),
                  ],
                  onChanged: _metadataLoaded
                      ? (value) {
                          if (value != null) {
                            setState(() => _visibility = value);
                          }
                        }
                      : null,
                ),
                if (_loadingMetadata) ...[
                  const SizedBox(height: 16),
                  const LinearProgressIndicator(),
                ],
                if (_metadataLoadError != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Não foi possível carregar os dados do servidor. Tente novamente.',
                    style: TextStyle(color: colorScheme.error),
                  ),
                  TextButton.icon(
                    onPressed: widget.runtime == null || _loadingMetadata
                        ? null
                        : () {
                            setState(() => _loadingMetadata = true);
                            unawaited(_loadMetadata(widget.runtime!));
                          },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tentar novamente'),
                  ),
                ],

                // Information box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? colorScheme.surfaceContainerHigh
                        : colorScheme.primaryContainer.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        size: 20,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _isChannel
                              ? 'Apenas administradores e o proprietário do canal podem alterar estas informações.'
                              : 'Apenas administradores e o proprietário do grupo podem alterar estas informações.',
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
