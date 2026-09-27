import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../data/services/map_config_service.dart';
import 'fieldnote_theme.dart';

export 'package:google_maps_flutter/google_maps_flutter.dart'
    show
        BitmapDescriptor,
        Circle,
        CircleId,
        GoogleMapController,
        InfoWindow,
        LatLng,
        LatLngBounds,
        MapType,
        Marker,
        MarkerId,
        Polyline,
        PolylineId;

/// Whether map tiles can be drawn in this build. Screens use this to hide
/// legends and map-only controls that would make no sense over a fallback
/// panel.
bool get mapsAvailable => MapConfig.isConfigured;

/// Marker colours used across both roles, so a pin means the same thing on the
/// volunteer approach map and the sponsor evidence map.
abstract final class FieldnoteMapPalette {
  static const campaign = BitmapDescriptor.hueGreen;
  static const volunteer = BitmapDescriptor.hueAzure;
  static const verified = BitmapDescriptor.hueGreen;
  static const demo = BitmapDescriptor.hueOrange;
  static const rejected = BitmapDescriptor.hueRed;
  static const evidence = BitmapDescriptor.hueViolet;

  /// Colour for a pin whose location integrity status came from the server.
  static double forIntegrity(String status, {required bool isDemo}) {
    if (isDemo) return demo;
    return switch (status) {
      'verified' => verified,
      'rejected' => rejected,
      _ => volunteer,
    };
  }
}

/// A muted map style that keeps FieldNote's paper-and-moss palette readable
/// underneath markers and geofence circles.
const fieldnoteMapStyle = '''
[
  {"elementType":"geometry","stylers":[{"color":"#f4f1e8"}]},
  {"elementType":"labels.icon","stylers":[{"visibility":"off"}]},
  {"elementType":"labels.text.fill","stylers":[{"color":"#17352c"}]},
  {"elementType":"labels.text.stroke","stylers":[{"color":"#f4f1e8"}]},
  {"featureType":"administrative","elementType":"geometry.stroke","stylers":[{"color":"#d9e3dc"}]},
  {"featureType":"landscape.natural","elementType":"geometry","stylers":[{"color":"#e9e5d9"}]},
  {"featureType":"poi","elementType":"geometry","stylers":[{"color":"#e3e8dd"}]},
  {"featureType":"poi.park","elementType":"geometry.fill","stylers":[{"color":"#d5e4c9"}]},
  {"featureType":"poi.park","elementType":"labels.text.fill","stylers":[{"color":"#6e8f5e"}]},
  {"featureType":"road","elementType":"geometry","stylers":[{"color":"#ffffff"}]},
  {"featureType":"road.arterial","elementType":"geometry","stylers":[{"color":"#fbfaf5"}]},
  {"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#f0e3d2"}]},
  {"featureType":"road.highway","elementType":"geometry.stroke","stylers":[{"color":"#e2d3bd"}]},
  {"featureType":"road","elementType":"labels.text.fill","stylers":[{"color":"#6b6b60"}]},
  {"featureType":"transit","elementType":"geometry","stylers":[{"color":"#e5e3d8"}]},
  {"featureType":"water","elementType":"geometry.fill","stylers":[{"color":"#bcd5d8"}]},
  {"featureType":"water","elementType":"labels.text.fill","stylers":[{"color":"#7d9ba0"}]}
]
''';

/// Every FieldNote map goes through this widget.
///
/// It exists mainly so that a build with no Google Maps key still renders
/// something honest: the caller passes the coordinate and distance facts it
/// would otherwise have shown as [fallback], and those stay on screen instead
/// of a blank grey rectangle. Nothing in the app depends on tiles being
/// available to function.
class FieldnoteMap extends StatefulWidget {
  const FieldnoteMap({
    super.key,
    required this.target,
    this.zoom = 15,
    this.height = 240,
    this.markers = const <Marker>{},
    this.circles = const <Circle>{},
    this.polylines = const <Polyline>{},
    this.onTap,
    this.onMapCreated,
    this.myLocationEnabled = false,
    this.interactive = true,
    this.fitBounds,
    this.fallback,
    this.mapType = MapType.normal,
    this.semanticLabel,
  });

  final LatLng target;
  final double zoom;
  final double height;
  final Set<Marker> markers;
  final Set<Circle> circles;
  final Set<Polyline> polylines;
  final ValueChanged<LatLng>? onTap;
  final ValueChanged<GoogleMapController>? onMapCreated;
  final bool myLocationEnabled;
  final bool interactive;

  /// Points the camera should frame once the map is ready. Useful when the
  /// interesting extent is a geofence circle or a spread of evidence pins
  /// rather than a single coordinate.
  final List<LatLng>? fitBounds;

  /// Shown instead of the map when no Maps key is configured.
  final Widget? fallback;
  final MapType mapType;
  final String? semanticLabel;

  @override
  State<FieldnoteMap> createState() => _FieldnoteMapState();
}

class _FieldnoteMapState extends State<FieldnoteMap> {
  GoogleMapController? _controller;
  bool _showFallback = false;

  @override
  void didUpdateWidget(FieldnoteMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    final bounds = widget.fitBounds;
    if (bounds != null && !listEquals(bounds, oldWidget.fitBounds)) {
      _frame(bounds);
    } else if (bounds == null &&
        (widget.target != oldWidget.target || widget.zoom != oldWidget.zoom)) {
      _focusTarget();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _frame(List<LatLng> points) async {
    final controller = _controller;
    if (controller == null || points.isEmpty) return;
    if (points.length == 1) {
      await controller.animateCamera(
        CameraUpdate.newLatLngZoom(points.single, widget.zoom),
      );
      return;
    }
    await controller.animateCamera(
      CameraUpdate.newLatLngBounds(boundsFor(points), 48),
    );
  }

  Future<void> _focusTarget() async {
    final controller = _controller;
    if (controller == null) return;
    await controller.animateCamera(
      CameraUpdate.newLatLngZoom(widget.target, widget.zoom),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!MapConfig.isConfigured) {
      return widget.fallback ?? const MapUnavailableNotice();
    }
    if (_showFallback) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          widget.fallback ?? const MapUnavailableNotice(),
          TextButton.icon(
            onPressed: () => setState(() => _showFallback = false),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry map'),
          ),
        ],
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        height: widget.height,
        width: double.infinity,
        child: Stack(
          children: [
            Semantics(
              label: widget.semanticLabel,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: widget.target,
                  zoom: widget.zoom,
                ),
                // Google's default style keeps street, locality and place labels
                // visible while someone chooses or checks an exact work site.
                markers: widget.markers,
                circles: widget.circles,
                polylines: widget.polylines,
                onTap: widget.onTap,
                mapType: widget.mapType,
                myLocationEnabled: widget.myLocationEnabled,
                myLocationButtonEnabled: widget.myLocationEnabled,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                compassEnabled: false,
                rotateGesturesEnabled: false,
                tiltGesturesEnabled: false,
                scrollGesturesEnabled: widget.interactive,
                zoomGesturesEnabled: widget.interactive,
                // Every map in FieldNote sits inside a scrolling column. Without an
                // eager recognizer the parent scrollable swallows the drag and the
                // map cannot be panned at all.
                gestureRecognizers: widget.interactive
                    ? <Factory<OneSequenceGestureRecognizer>>{
                        Factory<OneSequenceGestureRecognizer>(
                          EagerGestureRecognizer.new,
                        ),
                      }
                    : const <Factory<OneSequenceGestureRecognizer>>{},
                onMapCreated: (controller) {
                  _controller = controller;
                  widget.onMapCreated?.call(controller);
                  final bounds = widget.fitBounds;
                  if (bounds != null && bounds.length > 1) {
                    // The platform view needs a frame before it can measure the
                    // viewport a bounds animation is fitted against.
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _frame(bounds);
                    });
                  }
                },
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Material(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                child: IconButton(
                  tooltip: 'Map not loading? Show location details',
                  onPressed: () => setState(() {
                    _controller = null;
                    _showFallback = true;
                  }),
                  icon: const Icon(Icons.map_outlined),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shown wherever a map would be when no Maps key is configured.
class MapUnavailableNotice extends StatelessWidget {
  const MapUnavailableNotice({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      decoration: BoxDecoration(
        color: FieldnoteColors.mist.withValues(alpha: .45),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: FieldnoteColors.ink.withValues(alpha: .08)),
      ),
      child: Row(
        children: [
          const Icon(Icons.map_outlined, color: FieldnoteColors.moss),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message ??
                  'Map preview is unavailable. Location details are still shown below.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

/// A compact legend so a colour on a map always has a stated meaning.
class MapLegend extends StatelessWidget {
  const MapLegend({super.key, required this.entries});

  final List<({Color color, String label})> entries;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 6,
      children: [
        for (final entry in entries)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: entry.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(entry.label, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
      ],
    );
  }
}

/// A geofence or travel-radius ring.
Circle radiusCircle({
  required String id,
  required LatLng center,
  required double radiusMeters,
  Color color = FieldnoteColors.forest,
  int strokeWidth = 2,
}) => Circle(
  circleId: CircleId(id),
  center: center,
  radius: radiusMeters,
  fillColor: color.withValues(alpha: .12),
  strokeColor: color.withValues(alpha: .65),
  strokeWidth: strokeWidth,
);

LatLngBounds boundsFor(Iterable<LatLng> points) {
  final list = points.toList();
  if (list.isEmpty) {
    throw ArgumentError('boundsFor requires at least one point.');
  }
  var south = list.first.latitude;
  var north = list.first.latitude;
  var west = list.first.longitude;
  var east = list.first.longitude;
  for (final point in list.skip(1)) {
    south = math.min(south, point.latitude);
    north = math.max(north, point.latitude);
    west = math.min(west, point.longitude);
    east = math.max(east, point.longitude);
  }
  // A zero-area box makes the camera fit fail on some platforms.
  const pad = 0.0015;
  if (north - south < pad) {
    north += pad;
    south -= pad;
  }
  if (east - west < pad) {
    east += pad;
    west -= pad;
  }
  return LatLngBounds(
    southwest: LatLng(south, west),
    northeast: LatLng(north, east),
  );
}

/// Cardinal points around a geographic circle. Passing these to
/// [FieldnoteMap.fitBounds] keeps the complete radius visible when its center
/// or size changes.
List<LatLng> boundsPointsForRadius(LatLng center, double radiusMeters) {
  if (!radiusMeters.isFinite || radiusMeters <= 0) return [center];
  const metersPerLatitudeDegree = 111320.0;
  final latitudeDelta = radiusMeters / metersPerLatitudeDegree;
  final cosine = math.cos(center.latitude * math.pi / 180).abs();
  final longitudeDelta =
      radiusMeters / (metersPerLatitudeDegree * math.max(cosine, 0.01));
  return [
    LatLng(center.latitude + latitudeDelta, center.longitude),
    LatLng(center.latitude - latitudeDelta, center.longitude),
    LatLng(center.latitude, center.longitude + longitudeDelta),
    LatLng(center.latitude, center.longitude - longitudeDelta),
  ];
}

/// A zoom level that comfortably frames a circle of [radiusMeters].
double zoomForRadius(double radiusMeters) {
  if (!radiusMeters.isFinite || radiusMeters <= 0) return 15;
  // Roughly: each zoom level halves the metres covered by the viewport.
  final zoom = 16 - math.log(radiusMeters / 250) / math.ln2;
  return zoom.clamp(3.0, 18.0).toDouble();
}
