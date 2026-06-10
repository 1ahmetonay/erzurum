import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/cleanup_event_model.dart';
import '../../providers/cleanup_event_provider.dart';
import '../../providers/user_provider.dart';
import '../../shared/widgets/empty_state.dart';

class CleanupApprovalsScreen extends ConsumerWidget {
  const CleanupApprovalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(currentUserIsAdminProvider);
    final pendingState = ref.watch(pendingApprovalCleanupEventsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Temizlik Onayları')),
      body: SafeArea(
        child: !isAdmin
            ? const Padding(
                padding: EdgeInsets.all(18),
                child: EmptyState(
                  title: 'Yetki gerekli',
                  message: 'Bu ekran yalnızca admin kullanıcılar içindir.',
                  icon: Icons.admin_panel_settings_outlined,
                ),
              )
            : pendingState.when(
                data: (events) {
                  if (events.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(18),
                      child: EmptyState(
                        title: 'Onay bekleyen kayıt yok',
                        message:
                            'Temizlik kanıtları gönderildiğinde burada listelenir.',
                        icon: Icons.fact_check_outlined,
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
                    itemCount: events.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return _ApprovalCard(
                        event: event,
                        onReview: () =>
                            context.go('/admin/cleanup-approvals/${event.id}'),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) => const Padding(
                  padding: EdgeInsets.all(18),
                  child: EmptyState(
                    title: 'Onaylar yüklenemedi',
                    message: 'Onay bekleyen temizlikler şu anda alınamadı.',
                    icon: Icons.error_outline,
                  ),
                ),
              ),
      ),
    );
  }
}

class _ApprovalCard extends StatelessWidget {
  const _ApprovalCard({required this.event, required this.onReview});

  final CleanupEventModel event;
  final VoidCallback onReview;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (event.completionPhotoUrl != null &&
              event.completionPhotoUrl!.isNotEmpty)
            AspectRatio(
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
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.subtitle.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Yükleyen: ${event.createdByUsername}',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${event.participantCount} katılımcı / kişi başı ${event.pointsPerParticipant} puan',
                  style: AppTextStyles.body,
                ),
                if (event.completedAt != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    DateFormat('d MMMM y, HH:mm').format(event.completedAt!),
                    style: AppTextStyles.caption,
                  ),
                ],
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    onPressed: onReview,
                    icon: const Icon(Icons.rate_review_outlined),
                    label: const Text('İncele'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
