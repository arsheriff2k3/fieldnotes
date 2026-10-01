import 'dart:async';
import 'dart:convert';

import 'package:serverpod/serverpod.dart';

import '../../fieldnotes/services/fieldnote_config.dart';

/// R-5: Android App Links and iOS Universal Links verification files, built
/// from `FIELDNOTE_ANDROID_PACKAGE` + `FIELDNOTE_ANDROID_SHA256_CERT_FINGERPRINTS`
/// and `FIELDNOTE_IOS_APP_ID`. Each answers 404 until its variables are set.
abstract final class WellKnownDocuments {
  /// `/.well-known/assetlinks.json`, or null when not configured.
  static String? assetLinks() {
    final package = FieldnoteConfig.androidPackage;
    final fingerprints = FieldnoteConfig.androidCertFingerprints;
    if (package == null || fingerprints.isEmpty) return null;
    return jsonEncode([
      {
        'relation': ['delegate_permission/common.handle_all_urls'],
        'target': {
          'namespace': 'android_app',
          'package_name': package,
          'sha256_cert_fingerprints': fingerprints,
        },
      },
    ]);
  }

  /// `/.well-known/apple-app-site-association`, or null when not configured.
  static String? appleAppSiteAssociation() {
    final appId = FieldnoteConfig.iosAppId;
    if (appId == null) return null;
    return jsonEncode({
      'applinks': {
        'details': [
          {
            'appIDs': [appId],
            'components': [
              {'/': '/c/*', 'comment': 'Shared FieldNote campaign links'},
            ],
          },
        ],
      },
    });
  }
}

/// Serves one generated JSON document with `Content-Type: application/json`,
/// no redirect and a one-hour cache.
class WellKnownRoute extends Route {
  WellKnownRoute(this._document) : super(methods: {Method.get, Method.head});

  final String? Function() _document;

  @override
  FutureOr<Result> handleCall(Session session, Request request) {
    final body = _document();
    if (body == null) {
      return Response.notFound(body: Body.fromString('Not found'));
    }
    return Response.ok(
      body: Body.fromString(body, mimeType: MimeType.json),
      headers: Headers.build(
        (headers) => headers.cacheControl = CacheControlHeader(
          publicCache: true,
          maxAge: 3600,
        ),
      ),
    );
  }
}
