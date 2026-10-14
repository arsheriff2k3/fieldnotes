import 'dart:io';
import 'dart:ui' as ui;

import 'package:fieldnotes_flutter/ui/core/fieldnote_theme.dart';
import 'package:fieldnotes_flutter/ui/core/fieldnote_map.dart';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
// Maps tiles are replaced by a local surface; the UI and marker actions stay real.
// ignore: depend_on_referenced_packages
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:fieldnotes_flutter/data/services/map_config_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../tool/sponsor_ui_review.dart' show initializeReviewClient;
import 'package:fieldnotes_flutter/ui/core/widgets.dart';
import 'package:fieldnotes_flutter/ui/core/in_app_maps.dart';
import 'package:fieldnotes_flutter/ui/features/volunteer/volunteer_views.dart';
import 'package:fieldnotes_flutter/ui/features/volunteer/volunteer_history_view.dart';
import 'package:fieldnotes_flutter/ui/features/volunteer/shared_campaign_view.dart';
import 'package:fieldnotes_flutter/ui/features/volunteer/volunteer_area_map_screen.dart';
import 'package:fieldnotes_flutter/ui/features/profile/profile_view.dart';
import 'package:fieldnotes_flutter/ui/features/trust/trust_center_view.dart';
import 'package:fieldnotes_flutter/ui/features/trust/account_data_export_view.dart';
import 'package:fieldnotes_flutter/ui/features/onboarding/onboarding_view.dart';
import 'package:fieldnotes_flutter/ui/features/shell/fieldnote_view_model.dart';
import 'support/volunteer_review_fixture.dart';

const screenshotPath = String.fromEnvironment('UI_REVIEW_SCREENSHOTS');
final _images = <String, ui.Image>{};

Future<void> _capture(WidgetTester tester, GlobalKey key, String name) async {
  if (screenshotPath.isEmpty) return;
  await tester.runAsync(() async {
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage();
    _images[name] = image;
    final png = await image.toByteData(format: ui.ImageByteFormat.png);
    await Directory(screenshotPath).create(recursive: true);
    await File(
      '$screenshotPath/$name.png',
    ).writeAsBytes(png!.buffer.asUint8List());
  });
}

Future<void> _captureScrollEnd(
  WidgetTester tester,
  GlobalKey key,
  String name,
) async {
  final vertical = find.byType(Scrollable).evaluate().where((e) {
    final state = (e as StatefulElement).state as ScrollableState;
    return state.position.axis == Axis.vertical &&
        state.position.maxScrollExtent > 0;
  }).toList();
  if (vertical.isEmpty) return;
  final state = (vertical.last as StatefulElement).state as ScrollableState;
  state.position.jumpTo(state.position.maxScrollExtent);
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
  await _capture(tester, key, name);
}

Future<void> _contactSheets() async {
  if (screenshotPath.isEmpty) return;
  final entries = _images.entries.toList();
  for (var start = 0; start < entries.length; start += 6) {
    final group = entries.skip(start).take(6).toList();
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder)..drawColor(Colors.white, BlendMode.src);
    for (var i = 0; i < group.length; i++) {
      final entry = group[i];
      final x = (i % 3) * 390.0;
      final y = (i ~/ 3) * 890.0;
      final label = TextPainter(
        text: TextSpan(
          text: entry.key,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 15,
            fontFamily: 'Manrope_regular',
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: 380);
      label.paint(canvas, Offset(x + 4, y + 8));
      canvas.drawImageRect(
        entry.value,
        Rect.fromLTWH(
          0,
          0,
          entry.value.width.toDouble(),
          entry.value.height.toDouble(),
        ),
        Rect.fromLTWH(x, y + 40, 390, 844),
        Paint(),
      );
    }
    final picture = recorder.endRecording();
    final image = await picture.toImage(1170, group.length > 3 ? 1780 : 890);
    final png = await image.toByteData(format: ui.ImageByteFormat.png);
    await File(
      '$screenshotPath/contact-${start ~/ 6}.png',
    ).writeAsBytes(png!.buffer.asUint8List());
    image.dispose();
    picture.dispose();
  }
  for (final image in _images.values) {
    image.dispose();
  }
}

Future<void> _pump(
  WidgetTester tester,
  Widget home,
  GlobalKey key,
  double scale,
) async {
  await tester.pumpWidget(
    RepaintBoundary(
      key: key,
      child: MaterialApp(
        theme: buildFieldnoteTheme(),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: home,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Map<String, Widget Function()> volunteerScreens(
  VolunteerReviewRepository repo,
  FieldnoteViewModel model,
) => {
  'matches': () => Scaffold(
    body: SafeArea(child: VolunteerMatchesView(viewModel: model)),
  ),
  'my-work': () => Scaffold(
    body: SafeArea(child: VolunteerWorkView(viewModel: model)),
  ),
  'availability': () => Scaffold(
    body: SafeArea(child: VolunteerAvailabilityView(viewModel: model)),
  ),
  'history': () => VolunteerHistoryScreen(viewModel: model),
  'shared-campaign': () =>
      SharedCampaignView(viewModel: model, campaign: volunteerUpcomingCampaign),
  'travel': () => TravelMapScreen(
    campaign: volunteerCurrentCampaign,
    repository: repo,
    canStartTravel: true,
  ),
  'travel-area': () => const VolunteerAreaMapScreen(
    radiusKm: 10,
    initialPoint: LatLng(18.52, 73.85),
  ),
  'profile': () => Scaffold(
    body: SafeArea(child: ProfileView(viewModel: model)),
  ),
  'trust': () => Scaffold(
    body: SafeArea(child: TrustCenterView(viewModel: model)),
  ),
  'consent': () => LegalConsentGate(viewModel: model),
  'onboarding': () => OnboardingView(viewModel: model),
  'account-export': () => AccountDataExportView(viewModel: model),
};

class _ReviewMaps extends GoogleMapsFlutterPlatform {
  @override
  Widget buildViewWithConfiguration(
    int creationId,
    PlatformViewCreatedCallback onPlatformViewCreated, {
    required MapWidgetConfiguration widgetConfiguration,
    MapConfiguration mapConfiguration = const MapConfiguration(),
    MapObjects mapObjects = const MapObjects(),
  }) => const ColoredBox(
    color: Color(0xffdce7dd),
    child: Center(child: Icon(Icons.map_outlined)),
  );
}

void main() {
  setUpAll(() async {
    WidgetController.hitTestWarningShouldBeFatal = true;
    initializeReviewClient();
    GoogleMapsFlutterPlatform.instance = _ReviewMaps();
    await MapConfig.load();
    GoogleFonts.config.allowRuntimeFetching = false;
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
    final roboto = FontLoader('Roboto')
      ..addFont(rootBundle.load('assets/fonts/Roboto-Regular.ttf'));
    await roboto.load();
    final fallback = FontLoader('Ahem')
      ..addFont(rootBundle.load('assets/fonts/Roboto-Regular.ttf'));
    await fallback.load();
    final fonts = Directory('/tmp/fieldnote-review-fonts');
    if (screenshotPath.isNotEmpty && fonts.existsSync()) {
      for (final file in fonts.listSync().whereType<File>()) {
        final family = file.uri.pathSegments.last.replaceAll('.ttf', '');
        final loader = FontLoader(family)
          ..addFont(Future.value(ByteData.sublistView(file.readAsBytesSync())));
        await loader.load();
      }
    }
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('com.llfbandit.record/messages'),
          (_) async => null,
        );
    for (final channel in [
      'flutter.baseflow.com/geolocator',
      'flutter.baseflow.com/geolocator_android',
    ]) {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(MethodChannel(channel), (call) async {
            if (call.method == 'checkPermission' ||
                call.method == 'requestPermission') {
              return 3;
            }
            if (call.method == 'isLocationServiceEnabled') return true;
            if (call.method == 'getCurrentPosition') {
              return {
                'latitude': 18.52,
                'longitude': 73.85,
                'timestamp': DateTime.now().millisecondsSinceEpoch,
                'accuracy': 8.0,
              };
            }
            return null;
          });
    }
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('razorpay_flutter'),
          (_) async => null,
        );
  });
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'fieldnote.pending-account-role': 'volunteer',
    });
  });
  tearDownAll(_contactSheets);
  final names = [
    'matches',
    'my-work',
    'availability',
    'history',
    'shared-campaign',
    'travel',
    'travel-area',
    'profile',
    'trust',
    'consent',
    'onboarding',
    'account-export',
  ];
  for (final width in [390.0, 320.0]) {
    final scale = width == 320 ? 1.6 : 1.0;
    for (final name in names) {
      testWidgets(
        'volunteer $name fits ${width.toInt()}px at text scale $scale',
        (tester) async {
          tester.view
            ..physicalSize = Size(width, 844)
            ..devicePixelRatio = 1;
          addTearDown(tester.view.reset);
          final repo = VolunteerReviewRepository();
          final model = await volunteerReviewModel(repo);
          addTearDown(model.dispose);
          final key = GlobalKey();
          await _pump(
            tester,
            volunteerScreens(repo, model)[name]!(),
            key,
            scale,
          );
          expect(tester.takeException(), isNull);
          await _capture(tester, key, '$name-${width.toInt()}-top');
          final vertical = find.byType(Scrollable).evaluate().where((e) {
            final state = (e as StatefulElement).state as ScrollableState;
            return state.position.axis == Axis.vertical &&
                state.position.maxScrollExtent > 0;
          }).toList();
          if (vertical.isNotEmpty) {
            final state =
                (vertical.first as StatefulElement).state as ScrollableState;
            state.position.jumpTo(state.position.maxScrollExtent);
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
            await _capture(tester, key, '$name-${width.toInt()}-bottom');
          }
          await tester.pumpWidget(const SizedBox());
          await tester.pump();
        },
      );
    }
  }

  final interactions = <(String, String, String)>[
    ('my-work', 'Leave campaign', 'leave-campaign'),
    ('my-work', 'Submit evidence', 'evidence-submission'),
    ('matches', '@map', 'matches-map-tab'),
    ('matches', '@invites', 'invites-tab'),
    ('matches', '@match', 'match-details-sheet'),
    ('availability', '@time', 'availability-time-picker'),
    ('travel', 'View route steps', 'route-steps-sheet'),
    ('profile', 'Edit profile', 'profile-editor'),
    ('trust', 'View all 8 events', 'security-activity-sheet'),
  ];
  for (final (screen, button, name) in interactions) {
    testWidgets('volunteer $name remains usable with keyboard', (tester) async {
      tester.view
        ..physicalSize = const Size(384, 856)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final repo = VolunteerReviewRepository();
      final model = await volunteerReviewModel(repo);
      addTearDown(model.dispose);
      final key = GlobalKey();
      await _pump(tester, volunteerScreens(repo, model)[screen]!(), key, 1);
      if (name == 'evidence-submission') {
        final context = tester.element(find.byType(Scaffold).first);
        showFieldnoteBottomSheet<void>(
          context: context,
          builder: (_) => CompletionEvidenceSheet(
            campaign: volunteerCurrentCampaign,
            participation: volunteerCheckedIn,
            viewModel: model,
          ),
        );
      } else if (name == 'match-details-sheet') {
        await tester.tap(find.text('Map'));
        await tester.pumpAndSettle();
        final map = tester.widget<FieldnoteMap>(
          find.byType(FieldnoteMap).first,
        );
        map.markers
            .firstWhere(
              (marker) => marker.markerId.value.startsWith('campaign-'),
            )
            .onTap!();
      } else {
        final target = button == '@map'
            ? find.text('Map')
            : button == '@invites'
            ? find.text('Invites')
            : button == '@match'
            ? find.text('Neighbourhood park cleanup')
            : button == '@time'
            ? find.byIcon(Icons.schedule).first
            : find.text(button);
        if (target.evaluate().isEmpty) {
          await tester.scrollUntilVisible(
            target,
            250,
            scrollable: find.byType(Scrollable).first,
          );
        }
        await tester.ensureVisible(target);
        await tester.pumpAndSettle();
        await tester.tap(target);
      }
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      if (name == 'profile-editor') {
        expect(
          find.byWidgetPredicate((widget) => widget is TextField),
          findsWidgets,
        );
      }
      if (name == 'leave-campaign') {
        expect(find.byType(AlertDialog), findsOneWidget);
      }
      if (name == 'availability-time-picker') {
        expect(find.byType(TimePickerDialog), findsOneWidget);
      }
      if ([
        'evidence-submission',
        'match-details-sheet',
        'route-steps-sheet',
        'security-activity-sheet',
      ].contains(name)) {
        expect(find.byType(BottomSheet), findsOneWidget);
      }
      await _capture(tester, key, name);
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await _capture(tester, key, '$name-keyboard');
      await _captureScrollEnd(tester, key, '$name-keyboard-bottom');
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
    });
  }
}
