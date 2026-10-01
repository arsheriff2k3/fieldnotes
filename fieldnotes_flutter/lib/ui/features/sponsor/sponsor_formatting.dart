import 'package:fieldnotes_client/fieldnotes_client.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/fieldnote_theme.dart';

/// Client copies of the server's campaign bounds (`campaign_validation.dart`)
/// so a sponsor sees the problem before a round trip.
abstract final class CampaignLimits {
  static const minimumGoal = 100.0;
  static const maximumGoal = 1000000.0;
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

/// Parses a rupee amount typed by a person: "25,000", "25 000", "₹25000.50".
/// Returns null for anything that is not a plain non-negative number with at
/// most two decimals.
double? parseRupees(String input) {
  final cleaned = input
      .replaceAll(RegExp(r'[\s,_₹]'), '')
      .replaceFirst(RegExp(r'^(rs\.?|inr)', caseSensitive: false), '');
  if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(cleaned)) return null;
  final value = double.tryParse(cleaned);
  return value == null || !value.isFinite ? null : value;
}

/// Parses a whole number that may contain grouping commas or spaces.
int? parseWholeNumber(String input) {
  final cleaned = input.replaceAll(RegExp(r'[\s,_]'), '');
  if (!RegExp(r'^\d+$').hasMatch(cleaned)) return null;
  return int.tryParse(cleaned);
}

String formatRupees(double amount) => NumberFormat.currency(
  locale: 'en_IN',
  symbol: '₹',
  decimalDigits: amount == amount.roundToDouble() ? 0 : 2,
).format(amount);

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
}) {
  final errors = <String, String>{};
  final t = title.trim();
  final d = description.trim();
  if (t.length < CampaignLimits.titleMin ||
      t.length > CampaignLimits.titleMax) {
    errors[CampaignField.title] =
        'Use ${CampaignLimits.titleMin}–${CampaignLimits.titleMax} characters.';
  }
  if (d.length < CampaignLimits.descriptionMin ||
      d.length > CampaignLimits.descriptionMax) {
    errors[CampaignField.description] =
        'Describe the work in ${CampaignLimits.descriptionMin}–'
        '${CampaignLimits.descriptionMax} characters.';
  }
  if (locationName.trim().isEmpty) {
    errors[CampaignField.location] = 'Name the location.';
  }
  if (!startsAt.isAfter(now ?? DateTime.now())) {
    errors[CampaignField.startsAt] =
        'This time has passed. Choose a start date and time in the future.';
  }
  final minutes = parseWholeNumber(duration);
  if (minutes == null ||
      minutes < CampaignLimits.minimumDurationMinutes ||
      minutes > CampaignLimits.maximumDurationMinutes) {
    errors[CampaignField.duration] =
        '${CampaignLimits.minimumDurationMinutes}–'
        '${CampaignLimits.maximumDurationMinutes} minutes.';
  }
  final places = parseWholeNumber(capacity);
  if (places == null ||
      places < CampaignLimits.minimumCapacity ||
      places > CampaignLimits.maximumCapacity) {
    errors[CampaignField.capacity] =
        '${CampaignLimits.minimumCapacity}–${CampaignLimits.maximumCapacity} places.';
  }
  final team = parseWholeNumber(minimum);
  if (team == null || team < 1 || (places != null && team > places)) {
    errors[CampaignField.minimum] = 'Between 1 and the volunteer places.';
  }
  final goal = parseRupees(funding);
  if (goal == null ||
      goal < CampaignLimits.minimumGoal ||
      goal > CampaignLimits.maximumGoal) {
    errors[CampaignField.funding] = '₹100 to ₹10,00,000.';
  }
  if (checklist.isEmpty) {
    errors[CampaignField.checklist] = 'Add at least one checklist task.';
  }
  final evidenceText = evidence.trim();
  if (evidenceText.length < 10 ||
      evidenceText.length > CampaignLimits.descriptionMax) {
    errors[CampaignField.evidence] =
        'Describe the evidence volunteers submit (10–4000 characters).';
  }
  for (final list in [checklist, skills, tags]) {
    if (list.length > CampaignLimits.listMaxItems ||
        list.any((item) => item.length > CampaignLimits.listItemMaxLength)) {
      errors[CampaignField.lists] =
          'Keep checklists, skills and tags to ${CampaignLimits.listMaxItems} '
          'items of up to ${CampaignLimits.listItemMaxLength} characters.';
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
}) {
  final amount = parseRupees(goal);
  if (amount == null ||
      amount < CampaignLimits.minimumGoal ||
      amount > CampaignLimits.maximumGoal) {
    return 'Choose a funding goal between ₹100 and ₹10,00,000.';
  }
  final team = parseWholeNumber(minimum);
  if (team == null || team < 1 || team > volunteerCapacity) {
    return 'Choose a minimum team between 1 and $volunteerCapacity.';
  }
  final length = description.trim().length;
  if (length < CampaignLimits.scopeNoteMin ||
      length > CampaignLimits.scopeNoteMax) {
    return 'Describe the revised work in ${CampaignLimits.scopeNoteMin}–'
        '${CampaignLimits.scopeNoteMax} characters.';
  }
  return null;
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

StatusStyle campaignPhaseStyle(CampaignPhase phase) => switch (phase) {
  CampaignPhase.draft => (
    label: 'Draft',
    color: FieldnoteColors.clay,
    icon: Icons.edit_note,
  ),
  CampaignPhase.planning => (
    label: 'Planning',
    color: FieldnoteColors.moss,
    icon: Icons.circle,
  ),
  CampaignPhase.needsDecision => (
    label: 'Needs a decision',
    color: FieldnoteColors.clay,
    icon: Icons.error_outline,
  ),
  CampaignPhase.postponed => (
    label: 'Postponed',
    color: FieldnoteColors.clay,
    icon: Icons.event_repeat_outlined,
  ),
  CampaignPhase.confirmed => (
    label: 'Confirmed',
    color: FieldnoteColors.forest,
    icon: Icons.verified_outlined,
  ),
  CampaignPhase.inProgress => (
    label: 'In progress',
    color: FieldnoteColors.forest,
    icon: Icons.directions_run,
  ),
  CampaignPhase.completed => (
    label: 'Completed',
    color: FieldnoteColors.forest,
    icon: Icons.task_alt,
  ),
  CampaignPhase.cancelled => (
    label: 'Cancelled',
    color: FieldnoteColors.danger,
    icon: Icons.cancel_outlined,
  ),
  CampaignPhase.expired => (
    label: 'Expired',
    color: FieldnoteColors.danger,
    icon: Icons.event_busy_outlined,
  ),
};

/// Status chip for one payment-history row. A refund, when present, wins
/// because it is the most recent thing that happened to the money.
StatusStyle paymentStatusStyle(String paymentStatus, {TestRefund? refund}) {
  if (refund != null) return refundStatusStyle(refund.status);
  return switch (paymentStatus) {
    'verified' => (
      label: 'Verified',
      color: FieldnoteColors.forest,
      icon: Icons.verified_outlined,
    ),
    'verified_uncredited' => (
      label: 'Refund queued',
      color: FieldnoteColors.clay,
      icon: Icons.undo,
    ),
    'failed' || 'verification_failed' => (
      label: 'Failed',
      color: FieldnoteColors.danger,
      icon: Icons.error_outline,
    ),
    'expired' => (
      label: 'Not completed',
      color: FieldnoteColors.moss,
      icon: Icons.timer_off_outlined,
    ),
    _ => (
      label: 'Pending',
      color: FieldnoteColors.clay,
      icon: Icons.hourglass_empty,
    ),
  };
}

StatusStyle refundStatusStyle(String status) => switch (status) {
  'processed' => (
    label: 'Refunded',
    color: FieldnoteColors.forest,
    icon: Icons.check_circle_outline,
  ),
  'processing' => (
    label: 'Refund processing',
    color: FieldnoteColors.clay,
    icon: Icons.sync,
  ),
  'failed' => (
    label: 'Refund failed',
    color: FieldnoteColors.danger,
    icon: Icons.error_outline,
  ),
  _ => (
    label: 'Refund pending',
    color: FieldnoteColors.clay,
    icon: Icons.hourglass_empty,
  ),
};

String refundReasonLabel(String reason) => switch (reason) {
  'campaign_cancelled' => 'Campaign cancelled',
  'campaign_expired' => 'Campaign expired',
  'uncredited' => 'Payment could not be credited',
  _ => reason,
};

StatusStyle reviewStateStyle(ReviewState state) => switch (state) {
  ReviewState.approved => (
    label: 'Approved',
    color: FieldnoteColors.forest,
    icon: Icons.thumb_up_alt_outlined,
  ),
  ReviewState.rejected => (
    label: 'Rejected',
    color: FieldnoteColors.danger,
    icon: Icons.thumb_down_alt_outlined,
  ),
  ReviewState.changesRequested => (
    label: 'Changes requested',
    color: FieldnoteColors.clay,
    icon: Icons.edit_note,
  ),
  ReviewState.awaitingReview => (
    label: 'Awaiting review',
    color: FieldnoteColors.clay,
    icon: Icons.rate_review_outlined,
  ),
};
