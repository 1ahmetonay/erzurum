import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/mock_data.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/reward_model.dart';
import '../../providers/reward_provider.dart';
import '../../providers/user_provider.dart';
import '../../shared/widgets/section_header.dart';
import 'widgets/coupon_dialog.dart';
import 'widgets/reward_card.dart';

class RewardsScreen extends ConsumerStatefulWidget {
  const RewardsScreen({super.key});

  @override
  ConsumerState<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends ConsumerState<RewardsScreen> {
  var _selectedCategory = 'all';
  String? _redeemingRewardId;

  @override
  Widget build(BuildContext context) {
    final user =
        ref.watch(currentUserProvider).valueOrNull ?? MockData.currentUser;
    final rewardsState = ref.watch(activeRewardsProvider);
    final redemptionState = ref.watch(rewardRedemptionControllerProvider);
    final rewards = _filteredRewards(
      _sortedRewards(rewardsState.valueOrNull ?? MockData.rewards),
    );

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            const SectionHeader(
              title: 'Ödüller',
              subtitle: 'Dadaş Puanlarını yerel faydaya dönüştür.',
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: AppColors.outline),
              ),
              child: Row(
                children: [
                  const Icon(Icons.eco, color: AppColors.primary, size: 38),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Bakiyen: ${user.totalPoints} Dadaş Puan 🌱',
                      style: AppTextStyles.title.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _RewardCategoryChips(
              selectedCategory: _selectedCategory,
              onSelected: (category) =>
                  setState(() => _selectedCategory = category),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.winterLight,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                'Bu hafta 3 görev tamamla, seçili ödüllerde +100 bonus puan kazan.',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (rewardsState.isLoading && !rewardsState.hasValue)
              const _LoadingState()
            else ...[
              if (rewardsState.hasError) ...[
                const _ErrorState(
                  message:
                      'Ödüller yüklenemedi. Demo ödüllerle devam edebilirsin.',
                ),
                const SizedBox(height: 12),
              ],
              if (rewards.isEmpty)
                const _EmptyState(message: 'Bu kategoride aktif ödül yok.')
              else
                for (final reward in rewards) ...[
                  RewardCard(
                    reward: reward,
                    userPoints: user.totalPoints,
                    isLoading:
                        redemptionState.isLoading &&
                        _redeemingRewardId == reward.id,
                    onUse: () => _redeemReward(reward.id),
                  ),
                  const SizedBox(height: 12),
                ],
            ],
          ],
        ),
      ),
    );
  }

  List<RewardModel> _filteredRewards(List<RewardModel> rewards) {
    if (_selectedCategory == 'all') return rewards;
    return rewards
        .where((reward) => reward.category == _selectedCategory)
        .toList();
  }

  List<RewardModel> _sortedRewards(List<RewardModel> rewards) {
    return [...rewards]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  Future<void> _redeemReward(String rewardId) async {
    setState(() => _redeemingRewardId = rewardId);
    try {
      final result = await ref
          .read(rewardRedemptionControllerProvider.notifier)
          .redeemReward(rewardId);
      if (!mounted || result == null) return;
      await CouponDialog.show(context, result);
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) {
        setState(() => _redeemingRewardId = null);
      }
    }
  }
}

class _RewardCategoryChips extends StatelessWidget {
  const _RewardCategoryChips({
    required this.selectedCategory,
    required this.onSelected,
  });

  final String selectedCategory;
  final ValueChanged<String> onSelected;

  static const _items = [
    ('Tümü', 'all'),
    ('İndirim', RewardCategories.discount),
    ('Ulaşım', RewardCategories.transport),
    ('Fiziksel', RewardCategories.physical),
    ('Bağış', RewardCategories.donation),
    ('Sertifika', RewardCategories.certificate),
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
      padding: EdgeInsets.symmetric(vertical: 32),
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
