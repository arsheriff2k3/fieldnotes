import 'package:fieldnotes_flutter/ui/core/fieldnote_map.dart';
import 'package:fieldnotes_flutter/ui/core/fieldnote_theme.dart';
import 'package:fieldnotes_flutter/ui/features/volunteer/volunteer_area_map_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('expanded volunteer map returns the selected travel area', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    LatLng? chosen;

    await tester.pumpWidget(
      MaterialApp(
        theme: buildFieldnoteTheme(),
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                chosen = await Navigator.of(context).push<LatLng>(
                  MaterialPageRoute(
                    builder: (_) => const VolunteerAreaMapScreen(
                      radiusKm: 10,
                      initialPoint: LatLng(12.97, 80.15),
                    ),
                  ),
                );
              },
              child: const Text('Expand map'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Expand map'));
    await tester.pumpAndSettle();
    var map = tester.widget<FieldnoteMap>(find.byType(FieldnoteMap));
    expect(map.target, const LatLng(12.97, 80.15));
    expect(map.circles.single.radius, 10000);

    map.onTap!(const LatLng(12.99, 80.17));
    await tester.pump();
    map = tester.widget<FieldnoteMap>(find.byType(FieldnoteMap));
    expect(map.markers.single.position, const LatLng(12.99, 80.17));
    expect(map.circles.single.center, const LatLng(12.99, 80.17));

    await tester.tap(find.text('Use this area'));
    await tester.pumpAndSettle();
    expect(chosen, const LatLng(12.99, 80.17));
  });
}
