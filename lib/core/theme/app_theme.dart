import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Palet warna terpusat. Semua widget membaca warna dari sini
/// (context.palette), bukan dari nilai hardcode.
class AppPalette extends ThemeExtension<AppPalette> {
  final Color background, surface, primary, secondary, text, muted;
  final Color divider, tint, income, expense, warn;
  final List<Color> chartColors;

  const AppPalette({
    required this.background,
    required this.surface,
    required this.primary,
    required this.secondary,
    required this.text,
    required this.muted,
    required this.divider,
    required this.tint,
    required this.income,
    required this.expense,
    required this.warn,
    required this.chartColors,
  });

  static const light = AppPalette(
    background: Color(0xFFF7F5EF),
    surface: Color(0xFFFFFFFF),
    primary: Color(0xFF183C32),
    secondary: Color(0xFFA8B9A0),
    text: Color(0xFF242824),
    muted: Color(0xFF858982),
    divider: Color(0xFFE6E3DA),
    tint: Color(0xFFEDF0E6),
    income: Color(0xFF2F7A52),
    expense: Color(0xFFB5483A),
    warn: Color(0xFFB7791F),
    chartColors: [
      Color(0xFF183C32), Color(0xFF5F8068), Color(0xFFA8B9A0), Color(0xFFB5483A),
      Color(0xFFC98A2B), Color(0xFF7A8B99), Color(0xFF8C6F5A), Color(0xFFC9C3B2),
    ],
  );

  static const dark = AppPalette(
    background: Color(0xFF151B18),
    surface: Color(0xFF202923),
    primary: Color(0xFFB3C9B5),
    secondary: Color(0xFF79947E),
    text: Color(0xFFF0F1EA),
    muted: Color(0xFFA0AAA1),
    divider: Color(0xFF2D3831),
    tint: Color(0xFF2A352D),
    income: Color(0xFF8FD19E),
    expense: Color(0xFFE59A8D),
    warn: Color(0xFFE0B35C),
    chartColors: [
      Color(0xFFB3C9B5), Color(0xFF79947E), Color(0xFF5E7A64), Color(0xFFE59A8D),
      Color(0xFFE0B35C), Color(0xFF93A5B3), Color(0xFFB59A85), Color(0xFF6F7A72),
    ],
  );

  @override
  AppPalette copyWith() => this;

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) =>
      other is AppPalette ? (t < 0.5 ? this : other) : this;
}

extension PaletteX on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;
}

/// Hierarki tipografi (Plus Jakarta Sans).
class AppText {
  static TextStyle balance(BuildContext c) => GoogleFonts.plusJakartaSans(
      fontSize: 36, fontWeight: FontWeight.w600, letterSpacing: -1, color: c.palette.text);
  static TextStyle heading(BuildContext c) => GoogleFonts.plusJakartaSans(
      fontSize: 26, fontWeight: FontWeight.w700, letterSpacing: -0.5, color: c.palette.text);
  static TextStyle section(BuildContext c) => GoogleFonts.plusJakartaSans(
      fontSize: 18, fontWeight: FontWeight.w600, color: c.palette.text);
  static TextStyle body(BuildContext c) => GoogleFonts.plusJakartaSans(
      fontSize: 14.5, fontWeight: FontWeight.w400, color: c.palette.text);
  static TextStyle bodyStrong(BuildContext c) => GoogleFonts.plusJakartaSans(
      fontSize: 14.5, fontWeight: FontWeight.w600, color: c.palette.text);
  static TextStyle caption(BuildContext c) => GoogleFonts.plusJakartaSans(
      fontSize: 12, fontWeight: FontWeight.w400, color: c.palette.muted);
  static TextStyle overline(BuildContext c) => GoogleFonts.plusJakartaSans(
      fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 2, color: c.palette.muted);
}

/// Skala jarak: 4, 8, 12, 16, 24, 32.
class Gap {
  static const double xs = 4, s = 8, m = 12, l = 16, xl = 24, xxl = 32;
}

class AppTheme {
  static ThemeData light() => _build(AppPalette.light, Brightness.light);
  static ThemeData dark() => _build(AppPalette.dark, Brightness.dark);

  static OutlineInputBorder _border(Color c, [double w = 1]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: c, width: w));

  static ThemeData _build(AppPalette p, Brightness b) {
    final onPrimary = b == Brightness.light ? Colors.white : p.background;
    final scheme = ColorScheme.fromSeed(seedColor: p.primary, brightness: b).copyWith(
      primary: p.primary,
      onPrimary: onPrimary,
      secondary: p.secondary,
      surface: p.surface,
      onSurface: p.text,
      error: p.expense,
    );
    final text = GoogleFonts.plusJakartaSansTextTheme(ThemeData(brightness: b).textTheme)
        .apply(bodyColor: p.text, displayColor: p.text);

    Color navColor(Set<WidgetState> s) => s.contains(WidgetState.selected) ? p.primary : p.muted;

    return ThemeData(
      useMaterial3: true,
      brightness: b,
      colorScheme: scheme,
      scaffoldBackgroundColor: p.background,
      textTheme: text,
      extensions: [p],
      dividerTheme: DividerThemeData(color: p.divider, thickness: 1, space: 1),
      appBarTheme: AppBarTheme(
        backgroundColor: p.background,
        foregroundColor: p.text,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.plusJakartaSans(
            fontSize: 18, fontWeight: FontWeight.w600, color: p.text),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: p.surface,
        indicatorColor: p.tint,
        surfaceTintColor: Colors.transparent,
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith((s) => GoogleFonts.plusJakartaSans(
            fontSize: 11.5,
            fontWeight: s.contains(WidgetState.selected) ? FontWeight.w600 : FontWeight.w400,
            color: navColor(s))),
        iconTheme: WidgetStateProperty.resolveWith(
            (s) => IconThemeData(size: 24, color: navColor(s))),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: p.primary,
        foregroundColor: onPrimary,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: p.primary,
          foregroundColor: onPrimary,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: p.primary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.surface,
        border: _border(p.divider),
        enabledBorder: _border(p.divider),
        focusedBorder: _border(p.primary, 1.5),
        errorBorder: _border(p.expense),
        focusedErrorBorder: _border(p.expense, 1.5),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: TextStyle(color: p.muted),
        labelStyle: TextStyle(color: p.muted),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: p.primary,
        contentTextStyle: TextStyle(color: onPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
