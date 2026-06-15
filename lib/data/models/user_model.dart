import 'package:equatable/equatable.dart';
import 'package:gamified_fitness_app/business/xp_service.dart';

/// User data model representing player profile
class UserModel extends Equatable {
  final String id;
  final String name;
  final int level;
  final int xp;
  final int totalWorkouts;
  final DateTime joinDate;

  const UserModel({
    required this.id,
    required this.name,
    this.level = 1,
    this.xp = 0,
    this.totalWorkouts = 0,
    required this.joinDate,
  });

  /// XP required for next level (Level 1 needs 60 XP, then formula applies)
  int get xpForNextLevel {
    if (level <= 1) return 60;
    return XPService.xpRequiredForLevel(level);
  }

  /// XP progress within current level
  int get currentLevelXP {
    return XPService.getCurrentLevelProgress(xp, level);
  }

  /// Progress percentage toward next level (0-100)
  int get progressPercent {
    final needed = xpForNextLevel;
    if (needed <= 0) return 0;
    final progress = (currentLevelXP / needed * 100).toInt().clamp(0, 100);
    return progress;
  }

  /// Immutable update pattern for state management
  UserModel copyWith({
    String? id,
    String? name,
    int? level,
    int? xp,
    int? totalWorkouts,
    DateTime? joinDate,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      totalWorkouts: totalWorkouts ?? this.totalWorkouts,
      joinDate: joinDate ?? this.joinDate,
    );
  }

  /// Convert to Map for database storage (snake_case column names)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'level': level,
      'xp': xp,
      'total_workouts': totalWorkouts,
      'join_date': joinDate.toIso8601String(),
    };
  }

  /// Create from Map (database read)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    final user = UserModel(
      id: map['id'],
      name: map['name'],
      level: map['level'] ?? 1,
      xp: map['xp'] ?? 0,
      totalWorkouts: map['total_workouts'] ?? 0,
      joinDate: DateTime.parse(map['join_date']),
    );

    // Recalculate level based on total XP to ensure consistency
    final correctLevel = XPService.getLevelFromXP(user.xp);
    if (correctLevel != user.level) {
      return user.copyWith(level: correctLevel);
    }
    return user;
  }

  @override
  List<Object?> get props => [id, name, level, xp, totalWorkouts, joinDate];
}