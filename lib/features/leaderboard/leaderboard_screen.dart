import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/mock_data.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/leaderboard_model.dart';
import '../../providers/leaderboard_provider.dart';
import '../../providers/user_provider.dart';
import 'widgets/current_user_rank_card.dart';
import 'widgets/leaderboard_filter_chips.dart';
import 'widgets/leaderboard_list_item.dart';
import 'widgets/top_three_podium.dart';

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
    // TODO: Apply showOnLeaderboard filter in leaderboard query when privacy rules are finalized.
    final entries = _fallbackEntries(leaderboardState.valueOrNull);
    final currentUser = ref.watch(currentUserProvider).valueOrNull;
    final currentUserEntry = LeaderboardModel(
      id: currentUser?.uid ?? MockData.currentUser.uid,
      category: _selectedCategory,
      userId: currentUser?.uid ?? MockData.currentUser.uid,
      name: currentUser?.displayName.isNotEmpty == true
          ? currentUser!.displayName
          : 'Dadaş',
      photoUrl: currentUser?.photoUrl,
      weeklyPoints: currentUser?.weeklyPoints ?? 350,
      totalPoints: currentUser?.totalPoints ?? MockData.currentUser.totalPoints,
      rank: 124,
    );

    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      body: Column(
        children: [
          const SizedBox(height: 14),
          LeaderboardFilterChips(
            selectedCategory: _selectedCategory,
            onSelected: (category) {
              setState(() => _selectedCategory = category);
            },
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: [
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
                  if (entries.length < 3)
                    const _EmptyState(message: 'Bu kategoride sıralama yok.')
                  else ...[
                    TopThreePodium(entries: entries),
                    const SizedBox(height: 16),
                    for (final entry in entries.skip(3)) ...[
                      LeaderboardListItem(entry: entry),
                      const SizedBox(height: 12),
                    ],
                  ],
                ],
                const SizedBox(height: 4),
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
              child: CurrentUserRankCard(entry: currentUserEntry),
            ),
          ),
        ],
      ),
    );
  }

  List<LeaderboardModel> _fallbackEntries(List<LeaderboardModel>? entries) {
    final source = entries == null || entries.isEmpty
        ? _demoEntries(_selectedCategory)
        : entries;
    return [...source]..sort((a, b) => a.rank.compareTo(b.rank));
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 72),
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

List<LeaderboardModel> _demoEntries(String category) {
  final rows = switch (category) {
    LeaderboardCategories.neighborhood => const [
      ('Yıldızkent', 12840, 42100),
      ('Şükrüpaşa', 11320, 38900),
      ('Yenişehir', 10210, 35100),
      ('Yakutiye Merkez', 9840, 33700),
      ('Aziziye Merkez', 8620, 29600),
      ('Palandöken Merkez', 8210, 28400),
      ('Cumhuriyet', 7540, 26300),
    ],
    LeaderboardCategories.school => const [
      ('Erzurum Anadolu Lisesi', 8240, 24100),
      ('Yakutiye Ortaokulu', 7160, 21800),
      ('Palandöken İlkokulu', 6420, 19200),
      ('Aziziye Fen Lisesi', 5980, 18100),
      ('Şükrüpaşa İlkokulu', 5310, 16400),
      ('Mecidiye Ortaokulu', 4860, 15100),
      ('Atatürk Mesleki Lisesi', 4210, 13700),
    ],
    LeaderboardCategories.campus => const [
      ('Atatürk Üniversitesi', 18420, 62300),
      ('Erzurum Teknik Üniversitesi', 13950, 48700),
      ('Kazım Karabekir Kampüsü', 11280, 39400),
      ('Sağlık Bilimleri Kampüsü', 9840, 33100),
      ('Açıköğretim Topluluğu', 8620, 28700),
      ('Mühendislik Topluluğu', 7410, 24400),
      ('Güzel Sanatlar Topluluğu', 6380, 21900),
    ],
    LeaderboardCategories.districtYakutiye => const [
      ('Yakutiye Merkez', 14320, 44200),
      ('Muratpaşa', 12640, 39800),
      ('Kavak', 11450, 35400),
      ('Lalapaşa', 10220, 33100),
      ('Rabia Ana', 9430, 30200),
      ('Üniversite', 8720, 27600),
      ('Terminal', 7950, 25100),
    ],
    LeaderboardCategories.districtPalandoken => const [
      ('Yıldızkent', 13840, 42100),
      ('Yenişehir', 11960, 37600),
      ('Palandöken Merkez', 10780, 34200),
      ('Hüseyin Avni Ulaş', 9820, 31800),
      ('Adnan Menderes', 8910, 28700),
      ('Müftü Solakzade', 8340, 26400),
      ('Kayakyolu', 7680, 24100),
    ],
    LeaderboardCategories.districtAziziye => const [
      ('Ilıca', 12420, 38200),
      ('Dadaşkent', 10980, 35100),
      ('Aziziye Merkez', 9840, 32200),
      ('Saltuklu', 8920, 28400),
      ('Gezköy', 8160, 26100),
      ('Selçuklu', 7420, 23900),
      ('Aşkale Yolu', 6930, 21800),
    ],
    _ => const [
      ('Ahmet K.', 3120, 10450),
      ('Ayşe Y.', 2840, 9240),
      ('Mehmet S.', 2450, 8610),
      ('Fatma G.', 2100, 7820),
      ('Caner D.', 1980, 7410),
      ('Burak T.', 1850, 6900),
      ('Zeynep E.', 1720, 6320),
    ],
  };

  return [
    for (var index = 0; index < rows.length; index++)
      LeaderboardModel(
        id: 'demo_${category}_${index + 1}',
        category: category,
        userId: 'demo_${category}_user_${index + 1}',
        name: rows[index].$1,
        weeklyPoints: rows[index].$2,
        totalPoints: rows[index].$3,
        rank: index + 1,
      ),
  ];
}
