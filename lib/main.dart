import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gamified_fitness_app/providers/user_provider.dart';
import 'package:gamified_fitness_app/providers/workout_provider.dart';
import 'package:gamified_fitness_app/router/app_router.dart';
import 'package:gamified_fitness_app/data/database/database_helper.dart';

/// Application entry point
/// Initializes database and runs the app with MultiProvider for state management
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper().database;
  runApp(const MyApp());
}

/// Main application widget with Provider setup and Material 3 theme
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // User state provider - loads user on startup
        ChangeNotifierProvider(create: (_) => UserProvider()..loadUser()),
        // Workout state provider - loads today's workouts on startup
        ChangeNotifierProvider(create: (_) => WorkoutProvider()..loadTodayWorkouts()),
        // Note: loadHistory is called only when HistoryScreen is opened
      ],
      child: MaterialApp.router(
        title: 'Gamified Fitness',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.green,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}