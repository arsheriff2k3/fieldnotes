import 'dart:async';
import 'dart:math' as math;

import 'package:fieldnotes_client/fieldnotes_client.dart';
import 'package:flutter/foundation.dart';

import '../../../data/repositories/fieldnote_repository.dart';
import '../../../data/services/campaign_link_service.dart';
import '../../../data/services/pending_role_service.dart';
import '../../core/error_messages.dart';

/// Set when the view model signed the user out because the server rejected
/// the session. It outlives the view model (the shell is torn down on sign
/// out), so the sign-in screen can show [sessionExpiredMessage] and then
/// reset it to false.
final ValueNotifier<bool> sessionExpiredNotice = ValueNotifier(false);

/// State of one live campaign stream.
enum LiveConnectionState { connecting, connected, reconnecting }

class FieldnoteViewModel extends ChangeNotifier {
  FieldnoteViewModel(this._repository, {PendingRoleService? pendingRoles})
    : _pendingRoles = pendingRoles ?? PendingRoleService();

  final FieldnoteRepository _repository;
  final PendingRoleService _pendingRoles;

  FieldnoteUserProfile? profile;
  LegalConsent? consent;
  TrustCenterSummary? trustCenter;
  LegalPolicies? legalPolicies;
  AccountDeletionRequest? deletionStatus;
  List<LegalConsentHistory> consentHistory = const [];
  VolunteerAvailability? availability;
  List<Campaign> campaigns = const [];
  List<Campaign> createdCampaigns = const [];

  /// Sponsor: every campaign created or funded, in any status (S-3).
  List<Campaign> myCampaigns = const [];
  List<Sponsorship> sponsorships = const [];
  List<SponsorshipHistoryEntry> paymentHistory = const [];
  List<ParticipationHistoryEntry> participationHistory = const [];
  List<CampaignMatch> matches = const [];
  List<CampaignInvitation> invitations = const [];
  List<CampaignParticipation> participations = const [];
  final Map<int, ImpactSummary> impacts = {};

  /// Friendly message for campaigns whose impact could not be loaded.
  final Map<int, String> impactErrors = {};

  /// Null until known. False means evidence summaries are the deterministic,
  /// volunteer-confirmed note summary (send `manualSummary: true`).
  bool? aiAvailable;

  /// Most recent live update from any campaign stream.
  CampaignLiveUpdate? lastLiveUpdate;
  final Map<int, CampaignLiveUpdate> lastLiveUpdates = {};

  int selectedIndex = 0;
  bool loading = true;
  bool working = false;

  /// Fatal error: only set while no profile could be loaded.
  String? errorMessage;

  /// Non-blocking error for a banner/snackbar after login (S-7).
  String? lastError;

  /// True once the session was rejected and the user was signed out.
  bool sessionExpired = false;

  bool _disposed = false;
  final Map<int, StreamSubscription<CampaignLiveUpdate>> _liveSubscriptions =
      {};
  final Map<int, Timer> _reconnectTimers = {};
  final Map<int, int> _reconnectAttempts = {};
  final Map<int, LiveConnectionState> _liveStates = {};

  FieldnoteRepository get repository => _repository;
  bool get needsOnboarding => !loading && profile == null;
  bool get needsConsent =>
      !loading && profile != null && needsConsentForCurrentPolicy;
  bool get isSponsor => profile?.role == AccountRole.sponsor;
  bool get isVolunteer => profile?.role == AccountRole.volunteer;
  bool get isAiAvailable => aiAvailable ?? false;

  /// Campaigns for the sponsor Impact view: [myCampaigns], plus any created
  /// campaign the server has not yet returned there.
  List<Campaign> get impactCampaigns => [
    ...myCampaigns,
    ...createdCampaigns.where(
      (created) => !myCampaigns.any((item) => item.id == created.id),
    ),
  ];

  /// Campaign ids with an open (or reconnecting) live stream.
  Set<int> get liveCampaignIds => _liveStates.keys.toSet();
  LiveConnectionState? liveStateFor(int campaignId) => _liveStates[campaignId];
  bool isSubscribedTo(int campaignId) => _liveStates.containsKey(campaignId);

  Future<void> initialize() async {
    loading = true;
    errorMessage = null;
    _notify();
    unawaited(loadLegalPolicies());
    try {
      profile = await _repository.profile();
      if (profile != null) {
        consent = await _repository.legalConsent();
        trustCenter = await _repository.trustCenter();
        if (!needsConsentForCurrentPolicy) await _loadRoleData();
      }
    } catch (error) {
      if (await _handleSessionError(error)) return;
      errorMessage = userMessageFor(error);
    } finally {
      loading = false;
      _notify();
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
    await _guardedLoad(_loadRoleData);
    _notify();
  }

  Future<void> consentCompleted(LegalConsent value) async {
    consent = value;
    await _guardedLoad(_loadRoleData);
    _notify();
  }

  Future<void> refresh() async {
    working = true;
    errorMessage = null;
    _notify();
    try {
      profile = await _repository.profile();
      consent = await _repository.legalConsent();
      trustCenter = await _repository.trustCenter();
      if (!needsConsentForCurrentPolicy) await _loadRoleData();
    } catch (error) {
      if (!await _handleSessionError(error)) {
        if (profile == null) {
          errorMessage = userMessageFor(error);
        } else {
          lastError = userMessageFor(error);
        }
      }
    } finally {
      working = false;
      _notify();
    }
  }

  void clearLastError() {
    if (lastError == null) return;
    lastError = null;
    _notify();
  }

  /// Runs [load] and turns failures into [lastError] instead of throwing.
  Future<void> _guardedLoad(Future<void> Function() load) async {
    try {
      await load();
    } catch (error) {
      if (!await _handleSessionError(error)) lastError = userMessageFor(error);
    }
  }

  /// Runs a user action; signs out on an expired session, then rethrows so
  /// the view can still show its own message.
  Future<T> _action<T>(Future<T> Function() run) async {
    try {
      return await run();
    } catch (error) {
      await _handleSessionError(error);
      rethrow;
    }
  }

  Future<void> _loadRoleData() async {
    if (profile == null) return;
    trustCenter = await _repository.trustCenter();
    unawaited(refreshDeletionStatus());
    if (isSponsor) {
      final results = await Future.wait<dynamic>([
        _repository.campaigns(),
        _repository.myCreatedCampaigns(),
        _repository.mySponsorships(),
        _repository.myCampaigns(),
      ]);
      campaigns = results[0] as List<Campaign>;
      createdCampaigns = results[1] as List<Campaign>;
      sponsorships = results[2] as List<Sponsorship>;
      myCampaigns = results[3] as List<Campaign>;
      unawaited(loadPaymentHistory());
      await _loadImpacts(impactCampaigns);
      _syncLiveSubscriptions();
    } else {
      final results = await Future.wait<dynamic>([
        _repository.campaigns(),
        _repository.availability(),
        _repository.matches().catchError((_) => <CampaignMatch>[]),
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
      unawaited(loadParticipationHistory());
      unawaited(loadAiAvailability());
    }
  }

  /// Loads every impact independently; one failure never aborts the rest.
  Future<void> _loadImpacts(Iterable<Campaign> items) async {
    final ids = items.map((item) => item.id).whereType<int>().toSet();
    await Future.wait(ids.map(_loadImpact));
    final failed = impactErrors.length;
    if (failed > 0) {
      lastError = failed == 1
          ? 'Impact for one campaign could not be loaded.'
          : 'Impact for $failed campaigns could not be loaded.';
    }
  }

  Future<void> _loadImpact(int campaignId) async {
    try {
      impacts[campaignId] = await _repository.impact(campaignId);
      impactErrors.remove(campaignId);
    } catch (error) {
      if (await _handleSessionError(error)) return;
      impactErrors[campaignId] = userMessageFor(error);
    }
  }

  // ---------------------------------------------------------------------------
  // Secondary data. Each loader is safe to call from a view: failures land in
  // [lastError] and never throw.

  Future<void> loadLegalPolicies() async {
    try {
      legalPolicies = await _repository.legalPolicies();
      _notify();
    } catch (_) {
      // Public metadata; the trust center summary still carries versions.
    }
  }

  Future<void> refreshDeletionStatus() => _guardedLoad(() async {
    deletionStatus = await _repository.accountDeletionStatus();
    _notify();
  });

  Future<void> loadPaymentHistory({int? limit, int? offset}) =>
      _guardedLoad(() async {
        paymentHistory = await _repository.myPaymentHistory(
          limit: limit,
          offset: offset,
        );
        _notify();
      });

  Future<void> loadParticipationHistory({int? limit, int? offset}) =>
      _guardedLoad(() async {
        participationHistory = await _repository.myParticipationHistory(
          limit: limit,
          offset: offset,
        );
        _notify();
      });

  Future<void> loadConsentHistory({int? limit, int? offset}) =>
      _guardedLoad(() async {
        consentHistory = await _repository.myConsentHistory(
          limit: limit,
          offset: offset,
        );
        _notify();
      });

  Future<void> loadAiAvailability() async {
    try {
      aiAvailable = await _repository.isAiAvailable();
    } catch (error) {
      await _handleSessionError(error);
      aiAvailable = null;
    }
    _notify();
  }

  void selectSection(int index) {
    selectedIndex = index;
    _notify();
  }

  Campaign? campaignById(int id) =>
      campaigns.where((campaign) => campaign.id == id).firstOrNull ??
      myCampaigns.where((campaign) => campaign.id == id).firstOrNull;

  CampaignParticipation? participationFor(int campaignId) => participations
      .where((participation) => participation.campaignId == campaignId)
      .firstOrNull;

  bool invitedTo(int campaignId) => invitations.any(
    (invitation) => invitation.campaignId == campaignId,
  );

  /// Resolves a deep link (slug or numeric id). Null when it is not open.
  Future<Campaign?> campaignForLink(CampaignLinkTarget target) => _action(
    () => target.slug != null
        ? _repository.sharedCampaignBySlug(target.slug!)
        : _repository.sharedCampaign(target.id!),
  );

  Future<String> campaignShareLink(int campaignId) =>
      _action(() => _repository.campaignShareLink(campaignId));

  Future<RazorpayCheckoutOrder> createPaymentOrder(
    Campaign campaign,
    double amount,
    String? message,
  ) => _action(
    () => _repository.createRazorpayOrder(campaign.id!, amount, message),
  );

  Future<void> verifyPayment(
    RazorpayCheckoutOrder order, {
    required String returnedOrderId,
    required String paymentId,
    required String signature,
  }) async {
    await _action(
      () => _repository.verifyRazorpayPayment(
        sponsorshipId: order.sponsorshipId,
        orderId: returnedOrderId,
        paymentId: paymentId,
        signature: signature,
      ),
    );
  }

  Future<Campaign> publishCampaign(
    CampaignProposal proposal,
    double latitude,
    double longitude, {
    String? locationName,
    double? geofenceMeters,
  }) async {
    final campaign = await _action(
      () => _repository.createCampaign(
        proposal,
        latitude,
        longitude,
        locationName: locationName,
        geofenceMeters: geofenceMeters,
      ),
    );
    await refresh();
    return campaign;
  }

  Future<void> join(Campaign campaign) async {
    await _action(() => _repository.join(campaign.id!));
    await refresh();
  }

  /// Frees the volunteer's seat (V-1).
  Future<CampaignParticipation> leaveCampaign(
    CampaignParticipation participation,
  ) async {
    final updated = await _action(
      () => _repository.leaveCampaign(participation.id!),
    );
    await refresh();
    return updated;
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
    final updated = await _action(
      () => _repository.checkIn(
        participation.id!,
        latitude,
        longitude,
        accuracy,
        deviceReportedMock,
        explicitDemo,
        capturedAt,
      ),
    );
    await refresh();
    return updated;
  }

  Future<void> participationCompleted() => refresh();

  Future<void> availabilityUpdated() => refresh();

  Future<void> profileUpdated(FieldnoteUserProfile value) async {
    profile = value;
    await _guardedLoad(_loadRoleData);
    _notify();
  }

  /// Sponsor approves or rejects one evidence item (S-6), then reloads that
  /// campaign's impact.
  Future<CompletionEvidence> reviewEvidence(
    int campaignId,
    int evidenceId, {
    required bool approve,
    String? note,
  }) async {
    final evidence = await _action(
      () => _repository.reviewEvidence(
        evidenceId,
        approve: approve,
        note: note,
      ),
    );
    await _loadImpact(campaignId);
    _notify();
    return evidence;
  }

  Future<List<TestRefund>> campaignRefunds(
    int campaignId, {
    int? limit,
    int? offset,
  }) => _action(
    () => _repository.campaignRefunds(campaignId, limit: limit, offset: offset),
  );

  Future<CampaignPost> createCampaignPost(
    int campaignId,
    String title,
    String body,
  ) => _action(() => _repository.createCampaignPost(campaignId, title, body));

  Future<void> setEmailNotifications(bool enabled) async {
    profile = await _action(() => _repository.setEmailNotifications(enabled));
    _notify();
  }

  /// Records consent with the real checkbox values and the policy versions
  /// the user was shown (T-2/T-3).
  Future<LegalConsent> acceptLegalConsent({
    required bool locationConsent,
    required bool aiProcessingConsent,
    required bool evidenceSharingConsent,
  }) async {
    final accepted = await _action(
      () => _repository.acceptLegalConsent(
        locationConsent: locationConsent,
        aiProcessingConsent: aiProcessingConsent,
        evidenceSharingConsent: evidenceSharingConsent,
        acceptedPrivacyPolicyVersion:
            trustCenter?.privacyPolicyVersion ??
            legalPolicies?.privacyPolicyVersion,
        acceptedTermsVersion:
            trustCenter?.termsVersion ?? legalPolicies?.termsVersion,
      ),
    );
    await consentCompleted(accepted);
    return accepted;
  }

  /// Withdraws consent; [needsConsent] then routes back to the consent gate.
  Future<void> withdrawConsent() async {
    consent = await _action(_repository.withdrawConsent);
    _closeAllLiveSubscriptions();
    unawaited(loadConsentHistory());
    _notify();
  }

  Future<String> exportMyData() => _action(_repository.exportMyData);

  Future<void> recordAccountDataExport(String format) async {
    await _action(() => _repository.recordAccountDataExport(format));
    trustCenter = await _repository.trustCenter();
    _notify();
  }

  /// Throws `deletion_blocked_*` FieldnoteExceptions when obligations remain.
  Future<void> requestAccountDeletion() async {
    await _action(_repository.requestAccountDeletion);
    trustCenter = await _repository.trustCenter();
    await refreshDeletionStatus();
    _notify();
  }

  Future<void> refreshImpact(int campaignId) async {
    await _loadImpact(campaignId);
    _notify();
  }

  // ---------------------------------------------------------------------------
  // Live streams (S-8): one subscription per campaign, reconnect with backoff.

  static bool _isLiveWorthy(Campaign campaign) =>
      campaign.status != CampaignStatus.completed &&
      campaign.readinessState != 'cancelled' &&
      campaign.readinessState != 'expired';

  void _syncLiveSubscriptions() {
    for (final campaign in impactCampaigns.where(_isLiveWorthy)) {
      final id = campaign.id;
      if (id != null && !_liveStates.containsKey(id)) subscribeToCampaign(id);
    }
  }

  /// Opens (or keeps) a live stream for [campaignId]. Does not affect other
  /// campaigns' streams.
  void subscribeToCampaign(int campaignId) {
    if (_disposed) return;
    if (_liveSubscriptions.containsKey(campaignId)) return;
    _reconnectTimers.remove(campaignId)?.cancel();
    _liveStates[campaignId] = (_reconnectAttempts[campaignId] ?? 0) == 0
        ? LiveConnectionState.connecting
        : LiveConnectionState.reconnecting;
    _notify();
    _liveSubscriptions[campaignId] = _repository
        .watchCampaign(campaignId)
        .listen(
          (update) {
            _reconnectAttempts[campaignId] = 0;
            _liveStates[campaignId] = LiveConnectionState.connected;
            lastLiveUpdate = update;
            lastLiveUpdates[campaignId] = update;
            _notify();
            if (update.event != 'connected') {
              unawaited(refreshImpact(campaignId));
            }
          },
          onError: (Object error) async {
            if (await _handleSessionError(error)) return;
            _scheduleReconnect(campaignId);
          },
          // Streams also close cleanly on sign-out or a server restart.
          onDone: () => _scheduleReconnect(campaignId),
          cancelOnError: true,
        );
  }

  void unsubscribeFromCampaign(int campaignId) {
    _reconnectTimers.remove(campaignId)?.cancel();
    _liveSubscriptions.remove(campaignId)?.cancel();
    _reconnectAttempts.remove(campaignId);
    _liveStates.remove(campaignId);
    _notify();
  }

  void _scheduleReconnect(int campaignId) {
    _liveSubscriptions.remove(campaignId);
    if (_disposed ||
        sessionExpired ||
        !_liveStates.containsKey(campaignId) ||
        !_repository.isSignedIn) {
      _liveStates.remove(campaignId);
      _notify();
      return;
    }
    final attempt = (_reconnectAttempts[campaignId] ?? 0) + 1;
    _reconnectAttempts[campaignId] = attempt;
    final seconds = math.min(60, 1 << math.min(attempt - 1, 6));
    _liveStates[campaignId] = LiveConnectionState.reconnecting;
    _notify();
    _reconnectTimers[campaignId]?.cancel();
    _reconnectTimers[campaignId] = Timer(Duration(seconds: seconds), () {
      _reconnectTimers.remove(campaignId);
      if (_liveStates.containsKey(campaignId)) subscribeToCampaign(campaignId);
    });
  }

  void _closeAllLiveSubscriptions() {
    for (final timer in _reconnectTimers.values) {
      timer.cancel();
    }
    // Clear the state first so the cancelled streams do not reconnect.
    _liveStates.clear();
    _reconnectTimers.clear();
    _reconnectAttempts.clear();
    final subscriptions = _liveSubscriptions.values.toList();
    _liveSubscriptions.clear();
    for (final subscription in subscriptions) {
      subscription.cancel();
    }
  }

  // ---------------------------------------------------------------------------
  // Session.

  /// Signs out this device (or all devices), clears the pending role and all
  /// in-memory state (T-1). Local sign-out happens even if the server call
  /// fails; the return value is false in that case.
  Future<bool> signOut({bool allDevices = false}) async {
    _closeAllLiveSubscriptions();
    var signedOut = false;
    try {
      await _pendingRoles.clear();
      signedOut = await _repository.signOut(allDevices: allDevices);
    } finally {
      // The shell is normally gone by now; clear anyway in case it is not.
      _clearState();
      _notify();
    }
    return signedOut;
  }

  /// Returns true (after signing out) when [error] is an expired session.
  Future<bool> _handleSessionError(Object error) async {
    if (!isUnauthorizedError(error)) return false;
    if (sessionExpired) return true;
    sessionExpired = true;
    sessionExpiredNotice.value = true;
    await signOut();
    return true;
  }

  void _clearState() {
    profile = null;
    consent = null;
    trustCenter = null;
    deletionStatus = null;
    consentHistory = const [];
    availability = null;
    campaigns = const [];
    createdCampaigns = const [];
    myCampaigns = const [];
    sponsorships = const [];
    paymentHistory = const [];
    participationHistory = const [];
    matches = const [];
    invitations = const [];
    participations = const [];
    impacts.clear();
    impactErrors.clear();
    aiAvailable = null;
    lastLiveUpdate = null;
    lastLiveUpdates.clear();
    selectedIndex = 0;
    errorMessage = null;
    lastError = null;
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _closeAllLiveSubscriptions();
    super.dispose();
  }
}
