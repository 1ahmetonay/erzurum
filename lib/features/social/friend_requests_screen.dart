import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/social_demo_data.dart';
import '../../models/user_connection_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_connection_provider.dart';
import '../../shared/widgets/empty_state.dart';
import 'widgets/user_connection_card.dart';

class FriendRequestsScreen extends ConsumerWidget {
  const FriendRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).valueOrNull;
    final incoming = ref.watch(incomingConnectionRequestsProvider);
    final outgoing = ref.watch(outgoingConnectionRequestsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Arkadaşlık İstekleri')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
          children: [
            incoming.when(
              data: (requests) => _Section(
                title: 'Gelen İstekler',
                empty: 'Gelen arkadaşlık isteği yok.',
                children: [
                  for (final request in requests)
                    UserConnectionCard(
                      title: request.requesterUsername,
                      subtitle: 'Arkadaşlık isteği gönderdi',
                      primaryLabel: 'Kabul Et',
                      secondaryLabel: 'Reddet',
                      onPrimary:
                          user == null || SocialDemoData.isDemoId(request.id)
                          ? null
                          : () => _update(
                              ref,
                              request.id,
                              user.uid,
                              UserConnectionStatuses.accepted,
                            ),
                      onSecondary:
                          user == null || SocialDemoData.isDemoId(request.id)
                          ? null
                          : () => _update(
                              ref,
                              request.id,
                              user.uid,
                              UserConnectionStatuses.rejected,
                            ),
                    ),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => const EmptyState(
                title: 'İstekler yüklenemedi',
                message: 'Gelen istekler alınamadı.',
                icon: Icons.error_outline,
              ),
            ),
            const SizedBox(height: 20),
            outgoing.when(
              data: (requests) => _Section(
                title: 'Gönderilen İstekler',
                empty: 'Gönderilen bekleyen istek yok.',
                children: [
                  for (final request in requests)
                    UserConnectionCard(
                      title: request.receiverUsername,
                      subtitle: 'Yanıt bekleniyor',
                    ),
                ],
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _update(
    WidgetRef ref,
    String connectionId,
    String userId,
    String status,
  ) {
    return ref
        .read(userConnectionActionControllerProvider.notifier)
        .updateStatus(
          connectionId: connectionId,
          userId: userId,
          status: status,
        );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.empty,
    required this.children,
  });

  final String title;
  final String empty;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        if (children.isEmpty)
          EmptyState(title: 'Kayıt yok', message: empty)
        else
          for (final child in children) ...[child, const SizedBox(height: 10)],
      ],
    );
  }
}
