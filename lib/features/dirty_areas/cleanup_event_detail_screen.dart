import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/cleanup_event_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cleanup_event_provider.dart';
import '../../providers/cleanup_group_provider.dart';
import '../../repositories/cleanup_event_repository.dart';
import '../../shared/widgets/empty_state.dart';
import 'widgets/cleanup_event_card.dart';
import 'widgets/cleanup_group_card.dart';

class CleanupEventDetailScreen extends ConsumerStatefulWidget {
  const CleanupEventDetailScreen({required this.cleanupEventId, super.key});

  final String cleanupEventId;

  @override
  ConsumerState<CleanupEventDetailScreen> createState() =>
      _CleanupEventDetailScreenState();
}

class _CleanupEventDetailScreenState
    extends ConsumerState<CleanupEventDetailScreen> {
  bool _isUpdatingParticipation = false;

  @override
  Widget build(BuildContext context) {
    final eventState = ref.watch(
      cleanupEventDetailProvider(widget.cleanupEventId),
    );
    final firebaseUser = ref.watch(authStateProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(title: const Text('Temizlik Etkinliği')),
      body: SafeArea(
        child: eventState.when(
          data: (event) {
            if (event == null) {
              return const Padding(
                padding: EdgeInsets.all(18),
                child: EmptyState(
                  title: 'Etkinlik bulunamadı',
                  message: 'Bu temizlik etkinliği silinmiş veya erişilemiyor.',
                  icon: Icons.event_busy_outlined,
                ),
              );
            }

            final userId = firebaseUser?.uid;
            final hasJoined =
                userId != null && event.participantIds.contains(userId);
            final isClosed =
                event.status == CleanupEventStatuses.completed ||
                event.status == CleanupEventStatuses.pendingApproval ||
                event.status == CleanupEventStatuses.cancelled;
            final isFull =
                !hasJoined && event.participantCount >= event.maxParticipants;
            final isCreator = userId == event.createdByUserId;
            final isCompleted = event.status == CleanupEventStatuses.completed;
            final isPendingApproval =
                event.status == CleanupEventStatuses.pendingApproval;
            final isRejected =
                event.approvalStatus == CleanupApprovalStatuses.rejected;
            final canComplete =
                isCreator &&
                !isPendingApproval &&
                !isCompleted &&
                event.status != CleanupEventStatuses.cancelled &&
                (event.status == CleanupEventStatuses.planned ||
                    event.status == CleanupEventStatuses.inProgress ||
                    isRejected);

            return ListView(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
              children: [
                Text(
                  event.title,
                  style: AppTextStyles.title.copyWith(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  event.description,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 18),
                _DetailTile(
                  icon: Icons.place_outlined,
                  title: 'Buluşma noktası',
                  value: event.meetingPointText,
                ),
                _DetailTile(
                  icon: Icons.schedule_outlined,
                  title: 'Tarih / saat',
                  value: DateFormat(
                    'd MMMM y, HH:mm',
                  ).format(event.scheduledAt),
                ),
                _DetailTile(
                  icon: Icons.flag_outlined,
                  title: 'Durum',
                  value: cleanupEventStatusLabel(event.status),
                ),
                _DetailTile(
                  icon: Icons.groups_outlined,
                  title: 'Katılımcı',
                  value:
                      '${event.participantCount}/${event.maxParticipants} kişi',
                ),
                _DetailTile(
                  icon: Icons.person_outline,
                  title: 'Oluşturan',
                  value: event.createdByUsername,
                ),
                if (isCompleted || isPendingApproval || isRejected) ...[
                  const SizedBox(height: 8),
                  _CompletionSummary(
                    event: event,
                    hasJoined: hasJoined,
                    isPendingApproval: isPendingApproval,
                    isRejected: isRejected,
                  ),
                ],
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () =>
                      context.go('/dirty-areas/${event.dirtyAreaId}'),
                  icon: const Icon(Icons.location_on_outlined),
                  label: const Text('Bağlı Kirli Bölgeye Git'),
                ),
                const SizedBox(height: 18),
                _CleanupGroupsSection(event: event),
                if (canComplete) ...[
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    onPressed: () =>
                        context.go('/cleanup-events/${event.id}/complete'),
                    icon: const Icon(Icons.verified_outlined),
                    label: const Text('Temizliği Tamamla'),
                  ),
                ],
                const SizedBox(height: 12),
                _ParticipationButton(
                  isBusy: _isUpdatingParticipation,
                  isClosed: isClosed,
                  isFull: isFull,
                  hasJoined: hasJoined,
                  onPressed: userId == null
                      ? null
                      : () => _toggleParticipation(
                          event: event,
                          userId: userId,
                          hasJoined: hasJoined,
                        ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => const Padding(
            padding: EdgeInsets.all(18),
            child: EmptyState(
              title: 'Etkinlik yüklenemedi',
              message: 'Temizlik etkinliği detayı şu anda alınamadı.',
              icon: Icons.error_outline,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _toggleParticipation({
    required CleanupEventModel event,
    required String userId,
    required bool hasJoined,
  }) async {
    setState(() => _isUpdatingParticipation = true);
    try {
      final repository = ref.read(cleanupEventRepositoryProvider);
      if (hasJoined) {
        await repository.leaveEvent(eventId: event.id, userId: userId);
        if (mounted) _showMessage('Etkinlikten ayrıldın.');
      } else {
        await repository.joinEvent(eventId: event.id, userId: userId);
        if (mounted) _showMessage('Etkinliğe katıldın.');
      }
    } on CleanupEventRepositoryException catch (error) {
      if (mounted) _showMessage(error.message);
    } on Object {
      if (mounted) _showMessage('İşlem tamamlanamadı. Tekrar dene.');
    } finally {
      if (mounted) setState(() => _isUpdatingParticipation = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _CleanupGroupsSection extends ConsumerWidget {
  const _CleanupGroupsSection({required this.event});

  final CleanupEventModel event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsState = ref.watch(cleanupGroupsForEventProvider(event.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Temizlik Grupları',
                style: AppTextStyles.subtitle.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: () =>
                  context.go('/cleanup-events/${event.id}/create-group'),
              icon: const Icon(Icons.group_add_outlined),
              label: const Text('Grup Oluştur'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        groupsState.when(
          data: (groups) {
            if (groups.isEmpty) {
              return const EmptyState(
                title: 'Henüz grup yok',
                message:
                    'Bu temizlik etkinliği için ilk grubu oluşturup arkadaşlarını davet edebilirsin.',
                icon: Icons.groups_outlined,
              );
            }

            return Column(
              children: [
                for (final group in groups) ...[
                  CleanupGroupCard(
                    group: group,
                    onOpen: () => context.go('/cleanup-groups/${group.id}'),
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => const EmptyState(
            title: 'Gruplar yüklenemedi',
            message: 'Temizlik grupları şu anda alınamadı.',
            icon: Icons.error_outline,
          ),
        ),
      ],
    );
  }
}

class _CompletionSummary extends StatelessWidget {
  const _CompletionSummary({
    required this.event,
    required this.hasJoined,
    required this.isPendingApproval,
    required this.isRejected,
  });

  final CleanupEventModel event;
  final bool hasJoined;
  final bool isPendingApproval;
  final bool isRejected;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryFixed.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryFixedDim),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isRejected
                    ? Icons.cancel_outlined
                    : isPendingApproval
                    ? Icons.pending_actions_outlined
                    : Icons.check_circle,
                color: isRejected ? AppColors.error : AppColors.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isRejected
                      ? 'Temizlik kanıtı reddedildi'
                      : isPendingApproval
                      ? 'Temizlik kanıtı admin onayında'
                      : 'Temizlik onaylandı ve Dadaş puanları dağıtıldı',
                  style: AppTextStyles.subtitle.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          if (event.completionPhotoUrl != null &&
              event.completionPhotoUrl!.isNotEmpty) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  event.completionPhotoUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const ColoredBox(
                    color: AppColors.surfaceContainer,
                    child: Center(child: Icon(Icons.image_not_supported)),
                  ),
                ),
              ),
            ),
          ],
          if (event.completedAt != null) ...[
            const SizedBox(height: 12),
            Text(
              'Tamamlanma: ${DateFormat('d MMMM y, HH:mm').format(event.completedAt!)}',
              style: AppTextStyles.body,
            ),
          ],
          const SizedBox(height: 6),
          Text(
            isPendingApproval
                ? 'Katılımcılara henüz puan verilmedi. Admin onayı bekleniyor.'
                : isRejected
                ? 'Puan verilmedi. Creator yeni kanıt gönderebilir.'
                : 'Kişi başı ${event.pointsPerParticipant} Dadaş puan verildi.',
            style: AppTextStyles.body,
          ),
          if (isRejected && event.rejectionReason != null) ...[
            const SizedBox(height: 6),
            Text(
              'Red sebebi: ${event.rejectionReason}',
              style: AppTextStyles.body.copyWith(color: AppColors.error),
            ),
          ],
          if (hasJoined && !isPendingApproval && !isRejected) ...[
            const SizedBox(height: 6),
            Text(
              'Bu etkinlikten Dadaş puan kazandın.',
              style: AppTextStyles.body.copyWith(
                color: AppColors.primaryDark,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ParticipationButton extends StatelessWidget {
  const _ParticipationButton({
    required this.isBusy,
    required this.isClosed,
    required this.isFull,
    required this.hasJoined,
    required this.onPressed,
  });

  final bool isBusy;
  final bool isClosed;
  final bool isFull;
  final bool hasJoined;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    if (isClosed) {
      return const FilledButton(
        onPressed: null,
        child: Text('Etkinlik Kapalı'),
      );
    }
    if (isFull) {
      return const FilledButton(onPressed: null, child: Text('Etkinlik Dolu'));
    }

    return FilledButton.icon(
      onPressed: isBusy ? null : onPressed,
      icon: isBusy
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(hasJoined ? Icons.logout_outlined : Icons.group_add_outlined),
      label: Text(hasJoined ? 'Etkinlikten Ayrıl' : 'Etkinliğe Katıl'),
    );
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
