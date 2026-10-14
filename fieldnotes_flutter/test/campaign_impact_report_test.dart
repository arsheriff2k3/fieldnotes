import 'dart:convert';

import 'package:fieldnotes_client/fieldnotes_client.dart';
import 'package:fieldnotes_flutter/data/models/campaign_impact_report.dart';
import 'package:fieldnotes_flutter/data/repositories/fieldnote_repository.dart';
import 'package:fieldnotes_flutter/ui/features/sponsor/campaign_impact_report.dart';
import 'package:fieldnotes_flutter/ui/features/sponsor/campaign_impact_report_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

final campaign = Campaign(
  id: 8,
  organizationId: 1,
  name: 'Park cleanup',
  description: 'Clean the park',
  locationName: 'Pune park',
  startsAt: DateTime.utc(2026, 10, 14),
  status: CampaignStatus.completed,
  createdBy: UuidValue.withValidation('550e8400-e29b-41d4-a716-446655440000'),
);

ImpactSummary reportFixture({int approved = 4}) => ImpactSummary(
  campaignId: 8,
  sponsorshipTotal: 0,
  fundingGoal: 0,
  sponsorshipTotalPaise: 123456,
  fundingGoalPaise: 200000,
  refundedPaise: 1000,
  joinedVolunteers: 8,
  completedVolunteers: 7,
  evidenceCount: 7,
  summary:
      'Includes Razorpay Test Mode payments: those payments move no real money.',
  recentEvidence: List.generate(
    8,
    (i) => CompletionEvidence(
      id: i + 1,
      participationId: i + 1,
      photographPath: 'private-$i.jpg',
      originalNote: 'Sensitive original note',
      confirmedSummary: 'Contribution $i',
      structuredResults: 'Do not infer quantities',
      latitude: 18.523456,
      longitude: 73.851234,
      locationAccuracyMeters: 5,
      submittedAt: DateTime.utc(2026, 10, 14),
      reviewedAt: DateTime.utc(2026, 10, 15),
      reviewState: i < approved
          ? ReviewState.approved
          : i == 6
          ? ReviewState.changesRequested
          : i == 7
          ? ReviewState.rejected
          : ReviewState.awaitingReview,
      locationIsDemo: i == 0,
    ),
  ),
);

class ReportRepository extends FieldnoteRepository {
  bool fail = false;
  bool laterPage = false;
  int calls = 0;
  final offsets = <int>[];
  @override
  Future<ImpactSummary> impact(int campaignId) async {
    calls++;
    if (fail) throw StateError('offline');
    return impactData;
  }

  ImpactSummary impactData = reportFixture();
  @override
  Future<List<Campaign>> myCampaigns({int? limit, int? offset}) async {
    offsets.add(offset ?? 0);
    if (laterPage && offset == 0) {
      return List.generate(100, (i) => campaign.copyWith(id: 100 + i));
    }
    return [campaign];
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('finds older campaigns beyond the first metadata page', () async {
    final repository = ReportRepository()..laterPage = true;
    final report = await repository.campaignImpactReport(8);
    expect(report.campaignId, 8);
    expect(repository.offsets, [0, 100]);
  });

  test('failed authorization does not load campaign metadata', () async {
    final repository = ReportRepository()..fail = true;
    await expectLater(repository.campaignImpactReport(8), throwsStateError);
    expect(repository.offsets, isEmpty);
  });

  test(
    'report separates every review state and exports only approved summaries',
    () async {
      final report = await ReportRepository().campaignImpactReport(8);
      expect(report.submittedCount, 8);
      expect(report.approvedCount, 4);
      expect(report.pendingCount, 2);
      expect(report.changesRequestedCount, 1);
      expect(report.rejectedCount, 1);
      expect(report.demoEvidenceCount, 1);
      expect(report.contributions, hasLength(4));
      expect(
        report.contributions.map((e) => e.summary),
        isNot(contains('Contribution 7')),
      );
      expect(report.netFundingPaise, 123456);
      expect(report.refundedPaise, 1000);
      expect(report.contributions.first.isDemo, isTrue);
      expect(reportMoney(9007199254740993), 'INR 90071992547409.93');
      expect(reportMoney(-101), '-INR 1.01');
    },
  );

  test('PDF supports a multipage campaign report', () async {
    final data = reportFixture();
    data.recentEvidence = List.generate(
      100,
      (i) => data.recentEvidence.first.copyWith(
        id: i + 1,
        confirmedSummary: 'Contribution $i: collected and sorted waste. ' * 12,
      ),
    );
    final report = CampaignImpactReport(
      campaign: campaign,
      impact: data,
      retrievedAt: DateTime.utc(2026, 10, 15),
    );
    final bytes = await buildCampaignImpactPdf(report);
    expect(ascii.decode(bytes.take(4).toList()), '%PDF');
    expect(
      RegExp(r'/Type\s*/Page\b').allMatches(latin1.decode(bytes)).length,
      greaterThan(1),
    );
  });

  testWidgets(
    'narrow screen shows report and clears stale export after failed refresh',
    (tester) async {
      tester.view.physicalSize = const Size(320, 740);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repository = ReportRepository();
      await tester.pumpWidget(
        MaterialApp(
          home: CampaignImpactReportView(campaignId: 8, repository: repository),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Park cleanup'), findsOneWidget);
      expect(find.text('8'), findsNWidgets(2));
      expect(tester.takeException(), isNull);
      repository.fail = true;
      await tester.tap(find.byTooltip('Refresh report'));
      await tester.pumpAndSettle();
      expect(find.text('Retry'), findsOneWidget);
      expect(find.text('Save or share PDF'), findsNothing);
      repository.fail = false;
      repository.impactData = reportFixture(approved: 5);
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(find.text('5'), findsOneWidget);
      expect(repository.calls, 3);
      expect(tester.takeException(), isNull);
    },
  );
}
