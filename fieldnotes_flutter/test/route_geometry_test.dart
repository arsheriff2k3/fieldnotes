import 'package:fieldnotes_flutter/ui/core/fieldnote_map.dart';
import 'package:fieldnotes_flutter/ui/core/route_geometry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('decodes a Routes polyline and tracks progress along the road', () {
    final points = decodeRoutePolyline('_p~iF~ps|U_ulLnnqC_mqNvxq`@');
    expect(points.length, 3);
    expect(points.first.latitude, closeTo(38.5, 0.00001));
    expect(points.first.longitude, closeTo(-120.2, 0.00001));

    final start = routeProgress(points, points.first);
    final middle = routeProgress(points, points[1]);
    final finish = routeProgress(points, points.last);
    expect(start.remainingMeters, greaterThan(middle.remainingMeters));
    expect(middle.remainingMeters, greaterThan(finish.remainingMeters));
    expect(finish.remainingMeters, closeTo(0, 1));

    final offRoute = routeProgress(points, const LatLng(0, 0));
    expect(offRoute.offRouteMeters, greaterThan(100));
  });
}
