import 'dart:async';

import 'package:fieldnotes_client/fieldnotes_client.dart';
import 'package:flutter/material.dart';

import '../../../data/repositories/fieldnote_repository.dart';
import '../../core/fieldnote_map.dart';
import '../../core/fieldnote_theme.dart';
import '../../core/widgets.dart';

/// Where a campaign will be published, and how tightly it is fenced.
class CampaignPin {
  const CampaignPin({
    required this.latitude,
    required this.longitude,
    required this.locationName,
    required this.geofenceMeters,
    required this.isDeviceLocation,
  });

  final double latitude;
  final double longitude;
  final String locationName;
  final double geofenceMeters;

  /// True while the pin is still wherever the sponsor's own device is, rather
  /// than a place they chose deliberately.
  final bool isDeviceLocation;

  CampaignPin copyWith({
    double? latitude,
    double? longitude,
    String? locationName,
    double? geofenceMeters,
    bool? isDeviceLocation,
  }) => CampaignPin(
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    locationName: locationName ?? this.locationName,
    geofenceMeters: geofenceMeters ?? this.geofenceMeters,
    isDeviceLocation: isDeviceLocation ?? this.isDeviceLocation,
  );
}

/// Lets a sponsor publish a campaign anywhere, not just where they are
/// standing.
///
/// Before this existed the only way to set a campaign's coordinates was a
/// "use my current location" button, so an office-bound sponsor could not
/// publish work at a lake twelve kilometres away. It combines four things the
/// sponsor previously had to guess at: the pin, its name, the geofence size,
/// and how many volunteers could actually get there.
class CampaignPinPicker extends StatefulWidget {
  const CampaignPinPicker({
    super.key,
    required this.repository,
    required this.pin,
    required this.locationSelected,
    required this.onChanged,
    required this.onUseDeviceLocation,
    this.onSearchPendingChanged,
  });

  final FieldnoteRepository repository;
  final CampaignPin pin;
  final bool locationSelected;
  final ValueChanged<CampaignPin> onChanged;
  final Future<void> Function() onUseDeviceLocation;
  final ValueChanged<bool>? onSearchPendingChanged;

  @override
  State<CampaignPinPicker> createState() => _CampaignPinPickerState();
}

class _CampaignPinPickerState extends State<CampaignPinPicker> {
  final _search = TextEditingController();

  Timer? _searchDebounce;
  Timer? _reachDebounce;
  List<PlaceSuggestion> _suggestions = const [];
  String? _searchMessage;
  bool _searching = false;
  bool _usingDeviceLocation = false;
  bool _placeSearchAvailable = false;
  CampaignReach? _reach;
  bool _loadingReach = false;
  int _reachRequest = 0;
  int _geocodeRequest = 0;
  int _searchRequest = 0;
  int _pinVersion = 0;

  @override
  void initState() {
    super.initState();
    _checkPlaceSearch();
    if (widget.locationSelected) _scheduleReach();
  }

  @override
  void didUpdateWidget(CampaignPinPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.locationSelected &&
        (oldWidget.pin.latitude != widget.pin.latitude ||
            oldWidget.pin.longitude != widget.pin.longitude ||
            oldWidget.pin.locationName != widget.pin.locationName ||
            !oldWidget.locationSelected)) {
      ++_pinVersion;
      _searchDebounce?.cancel();
      ++_searchRequest;
      _search.text = widget.pin.locationName;
      _suggestions = const [];
      _searchMessage = null;
    }
    if (_placeSearchAvailable &&
        !widget.locationSelected &&
        oldWidget.pin.locationName != widget.pin.locationName) {
      _search.clear();
      _suggestProposalPlace();
    }
    if (widget.locationSelected &&
        (!oldWidget.locationSelected ||
            oldWidget.pin.latitude != widget.pin.latitude ||
            oldWidget.pin.longitude != widget.pin.longitude)) {
      _scheduleReach();
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _reachDebounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  Future<void> _checkPlaceSearch() async {
    try {
      final available = await widget.repository.placeSearchAvailable();
      if (!mounted) return;
      setState(() => _placeSearchAvailable = available);
      if (available && !widget.locationSelected) _suggestProposalPlace();
    } on Object {
      // Leaving search hidden is the correct outcome when the check fails.
    }
  }

  void _suggestProposalPlace() {
    final proposed = widget.pin.locationName.trim();
    if (proposed.length < 3 || _search.text.isNotEmpty) return;
    _search.text = proposed;
    unawaited(_runSearch(proposed));
  }

  void _onQueryChanged(String value) {
    widget.onSearchPendingChanged?.call(
      widget.locationSelected && value.trim() != widget.pin.locationName.trim(),
    );
    _searchDebounce?.cancel();
    _searchRequest++;
    _geocodeRequest++;
    setState(() {
      _searchMessage = null;
      _suggestions = const [];
    });
    if (value.trim().length < 3) {
      return;
    }
    // Places autocomplete is billed per session; do not fire on every keypress.
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      unawaited(_runSearch(value.trim()));
    });
  }

  Future<void> _runSearch(String query) async {
    final request = ++_searchRequest;
    setState(() => _searching = true);
    try {
      final results = await widget.repository.searchPlaces(
        query,
        biasLatitude: widget.locationSelected ? widget.pin.latitude : null,
        biasLongitude: widget.locationSelected ? widget.pin.longitude : null,
      );
      if (mounted && request == _searchRequest) {
        setState(() {
          _suggestions = results;
          _searchMessage = results.isEmpty
              ? 'No matching places. Try a city, street, or landmark.'
              : null;
        });
      }
    } on Object {
      if (mounted && request == _searchRequest) {
        setState(() {
          _suggestions = const [];
          _searchMessage = 'Place search is unavailable. Use the map or GPS.';
        });
      }
    } finally {
      if (mounted && request == _searchRequest) {
        setState(() => _searching = false);
      }
    }
  }

  Future<void> _choosePlace(PlaceSuggestion suggestion) async {
    _searchDebounce?.cancel();
    ++_searchRequest;
    final request = ++_geocodeRequest;
    final pinVersion = _pinVersion;
    FocusScope.of(context).unfocus();
    setState(() {
      _suggestions = const [];
      _searchMessage = null;
    });
    try {
      final place = await widget.repository.resolvePlace(suggestion.placeId);
      if (!mounted || request != _geocodeRequest || pinVersion != _pinVersion) {
        return;
      }
      final label = place.address.trim().isNotEmpty
          ? place.address.trim()
          : place.name.isEmpty
          ? suggestion.primaryText
          : place.name;
      setState(() => _search.text = label);
      widget.onChanged(
        widget.pin.copyWith(
          latitude: place.latitude,
          longitude: place.longitude,
          locationName: label,
          isDeviceLocation: false,
        ),
      );
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error is FieldnoteException
                ? error.message
                : 'That place could not be resolved. Drag the pin instead.',
          ),
        ),
      );
    }
  }

  Future<void> _pinToDeviceLocation() async {
    if (_usingDeviceLocation) return;
    setState(() => _usingDeviceLocation = true);
    try {
      await widget.onUseDeviceLocation();
    } finally {
      if (mounted) setState(() => _usingDeviceLocation = false);
    }
  }

  /// Moves the pin and renames it from reverse geocoding, unless the sponsor
  /// has already typed a name they care about.
  Future<void> _movePin(LatLng point) async {
    _searchDebounce?.cancel();
    ++_searchRequest;
    final coordinates =
        '${point.latitude.toStringAsFixed(5)}, '
        '${point.longitude.toStringAsFixed(5)}';
    _search.text = coordinates;
    setState(() {
      _suggestions = const [];
      _searchMessage = null;
    });
    widget.onChanged(
      widget.pin.copyWith(
        latitude: point.latitude,
        longitude: point.longitude,
        locationName: coordinates,
        isDeviceLocation: false,
      ),
    );
    final request = ++_geocodeRequest;
    try {
      final place = await widget.repository.describeCoordinates(
        point.latitude,
        point.longitude,
      );
      if (!mounted ||
          request != _geocodeRequest ||
          place == null ||
          widget.pin.latitude != point.latitude ||
          widget.pin.longitude != point.longitude) {
        return;
      }
      final label = place.address.trim().isNotEmpty
          ? place.address.trim()
          : place.name.trim();
      if (label.isEmpty) return;
      _search.text = label;
      widget.onChanged(
        widget.pin.copyWith(
          latitude: point.latitude,
          longitude: point.longitude,
          locationName: label,
          isDeviceLocation: false,
        ),
      );
    } on Object {
      // The coordinates are already applied; only the label is missing.
    }
  }

  Future<void> _openFullScreenMap() async {
    final pin = await Navigator.of(context).push<CampaignPin>(
      MaterialPageRoute(
        builder: (_) => _FullScreenCampaignMap(
          repository: widget.repository,
          initialPin: widget.pin,
          locationSelected: widget.locationSelected,
          placeSearchAvailable: _placeSearchAvailable,
        ),
      ),
    );
    if (mounted && pin != null) widget.onChanged(pin);
  }

  void _scheduleReach() {
    _reachDebounce?.cancel();
    _reachDebounce = Timer(const Duration(milliseconds: 600), () {
      unawaited(_loadReach());
    });
  }

  Future<void> _loadReach() async {
    if (!widget.locationSelected) return;
    final request = ++_reachRequest;
    setState(() => _loadingReach = true);
    try {
      final reach = await widget.repository.previewReach(
        widget.pin.latitude,
        widget.pin.longitude,
      );
      if (mounted && request == _reachRequest) setState(() => _reach = reach);
    } on Object {
      if (mounted && request == _reachRequest) setState(() => _reach = null);
    } finally {
      if (mounted && request == _reachRequest) {
        setState(() => _loadingReach = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final point = LatLng(widget.pin.latitude, widget.pin.longitude);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Where will this happen?',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        Text(
          'Search for a place or move the pin to the exact work site. The ring is the check-in '
          'geofence volunteers must stand inside.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        if (!widget.locationSelected &&
            widget.pin.locationName.trim().isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            'From your brief: ${widget.pin.locationName}. Choose a search result or set a pin to confirm it.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _openFullScreenMap,
          icon: const Icon(Icons.map_outlined),
          label: const Text('Choose on map'),
        ),
        const SizedBox(height: 12),
        if (_placeSearchAvailable) ...[
          FieldnoteTextField(
            controller: _search,
            onChanged: _onQueryChanged,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              labelText: 'Search for a place',
              hintText: 'City, street, or landmark…',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searching
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : _search.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear',
                      icon: const Icon(Icons.close),
                      onPressed: () => setState(() {
                        _search.clear();
                        _suggestions = const [];
                        _searchMessage = null;
                      }),
                    ),
            ),
          ),
          if (_suggestions.isNotEmpty) ...[
            const SizedBox(height: 8),
            Material(
              color: Colors.white,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(
                  color: FieldnoteColors.ink.withValues(alpha: .1),
                ),
              ),
              child: Column(
                children: [
                  for (final suggestion in _suggestions.take(5))
                    ListTile(
                      dense: true,
                      leading: const Icon(Icons.place_outlined, size: 20),
                      title: Text(suggestion.primaryText),
                      subtitle: suggestion.secondaryText.isEmpty
                          ? null
                          : Text(suggestion.secondaryText),
                      onTap: () => _choosePlace(suggestion),
                    ),
                ],
              ),
            ),
          ],
          if (_searchMessage != null) ...[
            const SizedBox(height: 8),
            Text(_searchMessage!),
          ],
          const SizedBox(height: 14),
        ],
        if (widget.locationSelected)
          FieldnoteMap(
            target: point,
            zoom: zoomForRadius(widget.pin.geofenceMeters),
            fitBounds: boundsPointsForRadius(
              point,
              widget.pin.geofenceMeters,
            ),
            height: 280,
            semanticLabel: 'Draggable campaign pin with its check-in geofence',
            onTap: _movePin,
            markers: {
              Marker(
                markerId: const MarkerId('campaign-pin'),
                position: point,
                draggable: true,
                onDragEnd: _movePin,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  FieldnoteMapPalette.campaign,
                ),
                infoWindow: InfoWindow(title: widget.pin.locationName),
              ),
            },
            circles: {
              radiusCircle(
                id: 'geofence',
                center: point,
                radiusMeters: widget.pin.geofenceMeters,
              ),
              // Anonymised volunteer coverage: each bucket holds at least three
              // people and is rounded to roughly a kilometre by the server.
              for (
                var index = 0;
                index < (_reach?.coverageCells.length ?? 0);
                index++
              )
                radiusCircle(
                  id: 'coverage-$index',
                  center: LatLng(
                    _reach!.coverageCells[index].latitude,
                    _reach!.coverageCells[index].longitude,
                  ),
                  radiusMeters:
                      350 +
                      (_reach!.coverageCells[index].volunteerCount * 120)
                          .clamp(0, 900)
                          .toDouble(),
                  color: FieldnoteColors.moss,
                  strokeWidth: 1,
                ),
            },
            fallback: MapUnavailableNotice(
              message:
                  'Map preview is off. Campaign pin: '
                  '${widget.pin.latitude.toStringAsFixed(5)}, '
                  '${widget.pin.longitude.toStringAsFixed(5)} with a '
                  '${widget.pin.geofenceMeters.round()} m geofence.',
            ),
          )
        else
          const EmptyPanel(
            icon: Icons.map_outlined,
            title: 'Choose the campaign site',
            message:
                'Select a place result, choose on the map, or use your device location.',
          ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Icon(Icons.place_outlined, size: 17),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                !widget.locationSelected
                    ? 'Location not selected'
                    : widget.pin.locationName.isEmpty
                    ? 'Unnamed pin'
                    : widget.pin.locationName,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            if (widget.pin.isDeviceLocation)
              const StatusPill(
                label: 'Your device location',
                color: FieldnoteColors.clay,
                icon: Icons.my_location,
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Check-in geofence · ${widget.pin.geofenceMeters.round()} m',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Slider(
          value: widget.pin.geofenceMeters.clamp(50, 1000),
          min: 50,
          max: 1000,
          divisions: 19,
          label: '${widget.pin.geofenceMeters.round()} m',
          onChanged: (value) =>
              widget.onChanged(widget.pin.copyWith(geofenceMeters: value)),
        ),
        Text(
          'Volunteers must be inside this ring, allowing for their GPS '
          'accuracy, before they can check in.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 14),
        OutlinedButton.icon(
          onPressed: _usingDeviceLocation ? null : _pinToDeviceLocation,
          icon: _usingDeviceLocation
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.my_location),
          label: Text(
            _usingDeviceLocation
                ? 'Finding my location…'
                : 'Pin to my location',
          ),
        ),
        const SizedBox(height: 16),
        if (widget.locationSelected) _reachCard(context),
      ],
    );
  }

  Widget _reachCard(BuildContext context) {
    final reach = _reach;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FieldnoteColors.acid.withValues(alpha: .3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.groups_outlined, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Volunteer reach at this pin',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (_loadingReach)
                const SizedBox.square(
                  dimension: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (reach == null)
            Text(
              _loadingReach
                  ? 'Checking who could reach this pin…'
                  : 'Reach could not be estimated for this pin.',
              style: Theme.of(context).textTheme.bodySmall,
            )
          else ...[
            Text(reach.summary),
            if (reach.medianDistanceKm != null) ...[
              const SizedBox(height: 8),
              Text(
                'Median distance '
                '${reach.medianDistanceKm!.toStringAsFixed(1)} km.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'Counts come from volunteers who published availability and a '
              'travel radius. Individual volunteer locations are never shown '
              'to sponsors.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}

class _FullScreenCampaignMap extends StatefulWidget {
  const _FullScreenCampaignMap({
    required this.repository,
    required this.initialPin,
    required this.locationSelected,
    required this.placeSearchAvailable,
  });

  final FieldnoteRepository repository;
  final CampaignPin initialPin;
  final bool locationSelected;
  final bool placeSearchAvailable;

  @override
  State<_FullScreenCampaignMap> createState() => _FullScreenCampaignMapState();
}

class _FullScreenCampaignMapState extends State<_FullScreenCampaignMap> {
  final _search = TextEditingController();
  Timer? _debounce;
  List<PlaceSuggestion> _suggestions = const [];
  late CampaignPin _pin;
  late bool _selected;
  bool _searching = false;
  String? _searchError;
  int _geocodeRequest = 0;

  @override
  void initState() {
    super.initState();
    _pin = widget.initialPin;
    _selected = widget.locationSelected;
    if (_selected) _search.text = _pin.locationName;
    if (!_selected && widget.initialPin.locationName.trim().length >= 3) {
      _search.text = widget.initialPin.locationName;
      if (widget.placeSearchAvailable) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) unawaited(_runSearch(_search.text));
        });
      }
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _geocodeRequest++;
    if (value.trim().length < 3) {
      setState(() => _suggestions = const []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 350), () {
      unawaited(_runSearch(value.trim()));
    });
  }

  Future<void> _runSearch(String query) async {
    setState(() {
      _searching = true;
      _searchError = null;
    });
    try {
      final results = await widget.repository.searchPlaces(
        query,
        biasLatitude: _selected ? _pin.latitude : null,
        biasLongitude: _selected ? _pin.longitude : null,
      );
      if (mounted && _search.text.trim() == query) {
        setState(() => _suggestions = results);
      }
    } on Object {
      if (mounted) {
        setState(
          () => _searchError =
              'Place search is unavailable. Tap the map to set a pin.',
        );
      }
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  Future<void> _choosePlace(PlaceSuggestion suggestion) async {
    _debounce?.cancel();
    final request = ++_geocodeRequest;
    FocusScope.of(context).unfocus();
    try {
      final place = await widget.repository.resolvePlace(suggestion.placeId);
      if (!mounted || request != _geocodeRequest) return;
      setState(() {
        _selected = true;
        _pin = _pin.copyWith(
          latitude: place.latitude,
          longitude: place.longitude,
          locationName: place.address.trim().isNotEmpty
              ? place.address.trim()
              : place.name.trim().isNotEmpty
              ? place.name.trim()
              : suggestion.primaryText,
          isDeviceLocation: false,
        );
        _search.text = _pin.locationName;
        _suggestions = const [];
      });
    } on Object {
      if (mounted) {
        setState(
          () => _searchError =
              'That place could not be opened. Choose another result.',
        );
      }
    }
  }

  Future<void> _movePin(LatLng point) async {
    _debounce?.cancel();
    final request = ++_geocodeRequest;
    setState(() {
      _selected = true;
      _suggestions = const [];
      _pin = _pin.copyWith(
        latitude: point.latitude,
        longitude: point.longitude,
        locationName:
            '${point.latitude.toStringAsFixed(5)}, '
            '${point.longitude.toStringAsFixed(5)}',
        isDeviceLocation: false,
      );
      _search.text = _pin.locationName;
    });
    try {
      final place = await widget.repository.describeCoordinates(
        point.latitude,
        point.longitude,
      );
      if (!mounted || request != _geocodeRequest || place == null) return;
      final name = place.address.trim().isNotEmpty
          ? place.address.trim()
          : place.name.trim();
      if (name.isNotEmpty) {
        setState(() {
          _pin = _pin.copyWith(locationName: name);
          _search.text = name;
        });
      }
    } on Object {
      // The chosen coordinates remain usable when reverse geocoding fails.
    }
  }

  @override
  Widget build(BuildContext context) {
    final point = LatLng(_pin.latitude, _pin.longitude);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('Choose campaign location')),
      body: SafeArea(
        child: Column(
          children: [
            if (widget.placeSearchAvailable)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: FieldnoteTextField(
                  controller: _search,
                  onChanged: _onQueryChanged,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    labelText: 'Search for a place',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searching
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : null,
                  ),
                ),
              ),
            if (_searchError != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(_searchError!),
              ),
            if (_suggestions.isNotEmpty)
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 230),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _suggestions.length > 4 ? 4 : _suggestions.length,
                  itemBuilder: (context, index) {
                    final suggestion = _suggestions[index];
                    return ListTile(
                      dense: true,
                      leading: const Icon(Icons.place_outlined),
                      title: Text(suggestion.primaryText),
                      subtitle: suggestion.secondaryText.isEmpty
                          ? null
                          : Text(suggestion.secondaryText),
                      onTap: () => _choosePlace(suggestion),
                    );
                  },
                ),
              ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) => FieldnoteMap(
                  target: point,
                  zoom: 15,
                  height: constraints.maxHeight,
                  semanticLabel:
                      'Full-screen campaign map. Tap to set the pin.',
                  onTap: _movePin,
                  markers: {
                    Marker(
                      markerId: const MarkerId('campaign-pin-full'),
                      position: point,
                      draggable: true,
                      onDragEnd: _movePin,
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                        FieldnoteMapPalette.campaign,
                      ),
                    ),
                  },
                  circles: {
                    radiusCircle(
                      id: 'geofence-full',
                      center: point,
                      radiusMeters: _pin.geofenceMeters,
                    ),
                  },
                  fallback: MapUnavailableNotice(
                    message: widget.placeSearchAvailable
                        ? 'Map tiles are unavailable. Search for a place here, or go back to use device GPS.'
                        : 'Map tiles are unavailable. Go back to use device GPS.',
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selected
                        ? _pin.locationName
                        : 'Search for a place or tap the map to choose a site.',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _selected
                          ? () => Navigator.pop(context, _pin)
                          : null,
                      icon: const Icon(Icons.check),
                      label: const Text('Use this pin'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
