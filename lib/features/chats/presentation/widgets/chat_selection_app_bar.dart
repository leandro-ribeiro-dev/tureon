import 'package:flutter/material.dart';

class ChatSelectionAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const ChatSelectionAppBar({
    super.key,
    required this.selectedCount,
    required this.onClear,
    required this.onPin,
    required this.onArchive,
    required this.onDelete,
    required this.onSelectAll,
  });
  final int selectedCount;
  final VoidCallback onClear;
  final VoidCallback onPin;
  final VoidCallback onArchive;
  final VoidCallback onDelete;
  final VoidCallback onSelectAll;
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
  @override
  Widget build(BuildContext context) => AppBar(
    elevation: 2,
    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
    leading: IconButton(
      icon: const Icon(Icons.close_rounded),
      tooltip: 'Cancelar seleção',
      onPressed: onClear,
    ),
    title: Text(
      '$selectedCount selecionada(s)',
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
    ),
    actions: [
      IconButton(
        icon: const Icon(Icons.push_pin_outlined),
        tooltip: 'Fixar / Desfixar selecionadas',
        onPressed: onPin,
      ),
      IconButton(
        icon: const Icon(Icons.archive_outlined),
        tooltip: 'Arquivar selecionadas',
        onPressed: onArchive,
      ),
      if (selectedCount == 1)
        IconButton(
          icon: const Icon(Icons.delete_outline_rounded),
          tooltip: 'Apagar conversa',
          onPressed: onDelete,
        ),
      IconButton(
        icon: const Icon(Icons.select_all_rounded),
        tooltip: 'Selecionar todas',
        onPressed: onSelectAll,
      ),
    ],
  );
}
