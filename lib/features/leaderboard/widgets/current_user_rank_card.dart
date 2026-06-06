import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/leaderboard_model.dart';
import 'leaderboard_avatar.dart';

class CurrentUserRankCard extends StatelessWidget {
  const CurrentUserRankCard({required this.entry, super.key});

  final LeaderboardModel entry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.32),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          LeaderboardAvatar(
            name: entry.name,
            photoUrl: entry.photoUrl,
            size: 58,
            borderColor: AppColors.onPrimary,
            backgroundColor: AppColors.primaryFixed,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sen: Dadaş',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.subtitle.copyWith(
                    color: AppColors.onPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Sıralama: #${entry.rank}',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.onPrimary.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${entry.weeklyPoints}',
            style: AppTextStyles.title.copyWith(
              color: AppColors.onPrimary,
              fontSize: 32,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'PUAN',
            style: AppTextStyles.label.copyWith(
              color: AppColors.onPrimary.withValues(alpha: 0.9),
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
