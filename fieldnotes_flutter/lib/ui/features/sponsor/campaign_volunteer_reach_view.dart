import 'package:fieldnotes_client/fieldnotes_client.dart';
import 'package:flutter/material.dart';

import '../../../data/repositories/fieldnote_repository.dart';
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
      if (mounted) setState(() => _error = '$error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _invite(CampaignVolunteerMapMember person) async {
    if (person.status != 'available' || !_invitationsOpen) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Invite this volunteer?'),
        content: Text(
          'Send ${person.displayName} an in-app invitation to '
          '${widget.campaign.name}? They can choose whether to join.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Send invite'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _sending = true);
    try {
      final sent = await widget.repository.inviteCampaignVolunteer(
        widget.campaign.id!,
        person.profileId,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            sent
                ? 'Invitation sent to ${person.displayName}.'
                : '${person.displayName} has already joined or been invited.',
          ),
        ),
      );
      await _load();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not send invitation: $error')),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _showArea(_VolunteerAreaGroup area) {
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
                '${_statusLabel(area.status)} in this area',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 6),
              const Text('Pins show approximate areas, not live locations.'),
              const SizedBox(height: 12),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: area.people.length,
                  itemBuilder: (context, index) => _personTile(
                    area.people[index],
                    onInvite: () {
                      Navigator.pop(sheetContext);
                      _invite(area.people[index]);
                    },
                  ),
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _personTile(
    CampaignVolunteerMapMember person, {
    VoidCallback? onInvite,
  }) => Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: _statusColor(person.status).withValues(alpha: .16),
            foregroundColor: _statusColor(person.status),
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
          if (person.status == 'available' && _invitationsOpen)
            FilledButton(
              onPressed: _sending ? null : onInvite ?? () => _invite(person),
              child: const Text('Invite'),
            )
          else
            StatusPill(
              label: _statusLabel(person.status),
              color: _statusColor(person.status),
              icon: person.status == 'joined'
                  ? Icons.check_circle_outline
                  : Icons.mark_email_read_outlined,
            ),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final campaignPoint = LatLng(
      widget.campaign.latitude,
      widget.campaign.longitude,
    );
    final volunteers = _map?.volunteers ?? const <CampaignVolunteerMapMember>[];
    final areas = _groupByArea(volunteers);
    final joined = volunteers
        .where((person) => person.status == 'joined')
        .length;
    final available = volunteers
        .where((person) => person.status == 'available')
        .length;
    return Scaffold(
      appBar: AppBar(title: const Text('Nearby volunteers')),
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
              'See who joined and invite nearby volunteers. Pins show approximate areas.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_error != null)
              Column(
                children: [
                  Text(_error!),
                  TextButton(onPressed: _load, child: const Text('Try again')),
                ],
              )
            else ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  StatusPill(
                    label: '$joined joined',
                    color: FieldnoteColors.forest,
                    icon: Icons.check_circle_outline,
                  ),
                  StatusPill(
                    label: '$available to invite',
                    color: FieldnoteColors.clay,
                    icon: Icons.person_add_alt_1_outlined,
                  ),
                  StatusPill(
                    label: '${volunteers.length} total',
                    color: FieldnoteColors.moss,
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
                ],
                semanticLabel: 'Campaign and approximate volunteer areas',
                fallback: const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'Map unavailable. Volunteers and invite buttons are listed below.',
                  ),
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
                        title: '${area.people.length} ${area.status}',
                        snippet: 'Tap to view volunteers',
                      ),
                      onTap: () => _showArea(area),
                    ),
                },
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 12,
                runSpacing: 6,
                children: const [
                  _MapLegend(color: Colors.green, label: 'Campaign'),
                  _MapLegend(color: Colors.purple, label: 'Joined'),
                  _MapLegend(color: Colors.blue, label: 'Available'),
                  _MapLegend(color: Colors.orange, label: 'Invited'),
                ],
              ),
              const SizedBox(height: 22),
              Text('Volunteers', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              if (volunteers.isEmpty)
                const Text(
                  'No joined or available volunteers are in reach yet. '
                  'Ask volunteers to publish availability for this area.',
                )
              else
                for (final person in volunteers) ...[
                  _personTile(person),
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

String _statusLabel(String status) => switch (status) {
  'joined' => 'Joined',
  'invited' => 'Invited',
  _ => 'Available',
};

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
