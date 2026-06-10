import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/cleanup_event_model.dart';

class CleanupEventCard extends StatelessWidget {
  const CleanupEventCard({
    required this.cleanupEvent,
    required this.onOpenDetail,
    super.key,
  });

  final CleanupEventModel cleanupEvent;
  final VoidCallback onOpenDetail;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  cleanupEvent.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.subtitle.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _StatusChip(status: cleanupEvent.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            cleanupEvent.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.place_outlined,
            label: cleanupEvent.meetingPointText,
          ),
          const SizedBox(height: 8),
          _InfoRow(
            icon: Icons.schedule_outlined,
            label: DateFormat(
              'd MMM y, HH:mm',
            ).format(cleanupEvent.scheduledAt),
          ),
          const SizedBox(height: 8),
          _InfoRow(
            icon: Icons.groups_outlined,
            label:
                '${cleanupEvent.participantCount}/${cleanupEvent.maxParticipants} katılımcı',
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onOpenDetail,
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Detaya Git'),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryFixed.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        cleanupEventStatusLabel(status),
        style: AppTextStyles.caption.copyWith(
          color: AppColors.primaryDark,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

String cleanupEventStatusLabel(String status) {
  return switch (status) {
    CleanupEventStatuses.planned => 'Planlandı',
    CleanupEventStatuses.inProgress => 'Sürüyor',
    CleanupEventStatuses.pendingApproval => 'Onay Bekliyor',
    CleanupEventStatuses.completed => 'Tamamlandı',
    CleanupEventStatuses.cancelled => 'İptal',
    _ => 'Bilinmiyor',
  };
}
