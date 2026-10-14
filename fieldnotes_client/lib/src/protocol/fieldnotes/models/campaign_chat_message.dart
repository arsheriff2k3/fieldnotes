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

abstract class CampaignChatMessage
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  CampaignChatMessage._({
    this.id,
    required this.campaignId,
    required this.senderAuthUserId,
    required this.senderDisplayName,
    required this.senderIsCreator,
    required this.body,
    required this.clientRequestId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory CampaignChatMessage({
    int? id,
    required int campaignId,
    required _isc.UuidValue senderAuthUserId,
    required String senderDisplayName,
    required bool senderIsCreator,
    required String body,
    required String clientRequestId,
    DateTime? createdAt,
  }) = _CampaignChatMessageImpl;

  factory CampaignChatMessage.fromJson(Map<String, dynamic> jsonSerialization) {
    return CampaignChatMessage(
      id: jsonSerialization['id'] as int?,
      campaignId: jsonSerialization['campaignId'] as int,
      senderAuthUserId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['senderAuthUserId'],
      ),
      senderDisplayName: jsonSerialization['senderDisplayName'] as String,
      senderIsCreator: _isc.BoolJsonExtension.fromJson(
        jsonSerialization['senderIsCreator'],
      ),
      body: jsonSerialization['body'] as String,
      clientRequestId: jsonSerialization['clientRequestId'] as String,
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

  _isc.UuidValue senderAuthUserId;

  String senderDisplayName;

  bool senderIsCreator;

  String body;

  String clientRequestId;

  DateTime createdAt;

  /// Returns a shallow copy of this [CampaignChatMessage]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CampaignChatMessage copyWith({
    int? id,
    int? campaignId,
    _isc.UuidValue? senderAuthUserId,
    String? senderDisplayName,
    bool? senderIsCreator,
    String? body,
    String? clientRequestId,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CampaignChatMessage',
      if (id != null) 'id': id,
      'campaignId': campaignId,
      'senderAuthUserId': senderAuthUserId.toJson(),
      'senderDisplayName': senderDisplayName,
      'senderIsCreator': senderIsCreator,
      'body': body,
      'clientRequestId': clientRequestId,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'CampaignChatMessage',
      if (id != null) 'id': id,
      'campaignId': campaignId,
      'senderAuthUserId': senderAuthUserId.toJson(),
      'senderDisplayName': senderDisplayName,
      'senderIsCreator': senderIsCreator,
      'body': body,
      'clientRequestId': clientRequestId,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CampaignChatMessageImpl extends CampaignChatMessage {
  _CampaignChatMessageImpl({
    int? id,
    required int campaignId,
    required _isc.UuidValue senderAuthUserId,
    required String senderDisplayName,
    required bool senderIsCreator,
    required String body,
    required String clientRequestId,
    DateTime? createdAt,
  }) : super._(
         id: id,
         campaignId: campaignId,
         senderAuthUserId: senderAuthUserId,
         senderDisplayName: senderDisplayName,
         senderIsCreator: senderIsCreator,
         body: body,
         clientRequestId: clientRequestId,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [CampaignChatMessage]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CampaignChatMessage copyWith({
    Object? id = _Undefined,
    int? campaignId,
    _isc.UuidValue? senderAuthUserId,
    String? senderDisplayName,
    bool? senderIsCreator,
    String? body,
    String? clientRequestId,
    DateTime? createdAt,
  }) {
    return CampaignChatMessage(
      id: id is int? ? id : this.id,
      campaignId: campaignId ?? this.campaignId,
      senderAuthUserId: senderAuthUserId ?? this.senderAuthUserId,
      senderDisplayName: senderDisplayName ?? this.senderDisplayName,
      senderIsCreator: senderIsCreator ?? this.senderIsCreator,
      body: body ?? this.body,
      clientRequestId: clientRequestId ?? this.clientRequestId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
