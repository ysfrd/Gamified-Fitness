import 'package:gamified_fitness_app/data/models/user_model.dart';
import 'package:gamified_fitness_app/data/models/exercise_model.dart';

/// Business logic for XP and level management
class XPService {
  /// XP required to level up from given level
  /// Level 1 -> 2 needs 60 XP, then formula: 50 + 10 * (level - 1)
  static int xpRequiredForLevel(int level) {
    if (level <= 1) return 60;
    return 50 + 10 * (level - 1);
  }

  /// Cumulative XP needed to reach a specific level
  static int totalXPForLevel(int level) {
    if (level <= 1) return 0;
    int n = level - 1;
    int first = 50;
    int last = 50 + 10 * (n - 1);
    return n * (first + last) ~/ 2;
  }

  /// Calculate level from total XP using cumulative XP thresholds
  static int getLevelFromXP(int totalXP) {
    int level = 1;
    while (totalXP >= totalXPForLevel(level + 1)) {
      level++;
    }
    return level;
  }

  /// Get XP progress within current level
  static int getCurrentLevelProgress(int totalXP, int currentLevel) {
    int xpForCurrentLevel = totalXPForLevel(currentLevel);
    return totalXP - xpForCurrentLevel;
  }

  /// Add XP to user, check for level up, increment workout count
  static ({UserModel updatedUser, bool leveledUp, int oldLevel})
  addXP(UserModel user, int gainedXP) {
    int newTotalXP = user.xp + gainedXP;
    int oldLevel = user.level;
    int newLevel = getLevelFromXP(newTotalXP);
    bool leveledUp = newLevel > oldLevel;

    UserModel updatedUser = user.copyWith(
      xp: newTotalXP,
      level: newLevel,
      totalWorkouts: user.totalWorkouts + 1,
    );

    return (updatedUser: updatedUser, leveledUp: leveledUp, oldLevel: oldLevel);
  }

  /// Get rank enum from level (10 rank tiers)
  static Rank getRankEnum(int level) {
    if (level < 10) return Rank.beginner;
    if (level < 20) return Rank.rookie;
    if (level < 35) return Rank.trainee;
    if (level < 50) return Rank.athlete;
    if (level < 90) return Rank.warrior;
    if (level < 120) return Rank.champion;
    if (level < 150) return Rank.elite;
    if (level < 200) return Rank.titan;
    if (level < 300) return Rank.olympian;
    return Rank.legend;
  }

  /// Get rank display name with emoji
  static String getRank(int level) {
    switch (getRankEnum(level)) {
      case Rank.beginner: return '🥉 Beginner';
      case Rank.rookie: return '⭐ Rookie';
      case Rank.trainee: return '⚡ Trainee';
      case Rank.athlete: return '🏅 Athlete';
      case Rank.warrior: return '🔥 Warrior';
      case Rank.champion: return '💪 Champion';
      case Rank.elite: return '👑 Elite';
      case Rank.titan: return '🗿 Titan';
      case Rank.olympian: return '🏆 Olympian';
      case Rank.legend: return '🌟 Legend';
    }
  }

  /// Get next rank name for progression display
  static String getNextRank(int currentLevel) {
    final currentRank = getRankEnum(currentLevel);
    switch (currentRank) {
      case Rank.beginner: return 'Rookie';
      case Rank.rookie: return 'Trainee';
      case Rank.trainee: return 'Athlete';
      case Rank.athlete: return 'Warrior';
      case Rank.warrior: return 'Champion';
      case Rank.champion: return 'Elite';
      case Rank.elite: return 'Titan';
      case Rank.titan: return 'Olympian';
      case Rank.olympian: return 'Legend';
      case Rank.legend: return 'Mythic';
    }
  }

  /// Get XP needed to reach next rank tier
  static int getXPNeededForNextRank(int currentLevel, int currentXP) {
    final targetLevel = _getLevelForNextRank(currentLevel);
    return totalXPForLevel(targetLevel) - currentXP;
  }

  /// Get level threshold for next rank
  static int _getLevelForNextRank(int currentLevel) {
    if (currentLevel < 10) return 10;
    if (currentLevel < 20) return 20;
    if (currentLevel < 35) return 35;
    if (currentLevel < 50) return 50;
    if (currentLevel < 90) return 90;
    if (currentLevel < 120) return 120;
    if (currentLevel < 150) return 150;
    if (currentLevel < 200) return 200;
    if (currentLevel < 300) return 300;
    return 400;
  }

  /// Get max daily XP limit based on user's rank
  static int getMaxDailyXP(UserModel user) {
    final rank = getRankEnum(user.level);
    switch (rank) {
      case Rank.beginner: return 317;
      case Rank.rookie: return 418;
      case Rank.trainee: return 519;
      case Rank.athlete: return 640;
      case Rank.warrior: return 786;
      case Rank.champion: return 938;
      case Rank.elite: return 1090;
      case Rank.titan: return 1242;
      case Rank.olympian: return 1369;
      case Rank.legend: return 1496;
    }
  }
}