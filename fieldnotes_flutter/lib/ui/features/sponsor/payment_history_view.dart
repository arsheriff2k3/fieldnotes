import 'package:fieldnotes_client/fieldnotes_client.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/fieldnote_theme.dart';
import '../../core/widgets.dart';
import '../shell/fieldnote_view_model.dart';
import 'sponsor_formatting.dart';

/// Every payment attempt the sponsor made, including failed, uncredited and
/// refunded ones (S-2).
class PaymentHistoryView extends StatefulWidget {
  const PaymentHistoryView({super.key, required this.viewModel});

  final FieldnoteViewModel viewModel;

  @override
  State<PaymentHistoryView> createState() => _PaymentHistoryViewState();
}

class _PaymentHistoryViewState extends State<PaymentHistoryView> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    await widget.viewModel.loadPaymentHistory();
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment history')),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          final entries = widget.viewModel.paymentHistory;
          final error = widget.viewModel.lastError;
          return RefreshIndicator(
            onRefresh: _load,
            child: FieldnotePageList(
              top: 16,
              maxWidth: 760,
              children: [
                Text(
                  'Razorpay Test Mode. Payments are credited only after the '
                  'server verifies them; anything that could not be credited '
                  'is refunded automatically.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 14),
                if (_loading && entries.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (entries.isEmpty && error != null)
                  SurfaceCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(error),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: () {
                            widget.viewModel.clearLastError();
                            _load();
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Try again'),
                        ),
                      ],
                    ),
                  )
                else if (entries.isEmpty)
                  const EmptyPanel(
                    icon: Icons.receipt_long_outlined,
                    title: 'No payments yet',
                    message: 'Sponsor a campaign and it will be listed here.',
                  )
                else
                  for (final entry in entries) ...[
                    PaymentHistoryTile(entry: entry),
                    const SizedBox(height: 10),
                  ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class PaymentHistoryTile extends StatelessWidget {
  const PaymentHistoryTile({super.key, required this.entry});

  final SponsorshipHistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    final sponsorship = entry.sponsorship;
    final refund = entry.refund;
    final style = paymentStatusStyle(sponsorship.paymentStatus, refund: refund);
    final date = DateFormat(
      'd MMM yyyy · h:mm a',
    ).format((sponsorship.verifiedAt ?? sponsorship.createdAt).toLocal());
    final failure = sponsorship.failureReason?.trim();
    return SurfaceCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  entry.campaignName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                formatRupees(sponsorship.amount),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(date, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              StatusPill(
                label: style.label,
                color: style.color,
                icon: style.icon,
              ),
              if (refund != null)
                StatusPill(
                  label: refundReasonLabel(refund.reason),
                  color: FieldnoteColors.moss,
                  icon: Icons.info_outline,
                ),
            ],
          ),
          if (refund != null) ...[
            const SizedBox(height: 8),
            Text(
              switch (refund.status) {
                'processed' =>
                  '${formatRupees(refund.amount)} refunded'
                      '${refund.processedAt == null ? '' : ' on ${DateFormat('d MMM yyyy').format(refund.processedAt!.toLocal())}'}.',
                'failed' =>
                  'The refund of ${formatRupees(refund.amount)} failed. '
                      'FieldNote will contact you to resolve it.',
                _ =>
                  'A refund of ${formatRupees(refund.amount)} is on its way '
                      'to the original payment method.',
              },
            ),
          ] else if (sponsorship.paymentStatus == 'verified_uncredited') ...[
            const SizedBox(height: 8),
            const Text(
              'The payment was verified but could not be credited (for '
              'example the campaign closed or was already fully funded). It '
              'will be refunded automatically.',
            ),
          ] else if (failure != null && failure.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              failure,
              style: const TextStyle(color: FieldnoteColors.danger),
            ),
          ] else if (sponsorship.paymentStatus == 'created') ...[
            const SizedBox(height: 8),
            const Text(
              'Waiting for Razorpay to confirm this payment. It updates '
              'automatically.',
            ),
          ],
        ],
      ),
    );
  }
}
