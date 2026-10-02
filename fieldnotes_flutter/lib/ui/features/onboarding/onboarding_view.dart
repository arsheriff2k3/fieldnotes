import 'dart:async';

import 'package:fieldnotes_client/fieldnotes_client.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/services/device_location_service.dart';
import '../../../data/services/pending_role_service.dart';
import '../../core/error_messages.dart';
import '../../core/fieldnote_map.dart';
import '../../core/legal.dart';
import '../../core/location_picker.dart';
import '../../core/fieldnote_theme.dart';
import '../../core/widgets.dart';
import '../../../l10n/l10n.dart';
import '../shell/fieldnote_view_model.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key, required this.viewModel});

  final FieldnoteViewModel viewModel;

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final _roles = PendingRoleService();
  final _location = DeviceLocationService();
  final _name = TextEditingController();
  final _city = TextEditingController();
  final _organization = TextEditingController();
  final _contactPhone = TextEditingController();
  Timer? _citySearchDebounce;
  List<PlaceSuggestion> _citySuggestions = const [];
  String? _selectedCityPlaceId;
  SelectedLocation? _sponsorLocation;
  int _citySearchRequest = 0;
  bool _citySearchAvailable = false;
  bool _checkingCitySearch = false;
  bool _searchingCity = false;
  AccountRole? _role;
  String _sponsorType = 'Individual';
  final Set<String> _interests = {'environment'};
  final Set<String> _skills = {'outdoors'};
  final Set<int> _weekdays = {DateTime.saturday, DateTime.sunday};
  double _radius = 10;
  bool _available = true;
  bool _availableToday = false;
  DeviceLocation? _deviceLocation;
  bool _pinnedByHand = false;
  bool _saving = false;
  bool _locating = false;
  bool _resolvingArea = false;
  LocationAccessException? _locationError;
  int _areaRequest = 0;
  final Map<String, bool> _consents = {};

  @override
  void initState() {
    super.initState();
    _loadRole();
    if (widget.viewModel.legalPolicies == null) {
      unawaited(widget.viewModel.loadLegalPolicies());
    }
  }

  Future<void> _loadRole() async {
    final role = await _roles.load();
    if (!mounted) return;
    setState(() => _role = role);
    if (role == AccountRole.sponsor) {
      unawaited(_checkCitySearch());
    }
  }

  @override
  void dispose() {
    _citySearchDebounce?.cancel();
    _name.dispose();
    _city.dispose();
    _organization.dispose();
    _contactPhone.dispose();
    super.dispose();
  }

  Future<void> _checkCitySearch() async {
    if (_checkingCitySearch) return;
    setState(() => _checkingCitySearch = true);
    try {
      final available = await widget.viewModel.repository
          .locationSearchAvailable();
      if (mounted) setState(() => _citySearchAvailable = available);
    } on Object {
      if (mounted) setState(() => _citySearchAvailable = false);
    } finally {
      if (mounted) setState(() => _checkingCitySearch = false);
    }
  }

  void _onCityQueryChanged(String value) {
    _selectedCityPlaceId = null;
    _sponsorLocation = null;
    _citySearchDebounce?.cancel();
    if (!_citySearchAvailable || value.trim().length < 2) {
      _citySearchRequest++;
      setState(() => _citySuggestions = const []);
      return;
    }
    _citySearchDebounce = Timer(const Duration(milliseconds: 350), () {
      unawaited(_searchCities(value.trim()));
    });
  }

  Future<void> _searchCities(String query) async {
    final request = ++_citySearchRequest;
    setState(() => _searchingCity = true);
    try {
      final suggestions = await widget.viewModel.repository.searchLocations(
        query,
      );
      if (mounted && request == _citySearchRequest) {
        setState(() => _citySuggestions = suggestions);
      }
    } on Object {
      if (mounted && request == _citySearchRequest) {
        setState(() => _citySuggestions = const []);
      }
    } finally {
      if (mounted && request == _citySearchRequest) {
        setState(() => _searchingCity = false);
      }
    }
  }

  void _chooseCity(PlaceSuggestion suggestion) {
    _citySearchDebounce?.cancel();
    FocusScope.of(context).unfocus();
    setState(() {
      _city.text = [
        suggestion.primaryText,
        suggestion.secondaryText,
      ].where((part) => part.trim().isNotEmpty).join(', ');
      _selectedCityPlaceId = suggestion.placeId;
      _sponsorLocation = null;
      _citySuggestions = const [];
      _searchingCity = false;
    });
  }

  Future<void> _openLocationMap() async {
    final result = await Navigator.push<SelectedLocation>(
      context,
      MaterialPageRoute(
        builder: (_) => LocationPicker(
          repository: widget.viewModel.repository,
          title: context.l10n.onboardingChooseSponsorLocation,
          initialQuery: _city.text,
        ),
      ),
    );
    if (result == null || !mounted) return;
    setState(() {
      _sponsorLocation = result;
      _selectedCityPlaceId = result.placeId;
      _city.text = result.label;
      _citySuggestions = const [];
    });
  }

  Future<void> _openTravelMap() async {
    final result = await Navigator.push<SelectedLocation>(
      context,
      MaterialPageRoute(
        builder: (_) => LocationPicker(
          repository: widget.viewModel.repository,
          title: context.l10n.onboardingChooseTravelArea,
          initialQuery: _city.text,
          initialLatitude: _deviceLocation?.latitude,
          initialLongitude: _deviceLocation?.longitude,
        ),
      ),
    );
    if (result == null || !mounted) return;
    _movePin(LatLng(result.latitude, result.longitude));
  }

  Future<void> _locate() async {
    setState(() {
      _locating = true;
      _locationError = null;
    });
    try {
      final value = await _location.current();
      if (!mounted) return;
      setState(() {
        _deviceLocation = value;
        _pinnedByHand = false;
      });
      unawaited(_describeArea(value));
    } on LocationAccessException catch (error) {
      if (mounted) setState(() => _locationError = error);
    } on Object {
      if (mounted) {
        setState(
          () => _locationError = const LocationAccessException(
            LocationAccessIssue.unavailable,
            'The device location is unavailable. Check Location settings and '
            'try again.',
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  /// Moves the saved area to a point the volunteer chose on the map, which is
  /// often not where they happen to be standing during onboarding.
  void _movePin(LatLng point) {
    final location = DeviceLocation(
      latitude: point.latitude,
      longitude: point.longitude,
      accuracyMeters: 50,
      isLive: true,
      isMocked: false,
      capturedAt: DateTime.now().toUtc(),
      isDemo: false,
    );
    setState(() {
      _pinnedByHand = true;
      _deviceLocation = location;
      _locationError = null;
    });
    unawaited(_describeArea(location));
  }

  Future<void> _describeArea(DeviceLocation location) async {
    final request = ++_areaRequest;
    final coordinates =
        '${location.latitude.toStringAsFixed(5)}, '
        '${location.longitude.toStringAsFixed(5)}';
    setState(() {
      _city.text = coordinates;
      _resolvingArea = true;
    });
    try {
      final place = await widget.viewModel.repository.describeCoordinates(
        location.latitude,
        location.longitude,
      );
      if (!mounted || request != _areaRequest || place == null) return;
      final label = place.address.trim().isNotEmpty
          ? place.address.trim()
          : place.name.trim();
      if (label.isNotEmpty) setState(() => _city.text = label);
    } on Object {
      // Coordinates remain a usable label when Google Geocoding is unavailable.
    } finally {
      if (mounted && request == _areaRequest) {
        setState(() => _resolvingArea = false);
      }
    }
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    if (_role == null || _name.text.trim().length < 2) {
      _message(l10n.onboardingNeedRoleAndName);
      return;
    }
    if (_role == AccountRole.volunteer && _deviceLocation == null) {
      _message(l10n.onboardingNeedArea);
      return;
    }
    if (_role == AccountRole.volunteer && _resolvingArea) {
      _message(l10n.onboardingWaitForArea);
      return;
    }
    if (_role == AccountRole.sponsor && _city.text.trim().length < 2) {
      _message(l10n.onboardingNeedLocation);
      return;
    }
    if (_role == AccountRole.sponsor &&
        !RegExp(r'^\+[1-9]\d{7,14}$').hasMatch(
          _contactPhone.text.replaceAll(RegExp(r'[\s()\-]'), ''),
        )) {
      _message(l10n.onboardingNeedPhone);
      return;
    }
    if (_role == AccountRole.sponsor &&
        _citySearchAvailable &&
        _selectedCityPlaceId == null &&
        _sponsorLocation == null) {
      _message(l10n.onboardingSelectSuggestion);
      return;
    }
    if (widget.viewModel.legalPolicies == null) {
      await widget.viewModel.loadLegalPolicies();
      if (!mounted) return;
    }
    final policies = widget.viewModel.legalPolicies;
    if (policies == null) {
      _message(l10n.onboardingPoliciesUnavailable);
      return;
    }
    if (!requiredConsentsGiven(_consents, policies)) {
      _message(l10n.onboardingAcceptConsents);
      return;
    }
    setState(() => _saving = true);
    try {
      late final FieldnoteUserProfile profile;
      if (_role == AccountRole.sponsor) {
        profile = await widget.viewModel.repository.completeSponsorProfile(
          displayName: _name.text,
          sponsorType: _sponsorType,
          organizationName: _organization.text,
          contactPhone: _contactPhone.text,
          city: _city.text,
          cityPlaceId: _selectedCityPlaceId,
          locationLatitude: _sponsorLocation?.placeId == null
              ? _sponsorLocation?.latitude
              : null,
          locationLongitude: _sponsorLocation?.placeId == null
              ? _sponsorLocation?.longitude
              : null,
          interests: _interests.toList(),
        );
      } else {
        profile = await widget.viewModel.repository.completeVolunteerProfile(
          displayName: _name.text,
          city: _city.text,
          interests: _interests.toList(),
          skills: _skills.toList(),
          isAvailable: _available,
          availableToday: _availableToday,
          weekdays: _weekdays.toList(),
          startMinutes: 7 * 60,
          endMinutes: 13 * 60,
          maximumTravelKm: _radius,
          latitude: _deviceLocation!.latitude,
          longitude: _deviceLocation!.longitude,
          locationLabel: _pinnedByHand
              ? 'Chosen map area'
              : _deviceLocation!.isLive
              ? 'Current GPS area'
              : 'Location captured',
        );
      }
      final consent = await widget.viewModel.repository.acceptLegalConsent(
        locationConsent: _consents[consentLocation] ?? false,
        aiProcessingConsent: _consents[consentAiProcessing] ?? false,
        evidenceSharingConsent: _consents[consentEvidenceSharing] ?? false,
        acceptedPrivacyPolicyVersion: policies.privacyPolicyVersion,
        acceptedTermsVersion: policies.termsVersion,
      );
      await _roles.clear();
      await widget.viewModel.onboardingCompleted(profile, consent);
    } catch (error) {
      if (error is FieldnoteException &&
          error.code == 'consent_version_mismatch') {
        unawaited(widget.viewModel.loadLegalPolicies());
      }
      _message(
        userMessageFor(error, fallback: l10n.onboardingSetupFailed),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _message(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: FieldnotePageList(
              top: FieldnoteSpacing.xl,
              bottom: FieldnoteSpacing.xxl,
              maxWidth: 760,
              children: [
                Row(
                  children: [
                    Icon(Icons.eco, color: context.fieldnoteColors.forest),
                    const SizedBox(width: 8),
                    Text(
                      l10n.onboardingBrandHeader,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 26),
                SectionHeading(
                  eyebrow: switch (_role) {
                    null => l10n.onboardingChooseRole,
                    final role => _roleLabel(role),
                  },
                  title: _role == AccountRole.sponsor
                      ? l10n.onboardingSponsorTitle
                      : l10n.onboardingVolunteerTitle,
                  description: _role == AccountRole.sponsor
                      ? l10n.onboardingSponsorDescription
                      : l10n.onboardingVolunteerDescription,
                ),
                const SizedBox(height: 22),
                if (_role == null) _rolePicker(),
                if (_role != null)
                  SurfaceCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FieldnoteTextField(
                          controller: _name,
                          decoration: InputDecoration(
                            labelText: l10n.onboardingDisplayName,
                            prefixIcon: const Icon(Icons.person_outline),
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (_role == AccountRole.sponsor) ...[
                          _sponsorCityField(),
                          const SizedBox(height: 18),
                        ],
                        if (_role == AccountRole.sponsor)
                          _sponsorFields()
                        else
                          _volunteerFields(),
                        const SizedBox(height: 20),
                        _consentFields(),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _saving ? null : _save,
                            icon: _saving
                                ? const SizedBox.square(
                                    dimension: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.arrow_forward),
                            label: Text(
                              _saving
                                  ? l10n.onboardingPreparing
                                  : l10n.onboardingEnter,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _roleLabel(AccountRole role) => switch (role) {
    AccountRole.sponsor => context.l10n.roleSponsor,
    AccountRole.volunteer => context.l10n.roleVolunteer,
  };

  Widget _rolePicker() {
    return ResponsiveCardGrid(
      minimumItemWidth: 150,
      spacing: 12,
      children: AccountRole.values
          .map(
            (role) => OutlinedButton.icon(
              onPressed: () async {
                await _roles.save(role);
                setState(() {
                  _role = role;
                  _selectedCityPlaceId = null;
                  _citySuggestions = const [];
                });
                if (role == AccountRole.sponsor) {
                  unawaited(_checkCitySearch());
                }
              },
              icon: Icon(
                role == AccountRole.sponsor
                    ? Icons.volunteer_activism_outlined
                    : Icons.directions_walk_outlined,
              ),
              label: Text(_roleLabel(role)),
            ),
          )
          .toList(),
    );
  }

  Widget _sponsorCityField() {
    final c = context.fieldnoteColors;
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldnoteTextField(
          controller: _city,
          onChanged: _onCityQueryChanged,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            labelText: l10n.onboardingLocationLabel,
            hintText: l10n.onboardingLocationHint,
            prefixIcon: const Icon(Icons.location_on_outlined),
            suffixIcon: _checkingCitySearch || _searchingCity
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : _selectedCityPlaceId == null
                ? null
                : Icon(Icons.check_circle, color: c.moss),
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _openLocationMap,
          icon: const Icon(Icons.map_outlined),
          label: Text(l10n.onboardingChooseOnMap),
        ),
        if (_citySuggestions.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: c.raised,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: c.ink.withValues(alpha: .1),
              ),
            ),
            child: Column(
              children: [
                for (final suggestion in _citySuggestions.take(5))
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.location_on_outlined),
                    title: Text(suggestion.primaryText),
                    subtitle: suggestion.secondaryText.isEmpty
                        ? null
                        : Text(suggestion.secondaryText),
                    onTap: () => _chooseCity(suggestion),
                  ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 6),
        Text(
          _citySearchAvailable
              ? l10n.onboardingPlacesHint
              : l10n.onboardingPlacesUnavailable,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _sponsorFields() {
    final l10n = context.l10n;
    // The values are stored on the profile; only their labels are localized.
    final sponsorTypes = {
      'Individual': l10n.sponsorTypeIndividual,
      'Company': l10n.sponsorTypeCompany,
      'Foundation': l10n.sponsorTypeFoundation,
      'Community group': l10n.sponsorTypeCommunityGroup,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          initialValue: _sponsorType,
          decoration: InputDecoration(labelText: l10n.onboardingSponsorType),
          items: sponsorTypes.entries
              .map(
                (type) => DropdownMenuItem(
                  value: type.key,
                  child: Text(type.value),
                ),
              )
              .toList(),
          onChanged: (value) =>
              setState(() => _sponsorType = value ?? 'Individual'),
        ),
        const SizedBox(height: 12),
        FieldnoteTextField(
          controller: _organization,
          decoration: InputDecoration(
            labelText: l10n.onboardingOrganization,
          ),
        ),
        const SizedBox(height: 12),
        FieldnoteTextField(
          controller: _contactPhone,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: l10n.onboardingContactPhone,
            hintText: '+919876543210',
            prefixIcon: const Icon(Icons.call_outlined),
            helperText: l10n.onboardingContactPhoneHelper,
          ),
        ),
        const SizedBox(height: 18),
        _choiceChips(
          title: l10n.onboardingPreferredCauses,
          values: const ['environment', 'tree care', 'cleanup', 'community'],
          selected: _interests,
        ),
      ],
    );
  }

  Widget _volunteerFields() {
    final l10n = context.l10n;
    // Short weekday names in the current locale; 2024-01-01 was a Monday, so
    // DateTime(2024, 1, n) has weekday n.
    final weekdayFormat = DateFormat.E(context.localeTag);
    final days = {
      for (var day = DateTime.monday; day <= DateTime.sunday; day++)
        day: weekdayFormat.format(DateTime(2024, 1, day)),
    };
    final km = NumberFormat.decimalPattern(context.localeTag);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          value: _available,
          title: Text(l10n.onboardingAvailableForMatches),
          onChanged: (value) => setState(() => _available = value),
        ),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          value: _availableToday,
          title: Text(l10n.onboardingAvailableToday),
          onChanged: (value) => setState(() => _availableToday = value),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.onboardingAvailableDays,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 7),
        Wrap(
          spacing: 7,
          children: days.entries
              .map(
                (day) => FilterChip(
                  label: Text(day.value),
                  selected: _weekdays.contains(day.key),
                  onSelected: (selected) => setState(() {
                    selected
                        ? _weekdays.add(day.key)
                        : _weekdays.remove(day.key);
                  }),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 15),
        Text(l10n.onboardingTravelRadius(km.format(_radius.round()))),
        Slider(
          value: _radius,
          min: 2,
          max: 50,
          divisions: 24,
          onChanged: (value) => setState(() => _radius = value),
        ),
        const SizedBox(height: 8),
        Text(l10n.onboardingTravelAreaHint),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: _locating ? null : _locate,
          icon: _locating
              ? const SizedBox.square(
                  dimension: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.my_location),
          label: Text(
            _locating
                ? l10n.onboardingFindingLocation
                : _deviceLocation == null
                ? l10n.onboardingUseGps
                : _pinnedByHand
                ? l10n.onboardingUseGpsInstead
                : _deviceLocation!.isLive
                ? l10n.onboardingRefreshGps
                : l10n.onboardingUseGps,
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _openTravelMap,
          icon: const Icon(Icons.map_outlined),
          label: Text(l10n.onboardingChooseTravelAreaOnMap),
        ),
        if (_locationError != null) ...[
          const SizedBox(height: 8),
          Text(_locationError!.message),
          if (_locationError!.issue == LocationAccessIssue.serviceDisabled)
            TextButton.icon(
              onPressed: _location.openLocationSettings,
              icon: const Icon(Icons.settings_outlined),
              label: Text(l10n.locationEnableInSettings),
            )
          else if (_locationError!.issue ==
              LocationAccessIssue.permissionDeniedForever)
            TextButton.icon(
              onPressed: _location.openAppSettings,
              icon: const Icon(Icons.settings_outlined),
              label: Text(l10n.locationOpenPermissions),
            ),
        ],
        const SizedBox(height: 10),
        // Drawn to scale, so the radius is an informed choice rather than a
        // number picked in the abstract.
        _areaMap(),
        if (_deviceLocation != null) ...[
          const SizedBox(height: 8),
          Text(
            _resolvingArea
                ? l10n.onboardingFindingAreaName
                : l10n.onboardingSelectedArea(_city.text),
          ),
        ],
        const SizedBox(height: 18),
        _choiceChips(
          title: l10n.onboardingInterests,
          values: const ['environment', 'tree care', 'cleanup', 'community'],
          selected: _interests,
        ),
        const SizedBox(height: 14),
        _choiceChips(
          title: l10n.onboardingSkills,
          values: const ['outdoors', 'gardening', 'organizing', 'photography'],
          selected: _skills,
        ),
      ],
    );
  }

  Widget _areaMap() {
    final location = _deviceLocation;
    final point = location == null
        ? LatLng(
            20.5937,
            78.9629,
          )
        : LatLng(location.latitude, location.longitude);
    final radiusMeters = _radius * 1000;
    return FieldnoteMap(
      target: point,
      zoom: zoomForRadius(radiusMeters),
      height: 220,
      semanticLabel: context.l10n.onboardingMapSemantics,
      onTap: _movePin,
      markers: {
        Marker(
          markerId: const MarkerId('area'),
          position: point,
          draggable: true,
          onDragEnd: _movePin,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            FieldnoteMapPalette.volunteer,
          ),
        ),
      },
      circles: {
        radiusCircle(
          id: 'radius',
          center: point,
          radiusMeters: radiusMeters,
        ),
      },
      fallback: MapUnavailableNotice(
        message: context.l10n.onboardingMapFallback,
      ),
    );
  }

  Widget _consentFields() {
    final policies = widget.viewModel.legalPolicies;
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.fieldnoteColors.mist,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.onboardingPrivacyChoices,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(l10n.onboardingPrivacyChoicesBody),
          ConsentChecklist(
            values: _consents,
            policies: policies,
            enabled: !_saving,
            showDescriptions: false,
            onChanged: (key, value) => setState(() => _consents[key] = value),
          ),
          Text(
            policies == null
                ? l10n.onboardingAcceptCurrent
                : l10n.onboardingAcceptVersions(
                    policies.termsVersion,
                    policies.privacyPolicyVersion,
                  ),
            style: const TextStyle(fontSize: 12),
          ),
          LegalLinks(
            policies: policies,
            onRetry: widget.viewModel.loadLegalPolicies,
          ),
        ],
      ),
    );
  }

  Widget _choiceChips({
    required String title,
    required List<String> values,
    required Set<String> selected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 7),
        Wrap(
          spacing: 7,
          children: values
              .map(
                (value) => FilterChip(
                  label: Text(value),
                  selected: selected.contains(value),
                  onSelected: (enabled) => setState(() {
                    enabled ? selected.add(value) : selected.remove(value);
                  }),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
