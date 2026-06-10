class PhotoAnalysisResultModel {
  const PhotoAnalysisResultModel({
    required this.status,
    this.cleanlinessScore,
    this.wasteMatchScore,
    this.detectedWasteTypes = const [],
    this.summary,
    this.provider,
    this.analyzedAt,
  });

  final String status;
  final int? cleanlinessScore;
  final int? wasteMatchScore;
  final List<String> detectedWasteTypes;
  final String? summary;
  final String? provider;
  final DateTime? analyzedAt;

  factory PhotoAnalysisResultModel.fromMap(Map<String, dynamic> map) {
    return PhotoAnalysisResultModel(
      status: map['status'] as String? ?? 'notStarted',
      cleanlinessScore: _intFromValue(map['cleanlinessScore']),
      wasteMatchScore: _intFromValue(map['wasteMatchScore']),
      detectedWasteTypes: List<String>.from(
        map['detectedWasteTypes'] as List? ?? const [],
      ),
      summary: map['summary'] as String?,
      provider: map['provider'] as String?,
      analyzedAt: _dateTimeFromValue(map['analyzedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'status': status,
      'cleanlinessScore': cleanlinessScore,
      'wasteMatchScore': wasteMatchScore,
      'detectedWasteTypes': detectedWasteTypes,
      'summary': summary,
      'provider': provider,
      'analyzedAt': analyzedAt,
    };
  }

  PhotoAnalysisResultModel copyWith({
    String? status,
    int? cleanlinessScore,
    int? wasteMatchScore,
    List<String>? detectedWasteTypes,
    String? summary,
    String? provider,
    DateTime? analyzedAt,
  }) {
    return PhotoAnalysisResultModel(
      status: status ?? this.status,
      cleanlinessScore: cleanlinessScore ?? this.cleanlinessScore,
      wasteMatchScore: wasteMatchScore ?? this.wasteMatchScore,
      detectedWasteTypes: detectedWasteTypes ?? this.detectedWasteTypes,
      summary: summary ?? this.summary,
      provider: provider ?? this.provider,
      analyzedAt: analyzedAt ?? this.analyzedAt,
    );
  }
}

int? _intFromValue(Object? value) {
  if (value is int) return value;
  if (value is double) return value.round();
  if (value is String) return int.tryParse(value);
  return null;
}

DateTime? _dateTimeFromValue(Object? value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  final dynamic timestampLike = value;
  try {
    final converted = timestampLike.toDate();
    return converted is DateTime ? converted : null;
  } on Object {
    return null;
  }
}
