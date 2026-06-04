import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/firestore_paths.dart';
import '../core/utils/point_report_resolver.dart';
import '../models/point_report_model.dart';
import '../models/recycling_point_model.dart';
import 'task_repository.dart';

class PointReportRepository {
  PointReportRepository({
    FirebaseFirestore? firestore,
    TaskRepository? taskRepository,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _taskRepository = taskRepository ?? TaskRepository(firestore: firestore);

  final FirebaseFirestore _firestore;
  final TaskRepository _taskRepository;

  Future<TaskProgressUpdateResult> createPointReport({
    required String userId,
    required RecyclingPointModel point,
    required String reportType,
    String? description,
  }) async {
    final normalizedUserId = userId.trim();
    final normalizedReportType = reportType.trim();
    if (normalizedUserId.isEmpty) {
      throw const PointReportRepositoryException(
        'Bildirim göndermek için giriş yapmalısın.',
      );
    }
    if (point.id.trim().isEmpty) {
      throw const PointReportRepositoryException('Nokta bilgisi eksik.');
    }
    if (!isValidReportType(normalizedReportType)) {
      throw const PointReportRepositoryException('Bildirim türü geçersiz.');
    }

    await _ensureRecentReportIsAllowed(
      userId: normalizedUserId,
      pointId: point.id,
    );

    final reportRef = _firestore.collection(FirestorePaths.pointReports).doc();
    final now = DateTime.now();
    final report = PointReportModel(
      id: reportRef.id,
      userId: normalizedUserId,
      pointId: point.id,
      pointName: point.name,
      reportType: normalizedReportType,
      description: _nullableTrimmed(description),
      status: PointReportStatuses.pending,
      createdAt: now,
    );

    await reportRef.set(report.toMap());

    return _taskRepository.updateProgressForPointReport(
      userId: normalizedUserId,
      reportType: normalizedReportType,
    );
  }

  Stream<List<PointReportModel>> watchUserPointReports(String userId) {
    if (userId.trim().isEmpty) return Stream.value(const []);
    return _firestore
        .collection(FirestorePaths.pointReports)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => _parseReport(doc.data()))
                  .whereType<PointReportModel>()
                  .toList()
                ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
        );
  }

  Stream<List<PointReportModel>> watchPendingPointReports() {
    return _firestore
        .collection(FirestorePaths.pointReports)
        .where('status', isEqualTo: PointReportStatuses.pending)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => _parseReport(doc.data()))
                  .whereType<PointReportModel>()
                  .toList()
                ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
        );
  }

  Future<void> _ensureRecentReportIsAllowed({
    required String userId,
    required String pointId,
  }) async {
    final snapshot = await _firestore
        .collection(FirestorePaths.pointReports)
        .where('userId', isEqualTo: userId)
        .limit(50)
        .get();
    final now = DateTime.now();
    final hasRecentReport = snapshot.docs
        .map((doc) => _parseReport(doc.data()))
        .whereType<PointReportModel>()
        .any(
          (report) =>
              report.pointId == pointId &&
              report.status == PointReportStatuses.pending &&
              isWithinReportCooldown(
                report.createdAt,
                now,
                const Duration(minutes: 30),
              ),
        );

    if (hasRecentReport) {
      throw const PointReportRepositoryException(
        'Bu nokta için kısa süre önce bildirim gönderdin.',
      );
    }
  }

  PointReportModel? _parseReport(Map<String, dynamic> data) {
    try {
      return PointReportModel.fromMap(data);
    } on Object {
      return null;
    }
  }

  String? _nullableTrimmed(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }
}

class PointReportRepositoryException implements Exception {
  const PointReportRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}
