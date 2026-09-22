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
  }) : locationIntegrityStatus = locationIntegrityStatus ?? 'verified',
       locationIntegrityReasons =
           locationIntegrityReasons ?? 'Location checks passed',
       locationIsDemo = locationIsDemo ?? false,
       moderationStatus = moderationStatus ?? 'passed',
       submittedAt = submittedAt ?? DateTime.now();

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
    );
  }
}
