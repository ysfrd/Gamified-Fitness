import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Main shell widget containing bottom navigation bar for the app
/// Wraps all screens with consistent navigation
class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _getSelectedIndex(context),
        onDestinationSelected: (index) => _onDestinationSelected(context, index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.fitness_center_outlined), label: 'Exercise'),
          NavigationDestination(icon: Icon(Icons.emoji_events_outlined), label: 'Leaderboard'),
          NavigationDestination(icon: Icon(Icons.history_outlined), label: 'History'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }

  /// Determine which tab is currently selected based on route path
  int _getSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    switch (location) {
      case '/':
        return 0;
      case '/exercise':
        return 1;
      case '/leaderboard':
        return 2;
      case '/history':
        return 3;
      case '/profile':
        return 4;
      default:
        return 0;
    }
  }

  /// Navigate to selected tab
  void _onDestinationSelected(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/exercise');
        break;
      case 2:
        context.go('/leaderboard');
        break;
      case 3:
        context.go('/history');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }
}