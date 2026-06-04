class UserTaskProgressModel {
  const UserTaskProgressModel({
    required this.id,
    required this.userId,
    required this.taskId,
    required this.currentCount,
    required this.requiredCount,
    required this.isCompleted,
    this.completedAt,
    this.claimedAt,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String userId;
  final String taskId;
  final int currentCount;
  final int requiredCount;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime? claimedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory UserTaskProgressModel.fromMap(Map<String, dynamic> map) {
    return UserTaskProgressModel(
      id: map['id'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      taskId: map['taskId'] as String? ?? '',
      currentCount: _intFromValue(map['currentCount']),
      requiredCount: _intFromValue(map['requiredCount']),
      isCompleted: map['isCompleted'] as bool? ?? false,
      completedAt: _dateTimeFromValue(map['completedAt']),
      claimedAt: _dateTimeFromValue(map['claimedAt']),
      createdAt: _dateTimeFromValue(map['createdAt']),
      updatedAt: _dateTimeFromValue(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'taskId': taskId,
      'currentCount': currentCount,
      'requiredCount': requiredCount,
      'isCompleted': isCompleted,
      'completedAt': completedAt,
      'claimedAt': claimedAt,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  UserTaskProgressModel copyWith({
    String? id,
    String? userId,
    String? taskId,
    int? currentCount,
    int? requiredCount,
    bool? isCompleted,
    DateTime? completedAt,
    DateTime? claimedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserTaskProgressModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      taskId: taskId ?? this.taskId,
      currentCount: currentCount ?? this.currentCount,
      requiredCount: requiredCount ?? this.requiredCount,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      claimedAt: claimedAt ?? this.claimedAt,
      createdAt: createdAt ?? this.createdAt,
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
