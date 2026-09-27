/// Android and iOS read the Maps SDK key from native configuration
/// (`AndroidManifest.xml` and `AppDelegate.swift`), so there is nothing to
/// load at runtime here.
Future<bool> bootstrapMapsSdk(String apiKey) async => true;
