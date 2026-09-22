import 'dart:async';

import 'package:fieldnotes_client/fieldnotes_client.dart';
import 'package:flutter/foundation.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorpayCheckoutResult {
  const RazorpayCheckoutResult({
    required this.orderId,
    required this.paymentId,
    required this.signature,
  });

  final String orderId;
  final String paymentId;
  final String signature;
}

class RazorpayCheckoutException implements Exception {
  const RazorpayCheckoutException(this.message);
  final String message;

  @override
  String toString() => message;
}

class RazorpayCheckoutService {
  RazorpayCheckoutService() {
    _razorpay
      ..on(Razorpay.EVENT_PAYMENT_SUCCESS, _success)
      ..on(Razorpay.EVENT_PAYMENT_ERROR, _failure)
      ..on(Razorpay.EVENT_EXTERNAL_WALLET, _externalWallet);
  }

  final Razorpay _razorpay = Razorpay();
  Completer<RazorpayCheckoutResult>? _pending;

  Future<RazorpayCheckoutResult> open(RazorpayCheckoutOrder order) {
    if (kIsWeb) {
      throw const RazorpayCheckoutException(
        'Razorpay checkout is enabled in the Android/iOS demo build.',
      );
    }
    if (_pending != null) {
      throw const RazorpayCheckoutException('A checkout is already open.');
    }
    final completer = Completer<RazorpayCheckoutResult>();
    _pending = completer;
    try {
      _razorpay.open({
        'key': order.keyId,
        'order_id': order.orderId,
        'amount': order.amountPaise,
        'currency': order.currency,
        'name': 'FieldNote',
        'description': order.campaignName,
        'retry': {'enabled': true, 'max_count': 2},
        'theme': {'color': '#1B5E4B'},
      });
    } catch (error) {
      _pending = null;
      throw RazorpayCheckoutException('Could not open Razorpay: $error');
    }
    return completer.future.whenComplete(() => _pending = null);
  }

  void _success(PaymentSuccessResponse response) {
    final orderId = response.orderId;
    final paymentId = response.paymentId;
    final signature = response.signature;
    if (orderId == null || paymentId == null || signature == null) {
      _pending?.completeError(
        const RazorpayCheckoutException(
          'Razorpay did not return all verification fields.',
        ),
      );
      return;
    }
    _pending?.complete(
      RazorpayCheckoutResult(
        orderId: orderId,
        paymentId: paymentId,
        signature: signature,
      ),
    );
  }

  void _failure(PaymentFailureResponse response) {
    _pending?.completeError(
      RazorpayCheckoutException(
        response.message ?? 'Razorpay checkout was cancelled or failed.',
      ),
    );
  }

  void _externalWallet(ExternalWalletResponse response) {
    // The final success/error callback still completes the active checkout.
  }

  void dispose() {
    _razorpay.clear();
    final pending = _pending;
    if (pending != null && !pending.isCompleted) {
      pending.completeError(
        const RazorpayCheckoutException('Checkout was closed.'),
      );
    }
  }
}
