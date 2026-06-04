import 'package:atikavi_erzurum/core/utils/task_progress_resolver.dart';
import 'package:atikavi_erzurum/models/task_model.dart';
import 'package:atikavi_erzurum/models/user_task_progress_model.dart';
import 'package:atikavi_erzurum/models/waste_log_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('doesTaskMatchWasteLog', () {
    test('matches scan_plastic only for plastic waste', () {
      expect(
        doesTaskMatchWasteLog(
          _task(requiredAction: TaskActions.scanPlastic),
          WasteTypes.plastic,
        ),
        isTrue,
      );
      expect(
        doesTaskMatchWasteLog(
          _task(requiredAction: TaskActions.scanPlastic),
          WasteTypes.paper,
        ),
        isFalse,
      );
    });

    test('matches scan_paper for paper waste', () {
      expect(
        doesTaskMatchWasteLog(
          _task(requiredAction: TaskActions.scanPaper),
          WasteTypes.paper,
        ),
        isTrue,
      );
    });

    test('matches scan_battery for battery waste', () {
      expect(
        doesTaskMatchWasteLog(
          _task(requiredAction: TaskActions.scanBattery),
          WasteTypes.battery,
        ),
        isTrue,
      );
    });

    test('matches scan_any for every waste type', () {
      final task = _task(requiredAction: TaskActions.scanAny);

      expect(doesTaskMatchWasteLog(task, WasteTypes.plastic), isTrue);
      expect(doesTaskMatchWasteLog(task, WasteTypes.paper), isTrue);
      expect(doesTaskMatchWasteLog(task, WasteTypes.glass), isTrue);
    });

    test('matches winter_cup_lid for plastic or paper', () {
      final task = _task(requiredAction: TaskActions.winterCupLid);

      expect(doesTaskMatchWasteLog(task, WasteTypes.plastic), isTrue);
      expect(doesTaskMatchWasteLog(task, WasteTypes.paper), isTrue);
      expect(doesTaskMatchWasteLog(task, WasteTypes.battery), isFalse);
    });

    test('does not match non-waste-log actions', () {
      expect(
        doesTaskMatchWasteLog(
          _task(requiredAction: TaskActions.inviteFriend),
          WasteTypes.plastic,
        ),
        isFalse,
      );
      expect(
        doesTaskMatchWasteLog(
          _task(requiredAction: TaskActions.solveQuiz),
          WasteTypes.plastic,
        ),
        isFalse,
      );
      expect(
        doesTaskMatchWasteLog(
          _task(requiredAction: TaskActions.reportNearbyPoint),
          WasteTypes.plastic,
        ),
        isFalse,
      );
    });
  });

  group('incrementProgress', () {
    test('increments an incomplete task without completing it', () {
      final now = DateTime(2026, 6, 4, 12);
      final result = incrementProgress(
        progress: _progress(currentCount: 0, requiredCount: 5),
        now: now,
      );

      expect(result.currentCount, 1);
      expect(result.requiredCount, 5);
      expect(result.isCompleted, isFalse);
      expect(result.completedAt, isNull);
      expect(result.updatedAt, now);
    });

    test('marks task completed when required count is reached', () {
      final now = DateTime(2026, 6, 4, 12);
      final result = incrementProgress(
        progress: _progress(currentCount: 4, requiredCount: 5),
        now: now,
      );

      expect(result.currentCount, 5);
      expect(result.requiredCount, 5);
      expect(result.isCompleted, isTrue);
      expect(result.completedAt, now);
    });

    test('does not increment an already completed task', () {
      final completedAt = DateTime(2026, 6, 4, 10);
      final claimedAt = DateTime(2026, 6, 4, 11);
      final now = DateTime(2026, 6, 4, 12);
      final result = incrementProgress(
        progress: _progress(
          currentCount: 5,
          requiredCount: 5,
          isCompleted: true,
          completedAt: completedAt,
          claimedAt: claimedAt,
        ),
        now: now,
      );

      expect(result.currentCount, 5);
      expect(result.isCompleted, isTrue);
      expect(result.completedAt, completedAt);
      expect(result.claimedAt, claimedAt);
    });

    test('keeps existing completedAt and claimedAt unchanged', () {
      final completedAt = DateTime(2026, 6, 4, 10);
      final claimedAt = DateTime(2026, 6, 4, 11);
      final now = DateTime(2026, 6, 4, 12);
      final result = incrementProgress(
        progress: _progress(
          currentCount: 4,
          requiredCount: 5,
          completedAt: completedAt,
          claimedAt: claimedAt,
        ),
        now: now,
      );

      expect(result.isCompleted, isTrue);
      expect(result.completedAt, completedAt);
      expect(result.claimedAt, claimedAt);
    });
  });

  group('task bonus', () {
    test('returns zero when task is not completed by this increment', () {
      final task = _task(pointReward: 40);
      final before = _progress(currentCount: 0, requiredCount: 5);
      final after = incrementProgress(
        progress: before,
        now: DateTime(2026, 6, 4, 12),
      );

      expect(shouldAwardTaskBonus(before: before, after: after), isFalse);
      expect(calculateTaskBonus(task: task, before: before, after: after), 0);
    });

    test('returns task reward when task is completed by this increment', () {
      final task = _task(pointReward: 40);
      final before = _progress(currentCount: 4, requiredCount: 5);
      final after = incrementProgress(
        progress: before,
        now: DateTime(2026, 6, 4, 12),
      );

      expect(shouldAwardTaskBonus(before: before, after: after), isTrue);
      expect(calculateTaskBonus(task: task, before: before, after: after), 40);
    });

    test('returns zero when task was already completed', () {
      final task = _task(pointReward: 40);
      final before = _progress(
        currentCount: 5,
        requiredCount: 5,
        isCompleted: true,
        completedAt: DateTime(2026, 6, 4, 10),
      );
      final after = incrementProgress(
        progress: before,
        now: DateTime(2026, 6, 4, 12),
      );

      expect(shouldAwardTaskBonus(before: before, after: after), isFalse);
      expect(calculateTaskBonus(task: task, before: before, after: after), 0);
    });

    test('does not award the same task twice', () {
      final task = _task(pointReward: 40);
      final firstBefore = _progress(currentCount: 4, requiredCount: 5);
      final firstAfter = incrementProgress(
        progress: firstBefore,
        now: DateTime(2026, 6, 4, 12),
      );
      final secondAfter = incrementProgress(
        progress: firstAfter,
        now: DateTime(2026, 6, 4, 12, 1),
      );

      expect(
        calculateTaskBonus(task: task, before: firstBefore, after: firstAfter),
        40,
      );
      expect(
        calculateTaskBonus(task: task, before: firstAfter, after: secondAfter),
        0,
      );
    });
  });
}

TaskModel _task({
  String requiredAction = TaskActions.scanPlastic,
  int pointReward = 10,
}) {
  return TaskModel(
    id: 'task_$requiredAction',
    title: 'Test task',
    description: 'Test description',
    type: TaskTypes.daily,
    pointReward: pointReward,
    requiredAction: requiredAction,
    requiredCount: 5,
    isWinterOnly: false,
    iconEmoji: '*',
  );
}

UserTaskProgressModel _progress({
  int currentCount = 0,
  int requiredCount = 5,
  bool isCompleted = false,
  DateTime? completedAt,
  DateTime? claimedAt,
}) {
  return UserTaskProgressModel(
    id: 'task_1',
    userId: 'user_1',
    taskId: 'task_1',
    currentCount: currentCount,
    requiredCount: requiredCount,
    isCompleted: isCompleted,
    completedAt: completedAt,
    claimedAt: claimedAt,
    createdAt: DateTime(2026, 6, 4),
    updatedAt: DateTime(2026, 6, 4),
  );
}
