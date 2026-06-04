import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/firestore_paths.dart';
import '../core/utils/redemption_resolver.dart';
import '../models/redemption_model.dart';
import '../models/redemption_result_model.dart';
import '../models/reward_model.dart';

class RewardRepository {
  RewardRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<RewardModel>> watchActiveRewards() {
    return _firestore
        .collection(FirestorePaths.rewards)
        .where('isActive', isEqualTo: true)
        .orderBy('sortOrder')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => _parseReward(doc.data()))
              .whereType<RewardModel>()
              .toList(),
        );
  }

  Stream<List<RedemptionModel>> watchUserRedemptions(String userId) {
    if (userId.trim().isEmpty) return Stream.value(const []);
    return _firestore
        .collection(FirestorePaths.redemptions)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => _parseRedemption(doc.data()))
                  .whereType<RedemptionModel>()
                  .toList()
                ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
        );
  }

  Future<RedemptionResultModel> redeemReward({
    required String userId,
    required String rewardId,
  }) async {
    if (userId.trim().isEmpty) {
      throw const RewardRepositoryException(
        'Ödül kullanmak için giriş yapmalısın.',
      );
    }
    if (rewardId.trim().isEmpty) {
      throw const RewardRepositoryException('Ödül seçilemedi.');
    }

    final userRef = _firestore.collection(FirestorePaths.users).doc(userId);
    final rewardRef = _firestore
        .collection(FirestorePaths.rewards)
        .doc(rewardId);
    final redemptionRef = _firestore
        .collection(FirestorePaths.redemptions)
        .doc();

    return _firestore.runTransaction((transaction) async {
      final userSnapshot = await transaction.get(userRef);
      if (!userSnapshot.exists) {
        throw const RewardRepositoryException('Kullanıcı bulunamadı.');
      }

      final rewardSnapshot = await transaction.get(rewardRef);
      final rewardData = rewardSnapshot.data();
      if (!rewardSnapshot.exists || rewardData == null) {
        throw const RewardRepositoryException('Ödül bulunamadı.');
      }

      final reward = RewardModel.fromMap(rewardData);
      final userData = userSnapshot.data() ?? <String, dynamic>{};
      final userPoints = _intFromValue(userData['totalPoints']);
      final disabledReason = getRedeemDisabledReason(
        userPoints: userPoints,
        requiredPoints: reward.requiredPoints,
        isActive: reward.isActive,
        stockCount: reward.stockCount,
      );
      if (disabledReason != null) {
        throw RewardRepositoryException(disabledReason);
      }

      final now = DateTime.now();
      final remainingPoints = calculateRemainingPoints(
        userPoints,
        reward.requiredPoints,
      );
      final couponCode = generateCouponCode();
      final redemption = RedemptionModel(
        id: redemptionRef.id,
        userId: userId,
        rewardId: reward.id,
        rewardTitle: reward.title,
        sponsor: reward.sponsor,
        pointsSpent: reward.requiredPoints,
        couponCode: couponCode,
        status: RedemptionStatuses.active,
        createdAt: now,
        expiresAt: now.add(const Duration(days: 30)),
      );

      transaction.set(redemptionRef, redemption.toMap());
      transaction.set(userRef, {
        'totalPoints': remainingPoints,
        'updatedAt': now,
      }, SetOptions(merge: true));

      final stockCount = reward.stockCount;
      if (stockCount != null) {
        transaction.set(rewardRef, {
          'stockCount': stockCount - 1,
          'updatedAt': now,
        }, SetOptions(merge: true));
      }

      return RedemptionResultModel(
        redemptionId: redemptionRef.id,
        rewardId: reward.id,
        rewardTitle: reward.title,
        sponsor: reward.sponsor,
        pointsSpent: reward.requiredPoints,
        couponCode: couponCode,
        remainingPoints: remainingPoints,
        message: '${reward.title} kuponun hazır.',
      );
    });
  }

  RewardModel? _parseReward(Map<String, dynamic> data) {
    try {
      return RewardModel.fromMap(data);
    } on Object {
      return null;
    }
  }

  RedemptionModel? _parseRedemption(Map<String, dynamic> data) {
    try {
      return RedemptionModel.fromMap(data);
    } on Object {
      return null;
    }
  }

  int _intFromValue(Object? value) {
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}

class RewardRepositoryException implements Exception {
  const RewardRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}
