class TaskTypes {
  const TaskTypes._();

  static const daily = 'daily';
  static const weekly = 'weekly';
  static const social = 'social';
  static const education = 'education';
  static const winter = 'winter';

  static const values = [daily, weekly, social, education, winter];
}

class TaskActions {
  const TaskActions._();

  static const scanPlastic = 'scan_plastic';
  static const scanPaper = 'scan_paper';
  static const scanBattery = 'scan_battery';
  static const scanAny = 'scan_any';
  static const scanGlass = 'scan_glass';
  static const inviteFriend = 'invite_friend';
  static const solveQuiz = 'solve_quiz';
  static const visitPoint = 'visit_point';
  static const reportNearbyPoint = 'report_nearby_point';
  static const winterCupLid = 'winter_cup_lid';
  static const winterGroupTask = 'winter_group_task';
}

class TaskModel {
  const TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.pointReward,
    required this.isWinterOnly,
    required this.iconEmoji,
    this.requiredAction,
    this.requiredCount,
    this.currentCount = 0,
    this.isCompleted = false,
    this.isActive = true,
    this.sortOrder = 0,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String title;
  final String description;
  final String type;
  final int pointReward;
  final String? requiredAction;
  final int? requiredCount;
  final bool isWinterOnly;
  final String iconEmoji;
  final int currentCount;
  final bool isCompleted;
  final bool isActive;
  final int sortOrder;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      type: map['type'] as String? ?? TaskTypes.daily,
      pointReward: _intFromValue(map['pointReward']),
      requiredAction: map['requiredAction'] as String?,
      requiredCount: _nullableIntFromValue(map['requiredCount']),
      isWinterOnly: map['isWinterOnly'] as bool? ?? false,
      iconEmoji: map['iconEmoji'] as String? ?? '♻️',
      currentCount: map['currentCount'] as int? ?? 0,
      isCompleted: map['isCompleted'] as bool? ?? false,
      isActive: map['isActive'] as bool? ?? true,
      sortOrder: _intFromValue(map['sortOrder']),
      createdAt: _dateTimeFromValue(map['createdAt']),
      updatedAt: _dateTimeFromValue(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'pointReward': pointReward,
      'requiredAction': requiredAction,
      'requiredCount': requiredCount,
      'isWinterOnly': isWinterOnly,
      'iconEmoji': iconEmoji,
      'currentCount': currentCount,
      'isCompleted': isCompleted,
      'isActive': isActive,
      'sortOrder': sortOrder,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    String? type,
    int? pointReward,
    String? requiredAction,
    int? requiredCount,
    bool? isWinterOnly,
    String? iconEmoji,
    int? currentCount,
    bool? isCompleted,
    bool? isActive,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      pointReward: pointReward ?? this.pointReward,
      requiredAction: requiredAction ?? this.requiredAction,
      requiredCount: requiredCount ?? this.requiredCount,
      isWinterOnly: isWinterOnly ?? this.isWinterOnly,
      iconEmoji: iconEmoji ?? this.iconEmoji,
      currentCount: currentCount ?? this.currentCount,
      isCompleted: isCompleted ?? this.isCompleted,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
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
