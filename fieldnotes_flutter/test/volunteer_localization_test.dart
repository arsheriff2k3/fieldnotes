import 'package:fieldnotes_client/fieldnotes_client.dart';
import 'package:fieldnotes_flutter/client.dart';
import 'package:fieldnotes_flutter/data/repositories/fieldnote_repository.dart';
import 'package:fieldnotes_flutter/l10n/app_localizations.dart';
import 'package:fieldnotes_flutter/ui/core/fieldnote_map.dart';
import 'package:fieldnotes_flutter/ui/core/fieldnote_theme.dart';
import 'package:fieldnotes_flutter/ui/features/shell/fieldnote_view_model.dart';
import 'package:fieldnotes_flutter/ui/features/volunteer/shared_campaign_view.dart';
import 'package:fieldnotes_flutter/ui/features/volunteer/volunteer_area_map_screen.dart';
import 'package:fieldnotes_flutter/ui/features/volunteer/volunteer_status.dart';
import 'package:fieldnotes_flutter/ui/features/volunteer/volunteer_views.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MemoryAuthStorage implements ClientAuthSuccessStorage {
  AuthSuccess? _value;

  @override
  Future<AuthSuccess?> get() async => _value;

  @override
  Future<void> set(AuthSuccess? data) async => _value = data;
}

final _hi = lookupAppLocalizations(const Locale('hi'));
final _user = UuidValue.withValidation('550e8400-e29b-41d4-a716-446655440000');

Widget _app(Widget home, {Locale locale = const Locale('hi')}) => MaterialApp(
  theme: buildFieldnoteTheme(),
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

void main() {
  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
    client = Client('http://localhost:8080/')
      ..authSessionManager = FlutterAuthSessionManager(
        storage: _MemoryAuthStorage(),
      );
  });

  void setSize(WidgetTester tester) {
    tester.view
      ..physicalSize = const Size(420, 1600)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  testWidgets('volunteer screens render in Hindi without exceptions', (
    tester,
  ) async {
    setSize(tester);
    final model = FieldnoteViewModel(FieldnoteRepository());
    addTearDown(model.dispose);

    await tester.pumpWidget(
      _app(Scaffold(body: VolunteerMatchesView(viewModel: model))),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text(_hi.volunteerMatchesTitle), findsOneWidget);
    expect(find.text(_hi.volunteerTabList), findsOneWidget);
    expect(find.text(_hi.volunteerNoMatchesTitle), findsOneWidget);

    await tester.pumpWidget(
      _app(Scaffold(body: VolunteerWorkView(viewModel: model))),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text(_hi.volunteerBrowseCampaigns), findsOneWidget);

    await tester.pumpWidget(
      _app(
        SharedCampaignView(
          viewModel: model,
          campaign: Campaign(
            id: 7,
            organizationId: 1,
            name: 'पेड़ लगाना',
            description: 'Plant trees.',
            locationName: 'Pollachi',
            startsAt: DateTime.utc(2026, 10, 4, 9),
            status: CampaignStatus.active,
            createdBy: _user,
            readinessState: 'confirmed',
          ),
        ),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text('पेड़ लगाना'), findsOneWidget);

    await tester.pumpWidget(
      _app(
        const VolunteerAreaMapScreen(
          radiusKm: 10,
          initialPoint: LatLng(12.97, 80.15),
        ),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  test('pure helpers word labels in the given locale', () {
    final participation = CampaignParticipation(
      id: 1,
      campaignId: 1,
      volunteerAuthUserId: _user,
      status: ParticipationStatus.joined,
    );
    expect(
      participationDisplay(participation, null, l10n: _hi).label,
      _hi.volunteerStatusJoined,
    );
    expect(
      reviewStateLabel(ReviewState.approved, l10n: _hi),
      _hi.volunteerReviewApproved,
    );
    expect(
      availabilityWindowProblem(10, 5, l10n: _hi),
      _hi.volunteerEndAfterStart,
    );
  });
}
