import 'package:fieldnotes_client/fieldnotes_client.dart';
import 'package:flutter/material.dart';

import '../../../data/repositories/fieldnote_repository.dart';
import '../../core/fieldnote_map.dart';
import '../../core/fieldnote_theme.dart';

/// Creator-only view of coarse availability areas around a published campaign.
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
  CampaignReach? _reach;
  String? _error;
  bool _loading = true;
  bool _sending = false;

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
      final reach = await widget.repository.campaignVolunteerReach(
        widget.campaign.id!,
      );
      if (mounted) setState(() => _reach = reach);
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _invite(ReachCell cell) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Invite volunteers?'),
        content: Text(
          'Send an in-app invitation to ${cell.volunteerCount} available '
          'volunteers in this area for ${widget.campaign.name}? '
          'They can choose whether to join.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Send invites'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _sending = true);
    try {
      final sent = await widget.repository.inviteCampaignVolunteersInArea(
        widget.campaign.id!,
        cell.latitude,
        cell.longitude,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            sent == 0
                ? 'These volunteers have already been invited.'
                : '$sent volunteer${sent == 1 ? '' : 's'} invited. They will see this campaign in Matches.',
          ),
        ),
      );
      await _load();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not send invitations: $error')),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final campaignPoint = LatLng(
      widget.campaign.latitude,
      widget.campaign.longitude,
    );
    final reach = _reach;
    final cells = reach?.coverageCells ?? const <ReachCell>[];
    return Scaffold(
      appBar: AppBar(title: const Text('Nearby volunteers')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
          children: [
            Text(
              widget.campaign.name,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'See available volunteers who can travel to this campaign. '
              'The map groups nearby volunteers and hides areas with fewer '
              'than three people to protect their locations.',
            ),
            const SizedBox(height: 18),
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
              Text(
                reach!.summary,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 14),
              FieldnoteMap(
                target: campaignPoint,
                height: 380,
                zoom: 11,
                fitBounds: [
                  campaignPoint,
                  for (final cell in cells)
                    LatLng(cell.latitude, cell.longitude),
                ],
                semanticLabel: 'Campaign and grouped volunteer areas',
                fallback: const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'Map unavailable. Areas and invite buttons are listed below.',
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
                  for (var index = 0; index < cells.length; index++)
                    Marker(
                      markerId: MarkerId('area-$index'),
                      position: LatLng(
                        cells[index].latitude,
                        cells[index].longitude,
                      ),
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                        FieldnoteMapPalette.volunteer,
                      ),
                      infoWindow: InfoWindow(
                        title:
                            '${cells[index].volunteerCount} available volunteers',
                        snippet: 'Tap to invite this area',
                      ),
                      onTap: () => _invite(cells[index]),
                    ),
                },
              ),
              const SizedBox(height: 14),
              for (var index = 0; index < cells.length; index++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.groups_outlined,
                            color: FieldnoteColors.forest,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Area ${index + 1} · ${cells[index].volunteerCount} available',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ),
                          FilledButton(
                            onPressed: _sending
                                ? null
                                : () => _invite(cells[index]),
                            child: const Text('Invite'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
