import 'dart:convert';
import 'dart:io';

import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart';

const fieldnoteApkFilePath =
    '../fieldnotes_flutter/build/app/outputs/flutter-apk/app-release.apk';

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
    final apkFile = File(fieldnoteApkFilePath);
    final apkRevision = apkFile.existsSync()
        ? apkFile.lastModifiedSync().millisecondsSinceEpoch
        : null;
    return _CampaignSharePage(campaign, apkRevision);
  }
}

class _CampaignSharePage extends WebWidget {
  _CampaignSharePage(this.campaign, this.apkRevision);

  final Campaign campaign;
  final int? apkRevision;

  @override
  String render({String? Function(String)? onMissingVariable}) {
    const escape = HtmlEscape(HtmlEscapeMode.attribute);
    final title = escape.convert(campaign.name);
    final description = escape.convert(campaign.description);
    final location = escape.convert(campaign.locationName);
    final id = campaign.id!;
    final openUrl = 'fieldnote://campaign/$id';
    final downloadUrl = apkRevision == null
        ? null
        : '/download/fieldnote.apk?v=$apkRevision';
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
    * { box-sizing:border-box; }
    body { margin:0; background:#eae8dc; color:#17352c; font:16px/1.5 system-ui,sans-serif; }
    main { max-width:660px; margin:5vh auto; padding:20px; }
    article { background:#f8f6ee; border-radius:26px; padding:clamp(22px,5vw,36px); box-shadow:0 8px 24px #17352c14; }
    small { color:#b65c39; text-transform:uppercase; letter-spacing:.12em; font-weight:700; }
    h1 { font:bold clamp(30px,6vw,46px)/1.1 Georgia,serif; margin:14px 0; }
    h2 { font: bold 25px/1.2 Georgia,serif; margin:0 0 12px; }
    p { margin:12px 0; }
    .place { color:#527267; }
    .button { display:block; width:100%; padding:15px 20px; border-radius:14px; background:#174d3f; color:white; font-weight:700; text-align:center; text-decoration:none; }
    .button.secondary { background:#e0e9df; color:#17352c; }
    .button + .button { margin-top:10px; }
    .button:focus-visible, .text-link:focus-visible { outline:3px solid #b65c39; outline-offset:3px; }
    .actions { margin:24px 0 8px; }
    .hint { color:#527267; font-size:14px; }
    .install { margin-top:28px; padding-top:26px; border-top:1px solid #cbd6cb; scroll-margin-top:20px; }
    .install:target { outline:2px solid #b65c39; outline-offset:12px; border-radius:8px; }
    ol { padding-left:22px; margin:16px 0 0; }
    li { margin:10px 0; }
    .text-link { color:#174d3f; font-weight:700; }
  </style>
</head>
<body>
<main><article>
  <small>FieldNote campaign</small>
  <h1>$title</h1>
  <p>$description</p>
  <p class="place">$location</p>
  ${open ? '''<div class="actions">
    <a id="open-app" class="button" href="$openUrl">Open campaign in FieldNote</a>
    ${downloadUrl == null ? '' : '<a class="button secondary" href="$downloadUrl" download="FieldNote.apk">Download Android app</a>'}
    <p class="hint">If installed, Open goes to this campaign. New volunteers can download the app and follow the steps below.</p>
  </div>''' : '<p>This campaign is no longer open for joining.</p>'}
  <section class="install" id="install">
    <h2>New to FieldNote?</h2>
    ${downloadUrl == null ? '<p>The Android download is temporarily unavailable. Ask the campaign creator for the current APK.</p>' : '<a class="button secondary" href="$downloadUrl" download="FieldNote.apk">Download Android app</a>'}
    <ol>
      <li>Download and install FieldNote. If Android asks, allow your browser to install this app.</li>
      <li>Open FieldNote and sign up as a <strong>Volunteer</strong>. Complete your profile and consent.</li>
      <li>Return to this page or reopen the shared campaign link, then tap <strong>Open campaign in FieldNote</strong>.</li>
      <li>Review the campaign and tap <strong>Join</strong> in the app.</li>
    </ol>
  </section>
</article></main>
<script>
  (function() {
    var openButton = document.getElementById('open-app');
    if (!openButton || !/Android/i.test(navigator.userAgent) ||
        !/Chrome\\//i.test(navigator.userAgent)) return;
    var fallback = encodeURIComponent(location.origin + location.pathname + '#install');
    openButton.href = 'intent://campaign/$id#Intent;scheme=fieldnote;package=com.example.fieldnotes_flutter;S.browser_fallback_url=' + fallback + ';end';
  })();
</script>
</body>
</html>''';
  }
}
