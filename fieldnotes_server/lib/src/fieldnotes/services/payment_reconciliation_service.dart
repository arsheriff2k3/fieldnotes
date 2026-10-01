import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart';
import 'campaign_events_service.dart';
import 'campaign_lifecycle_service.dart';
import 'notification_service.dart';
import 'money.dart';
import 'payment_credit_service.dart';
import 'razorpay_payment_service.dart';

/// Applies a provider-confirmed captured payment through the locked
/// [PaymentCreditService] path, from checkout, webhook or reconciliation.
class PaymentSettlementService {
  const PaymentSettlementService();

  static const _events = CampaignEventsService();

  Future<PaymentCreditResult> settleCaptured(
    Session session, {
    required Sponsorship sponsorship,
    required String paymentId,
    required String source,
  }) async {
    final result = await const PaymentCreditService().credit(
      session,
      sponsorshipId: sponsorship.id!,
      campaignId: sponsorship.campaignId,
      sponsorAuthUserId: sponsorship.sponsorAuthUserId,
      orderId: sponsorship.providerOrderId!,
      paymentId: paymentId,
    );
    if (result.alreadyVerified) return result;
    final updated = result.sponsorship;
    if (result.uncredited) {
      await _events.audit(
        session,
        actor: updated.sponsorAuthUserId,
        event: 'paymentVerifiedWithoutCredit',
        entityType: 'sponsorship',
        entityId: '${updated.id}',
        outcome: 'refund_queued',
        riskLevel: 'warning',
        detail:
            'A captured payment could not fund the campaign because it closed or its goal was reached. A refund was queued.',
      );
      return result;
    }
    await const CampaignLifecycleService().refreshReadiness(
      session,
      updated.campaignId,
    );
    await _events.publish(
      session,
      updated.campaignId,
      'sponsorshipAdded',
      'A Razorpay-verified sponsorship of ₹${updated.amount.toStringAsFixed(0)} was recorded.',
    );
    await _events.audit(
      session,
      actor: updated.sponsorAuthUserId,
      event: 'paymentSignatureVerified',
      entityType: 'sponsorship',
      entityId: '${updated.id}',
      outcome: 'verified',
      riskLevel: 'info',
      detail: source == 'checkout'
          ? 'Server signature verification passed for payment $paymentId.'
          : 'Payment $paymentId was confirmed by Razorpay ($source).',
    );
    await const NotificationService().paymentVerified(session, updated);
    return result;
  }

  /// Marks an unpaid attempt failed. Verified payments are never downgraded.
  Future<Sponsorship> markFailed(
    Session session, {
    required Sponsorship sponsorship,
    required String status,
    String? reason,
  }) => const PaymentCreditService().markFailed(
    session,
    sponsorshipId: sponsorship.id!,
    sponsorAuthUserId: sponsorship.sponsorAuthUserId,
    status: status,
    failureReason: reason,
  );
}

typedef ReconciliationResult = ({int checked, int credited, int expired});

/// P0-2: polls Razorpay for checkouts that never reached
/// `verifyRazorpayPayment` (app killed, network lost, tab closed).
class PaymentReconciliationService {
  const PaymentReconciliationService({this.gatewayOverride});

  /// Defaults to [RazorpayRuntime.gateway].
  final RazorpayGateway? gatewayOverride;

  RazorpayGateway get gateway => gatewayOverride ?? RazorpayRuntime.gateway;

  /// Unpaid orders stop reserving campaign balance and expire after this.
  static const orderTtl = Duration(minutes: 30);

  /// Give the checkout callback a chance before polling.
  static const minimumAge = Duration(minutes: 5);

  /// Older attempts are not polled any more; the webhook still covers them.
  static const lookback = Duration(hours: 24);

  /// Minimum time between polls of one order.
  static const pollInterval = Duration(minutes: 10);

  static const reconcilableStatuses = {
    'created',
    'failed',
    'verification_failed',
    'expired',
  };

  static const _settlement = PaymentSettlementService();

  Future<ReconciliationResult> reconcile(
    Session session, {
    DateTime? now,
  }) async {
    final clock = now ?? DateTime.now().toUtc();
    final credentials = RazorpayCredentials.fromSession(session);
    final rows = await Sponsorship.db.find(
      session,
      where: (t) =>
          t.paymentStatus.inSet(reconcilableStatuses) &
          (t.createdAt > clock.subtract(lookback)) &
          (t.createdAt < clock.subtract(minimumAge)),
      orderBy: (t) => t.createdAt,
      limit: 50,
    );
    var checked = 0;
    var credited = 0;
    var expired = 0;
    for (final row in rows) {
      final lastPolled = row.lastReconciledAt;
      if (lastPolled != null &&
          lastPolled.isAfter(clock.subtract(pollInterval))) {
        continue;
      }
      final stale = row.createdAt.isBefore(clock.subtract(orderTtl));
      final orderId = row.providerOrderId;
      if (orderId == null) {
        // Razorpay never issued an order for this attempt.
        if (row.paymentStatus == 'created' && stale) {
          await _settlement.markFailed(
            session,
            sponsorship: row,
            status: 'expired',
            reason: 'No Razorpay order was created.',
          );
          expired++;
        }
        continue;
      }
      if (credentials == null) continue;
      checked++;
      final List<RazorpayPaymentRecord> payments;
      try {
        payments = await gateway.fetchOrderPayments(
          credentials: credentials,
          orderId: orderId,
        );
      } on RazorpayPaymentException catch (error) {
        session.log(
          'Reconciliation of order $orderId failed: ${error.message}',
          level: LogLevel.warning,
        );
        await _touch(session, row.id!, clock);
        continue;
      }
      final captured = payments.where((p) => p.status == 'captured');
      if (captured.isNotEmpty) {
        final payment = captured.first;
        if (payment.amountPaise != Money.toPaise(row.amount)) {
          await const CampaignEventsService().audit(
            session,
            actor: row.sponsorAuthUserId,
            event: 'paymentReconciliation',
            entityType: 'sponsorship',
            entityId: '${row.id}',
            outcome: 'amount_mismatch',
            riskLevel: 'high',
            detail:
                'Captured amount ${payment.amountPaise} paise does not match the order.',
          );
          await _touch(session, row.id!, clock);
          continue;
        }
        final result = await _settlement.settleCaptured(
          session,
          sponsorship: row,
          paymentId: payment.id,
          source: 'reconciliation',
        );
        if (!result.alreadyVerified) credited++;
        await _touch(session, row.id!, clock);
        continue;
      }
      final pending = payments.any(
        (p) => p.status == 'authorized' || p.status == 'created',
      );
      if (row.paymentStatus == 'created' && stale && !pending) {
        final failure = payments
            .map((p) => p.errorDescription)
            .whereType<String>()
            .firstOrNull;
        await _settlement.markFailed(
          session,
          sponsorship: row,
          status: 'expired',
          reason:
              failure ?? 'Checkout was not completed before the order expired.',
        );
        expired++;
      }
      await _touch(session, row.id!, clock);
    }
    return (checked: checked, credited: credited, expired: expired);
  }

  /// Sum of unpaid orders that still reserve campaign balance (S6).
  static Future<double> reservedAmount(
    Session session, {
    required int campaignId,
    required Transaction transaction,
    DateTime? now,
  }) async {
    final clock = now ?? DateTime.now().toUtc();
    final pending = await Sponsorship.db.find(
      session,
      where: (t) =>
          t.campaignId.equals(campaignId) &
          t.paymentStatus.equals('created') &
          (t.createdAt > clock.subtract(orderTtl)),
      transaction: transaction,
    );
    return Money.fromPaise(
      pending.fold<int>(0, (sum, item) => sum + Money.toPaise(item.amount)),
    );
  }

  Future<void> _touch(Session session, int sponsorshipId, DateTime now) =>
      session.db.transaction((transaction) async {
        final row = await Sponsorship.db.findById(
          session,
          sponsorshipId,
          transaction: transaction,
          lockMode: LockMode.forUpdate,
        );
        if (row == null) return;
        row.lastReconciledAt = now;
        row.reconcileAttempts += 1;
        await Sponsorship.db.updateRow(session, row, transaction: transaction);
      });
}
