class RedemptionStatuses {
  const RedemptionStatuses._();

  static const active = 'active';
  static const used = 'used';
  static const expired = 'expired';
  static const cancelled = 'cancelled';

  static const values = [active, used, expired, cancelled];
}

class RedemptionModel {
  const RedemptionModel({
    required this.id,
    required this.userId,
    required this.rewardId,
    required this.rewardTitle,
    required this.sponsor,
    required this.pointsSpent,
    required this.couponCode,
    required this.status,
    required this.createdAt,
    this.usedAt,
    this.expiresAt,
  });

  final String id;
  final String userId;
  final String rewardId;
  final String rewardTitle;
  final String sponsor;
  final int pointsSpent;
  final String couponCode;
  final String status;
  final DateTime createdAt;
  final DateTime? usedAt;
  final DateTime? expiresAt;

  factory RedemptionModel.fromMap(Map<String, dynamic> map) {
    return RedemptionModel(
      id: map['id'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      rewardId: map['rewardId'] as String? ?? '',
      rewardTitle: map['rewardTitle'] as String? ?? '',
      sponsor: map['sponsor'] as String? ?? '',
      pointsSpent: _intFromValue(map['pointsSpent']),
      couponCode: map['couponCode'] as String? ?? '',
      status: map['status'] as String? ?? RedemptionStatuses.active,
      createdAt: _dateTimeFromValue(map['createdAt']) ?? DateTime.now(),
      usedAt: _dateTimeFromValue(map['usedAt']),
      expiresAt: _dateTimeFromValue(map['expiresAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'rewardId': rewardId,
      'rewardTitle': rewardTitle,
      'sponsor': sponsor,
      'pointsSpent': pointsSpent,
      'couponCode': couponCode,
      'status': status,
      'createdAt': createdAt,
      'usedAt': usedAt,
      'expiresAt': expiresAt,
    };
  }

  RedemptionModel copyWith({
    String? id,
    String? userId,
    String? rewardId,
    String? rewardTitle,
    String? sponsor,
    int? pointsSpent,
    String? couponCode,
    String? status,
    DateTime? createdAt,
    DateTime? usedAt,
    DateTime? expiresAt,
  }) {
    return RedemptionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      rewardId: rewardId ?? this.rewardId,
      rewardTitle: rewardTitle ?? this.rewardTitle,
      sponsor: sponsor ?? this.sponsor,
      pointsSpent: pointsSpent ?? this.pointsSpent,
      couponCode: couponCode ?? this.couponCode,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      usedAt: usedAt ?? this.usedAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}

int _intFromValue(Object? value) {
  if (value is int) return value;
  if (value is double) return value.round();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

DateTime? _dateTimeFromValue(Object? value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
  final dynamic timestampLike = value;
  try {
    final converted = timestampLike.toDate();
    if (converted is DateTime) return converted;
  } on Object {
    return null;
  }
  return null;
}
