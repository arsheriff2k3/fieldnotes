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
import '../../fieldnotes/models/ai_confidence.dart' as _i364pgf2;
import '../../fieldnotes/models/observation_condition.dart' as _iuuy06sg;
import '../../fieldnotes/models/review_state.dart' as _i926tkng;

abstract class Observation
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  Observation._({
    this.id,
    required this.clientId,
    required this.campaignId,
    this.assetId,
    required this.observerAuthUserId,
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
    required this.reviewState,
    this.possibleDuplicateAssetId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Observation({
    int? id,
    required String clientId,
    required int campaignId,
    int? assetId,
    required _isc.UuidValue observerAuthUserId,
    required DateTime capturedAt,
    required double latitude,
    required double longitude,
    required double accuracyMeters,
    required String originalNote,
    String? species,
    required _iuuy06sg.ObservationCondition condition,
    required String issues,
    required String recommendedFollowUp,
    required _i364pgf2.AiConfidence aiConfidence,
    required String aiRationale,
    required _i926tkng.ReviewState reviewState,
    int? possibleDuplicateAssetId,
    DateTime? createdAt,
  }) = _ObservationImpl;

  factory Observation.fromJson(Map<String, dynamic> jsonSerialization) {
    return Observation(
      id: jsonSerialization['id'] as int?,
      clientId: jsonSerialization['clientId'] as String,
      campaignId: jsonSerialization['campaignId'] as int,
      assetId: jsonSerialization['assetId'] as int?,
      observerAuthUserId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['observerAuthUserId'],
      ),
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
      issues: jsonSerialization['issues'] as String,
      recommendedFollowUp: jsonSerialization['recommendedFollowUp'] as String,
      aiConfidence: _i364pgf2.AiConfidence.fromJson(
        (jsonSerialization['aiConfidence'] as String),
      ),
      aiRationale: jsonSerialization['aiRationale'] as String,
      reviewState: _i926tkng.ReviewState.fromJson(
        (jsonSerialization['reviewState'] as String),
      ),
      possibleDuplicateAssetId:
          jsonSerialization['possibleDuplicateAssetId'] as int?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String clientId;

  int campaignId;

  int? assetId;

  _isc.UuidValue observerAuthUserId;

  DateTime capturedAt;

  double latitude;

  double longitude;

  double accuracyMeters;

  String originalNote;

  String? species;

  _iuuy06sg.ObservationCondition condition;

  String issues;

  String recommendedFollowUp;

  _i364pgf2.AiConfidence aiConfidence;

  String aiRationale;

  _i926tkng.ReviewState reviewState;

  int? possibleDuplicateAssetId;

  DateTime createdAt;

  /// Returns a shallow copy of this [Observation]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  Observation copyWith({
    int? id,
    String? clientId,
    int? campaignId,
    int? assetId,
    _isc.UuidValue? observerAuthUserId,
    DateTime? capturedAt,
    double? latitude,
    double? longitude,
    double? accuracyMeters,
    String? originalNote,
    String? species,
    _iuuy06sg.ObservationCondition? condition,
    String? issues,
    String? recommendedFollowUp,
    _i364pgf2.AiConfidence? aiConfidence,
    String? aiRationale,
    _i926tkng.ReviewState? reviewState,
    int? possibleDuplicateAssetId,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Observation',
      if (id != null) 'id': id,
      'clientId': clientId,
      'campaignId': campaignId,
      if (assetId != null) 'assetId': assetId,
      'observerAuthUserId': observerAuthUserId.toJson(),
      'capturedAt': capturedAt.toJson(),
      'latitude': latitude,
      'longitude': longitude,
      'accuracyMeters': accuracyMeters,
      'originalNote': originalNote,
      if (species != null) 'species': species,
      'condition': condition.toJson(),
      'issues': issues,
      'recommendedFollowUp': recommendedFollowUp,
      'aiConfidence': aiConfidence.toJson(),
      'aiRationale': aiRationale,
      'reviewState': reviewState.toJson(),
      if (possibleDuplicateAssetId != null)
        'possibleDuplicateAssetId': possibleDuplicateAssetId,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Observation',
      if (id != null) 'id': id,
      'clientId': clientId,
      'campaignId': campaignId,
      if (assetId != null) 'assetId': assetId,
      'observerAuthUserId': observerAuthUserId.toJson(),
      'capturedAt': capturedAt.toJson(),
      'latitude': latitude,
      'longitude': longitude,
      'accuracyMeters': accuracyMeters,
      'originalNote': originalNote,
      if (species != null) 'species': species,
      'condition': condition.toJson(),
      'issues': issues,
      'recommendedFollowUp': recommendedFollowUp,
      'aiConfidence': aiConfidence.toJson(),
      'aiRationale': aiRationale,
      'reviewState': reviewState.toJson(),
      if (possibleDuplicateAssetId != null)
        'possibleDuplicateAssetId': possibleDuplicateAssetId,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ObservationImpl extends Observation {
  _ObservationImpl({
    int? id,
    required String clientId,
    required int campaignId,
    int? assetId,
    required _isc.UuidValue observerAuthUserId,
    required DateTime capturedAt,
    required double latitude,
    required double longitude,
    required double accuracyMeters,
    required String originalNote,
    String? species,
    required _iuuy06sg.ObservationCondition condition,
    required String issues,
    required String recommendedFollowUp,
    required _i364pgf2.AiConfidence aiConfidence,
    required String aiRationale,
    required _i926tkng.ReviewState reviewState,
    int? possibleDuplicateAssetId,
    DateTime? createdAt,
  }) : super._(
         id: id,
         clientId: clientId,
         campaignId: campaignId,
         assetId: assetId,
         observerAuthUserId: observerAuthUserId,
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
         reviewState: reviewState,
         possibleDuplicateAssetId: possibleDuplicateAssetId,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [Observation]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  Observation copyWith({
    Object? id = _Undefined,
    String? clientId,
    int? campaignId,
    Object? assetId = _Undefined,
    _isc.UuidValue? observerAuthUserId,
    DateTime? capturedAt,
    double? latitude,
    double? longitude,
    double? accuracyMeters,
    String? originalNote,
    Object? species = _Undefined,
    _iuuy06sg.ObservationCondition? condition,
    String? issues,
    String? recommendedFollowUp,
    _i364pgf2.AiConfidence? aiConfidence,
    String? aiRationale,
    _i926tkng.ReviewState? reviewState,
    Object? possibleDuplicateAssetId = _Undefined,
    DateTime? createdAt,
  }) {
    return Observation(
      id: id is int? ? id : this.id,
      clientId: clientId ?? this.clientId,
      campaignId: campaignId ?? this.campaignId,
      assetId: assetId is int? ? assetId : this.assetId,
      observerAuthUserId: observerAuthUserId ?? this.observerAuthUserId,
      capturedAt: capturedAt ?? this.capturedAt,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracyMeters: accuracyMeters ?? this.accuracyMeters,
      originalNote: originalNote ?? this.originalNote,
      species: species is String? ? species : this.species,
      condition: condition ?? this.condition,
      issues: issues ?? this.issues,
      recommendedFollowUp: recommendedFollowUp ?? this.recommendedFollowUp,
      aiConfidence: aiConfidence ?? this.aiConfidence,
      aiRationale: aiRationale ?? this.aiRationale,
      reviewState: reviewState ?? this.reviewState,
      possibleDuplicateAssetId: possibleDuplicateAssetId is int?
          ? possibleDuplicateAssetId
          : this.possibleDuplicateAssetId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
