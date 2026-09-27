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
import 'package:fieldnotes_server/src/generated/protocol.dart' as _ix00qkn1;
import 'package:serverpod/serverpod.dart' as _is;
import '../../fieldnotes/models/campaign_volunteer_map_member.dart'
    as _i615e12c;

/// Creator-only volunteer roster for a published campaign.
abstract class CampaignVolunteerMap
    implements _is.SerializableModel, _is.ProtocolSerialization {
  CampaignVolunteerMap._({
    required this.volunteers,
    required this.summary,
  });

  factory CampaignVolunteerMap({
    required List<_i615e12c.CampaignVolunteerMapMember> volunteers,
    required String summary,
  }) = _CampaignVolunteerMapImpl;

  factory CampaignVolunteerMap.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CampaignVolunteerMap(
      volunteers: _ix00qkn1.Protocol()
          .deserialize<List<_i615e12c.CampaignVolunteerMapMember>>(
            jsonSerialization['volunteers'],
          ),
      summary: jsonSerialization['summary'] as String,
    );
  }

  List<_i615e12c.CampaignVolunteerMapMember> volunteers;

  String summary;

  /// Returns a shallow copy of this [CampaignVolunteerMap]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CampaignVolunteerMap copyWith({
    List<_i615e12c.CampaignVolunteerMapMember>? volunteers,
    String? summary,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CampaignVolunteerMap',
      'volunteers': volunteers.toJson(valueToJson: (v) => v.toJson()),
      'summary': summary,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'CampaignVolunteerMap',
      'volunteers': volunteers.toJson(
        valueToJson: (v) => v.toJsonForProtocol(),
      ),
      'summary': summary,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _CampaignVolunteerMapImpl extends CampaignVolunteerMap {
  _CampaignVolunteerMapImpl({
    required List<_i615e12c.CampaignVolunteerMapMember> volunteers,
    required String summary,
  }) : super._(
         volunteers: volunteers,
         summary: summary,
       );

  /// Returns a shallow copy of this [CampaignVolunteerMap]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CampaignVolunteerMap copyWith({
    List<_i615e12c.CampaignVolunteerMapMember>? volunteers,
    String? summary,
  }) {
    return CampaignVolunteerMap(
      volunteers:
          volunteers ?? this.volunteers.map((e0) => e0.copyWith()).toList(),
      summary: summary ?? this.summary,
    );
  }
}
