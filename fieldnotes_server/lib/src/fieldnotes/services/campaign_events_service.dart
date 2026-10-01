import 'dart:convert';

import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart';

/// Audit rows, live campaign messages and schedule notices. Usable from
/// endpoints, future calls and web routes because the actor is explicit.
class CampaignEventsService {
  const CampaignEventsService();

  static String channel(int campaignId) => 'fieldnote-campaign-$campaignId';

  Future<AuditEvent> audit(
    Session session, {
    required UuidValue actor,
    required String event,
    required String entityType,
    String? entityId,
    required String outcome,
    required String riskLevel,
    required String detail,
    Transaction? transaction,
  }) async {
    final item = await AuditEvent.db.insertRow(
      session,
      AuditEvent(
        actorAuthUserId: actor,
        event: event,
        entityType: entityType,
        entityId: entityId,
        outcome: outcome,
        riskLevel: riskLevel,
        detail: detail.length > 500 ? detail.substring(0, 500) : detail,
      ),
      transaction: transaction,
    );
    session.log(
      jsonEncode({
        'event': event,
        'entityType': entityType,
        'entityId': entityId,
        'outcome': outcome,
        'riskLevel': riskLevel,
      }),
      level: riskLevel == 'high' ? LogLevel.warning : LogLevel.info,
    );
    return item;
  }

  Future<void> publish(
    Session session,
    int campaignId,
    String event,
    String message,
  ) async {
    await session.messages.postMessage(
      channel(campaignId),
      CampaignLiveUpdate(
        campaignId: campaignId,
        event: event,
        message: message,
        occurredAt: DateTime.now().toUtc(),
      ),
    );
  }

  /// Records an official schedule post and broadcasts it.
  Future<void> readinessNotice(
    Session session,
    Campaign campaign,
    String message, {
    String event = 'campaignReadiness',
  }) async {
    await CampaignPost.db.insertRow(
      session,
      CampaignPost(
        campaignId: campaign.id!,
        authorSponsorAuthUserId: campaign.createdBy,
        title: 'Campaign schedule update',
        body: message,
      ),
    );
    await publish(session, campaign.id!, event, message);
  }
}
