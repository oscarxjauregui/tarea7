// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAC_HrEkIE8vNki5DRy2gWqQLY29UtMXDo',
    appId: '1:861803670908:web:bc82d2190930cc2caac8f9',
    messagingSenderId: '861803670908',
    projectId: 'tarea7-pmsn2024',
    authDomain: 'tarea7-pmsn2024.firebaseapp.com',
    databaseURL: 'https://tarea7-pmsn2024-default-rtdb.firebaseio.com',
    storageBucket: 'tarea7-pmsn2024.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA1_-bc1Ii8W4IZXtGFiJsJtwnsrnNB9n0',
    appId: '1:861803670908:android:9ca23755afb4548caac8f9',
    messagingSenderId: '861803670908',
    projectId: 'tarea7-pmsn2024',
    databaseURL: 'https://tarea7-pmsn2024-default-rtdb.firebaseio.com',
    storageBucket: 'tarea7-pmsn2024.appspot.com',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAC_HrEkIE8vNki5DRy2gWqQLY29UtMXDo',
    appId: '1:861803670908:web:2542449ef1c2b085aac8f9',
    messagingSenderId: '861803670908',
    projectId: 'tarea7-pmsn2024',
    authDomain: 'tarea7-pmsn2024.firebaseapp.com',
    databaseURL: 'https://tarea7-pmsn2024-default-rtdb.firebaseio.com',
    storageBucket: 'tarea7-pmsn2024.appspot.com',
  );
}
