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

abstract class VolunteerAvailability
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  VolunteerAvailability._({
    this.id,
    required this.volunteerAuthUserId,
    bool? isAvailable,
    bool? availableToday,
    required this.weekdays,
    required this.startMinutes,
    required this.endMinutes,
    required this.maximumTravelKm,
    this.latitude,
    this.longitude,
    required this.locationLabel,
    DateTime? updatedAt,
  }) : isAvailable = isAvailable ?? true,
       availableToday = availableToday ?? false,
       updatedAt = updatedAt ?? DateTime.now();

  factory VolunteerAvailability({
    int? id,
    required _isc.UuidValue volunteerAuthUserId,
    bool? isAvailable,
    bool? availableToday,
    required String weekdays,
    required int startMinutes,
    required int endMinutes,
    required double maximumTravelKm,
    double? latitude,
    double? longitude,
    required String locationLabel,
    DateTime? updatedAt,
  }) = _VolunteerAvailabilityImpl;

  factory VolunteerAvailability.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return VolunteerAvailability(
      id: jsonSerialization['id'] as int?,
      volunteerAuthUserId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['volunteerAuthUserId'],
      ),
      isAvailable: jsonSerialization['isAvailable'] == null
          ? null
          : _isc.BoolJsonExtension.fromJson(jsonSerialization['isAvailable']),
      availableToday: jsonSerialization['availableToday'] == null
          ? null
          : _isc.BoolJsonExtension.fromJson(
              jsonSerialization['availableToday'],
            ),
      weekdays: jsonSerialization['weekdays'] as String,
      startMinutes: jsonSerialization['startMinutes'] as int,
      endMinutes: jsonSerialization['endMinutes'] as int,
      maximumTravelKm: (jsonSerialization['maximumTravelKm'] as num).toDouble(),
      latitude: (jsonSerialization['latitude'] as num?)?.toDouble(),
      longitude: (jsonSerialization['longitude'] as num?)?.toDouble(),
      locationLabel: jsonSerialization['locationLabel'] as String,
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  _isc.UuidValue volunteerAuthUserId;

  bool isAvailable;

  bool availableToday;

  String weekdays;

  int startMinutes;

  int endMinutes;

  double maximumTravelKm;

  double? latitude;

  double? longitude;

  String locationLabel;

  DateTime updatedAt;

  /// Returns a shallow copy of this [VolunteerAvailability]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  VolunteerAvailability copyWith({
    int? id,
    _isc.UuidValue? volunteerAuthUserId,
    bool? isAvailable,
    bool? availableToday,
    String? weekdays,
    int? startMinutes,
    int? endMinutes,
    double? maximumTravelKm,
    double? latitude,
    double? longitude,
    String? locationLabel,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'VolunteerAvailability',
      if (id != null) 'id': id,
      'volunteerAuthUserId': volunteerAuthUserId.toJson(),
      'isAvailable': isAvailable,
      'availableToday': availableToday,
      'weekdays': weekdays,
      'startMinutes': startMinutes,
      'endMinutes': endMinutes,
      'maximumTravelKm': maximumTravelKm,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      'locationLabel': locationLabel,
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'VolunteerAvailability',
      if (id != null) 'id': id,
      'volunteerAuthUserId': volunteerAuthUserId.toJson(),
      'isAvailable': isAvailable,
      'availableToday': availableToday,
      'weekdays': weekdays,
      'startMinutes': startMinutes,
      'endMinutes': endMinutes,
      'maximumTravelKm': maximumTravelKm,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      'locationLabel': locationLabel,
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _VolunteerAvailabilityImpl extends VolunteerAvailability {
  _VolunteerAvailabilityImpl({
    int? id,
    required _isc.UuidValue volunteerAuthUserId,
    bool? isAvailable,
    bool? availableToday,
    required String weekdays,
    required int startMinutes,
    required int endMinutes,
    required double maximumTravelKm,
    double? latitude,
    double? longitude,
    required String locationLabel,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         volunteerAuthUserId: volunteerAuthUserId,
         isAvailable: isAvailable,
         availableToday: availableToday,
         weekdays: weekdays,
         startMinutes: startMinutes,
         endMinutes: endMinutes,
         maximumTravelKm: maximumTravelKm,
         latitude: latitude,
         longitude: longitude,
         locationLabel: locationLabel,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [VolunteerAvailability]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  VolunteerAvailability copyWith({
    Object? id = _Undefined,
    _isc.UuidValue? volunteerAuthUserId,
    bool? isAvailable,
    bool? availableToday,
    String? weekdays,
    int? startMinutes,
    int? endMinutes,
    double? maximumTravelKm,
    Object? latitude = _Undefined,
    Object? longitude = _Undefined,
    String? locationLabel,
    DateTime? updatedAt,
  }) {
    return VolunteerAvailability(
      id: id is int? ? id : this.id,
      volunteerAuthUserId: volunteerAuthUserId ?? this.volunteerAuthUserId,
      isAvailable: isAvailable ?? this.isAvailable,
      availableToday: availableToday ?? this.availableToday,
      weekdays: weekdays ?? this.weekdays,
      startMinutes: startMinutes ?? this.startMinutes,
      endMinutes: endMinutes ?? this.endMinutes,
      maximumTravelKm: maximumTravelKm ?? this.maximumTravelKm,
      latitude: latitude is double? ? latitude : this.latitude,
      longitude: longitude is double? ? longitude : this.longitude,
      locationLabel: locationLabel ?? this.locationLabel,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
