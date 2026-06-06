import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/task_model.dart';
import '../../../shared/widgets/puan_badge.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({
    required this.task,
    this.onTap,
    this.highlighted = false,
    super.key,
  });

  final TaskModel task;
  final VoidCallback? onTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final requiredCount = task.requiredCount ?? 1;
    final progress = requiredCount == 0
        ? 0.0
        : (task.currentCount / requiredCount).clamp(0.0, 1.0);
    final accent = task.isWinterOnly ? AppColors.winterBlue : AppColors.primary;
    final statusColor = task.isCompleted ? AppColors.success : accent;

    final borderColor = highlighted
        ? AppColors.primary
        : task.isCompleted
        ? AppColors.success.withValues(alpha: 0.28)
        : task.isWinterOnly
        ? AppColors.winterIce
        : AppColors.outlineVariant;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: task.isCompleted
              ? AppColors.cardBg
              : AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: highlighted ? 1.6 : 1),
          boxShadow: highlighted
              ? const [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(task.iconEmoji, style: const TextStyle(fontSize: 30)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(task.title, style: AppTextStyles.subtitle),
                      const SizedBox(height: 4),
                      Text(task.description, style: AppTextStyles.caption),
                    ],
                  ),
                ),
                if (task.isCompleted)
                  const Icon(Icons.check_circle, color: AppColors.success)
                else
                  PuanBadge(points: task.pointReward, compact: true),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: task.isCompleted ? 1 : progress,
                minHeight: 10,
                color: task.isCompleted ? AppColors.success : accent,
                backgroundColor: AppColors.surfaceLow,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _StatusChip(
                  label: task.isCompleted ? 'Tamamlandı' : 'Başla',
                  color: statusColor,
                ),
                const SizedBox(width: 8),
                Text(
                  '${task.currentCount}/$requiredCount',
                  style: AppTextStyles.caption.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Text(_typeLabel(task.type), style: AppTextStyles.caption),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _typeLabel(String type) {
    return switch (type) {
      TaskTypes.daily => 'Günlük',
      TaskTypes.weekly => 'Haftalık',
      TaskTypes.social => 'Sosyal',
      TaskTypes.education => 'Eğitim',
      TaskTypes.winter => 'Kış',
      _ => 'Görev',
    };
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
