import 'package:flutter/foundation.dart';
import '../models/user_model.dart' as app_user;

/// Tüm kimlik sağlayıcılarının (Firebase / Web) uyması gereken arayüz.
/// UI katmanı bu soyut tipe göre çalışır; somut sınıflar bunu 'extends' eder.
abstract class BaseAuthProvider extends ChangeNotifier {
  /// Uygulama içi kullanıcı modeli
  app_user.User? get currentUser;

  /// Kullanıcı giriş yapmış mı?
  bool get isAuthenticated;

  /// Asenkron işlem (login/register/update) sürüyor mu?
  bool get isLoading;

  /// "Beni hatırla" tercihi
  bool get rememberMe;

  /// Son hata mesajı (varsa)
  String? get errorMessage;

  /// Hata mesajını temizle
  void clearError();

  /// "Beni hatırla" ayarını set et
  void setRememberMe(bool value);

  /// Uygulama açılışında oturum durumunu kontrol et
  Future<void> checkAuthStatus();

  /// Kayıt ol (UI'da kullandığın imzayla birebir)
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

  /// Giriş yap
  Future<bool> login({
    required String email,
    required String password,
    bool rememberMe = true,
  });

  /// Çıkış yap
  Future<void> logout();

  /// Profil güncelle
  Future<bool> updateUserProfile(app_user.User updatedUser);

  /// Şifre sıfırlama
  Future<bool> resetPassword({required String email});
}
