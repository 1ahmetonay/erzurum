import 'package:geolocator/geolocator.dart';

class AppLocation {
  const AppLocation({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;
}

class LocationService {
  Future<bool> ensureLocationPermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocationServiceException(
        'Konum servisi kapalı. Cihaz ayarlarından konumu açıp tekrar dene.',
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw const LocationServiceException(
        'Mevcut konumu kullanmak için konum izni vermelisin.',
      );
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationServiceException(
        'Konum izni kalıcı olarak reddedildi. Uygulama ayarlarından izni açmalısın.',
      );
    }
    return true;
  }

  Future<Position?> getCurrentLocation() async {
    await ensureLocationPermission();
    try {
      return Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );
    } on LocationServiceException {
      rethrow;
    } on Object catch (error) {
      throw LocationServiceException('Konum alınamadı: $error');
    }
  }
}

class LocationServiceException implements Exception {
  const LocationServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}
