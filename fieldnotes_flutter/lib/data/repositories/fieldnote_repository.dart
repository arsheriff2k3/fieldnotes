import 'dart:convert';
import 'dart:typed_data';

import 'package:fieldnotes_client/fieldnotes_client.dart';

import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

import '../../client.dart';
import '../services/device_time_zone_service.dart';

class FieldnoteRepository {
  FieldnoteRepository({DeviceTimeZoneService? timeZones})
    : _timeZones = timeZones ?? DeviceTimeZoneService();

  final DeviceTimeZoneService _timeZones;

  bool get isSignedIn => client.auth.isAuthenticated;

  /// Revokes the session on the server; the local session is cleared even
  /// when that call fails (the result is then false).
  Future<bool> signOut({bool allDevices = false}) => allDevices
      ? client.auth.signOutAllDevices()
      : client.auth.signOutDevice();

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
  }) async => client.fieldnote.completeVolunteerProfile(
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
    timezone: await _timeZones.ianaTimeZone(),
    utcOffsetMinutes: DeviceTimeZoneService.utcOffsetMinutes(),
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
  }) async => client.fieldnote.updateAvailability(
    isAvailable,
    availableToday,
    weekdays,
    startMinutes,
    endMinutes,
    maximumTravelKm,
    latitude,
    longitude,
    locationLabel,
    timezone: await _timeZones.ianaTimeZone(),
    utcOffsetMinutes: DeviceTimeZoneService.utcOffsetMinutes(),
  );

  Future<FieldnoteUserProfile> setEmailNotifications(bool enabled) =>
      client.fieldnote.setEmailNotifications(enabled);

  Future<List<Campaign>> campaigns({int? limit, int? offset}) =>
      client.fieldnote.listCampaigns(limit: limit, offset: offset);
  Future<Campaign?> sharedCampaign(int campaignId) =>
      client.fieldnote.getSharedCampaign(campaignId);
  Future<Campaign?> sharedCampaignBySlug(String slug) =>
      client.fieldnote.getSharedCampaignBySlug(slug);

  /// The server-issued public `https://<host>/c/<slug>` link.
  Future<String> campaignShareLink(int campaignId) =>
      client.fieldnote.getCampaignShareLink(campaignId);
  Future<String?> campaignContactPhone(int campaignId) =>
      client.fieldnote.getCampaignContactPhone(campaignId);
  Future<List<Campaign>> myCreatedCampaigns({int? limit, int? offset}) =>
      client.fieldnote.listMyCreatedCampaigns(limit: limit, offset: offset);
  Future<List<Campaign>> myJoinedCampaigns({int? limit, int? offset}) =>
      client.fieldnote.listMyJoinedCampaigns(limit: limit, offset: offset);

  /// Campaigns the sponsor created or funded, in any status (S-3).
  Future<List<Campaign>> myCampaigns({int? limit, int? offset}) =>
      client.fieldnote.listMyCampaigns(limit: limit, offset: offset);
  Future<List<SponsorshipHistoryEntry>> myPaymentHistory({
    int? limit,
    int? offset,
  }) => client.fieldnote.listMyPaymentHistory(limit: limit, offset: offset);
  Future<List<ParticipationHistoryEntry>> myParticipationHistory({
    int? limit,
    int? offset,
  }) => client.fieldnote.listMyParticipationHistory(
    limit: limit,
    offset: offset,
  );
  Future<List<TestRefund>> campaignRefunds(
    int campaignId, {
    int? limit,
    int? offset,
  }) => client.fieldnote.listCampaignRefunds(
    campaignId,
    limit: limit,
    offset: offset,
  );
  Future<List<CampaignPost>> campaignPosts(
    int campaignId, {
    int? limit,
    int? offset,
  }) => client.fieldnote.listCampaignPosts(
    campaignId,
    limit: limit,
    offset: offset,
  );
  Future<CampaignPost> createCampaignPost(
    int campaignId,
    String title,
    String body,
  ) => client.fieldnote.createCampaignPost(campaignId, title, body);
  Future<Campaign> refreshCampaignReadiness(int campaignId) =>
      client.fieldnote.refreshCampaignReadiness(campaignId);

  /// The goal is sent in paise; the rupee value is only for old servers.
  Future<Campaign> reviseCampaignScope(
    int campaignId,
    int fundingGoalPaise,
    int minimumVolunteers,
    String description,
  ) => client.fieldnote.reviseCampaignScope(
    campaignId,
    fundingGoalPaise / 100,
    minimumVolunteers,
    description,
    fundingGoalPaise: fundingGoalPaise,
  );

  /// False in Razorpay live mode: payouts are then settled manually.
  Future<bool> isPayoutSimulationAvailable() =>
      client.fieldnote.isPayoutSimulationAvailable();
  Future<Campaign> postponeCampaign(int campaignId, DateTime newStartsAt) =>
      client.fieldnote.postponeCampaign(campaignId, newStartsAt);
  Future<Campaign> cancelCampaign(int campaignId) =>
      client.fieldnote.cancelCampaign(campaignId);
  Future<CampaignParticipation> reconfirmParticipation(int participationId) =>
      client.fieldnote.reconfirmCampaignParticipation(participationId);
  Future<List<Sponsorship>> mySponsorships({int? limit, int? offset}) =>
      client.fieldnote.listMySponsorships(limit: limit, offset: offset);
  Future<List<TestPayout>> campaignTestPayouts(
    int campaignId, {
    int? limit,
    int? offset,
  }) => client.fieldnote.listCampaignTestPayouts(
    campaignId,
    limit: limit,
    offset: offset,
  );
  Future<List<TestPayout>> simulateCampaignTestPayout(int campaignId) =>
      client.fieldnote.simulateCampaignTestPayout(campaignId);
  Future<List<CampaignMatch>> matches() =>
      client.fieldnote.getCampaignMatches();
  Future<List<CampaignParticipation>> participations({
    int? limit,
    int? offset,
  }) => client.fieldnote.listMyParticipations(limit: limit, offset: offset);

  Future<String> transcribeDictation(
    ByteData audio,
    String fileName,
    String mimeType,
  ) => client.fieldnote.transcribeDictation(audio, fileName, mimeType);

  Future<CampaignProposal> proposeCampaign(String prompt) async =>
      client.fieldnote.proposeCampaign(
        prompt,
        utcOffsetMinutes: DeviceTimeZoneService.utcOffsetMinutes(),
        timezone: await _timeZones.ianaTimeZone(),
      );

  /// Publishes [proposal] (its goal must be in `fundingGoalPaise`). The same
  /// [clientRequestId] on a retry returns the campaign created first.
  Future<Campaign> createCampaign(
    CampaignProposal proposal,
    double latitude,
    double longitude, {
    String? locationName,
    double? geofenceMeters,
    String? clientRequestId,
  }) => client.fieldnote.createCampaignFromProposal(
    proposal,
    latitude,
    longitude,
    locationName,
    geofenceMeters,
    clientRequestId: clientRequestId,
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

  Future<CampaignVolunteerMap> campaignVolunteerMap(int campaignId) =>
      client.fieldnote.getCampaignVolunteerMap(campaignId);

  Future<bool> inviteCampaignVolunteer(int campaignId, int profileId) =>
      client.fieldnote.inviteCampaignVolunteer(campaignId, profileId);

  Future<int> inviteCampaignVolunteersInArea(
    int campaignId,
    double latitude,
    double longitude,
  ) => client.fieldnote.inviteCampaignVolunteersInArea(
    campaignId,
    latitude,
    longitude,
  );

  Future<List<CampaignInvitation>> myCampaignInvitations({
    int? limit,
    int? offset,
  }) => client.fieldnote.listMyCampaignInvitations(
    limit: limit,
    offset: offset,
  );

  Future<CampaignMapOverview> campaignMap(int campaignId) =>
      client.fieldnote.getCampaignMap(campaignId);

  /// Opens a checkout for [amountPaise]. The same [clientRequestId] on a
  /// retry returns the order created first while it awaits payment.
  Future<RazorpayCheckoutOrder> createRazorpayOrder(
    int campaignId,
    int amountPaise,
    String? message, {
    String? clientRequestId,
  }) => client.fieldnote.createRazorpayOrder(
    campaignId,
    amountPaise / 100,
    message,
    amountPaise: amountPaise,
    clientRequestId: clientRequestId,
  );

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

  /// Public policy versions and URLs; works before sign-in.
  Future<LegalPolicies> legalPolicies() => client.legal.getLegalPolicies();

  /// Pass the versions the user actually saw so the server can reject a
  /// stale acceptance (`consent_version_mismatch`).
  Future<LegalConsent> acceptLegalConsent({
    bool locationConsent = true,
    bool aiProcessingConsent = true,
    bool evidenceSharingConsent = true,
    String? acceptedPrivacyPolicyVersion,
    String? acceptedTermsVersion,
  }) => client.fieldnote.acceptLegalConsent(
    locationConsent,
    aiProcessingConsent,
    evidenceSharingConsent,
    acceptedPrivacyPolicyVersion: acceptedPrivacyPolicyVersion,
    acceptedTermsVersion: acceptedTermsVersion,
  );

  Future<LegalConsent?> withdrawConsent() => client.fieldnote.withdrawConsent();

  Future<List<LegalConsentHistory>> myConsentHistory({
    int? limit,
    int? offset,
  }) => client.fieldnote.listMyConsentHistory(limit: limit, offset: offset);

  Future<TrustCenterSummary> trustCenter() => client.fieldnote.getTrustCenter();

  Future<String> exportMyData() => client.fieldnote.exportMyData();

  Future<AuditEvent> recordAccountDataExport(String format) =>
      client.fieldnote.recordAccountDataExport(format);

  Future<AuditEvent> requestAccountDeletion() =>
      client.fieldnote.requestAccountDeletion();

  Future<AccountDeletionRequest?> accountDeletionStatus() =>
      client.fieldnote.getAccountDeletionStatus();

  Future<CampaignParticipation> join(int campaignId) =>
      client.fieldnote.joinCampaign(campaignId);

  Future<CampaignParticipation> leaveCampaign(int participationId) =>
      client.fieldnote.leaveCampaign(participationId);

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

  /// False when no AI key is configured: `analyzeCompletion` then returns a
  /// deterministic summary of the note, which the volunteer confirms.
  Future<bool> isAiAvailable() => client.fieldnote.isAiAvailable();

  /// Uploads the photograph to the unique path the server issues for this
  /// attempt, then completes against that same path. Set [manualSummary] when
  /// the volunteer wrote or kept the non-AI summary.
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
    bool? manualSummary,
  }) async {
    final description = await client.fieldnote.getEvidenceUploadDescription(
      participationId,
      extension,
    );
    final uploadPath = _uploadPathFrom(description);
    final uploaded = await FileUploader(
      description,
    ).uploadByteData(ByteData.sublistView(photograph));
    if (!uploaded) {
      throw FieldnoteException(
        message: 'The photograph could not be uploaded. Try again.',
        code: 'upload_failed',
      );
    }
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
      uploadPath: uploadPath,
      manualSummary: manualSummary,
    );
  }

  Future<CompletionEvidence> reviewEvidence(
    int evidenceId, {
    required bool approve,
    String? note,
  }) => client.fieldnote.reviewEvidence(evidenceId, approve, note);

  Future<ImpactSummary> impact(int campaignId) =>
      client.fieldnote.getImpact(campaignId);
  Future<String> evidenceUrl(int evidenceId) =>
      client.fieldnote.getEvidenceDownloadUrl(evidenceId);
  Stream<CampaignLiveUpdate> watchCampaign(int campaignId) =>
      client.fieldnote.watchCampaign(campaignId);

  /// Extracts the storage path the server pinned for this upload from a
  /// Serverpod upload description (database storage puts it in the URL's
  /// `path` query parameter, S3-compatible storage in the `key` field).
  /// Returns null when it cannot be found; the server then falls back to the
  /// latest path it issued to the participation.
  static String? _uploadPathFrom(String description) {
    try {
      final data = jsonDecode(description);
      if (data is! Map) return null;
      final url = data['url'];
      if (url is String) {
        final path = Uri.tryParse(url)?.queryParameters['path'];
        if (path != null && path.isNotEmpty) return path;
      }
      final fields = data['request-fields'];
      if (fields is Map) {
        final key = fields['key'];
        if (key is String && key.isNotEmpty) return key;
      }
    } on FormatException {
      return null;
    }
    return null;
  }
}
