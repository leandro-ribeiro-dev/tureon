import 'package:flutter/material.dart';
import '../../../../core/design_system/app_bottom_sheet.dart';
import '../../../settings/presentation/views/chat_filters_settings_screen.dart';

void showChatsHomeMenu(
  BuildContext context, {
  required VoidCallback onOpenContactsTab,
  required VoidCallback onOpenSettings,
}) {
  AppBottomSheet.show<void>(
    context: context,
    builder: (sheetContext) => AppBottomSheetContainer(
      title: 'Opções',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppBottomSheetTile(
            icon: Icons.filter_list_rounded,
            title: 'Configurar Filtros e Abas',
            onTap: () {
              Navigator.pop(sheetContext);
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const ChatFiltersSettingsScreen(),
                ),
              );
            },
          ),
          AppBottomSheetTile(
            icon: Icons.contacts_outlined,
            title: 'Contatos',
            onTap: () {
              Navigator.pop(sheetContext);
              onOpenContactsTab();
            },
          ),
          AppBottomSheetTile(
            icon: Icons.tune_outlined,
            title: 'Configurações',
            onTap: () {
              Navigator.pop(sheetContext);
              onOpenSettings();
            },
          ),
        ],
      ),
    ),
  );
}
