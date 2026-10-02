/// The four outcomes at the campaign readiness cutoff.
class CampaignReadinessPolicy {
  const CampaignReadinessPolicy();

  String evaluate({
    required int fundingGoalPaise,
    required int sponsoredPaise,
    required int minimumVolunteers,
    required int joinedVolunteers,
  }) {
    final fundingReady = sponsoredPaise >= fundingGoalPaise;
    final volunteersReady = joinedVolunteers >= minimumVolunteers;
    if (fundingReady && volunteersReady) return 'confirmed';
    if (!fundingReady && volunteersReady) return 'fundingShort';
    if (fundingReady && !volunteersReady) return 'volunteersShort';
    return 'bothShort';
  }
}
