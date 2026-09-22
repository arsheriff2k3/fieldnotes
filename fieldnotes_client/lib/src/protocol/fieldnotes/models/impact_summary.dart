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
import 'package:fieldnotes_client/src/protocol/protocol.dart' as _imuhbzep;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import '../../fieldnotes/models/completion_evidence.dart' as _itgc1qzi;

abstract class ImpactSummary
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  ImpactSummary._({
    required this.campaignId,
    required this.sponsorshipTotal,
    required this.fundingGoal,
    required this.joinedVolunteers,
    required this.completedVolunteers,
    required this.evidenceCount,
    required this.summary,
    required this.recentEvidence,
  });

  factory ImpactSummary({
    required int campaignId,
    required double sponsorshipTotal,
    required double fundingGoal,
    required int joinedVolunteers,
    required int completedVolunteers,
    required int evidenceCount,
    required String summary,
    required List<_itgc1qzi.CompletionEvidence> recentEvidence,
  }) = _ImpactSummaryImpl;

  factory ImpactSummary.fromJson(Map<String, dynamic> jsonSerialization) {
    return ImpactSummary(
      campaignId: jsonSerialization['campaignId'] as int,
      sponsorshipTotal: (jsonSerialization['sponsorshipTotal'] as num)
          .toDouble(),
      fundingGoal: (jsonSerialization['fundingGoal'] as num).toDouble(),
      joinedVolunteers: jsonSerialization['joinedVolunteers'] as int,
      completedVolunteers: jsonSerialization['completedVolunteers'] as int,
      evidenceCount: jsonSerialization['evidenceCount'] as int,
      summary: jsonSerialization['summary'] as String,
      recentEvidence: _imuhbzep.Protocol()
          .deserialize<List<_itgc1qzi.CompletionEvidence>>(
            jsonSerialization['recentEvidence'],
          ),
    );
  }

  int campaignId;

  double sponsorshipTotal;

  double fundingGoal;

  int joinedVolunteers;

  int completedVolunteers;

  int evidenceCount;

  String summary;

  List<_itgc1qzi.CompletionEvidence> recentEvidence;

  /// Returns a shallow copy of this [ImpactSummary]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  ImpactSummary copyWith({
    int? campaignId,
    double? sponsorshipTotal,
    double? fundingGoal,
    int? joinedVolunteers,
    int? completedVolunteers,
    int? evidenceCount,
    String? summary,
    List<_itgc1qzi.CompletionEvidence>? recentEvidence,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ImpactSummary',
      'campaignId': campaignId,
      'sponsorshipTotal': sponsorshipTotal,
      'fundingGoal': fundingGoal,
      'joinedVolunteers': joinedVolunteers,
      'completedVolunteers': completedVolunteers,
      'evidenceCount': evidenceCount,
      'summary': summary,
      'recentEvidence': recentEvidence.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ImpactSummary',
      'campaignId': campaignId,
      'sponsorshipTotal': sponsorshipTotal,
      'fundingGoal': fundingGoal,
      'joinedVolunteers': joinedVolunteers,
      'completedVolunteers': completedVolunteers,
      'evidenceCount': evidenceCount,
      'summary': summary,
      'recentEvidence': recentEvidence.toJson(
        valueToJson: (v) => v.toJsonForProtocol(),
      ),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _ImpactSummaryImpl extends ImpactSummary {
  _ImpactSummaryImpl({
    required int campaignId,
    required double sponsorshipTotal,
    required double fundingGoal,
    required int joinedVolunteers,
    required int completedVolunteers,
    required int evidenceCount,
    required String summary,
    required List<_itgc1qzi.CompletionEvidence> recentEvidence,
  }) : super._(
         campaignId: campaignId,
         sponsorshipTotal: sponsorshipTotal,
         fundingGoal: fundingGoal,
         joinedVolunteers: joinedVolunteers,
         completedVolunteers: completedVolunteers,
         evidenceCount: evidenceCount,
         summary: summary,
         recentEvidence: recentEvidence,
       );

  /// Returns a shallow copy of this [ImpactSummary]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  ImpactSummary copyWith({
    int? campaignId,
    double? sponsorshipTotal,
    double? fundingGoal,
    int? joinedVolunteers,
    int? completedVolunteers,
    int? evidenceCount,
    String? summary,
    List<_itgc1qzi.CompletionEvidence>? recentEvidence,
  }) {
    return ImpactSummary(
      campaignId: campaignId ?? this.campaignId,
      sponsorshipTotal: sponsorshipTotal ?? this.sponsorshipTotal,
      fundingGoal: fundingGoal ?? this.fundingGoal,
      joinedVolunteers: joinedVolunteers ?? this.joinedVolunteers,
      completedVolunteers: completedVolunteers ?? this.completedVolunteers,
      evidenceCount: evidenceCount ?? this.evidenceCount,
      summary: summary ?? this.summary,
      recentEvidence:
          recentEvidence ??
          this.recentEvidence.map((e0) => e0.copyWith()).toList(),
    );
  }
}
