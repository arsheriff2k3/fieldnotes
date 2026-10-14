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
import '../../fieldnotes/models/campaign_status.dart' as _i4m9p8sf;
import '../../fieldnotes/models/sponsorship.dart' as _iddd4nv6;
import '../../fieldnotes/models/test_refund.dart' as _ivfg4rjz;

abstract class SponsorshipHistoryEntry
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  SponsorshipHistoryEntry._({
    required this.sponsorship,
    required this.campaignName,
    required this.campaignStatus,
    required this.campaignReadinessState,
    this.refund,
  });

  factory SponsorshipHistoryEntry({
    required _iddd4nv6.Sponsorship sponsorship,
    required String campaignName,
    required _i4m9p8sf.CampaignStatus campaignStatus,
    required String campaignReadinessState,
    _ivfg4rjz.TestRefund? refund,
  }) = _SponsorshipHistoryEntryImpl;

  factory SponsorshipHistoryEntry.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return SponsorshipHistoryEntry(
      sponsorship: _imuhbzep.Protocol().deserialize<_iddd4nv6.Sponsorship>(
        jsonSerialization['sponsorship'],
      ),
      campaignName: jsonSerialization['campaignName'] as String,
      campaignStatus: _i4m9p8sf.CampaignStatus.fromJson(
        (jsonSerialization['campaignStatus'] as String),
      ),
      campaignReadinessState:
          jsonSerialization['campaignReadinessState'] as String,
      refund: jsonSerialization['refund'] == null
          ? null
          : _imuhbzep.Protocol().deserialize<_ivfg4rjz.TestRefund>(
              jsonSerialization['refund'],
            ),
    );
  }

  _iddd4nv6.Sponsorship sponsorship;

  String campaignName;

  _i4m9p8sf.CampaignStatus campaignStatus;

  String campaignReadinessState;

  _ivfg4rjz.TestRefund? refund;

  /// Returns a shallow copy of this [SponsorshipHistoryEntry]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  SponsorshipHistoryEntry copyWith({
    _iddd4nv6.Sponsorship? sponsorship,
    String? campaignName,
    _i4m9p8sf.CampaignStatus? campaignStatus,
    String? campaignReadinessState,
    _ivfg4rjz.TestRefund? refund,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SponsorshipHistoryEntry',
      'sponsorship': sponsorship.toJson(),
      'campaignName': campaignName,
      'campaignStatus': campaignStatus.toJson(),
      'campaignReadinessState': campaignReadinessState,
      if (refund != null) 'refund': refund?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'SponsorshipHistoryEntry',
      'sponsorship': sponsorship.toJsonForProtocol(),
      'campaignName': campaignName,
      'campaignStatus': campaignStatus.toJson(),
      'campaignReadinessState': campaignReadinessState,
      if (refund != null) 'refund': refund?.toJsonForProtocol(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SponsorshipHistoryEntryImpl extends SponsorshipHistoryEntry {
  _SponsorshipHistoryEntryImpl({
    required _iddd4nv6.Sponsorship sponsorship,
    required String campaignName,
    required _i4m9p8sf.CampaignStatus campaignStatus,
    required String campaignReadinessState,
    _ivfg4rjz.TestRefund? refund,
  }) : super._(
         sponsorship: sponsorship,
         campaignName: campaignName,
         campaignStatus: campaignStatus,
         campaignReadinessState: campaignReadinessState,
         refund: refund,
       );

  /// Returns a shallow copy of this [SponsorshipHistoryEntry]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  SponsorshipHistoryEntry copyWith({
    _iddd4nv6.Sponsorship? sponsorship,
    String? campaignName,
    _i4m9p8sf.CampaignStatus? campaignStatus,
    String? campaignReadinessState,
    Object? refund = _Undefined,
  }) {
    return SponsorshipHistoryEntry(
      sponsorship: sponsorship ?? this.sponsorship.copyWith(),
      campaignName: campaignName ?? this.campaignName,
      campaignStatus: campaignStatus ?? this.campaignStatus,
      campaignReadinessState:
          campaignReadinessState ?? this.campaignReadinessState,
      refund: refund is _ivfg4rjz.TestRefund?
          ? refund
          : this.refund?.copyWith(),
    );
  }
}
