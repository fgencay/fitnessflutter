import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'

    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
          
          'DefaultFirebaseOptions have not been configured for this platform.',  );  }  }
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA_G0WOTlwEZXTE2g6jLgkgWkf5hkblR9k',
    appId: '1:650860941065:web:ccb416a6660c81fffb0dd8',
    messagingSenderId: '650860941065',
    projectId: 'fitlife-fitness-uygulamasi',
    authDomain: 'fitlife-fitness-uygulamasi.firebaseapp.com',
    storageBucket: 'fitlife-fitness-uygulamasi.firebasestorage.app',
    measurementId: 'G-8XC21CMLML',  );
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDVXQFHet290EGq4Xv6qC9VEsb9PcJbXdk',
    appId: '1:650860941065:android:79f8c6bd3a5ba8adfb0dd8',
    messagingSenderId: '650860941065',
    projectId: 'fitlife-fitness-uygulamasi',
    storageBucket: 'fitlife-fitness-uygulamasi.firebasestorage.app',  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
    iosBundleId: 'com.example.fitnessflutter',  );
  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyA_G0WOTlwEZXTE2g6jLgkgWkf5hkblR9k',
    appId: '1:650860941065:web:8de3a6a0f61d1ceafb0dd8',
    messagingSenderId: '650860941065',
    projectId: 'fitlife-fitness-uygulamasi',
    authDomain: 'fitlife-fitness-uygulamasi.firebaseapp.com',
    storageBucket: 'fitlife-fitness-uygulamasi.firebasestorage.app',
    measurementId: 'G-SQ814X592Z',
  );

}