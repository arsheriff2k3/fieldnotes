import 'dart:async';

import 'package:fieldnotes_client/fieldnotes_client.dart';
import 'package:fieldnotes_flutter/data/services/device_location_service.dart';
import 'package:fieldnotes_flutter/l10n/app_localizations.dart';
import 'package:fieldnotes_flutter/ui/core/error_messages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

final _en = lookupAppLocalizations(const Locale('en'));
final _hi = lookupAppLocalizations(const Locale('hi'));
final _ta = lookupAppLocalizations(const Locale('ta'));

FieldnoteException _code(String code, [String message = '']) =>
    FieldnoteException(message: message, code: code);

void main() {
  group('context-free (English)', () {
    test('rate limits use retryAfterSeconds', () {
      final error = FieldnoteException(
        message: 'Too many requests.',
        code: 'rate_limited',
        retryAfterSeconds: 90,
      );
      expect(
        userMessageFor(error),
        'Too many requests. Try again in 2 minutes.',
      );
      expect(
        userMessageFor(
          FieldnoteException(
            message: '',
            code: 'rate_limited',
            retryAfterSeconds: 1,
          ),
        ),
        'Too many requests. Try again in 1 second.',
      );
      expect(
        userMessageFor(_code('rate_limited')),
        'Too many requests. Wait a moment and try again.',
      );
    });

    test('server text wins; code text fills an empty message', () {
      expect(userMessageFor(_code('x', 'Full.')), 'Full.');
      expect(
        userMessageFor(_code('deletion_blocked_checked_in')),
        contains('checked in'),
      );
      expect(
        userMessageFor(_code('deletion_blocked_something_new')),
        startsWith('Your account cannot be deleted yet.'),
      );
      expect(
        userMessageFor(_code('campaign_expired', ' ')),
        'This campaign has expired.',
      );
      expect(
        userMessageFor(_code('payouts_manual')),
        'Payouts are settled manually by FieldNote operations.',
      );
      expect(
        userMessageFor(_code('invalid_whatever')),
        startsWith('Some of the details are invalid.'),
      );
      expect(userMessageFor(_code('unknown_code'), fallback: 'Nope.'), 'Nope.');
    });

    test('every listed code has a sentence', () {
      for (final code in [
        'campaign_started',
        'payouts_exist',
        'campaign_not_completed',
        'invalid_timezone',
        'input_too_long',
        'client_request_id_reused',
        'duplicate_payment_request',
        'forbidden',
        'upload_failed',
        'deletion_blocked_open_campaign',
        'deletion_blocked_refund_pending',
        'deletion_blocked_payment_pending',
      ]) {
        final message = userMessageFor(_code(code), fallback: 'FALLBACK');
        expect(message, isNot('FALLBACK'), reason: code);
        expect(message, isNotEmpty, reason: code);
      }
    });

    test('session, network and location errors', () {
      expect(
        userMessageFor(ServerpodClientUnauthorized()),
        sessionExpiredMessage,
      );
      expect(isUnauthorizedError(ServerpodClientUnauthorized()), isTrue);
      expect(userMessageFor(TimeoutException('slow')), offlineMessage);
      expect(
        userMessageFor(const ServerpodClientNetworkException('down')),
        offlineMessage,
      );
      expect(
        userMessageFor(
          const LocationAccessException(
            LocationAccessIssue.permissionDenied,
            'Allow location access.',
          ),
        ),
        'Allow location access.',
      );
      expect(userMessageFor(StateError('x'), fallback: 'Nope.'), 'Nope.');
    });

    test('constants match the English ARB strings', () {
      expect(_en.coreErrorSessionExpired, sessionExpiredMessage);
      expect(_en.coreErrorOffline, offlineMessage);
    });

    test('errors classify into kinds with parameters', () {
      final error = UserError.from(
        FieldnoteException(
          message: 'Slow down',
          code: 'rate_limited',
          retryAfterSeconds: 30,
        ),
      );
      expect(error.kind, UserErrorKind.server);
      expect(error.code, 'rate_limited');
      expect(error.retryAfterSeconds, 30);
      expect(error.serverMessage, 'Slow down');
      expect(
        UserError.from(TimeoutException('x')).kind,
        UserErrorKind.offline,
      );
      expect(
        UserError.from(
          const LocationAccessException(LocationAccessIssue.timedOut, 'x'),
        ).locationIssue,
        LocationAccessIssue.timedOut,
      );
    });
  });

  group('localized', () {
    test('Hindi words known codes instead of English server text', () {
      expect(
        UserError.from(
          _code('campaign_full', 'This campaign is already full.'),
        ).messageIn(_hi),
        _hi.coreErrorCampaignFull,
      );
      expect(
        UserError.from(ServerpodClientUnauthorized()).messageIn(_hi),
        _hi.coreErrorSessionExpired,
      );
      expect(
        UserError.from(TimeoutException('x')).messageIn(_hi),
        _hi.coreErrorOffline,
      );
      expect(_hi.coreErrorOffline, isNot(offlineMessage));
    });

    test('unknown codes keep the server text; English keeps server text', () {
      expect(
        UserError.from(_code('something_new', 'Server says.')).messageIn(_hi),
        'Server says.',
      );
      expect(
        UserError.from(_code('campaign_full', 'Only 0 left.')).messageIn(_en),
        'Only 0 left.',
      );
    });

    test('rate limit wait and location issues are localized', () {
      final hiMessage = UserError.from(
        FieldnoteException(
          message: '',
          code: 'rate_limited',
          retryAfterSeconds: 120,
        ),
      ).messageIn(_ta);
      expect(hiMessage, _ta.coreErrorRateLimitedWait(_ta.coreWaitMinutes(2)));
      expect(
        UserError.from(
          const LocationAccessException(
            LocationAccessIssue.serviceDisabled,
            'Location is off (English).',
          ),
        ).messageIn(_hi),
        _hi.coreLocationServiceDisabled,
      );
    });

    testWidgets('userMessageFor uses the context locale', (tester) async {
      late String message;
      late String stored;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('hi'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              message = userMessageFor(
                _code('campaign_expired', 'This campaign has expired.'),
                context: context,
              );
              stored = localizeStoredMessage(context, offlineMessage);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(message, _hi.coreErrorCampaignExpired);
      expect(stored, _hi.coreErrorOffline);
    });
  });
}
