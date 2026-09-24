import 'package:fieldnotes_client/fieldnotes_client.dart';

import 'razorpay_checkout_mobile.dart'
    if (dart.library.js_interop) 'razorpay_checkout_web.dart';

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

/// Razorpay checkout. The mobile build uses the `razorpay_flutter`
/// plugin and the web build uses Razorpay's Checkout.js, but both return the
/// same three fields the server needs to verify the payment signature.
abstract class RazorpayCheckoutService {
  factory RazorpayCheckoutService() => createRazorpayCheckout();

  Future<RazorpayCheckoutResult> open(RazorpayCheckoutOrder order);

  void dispose();
}
