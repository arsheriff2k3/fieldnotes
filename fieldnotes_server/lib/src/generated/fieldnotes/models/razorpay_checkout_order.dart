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
import 'package:serverpod/serverpod.dart' as _is;

abstract class RazorpayCheckoutOrder
    implements _is.SerializableModel, _is.ProtocolSerialization {
  RazorpayCheckoutOrder._({
    required this.sponsorshipId,
    required this.orderId,
    required this.keyId,
    required this.amountPaise,
    required this.currency,
    required this.campaignName,
    required this.description,
  });

  factory RazorpayCheckoutOrder({
    required int sponsorshipId,
    required String orderId,
    required String keyId,
    required int amountPaise,
    required String currency,
    required String campaignName,
    required String description,
  }) = _RazorpayCheckoutOrderImpl;

  factory RazorpayCheckoutOrder.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return RazorpayCheckoutOrder(
      sponsorshipId: jsonSerialization['sponsorshipId'] as int,
      orderId: jsonSerialization['orderId'] as String,
      keyId: jsonSerialization['keyId'] as String,
      amountPaise: jsonSerialization['amountPaise'] as int,
      currency: jsonSerialization['currency'] as String,
      campaignName: jsonSerialization['campaignName'] as String,
      description: jsonSerialization['description'] as String,
    );
  }

  int sponsorshipId;

  String orderId;

  String keyId;

  int amountPaise;

  String currency;

  String campaignName;

  String description;

  /// Returns a shallow copy of this [RazorpayCheckoutOrder]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  RazorpayCheckoutOrder copyWith({
    int? sponsorshipId,
    String? orderId,
    String? keyId,
    int? amountPaise,
    String? currency,
    String? campaignName,
    String? description,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RazorpayCheckoutOrder',
      'sponsorshipId': sponsorshipId,
      'orderId': orderId,
      'keyId': keyId,
      'amountPaise': amountPaise,
      'currency': currency,
      'campaignName': campaignName,
      'description': description,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'RazorpayCheckoutOrder',
      'sponsorshipId': sponsorshipId,
      'orderId': orderId,
      'keyId': keyId,
      'amountPaise': amountPaise,
      'currency': currency,
      'campaignName': campaignName,
      'description': description,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _RazorpayCheckoutOrderImpl extends RazorpayCheckoutOrder {
  _RazorpayCheckoutOrderImpl({
    required int sponsorshipId,
    required String orderId,
    required String keyId,
    required int amountPaise,
    required String currency,
    required String campaignName,
    required String description,
  }) : super._(
         sponsorshipId: sponsorshipId,
         orderId: orderId,
         keyId: keyId,
         amountPaise: amountPaise,
         currency: currency,
         campaignName: campaignName,
         description: description,
       );

  /// Returns a shallow copy of this [RazorpayCheckoutOrder]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  RazorpayCheckoutOrder copyWith({
    int? sponsorshipId,
    String? orderId,
    String? keyId,
    int? amountPaise,
    String? currency,
    String? campaignName,
    String? description,
  }) {
    return RazorpayCheckoutOrder(
      sponsorshipId: sponsorshipId ?? this.sponsorshipId,
      orderId: orderId ?? this.orderId,
      keyId: keyId ?? this.keyId,
      amountPaise: amountPaise ?? this.amountPaise,
      currency: currency ?? this.currency,
      campaignName: campaignName ?? this.campaignName,
      description: description ?? this.description,
    );
  }
}
