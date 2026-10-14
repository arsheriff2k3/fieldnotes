import 'dart:async';

import 'package:fieldnotes_client/fieldnotes_client.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/repositories/fieldnote_repository.dart';
import '../../data/services/device_location_service.dart';
import '../../l10n/l10n.dart';
import 'error_messages.dart';
import 'fieldnote_map.dart';
import 'fieldnote_theme.dart';
import 'route_geometry.dart';

/// Inspects a campaign, evidence, or profile coordinate without leaving the app.
class PlaceMapScreen extends StatelessWidget {
  const PlaceMapScreen({
    super.key,
    required this.title,
    required this.latitude,
    required this.longitude,
    this.geofenceMeters,
  });

  final String title;
  final double latitude;
  final double longitude;
  final double? geofenceMeters;

  @override
  Widget build(BuildContext context) {
    final point = LatLng(latitude, longitude);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) => FieldnoteMap(
                  target: point,
                  height: constraints.maxHeight,
                  zoom: 16,
                  markers: {
                    Marker(
                      markerId: const MarkerId('place'),
                      position: point,
                      infoWindow: InfoWindow(title: title),
                    ),
                  },
                  circles: {
                    if (geofenceMeters != null)
                      radiusCircle(
                        id: 'geofence',
                        center: point,
                        radiusMeters: geofenceMeters!,
                        color: FieldnoteColors.forest,
                      ),
                  },
                  fallback: MapUnavailableNotice(
                    message: context.l10n.corePlaceLocation(
                      '${latitude.toStringAsFixed(5)}, '
                      '${longitude.toStringAsFixed(5)}',
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '$title · ${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Road route preview and foreground live travel guidance inside FieldNote.
class TravelMapScreen extends StatefulWidget {
  const TravelMapScreen({
    super.key,
    required this.campaign,
    required this.repository,
    required this.canStartTravel,
  });

  final Campaign campaign;
  final FieldnoteRepository repository;
  final bool canStartTravel;

  @override
  State<TravelMapScreen> createState() => _TravelMapScreenState();
}

class _TravelMapScreenState extends State<TravelMapScreen> {
  final _locationService = DeviceLocationService();
  StreamSubscription<DeviceLocation>? _subscription;
  DeviceLocation? _here;
  TravelRoute? _route;
  List<LatLng> _points = const [];
  double _geometryLength = 0;
  String _mode = 'WALK';

  /// A message, or an error object worded in [build] for the current locale.
  Object? _error;
  bool _loading = true;
  bool _starting = false;
  bool _travelling = false;
  DateTime? _lastRouteRequest;
  int _routeRequest = 0;

  @override
  void initState() {
    super.initState();
    unawaited(_initialize());
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _initialize() async {
    try {
      final location = await _locationService.current();
      if (!mounted) return;
      setState(() => _here = location);
      await _loadRoute(location);
    } on Object catch (error) {
      if (mounted) {
        setState(() {
          _error = error;
          _loading = false;
        });
      }
    }
  }

  Future<void> _loadRoute(
    DeviceLocation location, {
    bool preserveCurrentRoute = false,
  }) async {
    final campaignId = widget.campaign.id;
    if (campaignId == null) return;
    final request = ++_routeRequest;
    _lastRouteRequest = DateTime.now();
    setState(() {
      _loading = true;
      _error = null;
      if (!preserveCurrentRoute) {
        _route = null;
        _points = const [];
        _geometryLength = 0;
      }
    });
    try {
      final route = await widget.repository.travelRoute(
        campaignId: campaignId,
        originLatitude: location.latitude,
        originLongitude: location.longitude,
        travelMode: _mode,
      );
      final points = decodeRoutePolyline(route.encodedPolyline);
      if (points.length < 2) {
        throw const FormatException('The road route is incomplete.');
      }
      if (!mounted || request != _routeRequest) return;
      setState(() {
        _route = route;
        _points = points;
        _geometryLength = routeProgress(points, points.first).remainingMeters;
      });
    } on Object catch (error) {
      if (mounted && request == _routeRequest) {
        setState(
          () => _error = error is FieldnoteException
              ? error
              : _TravelNotice.routeUnavailable,
        );
      }
    } finally {
      if (mounted && request == _routeRequest) setState(() => _loading = false);
    }
  }

  Future<void> _start() async {
    if (_travelling || _starting || !widget.canStartTravel) return;
    final here = _here;
    if (here == null || _route == null) return;
    setState(() {
      _starting = true;
      _error = null;
    });
    try {
      final latest = await widget.repository.refreshCampaignReadiness(
        widget.campaign.id!,
      );
      if (!mounted) return;
      if (latest.readinessState != 'confirmed' ||
          latest.revision != widget.campaign.revision) {
        setState(() => _error = _TravelNotice.detailsChanged);
        return;
      }
    } on Object {
      if (mounted) {
        setState(() => _error = _TravelNotice.confirmFailed);
      }
      return;
    } finally {
      if (mounted) setState(() => _starting = false);
    }
    if (!mounted) return;
    setState(() => _travelling = true);
    _subscription = _locationService.watch().listen(
      (location) {
        if (!mounted) return;
        setState(() => _here = location);
        final progress = routeProgress(
          _points,
          LatLng(location.latitude, location.longitude),
        );
        final lastRequest = _lastRouteRequest;
        if (progress.offRouteMeters > 100 + location.accuracyMeters &&
            !_loading &&
            (lastRequest == null ||
                DateTime.now().difference(lastRequest) >
                    const Duration(minutes: 1))) {
          unawaited(_loadRoute(location, preserveCurrentRoute: true));
        }
      },
      onError: (Object error) {
        unawaited(_subscription?.cancel());
        _subscription = null;
        if (mounted) {
          setState(() {
            _travelling = false;
            _error = error;
          });
        }
      },
      onDone: () {
        if (mounted) setState(() => _travelling = false);
      },
    );
  }

  Future<void> _stop() async {
    await _subscription?.cancel();
    _subscription = null;
    if (mounted) setState(() => _travelling = false);
  }

  @override
  Widget build(BuildContext context) {
    final destination = LatLng(
      widget.campaign.latitude,
      widget.campaign.longitude,
    );
    final here = _here == null
        ? null
        : LatLng(_here!.latitude, _here!.longitude);
    final progress = here == null || _points.isEmpty
        ? null
        : routeProgress(_points, here);
    final route = _route;
    final remaining = progress?.remainingMeters;
    final remainingFraction = remaining == null || _geometryLength <= 0
        ? null
        : (remaining / _geometryLength).clamp(0.0, 1.0);
    final etaMinutes = route == null || remainingFraction == null
        ? null
        : (route.durationSeconds * remainingFraction / 60).ceil();
    final distanceTravelled = route == null || remainingFraction == null
        ? 0.0
        : route.distanceMeters * (1 - remainingFraction);
    final roadDistanceRemaining = route == null || remainingFraction == null
        ? null
        : route.distanceMeters * remainingFraction;
    var stepIndex = route == null || route.steps.isEmpty
        ? 0
        : route.steps.length - 1;
    if (route != null) {
      var cumulative = 0;
      for (var index = 0; index < route.steps.length; index++) {
        cumulative += route.steps[index].distanceMeters;
        if (distanceTravelled <= cumulative) {
          stepIndex = index;
          break;
        }
      }
    }
    final arrived =
        here != null &&
        distanceBetweenPoints(here, destination) <=
            widget.campaign.geofenceMeters;
    final offRoute =
        progress != null &&
        _here != null &&
        progress.offRouteMeters > 100 + _here!.accuracyMeters;
    final l10n = context.l10n;
    final locale = context.localeTag;
    String km(num meters) => NumberFormat.decimalPatternDigits(
      locale: locale,
      decimalDigits: 1,
    ).format(meters / 1000);
    final error = _error;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.coreTravelTitle)),
      body: SafeArea(
        child: Column(
          children: [
            if (!_travelling)
              Padding(
                padding: const EdgeInsets.all(12),
                child: SegmentedButton<String>(
                  segments: [
                    ButtonSegment(
                      value: 'WALK',
                      label: Text(l10n.coreTravelWalk),
                    ),
                    ButtonSegment(
                      value: 'DRIVE',
                      label: Text(l10n.coreTravelDrive),
                    ),
                    ButtonSegment(
                      value: 'BICYCLE',
                      label: Text(l10n.coreTravelCycle),
                    ),
                  ],
                  selected: {_mode},
                  onSelectionChanged: (value) {
                    setState(() => _mode = value.first);
                    if (_here != null) unawaited(_loadRoute(_here!));
                  },
                ),
              ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) => FieldnoteMap(
                  target: _travelling && here != null ? here : destination,
                  height: constraints.maxHeight,
                  fitBounds: _travelling
                      ? null
                      : [?here, destination, ..._points],
                  myLocationEnabled: _travelling,
                  markers: {
                    Marker(
                      markerId: const MarkerId('destination'),
                      position: destination,
                      infoWindow: InfoWindow(
                        title: widget.campaign.locationName,
                      ),
                    ),
                    if (here != null)
                      Marker(
                        markerId: const MarkerId('current'),
                        position: here,
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                          FieldnoteMapPalette.volunteer,
                        ),
                        infoWindow: InfoWindow(
                          title: l10n.coreTravelYourPosition,
                        ),
                      ),
                  },
                  polylines: {
                    if (_points.length > 1)
                      Polyline(
                        polylineId: const PolylineId('road-route'),
                        points: _points,
                        width: 6,
                        color: FieldnoteColors.forest,
                      ),
                  },
                  circles: {
                    radiusCircle(
                      id: 'geofence',
                      center: destination,
                      radiusMeters: widget.campaign.geofenceMeters,
                      color: FieldnoteColors.moss,
                    ),
                  },
                  fallback: MapUnavailableNotice(
                    message: l10n.coreTravelFallback(
                      widget.campaign.locationName,
                    ),
                  ),
                ),
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.38,
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      widget.campaign.locationName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (_loading) const LinearProgressIndicator(),
                    if (error != null)
                      Text(
                        switch (error) {
                          _TravelNotice.routeUnavailable =>
                            l10n.coreTravelRouteUnavailable,
                          _TravelNotice.detailsChanged =>
                            l10n.coreTravelDetailsChanged,
                          _TravelNotice.confirmFailed =>
                            l10n.coreTravelConfirmFailed,
                          _ => userMessageFor(
                            error,
                            context: context,
                            fallback: l10n.coreTravelRouteUnavailable,
                          ),
                        },
                        style: TextStyle(color: context.fieldnoteColors.clay),
                      ),
                    if (route != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        offRoute
                            ? l10n.coreTravelOffRoute
                            : roadDistanceRemaining == null
                            ? l10n.coreTravelRouteSummary(
                                km(route.distanceMeters),
                                (route.durationSeconds / 60).ceil(),
                              )
                            : l10n.coreTravelRemaining(
                                km(roadDistanceRemaining),
                                etaMinutes ?? 0,
                              ),
                      ),
                      if (route.steps.isNotEmpty && !offRoute)
                        Text(
                          route.steps[stepIndex].instruction,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      if (route.steps.isNotEmpty)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: () => showModalBottomSheet<void>(
                              context: context,
                              isScrollControlled: true,
                              useSafeArea: true,
                              showDragHandle: true,
                              builder: (sheetContext) => DraggableScrollableSheet(
                                expand: false,
                                initialChildSize: 0.42,
                                minChildSize: 0.25,
                                maxChildSize: 0.78,
                                builder: (context, scrollController) => Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        20,
                                        0,
                                        8,
                                        8,
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              l10n.coreTravelRouteSteps,
                                              style: Theme.of(
                                                context,
                                              ).textTheme.titleLarge,
                                            ),
                                          ),
                                          IconButton(
                                            tooltip: l10n.coreTravelCloseSteps,
                                            onPressed: () =>
                                                Navigator.pop(sheetContext),
                                            icon: const Icon(Icons.close),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: ListView.separated(
                                        controller: scrollController,
                                        padding: const EdgeInsets.fromLTRB(
                                          12,
                                          0,
                                          12,
                                          24,
                                        ),
                                        itemCount: route.steps.length,
                                        separatorBuilder: (_, _) =>
                                            const Divider(height: 1),
                                        itemBuilder: (context, index) =>
                                            ListTile(
                                              leading: Text('${index + 1}'),
                                              title: Text(
                                                route.steps[index].instruction,
                                              ),
                                              subtitle: Text(
                                                l10n.coreTravelStepDistance(
                                                  NumberFormat.decimalPattern(
                                                    locale,
                                                  ).format(
                                                    route
                                                        .steps[index]
                                                        .distanceMeters,
                                                  ),
                                                ),
                                              ),
                                              selected: index == stepIndex,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            child: Text(l10n.coreTravelViewSteps),
                          ),
                        ),
                    ],
                    if (arrived) Text(l10n.coreTravelArrived),
                    if (!widget.canStartTravel) Text(l10n.coreTravelJoinFirst),
                    const SizedBox(height: 8),
                    FilledButton.icon(
                      onPressed: _travelling
                          ? _stop
                          : !widget.canStartTravel ||
                                route == null ||
                                _loading ||
                                _starting
                          ? null
                          : _start,
                      icon: Icon(
                        _travelling
                            ? Icons.stop_circle_outlined
                            : Icons.navigation_outlined,
                      ),
                      label: Text(
                        _travelling
                            ? l10n.coreTravelStop
                            : l10n.coreTravelStart,
                      ),
                    ),
                    if (!_travelling &&
                        _here != null &&
                        !_loading &&
                        route == null)
                      TextButton(
                        onPressed: () => _loadRoute(_here!),
                        child: Text(l10n.coreTravelRetryRoute),
                      ),
                    if (_here == null)
                      TextButton(
                        onPressed: _initialize,
                        child: Text(l10n.coreTravelRetryLocation),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Travel-screen notices worded in [TravelMapScreen]'s build.
enum _TravelNotice {
  routeUnavailable,
  detailsChanged,
  confirmFailed,
}
