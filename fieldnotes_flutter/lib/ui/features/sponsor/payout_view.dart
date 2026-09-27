import 'package:fieldnotes_client/fieldnotes_client.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/repositories/fieldnote_repository.dart';
import '../../core/fieldnote_theme.dart';
import '../../core/widgets.dart';

/// Creator-only test ledger. It deliberately never requests a bank transfer.
class CampaignPayoutView extends StatefulWidget {
  const CampaignPayoutView({
    super.key,
    required this.campaign,
    required this.repository,
  });

  final Campaign campaign;
  final FieldnoteRepository repository;

  @override
  State<CampaignPayoutView> createState() => _CampaignPayoutViewState();
}

class _CampaignPayoutViewState extends State<CampaignPayoutView> {
  List<TestPayout> _payouts = const [];
  bool _loading = true;
  bool _simulating = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final payouts = await widget.repository.campaignTestPayouts(
        widget.campaign.id!,
      );
      if (mounted) {
        setState(() => _payouts = payouts);
      }
    } catch (error) {
      if (mounted) {
        setState(() => _error = 'Could not load test payout records.');
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
      final payouts = await widget.repository.simulateCampaignTestPayout(
        widget.campaign.id!,
      );
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
          () => _error = error is FieldnoteException
              ? error.message
              : 'Could not simulate payout.',
        );
      }
    } finally {
      if (mounted) setState(() => _simulating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final money = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    final simulated = _payouts.fold<double>(
      0,
      (sum, payout) => sum + payout.amount,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Campaign payout')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const StatusPill(
                    label: 'Razorpay Test Mode',
                    color: FieldnoteColors.clay,
                    icon: Icons.science_outlined,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    widget.campaign.name,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Payment testing is active. No real money has moved to a bank account.',
                  ),
                  if (widget.campaign.readinessState == 'cancelled') ...[
                    const SizedBox(height: 12),
                    Text(
                      'Campaign cancelled · test refund review due for ${money.format(widget.campaign.sponsoredAmount)} in verified sponsorships.',
                      style: const TextStyle(color: FieldnoteColors.danger),
                    ),
                  ],
                  const SizedBox(height: 22),
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
                          money.format(widget.campaign.sponsoredAmount),
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
                                _loading ||
                                    _simulating ||
                                    widget.campaign.readinessState !=
                                        'confirmed'
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
                        if (widget.campaign.readinessState != 'confirmed') ...[
                          const SizedBox(height: 8),
                          const Text(
                            'Confirm the event before recording a simulated creator credit.',
                          ),
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
                        const Text('Creator test account · in-app ledger only'),
                        const SizedBox(height: 8),
                        const Text(
                          'Tap Simulate after a verified Razorpay test checkout. Each checkout is credited once in this app’s test ledger. No Razorpay Route transfer or bank deposit occurs.',
                        ),
                      ],
                    ),
                  ),
                  if (_loading)
                    const Center(child: CircularProgressIndicator()),
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
                              padding: const EdgeInsets.symmetric(vertical: 7),
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
    );
  }

  Widget _row(String label, String value) => Row(
    children: [
      Expanded(child: Text(label)),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
    ],
  );
}
