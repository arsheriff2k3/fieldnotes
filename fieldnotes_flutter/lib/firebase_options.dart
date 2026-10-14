import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Load client settings from an ignored file via --dart-define-from-file.
/// Server service-account credentials must never be supplied to Flutter.
abstract final class FieldnoteFirebaseOptions {
  static FirebaseOptions? get currentPlatform =>
      !kIsWeb &&
          defaultTargetPlatform == TargetPlatform.android &&
          android.apiKey.isNotEmpty &&
          android.appId.isNotEmpty &&
          android.messagingSenderId.isNotEmpty &&
          android.projectId.isNotEmpty
      ? android
      : null;

  static const android = FirebaseOptions(
    apiKey: String.fromEnvironment('FIREBASE_ANDROID_API_KEY'),
    appId: String.fromEnvironment('FIREBASE_ANDROID_APP_ID'),
    messagingSenderId: String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID'),
    projectId: String.fromEnvironment('FIREBASE_PROJECT_ID'),
    storageBucket: String.fromEnvironment('FIREBASE_STORAGE_BUCKET'),
  );
}
