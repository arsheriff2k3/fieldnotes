import 'dart:async';

import 'package:fieldnotes_client/fieldnotes_client.dart';
import 'package:flutter/material.dart';

import '../../../data/services/razorpay_checkout_service.dart';
import '../../core/error_messages.dart';
import '../../core/fieldnote_theme.dart';
import '../../core/widgets.dart';
import '../shell/fieldnote_view_model.dart';
import 'sponsor_formatting.dart';

/// Opens the sponsor contribution dialog and Razorpay checkout for
/// [campaign]. Returns true when a payment was verified.
///
/// The dialog cannot be dismissed (barrier, back button or Cancel) while an
/// order is being created, the checkout is open, or the payment is being
/// verified (S-1). Sponsor data is always refreshed afterwards so the funding
/// figures and payment history reflect whatever the server recorded.
Future<bool> openSponsorCheckout(
  BuildContext context,
  FieldnoteViewModel viewModel,
  Campaign campaign,
) async {
  final remainingAmount = (campaign.fundingGoal - campaign.sponsoredAmount)
      .clamp(0, double.infinity)
      .toDouble();
  if (remainingAmount <= 0) {
    showFieldnoteNotice(
      context,
      title: 'Campaign fully funded',
      message: 'This campaign has already reached its funding goal.',
    );
    return false;
  }
  if (campaignIsClosed(campaignPhase(campaign))) {
    showFieldnoteNotice(
      context,
      title: 'Campaign closed',
      message: 'This campaign is no longer accepting sponsorships.',
      kind: FieldnoteNoticeKind.error,
    );
    return false;
  }
  const portions = [0.25, 0.5, 0.75, 1.0];
  final amounts = portions
      .map((portion) => (remainingAmount * portion * 100).round() / 100)
      .toList(growable: false);
  var selectedPortion = portions.first;
  var amount = amounts.first;
  final note = TextEditingController();
  final checkout = RazorpayCheckoutService();
  var saving = false;
  var paymentCompleted = false;
  var attempted = false;
  try {
    final verified =
        await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => StatefulBuilder(
            builder: (context, setDialogState) => PopScope(
              canPop: !saving,
              child: AlertDialog(
                scrollable: true,
                insetPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 24,
                ),
                titlePadding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
                contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                actionsPadding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sponsor campaign',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      campaign.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                content: SizedBox(
                  width: 480,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: FieldnoteColors.acid.withValues(alpha: .24),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.verified_user_outlined),
                            SizedBox(width: 9),
                            Expanded(
                              child: Text(
                                'Razorpay test checkout. Payment is credited after verification.',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '${formatRupees(remainingAmount)} remaining',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Choose how much to contribute',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 12),
                      Column(
                        children: [
                          for (var row = 0; row < 2; row++) ...[
                            Row(
                              children: [
                                for (var column = 0; column < 2; column++) ...[
                                  if (column > 0) const SizedBox(width: 12),
                                  Expanded(
                                    child: Builder(
                                      builder: (context) {
                                        final index = row * 2 + column;
                                        final portion = portions[index];
                                        final value = amounts[index];
                                        final selected =
                                            selectedPortion == portion;
                                        return OutlinedButton(
                                          onPressed: saving
                                              ? null
                                              : () => setDialogState(() {
                                                  selectedPortion = portion;
                                                  amount = value;
                                                }),
                                          style: OutlinedButton.styleFrom(
                                            minimumSize: const Size(0, 72),
                                            padding: const EdgeInsets.all(10),
                                            backgroundColor: selected
                                                ? FieldnoteColors.moss
                                                      .withValues(alpha: .18)
                                                : null,
                                            side: BorderSide(
                                              color: selected
                                                  ? FieldnoteColors.forest
                                                  : FieldnoteColors.moss
                                                        .withValues(alpha: .4),
                                              width: selected ? 2 : 1,
                                            ),
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                '${(portion * 100).round()}%',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                              Text(
                                                formatRupees(value),
                                                style: Theme.of(
                                                  context,
                                                ).textTheme.labelSmall,
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            if (row == 0) const SizedBox(height: 12),
                          ],
                        ],
                      ),
                      const SizedBox(height: 20),
                      FieldnoteTextField(
                        controller: note,
                        maxLines: 2,
                        maxLength: 500,
                        enabled: !saving,
                        decoration: const InputDecoration(
                          labelText: 'Message (optional)',
                          hintText: 'Why this campaign matters to you',
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: saving
                          ? null
                          : () async {
                              setDialogState(() => saving = true);
                              attempted = true;
                              RazorpayCheckoutOrder? createdOrder;
                              var checkoutReturned = false;
                              try {
                                final order = await viewModel
                                    .createPaymentOrder(
                                      campaign,
                                      amount,
                                      note.text,
                                    );
                                createdOrder = order;
                                final result = await checkout.open(order);
                                checkoutReturned = true;
                                await viewModel.verifyPayment(
                                  order,
                                  returnedOrderId: result.orderId,
                                  paymentId: result.paymentId,
                                  signature: result.signature,
                                );
                                paymentCompleted = true;
                                if (dialogContext.mounted) {
                                  Navigator.pop(dialogContext, true);
                                }
                              } catch (error) {
                                final order = createdOrder;
                                if (order != null && !checkoutReturned) {
                                  try {
                                    await viewModel.repository
                                        .recordRazorpayFailure(
                                          order.sponsorshipId,
                                          paymentErrorMessage(error),
                                        );
                                  } catch (_) {}
                                }
                                if (dialogContext.mounted) {
                                  showFieldnoteNotice(
                                    dialogContext,
                                    title: checkoutReturned
                                        ? 'Payment needs review'
                                        : 'Payment unsuccessful',
                                    message: checkoutReturned
                                        ? '${paymentErrorMessage(error)} '
                                              'If money left your account, it '
                                              'is credited or refunded '
                                              'automatically. See Payment '
                                              'history.'
                                        : paymentErrorMessage(error),
                                    kind: FieldnoteNoticeKind.error,
                                  );
                                }
                              } finally {
                                if (!paymentCompleted &&
                                    dialogContext.mounted) {
                                  setDialogState(() => saving = false);
                                }
                              }
                            },
                      icon: const Icon(Icons.lock_outline),
                      label: Text(
                        saving
                            ? 'Processing payment…'
                            : 'Pay ${formatRupees(amount)}',
                      ),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: saving
                          ? null
                          : () => Navigator.pop(dialogContext, false),
                      child: const Text('Cancel'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ) ??
        false;
    if (verified || paymentCompleted) {
      await viewModel.refresh();
      if (context.mounted) {
        showFieldnoteNotice(
          context,
          title: 'Payment successful',
          message: '${formatRupees(amount)} was added to ${campaign.name}.',
          kind: FieldnoteNoticeKind.success,
        );
      }
      return true;
    }
    if (attempted) await viewModel.refresh();
    return false;
  } finally {
    checkout.dispose();
    note.dispose();
  }
}

String paymentErrorMessage(Object error) {
  if (error is RazorpayCheckoutException &&
      error.message.trim().isNotEmpty &&
      error.message.trim().toLowerCase() != 'undefined') {
    return error.message;
  }
  return userMessageFor(
    error,
    fallback: 'The Razorpay test payment was not completed.',
  );
}
