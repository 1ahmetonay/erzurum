class WasteTypes {
  const WasteTypes._();

  static const plastic = 'plastic';
  static const glass = 'glass';
  static const paper = 'paper';
  static const battery = 'battery';
  static const oil = 'oil';
  static const electronic = 'electronic';

  static const values = [plastic, glass, paper, battery, oil, electronic];
}

class VerificationMethods {
  const VerificationMethods._();

  static const qr = 'qr';
  static const photo = 'photo';
  static const barcode = 'barcode';

  static const values = [qr, photo, barcode];
}

class WasteLogStatuses {
  const WasteLogStatuses._();

  static const approved = 'approved';
  static const pending = 'pending';
  static const rejected = 'rejected';

  static const values = [approved, pending, rejected];
}

class WasteLogModel {
  const WasteLogModel({
    required this.id,
    required this.userId,
    required this.wasteType,
    required this.verificationMethod,
    required this.latitude,
    required this.longitude,
    required this.pointsEarned,
    required this.loggedAt,
    required this.status,
    this.photoUrl,
    this.qrPointId,
    this.recyclingPointName,
  });

  final String id;
  final String userId;
  final String wasteType;
  final String verificationMethod;
  final String? photoUrl;
  final String? qrPointId;
  final String? recyclingPointName;
  final double latitude;
  final double longitude;
  final int pointsEarned;
  final DateTime loggedAt;
  final String status;

  factory WasteLogModel.fromMap(Map<String, dynamic> map) {
    return WasteLogModel(
      id: map['id'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      wasteType: map['wasteType'] as String? ?? WasteTypes.plastic,
      verificationMethod:
          map['verificationMethod'] as String? ?? VerificationMethods.photo,
      photoUrl: map['photoUrl'] as String?,
      qrPointId: map['qrPointId'] as String?,
      recyclingPointName: map['recyclingPointName'] as String?,
      latitude: _doubleFromValue(map['latitude']),
      longitude: _doubleFromValue(map['longitude']),
      pointsEarned: _intFromValue(map['pointsEarned']),
      loggedAt: _dateTimeFromValue(map['loggedAt']),
      status: map['status'] as String? ?? WasteLogStatuses.pending,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'wasteType': wasteType,
      'verificationMethod': verificationMethod,
      'photoUrl': photoUrl,
      'qrPointId': qrPointId,
      'recyclingPointName': recyclingPointName,
      'latitude': latitude,
      'longitude': longitude,
      'pointsEarned': pointsEarned,
      'loggedAt': loggedAt,
      'status': status,
    };
  }

  WasteLogModel copyWith({
    String? id,
    String? userId,
    String? wasteType,
    String? verificationMethod,
    String? photoUrl,
    String? qrPointId,
    String? recyclingPointName,
    double? latitude,
    double? longitude,
    int? pointsEarned,
    DateTime? loggedAt,
    String? status,
  }) {
    return WasteLogModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      wasteType: wasteType ?? this.wasteType,
      verificationMethod: verificationMethod ?? this.verificationMethod,
      photoUrl: photoUrl ?? this.photoUrl,
      qrPointId: qrPointId ?? this.qrPointId,
      recyclingPointName: recyclingPointName ?? this.recyclingPointName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      pointsEarned: pointsEarned ?? this.pointsEarned,
      loggedAt: loggedAt ?? this.loggedAt,
      status: status ?? this.status,
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
