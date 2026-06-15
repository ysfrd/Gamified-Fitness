import 'package:flutter/material.dart';
import 'package:gamified_fitness_app/data/models/exercise_model.dart';
import 'package:gamified_fitness_app/data/models/workout_record_model.dart';
import 'package:gamified_fitness_app/data/repositories/workout_repository.dart';

/// State management provider for workout data using ChangeNotifier
class WorkoutProvider extends ChangeNotifier {
  final WorkoutRepository _repository = WorkoutRepository();
  List<WorkoutRecord> _todayWorkouts = [];
  List<WorkoutRecord> _history = [];
  bool _isLoading = false;
  bool _isLoadingHistory = false;

  List<WorkoutRecord> get todayWorkouts => _todayWorkouts;
  List<WorkoutRecord> get history => _history;
  bool get isLoading => _isLoading;
  bool get isLoadingHistory => _isLoadingHistory;

  /// Load today's workouts (called on app startup)
  Future<void> loadTodayWorkouts() async {
    _todayWorkouts = await _repository.getTodayWorkouts();
    notifyListeners();
  }

  /// Load workout history (only once, prevents multiple reloads)
  Future<void> loadHistory() async {
    if (_isLoadingHistory) return; // Prevent duplicate loading
    if (_history.isNotEmpty) return; // Already loaded

    _isLoadingHistory = true;
    notifyListeners();

    _history = await _repository.getWorkoutHistory(days: 30);

    _isLoadingHistory = false;
    notifyListeners();
  }

  /// Manually refresh history (called on pull-to-refresh)
  Future<void> refreshHistory() async {
    _isLoadingHistory = true;
    notifyListeners();

    _history = await _repository.getWorkoutHistory(days: 30);

    _isLoadingHistory = false;
    notifyListeners();
  }

  /// Add new workout and refresh both today and history data
  Future<void> addWorkout(ExerciseType type, int earnedXP, int units) async {
    await _repository.addWorkoutRecord(type, earnedXP, units);
    await loadTodayWorkouts();
    await refreshHistory(); // Refresh history after new workout
  }

  /// Calculate total XP earned today
  int getTodayTotalXP() {
    return _todayWorkouts.fold(0, (sum, record) => sum + record.earnedXP);
  }

  /// Calculate total units completed today
  int getTodayTotalUnits() {
    return _todayWorkouts.fold(0, (sum, record) => sum + record.completedUnits);
  }

  /// Get last N workouts for history display
  List<WorkoutRecord> getLastNWorkouts(int n) {
    if (_history.length <= n) return _history;
    return _history.sublist(0, n);
  }
}