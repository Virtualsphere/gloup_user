// File generated manually from native Firebase config files.
// android/app/google-services.json  (package: com.gloup.userapp)
// ios/Runner/GoogleService-Info.plist

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDF3Q4S3f08WL3BNTNMceU9YhlFFOJIZDc',
    appId: '1:719761552533:android:5d02d553c84fdcb08a979c',
    messagingSenderId: '719761552533',
    projectId: 'gloup-a3374',
    storageBucket: 'gloup-a3374.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDDg_6YVL3pgpdFsPZDPH_6ZR0yO_cvvwA',
    appId: '1:719761552533:ios:2a11bf9bd143adbb8a979c',
    messagingSenderId: '719761552533',
    projectId: 'gloup-a3374',
    storageBucket: 'gloup-a3374.firebasestorage.app',
    iosClientId:
        '719761552533-g5sj28vuolgnlt5nna3jbd5ijcphcujv.apps.googleusercontent.com',
    iosBundleId: 'com.gloup.userapp',
  );
}
