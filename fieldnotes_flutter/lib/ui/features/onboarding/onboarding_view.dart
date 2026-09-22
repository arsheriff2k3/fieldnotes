import 'package:fieldnotes_client/fieldnotes_client.dart';
import 'package:flutter/material.dart';

import '../../../data/services/device_location_service.dart';
import '../../../data/services/pending_role_service.dart';
import '../../core/fieldnote_theme.dart';
import '../../core/widgets.dart';
import '../shell/hackathon_view_model.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key, required this.viewModel});

  final HackathonViewModel viewModel;

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final _roles = PendingRoleService();
  final _location = DeviceLocationService();
  final _name = TextEditingController();
  final _city = TextEditingController(text: 'Pune');
  final _organization = TextEditingController();
  AccountRole? _role;
  String _sponsorType = 'Individual';
  final Set<String> _interests = {'environment'};
  final Set<String> _skills = {'outdoors'};
  final Set<int> _weekdays = {DateTime.saturday, DateTime.sunday};
  double _radius = 10;
  bool _available = true;
  bool _availableToday = false;
  DeviceLocation? _deviceLocation;
  bool _saving = false;
  bool _locating = false;
  bool _locationConsent = false;
  bool _aiConsent = false;
  bool _evidenceConsent = false;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final role = await _roles.load();
    if (mounted) setState(() => _role = role);
  }

  @override
  void dispose() {
    _name.dispose();
    _city.dispose();
    _organization.dispose();
    super.dispose();
  }

  Future<void> _locate() async {
    setState(() => _locating = true);
    final value = await _location.current();
    if (mounted) {
      setState(() {
        _deviceLocation = value;
        _locating = false;
      });
    }
  }

  Future<void> _save() async {
    if (_role == null || _name.text.trim().length < 2) {
      _message('Choose a role and enter your name.');
      return;
    }
    if (!_locationConsent || !_aiConsent || !_evidenceConsent) {
      _message('Review and accept all three demo privacy choices.');
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
          city: _city.text,
          interests: _interests.toList(),
        );
      } else {
        _deviceLocation ??= await _location.current();
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
          locationLabel: _deviceLocation!.isLive
              ? 'Current GPS area'
              : 'Hackathon demo venue',
        );
      }
      final consent = await widget.viewModel.repository.acceptLegalConsent();
      await _roles.clear();
      await widget.viewModel.onboardingCompleted(profile, consent);
    } catch (error) {
      _message(
        error is FieldnoteException
            ? error.message
            : 'Could not complete account setup.',
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
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 60),
            children: [
              const Row(
                children: [
                  Icon(Icons.eco, color: FieldnoteColors.forest),
                  SizedBox(width: 8),
                  Text(
                    'FIELDNOTE · ACCOUNT SETUP',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 26),
              SectionHeading(
                eyebrow: _role?.name ?? 'Choose role',
                title: _role == AccountRole.sponsor
                    ? 'Set up your sponsor profile'
                    : 'Tell AI when and where you can help',
                description: _role == AccountRole.sponsor
                    ? 'Sponsors create, fund, and monitor campaigns.'
                    : 'Availability and GPS are used to explain every campaign match.',
              ),
              const SizedBox(height: 22),
              if (_role == null) _rolePicker(),
              if (_role != null)
                SurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _name,
                        decoration: const InputDecoration(
                          labelText: 'Display name',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _city,
                        decoration: const InputDecoration(
                          labelText: 'City',
                          prefixIcon: Icon(Icons.location_city_outlined),
                        ),
                      ),
                      const SizedBox(height: 18),
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
                            _saving ? 'Preparing account…' : 'Enter FieldNote',
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
    );
  }

  Widget _rolePicker() {
    return Row(
      children: AccountRole.values
          .map(
            (role) => Expanded(
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await _roles.save(role);
                    setState(() => _role = role);
                  },
                  icon: Icon(
                    role == AccountRole.sponsor
                        ? Icons.volunteer_activism_outlined
                        : Icons.directions_walk_outlined,
                  ),
                  label: Text(role.name),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _sponsorFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          initialValue: _sponsorType,
          decoration: const InputDecoration(labelText: 'Sponsor type'),
          items:
              const ['Individual', 'Company', 'Foundation', 'Community group']
                  .map(
                    (value) =>
                        DropdownMenuItem(value: value, child: Text(value)),
                  )
                  .toList(),
          onChanged: (value) =>
              setState(() => _sponsorType = value ?? 'Individual'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _organization,
          decoration: const InputDecoration(
            labelText: 'Organization name (optional)',
          ),
        ),
        const SizedBox(height: 18),
        _choiceChips(
          title: 'Preferred causes',
          values: const ['environment', 'tree care', 'cleanup', 'community'],
          selected: _interests,
        ),
      ],
    );
  }

  Widget _volunteerFields() {
    const days = {
      1: 'Mon',
      2: 'Tue',
      3: 'Wed',
      4: 'Thu',
      5: 'Fri',
      6: 'Sat',
      7: 'Sun',
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          value: _available,
          title: const Text('Available for campaign matches'),
          onChanged: (value) => setState(() => _available = value),
        ),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          value: _availableToday,
          title: const Text('Available today'),
          onChanged: (value) => setState(() => _availableToday = value),
        ),
        const SizedBox(height: 8),
        Text('Available days', style: Theme.of(context).textTheme.labelLarge),
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
        Text('Travel radius · ${_radius.round()} km'),
        Slider(
          value: _radius,
          min: 2,
          max: 50,
          divisions: 24,
          onChanged: (value) => setState(() => _radius = value),
        ),
        OutlinedButton.icon(
          onPressed: _locating ? null : _locate,
          icon: _locating
              ? const SizedBox.square(
                  dimension: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.my_location),
          label: Text(
            _deviceLocation == null
                ? 'Use current GPS location'
                : _deviceLocation!.isLive
                ? 'Live GPS captured'
                : 'Using hackathon demo venue',
          ),
        ),
        const SizedBox(height: 18),
        _choiceChips(
          title: 'Interests',
          values: const ['environment', 'tree care', 'cleanup', 'community'],
          selected: _interests,
        ),
        const SizedBox(height: 14),
        _choiceChips(
          title: 'Skills',
          values: const ['outdoors', 'gardening', 'organizing', 'photography'],
          selected: _skills,
        ),
      ],
    );
  }

  Widget _consentFields() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: FieldnoteColors.mist,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Privacy choices · required for this demo',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          const Text(
            'You can review these records and request data export or deletion from Trust Center.',
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: _locationConsent,
            title: const Text('Use GPS for matching and evidence integrity'),
            onChanged: (value) =>
                setState(() => _locationConsent = value ?? false),
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: _aiConsent,
            title: const Text('Send campaign/evidence input to Gemini AI'),
            onChanged: (value) => setState(() => _aiConsent = value ?? false),
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: _evidenceConsent,
            title: const Text(
              'Share submitted evidence privately with campaign sponsors',
            ),
            onChanged: (value) =>
                setState(() => _evidenceConsent = value ?? false),
          ),
          const Text(
            'By continuing you accept FieldNote Demo Terms and Privacy Policy v2026-09-22.',
            style: TextStyle(fontSize: 12),
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
