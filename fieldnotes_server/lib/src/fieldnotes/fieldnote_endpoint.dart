import 'dart:async';
import 'dart:math' as math;
import 'dart:convert';
import 'dart:typed_data';

import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import 'services/ai_provider_router.dart';
import 'services/content_moderation_service.dart';
import 'services/gemini_ai_service.dart';
import 'services/gemini_speech_service.dart';
import 'services/groq_ai_service.dart';
import 'services/google_maps_service.dart';
import 'services/structured_summary_service.dart';
import 'services/location_integrity_service.dart';
import 'services/payment_credit_service.dart';
import 'services/razorpay_payment_service.dart';
import 'services/campaign_events_service.dart';
import 'services/campaign_lifecycle_service.dart';
import 'services/campaign_validation.dart';
import 'services/fieldnote_sweep_service.dart';
import 'services/money.dart';
import 'services/manual_payout_service.dart';
import 'services/payment_reconciliation_service.dart';
import 'services/refund_service.dart';
import 'services/account_deletion_service.dart';
import 'services/fieldnote_config.dart';
import 'services/fieldnote_time.dart';
import 'services/notification_service.dart';
import 'services/in_app_notification_service.dart';
import 'services/rate_limiter.dart';

class FieldnoteEndpoint extends Endpoint {
  FieldnoteEndpoint({
    StructuredSummaryService? aiService,
    GeminiAiService? geminiService,
    GeminiSpeechService? speechService,
    GroqAiService? groqService,
    ContentModerationService? moderationService,
    LocationIntegrityService? locationIntegrityService,
    RazorpayGateway? paymentService,
    GoogleMapsService? mapsService,
  }) : _ai = aiService ?? const StructuredSummaryService(),
       _gemini = geminiService ?? const GeminiAiService(),
       _speech = speechService ?? GeminiSpeechService(),
       _groq = groqService ?? GroqAiService(),
       _moderation = moderationService ?? const ContentModerationService(),
       _locationIntegrity =
           locationIntegrityService ?? const LocationIntegrityService(),
       _paymentsOverride = paymentService,
       _maps = mapsService ?? _sharedMaps;

  /// Shared so the Routes API response cache survives across requests. A new
  /// endpoint instance is constructed per call by Serverpod.
  static final GoogleMapsService _sharedMaps = GoogleMapsService();

  final StructuredSummaryService _ai;
  final GeminiAiService _gemini;
  final GeminiSpeechService _speech;
  final GroqAiService _groq;
  final ContentModerationService _moderation;
  final LocationIntegrityService _locationIntegrity;
  final RazorpayGateway? _paymentsOverride;

  /// Resolved per call so tests can swap [RazorpayRuntime.gateway].
  RazorpayGateway get _payments => _paymentsOverride ?? RazorpayRuntime.gateway;

  static const _events = CampaignEventsService();
  static const _lifecycle = CampaignLifecycleService();
  static const _refunds = RefundService();
  final GoogleMapsService _maps;

  /// Volunteer coverage is only ever returned to sponsors in buckets of at
  /// least this many people, rounded to roughly a kilometre.
  static const _reachCellAnonymityThreshold = 3;

  static const privacyPolicyVersion = '2026-09-22';
  static const termsVersion = '2026-09-22';

  /// The three consent switches acceptLegalConsent requires.
  static const requiredConsents = [
    'locationConsent',
    'aiProcessingConsent',
    'evidenceSharingConsent',
  ];

  static const _limiter = RateLimiter();
  static const _notifications = NotificationService();
  static const _deletion = AccountDeletionService();

  // Input bounds (P2 hygiene).
  static const _displayNameMax = 80;
  static const _shortTextMax = 120;
  static const _noteMax = 2000;
  static const _postBodyMax = 2000;
  static const _promptMax = 4000;
  static const _tagListMax = 20;
  static const _tagMax = 40;
  static const _sponsorMessageMax = 500;

  @override
  bool get requireLogin => true;

  Future<FieldnoteUserProfile?> getMyProfile(Session session) async {
    return FieldnoteUserProfile.db.findFirstRow(
      session,
      where: (t) => t.authUserId.equals(_userId(session)),
    );
  }

  Future<LegalConsent?> getMyLegalConsent(Session session) {
    return LegalConsent.db.findFirstRow(
      session,
      where: (t) => t.authUserId.equals(_userId(session)),
    );
  }

  /// Records the checkbox values the user actually ticked. All three are
  /// required; a false value is rejected and nothing is stored. When the
  /// client passes the policy versions it displayed, stale versions are
  /// rejected so the user re-reads the current documents.
  Future<LegalConsent> acceptLegalConsent(
    Session session,
    bool locationConsent,
    bool aiProcessingConsent,
    bool evidenceSharingConsent, {
    String? acceptedPrivacyPolicyVersion,
    String? acceptedTermsVersion,
  }) async {
    if (!locationConsent || !aiProcessingConsent || !evidenceSharingConsent) {
      throw FieldnoteException(
        message:
            'Location, AI processing, and evidence sharing consent are required to continue.',
        code: 'consent_required',
      );
    }
    if ((acceptedPrivacyPolicyVersion != null &&
            acceptedPrivacyPolicyVersion != privacyPolicyVersion) ||
        (acceptedTermsVersion != null &&
            acceptedTermsVersion != termsVersion)) {
      throw FieldnoteException(
        message:
            'The Privacy Policy or Terms changed. Review the current versions to continue.',
        code: 'consent_version_mismatch',
      );
    }
    final userId = _userId(session);
    final existing = await getMyLegalConsent(session);
    final now = DateTime.now().toUtc();
    await _appendConsentHistory(
      session,
      userId,
      action: 'accepted',
      location: locationConsent,
      ai: aiProcessingConsent,
      evidence: evidenceSharingConsent,
    );
    final consent = existing == null
        ? await LegalConsent.db.insertRow(
            session,
            LegalConsent(
              authUserId: userId,
              privacyPolicyVersion: privacyPolicyVersion,
              termsVersion: termsVersion,
              locationConsent: true,
              aiProcessingConsent: true,
              evidenceSharingConsent: true,
              acceptedAt: now,
              updatedAt: now,
            ),
          )
        : await LegalConsent.db.updateRow(
            session,
            existing.copyWith(
              privacyPolicyVersion: privacyPolicyVersion,
              termsVersion: termsVersion,
              locationConsent: true,
              aiProcessingConsent: true,
              evidenceSharingConsent: true,
              acceptedAt: now,
              updatedAt: now,
            ),
          );
    await _audit(
      session,
      event: 'legalConsentAccepted',
      entityType: 'account',
      outcome: 'accepted',
      riskLevel: 'info',
      detail: 'Privacy $privacyPolicyVersion and Terms $termsVersion accepted.',
    );
    return consent;
  }

  /// T-2: withdraws location, AI processing and evidence sharing consent.
  /// Every role-gated feature then answers `consent_required` until the user
  /// accepts again. Withdrawal does not delete data; use
  /// [requestAccountDeletion] for that.
  Future<LegalConsent?> withdrawConsent(Session session) async {
    final userId = _userId(session);
    final existing = await getMyLegalConsent(session);
    if (existing == null) return null;
    if (!existing.locationConsent &&
        !existing.aiProcessingConsent &&
        !existing.evidenceSharingConsent) {
      return existing;
    }
    await _appendConsentHistory(
      session,
      userId,
      action: 'withdrawn',
      location: false,
      ai: false,
      evidence: false,
    );
    final updated = await LegalConsent.db.updateRow(
      session,
      existing.copyWith(
        locationConsent: false,
        aiProcessingConsent: false,
        evidenceSharingConsent: false,
        updatedAt: DateTime.now().toUtc(),
      ),
    );
    await _audit(
      session,
      event: 'legalConsentWithdrawn',
      entityType: 'account',
      outcome: 'withdrawn',
      riskLevel: 'info',
      detail: 'Location, AI processing and evidence sharing consent withdrawn.',
    );
    return updated;
  }

  /// Append-only consent history, newest first.
  Future<List<LegalConsentHistory>> listMyConsentHistory(
    Session session, {
    int? limit,
    int? offset,
  }) {
    final userId = _userId(session);
    final page = _page(limit, offset);
    return LegalConsentHistory.db.find(
      session,
      where: (t) => t.authUserId.equals(userId),
      orderBy: (t) => t.id.desc(),
      limit: page.limit,
      offset: page.offset,
    );
  }

  Future<void> _appendConsentHistory(
    Session session,
    UuidValue userId, {
    required String action,
    required bool location,
    required bool ai,
    required bool evidence,
  }) => LegalConsentHistory.db.insertRow(
    session,
    LegalConsentHistory(
      authUserId: userId,
      action: action,
      privacyPolicyVersion: privacyPolicyVersion,
      termsVersion: termsVersion,
      locationConsent: location,
      aiProcessingConsent: ai,
      evidenceSharingConsent: evidence,
    ),
  );

  /// A-9: turns transactional email on or off for the caller.
  Future<FieldnoteUserProfile> setEmailNotifications(
    Session session,
    bool enabled,
  ) async {
    final profile = await _requireProfile(session);
    if (profile.emailNotifications == enabled) return profile;
    profile.emailNotifications = enabled;
    profile.updatedAt = DateTime.now().toUtc();
    return FieldnoteUserProfile.db.updateRow(session, profile);
  }

  Future<TrustCenterSummary> getTrustCenter(Session session) async {
    final userId = _userId(session);
    final results = await Future.wait<dynamic>([
      getMyLegalConsent(session),
      AuditEvent.db.find(
        session,
        where: (t) => t.actorAuthUserId.equals(userId),
        orderBy: (t) => t.occurredAt.desc(),
        limit: 25,
      ),
    ]);
    return TrustCenterSummary(
      consent: results[0] as LegalConsent?,
      recentEvents: results[1] as List<AuditEvent>,
      privacyPolicyVersion: privacyPolicyVersion,
      termsVersion: termsVersion,
      locationProtection:
          'Freshness, coordinate bounds, accuracy, device mock flags, geofence, and movement continuity are checked.',
      moderationProtection:
          'Unsafe text and exposed identifiers are blocked before storage and before AI requests.',
      paymentProtection:
          'Razorpay orders are created by the server and successful checkout signatures are verified server-side before impact totals change.',
      retentionNotice:
          'FieldNote keeps your account data, approximate GPS evidence and private photographs until you delete your account. '
          'Deletion removes your profile, availability, invitations, photographs and evidence text and signs you out everywhere. '
          'Payment, refund and consent records are kept without your name for accounting and legal purposes.',
    );
  }

  /// Inbox IDs are an immutable keyset cursor, newest first.
  Future<List<NotificationItem>> getMyNotifications(
    Session session, {
    int limit = 20,
    int? beforeId,
    bool unreadOnly = false,
  }) async {
    final profile = await _requireProfile(session);
    if (limit < 1 || limit > 50 || (beforeId != null && beforeId <= 0)) {
      throw FieldnoteException(
        code: 'invalid_notification_page',
        message: 'Invalid notification page.',
      );
    }
    final rows = await InAppNotification.db.find(
      session,
      where: (t) =>
          t.recipientAuthUserId.equals(profile.authUserId) &
          (beforeId == null ? Constant.bool(true) : t.id < beforeId) &
          (unreadOnly ? t.readAt.equals(null) : Constant.bool(true)),
      orderBy: (t) => t.id.desc(),
      limit: limit,
    );
    return rows.map(InAppNotificationService.item).toList();
  }

  Future<NotificationItem?> getMyNotification(
    Session session,
    int notificationId,
  ) async {
    final profile = await _requireProfile(session);
    final row = await InAppNotification.db.findFirstRow(
      session,
      where: (t) =>
          t.id.equals(notificationId) &
          t.recipientAuthUserId.equals(profile.authUserId),
    );
    return row == null ? null : InAppNotificationService.item(row);
  }

  Future<int> getMyUnreadNotificationCount(Session session) async {
    final profile = await _requireProfile(session);
    return InAppNotification.db.count(
      session,
      where: (t) =>
          t.recipientAuthUserId.equals(profile.authUserId) &
          t.readAt.equals(null),
    );
  }

  Future<void> markMyNotificationRead(
    Session session,
    int notificationId,
  ) async {
    final profile = await _requireProfile(session);
    await InAppNotification.db.updateWhere(
      session,
      columnValues: (t) => [t.readAt(DateTime.now().toUtc())],
      where: (t) =>
          t.id.equals(notificationId) &
          t.recipientAuthUserId.equals(profile.authUserId) &
          t.readAt.equals(null),
    );
  }

  /// Newer arrivals remain unread even if the request races with insertion.
  Future<void> markMyNotificationsReadThrough(
    Session session,
    int throughId,
  ) async {
    final profile = await _requireProfile(session);
    final newest = await InAppNotification.db.findFirstRow(
      session,
      where: (t) => t.recipientAuthUserId.equals(profile.authUserId),
      orderBy: (t) => t.id.desc(),
    );
    if (throughId <= 0 || newest == null) return;
    final cutoff = math.min(throughId, newest.id!);
    await InAppNotification.db.updateWhere(
      session,
      columnValues: (t) => [t.readAt(DateTime.now().toUtc())],
      where: (t) =>
          t.recipientAuthUserId.equals(profile.authUserId) &
          (t.id <= cutoff) &
          t.readAt.equals(null),
    );
  }

  Future<void> registerMyPushDevice(
    Session session,
    String token,
    String platform,
  ) async {
    final profile = await _requireProfile(session);
    await _limiter.hit(
      session,
      profile.authUserId,
      RateLimits.pushRegistration,
    );
    await const InAppNotificationService().registerDevice(
      session,
      profile.authUserId,
      token,
      platform,
    );
  }

  Future<void> unregisterMyPushDevice(Session session, String token) async {
    await const InAppNotificationService().unregisterDevice(
      session,
      _userId(session),
      token,
    );
  }

  Future<void> unregisterAllMyPushDevices(Session session) async {
    final userId = _userId(session);
    await session.db.transaction((transaction) async {
      await PushDelivery.db.deleteWhere(
        session,
        where: (t) => t.recipientAuthUserId.equals(userId),
        transaction: transaction,
      );
      await PushDevice.db.deleteWhere(
        session,
        where: (t) => t.authUserId.equals(userId),
        transaction: transaction,
      );
    });
  }

  Future<String> exportMyData(Session session) async {
    final userId = _userId(session);
    final profile = await _requireProfile(session);
    await _limiter.hit(session, userId, RateLimits.dataExport);
    final consentHistory = await LegalConsentHistory.db.find(
      session,
      where: (t) => t.authUserId.equals(userId),
      orderBy: (t) => t.recordedAt.desc(),
    );
    final deletionRequest = await AccountDeletionRequest.db.findFirstRow(
      session,
      where: (t) => t.authUserId.equals(userId),
    );
    final consent = await getMyLegalConsent(session);
    final notifications = await InAppNotification.db.find(
      session,
      where: (t) => t.recipientAuthUserId.equals(userId),
      orderBy: (t) => t.id.desc(),
    );
    final pushDevices = await PushDevice.db.find(
      session,
      where: (t) => t.authUserId.equals(userId),
    );
    final availability = await VolunteerAvailability.db.findFirstRow(
      session,
      where: (t) => t.volunteerAuthUserId.equals(userId),
    );
    final createdCampaigns = await Campaign.db.find(
      session,
      where: (t) => t.createdBy.equals(userId),
      orderBy: (t) => t.createdAt.desc(),
    );
    final sponsorships = await Sponsorship.db.find(
      session,
      where: (t) => t.sponsorAuthUserId.equals(userId),
      orderBy: (t) => t.createdAt.desc(),
    );
    final participations = await CampaignParticipation.db.find(
      session,
      where: (t) => t.volunteerAuthUserId.equals(userId),
      orderBy: (t) => t.joinedAt.desc(),
    );
    final receivedInvitations = await CampaignInvitation.db.find(
      session,
      where: (t) => t.volunteerAuthUserId.equals(userId),
      orderBy: (t) => t.createdAt.desc(),
    );
    final sentInvitations = await CampaignInvitation.db.find(
      session,
      where: (t) => t.sponsorAuthUserId.equals(userId),
      orderBy: (t) => t.createdAt.desc(),
    );
    final manualPayouts = await ManualPayoutRequest.db.find(
      session,
      where: (t) => t.creatorAuthUserId.equals(userId),
      orderBy: (t) => t.requestedAt.desc(),
    );
    final payouts = await TestPayout.db.find(
      session,
      where: (t) => t.creatorAuthUserId.equals(userId),
      orderBy: (t) => t.simulatedAt.desc(),
    );
    final posts = await CampaignPost.db.find(
      session,
      where: (t) => t.authorSponsorAuthUserId.equals(userId),
      orderBy: (t) => t.createdAt.desc(),
    );
    final activity = await AuditEvent.db.find(
      session,
      where: (t) => t.actorAuthUserId.equals(userId),
      orderBy: (t) => t.occurredAt.desc(),
    );
    final campaignIds = <int>{
      ...createdCampaigns.map((item) => item.id).whereType<int>(),
      ...sponsorships.map((item) => item.campaignId),
      ...participations.map((item) => item.campaignId),
      ...receivedInvitations.map((item) => item.campaignId),
      ...sentInvitations.map((item) => item.campaignId),
    };
    final campaignNames = <int, String>{
      for (final campaign in createdCampaigns)
        if (campaign.id != null) campaign.id!: campaign.name,
    };
    final missingNames = campaignIds.difference(campaignNames.keys.toSet());
    if (missingNames.isNotEmpty) {
      for (final campaign in await Campaign.db.find(
        session,
        where: (t) => t.id.inSet(missingNames),
      )) {
        campaignNames[campaign.id!] = campaign.name;
      }
    }
    final participationCampaigns = {
      for (final item in participations)
        if (item.id != null) item.id!: item.campaignId,
    };
    final evidence = participationCampaigns.isEmpty
        ? <CompletionEvidence>[]
        : await CompletionEvidence.db.find(
            session,
            where: (t) =>
                t.participationId.inSet(participationCampaigns.keys.toSet()),
          );
    final sponsorshipIds = sponsorships
        .map((item) => item.id)
        .whereType<int>()
        .toSet();
    final refunds = sponsorshipIds.isEmpty
        ? <TestRefund>[]
        : await TestRefund.db.find(
            session,
            where: (t) => t.sponsorshipId.inSet(sponsorshipIds),
          );
    return const JsonEncoder.withIndent('  ').convert({
      'formatVersion': 2,
      'generatedAt': DateTime.now().toUtc().toIso8601String(),
      'profile': profile.toJson(),
      'consent': consent?.toJson(),
      'consentHistory': consentHistory.map((item) => item.toJson()).toList(),
      'accountDeletionRequest': deletionRequest?.toJson(),
      'availability': availability?.toJson(),
      'createdCampaigns': createdCampaigns
          .map((item) => item.toJson())
          .toList(),
      'sponsorships': sponsorships
          .map(
            (item) => {
              ...item.toJson(),
              'campaignName': campaignNames[item.campaignId],
            },
          )
          .toList(),
      'participations': participations
          .map(
            (item) => {
              ...item.toJson(),
              'campaignName': campaignNames[item.campaignId],
            },
          )
          .toList(),
      'receivedInvitations': receivedInvitations
          .map(
            (item) => {
              ...item.toJson(),
              'campaignName': campaignNames[item.campaignId],
            },
          )
          .toList(),
      'sentInvitations': sentInvitations
          .map((item) => item.campaignId)
          .toSet()
          .map(
            (campaignId) => {
              'campaignId': campaignId,
              'campaignName': campaignNames[campaignId],
              'count': sentInvitations
                  .where((item) => item.campaignId == campaignId)
                  .length,
            },
          )
          .toList(),
      'completionEvidence': evidence
          .map(
            (item) => {
              ...item.toJson(),
              'campaignName':
                  campaignNames[participationCampaigns[item.participationId]],
            },
          )
          .toList(),
      'campaignChatMessages': (await CampaignChatMessage.db.find(
        session,
        where: (t) => t.senderAuthUserId.equals(userId),
      )).map((item) => item.toJson()).toList(),
      'campaignPosts': posts.map((item) => item.toJson()).toList(),
      'manualPayoutRequests': manualPayouts.map((p) => p.toJson()).toList(),
      'testPayouts': payouts.map((item) => item.toJson()).toList(),
      'testRefunds': refunds.map((item) => item.toJson()).toList(),
      'securityActivity': activity.map((item) => item.toJson()).toList(),
      'mediaNotice': 'Private photographs are not embedded in this export.',
      'notifications': notifications
          .map(InAppNotificationService.item)
          .map((n) => n.toJson())
          .toList(),
      'pushDevices': pushDevices
          .map(
            (device) => {
              'platform': device.platform,
              'updatedAt': device.updatedAt.toIso8601String(),
            },
          )
          .toList(),
    });
  }

  Future<AuditEvent> recordAccountDataExport(
    Session session,
    String format,
  ) async {
    await _requireProfile(session);
    final normalizedFormat = format.toLowerCase();
    if (normalizedFormat != 'pdf' && normalizedFormat != 'json') {
      throw FieldnoteException(
        message: 'Unsupported account data export format.',
        code: 'invalid_export_format',
      );
    }
    return _audit(
      session,
      event: 'privacyDataExported',
      entityType: 'account',
      outcome: 'completed',
      riskLevel: 'info',
      detail:
          'The user saved or shared a ${normalizedFormat.toUpperCase()} account data export.',
    );
  }

  /// P0-6: queues real account deletion. Idempotent: repeated calls return
  /// the same pending request. Throws a `deletion_blocked_*` code while an
  /// obligation must settle first (see [AccountDeletionService]). The
  /// `fieldnote-outbox` future call executes the request within about a
  /// minute; afterwards the account, its sessions and its refresh tokens no
  /// longer exist. Poll [getAccountDeletionStatus] until then.
  Future<AuditEvent> requestAccountDeletion(Session session) async {
    final userId = _userId(session);
    await _limiter.hit(session, userId, RateLimits.accountDeletion);
    final request = await _deletion.request(session, userId);
    return _audit(
      session,
      event: 'accountDeletionRequested',
      entityType: 'account',
      entityId: '${request.id}',
      outcome: 'queued',
      riskLevel: 'info',
      detail:
          'Deletion queued. Personal data is deleted within minutes; payment and consent records are kept without identity.',
    );
  }

  /// The caller's deletion request, or null when none was made. Once the
  /// request completes the caller's sign-in no longer exists, so a completed
  /// status is only visible to a session that was still open.
  Future<AccountDeletionRequest?> getAccountDeletionStatus(Session session) {
    final userId = _userId(session);
    return AccountDeletionRequest.db.findFirstRow(
      session,
      where: (t) => t.authUserId.equals(userId),
    );
  }

  Future<FieldnoteUserProfile> completeSponsorProfile(
    Session session,
    String displayName,
    String sponsorType,
    String? organizationName,
    String city,
    String? cityPlaceId,
    List<String> interests, {
    double? locationLatitude,
    double? locationLongitude,
    String? contactPhone,
  }) async {
    final phone = _validatedContactPhone(contactPhone);
    final verifiedLocation = await _verifiedSponsorLocation(
      session,
      typedLocation: city,
      placeId: cityPlaceId,
      latitude: locationLatitude,
      longitude: locationLongitude,
    );
    return _upsertProfile(
      session,
      role: AccountRole.sponsor,
      displayName: displayName,
      sponsorType: sponsorType,
      organizationName: organizationName,
      contactPhone: phone,
      city: verifiedLocation.name,
      locationAddress: verifiedLocation.address,
      locationPlaceId: verifiedLocation.placeId,
      locationLatitude: verifiedLocation.latitude,
      locationLongitude: verifiedLocation.longitude,
      interests: interests,
      skills: const [],
    );
  }

  Future<FieldnoteUserProfile> completeVolunteerProfile(
    Session session,
    String displayName,
    String city,
    List<String> interests,
    List<String> skills,
    bool isAvailable,
    bool availableToday,
    List<int> weekdays,
    int startMinutes,
    int endMinutes,
    double maximumTravelKm,
    double? latitude,
    double? longitude,
    String locationLabel, {
    String? timezone,
    int? utcOffsetMinutes,
  }) async {
    _validateAvailability(
      weekdays: weekdays,
      startMinutes: startMinutes,
      endMinutes: endMinutes,
      maximumTravelKm: maximumTravelKm,
      latitude: latitude,
      longitude: longitude,
      locationLabel: locationLabel,
    );
    final profile = await _upsertProfile(
      session,
      role: AccountRole.volunteer,
      displayName: displayName,
      city: city,
      interests: interests,
      skills: skills,
    );
    await _upsertAvailability(
      session,
      isAvailable: isAvailable,
      availableToday: availableToday,
      weekdays: weekdays,
      startMinutes: startMinutes,
      endMinutes: endMinutes,
      maximumTravelKm: maximumTravelKm,
      latitude: latitude,
      longitude: longitude,
      locationLabel: locationLabel,
      timezone: timezone,
      utcOffsetMinutes: utcOffsetMinutes,
    );
    return profile;
  }

  /// Updates the editable account details while preserving the role and legal
  /// consent selected during account creation.
  Future<FieldnoteUserProfile> updateMyProfile(
    Session session,
    String displayName,
    String? sponsorType,
    String? organizationName,
    String city,
    String? cityPlaceId,
    List<String> interests,
    List<String> skills, {
    double? locationLatitude,
    double? locationLongitude,
    String? contactPhone,
  }) async {
    final current = await _requireProfile(session);
    await _requireRole(session, current.role);
    final submittedPhone = contactPhone ?? current.contactPhone;
    final phone = current.role == AccountRole.sponsor
        ? _validatedContactPhone(submittedPhone)
        : _validatedOptionalContactPhone(submittedPhone);
    final verifiedLocation = current.role == AccountRole.sponsor
        ? await _verifiedSponsorLocation(
            session,
            typedLocation: city,
            placeId: cityPlaceId,
            latitude: locationLatitude,
            longitude: locationLongitude,
            current: current,
          )
        : null;
    return _upsertProfile(
      session,
      role: current.role,
      displayName: displayName,
      sponsorType: current.role == AccountRole.sponsor ? sponsorType : null,
      organizationName: current.role == AccountRole.sponsor
          ? organizationName
          : null,
      contactPhone: phone,
      city: verifiedLocation?.name ?? city,
      locationAddress: verifiedLocation?.address,
      locationPlaceId: verifiedLocation?.placeId,
      locationLatitude: verifiedLocation?.latitude,
      locationLongitude: verifiedLocation?.longitude,
      interests: interests,
      skills: current.role == AccountRole.volunteer ? skills : const [],
    );
  }

  /// The saved availability. `availableToday` reads false once the local
  /// date it was set for has passed.
  Future<VolunteerAvailability?> getMyAvailability(Session session) async {
    final profile = await _requireProfile(session);
    if (profile.role != AccountRole.volunteer) return null;
    final availability = await VolunteerAvailability.db.findFirstRow(
      session,
      where: (t) => t.volunteerAuthUserId.equals(_userId(session)),
    );
    if (availability == null) return null;
    return availability.copyWith(
      availableToday: FieldnoteTime.availableTodayActive(availability),
    );
  }

  Future<VolunteerAvailability> updateAvailability(
    Session session,
    bool isAvailable,
    bool availableToday,
    List<int> weekdays,
    int startMinutes,
    int endMinutes,
    double maximumTravelKm,
    double? latitude,
    double? longitude,
    String locationLabel, {
    String? timezone,
    int? utcOffsetMinutes,
  }) async {
    await _requireRole(session, AccountRole.volunteer);
    _validateAvailability(
      weekdays: weekdays,
      startMinutes: startMinutes,
      endMinutes: endMinutes,
      maximumTravelKm: maximumTravelKm,
      latitude: latitude,
      longitude: longitude,
      locationLabel: locationLabel,
    );
    return _upsertAvailability(
      session,
      isAvailable: isAvailable,
      availableToday: availableToday,
      weekdays: weekdays,
      startMinutes: startMinutes,
      endMinutes: endMinutes,
      maximumTravelKm: maximumTravelKm,
      latitude: latitude,
      longitude: longitude,
      locationLabel: locationLabel,
      timezone: timezone,
      utcOffsetMinutes: utcOffsetMinutes,
    );
  }

  /// V3: availability bounds shared by onboarding and later edits.
  static void _validateAvailability({
    required List<int> weekdays,
    required int startMinutes,
    required int endMinutes,
    required double maximumTravelKm,
    required double? latitude,
    required double? longitude,
    required String locationLabel,
  }) {
    if (weekdays.isEmpty ||
        weekdays.length > 7 ||
        weekdays.any((day) => day < 1 || day > 7)) {
      throw FieldnoteException(
        message: 'Choose at least one day of the week.',
        code: 'invalid_availability',
      );
    }
    if (startMinutes < 0 || endMinutes > 1440 || endMinutes <= startMinutes) {
      throw FieldnoteException(
        message: 'Availability end time must be after the start time.',
        code: 'invalid_availability',
      );
    }
    if (!maximumTravelKm.isFinite ||
        maximumTravelKm < 1 ||
        maximumTravelKm > 100) {
      throw FieldnoteException(
        message: 'Choose a travel radius between 1 and 100 km.',
        code: 'invalid_availability',
      );
    }
    if ((latitude == null) != (longitude == null)) {
      throw FieldnoteException(
        message: 'Share a complete location or none.',
        code: 'invalid_coordinates',
      );
    }
    if (latitude != null) _requireValidCoordinates(latitude, longitude!);
    _maxLength(locationLabel, _shortTextMax, 'area label');
  }

  /// Transcribes a held-to-talk recording. The audio never leaves the server
  /// except to the configured provider, and the transcript is returned for the
  /// sponsor to review before anything is generated or published.
  Future<String> transcribeDictation(
    Session session,
    ByteData audio,
    String fileName,
    String mimeType,
  ) async {
    await _requireProfile(session);
    if (audio.lengthInBytes < 1600) {
      throw FieldnoteException(
        message:
            'Hold the microphone button while speaking for at least one second.',
        code: 'recording_too_short',
      );
    }
    if (audio.lengthInBytes > 4 * 1024 * 1024) {
      throw FieldnoteException(
        message: 'Keep the recording under 90 seconds.',
        code: 'recording_too_large',
      );
    }
    final safeName = fileName.trim();
    if (safeName.isEmpty || safeName.length > 120) {
      throw FieldnoteException(
        message: 'The recording file name is invalid.',
        code: 'invalid_audio_file',
      );
    }
    final safeMime = mimeType.trim().toLowerCase();
    if (!safeMime.startsWith('audio/')) {
      throw FieldnoteException(
        message: 'Only audio recordings can be transcribed.',
        code: 'invalid_audio_file',
      );
    }
    final apiKey = session.passwords['geminiApiKey']?.trim();
    final groqKey = session.passwords['groqApiKey']?.trim();
    if ((apiKey == null || apiKey.isEmpty) &&
        (groqKey == null || groqKey.isEmpty)) {
      throw FieldnoteException(
        message: 'Speech transcription is unavailable. Type the brief instead.',
        code: 'transcription_not_configured',
      );
    }
    await _limiter.hit(
      session,
      _userId(session),
      RateLimits.transcribeDictation,
    );
    try {
      return await AiProviderRouter.run<String>(
        primary: _aiPrimaryProvider(session),
        gemini: apiKey == null || apiKey.isEmpty
            ? null
            : () async {
                final transcript = await _speech.transcribe(
                  apiKey: apiKey,
                  model: _transcriptionModel(session),
                  audio: audio,
                  fileName: safeName,
                  mimeType: safeMime,
                );
                session.log('Dictation transcribed with Gemini.');
                return transcript;
              },
        groq: groqKey == null || groqKey.isEmpty
            ? null
            : () async {
                final transcript = await _groq.transcribe(
                  apiKey: groqKey,
                  audio: audio,
                  fileName: safeName,
                );
                session.log('Dictation transcribed with Groq.');
                return transcript;
              },
        onFallback: (from, to) => session.log(
          '${from.name} transcription quota exhausted; trying ${to.name}.',
        ),
      );
    } on SpeechTranscriptionException catch (error, stackTrace) {
      session.log(
        'Dictation transcription failed.',
        level: LogLevel.warning,
        exception: error,
        stackTrace: stackTrace,
      );
      throw FieldnoteException(
        message:
            'Speech transcription is temporarily unavailable. Type the brief instead.',
        code: 'transcription_failed',
      );
    } on GroqAiException catch (error, stackTrace) {
      session.log(
        'Groq transcription failed.',
        level: LogLevel.warning,
        exception: error,
        stackTrace: stackTrace,
      );
      throw FieldnoteException(
        message:
            'Speech transcription is temporarily unavailable. Type the brief instead.',
        code: 'transcription_failed',
      );
    }
  }

  /// Drafts a campaign from a brief. Relative dates such as "this Saturday
  /// 8am" resolve in the sponsor's time zone: the IANA [timezone]
  /// (`Asia/Kolkata`, DST-aware) when given and known, else
  /// [utcOffsetMinutes] (`DateTime.now().timeZoneOffset.inMinutes`), else IST.
  Future<CampaignProposal> proposeCampaign(
    Session session,
    String prompt, {
    int? utcOffsetMinutes,
    String? timezone,
  }) async {
    final sponsor = await _requireRole(session, AccountRole.sponsor);
    if (prompt.trim().length < 20) {
      throw FieldnoteException(
        message: 'Describe the cause, place, timing, and intended impact.',
        code: 'prompt_too_short',
      );
    }
    _maxLength(prompt, _promptMax, 'brief');
    final zone = FieldnoteTime.validatedZoneName(timezone);
    final now = DateTime.now();
    final offset = zone != null
        ? FieldnoteTime.offsetAt(now, zone: zone)
        : FieldnoteTime.validatedOffset(utcOffsetMinutes);
    await _moderateOrThrow(session, prompt, 'campaignPrompt');
    final apiKey = session.passwords['geminiApiKey']?.trim();
    final groqKey = session.passwords['groqApiKey']?.trim();
    if ((apiKey == null || apiKey.isEmpty) &&
        (groqKey == null || groqKey.isEmpty)) {
      throw FieldnoteException(
        message:
            'AI campaign generation is unavailable. Create the campaign manually.',
        code: 'ai_not_configured',
      );
    }
    await _limiter.hit(session, sponsor.authUserId, RateLimits.proposeCampaign);
    CampaignProposal finish(CampaignProposal proposal) {
      proposal.fundingGoalPaise = Money.toPaise(proposal.fundingGoal);
      if (zone != null) {
        proposal.startsAt = FieldnoteTime.reresolveInZone(
          proposal.startsAt,
          offsetUsed: offset,
          zone: zone,
        );
      }
      return proposal;
    }

    try {
      return finish(
        await AiProviderRouter.run<CampaignProposal>(
          primary: _aiPrimaryProvider(session),
          gemini: apiKey == null || apiKey.isEmpty
              ? null
              : () async {
                  final proposal = await _gemini.proposeCampaign(
                    apiKey: apiKey,
                    model: _geminiModel(session),
                    prompt: prompt.trim(),
                    now: now,
                    utcOffsetMinutes: offset,
                  );
                  session.log('Gemini campaign generation succeeded.');
                  return proposal;
                },
          groq: groqKey == null || groqKey.isEmpty
              ? null
              : () async {
                  final proposal = await _groq.proposeCampaign(
                    apiKey: groqKey,
                    prompt: prompt.trim(),
                    now: now,
                    utcOffsetMinutes: offset,
                  );
                  session.log('Groq campaign generation succeeded.');
                  return proposal;
                },
          onFallback: (from, to) => session.log(
            '${from.name} campaign quota exhausted; trying ${to.name}.',
          ),
        ),
      );
    } on GeminiAiException catch (error, stackTrace) {
      session.log(
        'Gemini campaign generation failed.',
        level: LogLevel.warning,
        exception: error,
        stackTrace: stackTrace,
      );
      throw FieldnoteException(
        message:
            'AI campaign generation is temporarily unavailable. Create the campaign manually or try again later.',
        code: 'gemini_unavailable',
      );
    } on GroqAiException catch (error, stackTrace) {
      session.log(
        'Groq campaign generation failed.',
        level: LogLevel.warning,
        exception: error,
        stackTrace: stackTrace,
      );
      throw FieldnoteException(
        message:
            'AI campaign generation is temporarily unavailable. Create the campaign manually.',
        code: 'ai_unavailable',
      );
    }
  }

  /// Publishes a proposal at a map pin.
  ///
  /// [locationName] and [geofenceMeters] come from the sponsor's map: the pin
  /// can be dragged anywhere and named from Places, so the published campaign
  /// is no longer tied to where the sponsor's own device happened to be.
  ///
  /// The goal is `proposal.fundingGoalPaise` when sent, else the rupee
  /// `proposal.fundingGoal`. [clientRequestId] makes publishing idempotent:
  /// a retry with the same id (per creator) returns the campaign created by
  /// the first call instead of a duplicate.
  Future<Campaign> createCampaignFromProposal(
    Session session,
    CampaignProposal proposal,
    double latitude,
    double longitude,
    String? locationName,
    double? geofenceMeters, {
    String? clientRequestId,
  }) async {
    final sponsor = await _requireRole(session, AccountRole.sponsor);
    final requestId = _validatedClientRequestId(clientRequestId);
    if (requestId != null) {
      final existing = await _campaignForRequest(
        session,
        sponsor.authUserId,
        requestId,
        proposal,
      );
      if (existing != null) return existing;
    }
    _validatedContactPhone(sponsor.contactPhone);
    CampaignValidation.proposal(proposal);
    final goalPaise = CampaignValidation.proposalGoalPaise(proposal);
    await _moderateOrThrow(
      session,
      '${proposal.title}\n${proposal.description}\n${proposal.checklist.join('\n')}',
      'campaignProposal',
    );
    _requireValidCoordinates(latitude, longitude);
    final pinName = _blankToNull(locationName) ?? proposal.locationName.trim();
    await _moderateOrThrow(session, pinName, 'campaignLocationName');
    final organization = await _platformOrganization(session);
    final start = proposal.startsAt.toUtc();
    final minimum =
        proposal.minimumVolunteers ??
        math.max(1, (proposal.volunteerCapacity / 2).ceil());
    if (!start.isAfter(DateTime.now().toUtc()) ||
        proposal.volunteerCapacity < 1 ||
        minimum < 1 ||
        minimum > proposal.volunteerCapacity) {
      throw FieldnoteException(
        message:
            'Choose a future date and a safe minimum team within the available places.',
        code: 'invalid_campaign_plan',
      );
    }
    final Campaign campaign;
    try {
      campaign = await Campaign.db.insertRow(
        session,
        Campaign(
          organizationId: organization.id!,
          name: proposal.title.trim(),
          description: proposal.description.trim(),
          locationName: pinName,
          startsAt: start,
          endsAt: start.add(Duration(minutes: proposal.durationMinutes)),
          status: CampaignStatus.active,
          createdBy: sponsor.authUserId,
          fundingGoal: Money.fromPaise(goalPaise),
          fundingGoalPaise: goalPaise,
          sponsoredAmount: 0,
          sponsoredAmountPaise: 0,
          latitude: latitude,
          longitude: longitude,
          geofenceMeters: (geofenceMeters ?? 200).clamp(50, 2000).toDouble(),
          volunteerCapacity: proposal.volunteerCapacity,
          minimumVolunteers: minimum,
          eligibleVolunteers: 0,
          readinessState: 'open',
          requiredSkills: proposal.requiredSkills.join(' | '),
          checklist: proposal.checklist.join(' | '),
          evidenceInstructions: proposal.evidenceInstructions,
          tags: proposal.tags.join(' | '),
          aiGenerated: !proposal.rationale.startsWith(
            'Entered manually by the sponsor.',
          ),
          publishedAt: DateTime.now().toUtc(),
          shareSlug: newShareSlug(),
          clientRequestId: requestId,
        ),
      );
    } on DatabaseException {
      // A concurrent retry with the same clientRequestId won the insert.
      final existing = requestId == null
          ? null
          : await _campaignForRequest(
              session,
              sponsor.authUserId,
              requestId,
              proposal,
            );
      if (existing == null) rethrow;
      return existing;
    }
    await _publish(
      session,
      campaign.id!,
      'campaignPublished',
      '${campaign.name} was published.',
    );
    return campaign;
  }

  /// Accepts UUIDs and similar opaque client keys.
  static String? _validatedClientRequestId(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    if (!RegExp(r'^[A-Za-z0-9_.:\-]{8,64}$').hasMatch(trimmed)) {
      throw FieldnoteException(
        message: 'The request id is invalid.',
        code: 'invalid_client_request_id',
      );
    }
    return trimmed;
  }

  /// The campaign an earlier publish with [requestId] created. A reused id
  /// for a different plan is rejected rather than silently ignored.
  Future<Campaign?> _campaignForRequest(
    Session session,
    UuidValue creator,
    String requestId,
    CampaignProposal proposal,
  ) async {
    final existing = await Campaign.db.findFirstRow(
      session,
      where: (t) =>
          t.createdBy.equals(creator) & t.clientRequestId.equals(requestId),
    );
    if (existing != null && existing.name != proposal.title.trim()) {
      throw FieldnoteException(
        message: 'This request id was already used for a different campaign.',
        code: 'client_request_id_reused',
      );
    }
    return existing;
  }

  /// Open campaigns (active, not cancelled or expired, not started), soonest
  /// first. Without [limit] up to [_openCampaignScanLimit] are returned.
  Future<List<Campaign>> listCampaigns(
    Session session, {
    int? limit,
    int? offset,
  }) async {
    await _requireProfile(session);
    return _openCampaigns(
      session,
      limit: limit == null ? _openCampaignScanLimit : _page(limit, 0).limit,
      offset: math.max(0, offset ?? 0),
    );
  }

  static const _openCampaignScanLimit = 500;

  Future<List<Campaign>> _openCampaigns(
    Session session, {
    int limit = _openCampaignScanLimit,
    int offset = 0,
  }) {
    final now = DateTime.now().toUtc();
    return Campaign.db.find(
      session,
      where: (t) =>
          t.status.equals(CampaignStatus.active) &
          t.readinessState.notInSet({'cancelled', 'expired'}) &
          (t.startsAt > now),
      orderBy: (t) => t.startsAt,
      limit: limit,
      offset: offset,
    );
  }

  static final _slugRandom = math.Random.secure();

  /// R-3: 22 base62 characters (about 131 bits).
  static String newShareSlug() {
    const alphabet =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(
      22,
      (_) => alphabet[_slugRandom.nextInt(alphabet.length)],
    ).join();
  }

  static bool _isPubliclyOpen(Campaign campaign) =>
      campaign.status == CampaignStatus.active &&
      !const {'cancelled', 'expired'}.contains(campaign.readinessState) &&
      DateTime.now().toUtc().isBefore(campaign.startsAt);

  /// Resolves a `/c/<slug>` share link after sign-in. Null when the slug is
  /// unknown or the campaign is no longer open, unless the caller already
  /// holds a place in it.
  Future<Campaign?> getSharedCampaignBySlug(
    Session session,
    String shareSlug,
  ) async {
    final profile = await _requireProfile(session);
    final slug = shareSlug.trim();
    if (!RegExp(r'^[A-Za-z0-9]{16,64}$').hasMatch(slug)) return null;
    final campaign = await Campaign.db.findFirstRow(
      session,
      where: (t) => t.shareSlug.equals(slug),
    );
    if (campaign == null) return null;
    if (_isPubliclyOpen(campaign)) return campaign;
    final held = await CampaignParticipation.db.findFirstRow(
      session,
      where: (t) =>
          t.campaignId.equals(campaign.id!) &
          t.volunteerAuthUserId.equals(profile.authUserId) &
          t.status.notEquals(ParticipationStatus.left),
    );
    return held == null ? null : campaign;
  }

  /// The public `https://<link-host>/c/<slug>` link for an open campaign.
  Future<String> getCampaignShareLink(Session session, int campaignId) async {
    final profile = await _requireProfile(session);
    await _limiter.hit(session, profile.authUserId, RateLimits.shareAndInvite);
    var campaign = await _campaign(session, campaignId);
    if (!_isPubliclyOpen(campaign)) {
      throw FieldnoteException(
        message: 'Only open campaigns can be shared.',
        code: 'campaign_unavailable',
      );
    }
    if (campaign.shareSlug == null) {
      campaign = await Campaign.db.updateRow(
        session,
        campaign.copyWith(shareSlug: newShareSlug()),
      );
    }
    return '${FieldnoteConfig.publicWebBaseUrl(session.serverpod)}/c/${campaign.shareSlug}';
  }

  /// Resolves a shared campaign after sign-in. The volunteer still joins via
  /// the normal capacity and readiness checks in [joinCampaign].
  Future<Campaign?> getSharedCampaign(Session session, int campaignId) async {
    await _requireProfile(session);
    if (campaignId < 1) return null;
    final campaign = await Campaign.db.findById(session, campaignId);
    if (campaign == null ||
        campaign.status != CampaignStatus.active ||
        const {'cancelled', 'expired'}.contains(campaign.readinessState) ||
        !DateTime.now().toUtc().isBefore(campaign.startsAt)) {
      return null;
    }
    return campaign;
  }

  Future<List<Campaign>> listMyCreatedCampaigns(
    Session session, {
    int? limit,
    int? offset,
  }) async {
    final profile = await _requireRole(session, AccountRole.sponsor);
    final page = _page(limit, offset, defaultLimit: 100);
    return Campaign.db.find(
      session,
      where: (t) => t.createdBy.equals(profile.authUserId),
      orderBy: (t) => t.createdAt.desc(),
      limit: page.limit,
      offset: page.offset,
    );
  }

  /// Re-evaluates readiness. Only the creator, verified funders and
  /// volunteers holding a place may trigger it.
  Future<Campaign> refreshCampaignReadiness(
    Session session,
    int campaignId,
  ) async {
    final profile = await _requireProfile(session);
    final campaign = await _campaign(session, campaignId);
    if (!await _isCampaignMember(session, profile, campaign)) {
      throw FieldnoteException(
        message: 'Only the campaign team can refresh its readiness.',
        code: 'forbidden',
      );
    }
    return _refreshCampaignReadiness(session, campaignId);
  }

  /// Creator, verified funder, or a volunteer who joined and did not leave.
  Future<bool> _isCampaignMember(
    Session session,
    FieldnoteUserProfile profile,
    Campaign campaign,
  ) async {
    if (campaign.createdBy == profile.authUserId) return true;
    if (profile.role == AccountRole.sponsor) {
      return await Sponsorship.db.count(
            session,
            where: (t) =>
                t.campaignId.equals(campaign.id!) &
                t.sponsorAuthUserId.equals(profile.authUserId) &
                t.paymentStatus.equals('verified'),
          ) >
          0;
    }
    return await CampaignParticipation.db.count(
          session,
          where: (t) =>
              t.campaignId.equals(campaign.id!) &
              t.volunteerAuthUserId.equals(profile.authUserId) &
              t.status.notEquals(ParticipationStatus.left),
        ) >
        0;
  }

  Future<Campaign> reviseCampaignScope(
    Session session,
    int campaignId,
    double fundingGoal,
    int minimumVolunteers,
    String description, {
    int? fundingGoalPaise,
  }) async {
    final sponsor = await _requireRole(session, AccountRole.sponsor);
    final note = description.trim();
    final goalPaise = CampaignValidation.fundingGoalPaise(
      Money.fromInput(paise: fundingGoalPaise, rupees: fundingGoal),
    );
    CampaignValidation.scopeNote(note);
    await _moderateOrThrow(session, note, 'campaignScope');
    final updated = await session.db.transaction((transaction) async {
      final campaign = await Campaign.db.findById(
        session,
        campaignId,
        transaction: transaction,
        lockMode: LockMode.forUpdate,
      );
      if (campaign == null ||
          campaign.createdBy != sponsor.authUserId ||
          campaign.readinessState == 'cancelled' ||
          campaign.readinessState == 'expired' ||
          campaign.status != CampaignStatus.active) {
        throw FieldnoteException(
          message: 'This campaign cannot be revised.',
          code: 'campaign_unavailable',
        );
      }
      await _requireNotStarted(session, campaign, transaction, 'revised');
      if (minimumVolunteers < 1 ||
          minimumVolunteers > campaign.volunteerCapacity ||
          goalPaise < campaign.sponsoredAmountPaise) {
        throw FieldnoteException(
          message:
              'Minimum team must fit the available places and the new goal cannot be below funds already recorded.',
          code: 'invalid_campaign_plan',
        );
      }
      campaign.setFundingGoalPaise(goalPaise);
      campaign.minimumVolunteers = minimumVolunteers;
      campaign.description = note;
      campaign.revision += 1;
      campaign.eligibleVolunteers = 0;
      campaign.readinessState = 'open';
      campaign.confirmedAt = null;
      campaign.readinessCheckedAt = null;
      campaign.updatedAt = DateTime.now().toUtc();
      return Campaign.db.updateRow(session, campaign, transaction: transaction);
    });
    await _readinessNotice(
      session,
      updated,
      'The organizer revised the work plan. Please review and reconfirm your place.',
    );
    await _notifications.campaignChanged(
      session,
      updated,
      NotificationKind.campaignRevised,
    );
    return _refreshCampaignReadiness(session, campaignId);
  }

  Future<Campaign> postponeCampaign(
    Session session,
    int campaignId,
    DateTime newStartsAt,
  ) async {
    final sponsor = await _requireRole(session, AccountRole.sponsor);
    final start = newStartsAt.toUtc();
    if (!start.isAfter(DateTime.now().toUtc().add(const Duration(hours: 1)))) {
      throw FieldnoteException(
        message: 'Choose a new start time at least one hour ahead.',
        code: 'invalid_campaign_date',
      );
    }
    final updated = await session.db.transaction((transaction) async {
      final campaign = await Campaign.db.findById(
        session,
        campaignId,
        transaction: transaction,
        lockMode: LockMode.forUpdate,
      );
      if (campaign == null ||
          campaign.createdBy != sponsor.authUserId ||
          campaign.readinessState == 'cancelled' ||
          campaign.readinessState == 'expired' ||
          campaign.status != CampaignStatus.active) {
        throw FieldnoteException(
          message: 'This campaign cannot be postponed.',
          code: 'campaign_unavailable',
        );
      }
      await _requireNotStarted(session, campaign, transaction, 'postponed');
      final duration =
          (campaign.endsAt ?? campaign.startsAt.add(const Duration(hours: 2)))
              .difference(campaign.startsAt);
      campaign.startsAt = start;
      campaign.endsAt = start.add(duration);
      campaign.revision += 1;
      campaign.eligibleVolunteers = 0;
      campaign.readinessState = 'postponed';
      campaign.confirmedAt = null;
      campaign.readinessCheckedAt = null;
      campaign.postponedAt = DateTime.now().toUtc();
      campaign.updatedAt = DateTime.now().toUtc();
      return Campaign.db.updateRow(session, campaign, transaction: transaction);
    });
    await _readinessNotice(
      session,
      updated,
      'The event has a new proposed date. Please review and reconfirm your place.',
    );
    await _notifications.campaignChanged(
      session,
      updated,
      NotificationKind.campaignPostponed,
    );
    return updated;
  }

  /// Cancels a campaign before it starts, refunds every credited payment and
  /// releases every volunteer place. Rejected once the event has started or
  /// once any creator payout has been recorded (S-5, S10).
  Future<Campaign> cancelCampaign(Session session, int campaignId) async {
    final sponsor = await _requireRole(session, AccountRole.sponsor);
    final result = await session.db.transaction((transaction) async {
      final campaign = await Campaign.db.findById(
        session,
        campaignId,
        transaction: transaction,
        lockMode: LockMode.forUpdate,
      );
      if (campaign == null ||
          campaign.createdBy != sponsor.authUserId ||
          campaign.status != CampaignStatus.active) {
        throw FieldnoteException(
          message: 'Only the creator can cancel this campaign.',
          code: 'creator_required',
        );
      }
      if (campaign.readinessState == 'cancelled') {
        return (campaign: campaign, changed: false);
      }
      if (campaign.readinessState == 'expired') {
        throw FieldnoteException(
          message:
              'This campaign already expired and its sponsors are being refunded.',
          code: 'campaign_expired',
        );
      }
      if (!DateTime.now().toUtc().isBefore(campaign.startsAt)) {
        throw FieldnoteException(
          message:
              'This campaign has already started and can no longer be cancelled.',
          code: 'campaign_started',
        );
      }
      final payouts = await TestPayout.db.count(
        session,
        where: (t) => t.campaignId.equals(campaignId),
        transaction: transaction,
      );
      if (payouts > 0) {
        throw FieldnoteException(
          message:
              'A creator payout was already recorded, so this campaign cannot be cancelled.',
          code: 'payouts_exist',
        );
      }
      campaign.readinessState = 'cancelled';
      campaign.cancelledAt = DateTime.now().toUtc();
      campaign.updatedAt = DateTime.now().toUtc();
      await _refunds.queueForCampaign(
        session,
        campaignId: campaignId,
        reason: RefundReason.campaignCancelled,
        transaction: transaction,
      );
      await _lifecycle.cancelParticipations(
        session,
        campaignId,
        transaction: transaction,
      );
      final updated = await Campaign.db.updateRow(
        session,
        campaign,
        transaction: transaction,
      );
      return (campaign: updated, changed: true);
    });
    if (result.changed) {
      await _readinessNotice(
        session,
        result.campaign,
        'The organizer cancelled this event. Do not travel to the work site.',
      );
      await _notifications.campaignChanged(
        session,
        result.campaign,
        NotificationKind.campaignCancelled,
      );
      await _audit(
        session,
        event: 'campaignCancelled',
        entityType: 'campaign',
        entityId: '$campaignId',
        outcome: 'cancelled',
        riskLevel: 'info',
        detail: 'Cancelled before start; refunds were queued for sponsors.',
      );
    }
    return result.campaign;
  }

  /// S11: schedule and scope changes are frozen once the event starts or a
  /// volunteer has checked in.
  Future<void> _requireNotStarted(
    Session session,
    Campaign campaign,
    Transaction transaction,
    String action,
  ) async {
    final checkedIn = await CampaignParticipation.db.count(
      session,
      where: (t) =>
          t.campaignId.equals(campaign.id!) & t.checkedInAt.notEquals(null),
      transaction: transaction,
    );
    if (!DateTime.now().toUtc().isBefore(campaign.startsAt) || checkedIn > 0) {
      throw FieldnoteException(
        message:
            'This campaign has started or volunteers have checked in, so it cannot be $action.',
        code: 'campaign_started',
      );
    }
  }

  Future<CampaignParticipation> reconfirmCampaignParticipation(
    Session session,
    int participationId,
  ) async {
    final participation = await _ownedParticipation(session, participationId);
    final campaign = await _campaign(session, participation.campaignId);
    if (campaign.readinessState == 'cancelled' ||
        campaign.readinessState == 'expired' ||
        participation.status != ParticipationStatus.joined) {
      throw FieldnoteException(
        message: 'This place cannot be reconfirmed.',
        code: 'campaign_unavailable',
      );
    }
    if (participation.confirmedRevision == campaign.revision) {
      return participation;
    }
    participation.confirmedRevision = campaign.revision;
    final updated = await CampaignParticipation.db.updateRow(
      session,
      participation,
    );
    await _refreshCampaignReadiness(session, campaign.id!);
    return updated;
  }

  Future<List<Campaign>> listMyJoinedCampaigns(
    Session session, {
    int? limit,
    int? offset,
  }) async {
    final volunteer = await _requireRole(session, AccountRole.volunteer);
    final page = _page(limit, offset, defaultLimit: 100);
    final joins = await CampaignParticipation.db.find(
      session,
      where: (t) => t.volunteerAuthUserId.equals(volunteer.authUserId),
      orderBy: (t) => t.joinedAt.desc(),
      limit: page.limit,
      offset: page.offset,
    );
    final ids = joins.map((join) => join.campaignId).toSet();
    if (ids.isEmpty) return const [];
    final campaigns = await Campaign.db.find(
      session,
      where: (t) => t.id.inSet(ids),
    );
    final byId = {for (final campaign in campaigns) campaign.id!: campaign};
    return [
      for (final join in joins)
        if (byId[join.campaignId] != null) byId[join.campaignId]!,
    ];
  }

  Future<Campaign> _refreshCampaignReadiness(
    Session session,
    int campaignId,
  ) => _lifecycle.refreshReadiness(session, campaignId);

  Future<void> _readinessNotice(
    Session session,
    Campaign campaign,
    String message,
  ) => _events.readinessNotice(session, campaign, message);

  // ---------------------------------------------------------------------------

  /// Whether Google Places autocomplete is available during account setup.
  /// This deliberately requires authentication but not an existing profile,
  /// because it is called before onboarding creates the profile row.
  Future<bool> isCitySearchAvailable(Session session) async {
    _userId(session);
    return _mapsKey(session) != null;
  }

  /// City-only Google Places autocomplete retained for volunteer profiles.
  Future<List<PlaceSuggestion>> searchCities(
    Session session,
    String query,
  ) async {
    _userId(session);
    final trimmed = query.trim();
    if (trimmed.length < 2) return const [];
    if (trimmed.length > 100) {
      throw FieldnoteException(
        message: 'Shorten the city search.',
        code: 'invalid_city_query',
      );
    }
    final apiKey = _mapsKey(session);
    if (apiKey == null) return const [];
    await _limiter.hit(session, _userId(session), RateLimits.maps);
    try {
      return await _maps.autocomplete(
        apiKey: apiKey,
        query: trimmed,
        citiesOnly: true,
      );
    } on GoogleMapsException catch (error, stackTrace) {
      session.log(
        'City autocomplete failed.',
        level: LogLevel.warning,
        exception: error,
        stackTrace: stackTrace,
      );
      return const [];
    }
  }

  /// Full Google Places autocomplete for sponsor account setup. Unlike the
  /// campaign search endpoint, this works before the profile row exists.
  Future<List<PlaceSuggestion>> searchSponsorLocations(
    Session session,
    String query,
  ) async {
    _userId(session);
    final trimmed = query.trim();
    if (trimmed.length < 2) return const [];
    if (trimmed.length > 200) {
      throw FieldnoteException(
        message: 'Shorten the location search.',
        code: 'invalid_location_query',
      );
    }
    final apiKey = _mapsKey(session);
    if (apiKey == null) return const [];
    await _limiter.hit(session, _userId(session), RateLimits.maps);
    try {
      return await _maps.autocomplete(apiKey: apiKey, query: trimmed);
    } on GoogleMapsException catch (error, stackTrace) {
      session.log(
        'Sponsor location autocomplete failed.',
        level: LogLevel.warning,
        exception: error,
        stackTrace: stackTrace,
      );
      return const [];
    }
  }

  // Google Maps Platform
  //
  // Places, Geocoding and Routes are billed per call and are reached with the
  // `googleMapsApiKey` Serverpod password. The key never leaves the server; the
  // Flutter app renders tiles with its own separately restricted client key.
  // Every one of these degrades to the app's original offline behaviour when
  // the key is absent or the provider is unreachable.
  // ---------------------------------------------------------------------------

  /// Whether server-side Places, Geocoding and Routes calls are available.
  /// The client uses this to hide search affordances it cannot fulfil.
  Future<bool> isPlaceSearchAvailable(Session session) async {
    await _requireProfile(session);
    return _mapsKey(session) != null;
  }

  /// Google Places autocomplete for naming a campaign pin.
  Future<List<PlaceSuggestion>> searchPlaces(
    Session session,
    String query,
    double? biasLatitude,
    double? biasLongitude,
  ) async {
    await _requireProfile(session);
    final trimmed = query.trim();
    if (trimmed.length < 3) return const [];
    if (trimmed.length > 200) {
      throw FieldnoteException(
        message: 'Shorten the place search.',
        code: 'invalid_place_query',
      );
    }
    final apiKey = _mapsKey(session);
    if (apiKey == null) return const [];
    await _limiter.hit(session, _userId(session), RateLimits.maps);
    try {
      return await _maps.autocomplete(
        apiKey: apiKey,
        query: trimmed,
        biasLatitude: biasLatitude,
        biasLongitude: biasLongitude,
      );
    } on GoogleMapsException catch (error, stackTrace) {
      session.log(
        'Places autocomplete failed.',
        level: LogLevel.warning,
        exception: error,
        stackTrace: stackTrace,
      );
      return const [];
    }
  }

  /// Turns a Places autocomplete selection into a campaign pin.
  Future<ResolvedPlace> resolvePlace(Session session, String placeId) async {
    await _requireProfile(session);
    final trimmed = placeId.trim();
    if (trimmed.isEmpty || trimmed.length > 300) {
      throw FieldnoteException(
        message: 'That place could not be resolved.',
        code: 'invalid_place_id',
      );
    }
    final apiKey = _mapsKey(session);
    if (apiKey == null) {
      throw FieldnoteException(
        message:
            'Place search is not available. Drag the pin on the map instead.',
        code: 'maps_not_configured',
      );
    }
    await _limiter.hit(session, _userId(session), RateLimits.maps);
    try {
      final place = await _maps.placeDetails(apiKey: apiKey, placeId: trimmed);
      _requireValidCoordinates(place.latitude, place.longitude);
      return place;
    } on GoogleMapsException catch (error, stackTrace) {
      session.log(
        'Place details lookup failed.',
        level: LogLevel.warning,
        exception: error,
        stackTrace: stackTrace,
      );
      throw FieldnoteException(
        message: 'Google could not resolve that place. Drag the pin instead.',
        code: 'maps_unavailable',
      );
    }
  }

  /// Names a dragged map pin. Returns null rather than throwing so the map
  /// keeps working with a typed label when geocoding is off or offline.
  Future<ResolvedPlace?> describeCoordinates(
    Session session,
    double latitude,
    double longitude,
  ) async {
    _userId(session);
    _requireValidCoordinates(latitude, longitude);
    final apiKey = _mapsKey(session);
    if (apiKey == null) return null;
    await _limiter.hit(session, _userId(session), RateLimits.maps);
    try {
      return await _maps.reverseGeocode(
        apiKey: apiKey,
        latitude: latitude,
        longitude: longitude,
      );
    } on GoogleMapsException catch (error, stackTrace) {
      session.log(
        'Reverse geocoding failed.',
        level: LogLevel.info,
        exception: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Route a volunteer from their current device position to a campaign.
  /// The saved availability area is only for matching and is never the
  /// origin of an active journey.
  Future<TravelRoute> getTravelRoute(
    Session session,
    int campaignId,
    double originLatitude,
    double originLongitude,
    String travelMode,
  ) async {
    final volunteer = await _requireRole(session, AccountRole.volunteer);
    _requireValidCoordinates(originLatitude, originLongitude);
    if (!const {
      'WALK',
      'DRIVE',
      'BICYCLE',
      'TWO_WHEELER',
    }.contains(travelMode)) {
      throw FieldnoteException(
        message: 'Choose a supported travel mode.',
        code: 'invalid_travel_mode',
      );
    }
    final campaign = await _refreshCampaignReadiness(session, campaignId);
    if (const {'cancelled', 'expired'}.contains(campaign.readinessState)) {
      throw FieldnoteException(
        message: 'This campaign is not available for travel.',
        code: 'campaign_unavailable',
      );
    }
    if (campaign.status != CampaignStatus.active) {
      final joined = await CampaignParticipation.db.findFirstRow(
        session,
        where: (t) =>
            t.campaignId.equals(campaignId) &
            t.volunteerAuthUserId.equals(volunteer.authUserId),
      );
      if (joined == null) {
        throw FieldnoteException(
          message: 'This campaign is not available for travel.',
          code: 'campaign_unavailable',
        );
      }
    }
    final apiKey = _mapsKey(session);
    if (apiKey == null) {
      throw FieldnoteException(
        message: 'In-app routes are not configured yet.',
        code: 'maps_not_configured',
      );
    }
    await _limiter.hit(session, _userId(session), RateLimits.maps);
    try {
      return await _maps.travelRoute(
        apiKey: apiKey,
        originLatitude: originLatitude,
        originLongitude: originLongitude,
        destinationLatitude: campaign.latitude,
        destinationLongitude: campaign.longitude,
        travelMode: travelMode,
      );
    } on GoogleMapsException catch (error, stackTrace) {
      session.log(
        'Travel route lookup failed.',
        level: LogLevel.warning,
        exception: error,
        stackTrace: stackTrace,
      );
      throw FieldnoteException(
        message:
            'A road route is unavailable. You can still view the destination on the map.',
        code: 'route_unavailable',
      );
    }
  }

  /// How many volunteers could actually reach a proposed pin, before the
  /// sponsor commits money to it.
  ///
  /// Individual volunteer coordinates are never returned. Coverage is bucketed
  /// to roughly a kilometre and any bucket holding fewer than
  /// [_reachCellAnonymityThreshold] volunteers is suppressed entirely.
  Future<CampaignReach> previewCampaignReach(
    Session session,
    double latitude,
    double longitude,
  ) async {
    final sponsor = await _requireRole(session, AccountRole.sponsor);
    _requireValidCoordinates(latitude, longitude);
    await _limiter.hit(session, sponsor.authUserId, RateLimits.maps);
    final availabilities = await _availableNear(session, latitude, longitude);
    final availableTotal = await VolunteerAvailability.db.count(
      session,
      where: (t) => t.isAvailable.equals(true),
    );
    final distances = <double>[];
    final cells = <String, _ReachBucket>{};
    for (final availability in availabilities) {
      final volunteerLatitude = availability.latitude;
      final volunteerLongitude = availability.longitude;
      if (volunteerLatitude == null || volunteerLongitude == null) continue;
      final distanceKm =
          _distanceMeters(
            volunteerLatitude,
            volunteerLongitude,
            latitude,
            longitude,
          ) /
          1000;
      if (distanceKm > availability.maximumTravelKm) continue;
      distances.add(distanceKm);
      // Two decimal places is about 1.1 km at the equator.
      final cellLatitude = double.parse(volunteerLatitude.toStringAsFixed(2));
      final cellLongitude = double.parse(volunteerLongitude.toStringAsFixed(2));
      final key = '$cellLatitude,$cellLongitude';
      final bucket = cells[key] ??= _ReachBucket(cellLatitude, cellLongitude);
      bucket.count++;
    }
    distances.sort();
    final coverage = [
      for (final bucket in cells.values)
        if (bucket.count >= _reachCellAnonymityThreshold)
          ReachCell(
            latitude: bucket.latitude,
            longitude: bucket.longitude,
            volunteerCount: bucket.count,
          ),
    ]..sort((a, b) => b.volunteerCount.compareTo(a.volunteerCount));

    return CampaignReach(
      latitude: latitude,
      longitude: longitude,
      volunteersInRange: distances.length,
      availableVolunteers: availableTotal,
      nearestDistanceKm: distances.isEmpty ? null : distances.first,
      medianDistanceKm: distances.isEmpty
          ? null
          : distances[distances.length ~/ 2],
      coverageCells: coverage,
      summary: switch (distances.length) {
        0 =>
          'No available volunteer has this pin inside their travel radius yet. '
              'Consider moving the pin closer to a populated area.',
        1 =>
          '1 available volunteer has this pin inside their travel radius, '
              '${distances.first.toStringAsFixed(1)} km away.',
        _ =>
          '${distances.length} of $availableTotal available volunteers '
              'have this pin inside their travel radius. Nearest is '
              '${distances.first.toStringAsFixed(1)} km away.',
      },
    );
  }

  /// Shows coarse groups of available, unjoined volunteers who can travel to
  /// this published campaign. Only its creator may inspect the map. Small
  /// groups and individual distances are never returned.
  Future<CampaignReach> getCampaignVolunteerReach(
    Session session,
    int campaignId,
  ) async {
    final sponsor = await _requireRole(session, AccountRole.sponsor);
    final campaign = await _campaign(session, campaignId);
    if (campaign.createdBy != sponsor.authUserId) {
      throw FieldnoteException(
        message: 'Only the campaign creator can view volunteer reach.',
        code: 'forbidden',
      );
    }
    final groups = await _eligibleVolunteerReachGroups(session, campaign);
    final coverage = <ReachCell>[
      for (final group in groups.values)
        if (group.volunteers.length >= _reachCellAnonymityThreshold)
          ReachCell(
            latitude: group.latitude,
            longitude: group.longitude,
            volunteerCount: group.volunteers.length,
          ),
    ]..sort((a, b) => b.volunteerCount.compareTo(a.volunteerCount));
    final visibleCount = coverage.fold<int>(
      0,
      (sum, cell) => sum + cell.volunteerCount,
    );
    return CampaignReach(
      latitude: campaign.latitude,
      longitude: campaign.longitude,
      volunteersInRange: visibleCount,
      availableVolunteers: visibleCount,
      nearestDistanceKm: null,
      medianDistanceKm: null,
      coverageCells: coverage,
      summary: coverage.isEmpty
          ? 'No area has three available volunteers who can reach this campaign yet.'
          : '$visibleCount available volunteers in ${coverage.length} nearby areas can reach this campaign.',
    );
  }

  /// Shows the campaign creator every joined volunteer and each currently
  /// eligible volunteer who has published availability. Coordinates are
  /// rounded to an area before leaving the server; exact GPS is never sent.
  Future<CampaignVolunteerMap> getCampaignVolunteerMap(
    Session session,
    int campaignId,
  ) async {
    final sponsor = await _requireRole(session, AccountRole.sponsor);
    final campaign = await _campaign(session, campaignId);
    if (campaign.createdBy != sponsor.authUserId) {
      throw FieldnoteException(
        message: 'Only the campaign creator can view nearby volunteers.',
        code: 'forbidden',
      );
    }
    if (campaign.status == CampaignStatus.draft) {
      throw FieldnoteException(
        message: 'Publish the campaign before viewing nearby volunteers.',
        code: 'campaign_unavailable',
      );
    }
    // A-2: joined volunteers are named; everyone else only appears inside
    // an anonymous area bucket of at least [_reachCellAnonymityThreshold].
    final joined = await CampaignParticipation.db.find(
      session,
      where: (t) =>
          t.campaignId.equals(campaignId) &
          t.status.notEquals(ParticipationStatus.left),
    );
    final joinedIds = joined.map((item) => item.volunteerAuthUserId).toSet();
    final profiles = joinedIds.isEmpty
        ? <FieldnoteUserProfile>[]
        : await FieldnoteUserProfile.db.find(
            session,
            where: (t) => t.authUserId.inSet(joinedIds),
          );
    final joinedAvailability = joinedIds.isEmpty
        ? <VolunteerAvailability>[]
        : await VolunteerAvailability.db.find(
            session,
            where: (t) => t.volunteerAuthUserId.inSet(joinedIds),
          );
    final availabilityByUser = {
      for (final availability in joinedAvailability)
        availability.volunteerAuthUserId: availability,
    };
    final volunteers = <CampaignVolunteerMapMember>[];
    for (final profile in profiles) {
      if (profile.role != AccountRole.volunteer) continue;
      final availability = availabilityByUser[profile.authUserId];
      final shared =
          availability != null &&
          availability.isAvailable &&
          availability.latitude != null &&
          availability.longitude != null;
      volunteers.add(
        CampaignVolunteerMapMember(
          profileId: profile.id!,
          displayName: profile.displayName,
          areaLabel: shared ? 'Approximate area' : 'Area not shared',
          latitude: shared
              ? double.parse(availability.latitude!.toStringAsFixed(2))
              : null,
          longitude: shared
              ? double.parse(availability.longitude!.toStringAsFixed(2))
              : null,
          status: 'joined',
        ),
      );
    }
    volunteers.sort((a, b) => a.displayName.compareTo(b.displayName));

    final areas = <CampaignVolunteerMapMember>[];
    if (_isPubliclyOpen(campaign)) {
      final groups = await _eligibleVolunteerReachGroups(session, campaign);
      final invitations = await CampaignInvitation.db.find(
        session,
        where: (t) => t.campaignId.equals(campaignId),
      );
      final invitedIds = invitations
          .map((item) => item.volunteerAuthUserId)
          .toSet();
      for (final group in groups.values) {
        final count = group.volunteers.length;
        if (count < _reachCellAnonymityThreshold) continue;
        final invited = group.volunteers
            .where((item) => invitedIds.contains(item.volunteerAuthUserId))
            .length;
        areas.add(
          CampaignVolunteerMapMember(
            profileId: 0,
            displayName: '',
            areaLabel: invited == 0
                ? '$count available volunteers'
                : '$count available volunteers · $invited invited',
            latitude: group.latitude,
            longitude: group.longitude,
            status: invited == count ? 'invited' : 'area',
            volunteerCount: count,
          ),
        );
      }
      areas.sort((a, b) => b.volunteerCount!.compareTo(a.volunteerCount!));
    }
    final areaVolunteers = areas.fold<int>(
      0,
      (sum, area) => sum + area.volunteerCount!,
    );
    return CampaignVolunteerMap(
      volunteers: [...volunteers, ...areas],
      summary:
          '${volunteers.length} joined · $areaVolunteers available in ${areas.length} area${areas.length == 1 ? '' : 's'}',
    );
  }

  /// Invites one volunteer selected from the creator-only approximate map.
  /// Eligibility is checked again at send time.
  Future<bool> inviteCampaignVolunteer(
    Session session,
    int campaignId,
    int volunteerProfileId,
  ) async {
    final sponsor = await _requireRole(session, AccountRole.sponsor);
    final campaign = await _campaign(session, campaignId);
    if (campaign.createdBy != sponsor.authUserId) {
      throw FieldnoteException(
        message: 'Only the campaign creator can invite volunteers.',
        code: 'forbidden',
      );
    }
    if (!_isPubliclyOpen(campaign)) {
      throw FieldnoteException(
        message: 'This campaign is no longer open for invitations.',
        code: 'campaign_unavailable',
      );
    }
    await _limiter.hit(session, sponsor.authUserId, RateLimits.shareAndInvite);
    final profile = await FieldnoteUserProfile.db.findById(
      session,
      volunteerProfileId,
    );
    if (profile == null || profile.role != AccountRole.volunteer) {
      throw FieldnoteException(
        message: 'This volunteer is no longer available.',
        code: 'volunteer_unavailable',
      );
    }
    final joined = await CampaignParticipation.db.findFirstRow(
      session,
      where: (t) =>
          t.campaignId.equals(campaignId) &
          t.volunteerAuthUserId.equals(profile.authUserId),
    );
    if (joined != null) return false;
    final availability = await VolunteerAvailability.db.findFirstRow(
      session,
      where: (t) => t.volunteerAuthUserId.equals(profile.authUserId),
    );
    if (availability == null ||
        !availability.isAvailable ||
        availability.latitude == null ||
        availability.longitude == null ||
        !FieldnoteTime.availabilityCovers(availability, campaign) ||
        _distanceMeters(
                  availability.latitude!,
                  availability.longitude!,
                  campaign.latitude,
                  campaign.longitude,
                ) /
                1000 >
            availability.maximumTravelKm) {
      throw FieldnoteException(
        message: 'This volunteer can no longer reach the campaign.',
        code: 'volunteer_unavailable',
      );
    }
    final existing = await CampaignInvitation.db.findFirstRow(
      session,
      where: (t) =>
          t.campaignId.equals(campaignId) &
          t.volunteerAuthUserId.equals(profile.authUserId),
    );
    if (existing != null) return false;
    await CampaignInvitation.db.insertRow(
      session,
      CampaignInvitation(
        campaignId: campaignId,
        volunteerAuthUserId: profile.authUserId,
        sponsorAuthUserId: sponsor.authUserId,
      ),
    );
    await _notifications.invitationsReceived(session, campaign, [
      profile.authUserId,
    ]);
    return true;
  }

  /// Delivers a private in-app invitation to everyone in a visible map area.
  /// Eligibility and the anonymity threshold are checked again on the server
  /// at send time. Repeated taps do not create duplicate invitations.
  Future<int> inviteCampaignVolunteersInArea(
    Session session,
    int campaignId,
    double areaLatitude,
    double areaLongitude,
  ) async {
    final sponsor = await _requireRole(session, AccountRole.sponsor);
    final campaign = await _campaign(session, campaignId);
    if (campaign.createdBy != sponsor.authUserId) {
      throw FieldnoteException(
        message: 'Only the campaign creator can invite volunteers.',
        code: 'forbidden',
      );
    }
    if (!_isPubliclyOpen(campaign)) {
      throw FieldnoteException(
        message: 'This campaign is no longer open for invitations.',
        code: 'campaign_unavailable',
      );
    }
    _requireValidCoordinates(areaLatitude, areaLongitude);
    await _limiter.hit(session, sponsor.authUserId, RateLimits.shareAndInvite);
    final key =
        '${areaLatitude.toStringAsFixed(2)},${areaLongitude.toStringAsFixed(2)}';
    final groups = await _eligibleVolunteerReachGroups(session, campaign);
    final group = groups[key];
    if (group == null ||
        group.volunteers.length < _reachCellAnonymityThreshold) {
      throw FieldnoteException(
        message:
            'This area no longer has enough eligible volunteers. Refresh the map.',
        code: 'area_unavailable',
      );
    }
    final candidates = group.volunteers
        .map((item) => item.volunteerAuthUserId)
        .toSet();
    final existing = await CampaignInvitation.db.find(
      session,
      where: (t) =>
          t.campaignId.equals(campaignId) &
          t.volunteerAuthUserId.inSet(candidates),
    );
    final fresh = candidates.difference(
      existing.map((item) => item.volunteerAuthUserId).toSet(),
    );
    if (fresh.isEmpty) return 0;
    await CampaignInvitation.db.insert(session, [
      for (final volunteerId in fresh)
        CampaignInvitation(
          campaignId: campaignId,
          volunteerAuthUserId: volunteerId,
          sponsorAuthUserId: sponsor.authUserId,
        ),
    ]);
    await _notifications.invitationsReceived(session, campaign, fresh);
    return fresh.length;
  }

  Future<List<CampaignInvitation>> listMyCampaignInvitations(
    Session session, {
    int? limit,
    int? offset,
  }) async {
    final volunteer = await _requireRole(session, AccountRole.volunteer);
    final page = _page(limit, offset, defaultLimit: 100);
    return CampaignInvitation.db.find(
      session,
      where: (t) => t.volunteerAuthUserId.equals(volunteer.authUserId),
      orderBy: (t) => t.createdAt.desc(),
      limit: page.limit,
      offset: page.offset,
    );
  }

  /// A-7: available volunteers whose saved area lies inside the largest
  /// travel radius (100 km) of a point. Callers still filter precisely by
  /// each volunteer's own radius.
  Future<List<VolunteerAvailability>> _availableNear(
    Session session,
    double latitude,
    double longitude,
  ) {
    const maxKm = 100.0;
    const kmPerDegree = 111.0;
    final latitudeDelta = maxKm / kmPerDegree;
    final cosine = math.cos(latitude * math.pi / 180).abs();
    final longitudeDelta = cosine < 0.01
        ? 360.0
        : maxKm / (kmPerDegree * cosine);
    final wraps =
        longitude - longitudeDelta < -180 || longitude + longitudeDelta > 180;
    return VolunteerAvailability.db.find(
      session,
      where: (t) {
        final near =
            t.isAvailable.equals(true) &
            t.latitude.between(
              latitude - latitudeDelta,
              latitude + latitudeDelta,
            );
        return wraps
            ? near
            : near &
                  t.longitude.between(
                    longitude - longitudeDelta,
                    longitude + longitudeDelta,
                  );
      },
      limit: 5000,
    );
  }

  Future<Map<String, _ReachBucket>> _eligibleVolunteerReachGroups(
    Session session,
    Campaign campaign,
  ) async {
    final availabilities = await _availableNear(
      session,
      campaign.latitude,
      campaign.longitude,
    );
    final joined = await CampaignParticipation.db.find(
      session,
      where: (t) =>
          t.campaignId.equals(campaign.id!) &
          t.status.notEquals(ParticipationStatus.left),
    );
    final joinedIds = joined.map((item) => item.volunteerAuthUserId).toSet();
    final groups = <String, _ReachBucket>{};
    for (final availability in availabilities) {
      final latitude = availability.latitude;
      final longitude = availability.longitude;
      if (latitude == null ||
          longitude == null ||
          !FieldnoteTime.availabilityCovers(availability, campaign) ||
          joinedIds.contains(availability.volunteerAuthUserId) ||
          _distanceMeters(
                    latitude,
                    longitude,
                    campaign.latitude,
                    campaign.longitude,
                  ) /
                  1000 >
              availability.maximumTravelKm) {
        continue;
      }
      final cellLatitude = double.parse(latitude.toStringAsFixed(2));
      final cellLongitude = double.parse(longitude.toStringAsFixed(2));
      final key = '$cellLatitude,$cellLongitude';
      final bucket = groups[key] ??= _ReachBucket(cellLatitude, cellLongitude);
      bucket.volunteers.add(availability);
    }
    return groups;
  }

  /// Every check-in and evidence point for one campaign, for the sponsor live
  /// map. Restricted to the sponsor who created the campaign.
  Future<CampaignMapOverview> getCampaignMap(
    Session session,
    int campaignId,
  ) async {
    final sponsor = await _requireRole(session, AccountRole.sponsor);
    final campaign = await _campaign(session, campaignId);
    if (campaign.createdBy != sponsor.authUserId) {
      throw FieldnoteException(
        message: 'Only the campaign creator can open the campaign map.',
        code: 'forbidden',
      );
    }
    final participations = await CampaignParticipation.db.find(
      session,
      where: (t) => t.campaignId.equals(campaignId),
      orderBy: (t) => t.joinedAt,
    );
    final participationIds = participations
        .map((item) => item.id)
        .whereType<int>()
        .toSet();
    final evidence = participationIds.isEmpty
        ? <CompletionEvidence>[]
        : await CompletionEvidence.db.find(
            session,
            where: (t) => t.participationId.inSet(participationIds),
            orderBy: (t) => t.submittedAt,
          );

    final pins = <CampaignMapPin>[];
    var index = 0;
    for (final participation in participations) {
      index++;
      final latitude = participation.checkInLatitude;
      final longitude = participation.checkInLongitude;
      if (latitude == null || longitude == null) continue;
      pins.add(
        CampaignMapPin(
          participationId: participation.id!,
          kind: 'checkIn',
          latitude: latitude,
          longitude: longitude,
          accuracyMeters: participation.checkInAccuracyMeters ?? 0,
          distanceMeters: _distanceMeters(
            latitude,
            longitude,
            campaign.latitude,
            campaign.longitude,
          ),
          integrityStatus: participation.locationIntegrityStatus ?? 'unknown',
          integrityReasons: participation.locationIntegrityReasons ?? '',
          isDemo: participation.locationIsDemo,
          // Volunteer identity is deliberately not placed on the sponsor map.
          label: 'Volunteer $index check-in',
          occurredAt: participation.checkedInAt ?? participation.joinedAt,
        ),
      );
    }
    for (final item in evidence) {
      pins.add(
        CampaignMapPin(
          participationId: item.participationId,
          evidenceId: item.id,
          kind: 'evidence',
          latitude: item.latitude,
          longitude: item.longitude,
          accuracyMeters: item.locationAccuracyMeters,
          distanceMeters: _distanceMeters(
            item.latitude,
            item.longitude,
            campaign.latitude,
            campaign.longitude,
          ),
          integrityStatus: item.locationIntegrityStatus,
          integrityReasons: item.locationIntegrityReasons,
          isDemo: item.locationIsDemo,
          label: item.confirmedSummary,
          occurredAt: item.submittedAt,
        ),
      );
    }
    pins.sort((a, b) => a.occurredAt.compareTo(b.occurredAt));

    return CampaignMapOverview(
      campaign: campaign,
      pins: pins,
      joinedCount: participations.length,
      checkedInCount: participations
          .where((item) => item.checkedInAt != null)
          .length,
      completedCount: participations
          .where((item) => item.status == ParticipationStatus.completed)
          .length,
      demoCount: pins.where((item) => item.isDemo).length,
    );
  }

  /// Creates a Razorpay order for part of a campaign's remaining balance.
  ///
  /// The balance check runs under the campaign row lock and counts unpaid
  /// orders from the last [PaymentReconciliationService.orderTtl] as reserved,
  /// so parallel checkouts cannot oversubscribe the goal (S6).
  ///
  /// [amountPaise] is preferred over the rupee [amount] when sent. A retry
  /// with the same [clientRequestId] (per sponsor) returns the order created
  /// by the first call while it is still awaiting payment.
  Future<RazorpayCheckoutOrder> createRazorpayOrder(
    Session session,
    int campaignId,
    double amount,
    String? message, {
    int? amountPaise,
    String? clientRequestId,
  }) async {
    final sponsor = await _requireRole(session, AccountRole.sponsor);
    final requestedPaise = Money.fromInput(paise: amountPaise, rupees: amount);
    if (requestedPaise == null ||
        requestedPaise < 100 ||
        requestedPaise > Money.maximumPaise) {
      throw FieldnoteException(
        message: 'Choose a sponsorship between ₹1 and ₹10,00,000.',
        code: 'invalid_amount',
      );
    }
    final orderPaise = requestedPaise;
    final requestId = _validatedClientRequestId(clientRequestId);
    if (requestId != null) {
      final replay = await _checkoutForRequest(
        session,
        sponsor.authUserId,
        requestId,
        campaignId: campaignId,
        amountPaise: orderPaise,
      );
      if (replay != null) return replay;
    }
    _maxLength(message ?? '', _sponsorMessageMax, 'message');
    await _moderateOrThrow(session, message ?? '', 'sponsorMessage');
    final credentials = RazorpayCredentials.require(session);
    await _limiter.hit(session, sponsor.authUserId, RateLimits.createOrder);
    await _refreshCampaignReadiness(session, campaignId);
    final ({Campaign campaign, Sponsorship sponsorship}) reserved;
    try {
      reserved = await session.db.transaction((transaction) async {
        final campaign = await Campaign.db.findById(
          session,
          campaignId,
          transaction: transaction,
          lockMode: LockMode.forUpdate,
        );
        if (campaign == null ||
            CampaignLifecycleService.isClosed(campaign) ||
            !DateTime.now().toUtc().isBefore(campaign.startsAt)) {
          throw FieldnoteException(
            message: 'This campaign is closed to new payments.',
            code: 'campaign_unavailable',
          );
        }
        final unfundedPaise = campaign.unfundedPaise;
        if (unfundedPaise <= 0) {
          throw FieldnoteException(
            message: 'This campaign is already fully funded.',
            code: 'campaign_fully_funded',
          );
        }
        final reservedPaise = await PaymentReconciliationService.reservedPaise(
          session,
          campaignId: campaignId,
          transaction: transaction,
        );
        final availablePaise = unfundedPaise - reservedPaise;
        if (orderPaise > availablePaise) {
          throw FieldnoteException(
            message: availablePaise <= 0
                ? 'Other sponsors are completing checkout for the remaining balance. Try again in a few minutes.'
                : 'Choose an amount up to the remaining campaign balance of '
                      '₹${Money.fromPaise(availablePaise).toStringAsFixed(2)}.',
            code: 'amount_exceeds_campaign_balance',
          );
        }
        final sponsorship = await Sponsorship.db.insertRow(
          session,
          Sponsorship(
            campaignId: campaignId,
            sponsorAuthUserId: sponsor.authUserId,
            amount: Money.fromPaise(orderPaise),
            amountPaise: orderPaise,
            message: _blankToNull(message),
            paymentProvider: 'razorpay',
            paymentTestMode: credentials.isTestMode
                ? true
                : credentials.keyId.startsWith('rzp_live_')
                ? false
                : null,
            paymentStatus: 'created',
            clientRequestId: requestId,
            updatedAt: DateTime.now().toUtc(),
          ),
          transaction: transaction,
        );
        return (campaign: campaign, sponsorship: sponsorship);
      });
    } on DatabaseException {
      // A concurrent retry with the same clientRequestId inserted first.
      final replay = requestId == null
          ? null
          : await _checkoutForRequest(
              session,
              sponsor.authUserId,
              requestId,
              campaignId: campaignId,
              amountPaise: orderPaise,
            );
      if (replay == null) rethrow;
      return replay;
    }
    final receipt = 'fn_${campaignId}_${reserved.sponsorship.id}';
    late final RazorpayOrderResult order;
    try {
      order = await _payments.createOrder(
        keyId: credentials.keyId,
        keySecret: credentials.keySecret,
        amountPaise: orderPaise,
        receipt: receipt,
        campaignId: campaignId,
      );
      if (order.amountPaise != orderPaise) {
        throw const RazorpayPaymentException(
          'Razorpay returned an order for a different amount.',
        );
      }
    } on RazorpayPaymentException catch (error, stackTrace) {
      session.log(
        'Razorpay order creation failed: ${error.message}',
        level: LogLevel.warning,
        stackTrace: stackTrace,
      );
      await const PaymentSettlementService().markFailed(
        session,
        sponsorship: reserved.sponsorship,
        status: 'failed',
        reason: 'Razorpay could not create the order.',
      );
      await _audit(
        session,
        event: 'paymentOrderCreate',
        entityType: 'campaign',
        entityId: '$campaignId',
        outcome: 'failed',
        riskLevel: 'warning',
        detail: 'Razorpay could not create the order.',
      );
      throw FieldnoteException(
        message:
            'Razorpay could not create the order. Check the server connection and try again.',
        code: 'razorpay_unavailable',
      );
    }
    final sponsorship = reserved.sponsorship
      ..providerOrderId = order.id
      ..updatedAt = DateTime.now().toUtc();
    await Sponsorship.db.updateRow(session, sponsorship);
    await _audit(
      session,
      event: 'paymentOrderCreated',
      entityType: 'sponsorship',
      entityId: '${sponsorship.id}',
      outcome: 'created',
      riskLevel: 'info',
      detail: 'Razorpay order ${order.id} created for $orderPaise paise.',
    );
    return RazorpayCheckoutOrder(
      sponsorshipId: sponsorship.id!,
      orderId: order.id,
      keyId: credentials.keyId,
      amountPaise: order.amountPaise,
      currency: order.currency,
      campaignName: reserved.campaign.name,
      description: 'Sponsor verified volunteer impact',
    );
  }

  /// The checkout an earlier [createRazorpayOrder] with [requestId] opened,
  /// or null when the id is new. A retry while Razorpay is still creating
  /// the order, a finished attempt, or an id reused for another campaign or
  /// amount is rejected with `duplicate_payment_request`.
  Future<RazorpayCheckoutOrder?> _checkoutForRequest(
    Session session,
    UuidValue sponsor,
    String requestId, {
    required int campaignId,
    required int amountPaise,
  }) async {
    final existing = await Sponsorship.db.findFirstRow(
      session,
      where: (t) =>
          t.sponsorAuthUserId.equals(sponsor) &
          t.clientRequestId.equals(requestId),
    );
    if (existing == null) return null;
    final campaign = await Campaign.db.findById(session, existing.campaignId);
    final orderId = existing.providerOrderId;
    if (campaign == null ||
        existing.campaignId != campaignId ||
        existing.amountPaise != amountPaise ||
        existing.paymentStatus != 'created' ||
        orderId == null) {
      throw FieldnoteException(
        message:
            'This payment request was already handled. Start a new checkout.',
        code: 'duplicate_payment_request',
      );
    }
    return RazorpayCheckoutOrder(
      sponsorshipId: existing.id!,
      orderId: orderId,
      keyId: RazorpayCredentials.require(session).keyId,
      amountPaise: existing.amountPaise,
      currency: 'INR',
      campaignName: campaign.name,
      description: 'Sponsor verified volunteer impact',
    );
  }

  Future<Sponsorship> verifyRazorpayPayment(
    Session session,
    int sponsorshipId,
    String orderId,
    String paymentId,
    String signature,
  ) async {
    final sponsor = await _requireRole(session, AccountRole.sponsor);
    final sponsorship = await Sponsorship.db.findById(session, sponsorshipId);
    if (sponsorship == null ||
        sponsorship.sponsorAuthUserId != sponsor.authUserId ||
        sponsorship.providerOrderId != orderId) {
      throw FieldnoteException(
        message: 'The Razorpay order does not match this sponsorship.',
        code: 'payment_order_mismatch',
      );
    }
    await _refreshCampaignReadiness(session, sponsorship.campaignId);
    if (sponsorship.paymentStatus == 'verified') return sponsorship;
    if (sponsorship.paymentStatus == 'verified_uncredited') {
      throw FieldnoteException(
        message:
            'This payment succeeded but could not be credited. A refund has been queued.',
        code: 'payment_uncredited',
      );
    }
    if (!RegExp(r'^pay_[A-Za-z0-9]+$').hasMatch(paymentId) ||
        !RegExp(r'^[a-fA-F0-9]{64}$').hasMatch(signature)) {
      throw FieldnoteException(
        message: 'Razorpay returned invalid payment verification fields.',
        code: 'invalid_payment_response',
      );
    }
    final verified = const RazorpayPaymentService().verifySignature(
      orderId: sponsorship.providerOrderId!,
      paymentId: paymentId,
      signature: signature,
      keySecret: RazorpayCredentials.require(session).keySecret,
    );
    if (!verified) {
      final updated = await const PaymentCreditService().markFailed(
        session,
        sponsorshipId: sponsorshipId,
        sponsorAuthUserId: sponsor.authUserId,
        status: 'verification_failed',
      );
      if (updated.paymentStatus == 'verified') return updated;
      if (updated.paymentStatus == 'verified_uncredited') {
        throw FieldnoteException(
          message:
              'This payment succeeded but could not be credited. It needs review.',
          code: 'payment_uncredited',
        );
      }
      await _audit(
        session,
        event: 'paymentSignatureVerified',
        entityType: 'sponsorship',
        entityId: '$sponsorshipId',
        outcome: 'rejected',
        riskLevel: 'high',
        detail: 'Razorpay signature mismatch; campaign funding was unchanged.',
      );
      throw FieldnoteException(
        message: 'Payment signature verification failed.',
        code: 'payment_verification_failed',
      );
    }
    final result = await const PaymentSettlementService().settleCaptured(
      session,
      sponsorship: sponsorship,
      paymentId: paymentId,
      source: 'checkout',
    );
    if (result.uncredited) {
      throw FieldnoteException(
        message:
            'Payment succeeded, but the campaign could not be credited. A refund has been queued.',
        code: 'payment_uncredited',
      );
    }
    return result.sponsorship;
  }

  Future<Sponsorship> recordRazorpayFailure(
    Session session,
    int sponsorshipId,
    String reason,
  ) async {
    final sponsor = await _requireRole(session, AccountRole.sponsor);
    final sponsorship = await Sponsorship.db.findById(session, sponsorshipId);
    if (sponsorship == null ||
        sponsorship.sponsorAuthUserId != sponsor.authUserId) {
      throw FieldnoteException(
        message: 'Sponsorship payment attempt not found.',
        code: 'payment_not_found',
      );
    }
    final safeReason = reason.trim().replaceAll(RegExp(r'\s+'), ' ');
    final updated = await const PaymentCreditService().markFailed(
      session,
      sponsorshipId: sponsorshipId,
      sponsorAuthUserId: sponsor.authUserId,
      status: 'failed',
      failureReason: safeReason.isEmpty ? null : safeReason,
    );
    if (updated.paymentStatus == 'verified' ||
        updated.paymentStatus == 'verified_uncredited') {
      return updated;
    }
    await _audit(
      session,
      event: 'paymentCheckoutFailed',
      entityType: 'sponsorship',
      entityId: '$sponsorshipId',
      outcome: 'failed',
      riskLevel: 'warning',
      detail: safeReason.isEmpty
          ? 'Razorpay checkout was cancelled or failed.'
          : safeReason.substring(0, math.min(safeReason.length, 240)),
    );
    return updated;
  }

  Future<List<Sponsorship>> listMySponsorships(
    Session session, {
    int? limit,
    int? offset,
  }) async {
    final sponsor = await _requireRole(session, AccountRole.sponsor);
    final page = _page(limit, offset, defaultLimit: 100);
    return Sponsorship.db.find(
      session,
      where: (t) => t.sponsorAuthUserId.equals(sponsor.authUserId),
      orderBy: (t) => t.createdAt.desc(),
      limit: page.limit,
      offset: page.offset,
    );
  }

  /// Whether [simulateCampaignTestPayout] can run: Razorpay keys are
  /// configured and are Test Mode (`rzp_test_`) keys. When false in live
  /// mode, creator payouts are settled manually by FieldNote operations
  /// (docs/DEPLOYMENT.md) and the app should say so instead of offering a
  /// simulation.
  Future<bool> isPayoutSimulationAvailable(Session session) async {
    await _requireProfile(session);
    return RazorpayCredentials.fromSession(session)?.isTestMode ?? false;
  }

  /// Creator-only demonstration ledger. These rows never initiate a bank
  /// transfer or call Razorpay Route.
  Future<List<TestPayout>> listCampaignTestPayouts(
    Session session,
    int campaignId, {
    int? limit,
    int? offset,
  }) async {
    final page = _page(limit, offset, defaultLimit: 100);
    final sponsor = await _requireRole(session, AccountRole.sponsor);
    final campaign = await _campaign(session, campaignId);
    if (campaign.createdBy != sponsor.authUserId) {
      throw FieldnoteException(
        message: 'Only the campaign creator can view its payout simulation.',
        code: 'creator_required',
      );
    }
    return TestPayout.db.find(
      session,
      where: (t) => t.campaignId.equals(campaignId),
      orderBy: (t) => t.simulatedAt.desc(),
      limit: page.limit,
      offset: page.offset,
    );
  }

  /// Records one simulated credit for each newly verified test checkout.
  /// A campaign row lock and unique sponsorship index make retries safe.
  Future<List<TestPayout>> simulateCampaignTestPayout(
    Session session,
    int campaignId,
  ) async {
    final sponsor = await _requireRole(session, AccountRole.sponsor);
    await _refreshCampaignReadiness(session, campaignId);
    if (!RazorpayCredentials.require(session).isTestMode) {
      // Item 7: real payouts need RazorpayX + KYC, which FieldNote does not
      // integrate. Live money is released by operations, never simulated.
      throw FieldnoteException(
        message: 'Payouts are settled manually by FieldNote operations.',
        code: 'payouts_manual',
      );
    }
    final results = await session.db.transaction((transaction) async {
      final campaign = await Campaign.db.findById(
        session,
        campaignId,
        transaction: transaction,
        lockMode: LockMode.forUpdate,
      );
      if (campaign == null || campaign.createdBy != sponsor.authUserId) {
        throw FieldnoteException(
          message: 'Only the campaign creator can simulate its payout.',
          code: 'creator_required',
        );
      }
      if (campaign.status != CampaignStatus.completed) {
        // S12: money is only released once the work window has closed.
        throw FieldnoteException(
          message:
              'Creator payouts are available after the campaign is completed.',
          code: 'campaign_not_completed',
        );
      }
      final verified = await Sponsorship.db.find(
        session,
        where: (t) =>
            t.campaignId.equals(campaignId) &
            t.paymentStatus.equals('verified'),
        transaction: transaction,
      );
      final previous = await TestPayout.db.find(
        session,
        where: (t) => t.campaignId.equals(campaignId),
        transaction: transaction,
      );
      final processed = previous.map((payout) => payout.sponsorshipId).toSet();
      // Money already going back to a sponsor is never paid out as well.
      final refunded = verified.isEmpty
          ? <int>{}
          : (await TestRefund.db.find(
              session,
              where: (t) => t.sponsorshipId.inSet(
                verified.map((payment) => payment.id!).toSet(),
              ),
              transaction: transaction,
            )).map((refund) => refund.sponsorshipId).toSet();
      for (final payment in verified) {
        if (payment.paymentTestMode == false ||
            processed.contains(payment.id) ||
            refunded.contains(payment.id) ||
            payment.providerPaymentId == null ||
            payment.paymentProvider != 'razorpay') {
          continue;
        }
        final payout = await TestPayout.db.insertRow(
          session,
          TestPayout(
            campaignId: campaignId,
            sponsorshipId: payment.id!,
            creatorAuthUserId: sponsor.authUserId,
            amount: Money.fromPaise(payment.amountPaise),
            amountPaise: payment.amountPaise,
            sourcePaymentId: payment.providerPaymentId!,
            status: 'simulated',
          ),
          transaction: transaction,
        );
        previous.add(payout);
      }
      return previous;
    });
    await _audit(
      session,
      event: 'testPayoutSimulated',
      entityType: 'campaign',
      entityId: '$campaignId',
      outcome: 'simulated',
      riskLevel: 'info',
      detail:
          'Test ledger updated; no Razorpay transfer or bank payout was made.',
    );
    return results;
  }

  Future<ManualPayoutSummary> getManualPayoutSummary(
    Session session,
    int campaignId,
  ) async {
    final creator = await _requireRole(session, AccountRole.sponsor);
    return const ManualPayoutService().summary(
      session,
      creator.authUserId,
      campaignId,
    );
  }

  Future<ManualPayoutRequest> requestManualPayout(
    Session session,
    int campaignId,
    String clientRequestId,
  ) async {
    final creator = await _requireRole(session, AccountRole.sponsor);
    return const ManualPayoutService().request(
      session,
      creator.authUserId,
      campaignId,
      clientRequestId,
    );
  }

  Future<bool> isPayoutOperator(Session session) async =>
      FieldnoteConfig.isPayoutOperator(_userId(session).uuid);

  Future<List<ManualPayoutRequest>> listManualPayoutRequests(
    Session session, {
    int limit = 50,
    int offset = 0,
  }) => const ManualPayoutService().queue(
    session,
    _userId(session),
    limit: limit,
    offset: offset,
  );

  Future<ManualPayoutRequest> reviewManualPayout(
    Session session,
    int requestId,
    bool approve,
    int deductionPaise,
    String settlementReference,
    String payeeVerificationReference,
    String note,
  ) => const ManualPayoutService().review(
    session,
    _userId(session),
    requestId,
    approve,
    deductionPaise,
    settlementReference,
    payeeVerificationReference,
    note,
  );

  Future<ManualPayoutRequest> recordManualPayoutPaid(
    Session session,
    int requestId,
    String bankTransferReference,
  ) => const ManualPayoutService().recordPaid(
    session,
    _userId(session),
    requestId,
    bankTransferReference,
  );

  Future<List<CampaignMatch>> getCampaignMatches(Session session) async {
    final volunteer = await _requireRole(session, AccountRole.volunteer);
    final availability = await VolunteerAvailability.db.findFirstRow(
      session,
      where: (t) => t.volunteerAuthUserId.equals(volunteer.authUserId),
    );
    if (availability == null) {
      throw FieldnoteException(
        message: 'Set availability before requesting campaign matches.',
        code: 'availability_required',
      );
    }
    if (!availability.isAvailable) return const [];
    await _limiter.hit(session, volunteer.authUserId, RateLimits.matches);
    final campaigns = await _openCampaigns(session);
    if (campaigns.isEmpty) return const [];

    // One query for every campaign's taken places and the volunteer's own.
    final places = await CampaignParticipation.db.find(
      session,
      where: (t) =>
          t.campaignId.inSet(campaigns.map((c) => c.id!).toSet()) &
          t.status.inSet(CampaignLifecycleService.activeParticipationStatuses),
    );
    final taken = <int, int>{};
    final held = <int>{};
    for (final place in places) {
      taken[place.campaignId] = (taken[place.campaignId] ?? 0) + 1;
      if (place.volunteerAuthUserId == volunteer.authUserId) {
        held.add(place.campaignId);
      }
    }

    // Straight-line distance is the admission filter: it is free, offline, and
    // never depends on a third party being reachable. It also bounds how many
    // destinations the billed Routes call has to price. Full campaigns are
    // not joinable, so they are only kept when the volunteer holds a place.
    final candidates = <(Campaign, int)>[];
    for (final campaign in campaigns) {
      final count = taken[campaign.id] ?? 0;
      if (count >= campaign.volunteerCapacity && !held.contains(campaign.id)) {
        continue;
      }
      final preview = _matchCampaign(campaign, availability, volunteer, count);
      if (preview.distanceKm <= availability.maximumTravelKm) {
        candidates.add((campaign, count));
      }
    }

    // Real travel time only refines the ranking of campaigns that already
    // passed the filter above.
    final travel = await _travelTimes(session, availability, [
      for (final candidate in candidates) candidate.$1,
    ]);
    final matches = [
      for (final candidate in candidates)
        _matchCampaign(
          candidate.$1,
          availability,
          volunteer,
          candidate.$2,
          travel: travel[candidate.$1.id],
        ),
    ];
    matches.sort((a, b) {
      if (a.isFull != b.isFull) return a.isFull ? 1 : -1;
      return b.score.compareTo(a.score);
    });
    return matches;
  }

  /// Best-effort Routes API lookup, keyed by campaign id.
  ///
  /// Returns an empty map when the key is missing, the volunteer has not
  /// shared a location, or the provider is unreachable, which leaves every
  /// match on its straight-line score.
  Future<Map<int, RouteLeg>> _travelTimes(
    Session session,
    VolunteerAvailability availability,
    List<Campaign> campaigns,
  ) async {
    final originLatitude = availability.latitude;
    final originLongitude = availability.longitude;
    if (originLatitude == null || originLongitude == null) return const {};
    if (campaigns.isEmpty) return const {};
    final apiKey = _mapsKey(session);
    if (apiKey == null) return const {};
    try {
      final legs = await _maps.travelMatrix(
        apiKey: apiKey,
        originLatitude: originLatitude,
        originLongitude: originLongitude,
        destinations: [
          for (final campaign in campaigns)
            (latitude: campaign.latitude, longitude: campaign.longitude),
        ],
      );
      return {
        for (final leg in legs)
          if (leg.destinationIndex < campaigns.length)
            campaigns[leg.destinationIndex].id!: leg,
      };
    } on GoogleMapsException catch (error, stackTrace) {
      session.log(
        'Routes travel matrix failed; falling back to straight-line distance.',
        level: LogLevel.warning,
        exception: error,
        stackTrace: stackTrace,
      );
      return const {};
    }
  }

  Future<CampaignParticipation> joinCampaign(
    Session session,
    int campaignId,
  ) async {
    final volunteer = await _requireRole(session, AccountRole.volunteer);
    await _refreshCampaignReadiness(session, campaignId);
    final result = await session.db.transaction((transaction) async {
      // Lock the campaign so two volunteers cannot both take the last place.
      final campaign = await Campaign.db.findById(
        session,
        campaignId,
        transaction: transaction,
        lockMode: LockMode.forUpdate,
      );
      if (campaign == null ||
          campaign.status != CampaignStatus.active ||
          const {'cancelled', 'expired'}.contains(campaign.readinessState) ||
          !DateTime.now().toUtc().isBefore(campaign.startsAt)) {
        throw FieldnoteException(
          message: 'This campaign is not open for joining.',
          code: 'campaign_unavailable',
        );
      }
      final existing = await CampaignParticipation.db.findFirstRow(
        session,
        where: (t) =>
            t.campaignId.equals(campaignId) &
            t.volunteerAuthUserId.equals(volunteer.authUserId),
        transaction: transaction,
      );
      if (existing != null && existing.status != ParticipationStatus.left) {
        return (participation: existing, joined: false);
      }
      final taken = await _placesTaken(
        session,
        campaignId,
        transaction: transaction,
      );
      if (taken >= campaign.volunteerCapacity) {
        throw FieldnoteException(
          message: 'This campaign has reached volunteer capacity.',
          code: 'campaign_full',
        );
      }
      if (existing != null) {
        // A volunteer who left may take a free place again.
        existing.status = ParticipationStatus.joined;
        existing.leftAt = null;
        existing.joinedAt = DateTime.now().toUtc();
        existing.confirmedRevision = campaign.revision;
        final rejoined = await CampaignParticipation.db.updateRow(
          session,
          existing,
          transaction: transaction,
        );
        return (participation: rejoined, joined: true);
      }
      final participation = await CampaignParticipation.db.insertRow(
        session,
        CampaignParticipation(
          campaignId: campaignId,
          volunteerAuthUserId: volunteer.authUserId,
          status: ParticipationStatus.joined,
          confirmedRevision: campaign.revision,
        ),
        transaction: transaction,
      );
      return (participation: participation, joined: true);
    });
    if (!result.joined) return result.participation;
    await _refreshCampaignReadiness(session, campaignId);
    await _publish(
      session,
      campaignId,
      'volunteerJoined',
      // The stream reaches funders and other volunteers: never broadcast names.
      'A volunteer joined the campaign.',
    );
    return result.participation;
  }

  /// V-1: gives up a place before check-in. The place is freed, readiness is
  /// recomputed and the creator's live view is told.
  Future<CampaignParticipation> leaveCampaign(
    Session session,
    int participationId,
  ) async {
    final owned = await _ownedParticipation(session, participationId);
    final result = await session.db.transaction((transaction) async {
      final campaign = await Campaign.db.findById(
        session,
        owned.campaignId,
        transaction: transaction,
        lockMode: LockMode.forUpdate,
      );
      final participation = await CampaignParticipation.db.findById(
        session,
        participationId,
        transaction: transaction,
        lockMode: LockMode.forUpdate,
      );
      if (campaign == null || participation == null) {
        throw FieldnoteException(
          message: 'Campaign participation not found.',
          code: 'participation_not_found',
        );
      }
      if (participation.status == ParticipationStatus.left) {
        return (participation: participation, changed: false);
      }
      if (participation.status != ParticipationStatus.joined) {
        throw FieldnoteException(
          message: participation.status == ParticipationStatus.checkedIn
              ? 'You have already checked in. Finish the work or contact the organizer.'
              : 'This place can no longer be changed.',
          code: 'leave_unavailable',
        );
      }
      participation.status = ParticipationStatus.left;
      participation.leftAt = DateTime.now().toUtc();
      final updated = await CampaignParticipation.db.updateRow(
        session,
        participation,
        transaction: transaction,
      );
      return (participation: updated, changed: true);
    });
    if (!result.changed) return result.participation;
    await _refreshCampaignReadiness(session, owned.campaignId);
    await _publish(
      session,
      owned.campaignId,
      'volunteerLeft',
      'A volunteer left the campaign and a place opened up.',
    );
    await _audit(
      session,
      event: 'campaignLeft',
      entityType: 'participation',
      entityId: '$participationId',
      outcome: 'left',
      riskLevel: 'info',
      detail: 'The volunteer gave up their place before check-in.',
    );
    return result.participation;
  }

  /// S9: places held by joined, checked-in or completed volunteers.
  Future<int> _placesTaken(
    Session session,
    int campaignId, {
    Transaction? transaction,
  }) => CampaignParticipation.db.count(
    session,
    where: (t) =>
        t.campaignId.equals(campaignId) &
        t.status.inSet(CampaignLifecycleService.activeParticipationStatuses),
    transaction: transaction,
  );

  /// A contact number is private until a volunteer joins this campaign.
  Future<String?> getCampaignContactPhone(
    Session session,
    int campaignId,
  ) async {
    final volunteer = await _requireRole(session, AccountRole.volunteer);
    final campaign = await _campaign(session, campaignId);
    final joined = await CampaignParticipation.db.findFirstRow(
      session,
      where: (t) =>
          t.campaignId.equals(campaignId) &
          t.volunteerAuthUserId.equals(volunteer.authUserId),
    );
    if (joined == null) {
      throw FieldnoteException(
        message: 'Join the campaign to see its contact number.',
        code: 'join_required',
      );
    }
    final creator = await FieldnoteUserProfile.db.findFirstRow(
      session,
      where: (t) => t.authUserId.equals(campaign.createdBy),
    );
    return creator?.contactPhone;
  }

  Future<List<CampaignParticipation>> listMyParticipations(
    Session session, {
    int? limit,
    int? offset,
  }) async {
    final volunteer = await _requireRole(session, AccountRole.volunteer);
    final page = _page(limit, offset, defaultLimit: 100);
    return CampaignParticipation.db.find(
      session,
      where: (t) => t.volunteerAuthUserId.equals(volunteer.authUserId),
      orderBy: (t) => t.joinedAt.desc(),
      limit: page.limit,
      offset: page.offset,
    );
  }

  Future<CampaignParticipation> checkIn(
    Session session,
    int participationId,
    double latitude,
    double longitude,
    double accuracyMeters,
    bool deviceReportedMock,
    bool explicitDemo,
    DateTime capturedAt,
  ) async {
    final participation = await _ownedParticipation(session, participationId);
    if (participation.status == ParticipationStatus.completed ||
        participation.status == ParticipationStatus.checkedIn) {
      return participation;
    }
    if (participation.status != ParticipationStatus.joined) {
      throw FieldnoteException(
        message: 'Join the campaign before checking in.',
        code: 'join_required',
      );
    }
    final campaign = await _refreshCampaignReadiness(
      session,
      participation.campaignId,
    );
    if (campaign.readinessState != 'confirmed' ||
        participation.confirmedRevision != campaign.revision) {
      throw FieldnoteException(
        message:
            'The event must be confirmed and your place reconfirmed before check-in.',
        code: 'campaign_not_confirmed',
      );
    }
    final now = DateTime.now().toUtc();
    final checkInOpens = campaign.startsAt.subtract(
      const Duration(minutes: 30),
    );
    final checkInCloses =
        campaign.endsAt ?? campaign.startsAt.add(const Duration(hours: 2));
    if (now.isBefore(checkInOpens) || now.isAfter(checkInCloses)) {
      throw FieldnoteException(
        message:
            'GPS check-in is available from 30 minutes before the event until it ends.',
        code: 'check_in_window_closed',
      );
    }
    final distance = _distanceMeters(
      latitude,
      longitude,
      campaign.latitude,
      campaign.longitude,
    );
    final integrity = _locationIntegrity.assess(
      latitude: latitude,
      longitude: longitude,
      accuracyMeters: accuracyMeters,
      deviceReportedMock: deviceReportedMock,
      explicitDemo: explicitDemo,
      capturedAt: capturedAt,
      now: DateTime.now().toUtc(),
    );
    if (!integrity.allowed) {
      await _audit(
        session,
        event: 'locationCheckIn',
        entityType: 'participation',
        entityId: '$participationId',
        outcome: 'rejected',
        riskLevel: 'high',
        detail: integrity.reasons.join('; '),
      );
      throw FieldnoteException(
        message: integrity.reasons.join('. '),
        code: 'location_integrity_failed',
      );
    }
    if (distance > campaign.geofenceMeters + accuracyMeters) {
      throw FieldnoteException(
        message:
            'Move closer to the campaign location. You are ${distance.round()} m away.',
        code: 'outside_geofence',
      );
    }
    participation.status = ParticipationStatus.checkedIn;
    participation.checkedInAt = DateTime.now().toUtc();
    participation.checkInLatitude = latitude;
    participation.checkInLongitude = longitude;
    participation.checkInAccuracyMeters = accuracyMeters;
    participation.locationIntegrityStatus = integrity.status;
    participation.locationIntegrityReasons = integrity.reasons.join(' | ');
    participation.locationIsDemo = explicitDemo;
    final updated = await CampaignParticipation.db.updateRow(
      session,
      participation,
    );
    await _publish(
      session,
      campaign.id!,
      'volunteerCheckedIn',
      'A volunteer checked in ${distance.round()} m from the campaign pin.',
    );
    await _audit(
      session,
      event: 'locationCheckIn',
      entityType: 'participation',
      entityId: '$participationId',
      outcome: integrity.status,
      riskLevel: explicitDemo ? 'demo' : 'info',
      detail: integrity.reasons.join('; '),
    );
    return updated;
  }

  Future<CompletionProposal> analyzeCompletion(
    Session session,
    int participationId,
    String note,
    ByteData? photograph,
    String? photographMimeType,
  ) async {
    final participation = await _ownedParticipation(session, participationId);
    if (note.trim().length < 8) {
      throw FieldnoteException(
        message: 'Describe the completed work in a little more detail.',
        code: 'note_too_short',
      );
    }
    _maxLength(note, _noteMax, 'note');
    await _moderateOrThrow(session, note, 'completionNote');
    if (photograph != null && photograph.lengthInBytes > 2500000) {
      throw FieldnoteException(
        message: 'Choose a photograph smaller than 2.5 MB for AI analysis.',
        code: 'photograph_too_large',
      );
    }
    const supportedTypes = {'image/jpeg', 'image/png', 'image/webp'};
    if (photograph != null && !supportedTypes.contains(photographMimeType)) {
      throw FieldnoteException(
        message: 'Use a JPEG, PNG, or WebP photograph.',
        code: 'invalid_photograph',
      );
    }
    final apiKey = session.passwords['geminiApiKey']?.trim();
    final groqKey = session.passwords['groqApiKey']?.trim();
    if ((apiKey == null || apiKey.isEmpty) &&
        (groqKey == null || groqKey.isEmpty)) {
      // P0-8: completion never depends on an AI key.
      return _ai.manualCompletionProposal(note);
    }
    await _limiter.hit(
      session,
      participation.volunteerAuthUserId,
      RateLimits.analyzeCompletion,
    );
    try {
      final proposal = await AiProviderRouter.run<CompletionProposal>(
        primary: _aiPrimaryProvider(session),
        gemini: apiKey == null || apiKey.isEmpty
            ? null
            : () async {
                final proposal = await _gemini.analyzeCompletion(
                  apiKey: apiKey,
                  model: _geminiModel(session),
                  note: note.trim(),
                  photograph: photograph,
                  photographMimeType: photographMimeType,
                );
                session.log('Gemini evidence analysis succeeded.');
                return proposal;
              },
        groq: groqKey == null || groqKey.isEmpty
            ? null
            : () async {
                final proposal = await _groq.analyzeCompletion(
                  apiKey: groqKey,
                  note: note.trim(),
                  photograph: photograph,
                  photographMimeType: photographMimeType,
                );
                session.log('Groq evidence analysis succeeded.');
                return proposal;
              },
        onFallback: (from, to) => session.log(
          '${from.name} evidence quota exhausted; trying ${to.name}.',
        ),
      );
      participation.aiAnalyzedAt = DateTime.now().toUtc();
      await CampaignParticipation.db.updateRow(session, participation);
      return proposal;
    } on GeminiAiException catch (error, stackTrace) {
      session.log(
        'Gemini completion analysis failed; using the manual summary.',
        level: LogLevel.warning,
        exception: error,
        stackTrace: stackTrace,
      );
      return _ai.manualCompletionProposal(note);
    } on GroqAiException catch (error, stackTrace) {
      session.log(
        'Groq evidence analysis failed; using the manual summary.',
        level: LogLevel.warning,
        exception: error,
        stackTrace: stackTrace,
      );
      return _ai.manualCompletionProposal(note);
    }
  }

  /// Whether a hosted AI provider is configured. When false,
  /// [analyzeCompletion] returns a deterministic summary of the note and the
  /// client should present it as a volunteer-written summary.
  Future<bool> isAiAvailable(Session session) async {
    _userId(session);
    final apiKey = session.passwords['geminiApiKey']?.trim();
    final groqKey = session.passwords['groqApiKey']?.trim();
    return (apiKey != null && apiKey.isNotEmpty) ||
        (groqKey != null && groqKey.isNotEmpty);
  }

  Future<String> getEvidenceUploadDescription(
    Session session,
    int participationId,
    String extension,
  ) async {
    final participation = await _ownedParticipation(session, participationId);
    final safe = _imageExtension(extension);
    if (participation.status != ParticipationStatus.checkedIn) {
      throw FieldnoteException(
        message: 'Evidence can be uploaded only while you are checked in.',
        code: 'check_in_required',
      );
    }
    final campaign = await _campaign(session, participation.campaignId);
    _requireCompletionWindow(campaign);
    // A-1: every upload gets a fresh, unguessable path; only the latest one
    // issued to this participation can be pinned into its evidence.
    final path = _evidencePath(participation, safe);
    participation.evidenceUploadPath = path;
    await CampaignParticipation.db.updateRow(session, participation);
    final description = await session.storage.createUploadDescription(
      storageId: 'private',
      path: path,
    );
    return description;
  }

  /// V-3: evidence is accepted only for open campaigns until the end of the
  /// event plus [CampaignLifecycleService.completionGrace].
  static void _requireCompletionWindow(Campaign campaign) {
    if (CampaignLifecycleService.isClosed(campaign)) {
      throw FieldnoteException(
        message: 'This campaign is closed and no longer accepts evidence.',
        code: 'campaign_closed',
      );
    }
    if (DateTime.now().toUtc().isAfter(
      CampaignLifecycleService.completionDeadline(campaign),
    )) {
      throw FieldnoteException(
        message: 'The evidence window for this campaign has closed.',
        code: 'completion_window_closed',
      );
    }
  }

  /// Submits location-verified evidence for a checked-in participation.
  ///
  /// [uploadPath] optionally pins the path returned by
  /// [getEvidenceUploadDescription]; it must be the latest path issued to this
  /// participation. Set [manualSummary] when the volunteer wrote or edited the
  /// summary without an AI proposal (P0-8); the evidence is then recorded with
  /// `aiGenerated = false`.
  Future<CompletionEvidence> completeParticipation(
    Session session,
    int participationId,
    String photoExtension,
    String originalNote,
    String confirmedSummary,
    List<String> structuredResults,
    double latitude,
    double longitude,
    double accuracyMeters,
    bool deviceReportedMock,
    bool explicitDemo,
    DateTime capturedAt, {
    String? uploadPath,
    bool? manualSummary,
  }) async {
    final participation = await _ownedParticipation(session, participationId);
    if (participation.status == ParticipationStatus.completed) {
      final existing = await CompletionEvidence.db.findFirstRow(
        session,
        where: (t) => t.participationId.equals(participationId),
      );
      if (existing != null) return existing;
    }
    if (participation.status != ParticipationStatus.checkedIn) {
      throw FieldnoteException(
        message: 'GPS check-in is required before completion.',
        code: 'check_in_required',
      );
    }
    final note = originalNote.trim();
    final summary = confirmedSummary.trim();
    final results = structuredResults
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
    if (summary.length < 8 ||
        summary.length > _noteMax ||
        note.length > _noteMax) {
      throw FieldnoteException(
        message: 'Write a summary of the completed work (8–2000 characters).',
        code: 'invalid_summary',
      );
    }
    if (results.length > 20 || results.any((item) => item.length > 300)) {
      throw FieldnoteException(
        message: 'Keep the results list to 20 short items.',
        code: 'invalid_summary',
      );
    }
    await _moderateOrThrow(
      session,
      '$note\n$summary\n${results.join('\n')}',
      'completionEvidence',
    );
    final campaign = await _campaign(session, participation.campaignId);
    _requireCompletionWindow(campaign);
    final integrity = _locationIntegrity.assess(
      latitude: latitude,
      longitude: longitude,
      accuracyMeters: accuracyMeters,
      deviceReportedMock: deviceReportedMock,
      explicitDemo: explicitDemo,
      capturedAt: capturedAt,
      now: DateTime.now().toUtc(),
      previousLatitude: participation.checkInLatitude,
      previousLongitude: participation.checkInLongitude,
      previousAt: participation.checkedInAt,
    );
    if (!integrity.allowed || explicitDemo != participation.locationIsDemo) {
      final reasons = [
        ...integrity.reasons,
        if (explicitDemo != participation.locationIsDemo)
          'Evidence location mode does not match check-in mode',
      ];
      await _audit(
        session,
        event: 'evidenceLocationIntegrity',
        entityType: 'participation',
        entityId: '$participationId',
        outcome: 'rejected',
        riskLevel: 'high',
        detail: reasons.join('; '),
      );
      throw FieldnoteException(
        message: reasons.join('. '),
        code: 'location_integrity_failed',
      );
    }
    // Evidence may be captured anywhere on the work site; allow twice the
    // check-in geofence plus the reported accuracy.
    final distance = _distanceMeters(
      latitude,
      longitude,
      campaign.latitude,
      campaign.longitude,
    );
    if (distance > campaign.geofenceMeters * 2 + accuracyMeters) {
      throw FieldnoteException(
        message:
            'Submit evidence from the work site. You are ${distance.round()} m away.',
        code: 'outside_geofence',
      );
    }
    final safe = _imageExtension(photoExtension);
    final path = participation.evidenceUploadPath;
    final requested = uploadPath?.trim();
    if (path == null ||
        !path.startsWith(_evidencePrefix(participation)) ||
        !path.endsWith('.$safe') ||
        (requested != null && requested.isNotEmpty && requested != path)) {
      throw FieldnoteException(
        message: 'Upload and verify a photograph before completing the work.',
        code: 'photo_required',
      );
    }
    final verified =
        await session.storage.verifyUpload(storageId: 'private', path: path) ||
        await session.storage.fileExists(storageId: 'private', path: path);
    if (!verified) {
      throw FieldnoteException(
        message: 'Upload and verify a photograph before completing the work.',
        code: 'photo_required',
      );
    }
    final outcome = await session.db.transaction((transaction) async {
      // A-10: the participation row lock serialises concurrent submissions.
      final locked = await CampaignParticipation.db.findById(
        session,
        participationId,
        transaction: transaction,
        lockMode: LockMode.forUpdate,
      );
      final existing = await CompletionEvidence.db.findFirstRow(
        session,
        where: (t) => t.participationId.equals(participationId),
        transaction: transaction,
      );
      if (existing != null) return (evidence: existing, created: false);
      if (locked == null ||
          locked.status != ParticipationStatus.checkedIn ||
          locked.evidenceUploadPath != path) {
        throw FieldnoteException(
          message: 'This participation can no longer be completed.',
          code: 'check_in_required',
        );
      }
      final current = await Campaign.db.findById(
        session,
        locked.campaignId,
        transaction: transaction,
      );
      if (current == null) {
        throw FieldnoteException(
          message: 'Campaign not found.',
          code: 'campaign_not_found',
        );
      }
      _requireCompletionWindow(current);
      final aiGenerated = manualSummary != true && locked.aiAnalyzedAt != null;
      final evidence = await CompletionEvidence.db.insertRow(
        session,
        CompletionEvidence(
          participationId: participationId,
          photographPath: path,
          originalNote: note,
          confirmedSummary: summary,
          structuredResults: results.join(' | '),
          latitude: latitude,
          longitude: longitude,
          locationAccuracyMeters: accuracyMeters,
          locationIntegrityStatus: integrity.status,
          locationIntegrityReasons: integrity.reasons.join(' | '),
          locationIsDemo: explicitDemo,
          moderationStatus: 'passed',
          aiGenerated: aiGenerated,
          reviewState: ReviewState.awaitingReview,
        ),
        transaction: transaction,
      );
      locked.status = ParticipationStatus.completed;
      locked.completedAt = DateTime.now().toUtc();
      await CampaignParticipation.db.updateRow(
        session,
        locked,
        transaction: transaction,
      );
      return (evidence: evidence, created: true);
    });
    if (!outcome.created) return outcome.evidence;
    final evidence = outcome.evidence;
    await _publish(
      session,
      participation.campaignId,
      'evidenceCompleted',
      'Location-verified volunteer evidence was completed.',
    );
    await _audit(
      session,
      event: 'evidenceSubmitted',
      entityType: 'completionEvidence',
      entityId: '${evidence.id}',
      outcome: integrity.status,
      riskLevel: explicitDemo ? 'demo' : 'info',
      detail:
          'Moderation passed. ${evidence.aiGenerated ? 'AI-assisted summary.' : 'Volunteer-written summary.'} ${integrity.reasons.join('; ')}',
    );
    return evidence;
  }

  /// S-6: the campaign creator approves or rejects one piece of evidence.
  /// Rejected evidence is excluded from verified impact totals.
  Future<CompletionEvidence> reviewEvidence(
    Session session,
    int evidenceId,
    bool approve,
    String? note,
  ) async {
    final sponsor = await _requireRole(session, AccountRole.sponsor);
    final trimmedNote = _blankToNull(note);
    if (trimmedNote != null && trimmedNote.length > 1000) {
      throw FieldnoteException(
        message: 'Keep the review note under 1000 characters.',
        code: 'invalid_review',
      );
    }
    if (!approve && (trimmedNote == null || trimmedNote.length < 5)) {
      throw FieldnoteException(
        message: 'Explain why this evidence is being rejected.',
        code: 'review_note_required',
      );
    }
    if (trimmedNote != null) {
      await _moderateOrThrow(session, trimmedNote, 'evidenceReview');
    }
    final reviewed = await session.db.transaction((transaction) async {
      final evidence = await CompletionEvidence.db.findById(
        session,
        evidenceId,
        transaction: transaction,
        lockMode: LockMode.forUpdate,
      );
      final participation = evidence == null
          ? null
          : await CampaignParticipation.db.findById(
              session,
              evidence.participationId,
              transaction: transaction,
            );
      final campaign = participation == null
          ? null
          : await Campaign.db.findById(
              session,
              participation.campaignId,
              transaction: transaction,
            );
      if (evidence == null ||
          campaign == null ||
          campaign.createdBy != sponsor.authUserId) {
        throw FieldnoteException(
          message: 'Only the campaign creator can review this evidence.',
          code: 'forbidden',
        );
      }
      evidence.reviewState = approve
          ? ReviewState.approved
          : ReviewState.rejected;
      evidence.reviewNote = trimmedNote;
      evidence.reviewedByAuthUserId = sponsor.authUserId;
      evidence.reviewedAt = DateTime.now().toUtc();
      final updated = await CompletionEvidence.db.updateRow(
        session,
        evidence,
        transaction: transaction,
      );
      return (
        evidence: updated,
        campaign: campaign,
        volunteer: participation!.volunteerAuthUserId,
      );
    });
    await _notifications.evidenceReviewed(
      session,
      evidence: reviewed.evidence,
      volunteer: reviewed.volunteer,
      campaign: reviewed.campaign,
    );
    await _audit(
      session,
      event: 'evidenceReviewed',
      entityType: 'completionEvidence',
      entityId: '$evidenceId',
      outcome: approve ? 'approved' : 'rejected',
      riskLevel: approve ? 'info' : 'warning',
      detail: trimmedNote ?? (approve ? 'Approved.' : 'Rejected.'),
    );
    await _publish(
      session,
      reviewed.campaign.id!,
      'evidenceReviewed',
      approve
          ? 'The organizer approved a piece of evidence.'
          : 'The organizer rejected a piece of evidence.',
    );
    return reviewed.evidence;
  }

  Future<String> getEvidenceDownloadUrl(
    Session session,
    int evidenceId,
  ) async {
    final profile = await _requireProfile(session);
    await _requireRole(session, profile.role);
    final evidence = await CompletionEvidence.db.findById(session, evidenceId);
    if (evidence?.photographPath == null) {
      throw FieldnoteException(
        message: 'Evidence photograph not found.',
        code: 'evidence_not_found',
      );
    }
    final participation = await CampaignParticipation.db.findById(
      session,
      evidence!.participationId,
    );
    if (participation == null ||
        !(profile.role == AccountRole.volunteer &&
                participation.volunteerAuthUserId == profile.authUserId) &&
            !(profile.role == AccountRole.sponsor &&
                await _canSponsorSeeEvidence(
                  session,
                  profile,
                  participation.campaignId,
                ))) {
      throw FieldnoteException(
        message: 'You cannot view this private evidence.',
        code: 'forbidden',
      );
    }
    final url = await session.storage.temporaryDownloadUrl(
      storageId: 'private',
      path: evidence.photographPath!,
    );
    return url.toString();
  }

  Future<ImpactSummary> getImpact(Session session, int campaignId) async {
    final sponsor = await _requireRole(session, AccountRole.sponsor);
    final campaign = await _campaign(session, campaignId);
    if (!await _canSponsorSeeEvidence(session, sponsor, campaignId)) {
      throw FieldnoteException(
        message: 'You cannot view this campaign impact.',
        code: 'forbidden',
      );
    }
    final participations = await CampaignParticipation.db.find(
      session,
      where: (t) => t.campaignId.equals(campaignId),
    );
    final ids = participations.map((item) => item.id).whereType<int>().toSet();
    final evidence = ids.isEmpty
        ? <CompletionEvidence>[]
        : await CompletionEvidence.db.find(
            session,
            where: (t) => t.participationId.inSet(ids),
            orderBy: (t) => t.submittedAt.desc(),
          );
    // S-6: rejected evidence never counts as verified impact.
    final accepted = evidence
        .where((item) => item.reviewState != ReviewState.rejected)
        .toList();
    final acceptedParticipations = accepted
        .map((item) => item.participationId)
        .toSet();
    final completed = participations
        .where(
          (item) =>
              item.status == ParticipationStatus.completed &&
              acceptedParticipations.contains(item.id),
        )
        .length;
    final joined = participations
        .where(
          (item) => CampaignLifecycleService.activeParticipationStatuses
              .contains(item.status),
        )
        .length;
    final approved = evidence
        .where((item) => item.reviewState == ReviewState.approved)
        .length;
    final rejected = evidence
        .where((item) => item.reviewState == ReviewState.rejected)
        .length;
    final payments = await Sponsorship.db.find(
      session,
      where: (t) =>
          t.campaignId.equals(campaignId) & t.paymentStatus.equals('verified'),
    );
    final fundingNotes = <String>[
      if (payments.any((item) => item.paymentTestMode == true))
        'Includes Razorpay Test Mode payments: those payments move no real money.',
      if (payments.any((item) => item.paymentTestMode == false))
        'Includes live payments. Recorded funding is not proof of creator bank settlement.',
      if (payments.any((item) => item.paymentTestMode == null))
        'Some historical payments have an unknown checkout mode; they must not be treated as confirmed live funding.',
      if (payments.isEmpty)
        'No verified payment records. Any historical funding balance has not been classified as live or Test Mode.',
    ];
    return ImpactSummary(
      campaignId: campaignId,
      sponsorshipTotal: Money.fromPaise(campaign.sponsoredAmountPaise),
      fundingGoal: Money.fromPaise(campaign.fundingGoalPaise),
      sponsorshipTotalPaise: campaign.sponsoredAmountPaise,
      fundingGoalPaise: campaign.fundingGoalPaise,
      refundedPaise: campaign.refundedAmountPaise,
      joinedVolunteers: joined,
      completedVolunteers: completed,
      evidenceCount: accepted.length,
      summary:
          '$approved sponsor-approved contributions; '
          '${evidence.length - approved - rejected} pending review; '
          '$rejected rejected. ${fundingNotes.join(' ')}',
      // The report needs every review state, including rejected evidence.
      // Keep the existing wire contract; clients limit dashboard previews.
      recentEvidence: evidence,
    );
  }

  /// S-3: every campaign the sponsor created or funded, in any status,
  /// newest first.
  Future<List<Campaign>> listMyCampaigns(
    Session session, {
    int? limit,
    int? offset,
  }) async {
    final sponsor = await _requireRole(session, AccountRole.sponsor);
    final page = _page(limit, offset);
    final funded = await Sponsorship.db.find(
      session,
      where: (t) =>
          t.sponsorAuthUserId.equals(sponsor.authUserId) &
          t.paymentStatus.inSet({'verified', 'verified_uncredited'}),
    );
    final fundedIds = funded.map((item) => item.campaignId).toSet();
    return Campaign.db.find(
      session,
      where: (t) => fundedIds.isEmpty
          ? t.createdBy.equals(sponsor.authUserId)
          : t.createdBy.equals(sponsor.authUserId) | t.id.inSet(fundedIds),
      orderBy: (t) => t.createdAt.desc(),
      limit: page.limit,
      offset: page.offset,
    );
  }

  /// S-2: the sponsor's payment attempts in every state with their refund.
  Future<List<SponsorshipHistoryEntry>> listMyPaymentHistory(
    Session session, {
    int? limit,
    int? offset,
  }) async {
    final sponsor = await _requireRole(session, AccountRole.sponsor);
    final page = _page(limit, offset);
    final sponsorships = await Sponsorship.db.find(
      session,
      where: (t) => t.sponsorAuthUserId.equals(sponsor.authUserId),
      orderBy: (t) => t.createdAt.desc(),
      limit: page.limit,
      offset: page.offset,
    );
    if (sponsorships.isEmpty) return const [];
    final campaigns = await Campaign.db.find(
      session,
      where: (t) => t.id.inSet(sponsorships.map((s) => s.campaignId).toSet()),
    );
    final refunds = await TestRefund.db.find(
      session,
      where: (t) =>
          t.sponsorshipId.inSet(sponsorships.map((s) => s.id!).toSet()),
    );
    final campaignById = {for (final c in campaigns) c.id!: c};
    final refundBySponsorship = {for (final r in refunds) r.sponsorshipId: r};
    return [
      for (final sponsorship in sponsorships)
        if (campaignById[sponsorship.campaignId] case final campaign?)
          SponsorshipHistoryEntry(
            sponsorship: sponsorship,
            campaignName: campaign.name,
            campaignStatus: campaign.status,
            campaignReadinessState: campaign.readinessState,
            refund: refundBySponsorship[sponsorship.id],
          ),
    ];
  }

  /// V-10: the volunteer's participations with campaign and evidence.
  Future<List<ParticipationHistoryEntry>> listMyParticipationHistory(
    Session session, {
    int? limit,
    int? offset,
  }) async {
    final volunteer = await _requireRole(session, AccountRole.volunteer);
    final page = _page(limit, offset);
    final participations = await CampaignParticipation.db.find(
      session,
      where: (t) => t.volunteerAuthUserId.equals(volunteer.authUserId),
      orderBy: (t) => t.joinedAt.desc(),
      limit: page.limit,
      offset: page.offset,
    );
    if (participations.isEmpty) return const [];
    final campaigns = await Campaign.db.find(
      session,
      where: (t) => t.id.inSet(participations.map((p) => p.campaignId).toSet()),
    );
    final evidence = await CompletionEvidence.db.find(
      session,
      where: (t) =>
          t.participationId.inSet(participations.map((p) => p.id!).toSet()),
    );
    final campaignById = {for (final c in campaigns) c.id!: c};
    final evidenceByParticipation = {
      for (final e in evidence) e.participationId: e,
    };
    return [
      for (final participation in participations)
        if (campaignById[participation.campaignId] case final campaign?)
          ParticipationHistoryEntry(
            participation: participation,
            campaign: campaign,
            evidence: evidenceByParticipation[participation.id],
          ),
    ];
  }

  /// Refund rows for one campaign, for its creator.
  Future<List<TestRefund>> listCampaignRefunds(
    Session session,
    int campaignId, {
    int? limit,
    int? offset,
  }) async {
    final page = _page(limit, offset, defaultLimit: 100);
    final sponsor = await _requireRole(session, AccountRole.sponsor);
    final campaign = await _campaign(session, campaignId);
    if (campaign.createdBy != sponsor.authUserId) {
      throw FieldnoteException(
        message: 'Only the campaign creator can view its refunds.',
        code: 'creator_required',
      );
    }
    return TestRefund.db.find(
      session,
      where: (t) => t.campaignId.equals(campaignId),
      orderBy: (t) => t.createdAt.desc(),
      limit: page.limit,
      offset: page.offset,
    );
  }

  static ({int limit, int offset}) _page(
    int? limit,
    int? offset, {
    int defaultLimit = 50,
  }) => (
    limit: (limit ?? defaultLimit).clamp(1, 100),
    offset: math.max(0, offset ?? 0),
  );

  Future<bool> _canSponsorSeeEvidence(
    Session session,
    FieldnoteUserProfile sponsor,
    int campaignId,
  ) async {
    final campaign = await _campaign(session, campaignId);
    if (campaign.createdBy == sponsor.authUserId) return true;
    final funding = await Sponsorship.db.findFirstRow(
      session,
      where: (t) =>
          t.campaignId.equals(campaignId) &
          t.sponsorAuthUserId.equals(sponsor.authUserId) &
          t.paymentStatus.equals('verified'),
    );
    return funding != null;
  }

  /// One room per campaign, with membership derived from participation.
  Future<void> _requireChatMember(
    Session session,
    FieldnoteUserProfile profile,
    Campaign campaign, {
    Transaction? transaction,
  }) async {
    if (campaign.createdBy == profile.authUserId) return;
    if (profile.role == AccountRole.volunteer) {
      final member = await CampaignParticipation.db.findFirstRow(
        session,
        where: (t) =>
            t.campaignId.equals(campaign.id!) &
            t.volunteerAuthUserId.equals(profile.authUserId) &
            t.status.inSet({
              ParticipationStatus.joined,
              ParticipationStatus.checkedIn,
              ParticipationStatus.completed,
              ParticipationStatus.incomplete,
            }),
        transaction: transaction,
      );
      if (member != null) return;
    }
    throw FieldnoteException(
      code: 'chat_forbidden',
      message:
          'Only the campaign creator and joined volunteers can open this discussion.',
    );
  }

  Future<CampaignChatMessage> sendCampaignMessage(
    Session session,
    int campaignId,
    String body,
    String clientRequestId,
  ) async {
    final profile = await _requireProfile(session);
    await _requireRole(session, profile.role);
    final text = body.trim();
    _requireLength(text, 1, 2000, 'message');
    if (!RegExp(r'^[a-zA-Z0-9_-]{8,80}$').hasMatch(clientRequestId)) {
      throw FieldnoteException(
        code: 'invalid_chat_request',
        message: 'Invalid message request id.',
      );
    }
    // Serialize sends with joins, departures and campaign closure. This also
    // makes concurrent retries return the same row, without duplicate messages.
    final message = await session.db.transaction((transaction) async {
      final campaign = await Campaign.db.findById(
        session,
        campaignId,
        transaction: transaction,
        lockMode: LockMode.forUpdate,
      );
      if (campaign == null) {
        throw FieldnoteException(
          code: 'campaign_not_found',
          message: 'Campaign not found.',
        );
      }
      await _requireChatMember(
        session,
        profile,
        campaign,
        transaction: transaction,
      );
      final previous = await CampaignChatMessage.db.findFirstRow(
        session,
        where: (t) =>
            t.campaignId.equals(campaignId) &
            t.senderAuthUserId.equals(profile.authUserId) &
            t.clientRequestId.equals(clientRequestId),
        transaction: transaction,
      );
      if (previous != null) {
        if (previous.body != text) {
          throw FieldnoteException(
            code: 'chat_request_conflict',
            message: 'This request id was already used for another message.',
          );
        }
        return previous;
      }
      if (CampaignLifecycleService.isClosed(campaign)) {
        throw FieldnoteException(
          code: 'chat_read_only',
          message: 'This campaign discussion is read-only.',
        );
      }
      await _limiter.hit(session, profile.authUserId, RateLimits.campaignChat);
      await _moderateOrThrow(session, text, 'campaignChat');
      return CampaignChatMessage.db.insertRow(
        session,
        CampaignChatMessage(
          campaignId: campaignId,
          senderAuthUserId: profile.authUserId,
          senderDisplayName: profile.displayName,
          senderIsCreator: campaign.createdBy == profile.authUserId,
          body: text,
          clientRequestId: clientRequestId,
        ),
        transaction: transaction,
      );
    });
    // Persistence is authoritative: a broadcast failure must not turn a saved
    // message into a failed send. Clients recover it from history on reconnect.
    try {
      await session.messages.postMessage(_chatChannel(campaignId), message);
    } catch (error, stack) {
      session.log(
        'Campaign chat broadcast failed.',
        level: LogLevel.warning,
        exception: error,
        stackTrace: stack,
      );
    }
    return message;
  }

  /// Newest page by default; afterId returns missed messages oldest first.
  Future<List<CampaignChatMessage>> listCampaignMessages(
    Session session,
    int campaignId, {
    int? beforeId,
    int? afterId,
    int? limit,
  }) async {
    final profile = await _requireProfile(session);
    await _requireChatMember(
      session,
      profile,
      await _campaign(session, campaignId),
    );
    if ((beforeId != null && afterId != null) ||
        (beforeId != null && beforeId <= 0) ||
        (afterId != null && afterId < 0)) {
      throw FieldnoteException(
        code: 'invalid_chat_page',
        message: 'Invalid discussion page.',
      );
    }
    return CampaignChatMessage.db.find(
      session,
      where: (t) =>
          t.campaignId.equals(campaignId) &
          (beforeId == null ? Constant.bool(true) : t.id < beforeId) &
          (afterId == null ? Constant.bool(true) : t.id > afterId),
      orderBy: (t) => afterId == null ? t.id.desc() : t.id.asc(),
      limit: (limit ?? 50).clamp(1, 100),
    );
  }

  /// Subscribe before fetching history on the client to avoid missing messages.
  Stream<CampaignChatEvent> watchCampaignChat(
    Session session,
    int campaignId,
  ) async* {
    final profile = await _requireProfile(session);
    await _requireChatMember(
      session,
      profile,
      await _campaign(session, campaignId),
    );
    final updates = StreamController<CampaignChatMessage?>();
    final subscription = session.messages
        .createStream<CampaignChatMessage>(
          _chatChannel(campaignId),
        )
        .listen(updates.add, onError: updates.addError);
    // Heartbeats recheck membership even in a quiet room, and propagate closure.
    final timer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => updates.add(null),
    );
    updates.add(null);
    try {
      await for (final message in updates.stream) {
        final campaign = await _campaign(session, campaignId);
        await _requireChatMember(session, profile, campaign);
        yield CampaignChatEvent(
          campaignId: campaignId,
          readOnly: CampaignLifecycleService.isClosed(campaign),
          message: message,
        );
      }
    } finally {
      timer.cancel();
      await subscription.cancel();
      await updates.close();
    }
  }

  static String _chatChannel(int campaignId) =>
      'fieldnote-campaign-chat-$campaignId';

  Future<CampaignPost> createCampaignPost(
    Session session,
    int campaignId,
    String title,
    String body,
  ) async {
    final sponsor = await _requireRole(session, AccountRole.sponsor);
    final campaign = await _campaign(session, campaignId);
    if (campaign.createdBy != sponsor.authUserId) {
      throw FieldnoteException(
        message: 'Only the campaign creator can publish official updates.',
        code: 'forbidden',
      );
    }
    _requireLength(title, 3, _shortTextMax, 'title');
    _requireLength(body, 3, _postBodyMax, 'update');
    await _moderateOrThrow(session, '$title\n$body', 'campaignPost');
    final post = await CampaignPost.db.insertRow(
      session,
      CampaignPost(
        campaignId: campaignId,
        authorSponsorAuthUserId: sponsor.authUserId,
        title: title.trim(),
        body: body.trim(),
      ),
    );
    await _publish(
      session,
      campaignId,
      'campaignPost',
      'A new campaign update was published.',
    );
    return post;
  }

  /// Official updates. Readable by the campaign team (creator, verified
  /// funders, volunteers holding a place) and, while the campaign is open,
  /// by anyone signed in who can already see it publicly.
  Future<List<CampaignPost>> listCampaignPosts(
    Session session,
    int campaignId, {
    int? limit,
    int? offset,
  }) async {
    final profile = await _requireProfile(session);
    final campaign = await _campaign(session, campaignId);
    if (!_isPubliclyOpen(campaign) &&
        !await _isCampaignMember(session, profile, campaign)) {
      throw FieldnoteException(
        message: 'Only the campaign team can read these updates.',
        code: 'forbidden',
      );
    }
    final page = _page(limit, offset);
    return CampaignPost.db.find(
      session,
      where: (t) => t.campaignId.equals(campaignId),
      orderBy: (t) => t.createdAt.desc(),
      limit: page.limit,
      offset: page.offset,
    );
  }

  /// Live updates for the campaign team only (creator, verified funders,
  /// volunteers holding a place). Messages never carry volunteer names.
  Stream<CampaignLiveUpdate> watchCampaign(
    Session session,
    int campaignId,
  ) async* {
    final profile = await _requireProfile(session);
    final campaign = await _campaign(session, campaignId);
    if (!await _isCampaignMember(session, profile, campaign)) {
      throw FieldnoteException(
        message: 'Only the campaign team can follow live updates.',
        code: 'forbidden',
      );
    }
    yield CampaignLiveUpdate(
      campaignId: campaignId,
      event: 'connected',
      message: 'Live campaign impact connected.',
      occurredAt: DateTime.now().toUtc(),
    );
    yield* session.messages.createStream<CampaignLiveUpdate>(
      _channel(campaignId),
    );
  }

  Future<FieldnoteUserProfile> _upsertProfile(
    Session session, {
    required AccountRole role,
    required String displayName,
    required String city,
    required List<String> interests,
    required List<String> skills,
    String? sponsorType,
    String? organizationName,
    String? contactPhone,
    String? locationAddress,
    String? locationPlaceId,
    double? locationLatitude,
    double? locationLongitude,
  }) async {
    final userId = _userId(session);
    final existing = await FieldnoteUserProfile.db.findFirstRow(
      session,
      where: (t) => t.authUserId.equals(userId),
    );
    if (existing != null && existing.role != role) {
      throw FieldnoteException(
        message: 'Account role cannot be changed after onboarding.',
        code: 'role_locked',
      );
    }
    final name = displayName.trim();
    if (name.length < 2 || name.length > _displayNameMax) {
      throw FieldnoteException(
        message: 'Enter a display name of 2–$_displayNameMax characters.',
        code: 'invalid_profile',
      );
    }
    _maxLength(city, _shortTextMax, 'city');
    _maxLength(sponsorType ?? '', 60, 'sponsor type');
    _maxLength(organizationName ?? '', _shortTextMax, 'organization name');
    _maxLength(locationAddress ?? '', 300, 'address');
    _tagList(interests, 'interests');
    _tagList(skills, 'skills');
    if (existing == null) {
      return FieldnoteUserProfile.db.insertRow(
        session,
        FieldnoteUserProfile(
          authUserId: userId,
          role: role,
          displayName: displayName.trim(),
          sponsorType: _blankToNull(sponsorType),
          organizationName: _blankToNull(organizationName),
          contactPhone: contactPhone,
          city: city.trim(),
          locationAddress: _blankToNull(locationAddress),
          locationPlaceId: _blankToNull(locationPlaceId),
          locationLatitude: locationLatitude,
          locationLongitude: locationLongitude,
          interests: interests.join(' | '),
          skills: skills.join(' | '),
        ),
      );
    }
    existing.displayName = displayName.trim();
    existing.sponsorType = _blankToNull(sponsorType);
    existing.organizationName = _blankToNull(organizationName);
    existing.contactPhone = contactPhone;
    existing.city = city.trim();
    existing.locationAddress = _blankToNull(locationAddress);
    existing.locationPlaceId = _blankToNull(locationPlaceId);
    existing.locationLatitude = locationLatitude;
    existing.locationLongitude = locationLongitude;
    existing.interests = interests.join(' | ');
    existing.skills = skills.join(' | ');
    existing.updatedAt = DateTime.now().toUtc();
    return FieldnoteUserProfile.db.updateRow(session, existing);
  }

  Future<_ProfileLocation> _verifiedSponsorLocation(
    Session session, {
    required String typedLocation,
    required String? placeId,
    double? latitude,
    double? longitude,
    FieldnoteUserProfile? current,
  }) async {
    final fallback = typedLocation.trim();
    if (fallback.length < 2) {
      throw FieldnoteException(
        message: 'Choose your location.',
        code: 'invalid_location',
      );
    }

    final apiKey = _mapsKey(session);
    if (latitude != null || longitude != null) {
      if (latitude == null || longitude == null) {
        throw FieldnoteException(
          message: 'Choose a complete map pin.',
          code: 'invalid_location',
        );
      }
      _requireValidCoordinates(latitude, longitude);
      if (apiKey == null) {
        return _ProfileLocation(
          name: fallback,
          address: fallback,
          latitude: latitude,
          longitude: longitude,
        );
      }
      try {
        final place = await _maps.reverseGeocode(
          apiKey: apiKey,
          latitude: latitude,
          longitude: longitude,
        );
        return _ProfileLocation(
          name: place.name.trim().isEmpty ? fallback : place.name.trim(),
          address: place.address.trim().isEmpty
              ? fallback
              : place.address.trim(),
          latitude: latitude,
          longitude: longitude,
        );
      } on GoogleMapsException {
        return _ProfileLocation(
          name: fallback,
          address: fallback,
          latitude: latitude,
          longitude: longitude,
        );
      }
    }
    if (apiKey == null) {
      return _ProfileLocation(name: fallback, address: fallback);
    }
    final safePlaceId = placeId?.trim() ?? '';
    final savedAddress = current?.locationAddress?.trim();
    if (safePlaceId.isEmpty &&
        (fallback == savedAddress || fallback == current?.city.trim())) {
      return _ProfileLocation(
        name: current!.city,
        address: savedAddress?.isNotEmpty == true
            ? savedAddress!
            : current.city,
        placeId: current.locationPlaceId,
        latitude: current.locationLatitude,
        longitude: current.locationLongitude,
      );
    }
    if (safePlaceId.isEmpty || safePlaceId.length > 300) {
      throw FieldnoteException(
        message: 'Select a location from the Google suggestions.',
        code: 'location_selection_required',
      );
    }

    try {
      final place = await _maps.placeDetails(
        apiKey: apiKey,
        placeId: safePlaceId,
      );
      final name = place.name.trim();
      final address = place.address.trim();
      if (name.length < 2 || address.length < 2) {
        throw const GoogleMapsException(
          'Google Places returned an incomplete location.',
        );
      }
      return _ProfileLocation(
        name: name,
        address: address,
        placeId: safePlaceId,
        latitude: place.latitude,
        longitude: place.longitude,
      );
    } on GoogleMapsException catch (error, stackTrace) {
      session.log(
        'Profile location verification failed.',
        level: LogLevel.warning,
        exception: error,
        stackTrace: stackTrace,
      );
      throw FieldnoteException(
        message: 'Google could not verify that location. Choose it again.',
        code: 'location_verification_failed',
      );
    }
  }

  Future<VolunteerAvailability> _upsertAvailability(
    Session session, {
    required bool isAvailable,
    required bool availableToday,
    required List<int> weekdays,
    required int startMinutes,
    required int endMinutes,
    required double maximumTravelKm,
    required double? latitude,
    required double? longitude,
    required String locationLabel,
    String? timezone,
    int? utcOffsetMinutes,
  }) async {
    final userId = _userId(session);
    final existing = await VolunteerAvailability.db.findFirstRow(
      session,
      where: (t) => t.volunteerAuthUserId.equals(userId),
    );
    final zone =
        FieldnoteTime.validatedZoneName(timezone) ?? existing?.timezone;
    final offset = utcOffsetMinutes == null
        ? existing?.utcOffsetMinutes
        : FieldnoteTime.validatedOffset(utcOffsetMinutes);
    // V-5: "I can help today" applies to the volunteer's current local date
    // and lapses at local midnight. Re-saving on the same day keeps it.
    final today = FieldnoteTime.todayKeyIn(
      zone: zone,
      utcOffsetMinutes: offset,
    );
    final todayDate = availableToday ? today : null;
    if (existing == null) {
      final sortedDays = weekdays.toSet().toList()..sort();
      return VolunteerAvailability.db.insertRow(
        session,
        VolunteerAvailability(
          volunteerAuthUserId: userId,
          isAvailable: isAvailable,
          availableToday: availableToday,
          weekdays: sortedDays.join(','),
          startMinutes: startMinutes,
          endMinutes: endMinutes,
          maximumTravelKm: maximumTravelKm.clamp(1, 100).toDouble(),
          latitude: latitude,
          longitude: longitude,
          locationLabel: locationLabel.trim(),
          timezone: zone,
          utcOffsetMinutes: offset,
          availableTodayDate: todayDate,
        ),
      );
    }
    existing.timezone = zone;
    existing.utcOffsetMinutes = offset;
    existing.availableTodayDate = todayDate;
    existing.isAvailable = isAvailable;
    existing.availableToday = availableToday;
    existing.weekdays = (weekdays.toSet().toList()..sort()).join(',');
    existing.startMinutes = startMinutes;
    existing.endMinutes = endMinutes;
    existing.maximumTravelKm = maximumTravelKm.clamp(1, 100).toDouble();
    existing.latitude = latitude;
    existing.longitude = longitude;
    existing.locationLabel = locationLabel.trim();
    existing.updatedAt = DateTime.now().toUtc();
    return VolunteerAvailability.db.updateRow(session, existing);
  }

  Future<FieldnoteUserProfile> _requireProfile(Session session) async {
    final profile = await FieldnoteUserProfile.db.findFirstRow(
      session,
      where: (t) => t.authUserId.equals(_userId(session)),
    );
    if (profile == null) {
      throw FieldnoteException(
        message: 'Complete account setup before continuing.',
        code: 'profile_required',
      );
    }
    return profile;
  }

  Future<FieldnoteUserProfile> _requireRole(
    Session session,
    AccountRole role,
  ) async {
    final profile = await _requireProfile(session);
    final consent = await getMyLegalConsent(session);
    if (consent == null ||
        !consent.locationConsent ||
        !consent.aiProcessingConsent ||
        !consent.evidenceSharingConsent ||
        consent.privacyPolicyVersion != privacyPolicyVersion ||
        consent.termsVersion != termsVersion) {
      throw FieldnoteException(
        message: 'Review and accept the current privacy choices to continue.',
        code: 'consent_required',
      );
    }
    if (profile.role != role) {
      throw FieldnoteException(
        message: 'This action is available to ${role.name} accounts.',
        code: 'forbidden',
      );
    }
    return profile;
  }

  Future<CampaignParticipation> _ownedParticipation(
    Session session,
    int participationId,
  ) async {
    final volunteer = await _requireRole(session, AccountRole.volunteer);
    final participation = await CampaignParticipation.db.findById(
      session,
      participationId,
    );
    if (participation == null ||
        participation.volunteerAuthUserId != volunteer.authUserId) {
      throw FieldnoteException(
        message: 'Campaign participation not found.',
        code: 'participation_not_found',
      );
    }
    return participation;
  }

  Future<Campaign> _campaign(Session session, int campaignId) async {
    final campaign = await Campaign.db.findById(session, campaignId);
    if (campaign == null) {
      throw FieldnoteException(
        message: 'Campaign not found.',
        code: 'campaign_not_found',
      );
    }
    return campaign;
  }

  CampaignMatch _matchCampaign(
    Campaign campaign,
    VolunteerAvailability availability,
    FieldnoteUserProfile volunteer,
    int participationCount, {
    RouteLeg? travel,
  }) {
    // V-5: weekday and time of day in the volunteer's own zone (DST-aware).
    final offset = FieldnoteTime.availabilityOffsetAt(
      availability,
      campaign.startsAt,
    );
    final availabilityMatches =
        availability.isAvailable &&
        FieldnoteTime.availabilityCovers(availability, campaign);

    final distance =
        availability.latitude == null || availability.longitude == null
        ? 0.0
        : _distanceMeters(
                availability.latitude!,
                availability.longitude!,
                campaign.latitude,
                campaign.longitude,
              ) /
              1000;
    final withinRadius =
        availability.latitude == null ||
        distance <= availability.maximumTravelKm;
    // The volunteer sets a radius in kilometres, so a travel-time score needs
    // an equivalent budget. 20 km/h is a realistic effective urban door-to-door
    // speed once parking and the last hundred metres on foot are included.
    final travelBudgetMinutes = math.max(
      availability.maximumTravelKm * 3,
      10.0,
    );
    final distanceScore = availability.latitude == null
        ? 15.0
        : travel != null
        ? 30 * (1 - (travel.minutes / travelBudgetMinutes).clamp(0, 1))
        : 30 *
              (1 -
                  (distance / math.max(availability.maximumTravelKm, 1)).clamp(
                    0,
                    1,
                  ));
    final interests = volunteer.interests
        .toLowerCase()
        .split('|')
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toSet();
    final tags = campaign.tags
        .toLowerCase()
        .split('|')
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toSet();
    final interestMatches = interests.intersection(tags).isNotEmpty;
    final skills = volunteer.skills
        .toLowerCase()
        .split('|')
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toSet();
    final requiredSkills = campaign.requiredSkills.toLowerCase();
    final skillMatches = skills.any(requiredSkills.contains);
    final affinityMatches = interestMatches || skillMatches;
    final hasCapacity = participationCount < campaign.volunteerCapacity;
    final isFull = !hasCapacity;
    final score =
        (availabilityMatches
            ? 40
            : availability.isAvailable
            ? 10
            : 0) +
        (withinRadius ? distanceScore : 0) +
        (affinityMatches ? 20 : 8) +
        (hasCapacity ? 10 : 0);
    final reasons = <String>[
      if (availabilityMatches)
        'Matches your ${_weekday(FieldnoteTime.localWeekday(campaign.startsAt, offset))} availability'
      else
        'Schedule does not fully overlap your saved availability',
      if (availability.latitude != null && travel != null)
        '${travel.minutes} min drive · ${travel.distanceKm.toStringAsFixed(1)} km '
            'by road — ${withinRadius ? 'inside' : 'outside'} your travel radius'
      else if (availability.latitude != null)
        withinRadius
            ? '${distance.toStringAsFixed(1)} km away — inside your travel radius'
            : '${distance.toStringAsFixed(1)} km away — outside your travel radius'
      else
        'Add GPS location for an exact distance score',
      if (interestMatches)
        'Matches your ${interests.intersection(tags).first} interest'
      else if (skillMatches)
        'Matches your ${skills.firstWhere(requiredSkills.contains)} skill'
      else
        'Broad community-impact match',
      hasCapacity
          ? '${campaign.volunteerCapacity - participationCount} volunteer places remaining'
          : 'Volunteer capacity reached',
    ];
    return CampaignMatch(
      campaign: campaign,
      score: score.clamp(0, 100).toDouble(),
      distanceKm: distance,
      availabilityMatches: availabilityMatches,
      reasons: reasons,
      travelMinutes: travel?.minutes,
      travelDistanceKm: travel?.distanceKm,
      travelMode: travel == null ? null : 'drive',
      isFull: isFull,
    );
  }

  /// D2: the single platform organization, created at most once. A
  /// transaction-scoped advisory lock serialises the first creation across
  /// instances without needing a unique index on existing data.
  Future<Organization> _platformOrganization(Session session) async {
    const name = 'FieldNote Community';
    final existing = await Organization.db.findFirstRow(
      session,
      where: (t) => t.name.equals(name),
      orderBy: (t) => t.id,
    );
    if (existing != null) return existing;
    return session.db.transaction((transaction) async {
      await session.db.unsafeQuery(
        "SELECT pg_advisory_xact_lock(hashtext('fieldnote_platform_organization'))",
        transaction: transaction,
      );
      final locked = await Organization.db.findFirstRow(
        session,
        where: (t) => t.name.equals(name),
        orderBy: (t) => t.id,
        transaction: transaction,
      );
      if (locked != null) return locked;
      return Organization.db.insertRow(
        session,
        Organization(
          name: name,
          // System sentinel: the platform organization has no human creator.
          createdBy: UuidValue.withValidation(
            '00000000-0000-4000-8000-000000000001',
          ),
        ),
        transaction: transaction,
      );
    });
  }

  Future<void> _publish(
    Session session,
    int campaignId,
    String event,
    String message,
  ) => _events.publish(session, campaignId, event, message);

  Future<void> _moderateOrThrow(
    Session session,
    String text,
    String entityType,
  ) async {
    if (text.trim().isEmpty) return;
    final decision = _moderation.evaluate(text);
    if (decision.allowed) return;
    await _audit(
      session,
      event: 'contentModeration',
      entityType: entityType,
      outcome: 'blocked',
      riskLevel: 'high',
      detail: 'Blocked categories: ${decision.categories.join(', ')}',
    );
    throw FieldnoteException(
      message:
          'This content was blocked for ${decision.categories.join(', ')}. Remove unsafe content or personal identifiers.',
      code: 'content_blocked',
    );
  }

  Future<AuditEvent> _audit(
    Session session, {
    required String event,
    required String entityType,
    String? entityId,
    required String outcome,
    required String riskLevel,
    required String detail,
  }) => _events.audit(
    session,
    actor: _userId(session),
    event: event,
    entityType: entityType,
    entityId: entityId,
    outcome: outcome,
    riskLevel: riskLevel,
    detail: detail,
  );

  UuidValue _userId(Session session) {
    final value = session.authenticated?.userIdentifier;
    if (value == null) {
      throw FieldnoteException(
        message: 'Sign in to continue.',
        code: 'unauthenticated',
      );
    }
    return UuidValue.withValidation(value);
  }

  static String _evidencePrefix(CampaignParticipation participation) =>
      'campaigns/${participation.campaignId}/participations/${participation.id}/';

  static final _random = math.Random.secure();

  /// A unique path per upload so a completed photograph is never overwritten.
  static String _evidencePath(
    CampaignParticipation participation,
    String extension,
  ) {
    final nonce = List.generate(
      12,
      (_) => _random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
    return '${_evidencePrefix(participation)}evidence-${DateTime.now().toUtc().millisecondsSinceEpoch}-$nonce.$extension';
  }

  static String _imageExtension(String value) {
    final safe = value.toLowerCase().replaceAll(RegExp('[^a-z0-9]'), '');
    if (!{'jpg', 'jpeg', 'png', 'webp'}.contains(safe)) {
      throw FieldnoteException(
        message: 'Only JPG, PNG, and WebP photographs are supported.',
        code: 'unsupported_media',
      );
    }
    return safe;
  }

  static String _channel(int campaignId) =>
      CampaignEventsService.channel(campaignId);

  static void _maxLength(String value, int max, String label) {
    if (value.trim().length > max) {
      throw FieldnoteException(
        message: 'Keep the $label under $max characters.',
        code: 'input_too_long',
      );
    }
  }

  static void _requireLength(String value, int min, int max, String label) {
    final length = value.trim().length;
    if (length < min || length > max) {
      throw FieldnoteException(
        message: 'The $label must be $min–$max characters.',
        code: 'invalid_input',
      );
    }
  }

  static void _tagList(List<String> values, String label) {
    if (values.length > _tagListMax ||
        values.any((value) => value.trim().length > _tagMax)) {
      throw FieldnoteException(
        message:
            'Choose up to $_tagListMax $label of at most $_tagMax characters each.',
        code: 'input_too_long',
      );
    }
  }

  static String? _blankToNull(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  static String _validatedContactPhone(String? value) {
    final phone = (value ?? '').replaceAll(RegExp(r'[\s()\-]'), '');
    if (!RegExp(r'^\+[1-9]\d{7,14}$').hasMatch(phone)) {
      throw FieldnoteException(
        message:
            'Enter a contact number with country code, for example +919876543210.',
        code: 'invalid_contact_phone',
      );
    }
    return phone;
  }

  static String? _validatedOptionalContactPhone(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return _validatedContactPhone(value);
  }

  /// The server-side Google Maps Platform key, or null when Maps web services
  /// are not configured. Callers must degrade instead of failing.
  static String? _mapsKey(Session session) {
    final value = session.passwords['googleMapsApiKey']?.trim();
    return value == null || value.isEmpty ? null : value;
  }

  static void _requireValidCoordinates(double latitude, double longitude) {
    if (!latitude.isFinite ||
        !longitude.isFinite ||
        latitude.abs() > 90 ||
        longitude.abs() > 180) {
      throw FieldnoteException(
        message: 'That map point is outside valid geographic bounds.',
        code: 'invalid_coordinates',
      );
    }
  }

  static AiProvider _aiPrimaryProvider(Session session) {
    final configured = session.passwords['aiPrimaryProvider']
        ?.trim()
        .toLowerCase();
    if (configured == null || configured.isEmpty || configured == 'gemini') {
      return AiProvider.gemini;
    }
    if (configured == 'groq') return AiProvider.groq;
    throw FieldnoteException(
      message: 'The configured AI provider is invalid.',
      code: 'invalid_ai_provider',
    );
  }

  static String _transcriptionModel(Session session) {
    final configured = session.passwords['geminiTranscriptionModel']?.trim();
    if (configured == null || configured.isEmpty) {
      return GeminiSpeechService.defaultModel;
    }
    if (!RegExp(r'^[a-zA-Z0-9._-]+$').hasMatch(configured)) {
      throw FieldnoteException(
        message: 'The configured transcription model name is invalid.',
        code: 'invalid_gemini_model',
      );
    }
    return configured;
  }

  static String _geminiModel(Session session) {
    final password = session.passwords['geminiModel']?.trim();
    final configured = password == null || password.isEmpty
        ? FieldnoteConfig.geminiModel
        : password;
    if (configured == null || configured.isEmpty) {
      return GeminiAiService.defaultModel;
    }
    if (!RegExp(r'^[a-zA-Z0-9._-]+$').hasMatch(configured)) {
      throw FieldnoteException(
        message: 'The configured AI model name is invalid.',
        code: 'invalid_gemini_model',
      );
    }
    return configured;
  }

  static double _distanceMeters(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const radius = 6371000.0;
    final phi1 = lat1 * math.pi / 180;
    final phi2 = lat2 * math.pi / 180;
    final dPhi = (lat2 - lat1) * math.pi / 180;
    final dLambda = (lon2 - lon1) * math.pi / 180;
    final a =
        math.sin(dPhi / 2) * math.sin(dPhi / 2) +
        math.cos(phi1) *
            math.cos(phi2) *
            math.sin(dLambda / 2) *
            math.sin(dLambda / 2);
    return radius * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  static String _weekday(int day) => const [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ][day - 1];
}

/// The 5-minute sweep: readiness cutoffs, expiry refunds, completion,
/// payment reconciliation and the refund worker. Scheduled in `server.dart`.
class CampaignReadinessFutureCall extends FutureCall {
  Future<void> sweep(Session session) async {
    await const FieldnoteSweepService().run(session);
  }
}

class _ProfileLocation {
  const _ProfileLocation({
    required this.name,
    required this.address,
    this.placeId,
    this.latitude,
    this.longitude,
  });

  final String name;
  final String address;
  final String? placeId;
  final double? latitude;
  final double? longitude;
}

class _ReachBucket {
  _ReachBucket(this.latitude, this.longitude);

  final double latitude;
  final double longitude;
  int count = 0;
  final List<VolunteerAvailability> volunteers = [];
}
