import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tureon/core/storage/message_records.dart';
import 'package:tureon/features/profile/presentation/views/edit_field_screen.dart';

void main() {
  const profile = UserProfile(
    userId: 'user-1',
    username: 'alice_123',
    displayName: 'Alice',
  );

  testWidgets('avatar editor rejects insecure and local URLs', (tester) async {
    var saveCalls = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: EditFieldScreen(
          fieldType: ProfileFieldType.avatarUrl,
          currentUser: profile,
          onSave: (updated) async {
            saveCalls++;
            return updated;
          },
        ),
      ),
    );

    await tester.enterText(
      find.byType(TextFormField),
      'http://localhost/avatar.png',
    );
    await tester.tap(find.byTooltip('Salvar'));
    await tester.pumpAndSettle();

    expect(saveCalls, 0);
    expect(find.text('Use uma URL HTTPS pública válida.'), findsOneWidget);
  });

  testWidgets('phone editor requires E.164 format', (tester) async {
    var saveCalls = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: EditFieldScreen(
          fieldType: ProfileFieldType.phone,
          currentUser: profile,
          onSave: (updated) async {
            saveCalls++;
            return updated;
          },
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField), '415 555 2671');
    await tester.tap(find.byTooltip('Salvar'));
    await tester.pumpAndSettle();

    expect(saveCalls, 0);
    expect(
      find.text(
        'Informe o telefone no formato internacional E.164 (ex: +14155552671).',
      ),
      findsOneWidget,
    );
  });

  testWidgets('country editor validates two letters and normalizes uppercase', (
    tester,
  ) async {
    UserProfile? saved;
    await tester.pumpWidget(
      MaterialApp(
        home: EditFieldScreen(
          fieldType: ProfileFieldType.country,
          currentUser: profile,
          onSave: (updated) async {
            saved = updated;
            return updated;
          },
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField), 'b');
    await tester.tap(find.byTooltip('Salvar'));
    await tester.pumpAndSettle();
    expect(saved, isNull);
    expect(find.text('Informe duas letras, como BR.'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'br');
    await tester.tap(find.byTooltip('Salvar'));
    await tester.pumpAndSettle();
    expect(saved?.countryCode, 'BR');
  });
}
