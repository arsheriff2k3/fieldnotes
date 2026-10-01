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
import '../../fieldnotes/models/campaign_status.dart' as _i4m9p8sf;

abstract class Campaign
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  Campaign._({
    this.id,
    required this.organizationId,
    required this.name,
    required this.description,
    required this.locationName,
    required this.startsAt,
    this.endsAt,
    required this.status,
    required this.createdBy,
    double? fundingGoal,
    double? sponsoredAmount,
    double? latitude,
    double? longitude,
    double? geofenceMeters,
    int? volunteerCapacity,
    int? minimumVolunteers,
    int? eligibleVolunteers,
    String? readinessState,
    int? revision,
    this.readinessCheckedAt,
    this.confirmedAt,
    this.decisionDueAt,
    this.postponedAt,
    this.cancelledAt,
    String? requiredSkills,
    String? checklist,
    String? evidenceInstructions,
    String? tags,
    bool? aiGenerated,
    this.coverImagePath,
    this.publishedAt,
    this.completedAt,
    this.shareSlug,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : fundingGoal = fundingGoal ?? 0.0,
       sponsoredAmount = sponsoredAmount ?? 0.0,
       latitude = latitude ?? 18.5204,
       longitude = longitude ?? 73.8567,
       geofenceMeters = geofenceMeters ?? 200.0,
       volunteerCapacity = volunteerCapacity ?? 10,
       minimumVolunteers = minimumVolunteers ?? 1,
       eligibleVolunteers = eligibleVolunteers ?? 0,
       readinessState = readinessState ?? 'open',
       revision = revision ?? 0,
       requiredSkills = requiredSkills ?? '',
       checklist = checklist ?? '',
       evidenceInstructions = evidenceInstructions ?? '',
       tags = tags ?? '',
       aiGenerated = aiGenerated ?? false,
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory Campaign({
    int? id,
    required int organizationId,
    required String name,
    required String description,
    required String locationName,
    required DateTime startsAt,
    DateTime? endsAt,
    required _i4m9p8sf.CampaignStatus status,
    required _isc.UuidValue createdBy,
    double? fundingGoal,
    double? sponsoredAmount,
    double? latitude,
    double? longitude,
    double? geofenceMeters,
    int? volunteerCapacity,
    int? minimumVolunteers,
    int? eligibleVolunteers,
    String? readinessState,
    int? revision,
    DateTime? readinessCheckedAt,
    DateTime? confirmedAt,
    DateTime? decisionDueAt,
    DateTime? postponedAt,
    DateTime? cancelledAt,
    String? requiredSkills,
    String? checklist,
    String? evidenceInstructions,
    String? tags,
    bool? aiGenerated,
    String? coverImagePath,
    DateTime? publishedAt,
    DateTime? completedAt,
    String? shareSlug,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _CampaignImpl;

  factory Campaign.fromJson(Map<String, dynamic> jsonSerialization) {
    return Campaign(
      id: jsonSerialization['id'] as int?,
      organizationId: jsonSerialization['organizationId'] as int,
      name: jsonSerialization['name'] as String,
      description: jsonSerialization['description'] as String,
      locationName: jsonSerialization['locationName'] as String,
      startsAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['startsAt'],
      ),
      endsAt: jsonSerialization['endsAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['endsAt']),
      status: _i4m9p8sf.CampaignStatus.fromJson(
        (jsonSerialization['status'] as String),
      ),
      createdBy: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['createdBy'],
      ),
      fundingGoal: (jsonSerialization['fundingGoal'] as num?)?.toDouble(),
      sponsoredAmount: (jsonSerialization['sponsoredAmount'] as num?)
          ?.toDouble(),
      latitude: (jsonSerialization['latitude'] as num?)?.toDouble(),
      longitude: (jsonSerialization['longitude'] as num?)?.toDouble(),
      geofenceMeters: (jsonSerialization['geofenceMeters'] as num?)?.toDouble(),
      volunteerCapacity: jsonSerialization['volunteerCapacity'] as int?,
      minimumVolunteers: jsonSerialization['minimumVolunteers'] as int?,
      eligibleVolunteers: jsonSerialization['eligibleVolunteers'] as int?,
      readinessState: jsonSerialization['readinessState'] as String?,
      revision: jsonSerialization['revision'] as int?,
      readinessCheckedAt: jsonSerialization['readinessCheckedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['readinessCheckedAt'],
            ),
      confirmedAt: jsonSerialization['confirmedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['confirmedAt'],
            ),
      decisionDueAt: jsonSerialization['decisionDueAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['decisionDueAt'],
            ),
      postponedAt: jsonSerialization['postponedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['postponedAt'],
            ),
      cancelledAt: jsonSerialization['cancelledAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['cancelledAt'],
            ),
      requiredSkills: jsonSerialization['requiredSkills'] as String?,
      checklist: jsonSerialization['checklist'] as String?,
      evidenceInstructions:
          jsonSerialization['evidenceInstructions'] as String?,
      tags: jsonSerialization['tags'] as String?,
      aiGenerated: jsonSerialization['aiGenerated'] == null
          ? null
          : _isc.BoolJsonExtension.fromJson(jsonSerialization['aiGenerated']),
      coverImagePath: jsonSerialization['coverImagePath'] as String?,
      publishedAt: jsonSerialization['publishedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['publishedAt'],
            ),
      completedAt: jsonSerialization['completedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['completedAt'],
            ),
      shareSlug: jsonSerialization['shareSlug'] as String?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int organizationId;

  String name;

  String description;

  String locationName;

  DateTime startsAt;

  DateTime? endsAt;

  _i4m9p8sf.CampaignStatus status;

  _isc.UuidValue createdBy;

  double fundingGoal;

  double sponsoredAmount;

  double latitude;

  double longitude;

  double geofenceMeters;

  int volunteerCapacity;

  int minimumVolunteers;

  int eligibleVolunteers;

  String readinessState;

  int revision;

  DateTime? readinessCheckedAt;

  DateTime? confirmedAt;

  DateTime? decisionDueAt;

  DateTime? postponedAt;

  DateTime? cancelledAt;

  String requiredSkills;

  String checklist;

  String evidenceInstructions;

  String tags;

  bool aiGenerated;

  String? coverImagePath;

  DateTime? publishedAt;

  DateTime? completedAt;

  String? shareSlug;

  DateTime createdAt;

  DateTime updatedAt;

  /// Returns a shallow copy of this [Campaign]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  Campaign copyWith({
    int? id,
    int? organizationId,
    String? name,
    String? description,
    String? locationName,
    DateTime? startsAt,
    DateTime? endsAt,
    _i4m9p8sf.CampaignStatus? status,
    _isc.UuidValue? createdBy,
    double? fundingGoal,
    double? sponsoredAmount,
    double? latitude,
    double? longitude,
    double? geofenceMeters,
    int? volunteerCapacity,
    int? minimumVolunteers,
    int? eligibleVolunteers,
    String? readinessState,
    int? revision,
    DateTime? readinessCheckedAt,
    DateTime? confirmedAt,
    DateTime? decisionDueAt,
    DateTime? postponedAt,
    DateTime? cancelledAt,
    String? requiredSkills,
    String? checklist,
    String? evidenceInstructions,
    String? tags,
    bool? aiGenerated,
    String? coverImagePath,
    DateTime? publishedAt,
    DateTime? completedAt,
    String? shareSlug,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Campaign',
      if (id != null) 'id': id,
      'organizationId': organizationId,
      'name': name,
      'description': description,
      'locationName': locationName,
      'startsAt': startsAt.toJson(),
      if (endsAt != null) 'endsAt': endsAt?.toJson(),
      'status': status.toJson(),
      'createdBy': createdBy.toJson(),
      'fundingGoal': fundingGoal,
      'sponsoredAmount': sponsoredAmount,
      'latitude': latitude,
      'longitude': longitude,
      'geofenceMeters': geofenceMeters,
      'volunteerCapacity': volunteerCapacity,
      'minimumVolunteers': minimumVolunteers,
      'eligibleVolunteers': eligibleVolunteers,
      'readinessState': readinessState,
      'revision': revision,
      if (readinessCheckedAt != null)
        'readinessCheckedAt': readinessCheckedAt?.toJson(),
      if (confirmedAt != null) 'confirmedAt': confirmedAt?.toJson(),
      if (decisionDueAt != null) 'decisionDueAt': decisionDueAt?.toJson(),
      if (postponedAt != null) 'postponedAt': postponedAt?.toJson(),
      if (cancelledAt != null) 'cancelledAt': cancelledAt?.toJson(),
      'requiredSkills': requiredSkills,
      'checklist': checklist,
      'evidenceInstructions': evidenceInstructions,
      'tags': tags,
      'aiGenerated': aiGenerated,
      if (coverImagePath != null) 'coverImagePath': coverImagePath,
      if (publishedAt != null) 'publishedAt': publishedAt?.toJson(),
      if (completedAt != null) 'completedAt': completedAt?.toJson(),
      if (shareSlug != null) 'shareSlug': shareSlug,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Campaign',
      if (id != null) 'id': id,
      'organizationId': organizationId,
      'name': name,
      'description': description,
      'locationName': locationName,
      'startsAt': startsAt.toJson(),
      if (endsAt != null) 'endsAt': endsAt?.toJson(),
      'status': status.toJson(),
      'createdBy': createdBy.toJson(),
      'fundingGoal': fundingGoal,
      'sponsoredAmount': sponsoredAmount,
      'latitude': latitude,
      'longitude': longitude,
      'geofenceMeters': geofenceMeters,
      'volunteerCapacity': volunteerCapacity,
      'minimumVolunteers': minimumVolunteers,
      'eligibleVolunteers': eligibleVolunteers,
      'readinessState': readinessState,
      'revision': revision,
      if (readinessCheckedAt != null)
        'readinessCheckedAt': readinessCheckedAt?.toJson(),
      if (confirmedAt != null) 'confirmedAt': confirmedAt?.toJson(),
      if (decisionDueAt != null) 'decisionDueAt': decisionDueAt?.toJson(),
      if (postponedAt != null) 'postponedAt': postponedAt?.toJson(),
      if (cancelledAt != null) 'cancelledAt': cancelledAt?.toJson(),
      'requiredSkills': requiredSkills,
      'checklist': checklist,
      'evidenceInstructions': evidenceInstructions,
      'tags': tags,
      'aiGenerated': aiGenerated,
      if (coverImagePath != null) 'coverImagePath': coverImagePath,
      if (publishedAt != null) 'publishedAt': publishedAt?.toJson(),
      if (completedAt != null) 'completedAt': completedAt?.toJson(),
      if (shareSlug != null) 'shareSlug': shareSlug,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CampaignImpl extends Campaign {
  _CampaignImpl({
    int? id,
    required int organizationId,
    required String name,
    required String description,
    required String locationName,
    required DateTime startsAt,
    DateTime? endsAt,
    required _i4m9p8sf.CampaignStatus status,
    required _isc.UuidValue createdBy,
    double? fundingGoal,
    double? sponsoredAmount,
    double? latitude,
    double? longitude,
    double? geofenceMeters,
    int? volunteerCapacity,
    int? minimumVolunteers,
    int? eligibleVolunteers,
    String? readinessState,
    int? revision,
    DateTime? readinessCheckedAt,
    DateTime? confirmedAt,
    DateTime? decisionDueAt,
    DateTime? postponedAt,
    DateTime? cancelledAt,
    String? requiredSkills,
    String? checklist,
    String? evidenceInstructions,
    String? tags,
    bool? aiGenerated,
    String? coverImagePath,
    DateTime? publishedAt,
    DateTime? completedAt,
    String? shareSlug,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         organizationId: organizationId,
         name: name,
         description: description,
         locationName: locationName,
         startsAt: startsAt,
         endsAt: endsAt,
         status: status,
         createdBy: createdBy,
         fundingGoal: fundingGoal,
         sponsoredAmount: sponsoredAmount,
         latitude: latitude,
         longitude: longitude,
         geofenceMeters: geofenceMeters,
         volunteerCapacity: volunteerCapacity,
         minimumVolunteers: minimumVolunteers,
         eligibleVolunteers: eligibleVolunteers,
         readinessState: readinessState,
         revision: revision,
         readinessCheckedAt: readinessCheckedAt,
         confirmedAt: confirmedAt,
         decisionDueAt: decisionDueAt,
         postponedAt: postponedAt,
         cancelledAt: cancelledAt,
         requiredSkills: requiredSkills,
         checklist: checklist,
         evidenceInstructions: evidenceInstructions,
         tags: tags,
         aiGenerated: aiGenerated,
         coverImagePath: coverImagePath,
         publishedAt: publishedAt,
         completedAt: completedAt,
         shareSlug: shareSlug,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [Campaign]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  Campaign copyWith({
    Object? id = _Undefined,
    int? organizationId,
    String? name,
    String? description,
    String? locationName,
    DateTime? startsAt,
    Object? endsAt = _Undefined,
    _i4m9p8sf.CampaignStatus? status,
    _isc.UuidValue? createdBy,
    double? fundingGoal,
    double? sponsoredAmount,
    double? latitude,
    double? longitude,
    double? geofenceMeters,
    int? volunteerCapacity,
    int? minimumVolunteers,
    int? eligibleVolunteers,
    String? readinessState,
    int? revision,
    Object? readinessCheckedAt = _Undefined,
    Object? confirmedAt = _Undefined,
    Object? decisionDueAt = _Undefined,
    Object? postponedAt = _Undefined,
    Object? cancelledAt = _Undefined,
    String? requiredSkills,
    String? checklist,
    String? evidenceInstructions,
    String? tags,
    bool? aiGenerated,
    Object? coverImagePath = _Undefined,
    Object? publishedAt = _Undefined,
    Object? completedAt = _Undefined,
    Object? shareSlug = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Campaign(
      id: id is int? ? id : this.id,
      organizationId: organizationId ?? this.organizationId,
      name: name ?? this.name,
      description: description ?? this.description,
      locationName: locationName ?? this.locationName,
      startsAt: startsAt ?? this.startsAt,
      endsAt: endsAt is DateTime? ? endsAt : this.endsAt,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      fundingGoal: fundingGoal ?? this.fundingGoal,
      sponsoredAmount: sponsoredAmount ?? this.sponsoredAmount,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      geofenceMeters: geofenceMeters ?? this.geofenceMeters,
      volunteerCapacity: volunteerCapacity ?? this.volunteerCapacity,
      minimumVolunteers: minimumVolunteers ?? this.minimumVolunteers,
      eligibleVolunteers: eligibleVolunteers ?? this.eligibleVolunteers,
      readinessState: readinessState ?? this.readinessState,
      revision: revision ?? this.revision,
      readinessCheckedAt: readinessCheckedAt is DateTime?
          ? readinessCheckedAt
          : this.readinessCheckedAt,
      confirmedAt: confirmedAt is DateTime? ? confirmedAt : this.confirmedAt,
      decisionDueAt: decisionDueAt is DateTime?
          ? decisionDueAt
          : this.decisionDueAt,
      postponedAt: postponedAt is DateTime? ? postponedAt : this.postponedAt,
      cancelledAt: cancelledAt is DateTime? ? cancelledAt : this.cancelledAt,
      requiredSkills: requiredSkills ?? this.requiredSkills,
      checklist: checklist ?? this.checklist,
      evidenceInstructions: evidenceInstructions ?? this.evidenceInstructions,
      tags: tags ?? this.tags,
      aiGenerated: aiGenerated ?? this.aiGenerated,
      coverImagePath: coverImagePath is String?
          ? coverImagePath
          : this.coverImagePath,
      publishedAt: publishedAt is DateTime? ? publishedAt : this.publishedAt,
      completedAt: completedAt is DateTime? ? completedAt : this.completedAt,
      shareSlug: shareSlug is String? ? shareSlug : this.shareSlug,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
