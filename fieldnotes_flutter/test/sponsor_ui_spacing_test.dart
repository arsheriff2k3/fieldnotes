import 'dart:io';
import 'dart:ui' as ui;

import 'package:fieldnotes_flutter/ui/core/fieldnote_theme.dart';
import 'package:fieldnotes_flutter/ui/core/fieldnote_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../tool/sponsor_ui_review.dart';
import 'support/sponsor_review_fixture.dart';

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

void main() {
  setUpAll(() async {
    WidgetController.hitTestWarningShouldBeFatal = true;
    initializeReviewClient();
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
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('razorpay_flutter'),
          (_) async => null,
        );
  });
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'fieldnote.pending-account-role': 'sponsor',
    });
  });
  tearDownAll(_contactSheets);
  final names = sponsorReviewScreens(
    SponsorReviewRepository(),
    sponsorReviewModel(SponsorReviewRepository()),
  ).keys.toList();
  for (final width in [390.0, 320.0]) {
    final scale = width == 320 ? 1.6 : 1.0;
    for (final name in names) {
      testWidgets(
        'sponsor $name fits ${width.toInt()}px at text scale $scale',
        (tester) async {
          tester.view
            ..physicalSize = Size(width, 844)
            ..devicePixelRatio = 1;
          addTearDown(tester.view.reset);
          final repo = SponsorReviewRepository();
          final model = sponsorReviewModel(repo);
          addTearDown(model.dispose);
          model.impacts[1] = await repo.impact(1);
          final key = GlobalKey();
          await _pump(
            tester,
            sponsorReviewScreens(repo, model)[name]!(),
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
  final modals = sponsorReviewModals(
    SponsorReviewRepository(),
    sponsorReviewModel(SponsorReviewRepository()),
  ).keys.toList();
  for (final name in modals) {
    testWidgets('sponsor $name modal remains usable with keyboard', (
      tester,
    ) async {
      tester.view
        ..physicalSize = const Size(390, 844)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final repo = SponsorReviewRepository();
      final model = sponsorReviewModel(repo);
      addTearDown(model.dispose);
      final key = GlobalKey();
      await _pump(
        tester,
        Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: TextButton(
                onPressed: () =>
                    sponsorReviewModals(repo, model)[name]!(context),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
        key,
        1,
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await _capture(tester, key, '$name-modal');
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await _capture(tester, key, '$name-keyboard');
      await _captureScrollEnd(tester, key, '$name-keyboard-bottom');
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
    });
  }
  final interactions = <(String, String, String)>[
    ('readiness', 'Revise scope', 'revise-scope'),
    ('readiness', 'Cancel', 'cancel-campaign'),
    ('readiness', 'Postpone', 'postpone-date'),
    ('reach', 'Invite area', 'invite-area'),
    ('trust', 'Withdraw consent', 'withdraw-consent'),
    ('trust', 'View all 8 events', 'security-activity-sheet'),
    ('profile', 'Edit profile', 'profile-editor'),
    ('manual-payout', 'Request payout', 'request-payout'),
    ('payout-operations', 'Approve for transfer', 'approve-payout'),
    ('payout-operations', 'Reject request', 'reject-payout'),
    ('payout-operations', 'Record completed transfer', 'record-transfer'),
    ('reach', '@joined', 'joined-area-sheet'),
    ('reach', '@bucket', 'volunteer-bucket-sheet'),
  ];
  for (final (screen, button, name) in interactions) {
    testWidgets('sponsor $name opens without clipping', (tester) async {
      tester.view
        ..physicalSize = const Size(390, 844)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final repo = SponsorReviewRepository()
        ..processingRequest = name == 'record-transfer';
      final model = sponsorReviewModel(repo);
      addTearDown(model.dispose);
      final key = GlobalKey();
      await _pump(tester, sponsorReviewScreens(repo, model)[screen]!(), key, 1);
      if (button.startsWith('@')) {
        final map = tester.widget<FieldnoteMap>(find.byType(FieldnoteMap));
        final marker = map.markers.firstWhere(
          (m) => button == '@bucket'
              ? m.markerId.value.startsWith('area:')
              : m.markerId.value.endsWith(',joined'),
        );
        marker.onTap!();
      } else {
        final target = find.text(button);
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
      if (name.endsWith('sheet')) {
        expect(find.byType(BottomSheet), findsOneWidget);
      } else if (name != 'profile-editor' && name != 'postpone-date') {
        expect(find.byType(AlertDialog), findsOneWidget);
      }
      await _capture(tester, key, name);
      if (name == 'postpone-date') {
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await _capture(tester, key, 'postpone-time');
      } else {
        tester.view.viewInsets = const FakeViewPadding(bottom: 300);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await _capture(tester, key, '$name-keyboard');
        await _captureScrollEnd(tester, key, '$name-keyboard-bottom');
      }
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
    });
  }
}
