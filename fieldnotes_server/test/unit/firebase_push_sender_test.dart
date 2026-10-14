import 'dart:convert';

import 'package:fieldnotes_server/src/fieldnotes/services/firebase_push_sender.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

void main() {
  test(
    'FCM request contains only a generic alert and an inbox identifier',
    () async {
      final sender = FirebasePushSender(
        'fieldnote-test',
        MockClient((request) async {
          expect(request.url.path, '/v1/projects/fieldnote-test/messages:send');
          final message = (jsonDecode(request.body) as Map)['message'] as Map;
          expect(message['token'], 'test-device-token');
          expect(message['data'], {'notificationId': '42'});
          expect(message['notification']['title'], 'FieldNote');
          expect(message['android']['notification']['tag'], 'fieldnote-42');
          return http.Response('{}', 200);
        }),
      );
      expect(
        await sender.send(token: 'test-device-token', notificationId: 42),
        PushSendResult.sent,
      );
      sender.close();
    },
  );

  test('only explicit UNREGISTERED responses retire a token', () {
    expect(
      classifyFirebaseResponse(
        404,
        jsonEncode({
          'error': {
            'details': [
              {
                '@type': 'type.googleapis.com/google.firebase.fcm.v1.FcmError',
                'errorCode': 'UNREGISTERED',
              },
            ],
          },
        }),
      ),
      PushSendResult.invalidToken,
    );
    expect(
      classifyFirebaseResponse(400, '{"error":{"status":"INVALID_ARGUMENT"}}'),
      PushSendResult.rejected,
    );
    expect(classifyFirebaseResponse(404, ''), PushSendResult.rejected);
  });

  test('transient provider and auth errors retry without deleting tokens', () {
    for (final code in [401, 403, 408, 429, 500, 503]) {
      expect(
        classifyFirebaseResponse(code, '<html>unavailable</html>'),
        PushSendResult.retry,
      );
    }
  });
}
