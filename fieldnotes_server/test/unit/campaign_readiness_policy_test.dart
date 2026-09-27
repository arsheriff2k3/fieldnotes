import 'package:fieldnotes_server/src/fieldnotes/services/campaign_readiness_policy.dart';
import 'package:test/test.dart';

void main() {
  const policy = CampaignReadinessPolicy();

  test('classifies all four cutoff outcomes', () {
    String result(double funded, int joined) => policy.evaluate(
      fundingGoal: 1500,
      sponsoredAmount: funded,
      minimumVolunteers: 4,
      joinedVolunteers: joined,
    );
    expect(result(1500, 4), 'confirmed');
    expect(result(1000, 4), 'fundingShort');
    expect(result(1500, 2), 'volunteersShort');
    expect(result(1000, 2), 'bothShort');
  });
}
