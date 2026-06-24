import 'package:flutter/material.dart';

/// Paleta corporativa Multiriesgos Corp
/// Tokens semánticos alineados con IBM Carbon Design System v11.
/// Referencia: https://carbondesignsystem.com/elements/color/tokens/
abstract final class AppColors {

  // ── Carbon color tokens (base) ───────────────────────────────────────
  // Azules Carbon — Interactive / brand support
  static const Color _cBlue20     = Color(0xFFD0E2FF);
  static const Color _cBlue50     = Color(0xFF4589FF);
  static const Color _cBlue60     = Color(0xFF0F62FE);

  // coolGray Carbon — Text & UI chrome
  static const Color _cCoolGray10 = Color(0xFFF2F4F8);
  static const Color _cCoolGray20 = Color(0xFFDDE1E6);
  static const Color _cCoolGray30 = Color(0xFFC1C7CD);
  static const Color _cCoolGray40 = Color(0xFFA2A9B0);
  static const Color _cCoolGray50 = Color(0xFF878D96);
  static const Color _cCoolGray80 = Color(0xFF343A3F);
  static const Color _cCoolGray90 = Color(0xFF21272A);

  // Gray Carbon — Surfaces
  static const Color _cGray10     = Color(0xFFF4F4F4);

  // Blue Carbon — Info background
  static const Color _cBlue10     = Color(0xFFEDF5FF); // Carbon blue-10

  // Green Carbon — Success
  static const Color _cGreen10    = Color(0xFFDEFBE6);
  static const Color _cGreen50    = Color(0xFF24A148);
  static const Color _cGreen70    = Color(0xFF0E6027);

  // Red Carbon — Error / Danger
  static const Color _cRed10      = Color(0xFFFFF1F1); // Carbon red-10
  static const Color _cRed60      = Color(0xFFDA1E28);
  static const Color _cRed70      = Color(0xFFA2191F);

  // Yellow Carbon — Warning
  static const Color _cYellow10   = Color(0xFFFCF4D6); // Carbon yellow-10
  static const Color _cYellow30   = Color(0xFFF1C21B); // Carbon yellow-30 (icono/borde)
  static const Color _cYellow70   = Color(0xFF8E6A00); // Carbon yellow-70 (texto)

  // ── Azules corporativos ──────────────────────────────────────────────
  static const Color primary      = Color(0xFF1530B8);
  static const Color primaryDark  = Color(0xFF0D1F8A);
  static const Color primaryLight = Color(0xFF2B48D4);
  static const Color accent       = _cBlue50;          // Carbon blue-50  #4589FF
  static const Color accentHover  = _cBlue60;          // Carbon blue-60  #0F62FE
  static const Color sidebarBg    = Color(0xFF060D45);
  static const Color sidebarText  = _cBlue20;          // Carbon blue-20  #D0E2FF

  // ── Texto (Carbon coolGray) ──────────────────────────────────────────
  static const Color textPrimary  = _cCoolGray90;      // #21272A
  static const Color textBody     = _cCoolGray80;      // #343A3F
  static const Color textMuted    = _cCoolGray50;      // #878D96
  static const Color textLight    = _cCoolGray40;      // #A2A9B0
  static const Color textFaint    = _cCoolGray30;      // #C1C7CD

  // ── Fondos y superficies (Carbon White theme) ────────────────────────
  static const Color surface      = Color(0xFFFFFFFF);
  static const Color background   = _cCoolGray10;      // #F2F4F8
  static const Color surfaceAlt   = _cGray10;          // #F4F4F4
  static const Color surfaceTable = _cGray10;          // #F4F4F4

  // ── Bordes (Carbon coolGray) ─────────────────────────────────────────
  static const Color borderLight  = Color(0xFFE8EDF5); // puente coolGray10↔20, tinte azul marca
  static const Color border       = _cCoolGray20;      // #DDE1E6
  static const Color borderInner  = _cCoolGray10;      // #F2F4F8

  // ── Semánticos ───────────────────────────────────────────────────────
  static const Color success      = _cGreen50;         // Carbon green-50  #24A148
  static const Color successBg    = _cGreen10;         // Carbon green-10  #DEFBE6
  static const Color successDark  = _cGreen70;         // Carbon green-70  #0E6027
  static const Color error        = _cRed60;           // Carbon red-60    #DA1E28
  static const Color errorBg      = _cRed10;           // Carbon red-10    #FFF1F1
  static const Color errorDark    = _cRed70;           // Carbon red-70    #A2191F
  static const Color warning      = _cYellow30;        // Carbon yellow-30 #F1C21B
  static const Color warningBg    = _cYellow10;        // Carbon yellow-10 #FCF4D6
  static const Color warningDark  = _cYellow70;        // Carbon yellow-70 #8E6A00
  static const Color info         = _cBlue60;          // Carbon blue-60   #0F62FE
  static const Color infoBg       = _cBlue10;          // Carbon blue-10   #EDF5FF

  // ── Iconos de stat ───────────────────────────────────────────────────
  static const Color statSuccess  = _cGreen50;         // #24A148
  static const Color statWarning  = Color(0xFFCA8A04);
  static const Color statDanger   = _cRed60;           // #DA1E28

  // ── Sombras ──────────────────────────────────────────────────────────
  static const Color shadowBase   = Color(0xFF060D45);

  // ── Dark-mode equivalents ────────────────────────────────────────────
  // Superficies con tinte navy corporativo (no escala gray pura de Carbon)
  static const Color darkSurface     = Color(0xFF1A1F2E);
  static const Color darkBackground  = Color(0xFF0F1420);
  static const Color darkSurfaceAlt  = Color(0xFF242B3D);
  // Texto dark → Carbon coolGray (extremo claro)
  static const Color darkTextPrimary = _cCoolGray10;   // #F2F4F8
  static const Color darkTextBody    = _cCoolGray30;   // #C1C7CD
  static const Color darkTextMuted   = _cCoolGray50;   // #878D96
  static const Color darkBorder      = _cCoolGray80;   // #343A3F

  // ── ColorScheme light ────────────────────────────────────────────────
  static ColorScheme get lightColorScheme => const ColorScheme(
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

  // ── ColorScheme dark ─────────────────────────────────────────────────
  static ColorScheme get darkColorScheme => const ColorScheme(
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

  // ── BoxShadow helpers ────────────────────────────────────────────────
  static List<BoxShadow> get shadowSm => [
    BoxShadow(
      color: shadowBase.withValues(alpha: 0.08),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get shadowMd => [
    BoxShadow(
      color: shadowBase.withValues(alpha: 0.14),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get shadowLg => [
    BoxShadow(
      color: shadowBase.withValues(alpha: 0.20),
      blurRadius: 32,
      offset: const Offset(0, 8),
    ),
  ];

  // ── Login gradient ───────────────────────────────────────────────────
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
