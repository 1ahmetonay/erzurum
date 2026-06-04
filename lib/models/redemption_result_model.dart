class RedemptionResultModel {
  const RedemptionResultModel({
    required this.redemptionId,
    required this.rewardId,
    required this.rewardTitle,
    required this.sponsor,
    required this.pointsSpent,
    required this.couponCode,
    required this.remainingPoints,
    required this.message,
  });

  final String redemptionId;
  final String rewardId;
  final String rewardTitle;
  final String sponsor;
  final int pointsSpent;
  final String couponCode;
  final int remainingPoints;
  final String message;
}
