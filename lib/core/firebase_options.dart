import 'package:firebase_core/firebase_core.dart';

/// Firebase config is injected at build time via `--dart-define-from-file=.env`.
/// These values are client-side identifiers (not secrets) — real protection
/// comes from Firebase Security Rules + SHA-1 app restriction in the console.
/// Sensible defaults are provided so notifications work out-of-the-box when the
/// dart-define is omitted. `--dart-define` still overrides these.
class DefaultFirebaseOptions {
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: String.fromEnvironment(
      'FIREBASE_API_KEY',
      defaultValue: 'AIzaSyAOBDqUFz2usbjWdeKZg0hwssVNggVMX6Y',
    ),
    appId: String.fromEnvironment(
      'FIREBASE_APP_ID',
      defaultValue: '1:872096044047:android:ff2f0d91d46d4d706fbf7a',
    ),
    messagingSenderId: String.fromEnvironment(
      'FIREBASE_MESSAGING_SENDER_ID',
      defaultValue: '872096044047',
    ),
    projectId: String.fromEnvironment(
      'FIREBASE_PROJECT_ID',
      defaultValue: 'shiplink-9159d',
    ),
    storageBucket: String.fromEnvironment(
      'FIREBASE_STORAGE_BUCKET',
      defaultValue: 'shiplink-9159d.firebasestorage.app',
    ),
  );

  static FirebaseOptions get currentPlatform => android;
}
