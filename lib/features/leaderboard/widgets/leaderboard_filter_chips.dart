import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/leaderboard_model.dart';

class LeaderboardFilterChips extends StatelessWidget {
  const LeaderboardFilterChips({
    required this.selectedCategory,
    required this.onSelected,
    super.key,
  });

  final String selectedCategory;
  final ValueChanged<String> onSelected;

  static const items = [
    ('Bireysel', LeaderboardCategories.individual),
    ('Mahalle', LeaderboardCategories.neighborhood),
    ('Okullar', LeaderboardCategories.school),
    ('Kampüs', LeaderboardCategories.campus),
    ('Yakutiye', LeaderboardCategories.districtYakutiye),
    ('Palandöken', LeaderboardCategories.districtPalandoken),
    ('Aziziye', LeaderboardCategories.districtAziziye),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          for (final item in items) ...[
            _LeaderboardChip(
              label: item.$1,
              selected: selectedCategory == item.$2,
              onTap: () => onSelected(item.$2),
            ),
            const SizedBox(width: 12),
          ],
        ],
      ),
    );
  }
}

class _LeaderboardChip extends StatelessWidget {
  const _LeaderboardChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.outlineVariant,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.shadow.withValues(alpha: 0.26),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: AppTextStyles.subtitle.copyWith(
            color: selected ? AppColors.onPrimary : AppColors.textPrimary,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
