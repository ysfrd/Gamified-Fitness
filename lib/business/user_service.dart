import 'package:gamified_fitness_app/data/dao/user_dao.dart';
import 'package:gamified_fitness_app/data/models/user_model.dart';
import 'package:gamified_fitness_app/business/xp_service.dart';

/// Business logic for user operations
class UserService {
  final UserDao _userDao = UserDao();

  /// Get current user, create default if none exists
  Future<UserModel> getCurrentUser() async {
    return await _userDao.getOrCreateUser();
  }

  /// Update user in database
  Future<void> updateUser(UserModel user) async {
    await _userDao.updateUser(user);
  }

  /// Change user name
  Future<void> changeUserName(String newName) async {
    final user = await getCurrentUser();
    final updatedUser = user.copyWith(name: newName);
    await updateUser(updatedUser);
  }

  /// Add XP and update user, return updated user
  Future<UserModel> addXPAndUpdate(int gainedXP) async {
    final user = await getCurrentUser();
    final result = XPService.addXP(user, gainedXP);
    await updateUser(result.updatedUser);
    return result.updatedUser;
  }
}