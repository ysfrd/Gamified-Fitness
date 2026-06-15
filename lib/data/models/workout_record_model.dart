/// Workout record model representing a completed exercise session
class WorkoutRecord {
  final String id;
  final String exerciseType;
  final int earnedXP;
  final int completedUnits;
  final DateTime timestamp;

  WorkoutRecord({
    required this.id,
    required this.exerciseType,
    required this.earnedXP,
    required this.completedUnits,
    required this.timestamp,
  });

  /// Create from database map (snake_case to camelCase conversion)
  factory WorkoutRecord.fromMap(Map<String, dynamic> map) {
    return WorkoutRecord(
      id: map['id'],
      exerciseType: map['exercise_type'],
      earnedXP: map['earned_xp'],
      completedUnits: map['completed_units'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }

  /// Convert to database map (camelCase to snake_case conversion)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'exercise_type': exerciseType,
      'earned_xp': earnedXP,
      'completed_units': completedUnits,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}