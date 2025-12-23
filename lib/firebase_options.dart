import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBKEXoBQ2Gwm9Ktx2gA_OriL7p1aeLyf9s',
    appId: '1:123456789:web:abcdef',
    messagingSenderId: '123456789',
    projectId: 'digito-app',
    authDomain: 'digito-app.firebaseapp.com',
    storageBucket: 'digito-app.appspot.com',
  );
}
