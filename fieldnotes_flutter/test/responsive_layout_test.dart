import 'package:fieldnotes_flutter/ui/core/fieldnote_theme.dart';
import 'package:fieldnotes_flutter/ui/core/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
