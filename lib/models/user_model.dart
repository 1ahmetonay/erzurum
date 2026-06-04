class UserModel {
  const UserModel({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.totalPoints,
    required this.weeklyPoints,
    required this.neighborhood,
    required this.badges,
    required this.level,
    required this.createdAt,
    required this.updatedAt,
    this.photoUrl,
    this.schoolOrCampus,
  });

  final String uid;
  final String displayName;
  final String email;
  final String? photoUrl;
  final int totalPoints;
  final int weeklyPoints;
  final String neighborhood;
  final String? schoolOrCampus;
  final List<String> badges;
  final int level;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String? ?? '',
      displayName: map['displayName'] as String? ?? '',
      email: map['email'] as String? ?? '',
      photoUrl: map['photoUrl'] as String?,
      totalPoints: map['totalPoints'] as int? ?? 0,
      weeklyPoints: map['weeklyPoints'] as int? ?? 0,
      neighborhood: map['neighborhood'] as String? ?? '',
      schoolOrCampus: map['schoolOrCampus'] as String?,
      badges: List<String>.from(map['badges'] as List? ?? const []),
      level: map['level'] as int? ?? 1,
      createdAt: _dateTimeFromValue(map['createdAt']),
      updatedAt: _dateTimeFromValue(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'photoUrl': photoUrl,
      'totalPoints': totalPoints,
      'weeklyPoints': weeklyPoints,
      'neighborhood': neighborhood,
      'schoolOrCampus': schoolOrCampus,
      'badges': badges,
      'level': level,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  UserModel copyWith({
    String? uid,
    String? displayName,
    String? email,
    String? photoUrl,
    int? totalPoints,
    int? weeklyPoints,
    String? neighborhood,
    String? schoolOrCampus,
    List<String>? badges,
    int? level,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      totalPoints: totalPoints ?? this.totalPoints,
      weeklyPoints: weeklyPoints ?? this.weeklyPoints,
      neighborhood: neighborhood ?? this.neighborhood,
      schoolOrCampus: schoolOrCampus ?? this.schoolOrCampus,
      badges: badges ?? this.badges,
      level: level ?? this.level,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

DateTime _dateTimeFromValue(Object? value) {
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
  if (value == null) return DateTime.now();
  final dynamic timestampLike = value;
  try {
    final converted = timestampLike?.toDate();
    if (converted is DateTime) return converted;
  } on Object {
    return DateTime.now();
  }
  return DateTime.now();
}
