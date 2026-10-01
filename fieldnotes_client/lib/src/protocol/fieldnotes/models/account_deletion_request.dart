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

/// One account deletion request (P0-6). Created by requestAccountDeletion and
/// executed by the outbox future call. The row keeps only the deleted auth
/// user id so the request stays idempotent; it never stores the anonymous id
/// that replaced the user in retained financial records.
///
/// status: pending | processing | completed | failed
abstract class AccountDeletionRequest
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  AccountDeletionRequest._({
    this.id,
    required this.authUserId,
    String? status,
    this.lastError,
    int? attempts,
    this.nextAttemptAt,
    DateTime? requestedAt,
    this.processedAt,
    this.completedAt,
    DateTime? updatedAt,
  }) : status = status ?? 'pending',
       attempts = attempts ?? 0,
       requestedAt = requestedAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory AccountDeletionRequest({
    int? id,
    required _isc.UuidValue authUserId,
    String? status,
    String? lastError,
    int? attempts,
    DateTime? nextAttemptAt,
    DateTime? requestedAt,
    DateTime? processedAt,
    DateTime? completedAt,
    DateTime? updatedAt,
  }) = _AccountDeletionRequestImpl;

  factory AccountDeletionRequest.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return AccountDeletionRequest(
      id: jsonSerialization['id'] as int?,
      authUserId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['authUserId'],
      ),
      status: jsonSerialization['status'] as String?,
      lastError: jsonSerialization['lastError'] as String?,
      attempts: jsonSerialization['attempts'] as int?,
      nextAttemptAt: jsonSerialization['nextAttemptAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['nextAttemptAt'],
            ),
      requestedAt: jsonSerialization['requestedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['requestedAt'],
            ),
      processedAt: jsonSerialization['processedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['processedAt'],
            ),
      completedAt: jsonSerialization['completedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['completedAt'],
            ),
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

  String status;

  /// Client-safe error code when the last attempt failed.
  String? lastError;

  int attempts;

  DateTime? nextAttemptAt;

  DateTime requestedAt;

  DateTime? processedAt;

  DateTime? completedAt;

  DateTime updatedAt;

  /// Returns a shallow copy of this [AccountDeletionRequest]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  AccountDeletionRequest copyWith({
    int? id,
    _isc.UuidValue? authUserId,
    String? status,
    String? lastError,
    int? attempts,
    DateTime? nextAttemptAt,
    DateTime? requestedAt,
    DateTime? processedAt,
    DateTime? completedAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AccountDeletionRequest',
      if (id != null) 'id': id,
      'authUserId': authUserId.toJson(),
      'status': status,
      if (lastError != null) 'lastError': lastError,
      'attempts': attempts,
      if (nextAttemptAt != null) 'nextAttemptAt': nextAttemptAt?.toJson(),
      'requestedAt': requestedAt.toJson(),
      if (processedAt != null) 'processedAt': processedAt?.toJson(),
      if (completedAt != null) 'completedAt': completedAt?.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AccountDeletionRequest',
      if (id != null) 'id': id,
      'authUserId': authUserId.toJson(),
      'status': status,
      if (lastError != null) 'lastError': lastError,
      'attempts': attempts,
      if (nextAttemptAt != null) 'nextAttemptAt': nextAttemptAt?.toJson(),
      'requestedAt': requestedAt.toJson(),
      if (processedAt != null) 'processedAt': processedAt?.toJson(),
      if (completedAt != null) 'completedAt': completedAt?.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AccountDeletionRequestImpl extends AccountDeletionRequest {
  _AccountDeletionRequestImpl({
    int? id,
    required _isc.UuidValue authUserId,
    String? status,
    String? lastError,
    int? attempts,
    DateTime? nextAttemptAt,
    DateTime? requestedAt,
    DateTime? processedAt,
    DateTime? completedAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         authUserId: authUserId,
         status: status,
         lastError: lastError,
         attempts: attempts,
         nextAttemptAt: nextAttemptAt,
         requestedAt: requestedAt,
         processedAt: processedAt,
         completedAt: completedAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [AccountDeletionRequest]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  AccountDeletionRequest copyWith({
    Object? id = _Undefined,
    _isc.UuidValue? authUserId,
    String? status,
    Object? lastError = _Undefined,
    int? attempts,
    Object? nextAttemptAt = _Undefined,
    DateTime? requestedAt,
    Object? processedAt = _Undefined,
    Object? completedAt = _Undefined,
    DateTime? updatedAt,
  }) {
    return AccountDeletionRequest(
      id: id is int? ? id : this.id,
      authUserId: authUserId ?? this.authUserId,
      status: status ?? this.status,
      lastError: lastError is String? ? lastError : this.lastError,
      attempts: attempts ?? this.attempts,
      nextAttemptAt: nextAttemptAt is DateTime?
          ? nextAttemptAt
          : this.nextAttemptAt,
      requestedAt: requestedAt ?? this.requestedAt,
      processedAt: processedAt is DateTime? ? processedAt : this.processedAt,
      completedAt: completedAt is DateTime? ? completedAt : this.completedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
