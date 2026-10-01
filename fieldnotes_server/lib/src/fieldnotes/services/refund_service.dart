import 'dart:math' as math;

import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart';
import 'campaign_events_service.dart';
import 'money.dart';
import 'notification_service.dart';
import 'razorpay_payment_service.dart';

/// Refund row statuses.
abstract final class RefundStatus {
  static const pending = 'pending';
  static const processing = 'processing';
  static const processed = 'processed';
  static const failed = 'failed';

  /// Rows written before the refund worker existed.
  static const legacyDue = 'refund_due_test';
}

/// Why a refund was queued.
abstract final class RefundReason {
  static const campaignCancelled = 'campaign_cancelled';
  static const campaignExpired = 'campaign_expired';
  static const uncredited = 'uncredited';
}

typedef RefundRunResult = ({int attempted, int processed, int failed});

/// Queues one refund per refundable sponsorship and executes them against
/// Razorpay `POST /v1/payments/{id}/refund`.
///
/// Idempotency: the `fieldnote_test_refund.sponsorshipId` unique index allows
/// one row per payment; each provider request carries the receipt
/// `fn_refund_<rowId>` (also sent as `X-Refund-Idempotency`) and the note
/// `fieldnote_refund_id`, and a retry first adopts any provider refund that
/// already carries that note.
class RefundService {
  const RefundService({this.gatewayOverride});

  /// Defaults to [RazorpayRuntime.gateway].
  final RazorpayGateway? gatewayOverride;

  RazorpayGateway get gateway => gatewayOverride ?? RazorpayRuntime.gateway;

  static const maxAttempts = 6;
  static const processingLease = Duration(minutes: 10);
  static const _events = CampaignEventsService();

  static String receiptFor(int refundId) => 'fn_refund_$refundId';

  /// Queues refunds for every credited payment of [campaignId]. Safe to call
  /// repeatedly: sponsorships that already have a refund row are skipped.
  Future<List<TestRefund>> queueForCampaign(
    Session session, {
    required int campaignId,
    required String reason,
    Transaction? transaction,
  }) async {
    final verified = await Sponsorship.db.find(
      session,
      where: (t) =>
          t.campaignId.equals(campaignId) & t.paymentStatus.equals('verified'),
      transaction: transaction,
    );
    final queued = <TestRefund>[];
    for (final sponsorship in verified) {
      final refund = await queueForSponsorship(
        session,
        sponsorship: sponsorship,
        reason: reason,
        transaction: transaction,
      );
      if (refund != null) queued.add(refund);
    }
    return queued;
  }

  /// Returns the new row, or null when the payment already has one.
  Future<TestRefund?> queueForSponsorship(
    Session session, {
    required Sponsorship sponsorship,
    required String reason,
    Transaction? transaction,
  }) async {
    final existing = await TestRefund.db.findFirstRow(
      session,
      where: (t) => t.sponsorshipId.equals(sponsorship.id!),
      transaction: transaction,
    );
    if (existing != null) return null;
    return TestRefund.db.insertRow(
      session,
      TestRefund(
        campaignId: sponsorship.campaignId,
        sponsorshipId: sponsorship.id!,
        amount: Money.round2(sponsorship.amount),
        status: RefundStatus.pending,
        reason: reason,
        testMode: RazorpayCredentials.fromSession(session)?.isTestMode ?? true,
      ),
      transaction: transaction,
    );
  }

  /// Gives every `verified_uncredited` payment a refund row (S-2 / S5).
  Future<int> queueUncredited(Session session) async {
    final uncredited = await Sponsorship.db.find(
      session,
      where: (t) => t.paymentStatus.equals('verified_uncredited'),
      limit: 200,
    );
    var count = 0;
    for (final sponsorship in uncredited) {
      final queued = await session.db.transaction(
        (transaction) => queueForSponsorship(
          session,
          sponsorship: sponsorship,
          reason: RefundReason.uncredited,
          transaction: transaction,
        ),
      );
      if (queued != null) count++;
    }
    return count;
  }

  /// Executes due refunds. Without Razorpay keys nothing is attempted and
  /// rows stay pending.
  Future<RefundRunResult> processDue(Session session, {DateTime? now}) async {
    final clock = now ?? DateTime.now().toUtc();
    final credentials = RazorpayCredentials.fromSession(session);
    if (credentials == null) {
      session.log(
        'Refund worker skipped: Razorpay keys are not configured.',
        level: LogLevel.info,
      );
      return (attempted: 0, processed: 0, failed: 0);
    }
    final candidates = await TestRefund.db.find(
      session,
      where: (t) => t.status.inSet({
        RefundStatus.pending,
        RefundStatus.legacyDue,
        RefundStatus.failed,
        RefundStatus.processing,
      }),
      orderBy: (t) => t.createdAt,
      limit: 25,
    );
    var attempted = 0;
    var processed = 0;
    var failed = 0;
    for (final candidate in candidates) {
      final outcome = await _processOne(
        session,
        candidate,
        credentials: credentials,
        now: clock,
      );
      if (outcome == null) continue;
      attempted++;
      if (outcome.status == RefundStatus.processed) processed++;
      if (outcome.status == RefundStatus.failed) failed++;
    }
    return (attempted: attempted, processed: processed, failed: failed);
  }

  /// Applies a refund status reported by Razorpay (webhook or poll).
  Future<TestRefund?> applyProviderRefund(
    Session session,
    RazorpayRefundRecord record, {
    String? failureReason,
  }) async {
    final rowId = int.tryParse(record.notes['fieldnote_refund_id'] ?? '');
    final updated = await session.db.transaction((transaction) async {
      var refund = await TestRefund.db.findFirstRow(
        session,
        where: (t) => t.providerRefundId.equals(record.id),
        transaction: transaction,
        lockMode: LockMode.forUpdate,
      );
      if (refund == null && rowId != null) {
        refund = await TestRefund.db.findById(
          session,
          rowId,
          transaction: transaction,
          lockMode: LockMode.forUpdate,
        );
      }
      if (refund == null) return null;
      if (refund.status == RefundStatus.processed) return refund;
      return _applyRecord(
        session,
        refund,
        record,
        transaction: transaction,
        failureReason: failureReason,
      );
    });
    if (updated != null) await _auditOutcome(session, updated);
    return updated;
  }

  Future<TestRefund?> _processOne(
    Session session,
    TestRefund candidate, {
    required RazorpayCredentials credentials,
    required DateTime now,
  }) async {
    if (candidate.status == RefundStatus.failed &&
        (candidate.attempts >= maxAttempts ||
            (candidate.nextAttemptAt != null &&
                candidate.nextAttemptAt!.isAfter(now)))) {
      return null;
    }
    if (candidate.status == RefundStatus.processing &&
        candidate.providerRefundId == null &&
        candidate.updatedAt.isAfter(now.subtract(processingLease))) {
      // Another sweep holds the lease.
      return null;
    }
    final sponsorship = await Sponsorship.db.findById(
      session,
      candidate.sponsorshipId,
    );
    final paymentId = sponsorship?.providerPaymentId;
    if (paymentId == null) {
      return _markTerminalFailure(
        session,
        candidate.id!,
        'The sponsorship has no captured Razorpay payment to refund.',
      );
    }

    // A refund already accepted by Razorpay is only polled.
    if (candidate.status == RefundStatus.processing &&
        candidate.providerRefundId != null) {
      if (candidate.updatedAt.isAfter(now.subtract(processingLease))) {
        return null;
      }
      return _pollExisting(session, candidate, credentials, paymentId);
    }

    final claimed = await session.db.transaction((transaction) async {
      final row = await TestRefund.db.findById(
        session,
        candidate.id!,
        transaction: transaction,
        lockMode: LockMode.forUpdate,
      );
      if (row == null ||
          row.status != candidate.status ||
          row.attempts != candidate.attempts) {
        return null;
      }
      row.status = RefundStatus.processing;
      row.attempts += 1;
      row.testMode = credentials.isTestMode;
      row.updatedAt = now;
      return TestRefund.db.updateRow(session, row, transaction: transaction);
    });
    if (claimed == null) return null;

    try {
      // A previous attempt may have reached Razorpay before failing locally.
      if (claimed.attempts > 1) {
        final adopted = await _findProviderRefund(
          credentials,
          paymentId,
          claimed.id!,
        );
        if (adopted != null) {
          return await _store(session, claimed.id!, adopted);
        }
      }
      final record = await gateway.createRefund(
        credentials: credentials,
        paymentId: paymentId,
        amountPaise: Money.toPaise(claimed.amount),
        receipt: receiptFor(claimed.id!),
        notes: {
          'fieldnote_refund_id': '${claimed.id}',
          'campaign_id': '${claimed.campaignId}',
          'reason': claimed.reason,
        },
      );
      return await _store(session, claimed.id!, record);
    } on RazorpayPaymentException catch (error) {
      if (error.statusCode == 400) {
        final adopted = await _findProviderRefund(
          credentials,
          paymentId,
          claimed.id!,
        ).catchError((Object _) => null);
        if (adopted != null) return _store(session, claimed.id!, adopted);
      }
      // Raw provider errors stay in the server log; sponsors see refund rows.
      session.log(
        'Razorpay refund ${claimed.id} failed: ${error.message}',
        level: LogLevel.warning,
      );
      return _markRetryableFailure(
        session,
        claimed.id!,
        'Razorpay could not process the refund'
        '${error.statusCode == null ? '' : ' (HTTP ${error.statusCode})'}; '
        'it will be retried.',
        now,
      );
    }
  }

  Future<TestRefund?> _pollExisting(
    Session session,
    TestRefund candidate,
    RazorpayCredentials credentials,
    String paymentId,
  ) async {
    try {
      final refunds = await gateway.listPaymentRefunds(
        credentials: credentials,
        paymentId: paymentId,
      );
      final match = refunds.where((r) => r.id == candidate.providerRefundId);
      if (match.isEmpty) {
        return await _touch(session, candidate.id!);
      }
      return await _store(session, candidate.id!, match.first);
    } on RazorpayPaymentException catch (error) {
      session.log(
        'Refund status poll failed: ${error.message}',
        level: LogLevel.warning,
      );
      return _touch(session, candidate.id!);
    }
  }

  Future<RazorpayRefundRecord?> _findProviderRefund(
    RazorpayCredentials credentials,
    String paymentId,
    int refundId,
  ) async {
    final refunds = await gateway.listPaymentRefunds(
      credentials: credentials,
      paymentId: paymentId,
    );
    for (final refund in refunds) {
      if (refund.notes['fieldnote_refund_id'] == '$refundId' ||
          refund.receipt == receiptFor(refundId)) {
        return refund;
      }
    }
    return null;
  }

  Future<TestRefund?> _store(
    Session session,
    int refundId,
    RazorpayRefundRecord record,
  ) async {
    final updated = await session.db.transaction((transaction) async {
      final row = await TestRefund.db.findById(
        session,
        refundId,
        transaction: transaction,
        lockMode: LockMode.forUpdate,
      );
      if (row == null) return null;
      if (row.status == RefundStatus.processed) return row;
      return _applyRecord(session, row, record, transaction: transaction);
    });
    if (updated != null) await _auditOutcome(session, updated);
    return updated;
  }

  Future<TestRefund> _applyRecord(
    Session session,
    TestRefund row,
    RazorpayRefundRecord record, {
    required Transaction transaction,
    String? failureReason,
  }) {
    final now = DateTime.now().toUtc();
    row.providerRefundId = record.id;
    row.updatedAt = now;
    switch (record.status) {
      case 'processed':
        row.status = RefundStatus.processed;
        row.processedAt = now;
        row.lastError = null;
      case 'failed':
        row.status = RefundStatus.failed;
        row.lastError = failureReason ?? 'Razorpay reported the refund failed.';
        // A provider-side failure is retried with a fresh request.
        row.providerRefundId = null;
        row.nextAttemptAt = now.add(_backoff(row.attempts));
      default:
        row.status = RefundStatus.processing;
    }
    return TestRefund.db.updateRow(session, row, transaction: transaction);
  }

  Future<TestRefund?> _markRetryableFailure(
    Session session,
    int refundId,
    String message,
    DateTime now,
  ) => session.db.transaction((transaction) async {
    final row = await TestRefund.db.findById(
      session,
      refundId,
      transaction: transaction,
      lockMode: LockMode.forUpdate,
    );
    if (row == null || row.status == RefundStatus.processed) return row;
    row.status = RefundStatus.failed;
    row.lastError = message.length > 300 ? message.substring(0, 300) : message;
    row.nextAttemptAt = now.add(_backoff(row.attempts));
    row.updatedAt = now;
    return TestRefund.db.updateRow(session, row, transaction: transaction);
  });

  Future<TestRefund?> _markTerminalFailure(
    Session session,
    int refundId,
    String message,
  ) => session.db.transaction((transaction) async {
    final row = await TestRefund.db.findById(
      session,
      refundId,
      transaction: transaction,
      lockMode: LockMode.forUpdate,
    );
    if (row == null || row.status == RefundStatus.processed) return row;
    row.status = RefundStatus.failed;
    row.attempts = math.max(row.attempts, maxAttempts);
    row.lastError = message;
    row.updatedAt = DateTime.now().toUtc();
    return TestRefund.db.updateRow(session, row, transaction: transaction);
  });

  Future<TestRefund?> _touch(Session session, int refundId) async {
    final row = await TestRefund.db.findById(session, refundId);
    if (row == null) return null;
    row.updatedAt = DateTime.now().toUtc();
    return TestRefund.db.updateRow(session, row);
  }

  Future<void> _auditOutcome(Session session, TestRefund refund) async {
    if (refund.status != RefundStatus.processed &&
        refund.status != RefundStatus.failed) {
      return;
    }
    final sponsorship = await Sponsorship.db.findById(
      session,
      refund.sponsorshipId,
    );
    if (sponsorship == null) return;
    await _events.audit(
      session,
      actor: sponsorship.sponsorAuthUserId,
      event: 'paymentRefund',
      entityType: 'sponsorship',
      entityId: '${sponsorship.id}',
      outcome: refund.status,
      riskLevel: refund.status == RefundStatus.failed ? 'warning' : 'info',
      detail: refund.status == RefundStatus.processed
          ? 'Refund of ₹${refund.amount.toStringAsFixed(2)} processed${refund.testMode ? ' in Razorpay Test Mode' : ''}.'
          : 'Refund attempt ${refund.attempts} failed and will be retried.',
    );
    if (refund.status == RefundStatus.processed) {
      await const NotificationService().refundProcessed(
        session,
        refund,
        sponsorship,
      );
    }
  }

  static Duration _backoff(int attempts) =>
      Duration(minutes: 5 * math.pow(2, math.max(0, attempts - 1)).toInt());
}
