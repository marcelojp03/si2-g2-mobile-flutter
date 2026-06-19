import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary = Color(0xFF0D2145);
  static const Color secondary = Color(0xFF1A5276);

  static ThemeData lightTheme() {
    return FlexThemeData.light(
      scheme: FlexScheme.deepBlue,
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 7,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 10,
        defaultRadius: 12,
        cardRadius: 14,
        inputDecoratorRadius: 10,
        dialogRadius: 18,
        chipRadius: 8,
      ),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
      fontFamily: GoogleFonts.inter().fontFamily,
    );
  }

  static ThemeData darkTheme() {
    return FlexThemeData.dark(
      scheme: FlexScheme.deepBlue,
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 13,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 20,
        useMaterial3Typography: true,
        cardRadius: 14,
        inputDecoratorRadius: 10,
        dialogRadius: 18,
        chipRadius: 8,
      ),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
      fontFamily: GoogleFonts.inter().fontFamily,
    );
  }
}
