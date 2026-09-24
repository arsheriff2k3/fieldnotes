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
import 'package:serverpod_client/serverpod_client.dart' as _isc;

/// A place that has been resolved to coordinates, either from a Places
/// autocomplete selection or from reverse geocoding a dragged map pin.
abstract class ResolvedPlace
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  ResolvedPlace._({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  factory ResolvedPlace({
    required String name,
    required String address,
    required double latitude,
    required double longitude,
  }) = _ResolvedPlaceImpl;

  factory ResolvedPlace.fromJson(Map<String, dynamic> jsonSerialization) {
    return ResolvedPlace(
      name: jsonSerialization['name'] as String,
      address: jsonSerialization['address'] as String,
      latitude: (jsonSerialization['latitude'] as num).toDouble(),
      longitude: (jsonSerialization['longitude'] as num).toDouble(),
    );
  }

  String name;

  String address;

  double latitude;

  double longitude;

  /// Returns a shallow copy of this [ResolvedPlace]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  ResolvedPlace copyWith({
    String? name,
    String? address,
    double? latitude,
    double? longitude,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ResolvedPlace',
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ResolvedPlace',
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _ResolvedPlaceImpl extends ResolvedPlace {
  _ResolvedPlaceImpl({
    required String name,
    required String address,
    required double latitude,
    required double longitude,
  }) : super._(
         name: name,
         address: address,
         latitude: latitude,
         longitude: longitude,
       );

  /// Returns a shallow copy of this [ResolvedPlace]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  ResolvedPlace copyWith({
    String? name,
    String? address,
    double? latitude,
    double? longitude,
  }) {
    return ResolvedPlace(
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}
