import 'dart:async';

import 'package:fieldnotes_client/fieldnotes_client.dart';
import 'package:flutter/foundation.dart';

import '../../../data/repositories/fieldnote_repository.dart';

class FieldnoteViewModel extends ChangeNotifier {
  FieldnoteViewModel(this._repository);

  final FieldnoteRepository _repository;
  StreamSubscription<CampaignLiveUpdate>? _liveSubscription;

  FieldnoteUserProfile? profile;
  LegalConsent? consent;
  TrustCenterSummary? trustCenter;
  VolunteerAvailability? availability;
  List<Campaign> campaigns = const [];
  List<Campaign> createdCampaigns = const [];
  List<Sponsorship> sponsorships = const [];
  List<CampaignMatch> matches = const [];
  List<CampaignInvitation> invitations = const [];
  List<CampaignParticipation> participations = const [];
  final Map<int, ImpactSummary> impacts = {};
  CampaignLiveUpdate? lastLiveUpdate;
  int selectedIndex = 0;
  bool loading = true;
  bool working = false;
  String? errorMessage;

  FieldnoteRepository get repository => _repository;
  bool get needsOnboarding => !loading && profile == null;
  bool get needsConsent =>
      !loading && profile != null && needsConsentForCurrentPolicy;
  bool get isSponsor => profile?.role == AccountRole.sponsor;
  bool get isVolunteer => profile?.role == AccountRole.volunteer;

  Future<void> initialize() async {
    loading = true;
    errorMessage = null;
    notifyListeners();
    try {
      profile = await _repository.profile();
      if (profile != null) {
        consent = await _repository.legalConsent();
        trustCenter = await _repository.trustCenter();
        if (!needsConsentForCurrentPolicy) await _loadRoleData();
      }
    } catch (error) {
      errorMessage = _message(error);
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  bool get needsConsentForCurrentPolicy =>
      consent == null ||
      trustCenter == null ||
      consent!.privacyPolicyVersion != trustCenter!.privacyPolicyVersion ||
      consent!.termsVersion != trustCenter!.termsVersion ||
      !consent!.locationConsent ||
      !consent!.aiProcessingConsent ||
      !consent!.evidenceSharingConsent;

  Future<void> onboardingCompleted(
    FieldnoteUserProfile value,
    LegalConsent acceptedConsent,
  ) async {
    profile = value;
    consent = acceptedConsent;
    selectedIndex = 0;
    await _loadRoleData();
    notifyListeners();
  }

  Future<void> consentCompleted(LegalConsent value) async {
    consent = value;
    await _loadRoleData();
    notifyListeners();
  }

  Future<void> refresh() async {
    working = true;
    errorMessage = null;
    notifyListeners();
    try {
      profile = await _repository.profile();
      consent = await _repository.legalConsent();
      trustCenter = await _repository.trustCenter();
      if (!needsConsentForCurrentPolicy) await _loadRoleData();
    } catch (error) {
      errorMessage = _message(error);
    } finally {
      working = false;
      notifyListeners();
    }
  }

  Future<void> _loadRoleData() async {
    if (profile == null) return;
    trustCenter = await _repository.trustCenter();
    if (isSponsor) {
      final results = await Future.wait<dynamic>([
        _repository.campaigns(),
        _repository.myCreatedCampaigns(),
        _repository.mySponsorships(),
      ]);
      campaigns = results[0] as List<Campaign>;
      createdCampaigns = results[1] as List<Campaign>;
      sponsorships = results[2] as List<Sponsorship>;
      final impactCampaigns = <Campaign>{...createdCampaigns};
      for (final sponsorship in sponsorships) {
        if (sponsorship.paymentStatus != 'verified') continue;
        final campaign = campaigns
            .where((item) => item.id == sponsorship.campaignId)
            .firstOrNull;
        if (campaign != null) impactCampaigns.add(campaign);
      }
      for (final campaign in impactCampaigns) {
        if (campaign.id != null) {
          impacts[campaign.id!] = await _repository.impact(campaign.id!);
        }
      }
      final liveCampaign =
          createdCampaigns.firstOrNull ?? campaigns.firstOrNull;
      if (liveCampaign?.id != null) subscribeToCampaign(liveCampaign!.id!);
    } else {
      final results = await Future.wait<dynamic>([
        _repository.campaigns(),
        _repository.availability(),
        _repository.matches(),
        _repository.participations(),
        _repository.myJoinedCampaigns(),
        _repository.myCampaignInvitations().catchError(
          (_) => <CampaignInvitation>[],
        ),
      ]);
      final discovered = results[0] as List<Campaign>;
      final joined = results[4] as List<Campaign>;
      campaigns = [
        ...discovered,
        ...joined.where(
          (item) => !discovered.any((value) => value.id == item.id),
        ),
      ];
      availability = results[1] as VolunteerAvailability?;
      matches = results[2] as List<CampaignMatch>;
      participations = results[3] as List<CampaignParticipation>;
      invitations = results[5] as List<CampaignInvitation>;
    }
  }

  void selectSection(int index) {
    selectedIndex = index;
    notifyListeners();
  }

  Campaign? campaignById(int id) =>
      campaigns.where((campaign) => campaign.id == id).firstOrNull;

  CampaignParticipation? participationFor(int campaignId) => participations
      .where((participation) => participation.campaignId == campaignId)
      .firstOrNull;

  bool invitedTo(int campaignId) => invitations.any(
    (invitation) => invitation.campaignId == campaignId,
  );

  Future<RazorpayCheckoutOrder> createPaymentOrder(
    Campaign campaign,
    double amount,
    String? message,
  ) => _repository.createRazorpayOrder(campaign.id!, amount, message);

  Future<void> verifyPayment(
    RazorpayCheckoutOrder order, {
    required String returnedOrderId,
    required String paymentId,
    required String signature,
  }) async {
    await _repository.verifyRazorpayPayment(
      sponsorshipId: order.sponsorshipId,
      orderId: returnedOrderId,
      paymentId: paymentId,
      signature: signature,
    );
  }

  Future<Campaign> publishCampaign(
    CampaignProposal proposal,
    double latitude,
    double longitude, {
    String? locationName,
    double? geofenceMeters,
  }) async {
    final campaign = await _repository.createCampaign(
      proposal,
      latitude,
      longitude,
      locationName: locationName,
      geofenceMeters: geofenceMeters,
    );
    await refresh();
    return campaign;
  }

  Future<void> join(Campaign campaign) async {
    await _repository.join(campaign.id!);
    await refresh();
  }

  Future<CampaignParticipation> checkIn(
    CampaignParticipation participation,
    double latitude,
    double longitude,
    double accuracy,
    bool deviceReportedMock,
    bool explicitDemo,
    DateTime capturedAt,
  ) async {
    final updated = await _repository.checkIn(
      participation.id!,
      latitude,
      longitude,
      accuracy,
      deviceReportedMock,
      explicitDemo,
      capturedAt,
    );
    await refresh();
    return updated;
  }

  Future<void> participationCompleted() => refresh();

  Future<void> availabilityUpdated() => refresh();

  Future<void> profileUpdated(FieldnoteUserProfile value) async {
    profile = value;
    await _loadRoleData();
    notifyListeners();
  }

  Future<String> exportMyData() => _repository.exportMyData();

  Future<void> recordAccountDataExport(String format) async {
    await _repository.recordAccountDataExport(format);
    trustCenter = await _repository.trustCenter();
    notifyListeners();
  }

  Future<void> requestAccountDeletion() async {
    await _repository.requestAccountDeletion();
    trustCenter = await _repository.trustCenter();
    notifyListeners();
  }

  Future<void> refreshImpact(int campaignId) async {
    impacts[campaignId] = await _repository.impact(campaignId);
    notifyListeners();
  }

  void subscribeToCampaign(int campaignId) {
    _liveSubscription?.cancel();
    _liveSubscription = _repository.watchCampaign(campaignId).listen(
      (update) {
        lastLiveUpdate = update;
        notifyListeners();
        if (update.event != 'connected') {
          unawaited(refreshImpact(campaignId));
        }
      },
      onError: (_) {},
    );
  }

  @override
  void dispose() {
    _liveSubscription?.cancel();
    super.dispose();
  }

  static String _message(Object error) {
    if (error is FieldnoteException) return error.message;
    return 'FieldNote could not complete that action. Check the local server connection and try again.';
  }
}
