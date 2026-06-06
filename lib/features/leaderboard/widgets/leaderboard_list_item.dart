import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/leaderboard_model.dart';
import 'leaderboard_avatar.dart';

class LeaderboardListItem extends StatelessWidget {
  const LeaderboardListItem({required this.entry, super.key});

  final LeaderboardModel entry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text(
              '${entry.rank}',
              style: AppTextStyles.subtitle.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          LeaderboardAvatar(
            name: entry.name,
            photoUrl: entry.photoUrl,
            size: 54,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.title.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  leaderboardTitleForRank(entry.rank),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '${_formatPoints(entry.weeklyPoints)} P',
            style: AppTextStyles.points.copyWith(fontSize: 19),
          ),
        ],
      ),
    );
  }
}

String leaderboardTitleForRank(int rank) {
  return switch (rank) {
    4 => 'Yıldız Atıkçı',
    5 => 'Doğa Dostu',
    6 => 'Sıfır Atık Gönüllüsü',
    7 => 'Geri Dönüşüm Kahramanı',
    _ => 'AtıkAvı Gönüllüsü',
  };
}

String _formatPoints(int points) {
  return points.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (match) => '${match[1]}.',
  );
}
