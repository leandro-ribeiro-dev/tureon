import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/app/app_runtime.dart';
import '../../../../core/design_system/app_avatar.dart';
import '../../../../core/design_system/app_bottom_sheet.dart';
import '../../../../core/design_system/compact_count.dart';
import '../../../../core/design_system/shared_media_showcase.dart';
import '../../../../core/protocol/recipient.dart';
import '../../../../core/protocol/recipient_type.dart';
import '../../../../generated/proto/tureon.pb.dart' as pb;
import '../../../../l10n/app_localizations_extensions.dart';
import '../../../channels/presentation/views/edit_channel_permissions_screen.dart';
import '../../../groups/presentation/views/edit_group_channel_profile_screen.dart';
import '../../../groups/presentation/views/edit_group_permissions_screen.dart';
import '../../../home/domain/home_repository.dart';
import '../../../home/home_providers.dart';
import '../../../profile/presentation/widgets/profile_header_card.dart';
import '../../../profile/presentation/widgets/profile_qr_code_sheet.dart';

/// Contact Profile Screen styled identically to MyProfileScreen (View 3 hero layout):
/// Top hero section with ProfileHeaderCard, action buttons in primaryContainer,
/// clean borderless info fields, shared media showcase, and member management.
class ContactProfileScreen extends ConsumerStatefulWidget {
  const ContactProfileScreen({
    super.key,
    this.recipientId = '',
    Recipient? recipient,
    this.runtime,
    required this.onBack,
    required this.onOpenChat,
    required this.onOpenSecretChat,
    this.onLeftGroupChannel,
    this.bio = '',
    this.birthDate,
    this.phone = '',
    this.isBioVisible = false,
    this.isPhoneVisible = false,
    this.isBirthDateVisible = false,
    this.isSecret = false,
  }) : initialRecipient = recipient;

  final String recipientId;
  final Recipient? initialRecipient;
  final AppRuntime? runtime;
  final VoidCallback onBack;
  final ValueChanged<Recipient> onOpenChat;
  final ValueChanged<Recipient> onOpenSecretChat;
  final ValueChanged<Recipient>? onLeftGroupChannel;
  final String bio;
  final String? birthDate;
  final String phone;
  final bool isBioVisible;
  final bool isPhoneVisible;
  final bool isBirthDateVisible;
  final bool isSecret;

  @override
  ConsumerState<ContactProfileScreen> createState() =>
      _ContactProfileScreenState();
}

class _ContactProfileScreenState extends ConsumerState<ContactProfileScreen> {
  bool _isMuted = false;
  Recipient? _recipient;
  Future<pb.ListGroupChannelMembersPageResponse>? _membersFuture;
  pb.ListGroupChannelMembersPageResponse? _membersPage;
  List<pb.GroupChannelMember> _members = const [];
  int _memberOffset = 0;
  int _memberTotalCount = 0;
  int _membersLoadGeneration = 0;
  bool _membersHaveMore = false;
  bool _loadingMoreMembers = false;
  int? _onlineMemberCount;
  Timer? _onlineMemberCountRefreshTimer;
  bool _refreshingOnlineMemberCount = false;
  int _onlineMemberCountGeneration = 0;
  bool _leavingGroupChannel = false;
  StreamSubscription<Recipient?>? _recipientSubscription;

  @override
  void initState() {
    super.initState();
    _recipient = widget.initialRecipient;
    final recipient = _recipient;
    if (recipient != null && _isGroupChannel(recipient)) {
      _memberTotalCount = recipient.memberCount;
      _membersFuture = _loadMembers(recipient);
      _startOnlineGroupCountRefresh(recipient);
    }
    final effectiveId = widget.recipientId.isNotEmpty
        ? widget.recipientId
        : widget.initialRecipient?.id ?? '';
    if (effectiveId.isNotEmpty) {
      HomeRepository? repository;
      try {
        repository = ref.read(homeRepositoryProvider);
      } catch (_) {
        repository = null;
      }
      if (repository != null) {
        _recipientSubscription = repository.watchRecipient(effectiveId).listen((
          recipient,
        ) {
          if (!mounted || recipient == null) return;
          final previous = _recipient;
          final changed =
              previous?.id != recipient.id || previous?.type != recipient.type;
          final membershipSnapshotAdvanced =
              !changed &&
              _isGroupChannel(recipient) &&
              recipient.roomVersion > (previous?.roomVersion ?? 0);
          setState(() {
            _recipient = recipient;
            if (changed) {
              _membersLoadGeneration++;
              _members = const [];
              _membersPage = null;
              _memberOffset = 0;
              _memberTotalCount = recipient.memberCount;
              _membersHaveMore = false;
              _onlineMemberCount = null;
              if (_isGroupChannel(recipient)) {
                _membersFuture = _loadMembers(recipient);
                _startOnlineGroupCountRefresh(recipient);
              } else {
                _membersFuture = null;
                _stopOnlineGroupCountRefresh();
              }
            } else if (membershipSnapshotAdvanced) {
              _memberTotalCount = recipient.memberCount;
              _membersFuture = _loadMembers(recipient, forceRefresh: true);
              unawaited(_refreshGroupOnlineCount(recipient));
            }
          });
        });
      }
    }
  }

  @override
  void dispose() {
    _membersLoadGeneration++;
    _recipientSubscription?.cancel();
    _stopOnlineGroupCountRefresh();
    super.dispose();
  }

  void _copyToClipboard(String text, String label) {
    if (text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copiado para a área de transferência!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openPermissionsScreen(Recipient recipient) {
    if (widget.runtime?.canWriteAccount == false) return;
    final members = List<pb.GroupChannelMember>.unmodifiable(_members);
    final runtime = widget.runtime;
    if (recipient.type == RecipientType.group) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => EditGroupPermissionsScreen(
            group: recipient,
            members: members,
            onSavePermissions: runtime == null
                ? null
                : (permissions, slowModeSeconds) async {
                    await runtime.updateGroupChannelPermissions(
                      groupChannelId: recipient.id,
                      isChannel: false,
                      permissions: permissions,
                      slowModeSeconds: slowModeSeconds,
                    );
                  },
            onPromoteAdmin: (userId) async {
              await widget.runtime?.updateGroupChannelMemberRole(
                groupChannelId: recipient.id,
                userId: userId,
                role: 'admin',
              );
            },
            onDemoteAdmin: (userId) async {
              await widget.runtime?.updateGroupChannelMemberRole(
                groupChannelId: recipient.id,
                userId: userId,
                role: 'member',
              );
            },
          ),
        ),
      );
    } else if (recipient.type == RecipientType.channel) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => EditChannelPermissionsScreen(
            channel: recipient,
            members: members,
            onSavePermissions: runtime == null
                ? null
                : (permissions, slowModeSeconds) async {
                    await runtime.updateGroupChannelPermissions(
                      groupChannelId: recipient.id,
                      isChannel: true,
                      permissions: permissions,
                      slowModeSeconds: slowModeSeconds,
                    );
                  },
            onPromoteAdmin: (userId) async {
              await widget.runtime?.updateGroupChannelMemberRole(
                groupChannelId: recipient.id,
                userId: userId,
                role: 'admin',
              );
            },
            onDemoteAdmin: (userId) async {
              await widget.runtime?.updateGroupChannelMemberRole(
                groupChannelId: recipient.id,
                userId: userId,
                role: 'subscriber',
              );
            },
          ),
        ),
      );
    }
  }

  void _openEditGroupChannel(Recipient recipient) {
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => EditGroupChannelProfileScreen(
          recipient: recipient,
          runtime: widget.runtime,
        ),
      ),
    );
  }

  Future<pb.ListGroupChannelMembersPageResponse>? _loadMembers(
    Recipient recipient, {
    bool forceRefresh = false,
  }) {
    final runtime = widget.runtime;
    if (runtime == null) return null;
    final loadGeneration = ++_membersLoadGeneration;
    final cached = forceRefresh
        ? null
        : runtime.loadCachedGroupChannelMembersPage(
            groupChannelId: recipient.id,
            offset: 0,
          );
    if (cached != null &&
        loadGeneration == _membersLoadGeneration &&
        _recipient?.id == recipient.id) {
      _membersPage = cached;
      _members = cached.members;
      _memberOffset = cached.nextOffset.toInt();
      _memberTotalCount = cached.totalCount.toInt();
      _membersHaveMore = cached.hasMore;
      _recipient = _recipient!.copyWith(memberCount: _memberTotalCount);
    }
    return runtime
        .listGroupChannelMembersPage(
          groupChannelId: recipient.id,
          offset: 0,
          forceRefresh: forceRefresh,
        )
        .then((page) {
          if (mounted &&
              loadGeneration == _membersLoadGeneration &&
              _recipient?.id == recipient.id) {
            final updatedRecipient = _recipient!.copyWith(
              memberCount: page.totalCount.toInt(),
            );
            setState(() {
              _membersPage = page;
              _recipient = updatedRecipient;
              _members = page.members;
              _memberOffset = page.nextOffset.toInt();
              _memberTotalCount = page.totalCount.toInt();
              _membersHaveMore = page.hasMore;
            });
          }
          return page;
        });
  }

  Future<void> _loadMoreMembers(Recipient recipient) async {
    final runtime = widget.runtime;
    if (runtime == null || _loadingMoreMembers || !_membersHaveMore) return;
    setState(() => _loadingMoreMembers = true);
    try {
      final page = await runtime.listGroupChannelMembersPage(
        groupChannelId: recipient.id,
        offset: _memberOffset,
      );
      if (!mounted || _recipient?.id != recipient.id) return;
      final updatedRecipient = _recipient!.copyWith(
        memberCount: page.totalCount.toInt(),
      );
      setState(() {
        _recipient = updatedRecipient;
        _members = [..._members, ...page.members];
        _memberOffset = page.nextOffset.toInt();
        _memberTotalCount = page.totalCount.toInt();
        _membersHaveMore = page.hasMore;
      });
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Não foi possível carregar participantes: $error'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loadingMoreMembers = false);
    }
  }

  Future<void> _refreshGroupOnlineCount(Recipient recipient) async {
    final runtime = widget.runtime;
    final generation = _onlineMemberCountGeneration;
    if (recipient.type != RecipientType.group ||
        runtime == null ||
        _refreshingOnlineMemberCount) {
      return;
    }
    _refreshingOnlineMemberCount = true;
    try {
      final count = await runtime.loadOnlineGroupMemberCount(
        groupId: recipient.id,
      );
      if (mounted &&
          generation == _onlineMemberCountGeneration &&
          _recipient?.id == recipient.id) {
        setState(() => _onlineMemberCount = count);
      }
    } catch (_) {
      // A presence snapshot is optional and does not block the profile view.
    } finally {
      if (generation == _onlineMemberCountGeneration) {
        _refreshingOnlineMemberCount = false;
      }
    }
  }

  void _startOnlineGroupCountRefresh(Recipient recipient) {
    _stopOnlineGroupCountRefresh();
    if (recipient.type != RecipientType.group) return;
    unawaited(_refreshGroupOnlineCount(recipient));
    _onlineMemberCountRefreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) {
        final current = _recipient;
        if (current != null) unawaited(_refreshGroupOnlineCount(current));
      },
    );
  }

  void _stopOnlineGroupCountRefresh() {
    _onlineMemberCountGeneration++;
    _refreshingOnlineMemberCount = false;
    _onlineMemberCountRefreshTimer?.cancel();
    _onlineMemberCountRefreshTimer = null;
  }

  Future<void> _leaveGroupChannel(Recipient recipient) async {
    final runtime = widget.runtime;
    if (runtime == null || _leavingGroupChannel) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          recipient.type == RecipientType.group
              ? 'Sair do grupo?'
              : 'Sair do canal?',
        ),
        content: const Text(
          'Você poderá entrar novamente se o espaço continuar público.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _leavingGroupChannel = true);
    try {
      await runtime.leaveGroupChannel(groupChannelId: recipient.id);
      if (!mounted) return;
      if (widget.onLeftGroupChannel != null) {
        widget.onLeftGroupChannel!(recipient);
      } else {
        widget.onBack();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Não foi possível sair: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _leavingGroupChannel = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final glassToken = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final headerColor = colorScheme.surfaceContainer;
    final isDark = theme.brightness == Brightness.dark;

    final recipient = _recipient;
    if (recipient == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: context.safeLocalizations.profileBack,
            onPressed: widget.onBack,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final isOwnerOrAdmin =
        recipient.composerRole == 'owner' || recipient.composerRole == 'admin';
    final canManageGroupChannel =
        isOwnerOrAdmin && widget.runtime?.canWriteAccount != false;
    final canEditGroupInfo =
        (isOwnerOrAdmin ||
            (recipient.type == RecipientType.group &&
                recipient.isMember &&
                recipient.membersCanChangeInfo)) &&
        widget.runtime?.canWriteAccount != false;

    final String cardSubtitle = switch (recipient.type) {
      RecipientType.bot =>
        recipient.description.isNotEmpty
            ? recipient.description
            : context.safeLocalizations.profileSubtitleBot,
      RecipientType.group =>
        '${_onlineMemberCount == null ? (recipient.visibility == 'private' ? 'Grupo privado' : 'Grupo público') : '${formatCompactCount(_onlineMemberCount!)} online'}${recipient.memberCount > 0 ? ' • ${formatCompactCount(recipient.memberCount)} participantes' : ''}',
      RecipientType.channel =>
        'Canal ${recipient.visibility == 'private' ? 'privado' : 'público'} • ${formatCompactCount(recipient.memberCount)} inscritos',
      _ => recipient.isUsernameVisible ? _handleLabel(recipient.handle) : '',
    };

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: headerColor,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: headerColor,
        appBar: AppBar(
          backgroundColor: headerColor,
          elevation: 0,
          leading: IconButton(
            tooltip: context.safeLocalizations.profileBack,
            onPressed: widget.onBack,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          title: Text(_profileTitle(recipient.type)),
        ),
        body: SafeArea(
          child: Material(
            color: glassToken.surface,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Hero Card Header (identical to MyProfileScreen style)
                  ProfileHeaderCard(
                    profile: null,
                    displayName: recipient.name,
                    userId: recipient.id,
                    subtitle: cardSubtitle,
                    type: recipient.type,
                    canEdit:
                        canEditGroupInfo &&
                        (recipient.type == RecipientType.group ||
                            recipient.type == RecipientType.channel),
                    onEdit: () => _openEditGroupChannel(recipient),
                    showSecurityIcon: widget.isSecret,
                    securityLabel: 'Chat Secreto (E2EE)',
                    securityDialogTitle: 'Chat Secreto Criptografado',
                    securityDialogMessage:
                        'Esta conversa é um Chat Secreto protegido por criptografia ponta a ponta (Signal Protocol). Todas as mensagens e mídias são codificadas no seu dispositivo e somente você e este contato possuem as chaves para decodificá-las. Está tudo OK e 100% seguro!',
                    onShowQrCode: () {
                      AppBottomSheet.show<void>(
                        context: context,
                        builder: (_) => ProfileQrCodeBottomSheet(profile: null),
                      );
                    },
                  ),

                  // Action Buttons Row (identical to MyProfileScreen)
                  Container(
                    color: headerColor,
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            context,
                            icon: Icons.chat_outlined,
                            label: context.safeLocalizations.sendMessage,
                            onTap: () => widget.onOpenChat(recipient),
                          ),
                        ),
                        if (recipient.type == RecipientType.user) ...[
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildActionButton(
                              context,
                              icon: Icons.lock_outline_rounded,
                              label: 'Chat Secreto',
                              onTap: () => widget.onOpenSecretChat(recipient),
                            ),
                          ),
                        ],
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildActionButton(
                            context,
                            icon: _isMuted
                                ? Icons.notifications_off_outlined
                                : Icons.notifications_outlined,
                            label: _isMuted ? 'Silenciado' : 'Silenciar',
                            onTap: () => setState(() => _isMuted = !_isMuted),
                          ),
                        ),
                        if (canManageGroupChannel &&
                            _isGroupChannel(recipient)) ...[
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildActionButton(
                              context,
                              icon: Icons.tune_rounded,
                              label: 'Permissões',
                              onTap: () => _openPermissionsScreen(recipient),
                            ),
                          ),
                        ],
                        if (_isGroupChannel(recipient) &&
                            recipient.isMember &&
                            recipient.composerRole != 'owner') ...[
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildActionButton(
                              context,
                              icon: Icons.logout_rounded,
                              label: _leavingGroupChannel ? 'Saindo…' : 'Sair',
                              onTap: _leavingGroupChannel
                                  ? () {}
                                  : () => _leaveGroupChannel(recipient),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Info & Privacy Section (identical to MyProfileScreen style)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'INFORMAÇÕES E PRIVACIDADE',
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: glassToken.onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(height: 8),
                        if (recipient.isOfficial) ...[
                          _buildInfoField(
                            context,
                            icon: Icons.verified_rounded,
                            title: 'Espaço oficial do Tureon',
                            subtitle: 'Conta oficial',
                          ),
                          Divider(color: glassToken.outlineVariant, height: 1),
                        ],
                        if (_isGroupChannel(recipient)) ...[
                          _buildInfoField(
                            context,
                            icon: recipient.type == RecipientType.group
                                ? Icons.groups_2_outlined
                                : Icons.campaign_outlined,
                            title: recipient.visibility == 'private'
                                ? 'Privado'
                                : 'Público',
                            subtitle: recipient.type == RecipientType.group
                                ? 'Grupo • ${_memberRoleLabel(recipient.composerRole)}'
                                : 'Canal • ${_memberRoleLabel(recipient.composerRole)}',
                          ),
                          Divider(color: glassToken.outlineVariant, height: 1),
                        ],
                        if (recipient.description.isNotEmpty &&
                            (recipient.type == RecipientType.group ||
                                recipient.type == RecipientType.channel)) ...[
                          _buildInfoField(
                            context,
                            icon: Icons.info_outline_rounded,
                            title: recipient.description,
                            subtitle: 'Descrição',
                            onTap: () => _copyToClipboard(
                              recipient.description,
                              'Descrição',
                            ),
                          ),
                          Divider(color: glassToken.outlineVariant, height: 1),
                        ],
                        if (recipient.isUsernameVisible &&
                            recipient.handle.isNotEmpty) ...[
                          _buildInfoField(
                            context,
                            icon: Icons.alternate_email_rounded,
                            title: recipient.handle.startsWith('@')
                                ? recipient.handle
                                : '@${recipient.handle}',
                            subtitle: 'Nome de usuário',
                            onTap: () => _copyToClipboard(
                              recipient.handle,
                              'Nome de usuário',
                            ),
                          ),
                          Divider(color: glassToken.outlineVariant, height: 1),
                        ],
                        if (widget.isPhoneVisible &&
                            widget.phone.isNotEmpty) ...[
                          _buildInfoField(
                            context,
                            icon: Icons.phone_outlined,
                            title: widget.phone,
                            subtitle: 'Celular',
                            onTap: () =>
                                _copyToClipboard(widget.phone, 'Telefone'),
                          ),
                          Divider(color: glassToken.outlineVariant, height: 1),
                        ],
                        if (widget.isBioVisible && widget.bio.isNotEmpty) ...[
                          _buildInfoField(
                            context,
                            icon: Icons.info_outline_rounded,
                            title: widget.bio,
                            subtitle: 'Bio',
                            onTap: () => _copyToClipboard(widget.bio, 'Bio'),
                          ),
                          Divider(color: glassToken.outlineVariant, height: 1),
                        ],
                        if (widget.isBirthDateVisible &&
                            widget.birthDate != null &&
                            widget.birthDate!.isNotEmpty) ...[
                          _buildInfoField(
                            context,
                            icon: Icons.cake_outlined,
                            title: widget.birthDate!,
                            subtitle: 'Aniversário',
                          ),
                          Divider(color: glassToken.outlineVariant, height: 1),
                        ],

                        // Members / Subscribers Section for Group/Channel
                        if (_isGroupChannel(recipient)) ...[
                          const SizedBox(height: 24),
                          _memberList(recipient),
                        ],

                        const SizedBox(height: 24),

                        // Shared Media Section
                        const SharedMediaShowcase(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 84),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 9),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: colorScheme.onPrimaryContainer, size: 22),
                const SizedBox(height: 5),
                Text(
                  label,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.1,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoField(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final glassToken = theme.colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          child: Row(
            children: [
              Icon(icon, size: 22, color: glassToken.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: glassToken.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: glassToken.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.copy_rounded,
                  size: 16,
                  color: glassToken.onSurfaceVariant.withValues(alpha: 0.5),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _memberList(Recipient recipient) {
    final glassToken = Theme.of(context).colorScheme;
    final future = _membersFuture;
    if (future == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          context.safeLocalizations.profileConnectToSeeMembers,
          style: TextStyle(color: glassToken.onSurfaceVariant, fontSize: 14),
        ),
      );
    }
    return FutureBuilder<pb.ListGroupChannelMembersPageResponse>(
      future: future,
      builder: (context, snapshot) {
        final l10n = context.safeLocalizations;
        if (snapshot.connectionState == ConnectionState.waiting &&
            _membersPage == null) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError && _membersPage == null) {
          return Row(
            children: [
              Expanded(
                child: Text(
                  l10n.profileMembersLoadFailed,
                  style: TextStyle(color: glassToken.error, fontSize: 14),
                ),
              ),
              IconButton(
                tooltip: l10n.profileRetry,
                onPressed: () => setState(
                  () => _membersFuture = _loadMembers(
                    recipient,
                    forceRefresh: true,
                  ),
                ),
                icon: const Icon(Icons.refresh),
              ),
            ],
          );
        }
        final page = _membersPage ?? snapshot.data;
        final members = _members.isNotEmpty
            ? _members
            : page?.members ?? const <pb.GroupChannelMember>[];
        final totalCount = _memberTotalCount > 0
            ? _memberTotalCount
            : page?.totalCount.toInt() ?? recipient.memberCount;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              (recipient.type == RecipientType.group
                      ? l10n.profileMembersCount(totalCount)
                      : l10n.profileSubscribersCount(totalCount))
                  .toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: glassToken.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            if (members.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  l10n.profileEmptyMembers,
                  style: TextStyle(
                    color: glassToken.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
              )
            else
              for (final member in members) _memberTile(recipient, member),
            if (_membersHaveMore) ...[
              const SizedBox(height: 8),
              Center(
                child: OutlinedButton.icon(
                  onPressed: _loadingMoreMembers
                      ? null
                      : () => _loadMoreMembers(recipient),
                  icon: _loadingMoreMembers
                      ? const SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.expand_more_rounded),
                  label: Text(
                    _loadingMoreMembers
                        ? 'Carregando…'
                        : 'Ver mais participantes',
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _memberTile(Recipient recipient, pb.GroupChannelMember member) {
    final glassToken = Theme.of(context).colorScheme;
    final name = member.displayName.isNotEmpty
        ? member.displayName
        : member.username.isNotEmpty
        ? member.username
        : member.userId;
    final avatarRecipient = Recipient(
      id: member.userId,
      type: RecipientType.user,
      name: name,
      handle: member.username,
      avatarUrl: member.avatarUrl.isEmpty ? null : member.avatarUrl,
    );
    final actions = _memberActions(recipient, member);
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: AppAvatar.fromRecipient(avatarRecipient, radius: 20),
          title: Text(
            name,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: glassToken.onSurface,
            ),
          ),
          subtitle: Text(
            _memberRoleLabel(member.role),
            style: TextStyle(fontSize: 13, color: glassToken.onSurfaceVariant),
          ),
          trailing: actions.isEmpty
              ? null
              : PopupMenuButton<_MemberAction>(
                  tooltip: context.safeLocalizations.profileParticipantActions,
                  onSelected: (action) =>
                      _handleMemberAction(recipient, member, action),
                  itemBuilder: (context) => [
                    for (final action in actions)
                      PopupMenuItem(
                        value: action,
                        child: Text(_memberActionLabel(action)),
                      ),
                  ],
                ),
        ),
        Divider(color: glassToken.outlineVariant, height: 1),
      ],
    );
  }

  List<_MemberAction> _memberActions(
    Recipient recipient,
    pb.GroupChannelMember member,
  ) {
    final currentUserId = widget.runtime?.currentUserId;
    if (member.userId == currentUserId && member.role != 'owner') {
      return [_MemberAction.remove];
    }
    final isOwner = recipient.composerRole == 'owner';
    final isAdmin = recipient.composerRole == 'admin';
    if (!isOwner && !isAdmin) return const [];
    if (member.role == 'owner' || (isAdmin && member.role == 'admin')) {
      return const [];
    }
    return [
      if (isOwner && member.role != 'admin') _MemberAction.promote,
      if (isOwner && member.role == 'admin') _MemberAction.demote,
      _MemberAction.remove,
      _MemberAction.ban,
    ];
  }

  Future<void> _handleMemberAction(
    Recipient recipient,
    pb.GroupChannelMember member,
    _MemberAction action,
  ) async {
    final runtime = widget.runtime;
    if (runtime == null) return;
    final isSelf = member.userId == runtime.currentUserId;
    final l10n = context.safeLocalizations;
    if (action == _MemberAction.remove || action == _MemberAction.ban) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(
            isSelf
                ? l10n.profileLeaveTitle
                : action == _MemberAction.ban
                ? l10n.profileBanTitle
                : l10n.profileRemoveTitle,
          ),
          content: Text(
            isSelf
                ? l10n.profileLeaveBody
                : l10n.profileRemoveBody(
                    member.displayName.isEmpty
                        ? member.username
                        : member.displayName,
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.actionCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.profileConfirm),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }
    try {
      switch (action) {
        case _MemberAction.promote:
          await runtime.updateGroupChannelMemberRole(
            groupChannelId: recipient.id,
            userId: member.userId,
            role: 'admin',
          );
        case _MemberAction.demote:
          await runtime.updateGroupChannelMemberRole(
            groupChannelId: recipient.id,
            userId: member.userId,
            role: recipient.type == RecipientType.group
                ? 'member'
                : 'subscriber',
          );
        case _MemberAction.remove:
          if (isSelf) {
            await runtime.leaveGroupChannel(groupChannelId: recipient.id);
          } else {
            await runtime.removeGroupChannelMember(
              groupChannelId: recipient.id,
              userId: member.userId,
            );
          }
        case _MemberAction.ban:
          await runtime.banGroupChannelMember(
            groupChannelId: recipient.id,
            userId: member.userId,
          );
      }
      if (!mounted) return;
      if (isSelf && action == _MemberAction.remove) {
        if (widget.onLeftGroupChannel != null) {
          widget.onLeftGroupChannel!(recipient);
        } else {
          widget.onBack();
        }
        return;
      }
      setState(() {
        _members = const [];
        _membersPage = null;
        _memberOffset = 0;
        _memberTotalCount = recipient.memberCount;
        _membersHaveMore = false;
        _membersFuture = _loadMembers(recipient, forceRefresh: true);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_memberActionSuccess(action, isSelf))),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.profileActionFailed(error.toString()))),
        );
      }
    }
  }

  bool _isGroupChannel(Recipient recipient) =>
      recipient.type == RecipientType.group ||
      recipient.type == RecipientType.channel;

  String _profileTitle(RecipientType type) {
    final l10n = context.safeLocalizations;
    return switch (type) {
      RecipientType.group => l10n.profileGroupTitle,
      RecipientType.channel => l10n.profileChannelTitle,
      RecipientType.bot => l10n.profileBotTitle,
      RecipientType.user || RecipientType.unspecified => l10n.profileUserTitle,
    };
  }

  String _memberRoleLabel(String role) {
    final l10n = context.safeLocalizations;
    return switch (role) {
      'owner' => l10n.profileRoleOwner,
      'admin' => l10n.profileRoleAdmin,
      'subscriber' => l10n.profileRoleSubscriber,
      _ => l10n.profileRoleMember,
    };
  }

  String _memberActionLabel(_MemberAction action) {
    final l10n = context.safeLocalizations;
    return switch (action) {
      _MemberAction.promote => l10n.profilePromoteAdmin,
      _MemberAction.demote => l10n.profileDemoteAdmin,
      _MemberAction.remove => l10n.profileRemoveMember,
      _MemberAction.ban => l10n.profileBanMember,
    };
  }

  String _handleLabel(String handle) => handle.isEmpty
      ? ''
      : handle.startsWith('@')
      ? handle
      : '@$handle';

  String _memberActionSuccess(_MemberAction action, bool isSelf) {
    final l10n = context.safeLocalizations;
    return switch (action) {
      _MemberAction.promote => l10n.profilePromoteSuccess,
      _MemberAction.demote => l10n.profileDemoteSuccess,
      _MemberAction.remove =>
        isSelf ? l10n.profileLeaveSuccess : l10n.profileRemoveSuccess,
      _MemberAction.ban => l10n.profileBanSuccess,
    };
  }
}

enum _MemberAction { promote, demote, remove, ban }
