import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:web/web.dart' as web;

/// Loads the Google Maps JavaScript API for `google_maps_flutter_web`.
///
/// The script is injected at runtime with the web key from `.env.maps`
/// rather than hard-coded into `web/index.html`, so the same build can be
/// pointed at a different restricted browser key without editing HTML. A
/// browser Maps key is public by design and must be locked down with an HTTP
/// referrer restriction in the Google Cloud console.
Future<void> bootstrapMapsSdk(String apiKey) {
  return _loading ??= _inject(apiKey);
}

Future<void>? _loading;

Future<void> _inject(String apiKey) {
  if (_alreadyLoaded()) return Future.value();
  final completer = Completer<void>();
  final script = web.document.createElement('script') as web.HTMLScriptElement
    ..type = 'text/javascript'
    ..async = true
    ..defer = true
    ..src =
        'https://maps.googleapis.com/maps/api/js'
        '?key=${Uri.encodeComponent(apiKey)}&libraries=marker';
  script.onload = (web.Event _) {
    if (!completer.isCompleted) completer.complete();
  }.toJS;
  script.onerror = (web.Event _) {
    // Resolve rather than reject: the app must still run with the map
    // fallback panel when the tiles cannot be reached.
    if (!completer.isCompleted) completer.complete();
  }.toJS;
  web.document.head!.appendChild(script);
  return completer.future.timeout(
    const Duration(seconds: 10),
    onTimeout: () {},
  );
}

bool _alreadyLoaded() {
  final maps = web.window.getProperty('google'.toJS);
  return maps != null && maps.isDefinedAndNotNull;
}
