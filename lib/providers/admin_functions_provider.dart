import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/admin_functions_service.dart';

final adminFunctionsServiceProvider = Provider<AdminFunctionsService>((ref) {
  return AdminFunctionsService();
});

final cleanupApprovalFunctionsControllerProvider =
    AutoDisposeAsyncNotifierProvider<CleanupApprovalFunctionsController, void>(
      CleanupApprovalFunctionsController.new,
    );

class CleanupApprovalFunctionsController
    extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> approve(String cleanupEventId) async {
    state = const AsyncLoading();
    try {
      await ref
          .read(adminFunctionsServiceProvider)
          .approveCleanupEvent(cleanupEventId);
      state = const AsyncData(null);
    } on Object catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  Future<void> reject(String cleanupEventId, String reason) async {
    state = const AsyncLoading();
    try {
      await ref
          .read(adminFunctionsServiceProvider)
          .rejectCleanupEvent(cleanupEventId, reason);
      state = const AsyncData(null);
    } on Object catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      Error.throwWithStackTrace(error, stackTrace);
    }
  }
}

final adminClaimControllerProvider =
    AutoDisposeAsyncNotifierProvider<AdminClaimController, void>(
      AdminClaimController.new,
    );

class AdminClaimController extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> setAdminClaim({
    required String targetUid,
    required bool admin,
  }) async {
    state = const AsyncLoading();
    try {
      await ref
          .read(adminFunctionsServiceProvider)
          .setAdminClaim(targetUid, admin);
      state = const AsyncData(null);
    } on Object catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      Error.throwWithStackTrace(error, stackTrace);
    }
  }
}
