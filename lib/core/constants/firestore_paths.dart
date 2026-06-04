class FirestorePaths {
  const FirestorePaths._();

  static const users = 'users';
  static const wasteLogs = 'waste_logs';
  static const recyclingPoints = 'recycling_points';
  static const tasks = 'tasks';
  static const rewards = 'rewards';
  static const redemptions = 'redemptions';
  static const pointReports = 'point_reports';
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
  static String leaderboardCategory(String category) =>
      '$leaderboard/$category';
  static String leaderboardEntries(String category) =>
      '$leaderboard/$category/entries';
  static String leaderboardEntry(String category, String id) =>
      '$leaderboard/$category/entries/$id';
}
