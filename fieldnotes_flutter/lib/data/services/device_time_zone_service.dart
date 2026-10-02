import 'package:flutter/foundation.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

/// The device's IANA time zone (`Asia/Kolkata`), sent to the server so
/// weekday, time-window and "this Saturday" maths are DST-aware in the
/// user's own zone. The server falls back to `utcOffsetMinutes`, then IST.
class DeviceTimeZoneService {
  DeviceTimeZoneService({Future<String> Function()? lookup})
    : _lookup = lookup ?? _platformLookup;

  final Future<String> Function() _lookup;
  Future<String?>? _cached;

  static Future<String> _platformLookup() async =>
      (await FlutterTimezone.getLocalTimezone()).identifier;

  /// The IANA zone, or null when the platform cannot tell (unsupported
  /// platform, plugin error, or a non-IANA name such as `IST`). Looked up
  /// once per service; a failed lookup is retried on the next call.
  Future<String?> ianaTimeZone() {
    final cached = _cached;
    if (cached != null) return cached;
    final pending = _resolve();
    _cached = pending;
    pending.then((value) {
      if (value == null) _cached = null;
    });
    return pending;
  }

  Future<String?> _resolve() async {
    try {
      return validIanaTimeZone(await _lookup());
    } catch (error) {
      debugPrint('Device time zone unavailable: $error');
      return null;
    }
  }

  /// The device's current UTC offset in minutes.
  static int utcOffsetMinutes() => DateTime.now().timeZoneOffset.inMinutes;
}

/// [name] when it looks like an IANA zone id (`Area/Location`, or `UTC`),
/// else null, so an abbreviation can never fail the server's format check.
String? validIanaTimeZone(String? name) {
  final value = name?.trim();
  if (value == null || value.isEmpty || value.length > 64) return null;
  if (value == 'UTC' || value == 'Etc/UTC') return value;
  if (!RegExp(
    r'^[A-Za-z][A-Za-z0-9_+\-]*(/[A-Za-z0-9_+\-]+)+$',
  ).hasMatch(value)) {
    return null;
  }
  return value;
}
