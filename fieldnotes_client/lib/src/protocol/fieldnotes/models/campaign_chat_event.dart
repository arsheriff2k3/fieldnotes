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
import 'package:fieldnotes_client/src/protocol/protocol.dart' as _imuhbzep;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import '../../fieldnotes/models/campaign_chat_message.dart' as _i35rnhb7;

abstract class CampaignChatEvent
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  CampaignChatEvent._({
    required this.campaignId,
    required this.readOnly,
    this.message,
  });

  factory CampaignChatEvent({
    required int campaignId,
    required bool readOnly,
    _i35rnhb7.CampaignChatMessage? message,
  }) = _CampaignChatEventImpl;

  factory CampaignChatEvent.fromJson(Map<String, dynamic> jsonSerialization) {
    return CampaignChatEvent(
      campaignId: jsonSerialization['campaignId'] as int,
      readOnly: _isc.BoolJsonExtension.fromJson(jsonSerialization['readOnly']),
      message: jsonSerialization['message'] == null
          ? null
          : _imuhbzep.Protocol().deserialize<_i35rnhb7.CampaignChatMessage>(
              jsonSerialization['message'],
            ),
    );
  }

  int campaignId;

  bool readOnly;

  _i35rnhb7.CampaignChatMessage? message;

  /// Returns a shallow copy of this [CampaignChatEvent]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CampaignChatEvent copyWith({
    int? campaignId,
    bool? readOnly,
    _i35rnhb7.CampaignChatMessage? message,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CampaignChatEvent',
      'campaignId': campaignId,
      'readOnly': readOnly,
      if (message != null) 'message': message?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'CampaignChatEvent',
      'campaignId': campaignId,
      'readOnly': readOnly,
      if (message != null) 'message': message?.toJsonForProtocol(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CampaignChatEventImpl extends CampaignChatEvent {
  _CampaignChatEventImpl({
    required int campaignId,
    required bool readOnly,
    _i35rnhb7.CampaignChatMessage? message,
  }) : super._(
         campaignId: campaignId,
         readOnly: readOnly,
         message: message,
       );

  /// Returns a shallow copy of this [CampaignChatEvent]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CampaignChatEvent copyWith({
    int? campaignId,
    bool? readOnly,
    Object? message = _Undefined,
  }) {
    return CampaignChatEvent(
      campaignId: campaignId ?? this.campaignId,
      readOnly: readOnly ?? this.readOnly,
      message: message is _i35rnhb7.CampaignChatMessage?
          ? message
          : this.message?.copyWith(),
    );
  }
}
