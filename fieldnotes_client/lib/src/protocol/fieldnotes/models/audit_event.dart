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

abstract class AuditEvent
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  AuditEvent._({
    this.id,
    required this.actorAuthUserId,
    required this.event,
    required this.entityType,
    this.entityId,
    required this.outcome,
    required this.riskLevel,
    required this.detail,
    DateTime? occurredAt,
  }) : occurredAt = occurredAt ?? DateTime.now();

  factory AuditEvent({
    int? id,
    required _isc.UuidValue actorAuthUserId,
    required String event,
    required String entityType,
    String? entityId,
    required String outcome,
    required String riskLevel,
    required String detail,
    DateTime? occurredAt,
  }) = _AuditEventImpl;

  factory AuditEvent.fromJson(Map<String, dynamic> jsonSerialization) {
    return AuditEvent(
      id: jsonSerialization['id'] as int?,
      actorAuthUserId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['actorAuthUserId'],
      ),
      event: jsonSerialization['event'] as String,
      entityType: jsonSerialization['entityType'] as String,
      entityId: jsonSerialization['entityId'] as String?,
      outcome: jsonSerialization['outcome'] as String,
      riskLevel: jsonSerialization['riskLevel'] as String,
      detail: jsonSerialization['detail'] as String,
      occurredAt: jsonSerialization['occurredAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['occurredAt'],
            ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  _isc.UuidValue actorAuthUserId;

  String event;

  String entityType;

  String? entityId;

  String outcome;

  String riskLevel;

  String detail;

  DateTime occurredAt;

  /// Returns a shallow copy of this [AuditEvent]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  AuditEvent copyWith({
    int? id,
    _isc.UuidValue? actorAuthUserId,
    String? event,
    String? entityType,
    String? entityId,
    String? outcome,
    String? riskLevel,
    String? detail,
    DateTime? occurredAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AuditEvent',
      if (id != null) 'id': id,
      'actorAuthUserId': actorAuthUserId.toJson(),
      'event': event,
      'entityType': entityType,
      if (entityId != null) 'entityId': entityId,
      'outcome': outcome,
      'riskLevel': riskLevel,
      'detail': detail,
      'occurredAt': occurredAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AuditEvent',
      if (id != null) 'id': id,
      'actorAuthUserId': actorAuthUserId.toJson(),
      'event': event,
      'entityType': entityType,
      if (entityId != null) 'entityId': entityId,
      'outcome': outcome,
      'riskLevel': riskLevel,
      'detail': detail,
      'occurredAt': occurredAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AuditEventImpl extends AuditEvent {
  _AuditEventImpl({
    int? id,
    required _isc.UuidValue actorAuthUserId,
    required String event,
    required String entityType,
    String? entityId,
    required String outcome,
    required String riskLevel,
    required String detail,
    DateTime? occurredAt,
  }) : super._(
         id: id,
         actorAuthUserId: actorAuthUserId,
         event: event,
         entityType: entityType,
         entityId: entityId,
         outcome: outcome,
         riskLevel: riskLevel,
         detail: detail,
         occurredAt: occurredAt,
       );

  /// Returns a shallow copy of this [AuditEvent]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  AuditEvent copyWith({
    Object? id = _Undefined,
    _isc.UuidValue? actorAuthUserId,
    String? event,
    String? entityType,
    Object? entityId = _Undefined,
    String? outcome,
    String? riskLevel,
    String? detail,
    DateTime? occurredAt,
  }) {
    return AuditEvent(
      id: id is int? ? id : this.id,
      actorAuthUserId: actorAuthUserId ?? this.actorAuthUserId,
      event: event ?? this.event,
      entityType: entityType ?? this.entityType,
      entityId: entityId is String? ? entityId : this.entityId,
      outcome: outcome ?? this.outcome,
      riskLevel: riskLevel ?? this.riskLevel,
      detail: detail ?? this.detail,
      occurredAt: occurredAt ?? this.occurredAt,
    );
  }
}
