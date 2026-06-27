import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Light Mode Colors ──
  static const _lightPrimary = Color(0xFF004AC6);
  static const _lightPrimaryContainer = Color(0xFF2563EB);
  static const _lightOnPrimary = Color(0xFFFFFFFF);
  static const _lightBackground = Color(0xFFF8F9FF);
  static const _lightSurface = Color(0xFFF8F9FF);
  static const _lightOnSurface = Color(0xFF0B1C30);
  static const _lightOnSurfaceVariant = Color(0xFF434655);
  static const _lightOutline = Color(0xFF737686);
  static const _lightOutlineVariant = Color(0xFFC3C6D7);
  static const _lightError = Color(0xFFBA1A1A);
  static const _lightErrorContainer = Color(0xFFFFDAD6);
  static const _lightSecondary = Color(0xFF5C5F61);
  static const _lightSecondaryContainer = Color(0xFFE0E3E5);
  static const _lightSurfaceContainerHigh = Color(0xFFDCE9FF);
  static const _lightCardBackground = Color(0xFFFFFFFF);

  // ── Dark Mode Colors ──
  static const _darkPrimary = Color(0xFFADC6FF);
  static const _darkPrimaryContainer = Color(0xFF4D8EFF);
  static const _darkOnPrimary = Color(0xFF002E6A);
  static const _darkBackground = Color(0xFF0B1326);
  static const _darkSurface = Color(0xFF0B1326);
  static const _darkSurfaceContainer = Color(0xFF171F33);
  static const _darkSurfaceContainerHigh = Color(0xFF222A3D);
  static const _darkOnSurface = Color(0xFFDAE2FD);
  static const _darkOnSurfaceVariant = Color(0xFFC2C6D6);
  static const _darkOutline = Color(0xFF8C909F);
  static const _darkOutlineVariant = Color(0xFF424754);
  static const _darkError = Color(0xFFFFB4AB);
  static const _darkErrorContainer = Color(0xFF93000A);
  static const _darkSecondary = Color(0xFFB7C8E1);
  static const _darkSecondaryContainer = Color(0xFF3A4A5F);
  static const _darkCardBackground = Color(0xFF222A3D);

  // ── Shared ──
  static const success = Color(0xFF22C55E);
  static const successLight = Color(0xFFDCFCE7);
  static const warning = Color(0xFFF59E0B);

  static TextTheme _textTheme(Color onSurface, Color onSurfaceVariant) {
    return TextTheme(
      displayLarge: GoogleFonts.inter(fontSize: 44, fontWeight: FontWeight.w700, color: onSurface, letterSpacing: -0.5),
      headlineLarge: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, color: onSurface, letterSpacing: -0.25),
      headlineMedium: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w600, color: onSurface),
      titleLarge: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: onSurface),
      titleMedium: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: onSurface),
      bodyLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400, color: onSurface, height: 1.5),
      bodyMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: onSurfaceVariant, height: 1.5),
      labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: onSurface, letterSpacing: 0.1),
      labelMedium: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: onSurfaceVariant),
      labelSmall: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: onSurfaceVariant, letterSpacing: 0.5),
    );
  }

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: _lightPrimary,
      primaryContainer: _lightPrimaryContainer,
      onPrimary: _lightOnPrimary,
      secondary: _lightSecondary,
      secondaryContainer: _lightSecondaryContainer,
      surface: _lightSurface,
      onSurface: _lightOnSurface,
      onSurfaceVariant: _lightOnSurfaceVariant,
      error: _lightError,
      errorContainer: _lightErrorContainer,
      outline: _lightOutline,
      outlineVariant: _lightOutlineVariant,
      surfaceContainerHighest: _lightSurfaceContainerHigh,
    ),
    scaffoldBackgroundColor: _lightBackground,
    textTheme: _textTheme(_lightOnSurface, _lightOnSurfaceVariant),
    cardTheme: CardThemeData(
      color: _lightCardBackground,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      shadowColor: Colors.black.withValues(alpha: 0.06),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _lightPrimary,
        foregroundColor: _lightOnPrimary,
        minimumSize: const Size(double.infinity, 54),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _lightPrimary,
        minimumSize: const Size(double.infinity, 54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        side: const BorderSide(color: _lightOutlineVariant, width: 1.5),
        textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF1F5F9),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: _lightPrimary, width: 2)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: _lightError)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: _lightError, width: 2)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      hintStyle: GoogleFonts.inter(color: _lightOutline, fontSize: 14),
      prefixIconColor: _lightOutline,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: _lightCardBackground,
      selectedItemColor: _lightPrimary,
      unselectedItemColor: _lightOutline,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontSize: 12),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: _lightOnSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: _lightOnSurface),
    ),
    dividerTheme: const DividerThemeData(color: _lightOutlineVariant, thickness: 0.5, space: 0),
    dialogTheme: DialogThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: _darkPrimary,
      primaryContainer: _darkPrimaryContainer,
      onPrimary: _darkOnPrimary,
      secondary: _darkSecondary,
      secondaryContainer: _darkSecondaryContainer,
      surface: _darkSurface,
      onSurface: _darkOnSurface,
      onSurfaceVariant: _darkOnSurfaceVariant,
      error: _darkError,
      errorContainer: _darkErrorContainer,
      outline: _darkOutline,
      outlineVariant: _darkOutlineVariant,
      surfaceContainerHighest: _darkSurfaceContainerHigh,
    ),
    scaffoldBackgroundColor: _darkBackground,
    textTheme: _textTheme(_darkOnSurface, _darkOnSurfaceVariant),
    cardTheme: CardThemeData(
      color: _darkCardBackground,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _darkPrimaryContainer,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 54),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _darkPrimary,
        minimumSize: const Size(double.infinity, 54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        side: const BorderSide(color: _darkOutlineVariant, width: 1.5),
        textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF131B2E),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: _darkOutlineVariant, width: 0.5)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: _darkOutlineVariant, width: 0.5)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: _darkPrimary, width: 2)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: _darkError)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: _darkError, width: 2)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      hintStyle: GoogleFonts.inter(color: _darkOutline, fontSize: 14),
      prefixIconColor: _darkOutline,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: _darkSurfaceContainer,
      selectedItemColor: _darkPrimary,
      unselectedItemColor: _darkOutline,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontSize: 12),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: _darkOnSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: _darkOnSurface),
    ),
    dividerTheme: const DividerThemeData(color: _darkOutlineVariant, thickness: 0.5, space: 0),
    dialogTheme: DialogThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: _darkSurfaceContainerHigh,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}
