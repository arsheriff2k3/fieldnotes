import 'dart:convert';
import 'package:fieldnotes_client/fieldnotes_client.dart';
import 'package:fieldnotes_flutter/ui/features/shell/fieldnote_view_model.dart';
import 'sponsor_review_fixture.dart';

final volunteerReviewProfile = reviewProfile.copyWith(
  role: AccountRole.volunteer,
  displayName: 'Volunteer Explorer',
  sponsorType: null,
  organizationName: null,
  interests: 'environment|community',
  skills: 'outdoors|photography',
);
final volunteerReviewAvailability = VolunteerAvailability(
  volunteerAuthUserId: reviewUser,
  weekdays: '1,2,3,4,5,6,7',
  startMinutes: 420,
  endMinutes: 1200,
  maximumTravelKm: 10,
  latitude: 18.52,
  longitude: 73.85,
  locationLabel: 'Pune volunteer travel area',
  timezone: 'Asia/Kolkata',
  utcOffsetMinutes: 330,
);
final volunteerUpcomingCampaign = reviewCampaign.copyWith(
  readinessState: 'confirmed',
);
final volunteerCurrentCampaign = reviewCampaign.copyWith(
  id: 2,
  name: 'Riverbank cleanup and recycling',
  readinessState: 'confirmed',
  startsAt: DateTime.now().toUtc().subtract(const Duration(minutes: 20)),
  endsAt: DateTime.now().toUtc().add(const Duration(hours: 2)),
);
final volunteerPastCampaign = reviewCampaign.copyWith(
  id: 3,
  name: 'Community tree care day',
  status: CampaignStatus.completed,
  readinessState: 'completed',
  startsAt: DateTime.now().toUtc().subtract(const Duration(days: 2)),
  endsAt: DateTime.now().toUtc().subtract(const Duration(days: 2, hours: -2)),
);
final volunteerJoined = CampaignParticipation(
  id: 1,
  campaignId: 1,
  volunteerAuthUserId: reviewUser,
  status: ParticipationStatus.joined,
);
final volunteerCheckedIn = CampaignParticipation(
  id: 2,
  campaignId: 2,
  volunteerAuthUserId: reviewUser,
  status: ParticipationStatus.checkedIn,
  checkedInAt: DateTime.now().toUtc(),
  checkInLatitude: 18.52,
  checkInLongitude: 73.85,
  checkInAccuracyMeters: 8,
  locationIntegrityStatus: 'verified',
);
final volunteerCompleted = CampaignParticipation(
  id: 3,
  campaignId: 3,
  volunteerAuthUserId: reviewUser,
  status: ParticipationStatus.completed,
  completedAt: DateTime.now().toUtc().subtract(const Duration(days: 2)),
);
final volunteerReviewedEvidence = reviewEvidence.copyWith(
  id: 3,
  participationId: 3,
  locationIsDemo: false,
  reviewState: ReviewState.approved,
  reviewedAt: DateTime.now().toUtc().subtract(const Duration(days: 1)),
);

class VolunteerReviewRepository extends SponsorReviewRepository {
  @override
  Future<String> exportMyData() async => jsonEncode({
    'generatedAt': DateTime.now().toUtc().toIso8601String(),
    'profile': {
      'displayName': volunteerReviewProfile.displayName,
      'role': 'volunteer',
      'city': 'Pune',
    },
    'participations': [
      {'campaignName': volunteerPastCampaign.name, 'status': 'completed'},
    ],
    'availability': {'weekdays': '1,2,3,4,5,6,7', 'maximumTravelKm': 10},
  });
  @override
  Future<FieldnoteUserProfile?> profile() async => volunteerReviewProfile;
  @override
  Future<VolunteerAvailability?> availability() async =>
      volunteerReviewAvailability;
  @override
  Future<List<Campaign>> campaigns({int? limit, int? offset}) async => [
    volunteerUpcomingCampaign,
    volunteerCurrentCampaign,
    volunteerPastCampaign,
  ];
  @override
  Future<List<Campaign>> myJoinedCampaigns({int? limit, int? offset}) =>
      campaigns();
  @override
  Future<List<CampaignMatch>> matches() async => [
    CampaignMatch(
      campaign: volunteerUpcomingCampaign,
      score: 93,
      distanceKm: 1.2,
      availabilityMatches: true,
      reasons: [
        'Your available days and time window fit this event.',
        'A short trip from your chosen travel area.',
        'Matches your environment and community interests.',
      ],
    ),
  ];
  @override
  Future<List<CampaignParticipation>> participations({
    int? limit,
    int? offset,
  }) async => [volunteerJoined, volunteerCheckedIn, volunteerCompleted];
  @override
  Future<List<CampaignInvitation>> myCampaignInvitations({
    int? limit,
    int? offset,
  }) async => [];
  @override
  Future<List<ParticipationHistoryEntry>> myParticipationHistory({
    int? limit,
    int? offset,
  }) async => [
    ParticipationHistoryEntry(
      participation: volunteerJoined,
      campaign: volunteerUpcomingCampaign,
    ),
    ParticipationHistoryEntry(
      participation: volunteerCheckedIn,
      campaign: volunteerCurrentCampaign,
    ),
    ParticipationHistoryEntry(
      participation: volunteerCompleted,
      campaign: volunteerPastCampaign,
      evidence: volunteerReviewedEvidence,
    ),
  ];
  @override
  Future<String?> campaignContactPhone(int campaignId) async => null;
  @override
  Future<TravelRoute> travelRoute({
    required int campaignId,
    required double originLatitude,
    required double originLongitude,
    String travelMode = 'WALK',
  }) async => TravelRoute(
    distanceMeters: 1200,
    durationSeconds: 900,
    encodedPolyline: '_p~iF~ps|U_ulLnnqC_mqNvxq`@',
    steps: [
      TravelStep(
        instruction: 'Follow the footpath towards the park entrance.',
        distanceMeters: 800,
        endLatitude: 18.52,
        endLongitude: 73.85,
      ),
      TravelStep(
        instruction: 'Turn left and meet the team by the main gate.',
        distanceMeters: 400,
        endLatitude: 18.52,
        endLongitude: 73.85,
      ),
    ],
  );
}

Future<FieldnoteViewModel> volunteerReviewModel(
  VolunteerReviewRepository repo,
) async {
  final model = sponsorReviewModel(repo)
    ..profile = volunteerReviewProfile
    ..availability = volunteerReviewAvailability
    ..campaigns = await repo.campaigns()
    ..createdCampaigns = []
    ..myCampaigns = []
    ..sponsorships = []
    ..matches = await repo.matches()
    ..participations = await repo.participations()
    ..participationHistory = await repo.myParticipationHistory();
  return model;
}
