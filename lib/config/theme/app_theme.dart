import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color scaffoldBg = Color(0xFFF6F6EF);
  static const Color primaryDark = Color(0xFF0D2145);
  static const Color secondaryAccent = Color(0xFF1A5276);

  static ThemeData lightTheme() {
    return FlexThemeData.light(
      scheme: FlexScheme.deepBlue,
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 7,
      appBarStyle: FlexAppBarStyle.primary,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 10,
        blendOnColors: false,
        defaultRadius: 14,
        cardRadius: 16,
        cardElevation: 2,
        inputDecoratorRadius: 12,
        dialogRadius: 20,
        chipRadius: 10,
        bottomNavigationBarElevation: 4,
        bottomNavigationBarSelectedIconSize: 26,
        bottomNavigationBarUnselectedIconSize: 22,
      ),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
      fontFamily: GoogleFonts.poppins().fontFamily,
      scaffoldBackground: scaffoldBg,
    );
  }

  static ThemeData darkTheme() {
    return FlexThemeData.dark(
      scheme: FlexScheme.deepBlue,
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 13,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 20,
        blendOnColors: false,
        useMaterial3Typography: true,
        cardRadius: 16,
        cardElevation: 2,
        inputDecoratorRadius: 12,
        dialogRadius: 20,
        chipRadius: 10,
        bottomNavigationBarElevation: 4,
      ),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
      fontFamily: GoogleFonts.poppins().fontFamily,
    );
  }
}
