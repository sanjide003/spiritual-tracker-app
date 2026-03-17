// 📂 File: lib/firebase_options.dart
// താങ്കൾ നൽകിയ ഡാറ്റ ഉപയോഗിച്ചുള്ള ഫയർബേസ് കണക്ഷൻ

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      apiKey: 'AIzaSyBJZb0VTShAJMIbC4vH-xTW8W0JZzxI3NI',
      appId: '1:567121775040:web:de1ed2ce4c18221afb2025',
      messagingSenderId: '567121775040',
      projectId: 'day-to-af6e4',
      authDomain: 'day-to-af6e4.firebaseapp.com',
      storageBucket: 'day-to-af6e4.firebasestorage.app',
      measurementId: 'G-EWQ0MS8233',
    );
  }
}