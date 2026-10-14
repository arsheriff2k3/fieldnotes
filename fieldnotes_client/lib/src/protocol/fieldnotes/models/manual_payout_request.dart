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

abstract class ManualPayoutRequest
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  ManualPayoutRequest._({
    this.id,
    required this.campaignId,
    required this.creatorAuthUserId,
    required this.clientRequestId,
    required this.sponsorshipIds,
    required this.grossAmountPaise,
    int? deductionPaise,
    required this.amountPaise,
    String? status,
    DateTime? requestedAt,
    DateTime? updatedAt,
    this.reviewedByAuthUserId,
    this.reviewedAt,
    this.settlementReference,
    this.payeeVerificationReference,
    this.reviewNote,
    this.bankTransferReference,
    this.paidAt,
  }) : deductionPaise = deductionPaise ?? 0,
       status = status ?? 'requested',
       requestedAt = requestedAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory ManualPayoutRequest({
    int? id,
    required int campaignId,
    required _isc.UuidValue creatorAuthUserId,
    required String clientRequestId,
    required List<int> sponsorshipIds,
    required int grossAmountPaise,
    int? deductionPaise,
    required int amountPaise,
    String? status,
    DateTime? requestedAt,
    DateTime? updatedAt,
    _isc.UuidValue? reviewedByAuthUserId,
    DateTime? reviewedAt,
    String? settlementReference,
    String? payeeVerificationReference,
    String? reviewNote,
    String? bankTransferReference,
    DateTime? paidAt,
  }) = _ManualPayoutRequestImpl;

  factory ManualPayoutRequest.fromJson(Map<String, dynamic> jsonSerialization) {
    return ManualPayoutRequest(
      id: jsonSerialization['id'] as int?,
      campaignId: jsonSerialization['campaignId'] as int,
      creatorAuthUserId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['creatorAuthUserId'],
      ),
      clientRequestId: jsonSerialization['clientRequestId'] as String,
      sponsorshipIds: _imuhbzep.Protocol().deserialize<List<int>>(
        jsonSerialization['sponsorshipIds'],
      ),
      grossAmountPaise: jsonSerialization['grossAmountPaise'] as int,
      deductionPaise: jsonSerialization['deductionPaise'] as int?,
      amountPaise: jsonSerialization['amountPaise'] as int,
      status: jsonSerialization['status'] as String?,
      requestedAt: jsonSerialization['requestedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['requestedAt'],
            ),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
      reviewedByAuthUserId: jsonSerialization['reviewedByAuthUserId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(
              jsonSerialization['reviewedByAuthUserId'],
            ),
      reviewedAt: jsonSerialization['reviewedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['reviewedAt'],
            ),
      settlementReference: jsonSerialization['settlementReference'] as String?,
      payeeVerificationReference:
          jsonSerialization['payeeVerificationReference'] as String?,
      reviewNote: jsonSerialization['reviewNote'] as String?,
      bankTransferReference:
          jsonSerialization['bankTransferReference'] as String?,
      paidAt: jsonSerialization['paidAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['paidAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int campaignId;

  _isc.UuidValue creatorAuthUserId;

  String clientRequestId;

  List<int> sponsorshipIds;

  int grossAmountPaise;

  int deductionPaise;

  int amountPaise;

  String status;

  DateTime requestedAt;

  DateTime updatedAt;

  _isc.UuidValue? reviewedByAuthUserId;

  DateTime? reviewedAt;

  String? settlementReference;

  String? payeeVerificationReference;

  String? reviewNote;

  String? bankTransferReference;

  DateTime? paidAt;

  /// Returns a shallow copy of this [ManualPayoutRequest]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  ManualPayoutRequest copyWith({
    int? id,
    int? campaignId,
    _isc.UuidValue? creatorAuthUserId,
    String? clientRequestId,
    List<int>? sponsorshipIds,
    int? grossAmountPaise,
    int? deductionPaise,
    int? amountPaise,
    String? status,
    DateTime? requestedAt,
    DateTime? updatedAt,
    _isc.UuidValue? reviewedByAuthUserId,
    DateTime? reviewedAt,
    String? settlementReference,
    String? payeeVerificationReference,
    String? reviewNote,
    String? bankTransferReference,
    DateTime? paidAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ManualPayoutRequest',
      if (id != null) 'id': id,
      'campaignId': campaignId,
      'creatorAuthUserId': creatorAuthUserId.toJson(),
      'clientRequestId': clientRequestId,
      'sponsorshipIds': sponsorshipIds.toJson(),
      'grossAmountPaise': grossAmountPaise,
      'deductionPaise': deductionPaise,
      'amountPaise': amountPaise,
      'status': status,
      'requestedAt': requestedAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      if (reviewedByAuthUserId != null)
        'reviewedByAuthUserId': reviewedByAuthUserId?.toJson(),
      if (reviewedAt != null) 'reviewedAt': reviewedAt?.toJson(),
      if (settlementReference != null)
        'settlementReference': settlementReference,
      if (payeeVerificationReference != null)
        'payeeVerificationReference': payeeVerificationReference,
      if (reviewNote != null) 'reviewNote': reviewNote,
      if (bankTransferReference != null)
        'bankTransferReference': bankTransferReference,
      if (paidAt != null) 'paidAt': paidAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ManualPayoutRequest',
      if (id != null) 'id': id,
      'campaignId': campaignId,
      'creatorAuthUserId': creatorAuthUserId.toJson(),
      'clientRequestId': clientRequestId,
      'sponsorshipIds': sponsorshipIds.toJson(),
      'grossAmountPaise': grossAmountPaise,
      'deductionPaise': deductionPaise,
      'amountPaise': amountPaise,
      'status': status,
      'requestedAt': requestedAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      if (reviewedByAuthUserId != null)
        'reviewedByAuthUserId': reviewedByAuthUserId?.toJson(),
      if (reviewedAt != null) 'reviewedAt': reviewedAt?.toJson(),
      if (settlementReference != null)
        'settlementReference': settlementReference,
      if (payeeVerificationReference != null)
        'payeeVerificationReference': payeeVerificationReference,
      if (reviewNote != null) 'reviewNote': reviewNote,
      if (bankTransferReference != null)
        'bankTransferReference': bankTransferReference,
      if (paidAt != null) 'paidAt': paidAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ManualPayoutRequestImpl extends ManualPayoutRequest {
  _ManualPayoutRequestImpl({
    int? id,
    required int campaignId,
    required _isc.UuidValue creatorAuthUserId,
    required String clientRequestId,
    required List<int> sponsorshipIds,
    required int grossAmountPaise,
    int? deductionPaise,
    required int amountPaise,
    String? status,
    DateTime? requestedAt,
    DateTime? updatedAt,
    _isc.UuidValue? reviewedByAuthUserId,
    DateTime? reviewedAt,
    String? settlementReference,
    String? payeeVerificationReference,
    String? reviewNote,
    String? bankTransferReference,
    DateTime? paidAt,
  }) : super._(
         id: id,
         campaignId: campaignId,
         creatorAuthUserId: creatorAuthUserId,
         clientRequestId: clientRequestId,
         sponsorshipIds: sponsorshipIds,
         grossAmountPaise: grossAmountPaise,
         deductionPaise: deductionPaise,
         amountPaise: amountPaise,
         status: status,
         requestedAt: requestedAt,
         updatedAt: updatedAt,
         reviewedByAuthUserId: reviewedByAuthUserId,
         reviewedAt: reviewedAt,
         settlementReference: settlementReference,
         payeeVerificationReference: payeeVerificationReference,
         reviewNote: reviewNote,
         bankTransferReference: bankTransferReference,
         paidAt: paidAt,
       );

  /// Returns a shallow copy of this [ManualPayoutRequest]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  ManualPayoutRequest copyWith({
    Object? id = _Undefined,
    int? campaignId,
    _isc.UuidValue? creatorAuthUserId,
    String? clientRequestId,
    List<int>? sponsorshipIds,
    int? grossAmountPaise,
    int? deductionPaise,
    int? amountPaise,
    String? status,
    DateTime? requestedAt,
    DateTime? updatedAt,
    Object? reviewedByAuthUserId = _Undefined,
    Object? reviewedAt = _Undefined,
    Object? settlementReference = _Undefined,
    Object? payeeVerificationReference = _Undefined,
    Object? reviewNote = _Undefined,
    Object? bankTransferReference = _Undefined,
    Object? paidAt = _Undefined,
  }) {
    return ManualPayoutRequest(
      id: id is int? ? id : this.id,
      campaignId: campaignId ?? this.campaignId,
      creatorAuthUserId: creatorAuthUserId ?? this.creatorAuthUserId,
      clientRequestId: clientRequestId ?? this.clientRequestId,
      sponsorshipIds:
          sponsorshipIds ?? this.sponsorshipIds.map((e0) => e0).toList(),
      grossAmountPaise: grossAmountPaise ?? this.grossAmountPaise,
      deductionPaise: deductionPaise ?? this.deductionPaise,
      amountPaise: amountPaise ?? this.amountPaise,
      status: status ?? this.status,
      requestedAt: requestedAt ?? this.requestedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      reviewedByAuthUserId: reviewedByAuthUserId is _isc.UuidValue?
          ? reviewedByAuthUserId
          : this.reviewedByAuthUserId,
      reviewedAt: reviewedAt is DateTime? ? reviewedAt : this.reviewedAt,
      settlementReference: settlementReference is String?
          ? settlementReference
          : this.settlementReference,
      payeeVerificationReference: payeeVerificationReference is String?
          ? payeeVerificationReference
          : this.payeeVerificationReference,
      reviewNote: reviewNote is String? ? reviewNote : this.reviewNote,
      bankTransferReference: bankTransferReference is String?
          ? bankTransferReference
          : this.bankTransferReference,
      paidAt: paidAt is DateTime? ? paidAt : this.paidAt,
    );
  }
}
