import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class FieldnoteColors {
  static const ink = Color(0xFF17352C);
  static const forest = Color(0xFF1D4B3B);
  static const moss = Color(0xFF6E8F5E);
  static const acid = Color(0xFFDDF7A2);
  static const paper = Color(0xFFF4F1E8);
  static const canvas = Color(0xFFE9E5D9);
  static const clay = Color(0xFFC86B49);
  static const danger = Color(0xFFB42318);
  static const mist = Color(0xFFD9E3DC);
}

ThemeData buildFieldnoteTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: FieldnoteColors.forest,
    brightness: Brightness.light,
    primary: FieldnoteColors.forest,
    secondary: FieldnoteColors.clay,
    surface: FieldnoteColors.paper,
  );
  final body = GoogleFonts.manropeTextTheme();
  final display = GoogleFonts.dmSerifDisplay();

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: FieldnoteColors.canvas,
    textTheme: body.copyWith(
      displayLarge: display.copyWith(
        fontSize: 58,
        height: .96,
        color: FieldnoteColors.ink,
      ),
      displayMedium: display.copyWith(
        fontSize: 42,
        height: 1,
        color: FieldnoteColors.ink,
      ),
      headlineLarge: display.copyWith(
        fontSize: 34,
        color: FieldnoteColors.ink,
      ),
      headlineMedium: display.copyWith(
        fontSize: 28,
        color: FieldnoteColors.ink,
      ),
      titleLarge: body.titleLarge?.copyWith(
        fontWeight: FontWeight.w800,
        color: FieldnoteColors.ink,
      ),
      titleMedium: body.titleMedium?.copyWith(fontWeight: FontWeight.w800),
      bodyLarge: body.bodyLarge?.copyWith(
        color: FieldnoteColors.ink,
        height: 1.45,
      ),
      bodyMedium: body.bodyMedium?.copyWith(
        color: FieldnoteColors.ink.withValues(alpha: .82),
        height: 1.4,
      ),
      labelLarge: body.labelLarge?.copyWith(fontWeight: FontWeight.w800),
    ),
    cardTheme: const CardThemeData(
      color: FieldnoteColors.paper,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(22)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withValues(alpha: .72),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: FieldnoteColors.ink.withValues(alpha: .1),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: FieldnoteColors.ink.withValues(alpha: .12),
        ),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        borderSide: BorderSide(color: FieldnoteColors.forest, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        textStyle: body.labelLarge?.copyWith(fontWeight: FontWeight.w800),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        side: BorderSide(color: FieldnoteColors.ink.withValues(alpha: .18)),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: FieldnoteColors.ink.withValues(alpha: .1),
      thickness: 1,
    ),
  );
}
