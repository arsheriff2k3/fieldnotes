import '../../generated/protocol.dart';

/// V-5: wall-clock maths in a volunteer's or sponsor's own UTC offset.
///
/// Dart has no IANA database without an extra package, so the client sends
/// `DateTime.now().timeZoneOffset.inMinutes` and the server computes local
/// weekdays and times with that offset. The IANA name is stored for display
/// and a later DST-aware upgrade. Offsets are captured on every availability
/// save, so a DST change is picked up the next time the volunteer saves.
abstract final class FieldnoteTime {
  /// FieldNote launches in India (INR, Razorpay), so rows saved before the
  /// client sent an offset are read as IST rather than the server's zone.
  static const defaultUtcOffsetMinutes = 330;

  /// UTC-12:00 .. UTC+14:00.
  static const minOffsetMinutes = -12 * 60;
  static const maxOffsetMinutes = 14 * 60;

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

  /// A UTC instant shifted to wall-clock fields in [offsetMinutes]. The
  /// result is a UTC [DateTime] whose fields read as local time; never
  /// compare it with real instants.
  static DateTime wallClock(DateTime instant, int offsetMinutes) =>
      instant.toUtc().add(Duration(minutes: offsetMinutes));

  static String dateKey(DateTime wall) =>
      '${wall.year.toString().padLeft(4, '0')}-'
      '${wall.month.toString().padLeft(2, '0')}-'
      '${wall.day.toString().padLeft(2, '0')}';

  /// Today's local date for [offsetMinutes].
  static String todayKey(int offsetMinutes, {DateTime? now}) =>
      dateKey(wallClock(now ?? DateTime.now().toUtc(), offsetMinutes));

  /// `2026-10-01T14:05:00+05:30`
  static String isoWithOffset(DateTime instant, int offsetMinutes) {
    final wall = wallClock(instant, offsetMinutes);
    final sign = offsetMinutes < 0 ? '-' : '+';
    final abs = offsetMinutes.abs();
    String two(int value) => value.toString().padLeft(2, '0');
    return '${dateKey(wall)}T${two(wall.hour)}:${two(wall.minute)}:'
        '${two(wall.second)}$sign${two(abs ~/ 60)}:${two(abs % 60)}';
  }

  /// Validates an optional IANA zone name such as `Asia/Kolkata`.
  static String? validatedZoneName(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    if (trimmed.length > 64 ||
        !RegExp(r'^[A-Za-z][A-Za-z0-9_+\-/]*$').hasMatch(trimmed)) {
      throw FieldnoteException(
        message: 'The device time zone name is invalid.',
        code: 'invalid_timezone',
      );
    }
    return trimmed;
  }

  /// Whether [availability] covers [campaign] in the volunteer's own offset.
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
    final offset = offsetOrDefault(availability.utcOffsetMinutes);
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
          todayKey(offsetOrDefault(availability.utcOffsetMinutes), now: now);

  /// Local weekday (1 = Monday) of [instant] for [offsetMinutes].
  static int localWeekday(DateTime instant, int offsetMinutes) =>
      wallClock(instant, offsetMinutes).weekday;

  static Set<int> weekdays(String value) =>
      value.split(',').map((day) => int.tryParse(day.trim())).nonNulls.toSet();
}
