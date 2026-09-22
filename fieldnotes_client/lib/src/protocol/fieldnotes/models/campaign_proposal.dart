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

abstract class CampaignProposal
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  CampaignProposal._({
    required this.title,
    required this.description,
    required this.locationName,
    required this.startsAt,
    required this.durationMinutes,
    required this.volunteerCapacity,
    required this.fundingGoal,
    required this.requiredSkills,
    required this.checklist,
    required this.evidenceInstructions,
    required this.tags,
    required this.rationale,
  });

  factory CampaignProposal({
    required String title,
    required String description,
    required String locationName,
    required DateTime startsAt,
    required int durationMinutes,
    required int volunteerCapacity,
    required double fundingGoal,
    required List<String> requiredSkills,
    required List<String> checklist,
    required String evidenceInstructions,
    required List<String> tags,
    required String rationale,
  }) = _CampaignProposalImpl;

  factory CampaignProposal.fromJson(Map<String, dynamic> jsonSerialization) {
    return CampaignProposal(
      title: jsonSerialization['title'] as String,
      description: jsonSerialization['description'] as String,
      locationName: jsonSerialization['locationName'] as String,
      startsAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['startsAt'],
      ),
      durationMinutes: jsonSerialization['durationMinutes'] as int,
      volunteerCapacity: jsonSerialization['volunteerCapacity'] as int,
      fundingGoal: (jsonSerialization['fundingGoal'] as num).toDouble(),
      requiredSkills: _imuhbzep.Protocol().deserialize<List<String>>(
        jsonSerialization['requiredSkills'],
      ),
      checklist: _imuhbzep.Protocol().deserialize<List<String>>(
        jsonSerialization['checklist'],
      ),
      evidenceInstructions: jsonSerialization['evidenceInstructions'] as String,
      tags: _imuhbzep.Protocol().deserialize<List<String>>(
        jsonSerialization['tags'],
      ),
      rationale: jsonSerialization['rationale'] as String,
    );
  }

  String title;

  String description;

  String locationName;

  DateTime startsAt;

  int durationMinutes;

  int volunteerCapacity;

  double fundingGoal;

  List<String> requiredSkills;

  List<String> checklist;

  String evidenceInstructions;

  List<String> tags;

  String rationale;

  /// Returns a shallow copy of this [CampaignProposal]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CampaignProposal copyWith({
    String? title,
    String? description,
    String? locationName,
    DateTime? startsAt,
    int? durationMinutes,
    int? volunteerCapacity,
    double? fundingGoal,
    List<String>? requiredSkills,
    List<String>? checklist,
    String? evidenceInstructions,
    List<String>? tags,
    String? rationale,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CampaignProposal',
      'title': title,
      'description': description,
      'locationName': locationName,
      'startsAt': startsAt.toJson(),
      'durationMinutes': durationMinutes,
      'volunteerCapacity': volunteerCapacity,
      'fundingGoal': fundingGoal,
      'requiredSkills': requiredSkills.toJson(),
      'checklist': checklist.toJson(),
      'evidenceInstructions': evidenceInstructions,
      'tags': tags.toJson(),
      'rationale': rationale,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'CampaignProposal',
      'title': title,
      'description': description,
      'locationName': locationName,
      'startsAt': startsAt.toJson(),
      'durationMinutes': durationMinutes,
      'volunteerCapacity': volunteerCapacity,
      'fundingGoal': fundingGoal,
      'requiredSkills': requiredSkills.toJson(),
      'checklist': checklist.toJson(),
      'evidenceInstructions': evidenceInstructions,
      'tags': tags.toJson(),
      'rationale': rationale,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _CampaignProposalImpl extends CampaignProposal {
  _CampaignProposalImpl({
    required String title,
    required String description,
    required String locationName,
    required DateTime startsAt,
    required int durationMinutes,
    required int volunteerCapacity,
    required double fundingGoal,
    required List<String> requiredSkills,
    required List<String> checklist,
    required String evidenceInstructions,
    required List<String> tags,
    required String rationale,
  }) : super._(
         title: title,
         description: description,
         locationName: locationName,
         startsAt: startsAt,
         durationMinutes: durationMinutes,
         volunteerCapacity: volunteerCapacity,
         fundingGoal: fundingGoal,
         requiredSkills: requiredSkills,
         checklist: checklist,
         evidenceInstructions: evidenceInstructions,
         tags: tags,
         rationale: rationale,
       );

  /// Returns a shallow copy of this [CampaignProposal]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CampaignProposal copyWith({
    String? title,
    String? description,
    String? locationName,
    DateTime? startsAt,
    int? durationMinutes,
    int? volunteerCapacity,
    double? fundingGoal,
    List<String>? requiredSkills,
    List<String>? checklist,
    String? evidenceInstructions,
    List<String>? tags,
    String? rationale,
  }) {
    return CampaignProposal(
      title: title ?? this.title,
      description: description ?? this.description,
      locationName: locationName ?? this.locationName,
      startsAt: startsAt ?? this.startsAt,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      volunteerCapacity: volunteerCapacity ?? this.volunteerCapacity,
      fundingGoal: fundingGoal ?? this.fundingGoal,
      requiredSkills:
          requiredSkills ?? this.requiredSkills.map((e0) => e0).toList(),
      checklist: checklist ?? this.checklist.map((e0) => e0).toList(),
      evidenceInstructions: evidenceInstructions ?? this.evidenceInstructions,
      tags: tags ?? this.tags.map((e0) => e0).toList(),
      rationale: rationale ?? this.rationale,
    );
  }
}
