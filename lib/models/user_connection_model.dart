import 'package:cloud_firestore/cloud_firestore.dart';

class UserConnectionStatuses {
  const UserConnectionStatuses._();

  static const pending = 'pending';
  static const accepted = 'accepted';
  static const rejected = 'rejected';
  static const blocked = 'blocked';

  static const values = [pending, accepted, rejected, blocked];
}

class UserConnectionModel {
  const UserConnectionModel({
    required this.id,
    required this.requesterUserId,
    required this.requesterUsername,
    required this.receiverUserId,
    required this.receiverUsername,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String requesterUserId;
  final String requesterUsername;
  final String receiverUserId;
  final String receiverUsername;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory UserConnectionModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? const <String, dynamic>{};
    return UserConnectionModel.fromMap({
      ...data,
      'id': data['id'] ?? snapshot.id,
    });
  }

  factory UserConnectionModel.fromMap(Map<String, dynamic> map) {
    return UserConnectionModel(
      id: map['id'] as String? ?? '',
      requesterUserId: map['requesterUserId'] as String? ?? '',
      requesterUsername: map['requesterUsername'] as String? ?? '',
      receiverUserId: map['receiverUserId'] as String? ?? '',
      receiverUsername: map['receiverUsername'] as String? ?? '',
      status: map['status'] as String? ?? UserConnectionStatuses.pending,
      createdAt: _dateTimeFromValue(map['createdAt']),
      updatedAt: _dateTimeFromValue(map['updatedAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'requesterUserId': requesterUserId,
      'requesterUsername': requesterUsername,
      'receiverUserId': receiverUserId,
      'receiverUsername': receiverUsername,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  UserConnectionModel copyWith({
    String? id,
    String? requesterUserId,
    String? requesterUsername,
    String? receiverUserId,
    String? receiverUsername,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserConnectionModel(
      id: id ?? this.id,
      requesterUserId: requesterUserId ?? this.requesterUserId,
      requesterUsername: requesterUsername ?? this.requesterUsername,
      receiverUserId: receiverUserId ?? this.receiverUserId,
      receiverUsername: receiverUsername ?? this.receiverUsername,
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
