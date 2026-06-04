class ScanResultModel {
  const ScanResultModel({
    required this.wasteLogId,
    required this.pointsEarned,
    required this.bonusPoints,
    required this.completedTaskTitles,
    required this.message,
    this.isPhotoPending = false,
  });

  final String? wasteLogId;
  final int pointsEarned;
  final int bonusPoints;
  final List<String> completedTaskTitles;
  final String message;
  final bool isPhotoPending;

  int get totalPointsEarned => pointsEarned + bonusPoints;

  bool get hasCompletedTasks => completedTaskTitles.isNotEmpty;
}
