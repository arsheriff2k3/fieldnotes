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

/// Current policy versions and public URLs. Served without sign-in by
/// LegalEndpoint.getLegalPolicies so signup can link the documents.
abstract class LegalPolicies
    implements _is.SerializableModel, _is.ProtocolSerialization {
  LegalPolicies._({
    required this.privacyPolicyVersion,
    required this.termsVersion,
    required this.privacyPolicyUrl,
    required this.termsUrl,
    required this.requiredConsents,
  });

  factory LegalPolicies({
    required String privacyPolicyVersion,
    required String termsVersion,
    required String privacyPolicyUrl,
    required String termsUrl,
    required List<String> requiredConsents,
  }) = _LegalPoliciesImpl;

  factory LegalPolicies.fromJson(Map<String, dynamic> jsonSerialization) {
    return LegalPolicies(
      privacyPolicyVersion: jsonSerialization['privacyPolicyVersion'] as String,
      termsVersion: jsonSerialization['termsVersion'] as String,
      privacyPolicyUrl: jsonSerialization['privacyPolicyUrl'] as String,
      termsUrl: jsonSerialization['termsUrl'] as String,
      requiredConsents: _ix00qkn1.Protocol().deserialize<List<String>>(
        jsonSerialization['requiredConsents'],
      ),
    );
  }

  String privacyPolicyVersion;

  String termsVersion;

  String privacyPolicyUrl;

  String termsUrl;

  /// Consent switches that must all be true in acceptLegalConsent.
  List<String> requiredConsents;

  /// Returns a shallow copy of this [LegalPolicies]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  LegalPolicies copyWith({
    String? privacyPolicyVersion,
    String? termsVersion,
    String? privacyPolicyUrl,
    String? termsUrl,
    List<String>? requiredConsents,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'LegalPolicies',
      'privacyPolicyVersion': privacyPolicyVersion,
      'termsVersion': termsVersion,
      'privacyPolicyUrl': privacyPolicyUrl,
      'termsUrl': termsUrl,
      'requiredConsents': requiredConsents.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'LegalPolicies',
      'privacyPolicyVersion': privacyPolicyVersion,
      'termsVersion': termsVersion,
      'privacyPolicyUrl': privacyPolicyUrl,
      'termsUrl': termsUrl,
      'requiredConsents': requiredConsents.toJson(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _LegalPoliciesImpl extends LegalPolicies {
  _LegalPoliciesImpl({
    required String privacyPolicyVersion,
    required String termsVersion,
    required String privacyPolicyUrl,
    required String termsUrl,
    required List<String> requiredConsents,
  }) : super._(
         privacyPolicyVersion: privacyPolicyVersion,
         termsVersion: termsVersion,
         privacyPolicyUrl: privacyPolicyUrl,
         termsUrl: termsUrl,
         requiredConsents: requiredConsents,
       );

  /// Returns a shallow copy of this [LegalPolicies]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  LegalPolicies copyWith({
    String? privacyPolicyVersion,
    String? termsVersion,
    String? privacyPolicyUrl,
    String? termsUrl,
    List<String>? requiredConsents,
  }) {
    return LegalPolicies(
      privacyPolicyVersion: privacyPolicyVersion ?? this.privacyPolicyVersion,
      termsVersion: termsVersion ?? this.termsVersion,
      privacyPolicyUrl: privacyPolicyUrl ?? this.privacyPolicyUrl,
      termsUrl: termsUrl ?? this.termsUrl,
      requiredConsents:
          requiredConsents ?? this.requiredConsents.map((e0) => e0).toList(),
    );
  }
}
