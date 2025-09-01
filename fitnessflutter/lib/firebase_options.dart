import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// IMPORTANT: This file contains placeholder values. You MUST replace them with your actual Firebase project configuration.
///
/// To get your Firebase configuration:
/// 1. Go to https://console.firebase.google.com/
/// 2. Create a new project or select existing project
/// 3. Enable Authentication -> Email/Password
/// 4. Enable Firestore Database
/// 5. Go to Project Settings -> General
/// 6. Add your app for each platform you want to support
/// 7. Copy the configuration values and replace the placeholder values below
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.windows:
        return windows;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA_G0WOTlwEZXTE2g6jLgkgWkf5hkblR9k',
    appId: '1:650860941065:web:ccb416a6660c81fffb0dd8',
    messagingSenderId: '650860941065',
    projectId: 'fitlife-fitness-uygulamasi',
    authDomain: 'fitlife-fitness-uygulamasi.firebaseapp.com',
    storageBucket: 'fitlife-fitness-uygulamasi.firebasestorage.app',
    measurementId: 'G-8XC21CMLML',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDVXQFHet290EGq4Xv6qC9VEsb9PcJbXdk',
    appId: '1:650860941065:android:79f8c6bd3a5ba8adfb0dd8',
    messagingSenderId: '650860941065',
    projectId: 'fitlife-fitness-uygulamasi',
    storageBucket: 'fitlife-fitness-uygulamasi.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
    iosBundleId: 'com.example.fitnessflutter',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'YOUR_WINDOWS_API_KEY',
    appId: 'YOUR_WINDOWS_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    authDomain: 'YOUR_PROJECT_ID.firebaseapp.com',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
  );
}