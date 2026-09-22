import 'package:fieldnotes_server/src/generated/protocol.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

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

    test('sponsor generates, publishes, and reads impact', () async {
      final profile = await endpoints.fieldnote.completeSponsorProfile(
        sponsor,
        'Asha Sponsor',
        'Company',
        'Asha Foundation',
        'Pune',
        ['environment', 'tree care'],
      );
      await endpoints.fieldnote.acceptLegalConsent(
        sponsor,
        true,
        true,
        true,
      );
      final proposal = await endpoints.fieldnote.proposeCampaign(
        sponsor,
        'Plant trees near the university with 12 volunteers and a ₹30000 budget this Saturday.',
      );
      final campaign = await endpoints.fieldnote.createCampaignFromProposal(
        sponsor,
        proposal,
        18.52040,
        73.85670,
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
          'Hackathon demo venue',
        );
        await endpoints.fieldnote.acceptLegalConsent(
          volunteer,
          true,
          true,
          true,
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
        final aiResult = await endpoints.fieldnote.analyzeCompletion(
          volunteer,
          participation.id!,
          'We watered 12 trees and cleared 8 bags of plastic waste.',
          null,
          null,
        );

        expect(matches, isNotEmpty);
        expect(match.reasons, isNotEmpty);
        expect(match.score, greaterThan(0));
        expect(checkedIn.status, ParticipationStatus.checkedIn);
        expect(aiResult.structuredResults, contains('12 trees watered'));
        expect(aiResult.structuredResults, contains('8 bags of waste cleared'));

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
          'Hackathon demo venue',
        );
        expect(
          await endpoints.fieldnote.getCampaignMatches(volunteer),
          isEmpty,
        );
      },
    );

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
          'Hackathon demo venue',
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
