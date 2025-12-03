import 'package:flutter/foundation.dart';
import '../models/user_model.dart' as app_user;

abstract class BaseAuthProvider extends ChangeNotifier {
  app_user.User? get currentUser;  
  bool get isAuthenticated; 
  bool get isLoading;  
  bool get rememberMe; 
  String? get errorMessage; 
  void clearError(); 
  void setRememberMe(bool value);
  Future<void> checkAuthStatus();
  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required int age,
    required double height,
    required double weight,
    required String gender,
    required String fitnessGoal,
    required String activityLevel,
  }); 
  Future<bool> login({
    required String email,
    required String password,
    bool rememberMe = true,
  }); 
  Future<void> logout(); 
  Future<bool> updateUserProfile(app_user.User updatedUser);
}
