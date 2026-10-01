import 'dart:async';

import 'package:fieldnotes_client/fieldnotes_client.dart';

import '../../data/services/device_location_service.dart';

/// Shown when the server no longer accepts the saved session.
const sessionExpiredMessage = 'Your session expired, please sign in again.';

/// Shown when the server cannot be reached at all.
const offlineMessage = "Can't reach FieldNote. Check your connection.";

const _genericMessage = 'FieldNote could not complete that action. Try again.';

/// True when [error] means the saved session is no longer valid.
bool isUnauthorizedError(Object error) {
  if (error is ServerpodClientUnauthorized) return true;
  if (error is ServerpodClientHttpException && error.statusCode == 401) {
    return true;
  }
  return error is FieldnoteException && error.code == 'unauthenticated';
}

/// True when [error] means the request never reached the server.
bool isNetworkError(Object error) {
  if (error is TimeoutException) return true;
  if (error is ServerpodClientNetworkException) return true;
  if (error is ServerpodClientUnknownException) return true;
  // `dart:io` is unavailable on web, so the socket type is matched by name.
  final type = error.runtimeType.toString();
  return type == 'SocketException' ||
      type == 'HttpException' ||
      type == 'ClientException' ||
      type == 'HandshakeException';
}

/// Converts any error thrown by the repository, location service or client
/// into a sentence that can be shown to the user. [fallback] is used for
/// errors that carry no user-facing text.
String userMessageFor(Object error, {String? fallback}) {
  if (isUnauthorizedError(error)) return sessionExpiredMessage;
  if (error is FieldnoteException) return _fieldnoteMessage(error, fallback);
  if (error is LocationAccessException) return error.message;
  if (error is ServerpodClientForbidden) {
    return "You don't have access to that.";
  }
  if (error is ServerpodClientInternalServerError) {
    return fallback ?? 'FieldNote hit a problem on the server. Try again.';
  }
  if (isNetworkError(error) || error is ServerpodClientException) {
    return offlineMessage;
  }
  return fallback ?? _genericMessage;
}

String _fieldnoteMessage(FieldnoteException error, String? fallback) {
  final serverText = error.message.trim();
  final code = error.code;
  if (code == 'rate_limited') {
    final seconds = error.retryAfterSeconds;
    if (seconds == null || seconds <= 0) {
      return serverText.isEmpty
          ? 'Too many requests. Wait a moment and try again.'
          : serverText;
    }
    return 'Too many requests. Try again in ${_describeWait(seconds)}.';
  }
  if (serverText.isNotEmpty) return serverText;
  if (code.startsWith('deletion_blocked_')) {
    return _deletionBlocked[code] ??
        'Your account cannot be deleted yet. Resolve open campaigns or '
            'payments and try again.';
  }
  return _codeMessages[code] ?? fallback ?? _genericMessage;
}

String _describeWait(int seconds) {
  if (seconds < 60) return seconds == 1 ? '1 second' : '$seconds seconds';
  final minutes = (seconds / 60).ceil();
  if (minutes < 60) return minutes == 1 ? '1 minute' : '$minutes minutes';
  final hours = (minutes / 60).ceil();
  return hours == 1 ? '1 hour' : '$hours hours';
}

const _deletionBlocked = {
  'deletion_blocked_open_campaign':
      'Cancel or complete the campaigns you created before deleting your '
      'account.',
  'deletion_blocked_refund_pending':
      'A refund for one of your payments is still being processed. Try again '
      'once it completes.',
  'deletion_blocked_payment_pending':
      'One of your payments is still being confirmed. Try again once it '
      'settles.',
  'deletion_blocked_checked_in':
      'Finish or leave the campaign you are checked in to before deleting '
      'your account.',
};

/// Used only when the server sent a code without a message.
const _codeMessages = {
  'campaign_started': 'This campaign has already started.',
  'campaign_expired': 'This campaign has expired.',
  'campaign_not_completed': 'This is available once the campaign completes.',
  'campaign_full': 'This campaign is already full.',
  'campaign_closed': 'This campaign is closed.',
  'campaign_unavailable': 'This campaign is no longer available.',
  'campaign_not_found': 'This campaign could not be found.',
  'payouts_exist':
      'A creator payout was already recorded, so this campaign cannot be '
      'changed.',
  'invalid_funding_goal': 'Enter a valid funding goal.',
  'invalid_duration': 'Enter a valid campaign duration.',
  'invalid_capacity': 'Enter a valid volunteer capacity.',
  'input_too_long': 'That text is too long. Shorten it and try again.',
  'invalid_input': 'Some of the details are invalid. Check them and try again.',
  'forbidden': "You don't have access to that.",
  'consent_required': 'Accept the current consent to continue.',
};
