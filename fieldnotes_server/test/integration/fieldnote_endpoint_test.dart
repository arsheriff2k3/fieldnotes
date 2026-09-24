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

    test('sponsor publishes and reads impact', () async {
      final profile = await endpoints.fieldnote.completeSponsorProfile(
        sponsor,
        'Asha Sponsor',
        'Company',
        'Asha Foundation',
        'Pune',
        null,
        ['environment', 'tree care'],
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

    test('profile details update without changing role or consent', () async {
      await endpoints.fieldnote.completeSponsorProfile(
        sponsor,
        'Asha Sponsor',
        'Individual',
        null,
        'Pune',
        null,
        ['environment'],
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
      );
      final unchangedConsent = await endpoints.fieldnote.getMyLegalConsent(
        sponsor,
      );

      expect(updated.role, AccountRole.sponsor);
      expect(updated.displayName, 'Asha Foundation');
      expect(updated.sponsorType, 'Foundation');
      expect(updated.organizationName, 'FieldNote Foundation');
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
        expect(profile.city, 'Nashik');
        expect(profile.skills, 'organizing | photography');
        expect(availability.isAvailable, isFalse);
        expect(availability.availableToday, isTrue);
        expect(availability.weekdays, '1,3,5');
        expect(availability.maximumTravelKm, 24);
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
