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
import '../../fieldnotes/models/campaign.dart' as _iatxe5ix;

abstract class CampaignMatch
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  CampaignMatch._({
    required this.campaign,
    required this.score,
    required this.distanceKm,
    required this.availabilityMatches,
    required this.reasons,
    this.travelMinutes,
    this.travelDistanceKm,
    this.travelMode,
  });

  factory CampaignMatch({
    required _iatxe5ix.Campaign campaign,
    required double score,
    required double distanceKm,
    required bool availabilityMatches,
    required List<String> reasons,
    int? travelMinutes,
    double? travelDistanceKm,
    String? travelMode,
  }) = _CampaignMatchImpl;

  factory CampaignMatch.fromJson(Map<String, dynamic> jsonSerialization) {
    return CampaignMatch(
      campaign: _imuhbzep.Protocol().deserialize<_iatxe5ix.Campaign>(
        jsonSerialization['campaign'],
      ),
      score: (jsonSerialization['score'] as num).toDouble(),
      distanceKm: (jsonSerialization['distanceKm'] as num).toDouble(),
      availabilityMatches: _isc.BoolJsonExtension.fromJson(
        jsonSerialization['availabilityMatches'],
      ),
      reasons: _imuhbzep.Protocol().deserialize<List<String>>(
        jsonSerialization['reasons'],
      ),
      travelMinutes: jsonSerialization['travelMinutes'] as int?,
      travelDistanceKm: (jsonSerialization['travelDistanceKm'] as num?)
          ?.toDouble(),
      travelMode: jsonSerialization['travelMode'] as String?,
    );
  }

  _iatxe5ix.Campaign campaign;

  double score;

  double distanceKm;

  bool availabilityMatches;

  List<String> reasons;

  /// Real travel time from the Google Routes API when it is configured and
  /// reachable. Null means the score fell back to straight-line distance.
  int? travelMinutes;

  double? travelDistanceKm;

  String? travelMode;

  /// Returns a shallow copy of this [CampaignMatch]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CampaignMatch copyWith({
    _iatxe5ix.Campaign? campaign,
    double? score,
    double? distanceKm,
    bool? availabilityMatches,
    List<String>? reasons,
    int? travelMinutes,
    double? travelDistanceKm,
    String? travelMode,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CampaignMatch',
      'campaign': campaign.toJson(),
      'score': score,
      'distanceKm': distanceKm,
      'availabilityMatches': availabilityMatches,
      'reasons': reasons.toJson(),
      if (travelMinutes != null) 'travelMinutes': travelMinutes,
      if (travelDistanceKm != null) 'travelDistanceKm': travelDistanceKm,
      if (travelMode != null) 'travelMode': travelMode,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'CampaignMatch',
      'campaign': campaign.toJsonForProtocol(),
      'score': score,
      'distanceKm': distanceKm,
      'availabilityMatches': availabilityMatches,
      'reasons': reasons.toJson(),
      if (travelMinutes != null) 'travelMinutes': travelMinutes,
      if (travelDistanceKm != null) 'travelDistanceKm': travelDistanceKm,
      if (travelMode != null) 'travelMode': travelMode,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CampaignMatchImpl extends CampaignMatch {
  _CampaignMatchImpl({
    required _iatxe5ix.Campaign campaign,
    required double score,
    required double distanceKm,
    required bool availabilityMatches,
    required List<String> reasons,
    int? travelMinutes,
    double? travelDistanceKm,
    String? travelMode,
  }) : super._(
         campaign: campaign,
         score: score,
         distanceKm: distanceKm,
         availabilityMatches: availabilityMatches,
         reasons: reasons,
         travelMinutes: travelMinutes,
         travelDistanceKm: travelDistanceKm,
         travelMode: travelMode,
       );

  /// Returns a shallow copy of this [CampaignMatch]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CampaignMatch copyWith({
    _iatxe5ix.Campaign? campaign,
    double? score,
    double? distanceKm,
    bool? availabilityMatches,
    List<String>? reasons,
    Object? travelMinutes = _Undefined,
    Object? travelDistanceKm = _Undefined,
    Object? travelMode = _Undefined,
  }) {
    return CampaignMatch(
      campaign: campaign ?? this.campaign.copyWith(),
      score: score ?? this.score,
      distanceKm: distanceKm ?? this.distanceKm,
      availabilityMatches: availabilityMatches ?? this.availabilityMatches,
      reasons: reasons ?? this.reasons.map((e0) => e0).toList(),
      travelMinutes: travelMinutes is int? ? travelMinutes : this.travelMinutes,
      travelDistanceKm: travelDistanceKm is double?
          ? travelDistanceKm
          : this.travelDistanceKm,
      travelMode: travelMode is String? ? travelMode : this.travelMode,
    );
  }
}
