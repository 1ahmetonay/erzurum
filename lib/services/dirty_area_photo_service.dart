import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class DirtyAreaPhotoService {
  DirtyAreaPhotoService({FirebaseStorage? storage})
    : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  Future<String> uploadDirtyAreaPhoto({
    required String userId,
    required XFile photo,
  }) async {
    if (userId.trim().isEmpty) {
      throw const DirtyAreaPhotoException(
        'Fotoğraf için kullanıcı bilgisi eksik.',
      );
    }

    try {
      final bytes = await photo.readAsBytes();
      if (bytes.length > 5 * 1024 * 1024) {
        throw const DirtyAreaPhotoException(
          'Fotoğraf boyutu en fazla 5 MB olabilir.',
        );
      }
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final storageRef = _storage.ref(
        'dirty_area_photos/$userId/$timestamp.jpg',
      );
      await storageRef.putData(
        bytes,
        SettableMetadata(contentType: photo.mimeType ?? 'image/jpeg'),
      );
      return storageRef.getDownloadURL();
    } on DirtyAreaPhotoException {
      rethrow;
    } on Object catch (error) {
      throw DirtyAreaPhotoException('Fotoğraf yüklenemedi: $error');
    }
  }
}

class DirtyAreaPhotoException implements Exception {
  const DirtyAreaPhotoException(this.message);

  final String message;

  @override
  String toString() => message;
}
