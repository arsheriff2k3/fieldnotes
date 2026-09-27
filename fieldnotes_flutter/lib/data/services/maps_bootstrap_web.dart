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
Future<bool> bootstrapMapsSdk(String apiKey) {
  return _loading ??= _inject(apiKey);
}

Future<bool>? _loading;

Future<bool> _inject(String apiKey) {
  if (_alreadyLoaded()) return Future.value(true);
  final completer = Completer<bool>();
  final script = web.document.createElement('script') as web.HTMLScriptElement
    ..type = 'text/javascript'
    ..async = true
    ..defer = true
    ..src =
        'https://maps.googleapis.com/maps/api/js'
        '?key=${Uri.encodeComponent(apiKey)}&libraries=marker';
  script.onload = (web.Event _) {
    if (!completer.isCompleted) completer.complete(_alreadyLoaded());
  }.toJS;
  script.onerror = (web.Event _) {
    if (!completer.isCompleted) completer.complete(false);
  }.toJS;
  web.document.head!.appendChild(script);
  return completer.future.timeout(
    const Duration(seconds: 10),
    onTimeout: () => false,
  );
}

bool _alreadyLoaded() {
  final google = web.window.getProperty('google'.toJS);
  if (google == null || !google.isDefinedAndNotNull) return false;
  final maps = (google as JSObject).getProperty('maps'.toJS);
  return maps != null && maps.isDefinedAndNotNull;
}
