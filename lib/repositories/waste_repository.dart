import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../core/constants/firestore_paths.dart';
import '../core/utils/task_progress_resolver.dart';
import '../models/recycling_point_model.dart';
import '../models/scan_result_model.dart';
import '../models/waste_log_model.dart';
import 'task_repository.dart';

class WasteRepository {
  WasteRepository({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
    TaskRepository? taskRepository,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _storage = storage ?? FirebaseStorage.instance,
       _taskRepository = taskRepository ?? TaskRepository(firestore: firestore);

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final TaskRepository _taskRepository;

  Future<RecyclingPointModel?> getRecyclingPointByQrCode(String qrCode) async {
    final normalized = qrCode.trim();
    if (normalized.isEmpty) {
      throw const WasteRepositoryException('QR kodu boş olamaz.');
    }

    final directDoc = await _firestore
        .collection(FirestorePaths.recyclingPoints)
        .doc(normalized)
        .get();
    if (directDoc.exists && directDoc.data() != null) {
      return RecyclingPointModel.fromMap(directDoc.data()!);
    }

    final query = await _firestore
        .collection(FirestorePaths.recyclingPoints)
        .where('qrCode', isEqualTo: normalized)
        .limit(1)
        .get();
    if (query.docs.isEmpty) return null;
    return RecyclingPointModel.fromMap(query.docs.first.data());
  }

  Future<ScanResultModel> createQrWasteLogAndAddPoints({
    required String userId,
    required String qrCode,
    required String wasteType,
  }) async {
    if (userId.trim().isEmpty) {
      throw const WasteRepositoryException('Giriş yapman gerekiyor.');
    }

    final point = await getRecyclingPointByQrCode(qrCode);
    if (point == null) {
      throw const WasteRepositoryException('QR noktası bulunamadı.');
    }
    if (!point.isActive) {
      throw const WasteRepositoryException('Bu nokta aktif değil.');
    }
    if (point.isBroken) {
      throw const WasteRepositoryException(
        'Bu nokta bozuk görünüyor. Lütfen başka bir nokta dene.',
      );
    }

    await _ensureRecentQrIsAllowed(userId: userId, qrPointId: point.id);

    final pointsEarned = pointsForWasteType(wasteType);
    final matchingTasks = await _taskRepository.matchingTasksForWasteLog(
      wasteType: wasteType,
      verificationMethod: VerificationMethods.qr,
    );
    final logRef = _firestore.collection(FirestorePaths.wasteLogs).doc();
    final userRef = _firestore.collection(FirestorePaths.users).doc(userId);
    final now = DateTime.now();
    final log = WasteLogModel(
      id: logRef.id,
      userId: userId,
      wasteType: wasteType,
      verificationMethod: VerificationMethods.qr,
      qrPointId: point.id,
      recyclingPointName: point.name,
      latitude: point.latitude,
      longitude: point.longitude,
      pointsEarned: pointsEarned,
      loggedAt: now,
      status: WasteLogStatuses.approved,
    );

    final progressResult = await _firestore.runTransaction((transaction) async {
      final userSnapshot = await transaction.get(userRef);
      final taskProgressResult = await _taskRepository
          .updateProgressForWasteLogInTransaction(
            transaction: transaction,
            userId: userId,
            tasks: matchingTasks,
            now: now,
          );
      final userData = userSnapshot.data() ?? <String, dynamic>{};
      final totalPoints = _intFromValue(userData['totalPoints']);
      final weeklyPoints = _intFromValue(userData['weeklyPoints']);
      final totalEarned = pointsEarned + taskProgressResult.bonusPoints;

      transaction.set(logRef, log.toMap());
      transaction.set(userRef, {
        'totalPoints': totalPoints + totalEarned,
        'weeklyPoints': weeklyPoints + totalEarned,
        'updatedAt': now,
      }, SetOptions(merge: true));

      return taskProgressResult;
    });

    return ScanResultModel(
      wasteLogId: logRef.id,
      pointsEarned: pointsEarned,
      bonusPoints: progressResult.bonusPoints,
      completedTaskTitles: progressResult.completedTaskTitles,
      message: '+$pointsEarned Dadaş Puan kazandın!',
    );
  }

  Future<void> createPhotoWasteLogAndAddPoints({
    required String userId,
    required String wasteType,
    required XFile photo,
  }) async {
    if (userId.trim().isEmpty) {
      throw const WasteRepositoryException('Giriş yapman gerekiyor.');
    }

    final logRef = _firestore.collection(FirestorePaths.wasteLogs).doc();
    final now = DateTime.now();
    String? photoUrl;

    try {
      final bytes = await photo.readAsBytes();
      final storageRef = _storage.ref('waste_photos/$userId/${logRef.id}.jpg');
      await storageRef.putData(
        bytes,
        SettableMetadata(contentType: photo.mimeType ?? 'image/jpeg'),
      );
      photoUrl = await storageRef.getDownloadURL();
    } on Object catch (error) {
      throw WasteRepositoryException('Fotoğraf yüklenemedi: $error');
    }

    final log = WasteLogModel(
      id: logRef.id,
      userId: userId,
      wasteType: wasteType,
      verificationMethod: VerificationMethods.photo,
      photoUrl: photoUrl,
      qrPointId: null,
      recyclingPointName: null,
      latitude: 0,
      longitude: 0,
      pointsEarned: 10,
      loggedAt: now,
      status: WasteLogStatuses.pending,
    );

    // Demo photo flow creates a pending review record and does not add points.
    await logRef.set(log.toMap());
  }

  Stream<List<WasteLogModel>> watchUserWasteLogs(String userId) {
    if (userId.isEmpty) return Stream.value(const []);
    return _firestore
        .collection(FirestorePaths.wasteLogs)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => _parseLog(doc.data()))
                  .whereType<WasteLogModel>()
                  .toList()
                ..sort((a, b) => b.loggedAt.compareTo(a.loggedAt)),
        );
  }

  Stream<int> watchUserWasteLogCount(String userId) {
    return watchUserWasteLogs(userId).map((logs) => logs.length);
  }

  Future<void> _ensureRecentQrIsAllowed({
    required String userId,
    required String qrPointId,
  }) async {
    final snapshot = await _firestore
        .collection(FirestorePaths.wasteLogs)
        .where('userId', isEqualTo: userId)
        .limit(50)
        .get();
    final now = DateTime.now();
    final hasRecentApprovedLog = snapshot.docs
        .map((doc) => _parseLog(doc.data()))
        .whereType<WasteLogModel>()
        .any(
          (log) =>
              log.qrPointId == qrPointId &&
              log.status == WasteLogStatuses.approved &&
              isWithinQrCooldown(
                log.loggedAt,
                now,
                const Duration(minutes: 10),
              ),
        );

    if (hasRecentApprovedLog) {
      throw const WasteRepositoryException(
        'Bu noktadan kısa süre önce puan kazandın. Lütfen biraz sonra tekrar dene.',
      );
    }
  }

  int pointsForWasteType(String wasteType) {
    return calculateWastePoints(wasteType);
  }

  WasteLogModel? _parseLog(Map<String, dynamic> data) {
    try {
      return WasteLogModel.fromMap(data);
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

class WasteRepositoryException implements Exception {
  const WasteRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}
