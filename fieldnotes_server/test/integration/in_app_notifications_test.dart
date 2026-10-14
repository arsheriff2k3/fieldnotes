import 'dart:convert';

import 'package:fieldnotes_server/src/fieldnotes/services/firebase_push_sender.dart';
import 'package:fieldnotes_server/src/fieldnotes/services/in_app_notification_service.dart';
import 'package:fieldnotes_server/src/fieldnotes/services/notification_service.dart';
import 'package:fieldnotes_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

const ownerId = '780e8400-e29b-41d4-a716-446655440000';
const otherId = '780e8400-e29b-41d4-a716-446655440001';
const deviceToken = 'test-android-registration-token-owner';

class FakePushSender implements PushSender {
  PushSendResult result = PushSendResult.sent;
  final sent = <int>[];
  @override
  Future<PushSendResult> send({
    required String token,
    required int notificationId,
    int unreadCount = 1,
  }) async {
    sent.add(notificationId);
    return result;
  }

  @override
  void close() {}
}

void main() {
  withServerpod('Server-owned notification inbox and Android push', (
    sessionBuilder,
    endpoints,
  ) {
    final owner = sessionBuilder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(ownerId, {}),
    );
    final other = sessionBuilder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(otherId, {}),
    );
    late FakePushSender push;

    setUp(() async {
      push = FakePushSender();
      PushRuntime.senderResolver = (_) async => push;
      NotificationRuntime.mailerResolver = (_) => null;
      for (final id in [ownerId, otherId]) {
        await FieldnoteUserProfile.db.insertRow(
          sessionBuilder.build(),
          FieldnoteUserProfile(
            authUserId: UuidValue.withValidation(id),
            role: id == ownerId ? AccountRole.volunteer : AccountRole.sponsor,
            displayName: 'Notification tester',
            city: 'Pune',
            interests: '',
            skills: '',
            emailNotifications: false,
          ),
        );
      }
    });
    tearDown(() {
      PushRuntime.reset();
      NotificationRuntime.reset();
    });

    Future<void> enqueue(
      String key, {
      String recipient = ownerId,
      String kind = 'campaignCancelled',
    }) => const InAppNotificationService().enqueue(
      sessionBuilder.build(),
      recipient: UuidValue.withValidation(recipient),
      kind: kind,
      dedupeKey: key,
      title: 'Campaign update',
      body: 'Do not travel.',
      campaignId: 1,
    );

    test(
      'email opt-out and missing SMTP do not suppress inbox or push',
      () async {
        await endpoints.fieldnote.registerMyPushDevice(
          owner,
          deviceToken,
          'android',
        );
        await const NotificationService().enqueue(
          sessionBuilder.build(),
          recipient: UuidValue.withValidation(ownerId),
          kind: NotificationKind.invitationReceived,
          dedupeKey: 'invite:1',
          subject: 'Invitation',
          text: 'Open the campaign.',
          campaignId: 1,
        );
        final inbox = await endpoints.fieldnote.getMyNotifications(
          owner,
          limit: 20,
          unreadOnly: false,
        );
        expect(inbox, hasLength(1));
        final emails = await const NotificationService().deliverDue(
          sessionBuilder.build(),
        );
        expect(emails.skipped, 1);
        await const InAppNotificationService().deliverDue(
          sessionBuilder.build(),
        );
        expect(push.sent, [inbox.single.id]);
      },
    );

    test(
      'duplicate events queue exactly one inbox item and one push per device',
      () async {
        await endpoints.fieldnote.registerMyPushDevice(
          owner,
          deviceToken,
          'android',
        );
        await enqueue('cancel:1');
        await enqueue('cancel:1');
        expect(
          await endpoints.fieldnote.getMyNotifications(
            owner,
            limit: 20,
            unreadOnly: false,
          ),
          hasLength(1),
        );
        expect(await PushDelivery.db.count(sessionBuilder.build()), 1);
        await const InAppNotificationService().deliverDue(
          sessionBuilder.build(),
        );
        await const InAppNotificationService().deliverDue(
          sessionBuilder.build(),
        );
        expect(push.sent, hasLength(1));
      },
    );

    test('inbox queries and read writes isolate recipients', () async {
      await enqueue('owner');
      await enqueue('other', recipient: otherId);
      final item = (await endpoints.fieldnote.getMyNotifications(
        owner,
        limit: 20,
        unreadOnly: false,
      )).single;
      expect(
        await endpoints.fieldnote.getMyNotification(other, item.id),
        isNull,
      );
      await endpoints.fieldnote.markMyNotificationRead(other, item.id);
      expect(await endpoints.fieldnote.getMyUnreadNotificationCount(owner), 1);
      await endpoints.fieldnote.markMyNotificationRead(owner, item.id);
      final readAt = (await endpoints.fieldnote.getMyNotification(
        owner,
        item.id,
      ))!.readAt;
      await endpoints.fieldnote.markMyNotificationRead(owner, item.id);
      expect(
        (await endpoints.fieldnote.getMyNotification(owner, item.id))!.readAt,
        readAt,
      );
      expect(await endpoints.fieldnote.getMyUnreadNotificationCount(owner), 0);
      expect(await endpoints.fieldnote.getMyUnreadNotificationCount(other), 1);
    });

    test(
      'snapshot mark-all and ID pagination preserve newer arrivals',
      () async {
        await enqueue('old1');
        await enqueue('old2');
        final snapshot = await endpoints.fieldnote.getMyNotifications(
          owner,
          limit: 1,
          unreadOnly: false,
        );
        final newest = snapshot.single.id;
        await enqueue('new');
        await endpoints.fieldnote.markMyNotificationsReadThrough(owner, newest);
        final unread = await endpoints.fieldnote.getMyNotifications(
          owner,
          limit: 20,
          unreadOnly: true,
        );
        expect(unread, hasLength(1));
        expect(unread.single.id, greaterThan(newest));
        final older = await endpoints.fieldnote.getMyNotifications(
          owner,
          limit: 20,
          unreadOnly: false,
          beforeId: newest,
        );
        expect(older, hasLength(1));
        expect(older.single.id, lessThan(newest));
      },
    );

    test(
      'shared device transfer removes the old recipient queued pushes',
      () async {
        await endpoints.fieldnote.registerMyPushDevice(
          owner,
          deviceToken,
          'android',
        );
        await enqueue('old-owner');
        await endpoints.fieldnote.registerMyPushDevice(
          other,
          deviceToken,
          'android',
        );
        await const InAppNotificationService().deliverDue(
          sessionBuilder.build(),
        );
        expect(push.sent, isEmpty);
        expect(
          await endpoints.fieldnote.getMyNotifications(
            owner,
            limit: 20,
            unreadOnly: false,
          ),
          hasLength(1),
        );
        await enqueue('new-owner', recipient: otherId);
        await const InAppNotificationService().deliverDue(
          sessionBuilder.build(),
        );
        expect(push.sent, hasLength(1));
        // The old account cannot unregister another account's current token.
        await endpoints.fieldnote.unregisterMyPushDevice(owner, deviceToken);
        expect(await PushDevice.db.count(sessionBuilder.build()), 1);
      },
    );

    test(
      'unconfigured Firebase keeps the inbox and pending push; transient errors retry',
      () async {
        await endpoints.fieldnote.registerMyPushDevice(
          owner,
          deviceToken,
          'android',
        );
        await enqueue('retry');
        PushRuntime.senderResolver = (_) async => null;
        await const InAppNotificationService().deliverDue(
          sessionBuilder.build(),
        );
        expect(
          (await PushDelivery.db.findFirstRow(
            sessionBuilder.build(),
          ))!.attempts,
          0,
        );
        PushRuntime.senderResolver = (_) async => push;
        push.result = PushSendResult.retry;
        final now = DateTime.now().toUtc();
        await const InAppNotificationService().deliverDue(
          sessionBuilder.build(),
          now: now,
        );
        final failed = (await PushDelivery.db.findFirstRow(
          sessionBuilder.build(),
        ))!;
        expect(failed.status, 'failed');
        expect(failed.nextAttemptAt, now.add(const Duration(minutes: 2)));
        await const InAppNotificationService().deliverDue(
          sessionBuilder.build(),
          now: now,
        );
        expect(push.sent, hasLength(1));
        push.result = PushSendResult.sent;
        await const InAppNotificationService().deliverDue(
          sessionBuilder.build(),
          now: now.add(const Duration(minutes: 3)),
        );
        expect(
          (await PushDelivery.db.findFirstRow(sessionBuilder.build()))!.status,
          'sent',
        );
        expect(
          await endpoints.fieldnote.getMyUnreadNotificationCount(owner),
          1,
        );
      },
    );

    test('invalid tokens retire devices; read inbox items skip push', () async {
      await endpoints.fieldnote.registerMyPushDevice(
        owner,
        deviceToken,
        'android',
      );
      await enqueue('read-first');
      final item = (await endpoints.fieldnote.getMyNotifications(
        owner,
        limit: 20,
        unreadOnly: false,
      )).single;
      await endpoints.fieldnote.markMyNotificationRead(owner, item.id);
      await const InAppNotificationService().deliverDue(sessionBuilder.build());
      expect(push.sent, isEmpty);
      await enqueue('invalid-token');
      push.result = PushSendResult.invalidToken;
      await const InAppNotificationService().deliverDue(sessionBuilder.build());
      expect(await PushDevice.db.count(sessionBuilder.build()), 0);
      expect(
        await endpoints.fieldnote.getMyNotifications(
          owner,
          limit: 20,
          unreadOnly: false,
        ),
        hasLength(2),
      );
    });

    test(
      'data export includes inbox and device metadata, never registration tokens',
      () async {
        await endpoints.fieldnote.registerMyPushDevice(
          owner,
          deviceToken,
          'android',
        );
        await enqueue('export');
        final exported = await endpoints.fieldnote.exportMyData(owner);
        final data = jsonDecode(exported) as Map<String, dynamic>;
        expect(data['notifications'], hasLength(1));
        expect((data['pushDevices'] as List).single['platform'], 'android');
        expect(exported, isNot(contains(deviceToken)));
      },
    );

    test(
      'a crashed final push attempt is finalized after its lease expires',
      () async {
        await endpoints.fieldnote.registerMyPushDevice(
          owner,
          deviceToken,
          'android',
        );
        await enqueue('lease');
        final delivery = (await PushDelivery.db.findFirstRow(
          sessionBuilder.build(),
        ))!;
        delivery.status = 'sending';
        delivery.attempts = 5;
        delivery.nextAttemptAt = DateTime.now().toUtc().subtract(
          const Duration(minutes: 1),
        );
        await PushDelivery.db.updateRow(sessionBuilder.build(), delivery);
        await const InAppNotificationService().deliverDue(
          sessionBuilder.build(),
        );
        final finished = (await PushDelivery.db.findById(
          sessionBuilder.build(),
          delivery.id!,
        ))!;
        expect(finished.status, 'failed');
        expect(finished.nextAttemptAt, isNull);
        expect(push.sent, isEmpty);
      },
    );

    test(
      'unregister all devices removes pending pushes but keeps inbox history',
      () async {
        await endpoints.fieldnote.registerMyPushDevice(
          owner,
          deviceToken,
          'android',
        );
        await enqueue('signout');
        await endpoints.fieldnote.unregisterAllMyPushDevices(owner);
        expect(await PushDevice.db.count(sessionBuilder.build()), 0);
        expect(await PushDelivery.db.count(sessionBuilder.build()), 0);
        expect(
          await endpoints.fieldnote.getMyNotifications(
            owner,
            limit: 20,
            unreadOnly: false,
          ),
          hasLength(1),
        );
      },
    );
  });
}
