import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class SuccessOverlay extends StatelessWidget {
  const SuccessOverlay({
    this.title = 'Kayıt tamamlandı',
    this.message = '+10 Dadaş Puan kazandın!',
    this.bonusPoints = 0,
    this.completedTaskTitles = const [],
    super.key,
  });

  final String title;
  final String message;
  final int bonusPoints;
  final List<String> completedTaskTitles;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.primaryLight),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 10,
            top: 6,
            child: Icon(
              Icons.auto_awesome,
              color: AppColors.gold.withValues(alpha: 0.9),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: AppColors.primaryDark,
                      size: 34,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: AppTextStyles.subtitle),
                        const SizedBox(height: 4),
                        Text(message, style: AppTextStyles.points),
                      ],
                    ),
                  ),
                ],
              ),
              if (completedTaskTitles.isNotEmpty) ...[
                const SizedBox(height: 14),
                for (final taskTitle in completedTaskTitles.take(3)) ...[
                  _CompletedTaskRow(title: taskTitle),
                  const SizedBox(height: 6),
                ],
                if (bonusPoints > 0)
                  Text(
                    '+$bonusPoints bonus puan',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _CompletedTaskRow extends StatelessWidget {
  const _CompletedTaskRow({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.task_alt, size: 18, color: AppColors.success),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Görev tamamlandı: $title',
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
