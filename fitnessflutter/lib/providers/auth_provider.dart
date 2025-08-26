import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isAuthenticated = false;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;

  // Check if user is already logged in
  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('current_user');
      
      if (userJson != null) {
        final userMap = json.decode(userJson);
        _currentUser = User.fromMap(userMap);
        _isAuthenticated = true;
      }
    } catch (e) {
      debugPrint('Error checking auth status: $e');
      _isAuthenticated = false;
      _currentUser = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  // Register a new user
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
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Check if user already exists
      final existingUsers = prefs.getStringList('users') ?? [];
      for (String userJson in existingUsers) {
        final userData = json.decode(userJson);
        if (userData['email'] == email) {
          _isLoading = false;
          notifyListeners();
          return false; // User already exists
        }
      }

      // Create new user
      final newUser = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        name: name,
        age: age,
        height: height,
        weight: weight,
        gender: gender,
        fitnessGoal: fitnessGoal,
        activityLevel: activityLevel,
        createdAt: DateTime.now(),
      );

      // Save user credentials
      final userCredentials = {
        'email': email,
        'password': password,
        'user': newUser.toMap(),
      };

      existingUsers.add(json.encode(userCredentials));
      await prefs.setStringList('users', existingUsers);

      // Set current user
      _currentUser = newUser;
      _isAuthenticated = true;
      await prefs.setString('current_user', json.encode(newUser.toMap()));

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error during registration: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Login user
  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final existingUsers = prefs.getStringList('users') ?? [];
      
      for (String userJson in existingUsers) {
        final userCredentials = json.decode(userJson);
        if (userCredentials['email'] == email && userCredentials['password'] == password) {
          _currentUser = User.fromMap(userCredentials['user']);
          _isAuthenticated = true;
          await prefs.setString('current_user', json.encode(_currentUser!.toMap()));
          
          _isLoading = false;
          notifyListeners();
          return true;
        }
      }

      _isLoading = false;
      notifyListeners();
      return false; // Invalid credentials
    } catch (e) {
      debugPrint('Error during login: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout user
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('current_user');
      
      _currentUser = null;
      _isAuthenticated = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error during logout: $e');
    }
  }

  // Update user profile
  Future<bool> updateUserProfile(User updatedUser) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Update current user
      _currentUser = updatedUser;
      await prefs.setString('current_user', json.encode(updatedUser.toMap()));
      
      // Update in users list
      final existingUsers = prefs.getStringList('users') ?? [];
      for (int i = 0; i < existingUsers.length; i++) {
        final userCredentials = json.decode(existingUsers[i]);
        if (userCredentials['user']['id'] == updatedUser.id) {
          userCredentials['user'] = updatedUser.toMap();
          existingUsers[i] = json.encode(userCredentials);
          break;
        }
      }
      await prefs.setStringList('users', existingUsers);
      
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error updating user profile: $e');
      return false;
    }
  }

  // Reset password (basic implementation)
  Future<bool> resetPassword({required String email, required String newPassword}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingUsers = prefs.getStringList('users') ?? [];
      
      for (int i = 0; i < existingUsers.length; i++) {
        final userCredentials = json.decode(existingUsers[i]);
        if (userCredentials['email'] == email) {
          userCredentials['password'] = newPassword;
          existingUsers[i] = json.encode(userCredentials);
          await prefs.setStringList('users', existingUsers);
          return true;
        }
      }
      
      return false; // User not found
    } catch (e) {
      debugPrint('Error resetting password: $e');
      return false;
    }
  }
}