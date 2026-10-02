import 'dart:math' as math;

import 'package:fieldnotes_client/fieldnotes_client.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../l10n/l10n.dart';
import '../../core/error_messages.dart';
import '../../core/fieldnote_theme.dart';

/// Client copies of the server's campaign bounds (`campaign_validation.dart`)
/// so a sponsor sees the problem before a round trip.
abstract final class CampaignLimits {
  static const minimumGoalPaise = 10000;
  static const maximumGoalPaise = 100000000;
  static const minimumDurationMinutes = 15;
  static const maximumDurationMinutes = 1440;
  static const minimumCapacity = 1;
  static const maximumCapacity = 500;
  static const titleMin = 3;
  static const titleMax = 120;
  static const descriptionMin = 10;
  static const descriptionMax = 4000;
  static const scopeNoteMin = 20;
  static const scopeNoteMax = 4000;
  static const listMaxItems = 20;
  static const listItemMaxLength = 200;
  static const postTitleMin = 3;
  static const postTitleMax = 120;
  static const postBodyMin = 3;
  static const postBodyMax = 2000;
  static const reviewNoteMin = 5;
  static const reviewNoteMax = 1000;
}

/// English strings for helpers called without a [BuildContext] (tests and
/// pure functions); views pass `context.l10n`.
AppLocalizations get _english => lookupAppLocalizations(const Locale('en'));

// ---------------------------------------------------------------------------
// Money. Integer paise are the source of truth (server `money.dart`). Rupee
// doubles are only read as a fallback for rows written before paise existed,
// and only ever for display; never do arithmetic on them.

/// Paise for a legacy rupee value.
int rupeesToPaise(double rupees) =>
    rupees.isFinite ? (rupees * 100).round() : 0;

/// [paise] when set, else the legacy rupee [fallbackRupees] in paise.
int paiseOr(int? paise, double? fallbackRupees) {
  if (paise != null && paise != 0) return paise;
  return fallbackRupees == null ? 0 : rupeesToPaise(fallbackRupees);
}

int campaignGoalPaise(Campaign campaign) =>
    paiseOr(campaign.fundingGoalPaise, campaign.fundingGoal);

/// Funded amount net of refunds.
int campaignSponsoredPaise(Campaign campaign) =>
    paiseOr(campaign.sponsoredAmountPaise, campaign.sponsoredAmount);

int campaignRefundedPaise(Campaign campaign) => campaign.refundedAmountPaise;

/// What is still needed to reach the goal (never negative).
int campaignRemainingPaise(Campaign campaign) => math.max(
  0,
  campaignGoalPaise(campaign) - campaignSponsoredPaise(campaign),
);

/// Funded share of the goal in 0..1.
double campaignFundingProgress(Campaign campaign) => fundingProgress(
  campaignSponsoredPaise(campaign),
  campaignGoalPaise(campaign),
);

double fundingProgress(int fundedPaise, int goalPaise) =>
    goalPaise <= 0 ? 0 : (fundedPaise / goalPaise).clamp(0.0, 1.0).toDouble();

int proposalGoalPaise(CampaignProposal proposal) =>
    paiseOr(proposal.fundingGoalPaise, proposal.fundingGoal);

int sponsorshipPaise(Sponsorship sponsorship) =>
    paiseOr(sponsorship.amountPaise, sponsorship.amount);

int refundPaise(TestRefund refund) =>
    paiseOr(refund.amountPaise, refund.amount);

int payoutPaise(TestPayout payout) =>
    paiseOr(payout.amountPaise, payout.amount);

int impactSponsoredPaise(ImpactSummary impact) =>
    paiseOr(impact.sponsorshipTotalPaise, impact.sponsorshipTotal);

int impactGoalPaise(ImpactSummary impact) =>
    paiseOr(impact.fundingGoalPaise, impact.fundingGoal);

/// Parses a rupee amount typed by a person ("25,000", "25 000",
/// "₹25000.50", "Rs. 500") into exact integer paise, without going through a
/// double. Returns null for anything that is not a plain non-negative number
/// with at most two decimals.
int? parseRupeesToPaise(String input) {
  final cleaned = input
      .replaceAll(RegExp(r'[\s,_₹]'), '')
      .replaceFirst(RegExp(r'^(rs\.?|inr)', caseSensitive: false), '');
  final match = RegExp(r'^(\d+)(?:\.(\d{1,2}))?$').firstMatch(cleaned);
  if (match == null) return null;
  final whole = match.group(1)!;
  // Anything this long is far beyond the goal bounds; avoid int overflow.
  if (whole.length > 15) return null;
  final fraction = (match.group(2) ?? '').padRight(2, '0');
  return int.parse(whole) * 100 + int.parse(fraction);
}

/// Parses a whole number that may contain grouping commas or spaces.
int? parseWholeNumber(String input) {
  final cleaned = input.replaceAll(RegExp(r'[\s,_]'), '');
  if (!RegExp(r'^\d+$').hasMatch(cleaned)) return null;
  return int.tryParse(cleaned);
}

/// The `intl` locale for rupee amounts: Indian digit grouping
/// (12,34,567) in English, Hindi and Tamil.
String moneyLocale(String? localeTag) {
  final language = (localeTag ?? 'en').split(RegExp('[-_]')).first;
  return switch (language) {
    'hi' => 'hi',
    'ta' => 'ta',
    _ => 'en_IN',
  };
}

/// "₹25,000" or "₹1,250.50", with Indian grouping in [localeTag].
String formatPaise(int paise, {String? localeTag}) {
  final whole = paise % 100 == 0;
  return NumberFormat.currency(
    locale: moneyLocale(localeTag),
    symbol: '₹',
    decimalDigits: whole ? 0 : 2,
  ).format(whole ? paise ~/ 100 : paise / 100);
}

/// Short form for cards: "₹25K", "₹2.5L" ("₹25 हज़ार" in Hindi).
String formatPaiseCompact(int paise, {String? localeTag}) =>
    NumberFormat.compactCurrency(
      locale: moneyLocale(localeTag),
      symbol: '₹',
      decimalDigits: paise % 100000 == 0 ? 0 : 1,
    ).format(paise / 100);

/// The amount as a plain number for an editable field ("25000",
/// "1250.50"), without grouping so it parses back exactly.
String paiseInputText(int paise) => paise % 100 == 0
    ? '${paise ~/ 100}'
    : '${paise ~/ 100}.${(paise % 100).toString().padLeft(2, '0')}';

String _goalRange(AppLocalizations l10n, String? localeTag) =>
    l10n.sponsorGoalRange(
      formatPaise(CampaignLimits.minimumGoalPaise, localeTag: localeTag),
      formatPaise(CampaignLimits.maximumGoalPaise, localeTag: localeTag),
    );

/// Field keys used by [validateCampaignForm].
abstract final class CampaignField {
  static const title = 'title';
  static const description = 'description';
  static const location = 'location';
  static const startsAt = 'startsAt';
  static const duration = 'duration';
  static const capacity = 'capacity';
  static const minimum = 'minimum';
  static const funding = 'funding';
  static const checklist = 'checklist';
  static const evidence = 'evidence';
  static const lists = 'lists';
}

/// Validates the campaign form against the same bounds the server enforces.
/// Returns one message per invalid field (empty when valid), in form order.
Map<String, String> validateCampaignForm({
  required String title,
  required String description,
  required String locationName,
  required DateTime startsAt,
  required String duration,
  required String capacity,
  required String minimum,
  required String funding,
  required List<String> checklist,
  required List<String> skills,
  required List<String> tags,
  required String evidence,
  DateTime? now,
  AppLocalizations? l10n,
  String? localeTag,
}) {
  final strings = l10n ?? _english;
  final errors = <String, String>{};
  final t = title.trim();
  final d = description.trim();
  if (t.length < CampaignLimits.titleMin ||
      t.length > CampaignLimits.titleMax) {
    errors[CampaignField.title] = strings.sponsorValidationTitle(
      CampaignLimits.titleMin,
      CampaignLimits.titleMax,
    );
  }
  if (d.length < CampaignLimits.descriptionMin ||
      d.length > CampaignLimits.descriptionMax) {
    errors[CampaignField.description] = strings.sponsorValidationDescription(
      CampaignLimits.descriptionMin,
      CampaignLimits.descriptionMax,
    );
  }
  if (locationName.trim().isEmpty) {
    errors[CampaignField.location] = strings.sponsorValidationLocation;
  }
  if (!startsAt.isAfter(now ?? DateTime.now())) {
    errors[CampaignField.startsAt] = strings.sponsorValidationStartsAt;
  }
  final minutes = parseWholeNumber(duration);
  if (minutes == null ||
      minutes < CampaignLimits.minimumDurationMinutes ||
      minutes > CampaignLimits.maximumDurationMinutes) {
    errors[CampaignField.duration] = strings.sponsorValidationDuration(
      CampaignLimits.minimumDurationMinutes,
      CampaignLimits.maximumDurationMinutes,
    );
  }
  final places = parseWholeNumber(capacity);
  if (places == null ||
      places < CampaignLimits.minimumCapacity ||
      places > CampaignLimits.maximumCapacity) {
    errors[CampaignField.capacity] = strings.sponsorValidationCapacity(
      CampaignLimits.minimumCapacity,
      CampaignLimits.maximumCapacity,
    );
  }
  final team = parseWholeNumber(minimum);
  if (team == null || team < 1 || (places != null && team > places)) {
    errors[CampaignField.minimum] = strings.sponsorValidationMinimum;
  }
  final goal = parseRupeesToPaise(funding);
  if (goal == null ||
      goal < CampaignLimits.minimumGoalPaise ||
      goal > CampaignLimits.maximumGoalPaise) {
    errors[CampaignField.funding] = _goalRange(strings, localeTag);
  }
  if (checklist.isEmpty) {
    errors[CampaignField.checklist] = strings.sponsorValidationChecklist;
  }
  final evidenceText = evidence.trim();
  if (evidenceText.length < 10 ||
      evidenceText.length > CampaignLimits.descriptionMax) {
    errors[CampaignField.evidence] = strings.sponsorValidationEvidence(
      10,
      CampaignLimits.descriptionMax,
    );
  }
  for (final list in [checklist, skills, tags]) {
    if (list.length > CampaignLimits.listMaxItems ||
        list.any((item) => item.length > CampaignLimits.listItemMaxLength)) {
      errors[CampaignField.lists] = strings.sponsorValidationLists(
        CampaignLimits.listMaxItems,
        CampaignLimits.listItemMaxLength,
      );
      break;
    }
  }
  return errors;
}

/// Validates the readiness "Revise scope" dialog. Returns null when valid.
String? validateScopeRevision({
  required String goal,
  required String minimum,
  required String description,
  required int volunteerCapacity,
  AppLocalizations? l10n,
  String? localeTag,
}) {
  final strings = l10n ?? _english;
  final amount = parseRupeesToPaise(goal);
  if (amount == null ||
      amount < CampaignLimits.minimumGoalPaise ||
      amount > CampaignLimits.maximumGoalPaise) {
    return strings.sponsorValidationScopeGoal(_goalRange(strings, localeTag));
  }
  final team = parseWholeNumber(minimum);
  if (team == null || team < 1 || team > volunteerCapacity) {
    return strings.sponsorValidationScopeMinimum(volunteerCapacity);
  }
  final length = description.trim().length;
  if (length < CampaignLimits.scopeNoteMin ||
      length > CampaignLimits.scopeNoteMax) {
    return strings.sponsorValidationScopeDescription(
      CampaignLimits.scopeNoteMin,
      CampaignLimits.scopeNoteMax,
    );
  }
  return null;
}

/// Sponsor-specific messages for idempotency and payout codes; everything
/// else goes through the shared [userMessageFor].
///
/// Pass [context] to word the shared messages in the current locale too.
String sponsorErrorMessage(
  Object error, {
  AppLocalizations? l10n,
  String? fallback,
  BuildContext? context,
}) {
  final strings = l10n ?? context?.l10n ?? _english;
  if (error is FieldnoteException) {
    switch (error.code) {
      case 'payouts_manual':
        return strings.sponsorPayoutsManual;
      case 'client_request_id_reused':
        return strings.sponsorErrorRequestReused;
      case 'invalid_client_request_id':
        return strings.sponsorErrorRequestInvalid;
      case 'duplicate_payment_request':
        return strings.sponsorErrorDuplicatePayment;
    }
  }
  return userMessageFor(error, fallback: fallback, context: context);
}

/// Where a campaign is in its life, as a sponsor sees it.
enum CampaignPhase {
  draft,
  planning,
  needsDecision,
  postponed,
  confirmed,
  inProgress,
  completed,
  cancelled,
  expired,
}

bool campaignHasStarted(Campaign campaign, {DateTime? now}) =>
    !(now ?? DateTime.now()).toUtc().isBefore(campaign.startsAt.toUtc());

CampaignPhase campaignPhase(Campaign campaign, {DateTime? now}) {
  if (campaign.status == CampaignStatus.completed) {
    return CampaignPhase.completed;
  }
  if (campaign.status == CampaignStatus.draft) return CampaignPhase.draft;
  switch (campaign.readinessState) {
    case 'cancelled':
      return CampaignPhase.cancelled;
    case 'expired':
      return CampaignPhase.expired;
  }
  if (campaignHasStarted(campaign, now: now)) return CampaignPhase.inProgress;
  return switch (campaign.readinessState) {
    'confirmed' => CampaignPhase.confirmed,
    'postponed' => CampaignPhase.postponed,
    'fundingShort' ||
    'volunteersShort' ||
    'bothShort' => CampaignPhase.needsDecision,
    _ => CampaignPhase.planning,
  };
}

/// True when the campaign is closed: no more joins, funding or edits.
bool campaignIsClosed(CampaignPhase phase) => const {
  CampaignPhase.completed,
  CampaignPhase.cancelled,
  CampaignPhase.expired,
}.contains(phase);

/// True while the sponsor may still revise, postpone or cancel.
bool campaignIsEditable(Campaign campaign, {DateTime? now}) {
  final phase = campaignPhase(campaign, now: now);
  return !campaignIsClosed(phase) &&
      phase != CampaignPhase.inProgress &&
      phase != CampaignPhase.draft;
}

typedef StatusStyle = ({String label, Color color, IconData icon});

StatusStyle campaignPhaseStyle(CampaignPhase phase, {AppLocalizations? l10n}) {
  final l = l10n ?? _english;
  return switch (phase) {
    CampaignPhase.draft => (
      label: l.sponsorPhaseDraft,
      color: FieldnoteColors.clay,
      icon: Icons.edit_note,
    ),
    CampaignPhase.planning => (
      label: l.sponsorPhasePlanning,
      color: FieldnoteColors.moss,
      icon: Icons.circle,
    ),
    CampaignPhase.needsDecision => (
      label: l.sponsorPhaseNeedsDecision,
      color: FieldnoteColors.clay,
      icon: Icons.error_outline,
    ),
    CampaignPhase.postponed => (
      label: l.sponsorPhasePostponed,
      color: FieldnoteColors.clay,
      icon: Icons.event_repeat_outlined,
    ),
    CampaignPhase.confirmed => (
      label: l.sponsorPhaseConfirmed,
      color: FieldnoteColors.forest,
      icon: Icons.verified_outlined,
    ),
    CampaignPhase.inProgress => (
      label: l.sponsorPhaseInProgress,
      color: FieldnoteColors.forest,
      icon: Icons.directions_run,
    ),
    CampaignPhase.completed => (
      label: l.sponsorPhaseCompleted,
      color: FieldnoteColors.forest,
      icon: Icons.task_alt,
    ),
    CampaignPhase.cancelled => (
      label: l.sponsorPhaseCancelled,
      color: FieldnoteColors.danger,
      icon: Icons.cancel_outlined,
    ),
    CampaignPhase.expired => (
      label: l.sponsorPhaseExpired,
      color: FieldnoteColors.danger,
      icon: Icons.event_busy_outlined,
    ),
  };
}

/// Status chip for one payment-history row. A refund, when present, wins
/// because it is the most recent thing that happened to the money.
StatusStyle paymentStatusStyle(
  String paymentStatus, {
  TestRefund? refund,
  AppLocalizations? l10n,
}) {
  if (refund != null) return refundStatusStyle(refund.status, l10n: l10n);
  final l = l10n ?? _english;
  return switch (paymentStatus) {
    'verified' => (
      label: l.sponsorPaymentVerified,
      color: FieldnoteColors.forest,
      icon: Icons.verified_outlined,
    ),
    'verified_uncredited' => (
      label: l.sponsorPaymentRefundQueued,
      color: FieldnoteColors.clay,
      icon: Icons.undo,
    ),
    'failed' || 'verification_failed' => (
      label: l.sponsorPaymentFailed,
      color: FieldnoteColors.danger,
      icon: Icons.error_outline,
    ),
    'expired' => (
      label: l.sponsorPaymentNotCompleted,
      color: FieldnoteColors.moss,
      icon: Icons.timer_off_outlined,
    ),
    _ => (
      label: l.sponsorPaymentPending,
      color: FieldnoteColors.clay,
      icon: Icons.hourglass_empty,
    ),
  };
}

StatusStyle refundStatusStyle(String status, {AppLocalizations? l10n}) {
  final l = l10n ?? _english;
  return switch (status) {
    'processed' => (
      label: l.sponsorRefundProcessed,
      color: FieldnoteColors.forest,
      icon: Icons.check_circle_outline,
    ),
    'processing' => (
      label: l.sponsorRefundProcessing,
      color: FieldnoteColors.clay,
      icon: Icons.sync,
    ),
    'failed' => (
      label: l.sponsorRefundFailed,
      color: FieldnoteColors.danger,
      icon: Icons.error_outline,
    ),
    _ => (
      label: l.sponsorRefundPending,
      color: FieldnoteColors.clay,
      icon: Icons.hourglass_empty,
    ),
  };
}

String refundReasonLabel(String reason, {AppLocalizations? l10n}) {
  final l = l10n ?? _english;
  return switch (reason) {
    'campaign_cancelled' => l.sponsorRefundReasonCancelled,
    'campaign_expired' => l.sponsorRefundReasonExpired,
    'uncredited' => l.sponsorRefundReasonUncredited,
    _ => reason,
  };
}

StatusStyle reviewStateStyle(ReviewState state, {AppLocalizations? l10n}) {
  final l = l10n ?? _english;
  return switch (state) {
    ReviewState.approved => (
      label: l.sponsorReviewApproved,
      color: FieldnoteColors.forest,
      icon: Icons.thumb_up_alt_outlined,
    ),
    ReviewState.rejected => (
      label: l.sponsorReviewRejected,
      color: FieldnoteColors.danger,
      icon: Icons.thumb_down_alt_outlined,
    ),
    ReviewState.changesRequested => (
      label: l.sponsorReviewChangesRequested,
      color: FieldnoteColors.clay,
      icon: Icons.edit_note,
    ),
    ReviewState.awaitingReview => (
      label: l.sponsorReviewAwaiting,
      color: FieldnoteColors.clay,
      icon: Icons.rate_review_outlined,
    ),
  };
}
