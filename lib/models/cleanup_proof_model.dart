import 'package:cloud_firestore/cloud_firestore.dart';

class CleanupProofModel {
  const CleanupProofModel({
    required this.id,
    required this.cleanupEventId,
    required this.dirtyAreaId,
    required this.uploadedByUserId,
    required this.uploadedByUsername,
    required this.photoUrl,
    required this.createdAt,
    this.note,
    this.status = CleanupProofStatuses.pending,
    this.reviewedByUserId,
    this.reviewedAt,
    this.rejectionReason,
  });

  final String id;
  final String cleanupEventId;
  final String dirtyAreaId;
  final String uploadedByUserId;
  final String uploadedByUsername;
  final String photoUrl;
  final String? note;
  final DateTime createdAt;
  final String status;
  final String? reviewedByUserId;
  final DateTime? reviewedAt;
  final String? rejectionReason;

  factory CleanupProofModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? const <String, dynamic>{};
    return CleanupProofModel.fromMap({
      ...data,
      'id': data['id'] ?? snapshot.id,
    });
  }

  factory CleanupProofModel.fromMap(Map<String, dynamic> map) {
    return CleanupProofModel(
      id: map['id'] as String? ?? '',
      cleanupEventId: map['cleanupEventId'] as String? ?? '',
      dirtyAreaId: map['dirtyAreaId'] as String? ?? '',
      uploadedByUserId: map['uploadedByUserId'] as String? ?? '',
      uploadedByUsername: map['uploadedByUsername'] as String? ?? '',
      photoUrl: map['photoUrl'] as String? ?? '',
      note: map['note'] as String?,
      createdAt: _dateTimeFromValue(map['createdAt']),
      status: map['status'] as String? ?? CleanupProofStatuses.pending,
      reviewedByUserId: map['reviewedByUserId'] as String?,
      reviewedAt: _nullableDateTimeFromValue(map['reviewedAt']),
      rejectionReason: map['rejectionReason'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'cleanupEventId': cleanupEventId,
      'dirtyAreaId': dirtyAreaId,
      'uploadedByUserId': uploadedByUserId,
      'uploadedByUsername': uploadedByUsername,
      'photoUrl': photoUrl,
      'note': note,
      'createdAt': createdAt,
      'status': status,
      'reviewedByUserId': reviewedByUserId,
      'reviewedAt': reviewedAt,
      'rejectionReason': rejectionReason,
    };
  }

  CleanupProofModel copyWith({
    String? id,
    String? cleanupEventId,
    String? dirtyAreaId,
    String? uploadedByUserId,
    String? uploadedByUsername,
    String? photoUrl,
    String? note,
    DateTime? createdAt,
    String? status,
    String? reviewedByUserId,
    DateTime? reviewedAt,
    String? rejectionReason,
  }) {
    return CleanupProofModel(
      id: id ?? this.id,
      cleanupEventId: cleanupEventId ?? this.cleanupEventId,
      dirtyAreaId: dirtyAreaId ?? this.dirtyAreaId,
      uploadedByUserId: uploadedByUserId ?? this.uploadedByUserId,
      uploadedByUsername: uploadedByUsername ?? this.uploadedByUsername,
      photoUrl: photoUrl ?? this.photoUrl,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      reviewedByUserId: reviewedByUserId ?? this.reviewedByUserId,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }
}

class CleanupProofStatuses {
  const CleanupProofStatuses._();

  static const pending = 'pending';
  static const approved = 'approved';
  static const rejected = 'rejected';

  static const values = [pending, approved, rejected];
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
