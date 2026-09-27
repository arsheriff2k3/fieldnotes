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
import '../../fieldnotes/models/travel_step.dart' as _iyifgn4c;

/// A route preview and its steps. The API key stays on the server.
abstract class TravelRoute
    implements _is.SerializableModel, _is.ProtocolSerialization {
  TravelRoute._({
    required this.distanceMeters,
    required this.durationSeconds,
    required this.encodedPolyline,
    required this.steps,
  });

  factory TravelRoute({
    required int distanceMeters,
    required int durationSeconds,
    required String encodedPolyline,
    required List<_iyifgn4c.TravelStep> steps,
  }) = _TravelRouteImpl;

  factory TravelRoute.fromJson(Map<String, dynamic> jsonSerialization) {
    return TravelRoute(
      distanceMeters: jsonSerialization['distanceMeters'] as int,
      durationSeconds: jsonSerialization['durationSeconds'] as int,
      encodedPolyline: jsonSerialization['encodedPolyline'] as String,
      steps: _ix00qkn1.Protocol().deserialize<List<_iyifgn4c.TravelStep>>(
        jsonSerialization['steps'],
      ),
    );
  }

  int distanceMeters;

  int durationSeconds;

  String encodedPolyline;

  List<_iyifgn4c.TravelStep> steps;

  /// Returns a shallow copy of this [TravelRoute]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  TravelRoute copyWith({
    int? distanceMeters,
    int? durationSeconds,
    String? encodedPolyline,
    List<_iyifgn4c.TravelStep>? steps,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TravelRoute',
      'distanceMeters': distanceMeters,
      'durationSeconds': durationSeconds,
      'encodedPolyline': encodedPolyline,
      'steps': steps.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'TravelRoute',
      'distanceMeters': distanceMeters,
      'durationSeconds': durationSeconds,
      'encodedPolyline': encodedPolyline,
      'steps': steps.toJson(valueToJson: (v) => v.toJsonForProtocol()),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _TravelRouteImpl extends TravelRoute {
  _TravelRouteImpl({
    required int distanceMeters,
    required int durationSeconds,
    required String encodedPolyline,
    required List<_iyifgn4c.TravelStep> steps,
  }) : super._(
         distanceMeters: distanceMeters,
         durationSeconds: durationSeconds,
         encodedPolyline: encodedPolyline,
         steps: steps,
       );

  /// Returns a shallow copy of this [TravelRoute]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  TravelRoute copyWith({
    int? distanceMeters,
    int? durationSeconds,
    String? encodedPolyline,
    List<_iyifgn4c.TravelStep>? steps,
  }) {
    return TravelRoute(
      distanceMeters: distanceMeters ?? this.distanceMeters,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      encodedPolyline: encodedPolyline ?? this.encodedPolyline,
      steps: steps ?? this.steps.map((e0) => e0.copyWith()).toList(),
    );
  }
}
