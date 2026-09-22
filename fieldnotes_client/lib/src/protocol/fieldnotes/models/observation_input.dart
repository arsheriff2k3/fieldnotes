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
import '../../fieldnotes/models/ai_confidence.dart' as _i364pgf2;
import '../../fieldnotes/models/observation_condition.dart' as _iuuy06sg;

abstract class ObservationInput
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  ObservationInput._({
    required this.clientId,
    required this.campaignId,
    this.assetId,
    required this.capturedAt,
    required this.latitude,
    required this.longitude,
    required this.accuracyMeters,
    required this.originalNote,
    this.species,
    required this.condition,
    required this.issues,
    required this.recommendedFollowUp,
    required this.aiConfidence,
    required this.aiRationale,
  });

  factory ObservationInput({
    required String clientId,
    required int campaignId,
    int? assetId,
    required DateTime capturedAt,
    required double latitude,
    required double longitude,
    required double accuracyMeters,
    required String originalNote,
    String? species,
    required _iuuy06sg.ObservationCondition condition,
    required List<String> issues,
    required String recommendedFollowUp,
    required _i364pgf2.AiConfidence aiConfidence,
    required String aiRationale,
  }) = _ObservationInputImpl;

  factory ObservationInput.fromJson(Map<String, dynamic> jsonSerialization) {
    return ObservationInput(
      clientId: jsonSerialization['clientId'] as String,
      campaignId: jsonSerialization['campaignId'] as int,
      assetId: jsonSerialization['assetId'] as int?,
      capturedAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['capturedAt'],
      ),
      latitude: (jsonSerialization['latitude'] as num).toDouble(),
      longitude: (jsonSerialization['longitude'] as num).toDouble(),
      accuracyMeters: (jsonSerialization['accuracyMeters'] as num).toDouble(),
      originalNote: jsonSerialization['originalNote'] as String,
      species: jsonSerialization['species'] as String?,
      condition: _iuuy06sg.ObservationCondition.fromJson(
        (jsonSerialization['condition'] as String),
      ),
      issues: _imuhbzep.Protocol().deserialize<List<String>>(
        jsonSerialization['issues'],
      ),
      recommendedFollowUp: jsonSerialization['recommendedFollowUp'] as String,
      aiConfidence: _i364pgf2.AiConfidence.fromJson(
        (jsonSerialization['aiConfidence'] as String),
      ),
      aiRationale: jsonSerialization['aiRationale'] as String,
    );
  }

  String clientId;

  int campaignId;

  int? assetId;

  DateTime capturedAt;

  double latitude;

  double longitude;

  double accuracyMeters;

  String originalNote;

  String? species;

  _iuuy06sg.ObservationCondition condition;

  List<String> issues;

  String recommendedFollowUp;

  _i364pgf2.AiConfidence aiConfidence;

  String aiRationale;

  /// Returns a shallow copy of this [ObservationInput]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  ObservationInput copyWith({
    String? clientId,
    int? campaignId,
    int? assetId,
    DateTime? capturedAt,
    double? latitude,
    double? longitude,
    double? accuracyMeters,
    String? originalNote,
    String? species,
    _iuuy06sg.ObservationCondition? condition,
    List<String>? issues,
    String? recommendedFollowUp,
    _i364pgf2.AiConfidence? aiConfidence,
    String? aiRationale,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ObservationInput',
      'clientId': clientId,
      'campaignId': campaignId,
      if (assetId != null) 'assetId': assetId,
      'capturedAt': capturedAt.toJson(),
      'latitude': latitude,
      'longitude': longitude,
      'accuracyMeters': accuracyMeters,
      'originalNote': originalNote,
      if (species != null) 'species': species,
      'condition': condition.toJson(),
      'issues': issues.toJson(),
      'recommendedFollowUp': recommendedFollowUp,
      'aiConfidence': aiConfidence.toJson(),
      'aiRationale': aiRationale,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ObservationInput',
      'clientId': clientId,
      'campaignId': campaignId,
      if (assetId != null) 'assetId': assetId,
      'capturedAt': capturedAt.toJson(),
      'latitude': latitude,
      'longitude': longitude,
      'accuracyMeters': accuracyMeters,
      'originalNote': originalNote,
      if (species != null) 'species': species,
      'condition': condition.toJson(),
      'issues': issues.toJson(),
      'recommendedFollowUp': recommendedFollowUp,
      'aiConfidence': aiConfidence.toJson(),
      'aiRationale': aiRationale,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ObservationInputImpl extends ObservationInput {
  _ObservationInputImpl({
    required String clientId,
    required int campaignId,
    int? assetId,
    required DateTime capturedAt,
    required double latitude,
    required double longitude,
    required double accuracyMeters,
    required String originalNote,
    String? species,
    required _iuuy06sg.ObservationCondition condition,
    required List<String> issues,
    required String recommendedFollowUp,
    required _i364pgf2.AiConfidence aiConfidence,
    required String aiRationale,
  }) : super._(
         clientId: clientId,
         campaignId: campaignId,
         assetId: assetId,
         capturedAt: capturedAt,
         latitude: latitude,
         longitude: longitude,
         accuracyMeters: accuracyMeters,
         originalNote: originalNote,
         species: species,
         condition: condition,
         issues: issues,
         recommendedFollowUp: recommendedFollowUp,
         aiConfidence: aiConfidence,
         aiRationale: aiRationale,
       );

  /// Returns a shallow copy of this [ObservationInput]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  ObservationInput copyWith({
    String? clientId,
    int? campaignId,
    Object? assetId = _Undefined,
    DateTime? capturedAt,
    double? latitude,
    double? longitude,
    double? accuracyMeters,
    String? originalNote,
    Object? species = _Undefined,
    _iuuy06sg.ObservationCondition? condition,
    List<String>? issues,
    String? recommendedFollowUp,
    _i364pgf2.AiConfidence? aiConfidence,
    String? aiRationale,
  }) {
    return ObservationInput(
      clientId: clientId ?? this.clientId,
      campaignId: campaignId ?? this.campaignId,
      assetId: assetId is int? ? assetId : this.assetId,
      capturedAt: capturedAt ?? this.capturedAt,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracyMeters: accuracyMeters ?? this.accuracyMeters,
      originalNote: originalNote ?? this.originalNote,
      species: species is String? ? species : this.species,
      condition: condition ?? this.condition,
      issues: issues ?? this.issues.map((e0) => e0).toList(),
      recommendedFollowUp: recommendedFollowUp ?? this.recommendedFollowUp,
      aiConfidence: aiConfidence ?? this.aiConfidence,
      aiRationale: aiRationale ?? this.aiRationale,
    );
  }
}
