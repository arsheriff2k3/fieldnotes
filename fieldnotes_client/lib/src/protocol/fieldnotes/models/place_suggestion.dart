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

/// A single Google Places autocomplete candidate.
/// Only the opaque place id and the display texts cross the wire; the
/// Places API key stays in Serverpod passwords.
abstract class PlaceSuggestion
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  PlaceSuggestion._({
    required this.placeId,
    required this.primaryText,
    required this.secondaryText,
  });

  factory PlaceSuggestion({
    required String placeId,
    required String primaryText,
    required String secondaryText,
  }) = _PlaceSuggestionImpl;

  factory PlaceSuggestion.fromJson(Map<String, dynamic> jsonSerialization) {
    return PlaceSuggestion(
      placeId: jsonSerialization['placeId'] as String,
      primaryText: jsonSerialization['primaryText'] as String,
      secondaryText: jsonSerialization['secondaryText'] as String,
    );
  }

  String placeId;

  String primaryText;

  String secondaryText;

  /// Returns a shallow copy of this [PlaceSuggestion]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  PlaceSuggestion copyWith({
    String? placeId,
    String? primaryText,
    String? secondaryText,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PlaceSuggestion',
      'placeId': placeId,
      'primaryText': primaryText,
      'secondaryText': secondaryText,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'PlaceSuggestion',
      'placeId': placeId,
      'primaryText': primaryText,
      'secondaryText': secondaryText,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _PlaceSuggestionImpl extends PlaceSuggestion {
  _PlaceSuggestionImpl({
    required String placeId,
    required String primaryText,
    required String secondaryText,
  }) : super._(
         placeId: placeId,
         primaryText: primaryText,
         secondaryText: secondaryText,
       );

  /// Returns a shallow copy of this [PlaceSuggestion]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  PlaceSuggestion copyWith({
    String? placeId,
    String? primaryText,
    String? secondaryText,
  }) {
    return PlaceSuggestion(
      placeId: placeId ?? this.placeId,
      primaryText: primaryText ?? this.primaryText,
      secondaryText: secondaryText ?? this.secondaryText,
    );
  }
}
