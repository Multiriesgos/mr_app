import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mr_app/core/theme/app_colors.dart';
import 'package:mr_app/core/theme/app_text_styles.dart';

abstract final class AppTheme {
  static ThemeData get light => _base(AppColors.lightColorScheme);
  static ThemeData get dark  => _base(AppColors.darkColorScheme);

  static ThemeData _base(ColorScheme scheme) {
    final isDark = scheme.brightness == Brightness.dark;
    final alphaHigh   = isDark ? 0.90 : 0.70;
    final alphaMedium = isDark ? 0.80 : 0.60;
    final alphaLow    = isDark ? 0.65 : 0.40;

    return ThemeData(
    useMaterial3:            true,
    colorScheme:             scheme,
    fontFamily:              GoogleFonts.ibmPlexSans().fontFamily,
    scaffoldBackgroundColor: scheme.surface == AppColors.surface
        ? AppColors.background
        : AppColors.darkBackground,
    cardColor:               scheme.surface,
    dividerColor:            scheme.outline,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.sidebarBg,
      foregroundColor: AppColors.surface,
      elevation:       0,
      titleTextStyle:  GoogleFonts.ibmPlexSans(
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
        textStyle: GoogleFonts.ibmPlexSans(
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
          ? AppColors.background
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
      labelStyle:         TextStyle(color: scheme.onSurface.withValues(alpha: alphaMedium)),
      floatingLabelStyle: TextStyle(color: scheme.primary, fontWeight: FontWeight.w500),
      hintStyle:          TextStyle(color: scheme.onSurface.withValues(alpha: alphaLow)),
      prefixIconColor:    scheme.onSurface.withValues(alpha: alphaMedium),
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
      selectedLabelStyle:    GoogleFonts.ibmPlexSans(fontSize: 11, fontWeight: FontWeight.w500),
      unselectedLabelStyle:  GoogleFonts.ibmPlexSans(fontSize: 11),
      type:                  BottomNavigationBarType.fixed,
    ),
    // Carbon v11 productive type scale — sizes/weights/lh/ls from AppTextStyles,
    // color from ColorScheme so dark/light mode works automatically.
    textTheme: GoogleFonts.ibmPlexSansTextTheme().copyWith(
      displayLarge:   AppTextStyles.heading05.copyWith(color: scheme.onSurface, fontWeight: FontWeight.w700),
      displayMedium:  AppTextStyles.heading04.copyWith(color: scheme.onSurface, fontWeight: FontWeight.w700),
      headlineLarge:  AppTextStyles.heading04.copyWith(color: scheme.onSurface, fontWeight: FontWeight.w600),
      headlineMedium: AppTextStyles.heading03.copyWith(color: scheme.onSurface, fontWeight: FontWeight.w600),
      headlineSmall:  AppTextStyles.headingCompact02.copyWith(color: scheme.onSurface, fontSize: 18),
      titleLarge:     AppTextStyles.headingCompact02.copyWith(color: scheme.onSurface),
      titleMedium:    AppTextStyles.headingCompact01.copyWith(color: scheme.onSurface, fontWeight: FontWeight.w500),
      titleSmall:     AppTextStyles.headingCompact01.copyWith(color: scheme.onSurface.withValues(alpha: alphaHigh)),
      bodyLarge:      AppTextStyles.bodyCompact02.copyWith(color: scheme.onSurface),
      bodyMedium:     AppTextStyles.bodyCompact01.copyWith(color: scheme.onSurface),
      bodySmall:      AppTextStyles.label01.copyWith(color: scheme.onSurface.withValues(alpha: alphaHigh)),
      labelLarge:     AppTextStyles.productiveHeading02.copyWith(color: scheme.onSurface),
      labelMedium:    AppTextStyles.label01.copyWith(color: scheme.onSurface.withValues(alpha: alphaHigh)),
      labelSmall:     AppTextStyles.productiveHeading01.copyWith(color: scheme.onSurface.withValues(alpha: alphaHigh)),
    ),
  );
  }
}
