import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/mock_data.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/recycling_point_model.dart';
import '../../models/task_model.dart';
import '../../providers/recycling_point_provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/waste_provider.dart';
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
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 120),
          children: [
            _PointBalanceCard(totalPoints: user.totalPoints, level: user.level),
            const SizedBox(height: 22),
            _WeeklyProgressCard(weeklyPoints: user.weeklyPoints),
            const SizedBox(height: 26),
            _HomeStatsGrid(
              wasteLogCount: wasteLogCount,
              wasteLogCountLoading: wasteLogCountState.isLoading,
              activeTaskCount: activeTasks.length,
            ),
            const SizedBox(height: 28),
            NearbyPointCard(
              point: nearbyPoint,
              onTap: () => context.go('/map'),
            ),
            const SizedBox(height: 26),
            const WeeklyChart(),
            const SizedBox(height: 28),
            _HomeSectionTitle(
              title: 'Aktif Görevler',
              actionLabel: 'Tümünü Gör',
              onAction: () => context.go('/tasks'),
            ),
            const SizedBox(height: 12),
            for (final task in activeTasks.take(2)) ...[
              _ActiveTaskPreview(
                task: task,
                onTap: () =>
                    context.go('/tasks?taskId=${Uri.encodeComponent(task.id)}'),
              ),
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
      (point) =>
          point.id.contains('yakutiye') || point.name.contains('Yakutiye'),
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
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryContainer, AppColors.primary],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'DADAŞ PUAN BAKİYESİ',
            textAlign: TextAlign.center,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textOnPrimary.withValues(alpha: 0.72),
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatPoints(totalPoints),
                  style: AppTextStyles.display.copyWith(
                    color: AppColors.onPrimaryContainer,
                    fontSize: 56,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    'PTS',
                    style: AppTextStyles.title.copyWith(
                      color: AppColors.onPrimaryContainer,
                      fontSize: 23,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Expanded(
                child: _PointChip(title: 'Erzurum Geneli', value: '#42'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PointChip(
                  title: 'Sıralama:',
                  value: level >= 7 ? 'Usta Dönüştürücü' : 'Dadaş Avcı',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatPoints(int value) {
    final text = value.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < text.length; i++) {
      final remaining = text.length - i;
      buffer.write(text[i]);
      if (remaining > 1 && remaining % 3 == 1) buffer.write('.');
    }
    return buffer.toString();
  }
}

class _PointChip extends StatelessWidget {
  const _PointChip({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 46),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryDark.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textOnPrimary.withValues(alpha: 0.75),
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textOnPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyProgressCard extends StatelessWidget {
  const _WeeklyProgressCard({required this.weeklyPoints});

  static const _weeklyGoal = 500;

  final int weeklyPoints;

  @override
  Widget build(BuildContext context) {
    final progress = (weeklyPoints / _weeklyGoal).clamp(0.0, 1.0);
    final percent = (progress * 100).round();
    final remaining = (_weeklyGoal - weeklyPoints).clamp(0, _weeklyGoal);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: BoxDecoration(
        color: AppColors.cardBg.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Haftalık Hedef: $_weeklyGoal Puan',
                  style: AppTextStyles.subtitle.copyWith(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                '%$percent Tamamlandı',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: AppColors.surfaceContainerLowest,
              color: AppColors.primaryFixed,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            remaining == 0
                ? 'Haftalık hedefini tamamladın.'
                : 'Haftalık hedefine ulaşmak için sadece $remaining puan kaldı!',
            style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}

class _HomeStatsGrid extends StatelessWidget {
  const _HomeStatsGrid({
    required this.wasteLogCount,
    required this.wasteLogCountLoading,
    required this.activeTaskCount,
  });

  final int wasteLogCount;
  final bool wasteLogCountLoading;
  final int activeTaskCount;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
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
              title: 'Dönüştürülen Atık',
              value: wasteLogCountLoading
                  ? '...'
                  : '${(wasteLogCount * 2.5).toStringAsFixed(1)} kg',
              icon: Icons.eco_outlined,
              color: AppColors.primary,
            ),
            const StatCard(
              title: 'Sıralamam',
              value: '128',
              icon: Icons.bar_chart_outlined,
              color: AppColors.primary,
            ),
            StatCard(
              title: 'Aktif Görevler',
              value: '$activeTaskCount Adet',
              icon: Icons.task_alt_outlined,
              color: AppColors.primary,
            ),
            const StatCard(
              title: 'Toplam Tasarruf',
              value: '₺240',
              icon: Icons.savings_outlined,
              color: AppColors.primary,
            ),
          ],
        );
      },
    );
  }
}

class _HomeSectionTitle extends StatelessWidget {
  const _HomeSectionTitle({
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.title.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        TextButton(
          onPressed: onAction,
          child: Text(
            actionLabel,
            style: AppTextStyles.label.copyWith(color: AppColors.primary),
          ),
        ),
      ],
    );
  }
}

class _ActiveTaskPreview extends StatelessWidget {
  const _ActiveTaskPreview({required this.task, required this.onTap});

  final TaskModel task;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceLow.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.58),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: const BoxDecoration(
                color: AppColors.secondaryContainer,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  task.iconEmoji,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.subtitle.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _taskPreviewDescription(task),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.outlineVariant),
          ],
        ),
      ),
    );
  }
}

String _taskPreviewDescription(TaskModel task) {
  final requiredCount = task.requiredCount ?? 1;
  return '$requiredCount ${_taskUnit(task.title)} / +${task.pointReward} Puan';
}

String _taskUnit(String title) {
  final lower = title.toLowerCase();
  if (lower.contains('kağıt') || lower.contains('kagit')) return 'kg Kağıt';
  if (lower.contains('cam')) return 'Cam Şişe';
  if (lower.contains('pil')) return 'Pil';
  if (lower.contains('plastik')) return 'Plastik Şişe';
  return 'Adet';
}
