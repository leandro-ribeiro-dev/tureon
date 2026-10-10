import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tureon/core/providers/settings_providers.dart';
import 'package:tureon/core/storage/message_records.dart';
import 'package:tureon/features/chats/presentation/widgets/chats_search_bar.dart';
import 'package:tureon/features/settings/presentation/views/devices_screen.dart';
import 'package:tureon/features/settings/presentation/views/language_settings_screen.dart';
import 'package:tureon/l10n/app_localizations.dart';

void main() {
  testWidgets('chat search pill navigates without opening an inline editor', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: ChatsSearchBar(onTap: () => taps++)),
      ),
    );

    expect(find.byType(TextField), findsNothing);
    await tester.tap(find.text('Pesquisar conversas...'));
    expect(taps, 1);
    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('language selector searches and applies the chosen locale', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const LanguageSettingsScreen(),
        ),
      ),
    );

    expect(find.text('Português (Brasil)'), findsNWidgets(2));
    await tester.enterText(find.byType(TextField).first, 'english');
    await tester.pumpAndSettle();
    expect(find.text('English (US)'), findsOneWidget);
    // The selected-language summary stays visible while the option list filters.
    expect(find.text('Português (Brasil)'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, '');
    await tester.pumpAndSettle();
    await tester.tap(find.text('English (US)'));
    await tester.pumpAndSettle();
    expect(container.read(appLocaleProvider).languageCode, 'en');
  });

  testWidgets(
    'device list refreshes after a revocation committed before notification failed',
    (tester) async {
      final devices = <DeviceSession>[
        DeviceSession(
          deviceId: 'current',
          name: 'Linux desktop',
          platform: 'Linux',
          lastActiveAt: DateTime.utc(2026, 10, 8),
          isCurrent: true,
        ),
        DeviceSession(
          deviceId: 'phone',
          name: 'Android phone',
          platform: 'Android',
          lastActiveAt: DateTime.utc(2026, 10, 7),
          isCurrent: false,
        ),
      ];
      var loadCalls = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: DevicesScreen(
            loadDevices: () async {
              loadCalls++;
              return List<DeviceSession>.of(devices);
            },
            revokeDevice: (deviceId) async {
              devices.removeWhere((device) => device.deviceId == deviceId);
              throw StateError('stream notification failed after commit');
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Linux desktop'), findsOneWidget);
      expect(find.text('Android phone'), findsOneWidget);
      expect(find.byTooltip('Encerrar sessão'), findsOneWidget);

      await tester.tap(find.byTooltip('Encerrar sessão'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Encerrar sessão'));
      await tester.pumpAndSettle();

      expect(loadCalls, 2);
      expect(find.text('Android phone'), findsNothing);
      expect(find.text('Linux desktop'), findsOneWidget);
      expect(find.text('Sessão encerrada.'), findsOneWidget);
    },
  );
}
