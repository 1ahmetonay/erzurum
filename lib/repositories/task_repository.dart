import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/firestore_paths.dart';
import '../core/utils/task_progress_resolver.dart';
import '../models/task_model.dart';
import '../models/user_task_progress_model.dart';
import '../models/waste_log_model.dart';

class TaskRepository {
  TaskRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<TaskModel>> watchActiveTasks() {
    return _firestore
        .collection(FirestorePaths.tasks)
        .where('isActive', isEqualTo: true)
        .orderBy('sortOrder')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => _parseTask(doc.data()))
              .whereType<TaskModel>()
              .toList(),
        );
  }

  Stream<List<UserTaskProgressModel>> watchUserTaskProgress(String userId) {
    if (userId.trim().isEmpty) return Stream.value(const []);
    return _firestore
        .collection(FirestorePaths.userTaskProgress(userId))
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => _parseProgress(doc.data()))
              .whereType<UserTaskProgressModel>()
              .toList(),
        );
  }

  Future<void> initializeUserTaskProgressIfNeeded(String userId) async {
    if (userId.trim().isEmpty) return;

    final tasksSnapshot = await _firestore
        .collection(FirestorePaths.tasks)
        .where('isActive', isEqualTo: true)
        .get();
    final tasks = tasksSnapshot.docs
        .map((doc) => _parseTask(doc.data()))
        .whereType<TaskModel>()
        .where((task) => (task.requiredCount ?? 0) > 0)
        .toList();
    if (tasks.isEmpty) return;

    final progressCollection = _firestore.collection(
      FirestorePaths.userTaskProgress(userId),
    );
    final existingSnapshot = await progressCollection.get();
    final existingIds = existingSnapshot.docs.map((doc) => doc.id).toSet();
    final now = DateTime.now();
    final batch = _firestore.batch();
    var hasWrites = false;

    for (final task in tasks) {
      if (existingIds.contains(task.id)) continue;
      hasWrites = true;
      final progress = UserTaskProgressModel(
        id: task.id,
        userId: userId,
        taskId: task.id,
        currentCount: 0,
        requiredCount: task.requiredCount ?? 1,
        isCompleted: false,
        createdAt: now,
        updatedAt: now,
      );
      batch.set(progressCollection.doc(task.id), progress.toMap());
    }

    if (hasWrites) {
      await batch.commit();
    }
  }

  Future<TaskProgressUpdateResult> updateProgressForWasteLog({
    required String userId,
    required String wasteType,
    String verificationMethod = VerificationMethods.qr,
  }) async {
    final tasks = await matchingTasksForWasteLog(
      wasteType: wasteType,
      verificationMethod: verificationMethod,
    );
    if (tasks.isEmpty) return const TaskProgressUpdateResult.empty();

    return _firestore.runTransaction((transaction) async {
      final userRef = _firestore.collection(FirestorePaths.users).doc(userId);
      final userSnapshot = await transaction.get(userRef);
      final result = await updateProgressForWasteLogInTransaction(
        transaction: transaction,
        userId: userId,
        tasks: tasks,
        now: DateTime.now(),
      );

      final userData = userSnapshot.data() ?? <String, dynamic>{};
      if (result.bonusPoints > 0) {
        transaction.set(userRef, {
          'totalPoints':
              _intFromValue(userData['totalPoints']) + result.bonusPoints,
          'weeklyPoints':
              _intFromValue(userData['weeklyPoints']) + result.bonusPoints,
          'updatedAt': DateTime.now(),
        }, SetOptions(merge: true));
      }

      return result;
    });
  }

  Future<List<TaskModel>> matchingTasksForWasteLog({
    required String wasteType,
    String verificationMethod = VerificationMethods.qr,
  }) async {
    if (verificationMethod != VerificationMethods.qr) return const [];

    final snapshot = await _firestore
        .collection(FirestorePaths.tasks)
        .where('isActive', isEqualTo: true)
        .get();

    return snapshot.docs
        .map((doc) => _parseTask(doc.data()))
        .whereType<TaskModel>()
        .where((task) => doesTaskMatchWasteLog(task, wasteType))
        .toList();
  }

  Future<TaskProgressUpdateResult> updateProgressForWasteLogInTransaction({
    required Transaction transaction,
    required String userId,
    required List<TaskModel> tasks,
    required DateTime now,
  }) async {
    final progressRefs = [
      for (final task in tasks)
        _firestore.doc(FirestorePaths.userTaskProgressDoc(userId, task.id)),
    ];
    final progressSnapshots = <DocumentSnapshot<Map<String, dynamic>>>[];
    for (final ref in progressRefs) {
      progressSnapshots.add(await transaction.get(ref));
    }

    final completedTitles = <String>[];
    var bonusPoints = 0;

    for (var i = 0; i < tasks.length; i += 1) {
      final task = tasks[i];
      final requiredCount = task.requiredCount ?? 1;
      if (requiredCount <= 0) continue;

      final progressRef = progressRefs[i];
      final snapshot = progressSnapshots[i];
      final existing = snapshot.data();
      final progress = existing == null
          ? UserTaskProgressModel(
              id: task.id,
              userId: userId,
              taskId: task.id,
              currentCount: 0,
              requiredCount: requiredCount,
              isCompleted: false,
              createdAt: now,
              updatedAt: now,
            )
          : UserTaskProgressModel.fromMap(existing);

      if (progress.isCompleted) continue;

      final nextProgress = incrementProgress(
        progress: progress.copyWith(requiredCount: requiredCount),
        now: now,
      ).copyWith(id: task.id, userId: userId, taskId: task.id);

      transaction.set(
        progressRef,
        nextProgress.toMap(),
        SetOptions(merge: true),
      );

      if (shouldAwardTaskBonus(before: progress, after: nextProgress)) {
        bonusPoints += calculateTaskBonus(
          task: task,
          before: progress,
          after: nextProgress,
        );
        completedTitles.add(task.title);
      }
    }

    return TaskProgressUpdateResult(
      completedTaskTitles: completedTitles,
      bonusPoints: bonusPoints,
    );
  }

  TaskModel? _parseTask(Map<String, dynamic> data) {
    try {
      return TaskModel.fromMap(data);
    } on Object {
      return null;
    }
  }

  UserTaskProgressModel? _parseProgress(Map<String, dynamic> data) {
    try {
      return UserTaskProgressModel.fromMap(data);
    } on Object {
      return null;
    }
  }

  int _intFromValue(Object? value) {
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}

class TaskProgressUpdateResult {
  const TaskProgressUpdateResult({
    required this.completedTaskTitles,
    required this.bonusPoints,
  });

  const TaskProgressUpdateResult.empty()
    : completedTaskTitles = const [],
      bonusPoints = 0;

  final List<String> completedTaskTitles;
  final int bonusPoints;
}
