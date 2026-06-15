import 'package:gamified_fitness_app/data/database/database_helper.dart';
import 'package:gamified_fitness_app/data/models/user_model.dart';

/// Data Access Object for User operations with SQLite
class UserDao {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  /// Save user to database
  Future<void> saveUser(UserModel user) async {
    await _dbHelper.insertUser(user.toMap());
  }

  /// Get user from database, returns null if none exists
  Future<UserModel?> getUser() async {
    final userMap = await _dbHelper.getCurrentUser();
    if (userMap == null) return null;
    return UserModel.fromMap(userMap);
  }

  /// Update existing user
  Future<void> updateUser(UserModel user) async {
    await _dbHelper.updateUser(user.toMap());
  }

  /// Check if user exists in database
  Future<bool> hasUser() async {
    final count = await _dbHelper.getUserCount();
    return count > 0;
  }

  /// Create default user with starter values
  UserModel createDefaultUser() {
    return UserModel(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Fitness Warrior',
      level: 1,
      xp: 0,
      totalWorkouts: 0,
      joinDate: DateTime.now(),
    );
  }

  /// Get existing user or create and return default
  Future<UserModel> getOrCreateUser() async {
    final existingUser = await getUser();
    if (existingUser != null) return existingUser;

    final newUser = createDefaultUser();
    await saveUser(newUser);
    return newUser;
  }
}