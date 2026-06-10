import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/firestore_paths.dart';
import '../models/dirty_area_model.dart';
import '../models/photo_analysis_result_model.dart';

class DirtyAreaRepository {
  DirtyAreaRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<String> createDirtyArea(DirtyAreaModel dirtyArea) async {
    if (dirtyArea.reportedByUserId.trim().isEmpty) {
      throw const DirtyAreaRepositoryException(
        'Kirli bölge bildirmek için giriş yapmalısın.',
      );
    }
    if (dirtyArea.title.trim().isEmpty) {
      throw const DirtyAreaRepositoryException('Başlık boş olamaz.');
    }
    if (dirtyArea.description.trim().isEmpty) {
      throw const DirtyAreaRepositoryException('Açıklama boş olamaz.');
    }

    final docRef = dirtyArea.id.trim().isEmpty
        ? _firestore.collection(FirestorePaths.dirtyAreas).doc()
        : _firestore.collection(FirestorePaths.dirtyAreas).doc(dirtyArea.id);
    final now = DateTime.now();
    final record = dirtyArea.copyWith(
      id: docRef.id,
      severityLevel: dirtyArea.severityLevel.clamp(1, 5).toInt(),
      status: DirtyAreaStatuses.reported,
      participantCount: 0,
      photoAnalysisStatus: PhotoAnalysisStatuses.pending,
      aiDetectedWasteTypes: const [],
      aiAnalysisSummary: 'Fotoğraf analizi bekleniyor.',
      createdAt: dirtyArea.createdAt,
      updatedAt: now,
    );

    await docRef.set(record.toFirestore());
    return docRef.id;
  }

  Future<void> updatePhotoAnalysisResult({
    required String dirtyAreaId,
    required PhotoAnalysisResultModel result,
  }) async {
    if (dirtyAreaId.trim().isEmpty) {
      throw const DirtyAreaRepositoryException('Kirli bölge bilgisi eksik.');
    }
    if (!PhotoAnalysisStatuses.values.contains(result.status)) {
      throw const DirtyAreaRepositoryException('Geçersiz analiz durumu.');
    }

    // Production: AI results must be written through Cloud Functions/Admin SDK.
    await _firestore
        .collection(FirestorePaths.dirtyAreas)
        .doc(dirtyAreaId)
        .update({
          'photoAnalysisStatus': result.status,
          'aiCleanlinessScore': result.cleanlinessScore,
          'aiWasteMatchScore': result.wasteMatchScore,
          'aiDetectedWasteTypes': result.detectedWasteTypes,
          'aiAnalysisSummary': result.summary,
          'aiAnalysisProvider': result.provider,
          'aiAnalyzedAt': result.analyzedAt,
          'updatedAt': DateTime.now(),
        });
  }

  Stream<List<DirtyAreaModel>> watchDirtyAreas() {
    return _firestore
        .collection(FirestorePaths.dirtyAreas)
        .snapshots()
        .map(_parseSnapshot);
  }

  Stream<List<DirtyAreaModel>> watchDirtyAreasByStatus(String status) {
    if (!DirtyAreaStatuses.values.contains(status)) {
      return Stream.value(const []);
    }
    return _firestore
        .collection(FirestorePaths.dirtyAreas)
        .where('status', isEqualTo: status)
        .snapshots()
        .map(_parseSnapshot);
  }

  Stream<DirtyAreaModel?> watchDirtyArea(String id) {
    if (id.trim().isEmpty) return Stream.value(null);
    return _firestore
        .collection(FirestorePaths.dirtyAreas)
        .doc(id)
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists) return null;
          return _parseDirtyArea(snapshot);
        });
  }

  Stream<List<DirtyAreaModel>> watchUserDirtyAreas(String userId) {
    if (userId.trim().isEmpty) return Stream.value(const []);
    return _firestore
        .collection(FirestorePaths.dirtyAreas)
        .where('reportedByUserId', isEqualTo: userId)
        .snapshots()
        .map(_parseSnapshot);
  }

  Future<void> updateStatus({
    required String dirtyAreaId,
    required String status,
  }) async {
    if (dirtyAreaId.trim().isEmpty) {
      throw const DirtyAreaRepositoryException('Kirli bölge bilgisi eksik.');
    }
    if (!DirtyAreaStatuses.values.contains(status)) {
      throw const DirtyAreaRepositoryException('Geçersiz durum değeri.');
    }

    await _firestore
        .collection(FirestorePaths.dirtyAreas)
        .doc(dirtyAreaId)
        .update({'status': status, 'updatedAt': DateTime.now()});
  }

  List<DirtyAreaModel> _parseSnapshot(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    return snapshot.docs
        .map(_parseDirtyArea)
        .whereType<DirtyAreaModel>()
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  DirtyAreaModel? _parseDirtyArea(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    try {
      return DirtyAreaModel.fromFirestore(snapshot);
    } on Object {
      return null;
    }
  }
}

class DirtyAreaRepositoryException implements Exception {
  const DirtyAreaRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}
