import 'dart:async';
import 'dart:typed_data';

import 'package:fieldnotes_client/fieldnotes_client.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../../data/services/device_location_service.dart';
import '../../core/in_app_maps.dart';
import '../../core/fieldnote_map.dart';
import '../../core/fieldnote_theme.dart';
import '../../core/widgets.dart';
import '../shell/fieldnote_view_model.dart';
import '../sponsor/sponsor_views.dart';
import 'volunteer_area_map_screen.dart';

class VolunteerMatchesView extends StatefulWidget {
  const VolunteerMatchesView({super.key, required this.viewModel});

  final FieldnoteViewModel viewModel;

  @override
  State<VolunteerMatchesView> createState() => _VolunteerMatchesViewState();
}

class _VolunteerMatchesViewState extends State<VolunteerMatchesView> {
  FieldnoteViewModel get viewModel => widget.viewModel;

  @override
  Widget build(BuildContext context) {
    final availability = viewModel.availability;
    final invitedCampaigns = viewModel.invitations
        .map((invitation) => viewModel.campaignById(invitation.campaignId))
        .whereType<Campaign>()
        .where(
          (campaign) => viewModel.participationFor(campaign.id!) == null,
        )
        .toList();
    final orderedMatches = [...viewModel.matches]
      ..sort((a, b) {
        final invitedA = viewModel.invitedTo(a.campaign.id!) ? 1 : 0;
        final invitedB = viewModel.invitedTo(b.campaign.id!) ? 1 : 0;
        return invitedB.compareTo(invitedA);
      });
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              FieldnoteSpacing.pageGutter(context),
              16,
              FieldnoteSpacing.pageGutter(context),
              12,
            ),
            child: SectionHeading(
              eyebrow: 'Volunteer campaigns',
              title: 'Find a campaign',
              description: 'Browse nearby work and invitations.',
            ),
          ),
          const FieldnoteSectionTabs(
            compact: true,
            tabs: [
              FieldnoteSectionTab('List', Icons.view_agenda_outlined),
              FieldnoteSectionTab('Map', Icons.map_outlined),
              FieldnoteSectionTab('Invites', Icons.mark_email_unread_outlined),
            ],
          ),
          const SizedBox(height: 4),
          Expanded(
            child: TabBarView(
              children: [
                _matchesList(orderedMatches, availability),
                _matchesMap(orderedMatches, availability),
                _invitations(invitedCampaigns),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _matchesList(
    List<CampaignMatch> matches,
    VolunteerAvailability? availability,
  ) => RefreshIndicator(
    onRefresh: viewModel.refresh,
    child: FieldnotePageList(
      key: const PageStorageKey('volunteer-matches-list'),
      top: 12,
      children: [
        if (matches.isEmpty)
          EmptyPanel(
            icon: Icons.travel_explore,
            title: 'No matches yet',
            message: availability?.isAvailable == true
                ? 'Try increasing your travel radius or choosing more available days.'
                : 'Turn on availability to let AI recommend campaigns.',
          )
        else
          ResponsiveCardGrid(
            children: [
              for (final match in matches)
                Builder(
                  builder: (context) {
                    final joined = viewModel.participationFor(
                      match.campaign.id!,
                    );
                    return CampaignCard(
                      campaign: match.campaign,
                      showFunding: false,
                      score: match.score,
                      reasons: [
                        if (viewModel.invitedTo(match.campaign.id!))
                          'The campaign creator invited you to join',
                        ...match.reasons,
                        distanceLabel(match),
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
            ],
          ),
      ],
    ),
  );

  Widget _matchesMap(
    List<CampaignMatch> matches,
    VolunteerAvailability? availability,
  ) => RefreshIndicator(
    onRefresh: viewModel.refresh,
    child: FieldnotePageList(
      key: const PageStorageKey('volunteer-matches-map'),
      top: 12,
      children: [
        if (!mapsAvailable)
          const EmptyPanel(
            icon: Icons.map_outlined,
            title: 'Map unavailable',
            message: 'Open List to browse and join campaigns.',
          )
        else if (matches.isEmpty)
          const EmptyPanel(
            icon: Icons.travel_explore,
            title: 'No campaigns on the map yet',
            message: 'Check your availability and travel radius, then refresh.',
          )
        else
          _MatchMap(
            matches: matches,
            availability: availability,
            onOpen: _openMatch,
          ),
      ],
    ),
  );

  Widget _invitations(List<Campaign> campaigns) => RefreshIndicator(
    onRefresh: viewModel.refresh,
    child: FieldnotePageList(
      key: const PageStorageKey('volunteer-invitations'),
      top: 12,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                campaigns.isEmpty
                    ? 'Invitations'
                    : 'Invitations (${campaigns.length})',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            IconButton.filledTonal(
              tooltip: 'Check for invitations',
              onPressed: viewModel.refresh,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (campaigns.isEmpty)
          SurfaceCard(
            child: Row(
              children: [
                const Icon(Icons.mark_email_unread_outlined, size: 28),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'No invitations yet. Pull down to check again.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          )
        else
          ResponsiveCardGrid(
            children: [
              for (final campaign in campaigns)
                CampaignCard(
                  campaign: campaign,
                  showFunding: false,
                  reasons: const ['The campaign creator invited you to join'],
                  actionLabel: 'Join campaign',
                  onAction: () => _join(context, campaign),
                ),
            ],
          ),
      ],
    ),
  );

  void _openMatch(CampaignMatch match) {
    final reasons = [
      if (viewModel.invitedTo(match.campaign.id!))
        'The campaign creator invited you to join',
      ...match.reasons,
    ];
    if (!reasons.any((reason) => reason.contains('by road'))) {
      reasons.add(distanceLabel(match));
    }
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (sheetContext) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.62,
        minChildSize: 0.35,
        maxChildSize: 0.85,
        builder: (context, scrollController) => Column(
          children: [
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 8),
                children: [
                  Text(
                    match.campaign.name,
                    style: Theme.of(sheetContext).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 6),
                  Text(match.campaign.locationName),
                  const SizedBox(height: 14),
                  for (final reason in reasons)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 7),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.check_circle_outline, size: 17),
                          const SizedBox(width: 8),
                          Expanded(child: Text(reason)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(sheetContext);
                          Navigator.of(this.context).push<void>(
                            MaterialPageRoute(
                              builder: (_) => TravelMapScreen(
                                campaign: match.campaign,
                                repository: viewModel.repository,
                                canStartTravel:
                                    match.campaign.readinessState ==
                                        'confirmed' &&
                                    viewModel
                                            .participationFor(
                                              match.campaign.id!,
                                            )
                                            ?.confirmedRevision ==
                                        match.campaign.revision,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.directions_outlined),
                        label: const Text('View route'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed:
                            viewModel.participationFor(match.campaign.id!) ==
                                null
                            ? () {
                                Navigator.pop(sheetContext);
                                _join(this.context, match.campaign);
                              }
                            : () {
                                Navigator.pop(sheetContext);
                                viewModel.selectSection(1);
                              },
                        icon: const Icon(Icons.how_to_reg_outlined),
                        label: Text(
                          viewModel.participationFor(match.campaign.id!) == null
                              ? 'Join'
                              : 'My work',
                        ),
                      ),
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

/// Prefers the Routes API travel time over straight-line distance, because
/// "18 min drive" is what a volunteer actually decides on. Falls back to the
/// haversine figure whenever Routes is unconfigured or unreachable.
String distanceLabel(CampaignMatch match) {
  final minutes = match.travelMinutes;
  if (minutes == null) {
    return '${match.distanceKm.toStringAsFixed(1)} km away (straight line)';
  }
  final byRoad = match.travelDistanceKm ?? match.distanceKm;
  return '$minutes min drive · ${byRoad.toStringAsFixed(1)} km by road';
}

/// Every match as a pin inside the volunteer's own travel radius.
class _MatchMap extends StatelessWidget {
  const _MatchMap({
    required this.matches,
    required this.availability,
    required this.onOpen,
  });

  final List<CampaignMatch> matches;
  final VolunteerAvailability? availability;
  final void Function(CampaignMatch match) onOpen;

  @override
  Widget build(BuildContext context) {
    final homeLatitude = availability?.latitude;
    final homeLongitude = availability?.longitude;
    final home = homeLatitude == null || homeLongitude == null
        ? null
        : LatLng(homeLatitude, homeLongitude);
    final points = [
      ?home,
      for (final match in matches)
        LatLng(match.campaign.latitude, match.campaign.longitude),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldnoteMap(
          target: points.first,
          height: 330,
          semanticLabel: 'Map of matched campaigns inside your travel radius',
          fitBounds: points,
          markers: {
            if (home != null)
              Marker(
                markerId: const MarkerId('home'),
                position: home,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  FieldnoteMapPalette.volunteer,
                ),
                infoWindow: InfoWindow(
                  title: 'Your area',
                  snippet: availability?.locationLabel,
                ),
              ),
            for (final match in matches)
              Marker(
                markerId: MarkerId('campaign-${match.campaign.id}'),
                position: LatLng(
                  match.campaign.latitude,
                  match.campaign.longitude,
                ),
                // Strong matches stay green; weaker ones fade to orange so the
                // map carries the same ranking the list does.
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  match.score >= 70
                      ? FieldnoteMapPalette.campaign
                      : match.score >= 45
                      ? BitmapDescriptor.hueYellow
                      : BitmapDescriptor.hueOrange,
                ),
                infoWindow: InfoWindow(
                  title: '${match.campaign.name} · ${match.score.round()}%',
                  snippet: distanceLabel(match),
                ),
                onTap: () => onOpen(match),
              ),
          },
          circles: {
            if (home != null && availability != null)
              radiusCircle(
                id: 'travel-radius',
                center: home,
                radiusMeters: availability!.maximumTravelKm * 1000,
                color: FieldnoteColors.forest,
              ),
          },
        ),
        const SizedBox(height: 10),
        const MapLegend(
          entries: [
            (color: FieldnoteColors.forest, label: 'Strong match'),
            (color: Color(0xFFE0B341), label: 'Moderate match'),
            (color: FieldnoteColors.clay, label: 'Weaker match'),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Tap a pin for the full score explanation. The ring is your saved '
          'travel radius.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class VolunteerWorkView extends StatelessWidget {
  const VolunteerWorkView({super.key, required this.viewModel});

  final FieldnoteViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: viewModel.refresh,
      child: FieldnotePageList(
        children: [
          const SectionHeading(
            eyebrow: 'Your campaigns',
            title: 'My work',
            description:
                'See your joined campaigns, directions, and next steps.',
          ),
          const SizedBox(height: 16),
          if (viewModel.participations.isEmpty)
            SurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.hiking_outlined, size: 30),
                  const SizedBox(height: 12),
                  Text(
                    'No joined campaigns yet',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  const Text('Find a campaign nearby and join when it fits.'),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: () => viewModel.selectSection(0),
                    icon: const Icon(Icons.travel_explore),
                    label: const Text('Browse campaigns'),
                  ),
                ],
              ),
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
  final FieldnoteViewModel viewModel;

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
  String? _contactPhone;
  bool _loadingContact = true;
  bool _contactLoadFailed = false;
  late Future<List<CampaignPost>> _posts;

  @override
  void initState() {
    super.initState();
    _loadContact();
    _posts = widget.viewModel.repository.campaignPosts(widget.campaign.id!);
  }

  @override
  void didUpdateWidget(covariant _MissionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.campaign.revision != widget.campaign.revision ||
        oldWidget.campaign.readinessState != widget.campaign.readinessState) {
      _posts = widget.viewModel.repository.campaignPosts(widget.campaign.id!);
    }
    if (oldWidget.campaign.id != widget.campaign.id) {
      _contactPhone = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _loadContact();
        }
      });
    }
  }

  Future<void> _loadContact({bool showResult = false}) async {
    if (_loadingContact && _contactPhone != null) return;
    if (mounted) setState(() => _loadingContact = true);
    try {
      final phone = await widget.viewModel.repository.campaignContactPhone(
        widget.campaign.id!,
      );
      if (mounted) {
        setState(() {
          _contactPhone = phone;
          _contactLoadFailed = false;
        });
        if (showResult && phone == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'This campaign creator has no saved phone number yet.',
              ),
            ),
          );
        }
        if (showResult && phone != null) await _dialPhone(phone);
      }
    } on Object {
      if (mounted) {
        setState(() => _contactLoadFailed = true);
        if (showResult) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not load contact. Try again.')),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _loadingContact = false);
    }
  }

  Future<void> _callCreator() async {
    final phone = _contactPhone;
    if (phone == null) return;
    await _dialPhone(phone);
  }

  Future<void> _dialPhone(String phone) async {
    var opened = false;
    try {
      opened = await launchUrl(
        Uri(scheme: 'tel', path: phone),
        mode: LaunchMode.externalApplication,
      );
    } on Object {
      opened = false;
    }
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the phone dialer.')),
      );
    }
  }

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

  Future<void> _checkIn() async {
    setState(() => _working = true);
    try {
      final recentLive = _liveLocation;
      final canUseTrackedLocation =
          recentLive != null &&
          DateTime.now().toUtc().difference(recentLive.capturedAt).abs() <
              const Duration(seconds: 30);
      final location = canUseTrackedLocation
          ? recentLive
          : await _locationService.current();
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
            'On-site GPS check-in confirmed.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      _showError(context, error, 'Live GPS check-in was not available.');
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _reconfirm() async {
    setState(() => _working = true);
    try {
      await widget.viewModel.repository.reconfirmParticipation(
        widget.participation.id!,
      );
      await widget.viewModel.refresh();
    } catch (error) {
      if (mounted) {
        _showError(context, error, 'Could not reconfirm your place.');
      }
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.participation.status;
    final checkedIn = status == ParticipationStatus.checkedIn;
    final completed = status == ParticipationStatus.completed;
    final needsReconfirmation =
        widget.participation.confirmedRevision != widget.campaign.revision &&
        !completed;
    final eventConfirmed = widget.campaign.readinessState == 'confirmed';
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
          const SizedBox(height: 12),
          Text(
            widget.campaign.name,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            widget.campaign.locationName,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 10),
          StatusPill(
            label: switch (widget.campaign.readinessState) {
              'confirmed' => 'Event confirmed',
              'postponed' => 'Postponed · new proposed date',
              'cancelled' => 'Event cancelled',
              'expired' => 'Proposed date expired',
              'fundingShort' ||
              'volunteersShort' ||
              'bothShort' => 'Awaiting sponsor decision',
              _ => 'Date tentative',
            },
            color: eventConfirmed
                ? FieldnoteColors.forest
                : FieldnoteColors.clay,
            icon: eventConfirmed ? Icons.verified_outlined : Icons.schedule,
          ),
          FutureBuilder<List<CampaignPost>>(
            future: _posts,
            builder: (context, snapshot) {
              final latest = snapshot.data?.firstOrNull;
              if (latest == null) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text('Organizer update: ${latest.body}'),
              );
            },
          ),
          if (needsReconfirmation &&
              !const {
                'cancelled',
                'expired',
              }.contains(widget.campaign.readinessState)) ...[
            const SizedBox(height: 8),
            const Text(
              'The sponsor changed the date or work scope. Review the details, then reconfirm your place.',
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _working ? null : _reconfirm,
              icon: const Icon(Icons.how_to_reg_outlined),
              label: const Text('Reconfirm my place'),
            ),
          ],
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _loadingContact
                ? null
                : _contactPhone == null
                ? () => _loadContact(showResult: true)
                : _callCreator,
            icon: const Icon(Icons.call_outlined),
            label: Text(
              _loadingContact
                  ? 'Loading campaign contact…'
                  : _contactPhone == null
                  ? 'Refresh creator contact'
                  : 'Call campaign creator',
            ),
          ),
          if (!_loadingContact && _contactPhone == null) ...[
            const SizedBox(height: 6),
            Text(
              _contactLoadFailed
                  ? 'Could not load the contact. Tap to retry.'
                  : 'The creator of this campaign has not added a phone number yet. They can add it in their Profile.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
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
                    onPressed:
                        _working || !eventConfirmed || needsReconfirmation
                        ? null
                        : _checkIn,
                    icon: _working
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.my_location),
                    label: Text(
                      !eventConfirmed
                          ? 'Await event confirmation'
                          : needsReconfirmation
                          ? 'Reconfirm your place first'
                          : 'GPS check in on site',
                    ),
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
          const SizedBox(height: 12),
          _approachMap(context, location, distance, inside),
          const SizedBox(height: 12),
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
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton.icon(
                onPressed: _tracking ? _stopTracking : _startTracking,
                icon: Icon(
                  _tracking ? Icons.stop_circle_outlined : Icons.my_location,
                ),
                label: Text(
                  _tracking ? 'Stop live tracking' : 'Enable live location',
                ),
              ),
              OutlinedButton.icon(
                onPressed:
                    const {'cancelled', 'expired'}.contains(
                      widget.campaign.readinessState,
                    )
                    ? null
                    : () => Navigator.of(context).push<void>(
                        MaterialPageRoute(
                          builder: (_) => TravelMapScreen(
                            campaign: widget.campaign,
                            repository: widget.viewModel.repository,
                            canStartTravel:
                                widget.campaign.readinessState == 'confirmed' &&
                                widget.participation.confirmedRevision ==
                                    widget.campaign.revision &&
                                widget.participation.status !=
                                    ParticipationStatus.completed,
                          ),
                        ),
                      ),
                icon: const Icon(Icons.directions_walk),
                label: Text(
                  const {'cancelled', 'expired'}.contains(
                        widget.campaign.readinessState,
                      )
                      ? 'Route unavailable'
                      : 'View route',
                ),
              ),
            ],
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

  /// The approach map. Before this existed a volunteer who failed the geofence
  /// check was told only "you are 412 m away" with no indication of which way
  /// to walk, which was the highest-friction moment in the whole flow.
  Widget _approachMap(
    BuildContext context,
    DeviceLocation? location,
    double? distance,
    bool inside,
  ) {
    final campaignPoint = LatLng(
      widget.campaign.latitude,
      widget.campaign.longitude,
    );
    final here = location == null
        ? null
        : LatLng(location.latitude, location.longitude);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldnoteMap(
          target: campaignPoint,
          zoom: zoomForRadius(widget.campaign.geofenceMeters),
          height: 210,
          semanticLabel:
              'Map showing the campaign geofence and your live position',
          fitBounds: here == null ? null : [campaignPoint, here],
          myLocationEnabled: _tracking,
          markers: {
            Marker(
              markerId: const MarkerId('campaign'),
              position: campaignPoint,
              icon: BitmapDescriptor.defaultMarkerWithHue(
                FieldnoteMapPalette.campaign,
              ),
              infoWindow: InfoWindow(
                title: widget.campaign.name,
                snippet: widget.campaign.locationName,
              ),
            ),
            if (here != null)
              Marker(
                markerId: const MarkerId('me'),
                position: here,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  inside
                      ? FieldnoteMapPalette.verified
                      : FieldnoteMapPalette.volunteer,
                ),
                infoWindow: InfoWindow(
                  title: 'You are here',
                  snippet: distance == null
                      ? null
                      : '${distance.round()} m from the pin',
                ),
              ),
          },
          circles: {
            radiusCircle(
              id: 'geofence',
              center: campaignPoint,
              radiusMeters: widget.campaign.geofenceMeters,
              color: inside ? FieldnoteColors.forest : FieldnoteColors.clay,
            ),
            if (here != null && location != null)
              radiusCircle(
                id: 'accuracy',
                center: here,
                radiusMeters: location.accuracyMeters,
                color: FieldnoteColors.moss,
                strokeWidth: 1,
              ),
          },
          polylines: {
            if (here != null)
              Polyline(
                polylineId: const PolylineId('approach'),
                points: [here, campaignPoint],
                color: FieldnoteColors.clay.withValues(alpha: .7),
                width: 3,
                patterns: const [],
              ),
          },
          fallback: MapUnavailableNotice(
            message: distance == null
                ? 'Map preview is off. Enable live location for a distance '
                      'readout, or add a Maps key to draw the geofence.'
                : 'Map preview is off. You are ${distance.round()} m from the '
                      'campaign pin (geofence '
                      '${widget.campaign.geofenceMeters.round()} m).',
          ),
        ),
        if (mapsAvailable) ...[
          const SizedBox(height: 8),
          MapLegend(
            entries: [
              (color: FieldnoteColors.forest, label: 'Campaign pin'),
              (
                color: inside ? FieldnoteColors.forest : FieldnoteColors.clay,
                label:
                    'Geofence '
                    '${widget.campaign.geofenceMeters.round()} m',
              ),
              (color: FieldnoteColors.moss, label: 'Your GPS accuracy'),
            ],
          ),
        ],
      ],
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
  final FieldnoteViewModel viewModel;

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
        'Take or choose an evidence photograph so AI can analyze it with your note.',
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
      final gps = await _location.current();
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
                'Capture one photo, describe the result, then confirm the structured summary.',
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
          FieldnoteTextField(
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
                  FieldnoteTextField(
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

  final FieldnoteViewModel viewModel;

  @override
  State<VolunteerAvailabilityView> createState() =>
      _VolunteerAvailabilityViewState();
}

class _VolunteerAvailabilityViewState extends State<VolunteerAvailabilityView> {
  final _locationService = DeviceLocationService();
  final _placeSearch = TextEditingController();
  final Set<int> _days = {};
  bool _available = true;
  bool _today = false;
  double _radius = 10;
  DeviceLocation? _location;
  bool _saving = false;

  /// True once the volunteer has dragged or tapped the pin themselves, which
  /// makes the saved area a deliberate choice rather than wherever the device
  /// happened to be.
  bool _pinnedByHand = false;
  String? _areaName;
  int _geocodeRequest = 0;
  int _searchRequest = 0;
  Timer? _searchDebounce;
  List<PlaceSuggestion> _suggestions = const [];
  bool _searchAvailable = false;
  bool _searching = false;
  String? _searchMessage;

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
        _areaName = value.locationLabel;
        _placeSearch.text = value.locationLabel;
        _location = DeviceLocation(
          latitude: value.latitude!,
          longitude: value.longitude!,
          accuracyMeters: 50,
          isLive: true,
          isMocked: false,
          capturedAt: DateTime.now().toUtc(),
          isDemo: false,
        );
      }
    }
    unawaited(_checkPlaceSearch());
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _placeSearch.dispose();
    super.dispose();
  }

  Future<void> _checkPlaceSearch() async {
    try {
      final available = await widget.viewModel.repository
          .placeSearchAvailable();
      if (mounted) setState(() => _searchAvailable = available);
    } on Object {
      // A map pin and GPS remain available without Places.
    }
  }

  void _onSearchChanged(String query) {
    _searchDebounce?.cancel();
    final request = ++_searchRequest;
    ++_geocodeRequest;
    setState(() {
      _suggestions = const [];
      _searchMessage = null;
      _searching = false;
    });
    if (query.trim().length < 3) return;
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      unawaited(_findPlace(query.trim(), request));
    });
  }

  Future<void> _findPlace(String query, int request) async {
    if (!mounted || request != _searchRequest) return;
    setState(() => _searching = true);
    try {
      final results = await widget.viewModel.repository.searchPlaces(
        query,
        biasLatitude: _location?.latitude,
        biasLongitude: _location?.longitude,
      );
      if (!mounted || request != _searchRequest) return;
      setState(() {
        _suggestions = results;
        _searchMessage = results.isEmpty ? 'No matching places found.' : null;
      });
    } on Object {
      if (mounted && request == _searchRequest) {
        setState(
          () => _searchMessage =
              'Place search is unavailable. Move the pin or use GPS.',
        );
      }
    } finally {
      if (mounted && request == _searchRequest) {
        setState(() => _searching = false);
      }
    }
  }

  Future<void> _choosePlace(PlaceSuggestion suggestion) async {
    _searchDebounce?.cancel();
    final request = ++_geocodeRequest;
    ++_searchRequest;
    FocusScope.of(context).unfocus();
    setState(() {
      _suggestions = const [];
      _searching = false;
    });
    try {
      final place = await widget.viewModel.repository.resolvePlace(
        suggestion.placeId,
      );
      if (!mounted || request != _geocodeRequest) return;
      final label = place.address.trim().isNotEmpty
          ? place.address.trim()
          : place.name.trim();
      setState(() {
        _pinnedByHand = true;
        _areaName = label.isNotEmpty ? label : suggestion.primaryText;
        _placeSearch.text = _areaName!;
        _searchMessage = null;
        _location = DeviceLocation(
          latitude: place.latitude,
          longitude: place.longitude,
          accuracyMeters: 50,
          isLive: true,
          isMocked: false,
          capturedAt: DateTime.now().toUtc(),
          isDemo: false,
        );
      });
    } on Object {
      if (mounted && request == _geocodeRequest) {
        setState(
          () => _searchMessage =
              'Could not select that place. Try another result.',
        );
      }
    }
  }

  /// Moves the saved area pin and asks the server to name it. Reverse
  /// geocoding is best-effort: a null answer just leaves the previous label.
  Future<void> _movePin(LatLng point) async {
    _searchDebounce?.cancel();
    ++_searchRequest;
    final request = ++_geocodeRequest;
    final coordinates =
        '${point.latitude.toStringAsFixed(5)}, ${point.longitude.toStringAsFixed(5)}';
    setState(() {
      _pinnedByHand = true;
      _areaName = coordinates;
      _placeSearch.text = coordinates;
      _suggestions = const [];
      _searchMessage = null;
      _location = DeviceLocation(
        latitude: point.latitude,
        longitude: point.longitude,
        accuracyMeters: 50,
        isLive: true,
        isMocked: false,
        capturedAt: DateTime.now().toUtc(),
        isDemo: false,
      );
    });
    try {
      final place = await widget.viewModel.repository.describeCoordinates(
        point.latitude,
        point.longitude,
      );
      // Ignore a slow answer that lost the race to a newer drag.
      if (!mounted || request != _geocodeRequest || place == null) return;
      final label = place.address.trim().isNotEmpty
          ? place.address.trim()
          : place.name.trim();
      if (label.isNotEmpty) {
        setState(() {
          _areaName = label;
          _placeSearch.text = label;
        });
      }
    } on Object {
      // Naming the pin is a nicety; the coordinates are what matter.
    }
  }

  Future<void> _describeGps(DeviceLocation location) async {
    final request = _geocodeRequest;
    try {
      final place = await widget.viewModel.repository.describeCoordinates(
        location.latitude,
        location.longitude,
      );
      if (!mounted || request != _geocodeRequest || place == null) return;
      final label = place.address.trim().isNotEmpty
          ? place.address.trim()
          : place.name.trim();
      if (label.isNotEmpty) {
        setState(() {
          _areaName = label;
          _placeSearch.text = label;
        });
      }
    } on Object {
      // The GPS coordinates remain selected when a label is unavailable.
    }
  }

  String get _savedLabel {
    final name = _areaName?.trim();
    if (name != null && name.isNotEmpty) return name;
    return _pinnedByHand ? 'Chosen map area' : 'Current GPS area';
  }

  Future<void> _save() async {
    if (_searchAvailable &&
        _placeSearch.text.trim().isNotEmpty &&
        _placeSearch.text.trim() != _savedLabel) {
      setState(
        () => _searchMessage =
            'Select a search result, or clear the search to keep the current pin.',
      );
      return;
    }
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
        locationLabel: _savedLabel,
      );
      await widget.viewModel.availabilityUpdated();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Availability saved.'),
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
    return FieldnotePageList(
      children: [
        const SectionHeading(
          eyebrow: 'Volunteer preferences',
          title: 'Availability',
          description: 'Choose when and how far you can travel.',
        ),
        const SizedBox(height: 16),
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
                'Where you can travel from',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Drag the pin to the area you actually set out from. The ring '
                'is the radius below, drawn to scale.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              if (_searchAvailable) ...[
                TextField(
                  controller: _placeSearch,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    labelText: 'Search Google Places',
                    hintText: 'Address, landmark, or city',
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
                if (_searchMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(_searchMessage!),
                ],
                if (_suggestions.isNotEmpty)
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 220),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _suggestions.length.clamp(0, 5),
                      itemBuilder: (context, index) {
                        final suggestion = _suggestions[index];
                        return ListTile(
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
                const SizedBox(height: 12),
              ],
              _areaMap(context),
              const SizedBox(height: 16),
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
                  try {
                    final location = await _locationService.current();
                    if (!mounted) return;
                    _searchDebounce?.cancel();
                    ++_searchRequest;
                    ++_geocodeRequest;
                    setState(() {
                      _location = location;
                      _pinnedByHand = false;
                      _areaName =
                          '${location.latitude.toStringAsFixed(5)}, ${location.longitude.toStringAsFixed(5)}';
                      _placeSearch.text = _areaName!;
                      _suggestions = const [];
                      _searchMessage = null;
                    });
                    unawaited(_describeGps(location));
                  } on Object catch (error) {
                    if (mounted) {
                      _showError(
                        this.context,
                        error,
                        'Could not get your current location.',
                      );
                    }
                  }
                },
                icon: const Icon(Icons.my_location),
                label: Text(
                  _location == null
                      ? 'Use my current GPS area'
                      : _pinnedByHand
                      ? 'Reset to my current GPS area'
                      : _location!.isLive
                      ? 'Live GPS area selected'
                      : 'Location selected',
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
                      : const Icon(Icons.save_outlined),
                  label: Text(_saving ? 'Saving…' : 'Save'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _expandAreaMap() async {
    final location = _location;
    final selected = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder: (_) => VolunteerAreaMapScreen(
          radiusKm: _radius,
          initialPoint: location == null
              ? null
              : LatLng(location.latitude, location.longitude),
        ),
      ),
    );
    if (!mounted || selected == null) return;
    await _movePin(selected);
  }

  Widget _areaMap(BuildContext context) {
    final location = _location;
    // Before any area is chosen, open at a neutral country-level view. This
    // point is never saved; saving requires an actual device location.
    final point = location == null
        ? LatLng(
            20.5937,
            78.9629,
          )
        : LatLng(location.latitude, location.longitude);
    final radiusMeters = _radius * 1000;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            FieldnoteMap(
              target: point,
              zoom: zoomForRadius(radiusMeters),
              height: 260,
              semanticLabel: 'Draggable map pin for your travel area',
              onTap: _movePin,
              markers: location == null
                  ? const {}
                  : {
                      Marker(
                        markerId: const MarkerId('area'),
                        position: point,
                        draggable: true,
                        onDragEnd: _movePin,
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                          FieldnoteMapPalette.volunteer,
                        ),
                        infoWindow: InfoWindow(
                          title: 'Your travel area',
                          snippet: _areaName ?? _savedLabel,
                        ),
                      ),
                    },
              circles: location == null
                  ? const {}
                  : {
                      radiusCircle(
                        id: 'radius',
                        center: point,
                        radiusMeters: radiusMeters,
                        color: FieldnoteColors.forest,
                      ),
                    },
              fallback: MapUnavailableNotice(
                message: location == null
                    ? 'Map preview is off. Use the GPS button below to set your '
                          'area.'
                    : 'Map preview is off. Saved area: '
                          '${point.latitude.toStringAsFixed(4)}, '
                          '${point.longitude.toStringAsFixed(4)} '
                          '(${_radius.round()} km radius).',
              ),
            ),
            if (mapsAvailable)
              Positioned(
                top: 8,
                right: 8,
                child: IconButton.filledTonal(
                  key: const Key('expand-volunteer-area-map'),
                  tooltip: 'Expand map',
                  onPressed: _expandAreaMap,
                  icon: const Icon(Icons.fullscreen),
                ),
              ),
          ],
        ),
        if (mapsAvailable) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.place_outlined, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _areaName ?? _savedLabel,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ],
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
