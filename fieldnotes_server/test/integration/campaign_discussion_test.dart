import 'dart:async';
import 'dart:convert';

import 'package:fieldnotes_server/src/fieldnotes/services/account_deletion_service.dart';
import 'package:fieldnotes_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Campaign discussion', (builder, endpoints) {
    const ids = [
      '880e8400-e29b-41d4-a716-446655440000',
      '880e8400-e29b-41d4-a716-446655440001',
      '880e8400-e29b-41d4-a716-446655440002',
      '880e8400-e29b-41d4-a716-446655440003',
    ];
    final accounts = ids
        .map(
          (id) => builder.copyWith(
            authentication: AuthenticationOverride.authenticationInfo(id, {}),
          ),
        )
        .toList();
    final creator = accounts[0];
    final volunteer = accounts[1];
    final teammate = accounts[2];
    final funder = accounts[3];
    late Session session;
    late Campaign campaign;

    Matcher denied(String code) =>
        throwsA(isA<FieldnoteException>().having((e) => e.code, 'code', code));

    setUp(() async {
      session = builder.build();
      for (var i = 0; i < ids.length; i++) {
        await FieldnoteUserProfile.db.insertRow(
          session,
          FieldnoteUserProfile(
            authUserId: UuidValue.fromString(ids[i]),
            role: i == 0 || i == 3
                ? AccountRole.sponsor
                : AccountRole.volunteer,
            displayName: 'Member $i',
            city: 'Pune',
            interests: '',
            skills: '',
          ),
        );
        await endpoints.fieldnote.acceptLegalConsent(
          accounts[i],
          true,
          true,
          true,
        );
      }
      final organization = await Organization.db.insertRow(
        session,
        Organization(
          name: 'Discussion tests',
          createdBy: UuidValue.fromString(ids[0]),
        ),
      );
      campaign = await Campaign.db.insertRow(
        session,
        Campaign(
          organizationId: organization.id!,
          name: 'Neighborhood cleanup',
          description: 'Clean the neighborhood together.',
          locationName: 'Pune',
          startsAt: DateTime.now().toUtc().add(const Duration(days: 2)),
          status: CampaignStatus.active,
          createdBy: UuidValue.fromString(ids[0]),
        ),
      );
      for (final id in ids.skip(1).take(2)) {
        await CampaignParticipation.db.insertRow(
          session,
          CampaignParticipation(
            campaignId: campaign.id!,
            volunteerAuthUserId: UuidValue.fromString(id),
            status: ParticipationStatus.joined,
          ),
        );
      }
    });

    test('creator and both volunteers share the same persisted room', () async {
      for (var i = 0; i < 3; i++) {
        await endpoints.fieldnote.sendCampaignMessage(
          accounts[i],
          campaign.id!,
          'Question or reply $i',
          'message-$i',
        );
      }
      for (final account in accounts.take(3)) {
        final messages = await endpoints.fieldnote.listCampaignMessages(
          account,
          campaign.id!,
        );
        expect(messages.map((m) => m.body), [
          'Question or reply 2',
          'Question or reply 1',
          'Question or reply 0',
        ]);
        expect(messages.last.senderIsCreator, isTrue);
        expect(messages.first.senderIsCreator, isFalse);
      }
    });

    test(
      'verified funders and volunteers from another campaign have no access',
      () async {
        await Sponsorship.db.insertRow(
          session,
          Sponsorship(
            campaignId: campaign.id!,
            sponsorAuthUserId: UuidValue.fromString(ids[3]),
            amount: 10,
            paymentStatus: 'verified',
          ),
        );
        await expectLater(
          endpoints.fieldnote.listCampaignMessages(funder, campaign.id!),
          denied('chat_forbidden'),
        );
        await expectLater(
          endpoints.fieldnote.sendCampaignMessage(
            funder,
            campaign.id!,
            'Hello',
            'outside-1',
          ),
          denied('chat_forbidden'),
        );
        await expectLater(
          endpoints.fieldnote.watchCampaignChat(funder, campaign.id!),
          emitsError(isA<FieldnoteException>()),
        );
        final other = await Campaign.db.insertRow(
          session,
          campaign.copyWith(id: null, name: 'Other neighborhood'),
        );
        await expectLater(
          endpoints.fieldnote.listCampaignMessages(volunteer, other.id!),
          denied('chat_forbidden'),
        );
      },
    );

    test(
      'send retries produce one row and conflicting retries fail',
      () async {
        final sent = <CampaignChatMessage>[];
        for (var i = 0; i < 3; i++) {
          sent.add(
            await endpoints.fieldnote.sendCampaignMessage(
              volunteer,
              campaign.id!,
              'Where should we meet?',
              'same-request',
            ),
          );
        }
        expect(sent.map((m) => m.id).toSet(), hasLength(1));
        expect(await CampaignChatMessage.db.count(session), 1);
        await expectLater(
          endpoints.fieldnote.sendCampaignMessage(
            volunteer,
            campaign.id!,
            'Different text',
            'same-request',
          ),
          denied('chat_request_conflict'),
        );
      },
    );

    test(
      'history pagination has no overlap and catch-up stays in its room',
      () async {
        final sent = <CampaignChatMessage>[];
        for (var i = 0; i < 5; i++) {
          sent.add(
            await endpoints.fieldnote.sendCampaignMessage(
              creator,
              campaign.id!,
              'Message $i',
              'page-msg-$i',
            ),
          );
        }
        final newest = await endpoints.fieldnote.listCampaignMessages(
          volunteer,
          campaign.id!,
          limit: 2,
        );
        final older = await endpoints.fieldnote.listCampaignMessages(
          volunteer,
          campaign.id!,
          beforeId: newest.last.id,
          limit: 2,
        );
        expect(newest.map((m) => m.id), [sent[4].id, sent[3].id]);
        expect(older.map((m) => m.id), [sent[2].id, sent[1].id]);
        final caughtUp = await endpoints.fieldnote.listCampaignMessages(
          volunteer,
          campaign.id!,
          afterId: sent[1].id,
        );
        expect(caughtUp.map((m) => m.id), [sent[2].id, sent[3].id, sent[4].id]);
        await expectLater(
          endpoints.fieldnote.listCampaignMessages(
            volunteer,
            campaign.id!,
            beforeId: 1,
            afterId: 0,
          ),
          denied('invalid_chat_page'),
        );
      },
    );

    test(
      'volunteers receive each other live; departure revokes an existing stream',
      () async {
        final stream = StreamIterator(
          endpoints.fieldnote.watchCampaignChat(volunteer, campaign.id!),
        );
        try {
          expect(await stream.moveNext(), isTrue);
          expect(stream.current.readOnly, isFalse);
          final sent = await endpoints.fieldnote.sendCampaignMessage(
            teammate,
            campaign.id!,
            'Bring gloves?',
            'live-msg-1',
          );
          expect(await stream.moveNext(), isTrue);
          expect(stream.current.message?.id, sent.id);
          final participation = (await CampaignParticipation.db.findFirstRow(
            session,
            where: (t) =>
                t.volunteerAuthUserId.equals(UuidValue.fromString(ids[1])),
          ))!;
          await endpoints.fieldnote.leaveCampaign(volunteer, participation.id!);
          await endpoints.fieldnote.sendCampaignMessage(
            creator,
            campaign.id!,
            'Team update',
            'live-msg-2',
          );
          await expectLater(stream.moveNext(), denied('chat_forbidden'));
          await expectLater(
            endpoints.fieldnote.listCampaignMessages(volunteer, campaign.id!),
            denied('chat_forbidden'),
          );
          await expectLater(
            endpoints.fieldnote.sendCampaignMessage(
              volunteer,
              campaign.id!,
              'Left message',
              'left-msg-1',
            ),
            denied('chat_forbidden'),
          );
        } finally {
          await stream.cancel();
        }
      },
    );

    test(
      'completed campaign keeps history and its stream becomes read-only',
      () async {
        await endpoints.fieldnote.sendCampaignMessage(
          volunteer,
          campaign.id!,
          'Thanks everyone',
          'closing-1',
        );
        final stream = StreamIterator(
          endpoints.fieldnote.watchCampaignChat(creator, campaign.id!),
        );
        try {
          await stream.moveNext();
          campaign.status = CampaignStatus.completed;
          await Campaign.db.updateRow(session, campaign);
          expect(await stream.moveNext(), isTrue);
          expect(stream.current.readOnly, isTrue);
          expect(
            await endpoints.fieldnote.listCampaignMessages(
              volunteer,
              campaign.id!,
            ),
            hasLength(1),
          );
          await expectLater(
            endpoints.fieldnote.sendCampaignMessage(
              creator,
              campaign.id!,
              'New message',
              'closed-1',
            ),
            denied('chat_read_only'),
          );
        } finally {
          await stream.cancel();
        }
      },
    );

    test('empty, oversized and moderated messages are rejected', () async {
      for (final text in ['   ', 'x' * 2001]) {
        await expectLater(
          endpoints.fieldnote.sendCampaignMessage(
            volunteer,
            campaign.id!,
            text,
            'invalid-1',
          ),
          throwsA(isA<FieldnoteException>()),
        );
      }
      await expectLater(
        endpoints.fieldnote.sendCampaignMessage(
          volunteer,
          campaign.id!,
          'shoot people',
          'invalid-2',
        ),
        throwsA(isA<FieldnoteException>()),
      );
      expect(await CampaignChatMessage.db.count(session), 0);
    });

    test(
      'export includes own chat messages and deletion removes their text',
      () async {
        await endpoints.fieldnote.sendCampaignMessage(
          volunteer,
          campaign.id!,
          'My private question',
          'export-1',
        );
        await endpoints.fieldnote.sendCampaignMessage(
          teammate,
          campaign.id!,
          'Team reply',
          'export-2',
        );
        final data =
            jsonDecode(await endpoints.fieldnote.exportMyData(volunteer))
                as Map<String, dynamic>;
        expect(
          (data['campaignChatMessages'] as List).single['body'],
          'My private question',
        );
        const deletion = AccountDeletionService();
        await deletion.request(session, UuidValue.fromString(ids[1]));
        expect((await deletion.processDue(session)).completed, 1);
        final messages = await endpoints.fieldnote.listCampaignMessages(
          creator,
          campaign.id!,
        );
        expect(messages.map((m) => m.body), ['Team reply']);
      },
    );
    test(
      'chat rate limit blocks excessive sends without storing them',
      () async {
        for (var i = 0; i < 30; i++) {
          await endpoints.fieldnote.sendCampaignMessage(
            volunteer,
            campaign.id!,
            'Message $i',
            'rate-msg-$i',
          );
        }
        await expectLater(
          endpoints.fieldnote.sendCampaignMessage(
            volunteer,
            campaign.id!,
            'One too many',
            'rate-msg-30',
          ),
          denied('rate_limited'),
        );
        expect(await CampaignChatMessage.db.count(session), 30);
      },
    );
  });
}
