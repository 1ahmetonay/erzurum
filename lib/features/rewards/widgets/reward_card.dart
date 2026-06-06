import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/reward_model.dart';

class RewardCard extends StatelessWidget {
  const RewardCard({
    required this.reward,
    required this.userPoints,
    required this.onUse,
    this.isLoading = false,
    super.key,
  });

  final RewardModel reward;
  final int userPoints;
  final VoidCallback onUse;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final hasStock = reward.stockCount == null || reward.stockCount! > 0;
    final canUse =
        reward.isActive && hasStock && userPoints >= reward.requiredPoints;
    final disabledLabel = !hasStock ? 'Stok yok' : 'Yetersiz';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 58,
            height: 58,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(reward.iconEmoji, style: const TextStyle(fontSize: 28)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(reward.title, style: AppTextStyles.subtitle),
                const SizedBox(height: 4),
                Text(reward.description, style: AppTextStyles.caption),
                const SizedBox(height: 10),
                Text(
                  '${reward.requiredPoints} Dadaş Puan',
                  style: AppTextStyles.points,
                ),
                if (reward.stockCount != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Stok: ${reward.stockCount}',
                    style: AppTextStyles.caption.copyWith(
                      color: hasStock
                          ? AppColors.textSecondary
                          : AppColors.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: canUse && !isLoading ? onUse : null,
            child: isLoading
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(canUse ? 'Kullan' : disabledLabel),
          ),
        ],
      ),
    );
  }
}
