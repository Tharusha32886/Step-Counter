import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData buildDarkTheme() {
  const seed = Color(0xFF6C63FF); // violetish
  final scheme = ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark);

  final textTheme = GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
    displaySmall: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 44),
    titleLarge: GoogleFonts.inter(fontWeight: FontWeight.w700),
    titleMedium: GoogleFonts.inter(fontWeight: FontWeight.w600),
    bodyMedium: GoogleFonts.inter(),
  );

  return ThemeData(
    brightness: Brightness.dark,
    colorScheme: scheme,
    useMaterial3: true,
    textTheme: textTheme,
    scaffoldBackgroundColor: Colors.transparent,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: const Color(0xFF171921),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      margin: const EdgeInsets.all(14),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1C1F28),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      hintStyle: const TextStyle(color: Colors.white70),
      labelStyle: const TextStyle(color: Colors.white70),
    ),
  );
}
