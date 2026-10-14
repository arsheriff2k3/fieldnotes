import 'dart:async';
import 'dart:convert';

import 'package:serverpod/serverpod.dart';

import '../../fieldnotes/services/razorpay_webhook_service.dart';

/// `POST /webhooks/razorpay`. Razorpay signs the raw body with the webhook
/// secret configured in its dashboard; the same value must be stored as the
/// `razorpayWebhookSecret` Serverpod password.
class RazorpayWebhookRoute extends Route {
  RazorpayWebhookRoute() : super(methods: {Method.post});

  /// Razorpay payloads are a few kilobytes.
  static const _maxBodyBytes = 256 * 1024;

  @override
  FutureOr<Result> handleCall(Session session, Request request) async {
    String rawBody;
    try {
      rawBody = await request.readAsString(maxLength: _maxBodyBytes);
    } catch (_) {
      return _json(413, {'outcome': 'rejected'});
    }
    final result = await const RazorpayWebhookService().handle(
      session,
      rawBody: rawBody,
      signature: request.headers['x-razorpay-signature']?.firstOrNull,
      eventIdHeader: request.headers['x-razorpay-event-id']?.firstOrNull,
      webhookSecret: session.passwords['razorpayWebhookSecret'],
    );
    return _json(result.statusCode, result.toJson());
  }

  static Response _json(int status, Map<String, Object> body) => Response(
    status,
    body: Body.fromString(jsonEncode(body), mimeType: MimeType.json),
  );
}
