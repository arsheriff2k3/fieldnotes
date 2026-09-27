import 'package:flutter/material.dart';

import '../../core/fieldnote_map.dart';
import '../../core/fieldnote_theme.dart';

/// Lets a volunteer choose the centre of their travel area on a full screen
/// map. The caller saves the returned point with the rest of the form.
class VolunteerAreaMapScreen extends StatefulWidget {
  const VolunteerAreaMapScreen({
    super.key,
    required this.radiusKm,
    this.initialPoint,
  });

  final double radiusKm;
  final LatLng? initialPoint;

  @override
  State<VolunteerAreaMapScreen> createState() => _VolunteerAreaMapScreenState();
}

class _VolunteerAreaMapScreenState extends State<VolunteerAreaMapScreen> {
  LatLng? _point;

  @override
  void initState() {
    super.initState();
    _point = widget.initialPoint;
  }

  @override
  Widget build(BuildContext context) {
    final point = _point;
    final center = point ?? const LatLng(20.5937, 78.9629);
    final radiusMeters = widget.radiusKm * 1000;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose travel area'),
        actions: [
          IconButton(
            tooltip: 'Minimize map',
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.fullscreen_exit),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) => FieldnoteMap(
          target: center,
          zoom: point == null ? 5 : zoomForRadius(radiusMeters),
          height: constraints.maxHeight,
          semanticLabel:
              'Full screen map. Tap or drag to choose your travel area.',
          onTap: (value) => setState(() => _point = value),
          markers: point == null
              ? const {}
              : {
                  Marker(
                    markerId: const MarkerId('travel-area'),
                    position: point,
                    draggable: true,
                    onDragEnd: (value) => setState(() => _point = value),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      FieldnoteMapPalette.volunteer,
                    ),
                    infoWindow: const InfoWindow(title: 'Your travel area'),
                  ),
                },
          circles: point == null
              ? const {}
              : {
                  radiusCircle(
                    id: 'travel-radius',
                    center: point,
                    radiusMeters: radiusMeters,
                    color: FieldnoteColors.forest,
                  ),
                },
          fallback: const MapUnavailableNotice(
            message:
                'The map is unavailable. Return to Availability and use your current GPS area.',
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              point == null
                  ? 'Tap the map to place your travel area pin.'
                  : 'Pin selected · ${widget.radiusKm.round()} km travel radius',
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: point == null
                    ? null
                    : () => Navigator.of(context).pop(point),
                icon: const Icon(Icons.check),
                label: const Text('Use this area'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
