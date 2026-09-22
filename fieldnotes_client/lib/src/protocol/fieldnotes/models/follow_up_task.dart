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
import '../../fieldnotes/models/task_status.dart' as _iqhuwlzt;

abstract class FollowUpTask
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  FollowUpTask._({
    this.id,
    required this.campaignId,
    this.observationId,
    this.assetId,
    required this.title,
    required this.description,
    this.assigneeAuthUserId,
    this.dueAt,
    required this.status,
    required this.createdBy,
    this.completionNote,
    this.completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory FollowUpTask({
    int? id,
    required int campaignId,
    int? observationId,
    int? assetId,
    required String title,
    required String description,
    _isc.UuidValue? assigneeAuthUserId,
    DateTime? dueAt,
    required _iqhuwlzt.TaskStatus status,
    required _isc.UuidValue createdBy,
    String? completionNote,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _FollowUpTaskImpl;

  factory FollowUpTask.fromJson(Map<String, dynamic> jsonSerialization) {
    return FollowUpTask(
      id: jsonSerialization['id'] as int?,
      campaignId: jsonSerialization['campaignId'] as int,
      observationId: jsonSerialization['observationId'] as int?,
      assetId: jsonSerialization['assetId'] as int?,
      title: jsonSerialization['title'] as String,
      description: jsonSerialization['description'] as String,
      assigneeAuthUserId: jsonSerialization['assigneeAuthUserId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(
              jsonSerialization['assigneeAuthUserId'],
            ),
      dueAt: jsonSerialization['dueAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['dueAt']),
      status: _iqhuwlzt.TaskStatus.fromJson(
        (jsonSerialization['status'] as String),
      ),
      createdBy: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['createdBy'],
      ),
      completionNote: jsonSerialization['completionNote'] as String?,
      completedAt: jsonSerialization['completedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['completedAt'],
            ),
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

  int campaignId;

  int? observationId;

  int? assetId;

  String title;

  String description;

  _isc.UuidValue? assigneeAuthUserId;

  DateTime? dueAt;

  _iqhuwlzt.TaskStatus status;

  _isc.UuidValue createdBy;

  String? completionNote;

  DateTime? completedAt;

  DateTime createdAt;

  DateTime updatedAt;

  /// Returns a shallow copy of this [FollowUpTask]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  FollowUpTask copyWith({
    int? id,
    int? campaignId,
    int? observationId,
    int? assetId,
    String? title,
    String? description,
    _isc.UuidValue? assigneeAuthUserId,
    DateTime? dueAt,
    _iqhuwlzt.TaskStatus? status,
    _isc.UuidValue? createdBy,
    String? completionNote,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'FollowUpTask',
      if (id != null) 'id': id,
      'campaignId': campaignId,
      if (observationId != null) 'observationId': observationId,
      if (assetId != null) 'assetId': assetId,
      'title': title,
      'description': description,
      if (assigneeAuthUserId != null)
        'assigneeAuthUserId': assigneeAuthUserId?.toJson(),
      if (dueAt != null) 'dueAt': dueAt?.toJson(),
      'status': status.toJson(),
      'createdBy': createdBy.toJson(),
      if (completionNote != null) 'completionNote': completionNote,
      if (completedAt != null) 'completedAt': completedAt?.toJson(),
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'FollowUpTask',
      if (id != null) 'id': id,
      'campaignId': campaignId,
      if (observationId != null) 'observationId': observationId,
      if (assetId != null) 'assetId': assetId,
      'title': title,
      'description': description,
      if (assigneeAuthUserId != null)
        'assigneeAuthUserId': assigneeAuthUserId?.toJson(),
      if (dueAt != null) 'dueAt': dueAt?.toJson(),
      'status': status.toJson(),
      'createdBy': createdBy.toJson(),
      if (completionNote != null) 'completionNote': completionNote,
      if (completedAt != null) 'completedAt': completedAt?.toJson(),
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

class _FollowUpTaskImpl extends FollowUpTask {
  _FollowUpTaskImpl({
    int? id,
    required int campaignId,
    int? observationId,
    int? assetId,
    required String title,
    required String description,
    _isc.UuidValue? assigneeAuthUserId,
    DateTime? dueAt,
    required _iqhuwlzt.TaskStatus status,
    required _isc.UuidValue createdBy,
    String? completionNote,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         campaignId: campaignId,
         observationId: observationId,
         assetId: assetId,
         title: title,
         description: description,
         assigneeAuthUserId: assigneeAuthUserId,
         dueAt: dueAt,
         status: status,
         createdBy: createdBy,
         completionNote: completionNote,
         completedAt: completedAt,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [FollowUpTask]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  FollowUpTask copyWith({
    Object? id = _Undefined,
    int? campaignId,
    Object? observationId = _Undefined,
    Object? assetId = _Undefined,
    String? title,
    String? description,
    Object? assigneeAuthUserId = _Undefined,
    Object? dueAt = _Undefined,
    _iqhuwlzt.TaskStatus? status,
    _isc.UuidValue? createdBy,
    Object? completionNote = _Undefined,
    Object? completedAt = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FollowUpTask(
      id: id is int? ? id : this.id,
      campaignId: campaignId ?? this.campaignId,
      observationId: observationId is int? ? observationId : this.observationId,
      assetId: assetId is int? ? assetId : this.assetId,
      title: title ?? this.title,
      description: description ?? this.description,
      assigneeAuthUserId: assigneeAuthUserId is _isc.UuidValue?
          ? assigneeAuthUserId
          : this.assigneeAuthUserId,
      dueAt: dueAt is DateTime? ? dueAt : this.dueAt,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      completionNote: completionNote is String?
          ? completionNote
          : this.completionNote,
      completedAt: completedAt is DateTime? ? completedAt : this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
