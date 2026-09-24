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
import '../../fieldnotes/models/campaign_map_pin.dart' as _i1tmtf4d;

/// Everything the sponsor live map needs for one campaign: the pin and
/// geofence it was published with, plus every check-in and evidence point.
abstract class CampaignMapOverview
    implements _is.SerializableModel, _is.ProtocolSerialization {
  CampaignMapOverview._({
    required this.campaign,
    required this.pins,
    required this.joinedCount,
    required this.checkedInCount,
    required this.completedCount,
    required this.demoCount,
  });

  factory CampaignMapOverview({
    required _iatxe5ix.Campaign campaign,
    required List<_i1tmtf4d.CampaignMapPin> pins,
    required int joinedCount,
    required int checkedInCount,
    required int completedCount,
    required int demoCount,
  }) = _CampaignMapOverviewImpl;

  factory CampaignMapOverview.fromJson(Map<String, dynamic> jsonSerialization) {
    return CampaignMapOverview(
      campaign: _ix00qkn1.Protocol().deserialize<_iatxe5ix.Campaign>(
        jsonSerialization['campaign'],
      ),
      pins: _ix00qkn1.Protocol().deserialize<List<_i1tmtf4d.CampaignMapPin>>(
        jsonSerialization['pins'],
      ),
      joinedCount: jsonSerialization['joinedCount'] as int,
      checkedInCount: jsonSerialization['checkedInCount'] as int,
      completedCount: jsonSerialization['completedCount'] as int,
      demoCount: jsonSerialization['demoCount'] as int,
    );
  }

  _iatxe5ix.Campaign campaign;

  List<_i1tmtf4d.CampaignMapPin> pins;

  int joinedCount;

  int checkedInCount;

  int completedCount;

  int demoCount;

  /// Returns a shallow copy of this [CampaignMapOverview]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CampaignMapOverview copyWith({
    _iatxe5ix.Campaign? campaign,
    List<_i1tmtf4d.CampaignMapPin>? pins,
    int? joinedCount,
    int? checkedInCount,
    int? completedCount,
    int? demoCount,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CampaignMapOverview',
      'campaign': campaign.toJson(),
      'pins': pins.toJson(valueToJson: (v) => v.toJson()),
      'joinedCount': joinedCount,
      'checkedInCount': checkedInCount,
      'completedCount': completedCount,
      'demoCount': demoCount,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'CampaignMapOverview',
      'campaign': campaign.toJsonForProtocol(),
      'pins': pins.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'joinedCount': joinedCount,
      'checkedInCount': checkedInCount,
      'completedCount': completedCount,
      'demoCount': demoCount,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _CampaignMapOverviewImpl extends CampaignMapOverview {
  _CampaignMapOverviewImpl({
    required _iatxe5ix.Campaign campaign,
    required List<_i1tmtf4d.CampaignMapPin> pins,
    required int joinedCount,
    required int checkedInCount,
    required int completedCount,
    required int demoCount,
  }) : super._(
         campaign: campaign,
         pins: pins,
         joinedCount: joinedCount,
         checkedInCount: checkedInCount,
         completedCount: completedCount,
         demoCount: demoCount,
       );

  /// Returns a shallow copy of this [CampaignMapOverview]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CampaignMapOverview copyWith({
    _iatxe5ix.Campaign? campaign,
    List<_i1tmtf4d.CampaignMapPin>? pins,
    int? joinedCount,
    int? checkedInCount,
    int? completedCount,
    int? demoCount,
  }) {
    return CampaignMapOverview(
      campaign: campaign ?? this.campaign.copyWith(),
      pins: pins ?? this.pins.map((e0) => e0.copyWith()).toList(),
      joinedCount: joinedCount ?? this.joinedCount,
      checkedInCount: checkedInCount ?? this.checkedInCount,
      completedCount: completedCount ?? this.completedCount,
      demoCount: demoCount ?? this.demoCount,
    );
  }
}
