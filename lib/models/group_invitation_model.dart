import 'package:cloud_firestore/cloud_firestore.dart';

class GroupInvitationStatuses {
  const GroupInvitationStatuses._();

  static const pending = 'pending';
  static const accepted = 'accepted';
  static const rejected = 'rejected';
  static const cancelled = 'cancelled';

  static const values = [pending, accepted, rejected, cancelled];
}

class GroupInvitationModel {
  const GroupInvitationModel({
    required this.id,
    required this.cleanupGroupId,
    required this.cleanupEventId,
    required this.dirtyAreaId,
    required this.invitedByUserId,
    required this.invitedByUsername,
    required this.invitedUserId,
    required this.invitedUsername,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String cleanupGroupId;
  final String cleanupEventId;
  final String dirtyAreaId;
  final String invitedByUserId;
  final String invitedByUsername;
  final String invitedUserId;
  final String invitedUsername;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory GroupInvitationModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? const <String, dynamic>{};
    return GroupInvitationModel.fromMap({
      ...data,
      'id': data['id'] ?? snapshot.id,
    });
  }

  factory GroupInvitationModel.fromMap(Map<String, dynamic> map) {
    return GroupInvitationModel(
      id: map['id'] as String? ?? '',
      cleanupGroupId: map['cleanupGroupId'] as String? ?? '',
      cleanupEventId: map['cleanupEventId'] as String? ?? '',
      dirtyAreaId: map['dirtyAreaId'] as String? ?? '',
      invitedByUserId: map['invitedByUserId'] as String? ?? '',
      invitedByUsername: map['invitedByUsername'] as String? ?? '',
      invitedUserId: map['invitedUserId'] as String? ?? '',
      invitedUsername: map['invitedUsername'] as String? ?? '',
      status: map['status'] as String? ?? GroupInvitationStatuses.pending,
      createdAt: _dateTimeFromValue(map['createdAt']),
      updatedAt: _dateTimeFromValue(map['updatedAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'cleanupGroupId': cleanupGroupId,
      'cleanupEventId': cleanupEventId,
      'dirtyAreaId': dirtyAreaId,
      'invitedByUserId': invitedByUserId,
      'invitedByUsername': invitedByUsername,
      'invitedUserId': invitedUserId,
      'invitedUsername': invitedUsername,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  GroupInvitationModel copyWith({
    String? id,
    String? cleanupGroupId,
    String? cleanupEventId,
    String? dirtyAreaId,
    String? invitedByUserId,
    String? invitedByUsername,
    String? invitedUserId,
    String? invitedUsername,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GroupInvitationModel(
      id: id ?? this.id,
      cleanupGroupId: cleanupGroupId ?? this.cleanupGroupId,
      cleanupEventId: cleanupEventId ?? this.cleanupEventId,
      dirtyAreaId: dirtyAreaId ?? this.dirtyAreaId,
      invitedByUserId: invitedByUserId ?? this.invitedByUserId,
      invitedByUsername: invitedByUsername ?? this.invitedByUsername,
      invitedUserId: invitedUserId ?? this.invitedUserId,
      invitedUsername: invitedUsername ?? this.invitedUsername,
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
