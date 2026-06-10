import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../core/constants/firestore_paths.dart';
import '../models/cleanup_event_model.dart';
import '../models/cleanup_proof_model.dart';
import '../models/dirty_area_model.dart';

class CleanupEventRepository {
  CleanupEventRepository({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  Future<String> createCleanupEvent(CleanupEventModel cleanupEvent) async {
    _validateBaseEvent(cleanupEvent);

    final eventRef = cleanupEvent.id.trim().isEmpty
        ? _firestore.collection(FirestorePaths.cleanupEvents).doc()
        : _firestore
              .collection(FirestorePaths.cleanupEvents)
              .doc(cleanupEvent.id);
    final dirtyAreaRef = _firestore
        .collection(FirestorePaths.dirtyAreas)
        .doc(cleanupEvent.dirtyAreaId);
    final now = DateTime.now();
    final participantIds = cleanupEvent.participantIds.toSet().toList()..sort();
    final event = cleanupEvent.copyWith(
      id: eventRef.id,
      status: CleanupEventStatuses.planned,
      approvalStatus: CleanupApprovalStatuses.none,
      maxParticipants: cleanupEvent.maxParticipants.clamp(2, 500).toInt(),
      participantIds: participantIds,
      participantCount: participantIds.length,
      createdAt: cleanupEvent.createdAt,
      updatedAt: now,
    );

    await _firestore.runTransaction((transaction) async {
      final dirtyAreaSnapshot = await transaction.get(dirtyAreaRef);
      if (!dirtyAreaSnapshot.exists) {
        throw const CleanupEventRepositoryException(
          'Kirli bölge kaydı bulunamadı.',
        );
      }

      transaction.set(eventRef, event.toFirestore());
      transaction.update(dirtyAreaRef, {
        'status': DirtyAreaStatuses.planned,
        'participantCount': event.participantCount,
        'updatedAt': now,
      });
    });

    return eventRef.id;
  }

  Future<String> uploadCompletionPhoto({
    required String cleanupEventId,
    required String userId,
    required XFile photo,
  }) async {
    if (cleanupEventId.trim().isEmpty || userId.trim().isEmpty) {
      throw const CleanupEventRepositoryException('Fotoğraf yolu eksik.');
    }

    try {
      final bytes = await photo.readAsBytes();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final storageRef = _storage.ref(
        'cleanup_proofs/$cleanupEventId/${userId}_$timestamp.jpg',
      );
      await storageRef.putData(
        bytes,
        SettableMetadata(contentType: photo.mimeType ?? 'image/jpeg'),
      );
      return storageRef.getDownloadURL();
    } on Object catch (error) {
      throw CleanupEventRepositoryException('Fotoğraf yüklenemedi: $error');
    }
  }

  Future<void> completeCleanupEvent({
    required String cleanupEventId,
    required String dirtyAreaId,
    required String completedByUserId,
    required String completedByUsername,
    required String completionPhotoUrl,
    required String? completionNote,
    required int pointsPerParticipant,
  }) async {
    final normalizedEventId = cleanupEventId.trim();
    final normalizedDirtyAreaId = dirtyAreaId.trim();
    final normalizedUserId = completedByUserId.trim();
    final normalizedPhotoUrl = completionPhotoUrl.trim();
    final normalizedPoints = pointsPerParticipant.clamp(10, 200).toInt();

    if (normalizedEventId.isEmpty ||
        normalizedDirtyAreaId.isEmpty ||
        normalizedUserId.isEmpty) {
      throw const CleanupEventRepositoryException('Tamamlama bilgisi eksik.');
    }
    if (normalizedPhotoUrl.isEmpty) {
      throw const CleanupEventRepositoryException(
        'Kanıt fotoğrafı yüklenmeden tamamlanamaz.',
      );
    }

    final eventRef = _firestore
        .collection(FirestorePaths.cleanupEvents)
        .doc(normalizedEventId);
    final proofRef = _proofRef(normalizedEventId);
    final now = DateTime.now();

    // MVP note: proof upload is client-driven. Production should verify this
    // submission and later approval with Cloud Functions + Admin SDK.
    await _firestore.runTransaction((transaction) async {
      final eventSnapshot = await transaction.get(eventRef);
      final event = _eventFromSnapshot(eventSnapshot);
      if (event.dirtyAreaId != normalizedDirtyAreaId) {
        throw const CleanupEventRepositoryException(
          'Etkinlik ve kirli bölge eşleşmiyor.',
        );
      }
      if (event.createdByUserId != normalizedUserId) {
        throw const CleanupEventRepositoryException(
          'Temizliği yalnızca etkinliği oluşturan kullanıcı tamamlayabilir.',
        );
      }
      if (event.status == CleanupEventStatuses.pendingApproval) {
        throw const CleanupEventRepositoryException(
          'Bu etkinlik için kanıt zaten admin onayında.',
        );
      }
      if (event.status == CleanupEventStatuses.completed) {
        throw const CleanupEventRepositoryException(
          'Bu etkinlik zaten onaylanmış.',
        );
      }
      if (event.status == CleanupEventStatuses.cancelled) {
        throw const CleanupEventRepositoryException(
          'İptal edilen etkinlik tamamlanamaz.',
        );
      }
      if (event.pointsAwarded) {
        throw const CleanupEventRepositoryException(
          'Bu etkinlik için puanlar daha önce verilmiş.',
        );
      }
      final participantIds = event.participantIds.toSet().toList()..sort();
      if (participantIds.isEmpty) {
        throw const CleanupEventRepositoryException(
          'Katılımcı olmayan etkinlik tamamlanamaz.',
        );
      }

      final proof = CleanupProofModel(
        id: normalizedEventId,
        cleanupEventId: normalizedEventId,
        dirtyAreaId: normalizedDirtyAreaId,
        uploadedByUserId: normalizedUserId,
        uploadedByUsername: completedByUsername.trim().isEmpty
            ? 'AtıkAvı kullanıcısı'
            : completedByUsername.trim(),
        photoUrl: normalizedPhotoUrl,
        note: _nullableTrimmed(completionNote),
        createdAt: now,
        status: CleanupProofStatuses.pending,
      );

      transaction.update(eventRef, {
        'status': CleanupEventStatuses.pendingApproval,
        'approvalStatus': CleanupApprovalStatuses.pending,
        'completionPhotoUrl': normalizedPhotoUrl,
        'completedAt': now,
        'completedByUserId': normalizedUserId,
        'pointsAwarded': false,
        'pointsPerParticipant': normalizedPoints,
        'approvedByUserId': null,
        'approvedAt': null,
        'rejectedByUserId': null,
        'rejectedAt': null,
        'rejectionReason': null,
        'updatedAt': now,
      });
      transaction.set(proofRef, proof.toFirestore());
    });
  }

  Future<void> approveCleanupEvent({
    required String cleanupEventId,
    required String adminUserId,
    required String adminUsername,
  }) async {
    final eventRef = _eventRef(cleanupEventId);
    final proofRef = _proofRef(cleanupEventId);
    final now = DateTime.now();

    await _firestore.runTransaction((transaction) async {
      await _ensureAdmin(transaction: transaction, adminUserId: adminUserId);
      final event = _eventFromSnapshot(await transaction.get(eventRef));
      if (event.status != CleanupEventStatuses.pendingApproval ||
          event.approvalStatus != CleanupApprovalStatuses.pending) {
        throw const CleanupEventRepositoryException(
          'Bu etkinlik admin onayı beklemiyor.',
        );
      }
      if (event.pointsAwarded) {
        throw const CleanupEventRepositoryException(
          'Bu etkinlik için puanlar daha önce verilmiş.',
        );
      }
      final participantIds = event.participantIds.toSet().toList()..sort();
      if (participantIds.isEmpty) {
        throw const CleanupEventRepositoryException(
          'Katılımcı olmayan etkinlik onaylanamaz.',
        );
      }

      final userSnapshots = <String, DocumentSnapshot<Map<String, dynamic>>>{};
      for (final participantId in participantIds) {
        final userRef = _firestore
            .collection(FirestorePaths.users)
            .doc(participantId);
        userSnapshots[participantId] = await transaction.get(userRef);
      }

      transaction.update(eventRef, {
        'status': CleanupEventStatuses.completed,
        'approvalStatus': CleanupApprovalStatuses.approved,
        'approvedByUserId': adminUserId.trim(),
        'approvedAt': now,
        'pointsAwarded': true,
        'updatedAt': now,
      });
      transaction.update(_dirtyAreaRef(event.dirtyAreaId), {
        'status': DirtyAreaStatuses.cleaned,
        'updatedAt': now,
      });
      transaction.set(proofRef, {
        'status': CleanupProofStatuses.approved,
        'reviewedByUserId': adminUserId.trim(),
        'reviewedAt': now,
        'rejectionReason': null,
      }, SetOptions(merge: true));

      for (final participantId in participantIds) {
        final userRef = _firestore
            .collection(FirestorePaths.users)
            .doc(participantId);
        final userData = userSnapshots[participantId]?.data() ?? {};
        transaction.set(userRef, {
          'totalPoints':
              _intFromValue(userData['totalPoints']) +
              event.pointsPerParticipant,
          'weeklyPoints':
              _intFromValue(userData['weeklyPoints']) +
              event.pointsPerParticipant,
          'updatedAt': now,
        }, SetOptions(merge: true));
      }
    });
  }

  Future<void> rejectCleanupEvent({
    required String cleanupEventId,
    required String adminUserId,
    required String adminUsername,
    required String reason,
  }) async {
    final normalizedReason = reason.trim();
    if (normalizedReason.isEmpty) {
      throw const CleanupEventRepositoryException('Red sebebi boş olamaz.');
    }

    final eventRef = _eventRef(cleanupEventId);
    final proofRef = _proofRef(cleanupEventId);
    final now = DateTime.now();

    await _firestore.runTransaction((transaction) async {
      await _ensureAdmin(transaction: transaction, adminUserId: adminUserId);
      final event = _eventFromSnapshot(await transaction.get(eventRef));
      if (event.status != CleanupEventStatuses.pendingApproval) {
        throw const CleanupEventRepositoryException(
          'Bu etkinlik admin onayı beklemiyor.',
        );
      }
      if (event.pointsAwarded) {
        throw const CleanupEventRepositoryException(
          'Puan verilmiş etkinlik reddedilemez.',
        );
      }

      transaction.update(eventRef, {
        'status': CleanupEventStatuses.planned,
        'approvalStatus': CleanupApprovalStatuses.rejected,
        'rejectedByUserId': adminUserId.trim(),
        'rejectedAt': now,
        'rejectionReason': normalizedReason,
        'updatedAt': now,
      });
      transaction.set(proofRef, {
        'status': CleanupProofStatuses.rejected,
        'reviewedByUserId': adminUserId.trim(),
        'reviewedAt': now,
        'rejectionReason': normalizedReason,
      }, SetOptions(merge: true));
    });
  }

  Stream<List<CleanupEventModel>> watchEventsForDirtyArea(String dirtyAreaId) {
    if (dirtyAreaId.trim().isEmpty) return Stream.value(const []);
    return _firestore
        .collection(FirestorePaths.cleanupEvents)
        .where('dirtyAreaId', isEqualTo: dirtyAreaId)
        .snapshots()
        .map(_parseSnapshot);
  }

  Stream<List<CleanupEventModel>> watchPlannedEvents() {
    return _firestore
        .collection(FirestorePaths.cleanupEvents)
        .where('status', isEqualTo: CleanupEventStatuses.planned)
        .snapshots()
        .map(_parseSnapshot);
  }

  Stream<List<CleanupEventModel>> watchPendingApprovalEvents() {
    return _firestore
        .collection(FirestorePaths.cleanupEvents)
        .where('status', isEqualTo: CleanupEventStatuses.pendingApproval)
        .snapshots()
        .map(_parseSnapshot);
  }

  Stream<CleanupProofModel?> watchCleanupProofForEvent(String cleanupEventId) {
    if (cleanupEventId.trim().isEmpty) return Stream.value(null);
    return _proofRef(cleanupEventId).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      try {
        return CleanupProofModel.fromFirestore(snapshot);
      } on Object {
        return null;
      }
    });
  }

  Stream<CleanupEventModel?> watchCleanupEvent(String eventId) {
    if (eventId.trim().isEmpty) return Stream.value(null);
    return _firestore
        .collection(FirestorePaths.cleanupEvents)
        .doc(eventId)
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists) return null;
          return _parseEvent(snapshot);
        });
  }

  Stream<List<CleanupEventModel>> watchUserJoinedEvents(String userId) {
    if (userId.trim().isEmpty) return Stream.value(const []);
    return _firestore
        .collection(FirestorePaths.cleanupEvents)
        .where('participantIds', arrayContains: userId)
        .snapshots()
        .map(_parseSnapshot);
  }

  Stream<List<CleanupEventModel>> watchUserCreatedEvents(String userId) {
    if (userId.trim().isEmpty) return Stream.value(const []);
    return _firestore
        .collection(FirestorePaths.cleanupEvents)
        .where('createdByUserId', isEqualTo: userId)
        .snapshots()
        .map(_parseSnapshot);
  }

  Future<void> joinEvent({
    required String eventId,
    required String userId,
  }) async {
    final normalizedUserId = userId.trim();
    if (eventId.trim().isEmpty || normalizedUserId.isEmpty) {
      throw const CleanupEventRepositoryException('Etkinlik bilgisi eksik.');
    }

    final eventRef = _firestore
        .collection(FirestorePaths.cleanupEvents)
        .doc(eventId);

    await _firestore.runTransaction((transaction) async {
      final eventSnapshot = await transaction.get(eventRef);
      final event = _eventFromSnapshot(eventSnapshot);
      if (event.status == CleanupEventStatuses.completed ||
          event.status == CleanupEventStatuses.pendingApproval ||
          event.status == CleanupEventStatuses.cancelled) {
        throw const CleanupEventRepositoryException(
          'Bu etkinliğe katılım kapalı.',
        );
      }

      final participantIds = event.participantIds.toSet();
      if (participantIds.contains(normalizedUserId)) return;
      if (participantIds.length >= event.maxParticipants) {
        throw const CleanupEventRepositoryException(
          'Etkinlik kontenjanı dolu.',
        );
      }

      participantIds.add(normalizedUserId);
      final updatedIds = participantIds.toList()..sort();
      final now = DateTime.now();
      transaction.update(eventRef, {
        'participantIds': updatedIds,
        'participantCount': updatedIds.length,
        'updatedAt': now,
      });
      transaction.update(_dirtyAreaRef(event.dirtyAreaId), {
        'participantCount': updatedIds.length,
        'updatedAt': now,
      });
    });
  }

  Future<void> leaveEvent({
    required String eventId,
    required String userId,
  }) async {
    final normalizedUserId = userId.trim();
    if (eventId.trim().isEmpty || normalizedUserId.isEmpty) {
      throw const CleanupEventRepositoryException('Etkinlik bilgisi eksik.');
    }

    final eventRef = _firestore
        .collection(FirestorePaths.cleanupEvents)
        .doc(eventId);

    await _firestore.runTransaction((transaction) async {
      final eventSnapshot = await transaction.get(eventRef);
      final event = _eventFromSnapshot(eventSnapshot);
      if (event.status == CleanupEventStatuses.completed ||
          event.status == CleanupEventStatuses.pendingApproval ||
          event.status == CleanupEventStatuses.cancelled) {
        throw const CleanupEventRepositoryException(
          'Bu etkinlikten ayrılma kapalı.',
        );
      }

      final participantIds = event.participantIds.toSet();
      if (!participantIds.remove(normalizedUserId)) return;

      final updatedIds = participantIds.toList()..sort();
      final now = DateTime.now();
      transaction.update(eventRef, {
        'participantIds': updatedIds,
        'participantCount': updatedIds.length,
        'updatedAt': now,
      });
      transaction.update(_dirtyAreaRef(event.dirtyAreaId), {
        'participantCount': updatedIds.length,
        'updatedAt': now,
      });
    });
  }

  Future<void> updateStatus({
    required String eventId,
    required String status,
  }) async {
    if (eventId.trim().isEmpty) {
      throw const CleanupEventRepositoryException('Etkinlik bilgisi eksik.');
    }
    if (!CleanupEventStatuses.values.contains(status)) {
      throw const CleanupEventRepositoryException('Geçersiz durum değeri.');
    }

    await _firestore
        .collection(FirestorePaths.cleanupEvents)
        .doc(eventId)
        .update({'status': status, 'updatedAt': DateTime.now()});
  }

  DocumentReference<Map<String, dynamic>> _dirtyAreaRef(String dirtyAreaId) {
    return _firestore.collection(FirestorePaths.dirtyAreas).doc(dirtyAreaId);
  }

  DocumentReference<Map<String, dynamic>> _eventRef(String cleanupEventId) {
    if (cleanupEventId.trim().isEmpty) {
      throw const CleanupEventRepositoryException('Etkinlik bilgisi eksik.');
    }
    return _firestore
        .collection(FirestorePaths.cleanupEvents)
        .doc(cleanupEventId);
  }

  DocumentReference<Map<String, dynamic>> _proofRef(String cleanupEventId) {
    if (cleanupEventId.trim().isEmpty) {
      throw const CleanupEventRepositoryException('Kanıt bilgisi eksik.');
    }
    return _firestore
        .collection(FirestorePaths.cleanupProofs)
        .doc(cleanupEventId);
  }

  Future<void> _ensureAdmin({
    required Transaction transaction,
    required String adminUserId,
  }) async {
    final normalizedAdminId = adminUserId.trim();
    if (normalizedAdminId.isEmpty) {
      throw const CleanupEventRepositoryException('Admin bilgisi eksik.');
    }
    final adminSnapshot = await transaction.get(
      _firestore.collection(FirestorePaths.users).doc(normalizedAdminId),
    );
    final role = adminSnapshot.data()?['role'] as String?;
    if (role != 'admin') {
      throw const CleanupEventRepositoryException(
        'Bu işlem için admin yetkisi gerekiyor.',
      );
    }
  }

  CleanupEventModel _eventFromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    if (!snapshot.exists) {
      throw const CleanupEventRepositoryException('Etkinlik bulunamadı.');
    }
    final event = _parseEvent(snapshot);
    if (event == null) {
      throw const CleanupEventRepositoryException('Etkinlik okunamadı.');
    }
    return event;
  }

  List<CleanupEventModel> _parseSnapshot(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    return snapshot.docs
        .map(_parseEvent)
        .whereType<CleanupEventModel>()
        .toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
  }

  CleanupEventModel? _parseEvent(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    try {
      return CleanupEventModel.fromFirestore(snapshot);
    } on Object {
      return null;
    }
  }

  void _validateBaseEvent(CleanupEventModel cleanupEvent) {
    if (cleanupEvent.dirtyAreaId.trim().isEmpty) {
      throw const CleanupEventRepositoryException('Kirli bölge bilgisi eksik.');
    }
    if (cleanupEvent.createdByUserId.trim().isEmpty) {
      throw const CleanupEventRepositoryException(
        'Temizlik etkinliği oluşturmak için giriş yapmalısın.',
      );
    }
    if (cleanupEvent.title.trim().isEmpty) {
      throw const CleanupEventRepositoryException('Başlık boş olamaz.');
    }
    if (cleanupEvent.description.trim().isEmpty) {
      throw const CleanupEventRepositoryException('Açıklama boş olamaz.');
    }
    if (cleanupEvent.meetingPointText.trim().isEmpty) {
      throw const CleanupEventRepositoryException(
        'Buluşma noktası boş olamaz.',
      );
    }
    if (cleanupEvent.maxParticipants < 2) {
      throw const CleanupEventRepositoryException(
        'Maksimum katılımcı en az 2 olmalı.',
      );
    }
    if (cleanupEvent.scheduledAt.isBefore(DateTime.now())) {
      throw const CleanupEventRepositoryException(
        'Etkinlik tarihi geçmişte olamaz.',
      );
    }
  }

  String? _nullableTrimmed(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }
}

class CleanupEventRepositoryException implements Exception {
  const CleanupEventRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}

int _intFromValue(Object? value) {
  if (value is int) return value;
  if (value is double) return value.round();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}
