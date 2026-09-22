import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:fieldnotes_client/fieldnotes_client.dart';
import 'package:web/web.dart' as web;

import 'razorpay_checkout_service.dart';

RazorpayCheckoutService createRazorpayCheckout() => WebRazorpayCheckout();

@JS('Razorpay')
extension type _RazorpayJs._(JSObject _) implements JSObject {
  external factory _RazorpayJs(JSObject options);

  external void open();
  external void on(String event, JSFunction handler);
}

/// Web checkout through Razorpay's Checkout.js overlay.
///
/// `web/index.html` loads `checkout.razorpay.com/v1/checkout.js`. The order is
/// still created and the signature still verified on the server, so the browser
/// only ever handles the public key ID and the returned payment fields.
class WebRazorpayCheckout implements RazorpayCheckoutService {
  static const _checkoutScriptUrl =
      'https://checkout.razorpay.com/v1/checkout.js';
  static Future<void>? _scriptLoad;

  Completer<RazorpayCheckoutResult>? _pending;

  @override
  Future<RazorpayCheckoutResult> open(RazorpayCheckoutOrder order) async {
    if (_pending != null) {
      throw const RazorpayCheckoutException('A checkout is already open.');
    }
    final completer = Completer<RazorpayCheckoutResult>();
    _pending = completer;

    try {
      await _ensureCheckoutLoaded();
      final theme = JSObject()..setProperty('color'.toJS, '#1B5E4B'.toJS);
      final modal = JSObject()
        ..setProperty(
          'ondismiss'.toJS,
          (() => _fail('Razorpay checkout was closed before payment.')).toJS,
        );
      final options = JSObject()
        ..setProperty('key'.toJS, order.keyId.toJS)
        ..setProperty('order_id'.toJS, order.orderId.toJS)
        ..setProperty('amount'.toJS, order.amountPaise.toJS)
        ..setProperty('currency'.toJS, order.currency.toJS)
        ..setProperty('name'.toJS, 'FieldNote'.toJS)
        ..setProperty('description'.toJS, order.campaignName.toJS)
        ..setProperty('theme'.toJS, theme)
        ..setProperty('modal'.toJS, modal)
        ..setProperty(
          'handler'.toJS,
          ((JSObject response) {
            _succeed(response);
          }).toJS,
        );

      final checkout = _RazorpayJs(options);
      checkout.on(
        'payment.failed',
        ((JSObject response) {
          _fail(_failureMessage(response));
        }).toJS,
      );
      checkout.open();
    } catch (error) {
      if (!completer.isCompleted) {
        completer.completeError(
          error is RazorpayCheckoutException
              ? error
              : RazorpayCheckoutException('Could not open Razorpay: $error'),
        );
      }
    }
    return completer.future.whenComplete(() => _pending = null);
  }

  static Future<void> _ensureCheckoutLoaded() async {
    if (globalContext.has('Razorpay')) return;

    final load = _scriptLoad ??= _loadCheckoutScript();
    try {
      await load;
    } finally {
      if (!globalContext.has('Razorpay')) _scriptLoad = null;
    }

    if (!globalContext.has('Razorpay')) {
      throw const RazorpayCheckoutException(
        'Razorpay Checkout was blocked by this browser. Try a standard browser '
        'such as Chrome, Safari, or Firefox.',
      );
    }
  }

  static Future<void> _loadCheckoutScript() {
    final completer = Completer<void>();

    // Replace a stale or failed tag. This supports tabs opened before
    // Checkout.js was added to index.html and subsequently only hot-reloaded.
    web.document.querySelector('script[src="$_checkoutScriptUrl"]')?.remove();

    final script =
        web.document.createElement('script') as web.HTMLScriptElement;
    script
      ..src = _checkoutScriptUrl
      ..async = true
      ..onload = ((web.Event _) {
        if (!completer.isCompleted) completer.complete();
      }).toJS
      ..onerror = ((web.Event _) {
        if (!completer.isCompleted) {
          completer.completeError(
            const RazorpayCheckoutException(
              'Razorpay Checkout was blocked by this browser. Try a standard '
              'browser such as Chrome, Safari, or Firefox.',
            ),
          );
        }
      }).toJS;
    web.document.head!.append(script);
    return completer.future;
  }

  void _succeed(JSObject response) {
    final orderId = _string(response, 'razorpay_order_id');
    final paymentId = _string(response, 'razorpay_payment_id');
    final signature = _string(response, 'razorpay_signature');
    final pending = _pending;
    if (pending == null || pending.isCompleted) return;
    if (orderId == null || paymentId == null || signature == null) {
      pending.completeError(
        const RazorpayCheckoutException(
          'Razorpay did not return all verification fields.',
        ),
      );
      return;
    }
    pending.complete(
      RazorpayCheckoutResult(
        orderId: orderId,
        paymentId: paymentId,
        signature: signature,
      ),
    );
  }

  void _fail(String message) {
    final pending = _pending;
    if (pending == null || pending.isCompleted) return;
    pending.completeError(RazorpayCheckoutException(message));
  }

  /// Razorpay nests the reason under `error` on a `payment.failed` event.
  static String _failureMessage(JSObject response) {
    final error = response.has('error')
        ? response.getProperty('error'.toJS)
        : null;
    if (error.isA<JSObject>()) {
      final description = _string(error! as JSObject, 'description');
      if (description != null && description.trim().isNotEmpty) {
        return description;
      }
    }
    return 'Razorpay checkout was cancelled or failed.';
  }

  static String? _string(JSObject source, String key) {
    if (!source.has(key)) return null;
    final value = source.getProperty(key.toJS);
    return value.isA<JSString>() ? (value! as JSString).toDart : null;
  }

  @override
  void dispose() {
    final pending = _pending;
    if (pending != null && !pending.isCompleted) {
      pending.completeError(
        const RazorpayCheckoutException('Checkout was closed.'),
      );
    }
    _pending = null;
  }
}
