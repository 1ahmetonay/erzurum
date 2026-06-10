import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin/cleanup_approval_detail_screen.dart';
import '../../features/admin/cleanup_approvals_screen.dart';
import '../../features/admin/admin_users_screen.dart';
import '../../features/admin/dev_seed_screen.dart';
import '../../features/auth/auth_screen.dart';
import '../../features/dirty_areas/cleanup_event_detail_screen.dart';
import '../../features/dirty_areas/cleanup_group_detail_screen.dart';
import '../../features/dirty_areas/complete_cleanup_event_screen.dart';
import '../../features/dirty_areas/create_cleanup_group_screen.dart';
import '../../features/dirty_areas/create_cleanup_event_screen.dart';
import '../../features/dirty_areas/dirty_area_detail_screen.dart';
import '../../features/dirty_areas/dirty_areas_screen.dart';
import '../../features/dirty_areas/report_dirty_area_screen.dart';
import '../../features/education/education_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/leaderboard/leaderboard_screen.dart';
import '../../features/map/map_screen.dart';
import '../../features/rewards/rewards_screen.dart';
import '../../features/scan/scan_screen.dart';
import '../../features/social/friend_requests_screen.dart';
import '../../features/social/friends_screen.dart';
import '../../features/social/group_invitations_screen.dart';
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
      GoRoute(
        path: '/admin/cleanup-approvals',
        builder: (context, state) => const CleanupApprovalsScreen(),
      ),
      GoRoute(
        path: '/admin/cleanup-approvals/:id',
        builder: (context, state) => CleanupApprovalDetailScreen(
          cleanupEventId: state.pathParameters['id'] ?? '',
        ),
      ),
      GoRoute(
        path: '/admin/users',
        builder: (context, state) => const AdminUsersScreen(),
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
              GoRoute(
                path: '/dirty-areas',
                builder: (context, state) => const DirtyAreasScreen(),
              ),
              GoRoute(
                path: '/dirty-areas/:id',
                builder: (context, state) => DirtyAreaDetailScreen(
                  dirtyAreaId: state.pathParameters['id'] ?? '',
                ),
              ),
              GoRoute(
                path: '/dirty-areas/:id/create-cleanup-event',
                builder: (context, state) => CreateCleanupEventScreen(
                  dirtyAreaId: state.pathParameters['id'] ?? '',
                ),
              ),
              GoRoute(
                path: '/cleanup-events/:id',
                builder: (context, state) => CleanupEventDetailScreen(
                  cleanupEventId: state.pathParameters['id'] ?? '',
                ),
              ),
              GoRoute(
                path: '/cleanup-events/:id/complete',
                builder: (context, state) => CompleteCleanupEventScreen(
                  cleanupEventId: state.pathParameters['id'] ?? '',
                ),
              ),
              GoRoute(
                path: '/cleanup-events/:id/create-group',
                builder: (context, state) => CreateCleanupGroupScreen(
                  cleanupEventId: state.pathParameters['id'] ?? '',
                ),
              ),
              GoRoute(
                path: '/cleanup-groups/:id',
                builder: (context, state) => CleanupGroupDetailScreen(
                  cleanupGroupId: state.pathParameters['id'] ?? '',
                ),
              ),
              GoRoute(
                path: '/friends',
                builder: (context, state) => const FriendsScreen(),
              ),
              GoRoute(
                path: '/friend-requests',
                builder: (context, state) => const FriendRequestsScreen(),
              ),
              GoRoute(
                path: '/group-invitations',
                builder: (context, state) => const GroupInvitationsScreen(),
              ),
              GoRoute(
                path: '/report-dirty-area',
                builder: (context, state) => const ReportDirtyAreaScreen(),
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
