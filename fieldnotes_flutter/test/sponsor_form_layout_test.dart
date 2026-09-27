import 'package:fieldnotes_flutter/ui/core/fieldnote_theme.dart';
import 'package:fieldnotes_flutter/ui/features/sponsor/sponsor_views.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('manual campaign form fits a compact portrait screen', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(360, 640)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildFieldnoteTheme(),
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showProposalFormDialog(
                context,
                heading: 'Create a campaign manually',
                confirmLabel: 'Use these details',
              ),
              child: const Text('Open form'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open form'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Basics'), findsOneWidget);
    expect(find.text('Schedule and capacity'), findsOneWidget);
    expect(find.text('Use these details'), findsOneWidget);
  });
}
