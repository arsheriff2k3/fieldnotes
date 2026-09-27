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

/// An invitation from a campaign creator to an available volunteer. The
/// volunteer sees it privately in Matches and chooses whether to join.
abstract class CampaignInvitation
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  CampaignInvitation._({
    this.id,
    required this.campaignId,
    required this.volunteerAuthUserId,
    required this.sponsorAuthUserId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory CampaignInvitation({
    int? id,
    required int campaignId,
    required _isc.UuidValue volunteerAuthUserId,
    required _isc.UuidValue sponsorAuthUserId,
    DateTime? createdAt,
  }) = _CampaignInvitationImpl;

  factory CampaignInvitation.fromJson(Map<String, dynamic> jsonSerialization) {
    return CampaignInvitation(
      id: jsonSerialization['id'] as int?,
      campaignId: jsonSerialization['campaignId'] as int,
      volunteerAuthUserId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['volunteerAuthUserId'],
      ),
      sponsorAuthUserId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['sponsorAuthUserId'],
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

  int campaignId;

  _isc.UuidValue volunteerAuthUserId;

  _isc.UuidValue sponsorAuthUserId;

  DateTime createdAt;

  /// Returns a shallow copy of this [CampaignInvitation]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CampaignInvitation copyWith({
    int? id,
    int? campaignId,
    _isc.UuidValue? volunteerAuthUserId,
    _isc.UuidValue? sponsorAuthUserId,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CampaignInvitation',
      if (id != null) 'id': id,
      'campaignId': campaignId,
      'volunteerAuthUserId': volunteerAuthUserId.toJson(),
      'sponsorAuthUserId': sponsorAuthUserId.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'CampaignInvitation',
      if (id != null) 'id': id,
      'campaignId': campaignId,
      'volunteerAuthUserId': volunteerAuthUserId.toJson(),
      'sponsorAuthUserId': sponsorAuthUserId.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CampaignInvitationImpl extends CampaignInvitation {
  _CampaignInvitationImpl({
    int? id,
    required int campaignId,
    required _isc.UuidValue volunteerAuthUserId,
    required _isc.UuidValue sponsorAuthUserId,
    DateTime? createdAt,
  }) : super._(
         id: id,
         campaignId: campaignId,
         volunteerAuthUserId: volunteerAuthUserId,
         sponsorAuthUserId: sponsorAuthUserId,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [CampaignInvitation]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CampaignInvitation copyWith({
    Object? id = _Undefined,
    int? campaignId,
    _isc.UuidValue? volunteerAuthUserId,
    _isc.UuidValue? sponsorAuthUserId,
    DateTime? createdAt,
  }) {
    return CampaignInvitation(
      id: id is int? ? id : this.id,
      campaignId: campaignId ?? this.campaignId,
      volunteerAuthUserId: volunteerAuthUserId ?? this.volunteerAuthUserId,
      sponsorAuthUserId: sponsorAuthUserId ?? this.sponsorAuthUserId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
