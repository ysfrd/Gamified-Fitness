import 'package:gamified_fitness_app/data/dao/user_dao.dart';
import 'package:gamified_fitness_app/data/models/user_model.dart';

/// Repository for user data operations
/// Provides abstraction between business layer and data source
class UserRepository {
  final UserDao _userDao = UserDao();

  /// Get current user (creates default user if none exists)
  Future<UserModel> getUser() async {
    return await _userDao.getOrCreateUser();
  }

  /// Update user in database
  Future<void> updateUser(UserModel user) async {
    await _userDao.updateUser(user);
  }
}