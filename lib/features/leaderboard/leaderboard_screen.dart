import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/mock_data.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/leaderboard_model.dart';
import '../../providers/leaderboard_provider.dart';
import '../../providers/user_provider.dart';
import '../../shared/widgets/section_header.dart';
import 'widgets/leaderboard_podium.dart';
import 'widgets/rank_card.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  var _selectedCategory = LeaderboardCategories.individual;

  @override
  Widget build(BuildContext context) {
    final leaderboardState = ref.watch(
      leaderboardEntriesProvider(_selectedCategory),
    );
    final entries = _fallbackEntries(leaderboardState.valueOrNull);
    final currentUser = ref.watch(currentUserProvider).valueOrNull;
    final currentUserEntry = LeaderboardModel(
      id: currentUser?.uid ?? MockData.currentUser.uid,
      category: LeaderboardCategories.individual,
      userId: currentUser?.uid ?? MockData.currentUser.uid,
      name: 'Sen',
      weeklyPoints: currentUser?.weeklyPoints ?? 350,
      totalPoints: currentUser?.totalPoints ?? MockData.currentUser.totalPoints,
      rank: 124,
    );

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                children: [
                  const SectionHeader(
                    title: 'Sıralama Tablosu',
                    subtitle: 'Haftalık geri dönüşüm liderleri',
                  ),
                  const SizedBox(height: 16),
                  _LeaderboardTabs(
                    selectedCategory: _selectedCategory,
                    onSelected: (category) {
                      setState(() => _selectedCategory = category);
                    },
                  ),
                  const SizedBox(height: 18),
                  if (leaderboardState.isLoading && !leaderboardState.hasValue)
                    const _LoadingState()
                  else ...[
                    if (leaderboardState.hasError) ...[
                      const _ErrorState(
                        message:
                            'Sıralama yüklenemedi. Demo sıralamayla devam edebilirsin.',
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (entries.isEmpty)
                      const _EmptyState(message: 'Bu kategoride sıralama yok.')
                    else ...[
                      LeaderboardPodium(entries: entries),
                      const SizedBox(height: 18),
                      for (final entry in entries) ...[
                        RankCard(
                          entry: entry,
                          isCurrentUser:
                              entry.userId == currentUser?.uid ||
                              entry.userId == MockData.currentUser.uid,
                        ),
                        const SizedBox(height: 10),
                      ],
                    ],
                  ],
                  const SizedBox(height: 8),
                  Text(
                    'Sıralama Pazartesi sıfırlanır',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: RankCard(entry: currentUserEntry, isCurrentUser: true),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<LeaderboardModel> _fallbackEntries(List<LeaderboardModel>? entries) {
    final source = entries == null || entries.isEmpty
        ? (_selectedCategory == LeaderboardCategories.individual
              ? MockData.leaderboard
              : const <LeaderboardModel>[])
        : entries;
    return [...source]..sort((a, b) => a.rank.compareTo(b.rank));
  }
}

class _LeaderboardTabs extends StatelessWidget {
  const _LeaderboardTabs({
    required this.selectedCategory,
    required this.onSelected,
  });

  final String selectedCategory;
  final ValueChanged<String> onSelected;

  static const _items = [
    ('Bireysel', LeaderboardCategories.individual),
    ('Mahalle', LeaderboardCategories.neighborhood),
    ('Kampüs', LeaderboardCategories.campus),
    ('Okul', LeaderboardCategories.school),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final item in _items) ...[
            ChoiceChip(
              selected: item.$2 == selectedCategory,
              label: Text(item.$1),
              onSelected: (_) => onSelected(item.$2),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 48),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.winterLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.winterIce),
      ),
      child: Text(
        message,
        style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(message, style: AppTextStyles.body),
    );
  }
}
