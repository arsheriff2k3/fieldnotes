import 'dart:convert';
import 'dart:math' as math;

import 'package:mailer/mailer.dart' as mailer;
import 'package:mailer/smtp_server.dart' as smtp;
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart' as auth;
import 'package:serverpod_auth_idp_server/providers/email.dart' as email_idp;

import '../../generated/protocol.dart';
import 'fieldnote_time.dart';

/// Sends one transactional email. Tests install a fake via
/// [NotificationRuntime.mailerResolver].
abstract interface class NotificationMailer {
  Future<void> send({
    required String to,
    required String subject,
    required String text,
    required String html,
  });
}

/// SMTP delivery with the same `smtpUsername` / `smtpAppPassword` passwords
/// as the signup verification sender. `smtpHost` (and optionally `smtpPort`)
/// switch from Gmail to any STARTTLS provider.
class SmtpNotificationMailer implements NotificationMailer {
  SmtpNotificationMailer._(this._server, this._from);

  final smtp.SmtpServer _server;
  final String _from;

  /// Null when SMTP is not configured.
  static SmtpNotificationMailer? fromSession(Session session) {
    final username = session.passwords['smtpUsername']?.trim();
    final password = session.passwords['smtpAppPassword']?.trim();
    if (username == null ||
        username.isEmpty ||
        password == null ||
        password.isEmpty) {
      return null;
    }
    final host = session.passwords['smtpHost']?.trim();
    final port = int.tryParse(session.passwords['smtpPort']?.trim() ?? '');
    final server = host == null || host.isEmpty
        ? smtp.gmail(username, password)
        : smtp.SmtpServer(
            host,
            port: port ?? 587,
            username: username,
            password: password,
          );
    return SmtpNotificationMailer._(server, username);
  }

  @override
  Future<void> send({
    required String to,
    required String subject,
    required String text,
    required String html,
  }) async {
    final message = mailer.Message()
      ..from = mailer.Address(_from, 'FieldNote')
      ..recipients.add(to)
      ..subject = subject
      ..text = text
      ..html = html;
    await mailer.send(message, _server, timeout: const Duration(seconds: 20));
  }
}

abstract final class NotificationRuntime {
  static NotificationMailer? Function(Session session)? mailerResolver;

  static NotificationMailer? mailer(Session session) => mailerResolver != null
      ? mailerResolver!(session)
      : SmtpNotificationMailer.fromSession(session);

  static void reset() => mailerResolver = null;
}

abstract final class NotificationKind {
  static const campaignCancelled = 'campaignCancelled';
  static const campaignExpired = 'campaignExpired';
  static const campaignPostponed = 'campaignPostponed';
  static const campaignRevised = 'campaignRevised';
  static const campaignConfirmed = 'campaignConfirmed';
  static const invitationReceived = 'invitationReceived';
  static const paymentVerified = 'paymentVerified';
  static const refundProcessed = 'refundProcessed';
  static const evidenceApproved = 'evidenceApproved';
  static const evidenceRejected = 'evidenceRejected';
  static const accountDeleted = 'accountDeleted';
}

abstract final class NotificationStatus {
  static const pending = 'pending';
  static const sending = 'sending';
  static const sent = 'sent';
  static const skipped = 'skipped';
  static const failed = 'failed';
}

typedef NotificationRunResult = ({int sent, int skipped, int failed});

/// A-9: transactional email through an outbox.
///
/// Business actions only insert rows (never fail because of email); the
/// `fieldnote-outbox` future call delivers them every minute with retries.
/// One row per (recipient, dedupeKey), so repeated or retried actions never
/// send a second email for the same event.
class NotificationService {
  const NotificationService();

  static const maxAttempts = 5;
  static const sendingLease = Duration(minutes: 10);

  /// Queues one email. Returns false when it was already queued. Never
  /// throws: a notification problem must not fail the business action.
  Future<bool> enqueue(
    Session session, {
    required UuidValue recipient,
    required String kind,
    required String dedupeKey,
    required String subject,
    required String text,
    String? toEmail,
  }) async {
    try {
      final existing = await NotificationOutbox.db.findFirstRow(
        session,
        where: (t) =>
            t.recipientAuthUserId.equals(recipient) &
            t.dedupeKey.equals(dedupeKey),
      );
      if (existing != null) return false;
      await NotificationOutbox.db.insertRow(
        session,
        NotificationOutbox(
          recipientAuthUserId: recipient,
          kind: kind,
          dedupeKey: dedupeKey,
          subject: subject,
          bodyText: text,
          bodyHtml: _html(subject, text),
          toEmail: toEmail,
        ),
      );
      return true;
    } catch (error, stackTrace) {
      session.log(
        'Notification $kind could not be queued.',
        level: LogLevel.warning,
        exception: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Notifies volunteers holding a place in [campaign] about a schedule
  /// change. Cancel and expiry also reach places that were just cancelled.
  Future<int> campaignChanged(
    Session session,
    Campaign campaign,
    String kind,
  ) async {
    final terminal =
        kind == NotificationKind.campaignCancelled ||
        kind == NotificationKind.campaignExpired;
    final participations = await CampaignParticipation.db.find(
      session,
      where: (t) =>
          t.campaignId.equals(campaign.id!) &
          t.status.inSet({
            ParticipationStatus.joined,
            ParticipationStatus.checkedIn,
            if (terminal) ParticipationStatus.cancelled,
          }),
    );
    final when = _when(campaign.startsAt);
    final (subject, text) = switch (kind) {
      NotificationKind.campaignCancelled => (
        'Cancelled: ${campaign.name}. Do not travel',
        'The organizer cancelled "${campaign.name}" ($when at ${campaign.locationName}).\n\n'
            'Do not travel to the work site. Your place has been released.',
      ),
      NotificationKind.campaignExpired => (
        'Not going ahead: ${campaign.name}. Do not travel',
        '"${campaign.name}" ($when) was not confirmed in time and will not go ahead.\n\n'
            'Do not travel to the work site. Sponsors are being refunded.',
      ),
      NotificationKind.campaignPostponed => (
        'New date for ${campaign.name}',
        '"${campaign.name}" has a new proposed time: $when at ${campaign.locationName}.\n\n'
            'Open FieldNote to review the change and reconfirm your place.',
      ),
      NotificationKind.campaignRevised => (
        'Updated plan for ${campaign.name}',
        'The organizer revised the work plan for "${campaign.name}" ($when).\n\n'
            'Open FieldNote to review the change and reconfirm your place.',
      ),
      _ => (
        'Confirmed: ${campaign.name}',
        '"${campaign.name}" is confirmed for $when at ${campaign.locationName}.\n\n'
            'Check in on site in FieldNote from 30 minutes before the start.',
      ),
    };
    final key = switch (kind) {
      NotificationKind.campaignCancelled ||
      NotificationKind.campaignExpired => 'campaign:${campaign.id}:$kind',
      _ => 'campaign:${campaign.id}:rev${campaign.revision}:$kind',
    };
    var queued = 0;
    for (final participation in participations) {
      if (await enqueue(
        session,
        recipient: participation.volunteerAuthUserId,
        kind: kind,
        dedupeKey: key,
        subject: subject,
        text: text,
      )) {
        queued++;
      }
    }
    return queued;
  }

  Future<int> invitationsReceived(
    Session session,
    Campaign campaign,
    Iterable<UuidValue> volunteers,
  ) async {
    var queued = 0;
    for (final volunteer in volunteers) {
      if (await enqueue(
        session,
        recipient: volunteer,
        kind: NotificationKind.invitationReceived,
        dedupeKey: 'invite:${campaign.id}',
        subject: 'You are invited: ${campaign.name}',
        text:
            'The organizer of "${campaign.name}" invited you to help on '
            '${_when(campaign.startsAt)} at ${campaign.locationName}.\n\n'
            'Open FieldNote to see the details and decide whether to join.',
      )) {
        queued++;
      }
    }
    return queued;
  }

  Future<void> paymentVerified(Session session, Sponsorship sponsorship) async {
    final campaign = await Campaign.db.findById(
      session,
      sponsorship.campaignId,
    );
    await enqueue(
      session,
      recipient: sponsorship.sponsorAuthUserId,
      kind: NotificationKind.paymentVerified,
      dedupeKey: 'payment:${sponsorship.id}:verified',
      subject: 'Payment received for ${campaign?.name ?? 'your campaign'}',
      text:
          'Your sponsorship of ₹${sponsorship.amount.toStringAsFixed(2)} for '
          '"${campaign?.name ?? 'a FieldNote campaign'}" was verified.\n\n'
          'Razorpay payment: ${sponsorship.providerPaymentId ?? '-'}',
    );
  }

  Future<void> refundProcessed(
    Session session,
    TestRefund refund,
    Sponsorship sponsorship,
  ) async {
    final campaign = await Campaign.db.findById(session, refund.campaignId);
    await enqueue(
      session,
      recipient: sponsorship.sponsorAuthUserId,
      kind: NotificationKind.refundProcessed,
      dedupeKey: 'refund:${refund.id}:processed',
      subject: 'Refund processed',
      text:
          'A refund of ₹${refund.amount.toStringAsFixed(2)} for '
          '"${campaign?.name ?? 'a FieldNote campaign'}" was processed'
          '${refund.testMode ? ' in Razorpay Test Mode (no real money moved)' : ''}.\n\n'
          'Banks usually show refunds within 5–7 working days.',
    );
  }

  Future<void> evidenceReviewed(
    Session session, {
    required CompletionEvidence evidence,
    required UuidValue volunteer,
    required Campaign campaign,
  }) async {
    final approved = evidence.reviewState == ReviewState.approved;
    await enqueue(
      session,
      recipient: volunteer,
      kind: approved
          ? NotificationKind.evidenceApproved
          : NotificationKind.evidenceRejected,
      dedupeKey: 'evidence:${evidence.id}:${evidence.reviewState.name}',
      subject: approved
          ? 'Your work on ${campaign.name} was approved'
          : 'Your evidence for ${campaign.name} needs attention',
      text: approved
          ? 'The organizer approved the evidence you submitted for "${campaign.name}". Thank you!'
          : 'The organizer did not accept the evidence you submitted for "${campaign.name}".\n\n'
                'Reason: ${evidence.reviewNote ?? 'not given'}',
    );
  }

  Future<void> accountDeleted(
    Session session, {
    required UuidValue anonymousId,
    required String email,
  }) => enqueue(
    session,
    recipient: anonymousId,
    kind: NotificationKind.accountDeleted,
    dedupeKey: 'account:deleted',
    toEmail: email,
    subject: 'Your FieldNote account was deleted',
    text:
        'Your FieldNote account and personal data have been deleted.\n\n'
        'Payment and refund records are kept without your name for accounting, '
        'as described in the Privacy Policy. If you did not request this, '
        'reply to this email.',
  );

  /// Delivers due rows. Absent SMTP marks rows `skipped` and never fails.
  Future<NotificationRunResult> deliverDue(
    Session session, {
    DateTime? now,
  }) async {
    final clock = now ?? DateTime.now().toUtc();
    final claimed = await session.db.transaction((transaction) async {
      final rows = await NotificationOutbox.db.find(
        session,
        where: (t) =>
            t.status.equals(NotificationStatus.pending) |
            (t.status.inSet({
                  NotificationStatus.failed,
                  NotificationStatus.sending,
                }) &
                (t.nextAttemptAt <= clock) &
                (t.attempts < maxAttempts)),
        orderBy: (t) => t.createdAt,
        limit: 25,
        transaction: transaction,
        lockMode: LockMode.forUpdate,
        lockBehavior: LockBehavior.skipLocked,
      );
      for (final row in rows) {
        row.status = NotificationStatus.sending;
        row.attempts += 1;
        row.nextAttemptAt = clock.add(sendingLease);
      }
      if (rows.isEmpty) return rows;
      return NotificationOutbox.db.update(
        session,
        rows,
        transaction: transaction,
      );
    });
    var sent = 0;
    var skipped = 0;
    var failed = 0;
    if (claimed.isEmpty) return (sent: 0, skipped: 0, failed: 0);
    final mailer = NotificationRuntime.mailer(session);
    for (final row in claimed) {
      final skip = await _skipReason(session, row, mailer);
      if (skip != null) {
        await _finish(session, row, NotificationStatus.skipped, error: skip);
        skipped++;
        continue;
      }
      final to =
          row.toEmail ?? await emailFor(session, row.recipientAuthUserId);
      if (to == null) {
        await _finish(
          session,
          row,
          NotificationStatus.skipped,
          error: 'no_email',
        );
        skipped++;
        continue;
      }
      try {
        await mailer!.send(
          to: to,
          subject: row.subject,
          text: row.bodyText,
          html: row.bodyHtml,
        );
        await _finish(session, row, NotificationStatus.sent);
        sent++;
      } catch (error, stackTrace) {
        // The address and SMTP response stay in the server log only.
        session.log(
          'Notification ${row.id} (${row.kind}) delivery failed.',
          level: LogLevel.warning,
          exception: error,
          stackTrace: stackTrace,
        );
        final terminal = row.attempts >= maxAttempts;
        row.nextAttemptAt = clock.add(
          Duration(minutes: 2 * math.pow(2, row.attempts - 1).toInt()),
        );
        await _finish(
          session,
          row,
          NotificationStatus.failed,
          error: 'smtp_error',
          keepEmail: !terminal,
        );
        failed++;
      }
    }
    return (sent: sent, skipped: skipped, failed: failed);
  }

  Future<String?> _skipReason(
    Session session,
    NotificationOutbox row,
    NotificationMailer? mailer,
  ) async {
    if (mailer == null) {
      session.log(
        'Notification ${row.id} (${row.kind}) skipped: SMTP is not configured.',
        level: LogLevel.info,
      );
      return 'smtp_not_configured';
    }
    if (row.kind == NotificationKind.accountDeleted) return null;
    final profile = await FieldnoteUserProfile.db.findFirstRow(
      session,
      where: (t) => t.authUserId.equals(row.recipientAuthUserId),
    );
    if (profile == null) return 'no_profile';
    if (!profile.emailNotifications) return 'opted_out';
    return null;
  }

  Future<void> _finish(
    Session session,
    NotificationOutbox row,
    String status, {
    String? error,
    bool keepEmail = false,
  }) async {
    row.status = status;
    row.lastError = error;
    if (status == NotificationStatus.sent) row.sentAt = DateTime.now().toUtc();
    if (status != NotificationStatus.failed) row.nextAttemptAt = null;
    if (!keepEmail) row.toEmail = null;
    await NotificationOutbox.db.updateRow(session, row);
  }

  /// The sign-in email of an auth user, or null.
  static Future<String?> emailFor(Session session, UuidValue authUserId) async {
    final account = await email_idp.EmailAccount.db.findFirstRow(
      session,
      where: (t) => t.authUserId.equals(authUserId),
    );
    if (account != null) return account.email;
    final profile = await auth.UserProfile.db.findFirstRow(
      session,
      where: (t) => t.authUserId.equals(authUserId),
    );
    return profile?.email;
  }

  static String _when(DateTime startsAt) {
    // FieldNote launches in India; email times are shown in IST.
    final ist = FieldnoteTime.wallClock(
      startsAt,
      FieldnoteTime.defaultUtcOffsetMinutes,
    );
    String two(int v) => v.toString().padLeft(2, '0');
    return '${ist.year}-${two(ist.month)}-${two(ist.day)} '
        '${two(ist.hour)}:${two(ist.minute)} IST';
  }

  static String _html(String subject, String text) {
    const escape = HtmlEscape();
    final paragraphs = text
        .split('\n\n')
        .map((p) => '<p>${escape.convert(p).replaceAll('\n', '<br>')}</p>')
        .join();
    return '<!doctype html><html><body style="font-family:system-ui,sans-serif;'
        'color:#17352c;max-width:560px;margin:auto;padding:16px">'
        '<h2 style="font-family:Georgia,serif">${escape.convert(subject)}</h2>'
        '$paragraphs<p style="color:#527267;font-size:13px">FieldNote · '
        'Manage email preferences in the app under Profile.</p></body></html>';
  }
}
