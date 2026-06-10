import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/mock_data.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/reward_model.dart';
import '../../providers/reward_provider.dart';
import '../../providers/user_provider.dart';
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
  String? _selectedRewardId;

  @override
  Widget build(BuildContext context) {
    final user =
        ref.watch(currentUserProvider).valueOrNull ?? MockData.currentUser;
    final rewardsState = ref.watch(activeRewardsProvider);
    final redemptionState = ref.watch(rewardRedemptionControllerProvider);
    final allRewards = _sortedRewards(_screenRewards(rewardsState.valueOrNull));
    final rewards = _filteredRewards(allRewards);

    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          RewardBalanceCard(points: user.totalPoints),
          const SizedBox(height: 18),
          RewardCategoryChips(
            selectedCategory: _selectedCategory,
            onSelected: (category) =>
                setState(() => _selectedCategory = category),
          ),
          const SizedBox(height: 18),
          if (rewardsState.isLoading && !rewardsState.hasValue)
            const _LoadingState()
          else ...[
            if (rewards.isEmpty)
              const _EmptyState(message: 'Bu kategoride aktif ödül yok.')
            else
              RewardCardsGrid(
                rewards: rewards,
                selectedRewardId: _selectedRewardId,
                redeemingRewardId: _redeemingRewardId,
                redemptionLoading: redemptionState.isLoading,
                onSelect: _showRewardDetails,
              ),
          ],
          const SizedBox(height: 20),
          const WeeklyMissionBanner(),
        ],
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

  List<RewardModel> _screenRewards(List<RewardModel>? rewards) {
    final byId = {
      for (final reward in rewards ?? const <RewardModel>[]) reward.id: reward,
    };

    return [
      for (final designReward in _designRewards)
        (byId[designReward.id] ?? designReward).copyWith(
          title: designReward.title,
          description: designReward.description,
          requiredPoints: designReward.requiredPoints,
          category: designReward.category,
          sponsor: designReward.sponsor,
          iconEmoji: designReward.iconEmoji,
          sortOrder: designReward.sortOrder,
        ),
    ];
  }

  Future<void> _showRewardDetails(RewardModel reward) async {
    setState(() => _selectedRewardId = reward.id);

    await RewardDetailSheet.show(
      context,
      reward: reward,
      imageAsset: _imageForReward(reward),
      userPoints:
          ref.read(currentUserProvider).valueOrNull?.totalPoints ??
          MockData.currentUser.totalPoints,
      isLoading: _redeemingRewardId == reward.id,
      onUse: () => _redeemReward(reward.id),
    );
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

class RewardBalanceCard extends StatelessWidget {
  const RewardBalanceCard({required this.points, super.key});

  final int points;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.28),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            top: 4,
            bottom: 0,
            child: Icon(
              Icons.eco_outlined,
              color: AppColors.onPrimary.withValues(alpha: 0.16),
              size: 128,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Toplam Bakiyeniz',
                style: AppTextStyles.label.copyWith(
                  color: AppColors.onPrimary.withValues(alpha: 0.78),
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatPoints(points),
                    style: AppTextStyles.display.copyWith(
                      color: AppColors.onPrimary,
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Text(
                      'Dadaş Puan',
                      style: AppTextStyles.subtitle.copyWith(
                        color: AppColors.onPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryDark.withValues(alpha: 0.36),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.workspace_premium,
                      size: 17,
                      color: AppColors.onPrimary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Erzurum Elçisi',
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.onPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class RewardCategoryChips extends StatelessWidget {
  const RewardCategoryChips({
    required this.selectedCategory,
    required this.onSelected,
    super.key,
  });

  final String selectedCategory;
  final ValueChanged<String> onSelected;

  static const items = [
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
          for (final item in items) ...[
            _RewardChip(
              label: item.$1,
              selected: item.$2 == selectedCategory,
              onTap: () => onSelected(item.$2),
            ),
            const SizedBox(width: 10),
          ],
        ],
      ),
    );
  }
}

class _RewardChip extends StatelessWidget {
  const _RewardChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.outlineVariant,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.label.copyWith(
            color: selected ? AppColors.onPrimary : AppColors.textPrimary,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class RewardCardsGrid extends StatelessWidget {
  const RewardCardsGrid({
    required this.rewards,
    required this.selectedRewardId,
    required this.redeemingRewardId,
    required this.redemptionLoading,
    required this.onSelect,
    super.key,
  });

  final List<RewardModel> rewards;
  final String? selectedRewardId;
  final String? redeemingRewardId;
  final bool redemptionLoading;
  final ValueChanged<RewardModel> onSelect;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 680 ? 2 : 1;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: rewards.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: columns == 1 ? 0.96 : 0.9,
          ),
          itemBuilder: (context, index) {
            final reward = rewards[index];
            return RewardCard(
              reward: reward,
              imageAsset: _imageForReward(reward),
              isSelected: selectedRewardId == reward.id,
              isPopular: index == 0,
              isLoading: redemptionLoading && redeemingRewardId == reward.id,
              onTap: () => onSelect(reward),
            );
          },
        );
      },
    );
  }
}

class RewardDetailSheet extends StatelessWidget {
  const RewardDetailSheet({
    required this.reward,
    required this.imageAsset,
    required this.userPoints,
    required this.isLoading,
    required this.onUse,
    super.key,
  });

  final RewardModel reward;
  final String imageAsset;
  final int userPoints;
  final bool isLoading;
  final Future<void> Function() onUse;

  static Future<void> show(
    BuildContext context, {
    required RewardModel reward,
    required String imageAsset,
    required int userPoints,
    required bool isLoading,
    required Future<void> Function() onUse,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => RewardDetailSheet(
        reward: reward,
        imageAsset: imageAsset,
        userPoints: userPoints,
        isLoading: isLoading,
        onUse: onUse,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasStock = reward.stockCount == null || reward.stockCount! > 0;
    final canUse =
        reward.isActive && hasStock && userPoints >= reward.requiredPoints;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        18,
        2,
        18,
        MediaQuery.paddingOf(context).bottom + 18,
      ),
      child: ListView(
        shrinkWrap: true,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: AspectRatio(
              aspectRatio: 1.85,
              child: Image.asset(imageAsset, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            reward.title,
            style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            reward.description,
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          _DetailInfoRow(
            icon: Icons.token_outlined,
            label: 'Puan Bedeli',
            value: '${_formatPoints(reward.requiredPoints)} Dadaş Puan',
          ),
          const SizedBox(height: 10),
          _DetailInfoRow(
            icon: Icons.category_outlined,
            label: 'Kategori',
            value: _categoryLabel(reward.category),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Text(
              _detailForReward(reward),
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          if (!canUse) ...[
            const SizedBox(height: 12),
            Text(
              !hasStock
                  ? 'Bu ödülün stoğu tükendi.'
                  : 'Bu ödül için puanın yetersiz.',
              style: AppTextStyles.label.copyWith(
                color: !hasStock ? AppColors.error : AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 18),
          FilledButton(
            onPressed: canUse && !isLoading
                ? () async {
                    Navigator.of(context).pop();
                    await onUse();
                  }
                : null,
            child: isLoading
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Kullan'),
          ),
        ],
      ),
    );
  }
}

class _DetailInfoRow extends StatelessWidget {
  const _DetailInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: AppTextStyles.label.copyWith(fontWeight: FontWeight.w900),
        ),
      ],
    );
  }
}

class WeeklyMissionBanner extends StatelessWidget {
  const WeeklyMissionBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.tertiaryContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.onTertiary.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.campaign_outlined,
              color: AppColors.onTertiary,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Haftalık Görev',
                  style: AppTextStyles.title.copyWith(
                    color: AppColors.onTertiary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '3 Cam Atık getir, 200 Ek Puan kazan!',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.onTertiary.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
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

const _designRewards = <RewardModel>[
  RewardModel(
    id: 'cafe_discount_001',
    title: 'Sıfır Atık Kafe %10 İndirim',
    description: 'Merkez Şubesi’nde geçerlidir.',
    requiredPoints: 250,
    category: RewardCategories.discount,
    sponsor: 'Sıfır Atık Kafe',
    iconEmoji: '☕',
    isActive: true,
    stockCount: 50,
    sortOrder: 1,
  ),
  RewardModel(
    id: 'transport_001',
    title: 'Erzurum Kart Bakiye',
    description: '10 TL Ulaşım Bakiyesi',
    requiredPoints: 500,
    category: RewardCategories.transport,
    sponsor: 'Erzurum Kart',
    iconEmoji: '🚌',
    isActive: true,
    stockCount: 20,
    sortOrder: 2,
  ),
  RewardModel(
    id: 'tree_donation_001',
    title: 'Fidan Bağışı',
    description: 'Adınıza 1 Fidan Dikimi',
    requiredPoints: 1000,
    category: RewardCategories.donation,
    sponsor: 'AtıkAvı Erzurum',
    iconEmoji: '🌲',
    isActive: true,
    stockCount: 12,
    sortOrder: 3,
  ),
];

String _imageForReward(RewardModel reward) {
  if (reward.id.contains('transport') ||
      reward.category == RewardCategories.transport) {
    return 'assets/otobus.png';
  }
  if (reward.id.contains('tree') ||
      reward.category == RewardCategories.donation) {
    return 'assets/fidan.png';
  }
  return 'assets/cafe.png';
}

String _categoryLabel(String category) {
  return switch (category) {
    RewardCategories.discount => 'İndirim',
    RewardCategories.transport => 'Ulaşım',
    RewardCategories.physical => 'Fiziksel',
    RewardCategories.donation => 'Bağış',
    RewardCategories.certificate => 'Sertifika',
    _ => 'Ödül',
  };
}

String _detailForReward(RewardModel reward) {
  if (reward.id == 'transport_001' ||
      reward.category == RewardCategories.transport) {
    return 'Erzurum Kart bakiyene 10 TL ulaşım desteği tanımlanır.';
  }
  if (reward.id == 'tree_donation_001' ||
      reward.category == RewardCategories.donation) {
    return 'Bu ödülü kullandığında adınıza 1 fidan bağışı oluşturulur.';
  }
  return 'Bu kuponu Sıfır Atık Kafe Merkez Şubesi’nde kasada göstererek kullanabilirsin.';
}

String _formatPoints(int points) {
  return points.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (match) => '${match[1]}.',
  );
}
