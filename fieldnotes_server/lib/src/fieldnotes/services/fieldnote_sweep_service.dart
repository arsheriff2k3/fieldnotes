import 'package:serverpod/serverpod.dart';

import 'account_deletion_service.dart';
import 'campaign_lifecycle_service.dart';
import 'notification_service.dart';
import 'payment_reconciliation_service.dart';
import 'rate_limiter.dart';
import 'refund_service.dart';

/// Everything the 5-minute `campaign-readiness-sweep` future call does. Each
/// step is isolated so one failing provider cannot stall the others.
class FieldnoteSweepService {
  const FieldnoteSweepService();

  Future<void> run(Session session) async {
    await _step(
      session,
      'readiness',
      () => const CampaignLifecycleService().refreshDueCampaigns(session),
    );
    await _step(
      session,
      'completion',
      () => const CampaignLifecycleService().completeEndedCampaigns(session),
    );
    await _step(
      session,
      'reconciliation',
      () => const PaymentReconciliationService().reconcile(session),
    );
    await _step(
      session,
      'uncredited refunds',
      () => const RefundService().queueUncredited(session),
    );
    await _step(
      session,
      'refund worker',
      () => const RefundService().processDue(session),
    );
  }

  Future<void> _step(
    Session session,
    String name,
    Future<Object?> Function() body,
  ) => runStep(session, name, body);
}

/// The 1-minute `fieldnote-outbox` future call: account deletions, email
/// delivery and rate-limit window cleanup.
class FieldnoteOutboxService {
  const FieldnoteOutboxService();

  Future<void> run(Session session) async {
    await runStep(
      session,
      'account deletions',
      () => const AccountDeletionService().processDue(session),
    );
    await runStep(
      session,
      'notifications',
      () => const NotificationService().deliverDue(session),
    );
    await runStep(
      session,
      'rate-limit cleanup',
      () => const RateLimiter().purgeExpired(session),
    );
  }
}

Future<void> runStep(
  Session session,
  String name,
  Future<Object?> Function() body,
) async {
  try {
    final result = await body();
    session.log('Sweep $name finished: $result');
  } catch (error, stackTrace) {
    session.log(
      'Sweep $name failed.',
      level: LogLevel.error,
      exception: error,
      stackTrace: stackTrace,
    );
  }
}
