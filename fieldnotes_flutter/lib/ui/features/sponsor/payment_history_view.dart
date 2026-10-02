import 'package:fieldnotes_client/fieldnotes_client.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../l10n/l10n.dart';
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
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.sponsorPaymentHistoryTitle)),
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
                  l10n.sponsorPaymentHistoryIntro,
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
                          label: Text(l10n.commonTryAgain),
                        ),
                      ],
                    ),
                  )
                else if (entries.isEmpty)
                  EmptyPanel(
                    icon: Icons.receipt_long_outlined,
                    title: l10n.sponsorPaymentHistoryEmptyTitle,
                    message: l10n.sponsorPaymentHistoryEmptyMessage,
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
    final l10n = context.l10n;
    final localeTag = context.localeTag;
    String money(int paise) => formatPaise(paise, localeTag: localeTag);
    final style = paymentStatusStyle(
      sponsorship.paymentStatus,
      refund: refund,
      l10n: l10n,
    );
    final date =
        DateFormat.yMMMd(
          localeTag,
        ).add_jm().format(
          (sponsorship.verifiedAt ?? sponsorship.createdAt).toLocal(),
        );
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
                money(sponsorshipPaise(sponsorship)),
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
                  label: refundReasonLabel(refund.reason, l10n: l10n),
                  color: context.fieldnoteColors.moss,
                  icon: Icons.info_outline,
                ),
            ],
          ),
          if (refund != null) ...[
            const SizedBox(height: 8),
            Text(
              switch (refund.status) {
                'processed' when refund.processedAt != null =>
                  l10n.sponsorPaymentRefundedOn(
                    money(refundPaise(refund)),
                    DateFormat.yMMMd(
                      localeTag,
                    ).format(refund.processedAt!.toLocal()),
                  ),
                'processed' => l10n.sponsorPaymentRefunded(
                  money(refundPaise(refund)),
                ),
                'failed' => l10n.sponsorPaymentRefundFailedDetail(
                  money(refundPaise(refund)),
                ),
                _ => l10n.sponsorPaymentRefundOnItsWay(
                  money(refundPaise(refund)),
                ),
              },
            ),
          ] else if (sponsorship.paymentStatus == 'verified_uncredited') ...[
            const SizedBox(height: 8),
            Text(l10n.sponsorPaymentUncreditedDetail),
          ] else if (failure != null && failure.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              failure,
              style: TextStyle(color: context.fieldnoteColors.danger),
            ),
          ] else if (sponsorship.paymentStatus == 'created') ...[
            const SizedBox(height: 8),
            Text(l10n.sponsorPaymentAwaitingConfirmation),
          ],
        ],
      ),
    );
  }
}
