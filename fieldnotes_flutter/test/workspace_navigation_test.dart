import 'package:fieldnotes_flutter/l10n/app_localizations.dart';
import 'package:fieldnotes_flutter/ui/core/fieldnote_theme.dart';
import 'package:fieldnotes_flutter/ui/features/shell/workspace_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final sponsor in [true, false]) {
    for (final locale in ['en', 'hi', 'ta']) {
      for (final width in [320.0, 390.0, 768.0]) {
        testWidgets(
          '${sponsor ? 'Sponsor' : 'Volunteer'} navigation in $locale at $width',
          (tester) async {
            tester.view.physicalSize = Size(width, 800);
            tester.view.devicePixelRatio = 1;
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);
            var selected = 0;
            late StateSetter update;
            await tester.pumpWidget(
              MaterialApp(
                theme: ThemeData(
                  brightness: width == 320 ? Brightness.dark : Brightness.light,
                  extensions: [
                    width == 320
                        ? FieldnoteColorsTheme.dark
                        : FieldnoteColorsTheme.light,
                  ],
                ),
                locale: Locale(locale),
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: StatefulBuilder(
                  builder: (context, setState) {
                    update = setState;
                    final l = AppLocalizations.of(context);
                    final items = sponsor
                        ? [
                            WorkspaceDestination(
                              l.navDiscover,
                              Icons.explore_outlined,
                              Icons.explore,
                            ),
                            WorkspaceDestination(
                              l.navImpact,
                              Icons.insights_outlined,
                              Icons.insights,
                            ),
                            WorkspaceDestination(
                              l.navCreate,
                              Icons.add_box_outlined,
                              Icons.add_box,
                            ),
                            WorkspaceDestination(
                              l.navTrust,
                              Icons.shield_outlined,
                              Icons.shield,
                            ),
                            WorkspaceDestination(
                              l.navProfile,
                              Icons.person_outline,
                              Icons.person,
                            ),
                          ]
                        : [
                            WorkspaceDestination(
                              l.navMatches,
                              Icons.travel_explore_outlined,
                              Icons.travel_explore,
                            ),
                            WorkspaceDestination(
                              l.navMyWork,
                              Icons.hiking_outlined,
                              Icons.hiking,
                            ),
                            WorkspaceDestination(
                              l.navAvailability,
                              Icons.event_available_outlined,
                              Icons.event_available,
                              compactLabel: l.navSchedule,
                            ),
                            WorkspaceDestination(
                              l.navTrust,
                              Icons.shield_outlined,
                              Icons.shield,
                            ),
                            WorkspaceDestination(
                              l.navProfile,
                              Icons.person_outline,
                              Icons.person,
                            ),
                          ];
                    return MediaQuery(
                      data: MediaQuery.of(context).copyWith(
                        textScaler: TextScaler.linear(width == 320 ? 2 : 1),
                        padding: const EdgeInsets.only(bottom: 24),
                        disableAnimations: width == 768,
                      ),
                      child: Scaffold(
                        bottomNavigationBar: WorkspaceBottomNavigation(
                          destinations: items,
                          selectedIndex: selected,
                          dockedActionIndex: sponsor ? 2 : null,
                          onSelected: (index) => update(() => selected = index),
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
            await tester.pumpAndSettle();
            for (final index in [4, 1, 3, 2, 0]) {
              final target = find.byKey(ValueKey('workspace-nav-$index'));
              final size = tester.getSize(target);
              expect(size.width, greaterThanOrEqualTo(48));
              expect(size.height, greaterThanOrEqualTo(48));
              if (!sponsor || index != 2) {
                final rect = tester.getRect(target);
                final icon = tester.getRect(
                  find.descendant(of: target, matching: find.byType(Icon)),
                );
                final label = tester.getRect(
                  find.descendant(of: target, matching: find.byType(Text)),
                );
                // Visual content should have balanced space above and below it.
                expect(
                  ((icon.top - rect.top) - (rect.bottom - label.bottom)).abs(),
                  lessThanOrEqualTo(4),
                );
              }
              await tester.tap(target);
              await tester.pumpAndSettle();
              expect(selected, index);
              expect(tester.takeException(), isNull);
            }
            await tester.pumpWidget(const SizedBox());
          },
        );
      }
    }
  }
}
