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

/// A volunteer visible to the creator of a published campaign. Map
/// coordinates are rounded to a coarse area, never the person's GPS point.
abstract class CampaignVolunteerMapMember
    implements _is.SerializableModel, _is.ProtocolSerialization {
  CampaignVolunteerMapMember._({
    required this.profileId,
    required this.displayName,
    required this.areaLabel,
    this.latitude,
    this.longitude,
    required this.status,
    this.volunteerCount,
  });

  factory CampaignVolunteerMapMember({
    required int profileId,
    required String displayName,
    required String areaLabel,
    double? latitude,
    double? longitude,
    required String status,
    int? volunteerCount,
  }) = _CampaignVolunteerMapMemberImpl;

  factory CampaignVolunteerMapMember.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CampaignVolunteerMapMember(
      profileId: jsonSerialization['profileId'] as int,
      displayName: jsonSerialization['displayName'] as String,
      areaLabel: jsonSerialization['areaLabel'] as String,
      latitude: (jsonSerialization['latitude'] as num?)?.toDouble(),
      longitude: (jsonSerialization['longitude'] as num?)?.toDouble(),
      status: jsonSerialization['status'] as String,
      volunteerCount: jsonSerialization['volunteerCount'] as int?,
    );
  }

  int profileId;

  String displayName;

  String areaLabel;

  double? latitude;

  double? longitude;

  String status;

  int? volunteerCount;

  /// Returns a shallow copy of this [CampaignVolunteerMapMember]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CampaignVolunteerMapMember copyWith({
    int? profileId,
    String? displayName,
    String? areaLabel,
    double? latitude,
    double? longitude,
    String? status,
    int? volunteerCount,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CampaignVolunteerMapMember',
      'profileId': profileId,
      'displayName': displayName,
      'areaLabel': areaLabel,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      'status': status,
      if (volunteerCount != null) 'volunteerCount': volunteerCount,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'CampaignVolunteerMapMember',
      'profileId': profileId,
      'displayName': displayName,
      'areaLabel': areaLabel,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      'status': status,
      if (volunteerCount != null) 'volunteerCount': volunteerCount,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CampaignVolunteerMapMemberImpl extends CampaignVolunteerMapMember {
  _CampaignVolunteerMapMemberImpl({
    required int profileId,
    required String displayName,
    required String areaLabel,
    double? latitude,
    double? longitude,
    required String status,
    int? volunteerCount,
  }) : super._(
         profileId: profileId,
         displayName: displayName,
         areaLabel: areaLabel,
         latitude: latitude,
         longitude: longitude,
         status: status,
         volunteerCount: volunteerCount,
       );

  /// Returns a shallow copy of this [CampaignVolunteerMapMember]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CampaignVolunteerMapMember copyWith({
    int? profileId,
    String? displayName,
    String? areaLabel,
    Object? latitude = _Undefined,
    Object? longitude = _Undefined,
    String? status,
    Object? volunteerCount = _Undefined,
  }) {
    return CampaignVolunteerMapMember(
      profileId: profileId ?? this.profileId,
      displayName: displayName ?? this.displayName,
      areaLabel: areaLabel ?? this.areaLabel,
      latitude: latitude is double? ? latitude : this.latitude,
      longitude: longitude is double? ? longitude : this.longitude,
      status: status ?? this.status,
      volunteerCount: volunteerCount is int?
          ? volunteerCount
          : this.volunteerCount,
    );
  }
}
