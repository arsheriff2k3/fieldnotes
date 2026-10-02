// Renders the FieldNote launcher icon PNGs from the geometry in
// assets/branding/icon.svg. Run from fieldnotes_flutter/:
//
//   flutter test tool/render_icon_test.dart
//   dart run flutter_launcher_icons
//
// Lives under tool/ so the normal `flutter test` run skips it.
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _forest = Color(0xFF1D4B3B);
const _acid = Color(0xFFDDF7A2);
const _ink = Color(0xFF17352C);
const _paper = Color(0xFFF4F1E8);
const _clay = Color(0xFFC86B49);

/// Draws the pin-and-note mark in the 1024x1024 SVG coordinate space.
void _paintMark(Canvas canvas) {
  const center = Offset(512, 417);
  const radius = 250.0;
  const tip = Offset(512, 857);
  final theta = math.acos(radius / (tip.dy - center.dy));
  final right =
      center + Offset(radius * math.sin(theta), radius * math.cos(theta));
  final startAngle = math.atan2(right.dy - center.dy, right.dx - center.dx);
  final pin = Path()
    ..moveTo(tip.dx, tip.dy)
    ..lineTo(right.dx, right.dy)
    ..arcTo(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      -(math.pi + 2 * startAngle),
      false,
    )
    ..close();
  canvas.drawPath(
    pin,
    Paint()
      ..color = _acid
      ..isAntiAlias = true,
  );
  canvas.drawCircle(center, 180, Paint()..color = _ink);

  final card = Path()
    ..moveTo(444, 312)
    ..lineTo(562, 312)
    ..lineTo(602, 352)
    ..lineTo(602, 500)
    ..quadraticBezierTo(602, 522, 580, 522)
    ..lineTo(444, 522)
    ..quadraticBezierTo(422, 522, 422, 500)
    ..lineTo(422, 334)
    ..quadraticBezierTo(422, 312, 444, 312)
    ..close();
  canvas.drawPath(card, Paint()..color = _paper);
  canvas.drawPath(
    Path()
      ..moveTo(562, 312)
      ..lineTo(562, 352)
      ..lineTo(602, 352)
      ..close(),
    Paint()..color = _clay,
  );
  final line = Paint()
    ..color = _forest
    ..strokeWidth = 20
    ..strokeCap = StrokeCap.round;
  canvas.drawLine(const Offset(457, 385), const Offset(567, 385), line);
  canvas.drawLine(const Offset(457, 430), const Offset(567, 430), line);
  canvas.drawLine(const Offset(457, 475), const Offset(527, 475), line);
}

Future<void> _write(String path, void Function(Canvas canvas) paint) async {
  final recorder = ui.PictureRecorder();
  paint(Canvas(recorder, const Rect.fromLTWH(0, 0, 1024, 1024)));
  final image = await recorder.endRecording().toImage(1024, 1024);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  File(path)
    ..createSync(recursive: true)
    ..writeAsBytesSync(bytes!.buffer.asUint8List());
}

void main() {
  testWidgets('render launcher icons', (tester) async {
    await tester.runAsync(() async {
      // Full-bleed icon for iOS, Android legacy and web.
      await _write('assets/branding/icon.png', (canvas) {
        canvas.drawRect(
          const Rect.fromLTWH(0, 0, 1024, 1024),
          Paint()..color = _forest,
        );
        _paintMark(canvas);
      });
      // Android adaptive foreground: transparent mark at full size.
      // flutter_launcher_icons wraps it in a 16% inset, which keeps the pin
      // (tip 345px from centre -> 23% of the canvas) inside the 66dp safe
      // circle (30.5% radius) so launcher masks never clip it.
      await _write('assets/branding/icon_foreground.png', _paintMark);
      // macOS: the platform does not mask icons, so draw the rounded tile
      // with the standard ~10% transparent margin.
      await _write('assets/branding/icon_macos.png', (canvas) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(100, 100, 824, 824),
            const Radius.circular(185),
          ),
          Paint()..color = _forest,
        );
        canvas
          ..translate(512, 512)
          ..scale(824 / 1024)
          ..translate(-512, -512);
        _paintMark(canvas);
      });
    });
  });
}
