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
    int? amountPaise,
    String? status,
    String? reason,
    bool? testMode,
    int? attempts,
    this.providerRefundId,
    this.lastError,
    this.nextAttemptAt,
    this.processedAt,
    this.fundingReversedAt,
    int? fundingReversedPaise,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : amountPaise = amountPaise ?? 0,
       status = status ?? 'pending',
       reason = reason ?? 'campaign_cancelled',
       testMode = testMode ?? true,
       attempts = attempts ?? 0,
       fundingReversedPaise = fundingReversedPaise ?? 0,
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory TestRefund({
    int? id,
    required int campaignId,
    required int sponsorshipId,
    required double amount,
    int? amountPaise,
    String? status,
    String? reason,
    bool? testMode,
    int? attempts,
    String? providerRefundId,
    String? lastError,
    DateTime? nextAttemptAt,
    DateTime? processedAt,
    DateTime? fundingReversedAt,
    int? fundingReversedPaise,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _TestRefundImpl;

  factory TestRefund.fromJson(Map<String, dynamic> jsonSerialization) {
    return TestRefund(
      id: jsonSerialization['id'] as int?,
      campaignId: jsonSerialization['campaignId'] as int,
      sponsorshipId: jsonSerialization['sponsorshipId'] as int,
      amount: (jsonSerialization['amount'] as num).toDouble(),
      amountPaise: jsonSerialization['amountPaise'] as int?,
      status: jsonSerialization['status'] as String?,
      reason: jsonSerialization['reason'] as String?,
      testMode: jsonSerialization['testMode'] == null
          ? null
          : _isc.BoolJsonExtension.fromJson(jsonSerialization['testMode']),
      attempts: jsonSerialization['attempts'] as int?,
      providerRefundId: jsonSerialization['providerRefundId'] as String?,
      lastError: jsonSerialization['lastError'] as String?,
      nextAttemptAt: jsonSerialization['nextAttemptAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['nextAttemptAt'],
            ),
      processedAt: jsonSerialization['processedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['processedAt'],
            ),
      fundingReversedAt: jsonSerialization['fundingReversedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['fundingReversedAt'],
            ),
      fundingReversedPaise: jsonSerialization['fundingReversedPaise'] as int?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int campaignId;

  int sponsorshipId;

  double amount;

  int amountPaise;

  String status;

  String reason;

  bool testMode;

  int attempts;

  String? providerRefundId;

  String? lastError;

  DateTime? nextAttemptAt;

  DateTime? processedAt;

  DateTime? fundingReversedAt;

  int fundingReversedPaise;

  DateTime createdAt;

  DateTime updatedAt;

  /// Returns a shallow copy of this [TestRefund]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  TestRefund copyWith({
    int? id,
    int? campaignId,
    int? sponsorshipId,
    double? amount,
    int? amountPaise,
    String? status,
    String? reason,
    bool? testMode,
    int? attempts,
    String? providerRefundId,
    String? lastError,
    DateTime? nextAttemptAt,
    DateTime? processedAt,
    DateTime? fundingReversedAt,
    int? fundingReversedPaise,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TestRefund',
      if (id != null) 'id': id,
      'campaignId': campaignId,
      'sponsorshipId': sponsorshipId,
      'amount': amount,
      'amountPaise': amountPaise,
      'status': status,
      'reason': reason,
      'testMode': testMode,
      'attempts': attempts,
      if (providerRefundId != null) 'providerRefundId': providerRefundId,
      if (lastError != null) 'lastError': lastError,
      if (nextAttemptAt != null) 'nextAttemptAt': nextAttemptAt?.toJson(),
      if (processedAt != null) 'processedAt': processedAt?.toJson(),
      if (fundingReversedAt != null)
        'fundingReversedAt': fundingReversedAt?.toJson(),
      'fundingReversedPaise': fundingReversedPaise,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
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
      'amountPaise': amountPaise,
      'status': status,
      'reason': reason,
      'testMode': testMode,
      'attempts': attempts,
      if (providerRefundId != null) 'providerRefundId': providerRefundId,
      if (lastError != null) 'lastError': lastError,
      if (nextAttemptAt != null) 'nextAttemptAt': nextAttemptAt?.toJson(),
      if (processedAt != null) 'processedAt': processedAt?.toJson(),
      if (fundingReversedAt != null)
        'fundingReversedAt': fundingReversedAt?.toJson(),
      'fundingReversedPaise': fundingReversedPaise,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
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
    int? amountPaise,
    String? status,
    String? reason,
    bool? testMode,
    int? attempts,
    String? providerRefundId,
    String? lastError,
    DateTime? nextAttemptAt,
    DateTime? processedAt,
    DateTime? fundingReversedAt,
    int? fundingReversedPaise,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         campaignId: campaignId,
         sponsorshipId: sponsorshipId,
         amount: amount,
         amountPaise: amountPaise,
         status: status,
         reason: reason,
         testMode: testMode,
         attempts: attempts,
         providerRefundId: providerRefundId,
         lastError: lastError,
         nextAttemptAt: nextAttemptAt,
         processedAt: processedAt,
         fundingReversedAt: fundingReversedAt,
         fundingReversedPaise: fundingReversedPaise,
         createdAt: createdAt,
         updatedAt: updatedAt,
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
    int? amountPaise,
    String? status,
    String? reason,
    bool? testMode,
    int? attempts,
    Object? providerRefundId = _Undefined,
    Object? lastError = _Undefined,
    Object? nextAttemptAt = _Undefined,
    Object? processedAt = _Undefined,
    Object? fundingReversedAt = _Undefined,
    int? fundingReversedPaise,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TestRefund(
      id: id is int? ? id : this.id,
      campaignId: campaignId ?? this.campaignId,
      sponsorshipId: sponsorshipId ?? this.sponsorshipId,
      amount: amount ?? this.amount,
      amountPaise: amountPaise ?? this.amountPaise,
      status: status ?? this.status,
      reason: reason ?? this.reason,
      testMode: testMode ?? this.testMode,
      attempts: attempts ?? this.attempts,
      providerRefundId: providerRefundId is String?
          ? providerRefundId
          : this.providerRefundId,
      lastError: lastError is String? ? lastError : this.lastError,
      nextAttemptAt: nextAttemptAt is DateTime?
          ? nextAttemptAt
          : this.nextAttemptAt,
      processedAt: processedAt is DateTime? ? processedAt : this.processedAt,
      fundingReversedAt: fundingReversedAt is DateTime?
          ? fundingReversedAt
          : this.fundingReversedAt,
      fundingReversedPaise: fundingReversedPaise ?? this.fundingReversedPaise,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
