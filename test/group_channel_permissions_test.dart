import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tureon/core/protocol/recipient.dart';
import 'package:tureon/core/protocol/recipient_type.dart';
import 'package:tureon/features/channels/presentation/views/edit_channel_permissions_screen.dart';
import 'package:tureon/features/groups/presentation/views/edit_group_permissions_screen.dart';
import 'package:tureon/l10n/app_localizations.dart';

void main() {
  testWidgets('group policy switch saves the members send setting', (
    tester,
  ) async {
    Map<String, bool>? savedPermissions;
    int? savedSlowModeSeconds;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('pt'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: EditGroupPermissionsScreen(
          group: const Recipient(
            id: 'group-1',
            type: RecipientType.group,
            name: 'Grupo',
            handle: '',
            membersCanSendMessages: false,
          ),
          onSavePermissions: (permissions, slowModeSeconds) async {
            savedPermissions = permissions;
            savedSlowModeSeconds = slowModeSeconds;
          },
        ),
      ),
    );

    final sendMessagesSwitch = tester.widget<SwitchListTile>(
      find.byType(SwitchListTile).first,
    );
    expect(sendMessagesSwitch.value, isFalse);
    await tester.tap(find.byType(SwitchListTile).first);
    await tester.pump();
    await tester.tap(find.byType(DropdownButton<int>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('30 s').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Salvar'));
    await tester.pumpAndSettle();

    expect(savedPermissions?['send_messages'], isTrue);
    expect(savedSlowModeSeconds, 30);
  });

  testWidgets('channel policy switch saves the subscribers publish setting', (
    tester,
  ) async {
    Map<String, bool>? savedPermissions;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('pt'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: EditChannelPermissionsScreen(
          channel: const Recipient(
            id: 'channel-1',
            type: RecipientType.channel,
            name: 'Canal',
            handle: '',
            membersCanSendMessages: true,
          ),
          onSavePermissions: (permissions, _) async {
            savedPermissions = permissions;
          },
        ),
      ),
    );

    final publishSwitch = tester.widget<SwitchListTile>(
      find.byType(SwitchListTile).first,
    );
    expect(publishSwitch.value, isTrue);
    await tester.tap(find.byType(SwitchListTile).first);
    await tester.pump();
    await tester.tap(find.byTooltip('Salvar'));
    await tester.pumpAndSettle();

    expect(savedPermissions?['send_messages'], isFalse);
  });
}
