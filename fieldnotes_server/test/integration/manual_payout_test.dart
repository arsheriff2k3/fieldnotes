import 'dart:convert';

import 'package:fieldnotes_server/src/fieldnotes/services/account_deletion_service.dart';
import 'package:fieldnotes_server/src/fieldnotes/services/fieldnote_config.dart';
import 'package:fieldnotes_server/src/fieldnotes/services/razorpay_payment_service.dart';
import 'package:fieldnotes_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

const creatorId = '770e8400-e29b-41d4-a716-446655440000';
const operatorId = '770e8400-e29b-41d4-a716-446655440001';
const strangerId = '770e8400-e29b-41d4-a716-446655440002';
const requestId = '770e8400-e29b-41d4-a716-446655440010';
const retryId = '770e8400-e29b-41d4-a716-446655440011';

Matcher errorCode(String code) =>
    throwsA(isA<FieldnoteException>().having((e) => e.code, 'code', code));

void main() {
  withServerpod('Manual creator payouts', (sessionBuilder, endpoints) {
    TestSessionBuilder as(String id) => sessionBuilder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(id, {}),
    );
    final creator = as(creatorId);
    final operator = as(operatorId);
    final stranger = as(strangerId);
    late Session session;
    late Campaign campaign;

    setUp(() async {
      FieldnoteConfig.environmentOverride = {
        'FIELDNOTE_PAYOUT_OPERATOR_IDS': operatorId,
      };
      RazorpayRuntime.credentialsResolver = (_) =>
          const RazorpayCredentials(keyId: 'rzp_live_fake', keySecret: 'fake');
      session = sessionBuilder.build();
      for (final account in [creator, stranger]) {
        await endpoints.fieldnote.completeSponsorProfile(
          account,
          'Creator',
          'Individual',
          null,
          'Pune',
          null,
          ['environment'],
          contactPhone: '+919876543210',
        );
        await endpoints.fieldnote.acceptLegalConsent(account, true, true, true);
      }
      final organization = await Organization.db.insertRow(
        session,
        Organization(
          name: 'Manual payout tests',
          createdBy: UuidValue.fromString(creatorId),
        ),
      );
      campaign = await Campaign.db.insertRow(
        session,
        Campaign(
          organizationId: organization.id!,
          name: 'Completed cleanup',
          description: 'A completed test activity',
          locationName: 'Park',
          startsAt: DateTime.now().toUtc().subtract(const Duration(days: 1)),
          status: CampaignStatus.completed,
          createdBy: UuidValue.fromString(creatorId),
          fundingGoalPaise: 50000,
          sponsoredAmountPaise: 50000,
        ),
      );
    });
    tearDown(() {
      FieldnoteConfig.environmentOverride = null;
      RazorpayRuntime.reset();
    });

    Future<Sponsorship> payment({
      bool? testMode = false,
      String status = 'verified',
      int amount = 50000,
    }) => Sponsorship.db.insertRow(
      session,
      Sponsorship(
        campaignId: campaign.id!,
        sponsorAuthUserId: UuidValue.fromString(strangerId),
        amount: amount / 100,
        amountPaise: amount,
        paymentTestMode: testMode,
        paymentStatus: status,
        providerPaymentId: 'pay_${DateTime.now().microsecondsSinceEpoch}',
        verifiedAt: DateTime.now().toUtc(),
      ),
    );

    Future<ManualPayoutRequest> request([String id = requestId]) =>
        endpoints.fieldnote.requestManualPayout(creator, campaign.id!, id);

    Future<ManualPayoutRequest> approve(
      ManualPayoutRequest request, {
      int deduction = 0,
    }) => endpoints.fieldnote.reviewManualPayout(
      operator,
      request.id!,
      true,
      deduction,
      'settlement-record-1',
      'verified-payee-record-1',
      'Agreed provider fee. Settlement and payee verified.',
    );

    test(
      'full lifecycle reserves gross, pays net once and includes the bank reference',
      () async {
        await payment();
        final first = await request();
        expect((await request()).id, first.id);
        await expectLater(
          request(retryId),
          errorCode('payout_no_available_funds'),
        );
        var summary = await endpoints.fieldnote.getManualPayoutSummary(
          creator,
          campaign.id!,
        );
        expect(summary.availablePaise, 0);
        expect(summary.reservedPaise, 50000);
        final reviewed = await approve(first, deduction: 1050);
        expect(reviewed.amountPaise, 48950);
        expect(reviewed.status, 'processing');
        final paid = await endpoints.fieldnote.recordManualPayoutPaid(
          operator,
          first.id!,
          'utr-bank-123',
        );
        expect(paid.status, 'paid');
        expect(paid.bankTransferReference, 'UTR-BANK-123');
        expect(
          (await endpoints.fieldnote.recordManualPayoutPaid(
            operator,
            first.id!,
            'utr-bank-123',
          )).id,
          paid.id,
        );
        summary = await endpoints.fieldnote.getManualPayoutSummary(
          creator,
          campaign.id!,
        );
        expect(summary.reservedPaise, 0);
        expect(summary.paidPaise, 48950);
        expect(
          summary.availablePaise,
          0,
        ); // Deductions do not become withdrawable again.
        final export =
            jsonDecode(await endpoints.fieldnote.exportMyData(creator))
                as Map<String, dynamic>;
        expect(
          (export['manualPayoutRequests'] as List)
              .single['bankTransferReference'],
          'UTR-BANK-123',
        );
        expect(
          await AuditEvent.db.count(
            session,
            where: (t) => t.event.equals('manualPayout'),
          ),
          3,
        );
      },
    );

    test(
      'only the owner reads or requests; only allowlisted operations can review or pay',
      () async {
        await payment();
        await expectLater(
          endpoints.fieldnote.getManualPayoutSummary(stranger, campaign.id!),
          errorCode('creator_required'),
        );
        await expectLater(
          endpoints.fieldnote.requestManualPayout(
            stranger,
            campaign.id!,
            requestId,
          ),
          errorCode('creator_required'),
        );
        final first = await request();
        expect(await endpoints.fieldnote.isPayoutOperator(creator), false);
        expect(await endpoints.fieldnote.isPayoutOperator(operator), true);
        await expectLater(
          endpoints.fieldnote.listManualPayoutRequests(
            creator,
            limit: 50,
            offset: 0,
          ),
          errorCode('payout_operator_required'),
        );
        await expectLater(
          endpoints.fieldnote.reviewManualPayout(
            creator,
            first.id!,
            true,
            0,
            'settled',
            'payee',
            'verified',
          ),
          errorCode('payout_operator_required'),
        );
        await expectLater(
          endpoints.fieldnote.recordManualPayoutPaid(
            creator,
            first.id!,
            'UTR-1',
          ),
          errorCode('payout_operator_required'),
        );
        expect(
          (await endpoints.fieldnote.listManualPayoutRequests(
            operator,
            limit: 50,
            offset: 0,
          )).single.id,
          first.id,
        );
        await expectLater(
          endpoints.fieldnote.recordManualPayoutPaid(
            operator,
            first.id!,
            'UTR-1',
          ),
          errorCode('payout_invalid_state'),
        );
      },
    );

    test(
      'test, legacy, unverified, simulated and refunded sources never fund real withdrawals',
      () async {
        await payment(testMode: true);
        await payment(testMode: null);
        await payment(status: 'created');
        final refunded = await payment();
        await TestRefund.db.insertRow(
          session,
          TestRefund(
            campaignId: campaign.id!,
            sponsorshipId: refunded.id!,
            amount: 500,
            amountPaise: 50000,
            reason: 'refund',
            status: 'pending',
            testMode: false,
          ),
        );
        final simulated = await payment();
        await TestPayout.db.insertRow(
          session,
          TestPayout(
            campaignId: campaign.id!,
            sponsorshipId: simulated.id!,
            creatorAuthUserId: UuidValue.fromString(creatorId),
            amount: 500,
            amountPaise: 50000,
            sourcePaymentId: simulated.providerPaymentId!,
          ),
        );
        await expectLater(request(), errorCode('payout_no_available_funds'));
        await payment();
        RazorpayRuntime.credentialsResolver = (_) => const RazorpayCredentials(
          keyId: 'rzp_test_fake',
          keySecret: 'fake',
        );
        await expectLater(request(), errorCode('payout_live_mode_required'));
      },
    );

    test(
      'rejection releases reservations, but refund changes block approval',
      () async {
        final source = await payment();
        final first = await request();
        await endpoints.fieldnote.reviewManualPayout(
          operator,
          first.id!,
          false,
          0,
          '',
          '',
          'Payee verification was not completed.',
        );
        expect(
          (await endpoints.fieldnote.getManualPayoutSummary(
            creator,
            campaign.id!,
          )).availablePaise,
          50000,
        );
        final second = await request(retryId);
        await TestRefund.db.insertRow(
          session,
          TestRefund(
            campaignId: campaign.id!,
            sponsorshipId: source.id!,
            amount: 500,
            amountPaise: 50000,
            reason: 'refund',
            status: 'pending',
            testMode: false,
          ),
        );
        await expectLater(approve(second), errorCode('payout_funds_changed'));
      },
    );

    test(
      'invalid request IDs and an empty operator allowlist fail closed',
      () async {
        await payment();
        await expectLater(
          endpoints.fieldnote.requestManualPayout(
            creator,
            campaign.id!,
            'invalid',
          ),
          errorCode('invalid_request_id'),
        );
        FieldnoteConfig.environmentOverride = {};
        expect(await endpoints.fieldnote.isPayoutOperator(operator), false);
        await expectLater(
          endpoints.fieldnote.listManualPayoutRequests(
            operator,
            limit: 50,
            offset: 0,
          ),
          errorCode('payout_operator_required'),
        );
      },
    );

    test(
      'campaign completion and valid references and deductions are required',
      () async {
        await payment();
        campaign.status = CampaignStatus.active;
        await Campaign.db.updateRow(session, campaign);
        await expectLater(request(), errorCode('campaign_not_completed'));
        campaign.status = CampaignStatus.completed;
        await Campaign.db.updateRow(session, campaign);
        final first = await request();
        await expectLater(
          approve(first, deduction: 50000),
          errorCode('invalid_amount'),
        );
        await expectLater(
          endpoints.fieldnote.reviewManualPayout(
            operator,
            first.id!,
            true,
            0,
            '',
            'payee',
            'verified',
          ),
          errorCode('invalid_payout_reference'),
        );
        expect(
          (await const AccountDeletionService().blocker(
            session,
            UuidValue.fromString(creatorId),
          ))?.code,
          'deletion_blocked_payout_pending',
        );
      },
    );

    test(
      'a bank transfer reference cannot be reused for another request',
      () async {
        await payment();
        final first = await request();
        await approve(first);
        await endpoints.fieldnote.recordManualPayoutPaid(
          operator,
          first.id!,
          'UTR-UNIQUE',
        );
        await payment(amount: 10000);
        final second = await request(retryId);
        await approve(second);
        await expectLater(
          endpoints.fieldnote.recordManualPayoutPaid(
            operator,
            second.id!,
            'utr-unique',
          ),
          errorCode('payout_transfer_reference_used'),
        );
        expect(
          (await endpoints.fieldnote.getManualPayoutSummary(
            creator,
            campaign.id!,
          )).reservedPaise,
          10000,
        );
      },
    );
  });
}
