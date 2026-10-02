import 'package:fieldnotes_client/fieldnotes_client.dart';
import 'package:flutter/material.dart';

import '../../../data/repositories/fieldnote_repository.dart';
import '../../../l10n/l10n.dart';
import '../../core/error_messages.dart';
import '../../core/fieldnote_map.dart';
import '../../core/fieldnote_theme.dart';
import '../../core/widgets.dart';

/// Creator-only view of volunteers at approximate, never exact, positions.
class CampaignVolunteerReachView extends StatefulWidget {
  const CampaignVolunteerReachView({
    super.key,
    required this.campaign,
    required this.repository,
  });

  final Campaign campaign;
  final FieldnoteRepository repository;

  @override
  State<CampaignVolunteerReachView> createState() =>
      _CampaignVolunteerReachViewState();
}

class _CampaignVolunteerReachViewState
    extends State<CampaignVolunteerReachView> {
  CampaignVolunteerMap? _map;
  String? _error;
  bool _loading = true;
  bool _sending = false;

  bool get _invitationsOpen =>
      widget.campaign.status == CampaignStatus.active &&
      DateTime.now().toUtc().isBefore(widget.campaign.startsAt) &&
      !const {'cancelled', 'expired'}.contains(widget.campaign.readinessState);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final map = await widget.repository.campaignVolunteerMap(
        widget.campaign.id!,
      );
      if (mounted) setState(() => _map = map);
    } catch (error) {
      if (mounted) {
        setState(
          () => _error = userMessageFor(
            error,
            fallback: context.l10n.sponsorReachLoadFailed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  static bool _isBucket(CampaignVolunteerMapMember member) =>
      member.profileId == 0 && member.status != 'joined';

  static int _bucketSize(CampaignVolunteerMapMember bucket) =>
      bucket.volunteerCount ?? 0;

  /// Invites every eligible volunteer in one anonymous area bucket. The
  /// sponsor never learns who they are.
  Future<void> _inviteArea(CampaignVolunteerMapMember bucket) async {
    final latitude = bucket.latitude;
    final longitude = bucket.longitude;
    if (latitude == null ||
        longitude == null ||
        bucket.status != 'area' ||
        !_invitationsOpen) {
      return;
    }
    final count = _bucketSize(bucket);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.sponsorReachInviteTitle),
        content: Text(
          context.l10n.sponsorReachInviteBody(count, widget.campaign.name),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.sponsorReachCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.sponsorReachInviteArea),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _sending = true);
    try {
      final sent = await widget.repository.inviteCampaignVolunteersInArea(
        widget.campaign.id!,
        latitude,
        longitude,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            sent == 0
                ? context.l10n.sponsorReachAllAlreadyInvited
                : context.l10n.sponsorReachInvitedCount(sent),
          ),
        ),
      );
      await _load();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            userMessageFor(
              error,
              fallback: context.l10n.sponsorReachInviteFailed,
            ),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _showJoinedArea(_VolunteerAreaGroup area) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.l10n.sponsorReachJoinedInArea,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 6),
              Text(context.l10n.sponsorReachApproximateNote),
              const SizedBox(height: 12),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: area.people.length,
                  itemBuilder: (context, index) =>
                      _personTile(area.people[index]),
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBucket(CampaignVolunteerMapMember bucket) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: _bucketTile(
            bucket,
            onInvite: () {
              Navigator.pop(sheetContext);
              _inviteArea(bucket);
            },
          ),
        ),
      ),
    );
  }

  /// A named row. Only volunteers who joined are ever named (A-2).
  Widget _personTile(CampaignVolunteerMapMember person) => Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: context.fieldnoteColors
                .adapt(_statusColor('joined'))
                .withValues(alpha: .16),
            foregroundColor: context.fieldnoteColors.adapt(
              _statusColor('joined'),
            ),
            child: Text(
              person.displayName.isEmpty
                  ? '?'
                  : person.displayName.characters.first.toUpperCase(),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  person.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(
                  person.areaLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          StatusPill(
            label: context.l10n.sponsorReachJoined,
            color: _statusColor('joined'),
            icon: Icons.check_circle_outline,
          ),
        ],
      ),
    ),
  );

  /// An anonymous bucket: "N volunteers in this area".
  Widget _bucketTile(
    CampaignVolunteerMapMember bucket, {
    VoidCallback? onInvite,
  }) {
    final count = _bucketSize(bucket);
    final invited = bucket.status == 'invited';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: context.fieldnoteColors
                  .adapt(_statusColor(bucket.status))
                  .withValues(alpha: .16),
              foregroundColor: context.fieldnoteColors.adapt(
                _statusColor(bucket.status),
              ),
              child: const Icon(Icons.groups_outlined),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.sponsorReachBucketTitle(count),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    bucket.areaLabel,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (!invited && _invitationsOpen)
              FilledButton(
                onPressed: _sending
                    ? null
                    : onInvite ?? () => _inviteArea(bucket),
                child: Text(context.l10n.sponsorReachInviteArea),
              )
            else
              StatusPill(
                label: invited
                    ? context.l10n.sponsorReachAllInvited
                    : context.l10n.sponsorReachClosed,
                color: _statusColor(bucket.status),
                icon: Icons.mark_email_read_outlined,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final campaignPoint = LatLng(
      widget.campaign.latitude,
      widget.campaign.longitude,
    );
    final members = _map?.volunteers ?? const <CampaignVolunteerMapMember>[];
    final joinedPeople = members
        .where((member) => member.status == 'joined')
        .toList();
    final buckets = members.where(_isBucket).toList();
    final areas = _groupByArea(joinedPeople);
    final joined = joinedPeople.length;
    final inReach = buckets.fold<int>(
      0,
      (sum, bucket) => sum + _bucketSize(bucket),
    );
    return Scaffold(
      appBar: AppBar(title: Text(l10n.sponsorReachTitle)),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            Text(
              widget.campaign.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.sponsorReachPrivacyNote,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_error != null)
              Column(
                children: [
                  Text(_error!, textAlign: TextAlign.center),
                  TextButton(
                    onPressed: _load,
                    child: Text(l10n.commonTryAgain),
                  ),
                ],
              )
            else ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  StatusPill(
                    label: l10n.sponsorReachJoinedCount(joined),
                    color: context.fieldnoteColors.forest,
                    icon: Icons.check_circle_outline,
                  ),
                  StatusPill(
                    label: l10n.sponsorReachInReachCount(inReach),
                    color: context.fieldnoteColors.clay,
                    icon: Icons.person_add_alt_1_outlined,
                  ),
                  StatusPill(
                    label: l10n.sponsorReachAreaCount(buckets.length),
                    color: context.fieldnoteColors.moss,
                    icon: Icons.groups_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              FieldnoteMap(
                target: campaignPoint,
                height: 320,
                zoom: 11,
                fitBounds: [
                  campaignPoint,
                  for (final area in areas) area.position,
                  for (final bucket in buckets)
                    if (bucket.latitude != null && bucket.longitude != null)
                      LatLng(bucket.latitude!, bucket.longitude!),
                ],
                semanticLabel: l10n.sponsorReachMapSemantics,
                fallback: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(l10n.sponsorReachMapFallback),
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId('campaign'),
                    position: campaignPoint,
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      FieldnoteMapPalette.campaign,
                    ),
                    infoWindow: InfoWindow(title: widget.campaign.name),
                  ),
                  for (final area in areas)
                    Marker(
                      markerId: MarkerId(
                        '${area.latitude},${area.longitude},${area.status}',
                      ),
                      position: area.position,
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                        _markerHue(area.status),
                      ),
                      infoWindow: InfoWindow(
                        title: l10n.sponsorReachJoinedCount(area.people.length),
                        snippet: l10n.sponsorReachMarkerTapHint,
                      ),
                      onTap: () => _showJoinedArea(area),
                    ),
                  for (final bucket in buckets)
                    if (bucket.latitude != null && bucket.longitude != null)
                      Marker(
                        markerId: MarkerId(
                          'area:${bucket.latitude},${bucket.longitude}',
                        ),
                        position: LatLng(
                          bucket.latitude! + .0015,
                          bucket.longitude! + .0015,
                        ),
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                          _markerHue(bucket.status),
                        ),
                        infoWindow: InfoWindow(
                          title: l10n.sponsorReachMarkerVolunteers(
                            _bucketSize(bucket),
                          ),
                          snippet: bucket.areaLabel,
                        ),
                        onTap: () => _showBucket(bucket),
                      ),
                },
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 12,
                runSpacing: 6,
                children: [
                  _MapLegend(
                    color: Colors.green,
                    label: l10n.sponsorReachLegendCampaign,
                  ),
                  _MapLegend(
                    color: Colors.purple,
                    label: l10n.sponsorReachJoined,
                  ),
                  _MapLegend(
                    color: Colors.blue,
                    label: l10n.sponsorReachLegendVolunteerArea,
                  ),
                  _MapLegend(
                    color: Colors.orange,
                    label: l10n.sponsorReachLegendAreaInvited,
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Text(
                l10n.sponsorReachJoined,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              if (joinedPeople.isEmpty)
                Text(l10n.sponsorReachNoneJoined)
              else
                for (final person in joinedPeople) ...[
                  _personTile(person),
                  const SizedBox(height: 8),
                ],
              const SizedBox(height: 18),
              Text(
                l10n.sponsorReachNearbyAreas,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              if (buckets.isEmpty)
                Text(
                  _invitationsOpen
                      ? l10n.sponsorReachNoAreas
                      : l10n.sponsorReachInvitationsClosed,
                )
              else
                for (final bucket in buckets) ...[
                  _bucketTile(bucket),
                  const SizedBox(height: 8),
                ],
            ],
          ],
        ),
      ),
    );
  }
}

class _VolunteerAreaGroup {
  _VolunteerAreaGroup(this.latitude, this.longitude, this.status);

  final double latitude;
  final double longitude;
  final String status;
  final List<CampaignVolunteerMapMember> people = [];

  // Separate status pins within the same coarse area; neither is a GPS point.
  LatLng get position => LatLng(
    latitude + (status == 'invited' ? .0015 : 0),
    longitude +
        switch (status) {
          'joined' => -.0015,
          'available' => .0015,
          _ => 0,
        },
  );
}

List<_VolunteerAreaGroup> _groupByArea(
  List<CampaignVolunteerMapMember> volunteers,
) {
  final groups = <String, _VolunteerAreaGroup>{};
  for (final person in volunteers) {
    final latitude = person.latitude;
    final longitude = person.longitude;
    if (latitude == null || longitude == null) continue;
    final key = '$latitude,$longitude,${person.status}';
    groups
        .putIfAbsent(
          key,
          () => _VolunteerAreaGroup(latitude, longitude, person.status),
        )
        .people
        .add(person);
  }
  return groups.values.toList();
}

Color _statusColor(String status) => switch (status) {
  'joined' => FieldnoteColors.forest,
  'invited' => FieldnoteColors.clay,
  _ => const Color(0xFF2871A0),
};

double _markerHue(String status) => switch (status) {
  'joined' => BitmapDescriptor.hueViolet,
  'invited' => BitmapDescriptor.hueOrange,
  _ => BitmapDescriptor.hueAzure,
};

class _MapLegend extends StatelessWidget {
  const _MapLegend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 5),
      Text(label, style: Theme.of(context).textTheme.labelSmall),
    ],
  );
}
