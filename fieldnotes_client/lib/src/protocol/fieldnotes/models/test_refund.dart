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

abstract class TestRefund
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  TestRefund._({
    this.id,
    required this.campaignId,
    required this.sponsorshipId,
    required this.amount,
    String? status,
    DateTime? createdAt,
  }) : status = status ?? 'refund_due_test',
       createdAt = createdAt ?? DateTime.now();

  factory TestRefund({
    int? id,
    required int campaignId,
    required int sponsorshipId,
    required double amount,
    String? status,
    DateTime? createdAt,
  }) = _TestRefundImpl;

  factory TestRefund.fromJson(Map<String, dynamic> jsonSerialization) {
    return TestRefund(
      id: jsonSerialization['id'] as int?,
      campaignId: jsonSerialization['campaignId'] as int,
      sponsorshipId: jsonSerialization['sponsorshipId'] as int,
      amount: (jsonSerialization['amount'] as num).toDouble(),
      status: jsonSerialization['status'] as String?,
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

  int sponsorshipId;

  double amount;

  String status;

  DateTime createdAt;

  /// Returns a shallow copy of this [TestRefund]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  TestRefund copyWith({
    int? id,
    int? campaignId,
    int? sponsorshipId,
    double? amount,
    String? status,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TestRefund',
      if (id != null) 'id': id,
      'campaignId': campaignId,
      'sponsorshipId': sponsorshipId,
      'amount': amount,
      'status': status,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'TestRefund',
      if (id != null) 'id': id,
      'campaignId': campaignId,
      'sponsorshipId': sponsorshipId,
      'amount': amount,
      'status': status,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _TestRefundImpl extends TestRefund {
  _TestRefundImpl({
    int? id,
    required int campaignId,
    required int sponsorshipId,
    required double amount,
    String? status,
    DateTime? createdAt,
  }) : super._(
         id: id,
         campaignId: campaignId,
         sponsorshipId: sponsorshipId,
         amount: amount,
         status: status,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [TestRefund]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  TestRefund copyWith({
    Object? id = _Undefined,
    int? campaignId,
    int? sponsorshipId,
    double? amount,
    String? status,
    DateTime? createdAt,
  }) {
    return TestRefund(
      id: id is int? ? id : this.id,
      campaignId: campaignId ?? this.campaignId,
      sponsorshipId: sponsorshipId ?? this.sponsorshipId,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
