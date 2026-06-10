import 'package:atikavi_erzurum/core/constants/mock_data.dart';
import 'package:atikavi_erzurum/core/theme/app_theme.dart';
import 'package:atikavi_erzurum/features/home/home_screen.dart';
import 'package:atikavi_erzurum/providers/recycling_point_provider.dart';
import 'package:atikavi_erzurum/providers/task_provider.dart';
import 'package:atikavi_erzurum/providers/user_provider.dart';
import 'package:atikavi_erzurum/providers/waste_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('home shortcut cards use the full available width', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentUserProvider.overrideWith(
            (ref) => Stream.value(MockData.currentUser),
          ),
          tasksWithProgressProvider.overrideWith(
            (ref) => AsyncData(MockData.tasks),
          ),
          activeRecyclingPointsProvider.overrideWith(
            (ref) => Stream.value(MockData.recyclingPoints),
          ),
          userWasteLogCountProvider.overrideWith((ref) => Stream.value(0)),
        ],
        child: MaterialApp(theme: AppTheme.light, home: const HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    final dirtyAreaSize = tester.getSize(
      find.byKey(const ValueKey('home-dirty-area-shortcut')),
    );
    final friendsSize = tester.getSize(
      find.byKey(const ValueKey('home-friends-shortcut')),
    );
    final invitationsSize = tester.getSize(
      find.byKey(const ValueKey('home-group-invitations-shortcut')),
    );

    expect(friendsSize.width, dirtyAreaSize.width);
    expect(invitationsSize.width, dirtyAreaSize.width);
    expect(friendsSize.width, greaterThan(380));
    expect(tester.takeException(), isNull);
  });
}
