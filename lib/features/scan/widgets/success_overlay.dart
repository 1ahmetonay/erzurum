import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class SuccessOverlay extends StatelessWidget {
  const SuccessOverlay({
    this.title = 'Başarılı!',
    this.message = '+10 Dadaş Puan kazandınız.',
    this.bonusPoints = 0,
    this.completedTaskTitles = const [],
    this.onDismiss,
    super.key,
  });

  final String title;
  final String message;
  final int bonusPoints;
  final List<String> completedTaskTitles;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 420),
      padding: const EdgeInsets.fromLTRB(28, 30, 28, 24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 28,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 92,
            height: 92,
            decoration: const BoxDecoration(
              color: AppColors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.onPrimaryContainer,
                child: Icon(Icons.check, color: AppColors.primary, size: 36),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.display.copyWith(
              color: AppColors.primary,
              fontSize: 32,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.subtitle.copyWith(
              color: AppColors.textSecondary,
              fontSize: 18,
            ),
          ),
          if (completedTaskTitles.isNotEmpty) ...[
            const SizedBox(height: 18),
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
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onDismiss,
              child: const Text('Harika!'),
            ),
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
