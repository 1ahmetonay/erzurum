import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/leaderboard_model.dart';

class RankCard extends StatelessWidget {
  const RankCard({required this.entry, this.isCurrentUser = false, super.key});

  final LeaderboardModel entry;
  final bool isCurrentUser;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrentUser ? AppColors.cardBg : AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isCurrentUser ? AppColors.primaryLight : AppColors.outline,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: _rankColor(entry.rank),
            foregroundColor: AppColors.textPrimary,
            child: Text('#${entry.rank}', style: AppTextStyles.label),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.name, style: AppTextStyles.subtitle),
                const SizedBox(height: 2),
                Text(
                  _categoryLabel(entry.category),
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          Text('${entry.weeklyPoints} puan', style: AppTextStyles.points),
        ],
      ),
    );
  }

  Color _rankColor(int rank) {
    return switch (rank) {
      1 => AppColors.gold,
      2 => AppColors.silver,
      3 => AppColors.bronze,
      _ => AppColors.surfaceLow,
    };
  }

  String _categoryLabel(String category) {
    return switch (category) {
      LeaderboardCategories.individual => 'Bireysel',
      LeaderboardCategories.neighborhood => 'Mahalle',
      LeaderboardCategories.campus => 'Kampüs',
      LeaderboardCategories.school => 'Okul',
      _ => 'Sıralama',
    };
  }
}
