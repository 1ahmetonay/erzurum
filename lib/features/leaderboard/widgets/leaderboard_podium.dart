import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/leaderboard_model.dart';

class LeaderboardPodium extends StatelessWidget {
  const LeaderboardPodium({required this.entries, super.key});

  final List<LeaderboardModel> entries;

  @override
  Widget build(BuildContext context) {
    final top = entries.take(3).toList();
    if (top.length < 3) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: _PodiumItem(entry: top[1], height: 96)),
          const SizedBox(width: 10),
          Expanded(
            child: _PodiumItem(entry: top[0], height: 126, winner: true),
          ),
          const SizedBox(width: 10),
          Expanded(child: _PodiumItem(entry: top[2], height: 82)),
        ],
      ),
    );
  }
}

class _PodiumItem extends StatelessWidget {
  const _PodiumItem({
    required this.entry,
    required this.height,
    this.winner = false,
  });

  final LeaderboardModel entry;
  final double height;
  final bool winner;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: winner ? 30 : 24,
          backgroundColor: _rankColor(entry.rank),
          child: Text(
            entry.name.characters.first,
            style: AppTextStyles.title.copyWith(fontSize: winner ? 22 : 18),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          entry.name,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.label,
        ),
        const SizedBox(height: 8),
        Container(
          height: height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _rankColor(entry.rank).withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text('#${entry.rank}', style: AppTextStyles.title),
        ),
      ],
    );
  }

  Color _rankColor(int rank) {
    return switch (rank) {
      1 => AppColors.gold,
      2 => AppColors.silver,
      _ => AppColors.bronze,
    };
  }
}
