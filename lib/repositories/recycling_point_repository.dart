import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/firestore_paths.dart';
import '../models/recycling_point_model.dart';

class RecyclingPointRepository {
  RecyclingPointRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<RecyclingPointModel>> watchActiveRecyclingPoints() {
    return _firestore
        .collection(FirestorePaths.recyclingPoints)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => _parsePoint(doc.data()))
              .whereType<RecyclingPointModel>()
              .toList(),
        );
  }

  RecyclingPointModel? _parsePoint(Map<String, dynamic> data) {
    try {
      return RecyclingPointModel.fromMap(data);
    } on Object {
      return null;
    }
  }
}
