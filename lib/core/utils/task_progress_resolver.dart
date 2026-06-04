import '../../models/task_model.dart';
import '../../models/user_task_progress_model.dart';
import '../../models/waste_log_model.dart';

int calculateWastePoints(String wasteType) {
  return switch (wasteType) {
    WasteTypes.plastic => 10,
    WasteTypes.paper => 10,
    WasteTypes.glass => 12,
    WasteTypes.battery => 20,
    WasteTypes.oil => 25,
    WasteTypes.electronic => 30,
    _ => 10,
  };
}

bool doesTaskMatchWasteLog(TaskModel task, String wasteType) {
  return switch (task.requiredAction) {
    TaskActions.scanPlastic => wasteType == WasteTypes.plastic,
    TaskActions.scanPaper => wasteType == WasteTypes.paper,
    TaskActions.scanBattery => wasteType == WasteTypes.battery,
    TaskActions.scanAny => true,
    TaskActions.winterCupLid =>
      wasteType == WasteTypes.paper || wasteType == WasteTypes.plastic,
    _ => false,
  };
}

UserTaskProgressModel incrementProgress({
  required UserTaskProgressModel progress,
  required DateTime now,
}) {
  if (progress.isCompleted) return progress;

  final requiredCount = progress.requiredCount <= 0
      ? 1
      : progress.requiredCount;
  final nextCount = (progress.currentCount + 1).clamp(0, requiredCount);
  final isCompleted = nextCount >= requiredCount;

  return progress.copyWith(
    currentCount: nextCount,
    requiredCount: requiredCount,
    isCompleted: isCompleted,
    completedAt: isCompleted
        ? progress.completedAt ?? now
        : progress.completedAt,
    updatedAt: now,
  );
}

bool shouldAwardTaskBonus({
  required UserTaskProgressModel before,
  required UserTaskProgressModel after,
}) {
  return !before.isCompleted && after.isCompleted;
}

int calculateTaskBonus({
  required TaskModel task,
  required UserTaskProgressModel before,
  required UserTaskProgressModel after,
}) {
  return shouldAwardTaskBonus(before: before, after: after)
      ? task.pointReward
      : 0;
}

bool isWithinQrCooldown(
  DateTime? lastLoggedAt,
  DateTime now,
  Duration cooldown,
) {
  if (lastLoggedAt == null) return false;
  return now.difference(lastLoggedAt) < cooldown;
}
