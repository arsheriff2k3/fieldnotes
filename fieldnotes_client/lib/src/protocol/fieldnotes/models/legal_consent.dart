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

abstract class LegalConsent
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  LegalConsent._({
    this.id,
    required this.authUserId,
    required this.privacyPolicyVersion,
    required this.termsVersion,
    required this.locationConsent,
    required this.aiProcessingConsent,
    required this.evidenceSharingConsent,
    DateTime? acceptedAt,
    DateTime? updatedAt,
  }) : acceptedAt = acceptedAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory LegalConsent({
    int? id,
    required _isc.UuidValue authUserId,
    required String privacyPolicyVersion,
    required String termsVersion,
    required bool locationConsent,
    required bool aiProcessingConsent,
    required bool evidenceSharingConsent,
    DateTime? acceptedAt,
    DateTime? updatedAt,
  }) = _LegalConsentImpl;

  factory LegalConsent.fromJson(Map<String, dynamic> jsonSerialization) {
    return LegalConsent(
      id: jsonSerialization['id'] as int?,
      authUserId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['authUserId'],
      ),
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
      acceptedAt: jsonSerialization['acceptedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['acceptedAt'],
            ),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  _isc.UuidValue authUserId;

  String privacyPolicyVersion;

  String termsVersion;

  bool locationConsent;

  bool aiProcessingConsent;

  bool evidenceSharingConsent;

  DateTime acceptedAt;

  DateTime updatedAt;

  /// Returns a shallow copy of this [LegalConsent]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  LegalConsent copyWith({
    int? id,
    _isc.UuidValue? authUserId,
    String? privacyPolicyVersion,
    String? termsVersion,
    bool? locationConsent,
    bool? aiProcessingConsent,
    bool? evidenceSharingConsent,
    DateTime? acceptedAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'LegalConsent',
      if (id != null) 'id': id,
      'authUserId': authUserId.toJson(),
      'privacyPolicyVersion': privacyPolicyVersion,
      'termsVersion': termsVersion,
      'locationConsent': locationConsent,
      'aiProcessingConsent': aiProcessingConsent,
      'evidenceSharingConsent': evidenceSharingConsent,
      'acceptedAt': acceptedAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'LegalConsent',
      if (id != null) 'id': id,
      'authUserId': authUserId.toJson(),
      'privacyPolicyVersion': privacyPolicyVersion,
      'termsVersion': termsVersion,
      'locationConsent': locationConsent,
      'aiProcessingConsent': aiProcessingConsent,
      'evidenceSharingConsent': evidenceSharingConsent,
      'acceptedAt': acceptedAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _LegalConsentImpl extends LegalConsent {
  _LegalConsentImpl({
    int? id,
    required _isc.UuidValue authUserId,
    required String privacyPolicyVersion,
    required String termsVersion,
    required bool locationConsent,
    required bool aiProcessingConsent,
    required bool evidenceSharingConsent,
    DateTime? acceptedAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         authUserId: authUserId,
         privacyPolicyVersion: privacyPolicyVersion,
         termsVersion: termsVersion,
         locationConsent: locationConsent,
         aiProcessingConsent: aiProcessingConsent,
         evidenceSharingConsent: evidenceSharingConsent,
         acceptedAt: acceptedAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [LegalConsent]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  LegalConsent copyWith({
    Object? id = _Undefined,
    _isc.UuidValue? authUserId,
    String? privacyPolicyVersion,
    String? termsVersion,
    bool? locationConsent,
    bool? aiProcessingConsent,
    bool? evidenceSharingConsent,
    DateTime? acceptedAt,
    DateTime? updatedAt,
  }) {
    return LegalConsent(
      id: id is int? ? id : this.id,
      authUserId: authUserId ?? this.authUserId,
      privacyPolicyVersion: privacyPolicyVersion ?? this.privacyPolicyVersion,
      termsVersion: termsVersion ?? this.termsVersion,
      locationConsent: locationConsent ?? this.locationConsent,
      aiProcessingConsent: aiProcessingConsent ?? this.aiProcessingConsent,
      evidenceSharingConsent:
          evidenceSharingConsent ?? this.evidenceSharingConsent,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
