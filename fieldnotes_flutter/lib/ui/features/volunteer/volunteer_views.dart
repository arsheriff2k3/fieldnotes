import 'dart:async';
import 'dart:typed_data';

import 'package:fieldnotes_client/fieldnotes_client.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../../data/services/device_location_service.dart';
import '../../../l10n/l10n.dart';
import '../../core/in_app_maps.dart';
import '../../core/fieldnote_map.dart';
import '../../core/error_messages.dart';
import '../../core/fieldnote_theme.dart';
import '../../core/widgets.dart';
import '../shell/fieldnote_view_model.dart';
import '../discussion/campaign_discussion_view.dart';
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
  /// [short] is the label for the narrow map sheet button.
  ({String label, String short, VoidCallback? onAction}) _joinAction(
    BuildContext context,
    Campaign campaign,
  ) {
    final l10n = context.l10n;
    final id = campaign.id!;
    if (_holdsPlace(id)) {
      return (
        label: l10n.volunteerViewMyWork,
        short: l10n.navMyWork,
        onAction: () => viewModel.selectSection(1),
      );
    }
    if (_isFull(id)) {
      return (
        label: l10n.volunteerFull,
        short: l10n.volunteerFull,
        onAction: null,
      );
    }
    if (_joining.contains(id)) {
      return (
        label: l10n.volunteerJoining,
        short: l10n.volunteerJoining,
        onAction: null,
      );
    }
    return (
      label: l10n.volunteerJoinCampaign,
      short: l10n.volunteerJoin,
      onAction: () => _join(context, campaign),
    );
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
    final l10n = context.l10n;
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
              eyebrow: l10n.volunteerMatchesEyebrow,
              title: l10n.volunteerMatchesTitle,
              description: l10n.volunteerMatchesDescription,
            ),
          ),
          FieldnoteSectionTabs(
            compact: true,
            tabs: [
              FieldnoteSectionTab(
                l10n.volunteerTabList,
                Icons.view_agenda_outlined,
              ),
              FieldnoteSectionTab(l10n.volunteerTabMap, Icons.map_outlined),
              FieldnoteSectionTab(
                l10n.volunteerTabInvites,
                Icons.mark_email_unread_outlined,
              ),
            ],
          ),
          const SizedBox(height: FieldnoteSpacing.xxs),
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
            title: context.l10n.volunteerNoMatchesTitle,
            message: availability?.isAvailable == true
                ? context.l10n.volunteerNoMatchesWiden
                : context.l10n.volunteerNoMatchesTurnOn,
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
                          context.l10n.volunteerEveryPlaceTaken,
                        if (viewModel.invitedTo(match.campaign.id!))
                          context.l10n.volunteerInvitedReason,
                        ...match.reasons,
                        distanceLabel(
                          match,
                          l10n: context.l10n,
                          locale: context.localeTag,
                        ),
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
          EmptyPanel(
            icon: Icons.map_outlined,
            title: context.l10n.volunteerMapUnavailableTitle,
            message: context.l10n.volunteerMapUnavailableMessage,
          )
        else if (matches.isEmpty)
          EmptyPanel(
            icon: Icons.travel_explore,
            title: context.l10n.volunteerMapEmptyTitle,
            message: context.l10n.volunteerMapEmptyMessage,
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
                    ? context.l10n.volunteerInvitations
                    : context.l10n.volunteerInvitationsCount(campaigns.length),
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            IconButton.filledTonal(
              tooltip: context.l10n.volunteerCheckInvitations,
              onPressed: viewModel.refresh,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        const SizedBox(height: FieldnoteSpacing.sm),
        if (campaigns.isEmpty)
          SurfaceCard(
            child: Row(
              children: [
                const Icon(Icons.mark_email_unread_outlined, size: 28),
                const SizedBox(width: FieldnoteSpacing.md),
                Expanded(
                  child: Text(
                    context.l10n.volunteerNoInvitations,
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
                      reasons: [context.l10n.volunteerInvitedReason],
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
    final l10n = context.l10n;
    final reasons = [
      if (viewModel.invitedTo(match.campaign.id!)) l10n.volunteerInvitedReason,
      ...match.reasons,
    ];
    // Server reasons are English; one mentioning "by road" already carries
    // the travel time.
    if (!match.reasons.any((reason) => reason.contains('by road'))) {
      reasons.add(
        distanceLabel(match, l10n: l10n, locale: context.localeTag),
      );
    }
    showFieldnoteBottomSheet<void>(
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
                padding: FieldnoteSpacing.sheetPadding(
                  context,
                  top: FieldnoteSpacing.xs,
                  bottom: FieldnoteSpacing.sm,
                ),
                children: [
                  Text(
                    match.campaign.name,
                    style: Theme.of(sheetContext).textTheme.titleLarge,
                  ),
                  const SizedBox(height: FieldnoteSpacing.xs),
                  Text(match.campaign.locationName),
                  const SizedBox(height: FieldnoteSpacing.md),
                  for (final reason in reasons)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 7),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.check_circle_outline, size: 17),
                          const SizedBox(width: FieldnoteSpacing.xs),
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
                padding: FieldnoteSpacing.sheetPadding(
                  context,
                  bottom: FieldnoteSpacing.md,
                ),
                child: FieldnoteActionRow(
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
                        label: Text(l10n.volunteerViewRoute),
                      ),
                    ),
                    const SizedBox(width: FieldnoteSpacing.sm),
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
                            label: Text(action.short),
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
    final l10n = context.l10n;
    try {
      await viewModel.join(campaign);
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.volunteerJoined(campaign.name))),
      );
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            UserError.from(
              error,
            ).messageIn(l10n, fallback: l10n.volunteerJoinCampaignFailed),
          ),
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
String distanceLabel(
  CampaignMatch match, {
  AppLocalizations? l10n,
  String? locale,
}) {
  final strings = l10n ?? lookupAppLocalizations(const Locale('en'));
  final km = NumberFormat.decimalPatternDigits(
    locale: locale ?? 'en',
    decimalDigits: 1,
  );
  final minutes = match.travelMinutes;
  if (minutes == null) {
    return strings.volunteerDistanceStraight(km.format(match.distanceKm));
  }
  final byRoad = match.travelDistanceKm ?? match.distanceKm;
  return strings.volunteerDistanceByRoad(minutes, km.format(byRoad));
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
    final l10n = context.l10n;
    final locale = context.localeTag;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldnoteMap(
          target: points.first,
          height: 330,
          semanticLabel: l10n.volunteerMatchMapSemantics,
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
                  title: l10n.volunteerYourArea,
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
                  title: l10n.volunteerMatchPinTitle(
                    match.campaign.name,
                    NumberFormat.percentPattern(
                      locale,
                    ).format(match.score / 100),
                  ),
                  snippet: distanceLabel(match, l10n: l10n, locale: locale),
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
        const SizedBox(height: FieldnoteSpacing.sm),
        MapLegend(
          entries: [
            (color: FieldnoteColors.forest, label: l10n.volunteerLegendStrong),
            (
              color: const Color(0xFFE0B341),
              label: l10n.volunteerLegendModerate,
            ),
            (color: FieldnoteColors.clay, label: l10n.volunteerLegendWeaker),
          ],
        ),
        const SizedBox(height: FieldnoteSpacing.xs),
        Text(
          l10n.volunteerMatchMapHint,
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
      final display = participationDisplay(
        participation,
        campaign,
        l10n: context.l10n,
      );
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
    final l10n = context.l10n;
    return RefreshIndicator(
      onRefresh: () async {
        await viewModel.refresh();
        await viewModel.loadParticipationHistory();
      },
      child: FieldnotePageList(
        children: [
          SectionHeading(
            eyebrow: l10n.volunteerWorkEyebrow,
            title: l10n.navMyWork,
            description: l10n.volunteerWorkDescription,
            trailing: OutlinedButton.icon(
              key: const Key('open-volunteer-history'),
              onPressed: () => _openHistory(context),
              icon: const Icon(Icons.history),
              label: Text(l10n.volunteerOpenHistory),
            ),
          ),
          const SizedBox(height: FieldnoteSpacing.md),
          if (active.isEmpty)
            SurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.hiking_outlined, size: 30),
                  const SizedBox(height: FieldnoteSpacing.sm),
                  Text(
                    past.isEmpty
                        ? l10n.volunteerNoJoinedCampaigns
                        : l10n.volunteerNoUpcomingCampaigns,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: FieldnoteSpacing.xs),
                  Text(l10n.volunteerFindNearby),
                  const SizedBox(height: FieldnoteSpacing.md),
                  FilledButton.icon(
                    onPressed: () => viewModel.selectSection(0),
                    icon: const Icon(Icons.travel_explore),
                    label: Text(l10n.volunteerBrowseCampaigns),
                  ),
                ],
              ),
            )
          else
            ...active,
          if (past.isNotEmpty) ...[
            const SizedBox(height: FieldnoteSpacing.sm),
            Text(
              l10n.volunteerPastAndClosed,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: FieldnoteSpacing.sm),
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
          const SizedBox(height: FieldnoteSpacing.sm),
          Text(
            context.l10n.volunteerCampaignNumber(participation.campaignId),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: FieldnoteSpacing.xxs),
          Text(
            context.l10n.volunteerJoinedOnRefresh(
              DateFormat.MMMEd(
                dateLocale(context.localeTag),
              ).format(participation.joinedAt.toLocal()),
            ),
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
              const SizedBox(width: FieldnoteSpacing.xs),
              const Spacer(),
              Text(
                DateFormat.MMMEd(
                  dateLocale(context.localeTag),
                ).format(campaign.startsAt.toLocal()),
              ),
            ],
          ),
          const SizedBox(height: FieldnoteSpacing.sm),
          Text(campaign.name, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: FieldnoteSpacing.xxs),
          Text(
            campaign.locationName,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (display.detail != null) ...[
            const SizedBox(height: FieldnoteSpacing.xs),
            Text(display.detail!),
          ],
          if (evidence != null) ...[
            const SizedBox(height: FieldnoteSpacing.xs),
            Text(
              reviewStateLabel(evidence!.reviewState, l10n: context.l10n),
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ],
          if (participation.status == ParticipationStatus.completed) ...[
            const SizedBox(height: FieldnoteSpacing.sm),
            TextButton.icon(
              onPressed: onOpenHistory,
              icon: const Icon(Icons.photo_outlined),
              label: Text(context.l10n.volunteerViewMyEvidence),
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
            SnackBar(content: Text(context.l10n.volunteerCreatorNoPhone)),
          );
        }
        if (showResult && phone != null) await _dialPhone(phone);
      }
    } on Object {
      if (mounted) {
        setState(() => _contactLoadFailed = true);
        if (showResult) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.volunteerContactLoadFailed)),
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
        SnackBar(content: Text(context.l10n.volunteerDialerFailed)),
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
          _showMessage(
            context,
            accuracyMessage(location.accuracyMeters, l10n: context.l10n),
          );
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
        SnackBar(content: Text(context.l10n.volunteerCheckInConfirmed)),
      );
    } catch (error) {
      if (!mounted) return;
      _showError(context, error, context.l10n.volunteerCheckInFailed);
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _leave() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => fieldnoteDialog(
        title: Text(dialogContext.l10n.volunteerLeaveTitle),
        content: Text(
          dialogContext.l10n.volunteerLeaveBody(widget.campaign.name),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(dialogContext.l10n.volunteerStay),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              // A solid fill with white text in both brightnesses.
              backgroundColor: FieldnoteColors.danger,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(dialogContext.l10n.volunteerLeaveCampaign),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _leaving = true);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    try {
      await _stopTracking();
      await widget.viewModel.leaveCampaign(widget.participation);
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.volunteerLeft(widget.campaign.name))),
      );
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            UserError.from(
              error,
            ).messageIn(l10n, fallback: l10n.volunteerLeaveFailed),
          ),
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
        _showError(context, error, context.l10n.volunteerReconfirmFailed);
      }
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now().toUtc();
    final l10n = context.l10n;
    final locale = context.localeTag;
    final display = participationDisplay(
      widget.participation,
      widget.campaign,
      now: now,
      l10n: l10n,
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
          Wrap(
            spacing: FieldnoteSpacing.sm,
            runSpacing: FieldnoteSpacing.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              StatusPill(
                label: display.label,
                color: display.color,
                icon: display.icon,
              ),
              Text(
                DateFormat.MMMEd(
                  dateLocale(locale),
                ).format(widget.campaign.startsAt.toLocal()),
              ),
            ],
          ),
          const SizedBox(height: FieldnoteSpacing.sm),
          Text(
            widget.campaign.name,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: FieldnoteSpacing.xxs),
          Text(
            widget.campaign.locationName,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: FieldnoteSpacing.sm),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              StatusPill(
                label: switch (widget.campaign.readinessState) {
                  'confirmed' => l10n.volunteerReadinessConfirmed,
                  'postponed' => l10n.volunteerReadinessPostponed,
                  'fundingShort' ||
                  'volunteersShort' ||
                  'bothShort' => l10n.volunteerReadinessAwaitingSponsor,
                  _ => l10n.volunteerReadinessTentative,
                },
                color: eventConfirmed
                    ? FieldnoteColors.forest
                    : FieldnoteColors.clay,
                icon: eventConfirmed ? Icons.verified_outlined : Icons.schedule,
              ),
              StatusPill(
                label: l10n.volunteerTimeRange(
                  DateFormat.Hm(
                    dateLocale(locale),
                  ).format(widget.campaign.startsAt.toLocal()),
                  DateFormat.Hm(
                    dateLocale(locale),
                  ).format(campaignEnd(widget.campaign).toLocal()),
                ),
                color: FieldnoteColors.moss,
                icon: Icons.access_time,
              ),
            ],
          ),
          if (display.detail != null) ...[
            const SizedBox(height: FieldnoteSpacing.xs),
            Text(display.detail!),
          ],
          if (const {
            ParticipationStatus.joined,
            ParticipationStatus.checkedIn,
            ParticipationStatus.completed,
            ParticipationStatus.incomplete,
          }.contains(status))
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push<void>(
                MaterialPageRoute(
                  builder: (_) => CampaignDiscussionView(
                    campaign: widget.campaign,
                    repository: widget.viewModel.repository,
                    currentUserId: widget.viewModel.profile?.authUserId,
                  ),
                ),
              ),
              icon: const Icon(Icons.forum_outlined),
              label: Text(context.l10n.campaignDiscussionTitle),
            ),
          FutureBuilder<List<CampaignPost>>(
            future: _posts,
            builder: (context, snapshot) {
              final latest = snapshot.data?.firstOrNull;
              if (latest == null) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(context.l10n.volunteerOrganizerUpdate(latest.body)),
              );
            },
          ),
          if (needsReconfirmation && !checkedIn) ...[
            const SizedBox(height: FieldnoteSpacing.xs),
            Text(l10n.volunteerReconfirmNeeded),
            const SizedBox(height: FieldnoteSpacing.xs),
            OutlinedButton.icon(
              onPressed: busy ? null : _reconfirm,
              icon: const Icon(Icons.how_to_reg_outlined),
              label: Text(l10n.volunteerReconfirm),
            ),
          ],
          const SizedBox(height: FieldnoteSpacing.sm),
          OutlinedButton.icon(
            onPressed: _loadingContact
                ? null
                : _contactPhone == null
                ? () => _loadContact(showResult: true)
                : _callCreator,
            icon: const Icon(Icons.call_outlined),
            label: Text(
              _loadingContact
                  ? l10n.volunteerContactLoading
                  : _contactPhone == null
                  ? l10n.volunteerContactRefresh
                  : l10n.volunteerContactCall,
            ),
          ),
          if (!_loadingContact && _contactPhone == null) ...[
            const SizedBox(height: FieldnoteSpacing.xs),
            Text(
              _contactLoadFailed
                  ? l10n.volunteerContactRetry
                  : l10n.volunteerContactMissing,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          const Divider(height: 28),
          Text(
            l10n.volunteerFieldChecklist,
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
                      Icon(
                        Icons.check_circle_outline,
                        size: 18,
                        color: context.fieldnoteColors.moss,
                      ),
                      const SizedBox(width: FieldnoteSpacing.xs),
                      Expanded(child: Text(item.trim())),
                    ],
                  ),
                ),
              ),
          const SizedBox(height: FieldnoteSpacing.md),
          _locationPanel(context),
          const SizedBox(height: FieldnoteSpacing.md),
          if (display.canComplete)
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: busy
                    ? null
                    : () => showFieldnoteBottomSheet<void>(
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
                label: Text(l10n.volunteerSubmitEvidence),
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
                      ? l10n.volunteerAwaitConfirmation
                      : needsReconfirmation
                      ? l10n.volunteerReconfirmFirst
                      : window == CheckInWindow.notYetOpen
                      ? checkInOpensLabel(
                          widget.campaign,
                          now,
                          l10n: l10n,
                          locale: locale,
                        )
                      : window == CheckInWindow.closed
                      ? l10n.volunteerCheckInClosed
                      : l10n.volunteerCheckInOnSite,
                ),
              ),
            ),
            if (eventConfirmed && window == CheckInWindow.notYetOpen) ...[
              const SizedBox(height: FieldnoteSpacing.xs),
              Text(
                l10n.volunteerCheckInWindowHint,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
          if (display.canLeave) ...[
            const SizedBox(height: FieldnoteSpacing.xs),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                key: const Key('leave-campaign-button'),
                style: TextButton.styleFrom(
                  foregroundColor: context.fieldnoteColors.danger,
                ),
                onPressed: busy ? null : _leave,
                icon: _leaving
                    ? const SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.logout),
                label: Text(
                  _leaving
                      ? l10n.volunteerLeaving
                      : l10n.volunteerLeaveCampaign,
                ),
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
    final c = context.fieldnoteColors;
    final l10n = context.l10n;
    final number = NumberFormat.decimalPattern(context.localeTag);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.mist,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: inside
              ? c.forest.withValues(alpha: .3)
              : c.ink.withValues(alpha: .08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_searching, size: 20),
              const SizedBox(width: FieldnoteSpacing.xs),
              Expanded(
                child: Text(
                  l10n.volunteerLiveLocationCheck,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              StatusPill(
                label: _tracking
                    ? l10n.volunteerGpsStreaming
                    : location == null
                    ? l10n.volunteerGpsNotStarted
                    : l10n.volunteerGpsPaused,
                color: _tracking
                    ? FieldnoteColors.forest
                    : FieldnoteColors.clay,
                icon: _tracking ? Icons.sensors : Icons.gps_not_fixed,
              ),
            ],
          ),
          const SizedBox(height: FieldnoteSpacing.sm),
          _approachMap(context, location, distance, inside),
          const SizedBox(height: FieldnoteSpacing.sm),
          if (location == null && _locationError == null)
            Text(l10n.volunteerTrackingIntro),
          if (locationError != null) ...[
            Text(
              _errorText(
                context,
                locationError,
                l10n.volunteerLiveLocationUnavailable,
              ),
              style: TextStyle(color: c.clay),
            ),
            ?_settingsButton(context, locationError),
          ],
          if (accuracyTooLow) ...[
            Text(
              accuracyMessage(location.accuracyMeters, l10n: l10n),
              style: TextStyle(color: c.clay),
            ),
            const SizedBox(height: FieldnoteSpacing.xs),
          ],
          if (location != null) ...[
            SelectableText(
              '${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: FieldnoteSpacing.xs),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _LocationFact(
                  icon: Icons.gps_fixed,
                  label: l10n.volunteerAccuracyFact(
                    number.format(location.accuracyMeters.round()),
                  ),
                ),
                _LocationFact(
                  icon: location.isMocked
                      ? Icons.gpp_bad_outlined
                      : Icons.verified_user_outlined,
                  label: location.isMocked
                      ? l10n.volunteerMockDetected
                      : l10n.volunteerNoMock,
                ),
                _LocationFact(
                  icon: inside
                      ? Icons.check_circle
                      : accuracyTooLow
                      ? Icons.gps_not_fixed
                      : Icons.cancel_outlined,
                  label: distance == null
                      ? l10n.volunteerCalculatingDistance
                      : accuracyTooLow
                      ? l10n.volunteerDistanceAccuracyLow(
                          number.format(distance.round()),
                        )
                      : inside
                      ? l10n.volunteerDistanceInside(
                          number.format(distance.round()),
                        )
                      : l10n.volunteerDistanceOutside(
                          number.format(distance.round()),
                        ),
                ),
                _LocationFact(
                  icon: Icons.schedule,
                  label: l10n.volunteerFixAge(
                    DateTime.now()
                        .toUtc()
                        .difference(location.capturedAt)
                        .inSeconds
                        .abs(),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: FieldnoteSpacing.sm),
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
                  _tracking
                      ? l10n.volunteerStopTracking
                      : l10n.volunteerEnableTracking,
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
                      ? l10n.volunteerRouteUnavailable
                      : l10n.volunteerViewRoute,
                ),
              ),
            ],
          ),
          const SizedBox(height: FieldnoteSpacing.xxs),
          Text(
            l10n.volunteerTrackingPrivacy,
            style: const TextStyle(fontSize: 12),
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
    final l10n = context.l10n;
    final number = NumberFormat.decimalPattern(context.localeTag);
    final geofence = number.format(widget.campaign.geofenceMeters.round());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldnoteMap(
          target: campaignPoint,
          zoom: zoomForRadius(widget.campaign.geofenceMeters),
          height: 210,
          semanticLabel: l10n.volunteerApproachMapSemantics,
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
                  title: l10n.volunteerYouAreHere,
                  snippet: distance == null
                      ? null
                      : l10n.volunteerMetersFromPin(
                          number.format(distance.round()),
                        ),
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
                ? l10n.volunteerApproachFallbackNoFix
                : l10n.volunteerApproachFallback(
                    number.format(distance.round()),
                    geofence,
                  ),
          ),
        ),
        if (mapsAvailable) ...[
          const SizedBox(height: FieldnoteSpacing.xs),
          MapLegend(
            entries: [
              (
                color: FieldnoteColors.forest,
                label: l10n.volunteerLegendCampaignPin,
              ),
              (
                color: inside ? FieldnoteColors.forest : FieldnoteColors.clay,
                label: l10n.volunteerLegendGeofence(geofence),
              ),
              (
                color: FieldnoteColors.moss,
                label: l10n.volunteerLegendAccuracy,
              ),
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
        color: context.fieldnoteColors.raised,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15),
          const SizedBox(width: FieldnoteSpacing.xs),
          Flexible(
            child: Text(label, style: Theme.of(context).textTheme.labelSmall),
          ),
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
              ? context.l10n.volunteerCameraUnavailable
              : context.l10n.volunteerGalleryFailed,
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
                label: context.l10n.volunteerOpenSettings,
                onPressed: () =>
                    unawaited(_openSafely(_location.openAppSettings)),
              )
            : null,
      ),
    );
  }

  String get _micPermissionMessage => context.l10n.volunteerMicPermission;

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
                  ? context.l10n.volunteerNoSpeech
                  : context.l10n.volunteerDictationStopped,
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
        if (!mounted) return;
        _speechError(
          permitted
              ? context.l10n.volunteerSpeechUnavailable
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
      if (mounted) _speechError(context.l10n.volunteerDictationFailed);
    }
  }

  bool _requirePhoto() {
    if (_photo != null) return true;
    _showMessage(context, context.l10n.volunteerPhotoFirst);
    return false;
  }

  Future<void> _analyze() async {
    if (!_requirePhoto()) return;
    if (_note.text.trim().length < minSummaryLength) {
      _showMessage(
        context,
        context.l10n.volunteerNoteTooShort(minSummaryLength),
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
          context.l10n.volunteerAnalyzeFailed,
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
    if (!mounted) return null;
    final problem = locationProblem(
      gps,
      DateTime.now().toUtc(),
      l10n: context.l10n,
    );
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
        context.l10n.volunteerSummaryLength(minSummaryLength, maxSummaryLength),
      );
      return;
    }
    if (_note.text.trim().length > maxSummaryLength) {
      _showMessage(
        context,
        context.l10n.volunteerNoteTooLong(maxSummaryLength),
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
      final sent = context.l10n.volunteerEvidenceSent;
      Navigator.pop(context);
      messenger.showSnackBar(SnackBar(content: Text(sent)));
    } catch (error) {
      if (mounted) {
        _showError(context, error, context.l10n.volunteerSubmitFailed);
      }
    } finally {
      if (mounted) setState(() => _phase = _SubmitPhase.idle);
    }
  }

  @override
  Widget build(BuildContext context) {
    final aiOff = widget.viewModel.aiAvailable == false;
    final proposal = _proposal;
    final showSummary = _manual || proposal != null;
    final l10n = context.l10n;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: .9,
      minChildSize: .65,
      maxChildSize: .96,
      builder: (context, scrollController) => ListView(
        controller: scrollController,
        padding: FieldnoteSpacing.sheetPadding(context),
        children: [
          SectionHeading(
            eyebrow: aiOff
                ? l10n.volunteerEvidenceEyebrow
                : l10n.volunteerEvidenceEyebrowAi,
            title: l10n.volunteerEvidenceTitle,
            description: aiOff
                ? l10n.volunteerEvidenceDescription
                : l10n.volunteerEvidenceDescriptionAi,
          ),
          if (_deadlinePassed) ...[
            const SizedBox(height: FieldnoteSpacing.sm),
            Text(
              l10n.volunteerEvidenceWindowClosed,
              style: TextStyle(color: context.fieldnoteColors.danger),
            ),
          ],
          const SizedBox(height: FieldnoteSpacing.lg),
          GestureDetector(
            onTap: _working ? null : () => _pick(ImageSource.camera),
            child: Container(
              height: 220,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: context.fieldnoteColors.mist,
                borderRadius: BorderRadius.circular(20),
              ),
              child: _photo == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add_a_photo_outlined, size: 42),
                        const SizedBox(height: FieldnoteSpacing.xs),
                        Text(l10n.volunteerTakePhoto),
                      ],
                    )
                  : Image.memory(
                      _photo!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
            ),
          ),
          const SizedBox(height: FieldnoteSpacing.sm),
          OutlinedButton.icon(
            onPressed: _working ? null : () => _pick(ImageSource.gallery),
            icon: const Icon(Icons.photo_library_outlined),
            label: Text(l10n.volunteerChooseGallery),
          ),
          const SizedBox(height: FieldnoteSpacing.md),
          FieldnoteTextField(
            controller: _note,
            minLines: 3,
            maxLines: 6,
            maxLength: maxSummaryLength,
            decoration: InputDecoration(
              labelText: l10n.volunteerNoteLabel,
              hintText: l10n.volunteerNoteHint,
              suffixIcon: IconButton(
                tooltip: _listening
                    ? l10n.volunteerStopListening
                    : l10n.volunteerDictateNote,
                onPressed: _toggleSpeech,
                icon: Icon(_listening ? Icons.mic : Icons.mic_none),
                color: _listening ? context.fieldnoteColors.clay : null,
              ),
            ),
          ),
          const SizedBox(height: FieldnoteSpacing.sm),
          if (!aiOff)
            FilledButton.icon(
              onPressed: _working ? null : _analyze,
              icon: _analyzing
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(
                _analyzing ? l10n.volunteerAnalyzing : l10n.volunteerAnalyze,
              ),
            ),
          if (!showSummary) ...[
            const SizedBox(height: FieldnoteSpacing.xs),
            TextButton(
              key: const Key('write-summary-myself'),
              onPressed: _working ? null : _writeMyself,
              child: Text(l10n.volunteerWriteMyself),
            ),
          ],
          if (showSummary) ...[
            const SizedBox(height: FieldnoteSpacing.md),
            SurfaceCard(
              color: _manual
                  ? context.fieldnoteColors.mist
                  : context.fieldnoteColors.acid.withValues(
                      alpha: context.fieldnoteColors.isDark ? .12 : .35,
                    ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StatusPill(
                    label: _manual
                        ? l10n.volunteerSummaryManualPill
                        : l10n.volunteerSummaryAiPill,
                    color: FieldnoteColors.clay,
                    icon: _manual ? Icons.edit_note : Icons.auto_awesome,
                  ),
                  if (_manual) ...[
                    const SizedBox(height: FieldnoteSpacing.xs),
                    Text(
                      aiOff ||
                              (proposal != null && isFallbackProposal(proposal))
                          ? l10n.volunteerAiUnavailableDescribe
                          : l10n.volunteerDescribeOwnWords,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  const SizedBox(height: FieldnoteSpacing.sm),
                  FieldnoteTextField(
                    key: const Key('confirmed-summary-field'),
                    controller: _summary,
                    minLines: 2,
                    maxLines: 6,
                    maxLength: maxSummaryLength,
                    decoration: InputDecoration(
                      labelText: l10n.volunteerConfirmedSummary,
                      helperText: l10n.volunteerSummaryHelper(minSummaryLength),
                    ),
                  ),
                  if (!_manual && proposal != null) ...[
                    const SizedBox(height: FieldnoteSpacing.sm),
                    ...proposal.structuredResults.map(
                      (result) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            const Icon(Icons.insights, size: 17),
                            const SizedBox(width: FieldnoteSpacing.xs),
                            Expanded(child: Text(result)),
                          ],
                        ),
                      ),
                    ),
                  ],
                  if (_accuracyProblem != null) ...[
                    const SizedBox(height: FieldnoteSpacing.sm),
                    Text(
                      _accuracyProblem!,
                      style: TextStyle(color: context.fieldnoteColors.clay),
                    ),
                  ],
                  if (_phase != _SubmitPhase.idle) ...[
                    const SizedBox(height: FieldnoteSpacing.sm),
                    const LinearProgressIndicator(),
                    const SizedBox(height: FieldnoteSpacing.xs),
                    Text(
                      _phase == _SubmitPhase.locating
                          ? l10n.volunteerCheckingGps
                          : l10n.volunteerUploading,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  const SizedBox(height: FieldnoteSpacing.sm),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      key: const Key('submit-evidence-button'),
                      onPressed: _working || _deadlinePassed ? null : _submit,
                      icon: const Icon(Icons.verified_outlined),
                      label: Text(
                        _phase == _SubmitPhase.uploading
                            ? l10n.volunteerSubmitting
                            : l10n.volunteerConfirmSubmit,
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
        _searchMessage = results.isEmpty
            ? context.l10n.volunteerNoPlacesFound
            : null;
      });
    } on Object {
      if (mounted && request == _searchRequest) {
        setState(
          () => _searchMessage = context.l10n.volunteerPlaceSearchUnavailable,
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
          () => _searchMessage = context.l10n.volunteerPlaceSelectFailed,
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
    // Stored as the location label, so this deliberately stays English.
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
      helpText: start
          ? context.l10n.volunteerAvailableFrom
          : context.l10n.volunteerAvailableUntil,
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
    final windowProblem = availabilityWindowProblem(
      _startMinutes,
      _endMinutes,
      l10n: context.l10n,
    );
    if (windowProblem != null) {
      _showMessage(context, windowProblem);
      return;
    }
    if (_searchAvailable &&
        _placeSearch.text.trim().isNotEmpty &&
        _placeSearch.text.trim() != _savedLabel) {
      setState(
        () => _searchMessage = context.l10n.volunteerSelectSearchResult,
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
          SnackBar(content: Text(context.l10n.volunteerAvailabilitySaved)),
        );
      }
    } catch (error) {
      if (mounted) {
        _showError(context, error, context.l10n.volunteerAvailabilityFailed);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = context.localeTag;
    // 1 January 2024 was a Monday, so day `i` of that month is weekday `i`.
    final dayFormat = DateFormat.E(dateLocale(locale));
    final names = {
      for (var day = 1; day <= 7; day++)
        day: dayFormat.format(DateTime(2024, 1, day)),
    };
    final number = NumberFormat.decimalPattern(locale);
    final radius = number.format(_radius.round());
    return FieldnotePageList(
      children: [
        SectionHeading(
          eyebrow: l10n.volunteerAvailabilityEyebrow,
          title: l10n.navAvailability,
          description: l10n.volunteerAvailabilityDescription,
        ),
        const SizedBox(height: FieldnoteSpacing.md),
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: _available,
                title: Text(l10n.volunteerAvailableToggle),
                subtitle: Text(l10n.volunteerAvailableToggleHint),
                onChanged: (value) => setState(() => _available = value),
              ),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: _today,
                title: Text(l10n.volunteerTodayToggle),
                subtitle: Text(l10n.volunteerTodayToggleHint),
                onChanged: (value) => setState(() => _today = value),
              ),
              const Divider(height: 28),
              Text(
                l10n.volunteerRegularDays,
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
              const SizedBox(height: FieldnoteSpacing.lg),
              Text(
                l10n.volunteerTimeWindow,
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
                    label: Text(
                      l10n.volunteerFromTime(formatMinutes(_startMinutes)),
                    ),
                  ),
                  OutlinedButton.icon(
                    key: const Key('availability-end-time'),
                    onPressed: () => _pickTime(start: false),
                    icon: const Icon(Icons.schedule_outlined),
                    label: Text(
                      l10n.volunteerUntilTime(formatMinutes(_endMinutes)),
                    ),
                  ),
                ],
              ),
              if (availabilityWindowProblem(
                    _startMinutes,
                    _endMinutes,
                    l10n: l10n,
                  )
                  case final problem?) ...[
                const SizedBox(height: FieldnoteSpacing.xs),
                Text(
                  problem,
                  style: TextStyle(color: context.fieldnoteColors.danger),
                ),
              ],
              const SizedBox(height: FieldnoteSpacing.lg),
              Text(
                l10n.volunteerTravelFrom,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: FieldnoteSpacing.xxs),
              Text(
                l10n.volunteerTravelFromHint,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: FieldnoteSpacing.sm),
              if (_searchAvailable) ...[
                TextField(
                  controller: _placeSearch,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    labelText: l10n.corePlacesSearchLabel,
                    hintText: l10n.volunteerPlaceSearchHint,
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
                  const SizedBox(height: FieldnoteSpacing.xs),
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
                const SizedBox(height: FieldnoteSpacing.sm),
              ],
              _areaMap(context),
              const SizedBox(height: FieldnoteSpacing.md),
              Text(
                l10n.volunteerMaximumTravel(radius),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Slider(
                value: _radius,
                min: 1,
                max: 100,
                divisions: 99,
                label: l10n.volunteerKm(radius),
                onChanged: (value) => setState(() => _radius = value),
              ),
              const SizedBox(height: FieldnoteSpacing.xs),
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
                        this.context.l10n.volunteerCurrentLocationFailed,
                      );
                    }
                  }
                },
                icon: const Icon(Icons.my_location),
                label: Text(
                  _location == null
                      ? l10n.volunteerUseGpsArea
                      : _location!.isLive && !_pinnedByHand
                      ? l10n.volunteerLiveGpsSelected
                      : l10n.volunteerUseGpsAreaInstead,
                ),
              ),
              const SizedBox(height: FieldnoteSpacing.lg),
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
                  label: Text(_saving ? l10n.commonSaving : l10n.volunteerSave),
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
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            FieldnoteMap(
              target: point,
              zoom: zoomForRadius(radiusMeters),
              height: 260,
              semanticLabel: l10n.volunteerAreaMapPinSemantics,
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
                          title: l10n.volunteerYourTravelArea,
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
                    ? l10n.volunteerAreaFallbackNoArea
                    : l10n.volunteerAreaFallback(
                        '${point.latitude.toStringAsFixed(4)}, '
                        '${point.longitude.toStringAsFixed(4)}',
                        NumberFormat.decimalPattern(
                          context.localeTag,
                        ).format(_radius.round()),
                      ),
              ),
            ),
            if (mapsAvailable)
              Positioned(
                top: 8,
                right: 8,
                child: IconButton.filledTonal(
                  key: const Key('expand-volunteer-area-map'),
                  tooltip: l10n.volunteerExpandMap,
                  onPressed: _expandAreaMap,
                  icon: const Icon(Icons.fullscreen),
                ),
              ),
          ],
        ),
        if (mapsAvailable) ...[
          const SizedBox(height: FieldnoteSpacing.xs),
          Row(
            children: [
              const Icon(Icons.place_outlined, size: 16),
              const SizedBox(width: FieldnoteSpacing.xs),
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
  final settings = _settingsActionFor(context, error);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(_errorText(context, error, fallback)),
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
({String label, VoidCallback open})? _settingsActionFor(
  BuildContext context,
  Object error,
) {
  if (error is! LocationAccessException) return null;
  final service = DeviceLocationService();
  final label = context.l10n.volunteerOpenSettings;
  return switch (error.issue) {
    LocationAccessIssue.serviceDisabled => (
      label: label,
      open: () => unawaited(_openSafely(service.openLocationSettings)),
    ),
    LocationAccessIssue.permissionDeniedForever => (
      label: label,
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

Widget? _settingsButton(BuildContext context, Object error) {
  final settings = _settingsActionFor(context, error);
  if (settings == null) return null;
  return TextButton.icon(
    onPressed: settings.open,
    icon: const Icon(Icons.settings_outlined),
    label: Text(
      error is LocationAccessException &&
              error.issue == LocationAccessIssue.serviceDisabled
          ? context.l10n.volunteerOpenLocationSettings
          : context.l10n.volunteerOpenAppSettings,
    ),
  );
}

String _errorText(BuildContext context, Object error, String fallback) =>
    userMessageFor(error, fallback: fallback, context: context);
