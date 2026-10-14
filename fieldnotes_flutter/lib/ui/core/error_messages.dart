import 'dart:async';

import 'package:fieldnotes_client/fieldnotes_client.dart';
import 'package:flutter/widgets.dart';

import '../../data/services/device_location_service.dart';
import '../../l10n/l10n.dart';

/// Shown when the server no longer accepts the saved session.
///
/// Kept as a constant because view models compare messages by value. It is
/// identical to the English `coreErrorSessionExpired` ARB string.
const sessionExpiredMessage = 'Your session expired, please sign in again.';

/// Shown when the server cannot be reached at all. Identical to the English
/// `coreErrorOffline` ARB string.
const offlineMessage = "Can't reach FieldNote. Check your connection.";

/// What went wrong, independent of language.
enum UserErrorKind {
  /// The saved session is no longer valid.
  sessionExpired,

  /// The request never reached the server.
  offline,

  /// The server refused access.
  forbidden,

  /// The server failed with an internal error.
  serverError,

  /// A [FieldnoteException] (see [UserError.code]).
  server,

  /// The device location could not be used (see [UserError.locationIssue]).
  location,

  /// Anything else; the caller's fallback (or a generic sentence) is shown.
  unknown,
}

/// A user-facing error reduced to a kind plus the parameters needed to word
/// it in any locale.
@immutable
class UserError {
  const UserError({
    required this.kind,
    this.code,
    this.serverMessage,
    this.retryAfterSeconds,
    this.locationIssue,
  });

  /// Classifies any error thrown by the repository, location service or
  /// client.
  factory UserError.from(Object error) {
    if (isUnauthorizedError(error)) {
      return const UserError(kind: UserErrorKind.sessionExpired);
    }
    if (error is FieldnoteException) {
      final text = error.message.trim();
      return UserError(
        kind: UserErrorKind.server,
        code: error.code,
        serverMessage: text.isEmpty ? null : text,
        retryAfterSeconds: error.retryAfterSeconds,
      );
    }
    if (error is LocationAccessException) {
      final text = error.message.trim();
      return UserError(
        kind: UserErrorKind.location,
        locationIssue: error.issue,
        serverMessage: text.isEmpty ? null : text,
      );
    }
    if (error is ServerpodClientForbidden) {
      return const UserError(kind: UserErrorKind.forbidden);
    }
    if (error is ServerpodClientInternalServerError) {
      return const UserError(kind: UserErrorKind.serverError);
    }
    if (isNetworkError(error) || error is ServerpodClientException) {
      return const UserError(kind: UserErrorKind.offline);
    }
    return const UserError(kind: UserErrorKind.unknown);
  }

  final UserErrorKind kind;

  /// The server error code (`rate_limited`, `deletion_blocked_*`, …) for
  /// [UserErrorKind.server].
  final String? code;

  /// The English text the server (or location service) sent, if any.
  final String? serverMessage;

  /// Seconds until a `rate_limited` request may be retried.
  final int? retryAfterSeconds;

  /// Why the device location was unavailable, for [UserErrorKind.location].
  final LocationAccessIssue? locationIssue;

  /// The English sentence. [fallback] is used for errors that carry no
  /// user-facing text.
  String message({String? fallback}) => messageIn(_english, fallback: fallback);

  /// The sentence in the locale of [context]. [fallback] should already be
  /// localized by the caller.
  String localizedMessage(BuildContext context, {String? fallback}) =>
      messageIn(context.l10n, fallback: fallback);

  /// The sentence in [l10n]'s locale.
  ///
  /// In English, text sent by the server wins because it is the most
  /// specific. In other locales a known code is worded from the ARB files
  /// and the (English) server text is used only for unknown codes.
  String messageIn(AppLocalizations l10n, {String? fallback}) {
    final english = l10n.localeName.startsWith('en');
    switch (kind) {
      case UserErrorKind.sessionExpired:
        return english ? sessionExpiredMessage : l10n.coreErrorSessionExpired;
      case UserErrorKind.offline:
        return english ? offlineMessage : l10n.coreErrorOffline;
      case UserErrorKind.forbidden:
        return l10n.coreErrorForbidden;
      case UserErrorKind.serverError:
        return fallback ?? l10n.coreErrorServer;
      case UserErrorKind.location:
        final text = serverMessage;
        if (english && text != null) return text;
        return _locationMessage(l10n, locationIssue) ??
            text ??
            fallback ??
            l10n.coreErrorGeneric;
      case UserErrorKind.server:
        return _serverMessage(l10n, english, fallback);
      case UserErrorKind.unknown:
        return fallback ?? l10n.coreErrorGeneric;
    }
  }

  String _serverMessage(AppLocalizations l10n, bool english, String? fallback) {
    final code = this.code ?? '';
    final text = serverMessage;
    if (code == 'rate_limited') {
      final seconds = retryAfterSeconds;
      if (seconds != null && seconds > 0) {
        return l10n.coreErrorRateLimitedWait(describeWait(l10n, seconds));
      }
      if (english && text != null) return text;
      return l10n.coreErrorRateLimited;
    }
    if (english && text != null) return text;
    final known = _codeMessage(l10n, code);
    if (known != null) return known;
    return text ?? fallback ?? l10n.coreErrorGeneric;
  }

  @override
  bool operator ==(Object other) =>
      other is UserError &&
      other.kind == kind &&
      other.code == code &&
      other.serverMessage == serverMessage &&
      other.retryAfterSeconds == retryAfterSeconds &&
      other.locationIssue == locationIssue;

  @override
  int get hashCode =>
      Object.hash(kind, code, serverMessage, retryAfterSeconds, locationIssue);

  @override
  String toString() => 'UserError($kind, code: $code)';
}

final _english = lookupAppLocalizations(const Locale('en'));

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
///
/// Without [context] the sentence is English (view models store these and
/// compare them with [sessionExpiredMessage] / [offlineMessage]). With a
/// [context] it is worded in the current locale; pass a localized
/// [fallback] then.
String userMessageFor(
  Object error, {
  String? fallback,
  BuildContext? context,
}) {
  final value = UserError.from(error);
  return context == null
      ? value.message(fallback: fallback)
      : value.localizedMessage(context, fallback: fallback);
}

/// Re-words a message that was produced without a context (e.g. stored by a
/// view model) when it is one of the known constants; any other text is
/// returned unchanged.
String localizeStoredMessage(BuildContext context, String message) {
  final l10n = context.l10n;
  if (message == sessionExpiredMessage) return l10n.coreErrorSessionExpired;
  if (message == offlineMessage) return l10n.coreErrorOffline;
  return message;
}

/// "2 minutes", "1 hour", … for a retry delay.
String describeWait(AppLocalizations l10n, int seconds) {
  if (seconds < 60) return l10n.coreWaitSeconds(seconds);
  final minutes = (seconds / 60).ceil();
  if (minutes < 60) return l10n.coreWaitMinutes(minutes);
  return l10n.coreWaitHours((minutes / 60).ceil());
}

String? _locationMessage(AppLocalizations l10n, LocationAccessIssue? issue) =>
    switch (issue) {
      LocationAccessIssue.serviceDisabled => l10n.coreLocationServiceDisabled,
      LocationAccessIssue.permissionDenied => l10n.coreLocationPermissionDenied,
      LocationAccessIssue.permissionDeniedForever =>
        l10n.coreLocationPermissionBlocked,
      LocationAccessIssue.timedOut => l10n.coreLocationTimedOut,
      LocationAccessIssue.unavailable => l10n.coreLocationUnavailable,
      null => null,
    };

/// Wording for server codes. In English it is used only when the server sent
/// a code without a message.
String? _codeMessage(AppLocalizations l10n, String code) {
  final known = switch (code) {
    'deletion_blocked_open_campaign' => l10n.coreErrorDeletionOpenCampaign,
    'deletion_blocked_refund_pending' => l10n.coreErrorDeletionRefundPending,
    'deletion_blocked_payment_pending' => l10n.coreErrorDeletionPaymentPending,
    'deletion_blocked_checked_in' => l10n.coreErrorDeletionCheckedIn,
    'campaign_started' => l10n.coreErrorCampaignStarted,
    'campaign_expired' => l10n.coreErrorCampaignExpired,
    'campaign_not_completed' => l10n.coreErrorCampaignNotCompleted,
    'campaign_full' => l10n.coreErrorCampaignFull,
    'campaign_closed' => l10n.coreErrorCampaignClosed,
    'campaign_unavailable' => l10n.coreErrorCampaignUnavailable,
    'campaign_not_found' => l10n.coreErrorCampaignNotFound,
    'campaign_not_confirmed' => l10n.coreErrorCampaignNotConfirmed,
    'payouts_exist' => l10n.coreErrorPayoutsExist,
    'payouts_manual' => l10n.coreErrorPayoutsManual,
    'invalid_funding_goal' => l10n.coreErrorInvalidFundingGoal,
    'invalid_duration' => l10n.coreErrorInvalidDuration,
    'invalid_capacity' => l10n.coreErrorInvalidCapacity,
    'invalid_amount' => l10n.coreErrorInvalidAmount,
    'invalid_campaign_date' => l10n.coreErrorInvalidCampaignDate,
    'invalid_availability' => l10n.coreErrorInvalidAvailability,
    'invalid_contact_phone' => l10n.coreErrorInvalidContactPhone,
    'invalid_location' ||
    'invalid_coordinates' => l10n.coreErrorInvalidLocation,
    'invalid_summary' => l10n.coreErrorInvalidSummary,
    'invalid_photograph' => l10n.coreErrorInvalidPhotograph,
    'invalid_timezone' => l10n.coreErrorInvalidTimezone,
    'input_too_long' => l10n.coreErrorInputTooLong,
    'client_request_id_reused' => l10n.coreErrorClientRequestIdReused,
    'duplicate_payment_request' => l10n.coreErrorDuplicatePaymentRequest,
    'forbidden' => l10n.coreErrorForbidden,
    'consent_required' => l10n.coreErrorConsentRequired,
    'upload_failed' => l10n.coreErrorUploadFailed,
    'photo_required' => l10n.coreErrorPhotoRequired,
    'outside_geofence' => l10n.coreErrorOutsideGeofence,
    'check_in_window_closed' => l10n.coreErrorCheckInWindow,
    'completion_window_closed' => l10n.coreErrorCompletionWindowClosed,
    'join_required' => l10n.coreErrorJoinRequired,
    'check_in_required' => l10n.coreErrorCheckInRequired,
    'ai_unavailable' || 'ai_not_configured' => l10n.coreErrorAiUnavailable,
    _ => null,
  };
  if (known != null) return known;
  if (code.startsWith('deletion_blocked_')) {
    return l10n.coreErrorDeletionBlocked;
  }
  if (code.startsWith('invalid_')) return l10n.coreErrorInvalidInput;
  return null;
}
