import 'package:flutter/material.dart';
import 'package:gamified_fitness_app/data/models/user_model.dart';
import 'package:gamified_fitness_app/data/models/exercise_model.dart';
import 'package:gamified_fitness_app/business/xp_service.dart';
import 'package:gamified_fitness_app/data/dao/exercise_dao.dart';
import 'package:gamified_fitness_app/data/dao/user_dao.dart';
import 'package:gamified_fitness_app/data/database/database_helper.dart';

/// Main workout screen where users perform exercises and earn XP
class ExerciseScreen extends StatefulWidget {
  const ExerciseScreen({super.key});

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  ExerciseModel? selectedExercise;
  int repCount = 0;
  int secondCount = 0;
  final ExerciseDao _exerciseDao = ExerciseDao();
  final UserDao _userDao = UserDao();

  bool _isLimitReached = false;
  int _todayCount = 0;
  int _maxUnits = 0;
  int _maxXP = 0;
  int _currentUserLevel = 1;
  Duration _timeUntilReset = const Duration();
  bool _isProcessing = false;

  // Daily quest tracking
  int _dailyPushups = 0;
  int _dailySquats = 0;
  int _dailyPlankSeconds = 0;
  bool _questBonusClaimed = false;

  @override
  void initState() {
    super.initState();
    _loadUserLevel();
    _loadDailyData();
    _startTimer();
  }

  /// Load current user level for daily limit calculations
  Future<void> _loadUserLevel() async {
    final user = await _userDao.getOrCreateUser();
    setState(() {
      _currentUserLevel = user.level;
    });
  }

  /// Start countdown timer for daily reset display
  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _timeUntilReset = _exerciseDao.getTimeUntilReset();
        });
        _startTimer();
      }
    });
  }

  /// Load all daily data including quests and limits
  Future<void> _loadDailyData() async {
    await _loadDailyQuests();
    if (selectedExercise != null) {
      await _checkLimit();
    }
    setState(() {});
  }

  /// Load daily quest progress from database
  Future<void> _loadDailyQuests() async {
    _dailyPushups = await _exerciseDao.getTodayExerciseUnits(ExerciseType.pushups);
    _dailySquats = await _exerciseDao.getTodayExerciseUnits(ExerciseType.squats);
    _dailyPlankSeconds = await _exerciseDao.getTodayExerciseUnits(ExerciseType.plank);

    final lastBonusDate = await DatabaseHelper().getSetting('lastQuestBonusDate');
    final today = DateTime.now().toIso8601String().split('T')[0];
    _questBonusClaimed = lastBonusDate == today;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.orange),
            onPressed: _showResetDialog,
            tooltip: 'Reset Today\'s Progress (Test Mode)',
          ),
          IconButton(
            icon: const Icon(Icons.new_releases, color: Colors.purple),
            onPressed: _showComingSoonDialog,
            tooltip: 'Coming Soon',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Daily reset timer display
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.timer, color: Colors.amber),
                  const SizedBox(width: 8),
                  Text(
                    'Day resets in: ${_formatDuration(_timeUntilReset.inSeconds)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            _buildDailyQuestsSection(),

            const SizedBox(height: 8),

            // Exercise selection grid
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: ExerciseModel.exercises.length,
                itemBuilder: (context, index) {
                  final exercise = ExerciseModel.exercises[index];
                  final isSelected = selectedExercise?.type == exercise.type;
                  return GestureDetector(
                    onTap: () async {
                      await _selectExercise(exercise);
                    },
                    child: Card(
                      color: isSelected ? Colors.green.shade800 : null,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            exercise.icon,
                            size: 48,
                            color: isSelected ? Colors.white : Colors.green,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            exercise.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : null,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${exercise.xpPerUnit.toStringAsFixed(1)} XP/unit',
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected ? Colors.white70 : Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          FutureBuilder<Map<String, int>>(
                            future: _getExerciseStats(exercise),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const SizedBox(height: 20);
                              }
                              final data = snapshot.data!;
                              final count = data['count'] ?? 0;
                              final limit = data['limit'] ?? 100;
                              final remaining = limit - count;
                              final isOverLimit = count >= limit;
                              return Column(
                                children: [
                                  Text(
                                    '📊 $count / $limit today',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isOverLimit
                                          ? Colors.red
                                          : (isSelected ? Colors.white54 : Colors.grey.shade600),
                                    ),
                                  ),
                                  if (remaining > 0 && remaining < 10)
                                    Text(
                                      '⚠️ $remaining left',
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: Colors.orange,
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Selected exercise controls
            if (selectedExercise != null) ...[
              const Divider(),
              const SizedBox(height: 16),
              Text(
                selectedExercise!.name,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  _showExerciseInfoDialog();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade800,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.info_outline, size: 16, color: Colors.white70),
                      const SizedBox(width: 4),
                      Text(
                        selectedExercise!.getInfoText(_currentUserLevel),
                        style: const TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Remaining units display
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '⚠️ Remaining today: ${(_maxUnits - _todayCount).clamp(0, _maxUnits)} units',
                  style: const TextStyle(fontSize: 12, color: Colors.orange),
                ),
              ),
              const SizedBox(height: 8),

              // Counter controls for rep-based exercises
              if (selectedExercise!.targetReps > 0)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: _isLimitReached || _isProcessing ? null : () => setState(() {
                        if (repCount > 0) repCount--;
                      }),
                      icon: const Icon(Icons.remove),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$repCount / ${selectedExercise!.targetReps}',
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                    IconButton(
                      onPressed: _isLimitReached || _isProcessing ? null : () => setState(() {
                        final remainingUnits = _maxUnits - _todayCount;
                        final targetLimit = selectedExercise!.targetReps;
                        final maxAllowed = (remainingUnits < targetLimit) ? remainingUnits : targetLimit;

                        if (repCount < maxAllowed) {
                          repCount++;
                        }
                      }),
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),

              // Counter controls for timed exercises
              if (selectedExercise!.durationSeconds > 0)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: _isLimitReached || _isProcessing ? null : () => setState(() {
                        if (secondCount > 0) secondCount--;
                      }),
                      icon: const Icon(Icons.remove),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_formatDuration(secondCount)} / ${_formatDuration(selectedExercise!.durationSeconds)}',
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                    IconButton(
                      onPressed: _isLimitReached || _isProcessing ? null : () => setState(() {
                        final remainingUnits = _maxUnits - _todayCount;
                        final targetLimit = selectedExercise!.durationSeconds;
                        final maxAllowed = (remainingUnits < targetLimit) ? remainingUnits : targetLimit;
                        final step = 5;

                        if (secondCount + step <= maxAllowed) {
                          secondCount += step;
                        } else if (secondCount < maxAllowed) {
                          secondCount = maxAllowed;
                        }
                      }),
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),

              const SizedBox(height: 16),

              // Daily limit progress bar
              LinearProgressIndicator(
                value: _maxUnits > 0 ? _todayCount / _maxUnits : 0,
                backgroundColor: Colors.grey.shade800,
                color: _todayCount >= _maxUnits ? Colors.red : Colors.green,
              ),
              const SizedBox(height: 8),
              Text(
                'Daily limit: $_todayCount / $_maxUnits units ($_maxXP XP max)',
                style: TextStyle(
                  fontSize: 12,
                  color: _todayCount >= _maxUnits ? Colors.red : Colors.white70,
                ),
              ),
              const SizedBox(height: 16),

              // Warning when limit reached
              if (_isLimitReached)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade900.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber, color: Colors.red),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Daily limit reached! Max $_maxUnits ${selectedExercise!.name} per day.\nNo more XP from this exercise today! 💪',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),

              // Complete workout button
              ElevatedButton.icon(
                onPressed: (_isLimitReached || _getCurrentProgress() == 0 || _isProcessing) ? null : _completeWorkout,
                icon: _isProcessing
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.check_circle),
                label: Text(_isLimitReached ? 'Daily Limit Reached' : 'Complete & Earn XP'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  minimumSize: const Size(double.infinity, 56),
                  backgroundColor: _isLimitReached ? Colors.grey : Colors.green,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Build daily quests section with progress tracking
  Widget _buildDailyQuestsSection() {
    final allQuestsDone = _dailyPushups >= 20 && _dailySquats >= 60 && _dailyPlankSeconds >= 60;
    final canClaim = allQuestsDone && !_questBonusClaimed;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.assignment, size: 20, color: Colors.amber),
              SizedBox(width: 8),
              Text('Daily Quests', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildQuestItem(Icons.fitness_center, 'Push-ups', _dailyPushups, 20),
              _buildQuestItem(Icons.accessibility_new, 'Squats', _dailySquats, 60),
              _buildQuestItem(Icons.timer, 'Plank (sec)', _dailyPlankSeconds, 60),
            ],
          ),
          if (canClaim)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: ElevatedButton(
                onPressed: _claimQuestBonus,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  minimumSize: const Size(double.infinity, 36),
                ),
                child: const Text('Claim +50 XP Bonus!', style: TextStyle(color: Colors.black)),
              ),
            ),
          if (_questBonusClaimed && allQuestsDone)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text('✓ Bonus claimed today! Come back tomorrow!',
                  style: TextStyle(color: Colors.green, fontSize: 12)),
            ),
        ],
      ),
    );
  }

  /// Build individual quest item widget
  Widget _buildQuestItem(IconData icon, String label, int current, int target) {
    final isComplete = current >= target;
    return Column(
      children: [
        Icon(icon, color: isComplete ? Colors.green : Colors.white54, size: 24),
        const SizedBox(height: 4),
        Text('$current/$target', style: TextStyle(color: isComplete ? Colors.green : Colors.white54)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.white54)),
      ],
    );
  }

  /// Claim daily quest bonus (50 XP)
  Future<void> _claimQuestBonus() async {
    final user = await _userDao.getOrCreateUser();
    final result = XPService.addXP(user, 50);
    await _userDao.updateUser(result.updatedUser);
    await _loadUserLevel();

    final today = DateTime.now().toIso8601String().split('T')[0];
    await DatabaseHelper().setSetting('lastQuestBonusDate', today);

    setState(() {
      _questBonusClaimed = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('+50 XP Bonus claimed! 🎉')),
    );

    if (result.leveledUp && mounted) {
      _showLevelUpDialog(result.oldLevel, result.updatedUser.level);
    }
  }

  /// Get current user level from database
  Future<int> _getCurrentUserLevel() async {
    final user = await _userDao.getOrCreateUser();
    return user.level;
  }

  /// Get current progress value (reps or seconds)
  int _getCurrentProgress() {
    if (selectedExercise == null) return 0;
    if (selectedExercise!.targetReps > 0) {
      return repCount;
    } else {
      return secondCount;
    }
  }

  /// Get exercise statistics for today
  Future<Map<String, int>> _getExerciseStats(ExerciseModel exercise) async {
    final user = await _userDao.getOrCreateUser();
    final count = await _exerciseDao.getTodayExerciseUnits(exercise.type);
    final limit = exercise.getMaxDailyUnits(user.level);
    return {'count': count, 'limit': limit};
  }

  /// Select an exercise and load its daily limits
  Future<void> _selectExercise(ExerciseModel exercise) async {
    final user = await _userDao.getOrCreateUser();

    _todayCount = await _exerciseDao.getTodayExerciseUnits(exercise.type);
    _maxUnits = exercise.getMaxDailyUnits(user.level);
    _maxXP = exercise.getMaxDailyXP(user.level);
    _isLimitReached = _todayCount >= _maxUnits;

    setState(() {
      selectedExercise = exercise;
      repCount = 0;
      secondCount = 0;
      _currentUserLevel = user.level;
    });

    if (_isLimitReached) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚠️ Daily limit reached! $_todayCount/$_maxUnits ${exercise.name} done. No more XP today!'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// Show exercise information dialog
  void _showExerciseInfoDialog() async {
    final userLevel = await _getCurrentUserLevel();
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(selectedExercise!.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('💰 XP Rate: ${selectedExercise!.xpPerUnit.toStringAsFixed(1)} XP per unit'),
              const SizedBox(height: 8),
              Text(selectedExercise!.getInfoText(userLevel)),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Text('📊 Daily Units: $_todayCount / $_maxUnits'),
              Text('✨ Daily Max XP: $_maxXP XP'),
              const SizedBox(height: 12),
              const Text('⚠️ Taking rest days is important for muscle recovery!'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Got it!'),
            ),
          ],
        );
      },
    );
  }

  /// Show coming soon features dialog
  void _showComingSoonDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('🚀 Coming Soon'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('✨ Upcoming Features:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• 🔐 Login with Google/Email'),
              Text('• 📏 Height & Weight Tracking'),
              Text('• 📊 BMI Calculator & Charts'),
              Text('• 🌐 Online Leaderboard'),
              Text('• 👥 Friend System'),
              Text('• 🏆 Weekly Tournaments'),
              Text('• 📱 Cloud Sync Across Devices'),
              Text('• 🎨 Custom Avatars'),
              Text('• 🔊 Voice Coach'),
              Text('• 📅 Workout Calendar'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Excited! 🎉'),
            ),
          ],
        );
      },
    );
  }

  /// Show reset dialog for testing purposes
  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('🔄 Reset Today\'s Progress'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('This will clear ALL workouts done today.'),
              Text('This is for TESTING only!', style: TextStyle(color: Colors.orange)),
              SizedBox(height: 8),
              Text('Are you sure?', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await _exerciseDao.clearTodayWorkouts();
                Navigator.of(dialogContext).pop();
                await _loadDailyData();
                if (selectedExercise != null) {
                  await _selectExercise(selectedExercise!);
                }
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Today\'s progress has been reset!')),
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
  }

  /// Format duration in seconds to HH:MM:SS or MM:SS format
  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remainingSeconds = seconds % 60;

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
    } else if (minutes > 0) {
      return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
    }
    return '${seconds}s';
  }

  /// Check and update daily limit status
  Future<void> _checkLimit() async {
    if (selectedExercise == null) return;

    final user = await _userDao.getOrCreateUser();

    _todayCount = await _exerciseDao.getTodayExerciseUnits(selectedExercise!.type);
    _maxUnits = selectedExercise!.getMaxDailyUnits(user.level);
    _maxXP = selectedExercise!.getMaxDailyXP(user.level);
    _isLimitReached = _todayCount >= _maxUnits;
    setState(() {});
  }

  /// Complete workout, earn XP, and update database
  Future<void> _completeWorkout() async {
    if (selectedExercise == null || _isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      UserModel user = await _userDao.getOrCreateUser();

      _todayCount = await _exerciseDao.getTodayExerciseUnits(selectedExercise!.type);
      _maxUnits = selectedExercise!.getMaxDailyUnits(user.level);
      _isLimitReached = _todayCount >= _maxUnits;

      if (_isLimitReached) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Daily limit reached! No more XP from this exercise today! 🧘'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      int completedUnits;
      if (selectedExercise!.targetReps > 0) {
        completedUnits = repCount;
      } else {
        completedUnits = secondCount;
      }

      int allowedUnits = (_maxUnits - _todayCount).clamp(0, completedUnits);

      if (allowedUnits <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Daily limit would be exceeded!')),
        );
        return;
      }

      int earnedXP = (allowedUnits * selectedExercise!.xpPerUnit).floor();

      if (earnedXP == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Complete more to earn XP! 💪')),
        );
        return;
      }

      await _exerciseDao.addWorkoutRecord(selectedExercise!.type, earnedXP, completedUnits);

      final result = XPService.addXP(user, earnedXP);
      await _userDao.updateUser(result.updatedUser);
      await _loadUserLevel();

      _todayCount += allowedUnits;
      _isLimitReached = _todayCount >= _maxUnits;
      await _loadDailyQuests();

      if (mounted) {
        if (result.leveledUp) {
          _showLevelUpDialog(result.oldLevel, result.updatedUser.level);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('+$earnedXP XP earned! 💪 ($_todayCount/$_maxUnits units used)'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }

      setState(() {
        repCount = 0;
        secondCount = 0;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  /// Show level up dialog with celebration
  void _showLevelUpDialog(int oldLevel, int newLevel) {
    final newRank = XPService.getRank(newLevel);
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('🎉 LEVEL UP! 🎉'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Level $oldLevel → Level $newLevel!'),
              const SizedBox(height: 8),
              Text('New Rank: $newRank', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('🏆 Next level needs: ${XPService.xpRequiredForLevel(newLevel)} XP'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Awesome!'),
            ),
          ],
        );
      },
    );
  }
}