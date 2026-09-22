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

abstract class ObservationMedia
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  ObservationMedia._({
    this.id,
    required this.observationId,
    required this.storagePath,
    required this.mediaType,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory ObservationMedia({
    int? id,
    required int observationId,
    required String storagePath,
    required String mediaType,
    DateTime? createdAt,
  }) = _ObservationMediaImpl;

  factory ObservationMedia.fromJson(Map<String, dynamic> jsonSerialization) {
    return ObservationMedia(
      id: jsonSerialization['id'] as int?,
      observationId: jsonSerialization['observationId'] as int,
      storagePath: jsonSerialization['storagePath'] as String,
      mediaType: jsonSerialization['mediaType'] as String,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int observationId;

  String storagePath;

  String mediaType;

  DateTime createdAt;

  /// Returns a shallow copy of this [ObservationMedia]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  ObservationMedia copyWith({
    int? id,
    int? observationId,
    String? storagePath,
    String? mediaType,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ObservationMedia',
      if (id != null) 'id': id,
      'observationId': observationId,
      'storagePath': storagePath,
      'mediaType': mediaType,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ObservationMedia',
      if (id != null) 'id': id,
      'observationId': observationId,
      'storagePath': storagePath,
      'mediaType': mediaType,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ObservationMediaImpl extends ObservationMedia {
  _ObservationMediaImpl({
    int? id,
    required int observationId,
    required String storagePath,
    required String mediaType,
    DateTime? createdAt,
  }) : super._(
         id: id,
         observationId: observationId,
         storagePath: storagePath,
         mediaType: mediaType,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [ObservationMedia]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  ObservationMedia copyWith({
    Object? id = _Undefined,
    int? observationId,
    String? storagePath,
    String? mediaType,
    DateTime? createdAt,
  }) {
    return ObservationMedia(
      id: id is int? ? id : this.id,
      observationId: observationId ?? this.observationId,
      storagePath: storagePath ?? this.storagePath,
      mediaType: mediaType ?? this.mediaType,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
