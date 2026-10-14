import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Public Firebase app identifiers; service-account credentials never belong here.
abstract final class FieldnoteFirebaseOptions {
  static FirebaseOptions? get currentPlatform =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android
      ? android
      : null;

  static const android = FirebaseOptions(
    messagingSenderId: "237416387779",
    projectId: "fieldnote-push-20261014",
    storageBucket: "fieldnote-push-20261014.firebasestorage.app",
    apiKey: "AIzaSyDvCS6R7kBXI82ri04SiW7zm9NXHGEJfjA",
    appId: "1:237416387779:android:3e758325a9a961e2fc3e76",
  );
}
