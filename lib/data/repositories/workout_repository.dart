import 'package:gamified_fitness_app/data/dao/exercise_dao.dart';
import 'package:gamified_fitness_app/data/models/exercise_model.dart';
import 'package:gamified_fitness_app/data/models/workout_record_model.dart';

/// Repository for workout data operations
/// Provides abstraction between business layer and data source
class WorkoutRepository {
  final ExerciseDao _exerciseDao = ExerciseDao();

  /// Add a new workout record to database
  Future<void> addWorkoutRecord(ExerciseType type, int earnedXP, int completedUnits) async {
    await _exerciseDao.addWorkoutRecord(type, earnedXP, completedUnits);
  }

  /// Get total completed units for an exercise today
  Future<int> getTodayExerciseUnits(ExerciseType type) async {
    return await _exerciseDao.getTodayExerciseUnits(type);
  }

  /// Get all workout records from today
  Future<List<WorkoutRecord>> getTodayWorkouts() async {
    final records = await _exerciseDao.getTodayWorkoutRecords();
    return records.map((r) => WorkoutRecord.fromMap(r)).toList();
  }

  /// Get workout history for last N days (default 30)
  Future<List<WorkoutRecord>> getWorkoutHistory({int days = 30}) async {
    final records = await _exerciseDao.getWorkoutHistory(days: days);
    return records.map((r) => WorkoutRecord.fromMap(r)).toList();
  }

  /// Get time until daily reset (next midnight)
  Duration getTimeUntilReset() {
    return _exerciseDao.getTimeUntilReset();
  }
}