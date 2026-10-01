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
import '../../fieldnotes/models/review_state.dart' as _i926tkng;

abstract class CompletionEvidence
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  CompletionEvidence._({
    this.id,
    required this.participationId,
    this.photographPath,
    required this.originalNote,
    required this.confirmedSummary,
    required this.structuredResults,
    required this.latitude,
    required this.longitude,
    required this.locationAccuracyMeters,
    String? locationIntegrityStatus,
    String? locationIntegrityReasons,
    bool? locationIsDemo,
    String? moderationStatus,
    DateTime? submittedAt,
    bool? aiGenerated,
    _i926tkng.ReviewState? reviewState,
    this.reviewNote,
    this.reviewedByAuthUserId,
    this.reviewedAt,
  }) : locationIntegrityStatus = locationIntegrityStatus ?? 'verified',
       locationIntegrityReasons =
           locationIntegrityReasons ?? 'Location checks passed',
       locationIsDemo = locationIsDemo ?? false,
       moderationStatus = moderationStatus ?? 'passed',
       submittedAt = submittedAt ?? DateTime.now(),
       aiGenerated = aiGenerated ?? true,
       reviewState = reviewState ?? _i926tkng.ReviewState.awaitingReview;

  factory CompletionEvidence({
    int? id,
    required int participationId,
    String? photographPath,
    required String originalNote,
    required String confirmedSummary,
    required String structuredResults,
    required double latitude,
    required double longitude,
    required double locationAccuracyMeters,
    String? locationIntegrityStatus,
    String? locationIntegrityReasons,
    bool? locationIsDemo,
    String? moderationStatus,
    DateTime? submittedAt,
    bool? aiGenerated,
    _i926tkng.ReviewState? reviewState,
    String? reviewNote,
    _isc.UuidValue? reviewedByAuthUserId,
    DateTime? reviewedAt,
  }) = _CompletionEvidenceImpl;

  factory CompletionEvidence.fromJson(Map<String, dynamic> jsonSerialization) {
    return CompletionEvidence(
      id: jsonSerialization['id'] as int?,
      participationId: jsonSerialization['participationId'] as int,
      photographPath: jsonSerialization['photographPath'] as String?,
      originalNote: jsonSerialization['originalNote'] as String,
      confirmedSummary: jsonSerialization['confirmedSummary'] as String,
      structuredResults: jsonSerialization['structuredResults'] as String,
      latitude: (jsonSerialization['latitude'] as num).toDouble(),
      longitude: (jsonSerialization['longitude'] as num).toDouble(),
      locationAccuracyMeters:
          (jsonSerialization['locationAccuracyMeters'] as num).toDouble(),
      locationIntegrityStatus:
          jsonSerialization['locationIntegrityStatus'] as String?,
      locationIntegrityReasons:
          jsonSerialization['locationIntegrityReasons'] as String?,
      locationIsDemo: jsonSerialization['locationIsDemo'] == null
          ? null
          : _isc.BoolJsonExtension.fromJson(
              jsonSerialization['locationIsDemo'],
            ),
      moderationStatus: jsonSerialization['moderationStatus'] as String?,
      submittedAt: jsonSerialization['submittedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['submittedAt'],
            ),
      aiGenerated: jsonSerialization['aiGenerated'] == null
          ? null
          : _isc.BoolJsonExtension.fromJson(jsonSerialization['aiGenerated']),
      reviewState: jsonSerialization['reviewState'] == null
          ? null
          : _i926tkng.ReviewState.fromJson(
              (jsonSerialization['reviewState'] as String),
            ),
      reviewNote: jsonSerialization['reviewNote'] as String?,
      reviewedByAuthUserId: jsonSerialization['reviewedByAuthUserId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(
              jsonSerialization['reviewedByAuthUserId'],
            ),
      reviewedAt: jsonSerialization['reviewedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['reviewedAt'],
            ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int participationId;

  String? photographPath;

  String originalNote;

  String confirmedSummary;

  String structuredResults;

  double latitude;

  double longitude;

  double locationAccuracyMeters;

  String locationIntegrityStatus;

  String locationIntegrityReasons;

  bool locationIsDemo;

  String moderationStatus;

  DateTime submittedAt;

  bool aiGenerated;

  _i926tkng.ReviewState reviewState;

  String? reviewNote;

  _isc.UuidValue? reviewedByAuthUserId;

  DateTime? reviewedAt;

  /// Returns a shallow copy of this [CompletionEvidence]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CompletionEvidence copyWith({
    int? id,
    int? participationId,
    String? photographPath,
    String? originalNote,
    String? confirmedSummary,
    String? structuredResults,
    double? latitude,
    double? longitude,
    double? locationAccuracyMeters,
    String? locationIntegrityStatus,
    String? locationIntegrityReasons,
    bool? locationIsDemo,
    String? moderationStatus,
    DateTime? submittedAt,
    bool? aiGenerated,
    _i926tkng.ReviewState? reviewState,
    String? reviewNote,
    _isc.UuidValue? reviewedByAuthUserId,
    DateTime? reviewedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CompletionEvidence',
      if (id != null) 'id': id,
      'participationId': participationId,
      if (photographPath != null) 'photographPath': photographPath,
      'originalNote': originalNote,
      'confirmedSummary': confirmedSummary,
      'structuredResults': structuredResults,
      'latitude': latitude,
      'longitude': longitude,
      'locationAccuracyMeters': locationAccuracyMeters,
      'locationIntegrityStatus': locationIntegrityStatus,
      'locationIntegrityReasons': locationIntegrityReasons,
      'locationIsDemo': locationIsDemo,
      'moderationStatus': moderationStatus,
      'submittedAt': submittedAt.toJson(),
      'aiGenerated': aiGenerated,
      'reviewState': reviewState.toJson(),
      if (reviewNote != null) 'reviewNote': reviewNote,
      if (reviewedByAuthUserId != null)
        'reviewedByAuthUserId': reviewedByAuthUserId?.toJson(),
      if (reviewedAt != null) 'reviewedAt': reviewedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'CompletionEvidence',
      if (id != null) 'id': id,
      'participationId': participationId,
      if (photographPath != null) 'photographPath': photographPath,
      'originalNote': originalNote,
      'confirmedSummary': confirmedSummary,
      'structuredResults': structuredResults,
      'latitude': latitude,
      'longitude': longitude,
      'locationAccuracyMeters': locationAccuracyMeters,
      'locationIntegrityStatus': locationIntegrityStatus,
      'locationIntegrityReasons': locationIntegrityReasons,
      'locationIsDemo': locationIsDemo,
      'moderationStatus': moderationStatus,
      'submittedAt': submittedAt.toJson(),
      'aiGenerated': aiGenerated,
      'reviewState': reviewState.toJson(),
      if (reviewNote != null) 'reviewNote': reviewNote,
      if (reviewedByAuthUserId != null)
        'reviewedByAuthUserId': reviewedByAuthUserId?.toJson(),
      if (reviewedAt != null) 'reviewedAt': reviewedAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CompletionEvidenceImpl extends CompletionEvidence {
  _CompletionEvidenceImpl({
    int? id,
    required int participationId,
    String? photographPath,
    required String originalNote,
    required String confirmedSummary,
    required String structuredResults,
    required double latitude,
    required double longitude,
    required double locationAccuracyMeters,
    String? locationIntegrityStatus,
    String? locationIntegrityReasons,
    bool? locationIsDemo,
    String? moderationStatus,
    DateTime? submittedAt,
    bool? aiGenerated,
    _i926tkng.ReviewState? reviewState,
    String? reviewNote,
    _isc.UuidValue? reviewedByAuthUserId,
    DateTime? reviewedAt,
  }) : super._(
         id: id,
         participationId: participationId,
         photographPath: photographPath,
         originalNote: originalNote,
         confirmedSummary: confirmedSummary,
         structuredResults: structuredResults,
         latitude: latitude,
         longitude: longitude,
         locationAccuracyMeters: locationAccuracyMeters,
         locationIntegrityStatus: locationIntegrityStatus,
         locationIntegrityReasons: locationIntegrityReasons,
         locationIsDemo: locationIsDemo,
         moderationStatus: moderationStatus,
         submittedAt: submittedAt,
         aiGenerated: aiGenerated,
         reviewState: reviewState,
         reviewNote: reviewNote,
         reviewedByAuthUserId: reviewedByAuthUserId,
         reviewedAt: reviewedAt,
       );

  /// Returns a shallow copy of this [CompletionEvidence]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CompletionEvidence copyWith({
    Object? id = _Undefined,
    int? participationId,
    Object? photographPath = _Undefined,
    String? originalNote,
    String? confirmedSummary,
    String? structuredResults,
    double? latitude,
    double? longitude,
    double? locationAccuracyMeters,
    String? locationIntegrityStatus,
    String? locationIntegrityReasons,
    bool? locationIsDemo,
    String? moderationStatus,
    DateTime? submittedAt,
    bool? aiGenerated,
    _i926tkng.ReviewState? reviewState,
    Object? reviewNote = _Undefined,
    Object? reviewedByAuthUserId = _Undefined,
    Object? reviewedAt = _Undefined,
  }) {
    return CompletionEvidence(
      id: id is int? ? id : this.id,
      participationId: participationId ?? this.participationId,
      photographPath: photographPath is String?
          ? photographPath
          : this.photographPath,
      originalNote: originalNote ?? this.originalNote,
      confirmedSummary: confirmedSummary ?? this.confirmedSummary,
      structuredResults: structuredResults ?? this.structuredResults,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationAccuracyMeters:
          locationAccuracyMeters ?? this.locationAccuracyMeters,
      locationIntegrityStatus:
          locationIntegrityStatus ?? this.locationIntegrityStatus,
      locationIntegrityReasons:
          locationIntegrityReasons ?? this.locationIntegrityReasons,
      locationIsDemo: locationIsDemo ?? this.locationIsDemo,
      moderationStatus: moderationStatus ?? this.moderationStatus,
      submittedAt: submittedAt ?? this.submittedAt,
      aiGenerated: aiGenerated ?? this.aiGenerated,
      reviewState: reviewState ?? this.reviewState,
      reviewNote: reviewNote is String? ? reviewNote : this.reviewNote,
      reviewedByAuthUserId: reviewedByAuthUserId is _isc.UuidValue?
          ? reviewedByAuthUserId
          : this.reviewedByAuthUserId,
      reviewedAt: reviewedAt is DateTime? ? reviewedAt : this.reviewedAt,
    );
  }
}
