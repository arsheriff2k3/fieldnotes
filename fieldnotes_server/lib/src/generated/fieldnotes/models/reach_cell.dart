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
import 'package:serverpod/serverpod.dart' as _is;

/// A coarse, k-anonymised bucket of volunteers used to draw sponsor reach
/// coverage. Coordinates are rounded to roughly a kilometre and cells below
/// the anonymity threshold are never emitted, so no volunteer home location
/// can be recovered from this data.
abstract class ReachCell
    implements _is.SerializableModel, _is.ProtocolSerialization {
  ReachCell._({
    required this.latitude,
    required this.longitude,
    required this.volunteerCount,
  });

  factory ReachCell({
    required double latitude,
    required double longitude,
    required int volunteerCount,
  }) = _ReachCellImpl;

  factory ReachCell.fromJson(Map<String, dynamic> jsonSerialization) {
    return ReachCell(
      latitude: (jsonSerialization['latitude'] as num).toDouble(),
      longitude: (jsonSerialization['longitude'] as num).toDouble(),
      volunteerCount: jsonSerialization['volunteerCount'] as int,
    );
  }

  double latitude;

  double longitude;

  int volunteerCount;

  /// Returns a shallow copy of this [ReachCell]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  ReachCell copyWith({
    double? latitude,
    double? longitude,
    int? volunteerCount,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ReachCell',
      'latitude': latitude,
      'longitude': longitude,
      'volunteerCount': volunteerCount,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ReachCell',
      'latitude': latitude,
      'longitude': longitude,
      'volunteerCount': volunteerCount,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _ReachCellImpl extends ReachCell {
  _ReachCellImpl({
    required double latitude,
    required double longitude,
    required int volunteerCount,
  }) : super._(
         latitude: latitude,
         longitude: longitude,
         volunteerCount: volunteerCount,
       );

  /// Returns a shallow copy of this [ReachCell]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  ReachCell copyWith({
    double? latitude,
    double? longitude,
    int? volunteerCount,
  }) {
    return ReachCell(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      volunteerCount: volunteerCount ?? this.volunteerCount,
    );
  }
}
