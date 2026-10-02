import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart';
import 'payment_reconciliation_service.dart';
import 'razorpay_payment_service.dart';
import 'refund_service.dart';

/// Outcome of one webhook delivery.
class WebhookResult {
  const WebhookResult(this.statusCode, this.outcome, {this.duplicate = false});

  final int statusCode;

  /// processed | ignored | duplicate | rejected | failed | not_configured
  final String outcome;
  final bool duplicate;

  Map<String, Object> toJson() => {'outcome': outcome, 'duplicate': duplicate};
}

/// P0-2: verifies, de-duplicates and applies Razorpay webhook deliveries.
///
/// Handled events: `payment.captured`, `order.paid`, `payment.failed`,
/// `refund.processed`, `refund.failed`. Everything else is acknowledged and
/// recorded as ignored.
class RazorpayWebhookService {
  const RazorpayWebhookService();

  static const _settlement = PaymentSettlementService();

  Future<WebhookResult> handle(
    Session session, {
    required String rawBody,
    required String? signature,
    required String? eventIdHeader,
    required String? webhookSecret,
  }) async {
    if (webhookSecret == null || webhookSecret.trim().isEmpty) {
      session.log(
        'Razorpay webhook rejected: razorpayWebhookSecret is not configured.',
        level: LogLevel.warning,
      );
      return const WebhookResult(503, 'not_configured');
    }
    if (signature == null ||
        !RazorpayPaymentService.verifyWebhookSignature(
          rawBody: rawBody,
          signature: signature,
          webhookSecret: webhookSecret.trim(),
        )) {
      session.log(
        'Razorpay webhook rejected: signature mismatch.',
        level: LogLevel.warning,
      );
      return const WebhookResult(401, 'rejected');
    }
    final Map<String, dynamic> json;
    try {
      final decoded = jsonDecode(rawBody);
      if (decoded is! Map<String, dynamic>) throw const FormatException();
      json = decoded;
    } on FormatException {
      return const WebhookResult(400, 'rejected');
    }
    final digest = sha256.convert(utf8.encode(rawBody)).toString();
    final headerId = eventIdHeader?.trim();
    final eventId = headerId == null || headerId.isEmpty
        ? 'sha256:$digest'
        : headerId;
    final eventType = json['event'] is String
        ? json['event'] as String
        : 'unknown';

    final claim = await _claim(session, eventId, eventType, digest);
    if (claim == null) {
      return const WebhookResult(200, 'duplicate', duplicate: true);
    }
    try {
      final (outcome, detail) = await _apply(session, eventType, json);
      await _finish(session, claim.id!, outcome, detail);
      return WebhookResult(200, outcome);
    } catch (error, stackTrace) {
      session.log(
        'Razorpay webhook $eventType failed.',
        level: LogLevel.error,
        exception: error,
        stackTrace: stackTrace,
      );
      await _finish(session, claim.id!, 'failed', '$error');
      // Razorpay retries non-2xx deliveries; the failed row is re-claimed.
      return const WebhookResult(500, 'failed');
    }
  }

  /// Returns the event row to process, or null when already handled.
  Future<PaymentWebhookEvent?> _claim(
    Session session,
    String eventId,
    String eventType,
    String digest,
  ) async {
    try {
      return await session.db.transaction((transaction) async {
        final existing = await PaymentWebhookEvent.db.findFirstRow(
          session,
          where: (t) =>
              t.provider.equals('razorpay') & t.eventId.equals(eventId),
          transaction: transaction,
          lockMode: LockMode.forUpdate,
        );
        if (existing != null) {
          if (existing.status == 'processed' || existing.status == 'ignored') {
            return null;
          }
          existing.attempts += 1;
          existing.status = 'received';
          return PaymentWebhookEvent.db.updateRow(
            session,
            existing,
            transaction: transaction,
          );
        }
        return PaymentWebhookEvent.db.insertRow(
          session,
          PaymentWebhookEvent(
            provider: 'razorpay',
            eventId: eventId,
            eventType: eventType,
            payloadSha256: digest,
          ),
          transaction: transaction,
        );
      });
    } on DatabaseException {
      // A concurrent delivery of the same event inserted it first.
      return null;
    }
  }

  Future<void> _finish(
    Session session,
    int id,
    String status,
    String? detail,
  ) async {
    final row = await PaymentWebhookEvent.db.findById(session, id);
    if (row == null) return;
    row.status = status;
    row.detail = detail == null || detail.length <= 300
        ? detail
        : detail.substring(0, 300);
    row.processedAt = DateTime.now().toUtc();
    await PaymentWebhookEvent.db.updateRow(session, row);
  }

  Future<(String, String?)> _apply(
    Session session,
    String eventType,
    Map<String, dynamic> json,
  ) async {
    final payload = json['payload'] is Map<String, dynamic>
        ? json['payload'] as Map<String, dynamic>
        : const <String, dynamic>{};
    switch (eventType) {
      case 'payment.captured':
      case 'order.paid':
        final payment = _entity(payload, 'payment');
        final order = _entity(payload, 'order');
        final paymentId = payment?['id'] as String?;
        final orderId =
            payment?['order_id'] as String? ?? order?['id'] as String?;
        if (paymentId == null || orderId == null) {
          return ('ignored', 'Missing payment or order id.');
        }
        final sponsorship = await _sponsorship(session, orderId);
        if (sponsorship == null) return ('ignored', 'Unknown order $orderId.');
        final amount = (payment?['amount'] as num?)?.round();
        if (amount != null && amount != sponsorship.amountPaise) {
          return ('ignored', 'Amount $amount does not match order $orderId.');
        }
        final result = await _settlement.settleCaptured(
          session,
          sponsorship: sponsorship,
          paymentId: paymentId,
          source: 'webhook',
        );
        return (
          'processed',
          result.alreadyVerified
              ? 'Already settled.'
              : result.uncredited
              ? 'Captured but uncredited; refund queued.'
              : 'Credited.',
        );
      case 'payment.failed':
        final payment = _entity(payload, 'payment');
        final orderId = payment?['order_id'] as String?;
        if (orderId == null) return ('ignored', 'Missing order id.');
        final sponsorship = await _sponsorship(session, orderId);
        if (sponsorship == null) return ('ignored', 'Unknown order $orderId.');
        if (sponsorship.paymentStatus != 'created') {
          // A later retry on the same order may still succeed (P0-1).
          return ('ignored', 'Attempt already ${sponsorship.paymentStatus}.');
        }
        await _settlement.markFailed(
          session,
          sponsorship: sponsorship,
          status: 'failed',
          reason: payment?['error_description'] as String?,
        );
        return ('processed', 'Marked failed.');
      case 'refund.processed':
      case 'refund.failed':
        final refund = _entity(payload, 'refund');
        if (refund == null || refund['id'] is! String) {
          return ('ignored', 'Missing refund entity.');
        }
        final record = RazorpayRefundRecord.fromJson({
          ...refund,
          'status': eventType == 'refund.processed' ? 'processed' : 'failed',
        });
        final updated = await const RefundService().applyProviderRefund(
          session,
          record,
          failureReason: eventType == 'refund.failed'
              ? 'Razorpay reported the refund failed.'
              : null,
        );
        return updated == null
            ? ('ignored', 'Unknown refund ${record.id}.')
            : ('processed', 'Refund ${updated.status}.');
      default:
        return ('ignored', 'Unhandled event type.');
    }
  }

  static Map<String, dynamic>? _entity(
    Map<String, dynamic> payload,
    String key,
  ) {
    final wrapper = payload[key];
    if (wrapper is! Map<String, dynamic>) return null;
    final entity = wrapper['entity'];
    return entity is Map<String, dynamic> ? entity : null;
  }

  static Future<Sponsorship?> _sponsorship(Session session, String orderId) =>
      Sponsorship.db.findFirstRow(
        session,
        where: (t) => t.providerOrderId.equals(orderId),
      );
}
