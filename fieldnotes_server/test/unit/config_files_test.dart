import 'package:fieldnotes_server/src/fieldnotes/services/fieldnote_time.dart';
import 'package:fieldnotes_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

// Placeholder values so the loader can build database/Redis sections.
const _passwords = {
  'database': 'test',
  'redis': 'test',
  'serviceSecret': 'test-service-secret',
};

void main() {
  group('config files', () {
    test('production and staging parse with Redis, CORS and cookies', () {
      for (final mode in ['production', 'staging']) {
        final config = ServerpodConfig.load(mode, null, _passwords);
        expect(config.redis?.enabled, isTrue, reason: mode);
        expect(config.allowedOrigins, isNotEmpty, reason: mode);
        expect(config.authCookie, isNotNull, reason: mode);
        expect(config.apiServer.publicHost, isNot(contains('examplepod')));
        expect(config.webServer?.publicHost, isNot(contains('examplepod')));
      }
    });

    test('development keeps localhost hosts', () {
      final config = ServerpodConfig.load('development', null, _passwords);
      expect(config.apiServer.publicHost, 'localhost');
      expect(config.redis?.enabled ?? false, isFalse);
    });
  });

  group('FieldnoteTime', () {
    VolunteerAvailability availability({
      required int offset,
      String weekdays = '1,2,3,4,5,6,7',
      bool today = false,
      String? todayDate,
      int start = 0,
      int end = 1440,
    }) => VolunteerAvailability(
      volunteerAuthUserId: UuidValue.withValidation(
        '880e8400-e29b-41d4-a716-446655440000',
      ),
      availableToday: today,
      availableTodayDate: todayDate,
      weekdays: weekdays,
      startMinutes: start,
      endMinutes: end,
      maximumTravelKm: 10,
      locationLabel: 'Area',
      utcOffsetMinutes: offset,
    );

    Campaign campaign(DateTime startsAt, Duration duration) => Campaign(
      organizationId: 1,
      name: 'Campaign',
      description: 'Description',
      locationName: 'Place',
      startsAt: startsAt,
      endsAt: startsAt.add(duration),
      status: CampaignStatus.active,
      createdBy: UuidValue.withValidation(
        '880e8400-e29b-41d4-a716-446655440001',
      ),
      latitude: 0,
      longitude: 0,
    );

    test('uses the volunteer offset for weekday and time', () {
      // Thursday 2026-10-01 02:30 UTC is Thursday 08:00 IST.
      final event = campaign(
        DateTime.utc(2026, 10, 1, 2, 30),
        const Duration(hours: 2),
      );
      expect(
        FieldnoteTime.availabilityCovers(
          availability(offset: 330, weekdays: '4', start: 480, end: 600),
          event,
        ),
        isTrue,
      );
      expect(
        FieldnoteTime.availabilityCovers(
          availability(offset: 0, weekdays: '4', start: 480, end: 600),
          event,
        ),
        isFalse,
      );
      // 02:30 UTC on Thursday is still Wednesday 19:30 in New York (-4h).
      expect(FieldnoteTime.localWeekday(event.startsAt, -240), 3);
    });

    test('events past local midnight need a window ending at 24:00', () {
      final event = campaign(
        DateTime.utc(2026, 10, 1, 17, 30), // 23:00 IST
        const Duration(hours: 2),
      );
      expect(
        FieldnoteTime.availabilityCovers(
          availability(offset: 330, start: 1200, end: 1439),
          event,
        ),
        isFalse,
      );
    });

    test('help-today only applies on its own local date', () {
      final now = DateTime.utc(2026, 10, 1, 4);
      final saved = availability(
        offset: 330,
        today: true,
        todayDate: FieldnoteTime.todayKey(330, now: now),
      );
      expect(FieldnoteTime.availableTodayActive(saved, now: now), isTrue);
      expect(
        FieldnoteTime.availableTodayActive(
          saved,
          now: now.add(const Duration(days: 1)),
        ),
        isFalse,
      );
    });

    test('formats local ISO time with offset', () {
      expect(
        FieldnoteTime.isoWithOffset(DateTime.utc(2026, 10, 1, 2, 30), 330),
        '2026-10-01T08:00:00+05:30',
      );
      expect(
        FieldnoteTime.isoWithOffset(DateTime.utc(2026, 10, 1, 2, 30), -240),
        '2026-09-30T22:30:00-04:00',
      );
    });
  });
}
