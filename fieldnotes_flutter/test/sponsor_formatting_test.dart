import 'package:fieldnotes_client/fieldnotes_client.dart';
import 'package:fieldnotes_flutter/ui/features/sponsor/payment_history_view.dart';
import 'package:fieldnotes_flutter/ui/features/sponsor/sponsor_checkout.dart';
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

  group('parseRupeesToPaise', () {
    test('accepts grouping commas, spaces and symbols as exact paise', () {
      expect(parseRupeesToPaise('25,000'), 2500000);
      expect(parseRupeesToPaise('10,00,000'), 100000000);
      expect(parseRupeesToPaise(' 25 000 '), 2500000);
      expect(parseRupeesToPaise('₹1,250.50'), 125050);
      expect(parseRupeesToPaise('₹1,250.5'), 125050);
      expect(parseRupeesToPaise('Rs. 500'), 50000);
      expect(parseRupeesToPaise('INR 0.07'), 7);
      // No floating-point drift: 0.29 * 100 is 28.999… as a double.
      expect(parseRupeesToPaise('0.29'), 29);
      expect(parseRupeesToPaise('1234567.89'), 123456789);
    });

    test('rejects malformed amounts', () {
      expect(parseRupeesToPaise(''), isNull);
      expect(parseRupeesToPaise('-100'), isNull);
      expect(parseRupeesToPaise('12.345'), isNull);
      expect(parseRupeesToPaise('1e5'), isNull);
      expect(parseRupeesToPaise('abc'), isNull);
      expect(parseRupeesToPaise('1' * 20), isNull);
    });

    test('paiseInputText round-trips through the parser', () {
      for (final paise in [0, 7, 29, 125050, 2500000, 100000000]) {
        expect(parseRupeesToPaise(paiseInputText(paise)), paise);
      }
      expect(paiseInputText(2500000), '25000');
      expect(paiseInputText(125005), '1250.05');
    });
  });

  group('formatPaise', () {
    test('uses Indian grouping and drops zero paise', () {
      expect(formatPaise(123456700), '₹12,34,567');
      expect(formatPaise(125050), '₹1,250.50');
      expect(formatPaise(5), '₹0.05');
      expect(formatPaise(0), '₹0');
    });

    test('is locale-aware with Indian grouping in hi and ta', () {
      expect(moneyLocale('en'), 'en_IN');
      expect(moneyLocale('en-US'), 'en_IN');
      expect(moneyLocale('hi'), 'hi');
      expect(moneyLocale('ta-IN'), 'ta');
      expect(formatPaise(123456700, localeTag: 'hi'), '₹12,34,567');
      expect(formatPaise(123456700, localeTag: 'ta'), '₹12,34,567');
    });

    test('compact form for cards', () {
      expect(formatPaiseCompact(2500000), '₹25K');
      expect(formatPaiseCompact(250000000), '₹25L');
    });
  });

  group('campaign money', () {
    Campaign money({
      double goal = 0,
      double sponsored = 0,
      int goalPaise = 0,
      int sponsoredPaise = 0,
      int refundedPaise = 0,
    }) => Campaign(
      organizationId: 1,
      name: 'Tree planting',
      description: 'Plant trees with local volunteers.',
      locationName: 'Pollachi',
      startsAt: DateTime.utc(2026, 10, 4),
      status: CampaignStatus.active,
      createdBy: creator,
      fundingGoal: goal,
      sponsoredAmount: sponsored,
      fundingGoalPaise: goalPaise,
      sponsoredAmountPaise: sponsoredPaise,
      refundedAmountPaise: refundedPaise,
    );

    test('paise are the source of truth', () {
      final campaign = money(
        goal: 1, // stale double, must be ignored
        sponsored: 1,
        goalPaise: 2500000,
        sponsoredPaise: 1000050,
        refundedPaise: 50000,
      );
      expect(campaignGoalPaise(campaign), 2500000);
      expect(campaignSponsoredPaise(campaign), 1000050);
      expect(campaignRefundedPaise(campaign), 50000);
      expect(campaignRemainingPaise(campaign), 1499950);
      expect(campaignFundingProgress(campaign), closeTo(0.4, 0.001));
    });

    test('old rows fall back to the rupee doubles', () {
      final campaign = money(goal: 1500, sponsored: 500.5);
      expect(campaignGoalPaise(campaign), 150000);
      expect(campaignSponsoredPaise(campaign), 50050);
      expect(campaignRemainingPaise(campaign), 99950);
    });

    test('remaining is never negative', () {
      expect(
        campaignRemainingPaise(
          money(goalPaise: 10000, sponsoredPaise: 20000),
        ),
        0,
      );
    });

    test('checkout portions are whole paise and end at the balance', () {
      expect(
        sponsorshipPortionsPaise(99999, const [0.25, 0.5, 0.75, 1.0]),
        [25000, 50000, 74999, 99999],
      );
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

  test('validation messages use the server goal bounds', () {
    final errors = validateCampaignForm(
      title: 'Tree care',
      description: 'Water and mulch the young trees.',
      locationName: 'University gate',
      startsAt: DateTime.now().add(const Duration(days: 2)),
      duration: '180',
      capacity: '10',
      minimum: '5',
      funding: '99.99',
      checklist: const ['Water trees'],
      skills: const [],
      tags: const [],
      evidence: 'A photo of the finished work.',
    );
    expect(errors[CampaignField.funding], '₹100 to ₹10,00,000.');
  });

  test('sponsor error codes get specific messages', () {
    expect(
      sponsorErrorMessage(
        FieldnoteException(message: '', code: 'payouts_manual'),
      ),
      'Payouts are settled manually by FieldNote operations.',
    );
    expect(
      sponsorErrorMessage(
        FieldnoteException(message: 'x', code: 'duplicate_payment_request'),
      ),
      contains('Start a new checkout'),
    );
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
      amountPaise: 50000,
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
        amountPaise: 250000,
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
    expect(find.text('₹2,500'), findsOneWidget);
  });
}
