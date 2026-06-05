import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';
import '../models/user_preferences_model.dart';

class UserRepository {
  UserRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> get _feedback =>
      _firestore.collection('feedback');

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

  Future<void> updateDisplayName({
    required String uid,
    required String displayName,
    String? email,
    String? photoUrl,
  }) {
    final data = <String, dynamic>{
      'uid': uid,
      'displayName': displayName.trim(),
      'updatedAt': DateTime.now(),
    };
    if (email != null) data['email'] = email;
    if (photoUrl != null) data['photoUrl'] = photoUrl;

    return _users.doc(uid).set(data, SetOptions(merge: true));
  }

  Future<void> updateUserPreferences({
    required String uid,
    required UserPreferencesModel preferences,
  }) {
    return _users.doc(uid).set({
      'preferences': preferences.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> sendFeedback({
    required String uid,
    required String email,
    required String message,
  }) {
    return _feedback.add({
      'uid': uid,
      'email': email,
      'message': message.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> softDeleteAccount(String uid) {
    return _users.doc(uid).set({
      'isDeleted': true,
      'deletedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
