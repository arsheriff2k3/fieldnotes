import 'dart:async';

import 'package:fieldnotes_client/fieldnotes_client.dart';
import 'package:flutter/material.dart';

import '../../data/repositories/fieldnote_repository.dart';
import '../../l10n/l10n.dart';
import 'fieldnote_map.dart';

class SelectedLocation {
  const SelectedLocation({
    required this.label,
    required this.latitude,
    required this.longitude,
    this.placeId,
  });

  final String label;
  final double latitude;
  final double longitude;
  final String? placeId;
}

/// One full-screen Google map and Places search for account locations.
class LocationPicker extends StatefulWidget {
  const LocationPicker({
    super.key,
    required this.repository,
    required this.title,
    this.initialQuery = '',
    this.initialLabel,
    this.initialLatitude,
    this.initialLongitude,
  });

  final FieldnoteRepository repository;
  final String title;
  final String initialQuery;
  final String? initialLabel;
  final double? initialLatitude;
  final double? initialLongitude;

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  late final TextEditingController _search;
  Timer? _debounce;
  List<PlaceSuggestion> _suggestions = const [];
  SelectedLocation? _selected;
  bool _queryPending = false;
  bool _searching = false;
  String? _message;
  int _request = 0;
  int _geocodeRequest = 0;

  @override
  void initState() {
    super.initState();
    _search = TextEditingController(text: widget.initialQuery);
    final latitude = widget.initialLatitude;
    final longitude = widget.initialLongitude;
    if (latitude != null &&
        longitude != null &&
        latitude.isFinite &&
        longitude.isFinite &&
        latitude.abs() <= 90 &&
        longitude.abs() <= 180) {
      final label = (widget.initialLabel ?? widget.initialQuery).trim();
      _selected = SelectedLocation(
        label: label.isNotEmpty
            ? label
            : '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}',
        latitude: latitude,
        longitude: longitude,
      );
      _queryPending = widget.initialQuery.trim() != _selected!.label;
    }
    if (widget.initialQuery.trim().length >= 3 &&
        (_selected == null || _queryPending)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) unawaited(_find(widget.initialQuery.trim()));
      });
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _changed(String query) {
    _debounce?.cancel();
    _request++;
    _geocodeRequest++;
    setState(() {
      _queryPending = _selected != null && query.trim() != _selected!.label;
      _suggestions = const [];
      _message = null;
      _searching = false;
    });
    if (query.trim().length < 3) return;
    _debounce = Timer(const Duration(milliseconds: 350), () {
      unawaited(_find(query.trim()));
    });
  }

  Future<void> _find(String query) async {
    final request = ++_request;
    setState(() => _searching = true);
    try {
      final results = await widget.repository.searchPlaces(query);
      if (!mounted || request != _request) return;
      setState(() {
        _suggestions = results;
        _message = results.isEmpty ? context.l10n.corePickerNoMatches : null;
      });
    } on Object {
      if (mounted && request == _request) {
        setState(
          () => _message = context.l10n.corePickerSearchUnavailable,
        );
      }
    } finally {
      if (mounted && request == _request) setState(() => _searching = false);
    }
  }

  Future<void> _choose(PlaceSuggestion suggestion) async {
    _debounce?.cancel();
    ++_request;
    final request = ++_geocodeRequest;
    FocusScope.of(context).unfocus();
    try {
      final place = await widget.repository.resolvePlace(suggestion.placeId);
      if (!mounted || request != _geocodeRequest) return;
      final label = place.address.trim().isNotEmpty
          ? place.address.trim()
          : place.name.trim();
      setState(() {
        _selected = SelectedLocation(
          label: label,
          latitude: place.latitude,
          longitude: place.longitude,
          placeId: suggestion.placeId,
        );
        _search.text = label;
        _queryPending = false;
        _suggestions = const [];
        _message = null;
      });
    } on Object {
      if (mounted) {
        setState(
          () => _message = context.l10n.corePickerOpenFailed,
        );
      }
    }
  }

  Future<void> _pin(LatLng point) async {
    _debounce?.cancel();
    ++_request;
    FocusScope.of(context).unfocus();
    final request = ++_geocodeRequest;
    final coordinates =
        '${point.latitude.toStringAsFixed(5)}, ${point.longitude.toStringAsFixed(5)}';
    setState(() {
      _selected = SelectedLocation(
        label: coordinates,
        latitude: point.latitude,
        longitude: point.longitude,
      );
      _suggestions = const [];
      _search.text = coordinates;
      _queryPending = false;
      _message = null;
    });
    try {
      final place = await widget.repository.describeCoordinates(
        point.latitude,
        point.longitude,
      );
      if (!mounted || request != _geocodeRequest || place == null) return;
      final label = place.address.trim().isNotEmpty
          ? place.address.trim()
          : place.name.trim();
      if (label.isEmpty) return;
      setState(() {
        _selected = SelectedLocation(
          label: label,
          latitude: point.latitude,
          longitude: point.longitude,
        );
        _search.text = label;
      });
    } on Object {
      // The exact pin remains selectable without reverse geocoding.
    }
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selected;
    final point = selected == null
        ? LatLng(
            widget.initialLatitude ?? 20.5937,
            widget.initialLongitude ?? 78.9629,
          )
        : LatLng(selected.latitude, selected.longitude);
    final l10n = context.l10n;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text(widget.title)),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _search,
                onChanged: _changed,
                decoration: InputDecoration(
                  labelText: l10n.corePlacesSearchLabel,
                  hintText: l10n.corePickerSearchHint,
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
            if (_message != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(_message!),
              ),
            if (_suggestions.isNotEmpty)
              Material(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 220),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _suggestions.length > 4
                        ? 4
                        : _suggestions.length,
                    itemBuilder: (context, index) {
                      final suggestion = _suggestions[index];
                      return ListTile(
                        dense: true,
                        leading: const Icon(Icons.place_outlined),
                        title: Text(suggestion.primaryText),
                        subtitle: suggestion.secondaryText.isEmpty
                            ? null
                            : Text(suggestion.secondaryText),
                        onTap: () => _choose(suggestion),
                      );
                    },
                  ),
                ),
              ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) => FieldnoteMap(
                  target: point,
                  zoom: selected == null ? 5 : 15,
                  height: constraints.maxHeight,
                  semanticLabel: l10n.corePickerMapSemantics,
                  onTap: _pin,
                  markers: selected == null
                      ? const {}
                      : {
                          Marker(
                            markerId: const MarkerId('selected-location'),
                            position: point,
                            draggable: true,
                            onDragEnd: _pin,
                          ),
                        },
                  fallback: MapUnavailableNotice(
                    message: l10n.corePickerTilesUnavailable,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    selected?.label ?? l10n.corePickerPrompt,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: selected == null || _queryPending
                        ? null
                        : () => Navigator.pop(context, selected),
                    icon: const Icon(Icons.check),
                    label: Text(l10n.corePickerUseLocation),
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
