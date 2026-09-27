import 'dart:convert';

import 'package:fieldnotes_flutter/ui/features/trust/account_data_export_view.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('builds a readable PDF with account records and Tamil text', () async {
    final raw = jsonEncode({
      'generatedAt': '2026-09-27T12:00:00Z',
      'profile': {
        'displayName': 'தமிழ் Volunteer',
        'role': 'volunteer',
        'city': 'Pallavaram',
      },
      'consent': {
        'acceptedAt': '2026-09-20T12:00:00Z',
        'locationConsent': true,
        'aiProcessingConsent': true,
        'evidenceSharingConsent': true,
        'privacyPolicyVersion': '2026-09-22',
        'termsVersion': '2026-09-22',
      },
      'participations': [
        {
          'campaignName': 'Tree planting',
          'status': 'joined',
          'joinedAt': '2026-09-25T12:00:00Z',
        },
      ],
      'completionEvidence': [
        {
          'campaignName': 'Tree planting',
          'originalNote': 'Planted trees',
          'confirmedSummary': 'Ten trees planted',
          'submittedAt': '2026-09-26T12:00:00Z',
          'locationIntegrityStatus': 'verified',
        },
      ],
    });

    final bytes = await buildAccountDataPdf(raw);
    expect(ascii.decode(bytes.take(4).toList()), '%PDF');
    expect(bytes.length, greaterThan(1000));
  });
}
