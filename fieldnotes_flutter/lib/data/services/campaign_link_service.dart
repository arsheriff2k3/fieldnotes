import 'package:fieldnotes_client/fieldnotes_client.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../repositories/fieldnote_repository.dart';

/// Fallback HTTPS base used only when the server's share link is unavailable.
/// The server (`getCampaignShareLink`) is the source of truth for share URLs.
const campaignShareBaseUrl = String.fromEnvironment(
  'CAMPAIGN_SHARE_BASE_URL',
);

/// A campaign referenced by a deep link: either a public share slug or, for
/// older links, a numeric campaign id.
@immutable
class CampaignLinkTarget {
  const CampaignLinkTarget.id(int this.id) : slug = null;
  const CampaignLinkTarget.slug(String this.slug) : id = null;

  final int? id;
  final String? slug;

  @override
  bool operator ==(Object other) =>
      other is CampaignLinkTarget && other.id == id && other.slug == slug;

  @override
  int get hashCode => Object.hash(id, slug);

  @override
  String toString() => slug != null ? 'slug:$slug' : 'id:$id';
}

/// Matches the server's slug format (`getSharedCampaignBySlug`).
final _slugPattern = RegExp(r'^[A-Za-z0-9]{16,64}$');
final _idPattern = RegExp(r'^[0-9]{1,15}$');

CampaignLinkTarget? _targetFromSegment(String segment) {
  final value = segment.trim();
  if (_idPattern.hasMatch(value)) {
    final id = int.tryParse(value);
    return id != null && id > 0 ? CampaignLinkTarget.id(id) : null;
  }
  if (_slugPattern.hasMatch(value)) return CampaignLinkTarget.slug(value);
  return null;
}

/// Accepts `fieldnote://campaign/<slug|id>` and `https://<host>/c/<slug|id>`.
CampaignLinkTarget? campaignLinkFromDeepLink(Uri uri) {
  final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
  if (uri.scheme == 'fieldnote' &&
      uri.host == 'campaign' &&
      segments.length == 1) {
    return _targetFromSegment(segments.single);
  }
  if (uri.scheme == 'https' && segments.length == 2 && segments.first == 'c') {
    return _targetFromSegment(segments.last);
  }
  return null;
}

/// Legacy helper: the numeric id in a link, or null for slug links.
int? campaignIdFromDeepLink(Uri uri) => campaignLinkFromDeepLink(uri)?.id;

/// Local fallback link, used only when the server link cannot be fetched.
Uri campaignShareUri(Campaign campaign) {
  final key = campaign.shareSlug ?? '${campaign.id}';
  final base = Uri.tryParse(campaignShareBaseUrl);
  if (base != null &&
      base.hasScheme &&
      base.scheme == 'https' &&
      base.host.isNotEmpty) {
    return base.replace(pathSegments: ['c', key], query: null);
  }
  return Uri(scheme: 'fieldnote', host: 'campaign', path: '/$key');
}

/// Shares the server-issued public link for [campaign].
Future<void> shareCampaign(
  BuildContext context,
  Campaign campaign, {
  FieldnoteRepository? repository,
}) async {
  final box = context.findRenderObject() as RenderBox?;
  final origin = box == null || !box.hasSize
      ? null
      : box.localToGlobal(Offset.zero) & box.size;
  String link;
  try {
    link = await (repository ?? FieldnoteRepository()).campaignShareLink(
      campaign.id!,
    );
  } catch (_) {
    link = campaignShareUri(campaign).toString();
  }
  await SharePlus.instance.share(
    ShareParams(
      subject: campaign.name,
      text: 'Join ${campaign.name} on FieldNote:\n$link',
      sharePositionOrigin: origin,
    ),
  );
}
