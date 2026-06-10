import 'package:cloud_firestore/cloud_firestore.dart';

import 'waste_log_model.dart';

class DirtyAreaWasteTypes {
  const DirtyAreaWasteTypes._();

  static const plastic = WasteTypes.plastic;
  static const glass = WasteTypes.glass;
  static const paper = WasteTypes.paper;
  static const metal = 'metal';
  static const organic = 'organic';
  static const mixed = 'mixed';

  static const values = [plastic, glass, paper, metal, organic, mixed];
}

class DirtyAreaStatuses {
  const DirtyAreaStatuses._();

  static const reported = 'reported';
  static const planned = 'planned';
  static const inProgress = 'inProgress';
  static const cleaned = 'cleaned';
  static const rejected = 'rejected';

  static const values = [reported, planned, inProgress, cleaned, rejected];
}

class PhotoAnalysisStatuses {
  const PhotoAnalysisStatuses._();

  static const notStarted = 'notStarted';
  static const pending = 'pending';
  static const approved = 'approved';
  static const rejected = 'rejected';
  static const needsReview = 'needsReview';
  static const failed = 'failed';

  static const values = [
    notStarted,
    pending,
    approved,
    rejected,
    needsReview,
    failed,
  ];
}

class DirtyAreaModel {
  const DirtyAreaModel({
    required this.id,
    required this.title,
    required this.description,
    required this.reportedByUserId,
    required this.reportedByUsername,
    required this.latitude,
    required this.longitude,
    required this.addressText,
    required this.wasteTypes,
    required this.severityLevel,
    required this.status,
    required this.participantCount,
    required this.createdAt,
    required this.updatedAt,
    this.photoUrl,
    this.photoAnalysisStatus = PhotoAnalysisStatuses.notStarted,
    this.aiCleanlinessScore,
    this.aiWasteMatchScore,
    this.aiDetectedWasteTypes = const [],
    this.aiAnalysisSummary,
    this.aiAnalysisProvider,
    this.aiAnalyzedAt,
  });

  final String id;
  final String title;
  final String description;
  final String reportedByUserId;
  final String reportedByUsername;
  final double latitude;
  final double longitude;
  final String addressText;
  final String? photoUrl;
  final String photoAnalysisStatus;
  final int? aiCleanlinessScore;
  final int? aiWasteMatchScore;
  final List<String> aiDetectedWasteTypes;
  final String? aiAnalysisSummary;
  final String? aiAnalysisProvider;
  final DateTime? aiAnalyzedAt;
  final List<String> wasteTypes;
  final int severityLevel;
  final String status;
  final int participantCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory DirtyAreaModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? const <String, dynamic>{};
    return DirtyAreaModel.fromMap({...data, 'id': data['id'] ?? snapshot.id});
  }

  factory DirtyAreaModel.fromMap(Map<String, dynamic> map) {
    return DirtyAreaModel(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      reportedByUserId: map['reportedByUserId'] as String? ?? '',
      reportedByUsername: map['reportedByUsername'] as String? ?? '',
      latitude: _doubleFromValue(map['latitude']),
      longitude: _doubleFromValue(map['longitude']),
      addressText: map['addressText'] as String? ?? '',
      photoUrl: map['photoUrl'] as String?,
      photoAnalysisStatus:
          map['photoAnalysisStatus'] as String? ??
          PhotoAnalysisStatuses.notStarted,
      aiCleanlinessScore: _nullableIntFromValue(map['aiCleanlinessScore']),
      aiWasteMatchScore: _nullableIntFromValue(map['aiWasteMatchScore']),
      aiDetectedWasteTypes: List<String>.from(
        map['aiDetectedWasteTypes'] as List? ?? const [],
      ),
      aiAnalysisSummary: map['aiAnalysisSummary'] as String?,
      aiAnalysisProvider: map['aiAnalysisProvider'] as String?,
      aiAnalyzedAt: _nullableDateTimeFromValue(map['aiAnalyzedAt']),
      wasteTypes: List<String>.from(map['wasteTypes'] as List? ?? const []),
      severityLevel: _intFromValue(map['severityLevel']).clamp(1, 5).toInt(),
      status: map['status'] as String? ?? DirtyAreaStatuses.reported,
      participantCount: _intFromValue(map['participantCount']),
      createdAt: _dateTimeFromValue(map['createdAt']),
      updatedAt: _dateTimeFromValue(map['updatedAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'reportedByUserId': reportedByUserId,
      'reportedByUsername': reportedByUsername,
      'latitude': latitude,
      'longitude': longitude,
      'addressText': addressText,
      'photoUrl': photoUrl,
      'photoAnalysisStatus': photoAnalysisStatus,
      'aiCleanlinessScore': aiCleanlinessScore,
      'aiWasteMatchScore': aiWasteMatchScore,
      'aiDetectedWasteTypes': aiDetectedWasteTypes,
      'aiAnalysisSummary': aiAnalysisSummary,
      'aiAnalysisProvider': aiAnalysisProvider,
      'aiAnalyzedAt': aiAnalyzedAt,
      'wasteTypes': wasteTypes,
      'severityLevel': severityLevel,
      'status': status,
      'participantCount': participantCount,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  DirtyAreaModel copyWith({
    String? id,
    String? title,
    String? description,
    String? reportedByUserId,
    String? reportedByUsername,
    double? latitude,
    double? longitude,
    String? addressText,
    String? photoUrl,
    String? photoAnalysisStatus,
    int? aiCleanlinessScore,
    int? aiWasteMatchScore,
    List<String>? aiDetectedWasteTypes,
    String? aiAnalysisSummary,
    String? aiAnalysisProvider,
    DateTime? aiAnalyzedAt,
    List<String>? wasteTypes,
    int? severityLevel,
    String? status,
    int? participantCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DirtyAreaModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      reportedByUserId: reportedByUserId ?? this.reportedByUserId,
      reportedByUsername: reportedByUsername ?? this.reportedByUsername,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      addressText: addressText ?? this.addressText,
      photoUrl: photoUrl ?? this.photoUrl,
      photoAnalysisStatus: photoAnalysisStatus ?? this.photoAnalysisStatus,
      aiCleanlinessScore: aiCleanlinessScore ?? this.aiCleanlinessScore,
      aiWasteMatchScore: aiWasteMatchScore ?? this.aiWasteMatchScore,
      aiDetectedWasteTypes: aiDetectedWasteTypes ?? this.aiDetectedWasteTypes,
      aiAnalysisSummary: aiAnalysisSummary ?? this.aiAnalysisSummary,
      aiAnalysisProvider: aiAnalysisProvider ?? this.aiAnalysisProvider,
      aiAnalyzedAt: aiAnalyzedAt ?? this.aiAnalyzedAt,
      wasteTypes: wasteTypes ?? this.wasteTypes,
      severityLevel: severityLevel ?? this.severityLevel,
      status: status ?? this.status,
      participantCount: participantCount ?? this.participantCount,
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

double _doubleFromValue(Object? value) {
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
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

DateTime? _nullableDateTimeFromValue(Object? value) {
  if (value == null) return null;
  return _dateTimeFromValue(value);
}
