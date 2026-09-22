import 'dart:math' as math;
import 'dart:convert';
import 'dart:typed_data';

import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import 'services/content_moderation_service.dart';
import 'services/gemini_ai_service.dart';
import 'services/gemini_speech_service.dart';
import 'services/hackathon_ai_service.dart';
import 'services/location_integrity_service.dart';
import 'services/razorpay_payment_service.dart';

class FieldnoteEndpoint extends Endpoint {
  FieldnoteEndpoint({
    HackathonAiService? aiService,
    GeminiAiService? geminiService,
    GeminiSpeechService? speechService,
    ContentModerationService? moderationService,
    LocationIntegrityService? locationIntegrityService,
    RazorpayPaymentService? paymentService,
  }) : _ai = aiService ?? const HackathonAiService(),
       _gemini = geminiService ?? const GeminiAiService(),
       _speech = speechService ?? GeminiSpeechService(),
       _moderation = moderationService ?? const ContentModerationService(),
       _locationIntegrity =
           locationIntegrityService ?? const LocationIntegrityService(),
       _payments = paymentService ?? const RazorpayPaymentService();

  final HackathonAiService _ai;
  final GeminiAiService _gemini;
  final GeminiSpeechService _speech;
  final ContentModerationService _moderation;
  final LocationIntegrityService _locationIntegrity;
  final RazorpayPaymentService _payments;

  static const privacyPolicyVersion = '2026-09-22';
  static const termsVersion = '2026-09-22';

  @override
  bool get requireLogin => true;

  Future<FieldnoteUserProfile?> getMyProfile(Session session) async {
    await _ensureDemoCampaigns(session);
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
            'Location, AI processing, and evidence sharing consent are required for this demo workflow.',
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
          'Freshness, coordinate bounds, accuracy, device mock flags, geofence, and movement continuity are checked. Demo GPS is always labeled.',
      moderationProtection:
          'Unsafe text and exposed identifiers are blocked before storage; Gemini provider safety also applies to AI requests.',
      paymentProtection:
          'Razorpay orders are created by the server and successful checkout signatures are verified server-side before impact totals change.',
      retentionNotice:
          'This local MVP keeps account, payment references, approximate GPS evidence, and private photographs until deletion is requested.',
    );
  }

  Future<String> exportMyData(Session session) async {
    final userId = _userId(session);
    final profile = await _requireProfile(session);
    final consent = await getMyLegalConsent(session);
    final sponsorships = await Sponsorship.db.find(
      session,
      where: (t) => t.sponsorAuthUserId.equals(userId),
    );
    final participations = await CampaignParticipation.db.find(
      session,
      where: (t) => t.volunteerAuthUserId.equals(userId),
    );
    await _audit(
      session,
      event: 'privacyDataExported',
      entityType: 'account',
      outcome: 'completed',
      riskLevel: 'info',
      detail: 'The user generated a portable JSON summary of their data.',
    );
    return const JsonEncoder.withIndent('  ').convert({
      'generatedAt': DateTime.now().toUtc().toIso8601String(),
      'profile': profile.toJson(),
      'consent': consent?.toJson(),
      'sponsorships': sponsorships.map((item) => item.toJson()).toList(),
      'participations': participations.map((item) => item.toJson()).toList(),
    });
  }

  Future<AuditEvent> requestAccountDeletion(Session session) {
    return _audit(
      session,
      event: 'accountDeletionRequested',
      entityType: 'account',
      outcome: 'queued',
      riskLevel: 'info',
      detail:
          'Deletion request recorded for operator review. Local demo data has not yet been erased.',
    );
  }

  Future<FieldnoteUserProfile> completeSponsorProfile(
    Session session,
    String displayName,
    String sponsorType,
    String? organizationName,
    String city,
    List<String> interests,
  ) async {
    return _upsertProfile(
      session,
      role: AccountRole.sponsor,
      displayName: displayName,
      sponsorType: sponsorType,
      organizationName: organizationName,
      city: city,
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
    if (apiKey == null || apiKey.isEmpty) {
      throw FieldnoteException(
        message:
            'Speech transcription is not configured. Add geminiApiKey to Serverpod passwords, or type the brief instead.',
        code: 'transcription_not_configured',
      );
    }
    try {
      final transcript = await _speech.transcribe(
        apiKey: apiKey,
        model: _transcriptionModel(session),
        audio: audio,
        fileName: safeName,
        mimeType: safeMime,
      );
      session.log(
        'Dictation transcribed with ${_transcriptionModel(session)} '
        '(${audio.lengthInBytes} bytes).',
      );
      return transcript;
    } on SpeechTranscriptionException catch (error, stackTrace) {
      session.log(
        'Dictation transcription failed.',
        level: LogLevel.warning,
        exception: error,
        stackTrace: stackTrace,
      );
      throw FieldnoteException(
        message: error.message,
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
    if (apiKey == null || apiKey.isEmpty) {
      return _ai.proposeCampaign(prompt.trim(), now);
    }
    try {
      final proposal = await _gemini.proposeCampaign(
        apiKey: apiKey,
        model: _geminiModel(session),
        prompt: prompt.trim(),
        now: now,
      );
      session.log(
        'Gemini campaign generation succeeded with ${_geminiModel(session)}.',
      );
      return proposal;
    } on GeminiAiException catch (error, stackTrace) {
      session.log(
        'Gemini campaign generation failed.',
        level: LogLevel.warning,
        exception: error,
        stackTrace: stackTrace,
      );
      throw FieldnoteException(
        message:
            'Gemini could not generate this campaign. Check the API key, model, quota, and server connection.',
        code: 'gemini_unavailable',
      );
    }
  }

  Future<Campaign> createCampaignFromProposal(
    Session session,
    CampaignProposal proposal,
    double latitude,
    double longitude,
  ) async {
    final sponsor = await _requireRole(session, AccountRole.sponsor);
    await _moderateOrThrow(
      session,
      '${proposal.title}\n${proposal.description}\n${proposal.checklist.join('\n')}',
      'campaignProposal',
    );
    final organization = await _platformOrganization(session);
    final start = proposal.startsAt.toUtc();
    final campaign = await Campaign.db.insertRow(
      session,
      Campaign(
        organizationId: organization.id!,
        name: proposal.title.trim(),
        description: proposal.description.trim(),
        locationName: proposal.locationName.trim(),
        startsAt: start,
        endsAt: start.add(Duration(minutes: proposal.durationMinutes)),
        status: CampaignStatus.active,
        createdBy: sponsor.authUserId,
        fundingGoal: proposal.fundingGoal,
        sponsoredAmount: 0,
        latitude: latitude,
        longitude: longitude,
        geofenceMeters: 200,
        volunteerCapacity: proposal.volunteerCapacity,
        requiredSkills: proposal.requiredSkills.join(' | '),
        checklist: proposal.checklist.join(' | '),
        evidenceInstructions: proposal.evidenceInstructions,
        tags: proposal.tags.join(' | '),
        aiGenerated: true,
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
    await _ensureDemoCampaigns(session);
    return Campaign.db.find(
      session,
      where: (t) => t.status.equals(CampaignStatus.active),
      orderBy: (t) => t.startsAt,
    );
  }

  Future<List<Campaign>> listMyCreatedCampaigns(Session session) async {
    final profile = await _requireRole(session, AccountRole.sponsor);
    return Campaign.db.find(
      session,
      where: (t) => t.createdBy.equals(profile.authUserId),
      orderBy: (t) => t.createdAt.desc(),
    );
  }

  Future<RazorpayCheckoutOrder> createRazorpayOrder(
    Session session,
    int campaignId,
    double amount,
    String? message,
  ) async {
    final sponsor = await _requireRole(session, AccountRole.sponsor);
    if (!amount.isFinite || amount < 100 || amount > 1000000) {
      throw FieldnoteException(
        message: 'Choose a sponsorship between ₹100 and ₹10,00,000.',
        code: 'invalid_amount',
      );
    }
    final campaign = await _campaign(session, campaignId);
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
      detail:
          'Razorpay Test Mode order ${order.id} created for $amountPaise paise.',
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
    if (sponsorship.paymentStatus == 'verified') return sponsorship;
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
      sponsorship.paymentStatus = 'verification_failed';
      await Sponsorship.db.updateRow(session, sponsorship);
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
    sponsorship.paymentStatus = 'verified';
    sponsorship.providerPaymentId = paymentId;
    sponsorship.verifiedAt = DateTime.now().toUtc();
    final updated = await Sponsorship.db.updateRow(session, sponsorship);
    final campaign = await _campaign(session, sponsorship.campaignId);
    campaign.sponsoredAmount += sponsorship.amount;
    campaign.updatedAt = DateTime.now().toUtc();
    await Campaign.db.updateRow(session, campaign);
    await _publish(
      session,
      campaign.id!,
      'sponsorshipAdded',
      'A Razorpay-verified Test Mode sponsorship of ₹${sponsorship.amount.toStringAsFixed(0)} was recorded.',
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
    if (sponsorship.paymentStatus == 'verified') return sponsorship;
    sponsorship.paymentStatus = 'failed';
    final updated = await Sponsorship.db.updateRow(session, sponsorship);
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
    final matches = <CampaignMatch>[];
    for (final campaign in campaigns) {
      final participations = await CampaignParticipation.db.find(
        session,
        where: (t) => t.campaignId.equals(campaign.id!),
      );
      final match = _matchCampaign(
        campaign,
        availability,
        volunteer,
        participations.length,
      );
      if (match.distanceKm <= availability.maximumTravelKm) {
        matches.add(match);
      }
    }
    matches.sort((a, b) => b.score.compareTo(a.score));
    return matches;
  }

  Future<CampaignParticipation> joinCampaign(
    Session session,
    int campaignId,
  ) async {
    final volunteer = await _requireRole(session, AccountRole.volunteer);
    final campaign = await _campaign(session, campaignId);
    final existing = await CampaignParticipation.db.findFirstRow(
      session,
      where: (t) =>
          t.campaignId.equals(campaignId) &
          t.volunteerAuthUserId.equals(volunteer.authUserId),
    );
    if (existing != null) return existing;
    final current = await CampaignParticipation.db.find(
      session,
      where: (t) => t.campaignId.equals(campaignId),
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
      ),
    );
    await _publish(
      session,
      campaignId,
      'volunteerJoined',
      '${volunteer.displayName} joined the campaign.',
    );
    return participation;
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
    final campaign = await _campaign(session, participation.campaignId);
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
    if (apiKey == null || apiKey.isEmpty) {
      return _ai.analyzeCompletion(note.trim());
    }
    try {
      final proposal = await _gemini.analyzeCompletion(
        apiKey: apiKey,
        model: _geminiModel(session),
        note: note.trim(),
        photograph: photograph,
        photographMimeType: photographMimeType,
      );
      session.log(
        'Gemini multimodal evidence analysis succeeded with ${_geminiModel(session)}.',
      );
      return proposal;
    } on GeminiAiException catch (error, stackTrace) {
      session.log(
        'Gemini completion analysis failed.',
        level: LogLevel.warning,
        exception: error,
        stackTrace: stackTrace,
      );
      throw FieldnoteException(
        message:
            'Gemini could not analyze this evidence. Check the API key, model, quota, and server connection.',
        code: 'gemini_unavailable',
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
    await _requireProfile(session);
    final evidence = await CompletionEvidence.db.findById(session, evidenceId);
    if (evidence?.photographPath == null) {
      throw FieldnoteException(
        message: 'Evidence photograph not found.',
        code: 'evidence_not_found',
      );
    }
    final url = await session.storage.temporaryDownloadUrl(
      storageId: 'private',
      path: evidence!.photographPath!,
    );
    return url.toString();
  }

  Future<ImpactSummary> getImpact(Session session, int campaignId) async {
    await _requireProfile(session);
    final campaign = await _campaign(session, campaignId);
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
          city: city.trim(),
          interests: interests.join(' | '),
          skills: skills.join(' | '),
        ),
      );
    }
    existing.displayName = displayName.trim();
    existing.sponsorType = _blankToNull(sponsorType);
    existing.organizationName = _blankToNull(organizationName);
    existing.city = city.trim();
    existing.interests = interests.join(' | ');
    existing.skills = skills.join(' | ');
    existing.updatedAt = DateTime.now().toUtc();
    return FieldnoteUserProfile.db.updateRow(session, existing);
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
    int participationCount,
  ) {
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
    final dayMatches = days.contains(campaign.startsAt.toLocal().weekday);
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
    final distanceScore = availability.latitude == null
        ? 15.0
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
      if (availability.latitude != null)
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
    );
  }

  Future<void> _ensureDemoCampaigns(Session session) async {
    final organization = await _platformOrganization(session);
    final demoCreator = UuidValue.withValidation(
      '00000000-0000-4000-8000-000000000001',
    );
    final now = DateTime.now();
    final seeds = [
      (
        'Campus Tree Care Day',
        'Care for young campus trees through watering, guard repair, and cleanup.',
        50000.0,
        32500.0,
        20,
        18.52040,
        73.85670,
        'tree care | environment | outdoors',
      ),
      (
        'Riverside Cleanup',
        'Remove visible waste and document a cleaner riverside public space.',
        30000.0,
        12000.0,
        15,
        18.52110,
        73.85810,
        'cleanup | environment | community',
      ),
      (
        'Community Garden Revival',
        'Restore planting beds and prepare the neighbourhood garden for the season.',
        75000.0,
        48000.0,
        25,
        18.51920,
        73.85530,
        'gardening | community | outdoors',
      ),
    ];
    for (var i = 0; i < seeds.length; i++) {
      final seed = seeds[i];
      final existing = await Campaign.db.findFirstRow(
        session,
        where: (t) => t.name.equals(seed.$1),
      );
      if (existing != null) continue;
      final start = _nextWeekday(now, DateTime.saturday).copyWith(
        hour: 8 + i,
        minute: 0,
        second: 0,
        millisecond: 0,
        microsecond: 0,
      );
      await Campaign.db.insertRow(
        session,
        Campaign(
          organizationId: organization.id!,
          name: seed.$1,
          description: seed.$2,
          locationName: i == 0 ? 'University Campus' : 'Pune Community Zone',
          startsAt: start.toUtc(),
          endsAt: start.add(const Duration(hours: 3)).toUtc(),
          status: CampaignStatus.active,
          createdBy: demoCreator,
          fundingGoal: seed.$3,
          sponsoredAmount: seed.$4,
          latitude: seed.$6,
          longitude: seed.$7,
          geofenceMeters: 200,
          volunteerCapacity: seed.$5,
          requiredSkills: 'No specialist skills | Comfortable outdoors',
          checklist:
              'Check in at the campaign pin | Complete the published work | Submit one photograph and note',
          evidenceInstructions:
              'Submit a location-verified photograph and describe completed work.',
          tags: seed.$8,
          aiGenerated: true,
          publishedAt: DateTime.now().toUtc(),
        ),
      );
    }
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

  static String _requiredPassword(Session session, String name) {
    final value = session.passwords[name]?.trim();
    if (value == null || value.isEmpty) {
      throw FieldnoteException(
        message:
            'Razorpay Test Mode is not configured on the server. Add $name to Serverpod passwords.',
        code: 'payment_not_configured',
      );
    }
    return value;
  }

  static String _transcriptionModel(Session session) {
    final configured = session.passwords['geminiTranscriptionModel']?.trim();
    if (configured == null || configured.isEmpty) {
      return GeminiSpeechService.defaultModel;
    }
    if (!RegExp(r'^[a-zA-Z0-9._-]+$').hasMatch(configured)) {
      throw FieldnoteException(
        message: 'The configured Gemini transcription model name is invalid.',
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
        message: 'The configured Gemini model name is invalid.',
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

  static DateTime _nextWeekday(DateTime from, int weekday) {
    var days = (weekday - from.weekday) % 7;
    if (days == 0) days = 7;
    return from.add(Duration(days: days));
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
