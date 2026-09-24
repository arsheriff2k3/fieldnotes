import 'dart:async';

import 'package:geolocator/geolocator.dart';

enum LocationAccessIssue {
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  timedOut,
  unavailable,
}

class LocationAccessException implements Exception {
  const LocationAccessException(this.issue, this.message);

  final LocationAccessIssue issue;
  final String message;

  @override
  String toString() => message;
}

class DeviceLocation {
  const DeviceLocation({
    required this.latitude,
    required this.longitude,
    required this.accuracyMeters,
    required this.isLive,
    required this.isMocked,
    required this.capturedAt,
    required this.isDemo,
  });

  final double latitude;
  final double longitude;
  final double accuracyMeters;
  final bool isLive;
  final bool isMocked;
  final DateTime capturedAt;
  final bool isDemo;
}

class DeviceLocationService {
  Future<DeviceLocation> current() async {
    await _ensureReady();
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      return _fromPosition(position);
    } on TimeoutException {
      throw const LocationAccessException(
        LocationAccessIssue.timedOut,
        'A precise location could not be obtained in time. Move near a window and try again.',
      );
    } on LocationServiceDisabledException {
      throw const LocationAccessException(
        LocationAccessIssue.serviceDisabled,
        'Location is turned off. Enable Location on this device and try again.',
      );
    } on PermissionDeniedException {
      throw const LocationAccessException(
        LocationAccessIssue.permissionDenied,
        'FieldNote does not have permission to use this device location.',
      );
    } on LocationAccessException {
      rethrow;
    } on Object {
      throw const LocationAccessException(
        LocationAccessIssue.unavailable,
        'The device location is currently unavailable. Check Location settings and try again.',
      );
    }
  }

  Future<bool> openLocationSettings() => Geolocator.openLocationSettings();

  Future<bool> openAppSettings() => Geolocator.openAppSettings();

  Stream<DeviceLocation> watch() async* {
    await _ensureReady();
    yield* Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 1,
      ),
    ).map(_fromPosition);
  }

  static double distanceMeters(
    DeviceLocation location,
    double latitude,
    double longitude,
  ) => Geolocator.distanceBetween(
    location.latitude,
    location.longitude,
    latitude,
    longitude,
  );

  Future<void> _ensureReady() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationAccessException(
        LocationAccessIssue.permissionDeniedForever,
        'Location permission is blocked. Enable Precise Location for FieldNote in device Settings.',
      );
    }
    if (permission == LocationPermission.denied) {
      throw const LocationAccessException(
        LocationAccessIssue.permissionDenied,
        'Location permission was not granted. Allow it and try again.',
      );
    }
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      throw const LocationAccessException(
        LocationAccessIssue.serviceDisabled,
        'Location is turned off. Enable Location on this device and try again.',
      );
    }
  }

  static DeviceLocation _fromPosition(Position position) => DeviceLocation(
    latitude: position.latitude,
    longitude: position.longitude,
    accuracyMeters: position.accuracy,
    isLive: true,
    isMocked: position.isMocked,
    capturedAt: position.timestamp.toUtc(),
    isDemo: false,
  );
}
