import 'package:atikavi_erzurum/core/theme/app_theme.dart';
import 'package:atikavi_erzurum/features/dirty_areas/report_dirty_area_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('dirty area report screen is scrollable on mobile viewport', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: const ReportDirtyAreaScreen(),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Kirli Bölge Bildir'), findsOneWidget);
    expect(find.text('KONUM BİLGİSİ'), findsOneWidget);
    expect(find.text('FOTOĞRAF EKLE'), findsOneWidget);
    expect(find.text('ATIK TÜRÜ'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -1600));
    await tester.pumpAndSettle();

    expect(find.text('AÇIKLAMA'), findsOneWidget);
    expect(find.text('Bildirimi Gönder'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('back button returns directly to home', (tester) async {
    final router = GoRouter(
      initialLocation: '/report-dirty-area',
      routes: [
        GoRoute(
          path: '/home',
          builder: (_, _) => const Scaffold(body: Text('Ana Sayfa')),
        ),
        GoRoute(
          path: '/report-dirty-area',
          builder: (_, _) => const ReportDirtyAreaScreen(),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Geri'));
    await tester.pumpAndSettle();

    expect(find.text('Ana Sayfa'), findsOneWidget);
    expect(find.text('Bildirim yüklenemedi'), findsNothing);
  });
}
