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
import 'package:serverpod_client/serverpod_client.dart' as _isc;

/// Append-only consent history (T-2). LegalConsent keeps the current state;
/// every accept and withdraw also appends one row here. On account deletion
/// the rows are kept with an anonymous id as the legal record.
///
/// action: accepted | withdrawn
abstract class LegalConsentHistory
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  LegalConsentHistory._({
    this.id,
    required this.authUserId,
    required this.action,
    required this.privacyPolicyVersion,
    required this.termsVersion,
    required this.locationConsent,
    required this.aiProcessingConsent,
    required this.evidenceSharingConsent,
    DateTime? recordedAt,
  }) : recordedAt = recordedAt ?? DateTime.now();

  factory LegalConsentHistory({
    int? id,
    required _isc.UuidValue authUserId,
    required String action,
    required String privacyPolicyVersion,
    required String termsVersion,
    required bool locationConsent,
    required bool aiProcessingConsent,
    required bool evidenceSharingConsent,
    DateTime? recordedAt,
  }) = _LegalConsentHistoryImpl;

  factory LegalConsentHistory.fromJson(Map<String, dynamic> jsonSerialization) {
    return LegalConsentHistory(
      id: jsonSerialization['id'] as int?,
      authUserId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['authUserId'],
      ),
      action: jsonSerialization['action'] as String,
      privacyPolicyVersion: jsonSerialization['privacyPolicyVersion'] as String,
      termsVersion: jsonSerialization['termsVersion'] as String,
      locationConsent: _isc.BoolJsonExtension.fromJson(
        jsonSerialization['locationConsent'],
      ),
      aiProcessingConsent: _isc.BoolJsonExtension.fromJson(
        jsonSerialization['aiProcessingConsent'],
      ),
      evidenceSharingConsent: _isc.BoolJsonExtension.fromJson(
        jsonSerialization['evidenceSharingConsent'],
      ),
      recordedAt: jsonSerialization['recordedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['recordedAt'],
            ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  _isc.UuidValue authUserId;

  String action;

  String privacyPolicyVersion;

  String termsVersion;

  bool locationConsent;

  bool aiProcessingConsent;

  bool evidenceSharingConsent;

  DateTime recordedAt;

  /// Returns a shallow copy of this [LegalConsentHistory]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  LegalConsentHistory copyWith({
    int? id,
    _isc.UuidValue? authUserId,
    String? action,
    String? privacyPolicyVersion,
    String? termsVersion,
    bool? locationConsent,
    bool? aiProcessingConsent,
    bool? evidenceSharingConsent,
    DateTime? recordedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'LegalConsentHistory',
      if (id != null) 'id': id,
      'authUserId': authUserId.toJson(),
      'action': action,
      'privacyPolicyVersion': privacyPolicyVersion,
      'termsVersion': termsVersion,
      'locationConsent': locationConsent,
      'aiProcessingConsent': aiProcessingConsent,
      'evidenceSharingConsent': evidenceSharingConsent,
      'recordedAt': recordedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'LegalConsentHistory',
      if (id != null) 'id': id,
      'authUserId': authUserId.toJson(),
      'action': action,
      'privacyPolicyVersion': privacyPolicyVersion,
      'termsVersion': termsVersion,
      'locationConsent': locationConsent,
      'aiProcessingConsent': aiProcessingConsent,
      'evidenceSharingConsent': evidenceSharingConsent,
      'recordedAt': recordedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _LegalConsentHistoryImpl extends LegalConsentHistory {
  _LegalConsentHistoryImpl({
    int? id,
    required _isc.UuidValue authUserId,
    required String action,
    required String privacyPolicyVersion,
    required String termsVersion,
    required bool locationConsent,
    required bool aiProcessingConsent,
    required bool evidenceSharingConsent,
    DateTime? recordedAt,
  }) : super._(
         id: id,
         authUserId: authUserId,
         action: action,
         privacyPolicyVersion: privacyPolicyVersion,
         termsVersion: termsVersion,
         locationConsent: locationConsent,
         aiProcessingConsent: aiProcessingConsent,
         evidenceSharingConsent: evidenceSharingConsent,
         recordedAt: recordedAt,
       );

  /// Returns a shallow copy of this [LegalConsentHistory]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  LegalConsentHistory copyWith({
    Object? id = _Undefined,
    _isc.UuidValue? authUserId,
    String? action,
    String? privacyPolicyVersion,
    String? termsVersion,
    bool? locationConsent,
    bool? aiProcessingConsent,
    bool? evidenceSharingConsent,
    DateTime? recordedAt,
  }) {
    return LegalConsentHistory(
      id: id is int? ? id : this.id,
      authUserId: authUserId ?? this.authUserId,
      action: action ?? this.action,
      privacyPolicyVersion: privacyPolicyVersion ?? this.privacyPolicyVersion,
      termsVersion: termsVersion ?? this.termsVersion,
      locationConsent: locationConsent ?? this.locationConsent,
      aiProcessingConsent: aiProcessingConsent ?? this.aiProcessingConsent,
      evidenceSharingConsent:
          evidenceSharingConsent ?? this.evidenceSharingConsent,
      recordedAt: recordedAt ?? this.recordedAt,
    );
  }
}
