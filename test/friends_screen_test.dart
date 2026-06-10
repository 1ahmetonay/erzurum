import 'package:atikavi_erzurum/core/theme/app_theme.dart';
import 'package:atikavi_erzurum/features/social/friends_screen.dart';
import 'package:atikavi_erzurum/models/user_connection_model.dart';
import 'package:atikavi_erzurum/providers/auth_provider.dart';
import 'package:atikavi_erzurum/providers/user_connection_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('friends screen switches between friends and requests', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final now = DateTime(2026, 1, 1);
    final friends = [
      UserConnectionModel(
        id: 'friend-1',
        requesterUserId: '',
        requesterUsername: 'Kullanıcı',
        receiverUserId: 'friend-user',
        receiverUsername: 'Ahmet Dadaş',
        status: UserConnectionStatuses.accepted,
        createdAt: now,
        updatedAt: now,
      ),
    ];
    final requests = [
      UserConnectionModel(
        id: 'local_demo_request-1',
        requesterUserId: 'request-user',
        requesterUsername: 'Zeynep Demir',
        receiverUserId: 'current-user',
        receiverUsername: 'Kullanıcı',
        status: UserConnectionStatuses.pending,
        createdAt: now,
        updatedAt: now,
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith((ref) => Stream<User?>.value(null)),
          acceptedConnectionsProvider.overrideWith(
            (ref) => Stream.value(friends),
          ),
          incomingConnectionRequestsProvider.overrideWith(
            (ref) => Stream.value(requests),
          ),
          userSearchResultsProvider.overrideWith((ref) async => const []),
        ],
        child: MaterialApp(theme: AppTheme.light, home: const FriendsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Arkadaşlarım'), findsWidgets);
    expect(find.text('Ahmet Dadaş'), findsOneWidget);
    expect(find.text('Davet Linki Paylaş'), findsOneWidget);

    await tester.tap(find.text('İstekler'));
    await tester.pumpAndSettle();

    expect(find.text('Zeynep Demir'), findsOneWidget);
    expect(find.text('Kabul Et'), findsOneWidget);
    expect(find.text('Reddet'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
