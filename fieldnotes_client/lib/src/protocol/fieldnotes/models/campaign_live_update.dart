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

abstract class CampaignLiveUpdate
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  CampaignLiveUpdate._({
    required this.campaignId,
    required this.event,
    required this.message,
    required this.occurredAt,
  });

  factory CampaignLiveUpdate({
    required int campaignId,
    required String event,
    required String message,
    required DateTime occurredAt,
  }) = _CampaignLiveUpdateImpl;

  factory CampaignLiveUpdate.fromJson(Map<String, dynamic> jsonSerialization) {
    return CampaignLiveUpdate(
      campaignId: jsonSerialization['campaignId'] as int,
      event: jsonSerialization['event'] as String,
      message: jsonSerialization['message'] as String,
      occurredAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['occurredAt'],
      ),
    );
  }

  int campaignId;

  String event;

  String message;

  DateTime occurredAt;

  /// Returns a shallow copy of this [CampaignLiveUpdate]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CampaignLiveUpdate copyWith({
    int? campaignId,
    String? event,
    String? message,
    DateTime? occurredAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CampaignLiveUpdate',
      'campaignId': campaignId,
      'event': event,
      'message': message,
      'occurredAt': occurredAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'CampaignLiveUpdate',
      'campaignId': campaignId,
      'event': event,
      'message': message,
      'occurredAt': occurredAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _CampaignLiveUpdateImpl extends CampaignLiveUpdate {
  _CampaignLiveUpdateImpl({
    required int campaignId,
    required String event,
    required String message,
    required DateTime occurredAt,
  }) : super._(
         campaignId: campaignId,
         event: event,
         message: message,
         occurredAt: occurredAt,
       );

  /// Returns a shallow copy of this [CampaignLiveUpdate]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CampaignLiveUpdate copyWith({
    int? campaignId,
    String? event,
    String? message,
    DateTime? occurredAt,
  }) {
    return CampaignLiveUpdate(
      campaignId: campaignId ?? this.campaignId,
      event: event ?? this.event,
      message: message ?? this.message,
      occurredAt: occurredAt ?? this.occurredAt,
    );
  }
}
