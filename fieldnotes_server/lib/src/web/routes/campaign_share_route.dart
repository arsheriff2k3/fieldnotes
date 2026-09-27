import 'dart:convert';

import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart';

/// Public, read-only page for links posted in social apps. A visitor sees the
/// campaign before choosing to open FieldNote. Joining still requires an
/// authenticated volunteer and an explicit tap inside the app.
class CampaignShareRoute extends WidgetRoute {
  CampaignShareRoute();

  @override
  Future<WebWidget?> build(Session session, Request request) async {
    final segments = request.url.pathSegments;
    if (segments.length != 2 || segments.first != 'c') return null;
    final id = int.tryParse(segments.last);
    if (id == null || id < 1) return null;
    final campaign = await Campaign.db.findById(session, id);
    if (campaign == null) return null;
    return _CampaignSharePage(campaign);
  }
}

class _CampaignSharePage extends WebWidget {
  _CampaignSharePage(this.campaign);

  final Campaign campaign;

  @override
  String render({String? Function(String)? onMissingVariable}) {
    const escape = HtmlEscape(HtmlEscapeMode.attribute);
    final title = escape.convert(campaign.name);
    final description = escape.convert(campaign.description);
    final location = escape.convert(campaign.locationName);
    final id = campaign.id!;
    final openUrl = 'fieldnote://campaign/$id';
    final open =
        campaign.status == CampaignStatus.active &&
        campaign.readinessState != 'cancelled' &&
        campaign.readinessState != 'expired' &&
        DateTime.now().toUtc().isBefore(campaign.startsAt);
    return '''<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="theme-color" content="#17352c">
  <meta property="og:type" content="website">
  <meta property="og:title" content="$title · FieldNote">
  <meta property="og:description" content="$description">
  <title>$title · FieldNote</title>
  <style>
    body { margin:0; background:#eae8dc; color:#17352c; font:17px/1.5 system-ui,sans-serif; }
    main { max-width:620px; margin:7vh auto; padding:28px; }
    article { background:#f8f6ee; border-radius:28px; padding:32px; box-shadow:0 8px 24px #17352c14; }
    small { color:#b65c39; text-transform:uppercase; letter-spacing:.12em; font-weight:700; }
    h1 { font: bold clamp(30px,6vw,48px)/1.1 Georgia,serif; margin:20px 0; }
    p { margin:16px 0; }
    .place { color:#527267; }
    a.button { display:block; margin-top:28px; padding:17px 24px; border-radius:15px; background:#174d3f; color:white; font-weight:700; text-align:center; text-decoration:none; }
  </style>
</head>
<body>
<main><article>
  <small>FieldNote campaign</small>
  <h1>$title</h1>
  <p>$description</p>
  <p class="place">$location</p>
  ${open ? '<a class="button" href="$openUrl">Open in FieldNote to join</a>' : '<p>This campaign is no longer open for joining.</p>'}
  <p>Joining requires a volunteer account and your confirmation in the app.</p>
</article></main>
</body>
</html>''';
  }
}
