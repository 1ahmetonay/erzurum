import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/firestore_paths.dart';
import '../models/user_connection_model.dart';
import '../models/user_model.dart';

class UserConnectionRepository {
  UserConnectionRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<List<UserModel>> searchUsers(
    String query, {
    String? excludeUid,
  }) async {
    final normalized = query.trim().toLowerCase();
    if (normalized.length < 2) return const [];

    final snapshot = await _firestore
        .collection(FirestorePaths.users)
        .limit(50)
        .get();

    return snapshot.docs
        .map((doc) => UserModel.fromMap(doc.data()))
        .where(
          (user) =>
              user.uid != excludeUid &&
              (user.displayName.toLowerCase().contains(normalized) ||
                  user.email.toLowerCase().contains(normalized)),
        )
        .toList();
  }

  Future<void> sendConnectionRequest({
    required String requesterUserId,
    required String requesterUsername,
    required String receiverUserId,
    required String receiverUsername,
  }) async {
    if (requesterUserId.trim().isEmpty || receiverUserId.trim().isEmpty) {
      throw const UserConnectionRepositoryException('Kullanıcı bilgisi eksik.');
    }
    if (requesterUserId == receiverUserId) {
      throw const UserConnectionRepositoryException(
        'Kendine arkadaşlık isteği gönderemezsin.',
      );
    }

    final now = DateTime.now();
    final connectionRef = _firestore
        .collection(FirestorePaths.userConnections)
        .doc(_connectionId(requesterUserId, receiverUserId));

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(connectionRef);
      if (snapshot.exists) {
        final existing = UserConnectionModel.fromFirestore(snapshot);
        if (existing.status == UserConnectionStatuses.pending ||
            existing.status == UserConnectionStatuses.accepted) {
          throw const UserConnectionRepositoryException(
            'Bu kullanıcıyla zaten bağlantı isteğin var.',
          );
        }
      }

      transaction.set(
        connectionRef,
        UserConnectionModel(
          id: connectionRef.id,
          requesterUserId: requesterUserId,
          requesterUsername: requesterUsername,
          receiverUserId: receiverUserId,
          receiverUsername: receiverUsername,
          status: UserConnectionStatuses.pending,
          createdAt: now,
          updatedAt: now,
        ).toFirestore(),
      );
    });
  }

  Stream<List<UserConnectionModel>> watchIncomingRequests(String userId) {
    if (userId.trim().isEmpty) return Stream.value(const []);
    return _firestore
        .collection(FirestorePaths.userConnections)
        .where('receiverUserId', isEqualTo: userId)
        .where('status', isEqualTo: UserConnectionStatuses.pending)
        .snapshots()
        .map(_parseConnections);
  }

  Stream<List<UserConnectionModel>> watchOutgoingRequests(String userId) {
    if (userId.trim().isEmpty) return Stream.value(const []);
    return _firestore
        .collection(FirestorePaths.userConnections)
        .where('requesterUserId', isEqualTo: userId)
        .where('status', isEqualTo: UserConnectionStatuses.pending)
        .snapshots()
        .map(_parseConnections);
  }

  Stream<List<UserConnectionModel>> watchAcceptedConnections(String userId) {
    if (userId.trim().isEmpty) return Stream.value(const []);
    return _firestore
        .collection(FirestorePaths.userConnections)
        .where('status', isEqualTo: UserConnectionStatuses.accepted)
        .snapshots()
        .map(
          (snapshot) => _parseConnections(snapshot)
              .where(
                (connection) =>
                    connection.requesterUserId == userId ||
                    connection.receiverUserId == userId,
              )
              .toList(),
        );
  }

  Future<void> updateRequestStatus({
    required String connectionId,
    required String userId,
    required String status,
  }) async {
    if (![
      UserConnectionStatuses.accepted,
      UserConnectionStatuses.rejected,
      UserConnectionStatuses.blocked,
    ].contains(status)) {
      throw const UserConnectionRepositoryException('Geçersiz durum.');
    }
    final ref = _firestore
        .collection(FirestorePaths.userConnections)
        .doc(connectionId);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(ref);
      if (!snapshot.exists) {
        throw const UserConnectionRepositoryException('İstek bulunamadı.');
      }
      final connection = UserConnectionModel.fromFirestore(snapshot);
      if (connection.receiverUserId != userId &&
          connection.requesterUserId != userId) {
        throw const UserConnectionRepositoryException(
          'Bu işlem için yetkin yok.',
        );
      }
      if (status != UserConnectionStatuses.blocked &&
          connection.receiverUserId != userId) {
        throw const UserConnectionRepositoryException(
          'Bu isteği yalnızca alıcı yanıtlayabilir.',
        );
      }
      transaction.update(ref, {'status': status, 'updatedAt': DateTime.now()});
    });
  }

  List<UserConnectionModel> _parseConnections(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    return snapshot.docs.map(UserConnectionModel.fromFirestore).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  String _connectionId(String a, String b) {
    final ids = [a, b]..sort();
    return '${ids.first}_${ids.last}';
  }
}

class UserConnectionRepositoryException implements Exception {
  const UserConnectionRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}
