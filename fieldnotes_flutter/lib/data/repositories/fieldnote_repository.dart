import 'dart:typed_data';

import 'package:fieldnotes_client/fieldnotes_client.dart';

import '../../client.dart';

class FieldnoteRepository {
  Future<FieldnoteUserProfile?> profile() => client.fieldnote.getMyProfile();

  Future<FieldnoteUserProfile> completeSponsorProfile({
    required String displayName,
    required String sponsorType,
    String? organizationName,
    required String city,
    required List<String> interests,
  }) => client.fieldnote.completeSponsorProfile(
    displayName,
    sponsorType,
    organizationName,
    city,
    interests,
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
  Future<List<Campaign>> myCreatedCampaigns() =>
      client.fieldnote.listMyCreatedCampaigns();
  Future<List<Sponsorship>> mySponsorships() =>
      client.fieldnote.listMySponsorships();
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
    double longitude,
  ) => client.fieldnote.createCampaignFromProposal(
    proposal,
    latitude,
    longitude,
  );

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
