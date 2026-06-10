import 'package:cloud_firestore/cloud_firestore.dart';

class CleanupEventStatuses {
  const CleanupEventStatuses._();

  static const planned = 'planned';
  static const inProgress = 'inProgress';
  static const pendingApproval = 'pendingApproval';
  static const completed = 'completed';
  static const cancelled = 'cancelled';

  static const values = [
    planned,
    inProgress,
    pendingApproval,
    completed,
    cancelled,
  ];
}

class CleanupApprovalStatuses {
  const CleanupApprovalStatuses._();

  static const none = 'none';
  static const pending = 'pending';
  static const approved = 'approved';
  static const rejected = 'rejected';

  static const values = [none, pending, approved, rejected];
}

class CleanupEventModel {
  const CleanupEventModel({
    required this.id,
    required this.dirtyAreaId,
    required this.title,
    required this.description,
    required this.createdByUserId,
    required this.createdByUsername,
    required this.meetingPointText,
    required this.scheduledAt,
    required this.status,
    required this.maxParticipants,
    required this.participantCount,
    required this.participantIds,
    required this.createdAt,
    required this.updatedAt,
    this.completionPhotoUrl,
    this.completedAt,
    this.completedByUserId,
    this.pointsAwarded = false,
    this.pointsPerParticipant = 50,
    this.approvalStatus = CleanupApprovalStatuses.none,
    this.approvedByUserId,
    this.approvedAt,
    this.rejectedByUserId,
    this.rejectedAt,
    this.rejectionReason,
  });

  final String id;
  final String dirtyAreaId;
  final String title;
  final String description;
  final String createdByUserId;
  final String createdByUsername;
  final String meetingPointText;
  final DateTime scheduledAt;
  final String status;
  final int maxParticipants;
  final int participantCount;
  final List<String> participantIds;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? completionPhotoUrl;
  final DateTime? completedAt;
  final String? completedByUserId;
  final bool pointsAwarded;
  final int pointsPerParticipant;
  final String approvalStatus;
  final String? approvedByUserId;
  final DateTime? approvedAt;
  final String? rejectedByUserId;
  final DateTime? rejectedAt;
  final String? rejectionReason;

  factory CleanupEventModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? const <String, dynamic>{};
    return CleanupEventModel.fromMap({
      ...data,
      'id': data['id'] ?? snapshot.id,
    });
  }

  factory CleanupEventModel.fromMap(Map<String, dynamic> map) {
    final participantIds = List<String>.from(
      map['participantIds'] as List? ?? const [],
    );
    return CleanupEventModel(
      id: map['id'] as String? ?? '',
      dirtyAreaId: map['dirtyAreaId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      createdByUserId: map['createdByUserId'] as String? ?? '',
      createdByUsername: map['createdByUsername'] as String? ?? '',
      meetingPointText: map['meetingPointText'] as String? ?? '',
      scheduledAt: _dateTimeFromValue(map['scheduledAt']),
      status: map['status'] as String? ?? CleanupEventStatuses.planned,
      maxParticipants: _intFromValue(map['maxParticipants']),
      participantCount: _intFromValue(
        map['participantCount'] ?? participantIds.length,
      ),
      participantIds: participantIds,
      createdAt: _dateTimeFromValue(map['createdAt']),
      updatedAt: _dateTimeFromValue(map['updatedAt']),
      completionPhotoUrl: map['completionPhotoUrl'] as String?,
      completedAt: _nullableDateTimeFromValue(map['completedAt']),
      completedByUserId: map['completedByUserId'] as String?,
      pointsAwarded: map['pointsAwarded'] as bool? ?? false,
      pointsPerParticipant: _intFromValue(map['pointsPerParticipant'] ?? 50),
      approvalStatus:
          map['approvalStatus'] as String? ?? CleanupApprovalStatuses.none,
      approvedByUserId: map['approvedByUserId'] as String?,
      approvedAt: _nullableDateTimeFromValue(map['approvedAt']),
      rejectedByUserId: map['rejectedByUserId'] as String?,
      rejectedAt: _nullableDateTimeFromValue(map['rejectedAt']),
      rejectionReason: map['rejectionReason'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'dirtyAreaId': dirtyAreaId,
      'title': title,
      'description': description,
      'createdByUserId': createdByUserId,
      'createdByUsername': createdByUsername,
      'meetingPointText': meetingPointText,
      'scheduledAt': scheduledAt,
      'status': status,
      'maxParticipants': maxParticipants,
      'participantCount': participantCount,
      'participantIds': participantIds,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'completionPhotoUrl': completionPhotoUrl,
      'completedAt': completedAt,
      'completedByUserId': completedByUserId,
      'pointsAwarded': pointsAwarded,
      'pointsPerParticipant': pointsPerParticipant,
      'approvalStatus': approvalStatus,
      'approvedByUserId': approvedByUserId,
      'approvedAt': approvedAt,
      'rejectedByUserId': rejectedByUserId,
      'rejectedAt': rejectedAt,
      'rejectionReason': rejectionReason,
    };
  }

  CleanupEventModel copyWith({
    String? id,
    String? dirtyAreaId,
    String? title,
    String? description,
    String? createdByUserId,
    String? createdByUsername,
    String? meetingPointText,
    DateTime? scheduledAt,
    String? status,
    int? maxParticipants,
    int? participantCount,
    List<String>? participantIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? completionPhotoUrl,
    DateTime? completedAt,
    String? completedByUserId,
    bool? pointsAwarded,
    int? pointsPerParticipant,
    String? approvalStatus,
    String? approvedByUserId,
    DateTime? approvedAt,
    String? rejectedByUserId,
    DateTime? rejectedAt,
    String? rejectionReason,
  }) {
    return CleanupEventModel(
      id: id ?? this.id,
      dirtyAreaId: dirtyAreaId ?? this.dirtyAreaId,
      title: title ?? this.title,
      description: description ?? this.description,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      createdByUsername: createdByUsername ?? this.createdByUsername,
      meetingPointText: meetingPointText ?? this.meetingPointText,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      status: status ?? this.status,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      participantCount: participantCount ?? this.participantCount,
      participantIds: participantIds ?? this.participantIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completionPhotoUrl: completionPhotoUrl ?? this.completionPhotoUrl,
      completedAt: completedAt ?? this.completedAt,
      completedByUserId: completedByUserId ?? this.completedByUserId,
      pointsAwarded: pointsAwarded ?? this.pointsAwarded,
      pointsPerParticipant: pointsPerParticipant ?? this.pointsPerParticipant,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      approvedByUserId: approvedByUserId ?? this.approvedByUserId,
      approvedAt: approvedAt ?? this.approvedAt,
      rejectedByUserId: rejectedByUserId ?? this.rejectedByUserId,
      rejectedAt: rejectedAt ?? this.rejectedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }
}

DateTime? _nullableDateTimeFromValue(Object? value) {
  if (value == null) return null;
  return _dateTimeFromValue(value);
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
