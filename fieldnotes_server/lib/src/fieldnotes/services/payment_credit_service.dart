import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart';
import 'money.dart';
import 'refund_service.dart';

typedef PaymentCreditResult = ({
  Sponsorship sponsorship,
  bool uncredited,
  bool alreadyVerified,
});

/// Records a signature-verified payment without letting concurrent orders
/// credit more than a campaign's funding goal.
class PaymentCreditService {
  const PaymentCreditService();

  Future<Sponsorship> markFailed(
    Session session, {
    required int sponsorshipId,
    required UuidValue sponsorAuthUserId,
    required String status,
    String? failureReason,
  }) => session.db.transaction((transaction) async {
    final sponsorship = await Sponsorship.db.findById(
      session,
      sponsorshipId,
      transaction: transaction,
      lockMode: LockMode.forUpdate,
    );
    if (sponsorship == null ||
        sponsorship.sponsorAuthUserId != sponsorAuthUserId) {
      throw FieldnoteException(
        message: 'Sponsorship payment attempt not found.',
        code: 'payment_not_found',
      );
    }
    if (sponsorship.paymentStatus == 'verified' ||
        sponsorship.paymentStatus == 'verified_uncredited') {
      return sponsorship;
    }
    sponsorship.paymentStatus = status;
    if (failureReason != null) {
      sponsorship.failureReason = failureReason.length > 240
          ? failureReason.substring(0, 240)
          : failureReason;
    }
    sponsorship.updatedAt = DateTime.now().toUtc();
    return Sponsorship.db.updateRow(
      session,
      sponsorship,
      transaction: transaction,
    );
  });

  Future<PaymentCreditResult> credit(
    Session session, {
    required int sponsorshipId,
    required int campaignId,
    required UuidValue sponsorAuthUserId,
    required String orderId,
    required String paymentId,
  }) => session.db.transaction((transaction) async {
    // Every credit for this campaign takes the same row lock first.
    final campaign = await Campaign.db.findById(
      session,
      campaignId,
      transaction: transaction,
      lockMode: LockMode.forUpdate,
    );
    final sponsorship = await Sponsorship.db.findById(
      session,
      sponsorshipId,
      transaction: transaction,
      lockMode: LockMode.forUpdate,
    );
    if (campaign == null ||
        sponsorship == null ||
        sponsorship.campaignId != campaignId ||
        sponsorship.sponsorAuthUserId != sponsorAuthUserId ||
        sponsorship.providerOrderId != orderId) {
      throw FieldnoteException(
        message: 'The Razorpay order does not match this sponsorship.',
        code: 'payment_order_mismatch',
      );
    }
    if (sponsorship.paymentStatus == 'verified') {
      return (
        sponsorship: sponsorship,
        uncredited: false,
        alreadyVerified: true,
      );
    }
    if (sponsorship.paymentStatus == 'verified_uncredited') {
      return (
        sponsorship: sponsorship,
        uncredited: true,
        alreadyVerified: true,
      );
    }

    sponsorship.providerPaymentId = paymentId;
    sponsorship.verifiedAt = DateTime.now().toUtc();
    sponsorship.updatedAt = sponsorship.verifiedAt;
    if (campaign.status != CampaignStatus.active ||
        const {'cancelled', 'expired'}.contains(campaign.readinessState) ||
        Money.toPaise(campaign.sponsoredAmount) +
                Money.toPaise(sponsorship.amount) >
            Money.toPaise(campaign.fundingGoal)) {
      sponsorship.paymentStatus = 'verified_uncredited';
      final updated = await Sponsorship.db.updateRow(
        session,
        sponsorship,
        transaction: transaction,
      );
      // The money was captured but cannot fund the campaign: refund it.
      await const RefundService().queueForSponsorship(
        session,
        sponsorship: updated,
        reason: RefundReason.uncredited,
        transaction: transaction,
      );
      return (
        sponsorship: updated,
        uncredited: true,
        alreadyVerified: false,
      );
    }

    sponsorship.paymentStatus = 'verified';
    final updated = await Sponsorship.db.updateRow(
      session,
      sponsorship,
      transaction: transaction,
    );
    campaign.sponsoredAmount = Money.add(
      campaign.sponsoredAmount,
      sponsorship.amount,
    );
    campaign.updatedAt = DateTime.now().toUtc();
    await Campaign.db.updateRow(session, campaign, transaction: transaction);
    return (
      sponsorship: updated,
      uncredited: false,
      alreadyVerified: false,
    );
  });
}
