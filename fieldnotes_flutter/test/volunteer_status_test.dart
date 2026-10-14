import 'package:fieldnotes_client/fieldnotes_client.dart';
import 'package:fieldnotes_flutter/data/services/device_location_service.dart';
import 'package:fieldnotes_flutter/ui/features/volunteer/volunteer_status.dart';
import 'package:flutter_test/flutter_test.dart';

final _user = UuidValue.withValidation('550e8400-e29b-41d4-a716-446655440000');

Campaign _campaign({
  DateTime? startsAt,
  DateTime? endsAt,
  String readiness = 'confirmed',
  CampaignStatus status = CampaignStatus.active,
}) => Campaign(
  organizationId: 1,
  name: 'Tree planting',
  description: 'Plant trees.',
  locationName: 'Pollachi',
  startsAt: startsAt ?? DateTime.utc(2026, 10, 4, 9),
  endsAt: endsAt,
  status: status,
  createdBy: _user,
  readinessState: readiness,
);

CampaignParticipation _participation(ParticipationStatus status) =>
    CampaignParticipation(
      id: 1,
      campaignId: 1,
      volunteerAuthUserId: _user,
      status: status,
    );

DeviceLocation _fix({required double accuracy, required DateTime at}) =>
    DeviceLocation(
      latitude: 10,
      longitude: 77,
      accuracyMeters: accuracy,
      isLive: true,
      isMocked: false,
      capturedAt: at,
      isDemo: false,
    );

void main() {
  group('check-in window', () {
    final campaign = _campaign(endsAt: DateTime.utc(2026, 10, 4, 12));

    test('opens 30 minutes before the start and closes at the end', () {
      expect(
        checkInWindow(campaign, DateTime.utc(2026, 10, 4, 8, 29)),
        CheckInWindow.notYetOpen,
      );
      expect(
        checkInWindow(campaign, DateTime.utc(2026, 10, 4, 8, 30)),
        CheckInWindow.open,
      );
      expect(
        checkInWindow(campaign, DateTime.utc(2026, 10, 4, 12)),
        CheckInWindow.open,
      );
      expect(
        checkInWindow(campaign, DateTime.utc(2026, 10, 4, 12, 1)),
        CheckInWindow.closed,
      );
    });

    test('falls back to a two hour event without endsAt', () {
      final legacy = _campaign();
      expect(campaignEnd(legacy), DateTime.utc(2026, 10, 4, 11));
      expect(completionDeadline(legacy), DateTime.utc(2026, 10, 4, 13));
    });

    test('label shows the opening time', () {
      final opens = checkInOpensAt(campaign).toLocal();
      final label = checkInOpensLabel(campaign, opens);
      final hh = opens.hour.toString().padLeft(2, '0');
      final mm = opens.minute.toString().padLeft(2, '0');
      expect(label, 'Check-in opens at $hh:$mm');
      expect(
        checkInOpensLabel(campaign, opens.subtract(const Duration(days: 2))),
        contains(' at $hh:$mm'),
      );
    });
  });

  group('participation display', () {
    final now = DateTime.utc(2026, 10, 4, 9);

    test('joined on a confirmed campaign can check in and leave', () {
      final display = participationDisplay(
        _participation(ParticipationStatus.joined),
        _campaign(),
        now: now,
      );
      expect(display.label, 'Joined');
      expect(display.canCheckIn, isTrue);
      expect(display.canLeave, isTrue);
      expect(display.canComplete, isFalse);
    });

    test('cancelled campaign tells the volunteer not to travel', () {
      for (final status in [
        ParticipationStatus.joined,
        ParticipationStatus.cancelled,
      ]) {
        final display = participationDisplay(
          _participation(status),
          _campaign(readiness: 'cancelled'),
          now: now,
        );
        expect(display.label, 'Campaign cancelled — do not travel');
        expect(display.isActive, isFalse);
      }
    });

    test('expired, completed and terminal statuses hide actions', () {
      final cases = {
        participationDisplay(
          _participation(ParticipationStatus.joined),
          _campaign(readiness: 'expired'),
          now: now,
        ): 'Campaign expired',
        participationDisplay(
          _participation(ParticipationStatus.joined),
          _campaign(status: CampaignStatus.completed),
          now: now,
        ): 'Campaign completed',
        participationDisplay(
          _participation(ParticipationStatus.completed),
          _campaign(),
          now: now,
        ): 'Impact submitted',
        participationDisplay(
          _participation(ParticipationStatus.left),
          _campaign(),
          now: now,
        ): 'You left this campaign',
        participationDisplay(
          _participation(ParticipationStatus.noShow),
          _campaign(),
          now: now,
        ): 'Missed · no check-in',
        participationDisplay(
          _participation(ParticipationStatus.incomplete),
          _campaign(),
          now: now,
        ): 'Incomplete · no evidence',
      };
      cases.forEach((display, label) {
        expect(display.label, label);
        expect(display.isActive, isFalse, reason: label);
      });
    });

    test('checked in can complete until the evidence deadline', () {
      final participation = _participation(ParticipationStatus.checkedIn);
      final campaign = _campaign(endsAt: DateTime.utc(2026, 10, 4, 12));
      expect(
        participationDisplay(
          participation,
          campaign,
          now: DateTime.utc(2026, 10, 4, 13, 59),
        ).canComplete,
        isTrue,
      );
      expect(
        participationDisplay(
          participation,
          campaign,
          now: DateTime.utc(2026, 10, 4, 14, 1),
        ).canComplete,
        isFalse,
      );
    });

    test('a volunteer who left no longer holds a place', () {
      expect(holdsPlace(null), isFalse);
      expect(holdsPlace(_participation(ParticipationStatus.left)), isFalse);
      expect(holdsPlace(_participation(ParticipationStatus.joined)), isTrue);
    });

    test('review states have labels', () {
      for (final state in ReviewState.values) {
        expect(reviewStateLabel(state), isNotEmpty);
      }
    });
  });

  group('evidence helpers', () {
    test('detects the server fallback proposal', () {
      CompletionProposal proposal(String rationale) => CompletionProposal(
        summary: 'We planted trees',
        structuredResults: const [],
        suggestedFollowUp: '',
        confidence: AiConfidence.low,
        rationale: rationale,
      );
      expect(
        isFallbackProposal(
          proposal(
            'AI analysis is unavailable. This summary was taken from your '
            'note. Review it before submitting.',
          ),
        ),
        isTrue,
      );
      expect(isFallbackProposal(proposal('Structured by AI.')), isFalse);
    });

    test('reuses only fresh, accurate fixes', () {
      final now = DateTime.utc(2026, 10, 4, 9);
      expect(
        isReusableFix(
          _fix(accuracy: 20, at: now.subtract(const Duration(seconds: 30))),
          now,
        ),
        isTrue,
      );
      expect(
        isReusableFix(
          _fix(accuracy: 20, at: now.subtract(const Duration(minutes: 3))),
          now,
        ),
        isFalse,
      );
      expect(isReusableFix(_fix(accuracy: 200, at: now), now), isFalse);
      expect(isReusableFix(null, now), isFalse);
    });

    test('explains weak accuracy', () {
      final now = DateTime.utc(2026, 10, 4, 9);
      expect(locationProblem(_fix(accuracy: 40, at: now), now), isNull);
      expect(
        locationProblem(_fix(accuracy: 412, at: now), now),
        startsWith('GPS accuracy is ±412 m'),
      );
    });

    test('splits a manual summary into results', () {
      expect(manualResultsFrom('Planted 12 saplings. Cleared 8 bags.'), [
        'Planted 12 saplings',
        'Cleared 8 bags',
      ]);
      expect(manualResultsFrom('ok'), ['ok']);
      expect(
        manualResultsFrom(List.filled(30, 'Did work').join('. ')).length,
        20,
      );
    });
  });

  group('availability window', () {
    test('validates start before end', () {
      expect(availabilityWindowProblem(7 * 60, 13 * 60), isNull);
      expect(availabilityWindowProblem(13 * 60, 13 * 60), isNotNull);
      expect(availabilityWindowProblem(14 * 60, 9 * 60), isNotNull);
      expect(availabilityWindowProblem(0, 1440), isNull);
    });

    test('formats minutes', () {
      expect(formatMinutes(7 * 60 + 5), '07:05');
      expect(formatMinutes(1440), '24:00');
    });
  });
}
