import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF64FFDA), // Cinematic Teal/Cyan
        primary: const Color(0xFF64FFDA), // Force exact primary color
        brightness: Brightness.dark,
        background: const Color(0xFF0F0F0F), // Deep black/grey
        surface: const Color(0xFF1A1A1A),
      ),
      scaffoldBackgroundColor: const Color(0xFF0A0A0A),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
    );
  }
}
