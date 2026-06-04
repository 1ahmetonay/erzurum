import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../models/scan_result_model.dart';
import '../models/waste_log_model.dart';
import '../repositories/waste_repository.dart';
import 'auth_provider.dart';

final wasteRepositoryProvider = Provider<WasteRepository>((ref) {
  return WasteRepository();
});

final userWasteLogsProvider = StreamProvider<List<WasteLogModel>>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) {
      if (user == null) return Stream.value(const []);
      return ref.watch(wasteRepositoryProvider).watchUserWasteLogs(user.uid);
    },
    loading: () => const Stream.empty(),
    error: (_, _) => Stream.value(const []),
  );
});

final userWasteLogCountProvider = StreamProvider<int>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) {
      if (user == null) return Stream.value(0);
      return ref
          .watch(wasteRepositoryProvider)
          .watchUserWasteLogCount(user.uid);
    },
    loading: () => const Stream.empty(),
    error: (_, _) => Stream.value(0),
  );
});

final scanControllerProvider =
    AutoDisposeAsyncNotifierProvider<ScanController, ScanResultModel?>(
      ScanController.new,
    );

class ScanController extends AutoDisposeAsyncNotifier<ScanResultModel?> {
  @override
  Future<ScanResultModel?> build() async => null;

  Future<ScanResultModel> submitQrCode(
    String qrCode, {
    String? selectedWasteType,
  }) async {
    state = const AsyncLoading();
    try {
      final user = ref.read(authStateProvider).valueOrNull;
      if (user == null) {
        throw const WasteRepositoryException('Giriş yapman gerekiyor.');
      }

      final result = await ref
          .read(wasteRepositoryProvider)
          .createQrWasteLogAndAddPoints(
            userId: user.uid,
            qrCode: qrCode,
            wasteType: selectedWasteType ?? WasteTypes.plastic,
          );
      state = AsyncData(result);
      return result;
    } on Object catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  Future<ScanResultModel> submitPhotoWaste({
    required String wasteType,
    XFile? photo,
  }) async {
    state = const AsyncLoading();
    try {
      final user = ref.read(authStateProvider).valueOrNull;
      if (user == null) {
        throw const WasteRepositoryException('Giriş yapman gerekiyor.');
      }
      if (photo == null) {
        throw const WasteRepositoryException('Fotoğraf seçilemedi.');
      }

      await ref
          .read(wasteRepositoryProvider)
          .createPhotoWasteLogAndAddPoints(
            userId: user.uid,
            wasteType: wasteType,
            photo: photo,
          );
      const result = ScanResultModel(
        wasteLogId: null,
        pointsEarned: 0,
        bonusPoints: 0,
        completedTaskTitles: [],
        message: 'Fotoğraf kaydın inceleme için alındı.',
        isPhotoPending: true,
      );
      state = const AsyncData(result);
      return result;
    } on Object catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      Error.throwWithStackTrace(error, stackTrace);
    }
  }
}
