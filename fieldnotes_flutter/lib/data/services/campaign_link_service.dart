import 'package:fieldnotes_client/fieldnotes_client.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

/// The HTTPS base is a temporary demo tunnel until FieldNote has a stable
/// domain. The landing page offers a custom-scheme link into the installed app.
const campaignShareBaseUrl = String.fromEnvironment(
  'CAMPAIGN_SHARE_BASE_URL',
);

Uri campaignShareUri(int campaignId) {
  final base = Uri.tryParse(campaignShareBaseUrl);
  if (base != null &&
      base.hasScheme &&
      base.scheme == 'https' &&
      base.host.isNotEmpty) {
    return base.replace(pathSegments: ['c', '$campaignId'], query: null);
  }
  return Uri(scheme: 'fieldnote', host: 'campaign', path: '/$campaignId');
}

int? campaignIdFromDeepLink(Uri uri) {
  final segments = uri.pathSegments;
  if (uri.scheme == 'fieldnote' &&
      uri.host == 'campaign' &&
      segments.length == 1) {
    final id = int.tryParse(segments.single);
    return id != null && id > 0 ? id : null;
  }
  if (uri.scheme == 'https' && segments.length == 2 && segments.first == 'c') {
    final id = int.tryParse(segments.last);
    return id != null && id > 0 ? id : null;
  }
  return null;
}

Future<void> shareCampaign(BuildContext context, Campaign campaign) async {
  final link = campaignShareUri(campaign.id!);
  final box = context.findRenderObject() as RenderBox?;
  await SharePlus.instance.share(
    ShareParams(
      subject: campaign.name,
      text: 'Join ${campaign.name} on FieldNote:\n$link',
      sharePositionOrigin: box == null
          ? null
          : box.localToGlobal(Offset.zero) & box.size,
    ),
  );
}
