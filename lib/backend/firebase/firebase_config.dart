import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

Future initFirebase() async {
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyDtomu7ISRSEGdeXfvsL-8PWXNrNDQHB4U",
            authDomain: "harmony-hub-6654c.firebaseapp.com",
            projectId: "harmony-hub-6654c",
            storageBucket: "harmony-hub-6654c.appspot.com",
            messagingSenderId: "554385304914",
            appId: "1:554385304914:web:983759cf02e9c8e8475e8b",
            measurementId: "G-W7G0DRCVWM"));
  } else {
    await Firebase.initializeApp();
  }
}
