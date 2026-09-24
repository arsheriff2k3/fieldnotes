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
import '../../fieldnotes/models/reach_cell.dart' as _i4cudvdq;

/// How many volunteers could actually reach a proposed campaign pin.
/// Shown to sponsors before they publish and pay.
abstract class CampaignReach
    implements _is.SerializableModel, _is.ProtocolSerialization {
  CampaignReach._({
    required this.latitude,
    required this.longitude,
    required this.volunteersInRange,
    required this.availableVolunteers,
    this.nearestDistanceKm,
    this.medianDistanceKm,
    required this.coverageCells,
    required this.summary,
  });

  factory CampaignReach({
    required double latitude,
    required double longitude,
    required int volunteersInRange,
    required int availableVolunteers,
    double? nearestDistanceKm,
    double? medianDistanceKm,
    required List<_i4cudvdq.ReachCell> coverageCells,
    required String summary,
  }) = _CampaignReachImpl;

  factory CampaignReach.fromJson(Map<String, dynamic> jsonSerialization) {
    return CampaignReach(
      latitude: (jsonSerialization['latitude'] as num).toDouble(),
      longitude: (jsonSerialization['longitude'] as num).toDouble(),
      volunteersInRange: jsonSerialization['volunteersInRange'] as int,
      availableVolunteers: jsonSerialization['availableVolunteers'] as int,
      nearestDistanceKm: (jsonSerialization['nearestDistanceKm'] as num?)
          ?.toDouble(),
      medianDistanceKm: (jsonSerialization['medianDistanceKm'] as num?)
          ?.toDouble(),
      coverageCells: _ix00qkn1.Protocol()
          .deserialize<List<_i4cudvdq.ReachCell>>(
            jsonSerialization['coverageCells'],
          ),
      summary: jsonSerialization['summary'] as String,
    );
  }

  double latitude;

  double longitude;

  int volunteersInRange;

  int availableVolunteers;

  double? nearestDistanceKm;

  double? medianDistanceKm;

  List<_i4cudvdq.ReachCell> coverageCells;

  String summary;

  /// Returns a shallow copy of this [CampaignReach]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CampaignReach copyWith({
    double? latitude,
    double? longitude,
    int? volunteersInRange,
    int? availableVolunteers,
    double? nearestDistanceKm,
    double? medianDistanceKm,
    List<_i4cudvdq.ReachCell>? coverageCells,
    String? summary,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CampaignReach',
      'latitude': latitude,
      'longitude': longitude,
      'volunteersInRange': volunteersInRange,
      'availableVolunteers': availableVolunteers,
      if (nearestDistanceKm != null) 'nearestDistanceKm': nearestDistanceKm,
      if (medianDistanceKm != null) 'medianDistanceKm': medianDistanceKm,
      'coverageCells': coverageCells.toJson(valueToJson: (v) => v.toJson()),
      'summary': summary,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'CampaignReach',
      'latitude': latitude,
      'longitude': longitude,
      'volunteersInRange': volunteersInRange,
      'availableVolunteers': availableVolunteers,
      if (nearestDistanceKm != null) 'nearestDistanceKm': nearestDistanceKm,
      if (medianDistanceKm != null) 'medianDistanceKm': medianDistanceKm,
      'coverageCells': coverageCells.toJson(
        valueToJson: (v) => v.toJsonForProtocol(),
      ),
      'summary': summary,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CampaignReachImpl extends CampaignReach {
  _CampaignReachImpl({
    required double latitude,
    required double longitude,
    required int volunteersInRange,
    required int availableVolunteers,
    double? nearestDistanceKm,
    double? medianDistanceKm,
    required List<_i4cudvdq.ReachCell> coverageCells,
    required String summary,
  }) : super._(
         latitude: latitude,
         longitude: longitude,
         volunteersInRange: volunteersInRange,
         availableVolunteers: availableVolunteers,
         nearestDistanceKm: nearestDistanceKm,
         medianDistanceKm: medianDistanceKm,
         coverageCells: coverageCells,
         summary: summary,
       );

  /// Returns a shallow copy of this [CampaignReach]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CampaignReach copyWith({
    double? latitude,
    double? longitude,
    int? volunteersInRange,
    int? availableVolunteers,
    Object? nearestDistanceKm = _Undefined,
    Object? medianDistanceKm = _Undefined,
    List<_i4cudvdq.ReachCell>? coverageCells,
    String? summary,
  }) {
    return CampaignReach(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      volunteersInRange: volunteersInRange ?? this.volunteersInRange,
      availableVolunteers: availableVolunteers ?? this.availableVolunteers,
      nearestDistanceKm: nearestDistanceKm is double?
          ? nearestDistanceKm
          : this.nearestDistanceKm,
      medianDistanceKm: medianDistanceKm is double?
          ? medianDistanceKm
          : this.medianDistanceKm,
      coverageCells:
          coverageCells ??
          this.coverageCells.map((e0) => e0.copyWith()).toList(),
      summary: summary ?? this.summary,
    );
  }
}
