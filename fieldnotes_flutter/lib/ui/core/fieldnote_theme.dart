import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// The FieldNote brand palette (light appearance).
///
/// These constants are the light values of [FieldnoteColorsTheme]. Widgets
/// should read colours through `context.fieldnoteColors` so they follow the
/// active brightness; the constants stay for brand assets (icon, share
/// cards) and for pure functions that return a brand colour, which callers
/// map with [FieldnoteColorsTheme.adapt].
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

/// Theme-aware FieldNote colour tokens.
///
/// Foreground accents ([ink], [forest], [moss], [clay], [danger]) are used for
/// text, icons, borders and tinted (`withValues(alpha: .1)`) backgrounds;
/// in dark mode they become lighter so text keeps WCAG AA contrast on the
/// dark surfaces. Solid brand fills that carry [onFill] text use
/// [forestFill] / [inkFill]; [acid] is always paired with [onAcid].
@immutable
class FieldnoteColorsTheme extends ThemeExtension<FieldnoteColorsTheme> {
  const FieldnoteColorsTheme({
    required this.brightness,
    required this.ink,
    required this.forest,
    required this.moss,
    required this.clay,
    required this.danger,
    required this.canvas,
    required this.paper,
    required this.mist,
    required this.raised,
    required this.forestFill,
    required this.inkFill,
    required this.onFill,
    required this.acid,
    required this.onAcid,
    required this.successSurface,
    required this.errorSurface,
    required this.errorAccent,
    required this.infoSurface,
    required this.shadow,
    required this.mapFallback,
  });

  final Brightness brightness;

  /// Primary text and icons.
  final Color ink;

  /// Brand green used as an accent (text, icons, outlines, tints).
  final Color forest;
  final Color moss;
  final Color clay;
  final Color danger;

  /// Scaffold background.
  final Color canvas;

  /// Cards and sheets.
  final Color paper;

  /// Muted tinted surface (tab bars, banners, chips).
  final Color mist;

  /// Raised surface that was pure white in the light design.
  final Color raised;

  /// Solid brand green behind [onFill] content.
  final Color forestFill;

  /// Solid deep-ink panel behind [onFill] content (hero/story panels).
  final Color inkFill;

  /// Text and icons on [forestFill] / [inkFill].
  final Color onFill;

  /// Highlight lime, used as a fill or as text on [forestFill]/[inkFill].
  final Color acid;

  /// Content placed on [acid].
  final Color onAcid;

  final Color successSurface;
  final Color errorSurface;
  final Color errorAccent;
  final Color infoSurface;
  final Color shadow;

  /// Background of the coordinate panel shown when map tiles are unavailable.
  final Color mapFallback;

  bool get isDark => brightness == Brightness.dark;

  static const light = FieldnoteColorsTheme(
    brightness: Brightness.light,
    ink: FieldnoteColors.ink,
    forest: FieldnoteColors.forest,
    moss: FieldnoteColors.moss,
    clay: FieldnoteColors.clay,
    danger: FieldnoteColors.danger,
    canvas: FieldnoteColors.canvas,
    paper: FieldnoteColors.paper,
    mist: FieldnoteColors.mist,
    raised: Colors.white,
    forestFill: FieldnoteColors.forest,
    inkFill: FieldnoteColors.ink,
    onFill: Colors.white,
    acid: FieldnoteColors.acid,
    onAcid: FieldnoteColors.ink,
    successSurface: Color(0xFFF1F8F3),
    errorSurface: Color(0xFFFFF1EF),
    errorAccent: Color(0xFF9D352F),
    infoSurface: Color(0xFFF4F1E8),
    shadow: FieldnoteColors.ink,
    mapFallback: FieldnoteColors.mist,
  );

  // WCAG contrast of the dark accents on [paper] (#18221E): ink 13.8:1,
  // forest 9.2:1, moss 8.9:1, clay 7.6:1, danger 7.4:1; on [mist] all stay
  // >= 6:1. onFill on forestFill 8.0:1, acid on forestFill 6.8:1.
  static const dark = FieldnoteColorsTheme(
    brightness: Brightness.dark,
    ink: Color(0xFFE6EEE8),
    forest: Color(0xFF8ED1B0),
    moss: Color(0xFFA9C99A),
    clay: Color(0xFFEE9E80),
    danger: Color(0xFFFF8F80),
    canvas: Color(0xFF101815),
    paper: Color(0xFF18221E),
    mist: Color(0xFF26332D),
    raised: Color(0xFF212D28),
    forestFill: Color(0xFF235A46),
    inkFill: Color(0xFF0B1310),
    onFill: Colors.white,
    acid: FieldnoteColors.acid,
    onAcid: FieldnoteColors.ink,
    successSurface: Color(0xFF16291F),
    errorSurface: Color(0xFF2E1A18),
    errorAccent: Color(0xFFFF9E92),
    infoSurface: Color(0xFF1E2823),
    shadow: Colors.black,
    mapFallback: Color(0xFF1D2A24),
  );

  /// Maps a light brand constant from [FieldnoteColors] to this theme's
  /// token. Lets pure helpers keep returning `FieldnoteColors.*` while the
  /// widget that paints the colour follows the active brightness. Unknown
  /// colours are returned unchanged.
  Color adapt(Color color) {
    if (color == FieldnoteColors.ink) return ink;
    if (color == FieldnoteColors.forest) return forest;
    if (color == FieldnoteColors.moss) return moss;
    if (color == FieldnoteColors.clay) return clay;
    if (color == FieldnoteColors.danger) return danger;
    if (color == FieldnoteColors.paper) return paper;
    if (color == FieldnoteColors.canvas) return canvas;
    if (color == FieldnoteColors.mist) return mist;
    if (color == FieldnoteColors.acid) return acid;
    return color;
  }

  @override
  FieldnoteColorsTheme copyWith({
    Brightness? brightness,
    Color? ink,
    Color? forest,
    Color? moss,
    Color? clay,
    Color? danger,
    Color? canvas,
    Color? paper,
    Color? mist,
    Color? raised,
    Color? forestFill,
    Color? inkFill,
    Color? onFill,
    Color? acid,
    Color? onAcid,
    Color? successSurface,
    Color? errorSurface,
    Color? errorAccent,
    Color? infoSurface,
    Color? shadow,
    Color? mapFallback,
  }) {
    return FieldnoteColorsTheme(
      brightness: brightness ?? this.brightness,
      ink: ink ?? this.ink,
      forest: forest ?? this.forest,
      moss: moss ?? this.moss,
      clay: clay ?? this.clay,
      danger: danger ?? this.danger,
      canvas: canvas ?? this.canvas,
      paper: paper ?? this.paper,
      mist: mist ?? this.mist,
      raised: raised ?? this.raised,
      forestFill: forestFill ?? this.forestFill,
      inkFill: inkFill ?? this.inkFill,
      onFill: onFill ?? this.onFill,
      acid: acid ?? this.acid,
      onAcid: onAcid ?? this.onAcid,
      successSurface: successSurface ?? this.successSurface,
      errorSurface: errorSurface ?? this.errorSurface,
      errorAccent: errorAccent ?? this.errorAccent,
      infoSurface: infoSurface ?? this.infoSurface,
      shadow: shadow ?? this.shadow,
      mapFallback: mapFallback ?? this.mapFallback,
    );
  }

  @override
  FieldnoteColorsTheme lerp(FieldnoteColorsTheme? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return FieldnoteColorsTheme(
      brightness: t < .5 ? brightness : other.brightness,
      ink: l(ink, other.ink),
      forest: l(forest, other.forest),
      moss: l(moss, other.moss),
      clay: l(clay, other.clay),
      danger: l(danger, other.danger),
      canvas: l(canvas, other.canvas),
      paper: l(paper, other.paper),
      mist: l(mist, other.mist),
      raised: l(raised, other.raised),
      forestFill: l(forestFill, other.forestFill),
      inkFill: l(inkFill, other.inkFill),
      onFill: l(onFill, other.onFill),
      acid: l(acid, other.acid),
      onAcid: l(onAcid, other.onAcid),
      successSurface: l(successSurface, other.successSurface),
      errorSurface: l(errorSurface, other.errorSurface),
      errorAccent: l(errorAccent, other.errorAccent),
      infoSurface: l(infoSurface, other.infoSurface),
      shadow: l(shadow, other.shadow),
      mapFallback: l(mapFallback, other.mapFallback),
    );
  }
}

extension FieldnoteColorsContext on BuildContext {
  /// The FieldNote colour tokens for the active theme. Falls back to the
  /// light tokens when a widget is pumped without the FieldNote theme.
  FieldnoteColorsTheme get fieldnoteColors =>
      Theme.of(this).extension<FieldnoteColorsTheme>() ??
      FieldnoteColorsTheme.light;
}

ThemeData buildFieldnoteTheme() =>
    _buildTheme(FieldnoteColorsTheme.light, Brightness.light);

ThemeData buildFieldnoteDarkTheme() =>
    _buildTheme(FieldnoteColorsTheme.dark, Brightness.dark);

ThemeData _buildTheme(FieldnoteColorsTheme c, Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final scheme = dark
      ? ColorScheme.fromSeed(
          seedColor: FieldnoteColors.forest,
          brightness: Brightness.dark,
          primary: c.forest,
          onPrimary: const Color(0xFF0B2A1F),
          secondary: c.clay,
          onSecondary: const Color(0xFF3A1406),
          error: c.danger,
          surface: c.paper,
          onSurface: c.ink,
        )
      : ColorScheme.fromSeed(
          seedColor: FieldnoteColors.forest,
          brightness: Brightness.light,
          primary: FieldnoteColors.forest,
          secondary: FieldnoteColors.clay,
          surface: FieldnoteColors.paper,
        );
  // Light keeps google_fonts' default base (ThemeData.light()) so the light
  // appearance is unchanged; dark needs light-on-dark defaults.
  final baseText = dark
      ? ThemeData.dark().textTheme
      : ThemeData.light().textTheme;
  final body = GoogleFonts.manropeTextTheme(baseText);
  final display = GoogleFonts.dmSerifDisplay();

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    extensions: [c],
    scaffoldBackgroundColor: c.canvas,
    textTheme: body.copyWith(
      displayLarge: display.copyWith(
        fontSize: 58,
        height: .96,
        color: c.ink,
      ),
      displayMedium: display.copyWith(
        fontSize: 42,
        height: 1,
        color: c.ink,
      ),
      headlineLarge: display.copyWith(
        fontSize: 34,
        color: c.ink,
      ),
      headlineMedium: display.copyWith(
        fontSize: 28,
        color: c.ink,
      ),
      titleLarge: body.titleLarge?.copyWith(
        fontWeight: FontWeight.w800,
        color: c.ink,
      ),
      titleMedium: body.titleMedium?.copyWith(fontWeight: FontWeight.w800),
      bodyLarge: body.bodyLarge?.copyWith(
        color: c.ink,
        height: 1.45,
      ),
      bodyMedium: body.bodyMedium?.copyWith(
        color: c.ink.withValues(alpha: .82),
        height: 1.4,
      ),
      labelLarge: body.labelLarge?.copyWith(fontWeight: FontWeight.w800),
    ),
    cardTheme: CardThemeData(
      color: c.paper,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(22)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: c.raised.withValues(alpha: .72),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: c.ink.withValues(alpha: .1),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: c.ink.withValues(alpha: .12),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        borderSide: BorderSide(color: c.forest, width: 2),
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
        side: BorderSide(color: c.ink.withValues(alpha: .18)),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: c.ink.withValues(alpha: .1),
      thickness: 1,
    ),
  );
}
