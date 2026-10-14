import 'package:fieldnotes_flutter/data/services/campaign_link_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('accepts numeric campaign links and rejects unrelated links', () {
    expect(
      campaignLinkFromDeepLink(Uri.parse('fieldnote://campaign/42')),
      const CampaignLinkTarget.id(42),
    );
    expect(campaignIdFromDeepLink(Uri.parse('fieldnote://campaign/42')), 42);
    expect(
      campaignLinkFromDeepLink(Uri.parse('fieldnote://campaign/0')),
      isNull,
    );
    expect(
      campaignLinkFromDeepLink(Uri.parse('fieldnote://profile/42')),
      isNull,
    );
    expect(
      campaignLinkFromDeepLink(Uri.parse('https://example.com/c/42')),
      const CampaignLinkTarget.id(42),
    );
  });

  test('accepts share slugs on both link forms', () {
    const slug = 'aB3dE5gH7jK9mN1p';
    expect(
      campaignLinkFromDeepLink(Uri.parse('https://fieldnote.app/c/$slug')),
      const CampaignLinkTarget.slug(slug),
    );
    expect(
      campaignLinkFromDeepLink(Uri.parse('fieldnote://campaign/$slug')),
      const CampaignLinkTarget.slug(slug),
    );
    expect(
      campaignIdFromDeepLink(Uri.parse('fieldnote://campaign/$slug')),
      isNull,
    );
  });

  test('rejects malformed slugs and paths', () {
    expect(
      campaignLinkFromDeepLink(Uri.parse('https://fieldnote.app/c/short')),
      isNull,
    );
    expect(
      campaignLinkFromDeepLink(Uri.parse('https://fieldnote.app/c/bad-slug!!')),
      isNull,
    );
    expect(
      campaignLinkFromDeepLink(Uri.parse('http://fieldnote.app/c/42')),
      isNull,
    );
    expect(
      campaignLinkFromDeepLink(Uri.parse('https://fieldnote.app/x/42')),
      isNull,
    );
  });
}
