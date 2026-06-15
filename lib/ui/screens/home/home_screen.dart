import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gamified_fitness_app/data/models/user_model.dart';
import 'package:gamified_fitness_app/business/xp_service.dart';
import 'package:gamified_fitness_app/ui/widgets/xp_progress_bar.dart';
import 'package:gamified_fitness_app/ui/widgets/level_badge.dart';
import 'package:gamified_fitness_app/data/dao/user_dao.dart';

/// Main dashboard screen showing user stats, XP progress, and rank information
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gamified Fitness'),
        centerTitle: true,
      ),
      body: FutureBuilder<UserModel>(
        future: UserDao().getOrCreateUser(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = snapshot.data!;
          final rank = XPService.getRank(user.level);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Level and rank display
                Center(
                  child: Column(
                    children: [
                      LevelBadge(level: user.level),
                      const SizedBox(height: 8),
                      Text(
                        rank,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // XP progress bar
                XPProgressBar(user: user),
                const SizedBox(height: 24),

                // Rank progression badges
                _buildRankBadges(context, user.level),
                const SizedBox(height: 16),

                // Daily limits summary for current rank
                _buildDailyLimitsSummary(context, user.level),
                const SizedBox(height: 16),

                // User statistics cards
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatCard('Level', user.level.toString()),
                    _buildStatCard('Total XP', user.xp.toString()),
                    _buildStatCard('Workouts', user.totalWorkouts.toString()),
                  ],
                ),
                const SizedBox(height: 32),

                const Divider(),
                const SizedBox(height: 16),

                // Call to action button
                Text(
                  'Ready to work out? 💪',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.go('/exercise');
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start Working Out'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Build a statistics card with label and value
  Widget _buildStatCard(String label, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            Text(label),
          ],
        ),
      ),
    );
  }

  /// Build daily limits summary widget based on user level
  Widget _buildDailyLimitsSummary(BuildContext context, int userLevel) {
    late int pushLimit, squatLimit, situpLimit, jjLimit, plankSeconds;

    // Determine limits based on level ranges
    if (userLevel < 10) {
      pushLimit = 75; squatLimit = 100; situpLimit = 75; jjLimit = 150; plankSeconds = 60;
    } else if (userLevel < 20) {
      pushLimit = 100; squatLimit = 125; situpLimit = 100; jjLimit = 200; plankSeconds = 90;
    } else if (userLevel < 35) {
      pushLimit = 125; squatLimit = 150; situpLimit = 125; jjLimit = 250; plankSeconds = 120;
    } else if (userLevel < 50) {
      pushLimit = 150; squatLimit = 200; situpLimit = 150; jjLimit = 300; plankSeconds = 150;
    } else if (userLevel < 90) {
      pushLimit = 175; squatLimit = 250; situpLimit = 175; jjLimit = 400; plankSeconds = 180;
    } else if (userLevel < 120) {
      pushLimit = 200; squatLimit = 300; situpLimit = 200; jjLimit = 500; plankSeconds = 240;
    } else if (userLevel < 150) {
      pushLimit = 225; squatLimit = 350; situpLimit = 225; jjLimit = 600; plankSeconds = 300;
    } else if (userLevel < 200) {
      pushLimit = 250; squatLimit = 400; situpLimit = 250; jjLimit = 700; plankSeconds = 360;
    } else if (userLevel < 300) {
      pushLimit = 275; squatLimit = 450; situpLimit = 275; jjLimit = 750; plankSeconds = 420;
    } else {
      pushLimit = 300; squatLimit = 500; situpLimit = 300; jjLimit = 800; plankSeconds = 480;
    }

    final currentRank = XPService.getRank(userLevel).replaceAll(RegExp(r'[^\w\s]'), '').trim();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.speed, color: Colors.cyan, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Daily Limits • $currentRank',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const Spacer(),
                // Tap to see all ranks
                GestureDetector(
                  onTap: () => _showFullLimitsDialog(context, userLevel),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade800,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('All Ranks', style: TextStyle(fontSize: 10, color: Colors.amber)),
                        SizedBox(width: 2),
                        Icon(Icons.chevron_right, size: 12, color: Colors.amber),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLimitItem('💪', 'Push-up', pushLimit),
                _buildLimitItem('🦵', 'Squat', squatLimit),
                _buildLimitItem('🪑', 'Sit-up', situpLimit),
                _buildLimitItem('🦘', 'Jump Jack', jjLimit),
                _buildLimitItem('⏱️', 'Plank', plankSeconds),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: Colors.grey.shade800, borderRadius: BorderRadius.circular(8)),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, size: 12, color: Colors.white54),
                  SizedBox(width: 4),
                  Text('Higher rank = Higher daily limits! Train daily to rank up!', style: TextStyle(fontSize: 9, color: Colors.white54)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build individual limit item with icon, name, and value
  Widget _buildLimitItem(String icon, String name, int limit) {
    String displayValue = name == 'Plank' ? '$limit s' : limit.toString();
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 2),
        Text(displayValue, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        Text(name, style: const TextStyle(fontSize: 9, color: Colors.white54)),
      ],
    );
  }

  /// Show dialog with full daily limits table for all ranks
  void _showFullLimitsDialog(BuildContext context, int currentUserLevel) {
    final List<Map<String, dynamic>> ranks = [
      {'rank': '🥉 Beginner', 'pushups': 75, 'squats': 100, 'situps': 75, 'jj': 150, 'plank': '60 s'},
      {'rank': '⭐ Rookie', 'pushups': 100, 'squats': 125, 'situps': 100, 'jj': 200, 'plank': '90 s'},
      {'rank': '⚡ Trainee', 'pushups': 125, 'squats': 150, 'situps': 125, 'jj': 250, 'plank': '120 s'},
      {'rank': '🏅 Athlete', 'pushups': 150, 'squats': 200, 'situps': 150, 'jj': 300, 'plank': '150 s'},
      {'rank': '🔥 Warrior', 'pushups': 175, 'squats': 250, 'situps': 175, 'jj': 400, 'plank': '180 s'},
      {'rank': '💪 Champion', 'pushups': 200, 'squats': 300, 'situps': 200, 'jj': 500, 'plank': '240 s'},
      {'rank': '👑 Elite', 'pushups': 225, 'squats': 350, 'situps': 225, 'jj': 600, 'plank': '300 s'},
      {'rank': '🗿 Titan', 'pushups': 250, 'squats': 400, 'situps': 250, 'jj': 700, 'plank': '360 s'},
      {'rank': '🏆 Olympian', 'pushups': 275, 'squats': 450, 'situps': 275, 'jj': 750, 'plank': '420 s'},
      {'rank': '🌟 Legend', 'pushups': 300, 'squats': 500, 'situps': 300, 'jj': 800, 'plank': '480 s'},
    ];

    String currentRankName = XPService.getRank(currentUserLevel).replaceAll(RegExp(r'[^\w\s]'), '').trim();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Row(children: [Icon(Icons.table_chart, color: Colors.amber), SizedBox(width: 8), Text('Daily Limits by Rank')]),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 12,
                headingRowColor: WidgetStateProperty.all(Colors.grey.shade800),
                columns: const [
                  DataColumn(label: Text('Rank', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                  DataColumn(label: Text('💪', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                  DataColumn(label: Text('🦵', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                  DataColumn(label: Text('🪑', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                  DataColumn(label: Text('🦘', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                  DataColumn(label: Text('⏱️', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                ],
                rows: ranks.map((rank) {
                  final bool isCurrentRank = rank['rank'].toString().contains(currentRankName);
                  return DataRow(
                    color: isCurrentRank ? WidgetStateProperty.all(Colors.green.shade900.withOpacity(0.5)) : null,
                    cells: [
                      DataCell(Text(rank['rank'] as String, style: TextStyle(fontSize: 10, fontWeight: isCurrentRank ? FontWeight.bold : FontWeight.normal, color: isCurrentRank ? Colors.amber : null))),
                      DataCell(Text('${rank['pushups']}', style: TextStyle(fontSize: 10, fontWeight: isCurrentRank ? FontWeight.bold : FontWeight.normal, color: isCurrentRank ? Colors.amber : null))),
                      DataCell(Text('${rank['squats']}', style: TextStyle(fontSize: 10, fontWeight: isCurrentRank ? FontWeight.bold : FontWeight.normal, color: isCurrentRank ? Colors.amber : null))),
                      DataCell(Text('${rank['situps']}', style: TextStyle(fontSize: 10, fontWeight: isCurrentRank ? FontWeight.bold : FontWeight.normal, color: isCurrentRank ? Colors.amber : null))),
                      DataCell(Text('${rank['jj']}', style: TextStyle(fontSize: 10, fontWeight: isCurrentRank ? FontWeight.bold : FontWeight.normal, color: isCurrentRank ? Colors.amber : null))),
                      DataCell(Text(rank['plank'] as String, style: TextStyle(fontSize: 10, fontWeight: isCurrentRank ? FontWeight.bold : FontWeight.normal, color: isCurrentRank ? Colors.amber : null))),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          actions: [TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Got it!'))],
        );
      },
    );
  }

  /// Build horizontal scrollable rank progression badges
  Widget _buildRankBadges(BuildContext context, int currentLevel) {
    final List<Map<String, dynamic>> ranks = [
      {'rank': 'Beginner', 'icon': '🥉', 'level': 1, 'minXP': 0, 'color': Colors.brown},
      {'rank': 'Rookie', 'icon': '⭐', 'level': 10, 'minXP': 900, 'color': Colors.blue},
      {'rank': 'Trainee', 'icon': '⚡', 'level': 20, 'minXP': 2800, 'color': Colors.cyan},
      {'rank': 'Athlete', 'icon': '🏅', 'level': 35, 'minXP': 7650, 'color': Colors.green},
      {'rank': 'Warrior', 'icon': '🔥', 'level': 50, 'minXP': 14750, 'color': Colors.orange},
      {'rank': 'Champion', 'icon': '💪', 'level': 90, 'minXP': 44050, 'color': Colors.red},
      {'rank': 'Elite', 'icon': '👑', 'level': 120, 'minXP': 77400, 'color': Colors.purple},
      {'rank': 'Titan', 'icon': '🗿', 'level': 150, 'minXP': 119750, 'color': Colors.indigo},
      {'rank': 'Olympian', 'icon': '🏆', 'level': 200, 'minXP': 208000, 'color': Colors.amber},
      {'rank': 'Legend', 'icon': '🌟', 'level': 300, 'minXP': 461000, 'color': Colors.pink},
    ];

    // Find current rank index
    int currentRankIndex = 0;
    for (int i = ranks.length - 1; i >= 0; i--) {
      if (currentLevel >= (ranks[i]['level'] as int)) {
        currentRankIndex = i;
        break;
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(children: [Icon(Icons.emoji_events, color: Colors.amber, size: 20), SizedBox(width: 8), Text('Rank Progression', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), SizedBox(width: 8), Icon(Icons.chevron_right, size: 16, color: Colors.white54), Text('Scroll →', style: TextStyle(fontSize: 10, color: Colors.white54))]),
            const SizedBox(height: 12),
            SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: ranks.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final rank = ranks[index];
                  final bool isCurrentRank = index == currentRankIndex;
                  final bool isPassed = index < currentRankIndex;
                  final bool isLocked = index > currentRankIndex;

                  Color getCardColor() {
                    if (isCurrentRank) return Colors.amber;
                    if (isPassed) return Colors.green;
                    return Colors.grey.shade800;
                  }

                  return GestureDetector(
                    onLongPress: () => _showXPDialog(context, rank),
                    child: Container(
                      width: 85,
                      decoration: BoxDecoration(
                        gradient: isCurrentRank ? const LinearGradient(colors: [Colors.amber, Colors.deepOrange]) : null,
                        color: !isCurrentRank ? getCardColor() : null,
                        borderRadius: BorderRadius.circular(16),
                        border: isCurrentRank ? Border.all(color: Colors.amber.shade300, width: 2) : (isLocked ? Border.all(color: Colors.grey.shade700, width: 1) : null),
                      ),
                      child: Stack(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Opacity(opacity: isLocked ? 0.4 : 1.0, child: Text(rank['icon'] as String, style: const TextStyle(fontSize: 32))),
                              const SizedBox(height: 4),
                              Text(rank['rank'] as String, style: TextStyle(fontSize: 11, fontWeight: isCurrentRank ? FontWeight.bold : FontWeight.normal, color: isLocked ? Colors.white38 : (isCurrentRank ? Colors.white : Colors.white70))),
                              Text('Lv.${rank['level']}', style: TextStyle(fontSize: 9, color: isLocked ? Colors.white38 : (isCurrentRank ? Colors.white70 : Colors.white54))),
                              if (isLocked) const Padding(padding: EdgeInsets.only(top: 4), child: Icon(Icons.lock, size: 12, color: Colors.white38)),
                              if (isPassed && !isCurrentRank) const Padding(padding: EdgeInsets.only(top: 4), child: Icon(Icons.check_circle, size: 12, color: Colors.white70)),
                            ],
                          ),
                          Positioned(
                            bottom: 4,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), borderRadius: BorderRadius.circular(8)),
                              child: Text(_formatXP(rank['minXP'] as int), style: const TextStyle(fontSize: 8, color: Colors.white70), textAlign: TextAlign.center),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.grey.shade800, borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('🎯 Current Progress', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  Text('${ranks[currentRankIndex]['rank']} → ${currentRankIndex + 1 < ranks.length ? ranks[currentRankIndex + 1]['rank'] : 'MAX'}', style: const TextStyle(fontSize: 12, color: Colors.amber)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Format XP number for display (K, M suffixes)
  String _formatXP(int xp) {
    if (xp >= 1000000) return '${(xp / 1000000).toStringAsFixed(1)}M XP';
    if (xp >= 1000) return '${(xp / 1000).toStringAsFixed(0)}K XP';
    return '$xp XP';
  }

  /// Show dialog with rank XP requirements on long press
  void _showXPDialog(BuildContext context, Map<String, dynamic> rank) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Row(children: [Text(rank['icon'] as String, style: const TextStyle(fontSize: 24)), const SizedBox(width: 8), Text(rank['rank'] as String)]),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('🏆 Required Level: ${rank['level']}'),
              const SizedBox(height: 8),
              Text('✨ Required XP: ${_formatXP(rank['minXP'] as int)}'),
              const SizedBox(height: 8),
              Text(rank['rank'] == 'Beginner' ? '📊 Starting rank!' : '📊 Reach this rank to unlock new achievements!'),
            ],
          ),
          actions: [TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Got it!'))],
        );
      },
    );
  }
}