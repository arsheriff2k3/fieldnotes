import 'package:fieldnotes_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Campaign impact report', (builder, endpoints) {
    final sponsor = builder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(
        '550e8400-e29b-41d4-a716-446655440000',
        {},
      ),
    );
    final outsider = builder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(
        '550e8400-e29b-41d4-a716-446655440099',
        {},
      ),
    );

    test(
      'all evidence states and historical payment modes reach authorized reports',
      () async {
        for (final account in [sponsor, outsider]) {
          await endpoints.fieldnote.completeSponsorProfile(
            account,
            'Sponsor',
            'Individual',
            null,
            'Pune',
            null,
            [],
            contactPhone: '+919876543210',
          );
          await endpoints.fieldnote.acceptLegalConsent(
            account,
            true,
            true,
            true,
          );
        }
        final session = sponsor.build();
        final owner = (await endpoints.fieldnote.getMyProfile(
          sponsor,
        ))!.authUserId;
        final campaign = await endpoints.fieldnote.createCampaignFromProposal(
          sponsor,
          CampaignProposal(
            title: 'Park cleanup',
            description: 'Clean the park and report work.',
            locationName: 'Pune park',
            startsAt: DateTime.now().toUtc().add(const Duration(days: 2)),
            durationMinutes: 60,
            volunteerCapacity: 20,
            fundingGoal: 5000,
            requiredSkills: [],
            checklist: ['Collect waste'],
            evidenceInstructions: 'Submit photo evidence.',
            tags: ['environment'],
            rationale: 'Sponsor plan',
          ),
          18.52,
          73.85,
          'Pune park',
          200,
        );
        final states = [
          ReviewState.approved,
          ReviewState.approved,
          ReviewState.approved,
          ReviewState.approved,
          ReviewState.awaitingReview,
          ReviewState.awaitingReview,
          ReviewState.changesRequested,
          ReviewState.rejected,
        ];
        for (var i = 0; i < states.length; i++) {
          final participation = await CampaignParticipation.db.insertRow(
            session,
            CampaignParticipation(
              campaignId: campaign.id!,
              volunteerAuthUserId: UuidValue.withValidation(
                '550e8400-e29b-41d4-a716-44665544001$i',
              ),
              status: ParticipationStatus.completed,
            ),
          );
          await CompletionEvidence.db.insertRow(
            session,
            CompletionEvidence(
              participationId: participation.id!,
              originalNote: 'Private note',
              confirmedSummary: 'Contribution $i',
              structuredResults: 'Reported work',
              latitude: 18.52,
              longitude: 73.85,
              locationAccuracyMeters: 5,
              reviewState: states[i],
              locationIsDemo: i == 0,
            ),
          );
        }
        for (final mode in <bool?>[true, false, null]) {
          await Sponsorship.db.insertRow(
            session,
            Sponsorship(
              campaignId: campaign.id!,
              sponsorAuthUserId: owner,
              amount: 100,
              amountPaise: 10000,
              paymentStatus: 'verified',
              paymentTestMode: mode,
            ),
          );
        }
        final report = await endpoints.fieldnote.getImpact(
          sponsor,
          campaign.id!,
        );
        expect(report.recentEvidence, hasLength(8));
        expect(
          report.recentEvidence.map((e) => e.reviewState),
          containsAll(states),
        );
        expect(report.summary, contains('4 sponsor-approved contributions'));
        expect(report.summary, contains('3 pending review'));
        expect(report.summary, contains('1 rejected'));
        expect(report.summary, contains('Test Mode'));
        expect(report.summary, contains('Includes live payments'));
        expect(report.summary, contains('unknown checkout mode'));
        await expectLater(
          endpoints.fieldnote.getImpact(outsider, campaign.id!),
          throwsA(
            isA<FieldnoteException>().having(
              (e) => e.code,
              'code',
              'forbidden',
            ),
          ),
        );
        final pending = report.recentEvidence.firstWhere(
          (e) => e.reviewState == ReviewState.awaitingReview,
        );
        await endpoints.fieldnote.reviewEvidence(
          sponsor,
          pending.id!,
          true,
          null,
        );
        final refreshed = await endpoints.fieldnote.getImpact(
          sponsor,
          campaign.id!,
        );
        expect(refreshed.summary, contains('5 sponsor-approved contributions'));
        expect(
          refreshed.recentEvidence.where(
            (e) => e.reviewState == ReviewState.approved,
          ),
          hasLength(5),
        );
      },
    );
  });
}
