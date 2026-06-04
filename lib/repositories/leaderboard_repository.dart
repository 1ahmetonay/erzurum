import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/firestore_paths.dart';
import '../models/leaderboard_model.dart';

class LeaderboardRepository {
  LeaderboardRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<LeaderboardModel>> watchLeaderboardEntries(String category) {
    return _firestore
        .collection(FirestorePaths.leaderboardEntries(category))
        .orderBy('rank')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => _parseEntry(doc.data()))
              .whereType<LeaderboardModel>()
              .toList(),
        );
  }

  LeaderboardModel? _parseEntry(Map<String, dynamic> data) {
    try {
      return LeaderboardModel.fromMap(data);
    } on Object {
      return null;
    }
  }
}
