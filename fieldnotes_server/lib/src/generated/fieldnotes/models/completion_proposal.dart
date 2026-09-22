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

abstract class CompletionProposal
    implements _is.SerializableModel, _is.ProtocolSerialization {
  CompletionProposal._({
    required this.summary,
    required this.structuredResults,
    required this.suggestedFollowUp,
    required this.confidence,
    required this.rationale,
  });

  factory CompletionProposal({
    required String summary,
    required List<String> structuredResults,
    required String suggestedFollowUp,
    required _i364pgf2.AiConfidence confidence,
    required String rationale,
  }) = _CompletionProposalImpl;

  factory CompletionProposal.fromJson(Map<String, dynamic> jsonSerialization) {
    return CompletionProposal(
      summary: jsonSerialization['summary'] as String,
      structuredResults: _ix00qkn1.Protocol().deserialize<List<String>>(
        jsonSerialization['structuredResults'],
      ),
      suggestedFollowUp: jsonSerialization['suggestedFollowUp'] as String,
      confidence: _i364pgf2.AiConfidence.fromJson(
        (jsonSerialization['confidence'] as String),
      ),
      rationale: jsonSerialization['rationale'] as String,
    );
  }

  String summary;

  List<String> structuredResults;

  String suggestedFollowUp;

  _i364pgf2.AiConfidence confidence;

  String rationale;

  /// Returns a shallow copy of this [CompletionProposal]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CompletionProposal copyWith({
    String? summary,
    List<String>? structuredResults,
    String? suggestedFollowUp,
    _i364pgf2.AiConfidence? confidence,
    String? rationale,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CompletionProposal',
      'summary': summary,
      'structuredResults': structuredResults.toJson(),
      'suggestedFollowUp': suggestedFollowUp,
      'confidence': confidence.toJson(),
      'rationale': rationale,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'CompletionProposal',
      'summary': summary,
      'structuredResults': structuredResults.toJson(),
      'suggestedFollowUp': suggestedFollowUp,
      'confidence': confidence.toJson(),
      'rationale': rationale,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _CompletionProposalImpl extends CompletionProposal {
  _CompletionProposalImpl({
    required String summary,
    required List<String> structuredResults,
    required String suggestedFollowUp,
    required _i364pgf2.AiConfidence confidence,
    required String rationale,
  }) : super._(
         summary: summary,
         structuredResults: structuredResults,
         suggestedFollowUp: suggestedFollowUp,
         confidence: confidence,
         rationale: rationale,
       );

  /// Returns a shallow copy of this [CompletionProposal]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CompletionProposal copyWith({
    String? summary,
    List<String>? structuredResults,
    String? suggestedFollowUp,
    _i364pgf2.AiConfidence? confidence,
    String? rationale,
  }) {
    return CompletionProposal(
      summary: summary ?? this.summary,
      structuredResults:
          structuredResults ?? this.structuredResults.map((e0) => e0).toList(),
      suggestedFollowUp: suggestedFollowUp ?? this.suggestedFollowUp,
      confidence: confidence ?? this.confidence,
      rationale: rationale ?? this.rationale,
    );
  }
}
