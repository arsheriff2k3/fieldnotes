import 'package:fieldnotes_client/fieldnotes_client.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/services/campaign_link_service.dart';
import '../../core/error_messages.dart';
import '../../core/fieldnote_theme.dart';
import '../../core/widgets.dart';
import '../shell/fieldnote_view_model.dart';
import 'volunteer_status.dart';

/// Opens a campaign deep link for the signed-in user.
///
/// The server only shares campaigns that have not started yet. When the link
/// is for a campaign this volunteer already holds a place in, it routes to
/// My work instead of reporting that the campaign is no longer open. Errors
/// are shown as friendly messages.
Future<void> openSharedCampaignLink(
  BuildContext context,
  FieldnoteViewModel viewModel,
  CampaignLinkTarget target,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context);
  Campaign? campaign;
  try {
    campaign = await viewModel.campaignForLink(target);
  } catch (error) {
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          userMessageFor(
            error,
            fallback: 'Could not open the campaign link. Try again.',
          ),
        ),
      ),
    );
    return;
  }
  if (campaign == null) {
    final joinedId = joinedCampaignIdForLink(viewModel, target);
    if (joinedId != null) {
      viewModel.selectSection(1);
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'This campaign has started. Your place is in My work.',
          ),
        ),
      );
      return;
    }
    messenger.showSnackBar(
      const SnackBar(content: Text('This campaign is no longer open.')),
    );
    return;
  }
  await navigator.push<void>(
    MaterialPageRoute(
      builder: (_) =>
          SharedCampaignView(campaign: campaign!, viewModel: viewModel),
    ),
  );
}

/// The id of the linked campaign when this volunteer holds a place in it.
int? joinedCampaignIdForLink(
  FieldnoteViewModel viewModel,
  CampaignLinkTarget target,
) {
  if (!viewModel.isVolunteer) return null;
  final id =
      target.id ??
      viewModel.campaigns
          .where((campaign) => campaign.shareSlug == target.slug)
          .firstOrNull
          ?.id ??
      viewModel.participationHistory
          .where((entry) => entry.campaign.shareSlug == target.slug)
          .firstOrNull
          ?.campaign
          .id;
  if (id == null) return null;
  return holdsPlace(viewModel.participationFor(id)) ? id : null;
}

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
        SnackBar(
          content: Text(
            userMessageFor(error, fallback: 'Could not join this campaign.'),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _joining = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final campaign = widget.campaign;
    final joined = holdsPlace(
      widget.viewModel.participationFor(campaign.id!),
    );
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
