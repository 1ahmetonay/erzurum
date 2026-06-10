import 'package:atikavi_erzurum/core/theme/app_theme.dart';
import 'package:atikavi_erzurum/features/social/group_invitations_screen.dart';
import 'package:atikavi_erzurum/models/group_invitation_model.dart';
import 'package:atikavi_erzurum/models/user_connection_model.dart';
import 'package:atikavi_erzurum/providers/auth_provider.dart';
import 'package:atikavi_erzurum/providers/cleanup_group_provider.dart';
import 'package:atikavi_erzurum/providers/user_connection_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('group invitations screen supports multi selection', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final now = DateTime(2026, 1, 1);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith((ref) => Stream<User?>.value(null)),
          incomingGroupInvitationsProvider.overrideWith(
            (ref) => Stream.value([
              GroupInvitationModel(
                id: 'local_demo_invite',
                cleanupGroupId: 'group',
                cleanupEventId: 'Erzurum Çevrecileri',
                dirtyAreaId: 'area',
                invitedByUserId: 'ahmet',
                invitedByUsername: 'Ahmet K.',
                invitedUserId: 'current',
                invitedUsername: 'Kullanıcı',
                status: GroupInvitationStatuses.pending,
                createdAt: now,
                updatedAt: now,
              ),
            ]),
          ),
          acceptedConnectionsProvider.overrideWith(
            (ref) => Stream.value([
              UserConnectionModel(
                id: 'friend',
                requesterUserId: '',
                requesterUsername: 'Kullanıcı',
                receiverUserId: 'mehmet',
                receiverUsername: 'Mehmet A.',
                status: UserConnectionStatuses.accepted,
                createdAt: now,
                updatedAt: now,
              ),
            ]),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const GroupInvitationsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Dadaş Takımı'), findsOneWidget);
    expect(find.text('Haftalık Hedef'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -1000));
    await tester.pumpAndSettle();

    expect(find.text('Mehmet A.'), findsOneWidget);
    await tester.tap(find.text('Mehmet A.'));
    await tester.pumpAndSettle();

    expect(find.text('Seçilenleri Davet Et (1)'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
