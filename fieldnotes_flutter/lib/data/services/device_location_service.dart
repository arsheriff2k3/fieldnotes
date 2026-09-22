import 'package:geolocator/geolocator.dart';

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

  static DeviceLocation get demoVenue => DeviceLocation(
    latitude: 18.52040,
    longitude: 73.85670,
    accuracyMeters: 8,
    isLive: false,
    isMocked: true,
    capturedAt: DateTime.now().toUtc(),
    isDemo: true,
  );

  static DeviceLocation demoAt(double latitude, double longitude) =>
      DeviceLocation(
        latitude: latitude,
        longitude: longitude,
        accuracyMeters: 8,
        isLive: false,
        isMocked: true,
        capturedAt: DateTime.now().toUtc(),
        isDemo: true,
      );
}

class DeviceLocationService {
  Future<DeviceLocation> current({bool allowDemoFallback = true}) async {
    try {
      await _ensureReady();
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 12),
        ),
      );
      return _fromPosition(position);
    } catch (_) {
      if (allowDemoFallback) return DeviceLocation.demoVenue;
      rethrow;
    }
  }

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
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      throw StateError(
        'Location services are disabled. Enable Location on this device.',
      );
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      throw StateError(
        'Location permission is permanently denied. Enable Precise Location for FieldNote in device Settings.',
      );
    }
    if (permission == LocationPermission.denied) {
      throw StateError('Location permission was not granted.');
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
