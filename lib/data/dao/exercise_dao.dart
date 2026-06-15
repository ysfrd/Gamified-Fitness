import 'package:gamified_fitness_app/data/database/database_helper.dart';
import 'package:gamified_fitness_app/data/models/exercise_model.dart';

/// Data Access Object for Exercise operations with SQLite
class ExerciseDao {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  /// Add a workout record to database
  Future<void> addWorkoutRecord(ExerciseType type, int earnedXP, int completedUnits) async {
    final record = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'exercise_type': type.name,
      'earned_xp': earnedXP,
      'completed_units': completedUnits,
      'timestamp': DateTime.now().toIso8601String(),
    };
    await _dbHelper.insertWorkoutRecord(record);
  }

  /// Get total completed units for an exercise today
  Future<int> getTodayExerciseUnits(ExerciseType type) async {
    return await _dbHelper.getTodayExerciseUnits(type.name);
  }

  /// Get all workout records from today
  Future<List<Map<String, dynamic>>> getTodayWorkoutRecords() async {
    return await _dbHelper.getTodayWorkoutRecords();
  }

  /// Get workout history for last N days
  Future<List<Map<String, dynamic>>> getWorkoutHistory({int days = 30}) async {
    return await _dbHelper.getWorkoutHistory(days: days);
  }

  /// Get time until daily reset (next midnight)
  Duration getTimeUntilReset() {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    return midnight.difference(now);
  }

  /// Clear all workouts from today (testing only)
  Future<void> clearTodayWorkouts() async {
    await _dbHelper.clearTodayWorkouts();
  }
}