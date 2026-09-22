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

abstract class CampaignPost
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  CampaignPost._({
    this.id,
    required this.campaignId,
    required this.authorSponsorAuthUserId,
    required this.title,
    required this.body,
    this.photographPath,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory CampaignPost({
    int? id,
    required int campaignId,
    required _isc.UuidValue authorSponsorAuthUserId,
    required String title,
    required String body,
    String? photographPath,
    DateTime? createdAt,
  }) = _CampaignPostImpl;

  factory CampaignPost.fromJson(Map<String, dynamic> jsonSerialization) {
    return CampaignPost(
      id: jsonSerialization['id'] as int?,
      campaignId: jsonSerialization['campaignId'] as int,
      authorSponsorAuthUserId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['authorSponsorAuthUserId'],
      ),
      title: jsonSerialization['title'] as String,
      body: jsonSerialization['body'] as String,
      photographPath: jsonSerialization['photographPath'] as String?,
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

  _isc.UuidValue authorSponsorAuthUserId;

  String title;

  String body;

  String? photographPath;

  DateTime createdAt;

  /// Returns a shallow copy of this [CampaignPost]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CampaignPost copyWith({
    int? id,
    int? campaignId,
    _isc.UuidValue? authorSponsorAuthUserId,
    String? title,
    String? body,
    String? photographPath,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CampaignPost',
      if (id != null) 'id': id,
      'campaignId': campaignId,
      'authorSponsorAuthUserId': authorSponsorAuthUserId.toJson(),
      'title': title,
      'body': body,
      if (photographPath != null) 'photographPath': photographPath,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'CampaignPost',
      if (id != null) 'id': id,
      'campaignId': campaignId,
      'authorSponsorAuthUserId': authorSponsorAuthUserId.toJson(),
      'title': title,
      'body': body,
      if (photographPath != null) 'photographPath': photographPath,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CampaignPostImpl extends CampaignPost {
  _CampaignPostImpl({
    int? id,
    required int campaignId,
    required _isc.UuidValue authorSponsorAuthUserId,
    required String title,
    required String body,
    String? photographPath,
    DateTime? createdAt,
  }) : super._(
         id: id,
         campaignId: campaignId,
         authorSponsorAuthUserId: authorSponsorAuthUserId,
         title: title,
         body: body,
         photographPath: photographPath,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [CampaignPost]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CampaignPost copyWith({
    Object? id = _Undefined,
    int? campaignId,
    _isc.UuidValue? authorSponsorAuthUserId,
    String? title,
    String? body,
    Object? photographPath = _Undefined,
    DateTime? createdAt,
  }) {
    return CampaignPost(
      id: id is int? ? id : this.id,
      campaignId: campaignId ?? this.campaignId,
      authorSponsorAuthUserId:
          authorSponsorAuthUserId ?? this.authorSponsorAuthUserId,
      title: title ?? this.title,
      body: body ?? this.body,
      photographPath: photographPath is String?
          ? photographPath
          : this.photographPath,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
