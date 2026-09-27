import 'package:fieldnotes_client/fieldnotes_client.dart';
import 'package:fieldnotes_flutter/data/repositories/fieldnote_repository.dart';
import 'package:fieldnotes_flutter/ui/core/fieldnote_theme.dart';
import 'package:fieldnotes_flutter/ui/core/fieldnote_map.dart';
import 'package:fieldnotes_flutter/ui/core/location_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _PlacesRepository extends FieldnoteRepository {
  @override
  Future<List<PlaceSuggestion>> searchPlaces(
    String query, {
    double? biasLatitude,
    double? biasLongitude,
  }) async => [
    PlaceSuggestion(
      placeId: 'pollachi',
      primaryText: 'Pollachi',
      secondaryText: 'Tamil Nadu, India',
    ),
  ];

  @override
  Future<ResolvedPlace> resolvePlace(String placeId) async => ResolvedPlace(
    name: 'Pollachi',
    address: 'Pollachi, Tamil Nadu, India',
    latitude: 10.6629,
    longitude: 77.0067,
  );
}

void main() {
  testWidgets('existing profile pin opens at its saved location', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SelectedLocation? result;

    await tester.pumpWidget(
      MaterialApp(
        theme: buildFieldnoteTheme(),
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                result = await Navigator.push<SelectedLocation>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LocationPicker(
                      repository: _PlacesRepository(),
                      title: 'Edit profile location',
                      initialQuery: 'Saved work site',
                      initialLatitude: 10.6629,
                      initialLongitude: 77.0067,
                    ),
                  ),
                );
              },
              child: const Text('Edit location'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Edit location'));
    await tester.pumpAndSettle();

    final map = tester.widget<FieldnoteMap>(find.byType(FieldnoteMap));
    expect(map.target, const LatLng(10.6629, 77.0067));
    expect(map.zoom, 15);
    expect(map.markers, hasLength(1));
    await tester.enterText(find.byType(TextField), 'Another site');
    await tester.pump();
    final pendingMap = tester.widget<FieldnoteMap>(find.byType(FieldnoteMap));
    expect(pendingMap.target, const LatLng(10.6629, 77.0067));
    expect(pendingMap.zoom, 15);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    await tester.enterText(find.byType(TextField), 'Saved work site');
    await tester.pump();
    await tester.tap(find.text('Use this location'));
    await tester.pumpAndSettle();
    expect(result?.latitude, 10.6629);
    expect(result?.longitude, 77.0067);
  });

  testWidgets(
    'Google place selection returns the label and exact coordinates',
    (
      tester,
    ) async {
      tester.view
        ..physicalSize = const Size(390, 844)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      SelectedLocation? result;

      await tester.pumpWidget(
        MaterialApp(
          theme: buildFieldnoteTheme(),
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async {
                  result = await Navigator.push<SelectedLocation>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LocationPicker(
                        repository: _PlacesRepository(),
                        title: 'Choose location',
                        initialQuery: 'Pollachi',
                      ),
                    ),
                  );
                },
                child: const Text('Open map'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open map'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ListTile, 'Pollachi'));
      await tester.pumpAndSettle();
      expect(find.text('Pollachi, Tamil Nadu, India'), findsWidgets);
      await tester.tap(find.text('Use this location'));
      await tester.pumpAndSettle();

      expect(result?.label, 'Pollachi, Tamil Nadu, India');
      expect(result?.placeId, 'pollachi');
      expect(result?.latitude, 10.6629);
    },
  );
}
