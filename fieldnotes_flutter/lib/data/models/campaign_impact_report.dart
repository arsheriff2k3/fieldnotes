import 'package:fieldnotes_client/fieldnotes_client.dart';

/// Export only reviewed summaries and provenance, never raw evidence records.
class ReportContribution {
  ReportContribution(CompletionEvidence evidence)
    : id = evidence.id,
      summary = evidence.confirmedSummary,
      submittedAt = evidence.submittedAt,
      reviewedAt = evidence.reviewedAt,
      isDemo = evidence.locationIsDemo,
      aiGenerated = evidence.aiGenerated;

  final int? id;
  final String summary;
  final DateTime submittedAt;
  final DateTime? reviewedAt;
  final bool isDemo;
  final bool aiGenerated;
}

class CampaignImpactReport {
  CampaignImpactReport({
    required Campaign campaign,
    required ImpactSummary impact,
    required this.retrievedAt,
  }) : campaignId = impact.campaignId,
       campaignName = campaign.name,
       locationName = campaign.locationName,
       startsAt = campaign.startsAt,
       endsAt = campaign.endsAt,
       netFundingPaise = impact.sponsorshipTotalPaise,
       fundingGoalPaise = impact.fundingGoalPaise,
       refundedPaise = impact.refundedPaise,
       joinedVolunteers = impact.joinedVolunteers,
       submittedCount = impact.recentEvidence.length,
       approvedCount = impact.recentEvidence
           .where((e) => e.reviewState == ReviewState.approved)
           .length,
       pendingCount = impact.recentEvidence
           .where((e) => e.reviewState == ReviewState.awaitingReview)
           .length,
       changesRequestedCount = impact.recentEvidence
           .where((e) => e.reviewState == ReviewState.changesRequested)
           .length,
       rejectedCount = impact.recentEvidence
           .where((e) => e.reviewState == ReviewState.rejected)
           .length,
       demoEvidenceCount = impact.recentEvidence
           .where((e) => e.locationIsDemo)
           .length,
       serverSummary = impact.summary,
       contributions = List.unmodifiable(
         impact.recentEvidence
             .where((e) => e.reviewState == ReviewState.approved)
             .map(ReportContribution.new),
       );

  final int campaignId;
  final String campaignName;
  final String locationName;
  final DateTime startsAt;
  final DateTime? endsAt;
  final DateTime retrievedAt;
  final int netFundingPaise;
  final int fundingGoalPaise;
  final int refundedPaise;
  final int joinedVolunteers;
  final int submittedCount;
  final int approvedCount;
  final int pendingCount;
  final int changesRequestedCount;
  final int rejectedCount;
  final int demoEvidenceCount;
  final String serverSummary;
  final List<ReportContribution> contributions;
}
