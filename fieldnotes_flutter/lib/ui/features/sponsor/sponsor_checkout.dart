import 'dart:async';

import 'package:fieldnotes_client/fieldnotes_client.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/services/razorpay_checkout_service.dart';
import '../../../l10n/l10n.dart';
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
  final l10n = context.l10n;
  final localeTag = context.localeTag;
  String money(int paise) => formatPaise(paise, localeTag: localeTag);
  final remainingPaise = campaignRemainingPaise(campaign);
  if (remainingPaise <= 0) {
    showFieldnoteNotice(
      context,
      title: l10n.sponsorCheckoutFullyFundedTitle,
      message: l10n.sponsorCheckoutFullyFundedMessage,
    );
    return false;
  }
  if (campaignIsClosed(campaignPhase(campaign))) {
    showFieldnoteNotice(
      context,
      title: l10n.sponsorCheckoutClosedTitle,
      message: l10n.sponsorCheckoutClosedMessage,
      kind: FieldnoteNoticeKind.error,
    );
    return false;
  }
  // Test keys are the only case where payout simulation is available, so the
  // same flag tells the banner whether this checkout moves real money. Fall
  // back to the neutral wording rather than claiming test mode.
  var testMode = false;
  try {
    testMode = await viewModel.payoutSimulationAvailable();
  } catch (_) {}
  if (!context.mounted) return false;
  const portions = [0.25, 0.5, 0.75, 1.0];
  final amounts = sponsorshipPortionsPaise(remainingPaise, portions);
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
                      l10n.sponsorCheckoutTitle,
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
                          color: context.fieldnoteColors.acid.withValues(
                            alpha: .24,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.verified_user_outlined),
                            const SizedBox(width: 9),
                            Expanded(
                              child: Text(
                                testMode
                                    ? l10n.sponsorCheckoutBanner
                                    : l10n.sponsorCheckoutBannerLive,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        l10n.sponsorCheckoutRemaining(money(remainingPaise)),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.sponsorCheckoutChooseAmount,
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
                                                ? context.fieldnoteColors.moss
                                                      .withValues(alpha: .18)
                                                : null,
                                            side: BorderSide(
                                              color: selected
                                                  ? context
                                                        .fieldnoteColors
                                                        .forest
                                                  : context.fieldnoteColors.moss
                                                        .withValues(alpha: .4),
                                              width: selected ? 2 : 1,
                                            ),
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                NumberFormat.percentPattern(
                                                  localeTag,
                                                ).format(portion),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                              Text(
                                                money(value),
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
                        decoration: InputDecoration(
                          labelText: l10n.sponsorCheckoutMessageLabel,
                          hintText: l10n.sponsorCheckoutMessageHint,
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
                                    // Stored server-side: kept in English.
                                    await viewModel.repository
                                        .recordRazorpayFailure(
                                          order.sponsorshipId,
                                          paymentErrorMessage(error),
                                        );
                                  } catch (_) {}
                                }
                                if (dialogContext.mounted) {
                                  final reason = paymentErrorMessage(
                                    error,
                                    l10n: l10n,
                                  );
                                  showFieldnoteNotice(
                                    dialogContext,
                                    title: checkoutReturned
                                        ? l10n.sponsorCheckoutNeedsReviewTitle
                                        : l10n.sponsorCheckoutUnsuccessfulTitle,
                                    message: checkoutReturned
                                        ? l10n.sponsorCheckoutNeedsReviewMessage(
                                            reason,
                                          )
                                        : reason,
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
                            ? l10n.sponsorCheckoutProcessing
                            : l10n.sponsorCheckoutPay(money(amount)),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: saving
                          ? null
                          : () => Navigator.pop(dialogContext, false),
                      child: Text(l10n.sponsorCheckoutCancel),
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
          title: l10n.sponsorCheckoutSuccessTitle,
          message: l10n.sponsorCheckoutSuccessMessage(
            money(amount),
            campaign.name,
          ),
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

/// Splits [remainingPaise] into contribution options in whole paise. The
/// last portion (1.0) is always exactly the remaining balance.
List<int> sponsorshipPortionsPaise(int remainingPaise, List<double> portions) =>
    [
      for (final portion in portions)
        portion >= 1 ? remainingPaise : (remainingPaise * portion).round(),
    ];

/// The message for a failed checkout. Without [l10n] it is English (used
/// for the failure reason stored on the server).
String paymentErrorMessage(Object error, {AppLocalizations? l10n}) {
  if (error is RazorpayCheckoutException &&
      error.message.trim().isNotEmpty &&
      error.message.trim().toLowerCase() != 'undefined') {
    return error.message;
  }
  final strings = l10n ?? lookupAppLocalizations(const Locale('en'));
  return sponsorErrorMessage(
    error,
    l10n: strings,
    fallback: strings.sponsorCheckoutNotCompleted,
  );
}
