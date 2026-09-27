import 'package:fieldnotes_client/fieldnotes_client.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/services/campaign_link_service.dart';
import '../../core/fieldnote_theme.dart';
import '../../core/widgets.dart';
import '../shell/fieldnote_view_model.dart';

/// Destination for campaign links opened from a browser or social app.
class SharedCampaignView extends StatefulWidget {
  const SharedCampaignView({
    super.key,
    required this.campaign,
    required this.viewModel,
  });

  final Campaign campaign;
  final FieldnoteViewModel viewModel;

  @override
  State<SharedCampaignView> createState() => _SharedCampaignViewState();
}

class _SharedCampaignViewState extends State<SharedCampaignView> {
  bool _joining = false;

  Future<void> _join() async {
    setState(() => _joining = true);
    try {
      await widget.viewModel.join(widget.campaign);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You joined ${widget.campaign.name}.')),
      );
      Navigator.of(context).pop();
      widget.viewModel.selectSection(1);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not join this campaign: $error')),
      );
    } finally {
      if (mounted) setState(() => _joining = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final campaign = widget.campaign;
    final joined = widget.viewModel.participationFor(campaign.id!) != null;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campaign invitation'),
        actions: [
          IconButton(
            tooltip: 'Share campaign',
            onPressed: () => shareCampaign(context, campaign),
            icon: const Icon(Icons.share_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'FIELDNOTE CAMPAIGN',
                  style: TextStyle(
                    color: FieldnoteColors.clay,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  campaign.name,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 14),
                Text(campaign.description),
                const Divider(height: 32),
                Row(
                  children: [
                    const Icon(Icons.place_outlined, size: 20),
                    const SizedBox(width: 10),
                    Expanded(child: Text(campaign.locationName)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.event_outlined, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      DateFormat('EEE, d MMM · h:mm a').format(
                        campaign.startsAt.toLocal(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                if (widget.viewModel.isVolunteer)
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _joining
                          ? null
                          : joined
                          ? () {
                              Navigator.of(context).pop();
                              widget.viewModel.selectSection(1);
                            }
                          : _join,
                      icon: Icon(joined ? Icons.hiking : Icons.groups_outlined),
                      label: Text(
                        _joining
                            ? 'Joining…'
                            : joined
                            ? 'View my work'
                            : 'Join campaign',
                      ),
                    ),
                  )
                else
                  const Text(
                    'Sign in with a volunteer account to join this campaign.',
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
