import 'dart:async';

import 'package:fieldnotes_client/fieldnotes_client.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../l10n/l10n.dart';
import '../../core/fieldnote_theme.dart';
import '../../core/widgets.dart';
import '../shell/fieldnote_view_model.dart';
import 'sponsor_formatting.dart';

/// Creator-only payout screen. In Razorpay Test Mode it is a test ledger
/// that never requests a bank transfer; in live mode payouts are settled
/// manually by FieldNote operations and no simulation is offered.
class CampaignPayoutView extends StatefulWidget {
  const CampaignPayoutView({
    super.key,
    required this.campaign,
    required this.viewModel,
  });

  final Campaign campaign;
  final FieldnoteViewModel viewModel;

  @override
  State<CampaignPayoutView> createState() => _CampaignPayoutViewState();
}

class _CampaignPayoutViewState extends State<CampaignPayoutView> {
  late Campaign _campaign = widget.campaign;
  List<TestPayout> _payouts = const [];
  List<TestRefund> _refunds = const [];
  bool _loading = true;
  bool _simulating = false;
  String? _error;

  /// Null until known (or when the check failed: the server then still
  /// answers `payouts_manual` if the simulate button is used in live mode).
  bool? _simulationAvailable;

  bool get _manualPayouts => _simulationAvailable == false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// Reloads the campaign itself as well as the ledgers, so the payout
  /// button never acts on a stale status (S-5).
  Future<void> _load() async {
    final id = widget.campaign.id!;
    final repository = widget.viewModel.repository;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait<dynamic>([
        repository.campaignTestPayouts(id),
        widget.viewModel.campaignRefunds(id),
        repository.myCampaigns(),
        widget.viewModel.payoutSimulationAvailable().then<bool?>(
          (value) => value,
          onError: (Object _) => null,
        ),
      ]);
      if (!mounted) return;
      final fresh = (results[2] as List<Campaign>)
          .where((item) => item.id == id)
          .firstOrNull;
      setState(() {
        _payouts = results[0] as List<TestPayout>;
        _refunds = results[1] as List<TestRefund>;
        _simulationAvailable = results[3] as bool?;
        if (fresh != null) _campaign = fresh;
      });
    } catch (error) {
      if (mounted) {
        setState(
          () => _error = sponsorErrorMessage(
            error,
            context: context,
            fallback: context.l10n.sponsorPayoutLoadFailed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _simulate() async {
    setState(() {
      _simulating = true;
      _error = null;
    });
    try {
      final payouts = await widget.viewModel.repository
          .simulateCampaignTestPayout(_campaign.id!);
      if (!mounted) return;
      setState(() => _payouts = payouts);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            payouts.isEmpty
                ? context.l10n.sponsorPayoutNothingToSimulate
                : context.l10n.sponsorPayoutSimulated,
          ),
        ),
      );
    } catch (error) {
      if (mounted) {
        setState(() {
          if (error is FieldnoteException && error.code == 'payouts_manual') {
            // Live keys: the manual-settlement notice replaces the button.
            _simulationAvailable = false;
            _error = null;
          } else {
            _error = sponsorErrorMessage(
              error,
              context: context,
              fallback: context.l10n.sponsorPayoutSimulateFailed,
            );
          }
        });
      }
      // The server may have moved the campaign on; show its real state.
      unawaited(_load());
    } finally {
      if (mounted) setState(() => _simulating = false);
    }
  }

  /// Why simulation is unavailable, or null when it is allowed.
  String? _blockedReason(AppLocalizations l10n, CampaignPhase phase) =>
      switch (phase) {
        CampaignPhase.completed => null,
        CampaignPhase.cancelled => l10n.sponsorPayoutBlockedCancelled,
        CampaignPhase.expired => l10n.sponsorPayoutBlockedExpired,
        CampaignPhase.inProgress => l10n.sponsorPayoutBlockedInProgress,
        _ => l10n.sponsorPayoutBlockedNotCompleted,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final localeTag = context.localeTag;
    final campaign = _campaign;
    final phase = campaignPhase(campaign);
    final phaseStyle = campaignPhaseStyle(phase, l10n: l10n);
    final blocked = _blockedReason(l10n, phase);
    String money(int paise) => formatPaise(paise, localeTag: localeTag);
    final simulated = _payouts.fold<int>(
      0,
      (sum, payout) => sum + payoutPaise(payout),
    );
    final refunded = campaignRefundedPaise(campaign);
    final manual = _manualPayouts;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.sponsorPayoutTitle)),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        StatusPill(
                          label: manual
                              ? l10n.sponsorPayoutManualPill
                              : l10n.sponsorPayoutTestModePill,
                          color: context.fieldnoteColors.clay,
                          icon: manual
                              ? Icons.account_balance_outlined
                              : Icons.science_outlined,
                        ),
                        StatusPill(
                          label: phaseStyle.label,
                          color: phaseStyle.color,
                          icon: phaseStyle.icon,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      campaign.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    if (!manual) ...[
                      const SizedBox(height: 8),
                      Text(l10n.sponsorPayoutTestModeNotice),
                    ],
                    if (phase == CampaignPhase.cancelled ||
                        phase == CampaignPhase.expired) ...[
                      const SizedBox(height: 12),
                      Text(
                        phase == CampaignPhase.cancelled
                            ? l10n.sponsorPayoutCancelledRefunds
                            : l10n.sponsorPayoutExpiredRefunds,
                        style: TextStyle(color: context.fieldnoteColors.danger),
                      ),
                    ],
                    const SizedBox(height: 16),
                    SurfaceCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.sponsorPayoutStatusTitle,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 18),
                          _row(
                            l10n.sponsorPayoutRecordedSponsorships,
                            money(campaignSponsoredPaise(campaign)),
                          ),
                          if (refunded > 0) ...[
                            const SizedBox(height: 12),
                            _row(
                              l10n.sponsorPayoutRefundedToSponsors,
                              money(refunded),
                            ),
                          ],
                          if (manual) ...[
                            const Divider(height: 28),
                            _ManualPayoutNotice(
                              blocked:
                                  phase == CampaignPhase.cancelled ||
                                  phase == CampaignPhase.expired,
                            ),
                          ] else ...[
                            const Divider(height: 28),
                            _row(
                              l10n.sponsorPayoutSimulatedCredit,
                              money(simulated),
                            ),
                            const SizedBox(height: 12),
                            _row(l10n.sponsorPayoutRealTransfer, money(0)),
                            const SizedBox(height: 14),
                            StatusPill(
                              label: _payouts.isEmpty
                                  ? l10n.sponsorPayoutNoSimulation
                                  : l10n.sponsorPayoutCreditsRecorded(
                                      _payouts.length,
                                    ),
                              color: context.fieldnoteColors.clay,
                              icon: Icons.science_outlined,
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed:
                                    _loading || _simulating || blocked != null
                                    ? null
                                    : _simulate,
                                icon: _simulating
                                    ? const SizedBox.square(
                                        dimension: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.play_arrow_outlined),
                                label: Text(
                                  _simulating
                                      ? l10n.sponsorPayoutSimulating
                                      : l10n.sponsorPayoutSimulateButton,
                                ),
                              ),
                            ),
                            if (blocked != null) ...[
                              const SizedBox(height: 8),
                              Text(blocked),
                            ],
                          ],
                          if (_error != null) ...[
                            const SizedBox(height: 10),
                            Text(
                              _error!,
                              style: TextStyle(
                                color: context.fieldnoteColors.danger,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (!manual) ...[
                      const SizedBox(height: 16),
                      SurfaceCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.sponsorPayoutRecipientTitle,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(l10n.sponsorPayoutRecipientAccount),
                            const SizedBox(height: 8),
                            Text(l10n.sponsorPayoutRecipientHelp),
                          ],
                        ),
                      ),
                    ],
                    if (_loading)
                      const Center(child: CircularProgressIndicator()),
                    if (_refunds.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      SurfaceCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.sponsorPayoutRefundsTitle,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            for (final refund in _refunds)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 7,
                                ),
                                child: _refundRow(refund, l10n, localeTag),
                              ),
                          ],
                        ),
                      ),
                    ],
                    if (_payouts.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      SurfaceCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.sponsorPayoutCreditHistoryTitle,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            ..._payouts.map(
                              (payout) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 7,
                                ),
                                child: _row(
                                  l10n.sponsorPayoutCheckoutLine(
                                    payout.sponsorshipId,
                                    _when(payout.simulatedAt, localeTag),
                                  ),
                                  money(payoutPaise(payout)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (!manual) ...[
                      const SizedBox(height: 16),
                      SurfaceCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.sponsorPayoutBeforeLiveTitle,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 12),
                            Text(l10n.sponsorPayoutBeforeLiveStep1),
                            const SizedBox(height: 8),
                            Text(l10n.sponsorPayoutBeforeLiveStep2),
                            const SizedBox(height: 8),
                            Text(l10n.sponsorPayoutBeforeLiveStep3),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static String _when(DateTime value, String localeTag) =>
      DateFormat.MMMd(localeTag).add_jm().format(value.toLocal());

  Widget _refundRow(
    TestRefund refund,
    AppLocalizations l10n,
    String localeTag,
  ) {
    final style = refundStatusStyle(refund.status, l10n: l10n);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _row(
          l10n.sponsorPayoutCheckoutLine(
            refund.sponsorshipId,
            refundReasonLabel(refund.reason, l10n: l10n),
          ),
          formatPaise(refundPaise(refund), localeTag: localeTag),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            StatusPill(
              label: style.label,
              color: style.color,
              icon: style.icon,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _when(refund.processedAt ?? refund.createdAt, localeTag),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _row(String label, String value) => Row(
    children: [
      Expanded(child: Text(label)),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
    ],
  );
}

/// Live mode: no simulation; FieldNote operations settle the payout by hand
/// (docs/DEPLOYMENT.md, "Payouts: manual settlement in live mode").
class _ManualPayoutNotice extends StatelessWidget {
  const _ManualPayoutNotice({required this.blocked});

  /// Cancelled or expired: there is no payout, sponsors are refunded.
  final bool blocked;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.account_balance_outlined,
          color: context.fieldnoteColors.moss,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.sponsorPayoutsManual,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              if (!blocked) ...[
                const SizedBox(height: 6),
                Text(l10n.sponsorPayoutManualDetail),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
