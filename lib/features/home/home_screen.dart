import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/mock_data.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/recycling_point_model.dart';
import '../../providers/recycling_point_provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/waste_provider.dart';
import '../../shared/widgets/puan_badge.dart';
import '../../shared/widgets/section_header.dart';
import '../tasks/widgets/task_card.dart';
import 'widgets/nearby_point_card.dart';
import 'widgets/stat_card.dart';
import 'widgets/weekly_chart.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final tasksState = ref.watch(tasksWithProgressProvider);
    final pointsState = ref.watch(activeRecyclingPointsProvider);
    final wasteLogCountState = ref.watch(userWasteLogCountProvider);

    if (currentUser.isLoading && !currentUser.hasValue) {
      return const Scaffold(
        body: SafeArea(child: Center(child: CircularProgressIndicator())),
      );
    }

    final user = currentUser.value ?? MockData.currentUser;
    final activeTasks =
        (tasksState.valueOrNull ?? MockData.tasks)
            .where((task) => !task.isCompleted)
            .toList()
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    final nearbyPoint = _nearbyPoint(pointsState.valueOrNull);
    final wasteLogCount = wasteLogCountState.valueOrNull ?? 0;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            _PointBalanceCard(totalPoints: user.totalPoints, level: user.level),
            const SizedBox(height: 14),
            _WeeklyProgressCard(weeklyPoints: user.weeklyPoints),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                final spacing = constraints.maxWidth > 520 ? 16.0 : 12.0;
                return GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  crossAxisSpacing: spacing,
                  mainAxisSpacing: spacing,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.08,
                  children: [
                    StatCard(
                      title: 'Atık Kaydı',
                      value: wasteLogCountState.isLoading
                          ? '...'
                          : '$wasteLogCount',
                      icon: Icons.delete_outline,
                      color: AppColors.primary,
                    ),
                    const StatCard(
                      title: 'Sıralamam',
                      value: '#124',
                      icon: Icons.leaderboard_outlined,
                      color: AppColors.gold,
                    ),
                    StatCard(
                      title: 'Aktif Görevler',
                      value: '${activeTasks.length}',
                      icon: Icons.task_alt_outlined,
                      color: AppColors.winterBlue,
                    ),
                    StatCard(
                      title: 'Toplam Tasarruf',
                      value: '18 kg CO₂',
                      icon: Icons.energy_savings_leaf_outlined,
                      color: AppColors.accent,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            const SectionHeader(
              title: 'En Yakın Nokta',
              subtitle: 'QR okutabileceğin aktif nokta',
            ),
            const SizedBox(height: 12),
            NearbyPointCard(point: nearbyPoint),
            const SizedBox(height: 24),
            const WeeklyChart(),
            const SizedBox(height: 24),
            SectionHeader(
              title: 'Aktif Görevler',
              trailing: TextButton(onPressed: () {}, child: const Text('Tümü')),
            ),
            const SizedBox(height: 12),
            for (final task in activeTasks.take(2)) ...[
              TaskCard(task: task),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }

  RecyclingPointModel _nearbyPoint(List<RecyclingPointModel>? points) {
    final source = points == null || points.isEmpty
        ? MockData.recyclingPoints
        : points;
    return source.firstWhere(
      (point) => point.id.contains('yakutiye'),
      orElse: () => source.first,
    );
  }
}

class _PointBalanceCard extends StatelessWidget {
  const _PointBalanceCard({required this.totalPoints, required this.level});

  final int totalPoints;
  final int level;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Dadaş Puan Bakiyesi',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textOnPrimary.withValues(alpha: 0.82),
                    ),
                  ),
                ),
                PuanBadge(
                  points: level,
                  compact: true,
                  foregroundColor: AppColors.primaryDark,
                  backgroundColor: AppColors.primaryLight,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '$totalPoints',
              style: AppTextStyles.display.copyWith(
                color: AppColors.textOnPrimary,
                fontSize: 42,
              ),
            ),
            Text(
              'Dadaş Puan 🌱',
              style: AppTextStyles.subtitle.copyWith(
                color: AppColors.textOnPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeeklyProgressCard extends StatelessWidget {
  const _WeeklyProgressCard({required this.weeklyPoints});

  final int weeklyPoints;

  @override
  Widget build(BuildContext context) {
    final progress = (weeklyPoints / 700).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Haftalık hedefe yaklaşıyorsun', style: AppTextStyles.subtitle),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: AppColors.surface,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$weeklyPoints / 700 puan tamamlandı',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}
