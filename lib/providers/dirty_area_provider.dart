import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/dirty_area_model.dart';
import '../repositories/dirty_area_repository.dart';
import '../services/dirty_area_photo_service.dart';
import '../services/photo_analysis_service.dart';
import 'auth_provider.dart';

final dirtyAreaRepositoryProvider = Provider<DirtyAreaRepository>((ref) {
  return DirtyAreaRepository();
});

final dirtyAreaPhotoServiceProvider = Provider<DirtyAreaPhotoService>((ref) {
  return DirtyAreaPhotoService();
});

final photoAnalysisServiceProvider = Provider<PhotoAnalysisService>((ref) {
  return PhotoAnalysisService();
});

final dirtyAreasProvider = StreamProvider<List<DirtyAreaModel>>((ref) {
  return ref.watch(dirtyAreaRepositoryProvider).watchDirtyAreas();
});

final activeDirtyAreasProvider = StreamProvider<List<DirtyAreaModel>>((ref) {
  return ref
      .watch(dirtyAreaRepositoryProvider)
      .watchDirtyAreasByStatus(DirtyAreaStatuses.reported);
});

final userDirtyAreasProvider = StreamProvider<List<DirtyAreaModel>>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) {
      if (user == null) return Stream.value(const []);
      return ref
          .watch(dirtyAreaRepositoryProvider)
          .watchUserDirtyAreas(user.uid);
    },
    loading: () => const Stream.empty(),
    error: (_, _) => Stream.value(const []),
  );
});

final dirtyAreaDetailProvider = StreamProvider.family<DirtyAreaModel?, String>((
  ref,
  dirtyAreaId,
) {
  return ref.watch(dirtyAreaRepositoryProvider).watchDirtyArea(dirtyAreaId);
});
