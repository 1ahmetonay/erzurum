class FirestorePaths {
  const FirestorePaths._();

  static const users = 'users';
  static const wasteLogs = 'waste_logs';
  static const recyclingPoints = 'recycling_points';
  static const tasks = 'tasks';
  static const rewards = 'rewards';
  static const redemptions = 'redemptions';
  static const pointReports = 'point_reports';
  static const dirtyAreas = 'dirty_areas';
  static const cleanupEvents = 'cleanup_events';
  static const cleanupProofs = 'cleanup_proofs';
  static const userConnections = 'user_connections';
  static const cleanupGroups = 'cleanup_groups';
  static const groupInvitations = 'group_invitations';
  static const leaderboard = 'leaderboard';

  static String user(String uid) => '$users/$uid';
  static String userTaskProgress(String userId) =>
      '$users/$userId/task_progress';
  static String userTaskProgressDoc(String userId, String taskId) =>
      '$users/$userId/task_progress/$taskId';
  static String wasteLog(String id) => '$wasteLogs/$id';
  static String userWasteLogsQuery(String uid) => '$wasteLogs?userId=$uid';
  static String recyclingPoint(String id) => '$recyclingPoints/$id';
  static String task(String id) => '$tasks/$id';
  static String reward(String id) => '$rewards/$id';
  static String redemption(String id) => '$redemptions/$id';
  static String userRedemptionsQuery(String userId) =>
      '$redemptions?userId=$userId';
  static String pointReport(String id) => '$pointReports/$id';
  static String userPointReports(String userId) =>
      '$pointReports?userId=$userId';
  static String pointReportsByPoint(String pointId) =>
      '$pointReports?pointId=$pointId';
  static String dirtyArea(String id) => '$dirtyAreas/$id';
  static String userDirtyAreas(String userId) =>
      '$dirtyAreas?reportedByUserId=$userId';
  static String cleanupEvent(String id) => '$cleanupEvents/$id';
  static String cleanupEventsByDirtyArea(String dirtyAreaId) =>
      '$cleanupEvents?dirtyAreaId=$dirtyAreaId';
  static String userCleanupEvents(String userId) =>
      '$cleanupEvents?participantIds=$userId';
  static String cleanupProof(String id) => '$cleanupProofs/$id';
  static String cleanupProofsByEvent(String cleanupEventId) =>
      '$cleanupProofs?cleanupEventId=$cleanupEventId';
  static String userConnection(String id) => '$userConnections/$id';
  static String cleanupGroup(String id) => '$cleanupGroups/$id';
  static String groupInvitation(String id) => '$groupInvitations/$id';
  static String leaderboardCategory(String category) =>
      '$leaderboard/$category';
  static String leaderboardEntries(String category) =>
      '$leaderboard/$category/entries';
  static String leaderboardEntry(String category, String id) =>
      '$leaderboard/$category/entries/$id';
}
