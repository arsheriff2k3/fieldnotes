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
import '../../fieldnotes/models/account_role.dart' as _i52iup9o;

abstract class FieldnoteUserProfile
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  FieldnoteUserProfile._({
    this.id,
    required this.authUserId,
    required this.role,
    required this.displayName,
    this.sponsorType,
    this.organizationName,
    required this.city,
    this.locationAddress,
    this.locationPlaceId,
    this.locationLatitude,
    this.locationLongitude,
    required this.interests,
    required this.skills,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory FieldnoteUserProfile({
    int? id,
    required _isc.UuidValue authUserId,
    required _i52iup9o.AccountRole role,
    required String displayName,
    String? sponsorType,
    String? organizationName,
    required String city,
    String? locationAddress,
    String? locationPlaceId,
    double? locationLatitude,
    double? locationLongitude,
    required String interests,
    required String skills,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _FieldnoteUserProfileImpl;

  factory FieldnoteUserProfile.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return FieldnoteUserProfile(
      id: jsonSerialization['id'] as int?,
      authUserId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['authUserId'],
      ),
      role: _i52iup9o.AccountRole.fromJson(
        (jsonSerialization['role'] as String),
      ),
      displayName: jsonSerialization['displayName'] as String,
      sponsorType: jsonSerialization['sponsorType'] as String?,
      organizationName: jsonSerialization['organizationName'] as String?,
      city: jsonSerialization['city'] as String,
      locationAddress: jsonSerialization['locationAddress'] as String?,
      locationPlaceId: jsonSerialization['locationPlaceId'] as String?,
      locationLatitude: (jsonSerialization['locationLatitude'] as num?)
          ?.toDouble(),
      locationLongitude: (jsonSerialization['locationLongitude'] as num?)
          ?.toDouble(),
      interests: jsonSerialization['interests'] as String,
      skills: jsonSerialization['skills'] as String,
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

  _isc.UuidValue authUserId;

  _i52iup9o.AccountRole role;

  String displayName;

  String? sponsorType;

  String? organizationName;

  String city;

  String? locationAddress;

  String? locationPlaceId;

  double? locationLatitude;

  double? locationLongitude;

  String interests;

  String skills;

  DateTime createdAt;

  DateTime updatedAt;

  /// Returns a shallow copy of this [FieldnoteUserProfile]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  FieldnoteUserProfile copyWith({
    int? id,
    _isc.UuidValue? authUserId,
    _i52iup9o.AccountRole? role,
    String? displayName,
    String? sponsorType,
    String? organizationName,
    String? city,
    String? locationAddress,
    String? locationPlaceId,
    double? locationLatitude,
    double? locationLongitude,
    String? interests,
    String? skills,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'FieldnoteUserProfile',
      if (id != null) 'id': id,
      'authUserId': authUserId.toJson(),
      'role': role.toJson(),
      'displayName': displayName,
      if (sponsorType != null) 'sponsorType': sponsorType,
      if (organizationName != null) 'organizationName': organizationName,
      'city': city,
      if (locationAddress != null) 'locationAddress': locationAddress,
      if (locationPlaceId != null) 'locationPlaceId': locationPlaceId,
      if (locationLatitude != null) 'locationLatitude': locationLatitude,
      if (locationLongitude != null) 'locationLongitude': locationLongitude,
      'interests': interests,
      'skills': skills,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'FieldnoteUserProfile',
      if (id != null) 'id': id,
      'authUserId': authUserId.toJson(),
      'role': role.toJson(),
      'displayName': displayName,
      if (sponsorType != null) 'sponsorType': sponsorType,
      if (organizationName != null) 'organizationName': organizationName,
      'city': city,
      if (locationAddress != null) 'locationAddress': locationAddress,
      if (locationPlaceId != null) 'locationPlaceId': locationPlaceId,
      if (locationLatitude != null) 'locationLatitude': locationLatitude,
      if (locationLongitude != null) 'locationLongitude': locationLongitude,
      'interests': interests,
      'skills': skills,
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

class _FieldnoteUserProfileImpl extends FieldnoteUserProfile {
  _FieldnoteUserProfileImpl({
    int? id,
    required _isc.UuidValue authUserId,
    required _i52iup9o.AccountRole role,
    required String displayName,
    String? sponsorType,
    String? organizationName,
    required String city,
    String? locationAddress,
    String? locationPlaceId,
    double? locationLatitude,
    double? locationLongitude,
    required String interests,
    required String skills,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         authUserId: authUserId,
         role: role,
         displayName: displayName,
         sponsorType: sponsorType,
         organizationName: organizationName,
         city: city,
         locationAddress: locationAddress,
         locationPlaceId: locationPlaceId,
         locationLatitude: locationLatitude,
         locationLongitude: locationLongitude,
         interests: interests,
         skills: skills,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [FieldnoteUserProfile]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  FieldnoteUserProfile copyWith({
    Object? id = _Undefined,
    _isc.UuidValue? authUserId,
    _i52iup9o.AccountRole? role,
    String? displayName,
    Object? sponsorType = _Undefined,
    Object? organizationName = _Undefined,
    String? city,
    Object? locationAddress = _Undefined,
    Object? locationPlaceId = _Undefined,
    Object? locationLatitude = _Undefined,
    Object? locationLongitude = _Undefined,
    String? interests,
    String? skills,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FieldnoteUserProfile(
      id: id is int? ? id : this.id,
      authUserId: authUserId ?? this.authUserId,
      role: role ?? this.role,
      displayName: displayName ?? this.displayName,
      sponsorType: sponsorType is String? ? sponsorType : this.sponsorType,
      organizationName: organizationName is String?
          ? organizationName
          : this.organizationName,
      city: city ?? this.city,
      locationAddress: locationAddress is String?
          ? locationAddress
          : this.locationAddress,
      locationPlaceId: locationPlaceId is String?
          ? locationPlaceId
          : this.locationPlaceId,
      locationLatitude: locationLatitude is double?
          ? locationLatitude
          : this.locationLatitude,
      locationLongitude: locationLongitude is double?
          ? locationLongitude
          : this.locationLongitude,
      interests: interests ?? this.interests,
      skills: skills ?? this.skills,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
