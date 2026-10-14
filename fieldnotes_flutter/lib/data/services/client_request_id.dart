import 'package:uuid/uuid.dart';

/// Server error codes for idempotency keys.
abstract final class ClientRequestErrors {
  /// A publish id was already used for a different campaign.
  static const reused = 'client_request_id_reused';

  /// The id failed the server's format check.
  static const invalid = 'invalid_client_request_id';

  /// A checkout id was already handled (paid, failed, or other amount).
  static const duplicatePayment = 'duplicate_payment_request';

  static const all = {reused, invalid, duplicatePayment};
}

/// Holds one idempotency key (UUID v4) for a single attempt-flow, such as
/// publishing one draft or opening one checkout.
///
/// [idFor] returns the same id for as long as the [fingerprint] of the
/// request is unchanged, so retries after a timeout or network error replay
/// the first request instead of duplicating it. A changed fingerprint (the
/// draft or amount was edited), [complete] (the request succeeded) or
/// [discard] (the server rejected the id) starts a new attempt with a new id.
class ClientRequestIdTracker {
  ClientRequestIdTracker({String Function()? generate})
    : _generate = generate ?? _uuidV4;

  static const _uuid = Uuid();
  static String _uuidV4() => _uuid.v4();

  final String Function() _generate;
  String? _id;
  Object? _fingerprint;

  /// The id in use, if an attempt is in flight.
  String? get current => _id;

  String idFor(Object fingerprint) {
    if (_id == null || _fingerprint != fingerprint) {
      _id = _generate();
      _fingerprint = fingerprint;
    }
    return _id!;
  }

  /// The request succeeded: the next attempt gets a new id.
  void complete() {
    _id = null;
    _fingerprint = null;
  }

  /// The server rejected the id; the next attempt gets a new one.
  void discard() => complete();
}
