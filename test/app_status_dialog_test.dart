import 'package:atikavi_erzurum/core/theme/app_theme.dart';
import 'package:atikavi_erzurum/shared/widgets/app_status_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('status dialog is centered and closes with its close button', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () => AppStatusDialog.showError(
                  context,
                  title: 'Bildirim yüklenemedi',
                  message: 'Biraz sonra tekrar dene.',
                ),
                child: const Text('Göster'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Göster'));
    await tester.pumpAndSettle();

    expect(find.text('Bildirim yüklenemedi'), findsOneWidget);
    expect(find.byTooltip('Kapat'), findsOneWidget);

    await tester.tap(find.byTooltip('Kapat'));
    await tester.pumpAndSettle();

    expect(find.text('Bildirim yüklenemedi'), findsNothing);
  });
}
