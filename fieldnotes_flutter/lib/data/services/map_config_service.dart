import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'maps_bootstrap_mobile.dart'
    if (dart.library.js_interop) 'maps_bootstrap_web.dart';

/// Whether this build can render Google Maps tiles, and with which key.
///
/// The client key is deliberately separate from the server's
/// `googleMapsApiKey` Serverpod password: this one only renders tiles and
/// should be restricted by bundle id, SHA-1, or HTTP referrer, while the
/// server key is the one allowed to make billed Places, Geocoding, and Routes
/// calls.
///
/// When no key is configured every map in the app falls back to the
/// coordinate-and-distance panels FieldNote shipped before Maps existed, so
/// the app never shows a blank grey rectangle.
abstract final class MapConfig {
  static const _legacyDefineKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
  );
  static const _androidDefineKey = String.fromEnvironment(
    'GOOGLE_MAPS_ANDROID_API_KEY',
  );
  static const _iosDefineKey = String.fromEnvironment(
    'GOOGLE_MAPS_IOS_API_KEY',
  );
  static const _webDefineKey = String.fromEnvironment(
    'GOOGLE_MAPS_WEB_API_KEY',
  );

  static String _apiKey = '';
  static bool _loaded = false;

  static String get apiKey => _apiKey;

  /// True when a key is present. On Android and iOS the same key must also be
  /// present in native configuration for tiles to actually draw; see
  /// `docs/SECRETS_AND_EXTERNAL_SERVICES.md`.
  static bool get isConfigured => _apiKey.isNotEmpty;

  /// Reads the key and, on web, loads the Maps JavaScript API. Safe to call
  /// more than once. Never throws: a missing or unreadable config just leaves
  /// maps disabled.
  static Future<void> load() async {
    if (_loaded) return;
    _loaded = true;
    _apiKey = _defineKeyForCurrentPlatform().trim();
    if (_apiKey.isEmpty) {
      final environment = await _fromMapsEnvironment();
      _apiKey = (environment[_environmentKeyForCurrentPlatform] ?? '').trim();
    }
    // Keep accepting the original config during migration. New builds should
    // use .env.maps so each platform can have a correctly restricted key.
    if (_apiKey.isEmpty) {
      _apiKey = await _fromLegacyAssetConfig();
    }
    if (_apiKey.isNotEmpty) {
      await bootstrapMapsSdk(_apiKey);
    }
  }

  static String _defineKeyForCurrentPlatform() {
    if (_legacyDefineKey.trim().isNotEmpty) return _legacyDefineKey;
    if (kIsWeb) return _webDefineKey;
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => _androidDefineKey,
      TargetPlatform.iOS => _iosDefineKey,
      _ => '',
    };
  }

  static String get _environmentKeyForCurrentPlatform {
    if (kIsWeb) return 'GOOGLE_MAPS_WEB_API_KEY';
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => 'GOOGLE_MAPS_ANDROID_API_KEY',
      TargetPlatform.iOS => 'GOOGLE_MAPS_IOS_API_KEY',
      _ => '',
    };
  }

  static Future<Map<String, String>> _fromMapsEnvironment() async {
    try {
      final raw = await rootBundle.loadString('.env.maps');
      final values = <String, String>{};
      for (final sourceLine in const LineSplitter().convert(raw)) {
        final line = sourceLine.trim();
        if (line.isEmpty || line.startsWith('#')) continue;
        final separator = line.indexOf('=');
        if (separator <= 0) continue;
        final key = line.substring(0, separator).trim();
        var value = line.substring(separator + 1).trim();
        if (value.length >= 2 &&
            ((value.startsWith('"') && value.endsWith('"')) ||
                (value.startsWith("'") && value.endsWith("'")))) {
          value = value.substring(1, value.length - 1);
        }
        values[key] = value;
      }
      return values;
    } on Object {
      return const {};
    }
  }

  static Future<String> _fromLegacyAssetConfig() async {
    try {
      final raw = await rootBundle.loadString('assets/config.json');
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return '';
      final value = decoded['googleMapsApiKey'];
      return value is String ? value.trim() : '';
    } on Object {
      return '';
    }
  }
}
