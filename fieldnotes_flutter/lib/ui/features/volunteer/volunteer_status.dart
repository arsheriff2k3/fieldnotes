import 'package:fieldnotes_client/fieldnotes_client.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/services/device_location_service.dart';
import '../../core/fieldnote_theme.dart';

/// Pure helpers for the volunteer screens. They mirror server rules so the UI
/// can explain (and disable) actions the server would reject anyway.

/// Matches `LocationIntegrityService`: accuracy weaker than this is rejected.
const maxAcceptedAccuracyMeters = 150.0;

/// Matches `LocationIntegrityService`: samples older than this are rejected.
const maxLocationAge = Duration(minutes: 2);

/// A fix is reused for evidence only while it stays inside [maxLocationAge]
/// after the photograph upload; this leaves room for a slow upload.
const reusableFixAge = Duration(seconds: 90);

/// Matches `completeParticipation`: summary must be 8–2000 characters.
const minSummaryLength = 8;
const maxSummaryLength = 2000;

/// Prefix of the server's non-AI proposal rationale
/// (`StructuredSummaryService.manualRationale`).
const manualRationalePrefix = 'AI analysis is unavailable';

/// Matches `CampaignLifecycleService.defaultDuration` / `completionGrace`.
const _defaultDuration = Duration(hours: 2);
const _completionGrace = Duration(hours: 2);
const _checkInLead = Duration(minutes: 30);

/// True when [proposal] is the server's deterministic fallback, not a hosted
/// AI proposal; the volunteer then owns the summary (`manualSummary: true`).
bool isFallbackProposal(CompletionProposal proposal) =>
    proposal.rationale.trim().startsWith(manualRationalePrefix);

DateTime campaignEnd(Campaign campaign) =>
    (campaign.endsAt ?? campaign.startsAt.add(_defaultDuration)).toUtc();

DateTime checkInOpensAt(Campaign campaign) =>
    campaign.startsAt.toUtc().subtract(_checkInLead);

DateTime completionDeadline(Campaign campaign) =>
    campaignEnd(campaign).add(_completionGrace);

enum CheckInWindow { notYetOpen, open, closed }

/// Check-in is accepted from 30 minutes before the start until the end.
CheckInWindow checkInWindow(Campaign campaign, DateTime now) {
  final at = now.toUtc();
  if (at.isBefore(checkInOpensAt(campaign))) return CheckInWindow.notYetOpen;
  if (at.isAfter(campaignEnd(campaign))) return CheckInWindow.closed;
  return CheckInWindow.open;
}

/// "Check-in opens at 09:30" (with the date when it is not today).
String checkInOpensLabel(Campaign campaign, DateTime now) {
  final opens = checkInOpensAt(campaign).toLocal();
  final local = now.toLocal();
  final sameDay =
      opens.year == local.year &&
      opens.month == local.month &&
      opens.day == local.day;
  final time = DateFormat('HH:mm').format(opens);
  return sameDay
      ? 'Check-in opens at $time'
      : 'Check-in opens ${DateFormat('EEE d MMM').format(opens)} at $time';
}

bool isCampaignCancelled(Campaign campaign) =>
    campaign.readinessState == 'cancelled';

bool isCampaignExpired(Campaign campaign) =>
    campaign.readinessState == 'expired';

bool isCampaignCompleted(Campaign campaign) =>
    campaign.status == CampaignStatus.completed;

/// Matches `CampaignLifecycleService.isClosed`.
bool isCampaignClosed(Campaign campaign) =>
    campaign.status != CampaignStatus.active ||
    isCampaignCancelled(campaign) ||
    isCampaignExpired(campaign);

/// True when the volunteer holds (or held and used) a place. A volunteer who
/// left may join again.
bool holdsPlace(CampaignParticipation? participation) =>
    participation != null && participation.status != ParticipationStatus.left;

/// Display state of one My work card.
class ParticipationDisplay {
  const ParticipationDisplay({
    required this.label,
    required this.color,
    required this.icon,
    this.detail,
    this.canCheckIn = false,
    this.canComplete = false,
    this.canLeave = false,
  });

  final String label;
  final Color color;
  final IconData icon;
  final String? detail;
  final bool canCheckIn;
  final bool canComplete;
  final bool canLeave;

  bool get isActive => canCheckIn || canComplete || canLeave;
}

ParticipationDisplay participationDisplay(
  CampaignParticipation participation,
  Campaign? campaign, {
  DateTime? now,
}) {
  final at = (now ?? DateTime.now()).toUtc();
  switch (participation.status) {
    case ParticipationStatus.completed:
      return const ParticipationDisplay(
        label: 'Impact submitted',
        color: FieldnoteColors.forest,
        icon: Icons.verified,
      );
    case ParticipationStatus.left:
      return const ParticipationDisplay(
        label: 'You left this campaign',
        color: FieldnoteColors.moss,
        icon: Icons.logout,
        detail: 'Your place was freed. You can join again while it is open.',
      );
    case ParticipationStatus.noShow:
      return const ParticipationDisplay(
        label: 'Missed · no check-in',
        color: FieldnoteColors.clay,
        icon: Icons.event_busy_outlined,
        detail: 'The campaign ended without a GPS check-in from you.',
      );
    case ParticipationStatus.incomplete:
      return const ParticipationDisplay(
        label: 'Incomplete · no evidence',
        color: FieldnoteColors.clay,
        icon: Icons.hourglass_disabled_outlined,
        detail: 'You checked in, but no evidence was sent before the deadline.',
      );
    case ParticipationStatus.cancelled:
      return _cancelledOrExpired(campaign);
    case ParticipationStatus.joined:
    case ParticipationStatus.checkedIn:
      break;
  }
  if (campaign != null &&
      (isCampaignCancelled(campaign) || isCampaignExpired(campaign))) {
    return _cancelledOrExpired(campaign);
  }
  if (campaign != null && isCampaignCompleted(campaign)) {
    return ParticipationDisplay(
      label: 'Campaign completed',
      color: FieldnoteColors.moss,
      icon: Icons.flag_outlined,
      detail: participation.status == ParticipationStatus.checkedIn
          ? 'The evidence window has closed.'
          : 'This campaign has finished.',
    );
  }
  if (participation.status == ParticipationStatus.checkedIn) {
    final open = campaign == null || !at.isAfter(completionDeadline(campaign));
    return ParticipationDisplay(
      label: 'GPS checked in',
      color: FieldnoteColors.forest,
      icon: Icons.gps_fixed,
      canComplete: open,
      detail: open ? null : 'The evidence window for this campaign has closed.',
    );
  }
  return const ParticipationDisplay(
    label: 'Joined',
    color: FieldnoteColors.clay,
    icon: Icons.how_to_reg,
    canCheckIn: true,
    canLeave: true,
  );
}

ParticipationDisplay _cancelledOrExpired(Campaign? campaign) =>
    campaign != null && isCampaignExpired(campaign)
    ? const ParticipationDisplay(
        label: 'Campaign expired',
        color: FieldnoteColors.danger,
        icon: Icons.event_busy_outlined,
        detail:
            'The proposed date passed without enough support. Do not travel.',
      )
    : const ParticipationDisplay(
        label: 'Campaign cancelled — do not travel',
        color: FieldnoteColors.danger,
        icon: Icons.cancel_outlined,
        detail: 'The organizer cancelled this campaign.',
      );

String reviewStateLabel(ReviewState state) => switch (state) {
  ReviewState.awaitingReview => 'Awaiting sponsor review',
  ReviewState.approved => 'Approved by sponsor',
  ReviewState.changesRequested => 'Changes requested',
  ReviewState.rejected => 'Rejected by sponsor',
};

/// Why [location] cannot be sent to the server, or null when it is usable.
String? locationProblem(DeviceLocation location, DateTime now) {
  if (location.accuracyMeters > maxAcceptedAccuracyMeters ||
      !location.accuracyMeters.isFinite ||
      location.accuracyMeters <= 0) {
    return accuracyMessage(location.accuracyMeters);
  }
  if (now.toUtc().difference(location.capturedAt.toUtc()).abs() >
      maxLocationAge) {
    return 'The GPS reading is out of date. Try again.';
  }
  return null;
}

String accuracyMessage(double accuracyMeters) =>
    'GPS accuracy is ±${accuracyMeters.isFinite ? accuracyMeters.round() : '?'} m; '
    'FieldNote needs ${maxAcceptedAccuracyMeters.round()} m or better. Move '
    'outdoors or near a window and try again.';

/// True when [location] can be reused instead of asking for a new fix.
bool isReusableFix(DeviceLocation? location, DateTime now) =>
    location != null &&
    !location.isDemo &&
    location.accuracyMeters > 0 &&
    location.accuracyMeters <= maxAcceptedAccuracyMeters &&
    now.toUtc().difference(location.capturedAt.toUtc()).abs() < reusableFixAge;

/// Splits a volunteer-written summary into the short results list the server
/// stores (at most 20 items of 300 characters).
List<String> manualResultsFrom(String summary) {
  final items = summary
      .split(RegExp(r'(?<=[.!?])\s+|\n+|;\s*'))
      .map((item) => item.trim().replaceAll(RegExp(r'[.!?]+$'), ''))
      .where((item) => item.length >= 3)
      .map((item) => item.length <= 300 ? item : item.substring(0, 300))
      .take(20)
      .toList();
  final trimmed = summary.trim();
  if (items.isNotEmpty || trimmed.isEmpty) return items;
  return [trimmed.length <= 300 ? trimmed : trimmed.substring(0, 300)];
}

String formatMinutes(int minutes) {
  final clamped = minutes.clamp(0, 1440);
  if (clamped == 1440) return '24:00';
  final h = (clamped ~/ 60).toString().padLeft(2, '0');
  final m = (clamped % 60).toString().padLeft(2, '0');
  return '$h:$m';
}

/// Null when the window is valid (0–1440, start before end).
String? availabilityWindowProblem(int startMinutes, int endMinutes) {
  if (startMinutes < 0 || endMinutes > 1440 || startMinutes > 1440) {
    return 'Choose times within the day.';
  }
  if (startMinutes >= endMinutes) {
    return 'The end time must be after the start time.';
  }
  return null;
}
