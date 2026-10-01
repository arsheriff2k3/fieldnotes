import 'dart:async';

import 'package:fieldnotes_client/fieldnotes_client.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/error_messages.dart';
import '../../core/fieldnote_theme.dart';
import '../../core/widgets.dart';
import '../shell/fieldnote_view_model.dart';
import 'sponsor_formatting.dart';

/// Creator-only test ledger. It deliberately never requests a bank transfer.
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
      ]);
      if (!mounted) return;
      final fresh = (results[2] as List<Campaign>)
          .where((item) => item.id == id)
          .firstOrNull;
      setState(() {
        _payouts = results[0] as List<TestPayout>;
        _refunds = results[1] as List<TestRefund>;
        if (fresh != null) _campaign = fresh;
      });
    } catch (error) {
      if (mounted) {
        setState(
          () => _error = userMessageFor(
            error,
            fallback: 'Could not load payout and refund records.',
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
                ? 'No verified Razorpay test checkout is ready to simulate.'
                : 'Test payout recorded. No money was sent.',
          ),
        ),
      );
    } catch (error) {
      if (mounted) {
        setState(
          () => _error = userMessageFor(
            error,
            fallback: 'Could not simulate payout.',
          ),
        );
      }
      // The server may have moved the campaign on; show its real state.
      unawaited(_load());
    } finally {
      if (mounted) setState(() => _simulating = false);
    }
  }

  /// Why simulation is unavailable, or null when it is allowed.
  String? _blockedReason(CampaignPhase phase) => switch (phase) {
    CampaignPhase.completed => null,
    CampaignPhase.cancelled =>
      'This campaign was cancelled, so sponsors are refunded instead of a '
          'creator payout.',
    CampaignPhase.expired =>
      'This campaign expired before it was confirmed, so sponsors are '
          'refunded instead of a creator payout.',
    CampaignPhase.inProgress =>
      'The event is under way. A payout can be simulated once FieldNote '
          'marks the campaign completed after it ends.',
    _ =>
      'A payout can only be simulated after the campaign is completed: '
          'the event must take place and FieldNote marks it completed after '
          'it ends.',
  };

  @override
  Widget build(BuildContext context) {
    final campaign = _campaign;
    final phase = campaignPhase(campaign);
    final phaseStyle = campaignPhaseStyle(phase);
    final blocked = _blockedReason(phase);
    final money = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    final simulated = _payouts.fold<double>(
      0,
      (sum, payout) => sum + payout.amount,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Campaign payout')),
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
                        const StatusPill(
                          label: 'Razorpay Test Mode',
                          color: FieldnoteColors.clay,
                          icon: Icons.science_outlined,
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
                    const SizedBox(height: 8),
                    const Text(
                      'Payment testing is active. No real money has moved to a bank account.',
                    ),
                    if (phase == CampaignPhase.cancelled ||
                        phase == CampaignPhase.expired) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Campaign ${phase == CampaignPhase.cancelled ? 'cancelled' : 'expired'} · '
                        'verified sponsorships are refunded to the original '
                        'payment method.',
                        style: const TextStyle(color: FieldnoteColors.danger),
                      ),
                    ],
                    const SizedBox(height: 16),
                    SurfaceCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Payout status',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 18),
                          _row(
                            'Recorded sponsorships',
                            money.format(campaign.sponsoredAmount),
                          ),
                          const Divider(height: 28),
                          _row(
                            'Simulated creator credit',
                            money.format(simulated),
                          ),
                          const SizedBox(height: 12),
                          _row('Real bank transfer', money.format(0)),
                          const SizedBox(height: 14),
                          StatusPill(
                            label: _payouts.isEmpty
                                ? 'No simulation yet'
                                : '${_payouts.length} test credit${_payouts.length == 1 ? '' : 's'} recorded',
                            color: FieldnoteColors.clay,
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
                                    ? 'Recording test payout…'
                                    : 'Simulate payout to creator',
                              ),
                            ),
                          ),
                          if (blocked != null) ...[
                            const SizedBox(height: 8),
                            Text(blocked),
                          ],
                          if (_error != null) ...[
                            const SizedBox(height: 10),
                            Text(
                              _error!,
                              style: const TextStyle(
                                color: FieldnoteColors.danger,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SurfaceCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Recipient account',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Creator test account · in-app ledger only',
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Tap Simulate after a verified Razorpay test checkout. Each checkout is credited once in this app’s test ledger. No Razorpay Route transfer or bank deposit occurs.',
                          ),
                        ],
                      ),
                    ),
                    if (_loading)
                      const Center(child: CircularProgressIndicator()),
                    if (_refunds.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      SurfaceCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sponsor refunds',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            for (final refund in _refunds)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 7,
                                ),
                                child: _refundRow(refund, money),
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
                              'Test credit history',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            ..._payouts.map(
                              (payout) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 7,
                                ),
                                child: _row(
                                  'Checkout #${payout.sponsorshipId} · ${DateFormat('d MMM, h:mm a').format(payout.simulatedAt.toLocal())}',
                                  money.format(payout.amount),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    SurfaceCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Before live payouts',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            '1. Verify the campaign creator and payout account.',
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '2. Decide when funds are released if a campaign is delayed, cancelled, or underfunded.',
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '3. Reconcile provider transfers, failures, and refunds with the campaign ledger.',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _refundRow(TestRefund refund, NumberFormat money) {
    final style = refundStatusStyle(refund.status);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _row(
          'Checkout #${refund.sponsorshipId} · ${refundReasonLabel(refund.reason)}',
          money.format(refund.amount),
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
                DateFormat(
                  'd MMM, h:mm a',
                ).format((refund.processedAt ?? refund.createdAt).toLocal()),
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
