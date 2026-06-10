import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cleanup_event_model.dart';
import '../models/cleanup_proof_model.dart';
import '../repositories/cleanup_event_repository.dart';
import 'auth_provider.dart';

final cleanupEventRepositoryProvider = Provider<CleanupEventRepository>((ref) {
  return CleanupEventRepository();
});

final cleanupEventsForDirtyAreaProvider =
    StreamProvider.family<List<CleanupEventModel>, String>((ref, dirtyAreaId) {
      return ref
          .watch(cleanupEventRepositoryProvider)
          .watchEventsForDirtyArea(dirtyAreaId);
    });

final plannedCleanupEventsProvider = StreamProvider<List<CleanupEventModel>>((
  ref,
) {
  return ref.watch(cleanupEventRepositoryProvider).watchPlannedEvents();
});

final pendingApprovalCleanupEventsProvider =
    StreamProvider<List<CleanupEventModel>>((ref) {
      return ref
          .watch(cleanupEventRepositoryProvider)
          .watchPendingApprovalEvents();
    });

final cleanupEventDetailProvider =
    StreamProvider.family<CleanupEventModel?, String>((ref, eventId) {
      return ref
          .watch(cleanupEventRepositoryProvider)
          .watchCleanupEvent(eventId);
    });

final cleanupProofForEventProvider =
    StreamProvider.family<CleanupProofModel?, String>((ref, cleanupEventId) {
      return ref
          .watch(cleanupEventRepositoryProvider)
          .watchCleanupProofForEvent(cleanupEventId);
    });

final userJoinedCleanupEventsProvider = StreamProvider<List<CleanupEventModel>>(
  (ref) {
    final authState = ref.watch(authStateProvider);
    return authState.when(
      data: (user) {
        if (user == null) return Stream.value(const []);
        return ref
            .watch(cleanupEventRepositoryProvider)
            .watchUserJoinedEvents(user.uid);
      },
      loading: () => const Stream.empty(),
      error: (_, _) => Stream.value(const []),
    );
  },
);

final userCreatedCleanupEventsProvider =
    StreamProvider<List<CleanupEventModel>>((ref) {
      final authState = ref.watch(authStateProvider);
      return authState.when(
        data: (user) {
          if (user == null) return Stream.value(const []);
          return ref
              .watch(cleanupEventRepositoryProvider)
              .watchUserCreatedEvents(user.uid);
        },
        loading: () => const Stream.empty(),
        error: (_, _) => Stream.value(const []),
      );
    });

final cleanupEventCompletionControllerProvider =
    AutoDisposeAsyncNotifierProvider<CleanupEventCompletionController, void>(
      CleanupEventCompletionController.new,
    );

class CleanupEventCompletionController extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> complete({
    required String cleanupEventId,
    required String dirtyAreaId,
    required String completedByUserId,
    required String completedByUsername,
    required String completionPhotoUrl,
    required String? completionNote,
    required int pointsPerParticipant,
  }) async {
    state = const AsyncLoading();
    try {
      await ref
          .read(cleanupEventRepositoryProvider)
          .completeCleanupEvent(
            cleanupEventId: cleanupEventId,
            dirtyAreaId: dirtyAreaId,
            completedByUserId: completedByUserId,
            completedByUsername: completedByUsername,
            completionPhotoUrl: completionPhotoUrl,
            completionNote: completionNote,
            pointsPerParticipant: pointsPerParticipant,
          );
      state = const AsyncData(null);
    } on Object catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      Error.throwWithStackTrace(error, stackTrace);
    }
  }
}

final cleanupApprovalControllerProvider =
    AutoDisposeAsyncNotifierProvider<CleanupApprovalController, void>(
      CleanupApprovalController.new,
    );

class CleanupApprovalController extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> approve({
    required String cleanupEventId,
    required String adminUserId,
    required String adminUsername,
  }) async {
    state = const AsyncLoading();
    try {
      await ref
          .read(cleanupEventRepositoryProvider)
          .approveCleanupEvent(
            cleanupEventId: cleanupEventId,
            adminUserId: adminUserId,
            adminUsername: adminUsername,
          );
      state = const AsyncData(null);
    } on Object catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  Future<void> reject({
    required String cleanupEventId,
    required String adminUserId,
    required String adminUsername,
    required String reason,
  }) async {
    state = const AsyncLoading();
    try {
      await ref
          .read(cleanupEventRepositoryProvider)
          .rejectCleanupEvent(
            cleanupEventId: cleanupEventId,
            adminUserId: adminUserId,
            adminUsername: adminUsername,
            reason: reason,
          );
      state = const AsyncData(null);
    } on Object catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      Error.throwWithStackTrace(error, stackTrace);
    }
  }
}
