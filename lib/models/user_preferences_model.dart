class UserPreferencesModel {
  const UserPreferencesModel({
    this.notificationsEnabled = true,
    this.taskRemindersEnabled = true,
    this.rewardNotificationsEnabled = true,
    this.nearbyPointsEnabled = true,
    this.defaultDistrict = 'Yakutiye',
    this.showOnLeaderboard = true,
    this.showProfilePhoto = true,
    this.themeMode = 'system',
  });

  final bool notificationsEnabled;
  final bool taskRemindersEnabled;
  final bool rewardNotificationsEnabled;
  final bool nearbyPointsEnabled;
  final String defaultDistrict;
  final bool showOnLeaderboard;
  final bool showProfilePhoto;
  final String themeMode;

  factory UserPreferencesModel.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const UserPreferencesModel();
    return UserPreferencesModel(
      notificationsEnabled: map['notificationsEnabled'] as bool? ?? true,
      taskRemindersEnabled: map['taskRemindersEnabled'] as bool? ?? true,
      rewardNotificationsEnabled:
          map['rewardNotificationsEnabled'] as bool? ?? true,
      nearbyPointsEnabled: map['nearbyPointsEnabled'] as bool? ?? true,
      defaultDistrict: _allowedDistrict(map['defaultDistrict'] as String?),
      showOnLeaderboard: map['showOnLeaderboard'] as bool? ?? true,
      showProfilePhoto: map['showProfilePhoto'] as bool? ?? true,
      themeMode: _allowedThemeMode(map['themeMode'] as String?),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'notificationsEnabled': notificationsEnabled,
      'taskRemindersEnabled': taskRemindersEnabled,
      'rewardNotificationsEnabled': rewardNotificationsEnabled,
      'nearbyPointsEnabled': nearbyPointsEnabled,
      'defaultDistrict': defaultDistrict,
      'showOnLeaderboard': showOnLeaderboard,
      'showProfilePhoto': showProfilePhoto,
      'themeMode': themeMode,
    };
  }

  UserPreferencesModel copyWith({
    bool? notificationsEnabled,
    bool? taskRemindersEnabled,
    bool? rewardNotificationsEnabled,
    bool? nearbyPointsEnabled,
    String? defaultDistrict,
    bool? showOnLeaderboard,
    bool? showProfilePhoto,
    String? themeMode,
  }) {
    return UserPreferencesModel(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      taskRemindersEnabled: taskRemindersEnabled ?? this.taskRemindersEnabled,
      rewardNotificationsEnabled:
          rewardNotificationsEnabled ?? this.rewardNotificationsEnabled,
      nearbyPointsEnabled: nearbyPointsEnabled ?? this.nearbyPointsEnabled,
      defaultDistrict: defaultDistrict ?? this.defaultDistrict,
      showOnLeaderboard: showOnLeaderboard ?? this.showOnLeaderboard,
      showProfilePhoto: showProfilePhoto ?? this.showProfilePhoto,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}

String _allowedDistrict(String? value) {
  return switch (value) {
    'Palandöken' || 'Aziziye' || 'Yakutiye' => value!,
    _ => 'Yakutiye',
  };
}

String _allowedThemeMode(String? value) {
  return switch (value) {
    'light' || 'dark' || 'system' => value!,
    _ => 'system',
  };
}
