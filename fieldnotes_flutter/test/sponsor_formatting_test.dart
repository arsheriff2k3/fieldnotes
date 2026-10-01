import 'package:fieldnotes_client/fieldnotes_client.dart';
import 'package:fieldnotes_flutter/ui/features/sponsor/payment_history_view.dart';
import 'package:fieldnotes_flutter/ui/features/sponsor/sponsor_formatting.dart';
import 'package:fieldnotes_flutter/ui/core/fieldnote_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final creator = UuidValue.withValidation(
    '550e8400-e29b-41d4-a716-446655440000',
  );
  Campaign campaign({
    CampaignStatus status = CampaignStatus.active,
    String readiness = 'open',
    DateTime? startsAt,
  }) => Campaign(
    organizationId: 1,
    name: 'Tree planting',
    description: 'Plant trees with local volunteers.',
    locationName: 'Pollachi',
    startsAt: startsAt ?? DateTime.now().toUtc().add(const Duration(days: 3)),
    status: status,
    createdBy: creator,
    readinessState: readiness,
  );

  group('parseRupees', () {
    test('accepts grouping commas, spaces and symbols', () {
      expect(parseRupees('25,000'), 25000);
      expect(parseRupees('10,00,000'), 1000000);
      expect(parseRupees(' 25 000 '), 25000);
      expect(parseRupees('₹1,250.50'), 1250.5);
      expect(parseRupees('Rs. 500'), 500);
    });

    test('rejects malformed amounts', () {
      expect(parseRupees(''), isNull);
      expect(parseRupees('-100'), isNull);
      expect(parseRupees('12.345'), isNull);
      expect(parseRupees('1e5'), isNull);
      expect(parseRupees('abc'), isNull);
    });
  });

  test('parseWholeNumber accepts grouping and rejects decimals', () {
    expect(parseWholeNumber('1,440'), 1440);
    expect(parseWholeNumber('12.5'), isNull);
    expect(parseWholeNumber(''), isNull);
  });

  group('validateCampaignForm', () {
    Map<String, String> validate({
      String funding = '25,000',
      String duration = '180',
      String capacity = '10',
      String minimum = '5',
      DateTime? startsAt,
    }) => validateCampaignForm(
      title: 'Tree care',
      description: 'Water and mulch the young trees.',
      locationName: 'University gate',
      startsAt: startsAt ?? DateTime.now().add(const Duration(days: 2)),
      duration: duration,
      capacity: capacity,
      minimum: minimum,
      funding: funding,
      checklist: const ['Water trees'],
      skills: const [],
      tags: const [],
      evidence: 'A photo of the finished work.',
    );

    test('accepts a valid form with a comma amount', () {
      expect(validate(), isEmpty);
    });

    test('matches the server bounds', () {
      expect(validate(funding: '10,00,001'), contains(CampaignField.funding));
      expect(validate(funding: '99'), contains(CampaignField.funding));
      expect(validate(duration: '14'), contains(CampaignField.duration));
      expect(validate(duration: '1441'), contains(CampaignField.duration));
      expect(validate(capacity: '501'), contains(CampaignField.capacity));
      expect(
        validate(capacity: '4', minimum: '5'),
        contains(CampaignField.minimum),
      );
      expect(
        validate(startsAt: DateTime.now().subtract(const Duration(hours: 1))),
        contains(CampaignField.startsAt),
      );
    });
  });

  test('validateScopeRevision rejects out-of-range input', () {
    expect(
      validateScopeRevision(
        goal: '25,000',
        minimum: '3',
        description: 'Water and mulch every young tree on campus.',
        volunteerCapacity: 10,
      ),
      isNull,
    );
    expect(
      validateScopeRevision(
        goal: '20,00,000',
        minimum: '3',
        description: 'Water and mulch every young tree on campus.',
        volunteerCapacity: 10,
      ),
      isNotNull,
    );
    expect(
      validateScopeRevision(
        goal: '25000',
        minimum: '11',
        description: 'Water and mulch every young tree on campus.',
        volunteerCapacity: 10,
      ),
      isNotNull,
    );
  });

  group('campaignPhase', () {
    test('maps closed and lifecycle states', () {
      expect(
        campaignPhase(campaign(status: CampaignStatus.completed)),
        CampaignPhase.completed,
      );
      expect(
        campaignPhase(campaign(readiness: 'cancelled')),
        CampaignPhase.cancelled,
      );
      expect(
        campaignPhase(campaign(readiness: 'expired')),
        CampaignPhase.expired,
      );
      expect(
        campaignPhase(
          campaign(
            readiness: 'confirmed',
            startsAt: DateTime.now().toUtc().subtract(const Duration(hours: 1)),
          ),
        ),
        CampaignPhase.inProgress,
      );
      expect(
        campaignPhase(campaign(readiness: 'bothShort')),
        CampaignPhase.needsDecision,
      );
      expect(campaignPhase(campaign()), CampaignPhase.planning);
    });

    test('labels never show cancelled or expired as planning', () {
      expect(
        campaignPhaseStyle(
          campaignPhase(campaign(readiness: 'cancelled')),
        ).label,
        'Cancelled',
      );
      expect(
        campaignPhaseStyle(campaignPhase(campaign(readiness: 'expired'))).label,
        'Expired',
      );
    });

    test('editing is locked after the start', () {
      expect(campaignIsEditable(campaign()), isTrue);
      expect(
        campaignIsEditable(
          campaign(
            startsAt: DateTime.now().toUtc().subtract(const Duration(hours: 1)),
          ),
        ),
        isFalse,
      );
      expect(campaignIsEditable(campaign(readiness: 'cancelled')), isFalse);
    });
  });

  test('payment status labels', () {
    expect(paymentStatusStyle('verified').label, 'Verified');
    expect(paymentStatusStyle('verified_uncredited').label, 'Refund queued');
    expect(paymentStatusStyle('failed').label, 'Failed');
    expect(paymentStatusStyle('verification_failed').label, 'Failed');
    expect(paymentStatusStyle('created').label, 'Pending');
    final refund = TestRefund(
      campaignId: 1,
      sponsorshipId: 2,
      amount: 500,
      status: 'processed',
    );
    expect(paymentStatusStyle('verified', refund: refund).label, 'Refunded');
    expect(refundStatusStyle('failed').label, 'Refund failed');
  });

  testWidgets('payment history tile shows the refund state', (tester) async {
    final entry = SponsorshipHistoryEntry(
      sponsorship: Sponsorship(
        campaignId: 1,
        sponsorAuthUserId: creator,
        amount: 2500,
        paymentStatus: 'verified_uncredited',
      ),
      campaignName: 'Tree planting',
      campaignStatus: CampaignStatus.active,
      campaignReadinessState: 'open',
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: buildFieldnoteTheme(),
        home: Scaffold(body: PaymentHistoryTile(entry: entry)),
      ),
    );
    expect(find.text('Refund queued'), findsOneWidget);
    expect(find.text('Tree planting'), findsOneWidget);
  });
}
