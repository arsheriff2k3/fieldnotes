import 'dart:async';

import 'package:fieldnotes_client/fieldnotes_client.dart';
import 'package:fieldnotes_flutter/data/services/device_location_service.dart';
import 'package:fieldnotes_flutter/ui/core/error_messages.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('rate limits use retryAfterSeconds', () {
    final error = FieldnoteException(
      message: 'Too many requests.',
      code: 'rate_limited',
      retryAfterSeconds: 90,
    );
    expect(userMessageFor(error), 'Too many requests. Try again in 2 minutes.');
  });

  test('server text wins; code text fills an empty message', () {
    expect(
      userMessageFor(FieldnoteException(message: 'Full.', code: 'x')),
      'Full.',
    );
    expect(
      userMessageFor(
        FieldnoteException(message: '', code: 'deletion_blocked_checked_in'),
      ),
      contains('checked in'),
    );
    expect(
      userMessageFor(
        FieldnoteException(message: ' ', code: 'campaign_expired'),
      ),
      'This campaign has expired.',
    );
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
}
