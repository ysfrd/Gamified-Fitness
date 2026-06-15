import 'package:go_router/go_router.dart';
import 'package:gamified_fitness_app/ui/shell/app_shell.dart';
import 'package:gamified_fitness_app/ui/screens/home/home_screen.dart';
import 'package:gamified_fitness_app/ui/screens/exercise/exercise_screen.dart';
import 'package:gamified_fitness_app/ui/screens/profile/profile_screen.dart';
import 'package:gamified_fitness_app/ui/screens/leaderboard/leaderboard_screen.dart';
import 'package:gamified_fitness_app/ui/screens/history/workout_history_screen.dart';

/// Route definitions and GoRouter configuration for navigation
class AppRouter {
  static const String home = '/';
  static const String exercise = '/exercise';
  static const String profile = '/profile';
  static const String leaderboard = '/leaderboard';
  static const String history = '/history';

  /// GoRouter instance with 5 main routes wrapped in AppShell
  static final GoRouter router = GoRouter(
    initialLocation: home,
    routes: [
      GoRoute(
        path: home,
        name: 'home',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: AppShell(child: HomeScreen()),
        ),
      ),
      GoRoute(
        path: exercise,
        name: 'exercise',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: AppShell(child: ExerciseScreen()),
        ),
      ),
      GoRoute(
        path: profile,
        name: 'profile',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: AppShell(child: ProfileScreen()),
        ),
      ),
      GoRoute(
        path: leaderboard,
        name: 'leaderboard',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: AppShell(child: LeaderboardScreen()),
        ),
      ),
      GoRoute(
        path: history,
        name: 'history',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: AppShell(child: WorkoutHistoryScreen()),
        ),
      ),
    ],
  );
}