import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mr_app/core/theme/app_colors.dart';
import 'package:mr_app/core/theme/app_radius.dart';
import 'package:mr_app/core/theme/app_text_styles.dart';

abstract final class AppTheme {
  static ThemeData get light => _base(AppColors.lightColorScheme);
  static ThemeData get dark  => _base(AppColors.darkColorScheme);

  static ThemeData _base(ColorScheme scheme) {
    final isDark = scheme.brightness == Brightness.dark;
    final alphaHigh   = isDark ? 0.90 : 0.70;
    final alphaMedium = isDark ? 0.80 : 0.60;
    final alphaLow    = isDark ? 0.65 : 0.40;
    final scaffoldBg  = isDark ? AppColors.darkBackground : AppColors.background;

    return ThemeData(
      useMaterial3:            true,
      colorScheme:             scheme,
      fontFamily:              GoogleFonts.ibmPlexSans().fontFamily,
      scaffoldBackgroundColor: scaffoldBg,
      cardColor:               scheme.surface,
      dividerColor:            scheme.outline,

      // ── AppBar ────────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.sidebarBg,
        foregroundColor: Colors.white,
        elevation:       0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.ibmPlexSans(
          color: Colors.white,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actionsIconTheme: const IconThemeData(color: Colors.white),
      ),

      // ── Card ──────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color:     scheme.surface,
        elevation: 0,
        margin:    EdgeInsets.zero,
        shape:     RoundedRectangleBorder(
          borderRadius: AppRadius.mdBR,
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),

      // ── Buttons ───────────────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          minimumSize:     const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.smBR),
          elevation: 0,
          textStyle: GoogleFonts.ibmPlexSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          side: BorderSide(color: scheme.primary),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.smBR),
          textStyle: GoogleFonts.ibmPlexSans(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize:  const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.smBR),
          textStyle: GoogleFonts.ibmPlexSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: AppRadius.smBR),
          textStyle: GoogleFonts.ibmPlexSans(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // ── Input ─────────────────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled:      true,
        fillColor:   isDark ? AppColors.darkSurfaceAlt : AppColors.surfaceContainerLow,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
          borderRadius: AppRadius.smBR,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: scheme.outline),
          borderRadius: AppRadius.smBR,
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: scheme.error),
          borderRadius: AppRadius.smBR,
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: scheme.error, width: 1.5),
          borderRadius: AppRadius.smBR,
        ),
        labelStyle:         TextStyle(color: scheme.onSurface.withValues(alpha: alphaMedium)),
        floatingLabelStyle: TextStyle(color: scheme.primary, fontWeight: FontWeight.w500),
        hintStyle:          TextStyle(color: scheme.onSurface.withValues(alpha: alphaLow)),
        prefixIconColor:    scheme.onSurface.withValues(alpha: alphaMedium),
        contentPadding:     const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),

      // ── Dialog ────────────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lgBR),
        titleTextStyle: GoogleFonts.ibmPlexSans(
          color: scheme.onSurface,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: GoogleFonts.ibmPlexSans(
          color: scheme.onSurface.withValues(alpha: alphaHigh),
          fontSize: 15,
        ),
      ),

      // ── Bottom Sheet ──────────────────────────────────────────────────────
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor:      scheme.surface,
        surfaceTintColor:     Colors.transparent,
        elevation:            0,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.topXl),
        showDragHandle:       true,
        dragHandleColor:      scheme.onSurface.withValues(alpha: 0.30),
        dragHandleSize:       const Size(36, 4),
        modalBackgroundColor: scheme.surface,
        modalElevation:       0,
        clipBehavior:         Clip.antiAlias,
      ),

      // ── Snack Bar ─────────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        behavior:         SnackBarBehavior.floating,
        backgroundColor:  isDark ? AppColors.darkSurfaceAlt : AppColors.sidebarBg,
        contentTextStyle: GoogleFonts.ibmPlexSans(color: Colors.white, fontSize: 14),
        shape:            RoundedRectangleBorder(borderRadius: AppRadius.mdBR),
        elevation:        4,
      ),

      // ── Popup Menu ────────────────────────────────────────────────────────
      popupMenuTheme: PopupMenuThemeData(
        color:     scheme.surface,
        elevation: 4,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.smBR,
          side: BorderSide(color: scheme.outlineVariant),
        ),
        textStyle: GoogleFonts.ibmPlexSans(
          color: scheme.onSurface,
          fontSize: 14,
        ),
      ),

      // ── List Tile ─────────────────────────────────────────────────────────
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        minVerticalPadding: 12,
        iconColor: scheme.onSurface.withValues(alpha: alphaMedium),
        titleTextStyle: GoogleFonts.ibmPlexSans(
          color: scheme.onSurface,
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
        subtitleTextStyle: GoogleFonts.ibmPlexSans(
          color: scheme.onSurface.withValues(alpha: alphaMedium),
          fontSize: 13,
        ),
      ),

      // ── Checkbox / Switch ─────────────────────────────────────────────────
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected) ? scheme.primary : null,
        ),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.xsBR),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected) ? scheme.primary : null,
        ),
        trackColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? scheme.primary.withValues(alpha: 0.30)
                : null,
        ),
      ),

      // ── Chip ──────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainerHighest,
        selectedColor:   scheme.primary.withValues(alpha: 0.15),
        labelStyle:      TextStyle(color: scheme.onSurface, fontSize: 13),
        shape:           RoundedRectangleBorder(borderRadius: AppRadius.pillBR),
        padding:         const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        side:            BorderSide(color: scheme.outlineVariant),
      ),

      // ── Badge ─────────────────────────────────────────────────────────────
      badgeTheme: BadgeThemeData(
        backgroundColor: scheme.secondary,
        textColor:       scheme.onSecondary,
        smallSize:       8,
        largeSize:       16,
      ),

      // ── Bottom Navigation Bar ─────────────────────────────────────────────
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor:     scheme.surface,
        selectedItemColor:   scheme.primary,
        unselectedItemColor: scheme.onSurface.withValues(alpha: 0.45),
        showSelectedLabels:    true,
        showUnselectedLabels:  true,
        selectedLabelStyle:    GoogleFonts.ibmPlexSans(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle:  GoogleFonts.ibmPlexSans(fontSize: 11),
        type:                  BottomNavigationBarType.fixed,
        elevation:             0,
      ),

      // ── Divider ───────────────────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color:    scheme.outlineVariant,
        space:    1,
        thickness: 1,
      ),

      // ── Typography ────────────────────────────────────────────────────────
      textTheme: GoogleFonts.ibmPlexSansTextTheme().copyWith(
        displayLarge:   AppTextStyles.heading05.copyWith(color: scheme.onSurface, fontWeight: FontWeight.w700),
        displayMedium:  AppTextStyles.heading04.copyWith(color: scheme.onSurface, fontWeight: FontWeight.w700),
        headlineLarge:  AppTextStyles.heading04.copyWith(color: scheme.onSurface, fontWeight: FontWeight.w600),
        headlineMedium: AppTextStyles.heading03.copyWith(color: scheme.onSurface, fontWeight: FontWeight.w600),
        headlineSmall:  AppTextStyles.headingCompact02.copyWith(color: scheme.onSurface, fontSize: 18),
        titleLarge:     AppTextStyles.headingCompact02.copyWith(color: scheme.onSurface),
        titleMedium:    AppTextStyles.headingCompact01.copyWith(color: scheme.onSurface, fontWeight: FontWeight.w600, fontSize: 15),
        titleSmall:     AppTextStyles.headingCompact01.copyWith(color: scheme.onSurface.withValues(alpha: alphaHigh)),
        bodyLarge:      AppTextStyles.bodyCompact02.copyWith(color: scheme.onSurface, fontSize: 15),
        bodyMedium:     AppTextStyles.bodyCompact01.copyWith(color: scheme.onSurface),
        bodySmall:      AppTextStyles.label01.copyWith(color: scheme.onSurface.withValues(alpha: alphaHigh), fontSize: 13),
        labelLarge:     AppTextStyles.productiveHeading02.copyWith(color: scheme.onSurface, fontSize: 15),
        labelMedium:    AppTextStyles.label01.copyWith(color: scheme.onSurface.withValues(alpha: alphaHigh)),
        labelSmall:     AppTextStyles.overline.copyWith(color: scheme.onSurface.withValues(alpha: alphaHigh)),
      ),
    );
  }
}
