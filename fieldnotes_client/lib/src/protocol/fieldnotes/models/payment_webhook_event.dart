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

abstract class PaymentWebhookEvent
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  PaymentWebhookEvent._({
    this.id,
    String? provider,
    required this.eventId,
    required this.eventType,
    required this.payloadSha256,
    String? status,
    this.detail,
    int? attempts,
    DateTime? receivedAt,
    this.processedAt,
  }) : provider = provider ?? 'razorpay',
       status = status ?? 'received',
       attempts = attempts ?? 1,
       receivedAt = receivedAt ?? DateTime.now();

  factory PaymentWebhookEvent({
    int? id,
    String? provider,
    required String eventId,
    required String eventType,
    required String payloadSha256,
    String? status,
    String? detail,
    int? attempts,
    DateTime? receivedAt,
    DateTime? processedAt,
  }) = _PaymentWebhookEventImpl;

  factory PaymentWebhookEvent.fromJson(Map<String, dynamic> jsonSerialization) {
    return PaymentWebhookEvent(
      id: jsonSerialization['id'] as int?,
      provider: jsonSerialization['provider'] as String?,
      eventId: jsonSerialization['eventId'] as String,
      eventType: jsonSerialization['eventType'] as String,
      payloadSha256: jsonSerialization['payloadSha256'] as String,
      status: jsonSerialization['status'] as String?,
      detail: jsonSerialization['detail'] as String?,
      attempts: jsonSerialization['attempts'] as int?,
      receivedAt: jsonSerialization['receivedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['receivedAt'],
            ),
      processedAt: jsonSerialization['processedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['processedAt'],
            ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String provider;

  String eventId;

  String eventType;

  String payloadSha256;

  String status;

  String? detail;

  int attempts;

  DateTime receivedAt;

  DateTime? processedAt;

  /// Returns a shallow copy of this [PaymentWebhookEvent]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  PaymentWebhookEvent copyWith({
    int? id,
    String? provider,
    String? eventId,
    String? eventType,
    String? payloadSha256,
    String? status,
    String? detail,
    int? attempts,
    DateTime? receivedAt,
    DateTime? processedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PaymentWebhookEvent',
      if (id != null) 'id': id,
      'provider': provider,
      'eventId': eventId,
      'eventType': eventType,
      'payloadSha256': payloadSha256,
      'status': status,
      if (detail != null) 'detail': detail,
      'attempts': attempts,
      'receivedAt': receivedAt.toJson(),
      if (processedAt != null) 'processedAt': processedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'PaymentWebhookEvent',
      if (id != null) 'id': id,
      'provider': provider,
      'eventId': eventId,
      'eventType': eventType,
      'payloadSha256': payloadSha256,
      'status': status,
      if (detail != null) 'detail': detail,
      'attempts': attempts,
      'receivedAt': receivedAt.toJson(),
      if (processedAt != null) 'processedAt': processedAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PaymentWebhookEventImpl extends PaymentWebhookEvent {
  _PaymentWebhookEventImpl({
    int? id,
    String? provider,
    required String eventId,
    required String eventType,
    required String payloadSha256,
    String? status,
    String? detail,
    int? attempts,
    DateTime? receivedAt,
    DateTime? processedAt,
  }) : super._(
         id: id,
         provider: provider,
         eventId: eventId,
         eventType: eventType,
         payloadSha256: payloadSha256,
         status: status,
         detail: detail,
         attempts: attempts,
         receivedAt: receivedAt,
         processedAt: processedAt,
       );

  /// Returns a shallow copy of this [PaymentWebhookEvent]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  PaymentWebhookEvent copyWith({
    Object? id = _Undefined,
    String? provider,
    String? eventId,
    String? eventType,
    String? payloadSha256,
    String? status,
    Object? detail = _Undefined,
    int? attempts,
    DateTime? receivedAt,
    Object? processedAt = _Undefined,
  }) {
    return PaymentWebhookEvent(
      id: id is int? ? id : this.id,
      provider: provider ?? this.provider,
      eventId: eventId ?? this.eventId,
      eventType: eventType ?? this.eventType,
      payloadSha256: payloadSha256 ?? this.payloadSha256,
      status: status ?? this.status,
      detail: detail is String? ? detail : this.detail,
      attempts: attempts ?? this.attempts,
      receivedAt: receivedAt ?? this.receivedAt,
      processedAt: processedAt is DateTime? ? processedAt : this.processedAt,
    );
  }
}
