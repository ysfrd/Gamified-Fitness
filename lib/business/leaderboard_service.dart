import 'package:gamified_fitness_app/data/models/user_model.dart';
import 'package:gamified_fitness_app/business/xp_service.dart';
import 'package:gamified_fitness_app/data/models/exercise_model.dart';


/// Leaderboard with bot competitors for offline competition
class LeaderboardService {
  // Generate bot competitors with different ranks
  static List<UserModel> getBotCompetitors(UserModel currentUser) {
    final List<UserModel> bots = [
      // Beginner rank bots (Level 1-9)
      _createBot(
        id: 'bot_beginner_1',
        name: 'TinyTitan',
        level: 3,
        workouts: 8,
        daysAgo: 3,
      ),
      _createBot(
        id: 'bot_beginner_2',
        name: 'RisingPhoenix',
        level: 7,
        workouts: 18,
        daysAgo: 10,
      ),

      // Rookie rank bots (Level 10-19)
      _createBot(
        id: 'bot_rookie_1',
        name: 'SpeedDemon',
        level: 12,
        workouts: 28,
        daysAgo: 20,
      ),
      _createBot(
        id: 'bot_rookie_2',
        name: 'IronWill',
        level: 15,
        workouts: 38,
        daysAgo: 28,
      ),
      _createBot(
        id: 'bot_rookie_3',
        name: 'NeonBlade',
        level: 18,
        workouts: 48,
        daysAgo: 35,
      ),

      // Trainee rank bots (Level 20-34)
      _createBot(
        id: 'bot_trainee_1',
        name: 'ShadowStrike',
        level: 22,
        workouts: 55,
        daysAgo: 42,
      ),
      _createBot(
        id: 'bot_trainee_2',
        name: 'ManiacNicole',
        level: 26,
        workouts: 65,
        daysAgo: 50,
      ),
      _createBot(
        id: 'bot_trainee_3',
        name: 'ThunderFist',
        level: 30,
        workouts: 80,
        daysAgo: 60,
      ),

      // Athlete rank bots (Level 35-49)
      _createBot(
        id: 'bot_athlete_1',
        name: 'StrongJoseph',
        level: 38,
        workouts: 100,
        daysAgo: 75,
      ),
      _createBot(
        id: 'bot_athlete_2',
        name: 'ViperQueen',
        level: 42,
        workouts: 120,
        daysAgo: 90,
      ),
      _createBot(
        id: 'bot_athlete_3',
        name: 'UnbreakableMan',
        level: 48,
        workouts: 145,
        daysAgo: 110,
      ),

      // Warrior rank bots (Level 50-89)
      _createBot(
        id: 'bot_warrior_1',
        name: 'BeastMode',
        level: 55,
        workouts: 185,
        daysAgo: 150,
      ),
      _createBot(
        id: 'bot_warrior_2',
        name: 'IronMaiden',
        level: 65,
        workouts: 230,
        daysAgo: 180,
      ),
      _createBot(
        id: 'bot_warrior_3',
        name: 'SavageWolf',
        level: 75,
        workouts: 290,
        daysAgo: 220,
      ),
      _createBot(
        id: 'bot_warrior_4',
        name: 'CrimsonFury',
        level: 85,
        workouts: 350,
        daysAgo: 280,
      ),

      // Champion rank bots (Level 90-119)
      _createBot(
        id: 'bot_champion_1',
        name: 'NightmareKing',
        level: 95,
        workouts: 430,
        daysAgo: 365,
      ),
      _createBot(
        id: 'bot_champion_2',
        name: 'ValkyrieRage',
        level: 105,
        workouts: 490,
        daysAgo: 420,
      ),
      _createBot(
        id: 'bot_champion_3',
        name: 'Hellbringer',
        level: 115,
        workouts: 560,
        daysAgo: 480,
      ),

      // Elite rank bots (Level 120-149)
      _createBot(
        id: 'bot_elite_1',
        name: 'Godslayer',
        level: 130,
        workouts: 690,
        daysAgo: 600,
      ),
      _createBot(
        id: 'bot_elite_2',
        name: 'FrostGiant',
        level: 140,
        workouts: 760,
        daysAgo: 680,
      ),
      _createBot(
        id: 'bot_elite_3',
        name: 'StormBreaker',
        level: 148,
        workouts: 860,
        daysAgo: 750,
      ),

      // Titan rank bots (Level 150-199)
      _createBot(
        id: 'bot_titan_1',
        name: 'Titanomachy',
        level: 165,
        workouts: 1060,
        daysAgo: 1000,
      ),
      _createBot(
        id: 'bot_titan_2',
        name: 'WorldEater',
        level: 180,
        workouts: 1260,
        daysAgo: 1150,
      ),
      _createBot(
        id: 'bot_titan_3',
        name: 'Colossus',
        level: 195,
        workouts: 1490,
        daysAgo: 1300,
      ),

      // Olympian rank bots (Level 200-299)
      _createBot(
        id: 'bot_olympian_1',
        name: 'ZeusThunder',
        level: 220,
        workouts: 1810,
        daysAgo: 1500,
      ),
      _createBot(
        id: 'bot_olympian_2',
        name: 'AthenaWisdom',
        level: 245,
        workouts: 2120,
        daysAgo: 1800,
      ),
      _createBot(
        id: 'bot_olympian_3',
        name: 'AresBloodlust',
        level: 270,
        workouts: 2520,
        daysAgo: 2200,
      ),
      _createBot(
        id: 'bot_olympian_4',
        name: 'HermesSwift',
        level: 290,
        workouts: 2920,
        daysAgo: 2600,
      ),

      // Legend rank bots (Level 300+)
      _createBot(
        id: 'bot_legend_1',
        name: 'OmniGod',
        level: 320,
        workouts: 3020,
        daysAgo: 3000,
      ),
      _createBot(
        id: 'bot_legend_2',
        name: 'EternalFlame',
        level: 350,
        workouts: 3620,
        daysAgo: 3500,
      ),
      _createBot(
        id: 'bot_legend_3',
        name: 'PrimordialOne',
        level: 400,
        workouts:4520,
        daysAgo: 4500,
      ),
    ];

    // Add real user and sort by TOTAL XP
    List<UserModel> all = [...bots, currentUser];
    all.sort((a, b) {
      int aTotalXP = a.xp;
      int bTotalXP = b.xp;
      return bTotalXP.compareTo(aTotalXP);
    });

    return all;
  }

  static UserModel _createBot({
    required String id,
    required String name,
    required int level,
    required int workouts,
    required int daysAgo,
  }) {
    // Calculate total XP for this level
    int totalXP = XPService.totalXPForLevel(level);
    // Add some progress within the level
    int xpForNextLevel = XPService.xpRequiredForLevel(level);
    int additionalXP = (level * 17) % xpForNextLevel;
    totalXP += additionalXP;

    return UserModel(
      id: id,
      name: name,
      level: level,
      xp: totalXP,
      totalWorkouts: workouts,
      joinDate: DateTime.now().subtract(Duration(days: daysAgo)),
    );
  }

  // Get user's rank position
  static int getUserRank(UserModel currentUser) {
    List<UserModel> ranked = getBotCompetitors(currentUser);
    return ranked.indexWhere((user) => user.id == currentUser.id) + 1;
  }
}