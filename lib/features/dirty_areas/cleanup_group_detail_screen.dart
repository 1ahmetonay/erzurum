import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/social_demo_data.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/cleanup_group_model.dart';
import '../../models/user_connection_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cleanup_group_provider.dart';
import '../../providers/user_connection_provider.dart';
import '../../providers/user_provider.dart';
import '../../repositories/cleanup_group_repository.dart';
import '../../shared/widgets/empty_state.dart';

class CleanupGroupDetailScreen extends ConsumerWidget {
  const CleanupGroupDetailScreen({required this.cleanupGroupId, super.key});

  final String cleanupGroupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupState = ref.watch(cleanupGroupDetailProvider(cleanupGroupId));
    final firebaseUser = ref.watch(authStateProvider).valueOrNull;
    final currentUser = ref.watch(currentUserProvider).valueOrNull;
    final actionState = ref.watch(cleanupGroupActionControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Temizlik Grubu')),
      body: SafeArea(
        child: groupState.when(
          data: (group) {
            if (group == null) {
              return const Padding(
                padding: EdgeInsets.all(18),
                child: EmptyState(
                  title: 'Grup bulunamadı',
                  message: 'Bu temizlik grubu silinmiş veya erişilemiyor.',
                  icon: Icons.group_off_outlined,
                ),
              );
            }

            final userId = firebaseUser?.uid;
            final isMember = userId != null && group.memberIds.contains(userId);
            final isFull = group.memberCount >= group.maxMembers;
            final isClosed =
                group.status == CleanupGroupStatuses.completed ||
                group.status == CleanupGroupStatuses.cancelled;
            final isDemoGroup = SocialDemoData.isDemoId(group.id);

            return ListView(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
              children: [
                Text(
                  group.name,
                  style: AppTextStyles.title.copyWith(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  group.description.isEmpty
                      ? 'Bu grup için henüz açıklama eklenmedi.'
                      : group.description,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 18),
                _GroupStatTile(
                  icon: Icons.person_outline,
                  title: 'Oluşturan',
                  value: group.createdByUsername,
                ),
                _GroupStatTile(
                  icon: Icons.groups_outlined,
                  title: 'Üye sayısı',
                  value: '${group.memberCount}/${group.maxMembers} kişi',
                ),
                _GroupStatTile(
                  icon: Icons.flag_outlined,
                  title: 'Durum',
                  value: _statusLabel(group.status),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () =>
                      context.go('/cleanup-events/${group.cleanupEventId}'),
                  icon: const Icon(Icons.event_outlined),
                  label: const Text('Etkinliğe Git'),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed:
                      userId == null ||
                          isDemoGroup ||
                          actionState.isLoading ||
                          isClosed ||
                          (!isMember && isFull)
                      ? null
                      : () => _toggleMembership(
                          context: context,
                          ref: ref,
                          group: group,
                          userId: userId,
                          isMember: isMember,
                        ),
                  icon: actionState.isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          isMember
                              ? Icons.logout_outlined
                              : Icons.group_add_outlined,
                        ),
                  label: Text(
                    isClosed
                        ? 'Grup Kapalı'
                        : isFull && !isMember
                        ? 'Grup Dolu'
                        : isMember
                        ? 'Gruptan Ayrıl'
                        : 'Gruba Katıl',
                  ),
                ),
                const SizedBox(height: 22),
                _MembersSection(
                  memberIds: group.memberIds,
                  currentUserId: firebaseUser?.uid,
                  currentUsername: currentUser?.displayName,
                ),
                const SizedBox(height: 22),
                if (isMember && !isDemoGroup)
                  _InviteFriendsSection(group: group)
                else if (isDemoGroup)
                  const EmptyState(
                    title: 'Demo grup',
                    message:
                        'Bu grup tanıtım verisidir. Üyelik ve davet işlemleri kapalıdır.',
                    icon: Icons.visibility_outlined,
                  )
                else
                  const EmptyState(
                    title: 'Davet için gruba katıl',
                    message:
                        'Arkadaşlarını bu temizlik grubuna davet etmek için önce gruba katılmalısın.',
                    icon: Icons.person_add_disabled_outlined,
                  ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => const Padding(
            padding: EdgeInsets.all(18),
            child: EmptyState(
              title: 'Grup yüklenemedi',
              message: 'Temizlik grubu detayı şu anda alınamadı.',
              icon: Icons.error_outline,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _toggleMembership({
    required BuildContext context,
    required WidgetRef ref,
    required CleanupGroupModel group,
    required String userId,
    required bool isMember,
  }) async {
    try {
      final controller = ref.read(
        cleanupGroupActionControllerProvider.notifier,
      );
      if (isMember) {
        await controller.leaveGroup(groupId: group.id, userId: userId);
        if (!context.mounted) return;
        _showMessage(context, 'Gruptan ayrıldın.');
      } else {
        await controller.joinGroup(groupId: group.id, userId: userId);
        if (!context.mounted) return;
        _showMessage(context, 'Gruba katıldın.');
      }
    } on CleanupGroupRepositoryException catch (error) {
      if (!context.mounted) return;
      _showMessage(context, error.message);
    } on Object {
      if (!context.mounted) return;
      _showMessage(context, 'İşlem tamamlanamadı. Tekrar dene.');
    }
  }
}

class _InviteFriendsSection extends ConsumerWidget {
  const _InviteFriendsSection({required this.group});

  final CleanupGroupModel group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friendsState = ref.watch(acceptedConnectionsProvider);
    final firebaseUser = ref.watch(authStateProvider).valueOrNull;
    final currentUser = ref.watch(currentUserProvider).valueOrNull;
    final isSaving = ref.watch(cleanupGroupActionControllerProvider).isLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          title: 'Arkadaş Davet Et',
          actionLabel: 'Arkadaşlarım',
          onAction: () => context.go('/friends'),
        ),
        const SizedBox(height: 10),
        friendsState.when(
          data: (friends) {
            final inviteable = friends
                .map((connection) => _friendView(connection, firebaseUser?.uid))
                .where((friend) => !group.memberIds.contains(friend.userId))
                .toList();
            if (inviteable.isEmpty) {
              return const EmptyState(
                title: 'Davet edilecek arkadaş yok',
                message:
                    'Arkadaş ekledikten sonra buradan grup daveti gönderebilirsin.',
                icon: Icons.person_add_alt_outlined,
              );
            }

            final invitedByUsername =
                currentUser?.displayName.trim().isNotEmpty == true
                ? currentUser!.displayName
                : firebaseUser?.displayName ?? 'AtıkAvı Üyesi';

            return Column(
              children: [
                for (final friend in inviteable) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.outlineVariant),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: AppColors.secondaryContainer,
                          child: Icon(
                            Icons.person_outline,
                            color: AppColors.primaryDark,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            friend.username,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.subtitle.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        TextButton.icon(
                          onPressed:
                              firebaseUser == null ||
                                  isSaving ||
                                  SocialDemoData.isDemoId(friend.userId)
                              ? null
                              : () => _invite(
                                  context: context,
                                  ref: ref,
                                  group: group,
                                  invitedByUserId: firebaseUser.uid,
                                  invitedByUsername: invitedByUsername,
                                  friend: friend,
                                ),
                          icon: const Icon(Icons.send_outlined),
                          label: const Text('Davet'),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => const EmptyState(
            title: 'Arkadaşlar yüklenemedi',
            message: 'Davet listesi şu anda alınamadı.',
            icon: Icons.error_outline,
          ),
        ),
      ],
    );
  }

  Future<void> _invite({
    required BuildContext context,
    required WidgetRef ref,
    required CleanupGroupModel group,
    required String invitedByUserId,
    required String invitedByUsername,
    required _FriendView friend,
  }) async {
    try {
      await ref
          .read(cleanupGroupActionControllerProvider.notifier)
          .invite(
            group: group,
            invitedByUserId: invitedByUserId,
            invitedByUsername: invitedByUsername,
            invitedUserId: friend.userId,
            invitedUsername: friend.username,
          );
      if (!context.mounted) return;
      _showMessage(context, 'Davet gönderildi.');
    } on CleanupGroupRepositoryException catch (error) {
      if (!context.mounted) return;
      _showMessage(context, error.message);
    } on Object {
      if (!context.mounted) return;
      _showMessage(context, 'Davet gönderilemedi. Tekrar dene.');
    }
  }

  _FriendView _friendView(UserConnectionModel connection, String? currentUid) {
    if (connection.requesterUserId == currentUid) {
      return _FriendView(
        userId: connection.receiverUserId,
        username: connection.receiverUsername,
      );
    }
    return _FriendView(
      userId: connection.requesterUserId,
      username: connection.requesterUsername,
    );
  }
}

class _MembersSection extends StatelessWidget {
  const _MembersSection({
    required this.memberIds,
    required this.currentUserId,
    required this.currentUsername,
  });

  final List<String> memberIds;
  final String? currentUserId;
  final String? currentUsername;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(title: 'Grup Üyeleri'),
        const SizedBox(height: 10),
        for (final memberId in memberIds) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Row(
              children: [
                const Icon(Icons.person_outline, color: AppColors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _memberLabel(memberId),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  String _memberLabel(String memberId) {
    if (memberId == currentUserId) {
      final username = currentUsername?.trim();
      return username == null || username.isEmpty ? 'Sen' : '$username (Sen)';
    }
    return switch (memberId) {
      '${SocialDemoData.idPrefix}user_ayse' => 'Ayşe Yılmaz',
      '${SocialDemoData.idPrefix}user_mehmet' => 'Mehmet Kaya',
      'demo_user_ayse' => 'Ayşe Yıldırım',
      'demo_user_mehmet' => 'Mehmet Demir',
      'demo_user_zeynep' => 'Zeynep Kaya',
      'demo_user_emir' => 'Emir Çelik',
      'demo_user_elifsu' => 'Elifsu Arslan',
      _ => memberId,
    };
  }
}

class _GroupStatTile extends StatelessWidget {
  const _GroupStatTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(value, style: AppTextStyles.body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.actionLabel, this.onAction});

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.subtitle.copyWith(fontWeight: FontWeight.w900),
          ),
        ),
        if (actionLabel != null)
          TextButton(onPressed: onAction, child: Text(actionLabel!)),
      ],
    );
  }
}

class _FriendView {
  const _FriendView({required this.userId, required this.username});

  final String userId;
  final String username;
}

String _statusLabel(String status) {
  return switch (status) {
    CleanupGroupStatuses.active => 'Aktif',
    CleanupGroupStatuses.full => 'Dolu',
    CleanupGroupStatuses.completed => 'Tamamlandı',
    CleanupGroupStatuses.cancelled => 'İptal',
    _ => status,
  };
}

void _showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
