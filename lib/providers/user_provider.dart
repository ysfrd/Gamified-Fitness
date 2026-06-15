import 'package:flutter/material.dart';
import 'package:gamified_fitness_app/data/models/user_model.dart';
import 'package:gamified_fitness_app/data/repositories/user_repository.dart';
import 'package:gamified_fitness_app/business/xp_service.dart';

/// State management provider for user data using ChangeNotifier
class UserProvider extends ChangeNotifier {
  final UserRepository _repository = UserRepository();
  UserModel? _user;
  bool _isLoading = true;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;

  /// Load user from database on app startup
  Future<void> loadUser() async {
    _isLoading = true;
    notifyListeners();

    _user = await _repository.getUser();

    _isLoading = false;
    notifyListeners();
  }

  /// Update user and notify all listeners (triggers UI refresh)
  Future<void> updateUser(UserModel updatedUser) async {
    await _repository.updateUser(updatedUser);
    _user = updatedUser;
    notifyListeners(); // This refreshes all listening widgets
  }

  /// Change user name and update UI automatically
  Future<void> changeName(String newName) async {
    if (_user == null) return;
    final updatedUser = _user!.copyWith(name: newName);
    await updateUser(updatedUser);
  }

  /// Add XP to user and update UI automatically
  Future<UserModel> addXP(int gainedXP) async {
    if (_user == null) return _user!;

    final result = XPService.addXP(_user!, gainedXP);
    await updateUser(result.updatedUser);

    return result.updatedUser;
  }
}