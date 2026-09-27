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
import '../../fieldnotes/models/participation_status.dart' as _ie4rmtud;

abstract class CampaignParticipation
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  CampaignParticipation._({
    this.id,
    required this.campaignId,
    required this.volunteerAuthUserId,
    required this.status,
    int? confirmedRevision,
    DateTime? joinedAt,
    this.checkedInAt,
    this.completedAt,
    this.checkInLatitude,
    this.checkInLongitude,
    this.checkInAccuracyMeters,
    this.locationIntegrityStatus,
    this.locationIntegrityReasons,
    bool? locationIsDemo,
  }) : confirmedRevision = confirmedRevision ?? 0,
       joinedAt = joinedAt ?? DateTime.now(),
       locationIsDemo = locationIsDemo ?? false;

  factory CampaignParticipation({
    int? id,
    required int campaignId,
    required _isc.UuidValue volunteerAuthUserId,
    required _ie4rmtud.ParticipationStatus status,
    int? confirmedRevision,
    DateTime? joinedAt,
    DateTime? checkedInAt,
    DateTime? completedAt,
    double? checkInLatitude,
    double? checkInLongitude,
    double? checkInAccuracyMeters,
    String? locationIntegrityStatus,
    String? locationIntegrityReasons,
    bool? locationIsDemo,
  }) = _CampaignParticipationImpl;

  factory CampaignParticipation.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CampaignParticipation(
      id: jsonSerialization['id'] as int?,
      campaignId: jsonSerialization['campaignId'] as int,
      volunteerAuthUserId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['volunteerAuthUserId'],
      ),
      status: _ie4rmtud.ParticipationStatus.fromJson(
        (jsonSerialization['status'] as String),
      ),
      confirmedRevision: jsonSerialization['confirmedRevision'] as int?,
      joinedAt: jsonSerialization['joinedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['joinedAt']),
      checkedInAt: jsonSerialization['checkedInAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['checkedInAt'],
            ),
      completedAt: jsonSerialization['completedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['completedAt'],
            ),
      checkInLatitude: (jsonSerialization['checkInLatitude'] as num?)
          ?.toDouble(),
      checkInLongitude: (jsonSerialization['checkInLongitude'] as num?)
          ?.toDouble(),
      checkInAccuracyMeters:
          (jsonSerialization['checkInAccuracyMeters'] as num?)?.toDouble(),
      locationIntegrityStatus:
          jsonSerialization['locationIntegrityStatus'] as String?,
      locationIntegrityReasons:
          jsonSerialization['locationIntegrityReasons'] as String?,
      locationIsDemo: jsonSerialization['locationIsDemo'] == null
          ? null
          : _isc.BoolJsonExtension.fromJson(
              jsonSerialization['locationIsDemo'],
            ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int campaignId;

  _isc.UuidValue volunteerAuthUserId;

  _ie4rmtud.ParticipationStatus status;

  int confirmedRevision;

  DateTime joinedAt;

  DateTime? checkedInAt;

  DateTime? completedAt;

  double? checkInLatitude;

  double? checkInLongitude;

  double? checkInAccuracyMeters;

  String? locationIntegrityStatus;

  String? locationIntegrityReasons;

  bool locationIsDemo;

  /// Returns a shallow copy of this [CampaignParticipation]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CampaignParticipation copyWith({
    int? id,
    int? campaignId,
    _isc.UuidValue? volunteerAuthUserId,
    _ie4rmtud.ParticipationStatus? status,
    int? confirmedRevision,
    DateTime? joinedAt,
    DateTime? checkedInAt,
    DateTime? completedAt,
    double? checkInLatitude,
    double? checkInLongitude,
    double? checkInAccuracyMeters,
    String? locationIntegrityStatus,
    String? locationIntegrityReasons,
    bool? locationIsDemo,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CampaignParticipation',
      if (id != null) 'id': id,
      'campaignId': campaignId,
      'volunteerAuthUserId': volunteerAuthUserId.toJson(),
      'status': status.toJson(),
      'confirmedRevision': confirmedRevision,
      'joinedAt': joinedAt.toJson(),
      if (checkedInAt != null) 'checkedInAt': checkedInAt?.toJson(),
      if (completedAt != null) 'completedAt': completedAt?.toJson(),
      if (checkInLatitude != null) 'checkInLatitude': checkInLatitude,
      if (checkInLongitude != null) 'checkInLongitude': checkInLongitude,
      if (checkInAccuracyMeters != null)
        'checkInAccuracyMeters': checkInAccuracyMeters,
      if (locationIntegrityStatus != null)
        'locationIntegrityStatus': locationIntegrityStatus,
      if (locationIntegrityReasons != null)
        'locationIntegrityReasons': locationIntegrityReasons,
      'locationIsDemo': locationIsDemo,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'CampaignParticipation',
      if (id != null) 'id': id,
      'campaignId': campaignId,
      'volunteerAuthUserId': volunteerAuthUserId.toJson(),
      'status': status.toJson(),
      'confirmedRevision': confirmedRevision,
      'joinedAt': joinedAt.toJson(),
      if (checkedInAt != null) 'checkedInAt': checkedInAt?.toJson(),
      if (completedAt != null) 'completedAt': completedAt?.toJson(),
      if (checkInLatitude != null) 'checkInLatitude': checkInLatitude,
      if (checkInLongitude != null) 'checkInLongitude': checkInLongitude,
      if (checkInAccuracyMeters != null)
        'checkInAccuracyMeters': checkInAccuracyMeters,
      if (locationIntegrityStatus != null)
        'locationIntegrityStatus': locationIntegrityStatus,
      if (locationIntegrityReasons != null)
        'locationIntegrityReasons': locationIntegrityReasons,
      'locationIsDemo': locationIsDemo,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CampaignParticipationImpl extends CampaignParticipation {
  _CampaignParticipationImpl({
    int? id,
    required int campaignId,
    required _isc.UuidValue volunteerAuthUserId,
    required _ie4rmtud.ParticipationStatus status,
    int? confirmedRevision,
    DateTime? joinedAt,
    DateTime? checkedInAt,
    DateTime? completedAt,
    double? checkInLatitude,
    double? checkInLongitude,
    double? checkInAccuracyMeters,
    String? locationIntegrityStatus,
    String? locationIntegrityReasons,
    bool? locationIsDemo,
  }) : super._(
         id: id,
         campaignId: campaignId,
         volunteerAuthUserId: volunteerAuthUserId,
         status: status,
         confirmedRevision: confirmedRevision,
         joinedAt: joinedAt,
         checkedInAt: checkedInAt,
         completedAt: completedAt,
         checkInLatitude: checkInLatitude,
         checkInLongitude: checkInLongitude,
         checkInAccuracyMeters: checkInAccuracyMeters,
         locationIntegrityStatus: locationIntegrityStatus,
         locationIntegrityReasons: locationIntegrityReasons,
         locationIsDemo: locationIsDemo,
       );

  /// Returns a shallow copy of this [CampaignParticipation]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CampaignParticipation copyWith({
    Object? id = _Undefined,
    int? campaignId,
    _isc.UuidValue? volunteerAuthUserId,
    _ie4rmtud.ParticipationStatus? status,
    int? confirmedRevision,
    DateTime? joinedAt,
    Object? checkedInAt = _Undefined,
    Object? completedAt = _Undefined,
    Object? checkInLatitude = _Undefined,
    Object? checkInLongitude = _Undefined,
    Object? checkInAccuracyMeters = _Undefined,
    Object? locationIntegrityStatus = _Undefined,
    Object? locationIntegrityReasons = _Undefined,
    bool? locationIsDemo,
  }) {
    return CampaignParticipation(
      id: id is int? ? id : this.id,
      campaignId: campaignId ?? this.campaignId,
      volunteerAuthUserId: volunteerAuthUserId ?? this.volunteerAuthUserId,
      status: status ?? this.status,
      confirmedRevision: confirmedRevision ?? this.confirmedRevision,
      joinedAt: joinedAt ?? this.joinedAt,
      checkedInAt: checkedInAt is DateTime? ? checkedInAt : this.checkedInAt,
      completedAt: completedAt is DateTime? ? completedAt : this.completedAt,
      checkInLatitude: checkInLatitude is double?
          ? checkInLatitude
          : this.checkInLatitude,
      checkInLongitude: checkInLongitude is double?
          ? checkInLongitude
          : this.checkInLongitude,
      checkInAccuracyMeters: checkInAccuracyMeters is double?
          ? checkInAccuracyMeters
          : this.checkInAccuracyMeters,
      locationIntegrityStatus: locationIntegrityStatus is String?
          ? locationIntegrityStatus
          : this.locationIntegrityStatus,
      locationIntegrityReasons: locationIntegrityReasons is String?
          ? locationIntegrityReasons
          : this.locationIntegrityReasons,
      locationIsDemo: locationIsDemo ?? this.locationIsDemo,
    );
  }
}
