import 'package:fieldnotes_flutter/data/services/campaign_link_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('accepts a campaign custom link and rejects unrelated links', () {
    expect(
      campaignIdFromDeepLink(Uri.parse('fieldnote://campaign/42')),
      42,
    );
    expect(campaignIdFromDeepLink(Uri.parse('fieldnote://campaign/0')), isNull);
    expect(campaignIdFromDeepLink(Uri.parse('fieldnote://profile/42')), isNull);
    expect(campaignIdFromDeepLink(Uri.parse('https://example.com/c/42')), 42);
  });
}
