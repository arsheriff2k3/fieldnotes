import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:fieldnotes_server/src/fieldnotes/services/campaign_lifecycle_service.dart';
import 'package:fieldnotes_server/src/fieldnotes/services/campaign_validation.dart';
import 'package:fieldnotes_server/src/fieldnotes/services/payment_credit_service.dart';
import 'package:fieldnotes_server/src/fieldnotes/services/payment_reconciliation_service.dart';
import 'package:fieldnotes_server/src/fieldnotes/services/razorpay_payment_service.dart';
import 'package:fieldnotes_server/src/fieldnotes/services/razorpay_webhook_service.dart';
import 'package:fieldnotes_server/src/fieldnotes/services/refund_service.dart';
import 'package:fieldnotes_server/src/fieldnotes/services/structured_summary_service.dart';
import 'package:fieldnotes_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

const _sponsorId = '660e8400-e29b-41d4-a716-446655440000';
const _funderId = '660e8400-e29b-41d4-a716-446655440003';
const _volunteerId = '660e8400-e29b-41d4-a716-446655440001';
const _secondVolunteerId = '660e8400-e29b-41d4-a716-446655440002';
const _webhookSecret = 'whsec_fieldnote_test';
const _siteLatitude = 18.52040;
const _siteLongitude = 73.85670;

/// In-memory Razorpay used by every money test.
class FakeRazorpayGateway implements RazorpayGateway {
  final orderPayments = <String, List<RazorpayPaymentRecord>>{};
  final refundsByPayment = <String, List<RazorpayRefundRecord>>{};
  var createRefundCalls = 0;
  var fetchOrderCalls = 0;
  var failRefunds = false;
  var _orders = 0;

  @override
  Future<RazorpayOrderResult> createOrder({
    required String keyId,
    required String keySecret,
    required int amountPaise,
    required String receipt,
    required int campaignId,
  }) async => RazorpayOrderResult(
    id: 'order_fake${++_orders}',
    amountPaise: amountPaise,
    currency: 'INR',
  );

  @override
  Future<List<RazorpayPaymentRecord>> fetchOrderPayments({
    required RazorpayCredentials credentials,
    required String orderId,
  }) async {
    fetchOrderCalls++;
    return orderPayments[orderId] ?? const [];
  }

  @override
  Future<RazorpayRefundRecord> createRefund({
    required RazorpayCredentials credentials,
    required String paymentId,
    required int amountPaise,
    required String receipt,
    required Map<String, String> notes,
  }) async {
    createRefundCalls++;
    if (failRefunds) {
      throw const RazorpayPaymentException('Gateway down', statusCode: 502);
    }
    final record = RazorpayRefundRecord(
      id: 'rfnd_fake$createRefundCalls',
      paymentId: paymentId,
      status: 'processed',
      amountPaise: amountPaise,
      receipt: receipt,
      notes: notes,
    );
    (refundsByPayment[paymentId] ??= []).add(record);
    return record;
  }

  @override
  Future<List<RazorpayRefundRecord>> listPaymentRefunds({
    required RazorpayCredentials credentials,
    required String paymentId,
  }) async => refundsByPayment[paymentId] ?? const [];
}

CampaignProposal _proposal({int capacity = 12, int minimum = 1}) =>
    CampaignProposal(
      title: 'Riverbank Cleanup Morning',
      description: 'Collect litter along the riverbank and document the work.',
      locationName: 'Riverbank',
      startsAt: DateTime.now().toUtc().add(const Duration(days: 2)),
      durationMinutes: 180,
      volunteerCapacity: capacity,
      minimumVolunteers: minimum,
      fundingGoal: 30000,
      requiredSkills: ['Comfortable outdoors'],
      checklist: ['Collect litter', 'Sort recyclables'],
      evidenceInstructions: 'Submit a location-verified photograph and note.',
      tags: ['cleanup', 'environment'],
      rationale: 'Sponsor-confirmed campaign details.',
    );

Matcher _throwsCode(String code) => throwsA(
  isA<FieldnoteException>().having((error) => error.code, 'code', code),
);

String _sign(String body) => Hmac(
  sha256,
  utf8.encode(_webhookSecret),
).convert(utf8.encode(body)).toString();

String _capturedEvent({
  required String orderId,
  required String paymentId,
  required int amountPaise,
  String event = 'payment.captured',
}) => jsonEncode({
  'entity': 'event',
  'event': event,
  'payload': {
    'payment': {
      'entity': {
        'id': paymentId,
        'order_id': orderId,
        'status': event == 'payment.failed' ? 'failed' : 'captured',
        'amount': amountPaise,
        'error_description': event == 'payment.failed' ? 'Card declined' : null,
      },
    },
  },
});

void main() {
  withServerpod('Given money and lifecycle flows', (sessionBuilder, endpoints) {
    TestSessionBuilder as(String id) => sessionBuilder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(id, {}),
    );
    final sponsor = as(_sponsorId);
    final funder = as(_funderId);
    final volunteer = as(_volunteerId);
    final secondVolunteer = as(_secondVolunteerId);
    late FakeRazorpayGateway gateway;

    setUp(() {
      gateway = FakeRazorpayGateway();
      RazorpayRuntime.gateway = gateway;
      RazorpayRuntime.credentialsResolver = (_) => const RazorpayCredentials(
        keyId: 'rzp_test_fake',
        keySecret: 'secret_fake',
      );
    });
    tearDown(RazorpayRuntime.reset);

    Future<void> sponsorProfile(TestSessionBuilder account, String name) async {
      await endpoints.fieldnote.completeSponsorProfile(
        account,
        name,
        'Individual',
        null,
        'Pune',
        null,
        ['environment'],
        contactPhone: '+919876543210',
      );
      await endpoints.fieldnote.acceptLegalConsent(account, true, true, true);
    }

    Future<void> volunteerProfile(TestSessionBuilder account) async {
      await endpoints.fieldnote.completeVolunteerProfile(
        account,
        'Ravi Volunteer',
        'Pune',
        ['environment'],
        ['outdoors'],
        true,
        true,
        [1, 2, 3, 4, 5, 6, 7],
        0,
        1439,
        10,
        _siteLatitude,
        _siteLongitude,
        'Current GPS area',
      );
      await endpoints.fieldnote.acceptLegalConsent(account, true, true, true);
    }

    Future<Campaign> publish({int capacity = 12, int minimum = 1}) async {
      await sponsorProfile(sponsor, 'Asha Sponsor');
      return endpoints.fieldnote.createCampaignFromProposal(
        sponsor,
        _proposal(capacity: capacity, minimum: minimum),
        _siteLatitude,
        _siteLongitude,
        'Riverbank site',
        200,
      );
    }

    Future<Campaign> update(int id, void Function(Campaign) change) async {
      final session = sessionBuilder.build();
      final campaign = (await Campaign.db.findById(session, id))!;
      change(campaign);
      return Campaign.db.updateRow(session, campaign);
    }

    Future<Sponsorship> sponsorshipRow(
      int campaignId, {
      required String status,
      required double amount,
      String? orderId,
      String? paymentId,
      String sponsorId = _sponsorId,
      Duration age = Duration.zero,
    }) => Sponsorship.db.insertRow(
      sessionBuilder.build(),
      Sponsorship(
        campaignId: campaignId,
        sponsorAuthUserId: UuidValue.withValidation(sponsorId),
        amount: amount,
        paymentStatus: status,
        providerOrderId: orderId,
        providerPaymentId: paymentId,
        createdAt: DateTime.now().toUtc().subtract(age),
      ),
    );

    /// A confirmed campaign that is running now, with a checked-in volunteer.
    Future<(Campaign, CampaignParticipation)> checkedIn() async {
      final campaign = await publish();
      await volunteerProfile(volunteer);
      final joined = await endpoints.fieldnote.joinCampaign(
        volunteer,
        campaign.id!,
      );
      final now = DateTime.now().toUtc();
      final running = await update(campaign.id!, (c) {
        c.readinessState = 'confirmed';
        c.startsAt = now.subtract(const Duration(minutes: 30));
        c.endsAt = now.add(const Duration(hours: 2));
      });
      joined
        ..status = ParticipationStatus.checkedIn
        ..checkedInAt = now.subtract(const Duration(minutes: 10))
        ..checkInLatitude = _siteLatitude
        ..checkInLongitude = _siteLongitude
        ..checkInAccuracyMeters = 8;
      final participation = await CampaignParticipation.db.updateRow(
        sessionBuilder.build(),
        joined,
      );
      return (running, participation);
    }

    Future<CompletionEvidence> complete(
      CampaignParticipation participation, {
      bool? manualSummary,
    }) async {
      await endpoints.fieldnote.getEvidenceUploadDescription(
        volunteer,
        participation.id!,
        'jpg',
      );
      final session = sessionBuilder.build();
      final pending = await CampaignParticipation.db.findById(
        session,
        participation.id!,
      );
      await session.storage.storeFile(
        storageId: 'private',
        path: pending!.evidenceUploadPath!,
        byteData: ByteData.sublistView(Uint8List.fromList([1, 2, 3, 4])),
      );
      return endpoints.fieldnote.completeParticipation(
        volunteer,
        participation.id!,
        'jpg',
        'Collected eight bags of litter along the bank.',
        'Collected eight bags of litter along the riverbank.',
        ['8 bags of litter collected'],
        _siteLatitude,
        _siteLongitude,
        8,
        false,
        false,
        DateTime.now().toUtc(),
        uploadPath: pending.evidenceUploadPath,
        manualSummary: manualSummary,
      );
    }

    group('Razorpay webhook', () {
      test(
        'rejects bad signatures and credits a captured payment once',
        () async {
          final campaign = await publish();
          final row = await sponsorshipRow(
            campaign.id!,
            status: 'created',
            amount: 5000,
            orderId: 'order_hook',
          );
          final body = _capturedEvent(
            orderId: 'order_hook',
            paymentId: 'pay_hook',
            amountPaise: 500000,
          );
          const service = RazorpayWebhookService();
          final session = sessionBuilder.build();

          final forged = await service.handle(
            session,
            rawBody: body,
            signature: 'a' * 64,
            eventIdHeader: 'evt_1',
            webhookSecret: _webhookSecret,
          );
          expect(forged.statusCode, 401);
          final unconfigured = await service.handle(
            session,
            rawBody: body,
            signature: _sign(body),
            eventIdHeader: 'evt_1',
            webhookSecret: null,
          );
          expect(unconfigured.statusCode, 503);
          expect(await PaymentWebhookEvent.db.count(session), 0);

          final accepted = await service.handle(
            session,
            rawBody: body,
            signature: _sign(body),
            eventIdHeader: 'evt_1',
            webhookSecret: _webhookSecret,
          );
          expect(accepted.statusCode, 200);
          expect(accepted.outcome, 'processed');
          final duplicate = await service.handle(
            session,
            rawBody: body,
            signature: _sign(body),
            eventIdHeader: 'evt_1',
            webhookSecret: _webhookSecret,
          );
          expect(duplicate.duplicate, isTrue);
          // A different delivery id for the same payment is still idempotent.
          await service.handle(
            session,
            rawBody: body,
            signature: _sign(body),
            eventIdHeader: 'evt_2',
            webhookSecret: _webhookSecret,
          );

          final credited = await Sponsorship.db.findById(session, row.id!);
          expect(credited!.paymentStatus, 'verified');
          expect(credited.providerPaymentId, 'pay_hook');
          final funded = await Campaign.db.findById(session, campaign.id!);
          expect(funded!.sponsoredAmount, 5000);
          expect(await PaymentWebhookEvent.db.count(session), 2);
        },
      );

      test('payment.failed marks only an unpaid attempt failed', () async {
        final campaign = await publish();
        final row = await sponsorshipRow(
          campaign.id!,
          status: 'created',
          amount: 1000,
          orderId: 'order_fail',
        );
        final body = _capturedEvent(
          orderId: 'order_fail',
          paymentId: 'pay_fail',
          amountPaise: 100000,
          event: 'payment.failed',
        );
        final result = await const RazorpayWebhookService().handle(
          sessionBuilder.build(),
          rawBody: body,
          signature: _sign(body),
          eventIdHeader: 'evt_fail',
          webhookSecret: _webhookSecret,
        );
        expect(result.outcome, 'processed');
        final failed = await Sponsorship.db.findById(
          sessionBuilder.build(),
          row.id!,
        );
        expect(failed!.paymentStatus, 'failed');
        expect(failed.failureReason, 'Card declined');
      });
    });

    group('reconciliation', () {
      test(
        'credits a stranded capture once and expires stale orders',
        () async {
          final campaign = await publish();
          final stranded = await sponsorshipRow(
            campaign.id!,
            status: 'created',
            amount: 2500,
            orderId: 'order_stranded',
            age: const Duration(minutes: 10),
          );
          final abandoned = await sponsorshipRow(
            campaign.id!,
            status: 'created',
            amount: 1000,
            orderId: 'order_abandoned',
            age: const Duration(minutes: 45),
          );
          gateway.orderPayments['order_stranded'] = [
            const RazorpayPaymentRecord(
              id: 'pay_stranded',
              orderId: 'order_stranded',
              status: 'captured',
              amountPaise: 250000,
            ),
          ];
          const service = PaymentReconciliationService();
          final session = sessionBuilder.build();
          final first = await service.reconcile(session);
          expect(first.credited, 1);
          expect(first.expired, 1);
          // A later sweep (after the poll interval) must not credit again.
          final second = await service.reconcile(
            session,
            now: DateTime.now().toUtc().add(const Duration(minutes: 20)),
          );
          expect(second.credited, 0);

          expect(
            (await Sponsorship.db.findById(
              session,
              stranded.id!,
            ))!.paymentStatus,
            'verified',
          );
          expect(
            (await Sponsorship.db.findById(
              session,
              abandoned.id!,
            ))!.paymentStatus,
            'expired',
          );
          expect(
            (await Campaign.db.findById(
              session,
              campaign.id!,
            ))!.sponsoredAmount,
            2500,
          );
        },
      );

      test('open orders reserve the remaining balance', () async {
        final campaign = await publish();
        final first = await endpoints.fieldnote.createRazorpayOrder(
          sponsor,
          campaign.id!,
          20000,
          null,
        );
        expect(first.amountPaise, 2000000);
        await expectLater(
          endpoints.fieldnote.createRazorpayOrder(
            sponsor,
            campaign.id!,
            20000,
            null,
          ),
          _throwsCode('amount_exceeds_campaign_balance'),
        );
        final second = await endpoints.fieldnote.createRazorpayOrder(
          sponsor,
          campaign.id!,
          10000,
          null,
        );
        expect(second.orderId, isNot(first.orderId));
      });
    });

    group('refunds', () {
      test(
        'cancellation queues a refund that the worker executes once',
        () async {
          final campaign = await publish();
          await update(campaign.id!, (c) => c.sponsoredAmount = 4000);
          final paid = await sponsorshipRow(
            campaign.id!,
            status: 'verified',
            amount: 4000,
            orderId: 'order_cancel',
            paymentId: 'pay_cancel',
          );
          final cancelled = await endpoints.fieldnote.cancelCampaign(
            sponsor,
            campaign.id!,
          );
          expect(cancelled.readinessState, 'cancelled');
          final refunds = await endpoints.fieldnote.listCampaignRefunds(
            sponsor,
            campaign.id!,
          );
          expect(refunds.single.status, RefundStatus.pending);
          expect(refunds.single.sponsorshipId, paid.id);

          final session = sessionBuilder.build();
          final run = await const RefundService().processDue(session);
          expect(run.processed, 1);
          await const RefundService().processDue(session);
          expect(gateway.createRefundCalls, 1);
          final processed = (await TestRefund.db.findById(
            session,
            refunds.single.id!,
          ))!;
          expect(processed.status, RefundStatus.processed);
          expect(processed.providerRefundId, 'rfnd_fake1');
          expect(processed.attempts, 1);
          expect(processed.testMode, isTrue);

          final history = await endpoints.fieldnote.listMyPaymentHistory(
            sponsor,
          );
          expect(history.single.refund?.status, RefundStatus.processed);
        },
      );

      test('failed refunds back off and retry without duplicating', () async {
        final campaign = await publish();
        await sponsorshipRow(
          campaign.id!,
          status: 'verified',
          amount: 1500,
          orderId: 'order_retry',
          paymentId: 'pay_retry',
        );
        await endpoints.fieldnote.cancelCampaign(sponsor, campaign.id!);
        final session = sessionBuilder.build();
        gateway.failRefunds = true;
        await const RefundService().processDue(session);
        final failed = (await TestRefund.db.find(session)).single;
        expect(failed.status, RefundStatus.failed);
        // Raw provider text stays in the server log, never in the row.
        expect(failed.lastError, isNot(contains('Gateway down')));
        expect(failed.lastError, contains('HTTP 502'));
        expect(failed.nextAttemptAt, isNotNull);
        // Not due yet.
        await const RefundService().processDue(session);
        expect(gateway.createRefundCalls, 1);
        gateway.failRefunds = false;
        await const RefundService().processDue(
          session,
          now: DateTime.now().toUtc().add(const Duration(hours: 1)),
        );
        final done = (await TestRefund.db.findById(session, failed.id!))!;
        expect(done.status, RefundStatus.processed);
        expect(done.attempts, 2);
      });

      test('an expiring campaign refunds its sponsors (P0-4)', () async {
        final campaign = await publish(minimum: 1);
        await volunteerProfile(volunteer);
        final joined = await endpoints.fieldnote.joinCampaign(
          volunteer,
          campaign.id!,
        );
        await update(campaign.id!, (c) {
          c.sponsoredAmount = 2000;
          c.startsAt = DateTime.now().toUtc().subtract(
            const Duration(minutes: 5),
          );
        });
        await sponsorshipRow(
          campaign.id!,
          status: 'verified',
          amount: 2000,
          orderId: 'order_expiry',
          paymentId: 'pay_expiry',
        );
        final session = sessionBuilder.build();
        await const CampaignLifecycleService().refreshDueCampaigns(session);
        final expired = (await Campaign.db.findById(session, campaign.id!))!;
        expect(expired.readinessState, 'expired');
        final refund = (await TestRefund.db.find(session)).single;
        expect(refund.reason, RefundReason.campaignExpired);
        expect(refund.amount, 2000);
        expect(
          (await CampaignParticipation.db.findById(
            session,
            joined.id!,
          ))!.status,
          ParticipationStatus.cancelled,
        );
      });

      test(
        'a payment that cannot be credited is refunded automatically',
        () async {
          final campaign = await publish();
          await update(campaign.id!, (c) => c.readinessState = 'cancelled');
          final row = await sponsorshipRow(
            campaign.id!,
            status: 'created',
            amount: 1000,
            orderId: 'order_late',
          );
          final session = sessionBuilder.build();
          final result = await const PaymentCreditService().credit(
            session,
            sponsorshipId: row.id!,
            campaignId: campaign.id!,
            sponsorAuthUserId: row.sponsorAuthUserId,
            orderId: 'order_late',
            paymentId: 'pay_late',
          );
          expect(result.uncredited, isTrue);
          final refund = (await TestRefund.db.find(session)).single;
          expect(refund.reason, RefundReason.uncredited);
          expect(refund.sponsorshipId, row.id);
        },
      );
    });

    group('lifecycle', () {
      test('the sweep completes ended campaigns and resolves places', () async {
        final campaign = await publish();
        await volunteerProfile(volunteer);
        await volunteerProfile(secondVolunteer);
        final absent = await endpoints.fieldnote.joinCampaign(
          volunteer,
          campaign.id!,
        );
        final unfinished = await endpoints.fieldnote.joinCampaign(
          secondVolunteer,
          campaign.id!,
        );
        final session = sessionBuilder.build();
        unfinished
          ..status = ParticipationStatus.checkedIn
          ..checkedInAt = DateTime.now().toUtc().subtract(
            const Duration(hours: 5),
          );
        await CampaignParticipation.db.updateRow(session, unfinished);
        final now = DateTime.now().toUtc();
        await update(campaign.id!, (c) {
          c.readinessState = 'confirmed';
          c.startsAt = now.subtract(const Duration(hours: 6));
          c.endsAt = now.subtract(const Duration(hours: 3));
        });
        await expectLater(
          endpoints.fieldnote.simulateCampaignTestPayout(
            sponsor,
            campaign.id!,
          ),
          _throwsCode('campaign_not_completed'),
        );

        final completed = await const CampaignLifecycleService()
            .completeEndedCampaigns(session);
        expect(completed.map((c) => c.id), [campaign.id]);
        final stored = (await Campaign.db.findById(session, campaign.id!))!;
        expect(stored.status, CampaignStatus.completed);
        expect(stored.completedAt, isNotNull);
        expect(
          (await CampaignParticipation.db.findById(
            session,
            absent.id!,
          ))!.status,
          ParticipationStatus.noShow,
        );
        expect(
          (await CampaignParticipation.db.findById(
            session,
            unfinished.id!,
          ))!.status,
          ParticipationStatus.incomplete,
        );
        // Running again is a no-op.
        expect(
          await const CampaignLifecycleService().completeEndedCampaigns(
            session,
          ),
          isEmpty,
        );
        expect(
          await endpoints.fieldnote.simulateCampaignTestPayout(
            sponsor,
            campaign.id!,
          ),
          isEmpty,
        );
      });

      test('cancel, revise and postpone are blocked once started', () async {
        final campaign = await publish();
        final started = DateTime.now().toUtc().subtract(
          const Duration(minutes: 1),
        );
        await update(campaign.id!, (c) => c.startsAt = started);
        await expectLater(
          endpoints.fieldnote.cancelCampaign(sponsor, campaign.id!),
          _throwsCode('campaign_started'),
        );
        await expectLater(
          endpoints.fieldnote.reviseCampaignScope(
            sponsor,
            campaign.id!,
            1000,
            1,
            'Plant only the first row of trees with the smaller team.',
          ),
          _throwsCode('campaign_started'),
        );
        await expectLater(
          endpoints.fieldnote.postponeCampaign(
            sponsor,
            campaign.id!,
            DateTime.now().toUtc().add(const Duration(days: 3)),
          ),
          _throwsCode('campaign_started'),
        );
        await update(campaign.id!, (c) => c.readinessState = 'expired');
        await expectLater(
          endpoints.fieldnote.postponeCampaign(
            sponsor,
            campaign.id!,
            DateTime.now().toUtc().add(const Duration(days: 3)),
          ),
          _throwsCode('campaign_unavailable'),
        );
      });

      test('cancel is blocked once a payout exists', () async {
        final campaign = await publish();
        final paid = await sponsorshipRow(
          campaign.id!,
          status: 'verified',
          amount: 1000,
          orderId: 'order_payout',
          paymentId: 'pay_payout',
        );
        await TestPayout.db.insertRow(
          sessionBuilder.build(),
          TestPayout(
            campaignId: campaign.id!,
            sponsorshipId: paid.id!,
            creatorAuthUserId: UuidValue.withValidation(_sponsorId),
            amount: 1000,
            sourcePaymentId: 'pay_payout',
          ),
        );
        await expectLater(
          endpoints.fieldnote.cancelCampaign(sponsor, campaign.id!),
          _throwsCode('payouts_exist'),
        );
      });

      test('cancellation releases joined volunteers', () async {
        final campaign = await publish();
        await volunteerProfile(volunteer);
        final joined = await endpoints.fieldnote.joinCampaign(
          volunteer,
          campaign.id!,
        );
        await endpoints.fieldnote.cancelCampaign(sponsor, campaign.id!);
        final after = await CampaignParticipation.db.findById(
          sessionBuilder.build(),
          joined.id!,
        );
        expect(after!.status, ParticipationStatus.cancelled);
      });
    });

    group('volunteer places', () {
      test(
        'leaving frees the seat; leaving after check-in is refused',
        () async {
          final campaign = await publish(capacity: 1);
          await volunteerProfile(volunteer);
          await volunteerProfile(secondVolunteer);
          final first = await endpoints.fieldnote.joinCampaign(
            volunteer,
            campaign.id!,
          );
          await expectLater(
            endpoints.fieldnote.joinCampaign(secondVolunteer, campaign.id!),
            _throwsCode('campaign_full'),
          );
          final left = await endpoints.fieldnote.leaveCampaign(
            volunteer,
            first.id!,
          );
          expect(left.status, ParticipationStatus.left);
          expect(left.leftAt, isNotNull);
          final second = await endpoints.fieldnote.joinCampaign(
            secondVolunteer,
            campaign.id!,
          );
          await expectLater(
            endpoints.fieldnote.joinCampaign(volunteer, campaign.id!),
            _throwsCode('campaign_full'),
          );
          await expectLater(
            endpoints.fieldnote.leaveCampaign(volunteer, second.id!),
            _throwsCode('participation_not_found'),
          );
          second.status = ParticipationStatus.checkedIn;
          await CampaignParticipation.db.updateRow(
            sessionBuilder.build(),
            second,
          );
          await expectLater(
            endpoints.fieldnote.leaveCampaign(secondVolunteer, second.id!),
            _throwsCode('leave_unavailable'),
          );
        },
      );
    });

    group('completion', () {
      test(
        'uploads require check-in and closed campaigns reject evidence',
        () async {
          final campaign = await publish();
          await volunteerProfile(volunteer);
          final joined = await endpoints.fieldnote.joinCampaign(
            volunteer,
            campaign.id!,
          );
          await expectLater(
            endpoints.fieldnote.getEvidenceUploadDescription(
              volunteer,
              joined.id!,
              'jpg',
            ),
            _throwsCode('check_in_required'),
          );
        },
      );

      test('evidence is rejected after cancellation or the deadline', () async {
        final (campaign, participation) = await checkedIn();
        final description = await endpoints.fieldnote
            .getEvidenceUploadDescription(volunteer, participation.id!, 'jpg');
        expect(description, isNotEmpty);
        final first = (await CampaignParticipation.db.findById(
          sessionBuilder.build(),
          participation.id!,
        ))!.evidenceUploadPath;
        await endpoints.fieldnote.getEvidenceUploadDescription(
          volunteer,
          participation.id!,
          'jpg',
        );
        final second = (await CampaignParticipation.db.findById(
          sessionBuilder.build(),
          participation.id!,
        ))!.evidenceUploadPath;
        expect(second, isNot(first));
        expect(
          second,
          startsWith(
            'campaigns/${campaign.id}/participations/${participation.id}/',
          ),
        );

        final now = DateTime.now().toUtc();
        await update(campaign.id!, (c) {
          c.endsAt = now.subtract(
            CampaignLifecycleService.completionGrace +
                const Duration(minutes: 1),
          );
          c.startsAt = now.subtract(const Duration(hours: 5));
        });
        await expectLater(complete(participation), throwsA(anything));
        await expectLater(
          endpoints.fieldnote.completeParticipation(
            volunteer,
            participation.id!,
            'jpg',
            'Collected litter.',
            'Collected eight bags of litter.',
            const [],
            _siteLatitude,
            _siteLongitude,
            8,
            false,
            false,
            DateTime.now().toUtc(),
          ),
          _throwsCode('completion_window_closed'),
        );
        await update(campaign.id!, (c) {
          c.endsAt = now.add(const Duration(hours: 1));
          c.readinessState = 'cancelled';
        });
        await expectLater(
          endpoints.fieldnote.completeParticipation(
            volunteer,
            participation.id!,
            'jpg',
            'Collected litter.',
            'Collected eight bags of litter.',
            const [],
            _siteLatitude,
            _siteLongitude,
            8,
            false,
            false,
            DateTime.now().toUtc(),
          ),
          _throwsCode('campaign_closed'),
        );
      });

      test('a volunteer-written summary completes without AI', () async {
        final (_, participation) = await checkedIn();
        final evidence = await complete(participation, manualSummary: true);
        expect(evidence.aiGenerated, isFalse);
        expect(evidence.reviewState, ReviewState.awaitingReview);
        expect(evidence.photographPath, contains('/evidence-'));
        final repeated = await endpoints.fieldnote.completeParticipation(
          volunteer,
          participation.id!,
          'jpg',
          'Collected eight bags of litter along the bank.',
          'Collected eight bags of litter along the riverbank.',
          const [],
          _siteLatitude,
          _siteLongitude,
          8,
          false,
          false,
          DateTime.now().toUtc(),
          manualSummary: true,
        );
        expect(repeated.id, evidence.id);
        await expectLater(
          endpoints.fieldnote.getEvidenceUploadDescription(
            volunteer,
            participation.id!,
            'jpg',
          ),
          _throwsCode('check_in_required'),
        );
        final history = await endpoints.fieldnote.listMyParticipationHistory(
          volunteer,
        );
        expect(history.single.evidence?.id, evidence.id);
        expect(
          history.single.participation.status,
          ParticipationStatus.completed,
        );

        if (!await endpoints.fieldnote.isAiAvailable(volunteer)) {
          final proposal = await endpoints.fieldnote.analyzeCompletion(
            volunteer,
            participation.id!,
            'Collected eight bags of litter. Sorted the recyclables.',
            null,
            null,
          );
          expect(
            proposal.rationale,
            startsWith(StructuredSummaryService.manualRationale),
          );
          expect(proposal.structuredResults, hasLength(2));
        }
      });
    });

    group('evidence review', () {
      test(
        'only the creator reviews, and rejected work is not impact',
        () async {
          final (campaign, participation) = await checkedIn();
          final evidence = await complete(participation, manualSummary: true);
          await sponsorProfile(funder, 'Other Sponsor');
          await expectLater(
            endpoints.fieldnote.reviewEvidence(
              funder,
              evidence.id!,
              true,
              null,
            ),
            _throwsCode('forbidden'),
          );
          await expectLater(
            endpoints.fieldnote.reviewEvidence(
              volunteer,
              evidence.id!,
              true,
              null,
            ),
            _throwsCode('forbidden'),
          );
          await expectLater(
            endpoints.fieldnote.reviewEvidence(
              sponsor,
              evidence.id!,
              false,
              '',
            ),
            _throwsCode('review_note_required'),
          );
          expect(
            (await endpoints.fieldnote.getImpact(
              sponsor,
              campaign.id!,
            )).evidenceCount,
            1,
          );
          final rejected = await endpoints.fieldnote.reviewEvidence(
            sponsor,
            evidence.id!,
            false,
            'The photograph shows a different site.',
          );
          expect(rejected.reviewState, ReviewState.rejected);
          expect(rejected.reviewedAt, isNotNull);
          final impact = await endpoints.fieldnote.getImpact(
            sponsor,
            campaign.id!,
          );
          expect(impact.evidenceCount, 0);
          expect(impact.completedVolunteers, 0);
          final audit = await endpoints.fieldnote.getTrustCenter(sponsor);
          expect(
            audit.recentEvents.map((e) => e.event),
            contains('evidenceReviewed'),
          );
        },
      );
    });

    group('sponsor views', () {
      test('created and funded campaigns stay listed after start', () async {
        final campaign = await publish();
        await sponsorProfile(funder, 'Funding Sponsor');
        await sponsorshipRow(
          campaign.id!,
          status: 'verified',
          amount: 1000,
          orderId: 'order_funder',
          paymentId: 'pay_funder',
          sponsorId: _funderId,
        );
        await update(
          campaign.id!,
          (c) => c.startsAt = DateTime.now().toUtc().subtract(
            const Duration(hours: 1),
          ),
        );
        expect(
          (await endpoints.fieldnote.listMyCampaigns(sponsor)).map((c) => c.id),
          contains(campaign.id),
        );
        expect(
          (await endpoints.fieldnote.listMyCampaigns(funder)).map((c) => c.id),
          contains(campaign.id),
        );
        expect(
          await endpoints.fieldnote.listMyCampaigns(sponsor, offset: 1),
          isEmpty,
        );
        expect(
          (await endpoints.fieldnote.listCampaigns(sponsor)).map((c) => c.id),
          isNot(contains(campaign.id)),
        );
        await expectLater(
          endpoints.fieldnote.listCampaignRefunds(funder, campaign.id!),
          _throwsCode('creator_required'),
        );
      });

      test('campaign plans are validated on the server', () async {
        await sponsorProfile(sponsor, 'Asha Sponsor');
        Future<Campaign> create(CampaignProposal proposal) =>
            endpoints.fieldnote.createCampaignFromProposal(
              sponsor,
              proposal,
              _siteLatitude,
              _siteLongitude,
              null,
              null,
            );
        await expectLater(
          create(_proposal().copyWith(fundingGoal: 50)),
          _throwsCode('invalid_funding_goal'),
        );
        // NaN cannot cross the JSON protocol, so check the validator itself.
        expect(
          () => CampaignValidation.fundingGoal(double.nan),
          _throwsCode('invalid_funding_goal'),
        );
        await expectLater(
          create(_proposal().copyWith(fundingGoal: 2000000)),
          _throwsCode('invalid_funding_goal'),
        );
        await expectLater(
          create(_proposal().copyWith(durationMinutes: 5)),
          _throwsCode('invalid_duration'),
        );
        await expectLater(
          create(_proposal().copyWith(volunteerCapacity: 501)),
          _throwsCode('invalid_capacity'),
        );
        await expectLater(
          create(_proposal().copyWith(title: 'x')),
          _throwsCode('invalid_campaign_plan'),
        );
      });
    });
  });
}
