import 'dart:convert';
import 'dart:math' as math;

import 'package:crypto/crypto.dart';
import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart';
import 'firebase_push_sender.dart';

class InAppNotificationService {
  const InAppNotificationService();

  static NotificationItem item(InAppNotification row) => NotificationItem(
    id: row.id!,
    kind: row.kind,
    title: row.title,
    body: row.body,
    campaignId: row.campaignId,
    createdAt: row.createdAt,
    readAt: row.readAt,
    unreadCount: row.readAt == null ? row.unreadCount : 0,
    chatMessageId: row.chatMessageId,
  );

  /// Independent of SMTP configuration and email opt-out. Persistence errors
  /// do not roll back an already completed business action.
  Future<void> enqueue(
    Session session, {
    required UuidValue recipient,
    required String kind,
    required String dedupeKey,
    required String title,
    required String body,
    int? campaignId,
  }) async {
    try {
      await session.db.transaction((transaction) async {
        // Serialize producers for a recipient and coordinate with deletion.
        final profile = await FieldnoteUserProfile.db.findFirstRow(
          session,
          where: (t) => t.authUserId.equals(recipient),
          transaction: transaction,
          lockMode: LockMode.forUpdate,
        );
        if (profile == null) return;
        final existing = await InAppNotification.db.findFirstRow(
          session,
          where: (t) =>
              t.recipientAuthUserId.equals(recipient) &
              t.dedupeKey.equals(dedupeKey),
          transaction: transaction,
        );
        if (existing != null) return;
        final row = await InAppNotification.db.insertRow(
          session,
          InAppNotification(
            recipientAuthUserId: recipient,
            kind: kind,
            dedupeKey: dedupeKey,
            title: title,
            body: body,
            campaignId: campaignId,
          ),
          transaction: transaction,
        );
        final devices = await PushDevice.db.find(
          session,
          where: (t) => t.authUserId.equals(recipient),
          transaction: transaction,
        );
        for (final device in devices) {
          await PushDelivery.db.insertRow(
            session,
            PushDelivery(
              notificationId: row.id!,
              deviceId: device.id!,
              recipientAuthUserId: recipient,
            ),
            transaction: transaction,
          );
        }
      });
    } catch (_) {
      session.log(
        'In-app notification could not be queued.',
        level: LogLevel.warning,
      );
    }
  }

  static String channel(UuidValue userId) => 'fieldnote-inbox-$userId';

  /// Called inside the chat transaction: one mutable unread group per campaign.
  Future<InAppNotification?> enqueueChat(
    Session session, {
    required Transaction transaction,
    required UuidValue recipient,
    required Campaign campaign,
    required CampaignChatMessage message,
  }) async {
    final profile = await FieldnoteUserProfile.db.findFirstRow(
      session,
      where: (t) => t.authUserId.equals(recipient),
      transaction: transaction,
      lockMode: LockMode.forUpdate,
    );
    if (profile == null) return null;
    final key = 'campaignChat:${campaign.id}';
    var row = await InAppNotification.db.findFirstRow(
      session,
      where: (t) =>
          t.recipientAuthUserId.equals(recipient) & t.dedupeKey.equals(key),
      transaction: transaction,
      lockMode: LockMode.forUpdate,
    );
    if (row != null && (row.chatMessageId ?? 0) >= message.id!) return row;
    const body = 'Open the campaign discussion to read new messages.';
    if (row == null) {
      row = await InAppNotification.db.insertRow(
        session,
        InAppNotification(
          recipientAuthUserId: recipient,
          kind: 'campaignChat',
          dedupeKey: key,
          title: campaign.name,
          body: body,
          campaignId: campaign.id,
          chatMessageId: message.id,
        ),
        transaction: transaction,
      );
    } else {
      row.unreadCount = row.readAt == null ? row.unreadCount + 1 : 1;
      row.readAt = null;
      row.chatMessageId = message.id;
      row.title = campaign.name;
      row.body = body;
      row.createdAt = DateTime.now().toUtc();
      row = await InAppNotification.db.updateRow(
        session,
        row,
        transaction: transaction,
      );
    }
    final devices = await PushDevice.db.find(
      session,
      where: (t) => t.authUserId.equals(recipient),
      transaction: transaction,
    );
    for (final device in devices) {
      await PushDelivery.db.insertRow(
        session,
        PushDelivery(
          notificationId: row.id!,
          notificationVersion: message.id!,
          deviceId: device.id!,
          recipientAuthUserId: recipient,
        ),
        transaction: transaction,
      );
    }
    return row;
  }

  Future<void> registerDevice(
    Session session,
    UuidValue userId,
    String token,
    String platform,
  ) async {
    if (token.length < 20 ||
        token.length > 4096 ||
        token.trim() != token ||
        platform != 'android') {
      throw FieldnoteException(
        code: 'invalid_push_device',
        message: 'Invalid notification registration.',
      );
    }
    final hash = sha256.convert(utf8.encode(token)).toString();
    await session.db.transaction((transaction) async {
      final profile = await FieldnoteUserProfile.db.findFirstRow(
        session,
        where: (t) => t.authUserId.equals(userId),
        transaction: transaction,
        lockMode: LockMode.forUpdate,
      );
      if (profile == null) {
        throw FieldnoteException(
          code: 'profile_required',
          message: 'Complete onboarding first.',
        );
      }
      var device = await PushDevice.db.findFirstRow(
        session,
        where: (t) => t.tokenHash.equals(hash),
        transaction: transaction,
        lockMode: LockMode.forUpdate,
      );
      if (device == null || device.authUserId != userId) {
        final count = await PushDevice.db.count(
          session,
          where: (t) => t.authUserId.equals(userId),
          transaction: transaction,
        );
        if (count >= 20) {
          throw FieldnoteException(
            code: 'push_device_limit',
            message: 'Too many registered devices.',
          );
        }
      }
      if (device == null) {
        await PushDevice.db.insertRow(
          session,
          PushDevice(
            authUserId: userId,
            token: token,
            tokenHash: hash,
            platform: platform,
          ),
          transaction: transaction,
        );
      } else {
        // Invalidate queued deliveries for the old account before transferring
        // a shared device token. Never replay old inbox items on registration.
        if (device.authUserId != userId) {
          await PushDelivery.db.deleteWhere(
            session,
            where: (t) => t.deviceId.equals(device.id!),
            transaction: transaction,
          );
        }
        device.authUserId = userId;
        device.platform = platform;
        device.updatedAt = DateTime.now().toUtc();
        await PushDevice.db.updateRow(
          session,
          device,
          transaction: transaction,
        );
      }
    });
  }

  Future<void> unregisterDevice(
    Session session,
    UuidValue userId,
    String token,
  ) async {
    final hash = sha256.convert(utf8.encode(token)).toString();
    await session.db.transaction((transaction) async {
      final device = await PushDevice.db.findFirstRow(
        session,
        where: (t) => t.authUserId.equals(userId) & t.tokenHash.equals(hash),
        transaction: transaction,
        lockMode: LockMode.forUpdate,
      );
      if (device == null) return;
      await PushDelivery.db.deleteWhere(
        session,
        where: (t) => t.deviceId.equals(device.id!),
        transaction: transaction,
      );
      await PushDevice.db.deleteRow(session, device, transaction: transaction);
    });
  }

  /// A leased batch lets multiple worker instances drain the queue safely.
  /// FCM may accept a message before a worker crashes; clients use the inbox
  /// ID as the source of truth rather than promising exactly-once push alerts.
  Future<void> deliverDue(Session session, {DateTime? now}) async {
    PushSender? sender;
    try {
      sender = await PushRuntime.sender(session);
    } catch (_) {
      session.log(
        'Firebase push credentials could not be loaded.',
        level: LogLevel.warning,
      );
      return;
    }
    // Leave rows pending while Firebase is unconfigured; the inbox still works.
    if (sender == null) return;
    final clock = now ?? DateTime.now().toUtc();
    try {
      await PushDelivery.db.updateWhere(
        session,
        columnValues: (t) => [
          t.status('failed'),
          t.nextAttemptAt(null),
          t.lastError('attempts_exhausted'),
        ],
        where: (t) =>
            t.status.equals('sending') &
            (t.attempts >= 5) &
            (t.nextAttemptAt <= clock),
      );
      final claimed = await session.db.transaction((transaction) async {
        final rows = await PushDelivery.db.find(
          session,
          where: (t) =>
              t.status.equals('pending') |
              (t.status.inSet({'failed', 'sending'}) &
                  (t.nextAttemptAt <= clock) &
                  (t.attempts < 5)),
          orderBy: (t) => t.id,
          limit: 25,
          transaction: transaction,
          lockMode: LockMode.forUpdate,
          lockBehavior: LockBehavior.skipLocked,
        );
        for (final row in rows) {
          row.status = 'sending';
          row.attempts += 1;
          row.nextAttemptAt = clock.add(const Duration(minutes: 10));
        }
        if (rows.isEmpty) return rows;
        return PushDelivery.db.update(session, rows, transaction: transaction);
      });
      for (final delivery in claimed) {
        final device = await PushDevice.db.findById(session, delivery.deviceId);
        final notification = await InAppNotification.db.findById(
          session,
          delivery.notificationId,
        );
        if (device == null ||
            notification == null ||
            device.authUserId != delivery.recipientAuthUserId ||
            notification.recipientAuthUserId != device.authUserId ||
            notification.readAt != null ||
            (notification.kind == 'campaignChat' &&
                notification.chatMessageId != delivery.notificationVersion) ||
            clock.difference(notification.createdAt) >
                const Duration(days: 1)) {
          delivery.status = 'skipped';
          delivery.lastError = 'unavailable_read_or_stale';
          delivery.nextAttemptAt = null;
        } else {
          PushSendResult result;
          try {
            result = await sender.send(
              token: device.token,
              notificationId: notification.id!,
              unreadCount: notification.kind == 'campaignChat'
                  ? notification.unreadCount
                  : 1,
            );
          } catch (_) {
            result = PushSendResult.retry;
          }
          delivery.status = switch (result) {
            PushSendResult.sent => 'sent',
            PushSendResult.retry => 'failed',
            _ => 'skipped',
          };
          delivery.lastError = result == PushSendResult.sent
              ? null
              : result.name;
          delivery.sentAt = result == PushSendResult.sent ? clock : null;
          delivery.nextAttemptAt =
              result == PushSendResult.retry && delivery.attempts < 5
              ? clock.add(
                  Duration(
                    minutes: 2 * math.pow(2, delivery.attempts - 1).toInt(),
                  ),
                )
              : null;
          if (result == PushSendResult.invalidToken) {
            // Constrain deletion to the token owner observed for this send.
            await PushDevice.db.deleteWhere(
              session,
              where: (t) =>
                  t.id.equals(device.id!) &
                  t.authUserId.equals(device.authUserId) &
                  t.tokenHash.equals(device.tokenHash),
            );
          }
        }
        // The row may have been removed by sign-out or account deletion.
        await PushDelivery.db.updateWhere(
          session,
          columnValues: (t) => [
            t.status(delivery.status),
            t.lastError(delivery.lastError),
            t.sentAt(delivery.sentAt),
            t.nextAttemptAt(delivery.nextAttemptAt),
          ],
          where: (t) =>
              t.id.equals(delivery.id!) &
              t.status.equals('sending') &
              t.attempts.equals(delivery.attempts),
        );
      }
    } finally {
      sender.close();
    }
  }
}
