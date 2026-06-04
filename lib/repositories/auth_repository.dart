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
      'network-request-failed' =>
        'Ağ bağlantısı kurulamadı. Lütfen bağlantını kontrol et.',
      'popup-blocked' =>
        'Tarayıcı giriş penceresini engelledi. Açılır pencereye izin ver.',
      'unauthorized-domain' =>
        'Bu alan adı Firebase Google girişi için yetkilendirilmemiş.',
      _ => error.message ?? 'Firebase kimlik doğrulama hatası oluştu.',
    };
  }
}

class AuthRepositoryException implements Exception {
  const AuthRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}
