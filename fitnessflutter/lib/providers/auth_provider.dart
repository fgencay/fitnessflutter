import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart' as app_user;
import 'base_auth_provider.dart';

class AuthProvider extends BaseAuthProvider {
  //giriş, kayıt için
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //kullanıcı bilgileri için
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  bool _rememberMe = false;
  @override
  bool get rememberMe => _rememberMe;
  @override
  void setRememberMe(bool value) {
    _rememberMe = value;
    notifyListeners();
  }
  app_user.User? _currentUser;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;
  @override
  app_user.User? get currentUser => _currentUser;
  @override
  bool get isAuthenticated => _isAuthenticated;
  @override
  bool get isLoading => _isLoading;
  @override
  String? get errorMessage => _errorMessage;
  @override
  void clearError() { _errorMessage = null; notifyListeners(); }  
  @override
  Future<void> checkAuthStatus() async {
    _isLoading = true; _errorMessage = null; notifyListeners();
    try {
      final u = _auth.currentUser;
      if (u == null) {
        _isAuthenticated = false;
        _currentUser = null;
      } else {
        _isAuthenticated = true;
        final snap = await _db.collection('users').doc(u.uid).get();
        _currentUser = snap.data() != null
            ? app_user.User.fromMap(snap.data()!..['id'] = u.uid)
            : app_user.User(
                id: u.uid,
                email: u.email ?? '',
                name: u.displayName ?? '',
                age: 0, height: 0, weight: 0,
                gender: '', fitnessGoal: '', activityLevel: '',
                createdAt: DateTime.now(),
              );}
    } catch (e) {
      _errorMessage = 'Oturum kontrolü başarısız.';
      _isAuthenticated = false;
      _currentUser = null;
    } finally {
      _isLoading = false; notifyListeners();
    }
  }
  @override
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
    _isLoading = true; _errorMessage = null; notifyListeners();
    try {
      final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      final u = cred.user;
      if (u == null) throw FirebaseAuthException(code: 'unknown', message: 'Kullanıcı oluşturulamadı');   
      await u.updateDisplayName(name);
      await u.reload();
      final user = app_user.User(
        id: u.uid,
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
      await _db.collection('users').doc(u.uid).set(user.toMap(), SetOptions(merge: true));
      _currentUser = user;
      _isAuthenticated = true;
      _isLoading = false; notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapAuthError(e);
    } catch (_) {
      _errorMessage = 'Kayıt sırasında beklenmeyen bir hata oluştu.';
    }
    _isLoading = false; notifyListeners();
    return false;
  }
  @override
  Future<bool> login({
    required String email,
    required String password,
    bool rememberMe = true,
  }) async {
    _isLoading = true; _errorMessage = null; notifyListeners();
    try {
      final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
      final u = cred.user;
      if (u == null) throw FirebaseAuthException(code: 'unknown', message: 'Giriş başarısız');
      final snap = await _db.collection('users').doc(u.uid).get();
      final data = snap.data() ?? {
        'email': u.email ?? email,
        'name': u.displayName ?? '',
        'createdAt': DateTime.now(),
      };
      _currentUser = app_user.User.fromMap({...data, 'id': u.uid}); 
      await _db.collection('users').doc(u.uid).set({
        'email': _currentUser!.email,
        'name': _currentUser!.name,
        'createdAt': _currentUser!.createdAt,
      }, SetOptions(merge: true));
      _isAuthenticated = true;
      _isLoading = false; notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapAuthError(e);
    } catch (_) {
      _errorMessage = 'Giriş sırasında beklenmeyen bir hata oluştu.';
    }
    _isLoading = false; notifyListeners();
    return false;
  }
  @override
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } finally {
      _currentUser = null;
      _isAuthenticated = false;
      notifyListeners();
    }
  }
  @override
  Future<bool> updateUserProfile(app_user.User updatedUser) async {
    try {
      final u = _auth.currentUser;
      if (u == null) return false;
      await _db.collection('users').doc(u.uid).set(updatedUser.toMap(), SetOptions(merge: true));
      if (updatedUser.name.isNotEmpty && (u.displayName ?? '') != updatedUser.name) {
        await u.updateDisplayName(updatedUser.name);
        await u.reload();
      }
      _currentUser = updatedUser;
      notifyListeners();
      return true;
    } catch (_) {
      _errorMessage = 'Profil güncellenemedi.';
      notifyListeners();
      return false;
    }
  }
  @override
  Future<bool> resetPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapAuthError(e);
      return false;
    } catch (_) {     
      return false;
    }
  }
  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use': return 'Bu e-posta zaten kullanımda.';
      case 'weak-password':        return 'Şifre çok zayıf (min. 6 karakter).';
      case 'invalid-email':        return 'Geçersiz e-posta adresi.';
      case 'operation-not-allowed':return 'Bu giriş yöntemi devre dışı.';
      case 'user-not-found':       return 'Kullanıcı bulunamadı.';
      case 'wrong-password':       return 'Yanlış şifre.';
      case 'user-disabled':        return 'Hesap devre dışı.';
      case 'too-many-requests':    return 'Çok fazla deneme. Daha sonra tekrar deneyin.';
      default:                     return 'İşlem başarısız: ${e.code}';
    }
  }
}
