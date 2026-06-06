import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin/dev_seed_screen.dart';
import '../../features/auth/auth_screen.dart';
import '../../features/education/education_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/leaderboard/leaderboard_screen.dart';
import '../../features/map/map_screen.dart';
import '../../features/rewards/rewards_screen.dart';
import '../../features/scan/scan_screen.dart';
import '../../features/tasks/tasks_screen.dart';
import '../../providers/auth_provider.dart';
import '../../shared/widgets/app_bottom_nav.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/home',
    redirect: (context, state) {
      final isDevSeedRoute = state.uri.path == '/dev/seed';
      if (!kDebugMode && isDevSeedRoute) return '/home';
      if (kDebugMode && isDevSeedRoute) return null;

      final isAuthRoute = state.matchedLocation == '/auth';

      return authState.when(
        data: (user) {
          if (user == null) return isAuthRoute ? null : '/auth';
          return isAuthRoute ? '/home' : null;
        },
        loading: () => isAuthRoute ? null : '/auth',
        error: (_, _) => isAuthRoute ? null : '/auth',
      );
    },
    routes: [
      GoRoute(path: '/auth', builder: (context, state) => const AuthScreen()),
      if (kDebugMode)
        GoRoute(
          path: '/dev/seed',
          builder: (context, state) => const DevSeedScreen(),
        ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppBottomNav(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/scan',
                builder: (context, state) => const ScanScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/map',
                builder: (context, state) => const MapScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/tasks',
                builder: (context, state) => TasksScreen(
                  initialTaskId: state.uri.queryParameters['taskId'],
                ),
              ),
              GoRoute(
                path: '/education',
                builder: (context, state) => const EducationScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/leaderboard',
                builder: (context, state) => const LeaderboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/rewards',
                builder: (context, state) => const RewardsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
