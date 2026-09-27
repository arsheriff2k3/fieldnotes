/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _ida;
import 'dart:typed_data' as _idt;
import 'package:fieldnotes_client/src/protocol/fieldnotes/models/audit_event.dart'
    as _ixscx4wv;
import 'package:fieldnotes_client/src/protocol/fieldnotes/models/campaign.dart'
    as _i6ar8a32;
import 'package:fieldnotes_client/src/protocol/fieldnotes/models/campaign_invitation.dart'
    as _ilmm7kn9;
import 'package:fieldnotes_client/src/protocol/fieldnotes/models/campaign_live_update.dart'
    as _ivzrz8af;
import 'package:fieldnotes_client/src/protocol/fieldnotes/models/campaign_map_overview.dart'
    as _if3inlr4;
import 'package:fieldnotes_client/src/protocol/fieldnotes/models/campaign_match.dart'
    as _ifn539xv;
import 'package:fieldnotes_client/src/protocol/fieldnotes/models/campaign_participation.dart'
    as _i43ypuev;
import 'package:fieldnotes_client/src/protocol/fieldnotes/models/campaign_post.dart'
    as _is6qjlzb;
import 'package:fieldnotes_client/src/protocol/fieldnotes/models/campaign_proposal.dart'
    as _i9wpoa9q;
import 'package:fieldnotes_client/src/protocol/fieldnotes/models/campaign_reach.dart'
    as _i7z8ummg;
import 'package:fieldnotes_client/src/protocol/fieldnotes/models/completion_evidence.dart'
    as _i82sjar3;
import 'package:fieldnotes_client/src/protocol/fieldnotes/models/completion_proposal.dart'
    as _inbe29jh;
import 'package:fieldnotes_client/src/protocol/fieldnotes/models/impact_summary.dart'
    as _i70v1zz5;
import 'package:fieldnotes_client/src/protocol/fieldnotes/models/legal_consent.dart'
    as _iu4zzdwl;
import 'package:fieldnotes_client/src/protocol/fieldnotes/models/place_suggestion.dart'
    as _igynj288;
import 'package:fieldnotes_client/src/protocol/fieldnotes/models/razorpay_checkout_order.dart'
    as _ieclxo3s;
import 'package:fieldnotes_client/src/protocol/fieldnotes/models/resolved_place.dart'
    as _iigiw870;
import 'package:fieldnotes_client/src/protocol/fieldnotes/models/sponsorship.dart'
    as _iffokzpe;
import 'package:fieldnotes_client/src/protocol/fieldnotes/models/test_payout.dart'
    as _irfbdx5f;
import 'package:fieldnotes_client/src/protocol/fieldnotes/models/travel_route.dart'
    as _il9u2d3q;
import 'package:fieldnotes_client/src/protocol/fieldnotes/models/trust_center_summary.dart'
    as _im0kjztm;
import 'package:fieldnotes_client/src/protocol/fieldnotes/models/user_profile.dart'
    as _isdhijrt;
import 'package:fieldnotes_client/src/protocol/fieldnotes/models/volunteer_availability.dart'
    as _i0dt06ps;
import 'package:fieldnotes_client/src/protocol/greetings/greeting.dart'
    as _ip7pdgaq;
import 'package:http/http.dart' as _i85jenna;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _iacc;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _iaic;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'protocol.dart' as _il2as5qe;

/// By extending [EmailIdpBaseEndpoint], the email identity provider endpoints
/// are made available on the server and enable the corresponding sign-in widget
/// on the client.
/// {@category Endpoint}
class EndpointEmailIdp extends _iaic.EndpointEmailIdpBase {
  EndpointEmailIdp(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'emailIdp';

  /// Logs in the user and returns a new session.
  ///
  /// Throws an [EmailAccountLoginException] in case of errors, with reason:
  /// - [EmailAccountLoginExceptionReason.invalidCredentials] if the email or
  ///   password is incorrect.
  /// - [EmailAccountLoginExceptionReason.tooManyAttempts] if there have been
  ///   too many failed login attempts.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  @override
  _ida.Future<_iacc.AuthSuccess> login({
    required String email,
    required String password,
  }) => caller.callServerEndpoint<_iacc.AuthSuccess>(
    'emailIdp',
    'login',
    {
      'email': email,
      'password': password,
    },
  );

  /// Starts the registration for a new user account with an email-based login
  /// associated to it.
  ///
  /// Upon successful completion of this method, an email will have been
  /// sent to [email] with a verification link, which the user must open to
  /// complete the registration.
  ///
  /// Always returns a account request ID, which can be used to complete the
  /// registration. If the email is already registered, the returned ID will not
  /// be valid.
  @override
  _ida.Future<_isc.UuidValue> startRegistration({required String email}) =>
      caller.callServerEndpoint<_isc.UuidValue>(
        'emailIdp',
        'startRegistration',
        {'email': email},
      );

  /// Verifies an account request code and returns a token
  /// that can be used to complete the account creation.
  ///
  /// Throws an [EmailAccountRequestException] in case of errors, with reason:
  /// - [EmailAccountRequestExceptionReason.expired] if the account request has
  ///   already expired.
  /// - [EmailAccountRequestExceptionReason.policyViolation] if the password
  ///   does not comply with the password policy.
  /// - [EmailAccountRequestExceptionReason.invalid] if no request exists
  ///   for the given [accountRequestId] or [verificationCode] is invalid.
  @override
  _ida.Future<String> verifyRegistrationCode({
    required _isc.UuidValue accountRequestId,
    required String verificationCode,
  }) => caller.callServerEndpoint<String>(
    'emailIdp',
    'verifyRegistrationCode',
    {
      'accountRequestId': accountRequestId,
      'verificationCode': verificationCode,
    },
  );

  /// Completes a new account registration, creating a new auth user with a
  /// profile and attaching the given email account to it.
  ///
  /// Throws an [EmailAccountRequestException] in case of errors, with reason:
  /// - [EmailAccountRequestExceptionReason.expired] if the account request has
  ///   already expired.
  /// - [EmailAccountRequestExceptionReason.policyViolation] if the password
  ///   does not comply with the password policy.
  /// - [EmailAccountRequestExceptionReason.invalid] if the [registrationToken]
  ///   is invalid.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  ///
  /// Returns a session for the newly created user.
  @override
  _ida.Future<_iacc.AuthSuccess> finishRegistration({
    required String registrationToken,
    required String password,
  }) => caller.callServerEndpoint<_iacc.AuthSuccess>(
    'emailIdp',
    'finishRegistration',
    {
      'registrationToken': registrationToken,
      'password': password,
    },
  );

  /// Requests a password reset for [email].
  ///
  /// If the email address is registered, an email with reset instructions will
  /// be send out. If the email is unknown, this method will have no effect.
  ///
  /// Always returns a password reset request ID, which can be used to complete
  /// the reset. If the email is not registered, the returned ID will not be
  /// valid.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.tooManyAttempts] if the user has
  ///   made too many attempts trying to request a password reset.
  ///
  @override
  _ida.Future<_isc.UuidValue> startPasswordReset({required String email}) =>
      caller.callServerEndpoint<_isc.UuidValue>(
        'emailIdp',
        'startPasswordReset',
        {'email': email},
      );

  /// Verifies a password reset code and returns a finishPasswordResetToken
  /// that can be used to finish the password reset.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.expired] if the password reset
  ///   request has already expired.
  /// - [EmailAccountPasswordResetExceptionReason.tooManyAttempts] if the user has
  ///   made too many attempts trying to verify the password reset.
  /// - [EmailAccountPasswordResetExceptionReason.invalid] if no request exists
  ///   for the given [passwordResetRequestId] or [verificationCode] is invalid.
  ///
  /// If multiple steps are required to complete the password reset, this endpoint
  /// should be overridden to return credentials for the next step instead
  /// of the credentials for setting the password.
  @override
  _ida.Future<String> verifyPasswordResetCode({
    required _isc.UuidValue passwordResetRequestId,
    required String verificationCode,
  }) => caller.callServerEndpoint<String>(
    'emailIdp',
    'verifyPasswordResetCode',
    {
      'passwordResetRequestId': passwordResetRequestId,
      'verificationCode': verificationCode,
    },
  );

  /// Completes a password reset request by setting a new password.
  ///
  /// The [verificationCode] returned from [verifyPasswordResetCode] is used to
  /// validate the password reset request.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.expired] if the password reset
  ///   request has already expired.
  /// - [EmailAccountPasswordResetExceptionReason.policyViolation] if the new
  ///   password does not comply with the password policy.
  /// - [EmailAccountPasswordResetExceptionReason.invalid] if no request exists
  ///   for the given [passwordResetRequestId] or [verificationCode] is invalid.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  @override
  _ida.Future<void> finishPasswordReset({
    required String finishPasswordResetToken,
    required String newPassword,
  }) => caller.callServerEndpoint<void>(
    'emailIdp',
    'finishPasswordReset',
    {
      'finishPasswordResetToken': finishPasswordResetToken,
      'newPassword': newPassword,
    },
  );

  @override
  _ida.Future<bool> hasAccount() => caller.callServerEndpoint<bool>(
    'emailIdp',
    'hasAccount',
    {},
  );
}

/// By extending [RefreshJwtTokensEndpoint], the JWT token refresh endpoint
/// is made available on the server and enables automatic token refresh on the client.
/// {@category Endpoint}
class EndpointJwtRefresh extends _iacc.EndpointRefreshJwtTokens {
  EndpointJwtRefresh(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'jwtRefresh';

  /// Creates a new token pair for the given [refreshToken].
  ///
  /// If [refreshToken] is omitted, cookie-mode web clients fall back to the
  /// configured HttpOnly refresh cookie. When neither source is present this
  /// throws [RefreshTokenNotFoundException], the same public "no usable refresh
  /// credential" exception used for unknown refresh tokens.
  ///
  /// Can throw the following exceptions:
  /// -[RefreshTokenMalformedException]: refresh token is malformed and could
  ///   not be parsed. Not expected to happen for tokens issued by the server.
  /// -[RefreshTokenNotFoundException]: refresh token is unknown to the server.
  ///   Either the token was deleted or generated by a different server.
  /// -[RefreshTokenExpiredException]: refresh token has expired. Will happen
  ///   only if it has not been used within configured `refreshTokenLifetime`.
  /// -[RefreshTokenInvalidSecretException]: refresh token is incorrect, meaning
  ///   it does not refer to the current secret refresh token. This indicates
  ///   either a malfunctioning client or a malicious attempt by someone who has
  ///   obtained the refresh token. In this case the underlying refresh token
  ///   will be deleted, and access to it will expire fully when the last access
  ///   token is elapsed.
  ///
  /// This endpoint is unauthenticated, meaning the client won't include any
  /// authentication information with the call.
  @override
  _ida.Future<_iacc.AuthSuccess> refreshAccessToken({String? refreshToken}) =>
      caller.callServerEndpoint<_iacc.AuthSuccess>(
        'jwtRefresh',
        'refreshAccessToken',
        {'refreshToken': refreshToken},
        authenticated: false,
      );
}

/// {@category Endpoint}
class EndpointFieldnote extends _isc.EndpointRef {
  EndpointFieldnote(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'fieldnote';

  _ida.Future<_isdhijrt.FieldnoteUserProfile?> getMyProfile() =>
      caller.callServerEndpoint<_isdhijrt.FieldnoteUserProfile?>(
        'fieldnote',
        'getMyProfile',
        {},
      );

  _ida.Future<_iu4zzdwl.LegalConsent?> getMyLegalConsent() =>
      caller.callServerEndpoint<_iu4zzdwl.LegalConsent?>(
        'fieldnote',
        'getMyLegalConsent',
        {},
      );

  _ida.Future<_iu4zzdwl.LegalConsent> acceptLegalConsent(
    bool locationConsent,
    bool aiProcessingConsent,
    bool evidenceSharingConsent,
  ) => caller.callServerEndpoint<_iu4zzdwl.LegalConsent>(
    'fieldnote',
    'acceptLegalConsent',
    {
      'locationConsent': locationConsent,
      'aiProcessingConsent': aiProcessingConsent,
      'evidenceSharingConsent': evidenceSharingConsent,
    },
  );

  _ida.Future<_im0kjztm.TrustCenterSummary> getTrustCenter() =>
      caller.callServerEndpoint<_im0kjztm.TrustCenterSummary>(
        'fieldnote',
        'getTrustCenter',
        {},
      );

  _ida.Future<String> exportMyData() => caller.callServerEndpoint<String>(
    'fieldnote',
    'exportMyData',
    {},
  );

  _ida.Future<_ixscx4wv.AuditEvent> recordAccountDataExport(String format) =>
      caller.callServerEndpoint<_ixscx4wv.AuditEvent>(
        'fieldnote',
        'recordAccountDataExport',
        {'format': format},
      );

  _ida.Future<_ixscx4wv.AuditEvent> requestAccountDeletion() =>
      caller.callServerEndpoint<_ixscx4wv.AuditEvent>(
        'fieldnote',
        'requestAccountDeletion',
        {},
      );

  _ida.Future<_isdhijrt.FieldnoteUserProfile> completeSponsorProfile(
    String displayName,
    String sponsorType,
    String? organizationName,
    String city,
    String? cityPlaceId,
    List<String> interests, {
    double? locationLatitude,
    double? locationLongitude,
    String? contactPhone,
  }) => caller.callServerEndpoint<_isdhijrt.FieldnoteUserProfile>(
    'fieldnote',
    'completeSponsorProfile',
    {
      'displayName': displayName,
      'sponsorType': sponsorType,
      'organizationName': organizationName,
      'city': city,
      'cityPlaceId': cityPlaceId,
      'interests': interests,
      'locationLatitude': locationLatitude,
      'locationLongitude': locationLongitude,
      'contactPhone': contactPhone,
    },
  );

  _ida.Future<_isdhijrt.FieldnoteUserProfile> completeVolunteerProfile(
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
  ) => caller.callServerEndpoint<_isdhijrt.FieldnoteUserProfile>(
    'fieldnote',
    'completeVolunteerProfile',
    {
      'displayName': displayName,
      'city': city,
      'interests': interests,
      'skills': skills,
      'isAvailable': isAvailable,
      'availableToday': availableToday,
      'weekdays': weekdays,
      'startMinutes': startMinutes,
      'endMinutes': endMinutes,
      'maximumTravelKm': maximumTravelKm,
      'latitude': latitude,
      'longitude': longitude,
      'locationLabel': locationLabel,
    },
  );

  /// Updates the editable account details while preserving the role and legal
  /// consent selected during account creation.
  _ida.Future<_isdhijrt.FieldnoteUserProfile> updateMyProfile(
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
  }) => caller.callServerEndpoint<_isdhijrt.FieldnoteUserProfile>(
    'fieldnote',
    'updateMyProfile',
    {
      'displayName': displayName,
      'sponsorType': sponsorType,
      'organizationName': organizationName,
      'city': city,
      'cityPlaceId': cityPlaceId,
      'interests': interests,
      'skills': skills,
      'locationLatitude': locationLatitude,
      'locationLongitude': locationLongitude,
      'contactPhone': contactPhone,
    },
  );

  _ida.Future<_i0dt06ps.VolunteerAvailability?> getMyAvailability() =>
      caller.callServerEndpoint<_i0dt06ps.VolunteerAvailability?>(
        'fieldnote',
        'getMyAvailability',
        {},
      );

  _ida.Future<_i0dt06ps.VolunteerAvailability> updateAvailability(
    bool isAvailable,
    bool availableToday,
    List<int> weekdays,
    int startMinutes,
    int endMinutes,
    double maximumTravelKm,
    double? latitude,
    double? longitude,
    String locationLabel,
  ) => caller.callServerEndpoint<_i0dt06ps.VolunteerAvailability>(
    'fieldnote',
    'updateAvailability',
    {
      'isAvailable': isAvailable,
      'availableToday': availableToday,
      'weekdays': weekdays,
      'startMinutes': startMinutes,
      'endMinutes': endMinutes,
      'maximumTravelKm': maximumTravelKm,
      'latitude': latitude,
      'longitude': longitude,
      'locationLabel': locationLabel,
    },
  );

  /// Transcribes a held-to-talk recording. The audio never leaves the server
  /// except to the configured provider, and the transcript is returned for the
  /// sponsor to review before anything is generated or published.
  _ida.Future<String> transcribeDictation(
    _idt.ByteData audio,
    String fileName,
    String mimeType,
  ) => caller.callServerEndpoint<String>(
    'fieldnote',
    'transcribeDictation',
    {
      'audio': audio,
      'fileName': fileName,
      'mimeType': mimeType,
    },
  );

  _ida.Future<_i9wpoa9q.CampaignProposal> proposeCampaign(String prompt) =>
      caller.callServerEndpoint<_i9wpoa9q.CampaignProposal>(
        'fieldnote',
        'proposeCampaign',
        {'prompt': prompt},
      );

  /// Publishes a proposal at a map pin.
  ///
  /// [locationName] and [geofenceMeters] come from the sponsor's map: the pin
  /// can be dragged anywhere and named from Places, so the published campaign
  /// is no longer tied to where the sponsor's own device happened to be.
  _ida.Future<_i6ar8a32.Campaign> createCampaignFromProposal(
    _i9wpoa9q.CampaignProposal proposal,
    double latitude,
    double longitude,
    String? locationName,
    double? geofenceMeters,
  ) => caller.callServerEndpoint<_i6ar8a32.Campaign>(
    'fieldnote',
    'createCampaignFromProposal',
    {
      'proposal': proposal,
      'latitude': latitude,
      'longitude': longitude,
      'locationName': locationName,
      'geofenceMeters': geofenceMeters,
    },
  );

  _ida.Future<List<_i6ar8a32.Campaign>> listCampaigns() =>
      caller.callServerEndpoint<List<_i6ar8a32.Campaign>>(
        'fieldnote',
        'listCampaigns',
        {},
      );

  /// Resolves a shared campaign after sign-in. The volunteer still joins via
  /// the normal capacity and readiness checks in [joinCampaign].
  _ida.Future<_i6ar8a32.Campaign?> getSharedCampaign(int campaignId) =>
      caller.callServerEndpoint<_i6ar8a32.Campaign?>(
        'fieldnote',
        'getSharedCampaign',
        {'campaignId': campaignId},
      );

  _ida.Future<List<_i6ar8a32.Campaign>> listMyCreatedCampaigns() =>
      caller.callServerEndpoint<List<_i6ar8a32.Campaign>>(
        'fieldnote',
        'listMyCreatedCampaigns',
        {},
      );

  _ida.Future<_i6ar8a32.Campaign> refreshCampaignReadiness(int campaignId) =>
      caller.callServerEndpoint<_i6ar8a32.Campaign>(
        'fieldnote',
        'refreshCampaignReadiness',
        {'campaignId': campaignId},
      );

  _ida.Future<_i6ar8a32.Campaign> reviseCampaignScope(
    int campaignId,
    double fundingGoal,
    int minimumVolunteers,
    String description,
  ) => caller.callServerEndpoint<_i6ar8a32.Campaign>(
    'fieldnote',
    'reviseCampaignScope',
    {
      'campaignId': campaignId,
      'fundingGoal': fundingGoal,
      'minimumVolunteers': minimumVolunteers,
      'description': description,
    },
  );

  _ida.Future<_i6ar8a32.Campaign> postponeCampaign(
    int campaignId,
    DateTime newStartsAt,
  ) => caller.callServerEndpoint<_i6ar8a32.Campaign>(
    'fieldnote',
    'postponeCampaign',
    {
      'campaignId': campaignId,
      'newStartsAt': newStartsAt,
    },
  );

  _ida.Future<_i6ar8a32.Campaign> cancelCampaign(int campaignId) =>
      caller.callServerEndpoint<_i6ar8a32.Campaign>(
        'fieldnote',
        'cancelCampaign',
        {'campaignId': campaignId},
      );

  _ida.Future<_i43ypuev.CampaignParticipation> reconfirmCampaignParticipation(
    int participationId,
  ) => caller.callServerEndpoint<_i43ypuev.CampaignParticipation>(
    'fieldnote',
    'reconfirmCampaignParticipation',
    {'participationId': participationId},
  );

  _ida.Future<List<_i6ar8a32.Campaign>> listMyJoinedCampaigns() =>
      caller.callServerEndpoint<List<_i6ar8a32.Campaign>>(
        'fieldnote',
        'listMyJoinedCampaigns',
        {},
      );

  /// Whether Google Places autocomplete is available during account setup.
  /// This deliberately requires authentication but not an existing profile,
  /// because it is called before onboarding creates the profile row.
  _ida.Future<bool> isCitySearchAvailable() => caller.callServerEndpoint<bool>(
    'fieldnote',
    'isCitySearchAvailable',
    {},
  );

  /// City-only Google Places autocomplete retained for volunteer profiles.
  _ida.Future<List<_igynj288.PlaceSuggestion>> searchCities(String query) =>
      caller.callServerEndpoint<List<_igynj288.PlaceSuggestion>>(
        'fieldnote',
        'searchCities',
        {'query': query},
      );

  /// Full Google Places autocomplete for sponsor account setup. Unlike the
  /// campaign search endpoint, this works before the profile row exists.
  _ida.Future<List<_igynj288.PlaceSuggestion>> searchSponsorLocations(
    String query,
  ) => caller.callServerEndpoint<List<_igynj288.PlaceSuggestion>>(
    'fieldnote',
    'searchSponsorLocations',
    {'query': query},
  );

  /// Whether server-side Places, Geocoding and Routes calls are available.
  /// The client uses this to hide search affordances it cannot fulfil.
  _ida.Future<bool> isPlaceSearchAvailable() => caller.callServerEndpoint<bool>(
    'fieldnote',
    'isPlaceSearchAvailable',
    {},
  );

  /// Google Places autocomplete for naming a campaign pin.
  _ida.Future<List<_igynj288.PlaceSuggestion>> searchPlaces(
    String query,
    double? biasLatitude,
    double? biasLongitude,
  ) => caller.callServerEndpoint<List<_igynj288.PlaceSuggestion>>(
    'fieldnote',
    'searchPlaces',
    {
      'query': query,
      'biasLatitude': biasLatitude,
      'biasLongitude': biasLongitude,
    },
  );

  /// Turns a Places autocomplete selection into a campaign pin.
  _ida.Future<_iigiw870.ResolvedPlace> resolvePlace(String placeId) =>
      caller.callServerEndpoint<_iigiw870.ResolvedPlace>(
        'fieldnote',
        'resolvePlace',
        {'placeId': placeId},
      );

  /// Names a dragged map pin. Returns null rather than throwing so the map
  /// keeps working with a typed label when geocoding is off or offline.
  _ida.Future<_iigiw870.ResolvedPlace?> describeCoordinates(
    double latitude,
    double longitude,
  ) => caller.callServerEndpoint<_iigiw870.ResolvedPlace?>(
    'fieldnote',
    'describeCoordinates',
    {
      'latitude': latitude,
      'longitude': longitude,
    },
  );

  /// Route a volunteer from their current device position to a campaign.
  /// The saved availability area is only for matching and is never the
  /// origin of an active journey.
  _ida.Future<_il9u2d3q.TravelRoute> getTravelRoute(
    int campaignId,
    double originLatitude,
    double originLongitude,
    String travelMode,
  ) => caller.callServerEndpoint<_il9u2d3q.TravelRoute>(
    'fieldnote',
    'getTravelRoute',
    {
      'campaignId': campaignId,
      'originLatitude': originLatitude,
      'originLongitude': originLongitude,
      'travelMode': travelMode,
    },
  );

  /// How many volunteers could actually reach a proposed pin, before the
  /// sponsor commits money to it.
  ///
  /// Individual volunteer coordinates are never returned. Coverage is bucketed
  /// to roughly a kilometre and any bucket holding fewer than
  /// [_reachCellAnonymityThreshold] volunteers is suppressed entirely.
  _ida.Future<_i7z8ummg.CampaignReach> previewCampaignReach(
    double latitude,
    double longitude,
  ) => caller.callServerEndpoint<_i7z8ummg.CampaignReach>(
    'fieldnote',
    'previewCampaignReach',
    {
      'latitude': latitude,
      'longitude': longitude,
    },
  );

  /// Shows coarse groups of available, unjoined volunteers who can travel to
  /// this published campaign. Only its creator may inspect the map. Small
  /// groups and individual distances are never returned.
  _ida.Future<_i7z8ummg.CampaignReach> getCampaignVolunteerReach(
    int campaignId,
  ) => caller.callServerEndpoint<_i7z8ummg.CampaignReach>(
    'fieldnote',
    'getCampaignVolunteerReach',
    {'campaignId': campaignId},
  );

  /// Delivers a private in-app invitation to everyone in a visible map area.
  /// Eligibility and the anonymity threshold are checked again on the server
  /// at send time. Repeated taps do not create duplicate invitations.
  _ida.Future<int> inviteCampaignVolunteersInArea(
    int campaignId,
    double areaLatitude,
    double areaLongitude,
  ) => caller.callServerEndpoint<int>(
    'fieldnote',
    'inviteCampaignVolunteersInArea',
    {
      'campaignId': campaignId,
      'areaLatitude': areaLatitude,
      'areaLongitude': areaLongitude,
    },
  );

  _ida.Future<List<_ilmm7kn9.CampaignInvitation>> listMyCampaignInvitations() =>
      caller.callServerEndpoint<List<_ilmm7kn9.CampaignInvitation>>(
        'fieldnote',
        'listMyCampaignInvitations',
        {},
      );

  /// Every check-in and evidence point for one campaign, for the sponsor live
  /// map. Restricted to the sponsor who created the campaign.
  _ida.Future<_if3inlr4.CampaignMapOverview> getCampaignMap(int campaignId) =>
      caller.callServerEndpoint<_if3inlr4.CampaignMapOverview>(
        'fieldnote',
        'getCampaignMap',
        {'campaignId': campaignId},
      );

  _ida.Future<_ieclxo3s.RazorpayCheckoutOrder> createRazorpayOrder(
    int campaignId,
    double amount,
    String? message,
  ) => caller.callServerEndpoint<_ieclxo3s.RazorpayCheckoutOrder>(
    'fieldnote',
    'createRazorpayOrder',
    {
      'campaignId': campaignId,
      'amount': amount,
      'message': message,
    },
  );

  _ida.Future<_iffokzpe.Sponsorship> verifyRazorpayPayment(
    int sponsorshipId,
    String orderId,
    String paymentId,
    String signature,
  ) => caller.callServerEndpoint<_iffokzpe.Sponsorship>(
    'fieldnote',
    'verifyRazorpayPayment',
    {
      'sponsorshipId': sponsorshipId,
      'orderId': orderId,
      'paymentId': paymentId,
      'signature': signature,
    },
  );

  _ida.Future<_iffokzpe.Sponsorship> recordRazorpayFailure(
    int sponsorshipId,
    String reason,
  ) => caller.callServerEndpoint<_iffokzpe.Sponsorship>(
    'fieldnote',
    'recordRazorpayFailure',
    {
      'sponsorshipId': sponsorshipId,
      'reason': reason,
    },
  );

  _ida.Future<List<_iffokzpe.Sponsorship>> listMySponsorships() =>
      caller.callServerEndpoint<List<_iffokzpe.Sponsorship>>(
        'fieldnote',
        'listMySponsorships',
        {},
      );

  /// Creator-only demonstration ledger. These rows never initiate a bank
  /// transfer or call Razorpay Route.
  _ida.Future<List<_irfbdx5f.TestPayout>> listCampaignTestPayouts(
    int campaignId,
  ) => caller.callServerEndpoint<List<_irfbdx5f.TestPayout>>(
    'fieldnote',
    'listCampaignTestPayouts',
    {'campaignId': campaignId},
  );

  /// Records one simulated credit for each newly verified test checkout.
  /// A campaign row lock and unique sponsorship index make retries safe.
  _ida.Future<List<_irfbdx5f.TestPayout>> simulateCampaignTestPayout(
    int campaignId,
  ) => caller.callServerEndpoint<List<_irfbdx5f.TestPayout>>(
    'fieldnote',
    'simulateCampaignTestPayout',
    {'campaignId': campaignId},
  );

  _ida.Future<List<_ifn539xv.CampaignMatch>> getCampaignMatches() =>
      caller.callServerEndpoint<List<_ifn539xv.CampaignMatch>>(
        'fieldnote',
        'getCampaignMatches',
        {},
      );

  _ida.Future<_i43ypuev.CampaignParticipation> joinCampaign(int campaignId) =>
      caller.callServerEndpoint<_i43ypuev.CampaignParticipation>(
        'fieldnote',
        'joinCampaign',
        {'campaignId': campaignId},
      );

  /// A contact number is private until a volunteer joins this campaign.
  _ida.Future<String?> getCampaignContactPhone(int campaignId) =>
      caller.callServerEndpoint<String?>(
        'fieldnote',
        'getCampaignContactPhone',
        {'campaignId': campaignId},
      );

  _ida.Future<List<_i43ypuev.CampaignParticipation>> listMyParticipations() =>
      caller.callServerEndpoint<List<_i43ypuev.CampaignParticipation>>(
        'fieldnote',
        'listMyParticipations',
        {},
      );

  _ida.Future<_i43ypuev.CampaignParticipation> checkIn(
    int participationId,
    double latitude,
    double longitude,
    double accuracyMeters,
    bool deviceReportedMock,
    bool explicitDemo,
    DateTime capturedAt,
  ) => caller.callServerEndpoint<_i43ypuev.CampaignParticipation>(
    'fieldnote',
    'checkIn',
    {
      'participationId': participationId,
      'latitude': latitude,
      'longitude': longitude,
      'accuracyMeters': accuracyMeters,
      'deviceReportedMock': deviceReportedMock,
      'explicitDemo': explicitDemo,
      'capturedAt': capturedAt,
    },
  );

  _ida.Future<_inbe29jh.CompletionProposal> analyzeCompletion(
    int participationId,
    String note,
    _idt.ByteData? photograph,
    String? photographMimeType,
  ) => caller.callServerEndpoint<_inbe29jh.CompletionProposal>(
    'fieldnote',
    'analyzeCompletion',
    {
      'participationId': participationId,
      'note': note,
      'photograph': photograph,
      'photographMimeType': photographMimeType,
    },
  );

  _ida.Future<String> getEvidenceUploadDescription(
    int participationId,
    String extension,
  ) => caller.callServerEndpoint<String>(
    'fieldnote',
    'getEvidenceUploadDescription',
    {
      'participationId': participationId,
      'extension': extension,
    },
  );

  _ida.Future<_i82sjar3.CompletionEvidence> completeParticipation(
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
  ) => caller.callServerEndpoint<_i82sjar3.CompletionEvidence>(
    'fieldnote',
    'completeParticipation',
    {
      'participationId': participationId,
      'photoExtension': photoExtension,
      'originalNote': originalNote,
      'confirmedSummary': confirmedSummary,
      'structuredResults': structuredResults,
      'latitude': latitude,
      'longitude': longitude,
      'accuracyMeters': accuracyMeters,
      'deviceReportedMock': deviceReportedMock,
      'explicitDemo': explicitDemo,
      'capturedAt': capturedAt,
    },
  );

  _ida.Future<String> getEvidenceDownloadUrl(int evidenceId) =>
      caller.callServerEndpoint<String>(
        'fieldnote',
        'getEvidenceDownloadUrl',
        {'evidenceId': evidenceId},
      );

  _ida.Future<_i70v1zz5.ImpactSummary> getImpact(int campaignId) =>
      caller.callServerEndpoint<_i70v1zz5.ImpactSummary>(
        'fieldnote',
        'getImpact',
        {'campaignId': campaignId},
      );

  _ida.Future<_is6qjlzb.CampaignPost> createCampaignPost(
    int campaignId,
    String title,
    String body,
  ) => caller.callServerEndpoint<_is6qjlzb.CampaignPost>(
    'fieldnote',
    'createCampaignPost',
    {
      'campaignId': campaignId,
      'title': title,
      'body': body,
    },
  );

  _ida.Future<List<_is6qjlzb.CampaignPost>> listCampaignPosts(int campaignId) =>
      caller.callServerEndpoint<List<_is6qjlzb.CampaignPost>>(
        'fieldnote',
        'listCampaignPosts',
        {'campaignId': campaignId},
      );

  _ida.Stream<_ivzrz8af.CampaignLiveUpdate> watchCampaign(int campaignId) =>
      caller.callStreamingServerEndpoint<
        _ida.Stream<_ivzrz8af.CampaignLiveUpdate>,
        _ivzrz8af.CampaignLiveUpdate
      >(
        'fieldnote',
        'watchCampaign',
        {'campaignId': campaignId},
        {},
      );
}

/// This is an example endpoint that returns a greeting message through
/// its [hello] method.
/// {@category Endpoint}
class EndpointGreeting extends _isc.EndpointRef {
  EndpointGreeting(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'greeting';

  /// Returns a personalized greeting message: "Hello {name}".
  _ida.Future<_ip7pdgaq.Greeting> hello(String name) =>
      caller.callServerEndpoint<_ip7pdgaq.Greeting>(
        'greeting',
        'hello',
        {'name': name},
      );
}

class Modules {
  Modules(Client client) {
    serverpod_auth_idp = _iaic.Caller(client);
    serverpod_auth_core = _iacc.Caller(client);
  }

  late final _iaic.Caller serverpod_auth_idp;

  late final _iacc.Caller serverpod_auth_core;
}

class Client extends _isc.ServerpodClientShared {
  Client(
    String host, {
    dynamic securityContext,
    Duration? streamingConnectionTimeout,
    Duration? connectionTimeout,
    Function(
      _isc.MethodCallContext,
      Object,
      StackTrace,
    )?
    onFailedCall,
    Function(_isc.MethodCallContext)? onSucceededCall,
    bool? disconnectStreamsOnLostInternetConnection,
    _i85jenna.Client? httpClientOverride,
  }) : super(
         host,
         _il2as5qe.Protocol(),
         securityContext: securityContext,
         streamingConnectionTimeout: streamingConnectionTimeout,
         connectionTimeout: connectionTimeout,
         onFailedCall: onFailedCall,
         onSucceededCall: onSucceededCall,
         disconnectStreamsOnLostInternetConnection:
             disconnectStreamsOnLostInternetConnection,
         httpClientOverride: httpClientOverride,
       ) {
    emailIdp = EndpointEmailIdp(this);
    jwtRefresh = EndpointJwtRefresh(this);
    fieldnote = EndpointFieldnote(this);
    greeting = EndpointGreeting(this);
    modules = Modules(this);
  }

  late final EndpointEmailIdp emailIdp;

  late final EndpointJwtRefresh jwtRefresh;

  late final EndpointFieldnote fieldnote;

  late final EndpointGreeting greeting;

  late final Modules modules;

  @override
  Map<String, _isc.EndpointRef> get endpointRefLookup => {
    'emailIdp': emailIdp,
    'jwtRefresh': jwtRefresh,
    'fieldnote': fieldnote,
    'greeting': greeting,
  };

  @override
  Map<String, _isc.ModuleEndpointCaller> get moduleLookup => {
    'serverpod_auth_idp': modules.serverpod_auth_idp,
    'serverpod_auth_core': modules.serverpod_auth_core,
  };
}
