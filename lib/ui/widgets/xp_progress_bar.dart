import 'package:flutter/material.dart';
import 'package:gamified_fitness_app/data/models/user_model.dart';

/// Reusable XP progress bar widget showing current level progress
/// Displays current XP, XP needed for next level, and total XP
class XPProgressBar extends StatelessWidget {
  final UserModel user;

  const XPProgressBar({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final xpNeeded = user.xpForNextLevel;
    final currentXP = user.currentLevelXP;

    // Prevent division by zero
    final progressValue = xpNeeded > 0 ? currentXP / xpNeeded : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('XP Progress', style: Theme.of(context).textTheme.titleSmall),
            Text('$currentXP / $xpNeeded XP to next level'),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progressValue.clamp(0.0, 1.0),
            minHeight: 12,
            backgroundColor: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Total XP: ${user.xp}',
          style: const TextStyle(fontSize: 12, color: Colors.white54),
        ),
      ],
    );
  }
}