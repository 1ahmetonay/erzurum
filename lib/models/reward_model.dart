class RewardCategories {
  const RewardCategories._();

  static const discount = 'discount';
  static const transport = 'transport';
  static const physical = 'physical';
  static const donation = 'donation';
  static const certificate = 'certificate';

  static const values = [discount, transport, physical, donation, certificate];
}

class RewardModel {
  const RewardModel({
    required this.id,
    required this.title,
    required this.description,
    required this.requiredPoints,
    required this.category,
    required this.sponsor,
    required this.iconEmoji,
    required this.isActive,
    this.stockCount,
    this.sortOrder = 0,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String title;
  final String description;
  final int requiredPoints;
  final String category;
  final String sponsor;
  final String iconEmoji;
  final bool isActive;
  final int? stockCount;
  final int sortOrder;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory RewardModel.fromMap(Map<String, dynamic> map) {
    return RewardModel(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      requiredPoints: _intFromValue(map['requiredPoints']),
      category: map['category'] as String? ?? RewardCategories.discount,
      sponsor: map['sponsor'] as String? ?? '',
      iconEmoji: map['iconEmoji'] as String? ?? '🎁',
      isActive: map['isActive'] as bool? ?? true,
      stockCount: _nullableIntFromValue(map['stockCount']),
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
      'requiredPoints': requiredPoints,
      'category': category,
      'sponsor': sponsor,
      'iconEmoji': iconEmoji,
      'isActive': isActive,
      'stockCount': stockCount,
      'sortOrder': sortOrder,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  RewardModel copyWith({
    String? id,
    String? title,
    String? description,
    int? requiredPoints,
    String? category,
    String? sponsor,
    String? iconEmoji,
    bool? isActive,
    int? stockCount,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RewardModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      requiredPoints: requiredPoints ?? this.requiredPoints,
      category: category ?? this.category,
      sponsor: sponsor ?? this.sponsor,
      iconEmoji: iconEmoji ?? this.iconEmoji,
      isActive: isActive ?? this.isActive,
      stockCount: stockCount ?? this.stockCount,
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
