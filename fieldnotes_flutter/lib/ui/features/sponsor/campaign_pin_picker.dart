import 'dart:async';

import 'package:fieldnotes_client/fieldnotes_client.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/repositories/fieldnote_repository.dart';
import '../../../l10n/l10n.dart';
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
              ? context.l10n.sponsorPinPickerNoMatches
              : null;
        });
      }
    } on Object {
      if (mounted && request == _searchRequest) {
        setState(() {
          _suggestions = const [];
          _searchMessage = context.l10n.sponsorPinPickerSearchUnavailable;
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
                : context.l10n.sponsorPinPickerResolveFailed,
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
    final l10n = context.l10n;
    final point = LatLng(widget.pin.latitude, widget.pin.longitude);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.sponsorPinPickerTitle,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: FieldnoteSpacing.xxs),
        Text(
          l10n.sponsorPinPickerIntro,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        if (!widget.locationSelected &&
            widget.pin.locationName.trim().isNotEmpty) ...[
          const SizedBox(height: FieldnoteSpacing.sm),
          Text(
            l10n.sponsorPinPickerFromBrief(widget.pin.locationName),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
        const SizedBox(height: FieldnoteSpacing.sm),
        OutlinedButton.icon(
          onPressed: _openFullScreenMap,
          icon: const Icon(Icons.map_outlined),
          label: Text(l10n.sponsorPinPickerChooseOnMap),
        ),
        const SizedBox(height: FieldnoteSpacing.sm),
        if (_placeSearchAvailable) ...[
          FieldnoteTextField(
            controller: _search,
            onChanged: _onQueryChanged,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              labelText: l10n.sponsorPinPickerSearchLabel,
              hintText: l10n.sponsorPinPickerSearchHint,
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
                      tooltip: l10n.sponsorPinPickerClear,
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
            const SizedBox(height: FieldnoteSpacing.xs),
            Material(
              color: context.fieldnoteColors.raised,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(
                  color: context.fieldnoteColors.ink.withValues(alpha: .1),
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
            const SizedBox(height: FieldnoteSpacing.xs),
            Text(_searchMessage!),
          ],
          const SizedBox(height: FieldnoteSpacing.md),
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
            semanticLabel: l10n.sponsorPinPickerMapSemantics,
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
              message: l10n.sponsorPinPickerMapFallback(
                widget.pin.latitude.toStringAsFixed(5),
                widget.pin.longitude.toStringAsFixed(5),
                widget.pin.geofenceMeters.round(),
              ),
            ),
          )
        else
          EmptyPanel(
            icon: Icons.map_outlined,
            title: l10n.sponsorPinPickerEmptyTitle,
            message: l10n.sponsorPinPickerEmptyMessage,
          ),
        const SizedBox(height: FieldnoteSpacing.sm),
        Row(
          children: [
            const Icon(Icons.place_outlined, size: 17),
            const SizedBox(width: FieldnoteSpacing.xs),
            Expanded(
              child: Text(
                !widget.locationSelected
                    ? l10n.sponsorPinPickerLocationNotSelected
                    : widget.pin.locationName.isEmpty
                    ? l10n.sponsorPinPickerUnnamedPin
                    : widget.pin.locationName,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            if (widget.pin.isDeviceLocation)
              StatusPill(
                label: l10n.sponsorPinPickerDeviceLocation,
                color: context.fieldnoteColors.clay,
                icon: Icons.my_location,
              ),
          ],
        ),
        const SizedBox(height: FieldnoteSpacing.md),
        Text(
          l10n.sponsorPinPickerGeofenceTitle(widget.pin.geofenceMeters.round()),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Slider(
          value: widget.pin.geofenceMeters.clamp(50, 1000),
          min: 50,
          max: 1000,
          divisions: 19,
          label: l10n.sponsorPinPickerGeofenceValue(
            widget.pin.geofenceMeters.round(),
          ),
          onChanged: (value) =>
              widget.onChanged(widget.pin.copyWith(geofenceMeters: value)),
        ),
        Text(
          l10n.sponsorPinPickerGeofenceHelp,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: FieldnoteSpacing.md),
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
                ? l10n.sponsorPinPickerFindingLocation
                : l10n.sponsorPinPickerPinToMyLocation,
          ),
        ),
        const SizedBox(height: FieldnoteSpacing.md),
        if (widget.locationSelected) _reachCard(context),
      ],
    );
  }

  Widget _reachCard(BuildContext context) {
    final l10n = context.l10n;
    final reach = _reach;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.fieldnoteColors.acid.withValues(alpha: .3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.groups_outlined, size: 20),
              const SizedBox(width: FieldnoteSpacing.xs),
              Expanded(
                child: Text(
                  l10n.sponsorPinPickerReachTitle,
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
          const SizedBox(height: FieldnoteSpacing.xs),
          if (reach == null)
            Text(
              _loadingReach
                  ? l10n.sponsorPinPickerReachChecking
                  : l10n.sponsorPinPickerReachUnavailable,
              style: Theme.of(context).textTheme.bodySmall,
            )
          else ...[
            Text(reach.summary),
            if (reach.medianDistanceKm != null) ...[
              const SizedBox(height: FieldnoteSpacing.xs),
              Text(
                l10n.sponsorPinPickerMedianDistance(
                  NumberFormat(
                    '0.0',
                    context.localeTag,
                  ).format(reach.medianDistanceKm!),
                ),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: FieldnoteSpacing.xs),
            Text(
              l10n.sponsorPinPickerReachPrivacy,
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
              context.l10n.sponsorPinPickerFullMapSearchUnavailable,
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
          () => _searchError = context.l10n.sponsorPinPickerFullMapOpenFailed,
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
    final l10n = context.l10n;
    final point = LatLng(_pin.latitude, _pin.longitude);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text(l10n.sponsorPinPickerFullMapTitle)),
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
                    labelText: l10n.sponsorPinPickerSearchLabel,
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
                  semanticLabel: l10n.sponsorPinPickerFullMapSemantics,
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
                        ? l10n.sponsorPinPickerFullMapFallbackSearch
                        : l10n.sponsorPinPickerFullMapFallbackGps,
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
                        : l10n.sponsorPinPickerFullMapPrompt,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: FieldnoteSpacing.sm),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _selected
                          ? () => Navigator.pop(context, _pin)
                          : null,
                      icon: const Icon(Icons.check),
                      label: Text(l10n.sponsorPinPickerUseThisPin),
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
