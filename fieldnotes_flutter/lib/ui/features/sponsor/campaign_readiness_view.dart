import 'dart:async';

import 'package:fieldnotes_client/fieldnotes_client.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

import '../../../data/services/campaign_link_service.dart';
import '../../../l10n/l10n.dart';
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
          () => _error = sponsorErrorMessage(
            error,
            context: context,
            fallback: context.l10n.sponsorReadinessUpdateFailed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  String _when(DateTime value) =>
      DateFormat.MMMEd(context.localeTag).add_jm().format(value.toLocal());

  Future<void> _revise() async {
    final l10n = context.l10n;
    final localeTag = context.localeTag;
    final goal = TextEditingController(
      text: paiseInputText(campaignGoalPaise(_campaign)),
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
          title: Text(l10n.sponsorReadinessReviseTitle),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.sponsorReadinessReviseIntro),
                const SizedBox(height: 14),
                TextField(
                  controller: goal,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l10n.sponsorReadinessReviseGoalLabel,
                    helperText: l10n.sponsorReadinessRange(
                      formatPaise(
                        CampaignLimits.minimumGoalPaise,
                        localeTag: localeTag,
                      ),
                      formatPaise(
                        CampaignLimits.maximumGoalPaise,
                        localeTag: localeTag,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: minimum,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l10n.sponsorReadinessReviseMinimumLabel,
                    helperText: l10n.sponsorReadinessRange(
                      '1',
                      '${_campaign.volunteerCapacity}',
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: scope,
                  maxLines: 4,
                  maxLength: CampaignLimits.scopeNoteMax,
                  decoration: InputDecoration(
                    labelText: l10n.sponsorReadinessReviseDescriptionLabel,
                  ),
                ),
                if (problem != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    problem!,
                    style: TextStyle(
                      color: context.fieldnoteColors.danger,
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
              child: Text(l10n.sponsorCheckoutCancel),
            ),
            FilledButton(
              onPressed: () {
                final error = validateScopeRevision(
                  goal: goal.text,
                  minimum: minimum.text,
                  description: scope.text,
                  volunteerCapacity: _campaign.volunteerCapacity,
                  l10n: l10n,
                  localeTag: localeTag,
                );
                if (error != null) {
                  setDialogState(() => problem = error);
                  return;
                }
                Navigator.pop(context, true);
              },
              child: Text(l10n.sponsorReadinessSaveRevision),
            ),
          ],
        ),
      ),
    );
    if (saved == true && mounted) {
      await _run(
        () => widget.viewModel.repository.reviseCampaignScope(
          _campaign.id!,
          parseRupeesToPaise(goal.text)!,
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
      setState(() => _error = context.l10n.sponsorReadinessPostponePast);
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
    final l10n = context.l10n;
    final recorded = formatPaise(
      campaignSponsoredPaise(campaign),
      localeTag: context.localeTag,
    );
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.sponsorReadinessCancelTitle),
        content: Text(l10n.sponsorReadinessCancelBody(joined, recorded)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.sponsorReadinessKeepCampaign),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              // A solid fill with white text in both brightnesses.
              backgroundColor: FieldnoteColors.danger,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.sponsorReadinessCancelCampaign),
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
    if (!mounted) return;
    final l10n = context.l10n;
    final message =
        '${campaign.name}\n'
        '${_when(campaign.startsAt)}\n'
        '${campaign.locationName}\n'
        '${l10n.sponsorReadinessInviteMessage(link)}';
    await Clipboard.setData(ClipboardData(text: message));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.sponsorReadinessInviteCopied)),
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
    final l10n = context.l10n;
    final localeTag = context.localeTag;
    String money(int paise) => formatPaise(paise, localeTag: localeTag);
    final campaign = _campaign;
    final joined = campaign.eligibleVolunteers;
    final fundingGap = campaignRemainingPaise(campaign);
    final refunded = campaignRefundedPaise(campaign);
    final teamGap = (campaign.minimumVolunteers - joined).clamp(
      0,
      campaign.minimumVolunteers,
    );
    final cutoff = campaign.startsAt.subtract(const Duration(hours: 24));
    final beforeCutoff = DateTime.now().toUtc().isBefore(cutoff);
    final phase = campaignPhase(campaign);
    final editable = campaignIsEditable(campaign);
    final status = switch (campaign.readinessState) {
      _ when phase == CampaignPhase.completed => l10n.sponsorPhaseCompleted,
      _ when phase == CampaignPhase.inProgress => l10n.sponsorPhaseInProgress,
      'confirmed' => l10n.sponsorPhaseConfirmed,
      'fundingShort' => l10n.sponsorReadinessFundingShort,
      'volunteersShort' => l10n.sponsorReadinessVolunteersShort,
      'bothShort' => l10n.sponsorReadinessBothShort,
      'postponed' =>
        beforeCutoff && teamGap == 0
            ? l10n.sponsorReadinessPostponedCutoff
            : l10n.sponsorReadinessPostponedReconfirm,
      'cancelled' => l10n.sponsorPhaseCancelled,
      'expired' => l10n.sponsorReadinessDateExpired,
      _ => l10n.sponsorReadinessOpenTentative,
    };
    final closed = campaignIsClosed(phase);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.sponsorReadinessTitle)),
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
                        ? context.fieldnoteColors.forest
                        : context.fieldnoteColors.clay,
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
                          l10n.sponsorReadinessCutoffTitle,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.sponsorReadinessCheckedBefore(
                            _when(campaign.startsAt),
                          ),
                        ),
                        if (beforeCutoff) ...[
                          const SizedBox(height: 10),
                          Text(
                            fundingGap == 0 && teamGap == 0
                                ? l10n.sponsorReadinessReadyBeforeCutoff(
                                    _when(cutoff),
                                  )
                                : l10n.sponsorReadinessTentativeUntil(
                                    _when(cutoff),
                                  ),
                          ),
                        ],
                        const SizedBox(height: 10),
                        Text(
                          l10n.sponsorReadinessFundingLine(
                            money(campaignSponsoredPaise(campaign)),
                            money(campaignGoalPaise(campaign)),
                            money(fundingGap),
                          ),
                        ),
                        if (refunded > 0) ...[
                          const SizedBox(height: 4),
                          Text(
                            l10n.sponsorReadinessRefundedLine(money(refunded)),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                        const SizedBox(height: 8),
                        Text(
                          l10n.sponsorReadinessTeamLine(
                            joined,
                            campaign.minimumVolunteers,
                            teamGap,
                          ),
                        ),
                        if (campaign.revision > 0) ...[
                          const SizedBox(height: 10),
                          Text(l10n.sponsorReadinessReconfirmNote),
                        ],
                      ],
                    ),
                  ),
                  if (!closed && !editable) ...[
                    const SizedBox(height: 12),
                    SurfaceCard(
                      child: Text(l10n.sponsorReadinessStartedLocked),
                    ),
                  ],
                  if (editable) ...[
                    const SizedBox(height: 12),
                    SurfaceCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.sponsorReadinessDecisionsTitle,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          if (fundingGap > 0)
                            Text(l10n.sponsorReadinessTopUpHint),
                          if (teamGap > 0)
                            Text(l10n.sponsorReadinessRecruitHint),
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
                                  label: Text(l10n.sponsorReadinessCopyInvite),
                                ),
                              if (fundingGap > 0)
                                OutlinedButton.icon(
                                  onPressed: _working ? null : _checkout,
                                  icon: const Icon(
                                    Icons.volunteer_activism_outlined,
                                  ),
                                  label: Text(
                                    l10n.sponsorReadinessOpenCheckout,
                                  ),
                                ),
                              OutlinedButton.icon(
                                onPressed: _working ? null : _revise,
                                icon: const Icon(Icons.edit_outlined),
                                label: Text(l10n.sponsorReadinessReviseScope),
                              ),
                              OutlinedButton.icon(
                                onPressed: _working ? null : _postpone,
                                icon: const Icon(Icons.event_repeat_outlined),
                                label: Text(l10n.sponsorReadinessPostpone),
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
                                label: Text(l10n.sponsorReadinessRefreshStatus),
                              ),
                              OutlinedButton.icon(
                                onPressed: _working ? null : _cancel,
                                icon: const Icon(Icons.cancel_outlined),
                                label: Text(l10n.sponsorCheckoutCancel),
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
                        style: TextStyle(color: context.fieldnoteColors.danger),
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
