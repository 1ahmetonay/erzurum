class LeaderboardCategories {
  const LeaderboardCategories._();

  static const individual = 'individual';
  static const neighborhood = 'neighborhood';
  static const campus = 'campus';
  static const school = 'school';
  static const districtYakutiye = 'district_yakutiye';
  static const districtPalandoken = 'district_palandoken';
  static const districtAziziye = 'district_aziziye';

  static const values = [
    individual,
    neighborhood,
    school,
    campus,
    districtYakutiye,
    districtPalandoken,
    districtAziziye,
  ];
}

class LeaderboardModel {
  const LeaderboardModel({
    required this.id,
    required this.category,
    required this.name,
    required this.weeklyPoints,
    required this.totalPoints,
    required this.rank,
    this.userId,
    this.photoUrl,
    this.memberCount,
    this.previousRank,
    this.movement,
    this.updatedAt,
  });

  final String id;
  final String category;
  final String? userId;
  final String name;
  final String? photoUrl;
  final int weeklyPoints;
  final int totalPoints;
  final int rank;
  final int? memberCount;
  final int? previousRank;
  final int? movement;
  final DateTime? updatedAt;

  int get rankDelta =>
      movement ?? (previousRank == null ? 0 : previousRank! - rank);

  factory LeaderboardModel.fromMap(Map<String, dynamic> map) {
    return LeaderboardModel(
      id: map['id'] as String? ?? '',
      category: map['category'] as String? ?? LeaderboardCategories.individual,
      userId: map['userId'] as String?,
      name: map['name'] as String? ?? map['displayName'] as String? ?? '',
      photoUrl: map['photoUrl'] as String?,
      weeklyPoints: _intFromValue(map['weeklyPoints']),
      totalPoints: _intFromValue(map['totalPoints']),
      rank: _intFromValue(map['rank']),
      memberCount: _nullableIntFromValue(map['memberCount']),
      previousRank: _nullableIntFromValue(map['previousRank']),
      movement: _nullableIntFromValue(map['movement']),
      updatedAt: _dateTimeFromValue(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'userId': userId,
      'name': name,
      'photoUrl': photoUrl,
      'weeklyPoints': weeklyPoints,
      'totalPoints': totalPoints,
      'rank': rank,
      'memberCount': memberCount,
      'previousRank': previousRank,
      'movement': movement,
      'updatedAt': updatedAt,
    };
  }

  LeaderboardModel copyWith({
    String? id,
    String? category,
    String? userId,
    String? name,
    String? photoUrl,
    int? weeklyPoints,
    int? totalPoints,
    int? rank,
    int? memberCount,
    int? previousRank,
    int? movement,
    DateTime? updatedAt,
  }) {
    return LeaderboardModel(
      id: id ?? this.id,
      category: category ?? this.category,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      weeklyPoints: weeklyPoints ?? this.weeklyPoints,
      totalPoints: totalPoints ?? this.totalPoints,
      rank: rank ?? this.rank,
      memberCount: memberCount ?? this.memberCount,
      previousRank: previousRank ?? this.previousRank,
      movement: movement ?? this.movement,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

int _intFromValue(Object? value) {
  if (value is int) return value;
  if (value is double) return value.round();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

int? _nullableIntFromValue(Object? value) {
  if (value == null) return null;
  return _intFromValue(value);
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
