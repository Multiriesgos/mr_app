import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mr_app/core/theme/app_colors.dart';

abstract final class AppTheme {
  static ThemeData get light => _base(AppColors.lightColorScheme);
  static ThemeData get dark  => _base(AppColors.darkColorScheme);

  static ThemeData _base(ColorScheme scheme) => ThemeData(
    useMaterial3:            true,
    colorScheme:             scheme,
    fontFamily:              'WorkSans',
    scaffoldBackgroundColor: scheme.surface == AppColors.surface
        ? AppColors.background
        : AppColors.darkBackground,
    cardColor:               scheme.surface,
    dividerColor:            scheme.outline,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.sidebarBg,
      foregroundColor: AppColors.surface,
      elevation:       0,
      titleTextStyle:  GoogleFonts.workSans(
        color: AppColors.surface,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        minimumSize:     const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: GoogleFonts.workSans(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: scheme.primary,
        side: BorderSide(color: scheme.primary),
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled:      true,
      fillColor:   scheme.brightness == Brightness.light
          ? AppColors.surfaceAlt
          : AppColors.darkSurfaceAlt,
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: scheme.primary, width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: scheme.outline),
        borderRadius: BorderRadius.circular(8),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: scheme.error),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: scheme.error, width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      labelStyle:   TextStyle(color: scheme.onSurface.withValues(alpha: 0.6)),
      hintStyle:    TextStyle(color: scheme.onSurface.withValues(alpha: 0.4)),
      prefixIconColor: scheme.onSurface.withValues(alpha: 0.5),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.selected) ? scheme.primary : null,),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: scheme.surfaceContainerHighest,
      selectedColor:   scheme.primary.withValues(alpha: 0.15),
      labelStyle:      TextStyle(color: scheme.onSurface),
    ),
    badgeTheme: BadgeThemeData(
      backgroundColor: scheme.secondary,
      textColor:       scheme.onSecondary,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor:       scheme.surface,
      selectedItemColor:     scheme.primary,
      unselectedItemColor:   scheme.onSurface.withValues(alpha: 0.45),
      showSelectedLabels:    true,
      showUnselectedLabels:  true,
      selectedLabelStyle:    GoogleFonts.workSans(fontSize: 11, fontWeight: FontWeight.w500),
      unselectedLabelStyle:  GoogleFonts.workSans(fontSize: 11),
      type:                  BottomNavigationBarType.fixed,
    ),
    textTheme: GoogleFonts.workSansTextTheme().copyWith(
      displayLarge:  GoogleFonts.workSans(color: scheme.onSurface, fontWeight: FontWeight.w700),
      displayMedium: GoogleFonts.workSans(color: scheme.onSurface, fontWeight: FontWeight.w700),
      headlineLarge: GoogleFonts.workSans(color: scheme.onSurface, fontWeight: FontWeight.w600, fontSize: 24),
      headlineMedium: GoogleFonts.workSans(color: scheme.onSurface, fontWeight: FontWeight.w600, fontSize: 20),
      headlineSmall:  GoogleFonts.workSans(color: scheme.onSurface, fontWeight: FontWeight.w600, fontSize: 18),
      titleLarge:   GoogleFonts.workSans(color: scheme.onSurface, fontWeight: FontWeight.w600, fontSize: 16),
      titleMedium:  GoogleFonts.workSans(color: scheme.onSurface, fontWeight: FontWeight.w500, fontSize: 15),
      titleSmall:   GoogleFonts.workSans(color: scheme.onSurface.withValues(alpha: 0.8), fontWeight: FontWeight.w500, fontSize: 14),
      bodyLarge:    GoogleFonts.workSans(color: scheme.onSurface, fontSize: 15),
      bodyMedium:   GoogleFonts.workSans(color: scheme.onSurface, fontSize: 14),
      bodySmall:    GoogleFonts.workSans(color: scheme.onSurface.withValues(alpha: 0.7), fontSize: 12),
      labelLarge:   GoogleFonts.workSans(color: scheme.onSurface, fontWeight: FontWeight.w600, fontSize: 14),
      labelMedium:  GoogleFonts.workSans(color: scheme.onSurface.withValues(alpha: 0.7), fontSize: 12),
    ),
  );
}
