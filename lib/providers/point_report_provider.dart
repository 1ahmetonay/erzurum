import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/point_report_model.dart';
import '../models/recycling_point_model.dart';
import '../repositories/point_report_repository.dart';
import 'auth_provider.dart';

final pointReportRepositoryProvider = Provider<PointReportRepository>((ref) {
  return PointReportRepository();
});

final userPointReportsProvider = StreamProvider<List<PointReportModel>>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) {
      if (user == null) return Stream.value(const []);
      return ref
          .watch(pointReportRepositoryProvider)
          .watchUserPointReports(user.uid);
    },
    loading: () => const Stream.empty(),
    error: (_, _) => Stream.value(const []),
  );
});

final pointReportControllerProvider =
    AutoDisposeAsyncNotifierProvider<PointReportController, void>(
      PointReportController.new,
    );

class PointReportController extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> submitPointReport({
    required RecyclingPointModel point,
    required String reportType,
    String? description,
  }) async {
    state = const AsyncLoading();
    try {
      final user = ref.read(authStateProvider).valueOrNull;
      if (user == null) {
        throw const PointReportRepositoryException(
          'Bildirim göndermek için giriş yapmalısın.',
        );
      }

      await ref
          .read(pointReportRepositoryProvider)
          .createPointReport(
            userId: user.uid,
            point: point,
            reportType: reportType,
            description: description,
          );
      state = const AsyncData(null);
    } on Object catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      Error.throwWithStackTrace(error, stackTrace);
    }
  }
}
