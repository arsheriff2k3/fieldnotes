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

abstract class Sponsorship
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  Sponsorship._({
    this.id,
    required this.campaignId,
    required this.sponsorAuthUserId,
    required this.amount,
    int? amountPaise,
    this.message,
    String? paymentProvider,
    String? paymentStatus,
    this.providerOrderId,
    this.providerPaymentId,
    this.verifiedAt,
    this.failureReason,
    int? reconcileAttempts,
    this.lastReconciledAt,
    this.updatedAt,
    this.clientRequestId,
    DateTime? createdAt,
  }) : amountPaise = amountPaise ?? 0,
       paymentProvider = paymentProvider ?? 'razorpay',
       paymentStatus = paymentStatus ?? 'created',
       reconcileAttempts = reconcileAttempts ?? 0,
       createdAt = createdAt ?? DateTime.now();

  factory Sponsorship({
    int? id,
    required int campaignId,
    required _isc.UuidValue sponsorAuthUserId,
    required double amount,
    int? amountPaise,
    String? message,
    String? paymentProvider,
    String? paymentStatus,
    String? providerOrderId,
    String? providerPaymentId,
    DateTime? verifiedAt,
    String? failureReason,
    int? reconcileAttempts,
    DateTime? lastReconciledAt,
    DateTime? updatedAt,
    String? clientRequestId,
    DateTime? createdAt,
  }) = _SponsorshipImpl;

  factory Sponsorship.fromJson(Map<String, dynamic> jsonSerialization) {
    return Sponsorship(
      id: jsonSerialization['id'] as int?,
      campaignId: jsonSerialization['campaignId'] as int,
      sponsorAuthUserId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['sponsorAuthUserId'],
      ),
      amount: (jsonSerialization['amount'] as num).toDouble(),
      amountPaise: jsonSerialization['amountPaise'] as int?,
      message: jsonSerialization['message'] as String?,
      paymentProvider: jsonSerialization['paymentProvider'] as String?,
      paymentStatus: jsonSerialization['paymentStatus'] as String?,
      providerOrderId: jsonSerialization['providerOrderId'] as String?,
      providerPaymentId: jsonSerialization['providerPaymentId'] as String?,
      verifiedAt: jsonSerialization['verifiedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['verifiedAt'],
            ),
      failureReason: jsonSerialization['failureReason'] as String?,
      reconcileAttempts: jsonSerialization['reconcileAttempts'] as int?,
      lastReconciledAt: jsonSerialization['lastReconciledAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['lastReconciledAt'],
            ),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
      clientRequestId: jsonSerialization['clientRequestId'] as String?,
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

  _isc.UuidValue sponsorAuthUserId;

  double amount;

  int amountPaise;

  String? message;

  String paymentProvider;

  String paymentStatus;

  String? providerOrderId;

  String? providerPaymentId;

  DateTime? verifiedAt;

  String? failureReason;

  int reconcileAttempts;

  DateTime? lastReconciledAt;

  DateTime? updatedAt;

  String? clientRequestId;

  DateTime createdAt;

  /// Returns a shallow copy of this [Sponsorship]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  Sponsorship copyWith({
    int? id,
    int? campaignId,
    _isc.UuidValue? sponsorAuthUserId,
    double? amount,
    int? amountPaise,
    String? message,
    String? paymentProvider,
    String? paymentStatus,
    String? providerOrderId,
    String? providerPaymentId,
    DateTime? verifiedAt,
    String? failureReason,
    int? reconcileAttempts,
    DateTime? lastReconciledAt,
    DateTime? updatedAt,
    String? clientRequestId,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Sponsorship',
      if (id != null) 'id': id,
      'campaignId': campaignId,
      'sponsorAuthUserId': sponsorAuthUserId.toJson(),
      'amount': amount,
      'amountPaise': amountPaise,
      if (message != null) 'message': message,
      'paymentProvider': paymentProvider,
      'paymentStatus': paymentStatus,
      if (providerOrderId != null) 'providerOrderId': providerOrderId,
      if (providerPaymentId != null) 'providerPaymentId': providerPaymentId,
      if (verifiedAt != null) 'verifiedAt': verifiedAt?.toJson(),
      if (failureReason != null) 'failureReason': failureReason,
      'reconcileAttempts': reconcileAttempts,
      if (lastReconciledAt != null)
        'lastReconciledAt': lastReconciledAt?.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
      if (clientRequestId != null) 'clientRequestId': clientRequestId,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Sponsorship',
      if (id != null) 'id': id,
      'campaignId': campaignId,
      'sponsorAuthUserId': sponsorAuthUserId.toJson(),
      'amount': amount,
      'amountPaise': amountPaise,
      if (message != null) 'message': message,
      'paymentProvider': paymentProvider,
      'paymentStatus': paymentStatus,
      if (providerOrderId != null) 'providerOrderId': providerOrderId,
      if (providerPaymentId != null) 'providerPaymentId': providerPaymentId,
      if (verifiedAt != null) 'verifiedAt': verifiedAt?.toJson(),
      if (failureReason != null) 'failureReason': failureReason,
      'reconcileAttempts': reconcileAttempts,
      if (lastReconciledAt != null)
        'lastReconciledAt': lastReconciledAt?.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
      if (clientRequestId != null) 'clientRequestId': clientRequestId,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SponsorshipImpl extends Sponsorship {
  _SponsorshipImpl({
    int? id,
    required int campaignId,
    required _isc.UuidValue sponsorAuthUserId,
    required double amount,
    int? amountPaise,
    String? message,
    String? paymentProvider,
    String? paymentStatus,
    String? providerOrderId,
    String? providerPaymentId,
    DateTime? verifiedAt,
    String? failureReason,
    int? reconcileAttempts,
    DateTime? lastReconciledAt,
    DateTime? updatedAt,
    String? clientRequestId,
    DateTime? createdAt,
  }) : super._(
         id: id,
         campaignId: campaignId,
         sponsorAuthUserId: sponsorAuthUserId,
         amount: amount,
         amountPaise: amountPaise,
         message: message,
         paymentProvider: paymentProvider,
         paymentStatus: paymentStatus,
         providerOrderId: providerOrderId,
         providerPaymentId: providerPaymentId,
         verifiedAt: verifiedAt,
         failureReason: failureReason,
         reconcileAttempts: reconcileAttempts,
         lastReconciledAt: lastReconciledAt,
         updatedAt: updatedAt,
         clientRequestId: clientRequestId,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [Sponsorship]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  Sponsorship copyWith({
    Object? id = _Undefined,
    int? campaignId,
    _isc.UuidValue? sponsorAuthUserId,
    double? amount,
    int? amountPaise,
    Object? message = _Undefined,
    String? paymentProvider,
    String? paymentStatus,
    Object? providerOrderId = _Undefined,
    Object? providerPaymentId = _Undefined,
    Object? verifiedAt = _Undefined,
    Object? failureReason = _Undefined,
    int? reconcileAttempts,
    Object? lastReconciledAt = _Undefined,
    Object? updatedAt = _Undefined,
    Object? clientRequestId = _Undefined,
    DateTime? createdAt,
  }) {
    return Sponsorship(
      id: id is int? ? id : this.id,
      campaignId: campaignId ?? this.campaignId,
      sponsorAuthUserId: sponsorAuthUserId ?? this.sponsorAuthUserId,
      amount: amount ?? this.amount,
      amountPaise: amountPaise ?? this.amountPaise,
      message: message is String? ? message : this.message,
      paymentProvider: paymentProvider ?? this.paymentProvider,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      providerOrderId: providerOrderId is String?
          ? providerOrderId
          : this.providerOrderId,
      providerPaymentId: providerPaymentId is String?
          ? providerPaymentId
          : this.providerPaymentId,
      verifiedAt: verifiedAt is DateTime? ? verifiedAt : this.verifiedAt,
      failureReason: failureReason is String?
          ? failureReason
          : this.failureReason,
      reconcileAttempts: reconcileAttempts ?? this.reconcileAttempts,
      lastReconciledAt: lastReconciledAt is DateTime?
          ? lastReconciledAt
          : this.lastReconciledAt,
      updatedAt: updatedAt is DateTime? ? updatedAt : this.updatedAt,
      clientRequestId: clientRequestId is String?
          ? clientRequestId
          : this.clientRequestId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
