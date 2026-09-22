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
import 'package:fieldnotes_server/src/generated/protocol.dart' as _ix00qkn1;
import 'package:serverpod/serverpod.dart' as _is;
import '../../fieldnotes/models/audit_event.dart' as _inplj1l9;
import '../../fieldnotes/models/legal_consent.dart' as _ikbj35qb;

abstract class TrustCenterSummary
    implements _is.SerializableModel, _is.ProtocolSerialization {
  TrustCenterSummary._({
    this.consent,
    required this.recentEvents,
    required this.privacyPolicyVersion,
    required this.termsVersion,
    required this.locationProtection,
    required this.moderationProtection,
    required this.paymentProtection,
    required this.retentionNotice,
  });

  factory TrustCenterSummary({
    _ikbj35qb.LegalConsent? consent,
    required List<_inplj1l9.AuditEvent> recentEvents,
    required String privacyPolicyVersion,
    required String termsVersion,
    required String locationProtection,
    required String moderationProtection,
    required String paymentProtection,
    required String retentionNotice,
  }) = _TrustCenterSummaryImpl;

  factory TrustCenterSummary.fromJson(Map<String, dynamic> jsonSerialization) {
    return TrustCenterSummary(
      consent: jsonSerialization['consent'] == null
          ? null
          : _ix00qkn1.Protocol().deserialize<_ikbj35qb.LegalConsent>(
              jsonSerialization['consent'],
            ),
      recentEvents: _ix00qkn1.Protocol()
          .deserialize<List<_inplj1l9.AuditEvent>>(
            jsonSerialization['recentEvents'],
          ),
      privacyPolicyVersion: jsonSerialization['privacyPolicyVersion'] as String,
      termsVersion: jsonSerialization['termsVersion'] as String,
      locationProtection: jsonSerialization['locationProtection'] as String,
      moderationProtection: jsonSerialization['moderationProtection'] as String,
      paymentProtection: jsonSerialization['paymentProtection'] as String,
      retentionNotice: jsonSerialization['retentionNotice'] as String,
    );
  }

  _ikbj35qb.LegalConsent? consent;

  List<_inplj1l9.AuditEvent> recentEvents;

  String privacyPolicyVersion;

  String termsVersion;

  String locationProtection;

  String moderationProtection;

  String paymentProtection;

  String retentionNotice;

  /// Returns a shallow copy of this [TrustCenterSummary]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  TrustCenterSummary copyWith({
    _ikbj35qb.LegalConsent? consent,
    List<_inplj1l9.AuditEvent>? recentEvents,
    String? privacyPolicyVersion,
    String? termsVersion,
    String? locationProtection,
    String? moderationProtection,
    String? paymentProtection,
    String? retentionNotice,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TrustCenterSummary',
      if (consent != null) 'consent': consent?.toJson(),
      'recentEvents': recentEvents.toJson(valueToJson: (v) => v.toJson()),
      'privacyPolicyVersion': privacyPolicyVersion,
      'termsVersion': termsVersion,
      'locationProtection': locationProtection,
      'moderationProtection': moderationProtection,
      'paymentProtection': paymentProtection,
      'retentionNotice': retentionNotice,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'TrustCenterSummary',
      if (consent != null) 'consent': consent?.toJsonForProtocol(),
      'recentEvents': recentEvents.toJson(
        valueToJson: (v) => v.toJsonForProtocol(),
      ),
      'privacyPolicyVersion': privacyPolicyVersion,
      'termsVersion': termsVersion,
      'locationProtection': locationProtection,
      'moderationProtection': moderationProtection,
      'paymentProtection': paymentProtection,
      'retentionNotice': retentionNotice,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _TrustCenterSummaryImpl extends TrustCenterSummary {
  _TrustCenterSummaryImpl({
    _ikbj35qb.LegalConsent? consent,
    required List<_inplj1l9.AuditEvent> recentEvents,
    required String privacyPolicyVersion,
    required String termsVersion,
    required String locationProtection,
    required String moderationProtection,
    required String paymentProtection,
    required String retentionNotice,
  }) : super._(
         consent: consent,
         recentEvents: recentEvents,
         privacyPolicyVersion: privacyPolicyVersion,
         termsVersion: termsVersion,
         locationProtection: locationProtection,
         moderationProtection: moderationProtection,
         paymentProtection: paymentProtection,
         retentionNotice: retentionNotice,
       );

  /// Returns a shallow copy of this [TrustCenterSummary]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  TrustCenterSummary copyWith({
    Object? consent = _Undefined,
    List<_inplj1l9.AuditEvent>? recentEvents,
    String? privacyPolicyVersion,
    String? termsVersion,
    String? locationProtection,
    String? moderationProtection,
    String? paymentProtection,
    String? retentionNotice,
  }) {
    return TrustCenterSummary(
      consent: consent is _ikbj35qb.LegalConsent?
          ? consent
          : this.consent?.copyWith(),
      recentEvents:
          recentEvents ?? this.recentEvents.map((e0) => e0.copyWith()).toList(),
      privacyPolicyVersion: privacyPolicyVersion ?? this.privacyPolicyVersion,
      termsVersion: termsVersion ?? this.termsVersion,
      locationProtection: locationProtection ?? this.locationProtection,
      moderationProtection: moderationProtection ?? this.moderationProtection,
      paymentProtection: paymentProtection ?? this.paymentProtection,
      retentionNotice: retentionNotice ?? this.retentionNotice,
    );
  }
}
