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
import '../../core/error_messages.dart';
import '../../core/fieldnote_theme.dart';
import '../../core/widgets.dart';
import '../shell/fieldnote_view_model.dart';
import '../sponsor/sponsor_views.dart';
import 'volunteer_area_map_screen.dart';
import 'volunteer_history_view.dart';
import 'volunteer_status.dart';

class VolunteerMatchesView extends StatefulWidget {
  const VolunteerMatchesView({super.key, required this.viewModel});

  final FieldnoteViewModel viewModel;

  @override
  State<VolunteerMatchesView> createState() => _VolunteerMatchesViewState();
}

class _VolunteerMatchesViewState extends State<VolunteerMatchesView> {
  FieldnoteViewModel get viewModel => widget.viewModel;

  /// Campaign ids with a join request in flight.
  final Set<int> _joining = {};

  bool _holdsPlace(int campaignId) =>
      holdsPlace(viewModel.participationFor(campaignId));

  bool _isFull(int campaignId) => viewModel.matches.any(
    (match) => match.campaign.id == campaignId && match.isFull,
  );

  /// Label and action for a campaign card: My work, Full, Joining, or Join.
  ({String label, VoidCallback? onAction}) _joinAction(
    BuildContext context,
    Campaign campaign,
  ) {
    final id = campaign.id!;
    if (_holdsPlace(id)) {
      return (
        label: 'View my work',
        onAction: () => viewModel.selectSection(1),
      );
    }
    if (_isFull(id)) return (label: 'Full', onAction: null);
    if (_joining.contains(id)) return (label: 'Joining…', onAction: null);
    return (label: 'Join campaign', onAction: () => _join(context, campaign));
  }

  @override
  Widget build(BuildContext context) {
    final availability = viewModel.availability;
    final invitedCampaigns = viewModel.invitations
        .map((invitation) => viewModel.campaignById(invitation.campaignId))
        .whereType<Campaign>()
        .where((campaign) => !_holdsPlace(campaign.id!))
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
                    final action = _joinAction(context, match.campaign);
                    return CampaignCard(
                      campaign: match.campaign,
                      showFunding: false,
                      score: match.score,
                      reasons: [
                        if (match.isFull && !_holdsPlace(match.campaign.id!))
                          'Every place is taken',
                        if (viewModel.invitedTo(match.campaign.id!))
                          'The campaign creator invited you to join',
                        ...match.reasons,
                        distanceLabel(match),
                      ],
                      actionLabel: action.label,
                      onAction: action.onAction,
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
                Builder(
                  builder: (context) {
                    final action = _joinAction(context, campaign);
                    return CampaignCard(
                      campaign: campaign,
                      showFunding: false,
                      reasons: const [
                        'The campaign creator invited you to join',
                      ],
                      actionLabel: action.label,
                      onAction: action.onAction,
                    );
                  },
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
                      child: Builder(
                        builder: (_) {
                          final action = _joinAction(
                            this.context,
                            match.campaign,
                          );
                          final onAction = action.onAction;
                          return FilledButton.icon(
                            onPressed: onAction == null
                                ? null
                                : () {
                                    Navigator.pop(sheetContext);
                                    onAction();
                                  },
                            icon: const Icon(Icons.how_to_reg_outlined),
                            label: Text(switch (action.label) {
                              'Join campaign' => 'Join',
                              'View my work' => 'My work',
                              final other => other,
                            }),
                          );
                        },
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
    final id = campaign.id!;
    if (_joining.contains(id)) return;
    setState(() => _joining.add(id));
    final messenger = ScaffoldMessenger.of(context);
    try {
      await viewModel.join(campaign);
      messenger.showSnackBar(
        SnackBar(content: Text('You joined ${campaign.name}.')),
      );
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(_errorText(error, 'Could not join the campaign.')),
        ),
      );
    } finally {
      if (mounted) setState(() => _joining.remove(id));
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

  void _openHistory(BuildContext context) {
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => VolunteerHistoryScreen(viewModel: viewModel),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final historyById = {
      for (final entry in viewModel.participationHistory)
        if (entry.participation.id != null) entry.participation.id!: entry,
    };
    // Participations from the history whose row is missing from the
    // participations list are still shown.
    final participations = [
      ...viewModel.participations,
      for (final entry in viewModel.participationHistory)
        if (!viewModel.participations.any(
          (item) => item.id == entry.participation.id,
        ))
          entry.participation,
    ];
    final active = <Widget>[];
    final past = <Widget>[];
    for (final participation in participations) {
      final campaign =
          viewModel.campaignById(participation.campaignId) ??
          historyById[participation.id]?.campaign;
      final display = participationDisplay(participation, campaign);
      final Widget card;
      if (campaign == null) {
        card = _MinimalParticipationCard(
          participation: participation,
          display: display,
        );
      } else if (display.isActive) {
        card = _MissionCard(
          key: ValueKey('mission-${participation.id}'),
          campaign: campaign,
          participation: participation,
          viewModel: viewModel,
        );
      } else {
        card = _ClosedMissionCard(
          campaign: campaign,
          participation: participation,
          display: display,
          evidence: historyById[participation.id]?.evidence,
          onOpenHistory: () => _openHistory(context),
        );
      }
      (display.isActive ? active : past).add(
        Padding(padding: const EdgeInsets.only(bottom: 16), child: card),
      );
    }
    return RefreshIndicator(
      onRefresh: () async {
        await viewModel.refresh();
        await viewModel.loadParticipationHistory();
      },
      child: FieldnotePageList(
        children: [
          SectionHeading(
            eyebrow: 'Your campaigns',
            title: 'My work',
            description:
                'See your joined campaigns, directions, and next steps.',
            trailing: OutlinedButton.icon(
              key: const Key('open-volunteer-history'),
              onPressed: () => _openHistory(context),
              icon: const Icon(Icons.history),
              label: const Text('My impact & history'),
            ),
          ),
          const SizedBox(height: 16),
          if (active.isEmpty)
            SurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.hiking_outlined, size: 30),
                  const SizedBox(height: 12),
                  Text(
                    past.isEmpty
                        ? 'No joined campaigns yet'
                        : 'No upcoming campaigns',
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
            ...active,
          if (past.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Past and closed',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            ...past,
          ],
        ],
      ),
    );
  }
}

/// A participation whose campaign is in no loaded list.
class _MinimalParticipationCard extends StatelessWidget {
  const _MinimalParticipationCard({
    required this.participation,
    required this.display,
  });

  final CampaignParticipation participation;
  final ParticipationDisplay display;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StatusPill(
            label: display.label,
            color: display.color,
            icon: display.icon,
          ),
          const SizedBox(height: 12),
          Text(
            'Campaign #${participation.campaignId}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Joined ${DateFormat('EEE, d MMM').format(participation.joinedAt.toLocal())}. '
            'Pull down to refresh the campaign details.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

/// Compact card for a participation the volunteer can no longer act on.
class _ClosedMissionCard extends StatelessWidget {
  const _ClosedMissionCard({
    required this.campaign,
    required this.participation,
    required this.display,
    required this.evidence,
    required this.onOpenHistory,
  });

  final Campaign campaign;
  final CampaignParticipation participation;
  final ParticipationDisplay display;
  final CompletionEvidence? evidence;
  final VoidCallback onOpenHistory;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: StatusPill(
                  label: display.label,
                  color: display.color,
                  icon: display.icon,
                ),
              ),
              const SizedBox(width: 8),
              const Spacer(),
              Text(
                DateFormat('EEE, d MMM').format(campaign.startsAt.toLocal()),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(campaign.name, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            campaign.locationName,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (display.detail != null) ...[
            const SizedBox(height: 8),
            Text(display.detail!),
          ],
          if (evidence != null) ...[
            const SizedBox(height: 8),
            Text(
              reviewStateLabel(evidence!.reviewState),
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ],
          if (participation.status == ParticipationStatus.completed) ...[
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: onOpenHistory,
              icon: const Icon(Icons.photo_outlined),
              label: const Text('View my evidence'),
            ),
          ],
        ],
      ),
    );
  }
}

class _MissionCard extends StatefulWidget {
  const _MissionCard({
    super.key,
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

  /// The fix the server accepted for check-in, reused for evidence while it
  /// is still fresh (V-8).
  DeviceLocation? _checkInFix;
  Object? _locationError;
  bool _tracking = false;
  bool _working = false;
  bool _leaving = false;
  String? _contactPhone;
  bool _loadingContact = true;
  bool _contactLoadFailed = false;
  late Future<List<CampaignPost>> _posts;

  /// Rebuilds the card when the check-in window opens or closes (V-7).
  Timer? _windowTimer;

  @override
  void initState() {
    super.initState();
    _loadContact();
    _posts = widget.viewModel.repository.campaignPosts(widget.campaign.id!);
    _scheduleWindowTimer();
  }

  void _scheduleWindowTimer() {
    _windowTimer?.cancel();
    final now = DateTime.now().toUtc();
    final next = [
      checkInOpensAt(widget.campaign),
      campaignEnd(widget.campaign),
    ].where((at) => at.isAfter(now)).firstOrNull;
    if (next == null) return;
    // Timers are capped so a far-future campaign never schedules a huge
    // delay; the card simply re-checks.
    final delay = next.difference(now) + const Duration(seconds: 1);
    _windowTimer = Timer(
      delay > const Duration(hours: 6) ? const Duration(hours: 6) : delay,
      () {
        if (!mounted) return;
        setState(() {});
        _scheduleWindowTimer();
      },
    );
  }

  @override
  void didUpdateWidget(covariant _MissionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.campaign.revision != widget.campaign.revision ||
        oldWidget.campaign.readinessState != widget.campaign.readinessState) {
      _posts = widget.viewModel.repository.campaignPosts(widget.campaign.id!);
    }
    if (oldWidget.campaign.startsAt != widget.campaign.startsAt ||
        oldWidget.campaign.endsAt != widget.campaign.endsAt) {
      _scheduleWindowTimer();
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
    _windowTimer?.cancel();
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
          _locationError = error;
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
      final now = DateTime.now().toUtc();
      final recentLive = _liveLocation;
      final canUseTrackedLocation =
          recentLive != null &&
          now.difference(recentLive.capturedAt).abs() <
              const Duration(seconds: 30) &&
          recentLive.accuracyMeters <= maxAcceptedAccuracyMeters;
      final location = canUseTrackedLocation
          ? recentLive
          : await _locationService.current();
      if (location.accuracyMeters > maxAcceptedAccuracyMeters) {
        if (mounted) {
          setState(() => _liveLocation = location);
          _showMessage(context, accuracyMessage(location.accuracyMeters));
        }
        return;
      }
      await widget.viewModel.checkIn(
        widget.participation,
        location.latitude,
        location.longitude,
        location.accuracyMeters,
        location.isMocked,
        location.isDemo,
        location.capturedAt,
      );
      _checkInFix = location;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('On-site GPS check-in confirmed.')),
      );
    } catch (error) {
      if (!mounted) return;
      _showError(context, error, 'Live GPS check-in was not available.');
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _leave() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Leave this campaign?'),
        content: Text(
          'Your place in ${widget.campaign.name} will be freed for another '
          'volunteer. You can join again later if places are still open.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Stay'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: FieldnoteColors.danger,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Leave campaign'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _leaving = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await _stopTracking();
      await widget.viewModel.leaveCampaign(widget.participation);
      messenger.showSnackBar(
        SnackBar(content: Text('You left ${widget.campaign.name}.')),
      );
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(_errorText(error, 'Could not leave the campaign.')),
        ),
      );
    } finally {
      if (mounted) setState(() => _leaving = false);
    }
  }

  /// The freshest accurate fix this card holds, for evidence submission.
  DeviceLocation? _bestRecentFix() {
    final now = DateTime.now().toUtc();
    final candidates =
        [
              _liveLocation,
              _checkInFix,
            ]
            .where((fix) => isReusableFix(fix, now))
            .cast<DeviceLocation>()
            .toList()
          ..sort((a, b) => b.capturedAt.compareTo(a.capturedAt));
    return candidates.firstOrNull;
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
    final now = DateTime.now().toUtc();
    final display = participationDisplay(
      widget.participation,
      widget.campaign,
      now: now,
    );
    final status = widget.participation.status;
    final checkedIn = status == ParticipationStatus.checkedIn;
    final needsReconfirmation =
        widget.participation.confirmedRevision != widget.campaign.revision;
    final eventConfirmed = widget.campaign.readinessState == 'confirmed';
    final window = checkInWindow(widget.campaign, now);
    final busy = _working || _leaving;
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: StatusPill(
                  label: display.label,
                  color: display.color,
                  icon: display.icon,
                ),
              ),
              const SizedBox(width: 8),
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
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              StatusPill(
                label: switch (widget.campaign.readinessState) {
                  'confirmed' => 'Event confirmed',
                  'postponed' => 'Postponed · new proposed date',
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
              StatusPill(
                label:
                    '${DateFormat('HH:mm').format(widget.campaign.startsAt.toLocal())}'
                    '–${DateFormat('HH:mm').format(campaignEnd(widget.campaign).toLocal())}',
                color: FieldnoteColors.moss,
                icon: Icons.access_time,
              ),
            ],
          ),
          if (display.detail != null) ...[
            const SizedBox(height: 8),
            Text(display.detail!),
          ],
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
          if (needsReconfirmation && !checkedIn) ...[
            const SizedBox(height: 8),
            const Text(
              'The sponsor changed the date or work scope. Review the details, then reconfirm your place.',
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: busy ? null : _reconfirm,
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
          if (display.canComplete)
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: busy
                    ? null
                    : () => showModalBottomSheet<void>(
                        context: context,
                        isScrollControlled: true,
                        useSafeArea: true,
                        builder: (_) => CompletionEvidenceSheet(
                          campaign: widget.campaign,
                          participation: widget.participation,
                          viewModel: widget.viewModel,
                          recentFix: _bestRecentFix,
                        ),
                      ),
                icon: const Icon(Icons.add_a_photo_outlined),
                label: const Text('Submit photo + field note'),
              ),
            )
          else if (display.canCheckIn) ...[
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                key: const Key('check-in-button'),
                onPressed:
                    busy ||
                        !eventConfirmed ||
                        needsReconfirmation ||
                        window != CheckInWindow.open
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
                      : window == CheckInWindow.notYetOpen
                      ? checkInOpensLabel(widget.campaign, now)
                      : window == CheckInWindow.closed
                      ? 'Check-in has closed'
                      : 'GPS check in on site',
                ),
              ),
            ),
            if (eventConfirmed && window == CheckInWindow.notYetOpen) ...[
              const SizedBox(height: 6),
              Text(
                'Check-in is open from 30 minutes before the start until the '
                'end of the event.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
          if (display.canLeave) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                key: const Key('leave-campaign-button'),
                style: TextButton.styleFrom(
                  foregroundColor: FieldnoteColors.danger,
                ),
                onPressed: busy ? null : _leave,
                icon: _leaving
                    ? const SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.logout),
                label: Text(_leaving ? 'Leaving…' : 'Leave campaign'),
              ),
            ),
          ],
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
    // The server rejects fixes weaker than 150 m, so a poor fix is never
    // reported as inside the geofence.
    final accuracyTooLow =
        location != null && location.accuracyMeters > maxAcceptedAccuracyMeters;
    final inside =
        distance != null &&
        !accuracyTooLow &&
        distance <= widget.campaign.geofenceMeters + location!.accuracyMeters;
    final locationError = _locationError;
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
          if (locationError != null) ...[
            Text(
              _errorText(locationError, 'Live location is unavailable.'),
              style: const TextStyle(color: FieldnoteColors.clay),
            ),
            ?_settingsButton(locationError),
          ],
          if (accuracyTooLow) ...[
            Text(
              accuracyMessage(location.accuracyMeters),
              style: const TextStyle(color: FieldnoteColors.clay),
            ),
            const SizedBox(height: 8),
          ],
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
                  icon: inside
                      ? Icons.check_circle
                      : accuracyTooLow
                      ? Icons.gps_not_fixed
                      : Icons.cancel_outlined,
                  label: distance == null
                      ? 'Calculating distance'
                      : accuracyTooLow
                      ? '${distance.round()} m · accuracy too low'
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
    this.recentFix,
  });

  final Campaign campaign;
  final CampaignParticipation participation;
  final FieldnoteViewModel viewModel;

  /// Returns a fresh, accurate fix the caller already holds (live tracking or
  /// the check-in fix), so submission does not need a second GPS read (V-8).
  final DeviceLocation? Function()? recentFix;

  @override
  State<CompletionEvidenceSheet> createState() =>
      _CompletionEvidenceSheetState();
}

enum _SubmitPhase { idle, locating, uploading }

class _CompletionEvidenceSheetState extends State<CompletionEvidenceSheet> {
  final _note = TextEditingController();
  final _summary = TextEditingController();
  final _picker = ImagePicker();
  final _speech = SpeechToText();
  final _location = DeviceLocationService();
  Uint8List? _photo;
  String _extension = 'jpg';
  CompletionProposal? _proposal;

  /// The volunteer writes the summary themselves (P0-8): AI is unavailable,
  /// the server returned its non-AI fallback, analysis failed, or the
  /// volunteer chose to.
  bool _manual = false;
  bool _analyzing = false;
  _SubmitPhase _phase = _SubmitPhase.idle;
  bool _listening = false;
  bool _speechReady = false;
  String _noteBeforeDictation = '';
  String? _accuracyProblem;

  bool get _working => _analyzing || _phase != _SubmitPhase.idle;

  @override
  void initState() {
    super.initState();
    if (widget.viewModel.aiAvailable == false) _manual = true;
    if (widget.viewModel.aiAvailable == null) {
      unawaited(
        widget.viewModel.loadAiAvailability().then((_) {
          if (mounted && widget.viewModel.aiAvailable == false) {
            setState(() => _manual = true);
          }
        }),
      );
    }
  }

  @override
  void dispose() {
    _speech.cancel();
    _note.dispose();
    _summary.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource source) async {
    try {
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
    } on Object catch (error) {
      if (mounted) {
        _showError(
          context,
          error,
          source == ImageSource.camera
              ? 'The camera is unavailable. Allow camera access or choose from the gallery.'
              : 'Could not open the photo library.',
        );
      }
    }
  }

  void _speechError(String message, {bool permission = false}) {
    if (!mounted) return;
    setState(() => _listening = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: permission
            ? SnackBarAction(
                label: 'Open settings',
                onPressed: () =>
                    unawaited(_openSafely(_location.openAppSettings)),
              )
            : null,
      ),
    );
  }

  static const _micPermissionMessage =
      'Microphone access is off. Allow microphone and speech recognition for '
      'FieldNote in Settings, or type your note.';

  Future<void> _toggleSpeech() async {
    if (_listening) {
      await _speech.stop();
      if (mounted) setState(() => _listening = false);
      return;
    }
    if (!_speechReady) {
      try {
        _speechReady = await _speech.initialize(
          onError: (error) {
            final permission = error.errorMsg.contains('permission');
            _speechError(
              permission
                  ? _micPermissionMessage
                  : error.errorMsg == 'error_no_match' ||
                        error.errorMsg == 'error_speech_timeout'
                  ? 'No speech was heard. Try again or type your note.'
                  : 'Dictation stopped. Try again or type your note.',
              permission: permission,
            );
          },
          onStatus: (status) {
            if (!mounted) return;
            if (status == SpeechToText.doneStatus ||
                status == SpeechToText.notListeningStatus) {
              setState(() => _listening = false);
            }
          },
        );
      } on Object {
        _speechReady = false;
      }
      if (!_speechReady) {
        var permitted = true;
        try {
          permitted = await _speech.hasPermission;
        } on Object {
          permitted = true;
        }
        _speechError(
          permitted
              ? 'Speech recognition is unavailable on this device. Type your note instead.'
              : _micPermissionMessage,
          permission: !permitted,
        );
        return;
      }
    }
    _noteBeforeDictation = _note.text.trim();
    setState(() => _listening = true);
    try {
      await _speech.listen(
        onResult: (result) {
          final words = result.recognizedWords;
          _note.text = _noteBeforeDictation.isEmpty
              ? words
              : '$_noteBeforeDictation $words';
          _note.selection = TextSelection.collapsed(offset: _note.text.length);
          if (result.finalResult && mounted) setState(() => _listening = false);
        },
      );
    } on Object {
      _speechError('Dictation could not start. Type your note instead.');
    }
  }

  bool _requirePhoto() {
    if (_photo != null) return true;
    _showMessage(
      context,
      'Take or choose an evidence photograph first.',
    );
    return false;
  }

  Future<void> _analyze() async {
    if (!_requirePhoto()) return;
    if (_note.text.trim().length < minSummaryLength) {
      _showMessage(
        context,
        'Add or dictate a field note of at least $minSummaryLength characters.',
      );
      return;
    }
    setState(() => _analyzing = true);
    try {
      final value = await widget.viewModel.repository.analyzeCompletion(
        widget.participation.id!,
        _note.text.trim(),
        _photo,
        _mimeType(_extension),
      );
      if (mounted) {
        setState(() {
          _proposal = value;
          _manual = isFallbackProposal(value);
          _summary.text = value.summary;
        });
      }
    } catch (error) {
      if (mounted) {
        // Never block submission on AI: fall back to a summary the volunteer
        // writes from their own note.
        setState(() {
          _manual = true;
          if (_summary.text.trim().isEmpty) _summary.text = _note.text.trim();
        });
        _showError(
          context,
          error,
          'AI could not analyze this note. Write the summary yourself below.',
        );
      }
    } finally {
      if (mounted) setState(() => _analyzing = false);
    }
  }

  void _writeMyself() {
    setState(() {
      _manual = true;
      if (_summary.text.trim().isEmpty) _summary.text = _note.text.trim();
    });
  }

  static String _mimeType(String extension) => switch (extension) {
    'png' => 'image/png',
    'webp' => 'image/webp',
    _ => 'image/jpeg',
  };

  bool get _deadlinePassed =>
      isCampaignClosed(widget.campaign) ||
      DateTime.now().toUtc().isAfter(completionDeadline(widget.campaign));

  Future<DeviceLocation?> _submissionFix() async {
    final recent = widget.recentFix?.call();
    if (isReusableFix(recent, DateTime.now().toUtc())) return recent;
    final gps = await _location.current();
    final problem = locationProblem(gps, DateTime.now().toUtc());
    if (problem != null) {
      if (mounted) setState(() => _accuracyProblem = problem);
      return null;
    }
    return gps;
  }

  Future<void> _submit() async {
    if (!_requirePhoto()) return;
    final summary = _summary.text.trim();
    if (summary.length < minSummaryLength ||
        summary.length > maxSummaryLength) {
      _showMessage(
        context,
        'Write a summary of the completed work '
        '($minSummaryLength–$maxSummaryLength characters).',
      );
      return;
    }
    if (_note.text.trim().length > maxSummaryLength) {
      _showMessage(
        context,
        'Keep the field note under $maxSummaryLength characters.',
      );
      return;
    }
    setState(() {
      _phase = _SubmitPhase.locating;
      _accuracyProblem = null;
    });
    try {
      final gps = await _submissionFix();
      if (gps == null || !mounted) return;
      setState(() => _phase = _SubmitPhase.uploading);
      final manual = _manual || _proposal == null;
      final proposal = _proposal;
      await widget.viewModel.repository.completeWithEvidence(
        participationId: widget.participation.id!,
        photograph: _photo!,
        extension: _extension,
        originalNote: _note.text.trim(),
        confirmedSummary: summary,
        structuredResults: manual || proposal == null
            ? manualResultsFrom(summary)
            : proposal.structuredResults,
        latitude: gps.latitude,
        longitude: gps.longitude,
        accuracyMeters: gps.accuracyMeters,
        deviceReportedMock: gps.isMocked,
        explicitDemo: gps.isDemo,
        capturedAt: gps.capturedAt,
        manualSummary: manual,
      );
      await widget.viewModel.participationCompleted();
      unawaited(widget.viewModel.loadParticipationHistory());
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      messenger.showSnackBar(
        const SnackBar(content: Text('Impact evidence sent to the sponsor.')),
      );
    } catch (error) {
      if (mounted) _showError(context, error, 'Could not submit evidence.');
    } finally {
      if (mounted) setState(() => _phase = _SubmitPhase.idle);
    }
  }

  @override
  Widget build(BuildContext context) {
    final aiOff = widget.viewModel.aiAvailable == false;
    final proposal = _proposal;
    final showSummary = _manual || proposal != null;
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
          SectionHeading(
            eyebrow: aiOff ? 'Evidence' : 'AI evidence assistant',
            title: 'Show what changed',
            description: aiOff
                ? 'Capture one photo, describe the result, then confirm your summary.'
                : 'Capture one photo, describe the result, then confirm the structured summary.',
          ),
          if (_deadlinePassed) ...[
            const SizedBox(height: 12),
            const Text(
              'The evidence window for this campaign has closed.',
              style: TextStyle(color: FieldnoteColors.danger),
            ),
          ],
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _working ? null : () => _pick(ImageSource.camera),
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
            onPressed: _working ? null : () => _pick(ImageSource.gallery),
            icon: const Icon(Icons.photo_library_outlined),
            label: const Text('Choose from gallery'),
          ),
          const SizedBox(height: 16),
          FieldnoteTextField(
            controller: _note,
            minLines: 3,
            maxLines: 6,
            maxLength: maxSummaryLength,
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
          if (!aiOff)
            FilledButton.icon(
              onPressed: _working ? null : _analyze,
              icon: _analyzing
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(_analyzing ? 'Analyzing…' : 'AI analyze field note'),
            ),
          if (!showSummary) ...[
            const SizedBox(height: 6),
            TextButton(
              key: const Key('write-summary-myself'),
              onPressed: _working ? null : _writeMyself,
              child: const Text('Write the summary myself'),
            ),
          ],
          if (showSummary) ...[
            const SizedBox(height: 18),
            SurfaceCard(
              color: _manual
                  ? FieldnoteColors.mist
                  : FieldnoteColors.acid.withValues(alpha: .35),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StatusPill(
                    label: _manual
                        ? 'Your summary · not AI generated'
                        : 'AI draft · volunteer confirms',
                    color: FieldnoteColors.clay,
                    icon: _manual ? Icons.edit_note : Icons.auto_awesome,
                  ),
                  if (_manual) ...[
                    const SizedBox(height: 8),
                    Text(
                      aiOff ||
                              (proposal != null && isFallbackProposal(proposal))
                          ? 'AI analysis is unavailable. Describe the completed work in your own words.'
                          : 'Describe the completed work in your own words.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  const SizedBox(height: 12),
                  FieldnoteTextField(
                    key: const Key('confirmed-summary-field'),
                    controller: _summary,
                    minLines: 2,
                    maxLines: 6,
                    maxLength: maxSummaryLength,
                    decoration: InputDecoration(
                      labelText: 'Confirmed impact summary',
                      helperText:
                          'At least $minSummaryLength characters. The sponsor sees this.',
                    ),
                  ),
                  if (!_manual && proposal != null) ...[
                    const SizedBox(height: 10),
                    ...proposal.structuredResults.map(
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
                  ],
                  if (_accuracyProblem != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      _accuracyProblem!,
                      style: const TextStyle(color: FieldnoteColors.clay),
                    ),
                  ],
                  if (_phase != _SubmitPhase.idle) ...[
                    const SizedBox(height: 12),
                    const LinearProgressIndicator(),
                    const SizedBox(height: 6),
                    Text(
                      _phase == _SubmitPhase.locating
                          ? 'Checking your GPS position…'
                          : 'Uploading photo and submitting evidence…',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      key: const Key('submit-evidence-button'),
                      onPressed: _working || _deadlinePassed ? null : _submit,
                      icon: const Icon(Icons.verified_outlined),
                      label: Text(
                        _phase == _SubmitPhase.uploading
                            ? 'Submitting…'
                            : 'Confirm and submit evidence',
                      ),
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
  int _startMinutes = 7 * 60;
  int _endMinutes = 13 * 60;
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
      _radius = value.maximumTravelKm.clamp(1, 100).toDouble();
      _startMinutes = value.startMinutes;
      _endMinutes = value.endMinutes;
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
          isLive: false,
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
          isLive: false,
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
        isLive: false,
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

  Future<void> _pickTime({required bool start}) async {
    final current = start ? _startMinutes : _endMinutes;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: (current ~/ 60).clamp(0, 23),
        minute: current >= 1440 ? 59 : current % 60,
      ),
      helpText: start ? 'Available from' : 'Available until',
    );
    if (picked == null || !mounted) return;
    setState(() {
      final minutes = picked.hour * 60 + picked.minute;
      if (start) {
        _startMinutes = minutes;
      } else {
        // 00:00 as an end time means the end of the day.
        _endMinutes = minutes == 0 ? 1440 : minutes;
      }
    });
  }

  Future<void> _save() async {
    final windowProblem = availabilityWindowProblem(_startMinutes, _endMinutes);
    if (windowProblem != null) {
      _showMessage(context, windowProblem);
      return;
    }
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
        startMinutes: _startMinutes,
        endMinutes: _endMinutes,
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
                subtitle: const Text('Turns off automatically at midnight.'),
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
                'Time window',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 9),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  OutlinedButton.icon(
                    key: const Key('availability-start-time'),
                    onPressed: () => _pickTime(start: true),
                    icon: const Icon(Icons.schedule),
                    label: Text('From ${formatMinutes(_startMinutes)}'),
                  ),
                  OutlinedButton.icon(
                    key: const Key('availability-end-time'),
                    onPressed: () => _pickTime(start: false),
                    icon: const Icon(Icons.schedule_outlined),
                    label: Text('Until ${formatMinutes(_endMinutes)}'),
                  ),
                ],
              ),
              if (availabilityWindowProblem(_startMinutes, _endMinutes)
                  case final problem?) ...[
                const SizedBox(height: 6),
                Text(
                  problem,
                  style: const TextStyle(color: FieldnoteColors.danger),
                ),
              ],
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
                min: 1,
                max: 100,
                divisions: 99,
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
                      : _location!.isLive && !_pinnedByHand
                      ? 'Live GPS area selected'
                      : 'Use my current GPS area instead',
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
  final settings = _settingsActionFor(error);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(_errorText(error, fallback)),
      action: settings == null
          ? null
          : SnackBarAction(label: settings.label, onPressed: settings.open),
    ),
  );
}

void _showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));
}

/// "Open settings" for location problems the user must fix in Settings
/// (V-6): app permissions when blocked, Location when switched off.
({String label, VoidCallback open})? _settingsActionFor(Object error) {
  if (error is! LocationAccessException) return null;
  final service = DeviceLocationService();
  return switch (error.issue) {
    LocationAccessIssue.serviceDisabled => (
      label: 'Open settings',
      open: () => unawaited(_openSafely(service.openLocationSettings)),
    ),
    LocationAccessIssue.permissionDeniedForever => (
      label: 'Open settings',
      open: () => unawaited(_openSafely(service.openAppSettings)),
    ),
    _ => null,
  };
}

Future<void> _openSafely(Future<bool> Function() open) async {
  try {
    await open();
  } on Object {
    // Not every platform (web) can open system settings.
  }
}

Widget? _settingsButton(Object error) {
  final settings = _settingsActionFor(error);
  if (settings == null) return null;
  return TextButton.icon(
    onPressed: settings.open,
    icon: const Icon(Icons.settings_outlined),
    label: Text(
      error is LocationAccessException &&
              error.issue == LocationAccessIssue.serviceDisabled
          ? 'Open location settings'
          : 'Open app settings',
    ),
  );
}

String _errorText(Object error, String fallback) =>
    userMessageFor(error, fallback: fallback);
