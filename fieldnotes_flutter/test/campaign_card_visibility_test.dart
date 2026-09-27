import 'package:fieldnotes_client/fieldnotes_client.dart';
import 'package:fieldnotes_flutter/ui/core/fieldnote_theme.dart';
import 'package:fieldnotes_flutter/ui/features/sponsor/sponsor_views.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final campaign = Campaign(
    organizationId: 1,
    name: 'Tree planting',
    description: 'Plant trees with local volunteers.',
    locationName: 'Pollachi',
    startsAt: DateTime.utc(2026, 10, 4),
    status: CampaignStatus.active,
    createdBy: UuidValue.withValidation(
      '550e8400-e29b-41d4-a716-446655440000',
    ),
    fundingGoal: 1500,
    sponsoredAmount: 500,
  );

  testWidgets('volunteer card omits sponsorship progress', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildFieldnoteTheme(),
        home: Scaffold(
          body: CampaignCard(
            campaign: campaign,
            showFunding: false,
            actionLabel: 'Join campaign',
            onAction: () {},
          ),
        ),
      ),
    );
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(find.textContaining('₹'), findsNothing);
  });

  testWidgets('sponsor card retains sponsorship progress', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildFieldnoteTheme(),
        home: Scaffold(
          body: CampaignCard(
            campaign: campaign,
            showFunding: true,
            actionLabel: 'Sponsor campaign',
            onAction: () {},
          ),
        ),
      ),
    );
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(find.textContaining('₹'), findsOneWidget);
  });
}
