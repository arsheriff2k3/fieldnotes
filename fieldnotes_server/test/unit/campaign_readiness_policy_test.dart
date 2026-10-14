import 'package:fieldnotes_server/src/fieldnotes/services/campaign_readiness_policy.dart';
import 'package:test/test.dart';

void main() {
  const policy = CampaignReadinessPolicy();

  test('classifies all four cutoff outcomes', () {
    String result(int fundedRupees, int joined) => policy.evaluate(
      fundingGoalPaise: 150000,
      sponsoredPaise: fundedRupees * 100,
      minimumVolunteers: 4,
      joinedVolunteers: joined,
    );
    expect(result(1500, 4), 'confirmed');
    expect(result(1000, 4), 'fundingShort');
    expect(result(1500, 2), 'volunteersShort');
    expect(result(1000, 2), 'bothShort');
  });
}
