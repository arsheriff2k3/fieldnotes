import 'dart:typed_data';

import 'package:fieldnotes_client/fieldnotes_client.dart';

import '../../client.dart';

class FieldnoteRepository {
  Future<FieldnoteUserProfile?> profile() => client.fieldnote.getMyProfile();

  Future<FieldnoteUserProfile> completeSponsorProfile({
    required String displayName,
    required String sponsorType,
    String? organizationName,
    required String contactPhone,
    required String city,
    String? cityPlaceId,
    required List<String> interests,
    double? locationLatitude,
    double? locationLongitude,
  }) => client.fieldnote.completeSponsorProfile(
    displayName,
    sponsorType,
    organizationName,
    city,
    cityPlaceId,
    interests,
    locationLatitude: locationLatitude,
    locationLongitude: locationLongitude,
    contactPhone: contactPhone,
  );

  Future<FieldnoteUserProfile> completeVolunteerProfile({
    required String displayName,
    required String city,
    required List<String> interests,
    required List<String> skills,
    required bool isAvailable,
    required bool availableToday,
    required List<int> weekdays,
    required int startMinutes,
    required int endMinutes,
    required double maximumTravelKm,
    double? latitude,
    double? longitude,
    required String locationLabel,
  }) => client.fieldnote.completeVolunteerProfile(
    displayName,
    city,
    interests,
    skills,
    isAvailable,
    availableToday,
    weekdays,
    startMinutes,
    endMinutes,
    maximumTravelKm,
    latitude,
    longitude,
    locationLabel,
  );

  Future<VolunteerAvailability?> availability() =>
      client.fieldnote.getMyAvailability();

  Future<FieldnoteUserProfile> updateProfile({
    required String displayName,
    String? sponsorType,
    String? organizationName,
    String? contactPhone,
    required String city,
    String? cityPlaceId,
    required List<String> interests,
    required List<String> skills,
    double? locationLatitude,
    double? locationLongitude,
  }) => client.fieldnote.updateMyProfile(
    displayName,
    sponsorType,
    organizationName,
    city,
    cityPlaceId,
    interests,
    skills,
    locationLatitude: locationLatitude,
    locationLongitude: locationLongitude,
    contactPhone: contactPhone,
  );

  Future<VolunteerAvailability> updateAvailability({
    required bool isAvailable,
    required bool availableToday,
    required List<int> weekdays,
    required int startMinutes,
    required int endMinutes,
    required double maximumTravelKm,
    double? latitude,
    double? longitude,
    required String locationLabel,
  }) => client.fieldnote.updateAvailability(
    isAvailable,
    availableToday,
    weekdays,
    startMinutes,
    endMinutes,
    maximumTravelKm,
    latitude,
    longitude,
    locationLabel,
  );

  Future<List<Campaign>> campaigns() => client.fieldnote.listCampaigns();
  Future<String?> campaignContactPhone(int campaignId) =>
      client.fieldnote.getCampaignContactPhone(campaignId);
  Future<List<Campaign>> myCreatedCampaigns() =>
      client.fieldnote.listMyCreatedCampaigns();
  Future<List<Campaign>> myJoinedCampaigns() =>
      client.fieldnote.listMyJoinedCampaigns();
  Future<List<CampaignPost>> campaignPosts(int campaignId) =>
      client.fieldnote.listCampaignPosts(campaignId);
  Future<Campaign> refreshCampaignReadiness(int campaignId) =>
      client.fieldnote.refreshCampaignReadiness(campaignId);
  Future<Campaign> reviseCampaignScope(
    int campaignId,
    double fundingGoal,
    int minimumVolunteers,
    String description,
  ) => client.fieldnote.reviseCampaignScope(
    campaignId,
    fundingGoal,
    minimumVolunteers,
    description,
  );
  Future<Campaign> postponeCampaign(int campaignId, DateTime newStartsAt) =>
      client.fieldnote.postponeCampaign(campaignId, newStartsAt);
  Future<Campaign> cancelCampaign(int campaignId) =>
      client.fieldnote.cancelCampaign(campaignId);
  Future<CampaignParticipation> reconfirmParticipation(int participationId) =>
      client.fieldnote.reconfirmCampaignParticipation(participationId);
  Future<List<Sponsorship>> mySponsorships() =>
      client.fieldnote.listMySponsorships();
  Future<List<TestPayout>> campaignTestPayouts(int campaignId) =>
      client.fieldnote.listCampaignTestPayouts(campaignId);
  Future<List<TestPayout>> simulateCampaignTestPayout(int campaignId) =>
      client.fieldnote.simulateCampaignTestPayout(campaignId);
  Future<List<CampaignMatch>> matches() =>
      client.fieldnote.getCampaignMatches();
  Future<List<CampaignParticipation>> participations() =>
      client.fieldnote.listMyParticipations();

  Future<String> transcribeDictation(
    ByteData audio,
    String fileName,
    String mimeType,
  ) => client.fieldnote.transcribeDictation(audio, fileName, mimeType);

  Future<CampaignProposal> proposeCampaign(String prompt) =>
      client.fieldnote.proposeCampaign(prompt);

  Future<Campaign> createCampaign(
    CampaignProposal proposal,
    double latitude,
    double longitude, {
    String? locationName,
    double? geofenceMeters,
  }) => client.fieldnote.createCampaignFromProposal(
    proposal,
    latitude,
    longitude,
    locationName,
    geofenceMeters,
  );

  // Google Maps Platform. The API key stays on the server; these calls return
  // empty or null rather than throwing when it is not configured, so the maps
  // keep working with dragged pins and typed labels.

  Future<bool> locationSearchAvailable() =>
      client.fieldnote.isCitySearchAvailable();

  Future<List<PlaceSuggestion>> searchLocations(String query) =>
      client.fieldnote.searchSponsorLocations(query);

  Future<bool> citySearchAvailable() =>
      client.fieldnote.isCitySearchAvailable();

  Future<List<PlaceSuggestion>> searchCities(String query) =>
      client.fieldnote.searchCities(query);

  Future<bool> placeSearchAvailable() =>
      client.fieldnote.isPlaceSearchAvailable();

  Future<List<PlaceSuggestion>> searchPlaces(
    String query, {
    double? biasLatitude,
    double? biasLongitude,
  }) => client.fieldnote.searchPlaces(query, biasLatitude, biasLongitude);

  Future<ResolvedPlace> resolvePlace(String placeId) =>
      client.fieldnote.resolvePlace(placeId);

  Future<ResolvedPlace?> describeCoordinates(
    double latitude,
    double longitude,
  ) => client.fieldnote.describeCoordinates(latitude, longitude);

  Future<TravelRoute> travelRoute({
    required int campaignId,
    required double originLatitude,
    required double originLongitude,
    required String travelMode,
  }) => client.fieldnote.getTravelRoute(
    campaignId,
    originLatitude,
    originLongitude,
    travelMode,
  );

  Future<CampaignReach> previewReach(double latitude, double longitude) =>
      client.fieldnote.previewCampaignReach(latitude, longitude);

  Future<CampaignReach> campaignVolunteerReach(int campaignId) =>
      client.fieldnote.getCampaignVolunteerReach(campaignId);

  Future<int> inviteCampaignVolunteersInArea(
    int campaignId,
    double latitude,
    double longitude,
  ) => client.fieldnote.inviteCampaignVolunteersInArea(
    campaignId,
    latitude,
    longitude,
  );

  Future<List<CampaignInvitation>> myCampaignInvitations() =>
      client.fieldnote.listMyCampaignInvitations();

  Future<CampaignMapOverview> campaignMap(int campaignId) =>
      client.fieldnote.getCampaignMap(campaignId);

  Future<RazorpayCheckoutOrder> createRazorpayOrder(
    int campaignId,
    double amount,
    String? message,
  ) => client.fieldnote.createRazorpayOrder(campaignId, amount, message);

  Future<Sponsorship> verifyRazorpayPayment({
    required int sponsorshipId,
    required String orderId,
    required String paymentId,
    required String signature,
  }) => client.fieldnote.verifyRazorpayPayment(
    sponsorshipId,
    orderId,
    paymentId,
    signature,
  );

  Future<Sponsorship> recordRazorpayFailure(
    int sponsorshipId,
    String reason,
  ) => client.fieldnote.recordRazorpayFailure(sponsorshipId, reason);

  Future<LegalConsent?> legalConsent() => client.fieldnote.getMyLegalConsent();

  Future<LegalConsent> acceptLegalConsent() =>
      client.fieldnote.acceptLegalConsent(true, true, true);

  Future<TrustCenterSummary> trustCenter() => client.fieldnote.getTrustCenter();

  Future<String> exportMyData() => client.fieldnote.exportMyData();

  Future<AuditEvent> requestAccountDeletion() =>
      client.fieldnote.requestAccountDeletion();

  Future<CampaignParticipation> join(int campaignId) =>
      client.fieldnote.joinCampaign(campaignId);

  Future<CampaignParticipation> checkIn(
    int participationId,
    double latitude,
    double longitude,
    double accuracyMeters,
    bool deviceReportedMock,
    bool explicitDemo,
    DateTime capturedAt,
  ) => client.fieldnote.checkIn(
    participationId,
    latitude,
    longitude,
    accuracyMeters,
    deviceReportedMock,
    explicitDemo,
    capturedAt,
  );

  Future<CompletionProposal> analyzeCompletion(
    int participationId,
    String note,
    Uint8List? photograph,
    String? photographMimeType,
  ) => client.fieldnote.analyzeCompletion(
    participationId,
    note,
    photograph == null ? null : ByteData.sublistView(photograph),
    photographMimeType,
  );

  Future<CompletionEvidence> completeWithEvidence({
    required int participationId,
    required Uint8List photograph,
    required String extension,
    required String originalNote,
    required String confirmedSummary,
    required List<String> structuredResults,
    required double latitude,
    required double longitude,
    required double accuracyMeters,
    required bool deviceReportedMock,
    required bool explicitDemo,
    required DateTime capturedAt,
  }) async {
    final description = await client.fieldnote.getEvidenceUploadDescription(
      participationId,
      extension,
    );
    final uploaded = await FileUploader(
      description,
    ).uploadByteData(ByteData.sublistView(photograph));
    if (!uploaded) throw StateError('Evidence photograph upload failed.');
    return client.fieldnote.completeParticipation(
      participationId,
      extension,
      originalNote,
      confirmedSummary,
      structuredResults,
      latitude,
      longitude,
      accuracyMeters,
      deviceReportedMock,
      explicitDemo,
      capturedAt,
    );
  }

  Future<ImpactSummary> impact(int campaignId) =>
      client.fieldnote.getImpact(campaignId);
  Future<String> evidenceUrl(int evidenceId) =>
      client.fieldnote.getEvidenceDownloadUrl(evidenceId);
  Stream<CampaignLiveUpdate> watchCampaign(int campaignId) =>
      client.fieldnote.watchCampaign(campaignId);
}
