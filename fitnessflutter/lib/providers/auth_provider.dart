import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart' as app_user;

class AuthProvider extends ChangeNotifier {
  app_user.User? _currentUser;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  bool _rememberMe = true; // Default to remember user
  String? _errorMessage; // Add error message property

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  app_user.User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  bool get rememberMe => _rememberMe;
  String? get errorMessage => _errorMessage;

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Set remember me preference
  void setRememberMe(bool value) {
    _rememberMe = value;
    notifyListeners();
  }

  // Check if user is already logged in
  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      _rememberMe = prefs.getBool('remember_me') ?? true;

      // Check Firebase Auth state
      final firebaseUser = _firebaseAuth.currentUser;
      
      if (firebaseUser != null && _rememberMe) {
        // User is logged in with Firebase, get user data from Firestore
        final userDoc = await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .get();
            
        if (userDoc.exists) {
          final userData = userDoc.data()!;
          _currentUser = app_user.User.fromMap(userData);
          _isAuthenticated = true;
          
          debugPrint('User auto-logged in from Firebase: ${_currentUser?.email}');
        } else {
          debugPrint('User document not found in Firestore');
          _isAuthenticated = false;
          _currentUser = null;
        }
      } else {
        // Sign out if remember me is disabled
        if (!_rememberMe && firebaseUser != null) {
          await _firebaseAuth.signOut();
        }
        debugPrint('No Firebase user found or remember me disabled');
        _isAuthenticated = false;
        _currentUser = null;
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
    _errorMessage = null;
    notifyListeners();

    debugPrint('=== REGISTRATION PROCESS STARTED ===');
    debugPrint('Email: $email');
    debugPrint('Name: $name');
    debugPrint('Age: $age, Height: $height, Weight: $weight');

    try {
      debugPrint('Step 1: Creating Firebase Auth user...');
      
      // Create Firebase Auth user
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      debugPrint('Step 1: Firebase Auth user created successfully');
      
      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        debugPrint('Step 1: ERROR - Firebase user is null');
        _errorMessage = 'Kullanıcı oluşturulamadı. Lütfen tekrar deneyin.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      debugPrint('Step 1: Firebase user UID: ${firebaseUser.uid}');
      debugPrint('Step 2: Creating user object...');

      // Create user object
      final newUser = app_user.User(
        id: firebaseUser.uid,
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

      debugPrint('Step 2: User object created successfully');
      debugPrint('Step 3: Saving user data to Firestore...');
      debugPrint('Firestore path: users/${firebaseUser.uid}');
      debugPrint('User data: ${newUser.toMap()}');

      // Save user data to Firestore
      await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .set(newUser.toMap());

      debugPrint('Step 3: User data saved to Firestore successfully');
      debugPrint('Step 4: Setting current user and preferences...');

      // Set current user
      _currentUser = newUser;
      _isAuthenticated = true;

      // Save remember me preference
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('remember_me', true);
      _rememberMe = true;

      debugPrint('Step 4: All steps completed successfully');
      debugPrint('=== REGISTRATION PROCESS COMPLETED ===');
      debugPrint('New user registered and saved to Firebase: ${newUser.email}');

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint('=== FIREBASE AUTH ERROR ===');
      debugPrint('Error Code: ${e.code}');
      debugPrint('Error Message: ${e.message}');
      debugPrint('========================');
      
      // Handle specific Firebase Auth errors
      switch (e.code) {
        case 'email-already-in-use':
          _errorMessage = 'Bu e-posta adresi zaten kullanımda. Lütfen farklı bir e-posta deneyin veya giriş yapın.';
          break;
        case 'weak-password':
          _errorMessage = 'Şifre çok zayıf. En az 6 karakter olmalı.';
          break;
        case 'invalid-email':
          _errorMessage = 'Geçersiz e-posta adresi. Lütfen doğru bir e-posta girin.';
          break;
        case 'operation-not-allowed':
          _errorMessage = 'E-posta/şifre ile kayıt aktif değil. Firebase Console\'da Email/Password provider\'ini etkinleştirin.';
          break;
        case 'network-request-failed':
          _errorMessage = 'Ağ bağlantısı hatası. İnternet bağlantınızı kontrol edin.';
          break;
        default:
          _errorMessage = 'Firebase Auth hatası (${e.code}): ${e.message}';
      }
      
      _isLoading = false;
      notifyListeners();
      return false;
    } on FirebaseException catch (e) {
      debugPrint('=== FIRESTORE ERROR ===');
      debugPrint('Error Code: ${e.code}');
      debugPrint('Error Message: ${e.message}');
      debugPrint('=====================');
      
      // Handle Firestore specific errors
      switch (e.code) {
        case 'permission-denied':
          _errorMessage = 'Firestore yazma izni yok. Veritabanı kurallarını kontrol edin.\n\nTest kuralları:\nallow read, write: if true;';
          break;
        case 'unavailable':
          _errorMessage = 'Firestore hizmeti geçici olarak kullanılamıyor. Lütfen tekrar deneyin.';
          break;
        default:
          _errorMessage = 'Firestore hatası (${e.code}): ${e.message}';
      }
      
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('=== GENERAL ERROR ===');
      debugPrint('Error: $e');
      debugPrint('Error Type: ${e.runtimeType}');
      debugPrint('===================');
      
      _errorMessage = 'Beklenmeyen hata: $e\n\nLütfen \u015funları kontrol edin:\n1. İnternet bağlantısı\n2. Firebase yapılandırması\n3. Firestore kuralları';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Login user
  Future<bool> login({required String email, required String password, bool rememberMe = true}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Sign in with Firebase Auth
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        _errorMessage = 'Giriş yapılamadı. Lütfen tekrar deneyin.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Get user data from Firestore
      final userDoc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (!userDoc.exists) {
        await _firebaseAuth.signOut();
        _errorMessage = 'Kullanıcı bilgileri bulunamadı. Lütfen tekrar kayıt olun.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final userData = userDoc.data()!;
      _currentUser = app_user.User.fromMap(userData);
      _isAuthenticated = true;
      _rememberMe = rememberMe;

      // Save remember me preference
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('remember_me', rememberMe);

      if (rememberMe) {
        debugPrint('User logged in and session saved: ${_currentUser?.email}');
      } else {
        debugPrint('User logged in (not remembered): ${_currentUser?.email}');
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Error during login: ${e.code} - ${e.message}');
      
      // Handle specific Firebase Auth errors
      switch (e.code) {
        case 'user-not-found':
          _errorMessage = 'Bu e-posta adresi ile kayıtlı kullanıcı bulunamadı. Lütfen önce kayıt olun.';
          break;
        case 'wrong-password':
          _errorMessage = 'Yanlış şifre. Lütfen şifrenizi kontrol edin.';
          break;
        case 'invalid-email':
          _errorMessage = 'Geçersiz e-posta adresi. Lütfen doğru bir e-posta girin.';
          break;
        case 'user-disabled':
          _errorMessage = 'Bu hesap devre dışı bırakılmış. Lütfen destek ile iletişime geçin.';
          break;
        case 'too-many-requests':
          _errorMessage = 'Çok fazla başarısız deneme. Lütfen daha sonra tekrar deneyin.';
          break;
        default:
          _errorMessage = 'Giriş sırasında bir hata oluştu: ${e.message}';
      }
      
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('General error during login: $e');
      _errorMessage = 'Beklenmeyen bir hata oluştu. Lütfen internet bağlantınızı kontrol edin ve tekrar deneyin.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout user
  Future<void> logout() async {
    try {
      debugPrint('User logged out: ${_currentUser?.email}');

      // Sign out from Firebase
      await _firebaseAuth.signOut();

      // Clear local preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('remember_me', false);
      _rememberMe = false;

      _currentUser = null;
      _isAuthenticated = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error during logout: $e');
    }
  }

  // Update user profile
  Future<bool> updateUserProfile(app_user.User updatedUser) async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) return false;

      // Update in Firestore
      await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .update(updatedUser.toMap());

      // Update current user
      _currentUser = updatedUser;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error updating user profile: $e');
      return false;
    }
  }

  // Reset password (Firebase implementation)
  Future<bool> resetPassword({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      debugPrint('Error resetting password: $e');
      return false;
    }
  }
}