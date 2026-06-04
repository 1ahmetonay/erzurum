import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';

class UserRepository {
  UserRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  Future<void> createUserIfNotExists(User firebaseUser) async {
    final docRef = _users.doc(firebaseUser.uid);
    final snapshot = await docRef.get();
    final now = DateTime.now();

    if (snapshot.exists) {
      await docRef.update({
        'displayName': firebaseUser.displayName ?? '',
        'email': firebaseUser.email ?? '',
        'photoUrl': firebaseUser.photoURL,
        'updatedAt': now,
      });
      return;
    }

    final user = UserModel(
      uid: firebaseUser.uid,
      displayName: firebaseUser.displayName ?? 'AtıkAvı Kullanıcısı',
      email: firebaseUser.email ?? '',
      photoUrl: firebaseUser.photoURL,
      totalPoints: 0,
      weeklyPoints: 0,
      neighborhood: 'Belirtilmedi',
      schoolOrCampus: null,
      badges: const [],
      level: 1,
      createdAt: now,
      updatedAt: now,
    );

    await docRef.set(user.toMap());
  }

  Stream<UserModel?> watchUser(String uid) {
    return _users.doc(uid).snapshots().map((snapshot) {
      final data = snapshot.data();
      if (!snapshot.exists || data == null) return null;
      return UserModel.fromMap(data);
    });
  }

  Future<UserModel?> getUser(String uid) async {
    final snapshot = await _users.doc(uid).get();
    final data = snapshot.data();
    if (!snapshot.exists || data == null) return null;
    return UserModel.fromMap(data);
  }

  Future<void> updateUser(UserModel user) {
    return _users
        .doc(user.uid)
        .set(
          user.copyWith(updatedAt: DateTime.now()).toMap(),
          SetOptions(merge: true),
        );
  }
}
