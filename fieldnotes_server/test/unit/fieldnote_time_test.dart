import 'package:fieldnotes_server/src/fieldnotes/services/fieldnote_time.dart';
import 'package:fieldnotes_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart' show UuidValue;
import 'package:test/test.dart';

void main() {
  VolunteerAvailability availability({
    String? timezone,
    int? offset,
    String weekdays = '6',
  }) => VolunteerAvailability(
    volunteerAuthUserId: UuidValue.withValidation(
      '880e8400-e29b-41d4-a716-446655440009',
    ),
    weekdays: weekdays,
    startMinutes: 8 * 60,
    endMinutes: 12 * 60,
    maximumTravelKm: 10,
    locationLabel: 'Area',
    timezone: timezone,
    utcOffsetMinutes: offset,
  );

  Campaign campaign(DateTime startsAt) => Campaign(
    organizationId: 1,
    name: 'Campaign',
    description: 'Description',
    locationName: 'Place',
    startsAt: startsAt,
    endsAt: startsAt.add(const Duration(hours: 2)),
    status: CampaignStatus.active,
    createdBy: UuidValue.withValidation('880e8400-e29b-41d4-a716-446655440001'),
  );

  group('IANA zone names', () {
    test('known zones are accepted, abbreviations ignored, bad names fail', () {
      expect(FieldnoteTime.validatedZoneName('Asia/Kolkata'), 'Asia/Kolkata');
      expect(
        FieldnoteTime.validatedZoneName(' America/New_York '),
        'America/New_York',
      );
      expect(FieldnoteTime.validatedZoneName('UTC'), 'UTC');
      // What DateTime.timeZoneName returns on older clients.
      expect(FieldnoteTime.validatedZoneName('IST'), isNull);
      expect(FieldnoteTime.validatedZoneName('PDT'), isNull);
      expect(FieldnoteTime.validatedZoneName(null), isNull);
      for (final bad in ['Mars/Olympus_Mons', 'not a zone', '../etc']) {
        expect(
          () => FieldnoteTime.validatedZoneName(bad),
          throwsA(
            isA<FieldnoteException>().having(
              (e) => e.code,
              'code',
              'invalid_timezone',
            ),
          ),
        );
      }
    });
  });

  group('DST', () {
    final july = DateTime.utc(2026, 7, 4, 12); // Saturday 08:00 EDT
    final january = DateTime.utc(2026, 1, 10, 13); // Saturday 08:00 EST

    test('America/New_York is -4h in July and -5h in January', () {
      expect(FieldnoteTime.offsetAt(july, zone: 'America/New_York'), -240);
      expect(FieldnoteTime.offsetAt(january, zone: 'America/New_York'), -300);
      expect(FieldnoteTime.offsetAt(july, zone: 'Asia/Kolkata'), 330);
      // Unknown zone: offset, then IST.
      expect(FieldnoteTime.offsetAt(july, utcOffsetMinutes: -300), -300);
      expect(FieldnoteTime.offsetAt(july), 330);
    });

    test('matching follows the zone, not a stale saved offset', () {
      // Offset saved in winter (-300), event in summer.
      final zoned = availability(timezone: 'America/New_York', offset: -300);
      expect(FieldnoteTime.availabilityCovers(zoned, campaign(july)), isTrue);
      expect(
        FieldnoteTime.availabilityCovers(zoned, campaign(january)),
        isTrue,
      );
      // Offset-only volunteers keep the old behaviour: 07:00 local in July.
      final offsetOnly = availability(offset: -300);
      expect(
        FieldnoteTime.availabilityCovers(offsetOnly, campaign(july)),
        isFalse,
      );
      expect(
        FieldnoteTime.availabilityCovers(offsetOnly, campaign(january)),
        isTrue,
      );
    });

    test('"I can help today" uses the zone date', () {
      // 2026-07-05 02:00 UTC is still 2026-07-04 22:00 EDT.
      final now = DateTime.utc(2026, 7, 5, 2);
      final helping = availability(
        timezone: 'America/New_York',
        offset: 0,
      )..availableToday = true;
      helping.availableTodayDate = '2026-07-04';
      expect(FieldnoteTime.availableTodayActive(helping, now: now), isTrue);
      helping.availableTodayDate = '2026-07-05';
      expect(FieldnoteTime.availableTodayActive(helping, now: now), isFalse);
    });

    test('AI dates across a DST change keep their local wall time', () {
      // Drafted on 2026-10-20 (EDT, -240): "Saturday 7 November 8am".
      final drafted = DateTime.utc(2026, 11, 7, 12);
      final fixed = FieldnoteTime.reresolveInZone(
        drafted,
        offsetUsed: -240,
        zone: 'America/New_York',
      );
      expect(fixed, DateTime.utc(2026, 11, 7, 13)); // 08:00 EST
      // No DST in India: unchanged.
      final ist = DateTime.utc(2026, 11, 7, 2, 30);
      expect(
        FieldnoteTime.reresolveInZone(
          ist,
          offsetUsed: 330,
          zone: 'Asia/Kolkata',
        ),
        ist,
      );
    });

    test('email times use the recipient zone, else IST', () {
      expect(
        FieldnoteTime.describe(july, zone: 'America/New_York'),
        '2026-07-04 08:00 EDT',
      );
      expect(
        FieldnoteTime.describe(january, zone: 'America/New_York'),
        '2026-01-10 08:00 EST',
      );
      expect(
        FieldnoteTime.describe(DateTime.utc(2026, 7, 4, 2, 30)),
        '2026-07-04 08:00 IST',
      );
      expect(
        FieldnoteTime.describe(july, utcOffsetMinutes: 60),
        '2026-07-04 13:00 UTC+01:00',
      );
      expect(
        FieldnoteTime.describe(july, zone: 'Asia/Kolkata'),
        '2026-07-04 17:30 IST',
      );
    });
  });
}
