import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_options.dart';
import '../repositories/fieldnote_repository.dart';

@pragma('vm:entry-point')
Future<void> fieldnotePushBackgroundHandler(RemoteMessage message) async {
  // FCM displays the generic notification payload in the background. Personal
  // inbox data is always fetched through Serverpod after authentication.
}

class FirebasePushService {
  FirebasePushService._();
  static final instance = FirebasePushService._();

  final incoming = ValueNotifier<int?>(null);
  final opened = ValueNotifier<int?>(null);
  bool available = false;
  bool enabled = false;
  FieldnoteRepository? _repository;
  String? _userId;
  String? _token;
  int _generation = 0;
  StreamSubscription<String>? _tokenSubscription;
  Future<void> _registration = Future.value();

  Future<void> initialize() async {
    final options = FieldnoteFirebaseOptions.currentPlatform;
    if (options == null) return;
    try {
      await Firebase.initializeApp(options: options);
      available = await FirebaseMessaging.instance.isSupported();
      if (!available) return;
      FirebaseMessaging.onBackgroundMessage(fieldnotePushBackgroundHandler);
      FirebaseMessaging.onMessage.listen((message) {
        incoming.value = notificationIdFromData(message.data);
      });
      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        opened.value = notificationIdFromData(message.data);
      });
      final initial = await FirebaseMessaging.instance.getInitialMessage();
      opened.value = initial == null
          ? null
          : notificationIdFromData(initial.data);
    } catch (_) {
      available = false;
      // Firebase configuration must not prevent sign-in or the inbox working.
    }
  }

  Future<void> attach(FieldnoteRepository repository, String userId) async {
    if (!available || _userId == userId) return;
    _repository = repository;
    _userId = userId;
    final generation = ++_generation;
    await _tokenSubscription?.cancel();
    _tokenSubscription = FirebaseMessaging.instance.onTokenRefresh.listen((
      token,
    ) {
      unawaited(
        _queueRegistration(token, generation).catchError((Object _) {}),
      );
    });
    try {
      final settings = await FirebaseMessaging.instance
          .getNotificationSettings();
      if (generation != _generation) return;
      enabled = _authorized(settings);
      if (enabled) {
        await _registerCurrentToken(generation);
      }
    } catch (_) {
      // Retried on the next resume or explicit Enable notifications action.
    }
  }

  Future<void> enable() async {
    if (!available) throw StateError('push_unavailable');
    final settings = await FirebaseMessaging.instance.requestPermission();
    enabled = _authorized(settings);
    if (!enabled) throw StateError('push_permission_denied');
    await _registerCurrentToken(_generation);
  }

  Future<void> resume() async {
    if (!available || _repository == null) return;
    try {
      final settings = await FirebaseMessaging.instance
          .getNotificationSettings();
      enabled = _authorized(settings);
      if (enabled) {
        await _registerCurrentToken(_generation);
      } else if (_token != null) {
        await _repository!.unregisterPushDevice(_token!);
        _token = null;
      }
    } catch (_) {
      // The authenticated inbox remains usable offline or without push.
    }
  }

  Future<void> _registerCurrentToken(int generation) async {
    final token = await FirebaseMessaging.instance.getToken().timeout(
      const Duration(seconds: 20),
    );
    if (token == null) throw StateError('push_token_unavailable');
    await _queueRegistration(token, generation);
  }

  Future<void> _queueRegistration(String token, int generation) {
    final operation = _registration.catchError((Object _) {}).then((_) async {
      final repository = _repository;
      if (generation != _generation || repository == null || !enabled) return;
      if (_token != null && _token != token) {
        await repository.unregisterPushDevice(_token!);
      }
      await repository.registerPushDevice(
        token,
        'android',
      );
      if (generation == _generation) _token = token;
    });
    // Keep later registrations alive after a failed RPC; explicit enable still
    // returns the error to the screen. Background refresh never throws uncaught.
    _registration = operation.catchError((Object _) {});
    return operation;
  }

  Future<void> unregister({bool allDevices = false}) async {
    ++_generation;
    await _tokenSubscription?.cancel();
    _tokenSubscription = null;
    await _registration;
    final repository = _repository;
    _repository = null;
    _userId = null;
    final token = _token;
    _token = null;
    enabled = false;
    incoming.value = null;
    opened.value = null;
    try {
      if (repository != null) {
        if (allDevices) {
          await repository.unregisterAllPushDevices();
        } else if (token != null) {
          await repository.unregisterPushDevice(token);
        }
      }
    } finally {
      if (available) {
        try {
          await FirebaseMessaging.instance.deleteToken();
        } catch (_) {}
      }
    }
  }

  /// Stop receiving personal foreground state when the authenticated shell
  /// disappears. Explicit sign-out unregisters before clearing auth tokens.
  void detach() {
    ++_generation;
    _tokenSubscription?.cancel();
    _tokenSubscription = null;
    _repository = null;
    _userId = null;
    enabled = false;
    incoming.value = null;
  }

  static bool _authorized(NotificationSettings settings) =>
      settings.authorizationStatus == AuthorizationStatus.authorized ||
      settings.authorizationStatus == AuthorizationStatus.provisional;
}

int? notificationIdFromData(Map<String, dynamic> data) {
  final id = int.tryParse('${data['notificationId']}');
  return id != null && id > 0 ? id : null;
}
