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

abstract class Asset
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  Asset._({
    this.id,
    required this.campaignId,
    required this.externalId,
    this.species,
    this.plantedAt,
    required this.latitude,
    required this.longitude,
    this.notes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Asset({
    int? id,
    required int campaignId,
    required String externalId,
    String? species,
    DateTime? plantedAt,
    required double latitude,
    required double longitude,
    String? notes,
    DateTime? createdAt,
  }) = _AssetImpl;

  factory Asset.fromJson(Map<String, dynamic> jsonSerialization) {
    return Asset(
      id: jsonSerialization['id'] as int?,
      campaignId: jsonSerialization['campaignId'] as int,
      externalId: jsonSerialization['externalId'] as String,
      species: jsonSerialization['species'] as String?,
      plantedAt: jsonSerialization['plantedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['plantedAt']),
      latitude: (jsonSerialization['latitude'] as num).toDouble(),
      longitude: (jsonSerialization['longitude'] as num).toDouble(),
      notes: jsonSerialization['notes'] as String?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int campaignId;

  String externalId;

  String? species;

  DateTime? plantedAt;

  double latitude;

  double longitude;

  String? notes;

  DateTime createdAt;

  /// Returns a shallow copy of this [Asset]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  Asset copyWith({
    int? id,
    int? campaignId,
    String? externalId,
    String? species,
    DateTime? plantedAt,
    double? latitude,
    double? longitude,
    String? notes,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Asset',
      if (id != null) 'id': id,
      'campaignId': campaignId,
      'externalId': externalId,
      if (species != null) 'species': species,
      if (plantedAt != null) 'plantedAt': plantedAt?.toJson(),
      'latitude': latitude,
      'longitude': longitude,
      if (notes != null) 'notes': notes,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Asset',
      if (id != null) 'id': id,
      'campaignId': campaignId,
      'externalId': externalId,
      if (species != null) 'species': species,
      if (plantedAt != null) 'plantedAt': plantedAt?.toJson(),
      'latitude': latitude,
      'longitude': longitude,
      if (notes != null) 'notes': notes,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AssetImpl extends Asset {
  _AssetImpl({
    int? id,
    required int campaignId,
    required String externalId,
    String? species,
    DateTime? plantedAt,
    required double latitude,
    required double longitude,
    String? notes,
    DateTime? createdAt,
  }) : super._(
         id: id,
         campaignId: campaignId,
         externalId: externalId,
         species: species,
         plantedAt: plantedAt,
         latitude: latitude,
         longitude: longitude,
         notes: notes,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [Asset]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  Asset copyWith({
    Object? id = _Undefined,
    int? campaignId,
    String? externalId,
    Object? species = _Undefined,
    Object? plantedAt = _Undefined,
    double? latitude,
    double? longitude,
    Object? notes = _Undefined,
    DateTime? createdAt,
  }) {
    return Asset(
      id: id is int? ? id : this.id,
      campaignId: campaignId ?? this.campaignId,
      externalId: externalId ?? this.externalId,
      species: species is String? ? species : this.species,
      plantedAt: plantedAt is DateTime? ? plantedAt : this.plantedAt,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      notes: notes is String? ? notes : this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
