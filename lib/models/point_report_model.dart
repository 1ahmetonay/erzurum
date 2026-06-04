class PointReportTypes {
  const PointReportTypes._();

  static const broken = 'broken';
  static const full = 'full';
  static const missing = 'missing';
  static const wrongLocation = 'wrong_location';
  static const other = 'other';

  static const values = [broken, full, missing, wrongLocation, other];
}

class PointReportStatuses {
  const PointReportStatuses._();

  static const pending = 'pending';
  static const reviewed = 'reviewed';
  static const resolved = 'resolved';
  static const rejected = 'rejected';

  static const values = [pending, reviewed, resolved, rejected];
}

class PointReportModel {
  const PointReportModel({
    required this.id,
    required this.userId,
    required this.pointId,
    required this.pointName,
    required this.reportType,
    required this.status,
    required this.createdAt,
    this.description,
    this.resolvedAt,
    this.adminNote,
  });

  final String id;
  final String userId;
  final String pointId;
  final String pointName;
  final String reportType;
  final String? description;
  final String status;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final String? adminNote;

  factory PointReportModel.fromMap(Map<String, dynamic> map) {
    return PointReportModel(
      id: map['id'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      pointId: map['pointId'] as String? ?? '',
      pointName: map['pointName'] as String? ?? '',
      reportType: map['reportType'] as String? ?? PointReportTypes.other,
      description: map['description'] as String?,
      status: map['status'] as String? ?? PointReportStatuses.pending,
      createdAt: _dateTimeFromValue(map['createdAt']) ?? DateTime(1970),
      resolvedAt: _dateTimeFromValue(map['resolvedAt']),
      adminNote: map['adminNote'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'pointId': pointId,
      'pointName': pointName,
      'reportType': reportType,
      'description': description,
      'status': status,
      'createdAt': createdAt,
      'resolvedAt': resolvedAt,
      'adminNote': adminNote,
    };
  }

  PointReportModel copyWith({
    String? id,
    String? userId,
    String? pointId,
    String? pointName,
    String? reportType,
    String? description,
    String? status,
    DateTime? createdAt,
    DateTime? resolvedAt,
    String? adminNote,
  }) {
    return PointReportModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      pointId: pointId ?? this.pointId,
      pointName: pointName ?? this.pointName,
      reportType: reportType ?? this.reportType,
      description: description ?? this.description,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      adminNote: adminNote ?? this.adminNote,
    );
  }
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
