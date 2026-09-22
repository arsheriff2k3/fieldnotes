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
import '../../fieldnotes/models/ai_confidence.dart' as _i364pgf2;
import '../../fieldnotes/models/observation_condition.dart' as _iuuy06sg;

abstract class ObservationProposal
    implements _is.SerializableModel, _is.ProtocolSerialization {
  ObservationProposal._({
    this.species,
    required this.condition,
    required this.issues,
    required this.recommendedFollowUp,
    required this.confidence,
    required this.rationale,
  });

  factory ObservationProposal({
    String? species,
    required _iuuy06sg.ObservationCondition condition,
    required List<String> issues,
    required String recommendedFollowUp,
    required _i364pgf2.AiConfidence confidence,
    required String rationale,
  }) = _ObservationProposalImpl;

  factory ObservationProposal.fromJson(Map<String, dynamic> jsonSerialization) {
    return ObservationProposal(
      species: jsonSerialization['species'] as String?,
      condition: _iuuy06sg.ObservationCondition.fromJson(
        (jsonSerialization['condition'] as String),
      ),
      issues: _ix00qkn1.Protocol().deserialize<List<String>>(
        jsonSerialization['issues'],
      ),
      recommendedFollowUp: jsonSerialization['recommendedFollowUp'] as String,
      confidence: _i364pgf2.AiConfidence.fromJson(
        (jsonSerialization['confidence'] as String),
      ),
      rationale: jsonSerialization['rationale'] as String,
    );
  }

  String? species;

  _iuuy06sg.ObservationCondition condition;

  List<String> issues;

  String recommendedFollowUp;

  _i364pgf2.AiConfidence confidence;

  String rationale;

  /// Returns a shallow copy of this [ObservationProposal]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  ObservationProposal copyWith({
    String? species,
    _iuuy06sg.ObservationCondition? condition,
    List<String>? issues,
    String? recommendedFollowUp,
    _i364pgf2.AiConfidence? confidence,
    String? rationale,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ObservationProposal',
      if (species != null) 'species': species,
      'condition': condition.toJson(),
      'issues': issues.toJson(),
      'recommendedFollowUp': recommendedFollowUp,
      'confidence': confidence.toJson(),
      'rationale': rationale,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ObservationProposal',
      if (species != null) 'species': species,
      'condition': condition.toJson(),
      'issues': issues.toJson(),
      'recommendedFollowUp': recommendedFollowUp,
      'confidence': confidence.toJson(),
      'rationale': rationale,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ObservationProposalImpl extends ObservationProposal {
  _ObservationProposalImpl({
    String? species,
    required _iuuy06sg.ObservationCondition condition,
    required List<String> issues,
    required String recommendedFollowUp,
    required _i364pgf2.AiConfidence confidence,
    required String rationale,
  }) : super._(
         species: species,
         condition: condition,
         issues: issues,
         recommendedFollowUp: recommendedFollowUp,
         confidence: confidence,
         rationale: rationale,
       );

  /// Returns a shallow copy of this [ObservationProposal]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  ObservationProposal copyWith({
    Object? species = _Undefined,
    _iuuy06sg.ObservationCondition? condition,
    List<String>? issues,
    String? recommendedFollowUp,
    _i364pgf2.AiConfidence? confidence,
    String? rationale,
  }) {
    return ObservationProposal(
      species: species is String? ? species : this.species,
      condition: condition ?? this.condition,
      issues: issues ?? this.issues.map((e0) => e0).toList(),
      recommendedFollowUp: recommendedFollowUp ?? this.recommendedFollowUp,
      confidence: confidence ?? this.confidence,
      rationale: rationale ?? this.rationale,
    );
  }
}
