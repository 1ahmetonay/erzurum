import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/constants/firestore_paths.dart';
import '../models/cleanup_event_model.dart';
import '../models/cleanup_group_model.dart';
import '../models/dirty_area_model.dart';
import '../models/group_invitation_model.dart';
import '../models/user_connection_model.dart';

class SocialDemoSeedService {
  SocialDemoSeedService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  Future<SocialDemoSeedResult> seedSocialDemoData() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw const SocialDemoSeedException(
        'Demo sosyal veri yüklemek için giriş yapmalısın.',
      );
    }

    final username = await _currentUsername(currentUser);
    final now = DateTime.now();
    final event = await _findOrCreateCleanupEvent(
      currentUser: currentUser,
      username: username,
      now: now,
    );
    final groupDadasId = _groupDadasId(event.id);
    final groupPalandokenId = _groupPalandokenId(event.id);

    final batch = _firestore.batch();
    _writeDemoUsers(batch, now);
    _writeDemoConnections(batch, currentUser.uid, username, now);
    _writeDemoGroups(
      batch: batch,
      cleanupEvent: event,
      currentUserId: currentUser.uid,
      currentUsername: username,
      groupDadasId: groupDadasId,
      groupPalandokenId: groupPalandokenId,
      now: now,
    );
    _writeDemoInvitations(
      batch: batch,
      cleanupEvent: event,
      currentUserId: currentUser.uid,
      currentUsername: username,
      groupDadasId: groupDadasId,
      groupPalandokenId: groupPalandokenId,
      now: now,
    );
    await batch.commit();

    return SocialDemoSeedResult(
      cleanupEventId: event.id,
      cleanupGroupIds: [groupDadasId, groupPalandokenId],
    );
  }

  Future<void> clearSocialDemoData() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw const SocialDemoSeedException(
        'Demo sosyal verileri temizlemek için giriş yapmalısın.',
      );
    }

    final event = await _findDemoRelatedCleanupEvent();
    final batch = _firestore.batch();
    for (final connectionId in _connectionIds(currentUser.uid)) {
      batch.delete(_connectionRef(connectionId));
    }

    if (event != null) {
      final groupDadasId = _groupDadasId(event.id);
      final groupPalandokenId = _groupPalandokenId(event.id);
      batch.delete(_groupRef(groupDadasId));
      batch.delete(_groupRef(groupPalandokenId));
      for (final invitationId in _invitationIds(currentUser.uid, event.id)) {
        batch.delete(_invitationRef(invitationId));
      }
    }

    await _deleteDemoInvitationsFromQuery(
      batch,
      await _firestore
          .collection(FirestorePaths.groupInvitations)
          .where('invitedUserId', isEqualTo: currentUser.uid)
          .get(),
    );
    await _deleteDemoInvitationsFromQuery(
      batch,
      await _firestore
          .collection(FirestorePaths.groupInvitations)
          .where('invitedByUserId', isEqualTo: currentUser.uid)
          .get(),
    );
    await batch.commit();
  }

  Future<String> _currentUsername(User currentUser) async {
    final snapshot = await _firestore
        .collection(FirestorePaths.users)
        .doc(currentUser.uid)
        .get();
    final data = snapshot.data();
    final displayName = data?['displayName'] as String?;
    if (displayName != null && displayName.trim().isNotEmpty) {
      return displayName.trim();
    }
    if (currentUser.displayName != null &&
        currentUser.displayName!.trim().isNotEmpty) {
      return currentUser.displayName!.trim();
    }
    if (currentUser.email != null && currentUser.email!.trim().isNotEmpty) {
      return currentUser.email!.trim();
    }
    return 'AtıkAvı Üyesi';
  }

  Future<CleanupEventModel> _findOrCreateCleanupEvent({
    required User currentUser,
    required String username,
    required DateTime now,
  }) async {
    final planned = await _firestore
        .collection(FirestorePaths.cleanupEvents)
        .where('status', isEqualTo: CleanupEventStatuses.planned)
        .limit(1)
        .get();
    if (planned.docs.isNotEmpty) {
      return CleanupEventModel.fromFirestore(planned.docs.first);
    }

    final any = await _firestore
        .collection(FirestorePaths.cleanupEvents)
        .limit(1)
        .get();
    if (any.docs.isNotEmpty) {
      return CleanupEventModel.fromFirestore(any.docs.first);
    }

    final dirtyAreaId = 'demo_dirty_area_social_${currentUser.uid}';
    final cleanupEventId = 'demo_cleanup_event_social_${currentUser.uid}';
    final dirtyArea = DirtyAreaModel(
      id: dirtyAreaId,
      title: 'Yakutiye Parkı Atık Yoğunluğu',
      description:
          'Park çevresinde plastik şişe, ambalaj ve karışık atık yoğunluğu bildirildi.',
      reportedByUserId: currentUser.uid,
      reportedByUsername: username,
      latitude: 39.9055,
      longitude: 41.2658,
      addressText: 'Yakutiye, Erzurum',
      wasteTypes: const [
        DirtyAreaWasteTypes.plastic,
        DirtyAreaWasteTypes.paper,
        DirtyAreaWasteTypes.mixed,
      ],
      severityLevel: 4,
      status: DirtyAreaStatuses.planned,
      participantCount: 3,
      createdAt: now,
      updatedAt: now,
    );
    final cleanupEvent = CleanupEventModel(
      id: cleanupEventId,
      dirtyAreaId: dirtyAreaId,
      title: 'Yakutiye Parkı Temizlik Buluşması',
      description:
          'Arkadaşlarla birlikte park çevresindeki atıkları toplayacağız.',
      createdByUserId: currentUser.uid,
      createdByUsername: username,
      meetingPointText: 'Yakutiye Kent Meydanı girişi',
      scheduledAt: now.add(const Duration(days: 2)),
      status: CleanupEventStatuses.planned,
      maxParticipants: 15,
      participantCount: 3,
      participantIds: [
        currentUser.uid,
        _DemoUsers.ayse.uid,
        _DemoUsers.mehmet.uid,
      ],
      createdAt: now,
      updatedAt: now,
    );

    final batch = _firestore.batch();
    batch.set(
      _firestore.collection(FirestorePaths.dirtyAreas).doc(dirtyAreaId),
      dirtyArea.toFirestore(),
      SetOptions(merge: true),
    );
    batch.set(
      _firestore.collection(FirestorePaths.cleanupEvents).doc(cleanupEventId),
      cleanupEvent.toFirestore(),
      SetOptions(merge: true),
    );
    await batch.commit();
    return cleanupEvent;
  }

  Future<CleanupEventModel?> _findDemoRelatedCleanupEvent() async {
    final socialDemo = await _firestore
        .collection(FirestorePaths.cleanupEvents)
        .where('title', isEqualTo: 'Yakutiye Parkı Temizlik Buluşması')
        .limit(1)
        .get();
    if (socialDemo.docs.isNotEmpty) {
      return CleanupEventModel.fromFirestore(socialDemo.docs.first);
    }

    final group = await _firestore
        .collection(FirestorePaths.cleanupGroups)
        .where('name', isEqualTo: 'Dadaş Temizlik Ekibi')
        .limit(1)
        .get();
    if (group.docs.isEmpty) return null;
    final cleanupEventId = CleanupGroupModel.fromFirestore(
      group.docs.first,
    ).cleanupEventId;
    final eventSnapshot = await _firestore
        .collection(FirestorePaths.cleanupEvents)
        .doc(cleanupEventId)
        .get();
    return eventSnapshot.exists
        ? CleanupEventModel.fromFirestore(eventSnapshot)
        : null;
  }

  void _writeDemoUsers(WriteBatch batch, DateTime now) {
    for (final user in _DemoUsers.values) {
      batch.set(
        _firestore.collection(FirestorePaths.users).doc(user.uid),
        {
          'uid': user.uid,
          'username': user.username,
          'displayName': user.displayName,
          'email': user.email,
          'photoUrl': null,
          'totalPoints': user.totalPoints,
          'weeklyPoints': user.weeklyPoints,
          'neighborhood': 'Erzurum',
          'schoolOrCampus': null,
          'role': 'user',
          'badges': const <String>[],
          'level': 1,
          'createdAt': now,
          'updatedAt': now,
          'preferences': const <String, dynamic>{},
        },
        SetOptions(merge: true),
      );
    }
  }

  void _writeDemoConnections(
    WriteBatch batch,
    String currentUserId,
    String currentUsername,
    DateTime now,
  ) {
    final records = [
      UserConnectionModel(
        id: _connectionAyseId(currentUserId),
        requesterUserId: currentUserId,
        requesterUsername: currentUsername,
        receiverUserId: _DemoUsers.ayse.uid,
        receiverUsername: _DemoUsers.ayse.username,
        status: UserConnectionStatuses.accepted,
        createdAt: now,
        updatedAt: now,
      ),
      UserConnectionModel(
        id: _connectionMehmetId(currentUserId),
        requesterUserId: _DemoUsers.mehmet.uid,
        requesterUsername: _DemoUsers.mehmet.username,
        receiverUserId: currentUserId,
        receiverUsername: currentUsername,
        status: UserConnectionStatuses.accepted,
        createdAt: now,
        updatedAt: now,
      ),
      UserConnectionModel(
        id: _connectionZeynepId(currentUserId),
        requesterUserId: _DemoUsers.zeynep.uid,
        requesterUsername: _DemoUsers.zeynep.username,
        receiverUserId: currentUserId,
        receiverUsername: currentUsername,
        status: UserConnectionStatuses.pending,
        createdAt: now,
        updatedAt: now,
      ),
      UserConnectionModel(
        id: _connectionEmirId(currentUserId),
        requesterUserId: currentUserId,
        requesterUsername: currentUsername,
        receiverUserId: _DemoUsers.emir.uid,
        receiverUsername: _DemoUsers.emir.username,
        status: UserConnectionStatuses.pending,
        createdAt: now,
        updatedAt: now,
      ),
      UserConnectionModel(
        id: _connectionElifsuId(currentUserId),
        requesterUserId: _DemoUsers.elifsu.uid,
        requesterUsername: _DemoUsers.elifsu.username,
        receiverUserId: currentUserId,
        receiverUsername: currentUsername,
        status: UserConnectionStatuses.rejected,
        createdAt: now,
        updatedAt: now,
      ),
    ];

    for (final record in records) {
      batch.set(
        _connectionRef(record.id),
        record.toFirestore(),
        SetOptions(merge: true),
      );
    }
  }

  void _writeDemoGroups({
    required WriteBatch batch,
    required CleanupEventModel cleanupEvent,
    required String currentUserId,
    required String currentUsername,
    required String groupDadasId,
    required String groupPalandokenId,
    required DateTime now,
  }) {
    final groups = [
      CleanupGroupModel(
        id: groupDadasId,
        cleanupEventId: cleanupEvent.id,
        dirtyAreaId: cleanupEvent.dirtyAreaId,
        name: 'Dadaş Temizlik Ekibi',
        description:
            'Yakutiye bölgesindeki atıkları birlikte toplayacak gönüllü ekip.',
        createdByUserId: currentUserId,
        createdByUsername: currentUsername,
        memberIds: [currentUserId, _DemoUsers.ayse.uid, _DemoUsers.mehmet.uid],
        memberCount: 3,
        maxMembers: 5,
        status: CleanupGroupStatuses.active,
        createdAt: now,
        updatedAt: now,
      ),
      CleanupGroupModel(
        id: groupPalandokenId,
        cleanupEventId: cleanupEvent.id,
        dirtyAreaId: cleanupEvent.dirtyAreaId,
        name: 'Palandöken Gönüllüleri',
        description: 'Hafta sonu temizlik etkinliği için küçük gönüllü grup.',
        createdByUserId: _DemoUsers.zeynep.uid,
        createdByUsername: _DemoUsers.zeynep.username,
        memberIds: [_DemoUsers.zeynep.uid, _DemoUsers.emir.uid],
        memberCount: 2,
        maxMembers: 4,
        status: CleanupGroupStatuses.active,
        createdAt: now,
        updatedAt: now,
      ),
    ];

    for (final group in groups) {
      batch.set(
        _groupRef(group.id),
        group.toFirestore(),
        SetOptions(merge: true),
      );
    }
  }

  void _writeDemoInvitations({
    required WriteBatch batch,
    required CleanupEventModel cleanupEvent,
    required String currentUserId,
    required String currentUsername,
    required String groupDadasId,
    required String groupPalandokenId,
    required DateTime now,
  }) {
    final invitations = [
      GroupInvitationModel(
        id: _inviteZeynepId(currentUserId, cleanupEvent.id),
        cleanupGroupId: groupPalandokenId,
        cleanupEventId: cleanupEvent.id,
        dirtyAreaId: cleanupEvent.dirtyAreaId,
        invitedByUserId: _DemoUsers.zeynep.uid,
        invitedByUsername: _DemoUsers.zeynep.username,
        invitedUserId: currentUserId,
        invitedUsername: currentUsername,
        status: GroupInvitationStatuses.pending,
        createdAt: now,
        updatedAt: now,
      ),
      GroupInvitationModel(
        id: _inviteElifsuId(currentUserId, cleanupEvent.id),
        cleanupGroupId: groupDadasId,
        cleanupEventId: cleanupEvent.id,
        dirtyAreaId: cleanupEvent.dirtyAreaId,
        invitedByUserId: currentUserId,
        invitedByUsername: currentUsername,
        invitedUserId: _DemoUsers.elifsu.uid,
        invitedUsername: _DemoUsers.elifsu.username,
        status: GroupInvitationStatuses.pending,
        createdAt: now,
        updatedAt: now,
      ),
      GroupInvitationModel(
        id: _inviteAyseId(currentUserId, cleanupEvent.id),
        cleanupGroupId: groupDadasId,
        cleanupEventId: cleanupEvent.id,
        dirtyAreaId: cleanupEvent.dirtyAreaId,
        invitedByUserId: currentUserId,
        invitedByUsername: currentUsername,
        invitedUserId: _DemoUsers.ayse.uid,
        invitedUsername: _DemoUsers.ayse.username,
        status: GroupInvitationStatuses.accepted,
        createdAt: now,
        updatedAt: now,
      ),
    ];

    for (final invitation in invitations) {
      batch.set(
        _invitationRef(invitation.id),
        invitation.toFirestore(),
        SetOptions(merge: true),
      );
    }
  }

  Future<void> _deleteDemoInvitationsFromQuery(
    WriteBatch batch,
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) async {
    for (final doc in snapshot.docs) {
      if (doc.id.startsWith('demo_invite_')) {
        batch.delete(doc.reference);
      }
    }
  }

  List<String> _connectionIds(String currentUserId) {
    return [
      _connectionAyseId(currentUserId),
      _connectionMehmetId(currentUserId),
      _connectionZeynepId(currentUserId),
      _connectionEmirId(currentUserId),
      _connectionElifsuId(currentUserId),
    ];
  }

  List<String> _invitationIds(String currentUserId, String cleanupEventId) {
    return [
      _inviteZeynepId(currentUserId, cleanupEventId),
      _inviteElifsuId(currentUserId, cleanupEventId),
      _inviteAyseId(currentUserId, cleanupEventId),
    ];
  }

  DocumentReference<Map<String, dynamic>> _connectionRef(String id) =>
      _firestore.collection(FirestorePaths.userConnections).doc(id);
  DocumentReference<Map<String, dynamic>> _groupRef(String id) =>
      _firestore.collection(FirestorePaths.cleanupGroups).doc(id);
  DocumentReference<Map<String, dynamic>> _invitationRef(String id) =>
      _firestore.collection(FirestorePaths.groupInvitations).doc(id);

  String _connectionAyseId(String currentUserId) =>
      'demo_connection_${currentUserId}_ayse';
  String _connectionMehmetId(String currentUserId) =>
      'demo_connection_mehmet_$currentUserId';
  String _connectionZeynepId(String currentUserId) =>
      'demo_connection_zeynep_$currentUserId';
  String _connectionEmirId(String currentUserId) =>
      'demo_connection_${currentUserId}_emir';
  String _connectionElifsuId(String currentUserId) =>
      'demo_connection_elifsu_$currentUserId';
  String _groupDadasId(String cleanupEventId) =>
      'demo_group_dadas_$cleanupEventId';
  String _groupPalandokenId(String cleanupEventId) =>
      'demo_group_palandoken_$cleanupEventId';
  String _inviteZeynepId(String currentUserId, String cleanupEventId) =>
      'demo_invite_zeynep_${currentUserId}_$cleanupEventId';
  String _inviteElifsuId(String currentUserId, String cleanupEventId) =>
      'demo_invite_${currentUserId}_elifsu_$cleanupEventId';
  String _inviteAyseId(String currentUserId, String cleanupEventId) =>
      'demo_invite_${currentUserId}_ayse_$cleanupEventId';
}

class SocialDemoSeedResult {
  const SocialDemoSeedResult({
    required this.cleanupEventId,
    required this.cleanupGroupIds,
  });

  final String cleanupEventId;
  final List<String> cleanupGroupIds;
}

class SocialDemoSeedException implements Exception {
  const SocialDemoSeedException(this.message);

  final String message;

  @override
  String toString() => message;
}

class _DemoUsers {
  const _DemoUsers({
    required this.uid,
    required this.username,
    required this.displayName,
    required this.email,
    required this.totalPoints,
    required this.weeklyPoints,
  });

  final String uid;
  final String username;
  final String displayName;
  final String email;
  final int totalPoints;
  final int weeklyPoints;

  static const ayse = _DemoUsers(
    uid: 'demo_user_ayse',
    username: 'Ayşe',
    displayName: 'Ayşe Yıldırım',
    email: 'ayse.demo@atikavi.local',
    totalPoints: 420,
    weeklyPoints: 80,
  );
  static const mehmet = _DemoUsers(
    uid: 'demo_user_mehmet',
    username: 'Mehmet',
    displayName: 'Mehmet Demir',
    email: 'mehmet.demo@atikavi.local',
    totalPoints: 310,
    weeklyPoints: 45,
  );
  static const zeynep = _DemoUsers(
    uid: 'demo_user_zeynep',
    username: 'Zeynep',
    displayName: 'Zeynep Kaya',
    email: 'zeynep.demo@atikavi.local',
    totalPoints: 560,
    weeklyPoints: 120,
  );
  static const emir = _DemoUsers(
    uid: 'demo_user_emir',
    username: 'Emir',
    displayName: 'Emir Çelik',
    email: 'emir.demo@atikavi.local',
    totalPoints: 150,
    weeklyPoints: 30,
  );
  static const elifsu = _DemoUsers(
    uid: 'demo_user_elifsu',
    username: 'Elifsu',
    displayName: 'Elifsu Arslan',
    email: 'elifsu.demo@atikavi.local',
    totalPoints: 270,
    weeklyPoints: 60,
  );

  static const values = [ayse, mehmet, zeynep, emir, elifsu];
}
