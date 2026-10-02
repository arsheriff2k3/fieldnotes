import 'dart:async';

import 'package:fieldnotes_client/fieldnotes_client.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/error_messages.dart';
import '../../core/fieldnote_theme.dart';
import '../../core/in_app_maps.dart';
import '../../core/location_picker.dart';
import '../../core/widgets.dart';
import '../../../l10n/l10n.dart';
import '../shell/fieldnote_view_model.dart';
import '../trust/account_deletion.dart';
import '../trust/trust_center_view.dart' show confirmSignOut;

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
  bool _savingNotifications = false;
  bool _signingOut = false;
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
          title: context.l10n.profileChooseLocation,
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
    final l10n = context.l10n;
    final city = _city.text.trim();
    if (_name.text.trim().length < 2 || city.length < 2) {
      _message(
        widget.viewModel.isSponsor
            ? l10n.profileNeedNameAndLocation
            : l10n.profileNeedNameAndCity,
      );
      return;
    }
    if (_interests.isEmpty) {
      _message(l10n.profileNeedInterest);
      return;
    }
    if (_citySearchAvailable &&
        city != _originalCity &&
        _cityPlaceId == null &&
        _sponsorLocation == null &&
        widget.viewModel.isSponsor) {
      _message(
        widget.viewModel.isSponsor
            ? l10n.profileSelectLocationSuggestion
            : l10n.profileSelectCitySuggestion,
      );
      return;
    }
    if (widget.viewModel.isVolunteer && _skills.isEmpty) {
      _message(l10n.profileNeedSkill);
      return;
    }
    if ((widget.viewModel.isSponsor || _contactPhone.text.trim().isNotEmpty) &&
        !RegExp(r'^\+[1-9]\d{7,14}$').hasMatch(
          _contactPhone.text.replaceAll(RegExp(r'[\s()\-]'), ''),
        )) {
      _message(l10n.onboardingNeedPhone);
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
      _message(l10n.profileUpdated);
    } catch (error) {
      _message(
        error is FieldnoteException ? error.message : l10n.profileUpdateFailed,
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _openSavedLocation(FieldnoteUserProfile profile) {
    final latitude = profile.locationLatitude;
    final longitude = profile.locationLongitude;
    if (latitude == null || longitude == null) {
      _message(context.l10n.profileNoMappedLocation);
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
    final l10n = context.l10n;
    return FieldnotePageList(
      children: [
        SectionHeading(
          eyebrow: widget.viewModel.isSponsor
              ? l10n.profileSponsorAccount
              : l10n.profileVolunteerAccount,
          title: _editing ? l10n.profileEditTitle : profile.displayName,
          description: _editing
              ? l10n.profileEditDescription
              : widget.viewModel.isSponsor
              ? l10n.profileSponsorDescription
              : l10n.profileVolunteerDescription,
          trailing: _editing
              ? OutlinedButton(
                  onPressed: _saving
                      ? null
                      : () => setState(() {
                          _resetFromModel();
                          _editing = false;
                        }),
                  child: Text(
                    MaterialLocalizations.of(context).cancelButtonLabel,
                  ),
                )
              : FilledButton.icon(
                  onPressed: () => setState(() => _editing = true),
                  icon: const Icon(Icons.edit_outlined),
                  label: Text(l10n.profileEdit),
                ),
        ),
        const SizedBox(height: 16),
        if (_editing) _editor() else _summary(profile),
      ],
    );
  }

  Widget _summary(FieldnoteUserProfile profile) {
    final availability = widget.viewModel.availability;
    final l10n = context.l10n;
    final number = NumberFormat.decimalPattern(context.localeTag);
    return Column(
      children: [
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detail(
                l10n.profilePhoneNumber,
                profile.contactPhone?.isNotEmpty == true
                    ? profile.contactPhone!
                    : l10n.profileNotProvided,
              ),
              if (widget.viewModel.isSponsor &&
                  profile.contactPhone?.isNotEmpty != true) ...[
                Text(l10n.profileAddPhoneHint),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => setState(() => _editing = true),
                  icon: const Icon(Icons.call_outlined),
                  label: Text(l10n.profileAddContactNumber),
                ),
                const SizedBox(height: 12),
              ],
              _detail(
                widget.viewModel.isSponsor
                    ? l10n.onboardingLocationLabel
                    : l10n.profileHomeArea,
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
                      label: Text(l10n.profileViewLocationOnMap),
                    ),
                  ),
                ),
              _detail(
                l10n.onboardingInterests,
                _values(profile.interests).join(', '),
              ),
              if (widget.viewModel.isSponsor) ...[
                Text(l10n.profilePhoneSharedNotice),
                const SizedBox(height: 12),
                _detail(
                  l10n.onboardingSponsorType,
                  _sponsorTypeLabel(profile.sponsorType ?? 'Individual'),
                ),
                _detail(
                  l10n.profileOrganization,
                  profile.organizationName?.isNotEmpty == true
                      ? profile.organizationName!
                      : l10n.profileNotProvided,
                ),
              ] else ...[
                _detail(
                  l10n.onboardingSkills,
                  _values(profile.skills).join(', '),
                ),
                _detail(
                  l10n.navAvailability,
                  availability?.isAvailable == true
                      ? l10n.profileAvailabilityActive
                      : l10n.profileAvailabilityPaused,
                ),
                _detail(
                  l10n.onboardingAvailableToday,
                  availability?.availableToday == true
                      ? l10n.commonYes
                      : l10n.commonNo,
                ),
                _detail(
                  l10n.profileRegularDays,
                  _weekdayLabel(availability?.weekdays),
                ),
                _detail(
                  l10n.profileHours,
                  l10n.profileHoursRange(
                    _time(availability?.startMinutes ?? 420),
                    _time(availability?.endMinutes ?? 780),
                  ),
                ),
                _detail(
                  l10n.profileTravelRadius,
                  l10n.profileKm(
                    number.format(availability?.maximumTravelKm.round() ?? 10),
                  ),
                ),
                _detail(
                  l10n.profileTravelArea,
                  availability?.locationLabel.isNotEmpty == true
                      ? availability!.locationLabel
                      : l10n.profileNotSelected,
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: widget.onEditAvailability,
                  icon: const Icon(Icons.event_available_outlined),
                  label: Text(l10n.profileEditAvailability),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        _notificationsCard(profile),
        const SizedBox(height: 16),
        _privacyCard(),
        const SizedBox(height: 16),
        AccountDeletionCard(viewModel: widget.viewModel),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            OutlinedButton.icon(
              onPressed: _signingOut ? null : () => _signOut(allDevices: false),
              icon: const Icon(Icons.logout),
              label: Text(l10n.signOut),
            ),
            OutlinedButton.icon(
              onPressed: _signingOut ? null : () => _signOut(allDevices: true),
              icon: const Icon(Icons.devices_other_outlined),
              label: Text(l10n.profileSignOutAllDevices),
            ),
          ],
        ),
      ],
    );
  }

  Widget _notificationsCard(FieldnoteUserProfile profile) {
    return SurfaceCard(
      child: SwitchListTile.adaptive(
        contentPadding: EdgeInsets.zero,
        value: profile.emailNotifications,
        title: Text(context.l10n.profileEmailNotifications),
        subtitle: Text(context.l10n.profileEmailNotificationsBody),
        onChanged: _savingNotifications ? null : _setEmailNotifications,
      ),
    );
  }

  Future<void> _setEmailNotifications(bool enabled) async {
    final l10n = context.l10n;
    setState(() => _savingNotifications = true);
    try {
      await widget.viewModel.setEmailNotifications(enabled);
    } on Object catch (error) {
      if (mounted) {
        _message(
          userMessageFor(
            error,
            fallback: l10n.profileEmailNotificationsFailed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _savingNotifications = false);
    }
  }

  Future<void> _signOut({required bool allDevices}) async {
    final confirmed = await confirmSignOut(context, allDevices: allDevices);
    if (confirmed != true || !mounted) return;
    final l10n = context.l10n;
    setState(() => _signingOut = true);
    final messenger = ScaffoldMessenger.of(context);
    final signedOut = await widget.viewModel.signOut(allDevices: allDevices);
    if (!signedOut) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            allDevices
                ? l10n.profileSignOutAllPartial
                : l10n.profileSignOutLocalOnly,
          ),
        ),
      );
    }
    if (mounted) setState(() => _signingOut = false);
  }

  String _sponsorTypeLabel(String value) => switch (value) {
    'Individual' => context.l10n.sponsorTypeIndividual,
    'Company' => context.l10n.sponsorTypeCompany,
    'Foundation' => context.l10n.sponsorTypeFoundation,
    'Community group' => context.l10n.sponsorTypeCommunityGroup,
    _ => value,
  };

  Widget _editor() {
    final l10n = context.l10n;
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FieldnoteTextField(
            controller: _name,
            decoration: InputDecoration(labelText: l10n.onboardingDisplayName),
          ),
          const SizedBox(height: 12),
          FieldnoteTextField(
            controller: _contactPhone,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: widget.viewModel.isSponsor
                  ? l10n.profilePhoneRequired
                  : l10n.profilePhoneOptional,
              hintText: '+919876543210',
              prefixIcon: const Icon(Icons.call_outlined),
              helperText: widget.viewModel.isSponsor
                  ? l10n.profilePhoneVisibleToJoined
                  : l10n.profilePhonePrivate,
              helperMaxLines: 2,
            ),
          ),
          const SizedBox(height: 12),
          _cityField(),
          const SizedBox(height: 18),
          if (widget.viewModel.isSponsor) ...[
            DropdownButtonFormField<String>(
              initialValue: _sponsorType,
              decoration: InputDecoration(
                labelText: l10n.onboardingSponsorType,
              ),
              // The values are stored on the profile; only labels are localized.
              items:
                  const [
                        'Individual',
                        'Company',
                        'Foundation',
                        'Community group',
                      ]
                      .map(
                        (value) => DropdownMenuItem(
                          value: value,
                          child: Text(_sponsorTypeLabel(value)),
                        ),
                      )
                      .toList(),
              onChanged: (value) => setState(() => _sponsorType = value!),
            ),
            const SizedBox(height: 12),
            FieldnoteTextField(
              controller: _organization,
              decoration: InputDecoration(
                labelText: l10n.onboardingOrganization,
              ),
            ),
          ],
          const SizedBox(height: 18),
          _chips(l10n.onboardingInterests, _interestOptions, _interests),
          if (widget.viewModel.isVolunteer) ...[
            const SizedBox(height: 18),
            _chips(l10n.onboardingSkills, _skillOptions, _skills),
            const Divider(height: 34),
            Text(l10n.profileScheduleManagedInAvailability),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: widget.onEditAvailability,
              icon: const Icon(Icons.event_available_outlined),
              label: Text(l10n.profileEditAvailability),
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
              label: Text(_saving ? l10n.commonSaving : l10n.profileSave),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cityField() {
    final isLocation = widget.viewModel.isSponsor;
    final c = context.fieldnoteColors;
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldnoteTextField(
          controller: _city,
          onChanged: _cityChanged,
          decoration: InputDecoration(
            labelText: isLocation
                ? l10n.onboardingLocationLabel
                : l10n.profileHomeCity,
            hintText: isLocation
                ? l10n.onboardingLocationHint
                : l10n.profileCityHint,
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
                : Icon(Icons.check_circle, color: c.moss),
          ),
        ),
        if (isLocation) ...[
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _openLocationMap,
            icon: const Icon(Icons.map_outlined),
            label: Text(l10n.onboardingChooseOnMap),
          ),
        ],
        if (_citySuggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
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
                    ? l10n.profileLocationSuggestionHint
                    : l10n.profileCitySuggestionHint
              : isLocation
              ? l10n.onboardingPlacesUnavailable
              : l10n.profileCitySearchUnavailable,
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
    final l10n = context.l10n;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.fieldnoteColors.mist,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lock_outline, size: 19),
              const SizedBox(width: 8),
              Text(l10n.profilePrivacyReadOnly),
            ],
          ),
          const SizedBox(height: 10),
          _lockedChoice(
            l10n.profileConsentGps,
            consent?.locationConsent,
          ),
          _lockedChoice(l10n.profileConsentAi, consent?.aiProcessingConsent),
          _lockedChoice(
            l10n.profileConsentEvidence,
            consent?.evidenceSharingConsent,
          ),
          const SizedBox(height: 4),
          Text(l10n.profilePrivacyReviewHint),
        ],
      ),
    );
  }

  Widget _lockedChoice(String label, bool? accepted) => Row(
    children: [
      Icon(
        accepted == true ? Icons.check_circle : Icons.cancel_outlined,
        size: 18,
        color: accepted == true
            ? context.fieldnoteColors.moss
            : context.fieldnoteColors.clay,
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
        final valueWidget = Text(
          value.isEmpty ? context.l10n.profileNotSelected : value,
        );
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
    // 2024-01-01 was a Monday, so DateTime(2024, 1, n) has weekday n.
    final format = DateFormat.E(context.localeTag);
    final values =
        encoded
            ?.split(',')
            .map(int.tryParse)
            .whereType<int>()
            .where((day) => day >= DateTime.monday && day <= DateTime.sunday)
            .map((day) => format.format(DateTime(2024, 1, day)))
            .join(', ') ??
        '';
    return values.isEmpty ? context.l10n.profileNotSelected : values;
  }

  /// Minutes after midnight as a locale-formatted time of day.
  String _time(int minutes) => DateFormat.jm(
    context.localeTag,
  ).format(DateTime(2000, 1, 1, minutes ~/ 60, minutes % 60));
}
