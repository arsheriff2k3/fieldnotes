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
import '../../fieldnotes/models/campaign.dart' as _iatxe5ix;
import '../../fieldnotes/models/campaign_participation.dart' as _io98qi8n;
import '../../fieldnotes/models/completion_evidence.dart' as _itgc1qzi;

abstract class ParticipationHistoryEntry
    implements _is.SerializableModel, _is.ProtocolSerialization {
  ParticipationHistoryEntry._({
    required this.participation,
    required this.campaign,
    this.evidence,
  });

  factory ParticipationHistoryEntry({
    required _io98qi8n.CampaignParticipation participation,
    required _iatxe5ix.Campaign campaign,
    _itgc1qzi.CompletionEvidence? evidence,
  }) = _ParticipationHistoryEntryImpl;

  factory ParticipationHistoryEntry.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return ParticipationHistoryEntry(
      participation: _ix00qkn1.Protocol()
          .deserialize<_io98qi8n.CampaignParticipation>(
            jsonSerialization['participation'],
          ),
      campaign: _ix00qkn1.Protocol().deserialize<_iatxe5ix.Campaign>(
        jsonSerialization['campaign'],
      ),
      evidence: jsonSerialization['evidence'] == null
          ? null
          : _ix00qkn1.Protocol().deserialize<_itgc1qzi.CompletionEvidence>(
              jsonSerialization['evidence'],
            ),
    );
  }

  _io98qi8n.CampaignParticipation participation;

  _iatxe5ix.Campaign campaign;

  _itgc1qzi.CompletionEvidence? evidence;

  /// Returns a shallow copy of this [ParticipationHistoryEntry]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  ParticipationHistoryEntry copyWith({
    _io98qi8n.CampaignParticipation? participation,
    _iatxe5ix.Campaign? campaign,
    _itgc1qzi.CompletionEvidence? evidence,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ParticipationHistoryEntry',
      'participation': participation.toJson(),
      'campaign': campaign.toJson(),
      if (evidence != null) 'evidence': evidence?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ParticipationHistoryEntry',
      'participation': participation.toJsonForProtocol(),
      'campaign': campaign.toJsonForProtocol(),
      if (evidence != null) 'evidence': evidence?.toJsonForProtocol(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ParticipationHistoryEntryImpl extends ParticipationHistoryEntry {
  _ParticipationHistoryEntryImpl({
    required _io98qi8n.CampaignParticipation participation,
    required _iatxe5ix.Campaign campaign,
    _itgc1qzi.CompletionEvidence? evidence,
  }) : super._(
         participation: participation,
         campaign: campaign,
         evidence: evidence,
       );

  /// Returns a shallow copy of this [ParticipationHistoryEntry]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  ParticipationHistoryEntry copyWith({
    _io98qi8n.CampaignParticipation? participation,
    _iatxe5ix.Campaign? campaign,
    Object? evidence = _Undefined,
  }) {
    return ParticipationHistoryEntry(
      participation: participation ?? this.participation.copyWith(),
      campaign: campaign ?? this.campaign.copyWith(),
      evidence: evidence is _itgc1qzi.CompletionEvidence?
          ? evidence
          : this.evidence?.copyWith(),
    );
  }
}
