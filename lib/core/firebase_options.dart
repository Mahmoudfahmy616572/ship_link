import 'package:firebase_core/firebase_core.dart';

/// Firebase config is injected at build time via `--dart-define-from-file=.env`.
/// These values are client-side identifiers (not secrets) — real protection
/// comes from Firebase Security Rules + SHA-1 app restriction in the console.
class DefaultFirebaseOptions {
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: String.fromEnvironment('FIREBASE_API_KEY', defaultValue: ''),
    appId: String.fromEnvironment('FIREBASE_APP_ID', defaultValue: ''),
    messagingSenderId:
        String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID', defaultValue: ''),
    projectId: String.fromEnvironment('FIREBASE_PROJECT_ID', defaultValue: ''),
    storageBucket:
        String.fromEnvironment('FIREBASE_STORAGE_BUCKET', defaultValue: ''),
  );

  static FirebaseOptions get currentPlatform => android;
}
