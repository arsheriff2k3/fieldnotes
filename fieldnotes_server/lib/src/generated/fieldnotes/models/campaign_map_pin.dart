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

/// One plottable point of proof on the sponsor campaign map: either a GPS
/// check-in or a completed evidence submission. Integrity status and the demo
/// flag travel with the pin so simulated GPS is never drawn as verified.
abstract class CampaignMapPin
    implements _is.SerializableModel, _is.ProtocolSerialization {
  CampaignMapPin._({
    required this.participationId,
    this.evidenceId,
    required this.kind,
    required this.latitude,
    required this.longitude,
    required this.accuracyMeters,
    required this.distanceMeters,
    required this.integrityStatus,
    required this.integrityReasons,
    required this.isDemo,
    required this.label,
    required this.occurredAt,
  });

  factory CampaignMapPin({
    required int participationId,
    int? evidenceId,
    required String kind,
    required double latitude,
    required double longitude,
    required double accuracyMeters,
    required double distanceMeters,
    required String integrityStatus,
    required String integrityReasons,
    required bool isDemo,
    required String label,
    required DateTime occurredAt,
  }) = _CampaignMapPinImpl;

  factory CampaignMapPin.fromJson(Map<String, dynamic> jsonSerialization) {
    return CampaignMapPin(
      participationId: jsonSerialization['participationId'] as int,
      evidenceId: jsonSerialization['evidenceId'] as int?,
      kind: jsonSerialization['kind'] as String,
      latitude: (jsonSerialization['latitude'] as num).toDouble(),
      longitude: (jsonSerialization['longitude'] as num).toDouble(),
      accuracyMeters: (jsonSerialization['accuracyMeters'] as num).toDouble(),
      distanceMeters: (jsonSerialization['distanceMeters'] as num).toDouble(),
      integrityStatus: jsonSerialization['integrityStatus'] as String,
      integrityReasons: jsonSerialization['integrityReasons'] as String,
      isDemo: _is.BoolJsonExtension.fromJson(jsonSerialization['isDemo']),
      label: jsonSerialization['label'] as String,
      occurredAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['occurredAt'],
      ),
    );
  }

  int participationId;

  int? evidenceId;

  String kind;

  double latitude;

  double longitude;

  double accuracyMeters;

  double distanceMeters;

  String integrityStatus;

  String integrityReasons;

  bool isDemo;

  String label;

  DateTime occurredAt;

  /// Returns a shallow copy of this [CampaignMapPin]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CampaignMapPin copyWith({
    int? participationId,
    int? evidenceId,
    String? kind,
    double? latitude,
    double? longitude,
    double? accuracyMeters,
    double? distanceMeters,
    String? integrityStatus,
    String? integrityReasons,
    bool? isDemo,
    String? label,
    DateTime? occurredAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CampaignMapPin',
      'participationId': participationId,
      if (evidenceId != null) 'evidenceId': evidenceId,
      'kind': kind,
      'latitude': latitude,
      'longitude': longitude,
      'accuracyMeters': accuracyMeters,
      'distanceMeters': distanceMeters,
      'integrityStatus': integrityStatus,
      'integrityReasons': integrityReasons,
      'isDemo': isDemo,
      'label': label,
      'occurredAt': occurredAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'CampaignMapPin',
      'participationId': participationId,
      if (evidenceId != null) 'evidenceId': evidenceId,
      'kind': kind,
      'latitude': latitude,
      'longitude': longitude,
      'accuracyMeters': accuracyMeters,
      'distanceMeters': distanceMeters,
      'integrityStatus': integrityStatus,
      'integrityReasons': integrityReasons,
      'isDemo': isDemo,
      'label': label,
      'occurredAt': occurredAt.toJson(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CampaignMapPinImpl extends CampaignMapPin {
  _CampaignMapPinImpl({
    required int participationId,
    int? evidenceId,
    required String kind,
    required double latitude,
    required double longitude,
    required double accuracyMeters,
    required double distanceMeters,
    required String integrityStatus,
    required String integrityReasons,
    required bool isDemo,
    required String label,
    required DateTime occurredAt,
  }) : super._(
         participationId: participationId,
         evidenceId: evidenceId,
         kind: kind,
         latitude: latitude,
         longitude: longitude,
         accuracyMeters: accuracyMeters,
         distanceMeters: distanceMeters,
         integrityStatus: integrityStatus,
         integrityReasons: integrityReasons,
         isDemo: isDemo,
         label: label,
         occurredAt: occurredAt,
       );

  /// Returns a shallow copy of this [CampaignMapPin]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CampaignMapPin copyWith({
    int? participationId,
    Object? evidenceId = _Undefined,
    String? kind,
    double? latitude,
    double? longitude,
    double? accuracyMeters,
    double? distanceMeters,
    String? integrityStatus,
    String? integrityReasons,
    bool? isDemo,
    String? label,
    DateTime? occurredAt,
  }) {
    return CampaignMapPin(
      participationId: participationId ?? this.participationId,
      evidenceId: evidenceId is int? ? evidenceId : this.evidenceId,
      kind: kind ?? this.kind,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracyMeters: accuracyMeters ?? this.accuracyMeters,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      integrityStatus: integrityStatus ?? this.integrityStatus,
      integrityReasons: integrityReasons ?? this.integrityReasons,
      isDemo: isDemo ?? this.isDemo,
      label: label ?? this.label,
      occurredAt: occurredAt ?? this.occurredAt,
    );
  }
}
