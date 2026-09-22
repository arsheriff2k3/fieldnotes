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
import '../../fieldnotes/models/member_role.dart' as _ity09nbz;

abstract class OrganizationMember
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  OrganizationMember._({
    this.id,
    required this.organizationId,
    required this.authUserId,
    required this.displayName,
    required this.role,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory OrganizationMember({
    int? id,
    required int organizationId,
    required _isc.UuidValue authUserId,
    required String displayName,
    required _ity09nbz.MemberRole role,
    DateTime? createdAt,
  }) = _OrganizationMemberImpl;

  factory OrganizationMember.fromJson(Map<String, dynamic> jsonSerialization) {
    return OrganizationMember(
      id: jsonSerialization['id'] as int?,
      organizationId: jsonSerialization['organizationId'] as int,
      authUserId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['authUserId'],
      ),
      displayName: jsonSerialization['displayName'] as String,
      role: _ity09nbz.MemberRole.fromJson(
        (jsonSerialization['role'] as String),
      ),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int organizationId;

  _isc.UuidValue authUserId;

  String displayName;

  _ity09nbz.MemberRole role;

  DateTime createdAt;

  /// Returns a shallow copy of this [OrganizationMember]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  OrganizationMember copyWith({
    int? id,
    int? organizationId,
    _isc.UuidValue? authUserId,
    String? displayName,
    _ity09nbz.MemberRole? role,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'OrganizationMember',
      if (id != null) 'id': id,
      'organizationId': organizationId,
      'authUserId': authUserId.toJson(),
      'displayName': displayName,
      'role': role.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'OrganizationMember',
      if (id != null) 'id': id,
      'organizationId': organizationId,
      'authUserId': authUserId.toJson(),
      'displayName': displayName,
      'role': role.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _OrganizationMemberImpl extends OrganizationMember {
  _OrganizationMemberImpl({
    int? id,
    required int organizationId,
    required _isc.UuidValue authUserId,
    required String displayName,
    required _ity09nbz.MemberRole role,
    DateTime? createdAt,
  }) : super._(
         id: id,
         organizationId: organizationId,
         authUserId: authUserId,
         displayName: displayName,
         role: role,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [OrganizationMember]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  OrganizationMember copyWith({
    Object? id = _Undefined,
    int? organizationId,
    _isc.UuidValue? authUserId,
    String? displayName,
    _ity09nbz.MemberRole? role,
    DateTime? createdAt,
  }) {
    return OrganizationMember(
      id: id is int? ? id : this.id,
      organizationId: organizationId ?? this.organizationId,
      authUserId: authUserId ?? this.authUserId,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
