import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/leaderboard_model.dart';
import 'leaderboard_avatar.dart';

class TopThreePodium extends StatelessWidget {
  const TopThreePodium({required this.entries, super.key});

  final List<LeaderboardModel> entries;

  @override
  Widget build(BuildContext context) {
    final top = entries.take(3).toList();
    if (top.length < 3) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 370;
        final sideAvatar = compact ? 58.0 : 70.0;
        final centerAvatar = compact ? 88.0 : 110.0;

        return SizedBox(
          height: compact ? 324 : 352,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: _SidePodiumUser(
                  entry: top[1],
                  avatarSize: sideAvatar,
                  podiumHeight: compact ? 70 : 92,
                  rankColor: AppColors.silver,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: _LeaderPodiumUser(
                  entry: top[0],
                  avatarSize: centerAvatar,
                  podiumHeight: compact ? 92 : 126,
                  compact: compact,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SidePodiumUser(
                  entry: top[2],
                  avatarSize: sideAvatar,
                  podiumHeight: compact ? 62 : 80,
                  rankColor: AppColors.bronze,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LeaderPodiumUser extends StatelessWidget {
  const _LeaderPodiumUser({
    required this.entry,
    required this.avatarSize,
    required this.podiumHeight,
    required this.compact,
  });

  final LeaderboardModel entry;
  final double avatarSize;
  final double podiumHeight;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Icon(
          Icons.workspace_premium,
          color: AppColors.gold,
          size: compact ? 32 : 40,
        ),
        LeaderboardAvatar(
          name: entry.name,
          photoUrl: entry.photoUrl,
          size: avatarSize,
          borderColor: AppColors.outlineVariant,
          backgroundColor: AppColors.primaryFixed,
        ),
        Transform.translate(
          offset: const Offset(0, -14),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 14 : 18,
              vertical: compact ? 6 : 8,
            ),
            decoration: BoxDecoration(
              color: AppColors.gold,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'LİDER',
              style: AppTextStyles.label.copyWith(
                color: AppColors.onPrimary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        Text(
          entry.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: AppTextStyles.title.copyWith(
            fontSize: compact ? 22 : 26,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: compact ? 2 : 4),
        Text(
          '${_formatPoints(entry.weeklyPoints)} P',
          style: AppTextStyles.points.copyWith(fontSize: compact ? 19 : 22),
        ),
        SizedBox(height: compact ? 8 : 12),
        _PodiumBlock(
          height: podiumHeight,
          color: AppColors.primary,
          icon: Icons.star_border,
          iconColor: AppColors.onPrimary,
        ),
      ],
    );
  }
}

class _SidePodiumUser extends StatelessWidget {
  const _SidePodiumUser({
    required this.entry,
    required this.avatarSize,
    required this.podiumHeight,
    required this.rankColor,
  });

  final LeaderboardModel entry;
  final double avatarSize;
  final double podiumHeight;
  final Color rankColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            LeaderboardAvatar(
              name: entry.name,
              photoUrl: entry.photoUrl,
              size: avatarSize,
              borderColor: AppColors.outlineVariant,
              backgroundColor: AppColors.primaryFixedDim,
            ),
            Positioned(
              bottom: -8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: rankColor,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '#${entry.rank}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.onPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          entry.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: AppTextStyles.subtitle.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 4),
        Text(
          '${_formatPoints(entry.weeklyPoints)} P',
          style: AppTextStyles.label.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 12),
        _PodiumBlock(
          height: podiumHeight,
          color: AppColors.surfaceContainerHigh,
          icon: entry.rank == 2 ? Icons.workspace_premium : Icons.military_tech,
          iconColor: rankColor,
        ),
      ],
    );
  }
}

class _PodiumBlock extends StatelessWidget {
  const _PodiumBlock({
    required this.height,
    required this.color,
    required this.icon,
    required this.iconColor,
  });

  final double height;
  final Color color;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.16),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(icon, color: iconColor, size: 54),
    );
  }
}

String _formatPoints(int points) {
  return points.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (match) => '${match[1]}.',
  );
}
