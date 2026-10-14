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

abstract class NotificationItem
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  NotificationItem._({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    this.campaignId,
    required this.createdAt,
    this.readAt,
  });

  factory NotificationItem({
    required int id,
    required String kind,
    required String title,
    required String body,
    int? campaignId,
    required DateTime createdAt,
    DateTime? readAt,
  }) = _NotificationItemImpl;

  factory NotificationItem.fromJson(Map<String, dynamic> jsonSerialization) {
    return NotificationItem(
      id: jsonSerialization['id'] as int,
      kind: jsonSerialization['kind'] as String,
      title: jsonSerialization['title'] as String,
      body: jsonSerialization['body'] as String,
      campaignId: jsonSerialization['campaignId'] as int?,
      createdAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      readAt: jsonSerialization['readAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['readAt']),
    );
  }

  int id;

  String kind;

  String title;

  String body;

  int? campaignId;

  DateTime createdAt;

  DateTime? readAt;

  /// Returns a shallow copy of this [NotificationItem]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  NotificationItem copyWith({
    int? id,
    String? kind,
    String? title,
    String? body,
    int? campaignId,
    DateTime? createdAt,
    DateTime? readAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'NotificationItem',
      'id': id,
      'kind': kind,
      'title': title,
      'body': body,
      if (campaignId != null) 'campaignId': campaignId,
      'createdAt': createdAt.toJson(),
      if (readAt != null) 'readAt': readAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'NotificationItem',
      'id': id,
      'kind': kind,
      'title': title,
      'body': body,
      if (campaignId != null) 'campaignId': campaignId,
      'createdAt': createdAt.toJson(),
      if (readAt != null) 'readAt': readAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _NotificationItemImpl extends NotificationItem {
  _NotificationItemImpl({
    required int id,
    required String kind,
    required String title,
    required String body,
    int? campaignId,
    required DateTime createdAt,
    DateTime? readAt,
  }) : super._(
         id: id,
         kind: kind,
         title: title,
         body: body,
         campaignId: campaignId,
         createdAt: createdAt,
         readAt: readAt,
       );

  /// Returns a shallow copy of this [NotificationItem]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  NotificationItem copyWith({
    int? id,
    String? kind,
    String? title,
    String? body,
    Object? campaignId = _Undefined,
    DateTime? createdAt,
    Object? readAt = _Undefined,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      title: title ?? this.title,
      body: body ?? this.body,
      campaignId: campaignId is int? ? campaignId : this.campaignId,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt is DateTime? ? readAt : this.readAt,
    );
  }
}
