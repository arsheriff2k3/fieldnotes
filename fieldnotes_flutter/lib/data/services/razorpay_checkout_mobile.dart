import 'dart:async';

import 'package:fieldnotes_client/fieldnotes_client.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import 'razorpay_checkout_service.dart';

RazorpayCheckoutService createRazorpayCheckout() => MobileRazorpayCheckout();

/// Android and iOS checkout through the `razorpay_flutter` plugin.
class MobileRazorpayCheckout implements RazorpayCheckoutService {
  MobileRazorpayCheckout() {
    _razorpay
      ..on(Razorpay.EVENT_PAYMENT_SUCCESS, _success)
      ..on(Razorpay.EVENT_PAYMENT_ERROR, _failure)
      ..on(Razorpay.EVENT_EXTERNAL_WALLET, _externalWallet);
  }

  final Razorpay _razorpay = Razorpay();
  Completer<RazorpayCheckoutResult>? _pending;

  @override
  Future<RazorpayCheckoutResult> open(RazorpayCheckoutOrder order) {
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
    final rawMessage = response.message?.trim();
    _pending?.completeError(
      RazorpayCheckoutException(
        rawMessage == null ||
                rawMessage.isEmpty ||
                rawMessage.toLowerCase() == 'undefined'
            ? 'Razorpay checkout was cancelled or failed.'
            : rawMessage,
      ),
    );
  }

  void _externalWallet(ExternalWalletResponse response) {
    // The final success/error callback still completes the active checkout.
  }

  @override
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
