import 'dart:math' as math;

import 'package:fieldnotes_client/fieldnotes_client.dart';
import 'package:fieldnotes_flutter/client.dart';
import 'package:fieldnotes_flutter/data/repositories/fieldnote_repository.dart';
import 'package:fieldnotes_flutter/l10n/app_localizations.dart';
import 'package:fieldnotes_flutter/screens/sign_in_screen.dart';
import 'package:fieldnotes_flutter/ui/core/fieldnote_theme.dart';
import 'package:fieldnotes_flutter/ui/core/legal.dart';
import 'package:fieldnotes_flutter/ui/features/shell/fieldnote_view_model.dart';
import 'package:fieldnotes_flutter/ui/features/trust/trust_center_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Keeps the test session off the platform secure-storage plugin.
class _MemoryAuthStorage implements ClientAuthSuccessStorage {
  AuthSuccess? _value;

  @override
  Future<AuthSuccess?> get() async => _value;

  @override
  Future<void> set(AuthSuccess? data) async => _value = data;
}

final _policies = LegalPolicies(
  privacyPolicyVersion: '2030-01-01',
  termsVersion: '2030-02-02',
  privacyPolicyUrl: 'https://example.test/legal/privacy',
  termsUrl: 'https://example.test/legal/terms',
  requiredConsents: allConsentKeys,
);

Widget _app(
  Widget home, {
  ThemeMode mode = ThemeMode.dark,
  Locale locale = const Locale('en'),
}) => MaterialApp(
  theme: buildFieldnoteTheme(),
  darkTheme: buildFieldnoteDarkTheme(),
  themeMode: mode,
  locale: locale,
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: AppLocalizations.supportedLocales,
  home: home,
);

double _luminance(Color color) {
  double channel(double c) =>
      c <= .03928 ? c / 12.92 : math.pow((c + .055) / 1.055, 2.4).toDouble();
  return .2126 * channel(color.r) +
      .7152 * channel(color.g) +
      .0722 * channel(color.b);
}

double _contrast(Color a, Color b) {
  final la = _luminance(a);
  final lb = _luminance(b);
  return (math.max(la, lb) + .05) / (math.min(la, lb) + .05);
}

void _setSize(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void main() {
  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
    client = Client('http://localhost:8080/')
      ..authSessionManager = FlutterAuthSessionManager(
        storage: _MemoryAuthStorage(),
      );
  });

  test('dark text tokens meet WCAG AA on every dark surface', () {
    const c = FieldnoteColorsTheme.dark;
    for (final surface in [c.canvas, c.paper, c.mist, c.raised]) {
      for (final text in [c.ink, c.forest, c.moss, c.clay, c.danger]) {
        expect(
          _contrast(text, surface),
          greaterThanOrEqualTo(4.5),
          reason: '$text on $surface',
        );
      }
    }
    expect(_contrast(c.onFill, c.forestFill), greaterThanOrEqualTo(4.5));
    expect(_contrast(c.onFill, c.inkFill), greaterThanOrEqualTo(4.5));
    expect(_contrast(c.onAcid, c.acid), greaterThanOrEqualTo(4.5));
  });

  test('light tokens keep the original brand colours', () {
    const c = FieldnoteColorsTheme.light;
    expect(c.ink, FieldnoteColors.ink);
    expect(c.paper, FieldnoteColors.paper);
    expect(c.forestFill, FieldnoteColors.forest);
    expect(c.adapt(FieldnoteColors.clay), FieldnoteColors.clay);
    expect(
      FieldnoteColorsTheme.dark.adapt(FieldnoteColors.clay),
      FieldnoteColorsTheme.dark.clay,
    );
  });

  for (final size in const [Size(390, 900), Size(1280, 900)]) {
    testWidgets('sign-in renders in dark mode at ${size.width.toInt()}px', (
      tester,
    ) async {
      _setSize(tester, size);
      await tester.pumpWidget(
        _app(const SignInScreen(child: SizedBox.shrink())),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.text('How will you create impact?'), findsOneWidget);
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
      expect(scaffold.backgroundColor, FieldnoteColorsTheme.dark.paper);
    });
  }

  testWidgets('sign-in shows Hindi strings and falls back to English', (
    tester,
  ) async {
    _setSize(tester, const Size(1280, 900));
    await tester.pumpWidget(
      _app(
        const SignInScreen(child: SizedBox.shrink()),
        mode: ThemeMode.light,
        locale: const Locale('hi'),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    // Translated key.
    expect(find.text('मेरा पहले से खाता है'), findsOneWidget);
    // Untranslated key falls back to the English template.
    expect(find.text('How will you create impact?'), findsOneWidget);
  });

  testWidgets('consent gate renders in dark mode', (tester) async {
    _setSize(tester, const Size(900, 2400));
    final model = FieldnoteViewModel(FieldnoteRepository())
      ..legalPolicies = _policies;
    addTearDown(model.dispose);

    await tester.pumpWidget(_app(LegalConsentGate(viewModel: model)));
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('Accept and continue'), findsOneWidget);
    expect(
      Theme.of(tester.element(find.byType(LegalConsentGate))).brightness,
      Brightness.dark,
    );
  });

  testWidgets('trust center loading state renders in dark mode', (
    tester,
  ) async {
    _setSize(tester, const Size(900, 1600));
    final model = FieldnoteViewModel(FieldnoteRepository())
      ..legalPolicies = _policies;
    addTearDown(model.dispose);

    await tester.pumpWidget(
      _app(Scaffold(body: TrustCenterView(viewModel: model))),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('Trust data is loading'), findsOneWidget);
  });
}
