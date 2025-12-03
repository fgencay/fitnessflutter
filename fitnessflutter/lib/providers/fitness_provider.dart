import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/bmi_model.dart';
import '../models/workout_model.dart';
import '../models/diet_model.dart';
import '../models/user_model.dart';

class FitnessProvider extends ChangeNotifier {
  BMIData? _currentBMI;
  WorkoutProgram? _currentWorkoutProgram;
  DietProgram? _currentDietProgram;
  bool _isLoading = false;
  BMIData? get currentBMI => _currentBMI;
  WorkoutProgram? get currentWorkoutProgram => _currentWorkoutProgram;
  DietProgram? get currentDietProgram => _currentDietProgram;
  bool get isLoading => _isLoading;
  void calculateBMI(double height, double weight) {
    _currentBMI = BMIData.calculateBMI(height, weight);
    notifyListeners();
    _saveBMIData();  } 
  Future<void> generateWorkoutProgram(User user, BMIData bmi) async {
    _isLoading = true;
    notifyListeners();
    try {
      await Future.delayed(const Duration(seconds: 1));      
      _currentWorkoutProgram = WorkoutProgram.generateProgram(
        user.id,
        user.fitnessGoal,
        user.activityLevel,
        bmi.bmi,
      );      
      await _saveWorkoutProgram();
    } catch (e) {
      debugPrint('Error generating workout program: $e');
    }
    _isLoading = false;
    notifyListeners();
  }
  Future<void> generateDietProgram(User user, BMIData bmi) async {
    _isLoading = true;
    notifyListeners();
    try {
      await Future.delayed(const Duration(seconds: 1));      
      double dailyCalories = bmi.calculateDailyCalories(
        user.weight,
        user.height,
        user.age,
        user.gender,
        user.activityLevel,
      );      
      _currentDietProgram = DietProgram.generateDietProgram(
        user.id,
        user.fitnessGoal,
        dailyCalories,
        bmi.bmi,
      );      
      await _saveDietProgram();
    } catch (e) {
      debugPrint('Error generating diet program: $e');
    }
    _isLoading = false;
    notifyListeners();
  } 
  Future<void> loadFitnessData(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();        
      final bmiJson = prefs.getString('${userId}_bmi');
      if (bmiJson != null) {
        final bmiMap = json.decode(bmiJson);
        _currentBMI = BMIData(
          bmi: bmiMap['bmi'],
          category: BMICategory.values[bmiMap['categoryIndex']],
          categoryText: bmiMap['categoryText'],
          recommendation: bmiMap['recommendation'],
          description: bmiMap['description'],
        );
      }         
      final workoutJson = prefs.getString('${userId}_workout');
      if (workoutJson != null) {
        final workoutMap = json.decode(workoutJson);
        _currentWorkoutProgram = WorkoutProgram.fromMap(workoutMap);
      }          
      final dietJson = prefs.getString('${userId}_diet');
      if (dietJson != null) {
        final dietMap = json.decode(dietJson);
        _currentDietProgram = DietProgram.fromMap(dietMap);
      }      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading fitness data: $e');
    }
  }  
  Future<void> _saveBMIData() async {
    if (_currentBMI == null) return;    
    try {
      final prefs = await SharedPreferences.getInstance();
      final bmiMap = {
        'bmi': _currentBMI!.bmi,
        'categoryIndex': _currentBMI!.category.index,
        'categoryText': _currentBMI!.categoryText,
        'recommendation': _currentBMI!.recommendation,
        'description': _currentBMI!.description,
      };       
      await prefs.setString('current_user_bmi', json.encode(bmiMap));
    } catch (e) {
      debugPrint('Error saving BMI data: $e');
    }
  } 
  Future<void> _saveWorkoutProgram() async {
    if (_currentWorkoutProgram == null) return;    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_user_workout', json.encode(_currentWorkoutProgram!.toMap()));
    } catch (e) {
      debugPrint('Error saving workout program: $e');
    }
  }
  Future<void> _saveDietProgram() async {
    if (_currentDietProgram == null) return;    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_user_diet', json.encode(_currentDietProgram!.toMap()));
    } catch (e) {
      debugPrint('Error saving diet program: $e');
    }
  } 
  void clearFitnessData() {
    _currentBMI = null;
    _currentWorkoutProgram = null;
    _currentDietProgram = null;
    notifyListeners();
  } 
  Map<String, dynamic> getFitnessSummary() {
    return {
      'hasBMI': _currentBMI != null,
      'hasWorkoutProgram': _currentWorkoutProgram != null,
      'hasDietProgram': _currentDietProgram != null,
      'bmiCategory': _currentBMI?.categoryText ?? 'Hesaplanmadı',
      'recommendation': _currentBMI?.recommendation ?? 'BMI hesaplayın',
    };
  }
}