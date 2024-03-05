// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyDsCFVjR2D-gk5_xTODK3Gmvqvj-um4pIM',
    appId: '1:751992999241:web:f1f627abf7c12a3f7ade98',
    messagingSenderId: '751992999241',
    projectId: 'drawli-ebe40',
    authDomain: 'drawli-ebe40.firebaseapp.com',
    storageBucket: 'drawli-ebe40.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBHRBy0y3WPTBz-RxyN7vk2B4JVxkDqobc',
    appId: '1:751992999241:android:1ea6f99817dddfe47ade98',
    messagingSenderId: '751992999241',
    projectId: 'drawli-ebe40',
    storageBucket: 'drawli-ebe40.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDjmEJCHFfSYzZii1Tl2siilQP4WUFLOm0',
    appId: '1:751992999241:ios:6a876381330dd0137ade98',
    messagingSenderId: '751992999241',
    projectId: 'drawli-ebe40',
    storageBucket: 'drawli-ebe40.appspot.com',
    iosBundleId: 'com.drawli.drawliFlutter.RunnerTests',
  );
}
