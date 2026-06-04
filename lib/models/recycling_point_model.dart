import 'waste_log_model.dart';

class RecyclingPointTypes {
  const RecyclingPointTypes._();

  static const plastic = WasteTypes.plastic;
  static const glass = WasteTypes.glass;
  static const paper = WasteTypes.paper;
  static const battery = WasteTypes.battery;
  static const oil = WasteTypes.oil;
  static const electronic = WasteTypes.electronic;
  static const cafe = 'cafe';

  static const values = [plastic, glass, paper, battery, oil, electronic, cafe];
}

class RecyclingPointModel {
  const RecyclingPointModel({
    required this.id,
    required this.name,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.qrCode,
    required this.isActive,
    required this.isBroken,
    this.imageUrl,
    this.workingHours,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String type;
  final double latitude;
  final double longitude;
  final String address;
  final String qrCode;
  final bool isActive;
  final bool isBroken;
  final String? imageUrl;
  final Map<String, dynamic>? workingHours;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory RecyclingPointModel.fromMap(Map<String, dynamic> map) {
    return RecyclingPointModel(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      type: map['type'] as String? ?? RecyclingPointTypes.plastic,
      latitude: _doubleFromValue(map['latitude']),
      longitude: _doubleFromValue(map['longitude']),
      address: map['address'] as String? ?? '',
      qrCode: map['qrCode'] as String? ?? '',
      isActive: map['isActive'] as bool? ?? true,
      isBroken: map['isBroken'] as bool? ?? false,
      imageUrl: map['imageUrl'] as String?,
      workingHours: _mapFromValue(map['workingHours']),
      createdAt: _dateTimeFromValue(map['createdAt']),
      updatedAt: _dateTimeFromValue(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'qrCode': qrCode,
      'isActive': isActive,
      'isBroken': isBroken,
      'imageUrl': imageUrl,
      'workingHours': workingHours,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  RecyclingPointModel copyWith({
    String? id,
    String? name,
    String? type,
    double? latitude,
    double? longitude,
    String? address,
    String? qrCode,
    bool? isActive,
    bool? isBroken,
    String? imageUrl,
    Map<String, dynamic>? workingHours,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RecyclingPointModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      qrCode: qrCode ?? this.qrCode,
      isActive: isActive ?? this.isActive,
      isBroken: isBroken ?? this.isBroken,
      imageUrl: imageUrl ?? this.imageUrl,
      workingHours: workingHours ?? this.workingHours,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

double _doubleFromValue(Object? value) {
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}

Map<String, dynamic>? _mapFromValue(Object? value) {
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
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
