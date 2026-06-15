import 'package:flutter/material.dart';
import 'package:gamified_fitness_app/data/models/user_model.dart';
import 'package:gamified_fitness_app/business/leaderboard_service.dart';
import 'package:gamified_fitness_app/business/xp_service.dart';
import 'package:gamified_fitness_app/data/dao/user_dao.dart';

/// Leaderboard screen showing user rank against bot competitors
class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Leaderboard')),
      body: FutureBuilder<UserModel>(
        future: UserDao().getOrCreateUser(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = snapshot.data!;
          final leaderboard = LeaderboardService.getBotCompetitors(user);
          final userRank = LeaderboardService.getUserRank(user);

          return Column(
            children: [
              // User rank highlight card
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Colors.orange, Colors.deepOrange]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Your Rank', style: TextStyle(color: Colors.white, fontSize: 18)),
                    Row(
                      children: [
                        Text('#$userRank', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        Text(XPService.getRank(user.level), style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              // Leaderboard list
              Expanded(
                child: ListView.builder(
                  itemCount: leaderboard.length,
                  itemBuilder: (context, index) {
                    final competitor = leaderboard[index];
                    final isUser = competitor.id == user.id;
                    final rankIcon = _getRankIcon(competitor.level);
                    final rankName = XPService.getRank(competitor.level).replaceAll(RegExp(r'[^\w\s]'), '').trim();
                    final xpForNextLevel = XPService.xpRequiredForLevel(competitor.level);
                    final currentLevelXP = XPService.getCurrentLevelProgress(competitor.xp, competitor.level);

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: isUser ? Colors.green.shade900 : Colors.grey.shade900,
                        borderRadius: BorderRadius.circular(12),
                        border: isUser ? Border.all(color: Colors.green.shade400, width: 2) : null,
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        // Rank number with colored circle
                        leading: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: _getRankColor(competitor.level).withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: _getRankColor(competitor.level),
                              ),
                            ),
                          ),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                competitor.name,
                                style: TextStyle(
                                  fontWeight: isUser ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            // Rank badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getRankColor(competitor.level).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: _getRankColor(competitor.level).withOpacity(0.5)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(rankIcon, style: const TextStyle(fontSize: 10)),
                                  const SizedBox(width: 2),
                                  Text(rankName, style: TextStyle(fontSize: 9, color: _getRankColor(competitor.level), fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        subtitle: Row(
                          children: [
                            Text('Lv.${competitor.level}', style: const TextStyle(fontSize: 11)),
                            const SizedBox(width: 8),
                            Container(width: 4, height: 4, decoration: const BoxDecoration(color: Colors.white38, shape: BoxShape.circle)),
                            const SizedBox(width: 8),
                            Text('${competitor.totalWorkouts} workouts', style: const TextStyle(fontSize: 11)),
                          ],
                        ),
                        trailing: SizedBox(
                          width: 85,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('${competitor.xp} XP', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              const SizedBox(height: 2),
                              Text('$currentLevelXP/$xpForNextLevel', style: const TextStyle(fontSize: 9, color: Colors.white54)),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Get emoji icon based on level range
  String _getRankIcon(int level) {
    if (level < 10) return '🥉';
    if (level < 20) return '⭐';
    if (level < 35) return '⚡';
    if (level < 50) return '🏅';
    if (level < 90) return '🔥';
    if (level < 120) return '💪';
    if (level < 150) return '👑';
    if (level < 200) return '🗿';
    if (level < 300) return '🏆';
    return '🌟';
  }

  /// Get color based on level range for rank display
  Color _getRankColor(int level) {
    if (level < 10) return Colors.brown;
    if (level < 20) return Colors.blue;
    if (level < 35) return Colors.cyan;
    if (level < 50) return Colors.green;
    if (level < 90) return Colors.orange;
    if (level < 120) return Colors.red;
    if (level < 150) return Colors.purple;
    if (level < 200) return Colors.indigo;
    if (level < 300) return Colors.amber;
    return Colors.pink;
  }
}