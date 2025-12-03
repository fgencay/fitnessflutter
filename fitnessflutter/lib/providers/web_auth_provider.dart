import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fa;
import '../models/user_model.dart' as app_user;
import 'base_auth_provider.dart';

class WebAuthProvider extends BaseAuthProvider {
  final fa.FirebaseAuth _auth = fa.FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  app_user.User? _currentUser;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  bool _rememberMe = true;
  String? _errorMessage;
  @override
  app_user.User? get currentUser => _currentUser;
  @override
  bool get isAuthenticated => _isAuthenticated;
  @override
  bool get isLoading => _isLoading;
  @override
  bool get rememberMe => _rememberMe;
  @override
  String? get errorMessage => _errorMessage;
  @override
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
  @override
  void setRememberMe(bool value) {
    _rememberMe = value;
    notifyListeners();
  }  
  @override
  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();
    try {
      final u = _auth.currentUser;
      if (u == null) {
        _isAuthenticated = false;
        _currentUser = null;
      } else {
        _isAuthenticated = true;
        _currentUser = await _loadProfile(u.uid, fallbackEmail: u.email, fallbackName: u.displayName);
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isAuthenticated = false;
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  Future<app_user.User?> _loadProfile(String uid, {String? fallbackEmail, String? fallbackName}) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return app_user.User.fromMap(doc.data()!..['id'] = uid);   }  
    if (fallbackEmail != null || fallbackName != null) {
      return app_user.User(id: uid,
        email: fallbackEmail ?? '',
        name: fallbackName ?? '',
        age: 0,height: 0,
        weight: 0, gender: '',
        fitnessGoal: '',  activityLevel: '',
        createdAt: DateTime.now(),
      ); }
    return null;
  }
  @override
  Future<bool> register({
    required String email, required String password, required String name,
    required int age,required double height,required double weight,
    required String gender,required String fitnessGoal,required String activityLevel,
  }) async {
    _isLoading = true; _errorMessage = null;
    notifyListeners();
    try {
      final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      final user = cred.user;
      if (user == null) throw Exception('Kullanıcı oluşturulamadı.');
      await user.updateDisplayName(name);
      await user.reload();
      final profile = app_user.User(
        id: user.uid,
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
      await _db.collection('users').doc(user.uid).set(profile.toMap(), SetOptions(merge: true));
      _currentUser = profile;
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } on fa.FirebaseAuthException catch (e) {
      _errorMessage = e.code;
    } catch (e) {
      _errorMessage = e.toString();    }
    _isLoading = false;
    notifyListeners();
    return false;  }
  @override
  Future<bool> login({
    required String email,
    required String password,
    bool rememberMe = true,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
      final user = cred.user;
      if (user == null) throw Exception('Giriş başarısız.');     
      _currentUser = await _loadProfile(user.uid, fallbackEmail: user.email, fallbackName: user.displayName)
          ?? app_user.User(
                id: user.uid,
                email: user.email ?? email,
                name: user.displayName ?? '',
                age: 0,height: 0, weight: 0,
                gender: '', fitnessGoal: '',  activityLevel: '',
                createdAt: DateTime.now(),   ); 
      await _db.collection('users').doc(user.uid).set({
        'email': _currentUser!.email,
        'name': _currentUser!.name,
        'createdAt': _currentUser!.createdAt,
      }, SetOptions(merge: true));
      _isAuthenticated = true;
      _rememberMe = rememberMe;
      _isLoading = false;
      notifyListeners();
      return true;
    } on fa.FirebaseAuthException catch (e) {
      _errorMessage = e.code;
    } catch (e) {
      _errorMessage = e.toString();    }
    _isLoading = false;
    notifyListeners();
    return false;  }
  @override
  Future<void> logout() async {
    await _auth.signOut();
    _currentUser = null;
    _isAuthenticated = false;
    _rememberMe = false;
    notifyListeners();  }
  @override
  Future<bool> updateUserProfile(app_user.User updatedUser) async {
    try {
      await _db.collection('users').doc(updatedUser.id).set(updatedUser.toMap(), SetOptions(merge: true));  
      final u = _auth.currentUser;
      if (u != null && updatedUser.name.isNotEmpty) {
        await u.updateDisplayName(updatedUser.name);
        await u.reload();      }
      _currentUser = updatedUser;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;   }  }
  @override
  Future<bool> resetPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } on fa.FirebaseAuthException catch (e) {
      _errorMessage = e.code;
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }
}
