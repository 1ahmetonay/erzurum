import 'package:atikavi_erzurum/main.dart';
import 'package:atikavi_erzurum/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AtıkAvı Erzurum açılış testi', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith((ref) => Stream.value(null)),
        ],
        child: const AtikAviApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Google ile Giriş Yap'), findsOneWidget);
    expect(find.byIcon(Icons.recycling), findsOneWidget);
  });
}
