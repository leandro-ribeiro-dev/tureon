import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tureon/l10n/app_localizations.dart';

import '../../../../core/design_system/app_bottom_sheet.dart';
import '../../../../core/providers/profile_providers.dart';
import '../../../../core/providers/settings_providers.dart';
import '../../../../core/storage/message_records.dart';
import '../../domain/settings_entry.dart';

/// Generic reusable Settings Section Screen.
/// Adheres to Requirement 0.1: Avoids duplicating screen layouts by taking a
/// [SettingsSection] data model and rendering entries dynamically.
class SettingsSectionScreen extends ConsumerStatefulWidget {
  const SettingsSectionScreen({
    super.key,
    required this.section,
    this.onNavigateRoute,
    this.onSelectionChanged,
    this.onLoadProfile,
    this.onUpdatePrivacySetting,
    this.isAccountUnderReview = false,
  });

  final SettingsSection section;
  final ValueChanged<String>? onNavigateRoute;
  final void Function(String entryId, String value)? onSelectionChanged;
  final Future<UserProfile> Function()? onLoadProfile;
  final Future<UserProfile> Function(String field, String visibility)?
  onUpdatePrivacySetting;
  final bool isAccountUnderReview;

  @override
  ConsumerState<SettingsSectionScreen> createState() =>
      _SettingsSectionScreenState();
}

class _SettingsSectionScreenState extends ConsumerState<SettingsSectionScreen> {
  String? _profileError;
  bool _loadingProfile = false;
  final Set<String> _savingPrivacyFields = {};

  @override
  void initState() {
    super.initState();
    if (widget.section.id == 'privacy_security' ||
        widget.section.id == 'account') {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadProfile());
    }
  }

  Future<void> _loadProfile() async {
    final loadProfile = widget.onLoadProfile;
    if (loadProfile == null) return;
    setState(() {
      _loadingProfile = true;
      _profileError = null;
    });
    try {
      await loadProfile();
      if (mounted) setState(() => _profileError = null);
    } catch (error) {
      if (mounted) setState(() => _profileError = '$error');
    } finally {
      if (mounted) setState(() => _loadingProfile = false);
    }
  }

  String? _privacyFieldFor(String entryId) => switch (entryId) {
    'privacy_phone' => 'phone',
    'privacy_last_seen' => 'last_seen',
    'privacy_profile_photo' => 'profile_photo',
    'privacy_username' => 'username',
    'privacy_bio' => 'bio',
    'privacy_country' => 'country',
    'privacy_read_receipts' => 'read_receipts',
    _ => null,
  };

  String _visibilityLabel(String? visibility, {String? field}) {
    if (field == 'read_receipts') {
      return visibility == 'everyone' ? 'Ativadas' : 'Desativadas';
    }
    return switch (visibility) {
      'contacts' => 'Meus Contatos',
      'nobody' => 'Ninguém',
      'everyone' => 'Todos',
      _ => '',
    };
  }

  String? _subtitleFor(
    SettingsEntry entry,
    Map<String, Object?> values,
    UserProfile? profile,
  ) {
    final privacyField = _privacyFieldFor(entry.id);
    if (privacyField != null && profile != null) {
      return _visibilityLabel(
        profile.privacySettings[privacyField],
        field: privacyField,
      );
    }
    if (entry.id == 'edit_name' && profile != null) {
      return profile.displayName;
    }
    if (entry.id == 'edit_phone' && profile != null) {
      return profile.phoneE164;
    }
    if (entry.id == 'edit_username' && profile != null) {
      return profile.username.isEmpty ? null : '@${profile.username}';
    }
    if (entry.id == 'edit_bio' && profile != null) {
      return profile.bio;
    }
    return values[entry.id] as String? ?? entry.subtitleKey;
  }

  Future<void> _chooseSelectorValue(
    BuildContext sheetContext,
    SettingsEntry entry,
    String value,
  ) async {
    final field = _privacyFieldFor(entry.id);
    final updatePrivacy = widget.onUpdatePrivacySetting;
    if (field != null && updatePrivacy == null) {
      final message = widget.isAccountUnderReview
          ? AppLocalizations.of(context)!.moderationUnderReview
          : 'Não foi possível salvar sem a conexão autenticada.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      Navigator.pop(sheetContext);
      return;
    }
    if (field != null && updatePrivacy != null) {
      setState(() => _savingPrivacyFields.add(field));
      try {
        final visibility = field == 'read_receipts'
            ? switch (value) {
                'Ativadas' => 'everyone',
                'Desativadas' => 'nobody',
                _ => throw ArgumentError.value(value, 'value'),
              }
            : switch (value) {
                'Meus Contatos' => 'contacts',
                'Ninguém' => 'nobody',
                _ => 'everyone',
              };
        await updatePrivacy(field, visibility);
        if (!mounted || !sheetContext.mounted) return;
        setState(() => _savingPrivacyFields.remove(field));
        Navigator.pop(sheetContext);
      } on ProfileSyncPendingException catch (error) {
        if (!mounted || !sheetContext.mounted) return;
        setState(() => _savingPrivacyFields.remove(field));
        Navigator.pop(sheetContext);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Privacidade salva neste dispositivo; sincronização pendente: ${error.cause}',
            ),
          ),
        );
      } catch (error) {
        if (!context.mounted) return;
        setState(() => _savingPrivacyFields.remove(field));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Não foi possível salvar a privacidade: $error'),
          ),
        );
      }
      return;
    }
    ref.read(settingsValuesProvider.notifier).setValue(entry.id, value);
    widget.onSelectionChanged?.call(entry.id, value);
    Navigator.pop(sheetContext);
  }

  void _handleEntryTap(SettingsEntry entry, UserProfile? profile) {
    switch (entry.type) {
      case SettingsEntryType.navigation:
        if (widget.section.id == 'chat_folders' &&
            entry.id.startsWith('folder_')) {
          _showFolderDialog(folderId: entry.id);
        } else if (entry.route != null && widget.onNavigateRoute != null) {
          widget.onNavigateRoute!(entry.route!);
        } else {
          entry.onTap?.call();
          if (entry.onTap == null && entry.route == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  entry.subtitleKey ?? 'Esta opção não está disponível.',
                ),
              ),
            );
          }
        }

      case SettingsEntryType.action:
        if (entry.id == 'create_folder') {
          _showFolderDialog();
        } else {
          _confirmAction(entry);
        }

      case SettingsEntryType.selector:
        if (entry.options != null && entry.options!.isNotEmpty) {
          _showSelectorDialog(entry, profile);
        }

      case SettingsEntryType.toggle:
        final current = entry.valueProviderKey == 'reduceVisualEffects'
            ? ref.read(reduceVisualEffectsProvider)
            : ref.read(settingsValuesProvider)[entry.id] as bool? ??
                  entry.currentValue as bool? ??
                  false;
        _setEntryValue(entry, !current);
    }
  }

  void _setEntryValue(SettingsEntry entry, bool value) {
    if (entry.valueProviderKey == 'reduceVisualEffects') {
      ref.read(reduceVisualEffectsProvider.notifier).toggle(value);
    } else {
      ref.read(settingsValuesProvider.notifier).setValue(entry.id, value);
      entry.onToggleChanged?.call(value);
    }
  }

  void _showSelectorDialog(SettingsEntry entry, UserProfile? profile) {
    final glassToken = Theme.of(context).colorScheme;
    final options = entry.options!;
    final privacyField = _privacyFieldFor(entry.id);
    final current =
        (privacyField == null
            ? null
            : _visibilityLabel(
                profile?.privacySettings[privacyField],
                field: privacyField,
              )) ??
        ref.read(settingsValuesProvider)[entry.id] as String? ??
        entry.currentValue as String? ??
        (options.contains(entry.subtitleKey)
            ? entry.subtitleKey!
            : options.first);

    AppBottomSheet.show<void>(
      context: context,
      builder: (sheetContext) => AppBottomSheetContainer(
        title: entry.titleKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...options.map((opt) {
              final isSelected = opt == current;
              return AppBottomSheetTile(
                icon: isSelected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                iconColor: isSelected
                    ? glassToken.primary
                    : glassToken.onSurfaceVariant,
                title: opt,
                onTap:
                    privacyField != null &&
                        _savingPrivacyFields.contains(privacyField)
                    ? () {}
                    : () => _chooseSelectorValue(sheetContext, entry, opt),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _confirmAction(SettingsEntry entry) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(entry.titleKey),
        content: Text('Deseja executar a ação "${entry.titleKey}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              entry.onTap?.call();
              if (entry.onTap == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Esta ação precisa de uma conexão ativa.'),
                  ),
                );
              }
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  Future<void> _showFolderDialog({String? folderId}) async {
    final folders = ref.read(chatFoldersProvider);
    final controller = TextEditingController(text: folders[folderId] ?? '');
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(folderId == null ? 'Criar pasta' : 'Editar pasta'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 32,
          decoration: const InputDecoration(labelText: 'Nome da pasta'),
          onSubmitted: (value) => Navigator.pop(dialogContext, value.trim()),
        ),
        actions: [
          if (folderId != null)
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, '__delete__'),
              child: const Text('Excluir'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (!mounted || name == null) return;
    final notifier = ref.read(chatFoldersProvider.notifier);
    if (name == '__delete__' && folderId != null) {
      notifier.remove(folderId);
    } else if (name.isNotEmpty) {
      if (folderId == null) {
        notifier.add(name);
      } else {
        notifier.rename(folderId, name);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final glassToken = Theme.of(context).colorScheme;
    final reduceEffects = ref.watch(reduceVisualEffectsProvider);
    final settingValues = ref.watch(settingsValuesProvider);
    final profileState = ref.watch(currentUserProfileProvider);
    final profile = profileState.when(
      data: (value) => value,
      error: (error, stackTrace) => null,
      loading: () => null,
    );
    final customFolders = ref.watch(chatFoldersProvider);
    final entries = [
      ...widget.section.entries,
      if (widget.section.id == 'chat_folders')
        ...customFolders.entries.map(
          (folder) => SettingsEntry(
            id: folder.key,
            icon: Icons.folder_open_rounded,
            titleKey: folder.value,
            subtitleKey: 'Toque para editar esta pasta',
            type: SettingsEntryType.navigation,
          ),
        ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.section.titleKey),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_loadingProfile) const LinearProgressIndicator(),
              if (_profileError != null)
                MaterialBanner(
                  content: Text(
                    'Não foi possível carregar dados do servidor: $_profileError',
                  ),
                  actions: [
                    TextButton(
                      onPressed: _loadProfile,
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              if (profileState.hasError)
                MaterialBanner(
                  content: const Text(
                    'Não foi possível observar o perfil salvo neste dispositivo.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () =>
                          ref.invalidate(currentUserProfileProvider),
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              if (widget.section.subtitle != null) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Text(
                    widget.section.subtitle!,
                    style: TextStyle(
                      fontSize: 14,
                      color: glassToken.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              ...entries.map((entry) {
                // Resolve dynamic state for toggles and selectors
                bool toggleVal = false;
                if (entry.valueProviderKey == 'reduceVisualEffects') {
                  toggleVal = reduceEffects;
                } else if (settingValues[entry.id] is bool) {
                  toggleVal = settingValues[entry.id] as bool;
                } else if (entry.currentValue is bool) {
                  toggleVal = entry.currentValue as bool;
                }

                final subtitle = _subtitleFor(entry, settingValues, profile);
                Widget? trailingWidget;
                if (entry.type == SettingsEntryType.toggle) {
                  trailingWidget = Switch(
                    value: toggleVal,
                    activeThumbColor: glassToken.primary,
                    onChanged: (val) => _setEntryValue(entry, val),
                  );
                } else if (entry.type == SettingsEntryType.navigation ||
                    entry.type == SettingsEntryType.selector) {
                  trailingWidget = const Icon(Icons.chevron_right_rounded);
                }

                final iconColor = entry.isDestructive
                    ? glassToken.error
                    : glassToken.primary;
                final titleColor = entry.isDestructive
                    ? glassToken.error
                    : glassToken.onSurface;

                return ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: entry.isDestructive
                          ? glassToken.errorContainer.withValues(alpha: 0.3)
                          : glassToken.surfaceContainerHigh,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(entry.icon, size: 20, color: iconColor),
                  ),
                  title: Text(
                    entry.titleKey,
                    style: TextStyle(
                      color: titleColor,
                      fontWeight: entry.isDestructive
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
                  ),
                  subtitle: subtitle != null && subtitle.isNotEmpty
                      ? Text(subtitle)
                      : null,
                  trailing:
                      _savingPrivacyFields.contains(_privacyFieldFor(entry.id))
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : trailingWidget,
                  onTap: () => _handleEntryTap(entry, profile),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
