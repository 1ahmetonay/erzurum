import 'package:cloud_firestore/cloud_firestore.dart';

class CleanupGroupStatuses {
  const CleanupGroupStatuses._();

  static const active = 'active';
  static const full = 'full';
  static const completed = 'completed';
  static const cancelled = 'cancelled';

  static const values = [active, full, completed, cancelled];
}

class CleanupGroupModel {
  const CleanupGroupModel({
    required this.id,
    required this.cleanupEventId,
    required this.dirtyAreaId,
    required this.name,
    required this.description,
    required this.createdByUserId,
    required this.createdByUsername,
    required this.memberIds,
    required this.memberCount,
    required this.maxMembers,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String cleanupEventId;
  final String dirtyAreaId;
  final String name;
  final String description;
  final String createdByUserId;
  final String createdByUsername;
  final List<String> memberIds;
  final int memberCount;
  final int maxMembers;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory CleanupGroupModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? const <String, dynamic>{};
    return CleanupGroupModel.fromMap({
      ...data,
      'id': data['id'] ?? snapshot.id,
    });
  }

  factory CleanupGroupModel.fromMap(Map<String, dynamic> map) {
    final memberIds = List<String>.from(map['memberIds'] as List? ?? const []);
    return CleanupGroupModel(
      id: map['id'] as String? ?? '',
      cleanupEventId: map['cleanupEventId'] as String? ?? '',
      dirtyAreaId: map['dirtyAreaId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      createdByUserId: map['createdByUserId'] as String? ?? '',
      createdByUsername: map['createdByUsername'] as String? ?? '',
      memberIds: memberIds,
      memberCount: _intFromValue(map['memberCount'] ?? memberIds.length),
      maxMembers: _intFromValue(map['maxMembers']),
      status: map['status'] as String? ?? CleanupGroupStatuses.active,
      createdAt: _dateTimeFromValue(map['createdAt']),
      updatedAt: _dateTimeFromValue(map['updatedAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'cleanupEventId': cleanupEventId,
      'dirtyAreaId': dirtyAreaId,
      'name': name,
      'description': description,
      'createdByUserId': createdByUserId,
      'createdByUsername': createdByUsername,
      'memberIds': memberIds,
      'memberCount': memberCount,
      'maxMembers': maxMembers,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  CleanupGroupModel copyWith({
    String? id,
    String? cleanupEventId,
    String? dirtyAreaId,
    String? name,
    String? description,
    String? createdByUserId,
    String? createdByUsername,
    List<String>? memberIds,
    int? memberCount,
    int? maxMembers,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CleanupGroupModel(
      id: id ?? this.id,
      cleanupEventId: cleanupEventId ?? this.cleanupEventId,
      dirtyAreaId: dirtyAreaId ?? this.dirtyAreaId,
      name: name ?? this.name,
      description: description ?? this.description,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      createdByUsername: createdByUsername ?? this.createdByUsername,
      memberIds: memberIds ?? this.memberIds,
      memberCount: memberCount ?? this.memberCount,
      maxMembers: maxMembers ?? this.maxMembers,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

DateTime _dateTimeFromValue(Object? value) {
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
  final dynamic timestampLike = value;
  try {
    final converted = timestampLike?.toDate();
    if (converted is DateTime) return converted;
  } on Object {
    return DateTime.now();
  }
  return DateTime.now();
}

int _intFromValue(Object? value) {
  if (value is int) return value;
  if (value is double) return value.round();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}
