/// The four outcomes at the campaign readiness cutoff.
class CampaignReadinessPolicy {
  const CampaignReadinessPolicy();

  String evaluate({
    required double fundingGoal,
    required double sponsoredAmount,
    required int minimumVolunteers,
    required int joinedVolunteers,
  }) {
    final fundingReady = sponsoredAmount + 0.001 >= fundingGoal;
    final volunteersReady = joinedVolunteers >= minimumVolunteers;
    if (fundingReady && volunteersReady) return 'confirmed';
    if (!fundingReady && volunteersReady) return 'fundingShort';
    if (fundingReady && !volunteersReady) return 'volunteersShort';
    return 'bothShort';
  }
}
