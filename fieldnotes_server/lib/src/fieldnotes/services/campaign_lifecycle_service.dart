import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart';
import 'campaign_events_service.dart';
import 'campaign_readiness_policy.dart';
import 'notification_service.dart';
import 'refund_service.dart';

/// Campaign state machine:
///
/// `active/open` → (24 h before start) readiness evaluated →
/// `active/confirmed` → (endsAt + [completionGrace]) `completed`.
/// `active/<short>` at startsAt → `active/expired` (refunds queued).
/// `active/*` before startsAt → `active/cancelled` by the creator.
class CampaignLifecycleService {
  const CampaignLifecycleService();

  /// Volunteers may still submit evidence for this long after the end, and
  /// the sweep completes the campaign once it has elapsed.
  static const completionGrace = Duration(hours: 2);

  /// Fallback duration for legacy rows without an end time.
  static const defaultDuration = Duration(hours: 2);

  static const _events = CampaignEventsService();

  /// Participations that hold a place.
  static const activeParticipationStatuses = {
    ParticipationStatus.joined,
    ParticipationStatus.checkedIn,
    ParticipationStatus.completed,
  };

  static DateTime endOf(Campaign campaign) =>
      campaign.endsAt ?? campaign.startsAt.add(defaultDuration);

  static DateTime completionDeadline(Campaign campaign) =>
      endOf(campaign).add(completionGrace);

  static bool isClosed(Campaign campaign) =>
      campaign.status != CampaignStatus.active ||
      const {'cancelled', 'expired'}.contains(campaign.readinessState);

  /// Re-evaluates readiness for every active campaign whose decision window
  /// has opened. Called from the sweep, never from list endpoints.
  Future<int> refreshDueCampaigns(Session session, {DateTime? now}) async {
    final clock = now ?? DateTime.now().toUtc();
    final campaigns = await Campaign.db.find(
      session,
      where: (t) =>
          t.status.equals(CampaignStatus.active) &
          (t.startsAt <= clock.add(const Duration(hours: 24))),
    );
    var refreshed = 0;
    for (final campaign in campaigns) {
      if (const {
        'cancelled',
        'expired',
        'confirmed',
      }.contains(campaign.readinessState)) {
        continue;
      }
      await refreshReadiness(session, campaign.id!);
      refreshed++;
    }
    return refreshed;
  }

  Future<Campaign> refreshReadiness(Session session, int campaignId) async {
    final result = await session.db.transaction((transaction) async {
      final campaign = await Campaign.db.findById(
        session,
        campaignId,
        transaction: transaction,
        lockMode: LockMode.forUpdate,
      );
      if (campaign == null) {
        throw FieldnoteException(
          message: 'Campaign not found.',
          code: 'campaign_not_found',
        );
      }
      final now = DateTime.now().toUtc();
      if (isClosed(campaign)) {
        return (campaign: campaign, changed: false);
      }
      final joins = await CampaignParticipation.db.find(
        session,
        where: (t) => t.campaignId.equals(campaignId),
        transaction: transaction,
      );
      final joinedCount = joins
          .where(
            (join) =>
                join.confirmedRevision == campaign.revision &&
                (join.status == ParticipationStatus.joined ||
                    join.status == ParticipationStatus.checkedIn),
          )
          .length;
      final countChanged = campaign.eligibleVolunteers != joinedCount;
      campaign.eligibleVolunteers = joinedCount;
      if (campaign.readinessState == 'confirmed' ||
          now.isBefore(campaign.startsAt.subtract(const Duration(hours: 24)))) {
        if (!countChanged) return (campaign: campaign, changed: false);
        final updated = await Campaign.db.updateRow(
          session,
          campaign,
          transaction: transaction,
        );
        return (campaign: updated, changed: false);
      }
      final previous = campaign.readinessState;
      if (!now.isBefore(campaign.startsAt)) {
        campaign.readinessState = 'expired';
        // P0-4: money for an event that never happened goes back.
        await const RefundService().queueForCampaign(
          session,
          campaignId: campaignId,
          reason: RefundReason.campaignExpired,
          transaction: transaction,
        );
        await _resolveParticipations(
          session,
          joins,
          transaction: transaction,
          now: now,
          joined: ParticipationStatus.cancelled,
          checkedIn: ParticipationStatus.cancelled,
        );
      } else {
        campaign.readinessState = const CampaignReadinessPolicy().evaluate(
          fundingGoalPaise: campaign.fundingGoalPaise,
          sponsoredPaise: campaign.sponsoredAmountPaise,
          minimumVolunteers: campaign.minimumVolunteers,
          joinedVolunteers: joinedCount,
        );
      }
      campaign.readinessCheckedAt = now;
      campaign.decisionDueAt = campaign.readinessState == 'confirmed'
          ? null
          : campaign.startsAt;
      if (campaign.readinessState == 'confirmed') campaign.confirmedAt = now;
      campaign.updatedAt = now;
      final updated = await Campaign.db.updateRow(
        session,
        campaign,
        transaction: transaction,
      );
      return (campaign: updated, changed: previous != updated.readinessState);
    });
    if (result.changed) {
      final message = switch (result.campaign.readinessState) {
        'confirmed' =>
          'The event is confirmed. Please review the meeting details.',
        'expired' =>
          'The proposed event date passed without confirmation. Do not travel to the work site. Sponsors will be refunded.',
        _ =>
          'The event date is awaiting an organizer decision. Please check again before travelling.',
      };
      await _events.readinessNotice(session, result.campaign, message);
      final kind = switch (result.campaign.readinessState) {
        'confirmed' => NotificationKind.campaignConfirmed,
        'expired' => NotificationKind.campaignExpired,
        _ => null,
      };
      if (kind != null) {
        await const NotificationService().campaignChanged(
          session,
          result.campaign,
          kind,
        );
      }
    }
    return result.campaign;
  }

  /// P0-5: closes confirmed campaigns after the end plus [completionGrace]
  /// and resolves participations that never finished.
  Future<List<Campaign>> completeEndedCampaigns(
    Session session, {
    DateTime? now,
  }) async {
    final clock = now ?? DateTime.now().toUtc();
    final candidates = await Campaign.db.find(
      session,
      where: (t) =>
          t.status.equals(CampaignStatus.active) &
          t.readinessState.equals('confirmed') &
          (t.startsAt < clock),
    );
    final completed = <Campaign>[];
    for (final candidate in candidates) {
      if (completionDeadline(candidate).isAfter(clock)) continue;
      final result = await session.db.transaction((transaction) async {
        final campaign = await Campaign.db.findById(
          session,
          candidate.id!,
          transaction: transaction,
          lockMode: LockMode.forUpdate,
        );
        if (campaign == null ||
            campaign.status != CampaignStatus.active ||
            campaign.readinessState != 'confirmed') {
          return null;
        }
        final participations = await CampaignParticipation.db.find(
          session,
          where: (t) => t.campaignId.equals(campaign.id!),
          transaction: transaction,
        );
        final resolved = await _resolveParticipations(
          session,
          participations,
          transaction: transaction,
          now: clock,
          joined: ParticipationStatus.noShow,
          checkedIn: ParticipationStatus.incomplete,
        );
        campaign.status = CampaignStatus.completed;
        campaign.completedAt = clock;
        campaign.updatedAt = clock;
        final updated = await Campaign.db.updateRow(
          session,
          campaign,
          transaction: transaction,
        );
        final completedCount = participations
            .where((item) => item.status == ParticipationStatus.completed)
            .length;
        return (
          campaign: updated,
          completedCount: completedCount,
          noShows: resolved.noShows,
          incomplete: resolved.incomplete,
        );
      });
      if (result == null) continue;
      completed.add(result.campaign);
      await _events.readinessNotice(
        session,
        result.campaign,
        'The campaign is complete. ${result.completedCount} volunteer${result.completedCount == 1 ? '' : 's'} submitted evidence.',
        event: 'campaignCompleted',
      );
      await _events.audit(
        session,
        actor: result.campaign.createdBy,
        event: 'campaignCompleted',
        entityType: 'campaign',
        entityId: '${result.campaign.id}',
        outcome: 'completed',
        riskLevel: 'info',
        detail:
            '${result.completedCount} completed, ${result.incomplete} incomplete, ${result.noShows} no-shows.',
      );
    }
    return completed;
  }

  /// Moves every still-open participation to its resolved status. Completed,
  /// left and already-resolved rows are untouched.
  Future<({int noShows, int incomplete})> _resolveParticipations(
    Session session,
    List<CampaignParticipation> participations, {
    required Transaction transaction,
    required DateTime now,
    required ParticipationStatus joined,
    required ParticipationStatus checkedIn,
  }) async {
    var noShows = 0;
    var incomplete = 0;
    for (final participation in participations) {
      final ParticipationStatus next;
      if (participation.status == ParticipationStatus.joined) {
        next = joined;
        noShows++;
      } else if (participation.status == ParticipationStatus.checkedIn) {
        next = checkedIn;
        incomplete++;
      } else {
        continue;
      }
      participation.status = next;
      participation.resolvedAt = now;
      await CampaignParticipation.db.updateRow(
        session,
        participation,
        transaction: transaction,
      );
    }
    return (noShows: noShows, incomplete: incomplete);
  }

  /// Marks open participations cancelled when the creator cancels.
  Future<void> cancelParticipations(
    Session session,
    int campaignId, {
    required Transaction transaction,
  }) async {
    final participations = await CampaignParticipation.db.find(
      session,
      where: (t) => t.campaignId.equals(campaignId),
      transaction: transaction,
    );
    await _resolveParticipations(
      session,
      participations,
      transaction: transaction,
      now: DateTime.now().toUtc(),
      joined: ParticipationStatus.cancelled,
      checkedIn: ParticipationStatus.cancelled,
    );
  }
}
