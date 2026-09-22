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
import '../../fieldnotes/models/campaign.dart' as _iatxe5ix;
import '../../fieldnotes/models/organization.dart' as _idt4rlmh;
import '../../fieldnotes/models/organization_member.dart' as _ie6abbe7;

abstract class WorkspaceSummary
    implements _is.SerializableModel, _is.ProtocolSerialization {
  WorkspaceSummary._({
    required this.organization,
    required this.membership,
    required this.campaigns,
  });

  factory WorkspaceSummary({
    required _idt4rlmh.Organization organization,
    required _ie6abbe7.OrganizationMember membership,
    required List<_iatxe5ix.Campaign> campaigns,
  }) = _WorkspaceSummaryImpl;

  factory WorkspaceSummary.fromJson(Map<String, dynamic> jsonSerialization) {
    return WorkspaceSummary(
      organization: _ix00qkn1.Protocol().deserialize<_idt4rlmh.Organization>(
        jsonSerialization['organization'],
      ),
      membership: _ix00qkn1.Protocol()
          .deserialize<_ie6abbe7.OrganizationMember>(
            jsonSerialization['membership'],
          ),
      campaigns: _ix00qkn1.Protocol().deserialize<List<_iatxe5ix.Campaign>>(
        jsonSerialization['campaigns'],
      ),
    );
  }

  _idt4rlmh.Organization organization;

  _ie6abbe7.OrganizationMember membership;

  List<_iatxe5ix.Campaign> campaigns;

  /// Returns a shallow copy of this [WorkspaceSummary]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  WorkspaceSummary copyWith({
    _idt4rlmh.Organization? organization,
    _ie6abbe7.OrganizationMember? membership,
    List<_iatxe5ix.Campaign>? campaigns,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'WorkspaceSummary',
      'organization': organization.toJson(),
      'membership': membership.toJson(),
      'campaigns': campaigns.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'WorkspaceSummary',
      'organization': organization.toJsonForProtocol(),
      'membership': membership.toJsonForProtocol(),
      'campaigns': campaigns.toJson(valueToJson: (v) => v.toJsonForProtocol()),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _WorkspaceSummaryImpl extends WorkspaceSummary {
  _WorkspaceSummaryImpl({
    required _idt4rlmh.Organization organization,
    required _ie6abbe7.OrganizationMember membership,
    required List<_iatxe5ix.Campaign> campaigns,
  }) : super._(
         organization: organization,
         membership: membership,
         campaigns: campaigns,
       );

  /// Returns a shallow copy of this [WorkspaceSummary]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  WorkspaceSummary copyWith({
    _idt4rlmh.Organization? organization,
    _ie6abbe7.OrganizationMember? membership,
    List<_iatxe5ix.Campaign>? campaigns,
  }) {
    return WorkspaceSummary(
      organization: organization ?? this.organization.copyWith(),
      membership: membership ?? this.membership.copyWith(),
      campaigns:
          campaigns ?? this.campaigns.map((e0) => e0.copyWith()).toList(),
    );
  }
}
