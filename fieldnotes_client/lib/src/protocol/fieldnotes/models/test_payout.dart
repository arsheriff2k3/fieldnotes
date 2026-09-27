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

abstract class TestPayout
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  TestPayout._({
    this.id,
    required this.campaignId,
    required this.sponsorshipId,
    required this.creatorAuthUserId,
    required this.amount,
    required this.sourcePaymentId,
    String? status,
    DateTime? simulatedAt,
  }) : status = status ?? 'simulated',
       simulatedAt = simulatedAt ?? DateTime.now();

  factory TestPayout({
    int? id,
    required int campaignId,
    required int sponsorshipId,
    required _isc.UuidValue creatorAuthUserId,
    required double amount,
    required String sourcePaymentId,
    String? status,
    DateTime? simulatedAt,
  }) = _TestPayoutImpl;

  factory TestPayout.fromJson(Map<String, dynamic> jsonSerialization) {
    return TestPayout(
      id: jsonSerialization['id'] as int?,
      campaignId: jsonSerialization['campaignId'] as int,
      sponsorshipId: jsonSerialization['sponsorshipId'] as int,
      creatorAuthUserId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['creatorAuthUserId'],
      ),
      amount: (jsonSerialization['amount'] as num).toDouble(),
      sourcePaymentId: jsonSerialization['sourcePaymentId'] as String,
      status: jsonSerialization['status'] as String?,
      simulatedAt: jsonSerialization['simulatedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['simulatedAt'],
            ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int campaignId;

  int sponsorshipId;

  _isc.UuidValue creatorAuthUserId;

  double amount;

  String sourcePaymentId;

  String status;

  DateTime simulatedAt;

  /// Returns a shallow copy of this [TestPayout]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  TestPayout copyWith({
    int? id,
    int? campaignId,
    int? sponsorshipId,
    _isc.UuidValue? creatorAuthUserId,
    double? amount,
    String? sourcePaymentId,
    String? status,
    DateTime? simulatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TestPayout',
      if (id != null) 'id': id,
      'campaignId': campaignId,
      'sponsorshipId': sponsorshipId,
      'creatorAuthUserId': creatorAuthUserId.toJson(),
      'amount': amount,
      'sourcePaymentId': sourcePaymentId,
      'status': status,
      'simulatedAt': simulatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'TestPayout',
      if (id != null) 'id': id,
      'campaignId': campaignId,
      'sponsorshipId': sponsorshipId,
      'creatorAuthUserId': creatorAuthUserId.toJson(),
      'amount': amount,
      'sourcePaymentId': sourcePaymentId,
      'status': status,
      'simulatedAt': simulatedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _TestPayoutImpl extends TestPayout {
  _TestPayoutImpl({
    int? id,
    required int campaignId,
    required int sponsorshipId,
    required _isc.UuidValue creatorAuthUserId,
    required double amount,
    required String sourcePaymentId,
    String? status,
    DateTime? simulatedAt,
  }) : super._(
         id: id,
         campaignId: campaignId,
         sponsorshipId: sponsorshipId,
         creatorAuthUserId: creatorAuthUserId,
         amount: amount,
         sourcePaymentId: sourcePaymentId,
         status: status,
         simulatedAt: simulatedAt,
       );

  /// Returns a shallow copy of this [TestPayout]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  TestPayout copyWith({
    Object? id = _Undefined,
    int? campaignId,
    int? sponsorshipId,
    _isc.UuidValue? creatorAuthUserId,
    double? amount,
    String? sourcePaymentId,
    String? status,
    DateTime? simulatedAt,
  }) {
    return TestPayout(
      id: id is int? ? id : this.id,
      campaignId: campaignId ?? this.campaignId,
      sponsorshipId: sponsorshipId ?? this.sponsorshipId,
      creatorAuthUserId: creatorAuthUserId ?? this.creatorAuthUserId,
      amount: amount ?? this.amount,
      sourcePaymentId: sourcePaymentId ?? this.sourcePaymentId,
      status: status ?? this.status,
      simulatedAt: simulatedAt ?? this.simulatedAt,
    );
  }
}
