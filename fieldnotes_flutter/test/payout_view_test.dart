import 'package:fieldnotes_client/fieldnotes_client.dart';
import 'package:fieldnotes_flutter/data/repositories/fieldnote_repository.dart';
import 'package:fieldnotes_flutter/ui/core/fieldnote_theme.dart';
import 'package:fieldnotes_flutter/ui/features/shell/fieldnote_view_model.dart';
import 'package:fieldnotes_flutter/ui/features/sponsor/payout_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

final _campaign = Campaign(
  id: 3,
  organizationId: 1,
  name: 'Tree planting',
  description: 'Plant trees with local volunteers.',
  locationName: 'Pollachi',
  startsAt: DateTime.utc(2026, 9, 1),
  status: CampaignStatus.completed,
  createdBy: UuidValue.withValidation('550e8400-e29b-41d4-a716-446655440000'),
  fundingGoalPaise: 2500000,
  sponsoredAmountPaise: 2000000,
  refundedAmountPaise: 50000,
);

class _PayoutRepository extends FieldnoteRepository {
  _PayoutRepository({required this.simulationAvailable});

  final bool simulationAvailable;

  @override
  Future<List<TestPayout>> campaignTestPayouts(
    int campaignId, {
    int? limit,
    int? offset,
  }) async => const [];

  @override
  Future<List<TestRefund>> campaignRefunds(
    int campaignId, {
    int? limit,
    int? offset,
  }) async => const [];

  @override
  Future<List<Campaign>> myCampaigns({int? limit, int? offset}) async => [
    _campaign,
  ];

  @override
  Future<bool> isPayoutSimulationAvailable() async => simulationAvailable;

  @override
  Future<ManualPayoutSummary> manualPayoutSummary(int campaignId) async =>
      ManualPayoutSummary(
        campaignId: campaignId,
        liveMode: !simulationAvailable,
        completed: true,
        eligiblePaise: 0,
        availablePaise: 0,
        reservedPaise: 0,
        paidPaise: 0,
        requests: [],
      );
}

Future<FieldnoteViewModel> _pump(WidgetTester tester, bool available) async {
  final model = FieldnoteViewModel(
    _PayoutRepository(simulationAvailable: available),
  );
  await tester.pumpWidget(
    MaterialApp(
      theme: buildFieldnoteTheme(),
      home: CampaignPayoutView(campaign: _campaign, viewModel: model),
    ),
  );
  await tester.pumpAndSettle();
  return model;
}

void main() {
  testWidgets('live mode shows manual settlement and no simulate button', (
    tester,
  ) async {
    final model = await _pump(tester, false);
    expect(
      find.text('Payouts are settled manually by FieldNote operations.'),
      findsOneWidget,
    );
    expect(find.text('Simulate payout to creator'), findsNothing);
    expect(find.text('Razorpay Test Mode'), findsNothing);
    expect(find.text('₹20,000'), findsOneWidget);
    expect(find.text('₹500'), findsOneWidget, reason: 'refunded amount');
    model.dispose();
  });

  testWidgets('test mode offers the simulation', (tester) async {
    final model = await _pump(tester, true);
    expect(find.text('Simulate payout to creator'), findsOneWidget);
    expect(
      find.text('Payouts are settled manually by FieldNote operations.'),
      findsNothing,
    );
    model.dispose();
  });
}
