import 'package:uuid/uuid.dart';

bool canRedeemReward({
  required int userPoints,
  required int requiredPoints,
  required bool isActive,
  int? stockCount,
}) {
  return getRedeemDisabledReason(
        userPoints: userPoints,
        requiredPoints: requiredPoints,
        isActive: isActive,
        stockCount: stockCount,
      ) ==
      null;
}

String? getRedeemDisabledReason({
  required int userPoints,
  required int requiredPoints,
  required bool isActive,
  int? stockCount,
}) {
  if (!isActive) return 'Bu ödül şu anda aktif değil.';
  if (stockCount != null && stockCount <= 0) return 'Bu ödülün stoğu kalmadı.';
  if (userPoints < requiredPoints) {
    return 'Bu ödül için yeterli Dadaş Puanın yok.';
  }
  return null;
}

int calculateRemainingPoints(int userPoints, int requiredPoints) {
  return userPoints - requiredPoints;
}

String generateCouponCode({String prefix = 'ATIKAVI'}) {
  final raw = const Uuid().v4().replaceAll('-', '').toUpperCase();
  return '$prefix-${raw.substring(0, 6)}';
}
