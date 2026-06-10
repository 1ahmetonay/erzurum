import '../../models/cleanup_group_model.dart';
import '../../models/group_invitation_model.dart';
import '../../models/user_connection_model.dart';

class SocialDemoData {
  const SocialDemoData._();

  static const idPrefix = 'local_demo_';

  static bool isDemoId(String id) => id.startsWith(idPrefix);

  static List<UserConnectionModel> acceptedConnections(String currentUserId) {
    final now = DateTime(2026, 1, 1);
    return [
      UserConnectionModel(
        id: '${idPrefix}connection_ayse',
        requesterUserId: currentUserId,
        requesterUsername: 'AtıkAvı Üyesi',
        receiverUserId: '${idPrefix}user_ayse',
        receiverUsername: 'Ayşe Yılmaz',
        status: UserConnectionStatuses.accepted,
        createdAt: now,
        updatedAt: now,
      ),
      UserConnectionModel(
        id: '${idPrefix}connection_mehmet',
        requesterUserId: '${idPrefix}user_mehmet',
        requesterUsername: 'Mehmet Kaya',
        receiverUserId: currentUserId,
        receiverUsername: 'AtıkAvı Üyesi',
        status: UserConnectionStatuses.accepted,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  static List<UserConnectionModel> incomingRequests(String currentUserId) {
    final now = DateTime(2026, 1, 2);
    return [
      UserConnectionModel(
        id: '${idPrefix}request_zeynep',
        requesterUserId: '${idPrefix}user_zeynep',
        requesterUsername: 'Zeynep Demir',
        receiverUserId: currentUserId,
        receiverUsername: 'AtıkAvı Üyesi',
        status: UserConnectionStatuses.pending,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  static List<UserConnectionModel> outgoingRequests(String currentUserId) {
    final now = DateTime(2026, 1, 3);
    return [
      UserConnectionModel(
        id: '${idPrefix}request_emir',
        requesterUserId: currentUserId,
        requesterUsername: 'AtıkAvı Üyesi',
        receiverUserId: '${idPrefix}user_emir',
        receiverUsername: 'Emir Can',
        status: UserConnectionStatuses.pending,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  static List<CleanupGroupModel> groupsForEvent(
    String eventId,
    String currentUserId,
  ) {
    final now = DateTime(2026, 1, 4);
    return [
      CleanupGroupModel(
        id: '${idPrefix}group_dadas_$eventId',
        cleanupEventId: eventId,
        dirtyAreaId: '${idPrefix}dirty_area',
        name: 'Dadaş Temizlik Ekibi',
        description: 'Yakutiye çevresinde birlikte temizlik yapan demo ekip.',
        createdByUserId: currentUserId,
        createdByUsername: 'AtıkAvı Üyesi',
        memberIds: [
          currentUserId,
          '${idPrefix}user_ayse',
          '${idPrefix}user_mehmet',
        ],
        memberCount: 3,
        maxMembers: 8,
        status: CleanupGroupStatuses.active,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  static CleanupGroupModel? groupById(String groupId, String currentUserId) {
    if (!isDemoId(groupId)) return null;
    final eventId = groupId.replaceFirst('${idPrefix}group_dadas_', '');
    return groupsForEvent(eventId, currentUserId).first;
  }

  static List<GroupInvitationModel> incomingInvitations(String currentUserId) {
    final now = DateTime(2026, 1, 5);
    return [
      GroupInvitationModel(
        id: '${idPrefix}invitation_palandoken',
        cleanupGroupId: '${idPrefix}group_palandoken',
        cleanupEventId: 'Palandöken Temizlik Buluşması',
        dirtyAreaId: '${idPrefix}dirty_area_palandoken',
        invitedByUserId: '${idPrefix}user_ayse',
        invitedByUsername: 'Ayşe Yılmaz',
        invitedUserId: currentUserId,
        invitedUsername: 'AtıkAvı Üyesi',
        status: GroupInvitationStatuses.pending,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }
}
