import 'package:flutter/material.dart';
import 'package:gamified_fitness_app/business/xp_service.dart';

/// Available exercise types
enum ExerciseType {
  pushups,
  squats,
  situps,
  jumpingJacks,
  plank,
}

/// Rank tiers for player progression
enum Rank {
  beginner,
  rookie,
  trainee,
  athlete,
  warrior,
  champion,
  elite,
  titan,
  olympian,
  legend,
}

/// Exercise model containing exercise properties and daily limits
class ExerciseModel {
  final ExerciseType type;
  final String name;
  final double xpPerUnit; // XP per rep or per second for plank
  final int durationSeconds; // 0 for rep-based exercises
  final int targetReps; // 0 for timed exercises

  const ExerciseModel({
    required this.type,
    required this.name,
    required this.xpPerUnit,
    this.durationSeconds = 0,
    this.targetReps = 0,
  });

  /// Predefined exercises list
  static List<ExerciseModel> get exercises => [
    ExerciseModel(
      type: ExerciseType.pushups,
      name: 'Push-ups',
      xpPerUnit: 1.0,
      targetReps: 15,
    ),
    ExerciseModel(
      type: ExerciseType.squats,
      name: 'Squats',
      xpPerUnit: 0.8,
      targetReps: 20,
    ),
    ExerciseModel(
      type: ExerciseType.situps,
      name: 'Sit-ups',
      xpPerUnit: 1.0,
      targetReps: 20,
    ),
    ExerciseModel(
      type: ExerciseType.jumpingJacks,
      name: 'Jumping Jacks',
      xpPerUnit: 0.5,
      targetReps: 30,
    ),
    ExerciseModel(
      type: ExerciseType.plank,
      name: 'Plank',
      xpPerUnit: 0.2,
      durationSeconds: 30,
    ),
  ];

  /// Calculate XP based on completed units (reps or seconds)
  int calculateXP(int completedReps, int completedSeconds) {
    double earnedXP = 0;

    if (targetReps > 0) {
      earnedXP = completedReps * xpPerUnit;
    } else {
      earnedXP = completedSeconds * xpPerUnit;
    }

    return earnedXP.floor().clamp(0, 1000);
  }

  /// Get max daily units based on player rank level
  int getMaxDailyUnits(int playerRankLevel) {
    final rank = XPService.getRankEnum(playerRankLevel);

    switch (type) {
      case ExerciseType.pushups:
        switch (rank) {
          case Rank.beginner: return 75;
          case Rank.rookie: return 100;
          case Rank.trainee: return 125;
          case Rank.athlete: return 150;
          case Rank.warrior: return 175;
          case Rank.champion: return 200;
          case Rank.elite: return 225;
          case Rank.titan: return 250;
          case Rank.olympian: return 275;
          case Rank.legend: return 300;
        }
      case ExerciseType.squats:
        switch (rank) {
          case Rank.beginner: return 100;
          case Rank.rookie: return 125;
          case Rank.trainee: return 150;
          case Rank.athlete: return 200;
          case Rank.warrior: return 250;
          case Rank.champion: return 300;
          case Rank.elite: return 350;
          case Rank.titan: return 400;
          case Rank.olympian: return 450;
          case Rank.legend: return 500;
        }
      case ExerciseType.situps:
        switch (rank) {
          case Rank.beginner: return 75;
          case Rank.rookie: return 100;
          case Rank.trainee: return 125;
          case Rank.athlete: return 150;
          case Rank.warrior: return 175;
          case Rank.champion: return 200;
          case Rank.elite: return 225;
          case Rank.titan: return 250;
          case Rank.olympian: return 275;
          case Rank.legend: return 300;
        }
      case ExerciseType.jumpingJacks:
        switch (rank) {
          case Rank.beginner: return 150;
          case Rank.rookie: return 200;
          case Rank.trainee: return 250;
          case Rank.athlete: return 300;
          case Rank.warrior: return 400;
          case Rank.champion: return 500;
          case Rank.elite: return 600;
          case Rank.titan: return 700;
          case Rank.olympian: return 750;
          case Rank.legend: return 800;
        }
      case ExerciseType.plank:
        switch (rank) {
          case Rank.beginner: return 60;
          case Rank.rookie: return 90;
          case Rank.trainee: return 120;
          case Rank.athlete: return 150;
          case Rank.warrior: return 180;
          case Rank.champion: return 240;
          case Rank.elite: return 300;
          case Rank.titan: return 360;
          case Rank.olympian: return 420;
          case Rank.legend: return 480;
        }
    }
  }

  /// Get max daily XP for this exercise at given rank
  int getMaxDailyXP(int playerRankLevel) {
    final maxUnits = getMaxDailyUnits(playerRankLevel);
    return (maxUnits * xpPerUnit).floor();
  }

  /// Get info text for exercise display (shows XP rate and daily limits)
  String getInfoText(int playerRankLevel) {
    final maxUnits = getMaxDailyUnits(playerRankLevel);
    final maxXP = getMaxDailyXP(playerRankLevel);

    if (targetReps > 0) {
      return '⚡ ${xpPerUnit.toStringAsFixed(1)} XP per rep | Daily: $maxUnits reps = $maxXP XP max';
    } else {
      return '⏱️ ${xpPerUnit.toStringAsFixed(1)} XP per sec | Daily: ${maxUnits}s = $maxXP XP max';
    }
  }

  /// Get icon for exercise type
  IconData get icon {
    switch (type) {
      case ExerciseType.pushups: return Icons.fitness_center;
      case ExerciseType.squats: return Icons.accessibility_new;
      case ExerciseType.situps: return Icons.sports_gymnastics;
      case ExerciseType.jumpingJacks: return Icons.bolt;
      case ExerciseType.plank: return Icons.timer;
    }
  }

  /// Base XP for backward compatibility
  int get baseXP => (targetReps * xpPerUnit).floor();
}