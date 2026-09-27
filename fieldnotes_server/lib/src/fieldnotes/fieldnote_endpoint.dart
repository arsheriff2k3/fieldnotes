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
import 'services/campaign_readiness_policy.dart';

class FieldnoteEndpoint extends Endpoint {
  FieldnoteEndpoint({
    StructuredSummaryService? aiService,
    GeminiAiService? geminiService,
    GeminiSpeechService? speechService,
    GroqAiService? groqService,
    ContentModerationService? moderationService,
    LocationIntegrityService? locationIntegrityService,
    RazorpayPaymentService? paymentService,
    GoogleMapsService? mapsService,
  }) : _ai = aiService ?? const StructuredSummaryService(),
       _gemini = geminiService ?? const GeminiAiService(),
       _speech = speechService ?? GeminiSpeechService(),
       _groq = groqService ?? GroqAiService(),
       _moderation = moderationService ?? const ContentModerationService(),
       _locationIntegrity =
           locationIntegrityService ?? const LocationIntegrityService(),
       _payments = paymentService ?? const RazorpayPaymentService(),
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
  final RazorpayPaymentService _payments;
  final GoogleMapsService _maps;

  /// Volunteer coverage is only ever returned to sponsors in buckets of at
  /// least this many people, rounded to roughly a kilometre.
  static const _reachCellAnonymityThreshold = 3;

  static const privacyPolicyVersion = '2026-09-22';
  static const termsVersion = '2026-09-22';

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

  Future<LegalConsent> acceptLegalConsent(
    Session session,
    bool locationConsent,
    bool aiProcessingConsent,
    bool evidenceSharingConsent,
  ) async {
    if (!locationConsent || !aiProcessingConsent || !evidenceSharingConsent) {
      throw FieldnoteException(
        message:
            'Location, AI processing, and evidence sharing consent are required to continue.',
        code: 'consent_required',
      );
    }
    final userId = _userId(session);
    final existing = await getMyLegalConsent(session);
    final now = DateTime.now().toUtc();
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
          'FieldNote keeps account data, payment references, approximate GPS evidence, and private photographs until deletion is requested.',
    );
  }

  Future<String> exportMyData(Session session) async {
    final userId = _userId(session);
    final profile = await _requireProfile(session);
    final consent = await getMyLegalConsent(session);
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
    for (final campaignId in campaignIds.difference(
      campaignNames.keys.toSet(),
    )) {
      final campaign = await Campaign.db.findById(session, campaignId);
      if (campaign != null) campaignNames[campaignId] = campaign.name;
    }
    final participationCampaigns = {
      for (final item in participations)
        if (item.id != null) item.id!: item.campaignId,
    };
    final evidence = participationCampaigns.isEmpty
        ? <CompletionEvidence>[]
        : (await CompletionEvidence.db.find(session))
              .where(
                (item) =>
                    participationCampaigns.containsKey(item.participationId),
              )
              .toList();
    final sponsorshipIds = sponsorships
        .map((item) => item.id)
        .whereType<int>()
        .toSet();
    final refunds = sponsorshipIds.isEmpty
        ? <TestRefund>[]
        : (await TestRefund.db.find(session))
              .where((item) => sponsorshipIds.contains(item.sponsorshipId))
              .toList();
    return const JsonEncoder.withIndent('  ').convert({
      'formatVersion': 2,
      'generatedAt': DateTime.now().toUtc().toIso8601String(),
      'profile': profile.toJson(),
      'consent': consent?.toJson(),
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
      'campaignPosts': posts.map((item) => item.toJson()).toList(),
      'testPayouts': payouts.map((item) => item.toJson()).toList(),
      'testRefunds': refunds.map((item) => item.toJson()).toList(),
      'securityActivity': activity.map((item) => item.toJson()).toList(),
      'mediaNotice': 'Private photographs are not embedded in this export.',
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

  Future<AuditEvent> requestAccountDeletion(Session session) {
    return _audit(
      session,
      event: 'accountDeletionRequested',
      entityType: 'account',
      outcome: 'queued',
      riskLevel: 'info',
      detail:
          'Deletion request recorded for operator review. Shared campaign records are retained until the request is processed.',
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
    String locationLabel,
  ) async {
    if (endMinutes <= startMinutes) {
      throw FieldnoteException(
        message: 'Availability end time must be after the start time.',
        code: 'invalid_availability',
      );
    }
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

  Future<VolunteerAvailability?> getMyAvailability(Session session) async {
    final profile = await _requireProfile(session);
    if (profile.role != AccountRole.volunteer) return null;
    return VolunteerAvailability.db.findFirstRow(
      session,
      where: (t) => t.volunteerAuthUserId.equals(_userId(session)),
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
    String locationLabel,
  ) async {
    await _requireRole(session, AccountRole.volunteer);
    if (weekdays.isEmpty || endMinutes <= startMinutes) {
      throw FieldnoteException(
        message: 'Choose at least one day and a valid time window.',
        code: 'invalid_availability',
      );
    }
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
    );
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

  Future<CampaignProposal> proposeCampaign(
    Session session,
    String prompt,
  ) async {
    await _requireRole(session, AccountRole.sponsor);
    if (prompt.trim().length < 20) {
      throw FieldnoteException(
        message: 'Describe the cause, place, timing, and intended impact.',
        code: 'prompt_too_short',
      );
    }
    await _moderateOrThrow(session, prompt, 'campaignPrompt');
    final now = DateTime.now();
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
    try {
      return await AiProviderRouter.run<CampaignProposal>(
        primary: _aiPrimaryProvider(session),
        gemini: apiKey == null || apiKey.isEmpty
            ? null
            : () async {
                final proposal = await _gemini.proposeCampaign(
                  apiKey: apiKey,
                  model: _geminiModel(session),
                  prompt: prompt.trim(),
                  now: now,
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
                );
                session.log('Groq campaign generation succeeded.');
                return proposal;
              },
        onFallback: (from, to) => session.log(
          '${from.name} campaign quota exhausted; trying ${to.name}.',
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
  Future<Campaign> createCampaignFromProposal(
    Session session,
    CampaignProposal proposal,
    double latitude,
    double longitude,
    String? locationName,
    double? geofenceMeters,
  ) async {
    final sponsor = await _requireRole(session, AccountRole.sponsor);
    _validatedContactPhone(sponsor.contactPhone);
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
    final campaign = await Campaign.db.insertRow(
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
        fundingGoal: proposal.fundingGoal,
        sponsoredAmount: 0,
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
      ),
    );
    await _publish(
      session,
      campaign.id!,
      'campaignPublished',
      '${campaign.name} was published.',
    );
    return campaign;
  }

  Future<List<Campaign>> listCampaigns(Session session) async {
    await _requireProfile(session);
    await _refreshDueCampaigns(session);
    final campaigns = await Campaign.db.find(
      session,
      where: (t) => t.status.equals(CampaignStatus.active),
      orderBy: (t) => t.startsAt,
    );
    final now = DateTime.now().toUtc();
    return campaigns
        .where(
          (campaign) =>
              campaign.readinessState != 'cancelled' &&
              campaign.readinessState != 'expired' &&
              now.isBefore(campaign.startsAt),
        )
        .toList();
  }

  /// Resolves a shared campaign after sign-in. The volunteer still joins via
  /// the normal capacity and readiness checks in [joinCampaign].
  Future<Campaign?> getSharedCampaign(Session session, int campaignId) async {
    await _requireProfile(session);
    if (campaignId < 1) return null;
    await _refreshDueCampaigns(session);
    final campaign = await Campaign.db.findById(session, campaignId);
    if (campaign == null ||
        campaign.status != CampaignStatus.active ||
        const {'cancelled', 'expired'}.contains(campaign.readinessState) ||
        !DateTime.now().toUtc().isBefore(campaign.startsAt)) {
      return null;
    }
    return campaign;
  }

  Future<List<Campaign>> listMyCreatedCampaigns(Session session) async {
    final profile = await _requireRole(session, AccountRole.sponsor);
    await _refreshDueCampaigns(session);
    return Campaign.db.find(
      session,
      where: (t) => t.createdBy.equals(profile.authUserId),
      orderBy: (t) => t.createdAt.desc(),
    );
  }

  Future<Campaign> refreshCampaignReadiness(
    Session session,
    int campaignId,
  ) async {
    await _requireProfile(session);
    return _refreshCampaignReadiness(session, campaignId);
  }

  Future<Campaign> reviseCampaignScope(
    Session session,
    int campaignId,
    double fundingGoal,
    int minimumVolunteers,
    String description,
  ) async {
    final sponsor = await _requireRole(session, AccountRole.sponsor);
    final note = description.trim();
    if (!fundingGoal.isFinite || fundingGoal < 100 || note.length < 20) {
      throw FieldnoteException(
        message:
            'Enter a valid revised budget and explain the smaller work scope.',
        code: 'invalid_campaign_plan',
      );
    }
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
      if (minimumVolunteers < 1 ||
          minimumVolunteers > campaign.volunteerCapacity ||
          fundingGoal + 0.001 < campaign.sponsoredAmount) {
        throw FieldnoteException(
          message:
              'Minimum team must fit the available places and the new goal cannot be below funds already recorded.',
          code: 'invalid_campaign_plan',
        );
      }
      campaign.fundingGoal = fundingGoal;
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
          campaign.status != CampaignStatus.active) {
        throw FieldnoteException(
          message: 'This campaign cannot be postponed.',
          code: 'campaign_unavailable',
        );
      }
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
    return updated;
  }

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
      campaign.readinessState = 'cancelled';
      campaign.cancelledAt = DateTime.now().toUtc();
      campaign.updatedAt = DateTime.now().toUtc();
      final verified = await Sponsorship.db.find(
        session,
        where: (t) =>
            t.campaignId.equals(campaignId) &
            t.paymentStatus.equals('verified'),
        transaction: transaction,
      );
      for (final sponsorship in verified) {
        await TestRefund.db.insertRow(
          session,
          TestRefund(
            campaignId: campaignId,
            sponsorshipId: sponsorship.id!,
            amount: sponsorship.amount,
            status: 'refund_due_test',
          ),
          transaction: transaction,
        );
      }
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
    }
    return result.campaign;
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

  Future<List<Campaign>> listMyJoinedCampaigns(Session session) async {
    final volunteer = await _requireRole(session, AccountRole.volunteer);
    await _refreshDueCampaigns(session);
    final joins = await CampaignParticipation.db.find(
      session,
      where: (t) => t.volunteerAuthUserId.equals(volunteer.authUserId),
    );
    final campaigns = <Campaign>[];
    for (final join in joins) {
      final campaign = await Campaign.db.findById(session, join.campaignId);
      if (campaign != null) campaigns.add(campaign);
    }
    return campaigns;
  }

  Future<void> _refreshDueCampaigns(Session session) async {
    final campaigns = await Campaign.db.find(
      session,
      where: (t) => t.status.equals(CampaignStatus.active),
    );
    final now = DateTime.now().toUtc();
    for (final campaign in campaigns) {
      if (campaign.readinessState == 'cancelled' ||
          campaign.readinessState == 'expired') {
        continue;
      }
      if (campaign.readinessState == 'confirmed') continue;
      if (!now.isBefore(
        campaign.startsAt.subtract(const Duration(hours: 24)),
      )) {
        await _refreshCampaignReadiness(session, campaign.id!);
      }
    }
  }

  Future<Campaign> _refreshCampaignReadiness(
    Session session,
    int campaignId,
  ) async {
    final result = await session.db.transaction((transaction) async {
      final campaign = await Campaign.db.findById(
        session,
        campaignId,
        transaction: transaction,
        lockMode: LockMode.forUpdate,
      );
      if (campaign == null) {
        throw FieldnoteException(
          message: 'Campaign not found.',
          code: 'campaign_not_found',
        );
      }
      final now = DateTime.now().toUtc();
      if (campaign.status != CampaignStatus.active ||
          const {'cancelled', 'expired'}.contains(campaign.readinessState)) {
        return (campaign: campaign, changed: false);
      }
      final joins = await CampaignParticipation.db.find(
        session,
        where: (t) => t.campaignId.equals(campaignId),
        transaction: transaction,
      );
      final joinedCount = joins
          .where(
            (join) =>
                join.confirmedRevision == campaign.revision &&
                join.status != ParticipationStatus.completed,
          )
          .length;
      final countChanged = campaign.eligibleVolunteers != joinedCount;
      campaign.eligibleVolunteers = joinedCount;
      if (campaign.readinessState == 'confirmed' ||
          now.isBefore(campaign.startsAt.subtract(const Duration(hours: 24)))) {
        if (!countChanged) return (campaign: campaign, changed: false);
        final updated = await Campaign.db.updateRow(
          session,
          campaign,
          transaction: transaction,
        );
        return (campaign: updated, changed: false);
      }
      final previous = campaign.readinessState;
      if (!now.isBefore(campaign.startsAt)) {
        campaign.readinessState = 'expired';
      } else {
        campaign.readinessState = const CampaignReadinessPolicy().evaluate(
          fundingGoal: campaign.fundingGoal,
          sponsoredAmount: campaign.sponsoredAmount,
          minimumVolunteers: campaign.minimumVolunteers,
          joinedVolunteers: joinedCount,
        );
      }
      campaign.readinessCheckedAt = now;
      campaign.decisionDueAt = campaign.readinessState == 'confirmed'
          ? null
          : campaign.startsAt;
      if (campaign.readinessState == 'confirmed') campaign.confirmedAt = now;
      campaign.updatedAt = now;
      final updated = await Campaign.db.updateRow(
        session,
        campaign,
        transaction: transaction,
      );
      return (campaign: updated, changed: previous != updated.readinessState);
    });
    if (result.changed) {
      final message = switch (result.campaign.readinessState) {
        'confirmed' =>
          'The event is confirmed. Please review the meeting details.',
        'expired' =>
          'The proposed event date passed without confirmation. Do not travel to the work site.',
        _ =>
          'The event date is awaiting an organizer decision. Please check again before travelling.',
      };
      await _readinessNotice(session, result.campaign, message);
    }
    return result.campaign;
  }

  Future<void> _readinessNotice(
    Session session,
    Campaign campaign,
    String message,
  ) async {
    await CampaignPost.db.insertRow(
      session,
      CampaignPost(
        campaignId: campaign.id!,
        authorSponsorAuthUserId: campaign.createdBy,
        title: 'Campaign schedule update',
        body: message,
      ),
    );
    await _publish(session, campaign.id!, 'campaignReadiness', message);
  }

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
            'Place search is not configured. Add googleMapsApiKey to Serverpod '
            'passwords, or drag the pin on the map instead.',
        code: 'maps_not_configured',
      );
    }
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
    await _requireRole(session, AccountRole.sponsor);
    _requireValidCoordinates(latitude, longitude);
    final availabilities = await VolunteerAvailability.db.find(
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
      availableVolunteers: availabilities.length,
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
          '${distances.length} of ${availabilities.length} available volunteers '
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
    final joined = await CampaignParticipation.db.find(
      session,
      where: (t) => t.campaignId.equals(campaignId),
    );
    final joinedIds = joined.map((item) => item.volunteerAuthUserId).toSet();
    final invitations = await CampaignInvitation.db.find(
      session,
      where: (t) => t.campaignId.equals(campaignId),
    );
    final invitedIds = invitations
        .map((item) => item.volunteerAuthUserId)
        .toSet();
    final availabilities = await VolunteerAvailability.db.find(session);
    final availabilityByUser = {
      for (final availability in availabilities)
        availability.volunteerAuthUserId: availability,
    };
    final visibleIds = {...joinedIds};
    for (final availability in availabilities) {
      if (campaign.status == CampaignStatus.active &&
          DateTime.now().toUtc().isBefore(campaign.startsAt) &&
          availability.isAvailable &&
          _availabilityCoversCampaign(availability, campaign) &&
          availability.latitude != null &&
          availability.longitude != null &&
          _distanceMeters(
                    availability.latitude!,
                    availability.longitude!,
                    campaign.latitude,
                    campaign.longitude,
                  ) /
                  1000 <=
              availability.maximumTravelKm) {
        visibleIds.add(availability.volunteerAuthUserId);
      }
    }
    final volunteers = <CampaignVolunteerMapMember>[];
    for (final userId in visibleIds) {
      final profile = await FieldnoteUserProfile.db.findFirstRow(
        session,
        where: (t) => t.authUserId.equals(userId),
      );
      if (profile == null || profile.role != AccountRole.volunteer) continue;
      final availability = availabilityByUser[userId];
      final latitude = availability?.isAvailable == true
          ? availability?.latitude
          : null;
      final longitude = availability?.isAvailable == true
          ? availability?.longitude
          : null;
      volunteers.add(
        CampaignVolunteerMapMember(
          profileId: profile.id!,
          displayName: profile.displayName,
          areaLabel: latitude == null || longitude == null
              ? 'Area not shared'
              : 'Approximate area',
          latitude: latitude == null
              ? null
              : double.parse(latitude.toStringAsFixed(2)),
          longitude: longitude == null
              ? null
              : double.parse(longitude.toStringAsFixed(2)),
          status: joinedIds.contains(userId)
              ? 'joined'
              : invitedIds.contains(userId)
              ? 'invited'
              : 'available',
        ),
      );
    }
    volunteers.sort((a, b) {
      const order = {'joined': 0, 'available': 1, 'invited': 2};
      final statusOrder = (order[a.status] ?? 3).compareTo(
        order[b.status] ?? 3,
      );
      return statusOrder != 0
          ? statusOrder
          : a.displayName.compareTo(b.displayName);
    });
    final joinedCount = volunteers
        .where((person) => person.status == 'joined')
        .length;
    final inviteableCount = volunteers
        .where((person) => person.status == 'available')
        .length;
    return CampaignVolunteerMap(
      volunteers: volunteers,
      summary:
          '$joinedCount joined · $inviteableCount ready to invite · ${volunteers.length} shown',
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
    if (campaign.status != CampaignStatus.active ||
        !DateTime.now().toUtc().isBefore(campaign.startsAt) ||
        const {'cancelled', 'expired'}.contains(campaign.readinessState)) {
      throw FieldnoteException(
        message: 'This campaign is no longer open for invitations.',
        code: 'campaign_unavailable',
      );
    }
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
        !_availabilityCoversCampaign(availability, campaign) ||
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
    if (campaign.status != CampaignStatus.active ||
        !DateTime.now().toUtc().isBefore(campaign.startsAt) ||
        const {'cancelled', 'expired'}.contains(campaign.readinessState)) {
      throw FieldnoteException(
        message: 'This campaign is no longer open for invitations.',
        code: 'campaign_unavailable',
      );
    }
    _requireValidCoordinates(areaLatitude, areaLongitude);
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
    var invited = 0;
    for (final availability in group.volunteers) {
      final existing = await CampaignInvitation.db.findFirstRow(
        session,
        where: (t) =>
            t.campaignId.equals(campaignId) &
            t.volunteerAuthUserId.equals(availability.volunteerAuthUserId),
      );
      if (existing != null) continue;
      await CampaignInvitation.db.insertRow(
        session,
        CampaignInvitation(
          campaignId: campaignId,
          volunteerAuthUserId: availability.volunteerAuthUserId,
          sponsorAuthUserId: sponsor.authUserId,
        ),
      );
      invited++;
    }
    return invited;
  }

  Future<List<CampaignInvitation>> listMyCampaignInvitations(
    Session session,
  ) async {
    final volunteer = await _requireRole(session, AccountRole.volunteer);
    return CampaignInvitation.db.find(
      session,
      where: (t) => t.volunteerAuthUserId.equals(volunteer.authUserId),
      orderBy: (t) => t.createdAt.desc(),
    );
  }

  Future<Map<String, _ReachBucket>> _eligibleVolunteerReachGroups(
    Session session,
    Campaign campaign,
  ) async {
    final availabilities = await VolunteerAvailability.db.find(
      session,
      where: (t) => t.isAvailable.equals(true),
    );
    final joined = await CampaignParticipation.db.find(
      session,
      where: (t) => t.campaignId.equals(campaign.id!),
    );
    final joinedIds = joined.map((item) => item.volunteerAuthUserId).toSet();
    final groups = <String, _ReachBucket>{};
    for (final availability in availabilities) {
      final latitude = availability.latitude;
      final longitude = availability.longitude;
      if (latitude == null ||
          longitude == null ||
          !_availabilityCoversCampaign(availability, campaign) ||
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

  bool _availabilityCoversCampaign(
    VolunteerAvailability availability,
    Campaign campaign,
  ) {
    final start = campaign.startsAt.toLocal();
    final end =
        campaign.endsAt?.toLocal() ?? start.add(const Duration(hours: 3));
    final now = DateTime.now();
    final today =
        start.year == now.year &&
        start.month == now.month &&
        start.day == now.day;
    final days = availability.weekdays
        .split(',')
        .map(int.tryParse)
        .whereType<int>()
        .toSet();
    return (days.contains(start.weekday) ||
            (availability.availableToday && today)) &&
        availability.startMinutes <= start.hour * 60 + start.minute &&
        availability.endMinutes >= end.hour * 60 + end.minute;
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

  Future<RazorpayCheckoutOrder> createRazorpayOrder(
    Session session,
    int campaignId,
    double amount,
    String? message,
  ) async {
    final sponsor = await _requireRole(session, AccountRole.sponsor);
    if (!amount.isFinite || amount < 1 || amount > 1000000) {
      throw FieldnoteException(
        message: 'Choose a sponsorship between ₹1 and ₹10,00,000.',
        code: 'invalid_amount',
      );
    }
    final campaign = await _refreshCampaignReadiness(session, campaignId);
    final remainingAmount = campaign.fundingGoal - campaign.sponsoredAmount;
    if (campaign.status != CampaignStatus.active ||
        const {'cancelled', 'expired'}.contains(campaign.readinessState) ||
        !DateTime.now().toUtc().isBefore(campaign.startsAt)) {
      throw FieldnoteException(
        message: 'This campaign is closed to new payments.',
        code: 'campaign_unavailable',
      );
    }
    if (remainingAmount <= 0) {
      throw FieldnoteException(
        message: 'This campaign is already fully funded.',
        code: 'campaign_fully_funded',
      );
    }
    if (amount > remainingAmount + 0.001) {
      throw FieldnoteException(
        message:
            'Choose an amount up to the remaining campaign balance of '
            '₹${remainingAmount.toStringAsFixed(2)}.',
        code: 'amount_exceeds_campaign_balance',
      );
    }
    await _moderateOrThrow(session, message ?? '', 'sponsorMessage');
    final keyId = _requiredPassword(session, 'razorpayKeyId');
    final keySecret = _requiredPassword(session, 'razorpayKeySecret');
    final amountPaise = (amount * 100).round();
    final receipt = 'fn_${campaignId}_${DateTime.now().microsecondsSinceEpoch}';
    late final RazorpayOrderResult order;
    try {
      order = await _payments.createOrder(
        keyId: keyId,
        keySecret: keySecret,
        amountPaise: amountPaise,
        receipt: receipt,
        campaignId: campaignId,
      );
    } on RazorpayPaymentException catch (error, stackTrace) {
      session.log(
        'Razorpay order creation failed: ${error.message}',
        level: LogLevel.warning,
        stackTrace: stackTrace,
      );
      await _audit(
        session,
        event: 'paymentOrderCreate',
        entityType: 'campaign',
        entityId: '$campaignId',
        outcome: 'failed',
        riskLevel: 'warning',
        detail: error.message,
      );
      throw FieldnoteException(
        message:
            'Razorpay could not create the test order. Check the test keys and server connection.',
        code: 'razorpay_unavailable',
      );
    }
    final sponsorship = await Sponsorship.db.insertRow(
      session,
      Sponsorship(
        campaignId: campaignId,
        sponsorAuthUserId: sponsor.authUserId,
        amount: order.amountPaise / 100,
        message: _blankToNull(message),
        paymentProvider: 'razorpay',
        paymentStatus: 'created',
        providerOrderId: order.id,
      ),
    );
    await _audit(
      session,
      event: 'paymentOrderCreated',
      entityType: 'sponsorship',
      entityId: '${sponsorship.id}',
      outcome: 'created',
      riskLevel: 'info',
      detail: 'Razorpay order ${order.id} created for $amountPaise paise.',
    );
    return RazorpayCheckoutOrder(
      sponsorshipId: sponsorship.id!,
      orderId: order.id,
      keyId: keyId,
      amountPaise: order.amountPaise,
      currency: order.currency,
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
            'This payment succeeded but could not be credited. It needs review.',
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
    final verified = _payments.verifySignature(
      orderId: sponsorship.providerOrderId!,
      paymentId: paymentId,
      signature: signature,
      keySecret: _requiredPassword(session, 'razorpayKeySecret'),
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
    final result = await const PaymentCreditService().credit(
      session,
      sponsorshipId: sponsorshipId,
      campaignId: sponsorship.campaignId,
      sponsorAuthUserId: sponsor.authUserId,
      orderId: orderId,
      paymentId: paymentId,
    );
    if (result.uncredited) {
      await _audit(
        session,
        event: 'paymentVerifiedWithoutCredit',
        entityType: 'sponsorship',
        entityId: '$sponsorshipId',
        outcome: 'requires_review',
        riskLevel: 'warning',
        detail:
            'A valid test payment could not be credited because the campaign closed or its goal was reached.',
      );
      throw FieldnoteException(
        message:
            'Payment succeeded, but the campaign could not be credited. This payment needs review.',
        code: 'payment_uncredited',
      );
    }
    final updated = result.sponsorship;
    if (result.alreadyVerified) return updated;
    await _refreshCampaignReadiness(session, updated.campaignId);
    await _publish(
      session,
      updated.campaignId,
      'sponsorshipAdded',
      'A Razorpay-verified sponsorship of ₹${sponsorship.amount.toStringAsFixed(0)} was recorded.',
    );
    await _audit(
      session,
      event: 'paymentSignatureVerified',
      entityType: 'sponsorship',
      entityId: '$sponsorshipId',
      outcome: 'verified',
      riskLevel: 'info',
      detail: 'Server signature verification passed for payment $paymentId.',
    );
    return updated;
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
    final updated = await const PaymentCreditService().markFailed(
      session,
      sponsorshipId: sponsorshipId,
      sponsorAuthUserId: sponsor.authUserId,
      status: 'failed',
    );
    if (updated.paymentStatus == 'verified' ||
        updated.paymentStatus == 'verified_uncredited') {
      return updated;
    }
    final safeReason = reason.trim().replaceAll(RegExp(r'\s+'), ' ');
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

  Future<List<Sponsorship>> listMySponsorships(Session session) async {
    final sponsor = await _requireRole(session, AccountRole.sponsor);
    return Sponsorship.db.find(
      session,
      where: (t) => t.sponsorAuthUserId.equals(sponsor.authUserId),
      orderBy: (t) => t.createdAt.desc(),
    );
  }

  /// Creator-only demonstration ledger. These rows never initiate a bank
  /// transfer or call Razorpay Route.
  Future<List<TestPayout>> listCampaignTestPayouts(
    Session session,
    int campaignId,
  ) async {
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
    if (!_requiredPassword(session, 'razorpayKeyId').startsWith('rzp_test_')) {
      throw FieldnoteException(
        message:
            'Payout simulation is available only with Razorpay Test Mode keys.',
        code: 'test_mode_required',
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
      if (campaign.readinessState != 'confirmed' &&
          campaign.status != CampaignStatus.completed) {
        throw FieldnoteException(
          message: 'Confirm the event before simulating a creator payout.',
          code: 'campaign_not_confirmed',
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
      for (final payment in verified) {
        if (processed.contains(payment.id) ||
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
            amount: payment.amount,
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
    final campaigns = await listCampaigns(session);

    // Straight-line distance is the admission filter: it is free, offline, and
    // never depends on a third party being reachable. It also bounds how many
    // destinations the billed Routes call has to price.
    final candidates = <(Campaign, int)>[];
    for (final campaign in campaigns) {
      final participations = await CampaignParticipation.db.find(
        session,
        where: (t) => t.campaignId.equals(campaign.id!),
      );
      final preview = _matchCampaign(
        campaign,
        availability,
        volunteer,
        participations.length,
      );
      if (preview.distanceKm <= availability.maximumTravelKm) {
        candidates.add((campaign, participations.length));
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
    matches.sort((a, b) => b.score.compareTo(a.score));
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
      if (existing != null) return (participation: existing, joined: false);
      final current = await CampaignParticipation.db.find(
        session,
        where: (t) => t.campaignId.equals(campaignId),
        transaction: transaction,
      );
      if (current.length >= campaign.volunteerCapacity) {
        throw FieldnoteException(
          message: 'This campaign has reached volunteer capacity.',
          code: 'campaign_full',
        );
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
      '${volunteer.displayName} joined the campaign.',
    );
    return result.participation;
  }

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
    Session session,
  ) async {
    final volunteer = await _requireRole(session, AccountRole.volunteer);
    return CampaignParticipation.db.find(
      session,
      where: (t) => t.volunteerAuthUserId.equals(volunteer.authUserId),
      orderBy: (t) => t.joinedAt.desc(),
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
    await _ownedParticipation(session, participationId);
    if (note.trim().length < 8) {
      throw FieldnoteException(
        message: 'Describe the completed work in a little more detail.',
        code: 'note_too_short',
      );
    }
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
      throw FieldnoteException(
        message: 'AI evidence analysis is unavailable. Try again later.',
        code: 'ai_not_configured',
      );
    }
    try {
      return await AiProviderRouter.run<CompletionProposal>(
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
    } on GeminiAiException catch (error, stackTrace) {
      session.log(
        'Gemini completion analysis failed.',
        level: LogLevel.warning,
        exception: error,
        stackTrace: stackTrace,
      );
      throw FieldnoteException(
        message:
            'AI evidence analysis is temporarily unavailable. Try again later.',
        code: 'gemini_unavailable',
      );
    } on GroqAiException catch (error, stackTrace) {
      session.log(
        'Groq evidence analysis failed.',
        level: LogLevel.warning,
        exception: error,
        stackTrace: stackTrace,
      );
      throw FieldnoteException(
        message:
            'AI evidence analysis is temporarily unavailable. Try again later.',
        code: 'ai_unavailable',
      );
    }
  }

  Future<String> getEvidenceUploadDescription(
    Session session,
    int participationId,
    String extension,
  ) async {
    final participation = await _ownedParticipation(session, participationId);
    final safe = _imageExtension(extension);
    final path = _evidencePath(participation, safe);
    return session.storage.createUploadDescription(
      storageId: 'private',
      path: path,
    );
  }

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
    DateTime capturedAt,
  ) async {
    final participation = await _ownedParticipation(session, participationId);
    if (participation.status != ParticipationStatus.checkedIn) {
      throw FieldnoteException(
        message: 'GPS check-in is required before completion.',
        code: 'check_in_required',
      );
    }
    await _moderateOrThrow(
      session,
      '$originalNote\n$confirmedSummary\n${structuredResults.join('\n')}',
      'completionEvidence',
    );
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
    final safe = _imageExtension(photoExtension);
    final path = _evidencePath(participation, safe);
    final verified = await session.storage.verifyUpload(
      storageId: 'private',
      path: path,
    );
    if (!verified) {
      throw FieldnoteException(
        message: 'Upload and verify a photograph before completing the work.',
        code: 'photo_required',
      );
    }
    final existing = await CompletionEvidence.db.findFirstRow(
      session,
      where: (t) => t.participationId.equals(participationId),
    );
    if (existing != null) return existing;
    final evidence = await CompletionEvidence.db.insertRow(
      session,
      CompletionEvidence(
        participationId: participationId,
        photographPath: path,
        originalNote: originalNote.trim(),
        confirmedSummary: confirmedSummary.trim(),
        structuredResults: structuredResults.join(' | '),
        latitude: latitude,
        longitude: longitude,
        locationAccuracyMeters: accuracyMeters,
        locationIntegrityStatus: integrity.status,
        locationIntegrityReasons: integrity.reasons.join(' | '),
        locationIsDemo: explicitDemo,
        moderationStatus: 'passed',
      ),
    );
    participation.status = ParticipationStatus.completed;
    participation.completedAt = DateTime.now().toUtc();
    await CampaignParticipation.db.updateRow(session, participation);
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
      detail: 'Moderation passed. ${integrity.reasons.join('; ')}',
    );
    return evidence;
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
    final allEvidence = await CompletionEvidence.db.find(
      session,
      orderBy: (t) => t.submittedAt.desc(),
    );
    final evidence = allEvidence
        .where((item) => ids.contains(item.participationId))
        .toList();
    final completed = participations
        .where((item) => item.status == ParticipationStatus.completed)
        .length;
    return ImpactSummary(
      campaignId: campaignId,
      sponsorshipTotal: campaign.sponsoredAmount,
      fundingGoal: campaign.fundingGoal,
      joinedVolunteers: participations.length,
      completedVolunteers: completed,
      evidenceCount: evidence.length,
      summary: _ai.impactSummary(
        completedVolunteers: completed,
        evidence: evidence,
      ),
      recentEvidence: evidence.take(6).toList(),
    );
  }

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

  Future<List<CampaignPost>> listCampaignPosts(
    Session session,
    int campaignId,
  ) async {
    await _requireProfile(session);
    await _campaign(session, campaignId);
    return CampaignPost.db.find(
      session,
      where: (t) => t.campaignId.equals(campaignId),
      orderBy: (t) => t.createdAt.desc(),
    );
  }

  Stream<CampaignLiveUpdate> watchCampaign(
    Session session,
    int campaignId,
  ) async* {
    await _requireProfile(session);
    await _campaign(session, campaignId);
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
    if (displayName.trim().length < 2) {
      throw FieldnoteException(
        message: 'Enter a valid display name.',
        code: 'invalid_profile',
      );
    }
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
  }) async {
    final userId = _userId(session);
    final existing = await VolunteerAvailability.db.findFirstRow(
      session,
      where: (t) => t.volunteerAuthUserId.equals(userId),
    );
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
        ),
      );
    }
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
    final days = availability.weekdays
        .split(',')
        .map(int.tryParse)
        .whereType<int>()
        .toSet();
    final startMinutes =
        campaign.startsAt.toLocal().hour * 60 +
        campaign.startsAt.toLocal().minute;
    final end =
        campaign.endsAt?.toLocal() ??
        campaign.startsAt.toLocal().add(const Duration(hours: 3));
    final endMinutes = end.hour * 60 + end.minute;
    final localStart = campaign.startsAt.toLocal();
    final localNow = DateTime.now();
    final isToday =
        localStart.year == localNow.year &&
        localStart.month == localNow.month &&
        localStart.day == localNow.day;
    final dayMatches =
        days.contains(localStart.weekday) ||
        (availability.availableToday && isToday);
    final timeMatches =
        availability.startMinutes <= startMinutes &&
        availability.endMinutes >= endMinutes;
    final availabilityMatches =
        availability.isAvailable && dayMatches && timeMatches;

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
        'Matches your ${_weekday(campaign.startsAt.toLocal().weekday)} availability'
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
    );
  }

  Future<Organization> _platformOrganization(Session session) async {
    final existing = await Organization.db.findFirstRow(
      session,
      where: (t) => t.name.equals('FieldNote Community'),
    );
    if (existing != null) return existing;
    return Organization.db.insertRow(
      session,
      Organization(
        name: 'FieldNote Community',
        createdBy: UuidValue.withValidation(
          '00000000-0000-4000-8000-000000000001',
        ),
      ),
    );
  }

  Future<void> _publish(
    Session session,
    int campaignId,
    String event,
    String message,
  ) async {
    await session.messages.postMessage(
      _channel(campaignId),
      CampaignLiveUpdate(
        campaignId: campaignId,
        event: event,
        message: message,
        occurredAt: DateTime.now().toUtc(),
      ),
    );
  }

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
  }) async {
    final item = await AuditEvent.db.insertRow(
      session,
      AuditEvent(
        actorAuthUserId: _userId(session),
        event: event,
        entityType: entityType,
        entityId: entityId,
        outcome: outcome,
        riskLevel: riskLevel,
        detail: detail,
      ),
    );
    session.log(
      jsonEncode({
        'event': event,
        'entityType': entityType,
        'entityId': entityId,
        'outcome': outcome,
        'riskLevel': riskLevel,
      }),
      level: riskLevel == 'high' ? LogLevel.warning : LogLevel.info,
    );
    return item;
  }

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

  static String _evidencePath(
    CampaignParticipation participation,
    String extension,
  ) =>
      'campaigns/${participation.campaignId}/participations/${participation.id}/evidence.$extension';

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

  static String _channel(int campaignId) => 'fieldnote-campaign-$campaignId';

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

  static String _requiredPassword(Session session, String name) {
    final value = session.passwords[name]?.trim();
    if (value == null || value.isEmpty) {
      throw FieldnoteException(
        message:
            'Razorpay is not configured on the server. Add $name to Serverpod passwords.',
        code: 'payment_not_configured',
      );
    }
    return value;
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
    final configured = session.passwords['geminiModel']?.trim();
    if (configured == null || configured.isEmpty) return 'gemini-3.8-flash';
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

/// Runs the cutoff check without relying on a user opening the app.
class CampaignReadinessFutureCall extends FutureCall {
  Future<void> sweep(Session session) async {
    await FieldnoteEndpoint()._refreshDueCampaigns(session);
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
