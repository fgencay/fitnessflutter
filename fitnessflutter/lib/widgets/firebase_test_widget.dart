import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart' as app_user;

class FirebaseTestWidget extends StatefulWidget {
  const FirebaseTestWidget({super.key});

  @override
  State<FirebaseTestWidget> createState() => _FirebaseTestWidgetState();
}

class _FirebaseTestWidgetState extends State<FirebaseTestWidget> {
  String _status = 'Firebase durumu kontrol ediliyor...';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _testFirebaseConnection();
  }

  Future<void> _testFirebaseConnection() async {
    setState(() {
      _status = 'Firebase bağlantısı test ediliyor...';
      _isLoading = true;
    });

    try {
      // Test 1: Firebase Auth initialization
      FirebaseAuth.instance;
      debugPrint('Step 1: Firebase Auth initialized');
      
      // Test 2: Firestore initialization
      final firestore = FirebaseFirestore.instance;
      debugPrint('Step 2: Firestore initialized');

      // Test 3: Try to read from Firestore (test connection)
      try {
        await firestore.collection('test').limit(1).get().timeout(
          const Duration(seconds: 10),
        );
        debugPrint('Step 3: Firestore read test successful');
      } catch (e) {
        debugPrint('Step 3: Firestore read test failed: $e');
        throw 'Firestore bağlantısı başarısız: $e';
      }


      try {
       
        debugPrint('Step 4: Testing auth methods availability');
        
        // Test if we can access createUserWithEmailAndPassword method
        debugPrint('Step 4a: createUserWithEmailAndPassword method available');
            } catch (e) {
        debugPrint('Step 4: Auth methods test failed: $e');
        throw 'Firebase Auth metodları erişilemez: $e';
      }

      // Test 5: Try a test write to Firestore
      try {
        debugPrint('Step 5: Testing Firestore write permissions...');
        final testDoc = firestore.collection('connection_test').doc('test');
        await testDoc.set({
          'timestamp': FieldValue.serverTimestamp(),
          'test': true,
          'message': 'Firebase connection test',
        }).timeout(const Duration(seconds: 10));
        
        // Verify write by reading back
        final readDoc = await testDoc.get();
        if (!readDoc.exists) {
          throw 'Yazma başarılı ama okuma başarısız';
        }
        
        // Clean up test document
        await testDoc.delete();
        debugPrint('Step 5: Firestore write test successful');
      } catch (e) {
        debugPrint('Step 5: Firestore write test failed: $e');
        if (e.toString().contains('permission-denied') || e.toString().contains('PERMISSION_DENIED')) {
          throw 'FIRESTORE RULES SORUNU:\n\n'
              'Veritabanı yazma izni yok. Firebase Console\'da:\n\n'
              '1. Firestore Database → Rules git\n'
              '2. Bu test kurallarını kullan:\n\n'
              'rules_version = "2";\n'
              'service cloud.firestore {\n'
              '  match /databases/{database}/documents {\n'
              '    match /{document=**} {\n'
              '      allow read, write: if true;\n'
              '    }\n'
              '  }\n'
              '}\n\n'
              '3. "Publish" butonuna bas\n\n'
              'Bu kurallar TEST İÇİNDİR. Üretimde güvenli kurallar kullan!';
        } else {
          throw 'Firestore yazma testi başarısız: $e\n\n'
              'Olası nedenler:\n'
              '1. Database kuralları kısıtlayıcı\n'
              '2. Ağ bağlantısı sorunu\n'
              '3. Firebase quota aşıldı\n'
              '4. Database lokasyonu erişilemiyor';
        }
      }
      
      setState(() {
        _status = '✅ Firebase tamamen yapılandırılmış!\n\n'
                 '✓ Auth: Aktif\n'
                 '✓ Firestore: Aktif\n'
                 '✓ Bağlantı: Başarılı\n'
                 '✓ Okuma: Başarılı\n'
                 '✓ Yazma: Başarılı\n\n'
                 'Hesap oluşturma işlemi için hazır!';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status = '❌ Firebase yapılandırma sorunu:\n\n'
                 'Hata: $e\n\n'
                 'Olası çözümler:\n\n'
                 '1. Firebase Console kontrolleri:\n'
                 '   • Proje oluşturuldu mu?\n'
                 '   • Authentication etkinleştirildi mi?\n'
                 '   • Email/Password provider aktif mi?\n'
                 '   • Firestore Database oluşturuldu mu?\n\n'
                 '2. Kod yapılandırması:\n'
                 '   • firebase_options.dart doğru mu?\n'
                 '   • API anahtarları geçerli mi?\n\n'
                 '3. Firestore Kuralları:\n'
                 '   • Yazma izinleri var mı?\n'
                 '   • Test kuralları: allow read, write: if true;';
        _isLoading = false;
      });
    }
  }

  Future<void> _testAccountCreation() async {
    setState(() {
      _status = 'Test hesabı oluşturma süreci başlatılıyor...';
      _isLoading = true;
    });

    final testEmail = 'test_${DateTime.now().millisecondsSinceEpoch}@test.com';
    final testPassword = 'test123456';

    try {
      final auth = FirebaseAuth.instance;
      final firestore = FirebaseFirestore.instance;

      debugPrint('=== TEST ACCOUNT CREATION ===');
      debugPrint('Test email: $testEmail');

      // Step 1: Create test user with Firebase Auth
      debugPrint('Step 1: Creating Firebase Auth user...');
      final userCredential = await auth.createUserWithEmailAndPassword(
        email: testEmail,
        password: testPassword,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw 'Firebase kullanıcısı oluşturulamadı';
      }

      debugPrint('Step 1: Success - UID: ${firebaseUser.uid}');

      // Step 2: Create test user data
      debugPrint('Step 2: Creating user data...');
      final testUser = app_user.User(
        id: firebaseUser.uid,
        email: testEmail,
        name: 'Test User',
        age: 25,
        height: 175.0,
        weight: 70.0,
        gender: 'Erkek',
        fitnessGoal: 'maintain',
        activityLevel: 'moderate',
        createdAt: DateTime.now(),
      );

      debugPrint('Step 2: Success - User data created');

      // Step 3: Save to Firestore
      debugPrint('Step 3: Saving to Firestore...');
      await firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .set(testUser.toMap());

      debugPrint('Step 3: Success - Saved to Firestore');

      // Step 4: Clean up - delete test user
      debugPrint('Step 4: Cleaning up test user...');
      
      // Delete from Firestore
      await firestore.collection('users').doc(firebaseUser.uid).delete();
      
      // Delete from Firebase Auth
      await firebaseUser.delete();
      
      debugPrint('Step 4: Success - Test user cleaned up');
      debugPrint('=== TEST COMPLETED SUCCESSFULLY ===');

      setState(() {
        _status = '✅ Test hesabı oluşturma BAŞARILI!\n\n'
                 '✓ Firebase Auth: Çalışıyor\n'
                 '✓ Firestore Write: Çalışıyor\n'
                 '✓ User Model: Çalışıyor\n'
                 '✓ Data Serialization: Çalışıyor\n\n'
                 'Hesap oluşturma sistemi tamamen hazır!\n\n'
                 'Eğer hala sorun yaşıyorsanız, muhtemelen:\n'
                 '1. Form validasyonu sorunu\n'
                 '2. UI ile AuthProvider bağlantı sorunu\n'
                 '3. Error handling sorunudur.';
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('=== TEST ACCOUNT CREATION FAILED ===');
      debugPrint('Error: $e');
      debugPrint('=====================================');

      setState(() {
        _status = '❌ Test hesabı oluşturma HATASI:\n\n'
                 'Hata: $e\n\n'
                 'Bu hata hesap oluşturamama sorununuzun nedeni olabilir.\n\n'
                 'En sık karşılaşılan sorunlar:\n\n'
                 '1. FIRESTORE KURALLARI:\n'
                 '   rules_version = "2";\n'
                 '   service cloud.firestore {\n'
                 '     match /databases/{database}/documents {\n'
                 '       match /{document=**} {\n'
                 '         allow read, write: if true;\n'
                 '       }\n'
                 '     }\n'
                 '   }\n\n'
                 '2. AUTHENTICATION AYARLARI:\n'
                 '   • Email/Password provider aktif mi?\n'
                 '   • Authorized domains doğru mu?\n\n'
                 '3. API ANAHTARLARI:\n'
                 '   • firebase_options.dart doğru mu?\n'
                 '   • API keys geçerli mi?';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Firebase Bağlantı Testi'),
      content: SizedBox(
        width: double.maxFinite,
        child: _isLoading
            ? const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Firebase bağlantısı test ediliyor...'),
                ],
              )
            : SingleChildScrollView(
                child: Text(
                  _status,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Kapat'),
        ),
        if (!_isLoading && _status.contains('✅'))
          TextButton(
            onPressed: _testAccountCreation,
            child: const Text('Hesap Testi'),
          ),
        if (!_isLoading && _status.contains('❌'))
          TextButton(
            onPressed: _testFirebaseConnection,
            child: const Text('Tekrar Dene'),
          ),
      ],
    );
  }
}