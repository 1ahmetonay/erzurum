import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/location_service.dart';

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

final currentLocationControllerProvider =
    StateNotifierProvider<CurrentLocationController, AsyncValue<AppLocation?>>((
      ref,
    ) {
      return CurrentLocationController(ref.watch(locationServiceProvider));
    });

class CurrentLocationController
    extends StateNotifier<AsyncValue<AppLocation?>> {
  CurrentLocationController(this._service) : super(const AsyncData(null));

  final LocationService _service;

  Future<AppLocation?> load() async {
    state = const AsyncLoading();
    try {
      final position = await _service.getCurrentLocation();
      final location = position == null
          ? null
          : AppLocation(
              latitude: position.latitude,
              longitude: position.longitude,
            );
      state = AsyncData(location);
      return location;
    } on Object catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}
