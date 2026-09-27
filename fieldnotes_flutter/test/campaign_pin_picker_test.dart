import 'package:fieldnotes_client/fieldnotes_client.dart';
import 'package:fieldnotes_flutter/data/repositories/fieldnote_repository.dart';
import 'package:fieldnotes_flutter/ui/core/fieldnote_theme.dart';
import 'package:fieldnotes_flutter/ui/features/sponsor/campaign_pin_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _PlacesRepository extends FieldnoteRepository {
  String? searchedQuery;
  double? searchedBiasLatitude;

  @override
  Future<bool> placeSearchAvailable() async => true;

  @override
  Future<List<PlaceSuggestion>> searchPlaces(
    String query, {
    double? biasLatitude,
    double? biasLongitude,
  }) async {
    searchedQuery = query;
    searchedBiasLatitude = biasLatitude;
    return [
      PlaceSuggestion(
        placeId: 'pollachi',
        primaryText: 'Pollachi',
        secondaryText: 'Tamil Nadu, India',
      ),
    ];
  }

  @override
  Future<ResolvedPlace> resolvePlace(String placeId) async => ResolvedPlace(
    name: 'Pollachi',
    address: 'Pollachi, Tamil Nadu, India',
    latitude: 10.6629,
    longitude: 77.0067,
  );
}

void main() {
  testWidgets('AI place requires a Google result before selecting a pin', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repository = _PlacesRepository();
    CampaignPin? selected;

    await tester.pumpWidget(
      MaterialApp(
        theme: buildFieldnoteTheme(),
        home: Scaffold(
          body: SingleChildScrollView(
            child: CampaignPinPicker(
              repository: repository,
              pin: const CampaignPin(
                latitude: 20.5937,
                longitude: 78.9629,
                locationName: 'Pollachi',
                geofenceMeters: 200,
                isDeviceLocation: false,
              ),
              locationSelected: false,
              onChanged: (pin) => selected = pin,
              onUseDeviceLocation: () async {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(repository.searchedQuery, 'Pollachi');
    expect(repository.searchedBiasLatitude, isNull);
    expect(find.text('Location not selected'), findsOneWidget);
    expect(selected, isNull);

    await tester.tap(find.text('Pollachi').last);
    await tester.pumpAndSettle();

    expect(selected?.latitude, 10.6629);
    expect(selected?.longitude, 77.0067);
    expect(selected?.locationName, 'Pollachi, Tamil Nadu, India');
  });

  testWidgets('campaign search follows an externally selected pin', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var pin = const CampaignPin(
      latitude: 10.0,
      longitude: 77.0,
      locationName: 'First site',
      geofenceMeters: 200,
      isDeviceLocation: false,
    );
    bool? searchPending;
    late StateSetter update;

    await tester.pumpWidget(
      MaterialApp(
        theme: buildFieldnoteTheme(),
        home: Scaffold(
          body: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (context, setState) {
                update = setState;
                return CampaignPinPicker(
                  repository: _PlacesRepository(),
                  pin: pin,
                  locationSelected: true,
                  onChanged: (value) => setState(() => pin = value),
                  onUseDeviceLocation: () async {},
                  onSearchPendingChanged: (value) => searchPending = value,
                );
              },
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(EditableText).first, 'Other site');
    expect(searchPending, isTrue);

    update(() {
      pin = pin.copyWith(
        latitude: 11.0,
        longitude: 78.0,
        locationName: 'GPS site',
      );
    });
    await tester.pumpAndSettle();
    expect(find.text('GPS site'), findsWidgets);
    expect(find.text('Other site'), findsNothing);
  });
}
