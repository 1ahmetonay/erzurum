import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/firestore_paths.dart';
import '../models/cleanup_event_model.dart';
import '../models/cleanup_group_model.dart';
import '../models/group_invitation_model.dart';

class CleanupGroupRepository {
  CleanupGroupRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<String> createGroup(CleanupGroupModel group) async {
    if (group.cleanupEventId.trim().isEmpty || group.name.trim().isEmpty) {
      throw const CleanupGroupRepositoryException('Grup bilgisi eksik.');
    }
    final groupRef = _firestore.collection(FirestorePaths.cleanupGroups).doc();
    final eventRef = _eventRef(group.cleanupEventId);
    final now = DateTime.now();

    await _firestore.runTransaction((transaction) async {
      final event = _eventFromSnapshot(await transaction.get(eventRef));
      final memberIds = {group.createdByUserId};
      final participantIds = event.participantIds.toSet()
        ..add(group.createdByUserId);
      final maxMembers = group.maxMembers.clamp(2, 20).toInt();
      final record = group.copyWith(
        id: groupRef.id,
        dirtyAreaId: event.dirtyAreaId,
        memberIds: memberIds.toList()..sort(),
        memberCount: memberIds.length,
        maxMembers: maxMembers,
        status: memberIds.length >= maxMembers
            ? CleanupGroupStatuses.full
            : CleanupGroupStatuses.active,
        createdAt: now,
        updatedAt: now,
      );
      transaction.set(groupRef, record.toFirestore());
      _updateEventParticipants(
        transaction: transaction,
        event: event,
        participantIds: participantIds,
        now: now,
      );
    });

    return groupRef.id;
  }

  Stream<List<CleanupGroupModel>> watchGroupsForEvent(String cleanupEventId) {
    if (cleanupEventId.trim().isEmpty) return Stream.value(const []);
    return _firestore
        .collection(FirestorePaths.cleanupGroups)
        .where('cleanupEventId', isEqualTo: cleanupEventId)
        .snapshots()
        .map(_parseGroups);
  }

  Stream<CleanupGroupModel?> watchGroup(String groupId) {
    if (groupId.trim().isEmpty) return Stream.value(null);
    return _firestore
        .collection(FirestorePaths.cleanupGroups)
        .doc(groupId)
        .snapshots()
        .map(
          (snapshot) => snapshot.exists
              ? CleanupGroupModel.fromFirestore(snapshot)
              : null,
        );
  }

  Stream<List<GroupInvitationModel>> watchIncomingInvitations(String userId) {
    if (userId.trim().isEmpty) return Stream.value(const []);
    return _firestore
        .collection(FirestorePaths.groupInvitations)
        .where('invitedUserId', isEqualTo: userId)
        .where('status', isEqualTo: GroupInvitationStatuses.pending)
        .snapshots()
        .map(_parseInvitations);
  }

  Future<void> joinGroup({
    required String groupId,
    required String userId,
  }) async {
    await _addMemberToGroup(groupId: groupId, userId: userId);
  }

  Future<void> leaveGroup({
    required String groupId,
    required String userId,
  }) async {
    final groupRef = _groupRef(groupId);
    await _firestore.runTransaction((transaction) async {
      final group = _groupFromSnapshot(await transaction.get(groupRef));
      final memberIds = group.memberIds.toSet();
      if (!memberIds.remove(userId)) return;
      final updatedIds = memberIds.toList()..sort();
      transaction.update(groupRef, {
        'memberIds': updatedIds,
        'memberCount': updatedIds.length,
        'status': CleanupGroupStatuses.active,
        'updatedAt': DateTime.now(),
      });
    });
  }

  Future<void> createInvitation({
    required CleanupGroupModel group,
    required String invitedByUserId,
    required String invitedByUsername,
    required String invitedUserId,
    required String invitedUsername,
  }) async {
    if (group.memberIds.contains(invitedUserId)) {
      throw const CleanupGroupRepositoryException('Kullanıcı zaten grupta.');
    }
    final invitationRef = _firestore
        .collection(FirestorePaths.groupInvitations)
        .doc('${group.id}_$invitedUserId');
    final now = DateTime.now();

    await _firestore.runTransaction((transaction) async {
      final existing = await transaction.get(invitationRef);
      if (existing.exists) {
        final invitation = GroupInvitationModel.fromFirestore(existing);
        if (invitation.status == GroupInvitationStatuses.pending) {
          throw const CleanupGroupRepositoryException('Davet zaten bekliyor.');
        }
      }
      transaction.set(
        invitationRef,
        GroupInvitationModel(
          id: invitationRef.id,
          cleanupGroupId: group.id,
          cleanupEventId: group.cleanupEventId,
          dirtyAreaId: group.dirtyAreaId,
          invitedByUserId: invitedByUserId,
          invitedByUsername: invitedByUsername,
          invitedUserId: invitedUserId,
          invitedUsername: invitedUsername,
          status: GroupInvitationStatuses.pending,
          createdAt: now,
          updatedAt: now,
        ).toFirestore(),
      );
    });
  }

  Future<void> acceptInvitation({
    required String invitationId,
    required String userId,
  }) async {
    final invitationRef = _invitationRef(invitationId);
    await _firestore.runTransaction((transaction) async {
      final invitation = _invitationFromSnapshot(
        await transaction.get(invitationRef),
      );
      if (invitation.invitedUserId != userId) {
        throw const CleanupGroupRepositoryException('Bu davet sana ait değil.');
      }
      if (invitation.status != GroupInvitationStatuses.pending) return;
      await _addMemberToGroupInTransaction(
        transaction: transaction,
        groupId: invitation.cleanupGroupId,
        userId: userId,
      );
      transaction.update(invitationRef, {
        'status': GroupInvitationStatuses.accepted,
        'updatedAt': DateTime.now(),
      });
    });
  }

  Future<void> rejectInvitation({
    required String invitationId,
    required String userId,
  }) async {
    final ref = _invitationRef(invitationId);
    await _firestore.runTransaction((transaction) async {
      final invitation = _invitationFromSnapshot(await transaction.get(ref));
      if (invitation.invitedUserId != userId) {
        throw const CleanupGroupRepositoryException('Bu davet sana ait değil.');
      }
      transaction.update(ref, {
        'status': GroupInvitationStatuses.rejected,
        'updatedAt': DateTime.now(),
      });
    });
  }

  Future<void> _addMemberToGroup({
    required String groupId,
    required String userId,
  }) async {
    await _firestore.runTransaction((transaction) async {
      await _addMemberToGroupInTransaction(
        transaction: transaction,
        groupId: groupId,
        userId: userId,
      );
    });
  }

  Future<void> _addMemberToGroupInTransaction({
    required Transaction transaction,
    required String groupId,
    required String userId,
  }) async {
    final groupRef = _groupRef(groupId);
    final group = _groupFromSnapshot(await transaction.get(groupRef));
    if (group.status == CleanupGroupStatuses.cancelled ||
        group.status == CleanupGroupStatuses.completed) {
      throw const CleanupGroupRepositoryException('Bu gruba katılım kapalı.');
    }
    final memberIds = group.memberIds.toSet();
    if (memberIds.contains(userId)) return;
    if (memberIds.length >= group.maxMembers) {
      throw const CleanupGroupRepositoryException('Grup kontenjanı dolu.');
    }
    memberIds.add(userId);
    final updatedMembers = memberIds.toList()..sort();

    final event = _eventFromSnapshot(
      await transaction.get(_eventRef(group.cleanupEventId)),
    );
    final participants = event.participantIds.toSet()..add(userId);
    final now = DateTime.now();
    transaction.update(groupRef, {
      'memberIds': updatedMembers,
      'memberCount': updatedMembers.length,
      'status': updatedMembers.length >= group.maxMembers
          ? CleanupGroupStatuses.full
          : CleanupGroupStatuses.active,
      'updatedAt': now,
    });
    _updateEventParticipants(
      transaction: transaction,
      event: event,
      participantIds: participants,
      now: now,
    );
  }

  void _updateEventParticipants({
    required Transaction transaction,
    required CleanupEventModel event,
    required Set<String> participantIds,
    required DateTime now,
  }) {
    final updated = participantIds.toList()..sort();
    transaction.update(_eventRef(event.id), {
      'participantIds': updated,
      'participantCount': updated.length,
      'updatedAt': now,
    });
    transaction.update(_dirtyAreaRef(event.dirtyAreaId), {
      'participantCount': updated.length,
      'updatedAt': now,
    });
  }

  List<CleanupGroupModel> _parseGroups(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    return snapshot.docs.map(CleanupGroupModel.fromFirestore).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<GroupInvitationModel> _parseInvitations(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    return snapshot.docs.map(GroupInvitationModel.fromFirestore).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  DocumentReference<Map<String, dynamic>> _eventRef(String id) =>
      _firestore.collection(FirestorePaths.cleanupEvents).doc(id);
  DocumentReference<Map<String, dynamic>> _dirtyAreaRef(String id) =>
      _firestore.collection(FirestorePaths.dirtyAreas).doc(id);
  DocumentReference<Map<String, dynamic>> _groupRef(String id) =>
      _firestore.collection(FirestorePaths.cleanupGroups).doc(id);
  DocumentReference<Map<String, dynamic>> _invitationRef(String id) =>
      _firestore.collection(FirestorePaths.groupInvitations).doc(id);

  CleanupEventModel _eventFromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    if (!snapshot.exists) {
      throw const CleanupGroupRepositoryException('Etkinlik bulunamadı.');
    }
    return CleanupEventModel.fromFirestore(snapshot);
  }

  CleanupGroupModel _groupFromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    if (!snapshot.exists) {
      throw const CleanupGroupRepositoryException('Grup bulunamadı.');
    }
    return CleanupGroupModel.fromFirestore(snapshot);
  }

  GroupInvitationModel _invitationFromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    if (!snapshot.exists) {
      throw const CleanupGroupRepositoryException('Davet bulunamadı.');
    }
    return GroupInvitationModel.fromFirestore(snapshot);
  }
}

class CleanupGroupRepositoryException implements Exception {
  const CleanupGroupRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}
