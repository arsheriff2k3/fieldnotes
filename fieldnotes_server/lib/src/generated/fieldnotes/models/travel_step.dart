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

/// One instruction on a route from the volunteer's live position to a campaign.
abstract class TravelStep
    implements _is.SerializableModel, _is.ProtocolSerialization {
  TravelStep._({
    required this.instruction,
    required this.distanceMeters,
    required this.endLatitude,
    required this.endLongitude,
  });

  factory TravelStep({
    required String instruction,
    required int distanceMeters,
    required double endLatitude,
    required double endLongitude,
  }) = _TravelStepImpl;

  factory TravelStep.fromJson(Map<String, dynamic> jsonSerialization) {
    return TravelStep(
      instruction: jsonSerialization['instruction'] as String,
      distanceMeters: jsonSerialization['distanceMeters'] as int,
      endLatitude: (jsonSerialization['endLatitude'] as num).toDouble(),
      endLongitude: (jsonSerialization['endLongitude'] as num).toDouble(),
    );
  }

  String instruction;

  int distanceMeters;

  double endLatitude;

  double endLongitude;

  /// Returns a shallow copy of this [TravelStep]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  TravelStep copyWith({
    String? instruction,
    int? distanceMeters,
    double? endLatitude,
    double? endLongitude,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TravelStep',
      'instruction': instruction,
      'distanceMeters': distanceMeters,
      'endLatitude': endLatitude,
      'endLongitude': endLongitude,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'TravelStep',
      'instruction': instruction,
      'distanceMeters': distanceMeters,
      'endLatitude': endLatitude,
      'endLongitude': endLongitude,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _TravelStepImpl extends TravelStep {
  _TravelStepImpl({
    required String instruction,
    required int distanceMeters,
    required double endLatitude,
    required double endLongitude,
  }) : super._(
         instruction: instruction,
         distanceMeters: distanceMeters,
         endLatitude: endLatitude,
         endLongitude: endLongitude,
       );

  /// Returns a shallow copy of this [TravelStep]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  TravelStep copyWith({
    String? instruction,
    int? distanceMeters,
    double? endLatitude,
    double? endLongitude,
  }) {
    return TravelStep(
      instruction: instruction ?? this.instruction,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      endLatitude: endLatitude ?? this.endLatitude,
      endLongitude: endLongitude ?? this.endLongitude,
    );
  }
}
