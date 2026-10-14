// Device-test entry point only. Production builds continue to use lib/main.dart.
// Run with flutter build apk --debug --target tool/notification_device_app.dart.
import 'dart:convert';

import 'package:fieldnotes_client/fieldnotes_client.dart';
import 'package:flutter_driver/driver_extension.dart';

import 'package:fieldnotes_flutter/data/repositories/fieldnote_repository.dart';
import 'package:fieldnotes_flutter/data/services/firebase_push_service.dart';
import 'package:fieldnotes_flutter/main.dart' as app;

const _prefix = '[Notification QA]';
final _foreground = <Map<String, Object>>[];
final _opened = <Map<String, Object>>[];

void main() {
  final push = FirebasePushService.instance;
  push.incoming.addListener(() {
    final id = push.incoming.value;
    if (id != null) {
      _foreground.add({
        'id': id,
        'at': DateTime.now().toUtc().toIso8601String(),
      });
    }
  });
  push.opened.addListener(() {
    final id = push.opened.value;
    if (id != null) {
      _opened.add({'id': id, 'at': DateTime.now().toUtc().toIso8601String()});
    }
  });
  enableFlutterDriverExtension(
    enableTextEntryEmulation: true,
    handler: _command,
  );
  app.main();
}

Future<String> _command(String? value) async {
  try {
    final command = jsonDecode(value!) as Map<String, dynamic>;
    final repository = FieldnoteRepository();
    final action = command['action'];
    if (action == 'snapshot') {
      final profile = await repository.profile();
      final notifications = await repository.notifications(limit: 50);
      return jsonEncode({
        'role': profile?.role.name,
        'profileId': profile?.id,
        'emailEnabled': profile?.emailNotifications,
        'pushAvailable': FirebasePushService.instance.available,
        'pushEnabled': FirebasePushService.instance.enabled,
        'unreadCount': await repository.unreadNotificationCount(),
        'notifications': notifications
            .where((n) => n.title.contains(_prefix))
            .map(
              (n) => {
                'id': n.id,
                'kind': n.kind,
                'campaignId': n.campaignId,
                'createdAt': n.createdAt.toIso8601String(),
                'readAt': n.readAt?.toIso8601String(),
              },
            )
            .toList(),
        'foreground': _foreground,
        'opened': _opened,
      });
    }
    if (action == 'enablePush') {
      await FirebasePushService.instance.enable();
      return jsonEncode({'enabled': true});
    }
    if (action == 'emailPreference') {
      final result = await repository.setEmailNotifications(
        command['enabled'] as bool,
      );
      return jsonEncode({'enabled': result.emailNotifications});
    }
    if (action == 'readNotification') {
      final item = await repository.notification(
        command['notificationId'] as int,
      );
      return jsonEncode({'available': item != null, 'kind': item?.kind});
    }
    if (action == 'create') {
      final campaign = await repository.createCampaign(
        CampaignProposal(
          title: '$_prefix ${command['label']}',
          description:
              'Temporary two-device notification test. No real-world activity will take place.',
          locationName: 'Notification QA simulated venue',
          startsAt: DateTime.now().toUtc().add(const Duration(days: 3)),
          durationMinutes: 60,
          volunteerCapacity: 10,
          minimumVolunteers: 1,
          fundingGoal: 100,
          fundingGoalPaise: 10000,
          requiredSkills: ['community'],
          checklist: ['Verify device notifications'],
          evidenceInstructions: 'This is a notification-only device test.',
          tags: ['community'],
          rationale: 'Dedicated device QA campaign, created without AI.',
        ),
        18.5204,
        73.8567,
        clientRequestId: 'notification-qa-${command['requestId']}',
      );
      return jsonEncode({
        'campaignId': campaign.id,
        'startsAt': campaign.startsAt.toIso8601String(),
      });
    }
    final id = command['campaignId'] as int;
    Campaign? campaign;
    final profile = await repository.profile();
    if (profile?.role == AccountRole.sponsor) {
      campaign = (await repository.myCreatedCampaigns())
          .where((c) => c.id == id)
          .firstOrNull;
    } else {
      campaign = await repository.sharedCampaign(id);
    }
    if (campaign == null || !campaign.name.startsWith(_prefix)) {
      throw StateError(
        'Only dedicated notification QA campaigns can be modified.',
      );
    }
    switch (action) {
      case 'join':
        final participation = await repository.join(id);
        return jsonEncode({
          'participationId': participation.id,
          'status': participation.status.name,
        });
      case 'reconfirm':
        final participation = await repository.reconfirmParticipation(
          command['participationId'] as int,
        );
        return jsonEncode({'status': participation.status.name});
      case 'revise':
        final result = await repository.reviseCampaignScope(
          id,
          campaign.fundingGoalPaise,
          campaign.minimumVolunteers,
          'Temporary QA campaign. Updated work plan to verify foreground notifications.',
        );
        return jsonEncode({'revision': result.revision});
      case 'postpone':
        final result = await repository.postponeCampaign(
          id,
          campaign.startsAt.add(const Duration(hours: 2)),
        );
        return jsonEncode({'revision': result.revision});
      case 'cancel':
        final result = await repository.cancelCampaign(id);
        return jsonEncode({'readinessState': result.readinessState});
      case 'invite':
        final invited = await repository.inviteCampaignVolunteer(
          id,
          command['profileId'] as int,
        );
        return jsonEncode({'invited': invited});
      default:
        throw StateError('Unsupported QA command.');
    }
  } on FieldnoteException catch (error) {
    return jsonEncode({'error': error.code, 'message': error.message});
  } catch (error) {
    return jsonEncode({'error': error.runtimeType.toString()});
  }
}
