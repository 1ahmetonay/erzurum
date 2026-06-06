import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/task_model.dart';

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
    final requiredCount = task.requiredCount;
    final hasCount = requiredCount != null && requiredCount > 0;
    final progress = hasCount
        ? (task.currentCount / requiredCount).clamp(0.0, 1.0)
        : 0.0;
    final accent = task.isWinterOnly ? AppColors.winterBlue : AppColors.primary;
    final progressValue = task.isCompleted ? 1.0 : progress;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: highlighted
                  ? accent
                  : task.isWinterOnly
                  ? AppColors.winterIce
                  : AppColors.outlineVariant,
              width: highlighted ? 1.6 : 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TaskIconBox(task: task),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.subtitle.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              task.isWinterOnly
                                  ? Icons.ac_unit
                                  : Icons.add_circle_outline,
                              color: accent,
                              size: 15,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '+${task.pointReward} Puan',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  _CategoryBadge(task: task),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Text(
                    hasCount ? 'İlerleme' : 'Tamamlanma',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _progressLabel(task),
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: progressValue,
                  minHeight: 11,
                  color: task.isCompleted ? AppColors.success : accent,
                  backgroundColor: AppColors.surfaceContainer,
                ),
              ),
              const SizedBox(height: 14),
              FilledButton(
                onPressed: onTap,
                style: FilledButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: AppColors.textOnPrimary,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(_actionLabel(task)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TaskIconBox extends StatelessWidget {
  const _TaskIconBox({required this.task});

  final TaskModel task;

  @override
  Widget build(BuildContext context) {
    final accent = task.isWinterOnly ? AppColors.winterBlue : AppColors.primary;

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Text(task.iconEmoji, style: const TextStyle(fontSize: 24)),
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.task});

  final TaskModel task;

  @override
  Widget build(BuildContext context) {
    final accent = task.isWinterOnly ? AppColors.winterBlue : AppColors.primary;

    return Container(
      constraints: const BoxConstraints(maxWidth: 94),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: task.isWinterOnly ? 1 : 0.18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _typeLabel(task),
        maxLines: 2,
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.caption.copyWith(
          color: task.isWinterOnly ? AppColors.onTertiary : AppColors.primary,
          fontWeight: FontWeight.w900,
          height: 1.05,
        ),
      ),
    );
  }
}

String _progressLabel(TaskModel task) {
  final requiredCount = task.requiredCount;
  if (task.isCompleted) return 'Tamamlandı';
  if (requiredCount == null || requiredCount <= 0) return 'Yeni';
  return '${task.currentCount}/$requiredCount';
}

String _actionLabel(TaskModel task) {
  if (task.isCompleted) return 'Tamamlandı';
  if (task.type == TaskTypes.social) return 'Davet Et';
  if (task.type == TaskTypes.education) return 'Başlat';
  return 'Yap';
}

String _typeLabel(TaskModel task) {
  if (task.isWinterOnly) return 'Kış\nBonusu';
  return switch (task.type) {
    TaskTypes.daily => 'Günlük',
    TaskTypes.weekly => 'Haftalık',
    TaskTypes.social => 'Sosyal',
    TaskTypes.education => 'Eğitim',
    TaskTypes.winter => 'Kış',
    _ => 'Görev',
  };
}
