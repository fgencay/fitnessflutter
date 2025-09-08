import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 👈 displayName için eklendi
import '../../providers/base_auth_provider.dart';
import '../../services/navigation_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();

  // Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  // Form data
  String _selectedGender = 'Erkek';
  String _selectedFitnessGoal = 'maintain';
  String _selectedActivityLevel = 'moderate';
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  int _currentPage = 0;

  final List<String> _genderOptions = ['Erkek', 'Kadın'];
  final Map<String, String> _fitnessGoals = {
    'lose_weight': 'Kilo Vermek',
    'maintain': 'Kilonu Korumak',
    'gain_weight': 'Kilo Almak',
  };
  final Map<String, String> _activityLevels = {
    'sedentary': 'Hareketsiz (Masa başı işi)',
    'light': 'Hafif Aktif (Haftada 1-3 gün)',
    'moderate': 'Orta Aktif (Haftada 3-5 gün)',
    'active': 'Aktif (Haftada 6-7 gün)',
    'very_active': 'Çok Aktif (Günde 2 kez)',
  };

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage == 0 && _validateFirstPage()) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else if (_currentPage == 1) {
      _register();
    }
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  bool _validateFirstPage() {
    return _emailController.text.isNotEmpty &&
        EmailValidator.validate(_emailController.text) &&
        _passwordController.text.length >= 6 &&
        _passwordController.text == _confirmPasswordController.text &&
        _nameController.text.isNotEmpty;
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    // Sayı parse'larını güvenli yapalım (hata fırlatmasın)
    final parsedAge = int.tryParse(_ageController.text);
    final parsedHeight = double.tryParse(_heightController.text);
    final parsedWeight = double.tryParse(_weightController.text);

    if (parsedAge == null || parsedAge < 16 || parsedAge > 100) {
      _showError('Geçerli bir yaş girin (16-100).');
      return;
    }
    if (parsedHeight == null || parsedHeight < 100 || parsedHeight > 250) {
      _showError('Geçerli bir boy girin (100-250 cm).');
      return;
    }
    if (parsedWeight == null || parsedWeight < 30 || parsedWeight > 300) {
      _showError('Geçerli bir kilo girin (30-300 kg).');
      return;
    }

    final authProvider = Provider.of<BaseAuthProvider>(context, listen: false);

    // Eski hatayı temizle
    authProvider.clearError();

    final success = await authProvider.register(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      name: _nameController.text.trim(),
      age: parsedAge,
      height: parsedHeight,
      weight: parsedWeight,
      gender: _selectedGender,
      fitnessGoal: _selectedFitnessGoal,
      activityLevel: _selectedActivityLevel,
    );

    if (!mounted) return;

    if (success) {
      // ✅ Kayıt başarılıysa displayName'i güncelle
      try {
        final fullName = _nameController.text.trim();
        final user = FirebaseAuth.instance.currentUser;
        if (user != null && fullName.isNotEmpty) {
          await user.updateDisplayName(fullName);
          await user.reload();
        }
      } catch (_) {
        // Sessiz geçelim; UI yine de devam etsin
      }

      // Dashboard'a yönlendir
      NavigationService.navigateAndClearStack(AppRoutes.dashboard);
    } else {
      // Provider'ın döndürdüğü spesifik hata mesajını göster
      final errorMessage =
          authProvider.errorMessage ?? 'Hesap oluşturulurken bir hata oluştu';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
          action: authProvider.errorMessage?.contains('zaten kullanımda') == true
              ? SnackBarAction(
                  label: 'Giriş Yap',
                  textColor: Colors.white,
                  onPressed: () {
                    NavigationService.navigateAndReplace(AppRoutes.login);
                  },
                )
              : null,
        ),
      );
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hesap Oluştur'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_currentPage == 0) {
              NavigationService.goBack();
            } else {
              _previousPage();
            }
          },
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: PageView(
            controller: _pageController,
            onPageChanged: (page) {
              setState(() {
                _currentPage = page;
              });
            },
            children: [
              _buildFirstPage(),
              _buildSecondPage(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFirstPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Kişisel Bilgiler',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Hesabınızı oluşturmak için gerekli bilgileri girin',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),

          // Name Field
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Ad Soyad',
              hintText: 'Adınızı ve soyadınızı girin',
              prefixIcon: Icon(Icons.person_outlined),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Ad soyad gerekli';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Email Field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'ornek@email.com',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email adresi gerekli';
              }
              if (!EmailValidator.validate(value)) {
                return 'Geçerli bir email adresi girin';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Password Field
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Şifre',
              hintText: 'En az 6 karakter',
              prefixIcon: const Icon(Icons.lock_outlined),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Şifre gerekli';
              }
              if (value.length < 6) {
                return 'Şifre en az 6 karakter olmalı';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Confirm Password Field
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            decoration: InputDecoration(
              labelText: 'Şifre Tekrar',
              hintText: 'Şifrenizi tekrar girin',
              prefixIcon: const Icon(Icons.lock_outlined),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Şifre tekrarı gerekli';
              }
              if (value != _passwordController.text) {
                return 'Şifreler eşleşmiyor';
              }
              return null;
            },
          ),
          const SizedBox(height: 40),

          // Next Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _nextPage,
              child: const Text(
                'Devam Et',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Login Link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Zaten hesabınız var mı? '),
              TextButton(
                onPressed: () {
                  NavigationService.navigateAndReplace(AppRoutes.login);
                },
                child: const Text('Giriş Yapın'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecondPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Fitness Bilgileri',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Size özel program oluşturmak için fiziksel bilgilerinizi girin',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),

          // Age Field
          TextFormField(
            controller: _ageController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Yaş',
              hintText: 'Yaşınızı girin',
              prefixIcon: Icon(Icons.cake_outlined),
              suffixText: 'yaş',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Yaş gerekli';
              }
              final age = int.tryParse(value);
              if (age == null || age < 16 || age > 100) {
                return 'Geçerli bir yaş girin (16-100)';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Gender Selection
          DropdownButtonFormField<String>(
            initialValue: _selectedGender,
            decoration: const InputDecoration(
              labelText: 'Cinsiyet',
              prefixIcon: Icon(Icons.person_outline),
            ),
            items: _genderOptions.map((gender) {
              return DropdownMenuItem(
                value: gender,
                child: Text(gender),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedGender = value!;
              });
            },
          ),
          const SizedBox(height: 20),

          // Height and Weight Row
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _heightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Boy',
                    hintText: '170',
                    prefixIcon: Icon(Icons.height),
                    suffixText: 'cm',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Boy gerekli';
                    }
                    final height = double.tryParse(value);
                    if (height == null || height < 100 || height > 250) {
                      return 'Geçerli boy (100-250 cm)';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: TextFormField(
                  controller: _weightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Kilo',
                    hintText: '70',
                    prefixIcon: const Icon(Icons.monitor_weight_outlined),
                    suffixText: 'kg',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Kilo gerekli';
                    }
                    final weight = double.tryParse(value);
                    if (weight == null || weight < 30 || weight > 300) {
                      return 'Geçerli kilo (30-300 kg)';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Fitness Goal
          DropdownButtonFormField<String>(
            initialValue: _selectedFitnessGoal,
            decoration: const InputDecoration(
              labelText: 'Fitness Hedefi',
              prefixIcon: Icon(Icons.flag_outlined),
            ),
            items: _fitnessGoals.entries.map((entry) {
              return DropdownMenuItem(
                value: entry.key,
                child: Text(entry.value),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedFitnessGoal = value!;
              });
            },
          ),
          const SizedBox(height: 20),

          // Activity Level
          DropdownButtonFormField<String>(
            initialValue: _selectedActivityLevel,
            decoration: const InputDecoration(
              labelText: 'Aktivite Seviyesi',
              prefixIcon: Icon(Icons.directions_run),
            ),
            items: _activityLevels.entries.map((entry) {
              return DropdownMenuItem(
                value: entry.key,
                child: Text(entry.value),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedActivityLevel = value!;
              });
            },
          ),
          const SizedBox(height: 40),

          // Register Button
          Consumer<BaseAuthProvider>(
            builder: (context, authProvider, child) {
              return SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: authProvider.isLoading ? null : _register,
                  child: authProvider.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Hesap Oluştur',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
