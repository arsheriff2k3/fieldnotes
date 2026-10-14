import 'package:fieldnotes_flutter/ui/core/fieldnote_theme.dart';
import 'package:fieldnotes_flutter/ui/core/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('card list tiles can paint their background and tap effects', (
    tester,
  ) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildFieldnoteTheme(),
        home: Scaffold(
          body: SurfaceCard(
            child: ListTile(
              title: const Text('Payout history'),
              tileColor: Colors.green,
              onTap: () => tapped = true,
            ),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Payout history'));
    await tester.pumpAndSettle();
    expect(tapped, isTrue);
    expect(tester.takeException(), isNull);
  });

  for (final size in <Size>[
    const Size(320, 568),
    const Size(390, 844),
    const Size(768, 1024),
    const Size(1440, 900),
  ]) {
    testWidgets('shared layout is overflow-free at ${size.width}x${size.height}', (
      tester,
    ) async {
      tester.view
        ..physicalSize = size
        ..devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: buildFieldnoteTheme(),
          home: Scaffold(
            body: SafeArea(
              child: FieldnotePageList(
                children: [
                  const SectionHeading(
                    eyebrow: 'Responsive workspace',
                    title: 'Content that fits every screen',
                    description:
                        'Shared gutters, readable type, and natural card height.',
                  ),
                  const SizedBox(height: FieldnoteSpacing.lg),
                  ResponsiveCardGrid(
                    children: const [
                      SurfaceCard(
                        child: Text(
                          'A card with enough content to wrap naturally without a fixed height.',
                        ),
                      ),
                      SurfaceCard(
                        child: FieldnoteTextField(
                          decoration: InputDecoration(
                            labelText: 'Reusable input field',
                            hintText: 'Type here',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(FieldnotePageList), findsOneWidget);
      expect(find.byType(FieldnoteTextField), findsOneWidget);
    });
  }
}
