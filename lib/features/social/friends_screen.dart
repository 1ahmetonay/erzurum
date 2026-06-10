import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/user_connection_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_connection_provider.dart';
import '../../providers/user_provider.dart';
import '../../repositories/user_connection_repository.dart';
import '../../shared/widgets/empty_state.dart';
import 'widgets/user_connection_card.dart';

class FriendsScreen extends ConsumerWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).valueOrNull;
    final profile = ref.watch(currentUserProvider).valueOrNull;
    final friendsState = ref.watch(acceptedConnectionsProvider);
    final searchState = ref.watch(userSearchResultsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Arkadaşlarım')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Kullanıcı ara',
                hintText: 'Ad veya e-posta yaz',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) =>
                  ref.read(userSearchQueryProvider.notifier).state = value,
            ),
            const SizedBox(height: 12),
            searchState.when(
              data: (results) => Column(
                children: [
                  for (final result in results) ...[
                    UserConnectionCard(
                      title: result.displayName,
                      subtitle: result.email,
                      primaryLabel: 'Arkadaşlık İsteği Gönder',
                      onPrimary: user == null
                          ? null
                          : () => _sendRequest(
                              context: context,
                              ref: ref,
                              requesterUserId: user.uid,
                              requesterUsername:
                                  profile?.displayName ?? user.email ?? '',
                              receiverUserId: result.uid,
                              receiverUsername: result.displayName,
                            ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ],
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.go('/friend-requests'),
                    child: const Text('Arkadaşlık İstekleri'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.go('/group-invitations'),
                    child: const Text('Grup Davetleri'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            friendsState.when(
              data: (connections) {
                if (connections.isEmpty) {
                  return const EmptyState(
                    title: 'Arkadaş yok',
                    message:
                        'Kullanıcı arayıp arkadaşlık isteği gönderebilirsin.',
                    icon: Icons.people_outline,
                  );
                }
                return Column(
                  children: [
                    for (final connection in connections) ...[
                      UserConnectionCard(
                        title: _friendName(connection, user?.uid ?? ''),
                        subtitle: 'Bağlantı aktif',
                      ),
                      const SizedBox(height: 10),
                    ],
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => const EmptyState(
                title: 'Arkadaşlar yüklenemedi',
                message: 'Bağlantı listesi şu anda alınamadı.',
                icon: Icons.error_outline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendRequest({
    required BuildContext context,
    required WidgetRef ref,
    required String requesterUserId,
    required String requesterUsername,
    required String receiverUserId,
    required String receiverUsername,
  }) async {
    try {
      await ref
          .read(userConnectionActionControllerProvider.notifier)
          .sendRequest(
            requesterUserId: requesterUserId,
            requesterUsername: requesterUsername,
            receiverUserId: receiverUserId,
            receiverUsername: receiverUsername,
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Arkadaşlık isteği gönderildi.')),
        );
      }
    } on UserConnectionRepositoryException catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    }
  }

  String _friendName(UserConnectionModel connection, String uid) {
    return connection.requesterUserId == uid
        ? connection.receiverUsername
        : connection.requesterUsername;
  }
}
