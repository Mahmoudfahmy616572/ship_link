import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAOBDqUFz2usbjWdeKZg0hwssVNggVMX6Y',
    appId: '1:872096044047:android:feb0a6ce9404989e6fbf7a',
    messagingSenderId: '872096044047',
    projectId: 'shiplink-9159d',
    storageBucket: 'shiplink-9159d.firebasestorage.app',
  );

  static FirebaseOptions get currentPlatform => android;
}
