import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart';

class RazorpayOrderResult {
  const RazorpayOrderResult({
    required this.id,
    required this.amountPaise,
    required this.currency,
  });

  final String id;
  final int amountPaise;
  final String currency;
}

/// One payment attempt against a Razorpay order.
class RazorpayPaymentRecord {
  const RazorpayPaymentRecord({
    required this.id,
    required this.orderId,
    required this.status,
    required this.amountPaise,
    this.errorDescription,
  });

  final String id;
  final String? orderId;

  /// created | authorized | captured | refunded | failed
  final String status;
  final int amountPaise;
  final String? errorDescription;

  factory RazorpayPaymentRecord.fromJson(Map<String, dynamic> json) =>
      RazorpayPaymentRecord(
        id: json['id'] as String,
        orderId: json['order_id'] as String?,
        status: json['status'] as String? ?? 'created',
        amountPaise: (json['amount'] as num?)?.round() ?? 0,
        errorDescription: json['error_description'] as String?,
      );
}

/// One refund of a Razorpay payment.
class RazorpayRefundRecord {
  const RazorpayRefundRecord({
    required this.id,
    required this.paymentId,
    required this.status,
    required this.amountPaise,
    this.receipt,
    this.notes = const {},
  });

  final String id;
  final String paymentId;

  /// pending | processed | failed
  final String status;
  final int amountPaise;
  final String? receipt;
  final Map<String, String> notes;

  factory RazorpayRefundRecord.fromJson(Map<String, dynamic> json) {
    final rawNotes = json['notes'];
    return RazorpayRefundRecord(
      id: json['id'] as String,
      paymentId: json['payment_id'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      amountPaise: (json['amount'] as num?)?.round() ?? 0,
      receipt: json['receipt'] as String?,
      notes: rawNotes is Map
          ? {
              for (final entry in rawNotes.entries)
                '${entry.key}': '${entry.value}',
            }
          : const {},
    );
  }
}

class RazorpayPaymentException implements Exception {
  const RazorpayPaymentException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;

  @override
  String toString() => 'RazorpayPaymentException: $message';
}

/// Server-side Razorpay API key pair.
class RazorpayCredentials {
  const RazorpayCredentials({required this.keyId, required this.keySecret});

  final String keyId;
  final String keySecret;

  /// Test Mode keys move no real money.
  bool get isTestMode => keyId.startsWith('rzp_test_');

  /// Reads `razorpayKeyId` and `razorpayKeySecret` from Serverpod passwords,
  /// or returns null when either is missing.
  static RazorpayCredentials? fromSession(Session session) {
    final override = RazorpayRuntime.credentialsResolver;
    if (override != null) return override(session);
    final keyId = session.passwords['razorpayKeyId']?.trim();
    final keySecret = session.passwords['razorpayKeySecret']?.trim();
    if (keyId == null ||
        keyId.isEmpty ||
        keySecret == null ||
        keySecret.isEmpty) {
      return null;
    }
    return RazorpayCredentials(keyId: keyId, keySecret: keySecret);
  }

  /// Like [fromSession] but throws a client-safe exception when missing.
  static RazorpayCredentials require(Session session) {
    final credentials = fromSession(session);
    if (credentials == null) {
      throw FieldnoteException(
        message: 'Payments are not configured on the server.',
        code: 'payment_not_configured',
      );
    }
    return credentials;
  }
}

/// The Razorpay REST calls FieldNote makes. Tests replace it with a fake via
/// [RazorpayRuntime.gateway].
abstract interface class RazorpayGateway {
  Future<RazorpayOrderResult> createOrder({
    required String keyId,
    required String keySecret,
    required int amountPaise,
    required String receipt,
    required int campaignId,
  });

  /// `GET /v1/orders/{orderId}/payments`
  Future<List<RazorpayPaymentRecord>> fetchOrderPayments({
    required RazorpayCredentials credentials,
    required String orderId,
  });

  /// `POST /v1/payments/{paymentId}/refund`
  Future<RazorpayRefundRecord> createRefund({
    required RazorpayCredentials credentials,
    required String paymentId,
    required int amountPaise,
    required String receipt,
    required Map<String, String> notes,
  });

  /// `GET /v1/payments/{paymentId}/refunds`
  Future<List<RazorpayRefundRecord>> listPaymentRefunds({
    required RazorpayCredentials credentials,
    required String paymentId,
  });
}

/// Process-wide hooks so future calls, web routes and endpoints share one
/// gateway. Integration tests swap these for fakes.
abstract final class RazorpayRuntime {
  static RazorpayGateway gateway = const RazorpayPaymentService();
  static RazorpayCredentials? Function(Session session)? credentialsResolver;

  /// Restores production defaults.
  static void reset() {
    gateway = const RazorpayPaymentService();
    credentialsResolver = null;
  }
}

class RazorpayPaymentService implements RazorpayGateway {
  const RazorpayPaymentService({
    this.endpoint = 'https://api.razorpay.com/v1/orders',
    this.apiBase = 'https://api.razorpay.com/v1',
  });

  final String endpoint;
  final String apiBase;

  @override
  Future<RazorpayOrderResult> createOrder({
    required String keyId,
    required String keySecret,
    required int amountPaise,
    required String receipt,
    required int campaignId,
  }) async {
    final decoded = await _send(
      method: 'POST',
      uri: Uri.parse(endpoint),
      credentials: RazorpayCredentials(keyId: keyId, keySecret: keySecret),
      body: {
        'amount': amountPaise,
        'currency': 'INR',
        'receipt': receipt,
        'notes': {'campaign_id': '$campaignId', 'source': 'fieldnote'},
      },
      action: 'create the order',
    );
    if (decoded is! Map<String, dynamic> ||
        decoded['id'] is! String ||
        decoded['amount'] is! num) {
      throw const RazorpayPaymentException(
        'Razorpay returned an invalid order response.',
      );
    }
    return RazorpayOrderResult(
      id: decoded['id'] as String,
      amountPaise: (decoded['amount'] as num).round(),
      currency: decoded['currency'] as String? ?? 'INR',
    );
  }

  @override
  Future<List<RazorpayPaymentRecord>> fetchOrderPayments({
    required RazorpayCredentials credentials,
    required String orderId,
  }) async {
    final decoded = await _send(
      method: 'GET',
      uri: Uri.parse(
        '$apiBase/orders/${Uri.encodeComponent(orderId)}/payments',
      ),
      credentials: credentials,
      action: 'fetch order payments',
    );
    return _items(decoded).map(RazorpayPaymentRecord.fromJson).toList();
  }

  @override
  Future<RazorpayRefundRecord> createRefund({
    required RazorpayCredentials credentials,
    required String paymentId,
    required int amountPaise,
    required String receipt,
    required Map<String, String> notes,
  }) async {
    final decoded = await _send(
      method: 'POST',
      uri: Uri.parse(
        '$apiBase/payments/${Uri.encodeComponent(paymentId)}/refund',
      ),
      credentials: credentials,
      // Razorpay de-duplicates refund requests carrying the same key.
      extraHeaders: {'X-Refund-Idempotency': receipt},
      body: {
        'amount': amountPaise,
        'speed': 'normal',
        'receipt': receipt,
        'notes': notes,
      },
      action: 'create the refund',
    );
    if (decoded is! Map<String, dynamic> || decoded['id'] is! String) {
      throw const RazorpayPaymentException(
        'Razorpay returned an invalid refund response.',
      );
    }
    return RazorpayRefundRecord.fromJson(decoded);
  }

  @override
  Future<List<RazorpayRefundRecord>> listPaymentRefunds({
    required RazorpayCredentials credentials,
    required String paymentId,
  }) async {
    final decoded = await _send(
      method: 'GET',
      uri: Uri.parse(
        '$apiBase/payments/${Uri.encodeComponent(paymentId)}/refunds',
      ),
      credentials: credentials,
      action: 'list refunds',
    );
    return _items(decoded).map(RazorpayRefundRecord.fromJson).toList();
  }

  /// Verifies the checkout handler signature `HMAC(orderId|paymentId)`.
  bool verifySignature({
    required String orderId,
    required String paymentId,
    required String signature,
    required String keySecret,
  }) {
    final expected = Hmac(
      sha256,
      utf8.encode(keySecret),
    ).convert(utf8.encode('$orderId|$paymentId')).toString();
    return constantTimeEquals(expected, signature.toLowerCase());
  }

  /// Verifies `X-Razorpay-Signature`: hex `HMAC-SHA256(rawBody, secret)`.
  static bool verifyWebhookSignature({
    required String rawBody,
    required String signature,
    required String webhookSecret,
  }) {
    final expected = Hmac(
      sha256,
      utf8.encode(webhookSecret),
    ).convert(utf8.encode(rawBody)).toString();
    return constantTimeEquals(expected, signature.trim().toLowerCase());
  }

  static bool constantTimeEquals(String left, String right) {
    if (left.length != right.length) return false;
    var result = 0;
    for (var i = 0; i < left.length; i++) {
      result |= left.codeUnitAt(i) ^ right.codeUnitAt(i);
    }
    return result == 0;
  }

  static Iterable<Map<String, dynamic>> _items(Object? decoded) {
    if (decoded is! Map<String, dynamic> || decoded['items'] is! List) {
      throw const RazorpayPaymentException(
        'Razorpay returned an invalid collection response.',
      );
    }
    return (decoded['items'] as List).whereType<Map<String, dynamic>>();
  }

  Future<Object?> _send({
    required String method,
    required Uri uri,
    required RazorpayCredentials credentials,
    required String action,
    Map<String, Object?>? body,
    Map<String, String> extraHeaders = const {},
  }) async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 8);
    try {
      final request = await client
          .openUrl(method, uri)
          .timeout(const Duration(seconds: 10));
      request.headers
        ..contentType = ContentType.json
        ..set(
          HttpHeaders.authorizationHeader,
          'Basic ${base64Encode(utf8.encode('${credentials.keyId}:${credentials.keySecret}'))}',
        );
      extraHeaders.forEach(request.headers.set);
      if (body != null) request.write(jsonEncode(body));
      final response = await request.close().timeout(
        const Duration(seconds: 15),
      );
      final text = await utf8.decoder.bind(response).join();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw RazorpayPaymentException(
          'Razorpay returned HTTP ${response.statusCode}: ${_safeError(text)}',
          statusCode: response.statusCode,
        );
      }
      return jsonDecode(text);
    } on TimeoutException {
      throw RazorpayPaymentException('Razorpay timed out trying to $action.');
    } on RazorpayPaymentException {
      rethrow;
    } catch (_) {
      throw RazorpayPaymentException(
        'Could not connect to Razorpay to $action.',
      );
    } finally {
      client.close(force: true);
    }
  }

  static String _safeError(String body) {
    try {
      final value = jsonDecode(body);
      if (value is Map && value['error'] is Map) {
        final description = (value['error'] as Map)['description'];
        if (description is String) return description;
      }
    } catch (_) {}
    return 'The payment provider did not return a usable error.';
  }
}
