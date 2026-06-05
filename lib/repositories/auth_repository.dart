import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository {
  AuthRepository({FirebaseAuth? firebaseAuth, GoogleSignIn? googleSignIn})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
      _googleSignIn = googleSignIn ?? GoogleSignIn();

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  Stream<User?> authStateChanges() => _firebaseAuth.authStateChanges();

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (error) {
      throw AuthRepositoryException(_firebaseAuthMessage(error));
    } on Object {
      throw const AuthRepositoryException(
        'Bir hata oluştu. Lütfen tekrar deneyin.',
      );
    }
  }

  Future<UserCredential> registerWithEmail({
    required String displayName,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await credential.user?.updateDisplayName(displayName.trim());
      await credential.user?.reload();
      return credential;
    } on FirebaseAuthException catch (error) {
      throw AuthRepositoryException(_firebaseAuthMessage(error));
    } on Object {
      throw const AuthRepositoryException(
        'Bir hata oluştu. Lütfen tekrar deneyin.',
      );
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        final googleProvider = GoogleAuthProvider();
        return await _firebaseAuth.signInWithPopup(googleProvider);
      }

      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return _firebaseAuth.signInWithCredential(credential);
    } on FirebaseAuthException catch (error) {
      if (_isCancelledAuthError(error.code)) return null;
      throw AuthRepositoryException(_firebaseAuthMessage(error));
    } on Object catch (error) {
      throw AuthRepositoryException(
        'Google ile giriş sırasında bir sorun oluştu: $error',
      );
    }
  }

  Future<void> updateDisplayName(String displayName) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return;
      await user.updateDisplayName(displayName.trim());
      await user.reload();
    } on FirebaseAuthException catch (error) {
      throw AuthRepositoryException(_firebaseAuthMessage(error));
    } on Object {
      throw const AuthRepositoryException(
        'Profil güncellenirken bir hata oluştu. Lütfen tekrar deneyin.',
      );
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (error) {
      throw AuthRepositoryException(_firebaseAuthMessage(error));
    } on Object {
      throw const AuthRepositoryException(
        'Bir hata oluştu. Lütfen tekrar deneyin.',
      );
    }
  }

  Future<void> signOut() async {
    try {
      if (!kIsWeb) {
        await _googleSignIn.signOut();
      }
      await _firebaseAuth.signOut();
    } on FirebaseAuthException catch (error) {
      throw AuthRepositoryException(_firebaseAuthMessage(error));
    } on Object catch (error) {
      throw AuthRepositoryException(
        'Çıkış yapılırken bir sorun oluştu: $error',
      );
    }
  }

  bool _isCancelledAuthError(String code) {
    return code == 'popup-closed-by-user' ||
        code == 'cancelled-popup-request' ||
        code == 'web-context-cancelled';
  }

  String _firebaseAuthMessage(FirebaseAuthException error) {
    return switch (error.code) {
      'account-exists-with-different-credential' =>
        'Bu e-posta adresi farklı bir giriş yöntemiyle kayıtlı.',
      'email-already-in-use' => 'Bu e-posta zaten kullanılıyor.',
      'invalid-credential' ||
      'invalid-email' ||
      'user-not-found' ||
      'wrong-password' => 'E-posta veya şifre hatalı.',
      'network-request-failed' =>
        'Ağ bağlantısı kurulamadı. Lütfen bağlantını kontrol et.',
      'popup-blocked' =>
        'Tarayıcı giriş penceresini engelledi. Açılır pencereye izin ver.',
      'weak-password' => 'Şifre en az 6 karakter olmalı.',
      'unauthorized-domain' =>
        'Bu alan adı Firebase Google girişi için yetkilendirilmemiş.',
      _ => 'Bir hata oluştu. Lütfen tekrar deneyin.',
    };
  }
}

class AuthRepositoryException implements Exception {
  const AuthRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}
