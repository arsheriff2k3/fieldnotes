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
import 'dart:typed_data' as _idt;
import 'package:fieldnotes_server/src/generated/fieldnotes/models/campaign_proposal.dart'
    as _imistozd;
import 'package:fieldnotes_server/src/generated/future_calls.dart' as _ivhm99lh;
import 'package:serverpod/serverpod.dart' as _is;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _iacs;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _iais;
import '../auth/email_idp_endpoint.dart' as _iuc1hd5t;
import '../auth/jwt_refresh_endpoint.dart' as _inwq3ztq;
import '../fieldnotes/fieldnote_endpoint.dart' as _i4pdwwji;
import '../fieldnotes/legal_endpoint.dart' as _ix6kkpx9;
export 'future_calls.dart' show ServerpodFutureCallsGetter;

class Endpoints extends _is.EndpointDispatch {
  @override
  void initializeEndpoints(_is.Server server) {
    var endpoints = <String, _is.Endpoint>{
      'emailIdp': _iuc1hd5t.EmailIdpEndpoint()
        ..initialize(
          server,
          'emailIdp',
          null,
        ),
      'jwtRefresh': _inwq3ztq.JwtRefreshEndpoint()
        ..initialize(
          server,
          'jwtRefresh',
          null,
        ),
      'fieldnote': _i4pdwwji.FieldnoteEndpoint()
        ..initialize(
          server,
          'fieldnote',
          null,
        ),
      'legal': _ix6kkpx9.LegalEndpoint()
        ..initialize(
          server,
          'legal',
          null,
        ),
    };
    connectors['emailIdp'] = _is.EndpointConnector(
      name: 'emailIdp',
      endpoint: endpoints['emailIdp']!,
      methodConnectors: {
        'login': _is.MethodConnector(
          name: 'login',
          params: {
            'email': _is.ParameterDescription(
              name: 'email',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'password': _is.ParameterDescription(
              name: 'password',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint).login(
                    session,
                    email: params['email'],
                    password: params['password'],
                  ),
        ),
        'startRegistration': _is.MethodConnector(
          name: 'startRegistration',
          params: {
            'email': _is.ParameterDescription(
              name: 'email',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .startRegistration(
                    session,
                    email: params['email'],
                  ),
        ),
        'verifyRegistrationCode': _is.MethodConnector(
          name: 'verifyRegistrationCode',
          params: {
            'accountRequestId': _is.ParameterDescription(
              name: 'accountRequestId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'verificationCode': _is.ParameterDescription(
              name: 'verificationCode',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .verifyRegistrationCode(
                    session,
                    accountRequestId: params['accountRequestId'],
                    verificationCode: params['verificationCode'],
                  ),
        ),
        'finishRegistration': _is.MethodConnector(
          name: 'finishRegistration',
          params: {
            'registrationToken': _is.ParameterDescription(
              name: 'registrationToken',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'password': _is.ParameterDescription(
              name: 'password',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .finishRegistration(
                    session,
                    registrationToken: params['registrationToken'],
                    password: params['password'],
                  ),
        ),
        'startPasswordReset': _is.MethodConnector(
          name: 'startPasswordReset',
          params: {
            'email': _is.ParameterDescription(
              name: 'email',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .startPasswordReset(
                    session,
                    email: params['email'],
                  ),
        ),
        'verifyPasswordResetCode': _is.MethodConnector(
          name: 'verifyPasswordResetCode',
          params: {
            'passwordResetRequestId': _is.ParameterDescription(
              name: 'passwordResetRequestId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'verificationCode': _is.ParameterDescription(
              name: 'verificationCode',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .verifyPasswordResetCode(
                    session,
                    passwordResetRequestId: params['passwordResetRequestId'],
                    verificationCode: params['verificationCode'],
                  ),
        ),
        'finishPasswordReset': _is.MethodConnector(
          name: 'finishPasswordReset',
          params: {
            'finishPasswordResetToken': _is.ParameterDescription(
              name: 'finishPasswordResetToken',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'newPassword': _is.ParameterDescription(
              name: 'newPassword',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .finishPasswordReset(
                    session,
                    finishPasswordResetToken:
                        params['finishPasswordResetToken'],
                    newPassword: params['newPassword'],
                  ),
        ),
        'hasAccount': _is.MethodConnector(
          name: 'hasAccount',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .hasAccount(session),
        ),
      },
    );
    connectors['jwtRefresh'] = _is.EndpointConnector(
      name: 'jwtRefresh',
      endpoint: endpoints['jwtRefresh']!,
      methodConnectors: {
        'refreshAccessToken': _is.MethodConnector(
          name: 'refreshAccessToken',
          params: {
            'refreshToken': _is.ParameterDescription(
              name: 'refreshToken',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['jwtRefresh'] as _inwq3ztq.JwtRefreshEndpoint)
                      .refreshAccessToken(
                        session,
                        refreshToken: params['refreshToken'],
                      ),
        ),
      },
    );
    connectors['fieldnote'] = _is.EndpointConnector(
      name: 'fieldnote',
      endpoint: endpoints['fieldnote']!,
      methodConnectors: {
        'getMyProfile': _is.MethodConnector(
          name: 'getMyProfile',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['fieldnote'] as _i4pdwwji.FieldnoteEndpoint)
                  .getMyProfile(session),
        ),
        'getMyLegalConsent': _is.MethodConnector(
          name: 'getMyLegalConsent',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['fieldnote'] as _i4pdwwji.FieldnoteEndpoint)
                  .getMyLegalConsent(session),
        ),
        'acceptLegalConsent': _is.MethodConnector(
          name: 'acceptLegalConsent',
          params: {
            'locationConsent': _is.ParameterDescription(
              name: 'locationConsent',
              type: _is.getType<bool>(),
              nullable: false,
            ),
            'aiProcessingConsent': _is.ParameterDescription(
              name: 'aiProcessingConsent',
              type: _is.getType<bool>(),
              nullable: false,
            ),
            'evidenceSharingConsent': _is.ParameterDescription(
              name: 'evidenceSharingConsent',
              type: _is.getType<bool>(),
              nullable: false,
            ),
            'acceptedPrivacyPolicyVersion': _is.ParameterDescription(
              name: 'acceptedPrivacyPolicyVersion',
              type: _is.getType<String?>(),
              nullable: true,
            ),
            'acceptedTermsVersion': _is.ParameterDescription(
              name: 'acceptedTermsVersion',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['fieldnote'] as _i4pdwwji.FieldnoteEndpoint)
                  .acceptLegalConsent(
                    session,
                    params['locationConsent'],
                    params['aiProcessingConsent'],
                    params['evidenceSharingConsent'],
                    acceptedPrivacyPolicyVersion:
                        params['acceptedPrivacyPolicyVersion'],
                    acceptedTermsVersion: params['acceptedTermsVersion'],
                  ),
        ),
        'withdrawConsent': _is.MethodConnector(
          name: 'withdrawConsent',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['fieldnote'] as _i4pdwwji.FieldnoteEndpoint)
                  .withdrawConsent(session),
        ),
        'listMyConsentHistory': _is.MethodConnector(
          name: 'listMyConsentHistory',
          params: {
            'limit': _is.ParameterDescription(
              name: 'limit',
              type: _is.getType<int?>(),
              nullable: true,
            ),
            'offset': _is.ParameterDescription(
              name: 'offset',
              type: _is.getType<int?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['fieldnote'] as _i4pdwwji.FieldnoteEndpoint)
                  .listMyConsentHistory(
                    session,
                    limit: params['limit'],
                    offset: params['offset'],
                  ),
        ),
        'setEmailNotifications': _is.MethodConnector(
          name: 'setEmailNotifications',
          params: {
            'enabled': _is.ParameterDescription(
              name: 'enabled',
              type: _is.getType<bool>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['fieldnote'] as _i4pdwwji.FieldnoteEndpoint)
                  .setEmailNotifications(
                    session,
                    params['enabled'],
                  ),
        ),
        'getTrustCenter': _is.MethodConnector(
          name: 'getTrustCenter',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['fieldnote'] as _i4pdwwji.FieldnoteEndpoint)
                  .getTrustCenter(session),
        ),
        'exportMyData': _is.MethodConnector(
          name: 'exportMyData',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['fieldnote'] as _i4pdwwji.FieldnoteEndpoint)
                  .exportMyData(session),
        ),
        'recordAccountDataExport': _is.MethodConnector(
          name: 'recordAccountDataExport',
          params: {
            'format': _is.ParameterDescription(
              name: 'format',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['fieldnote'] as _i4pdwwji.FieldnoteEndpoint)
                  .recordAccountDataExport(
                    session,
                    params['format'],
                  ),
        ),
        'requestAccountDeletion': _is.MethodConnector(
          name: 'requestAccountDeletion',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['fieldnote'] as _i4pdwwji.FieldnoteEndpoint)
                  .requestAccountDeletion(session),
        ),
        'getAccountDeletionStatus': _is.MethodConnector(
          name: 'getAccountDeletionStatus',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['fieldnote'] as _i4pdwwji.FieldnoteEndpoint)
                  .getAccountDeletionStatus(session),
        ),
        'completeSponsorProfile': _is.MethodConnector(
          name: 'completeSponsorProfile',
          params: {
            'displayName': _is.ParameterDescription(
              name: 'displayName',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'sponsorType': _is.ParameterDescription(
              name: 'sponsorType',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'organizationName': _is.ParameterDescription(
              name: 'organizationName',
              type: _is.getType<String?>(),
              nullable: true,
            ),
            'city': _is.ParameterDescription(
              name: 'city',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'cityPlaceId': _is.ParameterDescription(
              name: 'cityPlaceId',
              type: _is.getType<String?>(),
              nullable: true,
            ),
            'interests': _is.ParameterDescription(
              name: 'interests',
              type: _is.getType<List<String>>(),
              nullable: false,
            ),
            'locationLatitude': _is.ParameterDescription(
              name: 'locationLatitude',
              type: _is.getType<double?>(),
              nullable: true,
            ),
            'locationLongitude': _is.ParameterDescription(
              name: 'locationLongitude',
              type: _is.getType<double?>(),
              nullable: true,
            ),
            'contactPhone': _is.ParameterDescription(
              name: 'contactPhone',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['fieldnote'] as _i4pdwwji.FieldnoteEndpoint)
                  .completeSponsorProfile(
                    session,
                    params['displayName'],
                    params['sponsorType'],
                    params['organizationName'],
                    params['city'],
                    params['cityPlaceId'],
                    params['interests'],
                    locationLatitude: params['locationLatitude'],
                    locationLongitude: params['locationLongitude'],
                    contactPhone: params['contactPhone'],
                  ),
        ),
        'completeVolunteerProfile': _is.MethodConnector(
          name: 'completeVolunteerProfile',
          params: {
            'displayName': _is.ParameterDescription(
              name: 'displayName',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'city': _is.ParameterDescription(
              name: 'city',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'interests': _is.ParameterDescription(
              name: 'interests',
              type: _is.getType<List<String>>(),
              nullable: false,
            ),
            'skills': _is.ParameterDescription(
              name: 'skills',
              type: _is.getType<List<String>>(),
              nullable: false,
            ),
            'isAvailable': _is.ParameterDescription(
              name: 'isAvailable',
              type: _is.getType<bool>(),
              nullable: false,
            ),
            'availableToday': _is.ParameterDescription(
              name: 'availableToday',
              type: _is.getType<bool>(),
              nullable: false,
            ),
            'weekdays': _is.ParameterDescription(
              name: 'weekdays',
              type: _is.getType<List<int>>(),
              nullable: false,
            ),
            'startMinutes': _is.ParameterDescription(
              name: 'startMinutes',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'endMinutes': _is.ParameterDescription(
              name: 'endMinutes',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'maximumTravelKm': _is.ParameterDescription(
              name: 'maximumTravelKm',
              type: _is.getType<double>(),
              nullable: false,
            ),
            'latitude': _is.ParameterDescription(
              name: 'latitude',
              type: _is.getType<double?>(),
              nullable: true,
            ),
            'longitude': _is.ParameterDescription(
              name: 'longitude',
              type: _is.getType<double?>(),
              nullable: true,
            ),
            'locationLabel': _is.ParameterDescription(
              name: 'locationLabel',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'timezone': _is.ParameterDescription(
              name: 'timezone',
              type: _is.getType<String?>(),
              nullable: true,
            ),
            'utcOffsetMinutes': _is.ParameterDescription(
              name: 'utcOffsetMinutes',
              type: _is.getType<int?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['fieldnote'] as _i4pdwwji.FieldnoteEndpoint)
                  .completeVolunteerProfile(
                    session,
                    params['displayName'],
                    params['city'],
                    params['interests'],
                    params['skills'],
                    params['isAvailable'],
                    params['availableToday'],
                    params['weekdays'],
                    params['startMinutes'],
                    params['endMinutes'],
                    params['maximumTravelKm'],
                    params['latitude'],
                    params['longitude'],
                    params['locationLabel'],
                    timezone: params['timezone'],
                    utcOffsetMinutes: params['utcOffsetMinutes'],
                  ),
        ),
        'updateMyProfile': _is.MethodConnector(
          name: 'updateMyProfile',
          params: {
            'displayName': _is.ParameterDescription(
              name: 'displayName',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'sponsorType': _is.ParameterDescription(
              name: 'sponsorType',
              type: _is.getType<String?>(),
              nullable: true,
            ),
            'organizationName': _is.ParameterDescription(
              name: 'organizationName',
              type: _is.getType<String?>(),
              nullable: true,
            ),
            'city': _is.ParameterDescription(
              name: 'city',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'cityPlaceId': _is.ParameterDescription(
              name: 'cityPlaceId',
              type: _is.getType<String?>(),
              nullable: true,
            ),
            'interests': _is.ParameterDescription(
              name: 'interests',
              type: _is.getType<List<String>>(),
              nullable: false,
            ),
            'skills': _is.ParameterDescription(
              name: 'skills',
              type: _is.getType<List<String>>(),
              nullable: false,
            ),
            'locationLatitude': _is.ParameterDescription(
              name: 'locationLatitude',
              type: _is.getType<double?>(),
              nullable: true,
            ),
            'locationLongitude': _is.ParameterDescription(
              name: 'locationLongitude',
              type: _is.getType<double?>(),
              nullable: true,
            ),
            'contactPhone': _is.ParameterDescription(
              name: 'contactPhone',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['fieldnote'] as _i4pdwwji.FieldnoteEndpoint)
                  .updateMyProfile(
                    session,
                    params['displayName'],
                    params['sponsorType'],
                    params['organizationName'],
                    params['city'],
                    params['cityPlaceId'],
                    params['interests'],
                    params['skills'],
                    locationLatitude: params['locationLatitude'],
                    locationLongitude: params['locationLongitude'],
                    contactPhone: params['contactPhone'],
                  ),
        ),
        'getMyAvailability': _is.MethodConnector(
          name: 'getMyAvailability',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['fieldnote'] as _i4pdwwji.FieldnoteEndpoint)
                  .getMyAvailability(session),
        ),
        'updateAvailability': _is.MethodConnector(
          name: 'updateAvailability',
          params: {
            'isAvailable': _is.ParameterDescription(
              name: 'isAvailable',
              type: _is.getType<bool>(),
              nullable: false,
            ),
            'availableToday': _is.ParameterDescription(
              name: 'availableToday',
              type: _is.getType<bool>(),
              nullable: false,
            ),
            'weekdays': _is.ParameterDescription(
              name: 'weekdays',
              type: _is.getType<List<int>>(),
              nullable: false,
            ),
            'startMinutes': _is.ParameterDescription(
              name: 'startMinutes',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'endMinutes': _is.ParameterDescription(
              name: 'endMinutes',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'maximumTravelKm': _is.ParameterDescription(
              name: 'maximumTravelKm',
              type: _is.getType<double>(),
              nullable: false,
            ),
            'latitude': _is.ParameterDescription(
              name: 'latitude',
              type: _is.getType<double?>(),
              nullable: true,
            ),
            'longitude': _is.ParameterDescription(
              name: 'longitude',
              type: _is.getType<double?>(),
              nullable: true,
            ),
            'locationLabel': _is.ParameterDescription(
              name: 'locationLabel',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'timezone': _is.ParameterDescription(
              name: 'timezone',
              type: _is.getType<String?>(),
              nullable: true,
            ),
            'utcOffsetMinutes': _is.ParameterDescription(
              name: 'utcOffsetMinutes',
              type: _is.getType<int?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['fieldnote'] as _i4pdwwji.FieldnoteEndpoint)
                  .updateAvailability(
                    session,
                    params['isAvailable'],
                    params['availableToday'],
                    params['weekdays'],
                    params['startMinutes'],
                    params['endMinutes'],
                    params['maximumTravelKm'],
                    params['latitude'],
                    params['longitude'],
                    params['locationLabel'],
                    timezone: params['timezone'],
                    utcOffsetMinutes: params['utcOffsetMinutes'],
                  ),
        ),
        'transcribeDictation': _is.MethodConnector(
          name: 'transcribeDictation',
          params: {
            'audio': _is.ParameterDescription(
              name: 'audio',
              type: _is.getType<_idt.ByteData>(),
              nullable: false,
            ),
            'fileName': _is.ParameterDescription(
              name: 'fileName',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'mimeType': _is.ParameterDescription(
              name: 'mimeType',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['fieldnote'] as _i4pdwwji.FieldnoteEndpoint)
                  .transcribeDictation(
                    session,
                    params['audio'],
                    params['fileName'],
                    params['mimeType'],
                  ),
        ),
        'proposeCampaign': _is.MethodConnector(
          name: 'proposeCampaign',
          params: {
            'prompt': _is.ParameterDescription(
              name: 'prompt',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'utcOffsetMinutes': _is.ParameterDescription(
              name: 'utcOffsetMinutes',
              type: _is.getType<int?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['fieldnote'] as _i4pdwwji.FieldnoteEndpoint)
                  .proposeCampaign(
                    session,
                    params['prompt'],
                    utcOffsetMinutes: params['utcOffsetMinutes'],
                  ),
        ),
        'createCampaignFromProposal': _is.MethodConnector(
          name: 'createCampaignFromProposal',
          params: {
            'proposal': _is.ParameterDescription(
              name: 'proposal',
              type: _is.getType<_imistozd.CampaignProposal>(),
              nullable: false,
            ),
            'latitude': _is.ParameterDescription(
              name: 'latitude',
              type: _is.getType<double>(),
              nullable: false,
            ),
            'longitude': _is.ParameterDescription(
              name: 'longitude',
              type: _is.getType<double>(),
              nullable: false,
            ),
            'locationName': _is.ParameterDescription(
              name: 'locationName',
              type: _is.getType<String?>(),
              nullable: true,
            ),
            'geofenceMeters': _is.ParameterDescription(
              name: 'geofenceMeters',
              type: _is.getType<double?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['fieldnote'] as _i4pdwwji.FieldnoteEndpoint)
                  .createCampaignFromProposal(
                    session,
                    params['proposal'],
                    params['latitude'],
                    params['longitude'],
                    params['locationName'],
                    params['geofenceMeters'],
                  ),
        ),
        'listCampaigns': _is.MethodConnector(
          name: 'listCampaigns',
          params: {
            'limit': _is.ParameterDescription(
              name: 'limit',
              type: _is.getType<int?>(),
              nullable: true,
            ),
            'offset': _is.ParameterDescription(
              name: 'offset',
              type: _is.getType<int?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['fieldnote'] as _i4pdwwji.FieldnoteEndpoint)
                  .listCampaigns(
                    session,
                    limit: params['limit'],
                    offset: params['offset'],
                  ),
        ),
        'getSharedCampaignBySlug': _is.MethodConnector(
          name: 'getSharedCampaignBySlug',
          params: {
            'shareSlug': _is.ParameterDescription(
              name: 'shareSlug',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['fieldnote'] as _i4pdwwji.FieldnoteEndpoint)
                  .getSharedCampaignBySlug(
                    session,
                    params['shareSlug'],
                  ),
        ),
        'getCampaignShareLink': _is.MethodConnector(
          name: 'getCampaignShareLink',
          params: {
            'campaignId': _is.ParameterDescription(
              name: 'campaignId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['fieldnote'] as _i4pdwwji.FieldnoteEndpoint)
                  .getCampaignShareLink(
                    session,
                    params['campaignId'],
                  ),
        ),
        'getSharedCampaign': _is.MethodConnector(
          name: 'getSharedCampaign',
          params: {
            'campaignId': _is.ParameterDescription(
              name: 'campaignId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['fieldnote'] as _i4pdwwji.FieldnoteEndpoint)
                  .getSharedCampaign(
                    session,
                    params['campaignId'],
                  ),
        ),
        'listMyCreatedCampaigns': _is.MethodConnector(
          name: 'listMyCreatedCampaigns',
          params: {
            'limit': _is.ParameterDescription(
              name: 'limit',
              type: _is.getType<int?>(),
              nullable: true,
            ),
            'offset': _is.ParameterDescription(
              name: 'offset',
              type: _is.getType<int?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['fieldnote'] as _i4pdwwji.FieldnoteEndpoint)
                  .listMyCreatedCampaigns(
                    session,
                    limit: params['limit'],
                    offset: params['offset'],
                  ),
        ),
        'refreshCampaignReadiness': _is.MethodConnector(
          name: 'refreshCampaignReadiness',
          params: {
            'campaignId': _is.ParameterDescription(
              name: 'campaignId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['fieldnote'] as _i4pdwwji.FieldnoteEndpoint)
                  .refreshCampaignReadiness(
                    session,
                    params['campaignId'],
                  ),
        ),
        'reviseCampaignScope': _is.MethodConnector(
          name: 'reviseCampaignScope',
          params: {
            'campaignId': _is.ParameterDescription(
              name: 'campaignId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'fundingGoal': _is.ParameterDescription(
              name: 'fundingGoal',
              type: _is.getType<double>(),
              nullable: false,
            ),
            'minimumVolunteers': _is.ParameterDescription(
              name: 'minimumVolunteers',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'description': _is.ParameterDescription(
              name: 'description',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['fieldnote'] as _i4pdwwji.FieldnoteEndpoint)
                  .reviseCampaignScope(
                    session,
                    params['campaignId'],
                    params['fundingGoal'],
                    params['minimumVolunteers'],
                    params['description'],
                  ),
        ),
        'postponeCampaign': _is.MethodConnector(
          name: 'postponeCampaign',
          params: {
            'campaignId': _is.ParameterDescription(
              name: 'campaignId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'newStartsAt': _is.ParameterDescription(
              name: 'newStartsAt',
              type: _is.getType<DateTime>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['fieldnote'] as _i4pdwwji.FieldnoteEndpoint)
                  .postponeCampaign(
                    session,
                    params['campaignId'],
                    params['newStartsAt'],
                  ),
        ),
        'cancelCampaign': _is.MethodConnector(
          name: 'cancelCampaign',
          params: {
            'campaignId': _is.ParameterDescription(
              name: 'campaignId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['fieldnote'] as _i4pdwwji.FieldnoteEndpoint)
                  .cancelCampaign(
                    session,
                    params['campaignId'],
                  ),
        ),
        'reconfirmCampaignParticipation': _is.MethodConnector(
          name: 'reconfirmCampaignParticipation',
          params: {
            'participationId': _is.ParameterDescription(
              name: 'participationId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['fieldnote'] as _i4pdwwji.FieldnoteEndpoint)
                  .reconfirmCampaignParticipation(
                    session,
                    params['participationId'],
                  ),
        ),
        'listMyJoinedCampaigns': _is.MethodConnector(
          name: 'listMyJoinedCampaigns',
          params: {
            'limit': _is.ParameterDescription(
              name: 'limit',
              type: _is.getType<int?>(),
              nullable: true,
            ),
            'offset': _is.ParameterDescription(
              name: 'offset',
              type: _is.getType<int?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['fieldnote'] as _i4pdwwji.FieldnoteEndpoint)
                  .listMyJoinedCampaigns(
                    session,
                    limit: params['limit'],
                    offset: params['offset'],
                  ),
        ),
        'isCitySearchAvailable': _is.MethodConnector(
          name: 'isCitySearchAvailable',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['fieldnote'] as _i4pdwwji.FieldnoteEndpoint)
                  .isCitySearchAvailable(session),
        ),
        'searchCities': _is.MethodConnector(
          name: 'searchCities',
          params: {
            'query': _is.ParameterDescription(
              name: 'query',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['fieldnote'] as _i4pdwwji.FieldnoteEndpoint)
                  .searchCities(
                    session,
                    params['query'],
                  ),
        ),
        'searchSponsorLocations': _is.MethodConnector(
          name: 'searchSponsorLocations',
          params: {
            'query': _is.ParameterDescription(
              name: 'query',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['fieldnote'] as _i4pdwwji.FieldnoteEndpoint)
                  .searchSponsorLocations(
                    session,
                    params['query'],
                  ),
        ),
        'isPlaceSearchAvailable': _is.MethodConnector(
          name: 'isPlaceSearchAvailable',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['fieldnote'] as _i4pdwwji.FieldnoteEndpoint)
                  .isPlaceSearchAvailable(session),
        ),
        'searchPlaces': _is.MethodConnector(
          name: 'searchPlaces',
          params: {
            'query': _is.ParameterDescription(
              name: 'query',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'biasLatitude': _is.ParameterDescription(
              name: 'biasLatitude',
              type: _is.getType<double?>(),
              nullable: true,
            ),
            'biasLongitude': _is.ParameterDescription(
              name: 'biasLongitude',
              type: _is.getType<double?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['fieldnote'] as _i4pdwwji.FieldnoteEndpoint)
                  .searchPlaces(
                    session,
                    params['query'],
                    params['biasLatitude'],
                    params['biasLongitude'],
                  ),
        ),
        'resolvePlace': _is.MethodConnector(
          name: 'resolvePlace',
          params: {
            'placeId': _is.ParameterDescription(
              name: 'placeId',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['fieldnote'] as _i4pdwwji.FieldnoteEndpoint)
                  .resolvePlace(
                    session,
                    params['placeId'],
                  ),
        ),
        'describeCoordinates': _is.MethodConnector(
          name: 'describeCoordinates',
          params: {
            'latitude': _is.ParameterDescription(
              name: 'latitude',
              type: _is.getType<double>(),
              nullable: false,
            ),
            'longitude': _is.ParameterDescription(
              name: 'longitude',
              type: _is.getType<double>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['fieldnote'] as _i4pdwwji.FieldnoteEndpoint)
                  .describeCoordinates(
                    session,
                    params['latitude'],
                    params['longitude'],
                  ),
        ),
        'getTravelRoute': _is.MethodConnector(
          name: 'getTravelRoute',
          params: {
            'campaignId': _is.ParameterDescription(
              name: 'campaignId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'originLatitude': _is.ParameterDescription(
              name: 'originLatitude',
              type: _is.getType<double>(),
              nullable: false,
            ),
            'originLongitude': _is.ParameterDescription(
              name: 'originLongitude',
              type: _is.getType<double>(),
              nullable: false,
            ),
            'travelMode': _is.ParameterDescription(
              name: 'travelMode',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['fieldnote'] as _i4pdwwji.FieldnoteEndpoint)
                  .getTravelRoute(
                    session,
                    params['campaignId'],
                    params['originLatitude'],
                    params['originLongitude'],
                    params['travelMode'],
                  ),
        ),
        'previewCampaignReach': _is.MethodConnector(
          name: 'previewCampaignReach',
          params: {
            'latitude': _is.ParameterDescription(
              name: 'latitude',
              type: _is.getType<double>(),
              nullable: false,
            ),
            'longitude': _is.ParameterDescription(
              name: 'longitude',
              type: _is.getType<double>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['fieldnote'] as _i4pdwwji.FieldnoteEndpoint)
                  .previewCampaignReach(
                    session,
                    params['latitude'],
                    params['longitude'],
                  ),
        ),
        'getCampaignVolunteerReach': _is.MethodConnector(
          name: 'getCampaignVolunteerReach',
          params: {
            'campaignId': _is.ParameterDescription(
              name: 'campaignId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['fieldnote'] as _i4pdwwji.FieldnoteEndpoint)
                  .getCampaignVolunteerReach(
                    session,
                    params['campaignId'],
                  ),
        ),
        'getCampaignVolunteerMap': _is.MethodConnector(
          name: 'getCampaignVolunteerMap',
          params: {
            'campaignId': _is.ParameterDescription(
              name: 'campaignId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['fieldnote'] as _i4pdwwji.FieldnoteEndpoint)
                  .getCampaignVolunteerMap(
                    session,
                    params['campaignId'],
                  ),
        ),
        'inviteCampaignVolunteer': _is.MethodConnector(
          name: 'inviteCampaignVolunteer',
          params: {
            'campaignId': _is.ParameterDescription(
              name: 'campaignId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'volunteerProfileId': _is.ParameterDescription(
              name: 'volunteerProfileId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['fieldnote'] as _i4pdwwji.FieldnoteEndpoint)
                  .inviteCampaignVolunteer(
                    session,
                    params['campaignId'],
                    params['volunteerProfileId'],
                  ),
        ),
        'inviteCampaignVolunteersInArea': _is.MethodConnector(
          name: 'inviteCampaignVolunteersInArea',
          params: {
            'campaignId': _is.ParameterDescription(
              name: 'campaignId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'areaLatitude': _is.ParameterDescription(
              name: 'areaLatitude',
              type: _is.getType<double>(),
              nullable: false,
            ),
            'areaLongitude': _is.ParameterDescription(
              name: 'areaLongitude',
              type: _is.getType<double>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['fieldnote'] as _i4pdwwji.FieldnoteEndpoint)
                  .inviteCampaignVolunteersInArea(
                    session,
                    params['campaignId'],
                    params['areaLatitude'],
                    params['areaLongitude'],
                  ),
        ),
        'listMyCampaignInvitations': _is.MethodConnector(
          name: 'listMyCampaignInvitations',
          params: {
            'limit': _is.ParameterDescription(
              name: 'limit',
              type: _is.getType<int?>(),
              nullable: true,
            ),
            'offset': _is.ParameterDescription(
              name: 'offset',
              type: _is.getType<int?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['fieldnote'] as _i4pdwwji.FieldnoteEndpoint)
                  .listMyCampaignInvitations(
                    session,
                    limit: params['limit'],
                    offset: params['offset'],
                  ),
        ),
        'getCampaignMap': _is.MethodConnector(
          name: 'getCampaignMap',
          params: {
            'campaignId': _is.ParameterDescription(
              name: 'campaignId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['fieldnote'] as _i4pdwwji.FieldnoteEndpoint)
                  .getCampaignMap(
                    session,
                    params['campaignId'],
                  ),
        ),
        'createRazorpayOrder': _is.MethodConnector(
          name: 'createRazorpayOrder',
          params: {
            'campaignId': _is.ParameterDescription(
              name: 'campaignId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'amount': _is.ParameterDescription(
              name: 'amount',
              type: _is.getType<double>(),
              nullable: false,
            ),
            'message': _is.ParameterDescription(
              name: 'message',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['fieldnote'] as _i4pdwwji.FieldnoteEndpoint)
                  .createRazorpayOrder(
                    session,
                    params['campaignId'],
                    params['amount'],
                    params['message'],
                  ),
        ),
        'verifyRazorpayPayment': _is.MethodConnector(
          name: 'verifyRazorpayPayment',
          params: {
            'sponsorshipId': _is.ParameterDescription(
              name: 'sponsorshipId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'orderId': _is.ParameterDescription(
              name: 'orderId',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'paymentId': _is.ParameterDescription(
              name: 'paymentId',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'signature': _is.ParameterDescription(
              name: 'signature',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['fieldnote'] as _i4pdwwji.FieldnoteEndpoint)
                  .verifyRazorpayPayment(
                    session,
                    params['sponsorshipId'],
                    params['orderId'],
                    params['paymentId'],
                    params['signature'],
                  ),
        ),
        'recordRazorpayFailure': _is.MethodConnector(
          name: 'recordRazorpayFailure',
          params: {
            'sponsorshipId': _is.ParameterDescription(
              name: 'sponsorshipId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'reason': _is.ParameterDescription(
              name: 'reason',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['fieldnote'] as _i4pdwwji.FieldnoteEndpoint)
                  .recordRazorpayFailure(
                    session,
                    params['sponsorshipId'],
                    params['reason'],
                  ),
        ),
        'listMySponsorships': _is.MethodConnector(
          name: 'listMySponsorships',
          params: {
            'limit': _is.ParameterDescription(
              name: 'limit',
              type: _is.getType<int?>(),
              nullable: true,
            ),
            'offset': _is.ParameterDescription(
              name: 'offset',
              type: _is.getType<int?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['fieldnote'] as _i4pdwwji.FieldnoteEndpoint)
                  .listMySponsorships(
                    session,
                    limit: params['limit'],
                    offset: params['offset'],
                  ),
        ),
        'listCampaignTestPayouts': _is.MethodConnector(
          name: 'listCampaignTestPayouts',
          params: {
            'campaignId': _is.ParameterDescription(
              name: 'campaignId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'limit': _is.ParameterDescription(
              name: 'limit',
              type: _is.getType<int?>(),
              nullable: true,
            ),
            'offset': _is.ParameterDescription(
              name: 'offset',
              type: _is.getType<int?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['fieldnote'] as _i4pdwwji.FieldnoteEndpoint)
                  .listCampaignTestPayouts(
                    session,
                    params['campaignId'],
                    limit: params['limit'],
                    offset: params['offset'],
                  ),
        ),
        'simulateCampaignTestPayout': _is.MethodConnector(
          name: 'simulateCampaignTestPayout',
          params: {
            'campaignId': _is.ParameterDescription(
              name: 'campaignId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['fieldnote'] as _i4pdwwji.FieldnoteEndpoint)
                  .simulateCampaignTestPayout(
                    session,
                    params['campaignId'],
                  ),
        ),
        'getCampaignMatches': _is.MethodConnector(
          name: 'getCampaignMatches',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['fieldnote'] as _i4pdwwji.FieldnoteEndpoint)
                  .getCampaignMatches(session),
        ),
        'joinCampaign': _is.MethodConnector(
          name: 'joinCampaign',
          params: {
            'campaignId': _is.ParameterDescription(
              name: 'campaignId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['fieldnote'] as _i4pdwwji.FieldnoteEndpoint)
                  .joinCampaign(
                    session,
                    params['campaignId'],
                  ),
        ),
        'leaveCampaign': _is.MethodConnector(
          name: 'leaveCampaign',
          params: {
            'participationId': _is.ParameterDescription(
              name: 'participationId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['fieldnote'] as _i4pdwwji.FieldnoteEndpoint)
                  .leaveCampaign(
                    session,
                    params['participationId'],
                  ),
        ),
        'getCampaignContactPhone': _is.MethodConnector(
          name: 'getCampaignContactPhone',
          params: {
            'campaignId': _is.ParameterDescription(
              name: 'campaignId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['fieldnote'] as _i4pdwwji.FieldnoteEndpoint)
                  .getCampaignContactPhone(
                    session,
                    params['campaignId'],
                  ),
        ),
        'listMyParticipations': _is.MethodConnector(
          name: 'listMyParticipations',
          params: {
            'limit': _is.ParameterDescription(
              name: 'limit',
              type: _is.getType<int?>(),
              nullable: true,
            ),
            'offset': _is.ParameterDescription(
              name: 'offset',
              type: _is.getType<int?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['fieldnote'] as _i4pdwwji.FieldnoteEndpoint)
                  .listMyParticipations(
                    session,
                    limit: params['limit'],
                    offset: params['offset'],
                  ),
        ),
        'checkIn': _is.MethodConnector(
          name: 'checkIn',
          params: {
            'participationId': _is.ParameterDescription(
              name: 'participationId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'latitude': _is.ParameterDescription(
              name: 'latitude',
              type: _is.getType<double>(),
              nullable: false,
            ),
            'longitude': _is.ParameterDescription(
              name: 'longitude',
              type: _is.getType<double>(),
              nullable: false,
            ),
            'accuracyMeters': _is.ParameterDescription(
              name: 'accuracyMeters',
              type: _is.getType<double>(),
              nullable: false,
            ),
            'deviceReportedMock': _is.ParameterDescription(
              name: 'deviceReportedMock',
              type: _is.getType<bool>(),
              nullable: false,
            ),
            'explicitDemo': _is.ParameterDescription(
              name: 'explicitDemo',
              type: _is.getType<bool>(),
              nullable: false,
            ),
            'capturedAt': _is.ParameterDescription(
              name: 'capturedAt',
              type: _is.getType<DateTime>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['fieldnote'] as _i4pdwwji.FieldnoteEndpoint)
                  .checkIn(
                    session,
                    params['participationId'],
                    params['latitude'],
                    params['longitude'],
                    params['accuracyMeters'],
                    params['deviceReportedMock'],
                    params['explicitDemo'],
                    params['capturedAt'],
                  ),
        ),
        'analyzeCompletion': _is.MethodConnector(
          name: 'analyzeCompletion',
          params: {
            'participationId': _is.ParameterDescription(
              name: 'participationId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'note': _is.ParameterDescription(
              name: 'note',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'photograph': _is.ParameterDescription(
              name: 'photograph',
              type: _is.getType<_idt.ByteData?>(),
              nullable: true,
            ),
            'photographMimeType': _is.ParameterDescription(
              name: 'photographMimeType',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['fieldnote'] as _i4pdwwji.FieldnoteEndpoint)
                  .analyzeCompletion(
                    session,
                    params['participationId'],
                    params['note'],
                    params['photograph'],
                    params['photographMimeType'],
                  ),
        ),
        'isAiAvailable': _is.MethodConnector(
          name: 'isAiAvailable',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['fieldnote'] as _i4pdwwji.FieldnoteEndpoint)
                  .isAiAvailable(session),
        ),
        'getEvidenceUploadDescription': _is.MethodConnector(
          name: 'getEvidenceUploadDescription',
          params: {
            'participationId': _is.ParameterDescription(
              name: 'participationId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'extension': _is.ParameterDescription(
              name: 'extension',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['fieldnote'] as _i4pdwwji.FieldnoteEndpoint)
                  .getEvidenceUploadDescription(
                    session,
                    params['participationId'],
                    params['extension'],
                  ),
        ),
        'completeParticipation': _is.MethodConnector(
          name: 'completeParticipation',
          params: {
            'participationId': _is.ParameterDescription(
              name: 'participationId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'photoExtension': _is.ParameterDescription(
              name: 'photoExtension',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'originalNote': _is.ParameterDescription(
              name: 'originalNote',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'confirmedSummary': _is.ParameterDescription(
              name: 'confirmedSummary',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'structuredResults': _is.ParameterDescription(
              name: 'structuredResults',
              type: _is.getType<List<String>>(),
              nullable: false,
            ),
            'latitude': _is.ParameterDescription(
              name: 'latitude',
              type: _is.getType<double>(),
              nullable: false,
            ),
            'longitude': _is.ParameterDescription(
              name: 'longitude',
              type: _is.getType<double>(),
              nullable: false,
            ),
            'accuracyMeters': _is.ParameterDescription(
              name: 'accuracyMeters',
              type: _is.getType<double>(),
              nullable: false,
            ),
            'deviceReportedMock': _is.ParameterDescription(
              name: 'deviceReportedMock',
              type: _is.getType<bool>(),
              nullable: false,
            ),
            'explicitDemo': _is.ParameterDescription(
              name: 'explicitDemo',
              type: _is.getType<bool>(),
              nullable: false,
            ),
            'capturedAt': _is.ParameterDescription(
              name: 'capturedAt',
              type: _is.getType<DateTime>(),
              nullable: false,
            ),
            'uploadPath': _is.ParameterDescription(
              name: 'uploadPath',
              type: _is.getType<String?>(),
              nullable: true,
            ),
            'manualSummary': _is.ParameterDescription(
              name: 'manualSummary',
              type: _is.getType<bool?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['fieldnote'] as _i4pdwwji.FieldnoteEndpoint)
                  .completeParticipation(
                    session,
                    params['participationId'],
                    params['photoExtension'],
                    params['originalNote'],
                    params['confirmedSummary'],
                    params['structuredResults'],
                    params['latitude'],
                    params['longitude'],
                    params['accuracyMeters'],
                    params['deviceReportedMock'],
                    params['explicitDemo'],
                    params['capturedAt'],
                    uploadPath: params['uploadPath'],
                    manualSummary: params['manualSummary'],
                  ),
        ),
        'reviewEvidence': _is.MethodConnector(
          name: 'reviewEvidence',
          params: {
            'evidenceId': _is.ParameterDescription(
              name: 'evidenceId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'approve': _is.ParameterDescription(
              name: 'approve',
              type: _is.getType<bool>(),
              nullable: false,
            ),
            'note': _is.ParameterDescription(
              name: 'note',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['fieldnote'] as _i4pdwwji.FieldnoteEndpoint)
                  .reviewEvidence(
                    session,
                    params['evidenceId'],
                    params['approve'],
                    params['note'],
                  ),
        ),
        'getEvidenceDownloadUrl': _is.MethodConnector(
          name: 'getEvidenceDownloadUrl',
          params: {
            'evidenceId': _is.ParameterDescription(
              name: 'evidenceId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['fieldnote'] as _i4pdwwji.FieldnoteEndpoint)
                  .getEvidenceDownloadUrl(
                    session,
                    params['evidenceId'],
                  ),
        ),
        'getImpact': _is.MethodConnector(
          name: 'getImpact',
          params: {
            'campaignId': _is.ParameterDescription(
              name: 'campaignId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['fieldnote'] as _i4pdwwji.FieldnoteEndpoint)
                  .getImpact(
                    session,
                    params['campaignId'],
                  ),
        ),
        'listMyCampaigns': _is.MethodConnector(
          name: 'listMyCampaigns',
          params: {
            'limit': _is.ParameterDescription(
              name: 'limit',
              type: _is.getType<int?>(),
              nullable: true,
            ),
            'offset': _is.ParameterDescription(
              name: 'offset',
              type: _is.getType<int?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['fieldnote'] as _i4pdwwji.FieldnoteEndpoint)
                  .listMyCampaigns(
                    session,
                    limit: params['limit'],
                    offset: params['offset'],
                  ),
        ),
        'listMyPaymentHistory': _is.MethodConnector(
          name: 'listMyPaymentHistory',
          params: {
            'limit': _is.ParameterDescription(
              name: 'limit',
              type: _is.getType<int?>(),
              nullable: true,
            ),
            'offset': _is.ParameterDescription(
              name: 'offset',
              type: _is.getType<int?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['fieldnote'] as _i4pdwwji.FieldnoteEndpoint)
                  .listMyPaymentHistory(
                    session,
                    limit: params['limit'],
                    offset: params['offset'],
                  ),
        ),
        'listMyParticipationHistory': _is.MethodConnector(
          name: 'listMyParticipationHistory',
          params: {
            'limit': _is.ParameterDescription(
              name: 'limit',
              type: _is.getType<int?>(),
              nullable: true,
            ),
            'offset': _is.ParameterDescription(
              name: 'offset',
              type: _is.getType<int?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['fieldnote'] as _i4pdwwji.FieldnoteEndpoint)
                  .listMyParticipationHistory(
                    session,
                    limit: params['limit'],
                    offset: params['offset'],
                  ),
        ),
        'listCampaignRefunds': _is.MethodConnector(
          name: 'listCampaignRefunds',
          params: {
            'campaignId': _is.ParameterDescription(
              name: 'campaignId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'limit': _is.ParameterDescription(
              name: 'limit',
              type: _is.getType<int?>(),
              nullable: true,
            ),
            'offset': _is.ParameterDescription(
              name: 'offset',
              type: _is.getType<int?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['fieldnote'] as _i4pdwwji.FieldnoteEndpoint)
                  .listCampaignRefunds(
                    session,
                    params['campaignId'],
                    limit: params['limit'],
                    offset: params['offset'],
                  ),
        ),
        'createCampaignPost': _is.MethodConnector(
          name: 'createCampaignPost',
          params: {
            'campaignId': _is.ParameterDescription(
              name: 'campaignId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'title': _is.ParameterDescription(
              name: 'title',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'body': _is.ParameterDescription(
              name: 'body',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['fieldnote'] as _i4pdwwji.FieldnoteEndpoint)
                  .createCampaignPost(
                    session,
                    params['campaignId'],
                    params['title'],
                    params['body'],
                  ),
        ),
        'listCampaignPosts': _is.MethodConnector(
          name: 'listCampaignPosts',
          params: {
            'campaignId': _is.ParameterDescription(
              name: 'campaignId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'limit': _is.ParameterDescription(
              name: 'limit',
              type: _is.getType<int?>(),
              nullable: true,
            ),
            'offset': _is.ParameterDescription(
              name: 'offset',
              type: _is.getType<int?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['fieldnote'] as _i4pdwwji.FieldnoteEndpoint)
                  .listCampaignPosts(
                    session,
                    params['campaignId'],
                    limit: params['limit'],
                    offset: params['offset'],
                  ),
        ),
        'watchCampaign': _is.MethodStreamConnector(
          name: 'watchCampaign',
          params: {
            'campaignId': _is.ParameterDescription(
              name: 'campaignId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          streamParams: {},
          returnType: _is.MethodStreamReturnType.streamType,
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
                Map<String, Stream> streamParams,
              ) => (endpoints['fieldnote'] as _i4pdwwji.FieldnoteEndpoint)
                  .watchCampaign(
                    session,
                    params['campaignId'],
                  ),
        ),
      },
    );
    connectors['legal'] = _is.EndpointConnector(
      name: 'legal',
      endpoint: endpoints['legal']!,
      methodConnectors: {
        'getLegalPolicies': _is.MethodConnector(
          name: 'getLegalPolicies',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['legal'] as _ix6kkpx9.LegalEndpoint)
                  .getLegalPolicies(session),
        ),
      },
    );
    modules['serverpod_auth_idp'] = _iais.Endpoints()
      ..initializeEndpoints(server);
    modules['serverpod_auth_core'] = _iacs.Endpoints()
      ..initializeEndpoints(server);
  }

  @override
  _is.FutureCallDispatch? get futureCalls {
    return _ivhm99lh.FutureCalls();
  }
}
