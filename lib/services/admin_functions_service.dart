import 'package:cloud_functions/cloud_functions.dart';

class AdminFunctionsService {
  AdminFunctionsService({FirebaseFunctions? functions})
    : _functions = functions ?? FirebaseFunctions.instance;

  final FirebaseFunctions _functions;

  Future<void> approveCleanupEvent(String cleanupEventId) async {
    await _call('approveCleanupEvent', {'cleanupEventId': cleanupEventId});
  }

  Future<void> rejectCleanupEvent(String cleanupEventId, String reason) async {
    await _call('rejectCleanupEvent', {
      'cleanupEventId': cleanupEventId,
      'reason': reason,
    });
  }

  Future<void> setAdminClaim(String targetUid, bool admin) async {
    await _call('setAdminClaim', {'targetUid': targetUid, 'admin': admin});
  }

  Future<void> _call(String name, Map<String, Object?> data) async {
    try {
      final callable = _functions.httpsCallable(name);
      await callable.call<Object?>(data);
    } on FirebaseFunctionsException catch (error) {
      throw AdminFunctionsException(_messageFor(error));
    } on Object {
      throw const AdminFunctionsException(
        'İşlem tamamlanamadı. Biraz sonra tekrar dene.',
      );
    }
  }

  String _messageFor(FirebaseFunctionsException error) {
    return switch (error.code) {
      'permission-denied' => 'Bu işlem için admin yetkiniz yok.',
      'not-found' => 'İlgili kayıt bulunamadı.',
      'failed-precondition' => 'Bu işlem mevcut durumda yapılamaz.',
      'unauthenticated' => 'Bu işlem için giriş yapmalısınız.',
      'invalid-argument' => 'Gönderilen bilgiler geçersiz.',
      'internal' => 'İşlem sırasında beklenmeyen bir hata oluştu.',
      _ => error.message ?? 'İşlem tamamlanamadı.',
    };
  }
}

class AdminFunctionsException implements Exception {
  const AdminFunctionsException(this.message);

  final String message;

  @override
  String toString() => message;
}
