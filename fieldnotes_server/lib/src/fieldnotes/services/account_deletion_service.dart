import 'dart:math' as math;

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart' as auth;

import '../../generated/protocol.dart';
import 'campaign_events_service.dart';
import 'campaign_lifecycle_service.dart';
import 'notification_service.dart';
import 'payment_reconciliation_service.dart';
import 'refund_service.dart';

abstract final class AccountDeletionStatus {
  static const pending = 'pending';
  static const processing = 'processing';
  static const completed = 'completed';
  static const failed = 'failed';
}

typedef DeletionRunResult = ({int completed, int failed});

/// P0-6: real account deletion.
///
/// Policy:
/// - **Refused** (clear error code, nothing changes) while the user has an
///   obligation that must settle first: a volunteer checked in to an open
///   campaign, a sponsor with an open (not cancelled, expired or completed)
///   campaign they created, a refund still in flight, or a checkout from the
///   last 30 minutes that may still be captured.
/// - **Handled automatically**: joined-but-not-checked-in places are left so
///   the seat frees up, and invitations are deleted.
/// - **Deleted**: availability, current consent row, invitations, private
///   evidence photographs, notification outbox and rate-limit rows, and the
///   Serverpod auth user (cascading to email login, refresh tokens, server
///   sessions and the auth profile). All refresh tokens are revoked first and
///   live streams are told the user's authentication was revoked.
/// - **Anonymised** under a fresh random id that is stored nowhere else:
///   profile ("Deleted user", contact and location cleared), the volunteer's
///   evidence text, consent history (kept as the legal record), audit events,
///   participations, and financial rows (sponsorships, refunds via their
///   sponsorship, test payouts) which are kept for accounting.
class AccountDeletionService {
  const AccountDeletionService();

  static const maxAttempts = 5;
  static const processingLease = Duration(minutes: 10);
  static const deletedDisplayName = 'Deleted user';
  static const _events = CampaignEventsService();

  static const _blockerMessages = {
    'deletion_blocked_checked_in':
        'You are checked in to a campaign. Finish or wait for it to close before deleting your account.',
    'deletion_blocked_open_campaign':
        'Cancel or complete the campaigns you created before deleting your account. Cancelling refunds sponsors.',
    'deletion_blocked_refund_pending':
        'A refund for one of your payments is still being processed. Try again once it completes.',
    'deletion_blocked_payout_pending':
        'A creator payout is pending. Resolve it before deleting your account.',
    'deletion_blocked_payment_pending':
        'A payment you started recently is still being confirmed. Try again in 30 minutes.',
  };

  /// The first unsettled obligation as `(code, message)`, or null.
  Future<({String code, String message})?> blocker(
    Session session,
    UuidValue userId, {
    DateTime? now,
  }) async {
    final clock = now ?? DateTime.now().toUtc();
    String? code;
    final checkedIn = await CampaignParticipation.db.find(
      session,
      where: (t) =>
          t.volunteerAuthUserId.equals(userId) &
          t.status.equals(ParticipationStatus.checkedIn),
    );
    if (checkedIn.isNotEmpty) {
      final campaigns = await Campaign.db.find(
        session,
        where: (t) => t.id.inSet(checkedIn.map((p) => p.campaignId).toSet()),
      );
      if (campaigns.any((c) => !CampaignLifecycleService.isClosed(c))) {
        code = 'deletion_blocked_checked_in';
      }
    }
    if (code == null) {
      final open = await Campaign.db.count(
        session,
        where: (t) =>
            t.createdBy.equals(userId) &
            t.status.equals(CampaignStatus.active) &
            t.readinessState.notInSet({'cancelled', 'expired'}),
      );
      if (open > 0) code = 'deletion_blocked_open_campaign';
    }
    if (code == null) {
      final sponsorships = await Sponsorship.db.find(
        session,
        where: (t) => t.sponsorAuthUserId.equals(userId),
      );
      if (sponsorships.any(
        (s) =>
            s.paymentStatus == 'created' &&
            s.createdAt.isAfter(
              clock.subtract(PaymentReconciliationService.orderTtl),
            ),
      )) {
        code = 'deletion_blocked_payment_pending';
      } else if (sponsorships.isNotEmpty) {
        final refunds = await TestRefund.db.find(
          session,
          where: (t) =>
              t.sponsorshipId.inSet(sponsorships.map((s) => s.id!).toSet()),
        );
        final refunded = refunds.map((r) => r.sponsorshipId).toSet();
        final inFlight = refunds.any(
          (r) =>
              r.status != RefundStatus.processed &&
              !(r.status == RefundStatus.failed &&
                  r.attempts >= RefundService.maxAttempts),
        );
        final unqueued = sponsorships.any(
          (s) =>
              s.paymentStatus == 'verified_uncredited' &&
              !refunded.contains(s.id),
        );
        if (inFlight || unqueued) code = 'deletion_blocked_refund_pending';
      }
    }
    if (code == null) {
      final pendingPayouts = await ManualPayoutRequest.db.count(
        session,
        where: (t) =>
            t.creatorAuthUserId.equals(userId) &
            t.status.inSet({'requested', 'processing'}),
      );
      if (pendingPayouts > 0) code = 'deletion_blocked_payout_pending';
    }
    return code == null ? null : (code: code, message: _blockerMessages[code]!);
  }

  /// Creates (or re-opens) the caller's request. Throws the blocker as a
  /// [FieldnoteException] so the app can explain what to settle first.
  Future<AccountDeletionRequest> request(
    Session session,
    UuidValue userId,
  ) async {
    final blocked = await blocker(session, userId);
    if (blocked != null) {
      throw FieldnoteException(message: blocked.message, code: blocked.code);
    }
    final existing = await AccountDeletionRequest.db.findFirstRow(
      session,
      where: (t) => t.authUserId.equals(userId),
    );
    final now = DateTime.now().toUtc();
    if (existing == null) {
      return AccountDeletionRequest.db.insertRow(
        session,
        AccountDeletionRequest(authUserId: userId),
      );
    }
    if (existing.status == AccountDeletionStatus.failed) {
      existing
        ..status = AccountDeletionStatus.pending
        ..attempts = 0
        ..lastError = null
        ..nextAttemptAt = null
        ..updatedAt = now;
      return AccountDeletionRequest.db.updateRow(session, existing);
    }
    return existing;
  }

  /// Runs every due request. Called by the outbox future call.
  Future<DeletionRunResult> processDue(Session session, {DateTime? now}) async {
    final clock = now ?? DateTime.now().toUtc();
    final due = await AccountDeletionRequest.db.find(
      session,
      where: (t) =>
          t.status.equals(AccountDeletionStatus.pending) |
          (t.status.inSet({
                AccountDeletionStatus.failed,
                AccountDeletionStatus.processing,
              }) &
              (t.nextAttemptAt <= clock) &
              (t.attempts < maxAttempts)),
      orderBy: (t) => t.requestedAt,
      limit: 10,
    );
    var completed = 0;
    var failed = 0;
    for (final request in due) {
      final result = await process(session, request.id!, now: clock);
      if (result?.status == AccountDeletionStatus.completed) completed++;
      if (result?.status == AccountDeletionStatus.failed) failed++;
    }
    return (completed: completed, failed: failed);
  }

  /// Executes one request. Safe to retry: every step is idempotent.
  Future<AccountDeletionRequest?> process(
    Session session,
    int requestId, {
    DateTime? now,
  }) async {
    final clock = now ?? DateTime.now().toUtc();
    final claimed = await session.db.transaction((transaction) async {
      final row = await AccountDeletionRequest.db.findById(
        session,
        requestId,
        transaction: transaction,
        lockMode: LockMode.forUpdate,
      );
      if (row == null || row.status == AccountDeletionStatus.completed) {
        return null;
      }
      row
        ..status = AccountDeletionStatus.processing
        ..attempts += 1
        ..processedAt = clock
        ..nextAttemptAt = clock.add(processingLease)
        ..updatedAt = clock;
      return AccountDeletionRequest.db.updateRow(
        session,
        row,
        transaction: transaction,
      );
    });
    if (claimed == null) return null;
    final userId = claimed.authUserId;
    final blocked = await blocker(session, userId, now: clock);
    if (blocked != null) {
      // A new obligation appeared after the request; the user must settle it
      // and request again.
      return _fail(session, claimed, blocked.code, retry: false);
    }
    try {
      final email = await NotificationService.emailFor(session, userId);
      final anonymousId = _randomUuid();
      final storagePaths = await _anonymise(session, userId, anonymousId);
      for (final path in storagePaths) {
        try {
          await session.storage.deleteFile(storageId: 'private', path: path);
        } catch (error) {
          session.log(
            'Evidence file could not be deleted; it is unreferenced.',
            level: LogLevel.warning,
            exception: error,
          );
        }
      }
      await _deleteAuthUser(session, userId);
      claimed
        ..status = AccountDeletionStatus.completed
        ..completedAt = DateTime.now().toUtc()
        ..nextAttemptAt = null
        ..lastError = null
        ..updatedAt = DateTime.now().toUtc();
      final done = await AccountDeletionRequest.db.updateRow(session, claimed);
      await _events.audit(
        session,
        actor: anonymousId,
        event: 'accountDeletionCompleted',
        entityType: 'account',
        outcome: 'completed',
        riskLevel: 'info',
        detail:
            'Personal data deleted; financial and consent records kept without identity.',
      );
      if (email != null) {
        await const NotificationService().accountDeleted(
          session,
          anonymousId: anonymousId,
          email: email,
        );
      }
      return done;
    } catch (error, stackTrace) {
      session.log(
        'Account deletion ${claimed.id} failed.',
        level: LogLevel.error,
        exception: error,
        stackTrace: stackTrace,
      );
      return _fail(session, claimed, 'deletion_failed', retry: true);
    }
  }

  Future<AccountDeletionRequest> _fail(
    Session session,
    AccountDeletionRequest row,
    String code, {
    required bool retry,
  }) {
    final now = DateTime.now().toUtc();
    row
      ..status = AccountDeletionStatus.failed
      ..lastError = code
      ..nextAttemptAt = retry && row.attempts < maxAttempts
          ? now.add(Duration(minutes: 5 * math.pow(2, row.attempts).toInt()))
          : null
      ..updatedAt = now;
    if (!retry) row.attempts = maxAttempts;
    return AccountDeletionRequest.db.updateRow(session, row);
  }

  /// Deletes and re-keys every FieldNote row for [userId] in one transaction.
  /// Returns the private storage paths to delete afterwards.
  Future<List<String>> _anonymise(
    Session session,
    UuidValue userId,
    UuidValue anonymousId,
  ) => session.db.transaction((transaction) async {
    final now = DateTime.now().toUtc();
    // Only the placeholders a statement uses are bound.
    Future<void> sql(String statement) => session.db.unsafeExecute(
      statement,
      parameters: QueryParameters.named({
        'user': userId.uuid,
        if (statement.contains('@anon')) 'anon': anonymousId.uuid,
      }),
      transaction: transaction,
    );

    await CampaignChatMessage.db.deleteWhere(
      session,
      where: (t) => t.senderAuthUserId.equals(userId),
      transaction: transaction,
    );

    // Volunteer places: leave open joins so the seat frees up.
    final participations = await CampaignParticipation.db.find(
      session,
      where: (t) => t.volunteerAuthUserId.equals(userId),
      transaction: transaction,
    );
    final paths = <String>{};
    final touchedCampaigns = <int>{};
    for (final participation in participations) {
      if (participation.status == ParticipationStatus.joined) {
        participation.status = ParticipationStatus.left;
        participation.leftAt = now;
        touchedCampaigns.add(participation.campaignId);
      }
      if (participation.evidenceUploadPath case final path?) paths.add(path);
      participation.evidenceUploadPath = null;
      participation.volunteerAuthUserId = anonymousId;
    }
    if (participations.isNotEmpty) {
      await CampaignParticipation.db.update(
        session,
        participations,
        transaction: transaction,
      );
      final evidence = await CompletionEvidence.db.find(
        session,
        where: (t) =>
            t.participationId.inSet(participations.map((p) => p.id!).toSet()),
        transaction: transaction,
      );
      for (final item in evidence) {
        if (item.photographPath case final path?) paths.add(path);
        item
          ..photographPath = null
          ..originalNote = ''
          ..confirmedSummary =
              'Redacted after the volunteer deleted their account.'
          ..structuredResults = '';
      }
      if (evidence.isNotEmpty) {
        await CompletionEvidence.db.update(
          session,
          evidence,
          transaction: transaction,
        );
      }
    }

    final profile = await FieldnoteUserProfile.db.findFirstRow(
      session,
      where: (t) => t.authUserId.equals(userId),
      transaction: transaction,
    );
    if (profile != null) {
      profile
        ..authUserId = anonymousId
        ..displayName = deletedDisplayName
        ..sponsorType = null
        ..organizationName = null
        ..contactPhone = null
        ..city = ''
        ..locationAddress = null
        ..locationPlaceId = null
        ..locationLatitude = null
        ..locationLongitude = null
        ..interests = ''
        ..skills = ''
        ..emailNotifications = false
        ..updatedAt = now;
      await FieldnoteUserProfile.db.updateRow(
        session,
        profile,
        transaction: transaction,
      );
    }

    await sql(
      'DELETE FROM "fieldnote_volunteer_availability" WHERE "volunteerAuthUserId" = @user::uuid',
    );
    await sql(
      'DELETE FROM "fieldnote_legal_consent" WHERE "authUserId" = @user::uuid',
    );
    await sql(
      'DELETE FROM "fieldnote_campaign_invitation" WHERE "volunteerAuthUserId" = @user::uuid OR "sponsorAuthUserId" = @user::uuid',
    );
    await sql(
      'DELETE FROM "fieldnote_notification_outbox" WHERE "recipientAuthUserId" = @user::uuid',
    );
    await sql(
      'DELETE FROM "fieldnote_push_delivery" WHERE "recipientAuthUserId" = @user::uuid',
    );
    await sql(
      'DELETE FROM "fieldnote_push_device" WHERE "authUserId" = @user::uuid',
    );
    await sql(
      'DELETE FROM "fieldnote_in_app_notification" WHERE "recipientAuthUserId" = @user::uuid',
    );
    await sql(
      'DELETE FROM "fieldnote_rate_limit_bucket" WHERE "authUserId" = @user::uuid',
    );
    await sql(
      'UPDATE "fieldnote_legal_consent_history" SET "authUserId" = @anon::uuid WHERE "authUserId" = @user::uuid',
    );
    await sql(
      'UPDATE "fieldnote_audit_event" SET "actorAuthUserId" = @anon::uuid WHERE "actorAuthUserId" = @user::uuid',
    );
    await sql(
      'UPDATE "fieldnote_sponsorship" SET "sponsorAuthUserId" = @anon::uuid, "message" = NULL WHERE "sponsorAuthUserId" = @user::uuid',
    );
    await sql(
      'UPDATE "fieldnote_manual_payout_request" SET "creatorAuthUserId" = @anon::uuid, "reviewNote" = NULL WHERE "creatorAuthUserId" = @user::uuid',
    );
    await sql(
      'UPDATE "fieldnote_manual_payout_request" SET "reviewedByAuthUserId" = @anon::uuid WHERE "reviewedByAuthUserId" = @user::uuid',
    );
    await sql(
      'UPDATE "fieldnote_test_payout" SET "creatorAuthUserId" = @anon::uuid WHERE "creatorAuthUserId" = @user::uuid',
    );
    await sql(
      'UPDATE "fieldnote_campaign" SET "createdBy" = @anon::uuid WHERE "createdBy" = @user::uuid',
    );
    await sql(
      'UPDATE "fieldnote_campaign_post" SET "authorSponsorAuthUserId" = @anon::uuid WHERE "authorSponsorAuthUserId" = @user::uuid',
    );
    await sql(
      'UPDATE "fieldnote_completion_evidence" SET "reviewedByAuthUserId" = @anon::uuid WHERE "reviewedByAuthUserId" = @user::uuid',
    );
    for (final campaignId in touchedCampaigns) {
      await _events.audit(
        session,
        actor: anonymousId,
        event: 'campaignLeft',
        entityType: 'campaign',
        entityId: '$campaignId',
        outcome: 'left',
        riskLevel: 'info',
        detail:
            'A place was released because a volunteer deleted their account.',
        transaction: transaction,
      );
    }
    return paths.toList();
  });

  Future<void> _deleteAuthUser(Session session, UuidValue userId) async {
    try {
      await auth.AuthServices.instance.tokenManager.revokeAllTokens(
        session,
        authUserId: userId,
      );
    } on StateError {
      // AuthServices is not initialised (tests, maintenance role); deleting
      // the auth user below cascades to its refresh tokens and sessions.
    }
    await auth.AuthUser.db.deleteWhere(
      session,
      where: (t) => t.id.equals(userId),
    );
    await session.messages.authenticationRevoked(
      userId.uuid,
      RevokedAuthenticationUser(),
    );
  }

  static final _random = math.Random.secure();

  static UuidValue _randomUuid() {
    final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return UuidValue.withValidation(
      '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-'
      '${hex.substring(16, 20)}-${hex.substring(20)}',
    );
  }
}
