import 'dart:async';
import 'dart:typed_data';

import 'package:fieldnotes_client/fieldnotes_client.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../../data/services/device_location_service.dart';
import '../../core/fieldnote_theme.dart';
import '../../core/widgets.dart';
import '../shell/hackathon_view_model.dart';
import '../sponsor/sponsor_views.dart';

class VolunteerMatchesView extends StatelessWidget {
  const VolunteerMatchesView({super.key, required this.viewModel});

  final HackathonViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final availability = viewModel.availability;
    return RefreshIndicator(
      onRefresh: viewModel.refresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 100),
        children: [
          SectionHeading(
            eyebrow: 'AI opportunity matching',
            title: 'Campaigns that fit your life',
            description:
                'Every score is explained using your availability, travel radius, interests, and remaining campaign places.',
            trailing: StatusPill(
              label: availability?.isAvailable == true
                  ? 'Available for matches'
                  : 'Availability paused',
              color: availability?.isAvailable == true
                  ? FieldnoteColors.forest
                  : FieldnoteColors.clay,
              icon: availability?.isAvailable == true
                  ? Icons.bolt
                  : Icons.pause,
            ),
          ),
          const SizedBox(height: 24),
          if (viewModel.matches.isEmpty)
            EmptyPanel(
              icon: Icons.travel_explore,
              title: 'No matches yet',
              message: availability?.isAvailable == true
                  ? 'Try increasing your travel radius or choosing more available days.'
                  : 'Turn on availability to let AI recommend campaigns.',
            )
          else
            LayoutBuilder(
              builder: (context, constraints) => GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: viewModel.matches.length,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 520,
                  mainAxisExtent: 390,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemBuilder: (context, index) {
                  final match = viewModel.matches[index];
                  final joined = viewModel.participationFor(match.campaign.id!);
                  return CampaignCard(
                    campaign: match.campaign,
                    score: match.score,
                    reasons: [
                      ...match.reasons,
                      '${match.distanceKm.toStringAsFixed(1)} km away',
                    ],
                    actionLabel: joined == null
                        ? 'Join campaign'
                        : 'View my work',
                    onAction: joined == null
                        ? () => _join(context, match.campaign)
                        : () => viewModel.selectSection(1),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _join(BuildContext context, Campaign campaign) async {
    try {
      await viewModel.join(campaign);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You joined ${campaign.name}.')),
      );
    } catch (error) {
      if (!context.mounted) return;
      _showError(context, error, 'Could not join the campaign.');
    }
  }
}

class VolunteerWorkView extends StatelessWidget {
  const VolunteerWorkView({super.key, required this.viewModel});

  final HackathonViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: viewModel.refresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 100),
        children: [
          const SectionHeading(
            eyebrow: 'Volunteer mission control',
            title: 'Arrive. Verify. Show impact.',
            description:
                'GPS confirms arrival. A photo and voice note become sponsor-ready evidence with AI.',
          ),
          const SizedBox(height: 24),
          if (viewModel.participations.isEmpty)
            const EmptyPanel(
              icon: Icons.hiking_outlined,
              title: 'No active campaigns',
              message:
                  'Choose a recommended campaign to begin your first mission.',
            )
          else
            ...viewModel.participations.map((participation) {
              final campaign = viewModel.campaignById(participation.campaignId);
              if (campaign == null) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _MissionCard(
                  campaign: campaign,
                  participation: participation,
                  viewModel: viewModel,
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _MissionCard extends StatefulWidget {
  const _MissionCard({
    required this.campaign,
    required this.participation,
    required this.viewModel,
  });

  final Campaign campaign;
  final CampaignParticipation participation;
  final HackathonViewModel viewModel;

  @override
  State<_MissionCard> createState() => _MissionCardState();
}

class _MissionCardState extends State<_MissionCard> {
  final _locationService = DeviceLocationService();
  StreamSubscription<DeviceLocation>? _locationTracking;
  DeviceLocation? _liveLocation;
  String? _locationError;
  bool _tracking = false;
  bool _working = false;

  @override
  void dispose() {
    _locationTracking?.cancel();
    super.dispose();
  }

  Future<void> _startTracking() async {
    await _locationTracking?.cancel();
    if (mounted) {
      setState(() {
        _tracking = true;
        _locationError = null;
      });
    }
    _locationTracking = _locationService.watch().listen(
      (location) {
        if (!mounted) return;
        setState(() {
          _liveLocation = location;
          _locationError = null;
        });
      },
      onError: (Object error) {
        if (!mounted) return;
        setState(() {
          _tracking = false;
          _locationError = error.toString().replaceFirst('Bad state: ', '');
        });
      },
      onDone: () {
        if (mounted) setState(() => _tracking = false);
      },
    );
  }

  Future<void> _stopTracking() async {
    await _locationTracking?.cancel();
    _locationTracking = null;
    if (mounted) setState(() => _tracking = false);
  }

  Future<void> _checkIn({bool demo = false}) async {
    setState(() => _working = true);
    try {
      final recentLive = _liveLocation;
      final canUseTrackedLocation =
          recentLive != null &&
          DateTime.now().toUtc().difference(recentLive.capturedAt).abs() <
              const Duration(seconds: 30);
      final location = demo
          ? DeviceLocation.demoAt(
              widget.campaign.latitude,
              widget.campaign.longitude,
            )
          : canUseTrackedLocation
          ? recentLive
          : await _locationService.current(allowDemoFallback: false);
      await widget.viewModel.checkIn(
        widget.participation,
        location.latitude,
        location.longitude,
        location.accuracyMeters,
        location.isMocked,
        location.isDemo,
        location.capturedAt,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            demo
                ? 'Demo GPS check-in confirmed.'
                : 'On-site GPS check-in confirmed.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      await _offerDemoCheckIn(error);
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _offerDemoCheckIn(Object error) async {
    final useDemo = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Outside the campaign area'),
        content: Text(
          '${_errorText(error, 'Live GPS check-in was not available.')}\n\n'
          'For a local hackathon demo, you can simulate standing at the campaign pin. This is clearly labeled and never used silently.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.science_outlined),
            label: const Text('Use demo GPS'),
          ),
        ],
      ),
    );
    if (useDemo == true && mounted) await _checkIn(demo: true);
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.participation.status;
    final checkedIn = status == ParticipationStatus.checkedIn;
    final completed = status == ParticipationStatus.completed;
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StatusPill(
                label: completed
                    ? 'Impact submitted'
                    : checkedIn
                    ? 'GPS checked in'
                    : 'Joined',
                color: completed || checkedIn
                    ? FieldnoteColors.forest
                    : FieldnoteColors.clay,
                icon: completed
                    ? Icons.verified
                    : checkedIn
                    ? Icons.gps_fixed
                    : Icons.how_to_reg,
              ),
              const Spacer(),
              Text(
                DateFormat(
                  'EEE, d MMM',
                ).format(widget.campaign.startsAt.toLocal()),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            widget.campaign.name,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 6),
          Text(widget.campaign.locationName),
          const Divider(height: 28),
          Text(
            'Field checklist',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 9),
          ...widget.campaign.checklist
              .split('|')
              .where((item) => item.trim().isNotEmpty)
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 7),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        size: 18,
                        color: FieldnoteColors.moss,
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(item.trim())),
                    ],
                  ),
                ),
              ),
          const SizedBox(height: 14),
          _locationPanel(context),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: completed
                ? OutlinedButton.icon(
                    onPressed: null,
                    icon: Icon(Icons.celebration_outlined),
                    label: Text('Mission complete'),
                  )
                : checkedIn
                ? FilledButton.icon(
                    onPressed: _working
                        ? null
                        : () => showModalBottomSheet<void>(
                            context: context,
                            isScrollControlled: true,
                            useSafeArea: true,
                            builder: (_) => CompletionEvidenceSheet(
                              campaign: widget.campaign,
                              participation: widget.participation,
                              viewModel: widget.viewModel,
                            ),
                          ),
                    icon: const Icon(Icons.add_a_photo_outlined),
                    label: const Text('Submit photo + AI field note'),
                  )
                : FilledButton.icon(
                    onPressed: _working ? null : _checkIn,
                    icon: _working
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.my_location),
                    label: const Text('GPS check in on site'),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _locationPanel(BuildContext context) {
    final location = _liveLocation;
    final distance = location == null
        ? null
        : DeviceLocationService.distanceMeters(
            location,
            widget.campaign.latitude,
            widget.campaign.longitude,
          );
    final inside =
        distance != null &&
        distance <= widget.campaign.geofenceMeters + location!.accuracyMeters;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: FieldnoteColors.mist,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: inside
              ? FieldnoteColors.forest.withValues(alpha: .3)
              : FieldnoteColors.ink.withValues(alpha: .08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_searching, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Live location check',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              StatusPill(
                label: _tracking
                    ? 'GPS streaming'
                    : location == null
                    ? 'Not started'
                    : 'GPS paused',
                color: _tracking
                    ? FieldnoteColors.forest
                    : FieldnoteColors.clay,
                icon: _tracking ? Icons.sensors : Icons.gps_not_fixed,
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (location == null && _locationError == null)
            const Text(
              'Start tracking to request Precise Location and show live coordinates, accuracy, mock-location status, and geofence distance.',
            ),
          if (_locationError != null)
            Text(
              _locationError!,
              style: const TextStyle(color: FieldnoteColors.clay),
            ),
          if (location != null) ...[
            SelectableText(
              '${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _LocationFact(
                  icon: Icons.gps_fixed,
                  label: '±${location.accuracyMeters.round()} m',
                ),
                _LocationFact(
                  icon: location.isMocked
                      ? Icons.gpp_bad_outlined
                      : Icons.verified_user_outlined,
                  label: location.isMocked
                      ? 'Mock flag detected'
                      : 'No mock flag',
                ),
                _LocationFact(
                  icon: inside ? Icons.check_circle : Icons.cancel_outlined,
                  label: distance == null
                      ? 'Calculating distance'
                      : '${distance.round()} m · ${inside ? 'inside' : 'outside'} geofence',
                ),
                _LocationFact(
                  icon: Icons.schedule,
                  label:
                      '${DateTime.now().toUtc().difference(location.capturedAt).inSeconds.abs()} s old',
                ),
              ],
            ),
          ],
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _tracking ? _stopTracking : _startTracking,
            icon: Icon(
              _tracking ? Icons.stop_circle_outlined : Icons.my_location,
            ),
            label: Text(
              _tracking ? 'Stop live tracking' : 'Enable live location',
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Tracking stays on this screen. Only the check-in snapshot is sent to the server.',
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _LocationFact extends StatelessWidget {
  const _LocationFact({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15),
          const SizedBox(width: 5),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}

class CompletionEvidenceSheet extends StatefulWidget {
  const CompletionEvidenceSheet({
    super.key,
    required this.campaign,
    required this.participation,
    required this.viewModel,
  });

  final Campaign campaign;
  final CampaignParticipation participation;
  final HackathonViewModel viewModel;

  @override
  State<CompletionEvidenceSheet> createState() =>
      _CompletionEvidenceSheetState();
}

class _CompletionEvidenceSheetState extends State<CompletionEvidenceSheet> {
  final _note = TextEditingController();
  final _summary = TextEditingController();
  final _picker = ImagePicker();
  final _speech = SpeechToText();
  final _location = DeviceLocationService();
  Uint8List? _photo;
  String _extension = 'jpg';
  CompletionProposal? _proposal;
  bool _working = false;
  bool _listening = false;

  @override
  void dispose() {
    _speech.stop();
    _note.dispose();
    _summary.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource source) async {
    final selected = await _picker.pickImage(
      source: source,
      imageQuality: 78,
      maxWidth: 1600,
    );
    if (selected == null) return;
    final bytes = await selected.readAsBytes();
    final suffix = selected.name.split('.').last.toLowerCase();
    if (mounted) {
      setState(() {
        _photo = bytes;
        _extension = {'jpg', 'jpeg', 'png', 'webp'}.contains(suffix)
            ? suffix
            : 'jpg';
      });
    }
  }

  Future<void> _toggleSpeech() async {
    if (_listening) {
      await _speech.stop();
      if (mounted) setState(() => _listening = false);
      return;
    }
    final ready = await _speech.initialize();
    if (!ready) {
      if (mounted) {
        _showError(
          context,
          StateError('Speech unavailable'),
          'Speech recognition is unavailable on this device.',
        );
      }
      return;
    }
    setState(() => _listening = true);
    await _speech.listen(
      onResult: (result) {
        _note.text = result.recognizedWords;
        _note.selection = TextSelection.collapsed(offset: _note.text.length);
        if (result.finalResult && mounted) setState(() => _listening = false);
      },
    );
  }

  Future<void> _analyze() async {
    if (_photo == null) {
      _showError(
        context,
        StateError('Missing photograph'),
        'Take or choose an evidence photograph so Gemini can analyze it with your note.',
      );
      return;
    }
    if (_note.text.trim().length < 5) {
      _showError(
        context,
        StateError('Short note'),
        'Add or dictate a short field note first.',
      );
      return;
    }
    setState(() => _working = true);
    try {
      final value = await widget.viewModel.repository.analyzeCompletion(
        widget.participation.id!,
        _note.text,
        _photo,
        _mimeType(_extension),
      );
      if (mounted) {
        setState(() {
          _proposal = value;
          _summary.text = value.summary;
        });
      }
    } catch (error) {
      if (mounted) {
        _showError(context, error, 'AI could not analyze this field note.');
      }
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  static String _mimeType(String extension) => switch (extension) {
    'png' => 'image/png',
    'webp' => 'image/webp',
    _ => 'image/jpeg',
  };

  Future<void> _submit() async {
    if (_photo == null || _proposal == null || _summary.text.trim().isEmpty) {
      _showError(
        context,
        StateError('Missing evidence'),
        'Add a photo and confirm the AI summary first.',
      );
      return;
    }
    setState(() => _working = true);
    try {
      final gps = widget.participation.locationIsDemo
          ? DeviceLocation.demoAt(
              widget.campaign.latitude,
              widget.campaign.longitude,
            )
          : await _location.current(allowDemoFallback: false);
      await widget.viewModel.repository.completeWithEvidence(
        participationId: widget.participation.id!,
        photograph: _photo!,
        extension: _extension,
        originalNote: _note.text,
        confirmedSummary: _summary.text,
        structuredResults: _proposal!.structuredResults,
        latitude: gps.latitude,
        longitude: gps.longitude,
        accuracyMeters: gps.accuracyMeters,
        deviceReportedMock: gps.isMocked,
        explicitDemo: gps.isDemo,
        capturedAt: gps.capturedAt,
      );
      await widget.viewModel.participationCompleted();
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impact evidence sent to the sponsor.')),
      );
    } catch (error) {
      if (mounted) _showError(context, error, 'Could not submit evidence.');
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: .9,
      minChildSize: .65,
      maxChildSize: .96,
      builder: (context, scrollController) => ListView(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(24, 14, 24, 40),
        children: [
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: FieldnoteColors.ink.withValues(alpha: .18),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const SectionHeading(
            eyebrow: 'AI evidence assistant',
            title: 'Show what changed',
            description:
                'Capture one photo, dictate the result, then confirm the AI-generated summary.',
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => _pick(ImageSource.camera),
            child: Container(
              height: 220,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: FieldnoteColors.mist,
                borderRadius: BorderRadius.circular(20),
              ),
              child: _photo == null
                  ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo_outlined, size: 42),
                        SizedBox(height: 8),
                        Text('Take evidence photograph'),
                      ],
                    )
                  : Image.memory(
                      _photo!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => _pick(ImageSource.gallery),
            icon: const Icon(Icons.photo_library_outlined),
            label: const Text('Choose from gallery'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _note,
            minLines: 3,
            maxLines: 6,
            decoration: InputDecoration(
              labelText: 'What did your team complete?',
              hintText: 'We planted 12 saplings and cleared 8 bags of waste…',
              suffixIcon: IconButton(
                tooltip: _listening ? 'Stop listening' : 'Dictate note',
                onPressed: _toggleSpeech,
                icon: Icon(_listening ? Icons.mic : Icons.mic_none),
                color: _listening ? FieldnoteColors.clay : null,
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _working ? null : _analyze,
            icon: const Icon(Icons.auto_awesome),
            label: Text(_working ? 'Analyzing…' : 'AI analyze field note'),
          ),
          if (_proposal != null) ...[
            const SizedBox(height: 18),
            SurfaceCard(
              color: FieldnoteColors.acid.withValues(alpha: .35),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const StatusPill(
                    label: 'AI draft · volunteer confirms',
                    color: FieldnoteColors.clay,
                    icon: Icons.auto_awesome,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _summary,
                    minLines: 2,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Confirmed impact summary',
                    ),
                  ),
                  const SizedBox(height: 10),
                  ..._proposal!.structuredResults.map(
                    (result) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          const Icon(Icons.insights, size: 17),
                          const SizedBox(width: 7),
                          Expanded(child: Text(result)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _working ? null : _submit,
                      icon: const Icon(Icons.verified_outlined),
                      label: const Text('Confirm and submit evidence'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class VolunteerAvailabilityView extends StatefulWidget {
  const VolunteerAvailabilityView({super.key, required this.viewModel});

  final HackathonViewModel viewModel;

  @override
  State<VolunteerAvailabilityView> createState() =>
      _VolunteerAvailabilityViewState();
}

class _VolunteerAvailabilityViewState extends State<VolunteerAvailabilityView> {
  final _locationService = DeviceLocationService();
  final Set<int> _days = {};
  bool _available = true;
  bool _today = false;
  double _radius = 10;
  DeviceLocation? _location;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final value = widget.viewModel.availability;
    if (value != null) {
      _available = value.isAvailable;
      _today = value.availableToday;
      _radius = value.maximumTravelKm;
      _days.addAll(
        value.weekdays.split(',').map(int.tryParse).whereType<int>(),
      );
      if (value.latitude != null && value.longitude != null) {
        _location = DeviceLocation(
          latitude: value.latitude!,
          longitude: value.longitude!,
          accuracyMeters: 50,
          isLive: value.locationLabel != 'Hackathon demo venue',
          isMocked: value.locationLabel == 'Hackathon demo venue',
          capturedAt: DateTime.now().toUtc(),
          isDemo: value.locationLabel == 'Hackathon demo venue',
        );
      }
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      _location ??= await _locationService.current();
      await widget.viewModel.repository.updateAvailability(
        isAvailable: _available,
        availableToday: _today,
        weekdays: _days.toList(),
        startMinutes: widget.viewModel.availability?.startMinutes ?? 7 * 60,
        endMinutes: widget.viewModel.availability?.endMinutes ?? 13 * 60,
        maximumTravelKm: _radius,
        latitude: _location!.latitude,
        longitude: _location!.longitude,
        locationLabel: _location!.isLive
            ? 'Current GPS area'
            : 'Hackathon demo venue',
      );
      await widget.viewModel.availabilityUpdated();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Availability updated. AI matches refreshed.'),
          ),
        );
      }
    } catch (error) {
      if (mounted) _showError(context, error, 'Could not update availability.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const names = {
      1: 'Mon',
      2: 'Tue',
      3: 'Wed',
      4: 'Thu',
      5: 'Fri',
      6: 'Sat',
      7: 'Sun',
    };
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 100),
      children: [
        const SectionHeading(
          eyebrow: 'Your most important setting',
          title: 'Availability powers every match',
          description:
              'FieldNote only recommends work that fits your schedule and chosen travel radius.',
        ),
        const SizedBox(height: 24),
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: _available,
                title: const Text('I am available for campaigns'),
                subtitle: const Text(
                  'Pause this without deleting your preferences.',
                ),
                onChanged: (value) => setState(() => _available = value),
              ),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: _today,
                title: const Text('I can help today'),
                onChanged: (value) => setState(() => _today = value),
              ),
              const Divider(height: 28),
              Text(
                'Regular days',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 9),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: names.entries
                    .map(
                      (entry) => FilterChip(
                        label: Text(entry.value),
                        selected: _days.contains(entry.key),
                        onSelected: (selected) => setState(() {
                          selected
                              ? _days.add(entry.key)
                              : _days.remove(entry.key);
                        }),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 22),
              Text(
                'Maximum travel · ${_radius.round()} km',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Slider(
                value: _radius,
                min: 2,
                max: 50,
                divisions: 24,
                label: '${_radius.round()} km',
                onChanged: (value) => setState(() => _radius = value),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () async {
                  final location = await _locationService.current();
                  if (mounted) setState(() => _location = location);
                },
                icon: const Icon(Icons.my_location),
                label: Text(
                  _location == null
                      ? 'Update my GPS area'
                      : _location!.isLive
                      ? 'Live GPS area selected'
                      : 'Hackathon demo venue selected',
                ),
              ),
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
                      : const Icon(Icons.auto_awesome),
                  label: Text(
                    _saving
                        ? 'Refreshing matches…'
                        : 'Save and refresh AI matches',
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

void _showError(BuildContext context, Object error, String fallback) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(_errorText(error, fallback))),
  );
}

String _errorText(Object error, String fallback) {
  if (error is FieldnoteException) return error.message;
  return fallback;
}
