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
    this.message,
    String? paymentProvider,
    String? paymentStatus,
    this.providerOrderId,
    this.providerPaymentId,
    this.verifiedAt,
    DateTime? createdAt,
  }) : paymentProvider = paymentProvider ?? 'razorpay',
       paymentStatus = paymentStatus ?? 'created',
       createdAt = createdAt ?? DateTime.now();

  factory Sponsorship({
    int? id,
    required int campaignId,
    required _isc.UuidValue sponsorAuthUserId,
    required double amount,
    String? message,
    String? paymentProvider,
    String? paymentStatus,
    String? providerOrderId,
    String? providerPaymentId,
    DateTime? verifiedAt,
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

  String? message;

  String paymentProvider;

  String paymentStatus;

  String? providerOrderId;

  String? providerPaymentId;

  DateTime? verifiedAt;

  DateTime createdAt;

  /// Returns a shallow copy of this [Sponsorship]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  Sponsorship copyWith({
    int? id,
    int? campaignId,
    _isc.UuidValue? sponsorAuthUserId,
    double? amount,
    String? message,
    String? paymentProvider,
    String? paymentStatus,
    String? providerOrderId,
    String? providerPaymentId,
    DateTime? verifiedAt,
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
      if (message != null) 'message': message,
      'paymentProvider': paymentProvider,
      'paymentStatus': paymentStatus,
      if (providerOrderId != null) 'providerOrderId': providerOrderId,
      if (providerPaymentId != null) 'providerPaymentId': providerPaymentId,
      if (verifiedAt != null) 'verifiedAt': verifiedAt?.toJson(),
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
      if (message != null) 'message': message,
      'paymentProvider': paymentProvider,
      'paymentStatus': paymentStatus,
      if (providerOrderId != null) 'providerOrderId': providerOrderId,
      if (providerPaymentId != null) 'providerPaymentId': providerPaymentId,
      if (verifiedAt != null) 'verifiedAt': verifiedAt?.toJson(),
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
    String? message,
    String? paymentProvider,
    String? paymentStatus,
    String? providerOrderId,
    String? providerPaymentId,
    DateTime? verifiedAt,
    DateTime? createdAt,
  }) : super._(
         id: id,
         campaignId: campaignId,
         sponsorAuthUserId: sponsorAuthUserId,
         amount: amount,
         message: message,
         paymentProvider: paymentProvider,
         paymentStatus: paymentStatus,
         providerOrderId: providerOrderId,
         providerPaymentId: providerPaymentId,
         verifiedAt: verifiedAt,
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
    Object? message = _Undefined,
    String? paymentProvider,
    String? paymentStatus,
    Object? providerOrderId = _Undefined,
    Object? providerPaymentId = _Undefined,
    Object? verifiedAt = _Undefined,
    DateTime? createdAt,
  }) {
    return Sponsorship(
      id: id is int? ? id : this.id,
      campaignId: campaignId ?? this.campaignId,
      sponsorAuthUserId: sponsorAuthUserId ?? this.sponsorAuthUserId,
      amount: amount ?? this.amount,
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
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
