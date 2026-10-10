import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/app_bottom_sheet.dart';
import '../../../../core/providers/settings_providers.dart';

/// Screen allowing users to manage chat filter tabs/chips shown on the Home Chats screen:
/// - Enable/disable tabs (only active ones appear on the chat list screen).
/// - Add new custom filter tabs ("add mais").
/// - Edit or remove custom and built-in tabs ("remover abos").
/// - Reorder tabs via drag-and-drop.
/// - Configure unread badge counters on filter chips.
class ChatFiltersSettingsScreen extends ConsumerWidget {
  const ChatFiltersSettingsScreen({super.key});

  IconData _iconForFilterType(String filterType) => switch (filterType) {
        'all' => Icons.all_inclusive_rounded,
        'favorites' => Icons.star_outline_rounded,
        'unread' => Icons.mark_chat_unread_outlined,
        'groups' => Icons.groups_outlined,
        'channels' => Icons.campaign_outlined,
        'contacts' => Icons.person_outline_rounded,
        _ => Icons.filter_list_rounded,
      };

  String _labelForFilterType(String filterType) => switch (filterType) {
        'all' => 'Todas as conversas',
        'favorites' => 'Conversas fixadas / favoritas',
        'unread' => 'Mensagens não lidas',
        'groups' => 'Grupos e canais',
        'channels' => 'Apenas canais',
        'contacts' => 'Conversas privadas (contatos)',
        _ => 'Filtro personalizado',
      };

  void _showAddOrEditTabDialog(
    BuildContext context,
    WidgetRef ref, {
    ChatFilterTab? existingTab,
  }) {
    final isEditing = existingTab != null;
    final nameController =
        TextEditingController(text: existingTab?.label ?? '');
    String selectedFilterType = existingTab?.filterType ?? 'custom';

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final theme = Theme.of(context);
            return AlertDialog(
              title: Text(isEditing ? 'Editar Aba' : 'Nova Aba de Filtro'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameController,
                      autofocus: !isEditing,
                      maxLength: 24,
                      decoration: const InputDecoration(
                        labelText: 'Nome da aba',
                        hintText: 'Ex: Trabalho, Estudos, Projetos...',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Tipo de Filtro',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: selectedFilterType,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'favorites',
                          child: Text('Favoritos'),
                        ),
                        DropdownMenuItem(
                          value: 'unread',
                          child: Text('Não lidas'),
                        ),
                        DropdownMenuItem(
                          value: 'groups',
                          child: Text('Grupos'),
                        ),
                        DropdownMenuItem(
                          value: 'channels',
                          child: Text('Canais'),
                        ),
                        DropdownMenuItem(
                          value: 'contacts',
                          child: Text('Privados'),
                        ),
                        DropdownMenuItem(
                          value: 'custom',
                          child: Text('Personalizado'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() => selectedFilterType = val);
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    if (name.isEmpty) return;

                    final notifier =
                        ref.read(chatFilterTabsProvider.notifier);
                    if (isEditing) {
                      notifier.updateTab(
                        existingTab.copyWith(
                          label: name,
                          filterType: selectedFilterType,
                        ),
                      );
                    } else {
                      final newTab = ChatFilterTab(
                        id: 'custom_${DateTime.now().microsecondsSinceEpoch}',
                        label: name,
                        filterType: selectedFilterType,
                        isEnabled: true,
                        isBuiltIn: false,
                      );
                      notifier.addTab(newTab);
                    }
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDeleteTab(
    BuildContext context,
    WidgetRef ref,
    ChatFilterTab tab,
  ) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remover Aba'),
        content: Text('Deseja remover a aba "${tab.label}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              ref.read(chatFilterTabsProvider.notifier).removeTab(tab.id);
              Navigator.pop(dialogContext);
            },
            child: const Text('Remover'),
          ),
        ],
      ),
    );
  }

  void _showTabOptions(
    BuildContext context,
    WidgetRef ref,
    ChatFilterTab tab,
  ) {
    AppBottomSheet.show<void>(
      context: context,
      builder: (sheetContext) => AppBottomSheetContainer(
        title: tab.label,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBottomSheetTile(
              icon: Icons.edit_outlined,
              title: 'Editar nome e tipo',
              onTap: () {
                Navigator.pop(sheetContext);
                _showAddOrEditTabDialog(context, ref, existingTab: tab);
              },
            ),
            AppBottomSheetTile(
              icon: tab.isEnabled
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              title: tab.isEnabled
                  ? 'Ocultar na tela principal'
                  : 'Mostrar na tela principal',
              onTap: () {
                Navigator.pop(sheetContext);
                ref
                    .read(chatFilterTabsProvider.notifier)
                    .toggleEnabled(tab.id, !tab.isEnabled);
              },
            ),
            AppBottomSheetTile(
              icon: Icons.delete_outline_rounded,
              iconColor: Theme.of(context).colorScheme.error,
              title: 'Remover aba',
              onTap: () {
                Navigator.pop(sheetContext);
                _confirmDeleteTab(context, ref, tab);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final filterTabs = ref.watch(chatFilterTabsProvider);
    final showBadges = ref.watch(showFilterUnreadBadgesProvider);
    final showChipsRow = ref.watch(showFilterChipsRowProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Filtros e Abas de Conversa'),
        actions: [
          IconButton(
            tooltip: 'Restaurar padrão',
            icon: const Icon(Icons.restart_alt_rounded),
            onPressed: () {
              showDialog<void>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Restaurar abas padrão'),
                  content: const Text(
                    'Deseja restaurar as abas de filtro para as configurações originais?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancelar'),
                    ),
                    FilledButton(
                      onPressed: () {
                        ref
                            .read(chatFilterTabsProvider.notifier)
                            .resetToDefault();
                        Navigator.pop(ctx);
                      },
                      child: const Text('Restaurar'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Options header group
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    secondary: Icon(
                      Icons.filter_list_rounded,
                      color: colorScheme.primary,
                    ),
                    title: const Text(
                      'Exibir barra de filtros na lista',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    subtitle: const Text(
                      'Mostra os chips de filtro acima da lista de conversas',
                      style: TextStyle(fontSize: 12),
                    ),
                    value: showChipsRow,
                    onChanged: (value) => ref
                        .read(showFilterChipsRowProvider.notifier)
                        .toggle(value),
                  ),
                  Divider(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                    height: 1,
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    secondary: Icon(
                      Icons.mark_chat_unread_rounded,
                      color: colorScheme.primary,
                    ),
                    title: const Text(
                      'Contador de não lidas nas abas',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    subtitle: const Text(
                      'Exibe a quantidade de mensagens não lidas em cada filtro',
                      style: TextStyle(fontSize: 12),
                    ),
                    value: showBadges,
                    onChanged: (value) => ref
                        .read(showFilterUnreadBadgesProvider.notifier)
                        .toggle(value),
                  ),
                  Divider(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                    height: 1,
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'SUAS ABAS (${filterTabs.where((t) => t.isEnabled).length} ATIVAS)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Text(
                    'Arraste para reordenar',
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            // Reorderable list of tabs
            Expanded(
              child: ReorderableListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                itemCount: filterTabs.length,
                onReorderItem: (oldIndex, newIndex) {
                  ref
                      .read(chatFilterTabsProvider.notifier)
                      .reorderTabs(oldIndex, newIndex);
                },
                itemBuilder: (context, index) {
                  final tab = filterTabs[index];
                  final iconData = _iconForFilterType(tab.filterType);
                  final typeDescription = _labelForFilterType(tab.filterType);

                  return Container(
                    key: ValueKey(tab.id),
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Material(
                      color: colorScheme.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: colorScheme.outlineVariant
                              .withValues(alpha: 0.4),
                        ),
                      ),
                      child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 2,
                      ),
                      leading: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.drag_handle_rounded,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            iconData,
                            color: tab.isEnabled
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                          ),
                        ],
                      ),
                      title: Text(
                        tab.label,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: tab.isEnabled
                              ? colorScheme.onSurface
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                      subtitle: Text(
                        tab.isBuiltIn
                            ? '$typeDescription • Nativo'
                            : '$typeDescription • Personalizado',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Switch(
                            value: tab.isEnabled,
                            activeThumbColor: colorScheme.primary,
                            onChanged: (val) {
                              ref
                                  .read(chatFilterTabsProvider.notifier)
                                  .toggleEnabled(tab.id, val);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.more_vert_rounded),
                            onPressed: () =>
                                _showTabOptions(context, ref, tab),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add_rounded),
        label: const Text('Adicionar Aba'),
        onPressed: () => _showAddOrEditTabDialog(context, ref),
      ),
    );
  }
}
