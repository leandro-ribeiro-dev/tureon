import 'package:flutter/material.dart';

import '../../../../core/design_system/app_bottom_sheet.dart';

/// Engineer-grade Bottom Sheet for Logout confirmation adhering to Google M3 Guidelines.
abstract final class SettingsLogoutDialog {
  static Future<bool?> show(BuildContext context) {
    return AppBottomSheet.showOptionMenu<bool>(
      context: context,
      title: 'Sair da conta',
      subtitle:
          'O histórico fica somente neste dispositivo. Se você apagar os dados '
          'sem ter feito backup, perderá suas conversas.',
      options: [
        AppBottomSheetTile(
          icon: Icons.logout_rounded,
          title: 'Sair e manter dados locais',
          subtitle:
              'Sua sessão será encerrada, mas os dados locais serão mantidos.',
          onTap: () => Navigator.pop(context, false),
        ),
        AppBottomSheetTile(
          icon: Icons.delete_forever_rounded,
          title: 'Sair e apagar todos os dados locais',
          subtitle:
              'Sua sessão será encerrada e todo o histórico local será apagado.',
          isDestructive: true,
          onTap: () => Navigator.pop(context, true),
        ),
      ],
    );
  }
}
