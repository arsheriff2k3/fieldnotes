import 'dart:convert';

import 'package:fieldnotes_server/src/fieldnotes/services/payment_credit_service.dart';
import 'package:fieldnotes_server/src/generated/protocol.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

CampaignProposal _campaignProposal() => CampaignProposal(
  title: 'Campus Tree Care Day',
  description: 'Care for young trees and document the completed work.',
  locationName: 'University Campus',
  startsAt: DateTime.now().toUtc().add(const Duration(days: 2)),
  durationMinutes: 180,
  volunteerCapacity: 12,
  fundingGoal: 30000,
  requiredSkills: ['No specialist skills', 'Comfortable outdoors'],
  checklist: ['Water trees', 'Repair guards', 'Clear waste'],
  evidenceInstructions: 'Submit a location-verified photograph and note.',
  tags: ['tree care', 'environment', 'outdoors'],
  rationale: 'Sponsor-confirmed campaign details.',
);

void main() {
  withServerpod('Given sponsor and volunteer accounts', (
    sessionBuilder,
    endpoints,
  ) {
    final sponsor = sessionBuilder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(
        '550e8400-e29b-41d4-a716-446655440000',
        {},
      ),
    );
    final volunteer = sessionBuilder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(
        '550e8400-e29b-41d4-a716-446655440001',
        {},
      ),
    );
    final secondVolunteer = sessionBuilder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(
        '550e8400-e29b-41d4-a716-446655440002',
        {},
      ),
    );

    test('account export includes own campaigns and volunteer joins', () async {
      await endpoints.fieldnote.completeSponsorProfile(
        sponsor,
        'Asha Sponsor',
        'Individual',
        null,
        'Pune',
        null,
        ['environment'],
        contactPhone: '+919876543210',
      );
      await endpoints.fieldnote.acceptLegalConsent(sponsor, true, true, true);
      await endpoints.fieldnote.completeVolunteerProfile(
        volunteer,
        'Volunteer',
        'Pune',
        ['environment'],
        ['outdoors'],
        true,
        true,
        [DateTime.monday],
        420,
        780,
        10,
        18.5204,
        73.8567,
        'Pune',
      );
      await endpoints.fieldnote.acceptLegalConsent(volunteer, true, true, true);
      final campaign = await endpoints.fieldnote.createCampaignFromProposal(
        sponsor,
        _campaignProposal(),
        18.5204,
        73.8567,
        'Pune work site',
        200,
      );
      await endpoints.fieldnote.joinCampaign(volunteer, campaign.id!);

      final sponsorExport =
          jsonDecode(
                await endpoints.fieldnote.exportMyData(sponsor),
              )
              as Map<String, dynamic>;
      final volunteerExport =
          jsonDecode(
                await endpoints.fieldnote.exportMyData(volunteer),
              )
              as Map<String, dynamic>;

      expect(sponsorExport['formatVersion'], 2);
      expect((sponsorExport['createdCampaigns'] as List).length, 1);
      expect(sponsorExport['participations'], isEmpty);
      expect((volunteerExport['participations'] as List).length, 1);
      expect(volunteerExport['createdCampaigns'], isEmpty);
      expect(volunteerExport['availability'], isNotNull);
      expect(volunteerExport['securityActivity'], isNotEmpty);
    });

    test('one remaining place admits only one volunteer', () async {
      await endpoints.fieldnote.completeSponsorProfile(
        sponsor,
        'Asha Sponsor',
        'Individual',
        null,
        'Pune',
        null,
        ['environment'],
        contactPhone: '+919876543210',
      );
      await endpoints.fieldnote.acceptLegalConsent(sponsor, true, true, true);
      for (final account in [volunteer, secondVolunteer]) {
        await endpoints.fieldnote.completeVolunteerProfile(
          account,
          'Volunteer',
          'Pune',
          ['environment'],
          ['outdoors'],
          true,
          true,
          [DateTime.monday],
          420,
          780,
          10,
          18.5204,
          73.8567,
          'Pune',
        );
        await endpoints.fieldnote.acceptLegalConsent(account, true, true, true);
      }
      final campaign = await endpoints.fieldnote.createCampaignFromProposal(
        sponsor,
        _campaignProposal().copyWith(volunteerCapacity: 1),
        18.5204,
        73.8567,
        'Pune work site',
        200,
      );
      final joined = await endpoints.fieldnote.joinCampaign(
        volunteer,
        campaign.id!,
      );
      final repeated = await endpoints.fieldnote.joinCampaign(
        volunteer,
        campaign.id!,
      );
      expect(repeated.id, joined.id);
      await expectLater(
        endpoints.fieldnote.joinCampaign(secondVolunteer, campaign.id!),
        throwsA(
          isA<FieldnoteException>().having(
            (error) => error.code,
            'code',
            'campaign_full',
          ),
        ),
      );
    });

    test(
      'cancelled campaigns cannot provide volunteer travel routes',
      () async {
        await endpoints.fieldnote.completeSponsorProfile(
          sponsor,
          'Asha Sponsor',
          'Individual',
          null,
          'Pune',
          null,
          ['environment'],
          contactPhone: '+919876543210',
        );
        await endpoints.fieldnote.acceptLegalConsent(sponsor, true, true, true);
        await endpoints.fieldnote.completeVolunteerProfile(
          volunteer,
          'Volunteer',
          'Pune',
          ['environment'],
          ['outdoors'],
          true,
          true,
          [DateTime.monday],
          420,
          780,
          10,
          18.5204,
          73.8567,
          'Pune',
        );
        await endpoints.fieldnote.acceptLegalConsent(
          volunteer,
          true,
          true,
          true,
        );
        final campaign = await endpoints.fieldnote.createCampaignFromProposal(
          sponsor,
          _campaignProposal(),
          18.5204,
          73.8567,
          'Pune work site',
          200,
        );
        await endpoints.fieldnote.cancelCampaign(sponsor, campaign.id!);
        await expectLater(
          endpoints.fieldnote.getTravelRoute(
            volunteer,
            campaign.id!,
            18.5204,
            73.8567,
            'WALK',
          ),
          throwsA(
            isA<FieldnoteException>().having(
              (error) => error.code,
              'code',
              'campaign_unavailable',
            ),
          ),
        );
      },
    );

    test('volunteer can choose a map area before creating a profile', () async {
      final place = await endpoints.fieldnote.describeCoordinates(
        volunteer,
        18.52040,
        73.85670,
      );
      expect(place, isNull);
    });

    test('sponsor profile keeps an exact custom map pin', () async {
      final profile = await endpoints.fieldnote.completeSponsorProfile(
        sponsor,
        'Asha Sponsor',
        'Individual',
        null,
        'Pollachi work site',
        null,
        ['environment'],
        locationLatitude: 10.6629,
        locationLongitude: 77.0067,
        contactPhone: '+919876543210',
      );
      expect(profile.locationLatitude, 10.6629);
      expect(profile.locationLongitude, 77.0067);
      expect(profile.locationAddress, 'Pollachi work site');
    });

    test('sponsor profile requires a contact phone', () async {
      await expectLater(
        endpoints.fieldnote.completeSponsorProfile(
          sponsor,
          'Asha Sponsor',
          'Individual',
          null,
          'Pune',
          null,
          ['environment'],
        ),
        throwsA(
          isA<FieldnoteException>().having(
            (error) => error.code,
            'code',
            'invalid_contact_phone',
          ),
        ),
      );
    });

    test('sponsor publishes and reads impact', () async {
      final profile = await endpoints.fieldnote.completeSponsorProfile(
        sponsor,
        'Asha Sponsor',
        'Company',
        'Asha Foundation',
        'Pune',
        null,
        ['environment', 'tree care'],
        contactPhone: '+919876543210',
      );
      await endpoints.fieldnote.acceptLegalConsent(
        sponsor,
        true,
        true,
        true,
      );
      final proposal = _campaignProposal();
      final campaign = await endpoints.fieldnote.createCampaignFromProposal(
        sponsor,
        proposal,
        18.52040,
        73.85670,
        'Pashan Lake north bank',
        350,
      );
      final impact = await endpoints.fieldnote.getImpact(
        sponsor,
        campaign.id!,
      );

      expect(profile.role, AccountRole.sponsor);
      expect(proposal.volunteerCapacity, 12);
      expect(proposal.fundingGoal, 30000);
      expect(campaign.aiGenerated, isTrue);
      expect(impact.sponsorshipTotal, 0);
      expect(impact.completedVolunteers, 0);
      expect(campaign.locationName, 'Pashan Lake north bank');
      expect(campaign.geofenceMeters, 350);
    });

    test('manual campaign is not marked as AI generated', () async {
      await endpoints.fieldnote.completeSponsorProfile(
        sponsor,
        'Asha Sponsor',
        'Individual',
        null,
        'Pune',
        null,
        ['trees'],
        contactPhone: '+919876543210',
      );
      await endpoints.fieldnote.acceptLegalConsent(sponsor, true, true, true);
      final campaign = await endpoints.fieldnote.createCampaignFromProposal(
        sponsor,
        _campaignProposal().copyWith(
          rationale:
              'Entered manually by the sponsor. No AI model produced these details.',
        ),
        18.52040,
        73.85670,
        null,
        null,
      );
      expect(campaign.aiGenerated, isFalse);
    });

    test(
      'cutoff separates team and funding shortages and keeps revisions tentative',
      () async {
        await endpoints.fieldnote.completeSponsorProfile(
          sponsor,
          'Asha Sponsor',
          'Individual',
          null,
          'Pune',
          null,
          ['trees'],
          contactPhone: '+919876543210',
        );
        await endpoints.fieldnote.acceptLegalConsent(sponsor, true, true, true);
        final campaign = await endpoints.fieldnote.createCampaignFromProposal(
          sponsor,
          _campaignProposal().copyWith(minimumVolunteers: 2),
          18.52040,
          73.85670,
          null,
          null,
        );
        await endpoints.fieldnote.completeVolunteerProfile(
          volunteer,
          'Ravi Volunteer',
          'Pune',
          ['trees'],
          ['outdoors'],
          true,
          true,
          [1, 2, 3, 4, 5, 6, 7],
          0,
          1439,
          10,
          18.52040,
          73.85670,
          'Current GPS area',
        );
        await endpoints.fieldnote.acceptLegalConsent(
          volunteer,
          true,
          true,
          true,
        );
        final joined = await endpoints.fieldnote.joinCampaign(
          volunteer,
          campaign.id!,
        );
        final stored = (await Campaign.db.findById(
          sponsor.build(),
          campaign.id!,
        ))!;
        stored.startsAt = DateTime.now().toUtc().add(
          const Duration(minutes: 30),
        );
        await Campaign.db.updateRow(sponsor.build(), stored);
        final assessed = await endpoints.fieldnote.refreshCampaignReadiness(
          sponsor,
          campaign.id!,
        );
        expect(assessed.readinessState, 'bothShort');
        final revised = await endpoints.fieldnote.reviseCampaignScope(
          sponsor,
          campaign.id!,
          1000,
          1,
          'Plant only the first row of trees with the smaller team.',
        );
        expect(revised.revision, 1);
        expect(revised.readinessState, 'bothShort');
        final reconfirmed = await endpoints.fieldnote
            .reconfirmCampaignParticipation(volunteer, joined.id!);
        expect(reconfirmed.confirmedRevision, 1);
        expect(
          (await endpoints.fieldnote.refreshCampaignReadiness(
            sponsor,
            campaign.id!,
          )).readinessState,
          'fundingShort',
        );
        final cancelled = await endpoints.fieldnote.cancelCampaign(
          sponsor,
          campaign.id!,
        );
        expect(cancelled.readinessState, 'cancelled');
        expect(
          (await endpoints.fieldnote.listCampaigns(
            volunteer,
          )).any((item) => item.id == campaign.id),
          isFalse,
        );
        expect(
          (await endpoints.fieldnote.listMyJoinedCampaigns(
            volunteer,
          )).any((item) => item.id == campaign.id),
          isTrue,
        );
      },
    );

    test(
      'ready cutoff confirms once and cancellation records test refunds once',
      () async {
        await endpoints.fieldnote.completeSponsorProfile(
          sponsor,
          'Asha Sponsor',
          'Individual',
          null,
          'Pune',
          null,
          ['trees'],
          contactPhone: '+919876543210',
        );
        await endpoints.fieldnote.acceptLegalConsent(sponsor, true, true, true);
        final campaign = await endpoints.fieldnote.createCampaignFromProposal(
          sponsor,
          _campaignProposal().copyWith(minimumVolunteers: 1),
          18.52040,
          73.85670,
          null,
          null,
        );
        await endpoints.fieldnote.completeVolunteerProfile(
          volunteer,
          'Ravi Volunteer',
          'Pune',
          ['trees'],
          ['outdoors'],
          true,
          true,
          [1, 2, 3, 4, 5, 6, 7],
          0,
          1439,
          10,
          18.52040,
          73.85670,
          'Current GPS area',
        );
        await endpoints.fieldnote.acceptLegalConsent(
          volunteer,
          true,
          true,
          true,
        );
        await endpoints.fieldnote.joinCampaign(volunteer, campaign.id!);
        final session = sponsor.build();
        final stored = (await Campaign.db.findById(session, campaign.id!))!;
        stored.startsAt = DateTime.now().toUtc().add(
          const Duration(minutes: 30),
        );
        stored.sponsoredAmount = stored.fundingGoal;
        await Campaign.db.updateRow(session, stored);
        final sponsorship = await Sponsorship.db.insertRow(
          session,
          Sponsorship(
            campaignId: campaign.id!,
            sponsorAuthUserId: stored.createdBy,
            amount: stored.fundingGoal,
            paymentStatus: 'verified',
            providerOrderId: 'order_readiness',
            providerPaymentId: 'pay_readiness',
          ),
        );
        expect(
          (await endpoints.fieldnote.refreshCampaignReadiness(
            sponsor,
            campaign.id!,
          )).readinessState,
          'confirmed',
        );
        await endpoints.fieldnote.refreshCampaignReadiness(
          sponsor,
          campaign.id!,
        );
        final posts = await CampaignPost.db.find(
          session,
          where: (t) => t.campaignId.equals(campaign.id!),
        );
        expect(posts.length, 1);
        await endpoints.fieldnote.cancelCampaign(sponsor, campaign.id!);
        await endpoints.fieldnote.cancelCampaign(sponsor, campaign.id!);
        final refunds = await TestRefund.db.find(
          session,
          where: (t) => t.campaignId.equals(campaign.id!),
        );
        expect(refunds.length, 1);
        expect(refunds.single.sponsorshipId, sponsorship.id);
        expect(refunds.single.status, 'refund_due_test');
      },
    );

    test('only the creator can read test payout records', () async {
      await endpoints.fieldnote.completeSponsorProfile(
        sponsor,
        'Asha Sponsor',
        'Individual',
        null,
        'Pune',
        null,
        ['trees'],
        contactPhone: '+919876543210',
      );
      await endpoints.fieldnote.acceptLegalConsent(sponsor, true, true, true);
      final campaign = await endpoints.fieldnote.createCampaignFromProposal(
        sponsor,
        _campaignProposal(),
        18.52040,
        73.85670,
        null,
        null,
      );
      expect(
        await endpoints.fieldnote.listCampaignTestPayouts(
          sponsor,
          campaign.id!,
        ),
        isEmpty,
      );
      await endpoints.fieldnote.completeVolunteerProfile(
        volunteer,
        'Ravi Volunteer',
        'Pune',
        ['trees'],
        ['outdoors'],
        true,
        true,
        [1, 2, 3, 4, 5, 6, 7],
        0,
        1439,
        10,
        18.52040,
        73.85670,
        'Current GPS area',
      );
      await expectLater(
        endpoints.fieldnote.listCampaignTestPayouts(
          volunteer,
          campaign.id!,
        ),
        throwsA(isA<FieldnoteException>()),
      );
    });

    test('private impact and evidence deny unrelated accounts', () async {
      await endpoints.fieldnote.completeSponsorProfile(
        sponsor,
        'Asha Sponsor',
        'Individual',
        null,
        'Pune',
        null,
        ['trees'],
        contactPhone: '+919876543210',
      );
      await endpoints.fieldnote.acceptLegalConsent(sponsor, true, true, true);
      final campaign = await endpoints.fieldnote.createCampaignFromProposal(
        sponsor,
        _campaignProposal(),
        18.52040,
        73.85670,
        null,
        null,
      );
      await endpoints.fieldnote.completeVolunteerProfile(
        volunteer,
        'Ravi Volunteer',
        'Pune',
        ['trees'],
        ['outdoors'],
        true,
        true,
        [1, 2, 3, 4, 5, 6, 7],
        0,
        1439,
        10,
        18.52040,
        73.85670,
        'Current GPS area',
      );
      await endpoints.fieldnote.acceptLegalConsent(volunteer, true, true, true);
      await expectLater(
        endpoints.fieldnote.getCampaignContactPhone(volunteer, campaign.id!),
        throwsA(isA<FieldnoteException>()),
      );
      final participation = await endpoints.fieldnote.joinCampaign(
        volunteer,
        campaign.id!,
      );
      expect(
        await endpoints.fieldnote.getCampaignContactPhone(
          volunteer,
          campaign.id!,
        ),
        '+919876543210',
      );
      await endpoints.fieldnote.updateMyProfile(
        sponsor,
        'Asha Sponsor',
        'Individual',
        null,
        'Pune',
        null,
        ['trees'],
        const [],
        contactPhone: '+919876543299',
      );
      expect(
        await endpoints.fieldnote.getCampaignContactPhone(
          volunteer,
          campaign.id!,
        ),
        '+919876543299',
      );
      final evidence = await CompletionEvidence.db.insertRow(
        sponsor.build(),
        CompletionEvidence(
          participationId: participation.id!,
          photographPath: 'private-test-photo.jpg',
          originalNote: 'Private volunteer note',
          confirmedSummary: 'Private completed work',
          structuredResults: 'Private result',
          latitude: 18.52040,
          longitude: 73.85670,
          locationAccuracyMeters: 8,
          locationIntegrityStatus: 'verified',
          locationIntegrityReasons: 'test',
          locationIsDemo: false,
          moderationStatus: 'passed',
        ),
      );
      expect(
        (await endpoints.fieldnote.getImpact(
          sponsor,
          campaign.id!,
        )).evidenceCount,
        1,
      );
      final unrelated = sessionBuilder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(
          '550e8400-e29b-41d4-a716-446655440002',
          {},
        ),
      );
      await endpoints.fieldnote.completeSponsorProfile(
        unrelated,
        'Other Sponsor',
        'Individual',
        null,
        'Pune',
        null,
        [],
        contactPhone: '+919876543210',
      );
      await endpoints.fieldnote.acceptLegalConsent(
        unrelated,
        true,
        true,
        true,
      );
      await expectLater(
        endpoints.fieldnote.getImpact(unrelated, campaign.id!),
        throwsA(isA<FieldnoteException>()),
      );
      await expectLater(
        endpoints.fieldnote.getEvidenceDownloadUrl(unrelated, evidence.id!),
        throwsA(isA<FieldnoteException>()),
      );
      await expectLater(
        endpoints.fieldnote.getImpact(volunteer, campaign.id!),
        throwsA(isA<FieldnoteException>()),
      );
      final otherId = (await endpoints.fieldnote.getMyProfile(
        unrelated,
      ))!.authUserId;
      await Sponsorship.db.insertRow(
        unrelated.build(),
        Sponsorship(
          campaignId: campaign.id!,
          sponsorAuthUserId: otherId,
          amount: 100,
          paymentStatus: 'verified',
          providerOrderId: 'order_test_sponsor_access',
        ),
      );
      expect(
        (await endpoints.fieldnote.getImpact(
          unrelated,
          campaign.id!,
        )).evidenceCount,
        1,
      );
    });

    test('verified orders cannot credit more than the funding goal', () async {
      await endpoints.fieldnote.completeSponsorProfile(
        sponsor,
        'Asha Sponsor',
        'Individual',
        null,
        'Pune',
        null,
        [],
        contactPhone: '+919876543210',
      );
      await endpoints.fieldnote.acceptLegalConsent(sponsor, true, true, true);
      final campaign = await endpoints.fieldnote.createCampaignFromProposal(
        sponsor,
        _campaignProposal(),
        18.52040,
        73.85670,
        null,
        null,
      );
      final session = sponsor.build();
      final sponsorId = (await endpoints.fieldnote.getMyProfile(
        sponsor,
      ))!.authUserId;
      final first = await Sponsorship.db.insertRow(
        session,
        Sponsorship(
          campaignId: campaign.id!,
          sponsorAuthUserId: sponsorId,
          amount: 20000,
          paymentStatus: 'created',
          providerOrderId: 'order_test_first',
        ),
      );
      final second = await Sponsorship.db.insertRow(
        session,
        Sponsorship(
          campaignId: campaign.id!,
          sponsorAuthUserId: sponsorId,
          amount: 20000,
          paymentStatus: 'created',
          providerOrderId: 'order_test_second',
        ),
      );
      const credits = PaymentCreditService();
      final firstCredit = await credits.credit(
        session,
        sponsorshipId: first.id!,
        campaignId: campaign.id!,
        sponsorAuthUserId: sponsorId,
        orderId: 'order_test_first',
        paymentId: 'pay_testfirst',
      );
      final repeatedCredit = await credits.credit(
        session,
        sponsorshipId: first.id!,
        campaignId: campaign.id!,
        sponsorAuthUserId: sponsorId,
        orderId: 'order_test_first',
        paymentId: 'pay_testfirst',
      );
      final secondCredit = await credits.credit(
        session,
        sponsorshipId: second.id!,
        campaignId: campaign.id!,
        sponsorAuthUserId: sponsorId,
        orderId: 'order_test_second',
        paymentId: 'pay_testsecond',
      );
      final updatedCampaign = await Campaign.db.findById(session, campaign.id!);
      final updatedSecond = await Sponsorship.db.findById(session, second.id!);
      expect(updatedCampaign!.sponsoredAmount, 20000);
      expect(updatedSecond!.paymentStatus, 'verified_uncredited');
      expect(firstCredit.uncredited, isFalse);
      expect(repeatedCredit.alreadyVerified, isTrue);
      expect(secondCredit.uncredited, isTrue);
      final lateFailure = await credits.markFailed(
        session,
        sponsorshipId: first.id!,
        sponsorAuthUserId: sponsorId,
        status: 'failed',
      );
      expect(lateFailure.paymentStatus, 'verified');
    });

    test('check-in cannot undo a completed participation', () async {
      await endpoints.fieldnote.completeSponsorProfile(
        sponsor,
        'Asha Sponsor',
        'Individual',
        null,
        'Pune',
        null,
        [],
        contactPhone: '+919876543210',
      );
      await endpoints.fieldnote.acceptLegalConsent(sponsor, true, true, true);
      final campaign = await endpoints.fieldnote.createCampaignFromProposal(
        sponsor,
        _campaignProposal(),
        18.52040,
        73.85670,
        null,
        null,
      );
      await endpoints.fieldnote.completeVolunteerProfile(
        volunteer,
        'Ravi Volunteer',
        'Pune',
        [],
        [],
        true,
        true,
        [1, 2, 3, 4, 5, 6, 7],
        0,
        1439,
        10,
        18.52040,
        73.85670,
        'Current GPS area',
      );
      await endpoints.fieldnote.acceptLegalConsent(volunteer, true, true, true);
      final participation = await endpoints.fieldnote.joinCampaign(
        volunteer,
        campaign.id!,
      );
      participation.status = ParticipationStatus.completed;
      participation.completedAt = DateTime.now().toUtc();
      await CampaignParticipation.db.updateRow(
        volunteer.build(),
        participation,
      );
      final repeated = await endpoints.fieldnote.checkIn(
        volunteer,
        participation.id!,
        18.52040,
        73.85670,
        8,
        false,
        false,
        DateTime.now().toUtc(),
      );
      expect(repeated.status, ParticipationStatus.completed);
    });

    test('available today matches outside recurring weekdays', () async {
      await endpoints.fieldnote.completeSponsorProfile(
        sponsor,
        'Asha Sponsor',
        'Individual',
        null,
        'Pune',
        null,
        [],
        contactPhone: '+919876543210',
      );
      await endpoints.fieldnote.acceptLegalConsent(sponsor, true, true, true);
      final now = DateTime.now();
      final laterToday = now.add(const Duration(minutes: 1));
      final campaign = await endpoints.fieldnote.createCampaignFromProposal(
        sponsor,
        _campaignProposal().copyWith(startsAt: laterToday.toUtc()),
        18.52040,
        73.85670,
        null,
        null,
      );
      final otherDay = now.weekday == 7 ? 1 : now.weekday + 1;
      await endpoints.fieldnote.completeVolunteerProfile(
        volunteer,
        'Ravi Volunteer',
        'Pune',
        [],
        [],
        true,
        true,
        [otherDay],
        0,
        1439,
        10,
        18.52040,
        73.85670,
        'Current GPS area',
      );
      await endpoints.fieldnote.acceptLegalConsent(volunteer, true, true, true);
      final matches = await endpoints.fieldnote.getCampaignMatches(volunteer);
      expect(
        matches
            .singleWhere((match) => match.campaign.id == campaign.id)
            .availabilityMatches,
        isTrue,
      );
    });

    test('profile details update without changing role or consent', () async {
      await endpoints.fieldnote.completeSponsorProfile(
        sponsor,
        'Asha Sponsor',
        'Individual',
        null,
        'Pune',
        null,
        ['environment'],
        contactPhone: '+919876543210',
      );
      final consent = await endpoints.fieldnote.acceptLegalConsent(
        sponsor,
        true,
        true,
        true,
      );

      final updated = await endpoints.fieldnote.updateMyProfile(
        sponsor,
        'Asha Foundation',
        'Foundation',
        'FieldNote Foundation',
        'Mumbai',
        null,
        ['tree care', 'community'],
        ['photography'],
        contactPhone: '+919876543299',
      );
      final unchangedConsent = await endpoints.fieldnote.getMyLegalConsent(
        sponsor,
      );

      expect(updated.role, AccountRole.sponsor);
      expect(updated.displayName, 'Asha Foundation');
      expect(updated.sponsorType, 'Foundation');
      expect(updated.organizationName, 'FieldNote Foundation');
      expect(updated.contactPhone, '+919876543299');
      expect(updated.city, 'Mumbai');
      expect(updated.interests, 'tree care | community');
      expect(updated.skills, isEmpty);
      expect(unchangedConsent?.id, consent.id);
      expect(unchangedConsent?.locationConsent, isTrue);
      expect(unchangedConsent?.aiProcessingConsent, isTrue);
      expect(unchangedConsent?.evidenceSharingConsent, isTrue);
    });

    test(
      'volunteer profile and creation preferences remain editable',
      () async {
        await endpoints.fieldnote.completeVolunteerProfile(
          volunteer,
          'Ravi Volunteer',
          'Pune',
          ['environment'],
          ['outdoors'],
          true,
          false,
          [6, 7],
          420,
          780,
          10,
          18.52,
          73.85,
          'Current GPS area',
        );
        await endpoints.fieldnote.acceptLegalConsent(
          volunteer,
          true,
          true,
          true,
        );

        final profile = await endpoints.fieldnote.updateMyProfile(
          volunteer,
          'Ravi Patil',
          'Company',
          'Ignored organization',
          'Nashik',
          null,
          ['cleanup'],
          ['organizing', 'photography'],
          contactPhone: '+91 98765 43211',
        );
        final availability = await endpoints.fieldnote.updateAvailability(
          volunteer,
          false,
          true,
          [1, 3, 5],
          420,
          780,
          24,
          19.99,
          73.78,
          'Current GPS area',
        );

        expect(profile.role, AccountRole.volunteer);
        expect(profile.sponsorType, isNull);
        expect(profile.organizationName, isNull);
        expect(profile.contactPhone, '+919876543211');
        expect(profile.city, 'Nashik');
        expect(profile.skills, 'organizing | photography');
        expect(availability.isAvailable, isFalse);
        expect(availability.availableToday, isTrue);
        expect(availability.weekdays, '1,3,5');
        expect(availability.maximumTravelKm, 24);

        final cleared = await endpoints.fieldnote.updateMyProfile(
          volunteer,
          'Ravi Patil',
          null,
          null,
          'Nashik',
          null,
          ['cleanup'],
          ['organizing', 'photography'],
          contactPhone: '',
        );
        expect(cleared.contactPhone, isNull);
      },
    );

    test('map pin overrides are validated and bounded', () async {
      await endpoints.fieldnote.completeSponsorProfile(
        sponsor,
        'Asha Sponsor',
        'Company',
        'Asha Foundation',
        'Pune',
        null,
        ['environment'],
        contactPhone: '+919876543210',
      );
      await endpoints.fieldnote.acceptLegalConsent(sponsor, true, true, true);
      final proposal = _campaignProposal();

      await expectLater(
        endpoints.fieldnote.createCampaignFromProposal(
          sponsor,
          proposal,
          120.0,
          73.85670,
          null,
          null,
        ),
        throwsA(isA<FieldnoteException>()),
      );

      // A blank name falls back to the proposal, and an absurd geofence is
      // clamped rather than published as-is.
      final campaign = await endpoints.fieldnote.createCampaignFromProposal(
        sponsor,
        proposal,
        18.52040,
        73.85670,
        '   ',
        99999,
      );
      expect(campaign.locationName, proposal.locationName.trim());
      expect(campaign.geofenceMeters, 2000);
    });

    test('reach preview counts only volunteers who could travel', () async {
      await endpoints.fieldnote.completeSponsorProfile(
        sponsor,
        'Asha Sponsor',
        'Company',
        'Asha Foundation',
        'Pune',
        null,
        ['environment'],
        contactPhone: '+919876543210',
      );
      await endpoints.fieldnote.acceptLegalConsent(sponsor, true, true, true);
      await endpoints.fieldnote.completeVolunteerProfile(
        volunteer,
        'Vik Volunteer',
        'Pune',
        ['environment'],
        ['outdoors'],
        true,
        true,
        [1, 2, 3, 4, 5, 6, 7],
        0,
        1439,
        10,
        18.52040,
        73.85670,
        'Current GPS area',
      );
      await endpoints.fieldnote.acceptLegalConsent(volunteer, true, true, true);

      final near = await endpoints.fieldnote.previewCampaignReach(
        sponsor,
        18.52040,
        73.85670,
      );
      expect(near.volunteersInRange, 1);
      expect(near.nearestDistanceKm, closeTo(0, 0.01));

      // Mumbai is far outside a 10 km radius from Pune.
      final far = await endpoints.fieldnote.previewCampaignReach(
        sponsor,
        19.07600,
        72.87770,
      );
      expect(far.volunteersInRange, 0);
      expect(far.nearestDistanceKm, isNull);

      // A single volunteer never reaches the anonymity threshold, so no
      // coverage cell may be emitted.
      expect(near.coverageCells, isEmpty);
    });

    test('creator invites a visible area once and volunteers see it', () async {
      await endpoints.fieldnote.completeSponsorProfile(
        sponsor,
        'Asha Sponsor',
        'Individual',
        null,
        'Pune',
        null,
        ['environment'],
        contactPhone: '+919876543210',
      );
      await endpoints.fieldnote.acceptLegalConsent(sponsor, true, true, true);
      final accounts = [
        volunteer,
        secondVolunteer,
        sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            '550e8400-e29b-41d4-a716-446655440003',
            {},
          ),
        ),
      ];
      for (final account in accounts) {
        await endpoints.fieldnote.completeVolunteerProfile(
          account,
          'Nearby Volunteer',
          'Pune',
          ['environment'],
          ['outdoors'],
          true,
          true,
          [1, 2, 3, 4, 5, 6, 7],
          0,
          1439,
          10,
          18.5204,
          73.8567,
          'Pune area',
        );
        await endpoints.fieldnote.acceptLegalConsent(account, true, true, true);
      }
      final campaign = await endpoints.fieldnote.createCampaignFromProposal(
        sponsor,
        _campaignProposal(),
        18.5204,
        73.8567,
        'Pune work site',
        200,
      );
      final reach = await endpoints.fieldnote.getCampaignVolunteerReach(
        sponsor,
        campaign.id!,
      );
      expect(reach.volunteersInRange, 3);
      expect(reach.coverageCells.single.volunteerCount, 3);
      expect(reach.nearestDistanceKm, isNull);
      final area = reach.coverageCells.single;
      expect(
        await endpoints.fieldnote.inviteCampaignVolunteersInArea(
          sponsor,
          campaign.id!,
          area.latitude,
          area.longitude,
        ),
        3,
      );
      expect(
        await endpoints.fieldnote.inviteCampaignVolunteersInArea(
          sponsor,
          campaign.id!,
          area.latitude,
          area.longitude,
        ),
        0,
      );
      for (final account in accounts) {
        final invitations = await endpoints.fieldnote.listMyCampaignInvitations(
          account,
        );
        expect(invitations.single.campaignId, campaign.id);
      }
      await endpoints.fieldnote.joinCampaign(volunteer, campaign.id!);
      final afterJoin = await endpoints.fieldnote.getCampaignVolunteerReach(
        sponsor,
        campaign.id!,
      );
      expect(afterJoin.coverageCells, isEmpty);
      expect(afterJoin.volunteersInRange, 0);
      await expectLater(
        endpoints.fieldnote.inviteCampaignVolunteersInArea(
          sponsor,
          campaign.id!,
          area.latitude,
          area.longitude,
        ),
        throwsA(isA<FieldnoteException>()),
      );
    });

    test(
      'availability produces explained matches and supports GPS check-in',
      () async {
        await endpoints.fieldnote.completeVolunteerProfile(
          volunteer,
          'Vik Volunteer',
          'Pune',
          ['environment', 'cleanup'],
          ['outdoors', 'photography'],
          true,
          true,
          [1, 2, 3, 4, 5, 6, 7],
          0,
          1439,
          25,
          18.52040,
          73.85670,
          'Current GPS area',
        );
        await endpoints.fieldnote.acceptLegalConsent(
          volunteer,
          true,
          true,
          true,
        );

        await endpoints.fieldnote.completeSponsorProfile(
          sponsor,
          'Asha Sponsor',
          'Company',
          'Asha Foundation',
          'Pune',
          null,
          ['environment'],
          contactPhone: '+919876543210',
        );
        await endpoints.fieldnote.acceptLegalConsent(
          sponsor,
          true,
          true,
          true,
        );
        await endpoints.fieldnote.createCampaignFromProposal(
          sponsor,
          _campaignProposal(),
          18.52040,
          73.85670,
          'Pashan Lake north bank',
          200,
        );

        final matches = await endpoints.fieldnote.getCampaignMatches(volunteer);
        final match = matches.first;
        final participation = await endpoints.fieldnote.joinCampaign(
          volunteer,
          match.campaign.id!,
        );
        final readyCampaign = await Campaign.db.findById(
          sponsor.build(),
          match.campaign.id!,
        );
        readyCampaign!.readinessState = 'confirmed';
        await Campaign.db.updateRow(sponsor.build(), readyCampaign);
        await expectLater(
          endpoints.fieldnote.checkIn(
            volunteer,
            participation.id!,
            match.campaign.latitude,
            match.campaign.longitude,
            8,
            false,
            false,
            DateTime.now().toUtc(),
          ),
          throwsA(
            isA<FieldnoteException>().having(
              (error) => error.code,
              'code',
              'check_in_window_closed',
            ),
          ),
        );
        readyCampaign.startsAt = DateTime.now().toUtc().add(
          const Duration(minutes: 15),
        );
        readyCampaign.endsAt = readyCampaign.startsAt.add(
          const Duration(hours: 3),
        );
        await Campaign.db.updateRow(sponsor.build(), readyCampaign);
        final checkedIn = await endpoints.fieldnote.checkIn(
          volunteer,
          participation.id!,
          match.campaign.latitude,
          match.campaign.longitude,
          8,
          false,
          false,
          DateTime.now().toUtc(),
        );
        expect(matches, isNotEmpty);
        expect(match.reasons, isNotEmpty);
        expect(match.score, greaterThan(0));
        expect(checkedIn.status, ParticipationStatus.checkedIn);
        final repeatedCheckIn = await endpoints.fieldnote.checkIn(
          volunteer,
          participation.id!,
          match.campaign.latitude,
          match.campaign.longitude,
          8,
          false,
          false,
          DateTime.now().toUtc(),
        );
        expect(repeatedCheckIn.checkedInAt, checkedIn.checkedInAt);

        await endpoints.fieldnote.updateAvailability(
          volunteer,
          false,
          false,
          [1, 2, 3, 4, 5, 6, 7],
          0,
          1439,
          25,
          18.52040,
          73.85670,
          'Current GPS area',
        );
        expect(
          await endpoints.fieldnote.getCampaignMatches(volunteer),
          isEmpty,
        );
      },
    );

    test('campaign map exposes check-in pins to the creator only', () async {
      await endpoints.fieldnote.completeSponsorProfile(
        sponsor,
        'Asha Sponsor',
        'Company',
        'Asha Foundation',
        'Pune',
        null,
        ['environment'],
        contactPhone: '+919876543210',
      );
      await endpoints.fieldnote.acceptLegalConsent(sponsor, true, true, true);
      final proposal = _campaignProposal();
      final campaign = await endpoints.fieldnote.createCampaignFromProposal(
        sponsor,
        proposal,
        18.52040,
        73.85670,
        'Pashan Lake north bank',
        200,
      );

      await endpoints.fieldnote.completeVolunteerProfile(
        volunteer,
        'Vik Volunteer',
        'Pune',
        ['environment'],
        ['outdoors'],
        true,
        true,
        [1, 2, 3, 4, 5, 6, 7],
        0,
        1439,
        25,
        18.52040,
        73.85670,
        'Current GPS area',
      );
      await endpoints.fieldnote.acceptLegalConsent(volunteer, true, true, true);

      final empty = await endpoints.fieldnote.getCampaignMap(
        sponsor,
        campaign.id!,
      );
      expect(empty.pins, isEmpty);
      expect(empty.joinedCount, 0);

      final participation = await endpoints.fieldnote.joinCampaign(
        volunteer,
        campaign.id!,
      );
      final readyCampaign = await Campaign.db.findById(
        sponsor.build(),
        campaign.id!,
      );
      readyCampaign!.readinessState = 'confirmed';
      readyCampaign.startsAt = DateTime.now().toUtc().add(
        const Duration(minutes: 15),
      );
      readyCampaign.endsAt = readyCampaign.startsAt.add(
        const Duration(hours: 3),
      );
      await Campaign.db.updateRow(sponsor.build(), readyCampaign);
      await endpoints.fieldnote.checkIn(
        volunteer,
        participation.id!,
        campaign.latitude,
        campaign.longitude,
        8,
        false,
        false,
        DateTime.now().toUtc(),
      );

      final overview = await endpoints.fieldnote.getCampaignMap(
        sponsor,
        campaign.id!,
      );
      expect(overview.pins, hasLength(1));
      expect(overview.pins.single.kind, 'checkIn');
      expect(overview.pins.single.integrityStatus, 'verified');
      expect(overview.pins.single.isDemo, isFalse);
      expect(overview.pins.single.distanceMeters, closeTo(0, 1));
      expect(overview.checkedInCount, 1);
      expect(overview.completedCount, 0);
      // The sponsor map must not carry volunteer identity.
      expect(overview.pins.single.label, isNot(contains('Vik')));

      await expectLater(
        endpoints.fieldnote.getCampaignMap(volunteer, campaign.id!),
        throwsA(isA<FieldnoteException>()),
      );
    });

    test(
      'roles are locked and sponsor-only actions reject volunteers',
      () async {
        await endpoints.fieldnote.completeVolunteerProfile(
          volunteer,
          'Vik Volunteer',
          'Pune',
          ['community'],
          ['outdoors'],
          true,
          false,
          [6],
          420,
          780,
          10,
          18.52040,
          73.85670,
          'Current GPS area',
        );
        await endpoints.fieldnote.acceptLegalConsent(
          volunteer,
          true,
          true,
          true,
        );

        await expectLater(
          endpoints.fieldnote.proposeCampaign(
            volunteer,
            'Create a community cleanup with 10 volunteers and ₹10000.',
          ),
          throwsA(isA<FieldnoteException>()),
        );
        await expectLater(
          endpoints.fieldnote.completeSponsorProfile(
            volunteer,
            'Vik Volunteer',
            'Individual',
            null,
            'Pune',
            null,
            ['community'],
            contactPhone: '+919876543210',
          ),
          throwsA(isA<FieldnoteException>()),
        );
      },
    );
  });

  withServerpod('Given an unauthenticated visitor', (
    sessionBuilder,
    endpoints,
  ) {
    test('profile access is rejected', () async {
      await expectLater(
        endpoints.fieldnote.getMyProfile(sessionBuilder),
        throwsA(isA<ServerpodUnauthenticatedException>()),
      );
    });
  });
}
