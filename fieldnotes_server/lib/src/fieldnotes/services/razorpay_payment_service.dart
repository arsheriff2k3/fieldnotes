import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

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

class RazorpayPaymentException implements Exception {
  const RazorpayPaymentException(this.message);
  final String message;

  @override
  String toString() => 'RazorpayPaymentException: $message';
}

class RazorpayPaymentService {
  const RazorpayPaymentService({
    this.endpoint = 'https://api.razorpay.com/v1/orders',
  });

  final String endpoint;

  Future<RazorpayOrderResult> createOrder({
    required String keyId,
    required String keySecret,
    required int amountPaise,
    required String receipt,
    required int campaignId,
  }) async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 8);
    try {
      final request = await client
          .postUrl(Uri.parse(endpoint))
          .timeout(const Duration(seconds: 10));
      request.headers
        ..contentType = ContentType.json
        ..set(
          HttpHeaders.authorizationHeader,
          'Basic ${base64Encode(utf8.encode('$keyId:$keySecret'))}',
        );
      request.write(
        jsonEncode({
          'amount': amountPaise,
          'currency': 'INR',
          'receipt': receipt,
          'notes': {'campaign_id': '$campaignId', 'source': 'fieldnote'},
        }),
      );
      final response = await request.close().timeout(
        const Duration(seconds: 15),
      );
      final body = await utf8.decoder.bind(response).join();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw RazorpayPaymentException(
          'Razorpay returned HTTP ${response.statusCode}: ${_safeError(body)}',
        );
      }
      final decoded = jsonDecode(body);
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
    } on TimeoutException {
      throw const RazorpayPaymentException('Razorpay order request timed out.');
    } on RazorpayPaymentException {
      rethrow;
    } catch (_) {
      throw const RazorpayPaymentException(
        'Could not connect to Razorpay to create the order.',
      );
    } finally {
      client.close(force: true);
    }
  }

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
    return _constantTimeEquals(expected, signature.toLowerCase());
  }

  static bool _constantTimeEquals(String left, String right) {
    if (left.length != right.length) return false;
    var result = 0;
    for (var i = 0; i < left.length; i++) {
      result |= left.codeUnitAt(i) ^ right.codeUnitAt(i);
    }
    return result == 0;
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
