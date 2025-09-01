import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreRulesHelper extends StatelessWidget {
  const FirestoreRulesHelper({super.key});

  Future<void> _testFirestoreRules() async {
    try {
      final firestore = FirebaseFirestore.instance;
      
      // Try to write to a test collection
      await firestore.collection('rules_test').doc('test').set({
        'test': true,
        'timestamp': FieldValue.serverTimestamp(),
      });
      
      // Clean up
      await firestore.collection('rules_test').doc('test').delete();
      
      debugPrint('Firestore rules test: SUCCESS');
    } catch (e) {
      debugPrint('Firestore rules test: FAILED - $e');
      rethrow;
    }
  }

  void _copyRulesToClipboard() {
    const testRules = '''rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}''';
    
    Clipboard.setData(const ClipboardData(text: testRules));
  }

  void _copyProductionRulesToClipboard() {
    const productionRules = '''rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}''';
    
    Clipboard.setData(const ClipboardData(text: productionRules));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Firestore Rules Yardımcısı'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Firebase yazma testi başarısız oluyorsa, Firestore Database kuralları çok kısıtlayıcı olabilir.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              
              const Text(
                '1. TEST KURALLARI (Geçici):',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '''rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}''',
                  style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
              
              const SizedBox(height: 8),
              
              ElevatedButton(
                onPressed: () {
                  _copyRulesToClipboard();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Test kuralları kopyalandı!')),
                  );
                },
                child: const Text('Test Kurallarını Kopyala'),
              ),
              
              const SizedBox(height: 16),
              
              const Text(
                '2. ÜRETİM KURALLARI (Güvenli):',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '''rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}''',
                  style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
              
              const SizedBox(height: 8),
              
              ElevatedButton(
                onPressed: () {
                  _copyProductionRulesToClipboard();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Üretim kuralları kopyalandı!')),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('Üretim Kurallarını Kopyala'),
              ),
              
              const SizedBox(height: 16),
              
              const Text(
                '3. KURALLARI UYGULAMA:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              
              const Text(
                '• Firebase Console → Firestore Database → Rules\n'
                '• Kuralları yapıştır\n'
                '• "Publish" butonuna bas\n'
                '• Firebase Test\'i tekrar çalıştır',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Kapat'),
        ),
        ElevatedButton(
          onPressed: () async {
            try {
              await _testFirestoreRules();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Firestore yazma testi başarılı!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('❌ Firestore yazma testi başarısız: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
          child: const Text('Rules Testi'),
        ),
      ],
    );
  }
}