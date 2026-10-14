import 'dart:convert';
import 'dart:io';

import 'package:serverpod/serverpod.dart';

import '../../fieldnotes/services/fieldnote_config.dart';
import '../../generated/protocol.dart';

const fieldnoteApkFilePath =
    '../fieldnotes_flutter/build/app/outputs/flutter-apk/app-release.apk';

/// Public, read-only page for links posted in social apps. A visitor sees the
/// campaign before choosing to open FieldNote. Joining still requires an
/// authenticated volunteer and an explicit tap inside the app.
///
/// R-3: `/c/<shareSlug>` is the canonical link. `/c/<id>` keeps working for
/// links shared before slugs existed. Either way, only open campaigns are
/// rendered; drafts, cancelled, expired, started and completed campaigns get
/// a 404 so the page never leaks non-public campaigns.
class CampaignShareRoute extends WidgetRoute {
  CampaignShareRoute({this.allowApkDownload = false});

  /// R-4: the locally built APK is offered only in development.
  final bool allowApkDownload;

  @override
  Future<WebWidget?> build(Session session, Request request) async {
    final segments = request.url.pathSegments;
    if (segments.length != 2 || segments.first != 'c') return null;
    final campaign = await resolve(session, segments.last);
    if (campaign == null) return null;
    int? apkRevision;
    if (allowApkDownload) {
      final apkFile = File(fieldnoteApkFilePath);
      apkRevision = apkFile.existsSync()
          ? apkFile.lastModifiedSync().millisecondsSinceEpoch
          : null;
    }
    return _CampaignSharePage(
      campaign,
      apkRevision,
      androidPackage: FieldnoteConfig.androidPackage,
      playStoreUrl: FieldnoteConfig.playStoreUrl,
      appStoreUrl: FieldnoteConfig.appStoreUrl,
    );
  }

  /// The open campaign for a share-link key (slug or legacy numeric id), or
  /// null for anything that must 404.
  static Future<Campaign?> resolve(Session session, String key) async {
    final value = key.trim();
    Campaign? campaign;
    final id = int.tryParse(value);
    if (id != null) {
      if (id < 1) return null;
      campaign = await Campaign.db.findById(session, id);
    } else if (RegExp(r'^[A-Za-z0-9]{16,64}$').hasMatch(value)) {
      campaign = await Campaign.db.findFirstRow(
        session,
        where: (t) => t.shareSlug.equals(value),
      );
    }
    if (campaign == null || !isOpen(campaign)) return null;
    return campaign;
  }

  static bool isOpen(Campaign campaign) =>
      campaign.status == CampaignStatus.active &&
      !const {'cancelled', 'expired'}.contains(campaign.readinessState) &&
      DateTime.now().toUtc().isBefore(campaign.startsAt);
}

class _CampaignSharePage extends WebWidget {
  _CampaignSharePage(
    this.campaign,
    this.apkRevision, {
    this.androidPackage,
    this.playStoreUrl,
    this.appStoreUrl,
  });

  final Campaign campaign;
  final int? apkRevision;
  final String? androidPackage;
  final String? playStoreUrl;
  final String? appStoreUrl;

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
    final open = CampaignShareRoute.isOpen(campaign);
    final stores = [
      if (playStoreUrl != null)
        '<a class="button secondary" href="${escape.convert(playStoreUrl!)}">Get FieldNote on Google Play</a>',
      if (appStoreUrl != null)
        '<a class="button secondary" href="${escape.convert(appStoreUrl!)}">Get FieldNote on the App Store</a>',
    ].join('\n    ');
    final install = downloadUrl != null
        ? '<a class="button secondary" href="$downloadUrl" download="FieldNote.apk">Download Android app</a>'
        : stores.isNotEmpty
        ? stores
        : '<p>Ask the campaign creator how to install FieldNote.</p>';
    final package = androidPackage;
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
    <p class="hint">If installed, Open goes to this campaign. New volunteers can install the app and follow the steps below.</p>
  </div>''' : '<p>This campaign is no longer open for joining.</p>'}
  <section class="install" id="install">
    <h2>New to FieldNote?</h2>
    $install
    <ol>
      <li>Install FieldNote.</li>
      <li>Open FieldNote and sign up as a <strong>Volunteer</strong>. Complete your profile and consent.</li>
      <li>Return to this page or reopen the shared campaign link, then tap <strong>Open campaign in FieldNote</strong>.</li>
      <li>Review the campaign and tap <strong>Join</strong> in the app.</li>
    </ol>
  </section>
</article></main>
${package == null ? '' : """<script>
  (function() {
    var openButton = document.getElementById('open-app');
    if (!openButton || !/Android/i.test(navigator.userAgent) ||
        !/Chrome\\//i.test(navigator.userAgent)) return;
    var fallback = encodeURIComponent(location.origin + location.pathname + '#install');
    openButton.href = 'intent://campaign/$id#Intent;scheme=fieldnote;package=$package;S.browser_fallback_url=' + fallback + ';end';
  })();
</script>"""}
</body>
</html>''';
  }
}
