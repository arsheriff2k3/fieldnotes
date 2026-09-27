import 'dart:async';

import 'package:fieldnotes_client/fieldnotes_client.dart';
import 'package:flutter/material.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

import '../../../client.dart';
import '../../core/fieldnote_theme.dart';
import '../../core/in_app_maps.dart';
import '../../core/location_picker.dart';
import '../../core/widgets.dart';
import '../shell/fieldnote_view_model.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({
    super.key,
    required this.viewModel,
    this.onEditAvailability,
  });

  final FieldnoteViewModel viewModel;
  final VoidCallback? onEditAvailability;

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  static const _interestOptions = [
    'environment',
    'tree care',
    'cleanup',
    'community',
  ];
  static const _skillOptions = [
    'outdoors',
    'gardening',
    'organizing',
    'photography',
  ];
  static const _dayNames = {
    1: 'Mon',
    2: 'Tue',
    3: 'Wed',
    4: 'Thu',
    5: 'Fri',
    6: 'Sat',
    7: 'Sun',
  };
  final _name = TextEditingController();
  final _city = TextEditingController();
  final _organization = TextEditingController();
  final _contactPhone = TextEditingController();
  final Set<String> _interests = {};
  final Set<String> _skills = {};
  Timer? _cityDebounce;
  List<PlaceSuggestion> _citySuggestions = const [];
  String? _cityPlaceId;
  SelectedLocation? _sponsorLocation;
  String _originalCity = '';
  String _sponsorType = 'Individual';
  bool _editing = false;
  bool _saving = false;
  bool _citySearchAvailable = false;
  bool _searchingCity = false;
  int _cityRequest = 0;

  @override
  void initState() {
    super.initState();
    _resetFromModel();
    unawaited(_checkCitySearch());
  }

  @override
  void dispose() {
    _cityDebounce?.cancel();
    _name.dispose();
    _city.dispose();
    _organization.dispose();
    _contactPhone.dispose();
    super.dispose();
  }

  List<String> _values(String encoded) => encoded
      .split('|')
      .map((value) => value.trim())
      .where((value) => value.isNotEmpty)
      .toList();

  void _resetFromModel() {
    final profile = widget.viewModel.profile!;
    _name.text = profile.displayName;
    final displayedLocation = widget.viewModel.isSponsor
        ? profile.locationAddress ?? profile.city
        : profile.city;
    _city.text = displayedLocation;
    _originalCity = displayedLocation;
    _organization.text = profile.organizationName ?? '';
    _contactPhone.text = profile.contactPhone ?? '';
    _sponsorType = profile.sponsorType ?? 'Individual';
    _interests
      ..clear()
      ..addAll(_values(profile.interests));
    _skills
      ..clear()
      ..addAll(_values(profile.skills));
    _cityPlaceId = null;
    _sponsorLocation = null;
    _citySuggestions = const [];
  }

  Future<void> _checkCitySearch() async {
    try {
      final available = widget.viewModel.isSponsor
          ? await widget.viewModel.repository.placeSearchAvailable()
          : await widget.viewModel.repository.citySearchAvailable();
      if (mounted) setState(() => _citySearchAvailable = available);
    } on Object {
      if (mounted) setState(() => _citySearchAvailable = false);
    }
  }

  void _cityChanged(String value) {
    _cityPlaceId = null;
    _sponsorLocation = null;
    _cityDebounce?.cancel();
    if (!_citySearchAvailable || value.trim().length < 2) {
      _cityRequest++;
      setState(() => _citySuggestions = const []);
      return;
    }
    _cityDebounce = Timer(const Duration(milliseconds: 350), () {
      unawaited(_searchCities(value.trim()));
    });
  }

  Future<void> _searchCities(String query) async {
    final request = ++_cityRequest;
    setState(() => _searchingCity = true);
    try {
      final values = widget.viewModel.isSponsor
          ? await widget.viewModel.repository.searchPlaces(query)
          : await widget.viewModel.repository.searchCities(query);
      if (mounted && request == _cityRequest) {
        setState(() => _citySuggestions = values);
      }
    } on Object {
      if (mounted && request == _cityRequest) {
        setState(() => _citySuggestions = const []);
      }
    } finally {
      if (mounted && request == _cityRequest) {
        setState(() => _searchingCity = false);
      }
    }
  }

  void _chooseCity(PlaceSuggestion suggestion) {
    FocusScope.of(context).unfocus();
    setState(() {
      _city.text = widget.viewModel.isSponsor
          ? [
              suggestion.primaryText,
              suggestion.secondaryText,
            ].where((part) => part.trim().isNotEmpty).join(', ')
          : suggestion.primaryText;
      _cityPlaceId = suggestion.placeId;
      _sponsorLocation = null;
      _citySuggestions = const [];
    });
  }

  Future<void> _openLocationMap() async {
    final result = await Navigator.push<SelectedLocation>(
      context,
      MaterialPageRoute(
        builder: (_) => LocationPicker(
          repository: widget.viewModel.repository,
          title: 'Choose profile location',
          initialQuery: _city.text,
          initialLabel:
              widget.viewModel.profile?.locationAddress ??
              widget.viewModel.profile?.city,
          initialLatitude: widget.viewModel.profile?.locationLatitude,
          initialLongitude: widget.viewModel.profile?.locationLongitude,
        ),
      ),
    );
    if (result == null || !mounted) return;
    setState(() {
      _city.text = result.label;
      _citySuggestions = const [];
      _sponsorLocation = result;
      _cityPlaceId = result.placeId;
    });
  }

  Future<void> _save() async {
    final city = _city.text.trim();
    if (_name.text.trim().length < 2 || city.length < 2) {
      _message(
        widget.viewModel.isSponsor
            ? 'Enter your display name and location.'
            : 'Enter your display name and city.',
      );
      return;
    }
    if (_interests.isEmpty) {
      _message('Choose at least one interest.');
      return;
    }
    if (_citySearchAvailable &&
        city != _originalCity &&
        _cityPlaceId == null &&
        _sponsorLocation == null &&
        widget.viewModel.isSponsor) {
      _message(
        widget.viewModel.isSponsor
            ? 'Select the new location from the Google suggestions.'
            : 'Select the new city from the Google suggestions.',
      );
      return;
    }
    if (widget.viewModel.isVolunteer && _skills.isEmpty) {
      _message('Choose at least one skill.');
      return;
    }
    if ((widget.viewModel.isSponsor || _contactPhone.text.trim().isNotEmpty) &&
        !RegExp(r'^\+[1-9]\d{7,14}$').hasMatch(
          _contactPhone.text.replaceAll(RegExp(r'[\s()\-]'), ''),
        )) {
      _message(
        'Enter a phone number with country code, for example +919876543210.',
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final updated = await widget.viewModel.repository.updateProfile(
        displayName: _name.text,
        sponsorType: widget.viewModel.isSponsor ? _sponsorType : null,
        organizationName: widget.viewModel.isSponsor
            ? _organization.text
            : null,
        contactPhone: _contactPhone.text,
        city: city,
        cityPlaceId: _cityPlaceId,
        locationLatitude: _sponsorLocation?.placeId == null
            ? _sponsorLocation?.latitude
            : null,
        locationLongitude: _sponsorLocation?.placeId == null
            ? _sponsorLocation?.longitude
            : null,
        interests: _interests.toList(),
        skills: _skills.toList(),
      );
      await widget.viewModel.profileUpdated(updated);
      if (!mounted) return;
      _resetFromModel();
      setState(() => _editing = false);
      _message('Profile updated.');
    } catch (error) {
      _message(
        error is FieldnoteException
            ? error.message
            : 'Could not update your profile.',
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _openSavedLocation(FieldnoteUserProfile profile) {
    final latitude = profile.locationLatitude;
    final longitude = profile.locationLongitude;
    if (latitude == null || longitude == null) {
      _message('This profile does not have a mapped location yet.');
      return;
    }
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => PlaceMapScreen(
          title: profile.locationAddress ?? profile.city,
          latitude: latitude,
          longitude: longitude,
        ),
      ),
    );
  }

  void _message(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.viewModel.profile!;
    final roleName = widget.viewModel.isSponsor ? 'Sponsor' : 'Volunteer';
    return FieldnotePageList(
      children: [
        SectionHeading(
          eyebrow: '$roleName account',
          title: _editing ? 'Edit your profile' : profile.displayName,
          description: _editing
              ? 'Update the details people use to reach you.'
              : widget.viewModel.isSponsor
              ? 'Your contact and campaign identity.'
              : 'Your account and availability details.',
          trailing: _editing
              ? OutlinedButton(
                  onPressed: _saving
                      ? null
                      : () => setState(() {
                          _resetFromModel();
                          _editing = false;
                        }),
                  child: const Text('Cancel'),
                )
              : FilledButton.icon(
                  onPressed: () => setState(() => _editing = true),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit profile'),
                ),
        ),
        const SizedBox(height: 16),
        if (_editing) _editor() else _summary(profile),
      ],
    );
  }

  Widget _summary(FieldnoteUserProfile profile) {
    final availability = widget.viewModel.availability;
    return Column(
      children: [
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detail(
                'Phone number',
                profile.contactPhone?.isNotEmpty == true
                    ? profile.contactPhone!
                    : 'Not provided',
              ),
              if (widget.viewModel.isSponsor &&
                  profile.contactPhone?.isNotEmpty != true) ...[
                const Text(
                  'Add your phone number so volunteers who join your campaigns can call you.',
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => setState(() => _editing = true),
                  icon: const Icon(Icons.call_outlined),
                  label: const Text('Add contact number'),
                ),
                const SizedBox(height: 12),
              ],
              _detail(
                widget.viewModel.isSponsor ? 'Location' : 'Home area',
                widget.viewModel.isSponsor
                    ? profile.locationAddress ?? profile.city
                    : profile.city,
              ),
              if (widget.viewModel.isSponsor &&
                  profile.locationLatitude != null &&
                  profile.locationLongitude != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      onPressed: () => _openSavedLocation(profile),
                      icon: const Icon(Icons.map_outlined),
                      label: const Text('View location on map'),
                    ),
                  ),
                ),
              _detail('Interests', _values(profile.interests).join(', ')),
              if (widget.viewModel.isSponsor) ...[
                const Text(
                  'Your number is shared only with volunteers who join your campaign.',
                ),
                const SizedBox(height: 12),
                _detail('Sponsor type', profile.sponsorType ?? 'Individual'),
                _detail(
                  'Organization',
                  profile.organizationName?.isNotEmpty == true
                      ? profile.organizationName!
                      : 'Not provided',
                ),
              ] else ...[
                _detail('Skills', _values(profile.skills).join(', ')),
                _detail(
                  'Availability',
                  availability?.isAvailable == true ? 'Active' : 'Paused',
                ),
                _detail(
                  'Available today',
                  availability?.availableToday == true ? 'Yes' : 'No',
                ),
                _detail('Regular days', _weekdayLabel(availability?.weekdays)),
                _detail(
                  'Hours',
                  '${_time(availability?.startMinutes ?? 420)} – ${_time(availability?.endMinutes ?? 780)}',
                ),
                _detail(
                  'Travel radius',
                  '${availability?.maximumTravelKm.round() ?? 10} km',
                ),
                _detail(
                  'Travel area',
                  availability?.locationLabel.isNotEmpty == true
                      ? availability!.locationLabel
                      : 'Not selected',
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: widget.onEditAvailability,
                  icon: const Icon(Icons.event_available_outlined),
                  label: const Text('Edit availability and travel area'),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Account', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              const Text(
                'You can request deletion of this account and its private data.',
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _requestDeletion,
                style: FilledButton.styleFrom(
                  backgroundColor: FieldnoteColors.danger,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.delete_outline),
                label: const Text('Request account deletion'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _privacyCard(),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: () async {
              final signedOut = await client.auth.signOutDevice();
              if (!signedOut && mounted) {
                _message('Could not sign out this device.');
              }
            },
            icon: const Icon(Icons.logout),
            label: const Text('Sign out'),
          ),
        ),
      ],
    );
  }

  Widget _editor() {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FieldnoteTextField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Display name'),
          ),
          const SizedBox(height: 12),
          FieldnoteTextField(
            controller: _contactPhone,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: widget.viewModel.isSponsor
                  ? 'Phone number (required)'
                  : 'Phone number (optional)',
              hintText: '+919876543210',
              prefixIcon: const Icon(Icons.call_outlined),
              helperText: widget.viewModel.isSponsor
                  ? 'Visible only to joined volunteers.'
                  : 'Private to your account.',
              helperMaxLines: 2,
            ),
          ),
          const SizedBox(height: 12),
          _cityField(),
          const SizedBox(height: 18),
          if (widget.viewModel.isSponsor) ...[
            DropdownButtonFormField<String>(
              initialValue: _sponsorType,
              decoration: const InputDecoration(labelText: 'Sponsor type'),
              items:
                  const [
                        'Individual',
                        'Company',
                        'Foundation',
                        'Community group',
                      ]
                      .map(
                        (value) =>
                            DropdownMenuItem(value: value, child: Text(value)),
                      )
                      .toList(),
              onChanged: (value) => setState(() => _sponsorType = value!),
            ),
            const SizedBox(height: 12),
            FieldnoteTextField(
              controller: _organization,
              decoration: const InputDecoration(
                labelText: 'Organization name (optional)',
              ),
            ),
          ],
          const SizedBox(height: 18),
          _chips('Interests', _interestOptions, _interests),
          if (widget.viewModel.isVolunteer) ...[
            const SizedBox(height: 18),
            _chips('Skills', _skillOptions, _skills),
            const Divider(height: 34),
            const Text('Travel area and schedule are managed in Availability.'),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: widget.onEditAvailability,
              icon: const Icon(Icons.event_available_outlined),
              label: const Text('Edit availability and travel area'),
            ),
          ],
          const SizedBox(height: 22),
          _privacyCard(),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(_saving ? 'Saving…' : 'Save profile'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cityField() {
    final isLocation = widget.viewModel.isSponsor;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldnoteTextField(
          controller: _city,
          onChanged: _cityChanged,
          decoration: InputDecoration(
            labelText: isLocation ? 'Location' : 'Home city',
            hintText: isLocation
                ? 'Search for an address or place…'
                : 'Start typing a city…',
            prefixIcon: Icon(
              isLocation
                  ? Icons.location_on_outlined
                  : Icons.location_city_outlined,
            ),
            suffixIcon: _searchingCity
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : _cityPlaceId == null
                ? null
                : const Icon(Icons.check_circle, color: FieldnoteColors.moss),
          ),
        ),
        if (isLocation) ...[
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _openLocationMap,
            icon: const Icon(Icons.map_outlined),
            label: const Text('Choose on map'),
          ),
        ],
        if (_citySuggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: FieldnoteColors.ink.withValues(alpha: .1),
              ),
            ),
            child: Column(
              children: [
                for (final suggestion in _citySuggestions.take(5))
                  ListTile(
                    dense: true,
                    leading: Icon(
                      isLocation
                          ? Icons.location_on_outlined
                          : Icons.location_city_outlined,
                    ),
                    title: Text(suggestion.primaryText),
                    subtitle: suggestion.secondaryText.isEmpty
                        ? null
                        : Text(suggestion.secondaryText),
                    onTap: () => _chooseCity(suggestion),
                  ),
              ],
            ),
          ),
        const SizedBox(height: 6),
        Text(
          _citySearchAvailable
              ? isLocation
                    ? 'Choose a suggestion or pin a place on the map.'
                    : 'Choose a city suggestion · Powered by Google'
              : isLocation
              ? 'Location search is unavailable; enter the complete address manually.'
              : 'City search is unavailable; enter the city manually.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _chips(String title, List<String> options, Set<String> selected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: options
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

  Widget _privacyCard() {
    final consent = widget.viewModel.consent;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FieldnoteColors.mist,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lock_outline, size: 19),
              SizedBox(width: 8),
              Text('Privacy choices (read-only)'),
            ],
          ),
          const SizedBox(height: 10),
          _lockedChoice(
            'GPS for matching and evidence',
            consent?.locationConsent,
          ),
          _lockedChoice('AI processing', consent?.aiProcessingConsent),
          _lockedChoice('Evidence sharing', consent?.evidenceSharingConsent),
          const SizedBox(height: 4),
          const Text(
            'These choices cannot be changed from profile editing. Review the records in Trust Center.',
          ),
        ],
      ),
    );
  }

  Future<void> _requestDeletion() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Request account deletion?'),
        content: const Text(
          'The request is recorded for review. Shared campaign records are retained until it is processed.',
        ),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        actions: [
          SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: FieldnoteColors.danger,
                    backgroundColor: Colors.transparent,
                    side: const BorderSide(color: FieldnoteColors.danger),
                  ),
                  child: const Text('Cancel'),
                ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  style: FilledButton.styleFrom(
                    backgroundColor: FieldnoteColors.danger,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Yes, request deletion'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await widget.viewModel.requestAccountDeletion();
      if (mounted) _message('Deletion request recorded.');
    } on Object {
      if (mounted) {
        _message('Could not record the deletion request. Try again.');
      }
    }
  }

  Widget _lockedChoice(String label, bool? accepted) => Row(
    children: [
      Icon(
        accepted == true ? Icons.check_circle : Icons.cancel_outlined,
        size: 18,
        color: accepted == true ? FieldnoteColors.moss : FieldnoteColors.clay,
      ),
      const SizedBox(width: 8),
      Expanded(child: Text(label)),
    ],
  );

  Widget _detail(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final labelWidget = Text(
          label,
          style: Theme.of(context).textTheme.labelLarge,
        );
        final valueWidget = Text(value.isEmpty ? 'Not selected' : value);
        if (constraints.maxWidth < 420) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              labelWidget,
              const SizedBox(height: 4),
              valueWidget,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 132, child: labelWidget),
            Expanded(child: valueWidget),
          ],
        );
      },
    ),
  );

  String _weekdayLabel(String? encoded) {
    final values =
        encoded
            ?.split(',')
            .map(int.tryParse)
            .whereType<int>()
            .map((day) => _dayNames[day])
            .whereType<String>()
            .join(', ') ??
        '';
    return values.isEmpty ? 'Not selected' : values;
  }

  String _time(int minutes) {
    final hour = minutes ~/ 60;
    final minute = minutes % 60;
    final suffix = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    return '$displayHour:${minute.toString().padLeft(2, '0')} $suffix';
  }
}
