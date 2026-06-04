import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/task_model.dart';
import '../models/user_task_progress_model.dart';
import '../repositories/task_repository.dart';
import 'auth_provider.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository();
});

final activeTasksProvider = StreamProvider<List<TaskModel>>((ref) {
  return ref.watch(taskRepositoryProvider).watchActiveTasks();
});

final userTaskProgressProvider = StreamProvider<List<UserTaskProgressModel>>((
  ref,
) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) {
      if (user == null) return Stream.value(const []);
      final repository = ref.watch(taskRepositoryProvider);
      return Stream.fromFuture(
        repository.initializeUserTaskProgressIfNeeded(user.uid),
      ).asyncExpand((_) => repository.watchUserTaskProgress(user.uid));
    },
    loading: () => const Stream.empty(),
    error: (_, _) => Stream.value(const []),
  );
});

final taskProgressMapProvider =
    Provider<AsyncValue<Map<String, UserTaskProgressModel>>>((ref) {
      final progressState = ref.watch(userTaskProgressProvider);
      return progressState.whenData(
        (progressList) => {
          for (final progress in progressList) progress.taskId: progress,
        },
      );
    });

final tasksWithProgressProvider = Provider<AsyncValue<List<TaskModel>>>((ref) {
  final tasksState = ref.watch(activeTasksProvider);
  final progressMapState = ref.watch(taskProgressMapProvider);

  if (tasksState.hasError && !tasksState.hasValue) {
    return AsyncError(
      tasksState.error!,
      tasksState.stackTrace ?? StackTrace.current,
    );
  }
  if (tasksState.isLoading && !tasksState.hasValue) {
    return const AsyncLoading();
  }

  final tasks = tasksState.valueOrNull ?? const <TaskModel>[];
  final progressMap = progressMapState.valueOrNull ?? const {};
  final merged = [
    for (final task in tasks) _taskWithProgress(task, progressMap[task.id]),
  ]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

  return AsyncData(merged);
});

TaskModel _taskWithProgress(TaskModel task, UserTaskProgressModel? progress) {
  if (progress == null) return task;
  return task.copyWith(
    currentCount: progress.currentCount,
    requiredCount: progress.requiredCount,
    isCompleted: progress.isCompleted,
  );
}
