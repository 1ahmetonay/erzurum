import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/redemption_model.dart';
import '../models/redemption_result_model.dart';
import '../models/reward_model.dart';
import '../repositories/reward_repository.dart';
import 'auth_provider.dart';

final rewardRepositoryProvider = Provider<RewardRepository>((ref) {
  return RewardRepository();
});

final activeRewardsProvider = StreamProvider<List<RewardModel>>((ref) {
  return ref.watch(rewardRepositoryProvider).watchActiveRewards();
});

final userRedemptionsProvider = StreamProvider<List<RedemptionModel>>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) {
      if (user == null) return Stream.value(const []);
      return ref.watch(rewardRepositoryProvider).watchUserRedemptions(user.uid);
    },
    loading: () => const Stream.empty(),
    error: (_, _) => Stream.value(const []),
  );
});

final rewardRedemptionControllerProvider =
    AutoDisposeAsyncNotifierProvider<
      RewardRedemptionController,
      RedemptionResultModel?
    >(RewardRedemptionController.new);

class RewardRedemptionController
    extends AutoDisposeAsyncNotifier<RedemptionResultModel?> {
  @override
  Future<RedemptionResultModel?> build() async => null;

  Future<RedemptionResultModel?> redeemReward(String rewardId) async {
    state = const AsyncLoading();
    try {
      final user = ref.read(authStateProvider).valueOrNull;
      if (user == null) {
        throw const RewardRepositoryException(
          'Ödül kullanmak için giriş yapmalısın.',
        );
      }

      final result = await ref
          .read(rewardRepositoryProvider)
          .redeemReward(userId: user.uid, rewardId: rewardId);
      state = AsyncData(result);
      return result;
    } on Object catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      Error.throwWithStackTrace(error, stackTrace);
    }
  }
}
