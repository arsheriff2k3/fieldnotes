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
import '../../fieldnotes/models/completion_evidence.dart' as _itgc1qzi;

abstract class ImpactSummary
    implements _is.SerializableModel, _is.ProtocolSerialization {
  ImpactSummary._({
    required this.campaignId,
    required this.sponsorshipTotal,
    required this.fundingGoal,
    int? sponsorshipTotalPaise,
    int? fundingGoalPaise,
    int? refundedPaise,
    required this.joinedVolunteers,
    required this.completedVolunteers,
    required this.evidenceCount,
    required this.summary,
    required this.recentEvidence,
  }) : sponsorshipTotalPaise = sponsorshipTotalPaise ?? 0,
       fundingGoalPaise = fundingGoalPaise ?? 0,
       refundedPaise = refundedPaise ?? 0;

  factory ImpactSummary({
    required int campaignId,
    required double sponsorshipTotal,
    required double fundingGoal,
    int? sponsorshipTotalPaise,
    int? fundingGoalPaise,
    int? refundedPaise,
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
      sponsorshipTotalPaise: jsonSerialization['sponsorshipTotalPaise'] as int?,
      fundingGoalPaise: jsonSerialization['fundingGoalPaise'] as int?,
      refundedPaise: jsonSerialization['refundedPaise'] as int?,
      joinedVolunteers: jsonSerialization['joinedVolunteers'] as int,
      completedVolunteers: jsonSerialization['completedVolunteers'] as int,
      evidenceCount: jsonSerialization['evidenceCount'] as int,
      summary: jsonSerialization['summary'] as String,
      recentEvidence: _ix00qkn1.Protocol()
          .deserialize<List<_itgc1qzi.CompletionEvidence>>(
            jsonSerialization['recentEvidence'],
          ),
    );
  }

  int campaignId;

  double sponsorshipTotal;

  double fundingGoal;

  int sponsorshipTotalPaise;

  int fundingGoalPaise;

  int refundedPaise;

  int joinedVolunteers;

  int completedVolunteers;

  int evidenceCount;

  String summary;

  List<_itgc1qzi.CompletionEvidence> recentEvidence;

  /// Returns a shallow copy of this [ImpactSummary]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  ImpactSummary copyWith({
    int? campaignId,
    double? sponsorshipTotal,
    double? fundingGoal,
    int? sponsorshipTotalPaise,
    int? fundingGoalPaise,
    int? refundedPaise,
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
      'sponsorshipTotalPaise': sponsorshipTotalPaise,
      'fundingGoalPaise': fundingGoalPaise,
      'refundedPaise': refundedPaise,
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
      'sponsorshipTotalPaise': sponsorshipTotalPaise,
      'fundingGoalPaise': fundingGoalPaise,
      'refundedPaise': refundedPaise,
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
    return _is.SerializationManager.encode(this);
  }
}

class _ImpactSummaryImpl extends ImpactSummary {
  _ImpactSummaryImpl({
    required int campaignId,
    required double sponsorshipTotal,
    required double fundingGoal,
    int? sponsorshipTotalPaise,
    int? fundingGoalPaise,
    int? refundedPaise,
    required int joinedVolunteers,
    required int completedVolunteers,
    required int evidenceCount,
    required String summary,
    required List<_itgc1qzi.CompletionEvidence> recentEvidence,
  }) : super._(
         campaignId: campaignId,
         sponsorshipTotal: sponsorshipTotal,
         fundingGoal: fundingGoal,
         sponsorshipTotalPaise: sponsorshipTotalPaise,
         fundingGoalPaise: fundingGoalPaise,
         refundedPaise: refundedPaise,
         joinedVolunteers: joinedVolunteers,
         completedVolunteers: completedVolunteers,
         evidenceCount: evidenceCount,
         summary: summary,
         recentEvidence: recentEvidence,
       );

  /// Returns a shallow copy of this [ImpactSummary]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  ImpactSummary copyWith({
    int? campaignId,
    double? sponsorshipTotal,
    double? fundingGoal,
    int? sponsorshipTotalPaise,
    int? fundingGoalPaise,
    int? refundedPaise,
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
      sponsorshipTotalPaise:
          sponsorshipTotalPaise ?? this.sponsorshipTotalPaise,
      fundingGoalPaise: fundingGoalPaise ?? this.fundingGoalPaise,
      refundedPaise: refundedPaise ?? this.refundedPaise,
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
