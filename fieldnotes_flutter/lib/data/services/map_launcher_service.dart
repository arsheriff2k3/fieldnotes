import 'package:url_launcher/url_launcher.dart';

/// Hands off to the installed Google Maps app (or maps.google.com on web and
/// desktop) for turn-by-turn navigation to a campaign pin.
///
/// FieldNote deliberately does not draw its own turn-by-turn route: the
/// volunteer already has a maps app that knows their transport preferences,
/// and re-implementing navigation would add a billed Directions call per
/// journey for a worse experience.
abstract final class MapLauncher {
  static Future<bool> openDirections({
    required double latitude,
    required double longitude,
    String mode = 'walking',
  }) async {
    final uri = Uri.https('www.google.com', '/maps/dir/', {
      'api': '1',
      'destination': '$latitude,$longitude',
      'travelmode': mode,
    });
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  /// Opens the pin itself rather than a route, for sponsors reviewing where a
  /// campaign or a piece of evidence actually sits.
  static Future<bool> openPlace({
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.https('www.google.com', '/maps/search/', {
      'api': '1',
      'query': '$latitude,$longitude',
    });
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
