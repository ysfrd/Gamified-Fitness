import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gamified_fitness_app/providers/workout_provider.dart';
import 'package:gamified_fitness_app/data/models/workout_record_model.dart';

/// Workout history screen showing past workouts and statistics
class WorkoutHistoryScreen extends StatefulWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  State<WorkoutHistoryScreen> createState() => _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState extends State<WorkoutHistoryScreen> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load history only once when screen first opens
    if (!_initialized) {
      _initialized = true;
      final workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);
      workoutProvider.loadHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout History'),
        centerTitle: true,
        actions: [
          // Manual refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final provider = Provider.of<WorkoutProvider>(context, listen: false);
              provider.refreshHistory();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('History refreshed!'), duration: Duration(seconds: 1)),
              );
            },
          ),
        ],
      ),
      body: Consumer<WorkoutProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingHistory && provider.history.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final history = provider.getLastNWorkouts(10); // Show last 10 workouts only

          if (history.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.fitness_center, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No workouts yet!',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Start exercising to see your history',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              _buildStatsCard(provider),
              Expanded(
                child: ListView.separated(
                  itemCount: history.length,
                  separatorBuilder: (context, index) => const Divider(height: 0),
                  itemBuilder: (context, index) {
                    final record = history[index];
                    return _buildHistoryItem(record);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Build statistics card showing today's XP, units, and total workouts
  Widget _buildStatsCard(WorkoutProvider provider) {
    final totalXP = provider.getTodayTotalXP();
    final totalUnits = provider.getTodayTotalUnits();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.green, Colors.lightGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              const Text('Today\'s XP', style: TextStyle(color: Colors.white70)),
              Text(
                totalXP.toString(),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          Container(width: 1, height: 40, color: Colors.white38),
          Column(
            children: [
              const Text('Total Units', style: TextStyle(color: Colors.white70)),
              Text(
                totalUnits.toString(),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          Container(width: 1, height: 40, color: Colors.white38),
          Column(
            children: [
              const Text('Total Workouts', style: TextStyle(color: Colors.white70)),
              Text(
                provider.history.length.toString(),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build individual history item widget
  Widget _buildHistoryItem(WorkoutRecord record) {
    final date = record.timestamp;
    final formattedDate = '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

    String exerciseIcon = '💪';
    switch (record.exerciseType) {
      case 'pushups': exerciseIcon = '💪'; break;
      case 'squats': exerciseIcon = '🦵'; break;
      case 'situps': exerciseIcon = '🪑'; break;
      case 'jumpingJacks': exerciseIcon = '🦘'; break;
      case 'plank': exerciseIcon = '⏱️'; break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Center(child: Text(exerciseIcon, style: const TextStyle(fontSize: 24))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.exerciseType.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  formattedDate,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                Text(
                  '${record.completedUnits} units completed',
                  style: const TextStyle(fontSize: 11, color: Colors.white54),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              '+${record.earnedXP} XP',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }
}