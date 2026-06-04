import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/leaderboard_model.dart';
import '../repositories/leaderboard_repository.dart';

final leaderboardRepositoryProvider = Provider<LeaderboardRepository>((ref) {
  return LeaderboardRepository();
});

final leaderboardEntriesProvider =
    StreamProvider.family<List<LeaderboardModel>, String>((ref, category) {
      return ref
          .watch(leaderboardRepositoryProvider)
          .watchLeaderboardEntries(category);
    });
