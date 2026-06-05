import 'package:flutter/material.dart';

/// Paleta corporativa Multiriesgos Corp
/// Fuente: wwwroot/css/site.css  —  Única fuente de verdad de color.
abstract final class AppColors {
  // ── Azules corporativos ────────────────────────────────────────────
  static const Color primary      = Color(0xFF1530B8);
  static const Color primaryDark  = Color(0xFF0D1F8A);
  static const Color primaryLight = Color(0xFF2B48D4);
  static const Color accent       = Color(0xFF4A7AFF);
  static const Color accentHover  = Color(0xFF3366EE);
  static const Color sidebarBg   = Color(0xFF060D45);
  static const Color sidebarText = Color(0xFFBDC8F0);

  // ── Texto y fondos ─────────────────────────────────────────────────
  static const Color textPrimary  = Color(0xFF1A202C);
  static const Color textBody     = Color(0xFF2D3748);
  static const Color textMuted    = Color(0xFF718096);
  static const Color textLight    = Color(0xFFA0AEC0);
  static const Color textFaint    = Color(0xFFCBD5E0);

  static const Color surface      = Color(0xFFFFFFFF);
  static const Color background   = Color(0xFFF0F4F8);
  static const Color surfaceAlt   = Color(0xFFF7FAFC);
  static const Color surfaceTable = Color(0xFFF8FAFC);

  // ── Bordes ─────────────────────────────────────────────────────────
  static const Color borderLight  = Color(0xFFE8EDF5);
  static const Color border       = Color(0xFFE2E8F0);
  static const Color borderInner  = Color(0xFFF0F4F8);

  // ── Semánticos ─────────────────────────────────────────────────────
  static const Color success      = Color(0xFF16A34A);
  static const Color successBg    = Color(0xFFDCFCE7);
  static const Color successDark  = Color(0xFF166534);
  static const Color error        = Color(0xFFDC2626);
  static const Color errorBg      = Color(0xFFFEE2E2);
  static const Color errorDark    = Color(0xFF991B1B);
  static const Color warning      = Color(0xFFCA8A04);
  static const Color warningBg    = Color(0xFFFEF9C3);
  static const Color warningDark  = Color(0xFF854D0E);
  static const Color info         = Color(0xFF2563EB);

  // ── Iconos de stat ─────────────────────────────────────────────────
  static const Color statSuccess  = Color(0xFF16A34A);
  static const Color statWarning  = Color(0xFFCA8A04);
  static const Color statDanger   = Color(0xFFDC2626);

  // ── Sombras ────────────────────────────────────────────────────────
  static const Color shadowBase   = Color(0xFF060D45);

  // ── Dark-mode equivalents ──────────────────────────────────────────
  static const Color darkSurface      = Color(0xFF1A1F2E);
  static const Color darkBackground   = Color(0xFF0F1420);
  static const Color darkSurfaceAlt   = Color(0xFF242B3D);
  static const Color darkTextPrimary  = Color(0xFFF0F4F8);
  static const Color darkTextBody     = Color(0xFFCBD5E0);
  static const Color darkTextMuted    = Color(0xFF718096);
  static const Color darkBorder       = Color(0xFF2D3748);

  // ── ColorScheme light ──────────────────────────────────────────────
  static ColorScheme get lightColorScheme => ColorScheme(
    brightness:              Brightness.light,
    primary:                 primary,
    onPrimary:               surface,
    primaryContainer:        primaryLight,
    onPrimaryContainer:      surface,
    secondary:               accent,
    onSecondary:             surface,
    secondaryContainer:      Color(0x261530B8),
    onSecondaryContainer:    primary,
    tertiary:                info,
    onTertiary:              surface,
    error:                   error,
    onError:                 surface,
    errorContainer:          errorBg,
    onErrorContainer:        errorDark,
    surface:                 surface,
    onSurface:               textBody,
    surfaceContainerHighest: background,
    outline:                 border,
    outlineVariant:          borderLight,
    shadow:                  shadowBase,
    inverseSurface:          sidebarBg,
    onInverseSurface:        surface,
    inversePrimary:          accent,
  );

  // ── ColorScheme dark ───────────────────────────────────────────────
  static ColorScheme get darkColorScheme => ColorScheme(
    brightness:              Brightness.dark,
    primary:                 accent,
    onPrimary:               darkBackground,
    primaryContainer:        primary,
    onPrimaryContainer:      surface,
    secondary:               primaryLight,
    onSecondary:             darkBackground,
    secondaryContainer:      primaryDark,
    onSecondaryContainer:    surface,
    tertiary:                info,
    onTertiary:              darkBackground,
    error:                   Color(0xFFEF5350),
    onError:                 darkBackground,
    errorContainer:          Color(0xFF4A1515),
    onErrorContainer:        Color(0xFFFFCDD2),
    surface:                 darkSurface,
    onSurface:               darkTextBody,
    surfaceContainerHighest: darkBackground,
    outline:                 darkBorder,
    outlineVariant:          Color(0xFF1A2035),
    shadow:                  Colors.black,
    inverseSurface:          surface,
    onInverseSurface:        textBody,
    inversePrimary:          primary,
  );

  // ── BoxShadow helpers ──────────────────────────────────────────────
  static List<BoxShadow> get shadowSm => [
    BoxShadow(
        color: shadowBase.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2)),
  ];

  static List<BoxShadow> get shadowMd => [
    BoxShadow(
        color: shadowBase.withOpacity(0.14), blurRadius: 20, offset: const Offset(0, 4)),
  ];

  static List<BoxShadow> get shadowLg => [
    BoxShadow(
        color: shadowBase.withOpacity(0.20), blurRadius: 32, offset: const Offset(0, 8)),
  ];

  // ── Login gradient ─────────────────────────────────────────────────
  static const LinearGradient loginGradient = LinearGradient(
    begin: Alignment.topLeft,
    end:   Alignment.bottomRight,
    stops: [0.0, 0.45, 0.75, 1.0],
    colors: [
      Color(0xFF060D45),
      Color(0xFF0D1F8A),
      Color(0xFF1530B8),
      Color(0xFF2B48D4),
    ],
  );
}
