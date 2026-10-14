import 'dart:convert';

import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:serverpod/serverpod.dart';

enum PushSendResult { sent, invalidToken, retry, rejected }

abstract interface class PushSender {
  Future<PushSendResult> send({
    required String token,
    required int notificationId,
    int unreadCount = 1,
  });
  void close();
}

/// FCM HTTP v1 credentials stay exclusively in Serverpod passwords.
class FirebasePushSender implements PushSender {
  FirebasePushSender(this.projectId, this.client, {http.Client? baseClient})
    : _baseClient = baseClient;

  final String projectId;
  final http.Client client;
  final http.Client? _baseClient;

  static Future<PushSender?> fromSession(Session session) async {
    final secret = session.passwords['firebaseServiceAccountJson']?.trim();
    if (secret == null || secret.isEmpty) return null;
    final json = jsonDecode(secret) as Map<String, dynamic>;
    final projectId = json['project_id'] as String;
    if (!RegExp(r'^[a-z][a-z0-9-]{4,62}$').hasMatch(projectId)) {
      throw const FormatException('Invalid Firebase project ID');
    }
    final base = http.Client();
    try {
      final client = await clientViaServiceAccount(
        ServiceAccountCredentials.fromJson(json),
        ['https://www.googleapis.com/auth/firebase.messaging'],
        baseClient: base,
      ).timeout(const Duration(seconds: 20));
      return FirebasePushSender(projectId, client, baseClient: base);
    } catch (_) {
      base.close();
      rethrow;
    }
  }

  @override
  Future<PushSendResult> send({
    required String token,
    required int notificationId,
    int unreadCount = 1,
  }) async {
    final response = await client
        .post(
          Uri.https(
            'fcm.googleapis.com',
            '/v1/projects/$projectId/messages:send',
          ),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'message': {
              'token': token,
              // Private details are fetched through authenticated Serverpod RPC.
              // A delayed OS notification on a shared device reveals no details.
              'notification': {
                'title': 'FieldNote',
                'body': unreadCount > 1
                    ? 'You have $unreadCount unread messages. Open FieldNote to view them.'
                    : 'You have a new update. Open FieldNote to view it.',
              },
              'data': {'notificationId': '$notificationId'},
              'android': {
                'priority': 'HIGH',
                'ttl': '86400s',
                'notification': {
                  'tag': 'fieldnote-$notificationId',
                  'notification_count': unreadCount,
                },
              },
            },
          }),
        )
        .timeout(const Duration(seconds: 20));
    return classifyFirebaseResponse(response.statusCode, response.body);
  }

  @override
  void close() {
    client.close();
    _baseClient?.close();
  }
}

/// Only an explicit FCM UNREGISTERED error invalidates a registration token.
/// INVALID_ARGUMENT may mean a malformed payload and must not delete tokens.
PushSendResult classifyFirebaseResponse(int status, String body) {
  if (status >= 200 && status < 300) return PushSendResult.sent;
  try {
    final json = jsonDecode(body) as Map<String, dynamic>;
    final error = json['error'] as Map<String, dynamic>?;
    final details = error?['details'] as List<dynamic>? ?? [];
    if (details.any(
      (detail) =>
          detail is Map &&
          detail['@type'] ==
              'type.googleapis.com/google.firebase.fcm.v1.FcmError' &&
          detail['errorCode'] == 'UNREGISTERED',
    )) {
      return PushSendResult.invalidToken;
    }
  } catch (_) {
    // Provider bodies can be HTML or empty; do not log tokens or response text.
  }
  return status == 401 ||
          status == 403 ||
          status == 408 ||
          status == 429 ||
          status >= 500
      ? PushSendResult.retry
      : PushSendResult.rejected;
}

abstract final class PushRuntime {
  static Future<PushSender?> Function(Session)? senderResolver;

  static Future<PushSender?> sender(Session session) =>
      senderResolver?.call(session) ?? FirebasePushSender.fromSession(session);

  static void reset() => senderResolver = null;
}
