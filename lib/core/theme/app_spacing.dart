/// IBM Carbon Design System — Spacing Scale v11.
/// https://carbondesignsystem.com/elements/spacing/overview/
///
/// Base: 2 px, luego saltos de 4 px hasta s07, luego duplicación.
/// Los tokens de extensión (cardGap, pagePaddingH, sectionGap, iconTileGap)
/// son valores de diseño propio que caen entre pasos Carbon.
abstract final class AppSpacing {
  // ── Escala canonical Carbon (s01 – s13) ─────────────────────────────────
  static const double s01 =   2; // 0.125 rem
  static const double s02 =   4; // 0.25  rem
  static const double s03 =   8; // 0.5   rem
  static const double s04 =  12; // 0.75  rem
  static const double s05 =  16; // 1     rem
  static const double s06 =  24; // 1.5   rem
  static const double s07 =  32; // 2     rem
  static const double s08 =  40; // 2.5   rem
  static const double s09 =  48; // 3     rem
  static const double s10 =  64; // 4     rem
  static const double s11 =  80; // 5     rem
  static const double s12 =  96; // 6     rem
  static const double s13 = 160; // 10    rem

  // ── Aliases semánticos ───────────────────────────────────────────────────
  static const double xs  = s02; //  4 px — badge, micro gap
  static const double sm  = s03; //  8 px — gap inline ajustado
  static const double md  = s05; // 16 px — padding interno estándar
  static const double lg  = s06; // 24 px — padding de sección
  static const double xl  = s07; // 32 px — separación grande
  static const double xxl = s09; // 48 px — espaciado hero

  // ── Extensiones de app (entre pasos Carbon) ──────────────────────────────
  static const double cardGap      = 14; // ícono → texto en tarjetas
  static const double pagePaddingH = 20; // padding horizontal de página
  static const double sectionGap   = 28; // entre secciones principales
  static const double iconTileGap  =  6; // par ícono/etiqueta compacto
}
