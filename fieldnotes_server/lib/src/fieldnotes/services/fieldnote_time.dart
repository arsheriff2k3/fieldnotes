import 'package:timezone/data/latest_10y.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../generated/protocol.dart';

/// V-5: wall-clock maths in a volunteer's or sponsor's own time zone.
///
/// The IANA zone (`Asia/Kolkata`, `America/New_York`) is the source of truth
/// when it is known to the bundled tz database, so DST is applied for the
/// instant being converted. Otherwise the saved UTC offset is used, and rows
/// with neither are read as IST (FieldNote launches in India).
abstract final class FieldnoteTime {
  static const defaultUtcOffsetMinutes = 330;
  static const defaultZone = 'Asia/Kolkata';

  /// UTC-12:00 .. UTC+14:00.
  static const minOffsetMinutes = -12 * 60;
  static const maxOffsetMinutes = 14 * 60;

  static bool _initialized = false;

  /// Loads the tz database (current rules for the last/next ~10 years).
  /// Called at server start; every lookup also calls it lazily.
  static void ensureInitialized() {
    if (_initialized) return;
    tzdata.initializeTimeZones();
    _initialized = true;
  }

  /// The tz location for an IANA [name], or null when unknown.
  static tz.Location? location(String? name) {
    final trimmed = name?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    ensureInitialized();
    if (trimmed == 'UTC' || trimmed == 'Etc/UTC') return tz.UTC;
    try {
      return tz.getLocation(trimmed);
    } on tz.LocationNotFoundException {
      return null;
    }
  }

  static int offsetOrDefault(int? offset) => offset ?? defaultUtcOffsetMinutes;

  static int validatedOffset(int? offset) {
    if (offset == null) return defaultUtcOffsetMinutes;
    if (offset < minOffsetMinutes || offset > maxOffsetMinutes) {
      throw FieldnoteException(
        message: 'The device time zone offset is invalid.',
        code: 'invalid_timezone',
      );
    }
    return offset;
  }

  /// Validates an optional zone name.
  ///
  /// Returns the name when it is a known IANA zone. Names containing `/`
  /// claim to be IANA zones and are rejected when unknown. Abbreviations such
  /// as `IST`, `PDT` or `GMT+05:30` (what `DateTime.timeZoneName` returns on
  /// older clients) are ignored (null) so those requests keep working on the
  /// UTC offset.
  static String? validatedZoneName(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    if (trimmed.length > 64 ||
        !RegExp(r'^[A-Za-z][A-Za-z0-9_+\-/]*$').hasMatch(trimmed)) {
      throw _invalidZone();
    }
    if (location(trimmed) != null) return trimmed;
    if (trimmed.contains('/')) throw _invalidZone();
    return null;
  }

  static FieldnoteException _invalidZone() => FieldnoteException(
    message: 'The device time zone name is invalid.',
    code: 'invalid_timezone',
  );

  /// UTC offset in minutes at [instant]: from [zone] when it is a known IANA
  /// zone (DST-aware), else [utcOffsetMinutes], else IST.
  static int offsetAt(
    DateTime instant, {
    String? zone,
    int? utcOffsetMinutes,
  }) {
    final loc = location(zone);
    if (loc != null) {
      return loc.timeZone(instant.millisecondsSinceEpoch).offset.inMinutes;
    }
    return offsetOrDefault(utcOffsetMinutes);
  }

  /// [offsetAt] for a volunteer's saved availability.
  static int availabilityOffsetAt(
    VolunteerAvailability availability,
    DateTime instant,
  ) => offsetAt(
    instant,
    zone: availability.timezone,
    utcOffsetMinutes: availability.utcOffsetMinutes,
  );

  /// A UTC instant shifted to wall-clock fields in [offsetMinutes]. The
  /// result is a UTC [DateTime] whose fields read as local time; never
  /// compare it with real instants.
  static DateTime wallClock(DateTime instant, int offsetMinutes) =>
      instant.toUtc().add(Duration(minutes: offsetMinutes));

  /// The real instant of wall-clock [wall] (fields read as local time) in
  /// IANA [zone]. Non-existent DST-gap times move forward, as tz does.
  static DateTime fromWallClock(DateTime wall, String zone) {
    final loc = location(zone);
    if (loc == null) throw _invalidZone();
    return tz.TZDateTime(
      loc,
      wall.year,
      wall.month,
      wall.day,
      wall.hour,
      wall.minute,
      wall.second,
    ).toUtc();
  }

  /// Re-resolves an AI-drafted start time in [zone]. The model is told the
  /// sponsor's current offset ([offsetUsed]) and resolves "Saturday 8am" in
  /// it; when that date falls on the other side of a DST change, the same
  /// local wall-clock time is converted with the zone's rules instead.
  static DateTime reresolveInZone(
    DateTime startsAt, {
    required int offsetUsed,
    required String zone,
  }) => fromWallClock(wallClock(startsAt, offsetUsed), zone);

  static String dateKey(DateTime wall) =>
      '${wall.year.toString().padLeft(4, '0')}-'
      '${wall.month.toString().padLeft(2, '0')}-'
      '${wall.day.toString().padLeft(2, '0')}';

  /// Today's local date for [offsetMinutes].
  static String todayKey(int offsetMinutes, {DateTime? now}) =>
      dateKey(wallClock(now ?? DateTime.now().toUtc(), offsetMinutes));

  /// Today's local date in [zone] (DST-aware), else [utcOffsetMinutes].
  static String todayKeyIn({
    String? zone,
    int? utcOffsetMinutes,
    DateTime? now,
  }) {
    final clock = now ?? DateTime.now().toUtc();
    return todayKey(
      offsetAt(clock, zone: zone, utcOffsetMinutes: utcOffsetMinutes),
      now: clock,
    );
  }

  /// `2026-10-01T14:05:00+05:30`
  static String isoWithOffset(DateTime instant, int offsetMinutes) {
    final wall = wallClock(instant, offsetMinutes);
    return '${dateKey(wall)}T${_two(wall.hour)}:${_two(wall.minute)}:'
        '${_two(wall.second)}${offsetLabel(offsetMinutes, separator: ':')}';
  }

  /// `+05:30` / `-04:00` (or `+0530` without [separator]).
  static String offsetLabel(int offsetMinutes, {String separator = ':'}) {
    final sign = offsetMinutes < 0 ? '-' : '+';
    final abs = offsetMinutes.abs();
    return '$sign${_two(abs ~/ 60)}$separator${_two(abs % 60)}';
  }

  /// `2026-07-04 08:00 EDT` in [zone], `… UTC+05:30` with only an offset,
  /// and `… IST` when neither is known. Used for email.
  static String describe(
    DateTime instant, {
    String? zone,
    int? utcOffsetMinutes,
  }) {
    final loc = location(zone);
    final int offset;
    final String label;
    if (loc != null) {
      final current = loc.timeZone(instant.millisecondsSinceEpoch);
      offset = current.offset.inMinutes;
      final abbreviation = current.abbreviation;
      // Some zones only have numeric abbreviations such as "+04".
      label = RegExp(r'^[A-Za-z]{2,6}$').hasMatch(abbreviation)
          ? abbreviation
          : 'UTC${offsetLabel(offset)}';
    } else if (utcOffsetMinutes != null) {
      offset = utcOffsetMinutes;
      label = offset == defaultUtcOffsetMinutes
          ? 'IST'
          : 'UTC${offsetLabel(offset)}';
    } else {
      offset = defaultUtcOffsetMinutes;
      label = 'IST';
    }
    final wall = wallClock(instant, offset);
    return '${dateKey(wall)} ${_two(wall.hour)}:${_two(wall.minute)} $label';
  }

  /// Whether [availability] covers [campaign] in the volunteer's own zone.
  ///
  /// The campaign's local start weekday must be one of the saved weekdays, or
  /// the campaign must start on the local date "I can help today" was set
  /// for. The whole event must sit inside the saved daily window; an event
  /// that runs past local midnight only fits a window ending at 24:00.
  static bool availabilityCovers(
    VolunteerAvailability availability,
    Campaign campaign, {
    DateTime? now,
  }) {
    final offset = availabilityOffsetAt(availability, campaign.startsAt);
    final start = wallClock(campaign.startsAt, offset);
    final duration =
        (campaign.endsAt ?? campaign.startsAt.add(const Duration(hours: 3)))
            .difference(campaign.startsAt)
            .inMinutes;
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = startMinutes + duration;
    final days = weekdays(availability.weekdays);
    final helpsToday =
        availableTodayActive(availability, now: now) &&
        dateKey(start) == availability.availableTodayDate;
    return (days.contains(start.weekday) || helpsToday) &&
        availability.startMinutes <= startMinutes &&
        availability.endMinutes >= endMinutes;
  }

  /// "I can help today" only counts on the local date it was set for.
  static bool availableTodayActive(
    VolunteerAvailability availability, {
    DateTime? now,
  }) =>
      availability.availableToday &&
      availability.availableTodayDate != null &&
      availability.availableTodayDate ==
          todayKeyIn(
            zone: availability.timezone,
            utcOffsetMinutes: availability.utcOffsetMinutes,
            now: now,
          );

  /// Local weekday (1 = Monday) of [instant] for [offsetMinutes].
  static int localWeekday(DateTime instant, int offsetMinutes) =>
      wallClock(instant, offsetMinutes).weekday;

  static Set<int> weekdays(String value) =>
      value.split(',').map((day) => int.tryParse(day.trim())).nonNulls.toSet();

  static String _two(int value) => value.toString().padLeft(2, '0');
}
