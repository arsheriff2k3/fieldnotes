import 'dart:async';
import 'dart:convert';

import 'package:fieldnotes_server/src/fieldnotes/fieldnote_endpoint.dart';
import 'package:fieldnotes_server/src/fieldnotes/services/account_deletion_service.dart';
import 'package:fieldnotes_server/src/fieldnotes/services/fieldnote_config.dart';
import 'package:fieldnotes_server/src/fieldnotes/services/notification_service.dart';
import 'package:fieldnotes_server/src/fieldnotes/services/rate_limiter.dart';
import 'package:fieldnotes_server/src/generated/protocol.dart';
import 'package:fieldnotes_server/src/web/routes/campaign_share_route.dart';
import 'package:fieldnotes_server/src/web/routes/well_known_routes.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart' as auth;
import 'package:serverpod_auth_idp_server/providers/email.dart' as email_idp;
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

const _sponsorId = '770e8400-e29b-41d4-a716-446655440000';
const _strangerId = '770e8400-e29b-41d4-a716-446655440009';
const _siteLatitude = 18.52040;
const _siteLongitude = 73.85670;

Matcher _throwsCode(String code) => throwsA(
  isA<FieldnoteException>().having((error) => error.code, 'code', code),
);

/// Records every email instead of sending it.
class FakeMailer implements NotificationMailer {
  final sent = <({String to, String subject, String text})>[];

  @override
  Future<void> send({
    required String to,
    required String subject,
    required String text,
    required String html,
  }) async => sent.add((to: to, subject: subject, text: text));
}

CampaignProposal _proposal({
  DateTime? startsAt,
  int capacity = 12,
  int durationMinutes = 180,
}) => CampaignProposal(
  title: 'Riverbank Cleanup Morning',
  description: 'Collect litter along the riverbank and document the work.',
  locationName: 'Riverbank',
  startsAt: startsAt ?? DateTime.now().toUtc().add(const Duration(days: 2)),
  durationMinutes: durationMinutes,
  volunteerCapacity: capacity,
  minimumVolunteers: 1,
  fundingGoal: 30000,
  requiredSkills: ['Comfortable outdoors'],
  checklist: ['Collect litter', 'Sort recyclables'],
  evidenceInstructions: 'Submit a location-verified photograph and note.',
  tags: ['cleanup', 'environment'],
  rationale: 'Sponsor-confirmed campaign details.',
);

void main() {
  withServerpod('Given compliance, privacy and notification flows', (
    sessionBuilder,
    endpoints,
  ) {
    TestSessionBuilder as(String id) => sessionBuilder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(id, {}),
    );
    final sponsor = as(_sponsorId);
    final stranger = as(_strangerId);
    late FakeMailer mailer;

    setUp(() {
      mailer = FakeMailer();
      NotificationRuntime.mailerResolver = (_) => mailer;
    });
    tearDown(() {
      NotificationRuntime.reset();
      FieldnoteConfig.environmentOverride = null;
    });

    /// A real Serverpod auth user with an email login.
    Future<String> authUser(String email) async {
      final session = sessionBuilder.build();
      final user = await auth.AuthUser.db.insertRow(
        session,
        auth.AuthUser(scopeNames: {}, blocked: false),
      );
      await email_idp.EmailAccount.db.insertRow(
        session,
        email_idp.EmailAccount(
          authUserId: user.id!,
          email: email,
          passwordHash: r'$argon2id$test',
        ),
      );
      return user.id!.uuid;
    }

    Future<void> sponsorProfile(TestSessionBuilder account) async {
      await endpoints.fieldnote.completeSponsorProfile(
        account,
        'Asha Sponsor',
        'Individual',
        null,
        'Pune',
        null,
        ['environment'],
        contactPhone: '+919876543210',
      );
      await endpoints.fieldnote.acceptLegalConsent(account, true, true, true);
    }

    Future<FieldnoteUserProfile> volunteerProfile(
      TestSessionBuilder account, {
      String name = 'Ravi Volunteer',
      List<int> weekdays = const [1, 2, 3, 4, 5, 6, 7],
      int start = 0,
      int end = 1440,
      bool availableToday = false,
      int? utcOffsetMinutes,
      double latitude = _siteLatitude,
      double longitude = _siteLongitude,
    }) async {
      final profile = await endpoints.fieldnote.completeVolunteerProfile(
        account,
        name,
        'Pune',
        ['environment'],
        ['outdoors'],
        true,
        availableToday,
        weekdays,
        start,
        end,
        10,
        latitude,
        longitude,
        'Pune area',
        utcOffsetMinutes: utcOffsetMinutes,
        // The IANA zone wins over the offset, so only send it when they agree.
        timezone: utcOffsetMinutes == 330 ? 'Asia/Kolkata' : null,
      );
      await endpoints.fieldnote.acceptLegalConsent(account, true, true, true);
      return profile;
    }

    Future<Campaign> publish({DateTime? startsAt, int capacity = 12}) async {
      await sponsorProfile(sponsor);
      return endpoints.fieldnote.createCampaignFromProposal(
        sponsor,
        _proposal(startsAt: startsAt, capacity: capacity),
        _siteLatitude,
        _siteLongitude,
        'Riverbank site',
        200,
      );
    }

    group('account deletion', () {
      test(
        'anonymises shared rows, deletes personal data and the auth user',
        () async {
          final userId = await authUser('ravi@example.com');
          final volunteer = as(userId);
          await volunteerProfile(volunteer);
          final first = await publish();
          final second = await endpoints.fieldnote.createCampaignFromProposal(
            sponsor,
            _proposal(),
            _siteLatitude,
            _siteLongitude,
            'Second site',
            200,
          );
          final done = await endpoints.fieldnote.joinCampaign(
            volunteer,
            first.id!,
          );
          final open = await endpoints.fieldnote.joinCampaign(
            volunteer,
            second.id!,
          );
          final session = sessionBuilder.build();
          await CampaignParticipation.db.updateRow(
            session,
            done.copyWith(status: ParticipationStatus.completed),
          );
          final evidence = await CompletionEvidence.db.insertRow(
            session,
            CompletionEvidence(
              participationId: done.id!,
              photographPath: 'campaigns/1/participations/1/evidence.jpg',
              originalNote: 'Collected six bags near the bridge with Meera.',
              confirmedSummary: 'Collected six bags of litter.',
              structuredResults: '6 bags',
              latitude: _siteLatitude,
              longitude: _siteLongitude,
              locationAccuracyMeters: 8,
            ),
          );
          await CampaignInvitation.db.insertRow(
            session,
            CampaignInvitation(
              campaignId: second.id!,
              volunteerAuthUserId: UuidValue.withValidation(userId),
              sponsorAuthUserId: UuidValue.withValidation(_sponsorId),
            ),
          );

          expect(
            await endpoints.fieldnote.getAccountDeletionStatus(volunteer),
            isNull,
          );
          await endpoints.fieldnote.requestAccountDeletion(volunteer);
          await endpoints.fieldnote.requestAccountDeletion(volunteer);
          final pending = await endpoints.fieldnote.getAccountDeletionStatus(
            volunteer,
          );
          expect(pending!.status, AccountDeletionStatus.pending);
          expect(
            await AccountDeletionRequest.db.count(
              session,
              where: (t) =>
                  t.authUserId.equals(UuidValue.withValidation(userId)),
            ),
            1,
          );

          final run = await const AccountDeletionService().processDue(session);
          expect(run.completed, 1);

          final uuid = UuidValue.withValidation(userId);
          final status = await AccountDeletionRequest.db.findById(
            session,
            pending.id!,
          );
          expect(status!.status, AccountDeletionStatus.completed);
          expect(status.completedAt, isNotNull);

          // Personal rows are gone.
          expect(
            await FieldnoteUserProfile.db.findFirstRow(
              session,
              where: (t) => t.authUserId.equals(uuid),
            ),
            isNull,
          );
          expect(
            await VolunteerAvailability.db.count(
              session,
              where: (t) => t.volunteerAuthUserId.equals(uuid),
            ),
            0,
          );
          expect(
            await LegalConsent.db.count(
              session,
              where: (t) => t.authUserId.equals(uuid),
            ),
            0,
          );
          expect(
            await CampaignInvitation.db.count(
              session,
              where: (t) => t.volunteerAuthUserId.equals(uuid),
            ),
            0,
          );
          expect(await auth.AuthUser.db.findById(session, uuid), isNull);
          expect(
            await email_idp.EmailAccount.db.count(
              session,
              where: (t) => t.authUserId.equals(uuid),
            ),
            0,
          );

          // Shared rows stay, under one anonymous id.
          final kept = await CampaignParticipation.db.findById(
            session,
            done.id!,
          );
          final left = await CampaignParticipation.db.findById(
            session,
            open.id!,
          );
          expect(kept!.volunteerAuthUserId, isNot(uuid));
          expect(left!.status, ParticipationStatus.left);
          expect(left.volunteerAuthUserId, kept.volunteerAuthUserId);
          final anonymous = kept.volunteerAuthUserId;
          final profile = await FieldnoteUserProfile.db.findFirstRow(
            session,
            where: (t) => t.authUserId.equals(anonymous),
          );
          expect(profile!.displayName, 'Deleted user');
          expect(profile.contactPhone, isNull);
          expect(profile.interests, isEmpty);
          final redacted = await CompletionEvidence.db.findById(
            session,
            evidence.id!,
          );
          expect(redacted!.originalNote, isEmpty);
          expect(redacted.photographPath, isNull);
          expect(redacted.confirmedSummary, isNot(contains('six bags')));
          final history = await LegalConsentHistory.db.find(
            session,
            where: (t) => t.authUserId.equals(anonymous),
          );
          expect(history, isNotEmpty);
          expect(
            await AuditEvent.db.count(
              session,
              where: (t) => t.actorAuthUserId.equals(uuid),
            ),
            0,
          );

          // The confirmation email was captured before the login was deleted.
          final notice = await NotificationOutbox.db.findFirstRow(
            session,
            where: (t) => t.kind.equals(NotificationKind.accountDeleted),
          );
          expect(notice!.toEmail, 'ravi@example.com');
          await const NotificationService().deliverDue(session);
          expect(mailer.sent.single.to, 'ravi@example.com');
          final delivered = await NotificationOutbox.db.findById(
            session,
            notice.id!,
          );
          expect(delivered!.status, NotificationStatus.sent);
          expect(delivered.toEmail, isNull);

          // The old identity can no longer use FieldNote.
          await expectLater(
            endpoints.fieldnote.getCampaignMatches(volunteer),
            _throwsCode('profile_required'),
          );
        },
      );

      test('is refused while obligations are open', () async {
        final campaign = await publish();
        await expectLater(
          endpoints.fieldnote.requestAccountDeletion(sponsor),
          _throwsCode('deletion_blocked_open_campaign'),
        );
        expect(
          await endpoints.fieldnote.getAccountDeletionStatus(sponsor),
          isNull,
        );

        final volunteer = as('770e8400-e29b-41d4-a716-446655440001');
        await volunteerProfile(volunteer);
        final place = await endpoints.fieldnote.joinCampaign(
          volunteer,
          campaign.id!,
        );
        await CampaignParticipation.db.updateRow(
          sessionBuilder.build(),
          place.copyWith(status: ParticipationStatus.checkedIn),
        );
        await expectLater(
          endpoints.fieldnote.requestAccountDeletion(volunteer),
          _throwsCode('deletion_blocked_checked_in'),
        );

        // Cancelling settles the sponsor's obligation.
        await endpoints.fieldnote.cancelCampaign(sponsor, campaign.id!);
        await endpoints.fieldnote.requestAccountDeletion(sponsor);
        expect(
          (await endpoints.fieldnote.getAccountDeletionStatus(sponsor))!.status,
          AccountDeletionStatus.pending,
        );
      });
    });

    group('consent', () {
      test('withdrawal gates features and history is append-only', () async {
        await volunteerProfile(stranger);
        await endpoints.fieldnote.getCampaignMatches(stranger);
        final withdrawn = await endpoints.fieldnote.withdrawConsent(stranger);
        expect(withdrawn!.locationConsent, isFalse);
        await expectLater(
          endpoints.fieldnote.getCampaignMatches(stranger),
          _throwsCode('consent_required'),
        );
        await expectLater(
          endpoints.fieldnote.acceptLegalConsent(stranger, true, false, true),
          _throwsCode('consent_required'),
        );
        await expectLater(
          endpoints.fieldnote.acceptLegalConsent(
            stranger,
            true,
            true,
            true,
            acceptedPrivacyPolicyVersion: '2000-01-01',
          ),
          _throwsCode('consent_version_mismatch'),
        );
        await endpoints.fieldnote.acceptLegalConsent(
          stranger,
          true,
          true,
          true,
          acceptedPrivacyPolicyVersion: FieldnoteEndpoint.privacyPolicyVersion,
          acceptedTermsVersion: FieldnoteEndpoint.termsVersion,
        );
        await endpoints.fieldnote.getCampaignMatches(stranger);
        final history = await endpoints.fieldnote.listMyConsentHistory(
          stranger,
        );
        expect(history.map((item) => item.action).toList(), [
          'accepted',
          'withdrawn',
          'accepted',
        ]);
        expect(history[1].locationConsent, isFalse);
      });

      test('legal policies are public and use short-cache routes', () async {
        final policies = await endpoints.legal.getLegalPolicies(sessionBuilder);
        expect(
          policies.privacyPolicyVersion,
          FieldnoteEndpoint.privacyPolicyVersion,
        );
        expect(policies.privacyPolicyUrl, endsWith('/legal/privacy'));
        expect(policies.termsUrl, endsWith('/legal/terms'));
        expect(policies.requiredConsents, hasLength(3));
      });
    });

    group('volunteer map', () {
      test('unjoined volunteers only appear as k-anonymous buckets', () async {
        final campaign = await publish();
        final ids = [
          '770e8400-e29b-41d4-a716-446655440011',
          '770e8400-e29b-41d4-a716-446655440012',
          '770e8400-e29b-41d4-a716-446655440013',
          '770e8400-e29b-41d4-a716-446655440014',
        ];
        for (final (index, id) in ids.indexed) {
          await volunteerProfile(as(id), name: 'Secret Name $index');
        }
        await endpoints.fieldnote.joinCampaign(as(ids.first), campaign.id!);
        final map = await endpoints.fieldnote.getCampaignVolunteerMap(
          sponsor,
          campaign.id!,
        );
        final joined = map.volunteers.where((m) => m.status == 'joined');
        final buckets = map.volunteers.where((m) => m.volunteerCount != null);
        expect(joined.single.displayName, 'Secret Name 0');
        expect(buckets.single.volunteerCount, 3);
        expect(buckets.single.profileId, 0);
        expect(buckets.single.displayName, isEmpty);
        expect(
          map.volunteers.map((m) => m.displayName),
          isNot(contains('Secret Name 1')),
        );

        // Two unjoined volunteers are below k and disappear entirely.
        await endpoints.fieldnote.joinCampaign(as(ids[1]), campaign.id!);
        final smaller = await endpoints.fieldnote.getCampaignVolunteerMap(
          sponsor,
          campaign.id!,
        );
        expect(
          smaller.volunteers.where((m) => m.volunteerCount != null),
          isEmpty,
        );
        expect(smaller.volunteers, hasLength(2));
      });
    });

    group('campaign access', () {
      test('stream, posts and readiness are limited to the team', () async {
        final campaign = await publish();
        await volunteerProfile(stranger);
        final member = as('770e8400-e29b-41d4-a716-446655440021');
        await volunteerProfile(member, name: 'Meera Member');

        await expectLater(
          endpoints.fieldnote.watchCampaign(stranger, campaign.id!).first,
          _throwsCode('forbidden'),
        );
        await expectLater(
          endpoints.fieldnote.refreshCampaignReadiness(stranger, campaign.id!),
          _throwsCode('forbidden'),
        );
        // Public updates of an open campaign stay readable.
        await endpoints.fieldnote.listCampaignPosts(stranger, campaign.id!);

        final updates = StreamIterator(
          endpoints.fieldnote.watchCampaign(sponsor, campaign.id!),
        );
        expect(await updates.moveNext(), isTrue);
        expect(updates.current.event, 'connected');
        await Future<void>.delayed(const Duration(milliseconds: 300));
        await endpoints.fieldnote.joinCampaign(member, campaign.id!);
        expect(
          await updates.moveNext().timeout(const Duration(seconds: 5)),
          isTrue,
        );
        expect(updates.current.event, 'volunteerJoined');
        expect(updates.current.message, isNot(contains('Meera')));
        await updates.cancel();

        await endpoints.fieldnote.refreshCampaignReadiness(
          member,
          campaign.id!,
        );
        await endpoints.fieldnote.cancelCampaign(sponsor, campaign.id!);
        await expectLater(
          endpoints.fieldnote.listCampaignPosts(stranger, campaign.id!),
          _throwsCode('forbidden'),
        );
        expect(
          await endpoints.fieldnote.listCampaignPosts(member, campaign.id!),
          isNotEmpty,
        );
      });
    });

    group('rate limiting', () {
      test('fixed window rejects with a retry-after', () async {
        final session = sessionBuilder.build();
        final user = UuidValue.withValidation(_strangerId);
        const policy = RateLimitPolicy('test', 2, Duration(hours: 1));
        const limiter = RateLimiter();
        await limiter.hit(session, user, policy);
        await limiter.hit(session, user, policy);
        await expectLater(
          limiter.hit(session, user, policy),
          throwsA(
            isA<FieldnoteException>()
                .having((e) => e.code, 'code', 'rate_limited')
                .having((e) => e.retryAfterSeconds, 'retry', greaterThan(0)),
          ),
        );
        // Another action and another user have their own budgets.
        await limiter.hit(
          session,
          user,
          const RateLimitPolicy('other', 2, Duration(hours: 1)),
        );
        await limiter.hit(
          session,
          UuidValue.withValidation(_sponsorId),
          policy,
        );
      });

      test('data export is limited per day', () async {
        await volunteerProfile(stranger);
        for (var i = 0; i < RateLimits.dataExport.limit; i++) {
          await endpoints.fieldnote.exportMyData(stranger);
        }
        await expectLater(
          endpoints.fieldnote.exportMyData(stranger),
          _throwsCode('rate_limited'),
        );
      });
    });

    group('timezone-aware matching', () {
      DateTime istMorning(int daysAhead) {
        // 08:00 IST is 02:30 UTC.
        final day = DateTime.now().toUtc().add(Duration(days: daysAhead));
        return DateTime.utc(day.year, day.month, day.day, 2, 30);
      }

      test('a +05:30 volunteer matches an 08:00 IST campaign', () async {
        final startsAt = istMorning(3);
        final campaign = await publish(startsAt: startsAt);
        final istWeekday = startsAt.add(const Duration(minutes: 330)).weekday;
        await volunteerProfile(
          stranger,
          weekdays: [istWeekday],
          start: 7 * 60,
          end: 11 * 60,
          utcOffsetMinutes: 330,
        );
        final match = (await endpoints.fieldnote.getCampaignMatches(
          stranger,
        )).singleWhere((m) => m.campaign.id == campaign.id);
        expect(match.availabilityMatches, isTrue);

        // The same window read in UTC would not cover 02:30.
        final utcVolunteer = as('770e8400-e29b-41d4-a716-446655440031');
        await volunteerProfile(
          utcVolunteer,
          weekdays: [1, 2, 3, 4, 5, 6, 7],
          start: 7 * 60,
          end: 11 * 60,
          utcOffsetMinutes: 0,
        );
        final utcMatch = (await endpoints.fieldnote.getCampaignMatches(
          utcVolunteer,
        )).singleWhere((m) => m.campaign.id == campaign.id);
        expect(utcMatch.availabilityMatches, isFalse);
      });

      test('"I can help today" expires after its local date', () async {
        final utcNow = DateTime.now().toUtc();
        var offset = 600 - (utcNow.hour * 60 + utcNow.minute);
        if (offset < -720) offset += 1440;
        if (offset > 840) offset -= 1440;
        final local = utcNow.add(Duration(minutes: offset));
        await sponsorProfile(sponsor);
        final campaign = await endpoints.fieldnote.createCampaignFromProposal(
          sponsor,
          _proposal(
            startsAt: utcNow.add(const Duration(minutes: 5)),
            durationMinutes: 60,
          ),
          _siteLatitude,
          _siteLongitude,
          null,
          null,
        );
        final otherDay = local.weekday == 7 ? 1 : local.weekday + 1;
        await volunteerProfile(
          stranger,
          weekdays: [otherDay],
          availableToday: true,
          utcOffsetMinutes: offset,
        );
        expect(
          (await endpoints.fieldnote.getMyAvailability(
            stranger,
          ))!.availableToday,
          isTrue,
        );
        Future<bool> matches() async =>
            (await endpoints.fieldnote.getCampaignMatches(stranger))
                .singleWhere((m) => m.campaign.id == campaign.id)
                .availabilityMatches;
        expect(await matches(), isTrue);

        final session = sessionBuilder.build();
        final saved = await VolunteerAvailability.db.findFirstRow(
          session,
          where: (t) => t.volunteerAuthUserId.equals(
            UuidValue.withValidation(_strangerId),
          ),
        );
        await VolunteerAvailability.db.updateRow(
          session,
          saved!.copyWith(availableTodayDate: '2000-01-01'),
        );
        expect(
          (await endpoints.fieldnote.getMyAvailability(
            stranger,
          ))!.availableToday,
          isFalse,
        );
        expect(await matches(), isFalse);
      });

      test('availability input is validated', () async {
        await expectLater(
          volunteerProfile(stranger, weekdays: const []),
          _throwsCode('invalid_availability'),
        );
        await expectLater(
          volunteerProfile(stranger, weekdays: const [0, 8]),
          _throwsCode('invalid_availability'),
        );
        await expectLater(
          volunteerProfile(stranger, start: 600, end: 500),
          _throwsCode('invalid_availability'),
        );
        await expectLater(
          volunteerProfile(stranger, latitude: 95),
          _throwsCode('invalid_coordinates'),
        );
        await expectLater(
          volunteerProfile(stranger, utcOffsetMinutes: 2000),
          _throwsCode('invalid_timezone'),
        );
      });
    });

    group('full campaigns', () {
      test('are not matched unless the volunteer holds a place', () async {
        final campaign = await publish(capacity: 1);
        final holder = as('770e8400-e29b-41d4-a716-446655440041');
        await volunteerProfile(holder);
        await volunteerProfile(stranger);
        await endpoints.fieldnote.joinCampaign(holder, campaign.id!);
        final strangerMatches = await endpoints.fieldnote.getCampaignMatches(
          stranger,
        );
        expect(
          strangerMatches.where((m) => m.campaign.id == campaign.id),
          isEmpty,
        );
        final holderMatch = (await endpoints.fieldnote.getCampaignMatches(
          holder,
        )).singleWhere((m) => m.campaign.id == campaign.id);
        expect(holderMatch.isFull, isTrue);
      });
    });

    group('notifications', () {
      test('cancel enqueues one email per volunteer and delivers it', () async {
        final campaign = await publish();
        final userId = await authUser('meera@example.com');
        final volunteer = as(userId);
        await volunteerProfile(volunteer, name: 'Meera Volunteer');
        await endpoints.fieldnote.joinCampaign(volunteer, campaign.id!);
        await endpoints.fieldnote.cancelCampaign(sponsor, campaign.id!);
        await endpoints.fieldnote.cancelCampaign(sponsor, campaign.id!);
        final session = sessionBuilder.build();
        final cancelled = (await Campaign.db.findById(session, campaign.id!))!;
        // A retried producer is de-duplicated.
        await const NotificationService().campaignChanged(
          session,
          cancelled,
          NotificationKind.campaignCancelled,
        );
        final rows = await NotificationOutbox.db.find(
          session,
          where: (t) =>
              t.recipientAuthUserId.equals(UuidValue.withValidation(userId)),
        );
        expect(rows.single.kind, NotificationKind.campaignCancelled);
        expect(rows.single.bodyText, contains('Do not travel'));

        final result = await const NotificationService().deliverDue(session);
        expect(result.sent, 1);
        expect(mailer.sent.single.to, 'meera@example.com');
        expect(mailer.sent.single.subject, contains('Do not travel'));
        await const NotificationService().deliverDue(session);
        expect(mailer.sent, hasLength(1));
      });

      test('email times use each volunteer\'s own time zone', () async {
        // Saturday 2026-07-04 12:00 UTC: 08:00 EDT, 17:30 IST.
        final published = await publish();
        final campaign = await Campaign.db.updateRow(
          sessionBuilder.build(),
          published.copyWith(startsAt: DateTime.utc(2026, 7, 4, 12)),
        );
        final ny = as('770e8400-e29b-41d4-a716-446655440041');
        final ist = as('770e8400-e29b-41d4-a716-446655440042');
        await volunteerProfile(ny, name: 'Nia Volunteer');
        await volunteerProfile(ist, name: 'Isha Volunteer');
        await endpoints.fieldnote.updateAvailability(
          ny,
          true,
          false,
          [1, 2, 3, 4, 5, 6, 7],
          0,
          1440,
          10,
          _siteLatitude,
          _siteLongitude,
          'Pune area',
          timezone: 'America/New_York',
          utcOffsetMinutes: -300,
        );
        final session = sessionBuilder.build();
        for (final account in [ny, ist]) {
          final id = (await endpoints.fieldnote.getMyProfile(
            account,
          ))!.authUserId;
          await CampaignParticipation.db.insertRow(
            session,
            CampaignParticipation(
              campaignId: campaign.id!,
              volunteerAuthUserId: id,
              status: ParticipationStatus.joined,
            ),
          );
        }
        await const NotificationService().campaignChanged(
          session,
          campaign,
          NotificationKind.campaignConfirmed,
        );
        final rows = await NotificationOutbox.db.find(
          session,
          orderBy: (t) => t.id,
        );
        expect(rows, hasLength(2));
        expect(rows[0].bodyText, contains('2026-07-04 08:00 EDT'));
        expect(rows[1].bodyText, contains('2026-07-04 17:30 IST'));
      });

      test(
        'availability accepts IANA zones and ignores abbreviations',
        () async {
          final account = as('770e8400-e29b-41d4-a716-446655440043');
          await volunteerProfile(account);
          Future<VolunteerAvailability> save(String? zone) =>
              endpoints.fieldnote.updateAvailability(
                account,
                true,
                false,
                [6],
                480,
                720,
                10,
                _siteLatitude,
                _siteLongitude,
                'Pune area',
                timezone: zone,
                utcOffsetMinutes: -300,
              );
          expect((await save('America/New_York')).timezone, 'America/New_York');
          // An old client's abbreviation keeps the saved zone.
          expect((await save('EDT')).timezone, 'America/New_York');
          await expectLater(
            save('Mars/Olympus_Mons'),
            _throwsCode('invalid_timezone'),
          );
        },
      );

      test('opt-out and missing SMTP skip without failing', () async {
        final userId = await authUser('opt@example.com');
        final volunteer = as(userId);
        await volunteerProfile(volunteer);
        final profile = await endpoints.fieldnote.setEmailNotifications(
          volunteer,
          false,
        );
        expect(profile.emailNotifications, isFalse);
        final session = sessionBuilder.build();
        const service = NotificationService();
        await service.enqueue(
          session,
          recipient: UuidValue.withValidation(userId),
          kind: NotificationKind.invitationReceived,
          dedupeKey: 'invite:1',
          subject: 'Invite',
          text: 'Hello',
        );
        await service.deliverDue(session);
        expect(mailer.sent, isEmpty);
        final optedOut = await NotificationOutbox.db.findFirstRow(
          session,
          where: (t) => t.dedupeKey.equals('invite:1'),
        );
        expect(optedOut!.status, NotificationStatus.skipped);
        expect(optedOut.lastError, 'opted_out');

        await endpoints.fieldnote.setEmailNotifications(volunteer, true);
        NotificationRuntime.mailerResolver = (_) => null;
        await service.enqueue(
          session,
          recipient: UuidValue.withValidation(userId),
          kind: NotificationKind.invitationReceived,
          dedupeKey: 'invite:2',
          subject: 'Invite',
          text: 'Hello',
        );
        await service.deliverDue(session);
        final noSmtp = await NotificationOutbox.db.findFirstRow(
          session,
          where: (t) => t.dedupeKey.equals('invite:2'),
        );
        expect(noSmtp!.lastError, 'smtp_not_configured');
      });
    });

    group('share links', () {
      test('slug resolves open campaigns only and 404s otherwise', () async {
        final campaign = await publish();
        expect(campaign.shareSlug, matches(RegExp(r'^[A-Za-z0-9]{22}$')));
        final session = sessionBuilder.build();
        expect(
          (await CampaignShareRoute.resolve(session, campaign.shareSlug!))?.id,
          campaign.id,
        );
        expect(
          (await CampaignShareRoute.resolve(session, '${campaign.id}'))?.id,
          campaign.id,
        );
        expect(
          await CampaignShareRoute.resolve(session, 'unknownSlugValue123456'),
          isNull,
        );
        final link = await endpoints.fieldnote.getCampaignShareLink(
          sponsor,
          campaign.id!,
        );
        expect(link, endsWith('/c/${campaign.shareSlug}'));
        await volunteerProfile(stranger);
        expect(
          (await endpoints.fieldnote.getSharedCampaignBySlug(
            stranger,
            campaign.shareSlug!,
          ))?.id,
          campaign.id,
        );

        await endpoints.fieldnote.cancelCampaign(sponsor, campaign.id!);
        expect(
          await CampaignShareRoute.resolve(session, campaign.shareSlug!),
          isNull,
        );
        expect(
          await CampaignShareRoute.resolve(session, '${campaign.id}'),
          isNull,
        );
        expect(
          await endpoints.fieldnote.getSharedCampaignBySlug(
            stranger,
            campaign.shareSlug!,
          ),
          isNull,
        );
        await expectLater(
          endpoints.fieldnote.getCampaignShareLink(sponsor, campaign.id!),
          _throwsCode('campaign_unavailable'),
        );
      });

      test('well-known documents come from env and 404 when unset', () {
        FieldnoteConfig.environmentOverride = {};
        expect(WellKnownDocuments.assetLinks(), isNull);
        expect(WellKnownDocuments.appleAppSiteAssociation(), isNull);
        final fingerprint = List.filled(32, 'AB').join(':');
        FieldnoteConfig.environmentOverride = {
          'FIELDNOTE_ANDROID_PACKAGE': 'org.fieldnote.app',
          'FIELDNOTE_ANDROID_SHA256_CERT_FINGERPRINTS': '$fingerprint, bad',
          'FIELDNOTE_IOS_APP_ID': 'ABCDE12345.org.fieldnote.app',
        };
        final links = jsonDecode(WellKnownDocuments.assetLinks()!) as List;
        final target = (links.single as Map)['target'] as Map;
        expect(target['package_name'], 'org.fieldnote.app');
        expect(target['sha256_cert_fingerprints'], [fingerprint]);
        final aasa =
            jsonDecode(WellKnownDocuments.appleAppSiteAssociation()!) as Map;
        expect(
          ((aasa['applinks'] as Map)['details'] as List).single['appIDs'],
          ['ABCDE12345.org.fieldnote.app'],
        );
        expect(FieldnoteConfig.playStoreUrl, contains('org.fieldnote.app'));
      });
    });
  });
}
