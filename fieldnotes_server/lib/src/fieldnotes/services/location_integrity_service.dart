import 'dart:math' as math;

class LocationIntegrityResult {
  const LocationIntegrityResult({
    required this.allowed,
    required this.status,
    required this.reasons,
  });

  final bool allowed;
  final String status;
  final List<String> reasons;
}

/// Server-side location sanity checks for a defense-in-depth demo.
class LocationIntegrityService {
  const LocationIntegrityService();

  LocationIntegrityResult assess({
    required double latitude,
    required double longitude,
    required double accuracyMeters,
    required bool deviceReportedMock,
    required bool explicitDemo,
    required DateTime capturedAt,
    required DateTime now,
    double? previousLatitude,
    double? previousLongitude,
    DateTime? previousAt,
  }) {
    final rejected = <String>[];
    final passed = <String>[];
    if (!latitude.isFinite ||
        !longitude.isFinite ||
        latitude.abs() > 90 ||
        longitude.abs() > 180) {
      rejected.add('Coordinates are outside valid geographic bounds');
    }
    if (!accuracyMeters.isFinite || accuracyMeters <= 0) {
      rejected.add('Location accuracy is invalid');
    } else if (accuracyMeters > 150) {
      rejected.add('Location accuracy is weaker than 150 m');
    } else {
      passed.add('GPS accuracy ${accuracyMeters.round()} m');
    }
    final age = now.toUtc().difference(capturedAt.toUtc()).abs();
    if (age > const Duration(minutes: 2)) {
      rejected.add('Location sample is older than 2 minutes');
    } else {
      passed.add('Fresh device location sample');
    }
    if (deviceReportedMock && !explicitDemo) {
      rejected.add('Device reported a mock location provider');
    } else if (!explicitDemo) {
      passed.add('No device mock-location flag');
    }
    if (previousLatitude != null &&
        previousLongitude != null &&
        previousAt != null) {
      final seconds =
          capturedAt
              .toUtc()
              .difference(previousAt.toUtc())
              .inMilliseconds
              .abs() /
          1000;
      if (seconds > 0) {
        final speed =
            _distanceMeters(
              previousLatitude,
              previousLongitude,
              latitude,
              longitude,
            ) /
            seconds;
        if (speed > 70) {
          rejected.add('Implausible movement speed detected');
        } else {
          passed.add('Movement continuity passed');
        }
      }
    }
    if (explicitDemo) {
      return LocationIntegrityResult(
        allowed: rejected.where((item) => !item.contains('mock')).isEmpty,
        status: 'demo',
        reasons: ['Explicit hackathon GPS simulation', ...passed],
      );
    }
    return LocationIntegrityResult(
      allowed: rejected.isEmpty,
      status: rejected.isEmpty ? 'verified' : 'rejected',
      reasons: rejected.isEmpty ? passed : rejected,
    );
  }

  static double _distanceMeters(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const radius = 6371000.0;
    final phi1 = lat1 * math.pi / 180;
    final phi2 = lat2 * math.pi / 180;
    final dPhi = (lat2 - lat1) * math.pi / 180;
    final dLambda = (lon2 - lon1) * math.pi / 180;
    final a =
        math.sin(dPhi / 2) * math.sin(dPhi / 2) +
        math.cos(phi1) *
            math.cos(phi2) *
            math.sin(dLambda / 2) *
            math.sin(dLambda / 2);
    return radius * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }
}
