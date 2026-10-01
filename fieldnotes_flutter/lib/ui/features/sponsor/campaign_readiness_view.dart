import 'dart:async';

import 'package:fieldnotes_client/fieldnotes_client.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

import '../../../data/services/campaign_link_service.dart';
import '../../core/error_messages.dart';
import '../../core/fieldnote_theme.dart';
import '../../core/widgets.dart';
import '../shell/fieldnote_view_model.dart';
import 'sponsor_checkout.dart';
import 'sponsor_formatting.dart';

class CampaignReadinessView extends StatefulWidget {
  const CampaignReadinessView({
    super.key,
    required this.campaign,
    required this.viewModel,
  });

  final Campaign campaign;
  final FieldnoteViewModel viewModel;

  @override
  State<CampaignReadinessView> createState() => _CampaignReadinessViewState();
}

class _CampaignReadinessViewState extends State<CampaignReadinessView> {
  late Campaign _campaign = widget.campaign;
  bool _working = false;
  String? _error;

  Future<void> _run(Future<Campaign> Function() action) async {
    setState(() {
      _working = true;
      _error = null;
    });
    try {
      final updated = await action();
      if (mounted) setState(() => _campaign = updated);
      unawaited(widget.viewModel.refresh());
    } catch (error) {
      if (mounted) {
        setState(
          () => _error = userMessageFor(
            error,
            fallback: 'Could not update campaign readiness.',
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _revise() async {
    final goal = TextEditingController(
      text: _campaign.fundingGoal.toStringAsFixed(0),
    );
    final minimum = TextEditingController(
      text: '${_campaign.minimumVolunteers}',
    );
    final scope = TextEditingController(text: _campaign.description);
    String? problem;
    // The dialog validates before it closes, so nothing typed is lost (P2).
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Revise the work scope'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'A revised scope asks joined volunteers to reconfirm before they count toward the minimum team.',
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: goal,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Revised funding goal (₹)',
                    helperText: '₹100 – ₹10,00,000',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: minimum,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Minimum safe team',
                    helperText: '1 – ${_campaign.volunteerCapacity}',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: scope,
                  maxLines: 4,
                  maxLength: CampaignLimits.scopeNoteMax,
                  decoration: const InputDecoration(
                    labelText: 'Revised work description',
                  ),
                ),
                if (problem != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    problem!,
                    style: const TextStyle(
                      color: FieldnoteColors.danger,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final error = validateScopeRevision(
                  goal: goal.text,
                  minimum: minimum.text,
                  description: scope.text,
                  volunteerCapacity: _campaign.volunteerCapacity,
                );
                if (error != null) {
                  setDialogState(() => problem = error);
                  return;
                }
                Navigator.pop(context, true);
              },
              child: const Text('Save revision'),
            ),
          ],
        ),
      ),
    );
    if (saved == true && mounted) {
      await _run(
        () => widget.viewModel.repository.reviseCampaignScope(
          _campaign.id!,
          parseRupees(goal.text)!,
          parseWholeNumber(minimum.text)!,
          scope.text.trim(),
        ),
      );
    }
    goal.dispose();
    minimum.dispose();
    scope.dispose();
  }

  Future<void> _postpone() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _campaign.startsAt.toLocal().isAfter(now)
          ? _campaign.startsAt.toLocal()
          : now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_campaign.startsAt.toLocal()),
    );
    if (time == null || !mounted) return;
    final start = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    if (!start.isAfter(DateTime.now())) {
      setState(
        () => _error =
            'That time has already passed. Choose a new start in the future.',
      );
      return;
    }
    await _run(
      () => widget.viewModel.repository.postponeCampaign(
        _campaign.id!,
        start.toUtc(),
      ),
    );
  }

  Future<void> _cancel() async {
    final campaign = _campaign;
    final joined =
        widget.viewModel.impacts[campaign.id]?.joinedVolunteers ??
        campaign.eligibleVolunteers;
    final volunteers = joined == 1
        ? '1 volunteer has'
        : '$joined volunteers have';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel this campaign?'),
        content: Text(
          '$volunteers joined. Their places are released and they are '
          'emailed and told not to travel.\n\n'
          'Every verified sponsorship '
          '(${formatRupees(campaign.sponsoredAmount)} recorded) is refunded to '
          'the original payment method. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep campaign'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: FieldnoteColors.danger,
            ),
            child: const Text('Cancel campaign'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _run(
        () => widget.viewModel.repository.cancelCampaign(_campaign.id!),
      );
    }
  }

  Future<void> _invite() async {
    final campaign = _campaign;
    String link;
    try {
      link = await widget.viewModel.campaignShareLink(campaign.id!);
    } catch (_) {
      link = campaignShareUri(campaign).toString();
    }
    final message =
        '${campaign.name}\n'
        '${DateFormat('EEE, d MMM · h:mm a').format(campaign.startsAt.toLocal())}\n'
        '${campaign.locationName}\n'
        'Volunteer places are open on FieldNote. Join here: $link';
    await Clipboard.setData(ClipboardData(text: message));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Invite and campaign link copied. Share them with your volunteers.',
          ),
        ),
      );
    }
  }

  Future<void> _checkout() async {
    setState(() => _error = null);
    final paid = await openSponsorCheckout(
      context,
      widget.viewModel,
      _campaign,
    );
    if (!mounted) return;
    // The checkout refreshes the view model; pick up the new funding figures.
    final fresh = widget.viewModel.campaignById(_campaign.id!);
    if (fresh != null) setState(() => _campaign = fresh);
    if (paid) {
      await _run(
        () => widget.viewModel.repository.refreshCampaignReadiness(
          _campaign.id!,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final campaign = _campaign;
    final joined = campaign.eligibleVolunteers;
    final fundingGap = (campaign.fundingGoal - campaign.sponsoredAmount).clamp(
      0,
      double.infinity,
    );
    final teamGap = (campaign.minimumVolunteers - joined).clamp(
      0,
      campaign.minimumVolunteers,
    );
    final cutoff = campaign.startsAt.subtract(const Duration(hours: 24));
    final beforeCutoff = DateTime.now().toUtc().isBefore(cutoff);
    final phase = campaignPhase(campaign);
    final editable = campaignIsEditable(campaign);
    final status = switch (campaign.readinessState) {
      _ when phase == CampaignPhase.completed => 'Completed',
      _ when phase == CampaignPhase.inProgress => 'In progress',
      'confirmed' => 'Confirmed',
      'fundingShort' => 'Funding short',
      'volunteersShort' => 'Volunteers short',
      'bothShort' => 'Funding and volunteers short',
      'postponed' =>
        beforeCutoff && teamGap == 0
            ? 'Postponed · awaiting cutoff'
            : 'Postponed · awaiting reconfirmation',
      'cancelled' => 'Cancelled',
      'expired' => 'Date expired',
      _ => 'Open · date tentative',
    };
    final closed = campaignIsClosed(phase);
    return Scaffold(
      appBar: AppBar(title: const Text('Campaign readiness')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    campaign.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  StatusPill(
                    label: status,
                    color: campaign.readinessState == 'confirmed'
                        ? FieldnoteColors.forest
                        : FieldnoteColors.clay,
                    icon: campaign.readinessState == 'confirmed'
                        ? Icons.verified_outlined
                        : Icons.schedule,
                  ),
                  const SizedBox(height: 14),
                  SurfaceCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'At the cutoff',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Readiness is checked 24 hours before ${DateFormat('EEE, d MMM · h:mm a').format(campaign.startsAt.toLocal())}.',
                        ),
                        if (beforeCutoff) ...[
                          const SizedBox(height: 10),
                          Text(
                            fundingGap == 0 && teamGap == 0
                                ? 'Funding and the minimum team are ready. The event will be checked for confirmation on ${DateFormat('EEE, d MMM · h:mm a').format(cutoff.toLocal())}.'
                                : 'The event stays tentative until ${DateFormat('EEE, d MMM · h:mm a').format(cutoff.toLocal())}. Refreshing now updates the counts.',
                          ),
                        ],
                        const SizedBox(height: 10),
                        Text(
                          'Funding: ₹${campaign.sponsoredAmount.toStringAsFixed(0)} of ₹${campaign.fundingGoal.toStringAsFixed(0)} · ₹${fundingGap.toStringAsFixed(0)} short',
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Team: $joined joined · ${campaign.minimumVolunteers} minimum · $teamGap short',
                        ),
                        if (campaign.revision > 0) ...[
                          const SizedBox(height: 10),
                          const Text(
                            'After a scope or date change, joined volunteers must reconfirm before counting toward readiness.',
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (!closed && !editable) ...[
                    const SizedBox(height: 12),
                    const SurfaceCard(
                      child: Text(
                        'This campaign has started. Its date and scope are '
                        'locked and it can no longer be cancelled.',
                      ),
                    ),
                  ],
                  if (editable) ...[
                    const SizedBox(height: 12),
                    SurfaceCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sponsor decisions',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          if (fundingGap > 0)
                            const Text(
                              'Top up through the sponsor checkout. A verified payment updates the funding result.',
                            ),
                          if (teamGap > 0)
                            const Text(
                              'Keep recruiting volunteers. New joins and reconfirmations update the team result.',
                            ),
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              if (teamGap > 0)
                                OutlinedButton.icon(
                                  onPressed: _working ? null : _invite,
                                  icon: const Icon(
                                    Icons.person_add_alt_outlined,
                                  ),
                                  label: const Text('Copy volunteer invite'),
                                ),
                              if (fundingGap > 0)
                                OutlinedButton.icon(
                                  onPressed: _working ? null : _checkout,
                                  icon: const Icon(
                                    Icons.volunteer_activism_outlined,
                                  ),
                                  label: const Text('Open sponsor checkout'),
                                ),
                              OutlinedButton.icon(
                                onPressed: _working ? null : _revise,
                                icon: const Icon(Icons.edit_outlined),
                                label: const Text('Revise scope'),
                              ),
                              OutlinedButton.icon(
                                onPressed: _working ? null : _postpone,
                                icon: const Icon(Icons.event_repeat_outlined),
                                label: const Text('Postpone'),
                              ),
                              OutlinedButton.icon(
                                onPressed: _working
                                    ? null
                                    : () => _run(
                                        () => widget.viewModel.repository
                                            .refreshCampaignReadiness(
                                              campaign.id!,
                                            ),
                                      ),
                                icon: const Icon(Icons.refresh),
                                label: const Text('Refresh status'),
                              ),
                              OutlinedButton.icon(
                                onPressed: _working ? null : _cancel,
                                icon: const Icon(Icons.cancel_outlined),
                                label: const Text('Cancel'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (_working)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        _error!,
                        style: const TextStyle(color: FieldnoteColors.danger),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
