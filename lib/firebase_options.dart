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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBAlPa-3F49zkPdigpCc6vE0GfUOQTXlj0',
    appId: '1:890196785571:web:230d0cab66029687df0216',
    messagingSenderId: '890196785571',
    projectId: 'appdev-mcommerce',
    authDomain: 'appdev-mcommerce.firebaseapp.com',
    storageBucket: 'appdev-mcommerce.firebasestorage.app',
    measurementId: 'G-1EV6ZP3VYJ',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBAlPa-3F49zkPdigpCc6vE0GfUOQTXlj0',
    appId: '1:890196785571:web:230d0cab66029687df0216',
    messagingSenderId: '890196785571',
    projectId: 'appdev-mcommerce',
    storageBucket: 'appdev-mcommerce.firebasestorage.app',
  );
}