import 'dart:convert';

import 'package:fieldnotes_client/fieldnotes_client.dart';
import 'package:fieldnotes_flutter/data/repositories/fieldnote_repository.dart';
import 'package:fieldnotes_flutter/ui/features/shell/fieldnote_view_model.dart';

final reviewUser = UuidValue.withValidation(
  '550e8400-e29b-41d4-a716-446655440000',
);
final reviewCampaign = Campaign(
  id: 1,
  organizationId: 1,
  createdBy: reviewUser,
  name: 'Neighbourhood park cleanup',
  description:
      'Help clean the park, separate recyclable waste and document the work together.',
  locationName: 'Riverside community park, Pune',
  startsAt: DateTime.now().toUtc().add(const Duration(days: 2)),
  endsAt: DateTime.now().toUtc().add(const Duration(days: 2, hours: 2)),
  status: CampaignStatus.active,
  readinessState: 'needs_decision',
  fundingGoalPaise: 1500000,
  sponsoredAmountPaise: 850000,
  refundedAmountPaise: 50000,
  fundingGoal: 15000,
  sponsoredAmount: 8500,
  volunteerCapacity: 12,
  minimumVolunteers: 6,
  eligibleVolunteers: 4,
  latitude: 18.52,
  longitude: 73.85,
  checklist: 'Collect waste|Separate recycling|Take a photograph',
);
final reviewEvidence = CompletionEvidence(
  id: 1,
  participationId: 1,
  originalNote: 'We collected six bags of waste.',
  confirmedSummary:
      'Collected and sorted six bags of waste along the eastern park entrance.',
  structuredResults: 'Collected six bags|Separated recyclables',
  latitude: 18.52,
  longitude: 73.85,
  locationAccuracyMeters: 8,
  locationIsDemo: true,
  reviewState: ReviewState.awaitingReview,
);
final reviewProfile = FieldnoteUserProfile(
  id: 1,
  authUserId: reviewUser,
  role: AccountRole.sponsor,
  displayName: 'Community Sponsor',
  city: 'Pune',
  interests: 'environment|cleanup|community',
  skills: '',
  sponsorType: 'Company',
  organizationName: 'Neighbourhood collective',
  contactPhone: '+919876543210',
  emailNotifications: true,
);
final reviewConsent = LegalConsent(
  authUserId: reviewUser,
  privacyPolicyVersion: '2026-10-01',
  termsVersion: '2026-10-01',
  locationConsent: true,
  aiProcessingConsent: true,
  evidenceSharingConsent: true,
);
final reviewPolicies = LegalPolicies(
  privacyPolicyVersion: '2026-10-01',
  termsVersion: '2026-10-01',
  privacyPolicyUrl: 'http://localhost:8082/legal/privacy',
  termsUrl: 'http://localhost:8082/legal/terms',
  requiredConsents: [
    'locationConsent',
    'aiProcessingConsent',
    'evidenceSharingConsent',
  ],
);
final reviewEvents = List.generate(
  8,
  (i) => AuditEvent(
    actorAuthUserId: reviewUser,
    event: i.isEven ? 'paymentSignatureVerified' : 'evidenceSubmitted',
    entityType: 'campaign',
    entityId: '1',
    outcome: 'passed',
    riskLevel: 'info',
    detail: i.isEven
        ? 'Test Mode payment signature verified on the server.'
        : 'Location-backed evidence submitted for sponsor review.',
  ),
);
final reviewTrust = TrustCenterSummary(
  consent: reviewConsent,
  recentEvents: reviewEvents,
  privacyPolicyVersion: '2026-10-01',
  termsVersion: '2026-10-01',
  locationProtection:
      'Exact volunteer locations stay private to the campaign team.',
  moderationProtection: 'Evidence is moderated before it is stored.',
  paymentProtection: 'Payment signatures are verified on the server.',
  retentionNotice: 'You can export your records or request account deletion.',
);
final reviewPayment = Sponsorship(
  id: 1,
  campaignId: 1,
  sponsorAuthUserId: reviewUser,
  amount: 8500,
  amountPaise: 850000,
  paymentStatus: 'verified',
  paymentTestMode: true,
  providerOrderId: 'order_review',
  providerPaymentId: 'pay_review',
);
final reviewRequest = ManualPayoutRequest(
  id: 1,
  campaignId: 1,
  creatorAuthUserId: reviewUser,
  clientRequestId: 'review-only',
  sponsorshipIds: [1],
  grossAmountPaise: 850000,
  amountPaise: 850000,
);

/// No mutating network requests: the fixture is for UI review only.
class SponsorReviewRepository extends FieldnoteRepository {
  bool processingRequest = false;
  @override
  Future<AuditEvent> requestAccountDeletion() async => reviewEvents.first;
  @override
  Future<bool> signOut({bool allDevices = false}) async => true;
  @override
  Future<FieldnoteUserProfile?> profile() async => reviewProfile;
  @override
  Future<LegalConsent?> legalConsent() async => reviewConsent;
  @override
  Future<LegalPolicies> legalPolicies() async => reviewPolicies;
  @override
  Future<TrustCenterSummary> trustCenter() async => reviewTrust;
  @override
  Future<bool> isPayoutOperator() async => false;
  @override
  Future<bool> isAiAvailable() async => false;
  @override
  Future<bool> citySearchAvailable() async => false;
  @override
  Future<bool> placeSearchAvailable() async => false;
  @override
  Future<bool> locationSearchAvailable() async => false;
  @override
  Future<bool> isPayoutSimulationAvailable() async => true;
  @override
  Future<AccountDeletionRequest?> accountDeletionStatus() async => null;
  @override
  Future<List<LegalConsentHistory>> myConsentHistory({
    int? limit,
    int? offset,
  }) async => [];
  @override
  Future<List<Campaign>> campaigns({int? limit, int? offset}) async => [
    reviewCampaign,
  ];
  @override
  Future<List<Campaign>> myCampaigns({int? limit, int? offset}) async => [
    reviewCampaign,
  ];
  @override
  Future<List<Campaign>> myCreatedCampaigns({int? limit, int? offset}) async =>
      [reviewCampaign];
  @override
  Future<List<Sponsorship>> mySponsorships({int? limit, int? offset}) async => [
    reviewPayment,
  ];
  @override
  Future<ImpactSummary> impact(int campaignId) async => ImpactSummary(
    campaignId: campaignId,
    sponsorshipTotal: 8500,
    fundingGoal: 15000,
    sponsorshipTotalPaise: 850000,
    fundingGoalPaise: 1500000,
    refundedPaise: 50000,
    joinedVolunteers: 4,
    completedVolunteers: 2,
    evidenceCount: 2,
    summary:
        '1 sponsor-approved contribution; 1 pending review. Includes Razorpay Test Mode payments; no real money moves.',
    recentEvidence: [
      reviewEvidence,
      reviewEvidence.copyWith(
        id: 2,
        participationId: 2,
        reviewState: ReviewState.approved,
      ),
    ],
  );
  @override
  Future<List<SponsorshipHistoryEntry>> myPaymentHistory({
    int? limit,
    int? offset,
  }) async => [
    SponsorshipHistoryEntry(
      sponsorship: reviewPayment,
      campaignName: reviewCampaign.name,
      campaignStatus: reviewCampaign.status,
      campaignReadinessState: 'open',
    ),
  ];
  @override
  Future<List<TestRefund>> campaignRefunds(
    int campaignId, {
    int? limit,
    int? offset,
  }) async => [
    TestRefund(
      id: 1,
      campaignId: campaignId,
      sponsorshipId: 1,
      amount: 500,
      amountPaise: 50000,
      status: 'processed',
    ),
  ];
  @override
  Future<List<TestPayout>> campaignTestPayouts(
    int campaignId, {
    int? limit,
    int? offset,
  }) async => [];
  @override
  Future<List<CampaignPost>> campaignPosts(
    int campaignId, {
    int? limit,
    int? offset,
  }) async => [];
  @override
  Future<CampaignMapOverview> campaignMap(int campaignId) async =>
      CampaignMapOverview(
        campaign: reviewCampaign,
        pins: [],
        joinedCount: 4,
        checkedInCount: 2,
        completedCount: 2,
        demoCount: 1,
      );
  @override
  Future<CampaignVolunteerMap> campaignVolunteerMap(int campaignId) async =>
      CampaignVolunteerMap(
        summary:
            '4 joined volunteers and 3 eligible volunteers in a nearby area.',
        volunteers: [
          CampaignVolunteerMapMember(
            profileId: 1,
            displayName: 'Volunteer One',
            areaLabel: 'Riverside, Pune',
            latitude: 18.52,
            longitude: 73.85,
            status: 'joined',
          ),
          CampaignVolunteerMapMember(
            profileId: 2,
            displayName: 'Volunteer Two',
            areaLabel: 'Riverside, Pune',
            latitude: 18.52,
            longitude: 73.85,
            status: 'joined',
          ),
          CampaignVolunteerMapMember(
            profileId: 0,
            displayName: '',
            areaLabel: 'Nearby area',
            latitude: 18.53,
            longitude: 73.86,
            status: 'area',
            volunteerCount: 3,
          ),
        ],
      );
  @override
  Future<ManualPayoutSummary> manualPayoutSummary(int campaignId) async =>
      ManualPayoutSummary(
        campaignId: campaignId,
        liveMode: true,
        completed: true,
        eligiblePaise: 850000,
        availablePaise: 850000,
        reservedPaise: 0,
        paidPaise: 0,
        requests: [],
      );
  @override
  Future<List<ManualPayoutRequest>> manualPayoutRequests({
    int limit = 50,
    int offset = 0,
  }) async => [
    processingRequest
        ? reviewRequest.copyWith(status: 'processing')
        : reviewRequest,
  ];
  @override
  Stream<CampaignLiveUpdate> watchCampaign(int campaignId) =>
      const Stream.empty();
  @override
  Future<String> evidenceUrl(int evidenceId) async =>
      throw const FormatException('UI review photo placeholder');
  @override
  Future<String> exportMyData() async => jsonEncode({
    'generatedAt': DateTime.now().toUtc().toIso8601String(),
    'profile': {
      'displayName': reviewProfile.displayName,
      'role': 'sponsor',
      'city': 'Pune',
    },
    'createdCampaigns': [
      {
        'name': reviewCampaign.name,
        'locationName': reviewCampaign.locationName,
        'fundingGoal': 15000,
        'readinessState': 'open',
      },
    ],
    'sponsorships': [
      {
        'campaignName': reviewCampaign.name,
        'amount': 8500,
        'paymentStatus': 'verified',
      },
    ],
  });
}

FieldnoteViewModel sponsorReviewModel(SponsorReviewRepository repository) =>
    FieldnoteViewModel(repository)
      ..profile = reviewProfile
      ..consent = reviewConsent
      ..legalPolicies = reviewPolicies
      ..trustCenter = reviewTrust
      ..loading = false
      ..aiAvailable = false
      ..campaigns = [reviewCampaign]
      ..createdCampaigns = [reviewCampaign]
      ..myCampaigns = [reviewCampaign]
      ..sponsorships = [reviewPayment];
