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
import '../../fieldnotes/models/manual_payout_request.dart' as _if3x8m0j;

abstract class ManualPayoutSummary
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  ManualPayoutSummary._({
    required this.campaignId,
    required this.liveMode,
    required this.completed,
    required this.eligiblePaise,
    required this.availablePaise,
    required this.reservedPaise,
    required this.paidPaise,
    required this.requests,
  });

  factory ManualPayoutSummary({
    required int campaignId,
    required bool liveMode,
    required bool completed,
    required int eligiblePaise,
    required int availablePaise,
    required int reservedPaise,
    required int paidPaise,
    required List<_if3x8m0j.ManualPayoutRequest> requests,
  }) = _ManualPayoutSummaryImpl;

  factory ManualPayoutSummary.fromJson(Map<String, dynamic> jsonSerialization) {
    return ManualPayoutSummary(
      campaignId: jsonSerialization['campaignId'] as int,
      liveMode: _isc.BoolJsonExtension.fromJson(jsonSerialization['liveMode']),
      completed: _isc.BoolJsonExtension.fromJson(
        jsonSerialization['completed'],
      ),
      eligiblePaise: jsonSerialization['eligiblePaise'] as int,
      availablePaise: jsonSerialization['availablePaise'] as int,
      reservedPaise: jsonSerialization['reservedPaise'] as int,
      paidPaise: jsonSerialization['paidPaise'] as int,
      requests: _imuhbzep.Protocol()
          .deserialize<List<_if3x8m0j.ManualPayoutRequest>>(
            jsonSerialization['requests'],
          ),
    );
  }

  int campaignId;

  bool liveMode;

  bool completed;

  int eligiblePaise;

  int availablePaise;

  int reservedPaise;

  int paidPaise;

  List<_if3x8m0j.ManualPayoutRequest> requests;

  /// Returns a shallow copy of this [ManualPayoutSummary]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  ManualPayoutSummary copyWith({
    int? campaignId,
    bool? liveMode,
    bool? completed,
    int? eligiblePaise,
    int? availablePaise,
    int? reservedPaise,
    int? paidPaise,
    List<_if3x8m0j.ManualPayoutRequest>? requests,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ManualPayoutSummary',
      'campaignId': campaignId,
      'liveMode': liveMode,
      'completed': completed,
      'eligiblePaise': eligiblePaise,
      'availablePaise': availablePaise,
      'reservedPaise': reservedPaise,
      'paidPaise': paidPaise,
      'requests': requests.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ManualPayoutSummary',
      'campaignId': campaignId,
      'liveMode': liveMode,
      'completed': completed,
      'eligiblePaise': eligiblePaise,
      'availablePaise': availablePaise,
      'reservedPaise': reservedPaise,
      'paidPaise': paidPaise,
      'requests': requests.toJson(valueToJson: (v) => v.toJsonForProtocol()),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _ManualPayoutSummaryImpl extends ManualPayoutSummary {
  _ManualPayoutSummaryImpl({
    required int campaignId,
    required bool liveMode,
    required bool completed,
    required int eligiblePaise,
    required int availablePaise,
    required int reservedPaise,
    required int paidPaise,
    required List<_if3x8m0j.ManualPayoutRequest> requests,
  }) : super._(
         campaignId: campaignId,
         liveMode: liveMode,
         completed: completed,
         eligiblePaise: eligiblePaise,
         availablePaise: availablePaise,
         reservedPaise: reservedPaise,
         paidPaise: paidPaise,
         requests: requests,
       );

  /// Returns a shallow copy of this [ManualPayoutSummary]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  ManualPayoutSummary copyWith({
    int? campaignId,
    bool? liveMode,
    bool? completed,
    int? eligiblePaise,
    int? availablePaise,
    int? reservedPaise,
    int? paidPaise,
    List<_if3x8m0j.ManualPayoutRequest>? requests,
  }) {
    return ManualPayoutSummary(
      campaignId: campaignId ?? this.campaignId,
      liveMode: liveMode ?? this.liveMode,
      completed: completed ?? this.completed,
      eligiblePaise: eligiblePaise ?? this.eligiblePaise,
      availablePaise: availablePaise ?? this.availablePaise,
      reservedPaise: reservedPaise ?? this.reservedPaise,
      paidPaise: paidPaise ?? this.paidPaise,
      requests: requests ?? this.requests.map((e0) => e0.copyWith()).toList(),
    );
  }
}
