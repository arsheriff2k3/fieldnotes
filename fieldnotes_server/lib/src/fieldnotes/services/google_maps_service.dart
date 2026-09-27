import 'dart:convert';
import 'dart:io';

import '../../generated/protocol.dart';

class GoogleMapsException implements Exception {
  const GoogleMapsException(this.message);

  final String message;

  @override
  String toString() => 'GoogleMapsException: $message';
}

/// One origin-to-destination leg returned by the Routes API.
class RouteLeg {
  const RouteLeg({
    required this.destinationIndex,
    required this.minutes,
    required this.distanceKm,
  });

  final int destinationIndex;
  final int minutes;
  final double distanceKm;
}

/// Server-side Google Maps Platform calls.
///
/// The key lives in Serverpod passwords as `googleMapsApiKey` and never
/// reaches Flutter. The client renders maps with its own separately
/// restricted key; this service is only for billed web-service calls
/// (Places, Geocoding, Routes) that must not be exposed to a device.
///
/// Every method throws [GoogleMapsException] rather than returning partial
/// data, so callers can fall back to the offline straight-line behaviour the
/// app had before Maps was introduced.
class GoogleMapsService {
  GoogleMapsService({Uri? directionsUri})
    : _directionsUri = directionsUri ?? Uri.parse(directionsEndpoint);

  final Uri _directionsUri;

  static const placesEndpoint = 'https://places.googleapis.com/v1';
  static const geocodeEndpoint =
      'https://maps.googleapis.com/maps/api/geocode/json';
  static const routesEndpoint =
      'https://routes.googleapis.com/distanceMatrix/v2:computeRouteMatrix';
  static const directionsEndpoint =
      'https://routes.googleapis.com/directions/v2:computeRoutes';

  /// Routes API results are billed per element, so identical origin and
  /// destination pairs are reused for [_cacheTtl]. Campaign pins and volunteer
  /// home pins barely move, and the matcher re-runs on every list refresh.
  static const _cacheTtl = Duration(minutes: 30);
  static const _cacheLimit = 2000;

  /// The Routes API rejects matrices above 625 elements.
  static const maxRouteDestinations = 100;

  final Map<String, _CachedLeg> _routeCache = {};

  Future<List<PlaceSuggestion>> autocomplete({
    required String apiKey,
    required String query,
    double? biasLatitude,
    double? biasLongitude,
    double biasRadiusMeters = 50000,
    bool citiesOnly = false,
  }) async {
    final body = <String, Object?>{
      'input': query,
      if (citiesOnly) 'includedPrimaryTypes': ['(cities)'],
      if (biasLatitude != null && biasLongitude != null)
        'locationBias': {
          'circle': {
            'center': {'latitude': biasLatitude, 'longitude': biasLongitude},
            'radius': biasRadiusMeters.clamp(1, 50000),
          },
        },
    };
    final json = await _send(
      method: 'POST',
      url: Uri.parse('$placesEndpoint/places:autocomplete'),
      apiKey: apiKey,
      fieldMask:
          'suggestions.placePrediction.placeId,'
          'suggestions.placePrediction.structuredFormat',
      body: body,
    );
    final suggestions = json['suggestions'];
    if (suggestions is! List) return const [];
    final results = <PlaceSuggestion>[];
    for (final item in suggestions) {
      final prediction = item is Map ? item['placePrediction'] : null;
      if (prediction is! Map) continue;
      final placeId = prediction['placeId'];
      if (placeId is! String || placeId.isEmpty) continue;
      final format = prediction['structuredFormat'];
      results.add(
        PlaceSuggestion(
          placeId: placeId,
          primaryText: _textOf(format, 'mainText') ?? placeId,
          secondaryText: _textOf(format, 'secondaryText') ?? '',
        ),
      );
    }
    return results;
  }

  Future<ResolvedPlace> placeDetails({
    required String apiKey,
    required String placeId,
  }) async {
    final json = await _send(
      method: 'GET',
      url: Uri.parse('$placesEndpoint/places/${Uri.encodeComponent(placeId)}'),
      apiKey: apiKey,
      fieldMask: 'displayName,formattedAddress,location',
    );
    final location = json['location'];
    final latitude = location is Map ? location['latitude'] : null;
    final longitude = location is Map ? location['longitude'] : null;
    if (latitude is! num || longitude is! num) {
      throw const GoogleMapsException(
        'Google Places returned a place without coordinates.',
      );
    }
    final address = json['formattedAddress'];
    return ResolvedPlace(
      name: _textOf(json, 'displayName') ?? (address is String ? address : ''),
      address: address is String ? address : '',
      latitude: latitude.toDouble(),
      longitude: longitude.toDouble(),
    );
  }

  Future<ResolvedPlace> reverseGeocode({
    required String apiKey,
    required double latitude,
    required double longitude,
  }) async {
    final url = Uri.parse(geocodeEndpoint).replace(
      queryParameters: {
        'latlng': '$latitude,$longitude',
        'key': apiKey,
        'result_type':
            'point_of_interest|park|premise|establishment|street_address|'
            'sublocality|locality',
      },
    );
    final json = await _send(method: 'GET', url: url, apiKey: null);
    final status = json['status'];
    if (status == 'ZERO_RESULTS') {
      throw const GoogleMapsException(
        'Google Geocoding found no address for this point.',
      );
    }
    if (status != 'OK') {
      throw GoogleMapsException('Google Geocoding returned status $status.');
    }
    final results = json['results'];
    if (results is! List || results.isEmpty) {
      throw const GoogleMapsException(
        'Google Geocoding returned no usable result.',
      );
    }
    final first = results.first;
    final address = first is Map ? first['formatted_address'] : null;
    return ResolvedPlace(
      name: _shortPlaceName(first) ?? (address is String ? address : ''),
      address: address is String ? address : '',
      latitude: latitude,
      longitude: longitude,
    );
  }

  /// A single route for an in-app travel screen. The map draws the encoded
  /// road path while the steps provide text guidance inside FieldNote.
  Future<TravelRoute> travelRoute({
    required String apiKey,
    required double originLatitude,
    required double originLongitude,
    required double destinationLatitude,
    required double destinationLongitude,
    required String travelMode,
  }) async {
    final mode = _safeTravelMode(travelMode);
    final json = await _send(
      method: 'POST',
      url: _directionsUri,
      apiKey: apiKey,
      fieldMask:
          'routes.distanceMeters,routes.duration,'
          'routes.polyline.encodedPolyline,'
          'routes.legs.steps.distanceMeters,'
          'routes.legs.steps.navigationInstruction.instructions,'
          'routes.legs.steps.endLocation.latLng',
      body: {
        'origin': _waypoint(originLatitude, originLongitude)['waypoint'],
        'destination': _waypoint(
          destinationLatitude,
          destinationLongitude,
        )['waypoint'],
        'travelMode': mode,
        if (mode == 'DRIVE') 'routingPreference': 'TRAFFIC_AWARE',
        'languageCode': 'en',
      },
    );
    final routes = json['routes'];
    final route = routes is List && routes.isNotEmpty ? routes.first : null;
    if (route is! Map) {
      throw const GoogleMapsException('No route was found for this journey.');
    }
    final distance = route['distanceMeters'];
    final duration = route['duration'];
    final polyline = route['polyline'];
    final encoded = polyline is Map ? polyline['encodedPolyline'] : null;
    final seconds = duration is String
        ? double.tryParse(duration.replaceFirst('s', ''))
        : null;
    if (distance is! num ||
        seconds == null ||
        encoded is! String ||
        encoded.isEmpty) {
      throw const GoogleMapsException('The route response was incomplete.');
    }
    final legs = route['legs'];
    final firstLeg = legs is List && legs.isNotEmpty ? legs.first : null;
    final rawSteps = firstLeg is Map ? firstLeg['steps'] : null;
    final steps = <TravelStep>[];
    if (rawSteps is List) {
      for (final raw in rawSteps) {
        if (raw is! Map) continue;
        final navigation = raw['navigationInstruction'];
        final instruction = navigation is Map
            ? navigation['instructions']
            : null;
        final end = raw['endLocation'];
        final latLng = end is Map ? end['latLng'] : null;
        final lat = latLng is Map ? latLng['latitude'] : null;
        final lng = latLng is Map ? latLng['longitude'] : null;
        if (instruction is! String ||
            instruction.isEmpty ||
            lat is! num ||
            lng is! num) {
          continue;
        }
        steps.add(
          TravelStep(
            instruction: instruction,
            distanceMeters: (raw['distanceMeters'] as num?)?.round() ?? 0,
            endLatitude: lat.toDouble(),
            endLongitude: lng.toDouble(),
          ),
        );
      }
    }
    return TravelRoute(
      distanceMeters: distance.round(),
      durationSeconds: seconds.round(),
      encodedPolyline: encoded,
      steps: steps,
    );
  }

  /// Real travel time from one origin to many destinations.
  ///
  /// Returns only the legs the Routes API could actually route; unreachable
  /// destinations are omitted so the caller keeps its straight-line estimate
  /// for them rather than showing an invented number.
  Future<List<RouteLeg>> travelMatrix({
    required String apiKey,
    required double originLatitude,
    required double originLongitude,
    required List<({double latitude, double longitude})> destinations,
    String travelMode = 'DRIVE',
  }) async {
    if (destinations.isEmpty) return const [];
    final mode = _safeTravelMode(travelMode);
    final legs = <RouteLeg>[];
    final pending = <int>[];
    for (var index = 0; index < destinations.length; index++) {
      final cached = _cachedLeg(
        originLatitude,
        originLongitude,
        destinations[index].latitude,
        destinations[index].longitude,
        mode,
      );
      if (cached != null) {
        legs.add(
          RouteLeg(
            destinationIndex: index,
            minutes: cached.minutes,
            distanceKm: cached.distanceKm,
          ),
        );
      } else {
        pending.add(index);
      }
    }
    if (pending.isEmpty) return legs;
    if (pending.length > maxRouteDestinations) {
      pending.removeRange(maxRouteDestinations, pending.length);
    }

    final json = await _sendList(
      url: Uri.parse(routesEndpoint),
      apiKey: apiKey,
      fieldMask:
          'originIndex,destinationIndex,duration,distanceMeters,condition',
      body: {
        'origins': [
          _waypoint(originLatitude, originLongitude),
        ],
        'destinations': [
          for (final index in pending)
            _waypoint(
              destinations[index].latitude,
              destinations[index].longitude,
            ),
        ],
        'travelMode': mode,
        // TRAFFIC_UNAWARE is the cheapest Routes SKU and is only valid for
        // DRIVE; the other modes reject routingPreference outright.
        if (mode == 'DRIVE') 'routingPreference': 'TRAFFIC_UNAWARE',
      },
    );

    for (final element in json) {
      if (element is! Map) continue;
      if (element['condition'] != 'ROUTE_EXISTS') continue;
      final slot = element['destinationIndex'];
      final duration = element['duration'];
      final meters = element['distanceMeters'];
      if (slot is! int || slot < 0 || slot >= pending.length) continue;
      if (duration is! String || meters is! num) continue;
      final seconds = int.tryParse(duration.replaceAll('s', ''));
      if (seconds == null) continue;
      final index = pending[slot];
      final minutes = (seconds / 60).ceil();
      final distanceKm = meters.toDouble() / 1000;
      _storeLeg(
        originLatitude,
        originLongitude,
        destinations[index].latitude,
        destinations[index].longitude,
        mode,
        minutes,
        distanceKm,
      );
      legs.add(
        RouteLeg(
          destinationIndex: index,
          minutes: minutes,
          distanceKm: distanceKm,
        ),
      );
    }
    return legs;
  }

  static Map<String, Object?> _waypoint(double latitude, double longitude) => {
    'waypoint': {
      'location': {
        'latLng': {'latitude': latitude, 'longitude': longitude},
      },
    },
  };

  static String _safeTravelMode(String value) {
    final upper = value.trim().toUpperCase();
    const supported = {'DRIVE', 'WALK', 'BICYCLE', 'TWO_WHEELER'};
    return supported.contains(upper) ? upper : 'DRIVE';
  }

  static String? _textOf(Object? owner, String key) {
    if (owner is! Map) return null;
    final node = owner[key];
    if (node is String) return node.isEmpty ? null : node;
    if (node is Map) {
      final text = node['text'];
      if (text is String && text.isNotEmpty) return text;
    }
    return null;
  }

  static String? _shortPlaceName(Object? result) {
    if (result is! Map) return null;
    final components = result['address_components'];
    if (components is! List) return null;
    for (final component in components) {
      if (component is! Map) continue;
      final types = component['types'];
      if (types is! List) continue;
      if (types.contains('point_of_interest') ||
          types.contains('park') ||
          types.contains('premise') ||
          types.contains('establishment')) {
        final name = component['long_name'];
        if (name is String && name.isNotEmpty) return name;
      }
    }
    for (final component in components) {
      if (component is! Map) continue;
      final types = component['types'];
      if (types is! List) continue;
      if (types.contains('route') || types.contains('sublocality')) {
        final name = component['long_name'];
        if (name is String && name.isNotEmpty) return name;
      }
    }
    return null;
  }

  String _cacheKey(
    double originLat,
    double originLng,
    double destLat,
    double destLng,
    String mode,
  ) {
    String round(double value) => value.toStringAsFixed(4);
    return '${round(originLat)},${round(originLng)}>'
        '${round(destLat)},${round(destLng)}|$mode';
  }

  _CachedLeg? _cachedLeg(
    double originLat,
    double originLng,
    double destLat,
    double destLng,
    String mode,
  ) {
    final key = _cacheKey(originLat, originLng, destLat, destLng, mode);
    final cached = _routeCache[key];
    if (cached == null) return null;
    if (DateTime.now().toUtc().difference(cached.storedAt) > _cacheTtl) {
      _routeCache.remove(key);
      return null;
    }
    return cached;
  }

  void _storeLeg(
    double originLat,
    double originLng,
    double destLat,
    double destLng,
    String mode,
    int minutes,
    double distanceKm,
  ) {
    if (_routeCache.length >= _cacheLimit) {
      // Cheap bounded eviction: drop the oldest quarter rather than growing a
      // long-lived server map without limit.
      final entries = _routeCache.entries.toList()
        ..sort((a, b) => a.value.storedAt.compareTo(b.value.storedAt));
      for (final entry in entries.take(_cacheLimit ~/ 4)) {
        _routeCache.remove(entry.key);
      }
    }
    _routeCache[_cacheKey(
      originLat,
      originLng,
      destLat,
      destLng,
      mode,
    )] = _CachedLeg(
      minutes: minutes,
      distanceKm: distanceKm,
      storedAt: DateTime.now().toUtc(),
    );
  }

  Future<Map<String, dynamic>> _send({
    required String method,
    required Uri url,
    required String? apiKey,
    String? fieldMask,
    Map<String, Object?>? body,
  }) async {
    final decoded = await _sendRaw(
      method: method,
      url: url,
      apiKey: apiKey,
      fieldMask: fieldMask,
      body: body,
    );
    if (decoded is! Map<String, dynamic>) {
      throw const GoogleMapsException(
        'Google Maps returned an unexpected response shape.',
      );
    }
    return decoded;
  }

  Future<List<dynamic>> _sendList({
    required Uri url,
    required String apiKey,
    required String fieldMask,
    required Map<String, Object?> body,
  }) async {
    final decoded = await _sendRaw(
      method: 'POST',
      url: url,
      apiKey: apiKey,
      fieldMask: fieldMask,
      body: body,
    );
    if (decoded is! List) {
      throw const GoogleMapsException(
        'The Google Routes API returned an unexpected response shape.',
      );
    }
    return decoded;
  }

  Future<Object?> _sendRaw({
    required String method,
    required Uri url,
    required String? apiKey,
    String? fieldMask,
    Map<String, Object?>? body,
  }) async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 8);
    try {
      final request = method == 'POST'
          ? await client.postUrl(url).timeout(const Duration(seconds: 10))
          : await client.getUrl(url).timeout(const Duration(seconds: 10));
      if (apiKey != null) request.headers.set('X-Goog-Api-Key', apiKey.trim());
      if (fieldMask != null) request.headers.set('X-Goog-FieldMask', fieldMask);
      if (body != null) {
        request.headers.contentType = ContentType.json;
        request.write(jsonEncode(body));
      }
      final response = await request.close().timeout(
        const Duration(seconds: 15),
      );
      final responseBody = await utf8.decoder
          .bind(response)
          .join()
          .timeout(const Duration(seconds: 10));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw GoogleMapsException(
          'Google Maps returned HTTP ${response.statusCode}: '
          '${_safeErrorMessage(responseBody)}',
        );
      }
      return jsonDecode(responseBody);
    } on GoogleMapsException {
      rethrow;
    } on Object catch (error) {
      throw GoogleMapsException('Google Maps request failed: $error');
    } finally {
      client.close(force: true);
    }
  }

  /// Never echo a raw provider body back to a client; it can contain the key
  /// in a query string or other request detail.
  static String _safeErrorMessage(String body) {
    try {
      final decoded = jsonDecode(body);
      final error = decoded is Map ? decoded['error'] : null;
      final message = error is Map ? error['message'] : null;
      if (message is String && message.isNotEmpty) {
        return message.length > 200 ? message.substring(0, 200) : message;
      }
      final status = decoded is Map ? decoded['error_message'] : null;
      if (status is String && status.isNotEmpty) return status;
    } on Object {
      // Fall through to the generic message below.
    }
    return 'the provider did not return a readable error message';
  }
}

class _CachedLeg {
  const _CachedLeg({
    required this.minutes,
    required this.distanceKm,
    required this.storedAt,
  });

  final int minutes;
  final double distanceKm;
  final DateTime storedAt;
}
