import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/reward_model.dart';

class RewardCard extends StatelessWidget {
  const RewardCard({
    required this.reward,
    required this.onTap,
    required this.imageAsset,
    required this.isSelected,
    this.isLoading = false,
    this.isPopular = false,
    super.key,
  });

  final RewardModel reward;
  final VoidCallback onTap;
  final String imageAsset;
  final bool isSelected;
  final bool isLoading;
  final bool isPopular;

  @override
  Widget build(BuildContext context) {
    final hasStock = reward.stockCount == null || reward.stockCount! > 0;

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryFixed.withValues(alpha: 0.2)
              : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.outlineVariant,
            width: isSelected ? 1.4 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withValues(
                alpha: isSelected ? 0.14 : 0.07,
              ),
              blurRadius: isSelected ? 18 : 12,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: AspectRatio(
                    aspectRatio: 2.05,
                    child: Image.asset(imageAsset, fit: BoxFit.cover),
                  ),
                ),
                if (isPopular)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star,
                            size: 14,
                            color: AppColors.onPrimary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Popüler',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.onPrimary,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              reward.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.subtitle.copyWith(
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              reward.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                if (isLoading)
                  const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  const Icon(
                    Icons.token_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${_formatPoints(reward.requiredPoints)} Puan',
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Detayları Aç',
                  visualDensity: VisualDensity.compact,
                  onPressed: onTap,
                  icon: const Icon(
                    Icons.arrow_forward,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            if (!hasStock) ...[
              const SizedBox(height: 4),
              Text(
                'Stok yok',
                style: AppTextStyles.caption.copyWith(color: AppColors.error),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

String _formatPoints(int points) {
  return points.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (match) => '${match[1]}.',
  );
}
