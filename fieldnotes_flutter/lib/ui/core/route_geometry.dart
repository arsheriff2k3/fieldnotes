import 'dart:math' as math;

import 'fieldnote_map.dart';

/// Decodes the encoded polyline returned by Google Routes.
List<LatLng> decodeRoutePolyline(String encoded) {
  final points = <LatLng>[];
  var index = 0;
  var latitude = 0;
  var longitude = 0;
  int nextValue() {
    var value = 0;
    var shift = 0;
    while (true) {
      if (index >= encoded.length || shift > 30) {
        throw const FormatException('Invalid route polyline');
      }
      final part = encoded.codeUnitAt(index++) - 63;
      value |= (part & 0x1f) << shift;
      if (part < 0x20) break;
      shift += 5;
    }
    return (value & 1) != 0 ? ~(value >> 1) : value >> 1;
  }

  while (index < encoded.length) {
    latitude += nextValue();
    longitude += nextValue();
    points.add(LatLng(latitude / 1e5, longitude / 1e5));
  }
  return points;
}

double distanceBetweenPoints(LatLng a, LatLng b) {
  const radius = 6371000.0;
  final lat1 = a.latitude * math.pi / 180;
  final lat2 = b.latitude * math.pi / 180;
  final dLat = lat2 - lat1;
  final dLng = (b.longitude - a.longitude) * math.pi / 180;
  final h =
      math.pow(math.sin(dLat / 2), 2) +
      math.cos(lat1) * math.cos(lat2) * math.pow(math.sin(dLng / 2), 2);
  return 2 * radius * math.asin(math.sqrt(h.clamp(0, 1)));
}

typedef RouteProgress = ({double remainingMeters, double offRouteMeters});

/// Projects a GPS point onto each polyline segment and measures the route
/// still ahead from the nearest projection.
RouteProgress routeProgress(List<LatLng> points, LatLng here) {
  if (points.isEmpty) {
    return (remainingMeters: 0, offRouteMeters: double.infinity);
  }
  if (points.length == 1) {
    final distance = distanceBetweenPoints(here, points.single);
    return (remainingMeters: distance, offRouteMeters: distance);
  }
  final lengths = <double>[];
  var total = 0.0;
  for (var index = 0; index < points.length - 1; index++) {
    final length = distanceBetweenPoints(points[index], points[index + 1]);
    lengths.add(length);
    total += length;
  }
  var bestDistance = double.infinity;
  var bestRemaining = total;
  var traversed = 0.0;
  final metresPerDegreeLatitude = 111195.0;
  final metresPerDegreeLongitude =
      metresPerDegreeLatitude * math.cos(here.latitude * math.pi / 180);
  for (var index = 0; index < lengths.length; index++) {
    final start = points[index];
    final end = points[index + 1];
    final ax = (start.longitude - here.longitude) * metresPerDegreeLongitude;
    final ay = (start.latitude - here.latitude) * metresPerDegreeLatitude;
    final bx = (end.longitude - here.longitude) * metresPerDegreeLongitude;
    final by = (end.latitude - here.latitude) * metresPerDegreeLatitude;
    final dx = bx - ax;
    final dy = by - ay;
    final denominator = dx * dx + dy * dy;
    final fraction = denominator == 0
        ? 0.0
        : (-(ax * dx + ay * dy) / denominator).clamp(0.0, 1.0);
    final distance = math.sqrt(
      math.pow(ax + fraction * dx, 2) + math.pow(ay + fraction * dy, 2),
    );
    if (distance < bestDistance) {
      bestDistance = distance;
      bestRemaining = total - traversed - lengths[index] * fraction;
    }
    traversed += lengths[index];
  }
  return (
    remainingMeters: bestRemaining.clamp(0, total),
    offRouteMeters: bestDistance,
  );
}
