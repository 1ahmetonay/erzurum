import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/social_demo_data.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cleanup_group_provider.dart';
import '../../shared/widgets/empty_state.dart';
import 'widgets/group_invitation_card.dart';

class GroupInvitationsScreen extends ConsumerWidget {
  const GroupInvitationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).valueOrNull;
    final invitationsState = ref.watch(incomingGroupInvitationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Grup Davetleri')),
      body: SafeArea(
        child: invitationsState.when(
          data: (invitations) {
            if (invitations.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(18),
                child: EmptyState(
                  title: 'Davet yok',
                  message: 'Temizlik grubu davetleri burada görünecek.',
                  icon: Icons.group_add_outlined,
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
              itemCount: invitations.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final invitation = invitations[index];
                return GroupInvitationCard(
                  invitation: invitation,
                  onAccept:
                      user == null || SocialDemoData.isDemoId(invitation.id)
                      ? null
                      : () => ref
                            .read(cleanupGroupActionControllerProvider.notifier)
                            .acceptInvitation(
                              invitationId: invitation.id,
                              userId: user.uid,
                            ),
                  onReject:
                      user == null || SocialDemoData.isDemoId(invitation.id)
                      ? null
                      : () => ref
                            .read(cleanupGroupActionControllerProvider.notifier)
                            .rejectInvitation(
                              invitationId: invitation.id,
                              userId: user.uid,
                            ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => const Padding(
            padding: EdgeInsets.all(18),
            child: EmptyState(
              title: 'Davetler yüklenemedi',
              message: 'Grup davetleri şu anda alınamadı.',
              icon: Icons.error_outline,
            ),
          ),
        ),
      ),
    );
  }
}
