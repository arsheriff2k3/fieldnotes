import 'dart:convert';
import 'dart:io';

import 'package:fieldnotes_server/src/fieldnotes/services/google_maps_service.dart';
import 'package:test/test.dart';

void main() {
  test(
    'Compute Routes keeps the key server-side and returns road steps',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(() => server.close(force: true));
      final service = GoogleMapsService(
        directionsUri: Uri.parse('http://127.0.0.1:${server.port}/directions'),
      );

      final pending = service.travelRoute(
        apiKey: 'server-only-key',
        originLatitude: 10.66,
        originLongitude: 77.00,
        destinationLatitude: 10.67,
        destinationLongitude: 77.01,
        travelMode: 'WALK',
      );
      final request = await server.first;
      expect(request.method, 'POST');
      expect(request.uri.path, '/directions');
      expect(request.headers.value('X-Goog-Api-Key'), 'server-only-key');
      expect(
        request.headers.value('X-Goog-FieldMask'),
        contains('routes.legs.steps'),
      );
      final body = jsonDecode(await utf8.decoder.bind(request).join()) as Map;
      expect(body['travelMode'], 'WALK');
      expect(body['origin'], isA<Map>());
      expect(body['destination'], isA<Map>());
      request.response.headers.contentType = ContentType.json;
      request.response.write(
        jsonEncode({
          'routes': [
            {
              'distanceMeters': 1200,
              'duration': '900s',
              'polyline': {'encodedPolyline': '_p~iF~ps|U_ulLnnqC_mqNvxq`@'},
              'legs': [
                {
                  'steps': [
                    {
                      'distanceMeters': 500,
                      'navigationInstruction': {'instructions': 'Walk east'},
                      'endLocation': {
                        'latLng': {'latitude': 10.665, 'longitude': 77.005},
                      },
                    },
                  ],
                },
              ],
            },
          ],
        }),
      );
      await request.response.close();

      final route = await pending;
      expect(route.distanceMeters, 1200);
      expect(route.durationSeconds, 900);
      expect(route.steps.single.instruction, 'Walk east');
      expect(route.steps.single.endLatitude, 10.665);
    },
  );
}
