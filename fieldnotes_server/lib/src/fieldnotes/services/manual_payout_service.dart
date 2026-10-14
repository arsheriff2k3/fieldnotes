import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart';
import 'campaign_events_service.dart';
import 'fieldnote_config.dart';
import 'razorpay_payment_service.dart';

/// Full-balance requests reserve their source sponsorships, including fees.
/// Bank transfers are performed by operations outside this application.
class ManualPayoutService {
  const ManualPayoutService();

  static const reserving = {'requested', 'processing', 'paid'};
  static const _events = CampaignEventsService();

  static bool liveMode(Session session) =>
      RazorpayCredentials.fromSession(session)?.keyId.startsWith('rzp_live_') ??
      false;

  static Never fail(String code, String message) =>
      throw FieldnoteException(code: code, message: message);

  static String reference(String value, String label) {
    final result = value.trim();
    if (result.length < 3 ||
        result.length > 120 ||
        result.contains(RegExp(r'[\x00-\x1f]'))) {
      fail('invalid_payout_reference', '$label must be 3–120 characters.');
    }
    return result;
  }

  static void requireOperator(UuidValue actor) {
    if (!FieldnoteConfig.isPayoutOperator(actor.uuid)) {
      fail(
        'payout_operator_required',
        'This action is restricted to payout operations.',
      );
    }
  }

  Future<Campaign> _campaign(
    Session session,
    int id,
    Transaction transaction,
  ) async {
    final campaign = await Campaign.db.findById(
      session,
      id,
      transaction: transaction,
      lockMode: LockMode.forUpdate,
    );
    if (campaign == null) fail('campaign_not_found', 'Campaign not found.');
    return campaign;
  }

  Future<List<Sponsorship>> _eligible(
    Session session,
    int campaignId,
    Transaction transaction,
  ) async {
    final payments = await Sponsorship.db.find(
      session,
      where: (t) =>
          t.campaignId.equals(campaignId) &
          t.paymentStatus.equals('verified') &
          t.paymentProvider.equals('razorpay') &
          t.paymentTestMode.equals(false),
      transaction: transaction,
    );
    final refunds = await TestRefund.db.find(
      session,
      where: (t) => t.campaignId.equals(campaignId),
      transaction: transaction,
    );
    final refunded = refunds.map((r) => r.sponsorshipId).toSet();
    final simulations = await TestPayout.db.find(
      session,
      where: (t) => t.campaignId.equals(campaignId),
      transaction: transaction,
    );
    final simulated = simulations.map((r) => r.sponsorshipId).toSet();
    return payments
        .where(
          (p) =>
              p.providerPaymentId != null &&
              p.verifiedAt != null &&
              p.amountPaise > 0 &&
              !refunded.contains(p.id) &&
              !simulated.contains(p.id),
        )
        .toList();
  }

  Future<ManualPayoutSummary> _summary(
    Session session,
    Campaign campaign,
    Transaction transaction,
  ) async {
    final requests = await ManualPayoutRequest.db.find(
      session,
      where: (t) => t.campaignId.equals(campaign.id!),
      orderBy: (t) => t.requestedAt.desc(),
      transaction: transaction,
    );
    final payments = await _eligible(session, campaign.id!, transaction);
    final used = requests
        .where((r) => reserving.contains(r.status))
        .expand((r) => r.sponsorshipIds)
        .toSet();
    final eligible = payments.fold<int>(0, (sum, p) => sum + p.amountPaise);
    final available = payments
        .where((p) => !used.contains(p.id))
        .fold<int>(0, (sum, p) => sum + p.amountPaise);
    return ManualPayoutSummary(
      campaignId: campaign.id!,
      liveMode: liveMode(session),
      completed: campaign.status == CampaignStatus.completed,
      eligiblePaise: eligible,
      availablePaise: campaign.status == CampaignStatus.completed
          ? available
          : 0,
      reservedPaise: requests
          .where((r) => {'requested', 'processing'}.contains(r.status))
          .fold<int>(0, (sum, r) => sum + r.grossAmountPaise),
      paidPaise: requests
          .where((r) => r.status == 'paid')
          .fold<int>(0, (sum, r) => sum + r.amountPaise),
      requests: requests,
    );
  }

  Future<ManualPayoutSummary> summary(
    Session session,
    UuidValue creator,
    int campaignId,
  ) => session.db.transaction((transaction) async {
    final campaign = await _campaign(session, campaignId, transaction);
    if (campaign.createdBy != creator) {
      fail(
        'creator_required',
        'Only the campaign creator can view payout requests.',
      );
    }
    return _summary(session, campaign, transaction);
  });

  Future<ManualPayoutRequest> request(
    Session session,
    UuidValue creator,
    int campaignId,
    String clientRequestId,
  ) async {
    try {
      UuidValue.withValidation(clientRequestId);
    } on FormatException {
      fail('invalid_request_id', 'Use a valid request identifier.');
    }
    return session.db.transaction((transaction) async {
      final campaign = await _campaign(session, campaignId, transaction);
      if (campaign.createdBy != creator) {
        fail(
          'creator_required',
          'Only the campaign creator can request a payout.',
        );
      }
      final replay = await ManualPayoutRequest.db.findFirstRow(
        session,
        where: (t) =>
            t.creatorAuthUserId.equals(creator) &
            t.clientRequestId.equals(clientRequestId),
        transaction: transaction,
      );
      if (replay != null) {
        if (replay.campaignId != campaignId) {
          fail(
            'payout_request_conflict',
            'This request identifier was used for another campaign.',
          );
        }
        return replay;
      }
      if (!liveMode(session)) {
        fail(
          'payout_live_mode_required',
          'Real payout requests require configured Razorpay Live keys. Use the test simulation in Test Mode.',
        );
      }
      if (campaign.status != CampaignStatus.completed) {
        fail(
          'campaign_not_completed',
          'Payouts are available after campaign completion.',
        );
      }
      final state = await _summary(session, campaign, transaction);
      if (state.availablePaise <= 0) {
        fail(
          'payout_no_available_funds',
          'No eligible live funds are available to request.',
        );
      }
      final used = state.requests
          .where((r) => reserving.contains(r.status))
          .expand((r) => r.sponsorshipIds)
          .toSet();
      final payments = (await _eligible(
        session,
        campaignId,
        transaction,
      )).where((p) => !used.contains(p.id)).toList();
      final result = await ManualPayoutRequest.db.insertRow(
        session,
        ManualPayoutRequest(
          campaignId: campaignId,
          creatorAuthUserId: creator,
          clientRequestId: clientRequestId,
          sponsorshipIds: payments.map((p) => p.id!).toList(),
          grossAmountPaise: state.availablePaise,
          amountPaise: state.availablePaise,
        ),
        transaction: transaction,
      );
      await _audit(session, creator, result, 'requested', transaction);
      return result;
    });
  }

  Future<List<ManualPayoutRequest>> queue(
    Session session,
    UuidValue actor, {
    int limit = 50,
    int offset = 0,
  }) async {
    requireOperator(actor);
    if (limit < 1 || limit > 100 || offset < 0) {
      fail('invalid_input', 'Invalid payout page.');
    }
    return ManualPayoutRequest.db.find(
      session,
      orderBy: (t) => t.requestedAt.desc(),
      limit: limit,
      offset: offset,
    );
  }

  Future<ManualPayoutRequest> review(
    Session session,
    UuidValue actor,
    int requestId,
    bool approve,
    int deductionPaise,
    String settlementReference,
    String payeeVerificationReference,
    String note,
  ) async {
    requireOperator(actor);
    final cleanNote = note.trim();
    if (cleanNote.length < 3 || cleanNote.length > 500) {
      fail('invalid_input', 'Provide a review note of 3–500 characters.');
    }
    final settlement = approve
        ? reference(settlementReference, 'Settlement reference')
        : null;
    final payee = approve
        ? reference(payeeVerificationReference, 'Payee verification reference')
        : null;
    return _update(session, requestId, (request, transaction) async {
      if (request.status != 'requested') {
        fail(
          'payout_invalid_state',
          'Only a requested payout can be reviewed.',
        );
      }
      if (deductionPaise < 0 || deductionPaise >= request.grossAmountPaise) {
        fail(
          'invalid_amount',
          'Deductions must be less than the requested amount.',
        );
      }
      if (approve) {
        final campaign = await Campaign.db.findById(
          session,
          request.campaignId,
          transaction: transaction,
        );
        if (campaign?.status != CampaignStatus.completed) {
          fail('campaign_not_completed', 'The campaign is not completed.');
        }
        final eligible = await _eligible(
          session,
          request.campaignId,
          transaction,
        );
        final source = eligible
            .where((p) => request.sponsorshipIds.contains(p.id))
            .toList();
        if (source.length != request.sponsorshipIds.length ||
            source.fold<int>(0, (sum, p) => sum + p.amountPaise) !=
                request.grossAmountPaise) {
          fail(
            'payout_funds_changed',
            'Source payments changed or have refunds. Reject this request and recheck funding.',
          );
        }
      }
      request
        ..status = approve ? 'processing' : 'rejected'
        ..deductionPaise = approve ? deductionPaise : 0
        ..amountPaise =
            request.grossAmountPaise - (approve ? deductionPaise : 0)
        ..settlementReference = settlement
        ..payeeVerificationReference = payee
        ..reviewNote = cleanNote
        ..reviewedByAuthUserId = actor
        ..reviewedAt = DateTime.now().toUtc();
      await _audit(session, actor, request, request.status, transaction);
    });
  }

  Future<ManualPayoutRequest> recordPaid(
    Session session,
    UuidValue actor,
    int requestId,
    String bankTransferReference,
  ) async {
    requireOperator(actor);
    final bankReference = reference(
      bankTransferReference,
      'Bank transfer reference',
    ).toUpperCase();
    try {
      return await _update(session, requestId, (request, transaction) async {
        if (request.status == 'paid' &&
            request.bankTransferReference == bankReference) {
          return;
        }
        if (request.status != 'processing') {
          fail(
            'payout_invalid_state',
            'Verify settlement and payee details before recording a completed bank transfer.',
          );
        }
        request
          ..status = 'paid'
          ..bankTransferReference = bankReference
          ..paidAt = DateTime.now().toUtc();
        await _audit(session, actor, request, 'paid', transaction);
      });
    } on DatabaseUniqueViolationException {
      fail(
        'payout_transfer_reference_used',
        'That bank transfer reference is already recorded.',
      );
    }
  }

  Future<ManualPayoutRequest> _update(
    Session session,
    int requestId,
    Future<void> Function(ManualPayoutRequest, Transaction) change,
  ) async {
    final snapshot = await ManualPayoutRequest.db.findById(session, requestId);
    if (snapshot == null) fail('payout_not_found', 'Payout request not found.');
    return session.db.transaction((transaction) async {
      // Same lock order as creator requests: campaign first, request second.
      await _campaign(session, snapshot.campaignId, transaction);
      final request = await ManualPayoutRequest.db.findById(
        session,
        requestId,
        transaction: transaction,
        lockMode: LockMode.forUpdate,
      );
      if (request == null) {
        fail('payout_not_found', 'Payout request not found.');
      }
      await change(request, transaction);
      request.updatedAt = DateTime.now().toUtc();
      return ManualPayoutRequest.db.updateRow(
        session,
        request,
        transaction: transaction,
      );
    });
  }

  Future<void> _audit(
    Session session,
    UuidValue actor,
    ManualPayoutRequest request,
    String outcome,
    Transaction transaction,
  ) async {
    await _events.audit(
      session,
      actor: actor,
      event: 'manualPayout',
      entityType: 'payoutRequest',
      entityId: '${request.id}',
      outcome: outcome,
      riskLevel: 'info',
      detail:
          'Campaign ${request.campaignId}; gross ${request.grossAmountPaise} paise; net ${request.amountPaise} paise. No bank transfer is initiated by this app.',
      transaction: transaction,
    );
  }
}
