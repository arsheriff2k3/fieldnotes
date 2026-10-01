import 'dart:io';

import 'package:serverpod/serverpod.dart';

/// Non-secret deployment settings read from environment variables, plus the
/// public URLs built from the web server's public host configuration.
///
/// | Env var | Use |
/// |---|---|
/// | `FIELDNOTE_ANDROID_PACKAGE` | Android application ID for share-page intents and `assetlinks.json` |
/// | `FIELDNOTE_ANDROID_SHA256_CERT_FINGERPRINTS` | Comma-separated signing-cert SHA-256 fingerprints for `assetlinks.json` |
/// | `FIELDNOTE_IOS_APP_ID` | `TEAMID.bundle.id` for `apple-app-site-association` |
/// | `FIELDNOTE_PLAY_STORE_URL` / `FIELDNOTE_APP_STORE_URL` | Store links on the share page |
/// | `FIELDNOTE_LINK_BASE_URL` | Base URL of share links when it differs from the web server's public URL |
/// | `FIELDNOTE_GEMINI_MODEL` | Gemini model when the `geminiModel` password is not set |
abstract final class FieldnoteConfig {
  /// Tests replace the process environment here.
  static Map<String, String>? environmentOverride;

  static Map<String, String> get _env =>
      environmentOverride ?? Platform.environment;

  static String? _value(String name) {
    final value = _env[name]?.trim();
    return value == null || value.isEmpty ? null : value;
  }

  static final _packagePattern = RegExp(
    r'^[a-zA-Z][a-zA-Z0-9_]*(\.[a-zA-Z][a-zA-Z0-9_]*)+$',
  );

  /// Null when unset or not a valid application ID.
  static String? get androidPackage {
    final value = _value('FIELDNOTE_ANDROID_PACKAGE');
    return value != null && _packagePattern.hasMatch(value) ? value : null;
  }

  static List<String> get androidCertFingerprints {
    final value = _value('FIELDNOTE_ANDROID_SHA256_CERT_FINGERPRINTS');
    if (value == null) return const [];
    return [
      for (final item in value.split(','))
        if (RegExp(
          r'^([0-9A-Fa-f]{2}:){31}[0-9A-Fa-f]{2}$',
        ).hasMatch(item.trim()))
          item.trim().toUpperCase(),
    ];
  }

  /// `TEAMID.bundle.id`, or null when unset or malformed.
  static String? get iosAppId {
    final value = _value('FIELDNOTE_IOS_APP_ID');
    if (value == null) return null;
    return RegExp(r'^[A-Z0-9]{10}\.[A-Za-z0-9\-.]+$').hasMatch(value)
        ? value
        : null;
  }

  static String? get playStoreUrl {
    final explicit = _httpsUrl(_value('FIELDNOTE_PLAY_STORE_URL'));
    if (explicit != null) return explicit;
    final package = androidPackage;
    return package == null
        ? null
        : 'https://play.google.com/store/apps/details?id=$package';
  }

  static String? get appStoreUrl =>
      _httpsUrl(_value('FIELDNOTE_APP_STORE_URL'));

  static String? get geminiModel => _value('FIELDNOTE_GEMINI_MODEL');

  /// `https://<web-host>` without a trailing slash.
  static String publicWebBaseUrl(Serverpod pod) {
    final explicit = _httpsUrl(
      _value('FIELDNOTE_LINK_BASE_URL'),
      allowHttp: true,
    );
    if (explicit != null) return explicit.replaceAll(RegExp(r'/+$'), '');
    final web = pod.config.webServer ?? pod.config.apiServer;
    final defaultPort =
        (web.publicScheme == 'https' && web.publicPort == 443) ||
        (web.publicScheme == 'http' && web.publicPort == 80);
    return Uri(
      scheme: web.publicScheme,
      host: web.publicHost,
      port: defaultPort ? null : web.publicPort,
    ).toString().replaceAll(RegExp(r'/+$'), '');
  }

  static String? _httpsUrl(String? value, {bool allowHttp = false}) {
    if (value == null) return null;
    final uri = Uri.tryParse(value);
    if (uri == null || uri.host.isEmpty) return null;
    if (uri.scheme != 'https' && !(allowHttp && uri.scheme == 'http')) {
      return null;
    }
    return value;
  }
}
